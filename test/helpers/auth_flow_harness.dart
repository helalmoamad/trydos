import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/constant/configuration/chat_url_routes.dart';
import 'package:trydos/common/constant/configuration/market_url_routes.dart';
import 'package:trydos/common/constant/configuration/stories_url_routes.dart';
import 'package:trydos/common/constant/configuration/web_app_url.dart';
import 'package:trydos/core/api/log_interceptor.dart';
import 'package:trydos/core/api/token_refresh_coordinator.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/error/error_manager.dart';
import 'package:trydos/features/authentication/data/data_sources/auth_remote_datasource.dart';
import 'package:trydos/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:trydos/features/authentication/domain/repositories/auth_repository.dart';
import 'package:trydos/features/authentication/domain/use_cases/create_user_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/create_wallet_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/delete_fcm_from_chat_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/generating_token_for_comment.dart';
import 'package:trydos/features/authentication/domain/use_cases/get_customer_info_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/get_user_country_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/login_to_chat_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/login_to_stories_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/login_to_wallet_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/refresh_chat_token_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/refresh_comment_token_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/refresh_stories_token_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/refresh_token_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/register_guest_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/send_otp_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/store_fcm_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/update_chat_user_name_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/update_name_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/update_stories_user_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/verify_guest_phone_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/verify_otp_in_profile_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/verify_otp_signin_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/verify_otp_signup_usecase.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/chat/data/data_sources/chat_remote_datasource.dart';
import 'package:trydos/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/chat/presentation/manager/chat_event.dart';
// `dashBoard_event.dart` and `story_event.dart` are `part of` their blocs, so
// their event types arrive with the bloc imports below.
import 'package:trydos/features/dashBoard/presentation/bloc/dashBoard_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/story/presentation/bloc/story_bloc.dart';

import 'auth_fixtures.dart';
import 'network_harness.dart';
import 'session_prefs.dart';

/// Test ledger · wave 02 Account and session — the flow harness.
///
/// The ledger asks for these as **flow tests**: a mocked `Dio` at the bottom and
/// the real repository / use case / bloc chain above it. So this builds the real
/// [AuthBloc] over the real use cases, the real [AuthRepositoryImpl] and the
/// real [AuthRemoteDatasource]; the only thing replaced is the transport and the
/// things `AuthBloc` reaches for through `GetIt`.
///
/// `AuthBloc` talks to four other blocs while it works (home, chat, stories,
/// dashboard). Those are recorded, not run: what matters for these scenarios is
/// **which** event was handed over, not what the other bloc then did with it.

/// Records the events handed to `HomeBloc` instead of running them.
///
/// `implements` plus a throwing `noSuchMethod` is deliberate: a flow that starts
/// depending on more of `HomeBloc` than `add` fails loudly here rather than
/// reading a silent default.
class FakeHomeBloc implements HomeBloc {
  final List<HomeEvent> events = <HomeEvent>[];

  /// The events of one type, in order.
  List<T> eventsOf<T extends HomeEvent>() => events.whereType<T>().toList();

  @override
  void add(HomeEvent event) => events.add(event);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
        'FakeHomeBloc was asked for ${invocation.memberName}, which no test has '
        'set up. Add it here on purpose rather than returning a default.',
      );
}

/// Records the events handed to `ChatBloc`.
class FakeChatBloc implements ChatBloc {
  final List<ChatEvent> events = <ChatEvent>[];

  List<T> eventsOf<T extends ChatEvent>() => events.whereType<T>().toList();

  @override
  void add(ChatEvent event) => events.add(event);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
        'FakeChatBloc was asked for ${invocation.memberName}, which no test has '
        'set up.',
      );
}

/// Records the events handed to `StoryBloc`.
class FakeStoryBloc implements StoryBloc {
  final List<StoryEvent> events = <StoryEvent>[];

  List<T> eventsOf<T extends StoryEvent>() => events.whereType<T>().toList();

  @override
  void add(StoryEvent event) => events.add(event);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
        'FakeStoryBloc was asked for ${invocation.memberName}, which no test '
        'has set up.',
      );
}

