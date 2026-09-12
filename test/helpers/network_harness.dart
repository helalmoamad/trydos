import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/core/api/log_interceptor.dart';
import 'package:trydos/core/api/token_refresh_coordinator.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
// `auth_event.dart` is a `part of` the bloc, so the events arrive with it.
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';

/// Base urls for the tests, one clearly distinct host per server.
///
/// The interceptor picks its branch with `path.contains(dotenv.env[key]!)`, so
/// two hosts that share a prefix would let the wrong branch match first and the
/// test would still pass for the wrong reason. `marketgo.test` deliberately does
/// not contain `https://market.test`.
class TestServers {
  const TestServers._();

  static const String story = 'https://story.test';
  static const String wallet = 'https://wallet.test';
  static const String chatNest = 'https://chatnest.test';
  static const String comment = 'https://comment.test';
  static const String market = 'https://market.test';
  static const String marketGo = 'https://marketgo.test';
  static const String media = 'https://media.test';
  static const String elastic = 'https://elastic.test';

  /// The catalogue: listings, filters, product pages. Wave 03 is the first to
  /// call it — `WebUrls` reads `WEB_APP` with a `!`, so without this key every
  /// catalogue request threw before it reached the wire and came back as a
  /// generic 400.
  static const String webApp = 'https://webapp.test';
}

/// `BaseApi`, `detect_server` and the interceptor all read dotenv at call time
/// and throw on a missing key, so every key the code touches must be present.
void loadTestEnv() {
  dotenv.testLoad(
    fileInput: '''
STORY_URL=${TestServers.story}
WALLET_URL=${TestServers.wallet}
CHAT_NEST_URL=${TestServers.chatNest}
COMMENT_TOKEN_URL=${TestServers.comment}
MARKET_URL=${TestServers.market}
MARKETGo_URL=${TestServers.marketGo}
MEDIA_SERVER_URL=${TestServers.media}
ELASTIC_URL=${TestServers.elastic}
WEB_APP=${TestServers.webApp}
''',
  );
}

/// One canned HTTP answer.
class ScriptedReply {
  const ScriptedReply(this.statusCode, [this.body, this.delay = Duration.zero]);

  const ScriptedReply.unauthorized()
      : statusCode = 401,
        body = const <String, dynamic>{'error': 'Unauthorized'},
        delay = Duration.zero;

  final int statusCode;
  final Object? body;

  /// How long the server takes to answer.
  ///
  /// Zero for almost every test. It exists for the one question a reply that
  /// arrives at once cannot ask: what happens when an **old** request answers
  /// *after* a newer one — a listing whose filters changed while the first
  /// search was still in flight. Written for wave 03's "a late response must
  /// not overwrite the new list".
  final Duration delay;
}

/// Answers requests from a fixed script and records what it was actually sent.
///
/// The last reply repeats if more requests arrive than the script holds, so a
/// test that accidentally loops fails on its assertions rather than hanging.
class ScriptedAdapter implements HttpClientAdapter {
  ScriptedAdapter(this.replies);

  final List<ScriptedReply> replies;

  /// What reached the wire, in order. `sentBodies` keeps the object itself so a
  /// test can prove a multipart body was rebuilt rather than resent.
  final List<String> sentPaths = <String>[];
  final List<String?> sentAuthHeaders = <String?>[];
  final List<Object?> sentBodies = <Object?>[];

  int get callCount => sentPaths.length;

  int _index = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    sentPaths.add(options.path);
    sentAuthHeaders.add(
      options.headers[HttpHeaders.authorizationHeader] as String?,
    );
    sentBodies.add(options.data);

    final ScriptedReply reply =
        replies[_index < replies.length ? _index : replies.length - 1];
    _index++;

