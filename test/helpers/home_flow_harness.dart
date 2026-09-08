import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/constant/configuration/market_url_routes.dart';
import 'package:trydos/core/api/log_interceptor.dart';
import 'package:trydos/core/api/token_refresh_coordinator.dart';
import 'package:trydos/core/data/data_source/common_use_repo_data_source.dart';
import 'package:trydos/core/data/repository/common_use_repository_impl.dart';
import 'package:trydos/core/domin/repositories/common_use_repository.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/error/error_manager.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/home/data/data_sources/home_remote_data_source.dart';
import 'package:trydos/features/home/data/repositories/home_repository_implementation.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/features/story/data/repository/story_repository_impl.dart';
import 'package:trydos/features/story/data/data_source/story_data_source.dart';
import 'package:trydos/features/story/domain/repository/story_repository.dart';
import 'package:trydos/features/story/presentation/bloc/story_bloc.dart';
import 'package:trydos/features/home/domain/use_cases/DeliveredOrdersResponse_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/GetRelatedProductsUseCase.dart';
import 'package:trydos/features/home/domain/use_cases/add_item_to_cart_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/add_like_to_product_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/add_to_checklist_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/change_country_language_for_notification_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/check_availability_product_cart_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/check_checklist_exist_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/convert_item_from_Cart_to_oldCart_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/create_comment_order_rating.dart';
import 'package:trydos/features/home/domain/use_cases/delete_comment_order_rating.dart';
import 'package:trydos/features/home/domain/use_cases/delete_from_checklist_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/delete_like_of_product_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_allowed_country_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_auth_product_details_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_buyer_comments_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_cart_item_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_cart_overview_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_checklist_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_count_view_of_product_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_country_boundary_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_currencies_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_currency_for_country_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_fqa_comments_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_full_product_details_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_my_firebase_settings_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_notification_type_for_product_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_old_cart_item_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_order_rating_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_popular_search_terms_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_product_detail_without_related_products_uswcase.dart';
import 'package:trydos/features/home/domain/use_cases/get_starting_settings_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_stories_for_product_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_user_notification_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/hide_item_from_oldCart_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/remove_item_from_cart_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/send_accept__of_notifications_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/send_error_to_mobile_error_log.dart';
import 'package:trydos/features/home/domain/use_cases/store_fcm_token_of_market_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/subscribe_topic_for_notification_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/translate_comment_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/un_subscribe_topic_for_notification_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/update_comment_order_rating.dart';
import 'package:trydos/features/home/domain/use_cases/update_email_notification_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/update_firebase_notification_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/update_item_from_cart_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/update_like_comment_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/update_like_share_product_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/update_notification_frequency_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/update_profile_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/update_whatsapp_notification_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/upload_user_photo_usecase.dart';
import 'package:trydos/features/story/domain/useCases/get_width_and_height_usecase.dart';
import 'package:trydos/features/story/domain/useCases/report_about_story_usecase.dart';

import 'auth_flow_harness.dart';
import 'hydrated_storage_harness.dart';
import 'network_harness.dart';
import 'session_prefs.dart';

/// Test ledger . wave 02 Account and session - the home-flow harness.
///
/// The account scenarios that are not about tokens are about the profile: the
/// name and photo, the country and currency, the notification switches, the
/// notification inbox. All of those live in `HomeBloc`, so this builds the real
/// one over the same mocked transport the auth harness uses.
///
/// `HomeBloc` is a `HydratedBloc`, so a storage has to exist before it is built
/// - that is what [InMemoryHydratedStorage] is for. Its 54 use cases all hang
/// off one of four repositories, so building it is long but not complicated.

/// Everything one home-flow test needs, wired together.
class HomeFlowHarness {
  HomeFlowHarness({
    required this.bloc,
    required this.adapter,
    required this.prefs,
    required this.storage,
    required this.auth,
    required this.chat,
    required this.story,
    required this.emitted,
    required this.subscription,
  });