/// Records the events handed to `DashboardBloc`.
class FakeDashboardBloc implements DashboardBloc {
  final List<DashBoardEvent> events = <DashBoardEvent>[];

  @override
  void add(DashBoardEvent event) => events.add(event);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
        'FakeDashboardBloc was asked for ${invocation.memberName}, which no '
        'test has set up.',
      );
}

/// Route keys for the paths that two servers share.
///
/// [RoutingAdapter] matches on the whole url, and most endpoint paths are unique
/// enough to use on their own. Three are not:
///
/// * `ChatEndPoints.loginEP` and `StoriesEndPoints.loginEP` are both
///   `api/v1/users/login`, on two different hosts;
/// * the chat refresh borrows `MarketEndPoints.refreshTokenEP`, so the market
///   and chat refreshes share `api/v1/auth/refresh-token`.
///
/// Naming the host is what tells them apart — and a test that asserts on one of
/// these is really asserting the call went to the right server.
abstract final class AuthRoutes {
  static final String chatLogin =
      '${TestServers.chatNest}/${ChatEndPoints.loginEP}';
  static final String storiesLogin =
      '${TestServers.story}${StoriesEndPoints.loginEP}';
  static final String chatRefresh =
      '${TestServers.chatNest}/${MarketEndPoints.refreshTokenEP}';

  /// The market refresh runs against `marketGO`, whose host depends on the
  /// stored phone: a verified number routes to the market host, a guest's "0"
  /// to the marketGO host. Both are listed so a test does not have to care.
  static final String marketRefresh =
      '${TestServers.marketGo}/${MarketEndPoints.refreshTokenEP}';
  static final String marketRefreshVerified =
      '${TestServers.market}/${MarketEndPoints.refreshTokenEP}';

  /// The stories refresh path ends the same way as the market one, so it is
  /// host-qualified for the same reason.
  static final String storiesRefresh =
      '${TestServers.story}${StoriesEndPoints.refreshTokenEP}';
}

/// The routes a full sign-in fans out to.
///
/// One `VerifyOtpSignInEvent` (or sign-up, or guest-verify) does not stop at the
/// market: it goes on to customer-info, the stories login, the chat login and
/// the comments token. A test about one of those still has to answer all of
/// them, or the others fail for a reason it never meant to test.
Map<String, List<ScriptedReply>> fanOutRoutes({
  Map<String, dynamic>? customerInfo,
  ScriptedReply? stories,
  ScriptedReply? chat,
  ScriptedReply? comment,
}) {
  return <String, List<ScriptedReply>>{
    MarketEndPoints.getCustomerInfoEP: <ScriptedReply>[
      ScriptedReply(200, customerInfo ?? customerInfoEnvelope()),
    ],
    AuthRoutes.storiesLogin: <ScriptedReply>[
      stories ?? ScriptedReply(200, storiesLoginEnvelope()),
    ],
    AuthRoutes.chatLogin: <ScriptedReply>[
      chat ?? ScriptedReply(200, chatLoginEnvelope()),
    ],
    WebAppEndPoints.generateTokenForCommentEP: <ScriptedReply>[
      comment ?? ScriptedReply(200, commentTokenEnvelope()),
    ],
    // Both fcm registrations, so a device-token call never falls through to the
    // 404 fallback and drags a retry into an unrelated assertion.
    ChatEndPoints.storeFcmEP: <ScriptedReply>[
      const ScriptedReply(200, <String, dynamic>{
        'data': <String, dynamic>{'id': 1},
      }),
    ],
    MarketEndPoints.storeFcmEP: <ScriptedReply>[
      const ScriptedReply(200, <String, dynamic>{
        'data': <String, dynamic>{'id': 1},
      }),
    ],
  };
}

/// Everything one account-flow test needs, wired together.
class AuthFlowHarness {
  AuthFlowHarness({
    required this.bloc,
    required this.adapter,
    required this.prefs,
    required this.home,
    required this.chat,
    required this.story,
    required this.dashboard,
    required this.emitted,
    required this.subscription,
  });

