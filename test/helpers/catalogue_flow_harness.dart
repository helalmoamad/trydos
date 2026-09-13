import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/constant/design/constant_design.dart';
import 'package:trydos/service/language_service.dart';
import 'package:trydos/common/constant/configuration/market_url_routes.dart';
import 'package:trydos/core/api/log_interceptor.dart';
import 'package:trydos/core/api/token_refresh_coordinator.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/error/error_manager.dart';
import 'package:trydos/features/app/blocs/pre_caching_image_bloc/pre_caching_image_bloc.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/chat/presentation/manager/chat_state.dart';
import 'package:trydos/features/home/data/data_sources/home_remote_data_source.dart';
import 'package:trydos/features/home/data/repositories/home_repository_implementation.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';
import 'package:trydos/features/home/domain/use_cases/get_featured_products_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_home_boutiqes_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_main_categories_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_product_filters_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_products_with_filters_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_recommend_products_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/search_by_images_usecase.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_bloc.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_event.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_state.dart';
import 'package:trydos/features/home/presentation/manager/categoryBloc/category_bloc.dart';
import 'package:trydos/features/home/presentation/manager/categoryBloc/category_event.dart';
import 'package:trydos/features/home/presentation/manager/categoryBloc/category_state.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/story/presentation/bloc/story_bloc.dart';

import 'auth_flow_harness.dart';
import 'network_harness.dart';
import 'session_prefs.dart';

/// Test ledger · wave 03 Browsing, search and the product page — the catalogue
/// harness.
///
/// Finding a product runs through two blocs that are not `HomeBloc`:
/// `CategoryBloc` owns the home screen (the main-category tabs and each tab's
/// boutiques), and `BoutiqueBloc` owns every listing (its filters, its sort, its
/// pages). Each one reaches for the other through `GetIt` — a listing that
/// resets its filters tells `CategoryBloc` to clear the Gemini reply, and the
/// home screen hands a tapped category to `BoutiqueBloc` — so each is built here
/// for real with the other one **recorded**, never run.
///
/// Neither bloc is hydrated, so unlike the home harness there is no storage to
/// set up. Both hang off `HomeRepository` alone.
///
/// Both answer from the same host: the catalogue lives on the web-app server,
/// and **one path — `api/products/searchInCatalog` — answers the product list
/// and the filter facets both.** A test that wants to tell those two apart has
/// to read the query string (`RoutingAdapter.queryOf`), not the path.

/// Records the events handed to `CategoryBloc`.
class FakeCategoryBloc implements CategoryBloc {
  final List<CategoryEvent> events = <CategoryEvent>[];

  List<T> eventsOf<T extends CategoryEvent>() => events.whereType<T>().toList();

  @override
  void add(CategoryEvent event) => events.add(event);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
        'FakeCategoryBloc was asked for ${invocation.memberName}, which no test '
        'has set up.',
      );
}

/// Records the events handed to `BoutiqueBloc`.
class FakeBoutiqueBloc implements BoutiqueBloc {
  final List<BoutiqueEvent> events = <BoutiqueEvent>[];

  List<T> eventsOf<T extends BoutiqueEvent>() => events.whereType<T>().toList();

  @override
  void add(BoutiqueEvent event) => events.add(event);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
        'FakeBoutiqueBloc was asked for ${invocation.memberName}, which no test '
        'has set up.',
      );
}

/// Records events like [FakeChatBloc], and answers `state` as well.
///
/// `CategoryBloc.requestAPIAfterHome()` — which runs after the main categories
/// land — reads `chat.state.firstRequestForGetChats` to decide whether to ask
/// for the chat list. The recording fake throws on anything but `add`, and that
/// throw landed in the middle of the categories' success branch.
class FakeChatBlocWithState extends FakeChatBloc {
  @override
  ChatState get state => ChatState();
}

/// Records the image urls the blocs ask to warm, and warms none of them.
class FakePreCachingImageBloc implements PreCachingImageBloc {
  final List<PreCachingImageEvent> events = <PreCachingImageEvent>[];

  @override
  void add(PreCachingImageEvent event) => events.add(event);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
        'FakePreCachingImageBloc was asked for ${invocation.memberName}, which '
        'no test has set up.',
      );
}