    return ResponseBody.fromString(
      jsonEncode(reply.body ?? const <String, dynamic>{}),
      reply.statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Answers each request from the route whose key the request url contains, and
/// records everything that reached the wire.
///
/// [ScriptedAdapter] replies in call order, which is right for a test that
/// drives one request at a time. An account flow does not work that way: one
/// event fans out into several requests across four servers, and the order they
/// finish in is not something a test should have to predict. Here each route
/// gets its own queue, so a test says *what each endpoint answers* and then
/// asserts on what was actually asked.
///
/// A request that matches no route gets [fallback] — 404 by default, so a path
/// nobody scripted shows up as a failed call instead of a silent success.
class RoutingAdapter implements HttpClientAdapter {
  RoutingAdapter(
    Map<String, List<ScriptedReply>> routes, {
    this.fallback = const ScriptedReply(404, <String, dynamic>{
      'message': 'no route scripted for this path',
    }),
  }) : _routes = routes;

  final Map<String, List<ScriptedReply>> _routes;
  final ScriptedReply fallback;

  /// What reached the wire, in order.
  final List<String> sentPaths = <String>[];
  final List<String?> sentAuthHeaders = <String?>[];
  final List<Object?> sentBodies = <Object?>[];
  final List<Map<String, dynamic>> sentHeaders = <Map<String, dynamic>>[];

  /// Which route answered each request, in the same order as [sentPaths].
  final List<String?> matchedRoutes = <String?>[];

  final Map<String, int> _cursors = <String, int>{};

  int get callCount => sentPaths.length;

  /// How many requests this route answered.
  int callsTo(String route) =>
      matchedRoutes.where((String? r) => r == route).length;

  /// The body of the [index]-th request that reached [route].
  Object? bodyOf(String route, {int index = 0}) =>
      _pick(sentBodies, route, index);

  /// The bearer header the [index]-th request to [route] carried, if any.
  String? authOf(String route, {int index = 0}) =>
      _pick(sentAuthHeaders, route, index) as String?;

  /// Every header the [index]-th request to [route] carried.
  Map<String, dynamic>? headersOf(String route, {int index = 0}) =>
      _pick(sentHeaders, route, index) as Map<String, dynamic>?;

  /// The full url of the [index]-th request to [route] — the host is what
  /// proves a call went to the server it was meant for.
  String? urlOf(String route, {int index = 0}) =>
      _pick(sentPaths, route, index) as String?;

  /// The query string of the [index]-th request to [route], decoded.
  ///
  /// The catalogue is all GETs: `searchInCatalog` answers both the product list
  /// and the filter facets, from the same path. What a request *asked for* —
  /// which brands, which sort, which page — lives only here.
  Map<String, String>? queryOf(String route, {int index = 0}) {
    final String? url = urlOf(route, index: index);
    return url == null ? null : Uri.parse(url).queryParameters;
  }

  Object? _pick(List<Object?> from, String route, int index) {
    int seen = 0;
    for (int i = 0; i < matchedRoutes.length; i++) {
      if (matchedRoutes[i] != route) continue;
      if (seen == index) return from[i];
      seen++;
    }
    return null;
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final String url = options.uri.toString();
    sentPaths.add(url);
    sentAuthHeaders.add(
      options.headers[HttpHeaders.authorizationHeader] as String?,
    );
    sentBodies.add(options.data);
    sentHeaders.add(Map<String, dynamic>.from(options.headers));

    String? matched;
    for (final String route in _routes.keys) {
      if (url.contains(route)) {
        matched = route;
        break;
      }
    }
    matchedRoutes.add(matched);

    ScriptedReply reply = fallback;
    if (matched != null) {
      final List<ScriptedReply> queue = _routes[matched]!;
      final int cursor = _cursors[matched] ?? 0;
      // The last reply repeats, so a flow that retries does not fall off the
      // end of the script and start answering 404 for no stated reason.
      reply = queue[cursor < queue.length ? cursor : queue.length - 1];
      _cursors[matched] = cursor + 1;
    }

    if (reply.delay > Duration.zero) {
      await Future<void>.delayed(reply.delay);
    }

    return ResponseBody.fromString(
      jsonEncode(reply.body ?? const <String, dynamic>{}),
      reply.statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Stands in for stored preferences. Only the members the network layer touches
/// are implemented; anything else throws, so a test that quietly starts
/// depending on more state fails loudly instead of reading a silent default.
class FakePrefs implements PrefsRepository {
  String? marketTokenValue;
  String? chatTokenValue;
  String? storiesTokenValue;
  String? commentTokenValue;
  String? walletTokenValue;
  String? phoneNumberValue;

  /// Set by the wallet branch, which clears its token instead of refreshing.
  String? walletTokenSetTo;

  @override
  String? get marketToken => marketTokenValue;

  @override
  String? get chatToken => chatTokenValue;

  @override
  String? get storiesToken => storiesTokenValue;

  @override
  String? get tokenForComment => commentTokenValue;

  @override
  String? get walletToken => walletTokenValue;

  @override
  String? get myPhoneNumber => phoneNumberValue;

  // Read by `BaseApi` when it builds the country, seller and elastic headers.
  int? userCountryIsAvailableValue;
  String? userChoosedCountryIsoValue;
  String? countryIsoValue;
  String? myMarketIdValue;
  String? xSellerIdValue;

  @override
  int? get userCountryIsAvailable => userCountryIsAvailableValue;

  @override
  String? get userChoosedCountryIso => userChoosedCountryIsoValue;

  @override
  String? get countryIso => countryIsoValue;

  @override
  String? get myMarketId => myMarketIdValue;

  @override
  String? get getXSellerId => xSellerIdValue;

  @override
  Future<bool> setWalletToken(String token) async {
    walletTokenSetTo = token;
    return true;
  }

  @override
  void saveRequestsData(
    String? url,
    Map<String, dynamic>? response,
    Map<String, dynamic>? headers,
    int? statusCode,
    String? request,
    Map<String, dynamic>? query,
    Map<String, dynamic>? body, {
    String? error,
    String? responseTime,
  }) {
    // The interceptor logs every request and error through here; the tests do
    // not assert on it, they only need it not to blow up.
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
        'FakePrefs was asked for ${invocation.memberName}, which no test has '
        'set up. Add it here on purpose rather than returning a default.',
      );
}

/// Stands in for `AuthBloc`.
///
/// The real bloc answers [TokenRefreshCoordinator] when its refresh finishes.
/// This fake does the same thing synchronously, which is what lets a test say
/// "the refresh succeeded" or "the refresh failed" without a real backend.
class FakeAuthBloc implements AuthBloc {
  FakeAuthBloc({this.refreshSucceeds = true, this.answersTheCoordinator = true});

  /// What the simulated refresh reports back.
  bool refreshSucceeds;

  /// When false the refresh is left hanging, so a test can control the moment
  /// it resolves.
  bool answersTheCoordinator;

  /// Makes `add` throw the way a closed bloc does.
  bool isClosed = false;

  final List<AuthEvent> events = <AuthEvent>[];

  /// The refresh events only, in order — what most assertions care about.
  List<AuthEvent> get refreshEvents =>
      events.where((AuthEvent e) => scopeOf(e) != null).toList();

  static RefreshScope? scopeOf(AuthEvent event) {
    if (event is RefreshTokenEvent) return RefreshScope.market;
    if (event is RefreshChatTokenEvent) return RefreshScope.chat;
    if (event is RefreshStoriesTokenEvent) return RefreshScope.stories;
    if (event is RefreshCommentTokenEvent) return RefreshScope.comment;
    return null;
  }

  @override
  void add(AuthEvent event) {
    events.add(event);
    if (isClosed) {
      throw StateError('Cannot add new events after calling close');
    }
    final RefreshScope? scope = scopeOf(event);
    if (scope != null && answersTheCoordinator) {
      TokenRefreshCoordinator.instance.complete(scope, refreshSucceeds);
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
        'FakeAuthBloc was asked for ${invocation.memberName}, which no test has '
        'set up.',
      );
}

/// Everything one interceptor test needs, wired together.
class NetworkHarness {
  NetworkHarness({
    required this.dio,
    required this.adapter,
    required this.prefs,
    required this.auth,
  });

  final Dio dio;
  final ScriptedAdapter adapter;
  final FakePrefs prefs;
  final FakeAuthBloc auth;
}

/// Builds a `Dio` that answers from [replies] and carries the real
/// `LoggerInterceptor`, with the fakes registered in `GetIt` first — the
/// interceptor resolves `PrefsRepository` in its field initialiser, and reaches
/// for `AuthBloc` and `Dio` while handling a 401.
NetworkHarness buildNetworkHarness({
  required List<ScriptedReply> replies,
  FakePrefs? prefs,
  FakeAuthBloc? auth,
}) {
  loadTestEnv();

  final FakePrefs prefsFake = prefs ?? FakePrefs();
  final FakeAuthBloc authFake = auth ?? FakeAuthBloc();
  final ScriptedAdapter adapter = ScriptedAdapter(replies);

  final Dio dio = Dio(
    BaseOptions(
      // `onRequest` logs `connectTimeout! ~/ 1000`, so this must not be null.
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  dio.httpClientAdapter = adapter;

  GetIt.I.registerSingleton<PrefsRepository>(prefsFake);
  GetIt.I.registerSingleton<AuthBloc>(authFake);
  GetIt.I.registerSingleton<Dio>(dio);

  dio.interceptors.add(LoggerInterceptor());

  return NetworkHarness(
    dio: dio,
    adapter: adapter,
    prefs: prefsFake,
    auth: authFake,
  );
}

/// Clears the registrations and drains the coordinator, which is a
/// process-wide singleton with no reset hook of its own.
Future<void> tearDownNetworkHarness() async {
  for (final RefreshScope scope in RefreshScope.values) {
    TokenRefreshCoordinator.instance.complete(scope, false);
  }
  await Future<void>.delayed(Duration.zero);
  await GetIt.I.reset();
}