  final AuthBloc bloc;
  final RoutingAdapter adapter;
  final SessionPrefs prefs;
  final FakeHomeBloc home;
  final FakeChatBloc chat;
  final FakeStoryBloc story;
  final FakeDashboardBloc dashboard;

  /// Every state the bloc has been in, starting with the one it was built with.
  final List<AuthState> emitted;

  final StreamSubscription<AuthState> subscription;

  /// The values one status field took, in order, with repeats collapsed.
  ///
  /// Asserting only the final state cannot tell "went loading, then succeeded"
  /// from "jumped straight to success" — and a handler that stops emitting
  /// `loading` leaves every spinner in the app running forever. This is what
  /// makes that difference visible.
  List<T> transitionsOf<T>(T Function(AuthState state) read) {
    final List<T> out = <T>[];
    for (final AuthState state in emitted) {
      final T value = read(state);
      if (out.isEmpty || out.last != value) out.add(value);
    }
    return out;
  }
}

bool _firebaseReady = false;

/// Gives `Firebase.app()` something to return.
///
/// `AuthBloc` reports the signed-in user to Firebase Analytics. In sign-up that
/// call is **not** wrapped in a try/catch, so without a Firebase app the whole
/// handler throws before it finishes storing the session — the test would fail
/// for a reason that has nothing to do with the behaviour under test. The mock
/// only makes `Firebase.app()` answer; the analytics calls themselves go to a
/// method channel that nothing is listening on, and return null.
Future<void> setUpFirebaseMocks() async {
  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();

  // `showMessage` falls back to a toast whenever there is no navigator — which
  // is always, in a unit test. `Fluttertoast.cancel()` then throws
  // `MissingPluginException` on a future nobody awaits, and an unhandled async
  // error fails the test that happened to be running. Answering the channel
  // keeps the failure paths reportable.
  // The analytics calls in sign-in / sign-up / register-guest are not awaited
  // and, in sign-up, not wrapped either: a `MissingPluginException` from the
  // channel would fail the test from outside the code under test. The bloc only
  // ever tells analytics about the user, never reads back, so answering null is
  // the whole contract these tests need.
  for (final String channel in <String>[
    'PonnamKarthik/fluttertoast',
    'plugins.flutter.io/firebase_analytics',
    'plugins.flutter.io/firebase_messaging',
  ]) {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      MethodChannel(channel),
      (MethodCall call) async => null,
    );
  }

  if (_firebaseReady) return;
  setupFirebaseCoreMocks();
  await Firebase.initializeApp();
  _firebaseReady = true;
}