/// The state list, plus the transitions of one field with repeats collapsed —
/// see `AuthFlowHarness.transitionsOf` for why the final state is not enough.
List<T> _transitions<S, T>(List<S> emitted, T Function(S state) read) {
  final List<T> out = <T>[];
  for (final S state in emitted) {
    final T value = read(state);
    if (out.isEmpty || out.last != value) out.add(value);
  }
  return out;
}

/// The transport, the preferences and the blocs both catalogue blocs lean on.
class _CatalogueWorld {
  _CatalogueWorld({
    required this.adapter,
    required this.prefs,
    required this.repository,
    required this.home,
    required this.images,
  });

  final RoutingAdapter adapter;
  final SessionPrefs prefs;
  final HomeRepository repository;
  final FakeHomeBloc home;
  final FakePreCachingImageBloc images;
}

/// The two process-wide values the app sets at startup and a unit test never
/// gets.
///
/// **Screen size.** The catalogue sizes every image url it prefetches with
/// `320.w` / `464.h`. In the first-page handler that sits inside a `try`, so a
/// missing `ScreenUtil` was swallowed; in the non-cancelling handler that fills
/// the home rails it is **not**, and the whole handler threw. The device is
/// made the same size as the design, so `.w` and `.h` scale by exactly one and
/// no test depends on a made-up screen.
///
/// **Language.** Every catalogue success fires an analytics event that reads
/// `LanguageService.isKurdish`, a `late` static the app sets from the locale.
/// Unset, the service's own `catch` printed the error and moved on.
void configureDeviceStatics() {
  ScreenUtil.configure(
    data: const MediaQueryData(size: kDesignSize),
    designSize: kDesignSize,
    splitScreenMode: false,
    minTextAdapt: false,
  );
  LanguageService.isKurdish = false;
}

_CatalogueWorld _buildWorld(
  Map<String, List<ScriptedReply>> routes,
  SessionPrefs? prefs,
) {
  loadTestEnv();
  configureDeviceStatics();
  ErrorManager.clearAllRetries();

  final SessionPrefs prefsFake = prefs ?? SessionPrefs();
  if (prefsFake.getFcmTokens.isEmpty) {
    prefsFake.fcmTokens.add('seeded-fcm-token');
  }

  // Same reason as the home harness: a failed request is reported to the
  // market, and a failure-path test should not have to script that too.
  final RoutingAdapter adapter = RoutingAdapter(<String, List<ScriptedReply>>{
    MarketEndPoints.sendErrorToMobileErrorLogEP: <ScriptedReply>[
      const ScriptedReply(200, <String, dynamic>{'isSuccessful': true}),
    ],
    ...routes,
  });
  final Dio dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  dio.httpClientAdapter = adapter;

  final FakeHomeBloc home = FakeHomeBloc();
  final FakePreCachingImageBloc images = FakePreCachingImageBloc();

  GetIt.I.registerSingleton<PrefsRepository>(prefsFake);
  GetIt.I.registerSingleton<Dio>(dio);
  GetIt.I.registerSingleton<HomeBloc>(home);
  GetIt.I.registerSingleton<AuthBloc>(FakeAuthBloc());
  GetIt.I.registerSingleton<ChatBloc>(FakeChatBlocWithState());
  GetIt.I.registerSingleton<StoryBloc>(FakeStoryBloc());
  GetIt.I.registerSingleton<PreCachingImageBloc>(images);

  // Without the interceptor every non-2xx status collapses to 400 before a
  // handler can branch on it — see `test/README.md`.
  dio.interceptors.add(LoggerInterceptor());

  return _CatalogueWorld(
    adapter: adapter,
    prefs: prefsFake,
    repository: HomeRepositoryImpl(HomeRemoteDatasource()),
    home: home,
    images: images,
  );
}

// ------------------------------------------------------------ BoutiqueBloc

/// Everything one listing test needs, wired together.
class BoutiqueFlowHarness {
  BoutiqueFlowHarness({
    required this.bloc,
    required this.adapter,
    required this.prefs,
    required this.category,
    required this.home,
    required this.images,
    required this.emitted,
    required this.subscription,
  });

  final BoutiqueBloc bloc;
  final RoutingAdapter adapter;
  final SessionPrefs prefs;

  /// `BoutiqueBloc` tells `CategoryBloc` to drop the Gemini reply whenever the
  /// filters are reset. That hand-off is recorded here.
  final FakeCategoryBloc category;
  final FakeHomeBloc home;
  final FakePreCachingImageBloc images;