  final HomeBloc bloc;
  final RoutingAdapter adapter;
  final SessionPrefs prefs;
  final InMemoryHydratedStorage storage;
  final FakeAuthBloc auth;
  final FakeChatBloc chat;
  final FakeStoryBloc story;

  /// Every state the bloc has been in, starting with the one it was built with.
  final List<HomeState> emitted;

  final StreamSubscription<HomeState> subscription;

  /// The values one status field took, in order, with repeats collapsed — see
  /// `AuthFlowHarness.transitionsOf` for why the final state is not enough.
  List<T> transitionsOf<T>(T Function(HomeState state) read) {
    final List<T> out = <T>[];
    for (final HomeState state in emitted) {
      final T value = read(state);
      if (out.isEmpty || out.last != value) out.add(value);
    }
    return out;
  }
}

/// Records the events handed to `AuthBloc` instead of running them.
class FakeAuthBloc implements AuthBloc {
  final List<AuthEvent> events = <AuthEvent>[];

  List<T> eventsOf<T extends AuthEvent>() => events.whereType<T>().toList();

  @override
  void add(AuthEvent event) => events.add(event);

  /// The error reporter reads the resolved country off this state to put the
  /// client IP in its report. Nothing asks it to change, so the initial state
  /// is the whole contract.
  @override
  AuthState get state => const AuthState();

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
        'FakeAuthBloc was asked for ${invocation.memberName}, which no test has '
        'set up.',
      );
}