/// Builds the real `AuthBloc` over a routed, mocked transport.
///
/// [routes] maps a piece of an endpoint path to the replies that endpoint gives,
/// in order. Seed [prefs] to describe the session the flow starts from.
AuthFlowHarness buildAuthFlowHarness({
  required Map<String, List<ScriptedReply>> routes,
  SessionPrefs? prefs,
}) {
  loadTestEnv();
  // `ErrorManager` keeps its retry counters in process-wide statics with no
  // reset of its own. Left alone, a test that made an event retry would decide
  // whether the *next* test's event retries at all.
  ErrorManager.clearAllRetries();

  final SessionPrefs prefsFake = prefs ?? SessionPrefs();
  // `NotificationProcess.fcmToken` asks Firebase Messaging for a token whenever
  // the stored list has none longer than six characters, and Firebase Messaging
  // cannot answer in a unit test. A stored token short-circuits that branch, so
  // seed one unless the test set its own.
  if (prefsFake.getFcmTokens.isEmpty) {
    prefsFake.fcmTokens.add('seeded-fcm-token');
  }

  final RoutingAdapter adapter = RoutingAdapter(routes);

  final Dio dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  dio.httpClientAdapter = adapter;

  final FakeHomeBloc home = FakeHomeBloc();
  final FakeChatBloc chat = FakeChatBloc();
  final FakeStoryBloc story = FakeStoryBloc();
  final FakeDashboardBloc dashboard = FakeDashboardBloc();

  // `BaseApi` resolves the prefs and the Dio in its constructor, and the bloc
  // resolves the prefs in a field initialiser, so everything must be registered
  // before the bloc is built.
  GetIt.I.registerSingleton<PrefsRepository>(prefsFake);
  GetIt.I.registerSingleton<Dio>(dio);
  GetIt.I.registerSingleton<HomeBloc>(home);
  GetIt.I.registerSingleton<ChatBloc>(chat);
  GetIt.I.registerSingleton<StoryBloc>(story);
  GetIt.I.registerSingleton<DashboardBloc>(dashboard);

  final AuthRepository repository = AuthRepositoryImpl(AuthRemoteDatasource());
  // `CreateUserEvent` is the one account event that does not go through the
  // auth repository: creating the chat-side user belongs to the chat feature,
  // so its use case takes a `ChatRepository`.
  final ChatRepository chatRepository = ChatRepositoryImpl(
    ChatRemoteDataSource(),
  );

  final AuthBloc bloc = AuthBloc(
    UpdateStoriesUserUseCase(repository),
    UpdateChatUserNameUseCase(repository),
    CreateUserUseCase(chatRepository),
    LoginToChatUseCase(repository),
    LoginToStoriesUseCase(repository),
    StoreFcmUseCase(repository),
    VerifyOtpInProfileUseCase(repository),
    UpdateNameUseCase(repository),
    RefreshChatTokenUseCase(repository),
    RegisterGuestUseCase(repository),
    CreateWalletUseCase(repository),
    LoginToWalletUseCase(repository),
    GeneratingTokenForCommentUseCase(repository),
    SendOtpUseCase(repository),
    GetCustomerInfoUseCase(repository),
    VerifyOtpFromGuestUseCase(repository),
    VerifyOtpSignInUseCase(repository),
    GetUserCountryUseCase(repository),
    DeleteFcmFromChatUseCase(repository),
    VerifyOtpSignUpUseCase(repository),
    RefreshTokenUseCase(repository),
    RefreshStoriesTokenUseCase(repository),
    RefreshCommentTokenUseCase(repository),
  );

  // Recorded from the state the bloc was built with, so a sequence reads
  // `[init, loading, success]` rather than starting mid-flow.
  final List<AuthState> emitted = <AuthState>[bloc.state];
  final StreamSubscription<AuthState> subscription =
      bloc.stream.listen(emitted.add);

  // `NotificationProcess` reaches back for the bloc through GetIt.
  GetIt.I.registerSingleton<AuthBloc>(bloc);

  // The interceptor is not optional scenery — it is what keeps a status code
  // alive. Dio treats every non-2xx as an exception; `PostClient`'s `catchError`
  // then returns the exception where a `Response` belongs, which throws an
  // `ArgumentError`, and the generic catch in `handlingExceptionRequest` turns
  // *every* failure into `ServerFailure(400)`. `LoggerInterceptor.onError`
  // resolves the error back into a `Response` carrying the real status, so the
  // handlers see the 401 / 500 they branch on. Without it these tests would be
  // green against a code path the app never runs.
  //
  // It is added last because it resolves `PrefsRepository` when it is built and
  // reaches for `AuthBloc` and `Dio` while handling a 401.
  dio.interceptors.add(LoggerInterceptor());

  return AuthFlowHarness(
    bloc: bloc,
    adapter: adapter,
    prefs: prefsFake,
    home: home,
    chat: chat,
    story: story,
    dashboard: dashboard,
    emitted: emitted,
    subscription: subscription,
  );
}

/// Closes the bloc, drains the refresh coordinator (a process-wide singleton
/// with no reset hook) and clears the registrations.
Future<void> tearDownAuthFlowHarness(AuthFlowHarness? harness) async {
  await harness?.subscription.cancel();
  await harness?.bloc.close();
  for (final RefreshScope scope in RefreshScope.values) {
    TokenRefreshCoordinator.instance.complete(scope, false);
  }
  await Future<void>.delayed(Duration.zero);
  await GetIt.I.reset();
}