  /// Every state the bloc has been in, starting with the one it was built with.
  final List<BoutiqueState> emitted;

  final StreamSubscription<BoutiqueState> subscription;

  List<T> transitionsOf<T>(T Function(BoutiqueState state) read) =>
      _transitions(emitted, read);
}

/// Builds the real `BoutiqueBloc` over a routed, mocked transport.
BoutiqueFlowHarness buildBoutiqueFlowHarness({
  required Map<String, List<ScriptedReply>> routes,
  SessionPrefs? prefs,
}) {
  final _CatalogueWorld world = _buildWorld(routes, prefs);
  final FakeCategoryBloc category = FakeCategoryBloc();
  GetIt.I.registerSingleton<CategoryBloc>(category);

  final BoutiqueBloc bloc = BoutiqueBloc(
    GetFeaturedProductsUseCase(world.repository),
    GetProductsWithFiltersUseCase(world.repository),
    GetRecommendProductsUseCase(world.repository),
    GetProductFiltersUseCase(world.repository),
  );
  GetIt.I.registerSingleton<BoutiqueBloc>(bloc);

  final List<BoutiqueState> emitted = <BoutiqueState>[bloc.state];
  final StreamSubscription<BoutiqueState> subscription =
      bloc.stream.listen(emitted.add);

  return BoutiqueFlowHarness(
    bloc: bloc,
    adapter: world.adapter,
    prefs: world.prefs,
    category: category,
    home: world.home,
    images: world.images,
    emitted: emitted,
    subscription: subscription,
  );
}

Future<void> tearDownBoutiqueFlowHarness(BoutiqueFlowHarness? harness) async {
  await harness?.subscription.cancel();
  await harness?.bloc.close();
  await _tearDownWorld();
}

// ------------------------------------------------------------ CategoryBloc

/// Everything one home-screen test needs, wired together.
class CategoryFlowHarness {
  CategoryFlowHarness({
    required this.bloc,
    required this.adapter,
    required this.prefs,
    required this.boutique,
    required this.home,
    required this.images,
    required this.emitted,
    required this.subscription,
  });

  final CategoryBloc bloc;
  final RoutingAdapter adapter;
  final SessionPrefs prefs;

  /// The home screen hands the tapped category to `BoutiqueBloc`; recorded.
  final FakeBoutiqueBloc boutique;
  final FakeHomeBloc home;
  final FakePreCachingImageBloc images;

  final List<CategoryState> emitted;

  final StreamSubscription<CategoryState> subscription;

  List<T> transitionsOf<T>(T Function(CategoryState state) read) =>
      _transitions(emitted, read);
}

/// Builds the real `CategoryBloc` over a routed, mocked transport.
CategoryFlowHarness buildCategoryFlowHarness({
  required Map<String, List<ScriptedReply>> routes,
  SessionPrefs? prefs,
}) {
  final _CatalogueWorld world = _buildWorld(routes, prefs);
  final FakeBoutiqueBloc boutique = FakeBoutiqueBloc();
  GetIt.I.registerSingleton<BoutiqueBloc>(boutique);

  final CategoryBloc bloc = CategoryBloc(
    SearchByImageFromGeminiUseCase(world.repository),
    GetMainCategoriesUseCase(world.repository),
    GetHomeBoutiqesUseCase(world.repository),
  );
  GetIt.I.registerSingleton<CategoryBloc>(bloc);

  final List<CategoryState> emitted = <CategoryState>[bloc.state];
  final StreamSubscription<CategoryState> subscription =
      bloc.stream.listen(emitted.add);

  return CategoryFlowHarness(
    bloc: bloc,
    adapter: world.adapter,
    prefs: world.prefs,
    boutique: boutique,
    home: world.home,
    images: world.images,
    emitted: emitted,
    subscription: subscription,
  );
}

Future<void> tearDownCategoryFlowHarness(CategoryFlowHarness? harness) async {
  await harness?.subscription.cancel();
  await harness?.bloc.close();
  await _tearDownWorld();
}

Future<void> _tearDownWorld() async {
  for (final RefreshScope scope in RefreshScope.values) {
    TokenRefreshCoordinator.instance.complete(scope, false);
  }
  await Future<void>.delayed(Duration.zero);
  await GetIt.I.reset();
}