/// Builds the real `HomeBloc` over a routed, mocked transport.
HomeFlowHarness buildHomeFlowHarness({
  required Map<String, List<ScriptedReply>> routes,
  SessionPrefs? prefs,
  Map<String, dynamic>? hydratedSeed,
}) {
  loadTestEnv();
  ErrorManager.clearAllRetries();

  final SessionPrefs prefsFake = prefs ?? SessionPrefs();
  if (prefsFake.getFcmTokens.isEmpty) {
    prefsFake.fcmTokens.add('seeded-fcm-token');
  }

  // `LoggerInterceptor` reports every failed request through
  // `SendErrorToMobileErrorLogEvent`, which posts it to the market. A test about
  // a failure path should not also have to script that, and letting it fall
  // through to the 404 fallback would report *that* failure too. Tests may still
  // override it by naming the same route.
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

  final FakeAuthBloc auth = FakeAuthBloc();
  final FakeChatBloc chat = FakeChatBloc();
  final FakeStoryBloc story = FakeStoryBloc();

  GetIt.I.registerSingleton<PrefsRepository>(prefsFake);
  GetIt.I.registerSingleton<Dio>(dio);
  GetIt.I.registerSingleton<AuthBloc>(auth);
  GetIt.I.registerSingleton<ChatBloc>(chat);
  GetIt.I.registerSingleton<StoryBloc>(story);

  final InMemoryHydratedStorage storage =
      useInMemoryHydratedStorage(hydratedSeed);

  final HomeRepository homeRepository = HomeRepositoryImpl(
    HomeRemoteDatasource(),
  );
  final CommonUseRepository commonRepository = CommonUseRepositoryImpl(
    CommonUseRemoteDataSource(),
  );
  final StoryRepository storyRepository = StoryRepositoryImpl(
    StoriesDataSource(),
  );

  final HomeBloc bloc = HomeBloc(
    GetStoryForProductUseCase(homeRepository),
    RemoveItemToCartUseCase(homeRepository),
    ConvertItemFromcartToOldCartUsecase(homeRepository),
    GetCartItemUseCase(homeRepository),
    GetOldCartItemUseCase(homeRepository),
    ReportAboutStoryUseCase(storyRepository),
    StoreFcmTokenOfMarketUseCase(homeRepository),
    DeleteLikeOfProductUsecase(homeRepository),
    AddLikeToProductUsecase(homeRepository),
    UpdateItemInCartUseCase(homeRepository),
    GetFqaCommentsUsecase(homeRepository),
    GetBuyerCommentsUsecase(homeRepository),
    AddItemToCartUseCase(homeRepository),
    DeleteOrderCommentRatingUseCase(homeRepository),
    UpdateProfileUseCase(homeRepository),
    UpdateLikeSocialSharedProductsUsecase(homeRepository),
    GetAllowedCountryUseCase(homeRepository),
    GetNotificationTypeProductUseCase(homeRepository),
    GetWidthAndHeightUseCase(storyRepository),
    GetMyFirebaseSettingsUseCase(homeRepository),
    GetRelatedProductsUseCase(homeRepository),
    GetCurrenciesForWalletUseCase(homeRepository),
    GetAuthProductDetailsUseCase(homeRepository),
    UpdateEmailNotificationUseCase(homeRepository),
    UpdateFirebaseNotificationUseCase(homeRepository),
    UpdateNotificationFrequencyUseCase(homeRepository),
    UpdateWhatsappNotificationUseCase(homeRepository),
    ChangeCountryLanguageFornotificationUseCase(homeRepository),
    GetOrderRatingUsecase(homeRepository),
    UpdateOrderCommentRatingUseCase(homeRepository),
    SendAcceptOfNotificationsUseCase(homeRepository),
    SubscribeTopicFornotificationUseCase(homeRepository),
    UnSubscribeTopicFornotificationUseCase(homeRepository),
    GetProductDetailWithoutRelatedProductsUseCase(homeRepository),
    CreateOrderCommentRatingUseCase(homeRepository),
    GetStartingSettingsUseCase(homeRepository),
    GetPopularSearchItemUseCase(homeRepository),
    GetDeliveredOrdersResponseUseCase(homeRepository),
    UpdateUserPhotoUseCase(commonRepository),
    GetCurrencyForCountryUseCase(homeRepository),
    HideItemsInOldCartUseCase(homeRepository),
    GetFullProductDetailsUseCase(homeRepository),
    CountryBoundaryByIsoUseCase(homeRepository),
    GetAndAddCountViewOfProductUsecase(homeRepository),
    SendErrorToMobileErrorLogUseCase(homeRepository),
    UpdateLikeCommentUseCase(homeRepository),
    CheckAvailabilityProductCartUsecase(homeRepository),
    GetCartOverviewUseCase(homeRepository),
    TranslateCommentUsecase(homeRepository),
    GetUserNotificationUseCase(homeRepository),
    AddToChecklistUseCase(homeRepository),
    DeleteFromChecklistUseCase(homeRepository),
    CheckChecklistExistUseCase(homeRepository),
    GetChecklistUseCase(homeRepository),
  );

  final List<HomeState> emitted = <HomeState>[bloc.state];
  final StreamSubscription<HomeState> subscription =
      bloc.stream.listen(emitted.add);

  GetIt.I.registerSingleton<HomeBloc>(bloc);
  // Same reason as in the auth harness: without the interceptor every non-2xx
  // status collapses to 400 before a handler can branch on it.
  dio.interceptors.add(LoggerInterceptor());

  return HomeFlowHarness(
    bloc: bloc,
    adapter: adapter,
    prefs: prefsFake,
    storage: storage,
    auth: auth,
    chat: chat,
    story: story,
    emitted: emitted,
    subscription: subscription,
  );
}

/// Closes the bloc, drains the coordinator and clears every registration.
Future<void> tearDownHomeFlowHarness(HomeFlowHarness? harness) async {
  await harness?.subscription.cancel();
  await harness?.bloc.close();
  for (final RefreshScope scope in RefreshScope.values) {
    TokenRefreshCoordinator.instance.complete(scope, false);
  }
  await Future<void>.delayed(Duration.zero);
  clearHydratedStorage();
  await GetIt.I.reset();
}
