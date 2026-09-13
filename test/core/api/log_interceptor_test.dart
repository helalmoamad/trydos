import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trydos/core/api/log_interceptor.dart';
import 'package:trydos/core/api/token_refresh_coordinator.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';

import '../../helpers/network_harness.dart';

/// Captures whatever the interceptor does with an error.
///
/// `ErrorInterceptorHandler` completes a future the package keeps to itself, so
/// these overrides record the decision and deliberately skip `super`: no real
/// Dio call is waiting on this handler.
class _RecordingHandler extends ErrorInterceptorHandler {
  final Completer<Response<dynamic>> _completer =
      Completer<Response<dynamic>>();

  /// The response the interceptor resolved with, or the error it passed on.
  Future<Response<dynamic>> get outcome => _completer.future;

  @override
  void resolve(Response<dynamic> response) {
    if (!_completer.isCompleted) _completer.complete(response);
  }

  @override
  void next(DioException error) {
    if (!_completer.isCompleted) _completer.completeError(error);
  }

  @override
  void reject(DioException error) {
    if (!_completer.isCompleted) _completer.completeError(error);
  }
}

/// Test ledger · wave 01 Core runtime · unit "401 refresh and replay".
///
/// Every logged-in action in the app runs through this. When a token expires the
/// user must see the real answer, not the 401 — the request is replayed behind
/// their back. If that breaks, the app logs people out at random; if the loop
/// guard breaks, one expired token turns into an endless refresh storm.
///
/// The interceptor resolves errors into responses rather than throwing, so a
/// failed call arrives as a `Response` whose body is an error envelope.
void main() {
  tearDown(tearDownNetworkHarness);

  /// Drives `onError` directly, for the branches a live Dio call cannot reach.
  ///
  /// Dio keeps the handler's own future package-private, so this records what
  /// the interceptor decided instead of reaching inside it.
  Future<Response<dynamic>> driveOnError(DioException error) {
    final _RecordingHandler handler = _RecordingHandler();
    LoggerInterceptor().onError(error, handler);
    return handler.outcome;
  }

  DioException unauthorizedInBody(String path) {
    final RequestOptions options = RequestOptions(path: path);
    return DioException(
      requestOptions: options,
      response: Response<dynamic>(
        requestOptions: options,
        statusCode: 200,
        data: const <String, dynamic>{
          'statusCode': '401',
          'message': 'Unauthenticated',
        },
      ),
    );
  }

  test('a 401 by HTTP status starts a refresh', () async {
    final NetworkHarness harness = buildNetworkHarness(
      replies: <ScriptedReply>[
        const ScriptedReply.unauthorized(),
        const ScriptedReply(200, <String, dynamic>{'ok': true}),
      ],
    );
    harness.prefs.marketTokenValue = 'fresh-market-token';

    await harness.dio.get<dynamic>('${TestServers.market}/orders');

    expect(harness.auth.refreshEvents, hasLength(1));
    expect(harness.auth.refreshEvents.single, isA<RefreshTokenEvent>());
  });

  test('a 401 carried in the body with a 200 transport status also refreshes',
      () async {
    // Defensive branch: a live 200 passes `validateStatus`, so `onError` never
    // runs for it. Driven directly, which is the only way to reach the code.
    final NetworkHarness harness = buildNetworkHarness(
      replies: <ScriptedReply>[
        const ScriptedReply(200, <String, dynamic>{'ok': true}),
      ],
    );
    harness.prefs.marketTokenValue = 'fresh-market-token';

    await driveOnError(unauthorizedInBody('${TestServers.market}/profile'));

    expect(harness.auth.refreshEvents, hasLength(1),
        reason: 'the body said 401 even though the transport said 200');
  });

  test('a 401 on the refresh call itself joins the refresh already running',
      () async {
    // There is no "do not refresh the refresh" check in the interceptor. What
    // stops the loop is the coordinator: a second ask for a scope already in
    // flight returns the running future and never dispatches again.
    final NetworkHarness harness = buildNetworkHarness(
      replies: <ScriptedReply>[
        const ScriptedReply(200, <String, dynamic>{'ok': true}),
      ],
      auth: FakeAuthBloc(answersTheCoordinator: false),
    );
    harness.prefs.marketTokenValue = 'fresh-market-token';

    int dispatched = 0;
    final Future<bool> running = TokenRefreshCoordinator.instance
        .refresh(RefreshScope.market, () => dispatched++);
    expect(dispatched, 1);

    final _RecordingHandler handler = _RecordingHandler();
    final RequestOptions options =
        RequestOptions(path: '${TestServers.market}/auth/refresh');
    LoggerInterceptor().onError(
      DioException(
        requestOptions: options,
        response: Response<dynamic>(requestOptions: options, statusCode: 401),
      ),
      handler,
    );
    await Future<void>.delayed(Duration.zero);

    expect(dispatched, 1, reason: 'the running refresh was joined, not restarted');
    expect(harness.auth.refreshEvents, isEmpty,
        reason: 'AuthBloc must not be asked for a second refresh');

    TokenRefreshCoordinator.instance.complete(RefreshScope.market, true);
    await handler.outcome;
    await running;
  });

  test('a request already replayed reports the error instead of refreshing again',
      () async {
    final NetworkHarness harness = buildNetworkHarness(
      replies: <ScriptedReply>[const ScriptedReply.unauthorized()],
    );
    harness.prefs.marketTokenValue = 'fresh-market-token';

    // The interceptor stamps this key on a request it replays.
    final RequestOptions options = RequestOptions(
      path: '${TestServers.market}/orders',
      extra: <String, dynamic>{'wf_retried_after_refresh': true},
    );
    final Response<dynamic> resolved = await driveOnError(
      DioException(
        requestOptions: options,
        response: Response<dynamic>(requestOptions: options, statusCode: 401),
      ),
    );

    expect(harness.auth.refreshEvents, isEmpty,
        reason: 'a second 401 on the same request must not refresh again');
    expect(resolved.statusCode, 401);
    expect((resolved.data as Map<String, dynamic>)['error_code'], 401);
  });

  test('after a successful refresh the caller sees the real answer, not the 401',
      () async {
    final NetworkHarness harness = buildNetworkHarness(
      replies: <ScriptedReply>[
        const ScriptedReply.unauthorized(),
        const ScriptedReply(200, <String, dynamic>{
          'orders': <int>[7, 8],
        }),
      ],
    );
    harness.prefs.marketTokenValue = 'fresh-market-token';

    final Response<dynamic> response =
        await harness.dio.get<dynamic>('${TestServers.market}/orders');

    expect(response.statusCode, 200);
    expect(response.data, <String, dynamic>{
      'orders': <int>[7, 8],
    });
    expect(harness.adapter.callCount, 2, reason: 'sent once, then replayed');
    expect(harness.adapter.sentAuthHeaders[1], 'Bearer fresh-market-token',
        reason: 'the replay must carry the NEW token, not the rejected one');
  });

  test('a multipart body is rebuilt from its sources before the replay',
      () async {
    // A FormData stream is single use: the first attempt drains it, so resending
    // the same object would upload empty parts and the server would answer 200,
    // hiding the loss.
    final NetworkHarness harness = buildNetworkHarness(
      replies: <ScriptedReply>[
        const ScriptedReply.unauthorized(),
        const ScriptedReply(200, <String, dynamic>{'uploaded': true}),
      ],
    );
    harness.prefs.marketTokenValue = 'fresh-market-token';

    await harness.dio.post<dynamic>(
      '${TestServers.media}/gated/ticket',
      data: FormData.fromMap(<String, dynamic>{'name': 'photo.jpg'}),
    );

    expect(harness.adapter.sentBodies, hasLength(2));
    expect(harness.adapter.sentBodies[0], isA<FormData>());
    expect(harness.adapter.sentBodies[1], isA<FormData>());
    expect(
      identical(harness.adapter.sentBodies[0], harness.adapter.sentBodies[1]),
      isFalse,
      reason: 'the replay must carry a clone, not the drained original',
    );
  });

  test('a failed refresh reports the original 401 unchanged', () async {
    final NetworkHarness harness = buildNetworkHarness(
      replies: <ScriptedReply>[const ScriptedReply.unauthorized()],
      auth: FakeAuthBloc(refreshSucceeds: false),
    );

    final Response<dynamic> response =
        await harness.dio.get<dynamic>('${TestServers.market}/orders');

    expect(response.statusCode, 401);
    expect((response.data as Map<String, dynamic>)['error_code'], 401);
    expect(harness.adapter.callCount, 1,
        reason: 'nothing to retry with, so no replay');
  });

  test('the right RefreshScope is picked per server', () async {
    // Asserting the dispatched event alone is not enough: the event names the
    // work, the SCOPE names the mailbox the answer arrives in. Give the
    // interceptor the wrong scope and it still dispatches the right event, then
    // waits on a mailbox nobody posts to and times out. So the check below runs
    // all the way through to the replay — which only happens when the scope, the
    // event and the token the branch reads all agree.
    Future<void> expectScope(
      String baseUrl,
      TypeMatcher<Object> event,
      String expectedToken,
    ) async {
      final NetworkHarness harness = buildNetworkHarness(
        replies: <ScriptedReply>[
          const ScriptedReply.unauthorized(),
          const ScriptedReply(200, <String, dynamic>{'ok': true}),
        ],
      );
      harness.prefs
        ..marketTokenValue = 'market-token'
        ..chatTokenValue = 'chat-token'
        ..storiesTokenValue = 'stories-token'
        ..commentTokenValue = 'comment-token';

      final Response<dynamic> response =
          await harness.dio.get<dynamic>('$baseUrl/x');

      expect(harness.auth.refreshEvents.single, event, reason: baseUrl);
      expect(response.statusCode, 200, reason: '$baseUrl was never replayed');
      expect(harness.adapter.callCount, 2, reason: baseUrl);
      expect(harness.adapter.sentAuthHeaders[1], 'Bearer $expectedToken',
          reason: '$baseUrl must replay with its own refreshed token');

      await tearDownNetworkHarness();
    }

    // The three market-family hosts share one access token, so one scope.
    await expectScope(
        TestServers.market, isA<RefreshTokenEvent>(), 'market-token');
    await expectScope(
        TestServers.marketGo, isA<RefreshTokenEvent>(), 'market-token');
    await expectScope(
        TestServers.media, isA<RefreshTokenEvent>(), 'market-token');

    await expectScope(
        TestServers.chatNest, isA<RefreshChatTokenEvent>(), 'chat-token');
    await expectScope(
        TestServers.story, isA<RefreshStoriesTokenEvent>(), 'stories-token');
    await expectScope(
        TestServers.comment, isA<RefreshCommentTokenEvent>(), 'comment-token');

    // Wallet is the odd one out: it clears its token and never refreshes.
    final NetworkHarness wallet = buildNetworkHarness(
      replies: <ScriptedReply>[const ScriptedReply.unauthorized()],
    );
    await wallet.dio.get<dynamic>('${TestServers.wallet}/balance');
    expect(wallet.auth.refreshEvents, isEmpty);
    expect(wallet.prefs.walletTokenSetTo, '',
        reason: 'the wallet token is cleared, not renewed');
  });
}
