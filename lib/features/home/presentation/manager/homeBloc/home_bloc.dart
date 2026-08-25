import 'package:flutter/foundation.dart' hide Category;
import 'dart:async';
import 'dart:convert' show jsonEncode;
import 'dart:math';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/core/error/error_manager.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/app_elvated_button.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:geodesy/geodesy.dart' as geod;
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/home/data/models/get_auth_product_details_model.dart';
import 'package:trydos/features/home/data/models/get_buyers_comments_model.dart';
import 'package:trydos/features/home/data/models/get_cart_item_model.dart';
import 'package:trydos/features/home/data/models/get_fqa_comments_model.dart';

import 'package:trydos/features/home/data/models/get_old_cart_model.dart'
    as oldCart;
import 'package:trydos/features/home/data/models/get_product_detail_without_related_products_model.dart';
import 'package:trydos/features/home/data/models/get_product_filters_model.dart'
    as filters_model;
import 'package:trydos/features/home/data/models/get_product_listing_with_filters_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart';
import 'package:trydos/features/home/data/models/get_story_for_product_model.dart';
import 'package:trydos/features/home/data/models/popular_search_terms_model.dart';
import 'package:trydos/features/home/data/models/starting_settings_response_model.dart';
import 'package:trydos/features/home/domain/use_cases/DeliveredOrdersResponse_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/GetRelatedProductsUseCase.dart';
import 'package:trydos/features/home/domain/use_cases/add_like_to_product_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/add_to_checklist_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/change_country_language_for_notification_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/check_checklist_exist_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/convert_item_from_Cart_to_oldCart_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/create_comment_order_rating.dart';
import 'package:trydos/features/home/domain/use_cases/delete_comment_order_rating.dart';
import 'package:trydos/features/home/domain/use_cases/delete_from_checklist_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/delete_like_of_product_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_allowed_country_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_auth_product_details_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_cart_item_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_checklist_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_count_view_of_product_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_country_boundary_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_currencies_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_currency_for_country_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_full_product_details_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_my_firebase_settings_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_notification_type_for_product_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_old_cart_item_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_order_rating_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_popular_search_terms_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_product_detail_without_related_products_uswcase.dart';
import 'package:trydos/features/home/domain/use_cases/get_starting_settings_usecase.dart';
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
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_bloc.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_event.dart';
import 'package:trydos/features/home/presentation/manager/orderBloc/order_bloc.dart';
import 'package:trydos/features/home/presentation/manager/orderBloc/order_event.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_sheet_bottom_bar.dart';
import 'package:trydos/features/story/domain/useCases/get_width_and_height_usecase.dart';
import 'package:trydos/features/story/domain/useCases/report_about_story_usecase.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_buttons_event_name.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_events.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import 'package:trydos/service/firebase_analytics_service/firebase_analytics_service.dart';
import 'package:trydos/service/notification_service/notification_service/handle_notification/notification_process.dart';
import 'package:uuid/uuid.dart';
import '../../../../../common/helper/helper_functions.dart';
import '../../../../../core/data/model/pagination_model.dart';
import '../../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../../main.dart';
import '../../../../chat/presentation/manager/chat_bloc.dart';
import '../../../../chat/presentation/manager/chat_event.dart';
import '../../../data/models/get_user_notifications_model.dart';
import '../../../domain/use_cases/add_item_to_cart_usecase.dart';

import '../../../domain/use_cases/check_availability_product_cart_usecase.dart';
import '../../../domain/use_cases/get_cart_overview_usecase.dart';
import '../../../domain/use_cases/get_stories_for_product_usecase.dart';
import '../../../domain/use_cases/get_user_notification_usecase.dart';
import 'home_event.dart';
import '../../../domain/use_cases/get_fqa_comments_usecase.dart';
import '../../../domain/use_cases/get_buyer_comments_usecase.dart';
import 'home_state.dart';
import 'package:trydos/common/helper/dev_log.dart';

const throttleDuration = Duration(minutes: 2);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

@LazySingleton()
class HomeBloc extends HydratedBloc<HomeEvent, HomeState> {
  HomeBloc(
    //  this.getHomeSectionsUseCase,
    this.getStoryForProductUseCase,
    this.removeItemToCartUseCase,
    this.convertItemFromcartToOldCartUsecase,
    this.getCartItemUseCase,
    this.getOldCartItemUseCase,
    this.reportAboutStoryUseCase,
    this.storeFcmTokenOfMarketUseCase,
    // this.getBrandUseCase,
    //  this.getCategoryUseCase,
    this.deleteLikeOfProductUsecase,
    this.addLikeToProductUsecase,
    this.updateItemInCartUseCase,
    this.getFqaCommentsUsecase,
    this.getBuyerCommentsUsecase,
    this.addItemToCartUseCase,
    this.deleteOrderCommentRatingUseCase,
    //this.getCommentForProductUseCase,
    //this.getProductsListInCartUseCase,
    this.updateProfileUseCase,
    this.updateLikeSocialSharedProductsUsecase,
    this.getAllowedCountryUseCase,
    this.getNotificationTypeProductUseCase,
    this.getWidthAndHeightUseCase,
    this.getMyFirebaseSettingsUseCase,
    this.getRelatedProductsUseCase,
    this.getCurrenciesForWalletUseCase,
    this.getAuthProductDetailsUseCase,
    this.updateEmailNotificationUseCase,
    this.updateFirebaseNotificationUseCase,
    this.updateNotificationFrequencyUseCase,
    this.updateWhatsappNotificationUseCase,
    this.changeCountryLanguageFornotificationUseCase,
    this.getOrderRatingUsecase,
    this.updateOrderCommentRatingUseCase,
    this.sendAcceptOfNotificationsUseCase,
    this.subscribeTopicFornotificationUseCase,
    this.unSubscribeTopicFornotificationUseCase,
    this.getProductDetailWithoutRelatedProductsUseCase,
    this.createOrderRatingUseCase,
    this.getStartingSettingsUseCase,
    this.getPopularSearchItemUseCase,
    this.getDeliveredOrdersResponseUseCase,
    this.uploadFileCloudinaryUseCase,
    this.getCurrencyForCountryUseCase,
    this.hideItemsInOldCartUseCase,
    this.getFullProductDetailsUseCase,
    this.countryBoundaryByIsoUseCase,
    //this.getCommentsFromAnalyticsUsecase,
    //this.getCustomerInfoUseCase,
    this.getAndAddCountViewOfProductUsecase,
    this.sendErrorToMobileErrorLogUseCase,
    this.updateLikeCommentUseCase,
    this.checkAvailabilityProductCartUsecase,
    this.getCartOverviewUseCase,
    this.translateCommentUsecase,
    this.getUserNotificationUseCase,
    this.addToChecklistUseCase,
    this.deleteFromChecklistUseCase,
    this.checkChecklistExistUseCase,
    this.getChecklistUseCase,
  ) : super(const HomeState()) {
    on<HomeEvent>((event, emit) {});

    on<GetAndAddCountViewOfProductEvent>(_onGetAndAddCountViewOfProductEvent);

    on<IsChangedVariationWhenQtyZeroEvent>(
      _onIsChangedvariationWhenQtyZeroEvent,
    );

    on<UpdateLikeSocialSharedProductsEvent>(
      _onUpdateLikeSocialSharedProductsEvent,
    );
    on<GetCurrenciesForWalletEvent>(_onGetCurrenciesForWalletEvent);

    on<ReportAboutStoryEvent>(_onReportAboutStoryEvent);

    on<SaveUserInfoFromAuthEvent>(_onSaveUserInfoEvent);
    on<GetOrderRatingEvent>(_onGetOrderRatingEvent, transformer: restartable());
    on<IncreaseCountShareOfProductEvent>(_onIncreaseCountShareOfProductEvent);

    on<UpdateProfileEvent>(_onUpdateProfileEvent);

    on<CreateCommentRatingEvent>(_onCreateCommentRatingEvent);

    on<GetCoutryBoundaryByIsoEvent>(_onGetCoutryBoundaryByIsoEvent);
    on<AddProductIdToSaveRedeemTimerEvent>(
      _onAddProductIdToSaveRedeemTimerEvent,
    );

    on<UploadUserPhotoCloudinaryEvent>(_onUploadUserPhotoCloudinaryEvent);

    on<ChangeStatusOFGetProductsDetailsToSuccessEvent>(
      _onChangeStatusOFGetProductsDetailsToSuccessEvent,
    );

    on<GetNotificationTypeProductEvent>(_onGetNotificationTypeProductEvent);

    on<ClearAllAppCashEvent>(_onClearAllAppCashEvent);
    on<UpdateLikeCommentEvent>(_onUpdateLikeCommentEvent);
    on<FetchAuthProductDetailsEvent>(_onFetchAuthProductDetailsEvent);

    on<GetCurrencyForCountryEvent>(
      _onGetCurrencyForCountryEvent,
      transformer: throttleDroppable(const Duration(seconds: 5)),
    );
    on<AddCurrentColorSizeEvent>(_onAddCurrentSizeColorEvent);
    on<AddCurrentSelectedColorEvent>(_onAddCurrentSelectedColorEvent);

    on<ChangeCountryLanguageForNotificationEvent>(
      _onChangeCountryLanguageForNotificationEvent,
    );
    on<SubscribeTopicForNotificationEvent>(
      _onSubscribeTopicForNotificationEvent,
    );
    on<UnSubscribeTopicForNotificationEvent>(
      _onUnSubscribeTopicForNotificationEvent,
    );
    on<GetFirebaseSettingForNotificationEvent>(
      _onGetFirebaseSettingForNotificationEvent,
    );

    on<UpdateListOfItemForAddToCartEvent>(_onUpdateListOfItemForAddToCartEvent);
    // on<GetProductsListInCartEvent>(_onGetProductsListInCartEventEvent,
    //     transformer: restartable());
    on<SendErrorToMobileErrorLogEvent>(_onSendErrorToMobileErrorLogEvent);

    on<RequestForNotificationWhenProductBecameAvailableEvent>(
      _onRequestForNotificationWhenProductBecameAvailableEvent,
    );
    on<StoreFcmTokenOfMarketEvent>(
      _onStoreFcmTokenOfMarketEvent,
      transformer: throttleDroppable(const Duration(seconds: 10)),
    );
    on<UpdateEmailNotificationEvent>(_onUpdateEmailNotificationEvent);
    on<UpdateFirebaseNotificationEvent>(_onUpdateFirebaseNotificationEvent);
    on<UpdateNotificationFrequencyEvent>(_onUpdateNotificationFrequencyEvent);
    on<UpdateWhatsappNotificationEvent>(_onUpdateWhatsappNotificationEvent);
    on<AddQuantityForCartEvent>(_onAddCurrentQuantityForCartEvent);
    on<GetRelatedProductsEvent>(_onGetRelatedProductsEvent);
    on<CheckWithGetCartEvent>(_onCheckWithGetCartEvent);

    on<AddOrRemoveLikeForProductEvent>(
      _onAddOrRemoveLikeForProductEvent,
      transformer: throttleDroppable(const Duration(seconds: 3)),
    );

    on<AddSearchTextToHistoryEvent>(_onAddSearchTextToHistoryEvent);

    on<GetCartItemEvent>(_onGetCartItemEvent, transformer: restartable());

    on<GetAllowedCountriesEvent>(_onGetAllowedCountriesEvent);

    on<GetStartingSettingsEvent>(_onGetStartingSettingsEvent);

    on<AddItemToCartEvent>(_onAddItemToCartEvent);

    on<ChangeCurrentIndexForUpdatCartEvent>(
      _onChangeCurrentIndexForUpdatCartEvent,
    );

    on<AddMultiItemsToCartEvent>(_onAddMultiItemsToCartEvent);
    on<AddTimerStartedToHurryUpEvent>(_onAddTimerStartedToHurryUpEvent);

    on<UpdateItemInCartEvent>(_onUpdateItemInCartEvent);
    /*on<GetCommentsFromAnalyticsEvent>(
      _onGetCommentsFromAnalyticsEvent,
    );*/
    on<RemoveSearchTextfromHistoryEvent>(_onRemoveSearchTextToHistoryEvent);
    on<HideItemInOldCartEvent>(_onHideItemInOldCartEvent);

    on<GetStoryForProductEvent>(
      _onGetStoryEvent,
      transformer: throttleDroppable(const Duration(seconds: 5)),
    );

    // on<AddProductItemForCartEvent>(
    //   _onAddProductItemForCartEvent,
    // );

    on<AddSizesForColorsEvent>(_onAddSizesForColorsEvent);
    on<AddCurrentHeightWhenAddToBagEvent>(_onAddCurrentHeightWhenAddToBagEvent);
    on<GetOldCartItemEvent>(_onGetOldCartItemEvent, transformer: restartable());

    on<RemoveItemFormCartEvent>(_onRemoveItemToCartEvent);

    /*on<AddCommentEvent>(
      _onAddCommentEvent,
    );*/
    on<GetPopularSearchItemEvent>(_onGetPopularSearchItemEvent);

    ///////////////////////////
    on<GetProductDatailsWithoutRelatedProductsEvent>(
      _onGetProductDatailsWithoutRelatedProductsEvent,
      transformer: restartable(),
    );

    //////////////////////////

    on<GetFullProductDetailsEvent>(_onGetFullProductDetailsEvent);
    on<GetProductDetailsForCompareEvent>(_onGetProductDetailsForCompareEvent);
    on<ClearCompareProductEvent>(_onClearCompareProductEvent);
    on<ToggleCompareProductEvent>(_onToggleCompareProductEvent);
    on<SendAcceptOfNotificationMarketEvent>(
      _onSendAcceptOfNotificationMarketEvent,
    );
    on<ConvertItemFromCartToOldCartEvent>(_onConvertItemFromCartToOldCartEvent);
    /*on<GetCommentForProductEvent>(
      _onGetCommentForProductEvent,
    );*/
    /* on<GeColorsAndSizesForSearchEvent>(
      _onGeColorsAndSizesForSearchEvent,
    );*/
    on<LoadFailureEvent>(
      ((event, emit) => emit(
        state.copyWith(
          storiesCollections: state.storiesCollections.map((e) {
            if (e.id == event.collectionId) {
              return e.copyWith(
                selectedStoriesStatusForCollection:
                    SelectedStoriesStatus.failure,
              );
            }
            return e;
          }).toList(),
        ),
      )),
    );
    on<StorySelectedEvent>(_onStorySelectedEvent);
    on<RemoveItemsFromCartAfterOrderSuccessEvent>(
      _onRemoveItemsFromCartAfterOrderSuccessEvent,
    );
    on<CheckAvailabilityProductCartEvent>(_onCheckAvailabilityProductCartEvent);
    on<GetCartOverviewEvent>(
      _onGetCartOverviewEvent,
      transformer: restartable(),
    );

    on<GetUserNotificationEvent>(_onGetUserNotificationEvent);
    on<CheckChecklistExistEvent>(_onCheckChecklistExistEvent);
    on<ToggleChecklistEvent>(_onToggleChecklistEvent);
    on<GetChecklistEvent>(_onGetChecklistEvent, transformer: restartable());
    on<DeleteChecklistItemEvent>(_onDeleteChecklistItemEvent);
    on<DeleteCommentRatingEvent>(_onDeleteCommentRatingEvent);
    on<UpdateCommentRatingEvent>(_onUpdateCommentRatingEvent);
    on<TranslateCommentEvent>(_onTranslateCommentEvent);
    on<GetFqaCommentsEvent>(_onGetFqaCommentsEvent, transformer: restartable());
    on<GetBuyersCommentsEvent>(
      _onGetBuyersCommentsEvent,
      transformer: restartable(),
    );

    on<DeliveredOrdersResponseEvent>(_onDeliveredOrdersResponseEvent);
  }

  Map<String, bool> boutiquesThatEnablesToRequestItsProductsUsingFiveFilters =
      {};
  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  final GetStartingSettingsUseCase getStartingSettingsUseCase;
  final UpdateOrderCommentRatingUseCase updateOrderCommentRatingUseCase;
  final GetRelatedProductsUseCase getRelatedProductsUseCase;
  final GetWidthAndHeightUseCase getWidthAndHeightUseCase;
  final UpdateUserPhotoUseCase uploadFileCloudinaryUseCase;
  final SendAcceptOfNotificationsUseCase sendAcceptOfNotificationsUseCase;
  final DeleteOrderCommentRatingUseCase deleteOrderCommentRatingUseCase;
  final GetAuthProductDetailsUseCase getAuthProductDetailsUseCase;
  final UpdateLikeCommentUseCase updateLikeCommentUseCase;
  final GetCartItemUseCase getCartItemUseCase;
  final TranslateCommentUsecase translateCommentUsecase;
  final GetFqaCommentsUsecase getFqaCommentsUsecase;
  final GetBuyerCommentsUsecase getBuyerCommentsUsecase;
  final GetCartOverviewUseCase getCartOverviewUseCase;
  final ReportAboutStoryUseCase reportAboutStoryUseCase;
  //final GetCommentsFromAnalyticsUsecase getCommentsFromAnalyticsUsecase;
  final GetOrderRatingUsecase getOrderRatingUsecase;
  final GetOldCartItemUseCase getOldCartItemUseCase;
  final CreateOrderCommentRatingUseCase createOrderRatingUseCase;
  final GetNotificationTypeProductUseCase getNotificationTypeProductUseCase;
  final ConvertItemFromcartToOldCartUsecase convertItemFromcartToOldCartUsecase;
  final GetAndAddCountViewOfProductUsecase getAndAddCountViewOfProductUsecase;
  final CountryBoundaryByIsoUseCase countryBoundaryByIsoUseCase;
  // final GetProductsListInCartUseCase getProductsListInCartUseCase;
  final SendErrorToMobileErrorLogUseCase sendErrorToMobileErrorLogUseCase;
  final StoreFcmTokenOfMarketUseCase storeFcmTokenOfMarketUseCase;
  //final GetCommentForProductUseCase getCommentForProductUseCase;
  final GetStoryForProductUseCase getStoryForProductUseCase;
  final UpdateLikeSocialSharedProductsUsecase
  updateLikeSocialSharedProductsUsecase;
  final UpdateProfileUseCase updateProfileUseCase;
  // final GetCustomerInfoUseCase getCustomerInfoUseCase;
  final GetProductDetailWithoutRelatedProductsUseCase
  getProductDetailWithoutRelatedProductsUseCase;

  final GetDeliveredOrdersResponseUseCase getDeliveredOrdersResponseUseCase;

  final GetPopularSearchItemUseCase getPopularSearchItemUseCase;
  final GetCurrencyForCountryUseCase getCurrencyForCountryUseCase;

  final AddLikeToProductUsecase addLikeToProductUsecase;
  final DeleteLikeOfProductUsecase deleteLikeOfProductUsecase;

  final RemoveItemToCartUseCase removeItemToCartUseCase;

  final AddItemToCartUseCase addItemToCartUseCase;
  final UpdateEmailNotificationUseCase updateEmailNotificationUseCase;
  final UpdateFirebaseNotificationUseCase updateFirebaseNotificationUseCase;
  final UpdateWhatsappNotificationUseCase updateWhatsappNotificationUseCase;
  final UpdateNotificationFrequencyUseCase updateNotificationFrequencyUseCase;
  final UpdateItemInCartUseCase updateItemInCartUseCase;
  final HideItemsInOldCartUseCase hideItemsInOldCartUseCase;
  final GetAllowedCountryUseCase getAllowedCountryUseCase;
  final GetFullProductDetailsUseCase getFullProductDetailsUseCase;
  // final GetColorsAndSizesForSearchUseCase getColorsAndSizesForSearchUseCase;
  final CheckAvailabilityProductCartUsecase checkAvailabilityProductCartUsecase;

  final SubscribeTopicFornotificationUseCase
  subscribeTopicFornotificationUseCase;
  final UnSubscribeTopicFornotificationUseCase
  unSubscribeTopicFornotificationUseCase;
  final ChangeCountryLanguageFornotificationUseCase
  changeCountryLanguageFornotificationUseCase;
  final GetMyFirebaseSettingsUseCase getMyFirebaseSettingsUseCase;

  final GetUserNotificationUseCase getUserNotificationUseCase;
  final AddToChecklistUseCase addToChecklistUseCase;
  final DeleteFromChecklistUseCase deleteFromChecklistUseCase;
  final CheckChecklistExistUseCase checkChecklistExistUseCase;
  final GetChecklistUseCase getChecklistUseCase;
  final GetCurrenciesForWalletUseCase getCurrenciesForWalletUseCase;

  ////////////////////////////////////////////////////////////////
  FutureOr<void> _onGetCurrenciesForWalletEvent(
    GetCurrenciesForWalletEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (((prefsRepository.walletToken?.length ?? 0) < 5) ||
        ((prefsRepository.myPhoneNumber?.length ?? 0) < 3)) {
      GetIt.I<OrderBloc>().add(GetCustomerWalletEvent(assetId: ""));
      return;
    }
    if (event.currencySymbol != "") {
      GetIt.I<OrderBloc>().add(GetCustomerWalletEvent(assetId: "LOADING"));
    }
    emit(
      state.copyWith(
        getCurrenciesForWalletStatus: GetCurrenciesForWalletStatus.loading,
      ),
    );
    final response = await getCurrenciesForWalletUseCase(NoParams());
    response.fold(
      (l) {
        if (ErrorManager.shouldRetry('GetCurrenciesEvent', l.statusCode)) {
          add(GetCurrenciesForWalletEvent());
          ErrorManager.incrementRetry('GetCurrenciesEvent');
        }
        emit(
          state.copyWith(
            getCurrenciesForWalletStatus: GetCurrenciesForWalletStatus.failure,
          ),
        );
        if (event.currencySymbol != "") {
          GetIt.I<OrderBloc>().add(GetCustomerWalletEvent(assetId: "FAILED"));
        }
      },
      (r) {
        ErrorManager.resetRetry('GetCurrenciesEvent');
        if (event.currencySymbol != "" && ((r.items?.length ?? 0) > 0)) {
          GetIt.I<OrderBloc>().add(
            GetCustomerWalletEvent(
              assetId:
                  r.items!
                      .firstWhere(
                        (element) => element.symbol == event.currencySymbol,
                      )
                      .id ??
                  "",
            ),
          );
        }
        emit(
          state.copyWith(
            getCurrenciesForWalletStatus: GetCurrenciesForWalletStatus.success,
            walletCurrencies: r,
          ),
        );
      },
    );
  }

  FutureOr<void> _onGetRelatedProductsEvent(
    GetRelatedProductsEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        getRelatedProductsStatus: GetRelatedProductsStatus.loading,
      ),
    );
    devLog("_onGetRelatedProductsEvent in bloc ");
    final response = await getRelatedProductsUseCase(
      GetRelatedProductsParams(
        productSlug: event.productSlug ?? 0,
        color: event.color ?? "",
      ),
    );
    devLog("response in bloc");
    response.fold(
      (failure) {
        devLog("response in failure ${failure.message}");
        emit(
          state.copyWith(
            getRelatedProductsStatus: GetRelatedProductsStatus.failure,
          ),
        );
      },
      (relatedProducts) {
        if (kDebugMode)
          devLog("relatedProducts in ${relatedProducts.data.products}");
        emit(
          state.copyWith(
            getRelatedProductsStatus: GetRelatedProductsStatus.success,
            relatedProducts: relatedProducts.data.products,
          ),
        );
      },
    );
  }

  FutureOr<void> _onGetStartingSettingsEvent(
    GetStartingSettingsEvent event,
    Emitter<HomeState> emit,
  ) async {
    //  if (apisMustNotToRequest.contains('GetStartingSettingsEvent')) return;
    emit(
      state.copyWith(
        getStartingSettingsStatus: GetStartingSettingsStatus.loading,
      ),
    );
    final response = await getStartingSettingsUseCase(NoParams());

    response.fold(
      (l) {
        if (ErrorManager.shouldRetry(
          'GetStartingSettingsEvent',
          l.statusCode,
        )) {
          ErrorManager.incrementRetry('GetStartingSettingsEvent');
          add(const GetStartingSettingsEvent());
        }
        emit(
          state.copyWith(
            getStartingSettingsStatus: GetStartingSettingsStatus.failure,
          ),
        );
      },
      (r) {
        apisMustNotToRequest.add('GetStartingSettingsEvent');
        ErrorManager.resetRetry('GetStartingSettingsEvent');

        emit(
          state.copyWith(
            startingSetting: r.data!.startingSetting,
            getStartingSettingsStatus: GetStartingSettingsStatus.success,
          ),
        );
      },
    );
  }

  FutureOr<void> _onUpdateLikeSocialSharedProductsEvent(
    UpdateLikeSocialSharedProductsEvent event,
    Emitter<HomeState> emit,
  ) async {
    //  if (apisMustNotToRequest.contains('GetStartingSettingsEvent')) return;

    final response = await updateLikeSocialSharedProductsUsecase(
      UpdateLikeSocialSharedProductParams(productId: event.productId),
    );

    response.fold(
      (l) {
        if (ErrorManager.shouldRetry(
          'UpdateLikeSocialSharedProductsEvent',
          l.statusCode,
        )) {
          ErrorManager.incrementRetry('UpdateLikeSocialSharedProductsEvent');
          add(UpdateLikeSocialSharedProductsEvent(productId: event.productId));
        }
      },
      (r) {
        apisMustNotToRequest.add('UpdateLikeSocialSharedProductsEvent');
        ErrorManager.resetRetry('UpdateLikeSocialSharedProductsEvent');
      },
    );
  }

  FutureOr<void> _onGetCoutryBoundaryByIsoEvent(
    GetCoutryBoundaryByIsoEvent event,
    Emitter<HomeState> emit,
  ) async {
    //  if (apisMustNotToRequest.contains('GetStartingSettingsEvent')) return;
    emit(
      state.copyWith(
        getCoutryBoundaryByIsoStatus: GetCountryBoundaryByIsoStatus.loading,
      ),
    );
    final response = await countryBoundaryByIsoUseCase(NoParams());

    response.fold(
      (l) {
        if (ErrorManager.shouldRetry(
          'GetCoutryBoundaryByIsoEvent',
          l.statusCode,
        )) {
          add(const GetCoutryBoundaryByIsoEvent());
          ErrorManager.incrementRetry('GetCoutryBoundaryByIsoEvent');
        }
        emit(
          state.copyWith(
            getCoutryBoundaryByIsoStatus: GetCountryBoundaryByIsoStatus.failure,
          ),
        );
      },
      (r) {
        ErrorManager.resetRetry('GetCoutryBoundaryByIsoEvent');
        List<geod.LatLng>? countryCoordinatesBorders = [];
        r.country?.boundary?.coordinates?.forEach(
          (element) => countryCoordinatesBorders.add(
            geod.LatLng(element.lat ?? 0, element.lon ?? 0),
          ),
        );
        emit(
          state.copyWith(
            countryCoordinatesBorders: countryCoordinatesBorders,
            getCoutryBoundaryByIsoStatus: GetCountryBoundaryByIsoStatus.success,
          ),
        );
      },
    );
  }

  _onStorySelectedEvent(
    StorySelectedEvent event,
    Emitter<HomeState> emit,
  ) async {
    //todo make the story seen when he press to show it
    debugPrint(
      'currentStoryInEachCollection ${event.selectedStoryIndexInCollection}',
    );
    debugPrint('selected ${event.collectionIndex}');
    debugPrint(
      'state.currentStoryInEachCollection ${state.currentStoryInEachCollection[event.collectionIndex]}',
    );

    Map<int, int?> currentStoryInEachCollection = Map.of(
      state.currentStoryInEachCollection,
    );
    currentStoryInEachCollection[event.collectionIndex] =
        event.selectedStoryIndexInCollection == -1
        ? (currentStoryInEachCollection[event.collectionIndex] ?? 0)
        : event.selectedStoryIndexInCollection;
    //todo make  the state loading

    emit(
      state.copyWith(
        //selectedStoriesStatus: SelectedStoriesStatus.loading,
        currentPage: event.currentPage == -1
            ? state.currentPage
            : event.currentPage,
        selectedCollection: event.collectionIndex,
        currentStoryInEachCollection: Map.of(currentStoryInEachCollection),
      ),
    );

    var currentStoryInSelectedCollection =
        state.storiesCollections[event.collectionIndex].stories![max(
          state.currentStoryInEachCollection[event.collectionIndex] ?? 0,
          event.selectedStoryIndexInCollection,
        )];
    if (currentStoryInSelectedCollection.isPhoto == 1) {
      //todo debug
      //todo bring the real width and height for selected photo
      final response = await getWidthAndHeightUseCase(
        widthAndHeightParams(
          url: currentStoryInSelectedCollection.photoPath!,
          collectionId: state.storiesCollections[event.collectionIndex].id!,
        ),
      );
      response.fold(
        (l) {
          if (ErrorManager.shouldRetry('StorySelectedEvent', l.statusCode)) {
            ErrorManager.incrementRetry('StorySelectedEvent');

            emit(
              state.copyWith(
                storiesCollections: state.storiesCollections.map((e) {
                  if (e.id ==
                      state.storiesCollections[event.collectionIndex].id) {
                    return e.copyWith(
                      selectedStoriesStatusForCollection:
                          SelectedStoriesStatus.failure,
                    );
                  }
                  return e;
                }).toList(),
              ),
            );
          } else {
            ErrorManager.incrementRetry('StorySelectedEvent');
            add(
              StorySelectedEvent(
                collectionIndex: event.collectionIndex,
                selectedStoryIndexInCollection:
                    event.selectedStoryIndexInCollection,
                currentPage: event.currentPage,
              ),
            );
          }
        },
        (r) {
          //todo just make the state success with the width and height for the image and in the emitter above you changed the initial  story
          emit(
            state.copyWith(
              storiesCollections: state.storiesCollections.map((e) {
                if (e.id ==
                    state.storiesCollections[event.collectionIndex].id) {
                  return e.copyWith(
                    selectedStoriesStatusForCollection:
                        SelectedStoriesStatus.success,
                    imageDetail: r,
                  );
                }
                return e;
              }).toList(),
            ),
          );
        },
      );
    } else {
      //todo it's a video all what i will do is make it seen
      emit(
        state.copyWith(
          storiesCollections: state.storiesCollections.map((e) {
            if (e.id == state.storiesCollections[event.collectionIndex].id) {
              return e.copyWith(
                selectedStoriesStatusForCollection:
                    SelectedStoriesStatus.success,
              );
            }
            return e;
          }).toList(),
          currentStoryInEachCollection: currentStoryInEachCollection,
          selectedCollection: event.collectionIndex,
        ),
      );
    }
  }

  FutureOr<void> _onIncreaseCountShareOfProductEvent(
    IncreaseCountShareOfProductEvent event,
    Emitter<HomeState> emit,
  ) async {
    Map<String, GetProductDetailWithoutRelatedProductsModel>
    cachedProductWithoutRelatedProductsModel = Map.of(
      state.cachedProductWithoutRelatedProductsModel,
    );
    GetProductDetailWithoutRelatedProductsModel? product =
        cachedProductWithoutRelatedProductsModel[event.productId];
    product = product?.copyWith(
      data: product.product?.copyWith(
        sharedCount: (product.product?.sharedCount ?? 0) + 1,
      ),
    );
    cachedProductWithoutRelatedProductsModel[event.productId] =
        product ?? GetProductDetailWithoutRelatedProductsModel();
    emit(
      state.copyWith(
        cachedProductWithoutRelatedProductsModel:
            cachedProductWithoutRelatedProductsModel,
      ),
    );
    try {
      FirebaseAnalyticsService.logEventForSession(
        eventName: AnalyticsEventsConst.SHARE_CONTENT,
        executedEventName: AnalyticsButtonsEventNameConst.SHARE_CONTENT_BUTTON,
        extraParams: {
          'social_media_name': event.socialMediaName,
          'content_type': 'product',
          'brand': event.product.brand?.name ?? '',
          'category': event.product.categories!
              .map((e) => e.id.toString())
              .toList()
              .toString(),
          'count_likes': event.product.countOfLikes.toString(),
          'review_count': event.product.reviewsCount.toString(),
          'screen_name':
              '${GlobalScreenConst.PRODUCT_SCREEN}/${event.product.slug.toString()}',
          'item_name': event.product.name.toString(),
          'price': event.product.price.toString(),
        },
      );
    } catch (e) {
      devLog('home_bloc.dart: ignored error', e);
    }
    showMessage(
      LocaleKeys.product_shared_successfully.tr(),
      foreGroundColor: Colors.white,
      backGroundColor: Colors.black,
      showInRelease: true,
      timeShowing: Toast.LENGTH_SHORT,
    );

    add(UpdateLikeSocialSharedProductsEvent(productId: event.productId));
  }

  FutureOr<void> _onAddProductIdToSaveRedeemTimerEvent(
    AddProductIdToSaveRedeemTimerEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        addProductIdToSaveRedeemTimerStatus:
            AddProductIdToSaveRedeemTimerStatus.init,
      ),
    );
    await Future.delayed(const Duration(milliseconds: 300));
    emit(
      state.copyWith(
        addProductIdToSaveRedeemTimerStatus: event.on
            ? AddProductIdToSaveRedeemTimerStatus.on
            : AddProductIdToSaveRedeemTimerStatus.off,
        productIdToSaveRedeemTimer: event.productIdToSaveRedeemTimer,
      ),
    );
  }

  FutureOr<void> _onIsChangedvariationWhenQtyZeroEvent(
    IsChangedVariationWhenQtyZeroEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        finishLoadingAfterChangedVariationWhenQtyZero:
            event.finishLoadingAfterChangedVariationWhenQtyZero,
        isChangedVariationWhenQtyZero: event.isChangedVariationWhenQtyZero,
      ),
    );
  }

  FutureOr<void> _onRemoveItemsFromCartAfterOrderSuccessEvent(
    RemoveItemsFromCartAfterOrderSuccessEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        cartCollection: [],
        currentQuantityForCart: {},
        addImagesToProductIdForCart: {},
        addVariationToCartId: {},
        listitemForAddToCart: [],
      ),
    );
  }

  FutureOr<void> _onAddCurrentHeightWhenAddToBagEvent(
    AddCurrentHeightWhenAddToBagEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        currentHeightWhenAddToBag: event.currentHeightWhenAddToBag,
      ),
    );
  }

  FutureOr<void> _onUpdateWhatsappNotificationEvent(
    UpdateWhatsappNotificationEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        updateWhatsappNotificationStatus:
            UpdateWhatsappNotificationStatus.loading,
      ),
    );
    final response = await updateWhatsappNotificationUseCase(
      UpdateWhatsappNotificationParams(whatsapp: event.whatsapp),
    );

    response.fold(
      (l) {
        if (ErrorManager.shouldRetry(
          'UpdateWhatsappNotificationEvent',
          l.statusCode,
        )) {
          add(UpdateWhatsappNotificationEvent(whatsapp: event.whatsapp));

          ErrorManager.incrementRetry('UpdateWhatsappNotificationEvent');
        }
        emit(
          state.copyWith(
            updateWhatsappNotificationStatus:
                UpdateWhatsappNotificationStatus.failure,
          ),
        );
      },
      (r) async {
        ErrorManager.resetRetry('UpdateWhatsappNotificationEvent');
        emit(
          state.copyWith(
            firebaseSettingForNotificationModel: r,
            updateWhatsappNotificationStatus:
                UpdateWhatsappNotificationStatus.success,
          ),
        );
      },
    );
  }

  FutureOr<void> _onUpdateEmailNotificationEvent(
    UpdateEmailNotificationEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        updateEmailappNotificationStatus:
            UpdateEmailappNotificationStatus.loading,
      ),
    );
    final response = await updateEmailNotificationUseCase(
      UpdateEmailNotificationParams(email: event.email),
    );

    response.fold(
      (l) {
        if (ErrorManager.shouldRetry(
          'UpdateEmailNotificationEvent',
          l.statusCode,
        )) {
          add(UpdateEmailNotificationEvent(email: event.email));

          ErrorManager.incrementRetry('UpdateEmailNotificationEvent');
        }
        emit(
          state.copyWith(
            updateEmailappNotificationStatus:
                UpdateEmailappNotificationStatus.failure,
          ),
        );
        showMessage(
          l.message,
          foreGroundColor: Colors.white,
          backGroundColor: Colors.black,
          hasError: true,
          showInRelease: true,
        );
      },
      (r) async {
        ErrorManager.resetRetry('UpdateEmailNotificationEvent');
        emit(
          state.copyWith(
            firebaseSettingForNotificationModel: r,
            updateEmailappNotificationStatus:
                UpdateEmailappNotificationStatus.success,
          ),
        );
      },
    );
  }

  FutureOr<void> _onUpdateFirebaseNotificationEvent(
    UpdateFirebaseNotificationEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        getFirebaseSettingForNotificationStatus:
            GetFirebaseSettingForNotificationStatus.loading,
      ),
    );
    final response = await updateFirebaseNotificationUseCase(
      UpdateFirebaseNotificationParams(firebase: event.firebase),
    );

    response.fold(
      (l) {
        if (ErrorManager.shouldRetry(
          'UpdateFirebaseNotificationEvent',
          l.statusCode,
        )) {
          add(UpdateFirebaseNotificationEvent(firebase: event.firebase));

          ErrorManager.incrementRetry('UpdateFirebaseNotificationEvent');
        }
        emit(
          state.copyWith(
            getFirebaseSettingForNotificationStatus:
                GetFirebaseSettingForNotificationStatus.failure,
          ),
        );
      },
      (r) async {
        ErrorManager.resetRetry('UpdateFirebaseNotificationEvent');
        emit(
          state.copyWith(
            firebaseSettingForNotificationModel: r,
            getFirebaseSettingForNotificationStatus:
                GetFirebaseSettingForNotificationStatus.success,
          ),
        );
      },
    );
  }

  FutureOr<void> _onUpdateNotificationFrequencyEvent(
    UpdateNotificationFrequencyEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        getFirebaseSettingForNotificationStatus:
            GetFirebaseSettingForNotificationStatus.loading,
      ),
    );
    final response = await updateNotificationFrequencyUseCase(
      UpdateNotificationFrequencyParams(
        notificationFrequency: event.notificationFrequency,
      ),
    );

    response.fold(
      (l) {
        if (ErrorManager.shouldRetry(
          'UpdateNotificationFrequencyEvent',
          l.statusCode,
        )) {
          add(
            UpdateNotificationFrequencyEvent(
              notificationFrequency: event.notificationFrequency,
            ),
          );

          ErrorManager.incrementRetry('UpdateNotificationFrequencyEvent');
        }
        emit(
          state.copyWith(
            getFirebaseSettingForNotificationStatus:
                GetFirebaseSettingForNotificationStatus.failure,
          ),
        );
      },
      (r) async {
        ErrorManager.resetRetry('UpdateNotificationFrequencyEvent');
        emit(
          state.copyWith(
            firebaseSettingForNotificationModel: r,
            getFirebaseSettingForNotificationStatus:
                GetFirebaseSettingForNotificationStatus.success,
          ),
        );
      },
    );
  }

  FutureOr<void> _onSubscribeTopicForNotificationEvent(
    SubscribeTopicForNotificationEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        getFirebaseSettingForNotificationStatus:
            GetFirebaseSettingForNotificationStatus.loading,
      ),
    );
    final response = await subscribeTopicFornotificationUseCase(
      SubscribeTopicForNotificationParams(
        topic: event.topic,
        variant: event.variant?.replaceAll("_", "-"),
      ),
    );

    response.fold(
      (l) {
        if (ErrorManager.shouldRetry(
          'SubscribeTopicForNotificationEvent',
          l.statusCode,
        )) {
          add(
            SubscribeTopicForNotificationEvent(
              topic: event.topic,
              variant: event.variant?.replaceAll("_", "-"),
            ),
          );

          ErrorManager.incrementRetry('SubscribeTopicForNotificationEvent');
        }
        emit(
          state.copyWith(
            getFirebaseSettingForNotificationStatus:
                GetFirebaseSettingForNotificationStatus.failure,
          ),
        );
      },
      (r) async {
        ErrorManager.resetRetry('SubscribeTopicForNotificationEvent');
        emit(
          state.copyWith(
            firebaseSettingForNotificationModel: r,
            getFirebaseSettingForNotificationStatus:
                GetFirebaseSettingForNotificationStatus.success,
          ),
        );
      },
    );
  }

  /*  FutureOr<void> _onGeColorsAndSizesForSearchEvent(
      GeColorsAndSizesForSearchEvent event, Emitter<HomeState> emit) async {
    final response = await getColorsAndSizesForSearchUseCase(NoParams());

    response.fold((l) {
      if (!isFailedTheFirstTime.contains('GeColorsAndSizesForSearchEvent')) {
        add(GeColorsAndSizesForSearchEvent());

        isFailedTheFirstTime.add('GeColorsAndSizesForSearchEvent');
      }
    }, (r) async {
      isFailedTheFirstTime.remove('GeColorsAndSizesForSearchEvent');
      emit(state.copyWith(geColorsAndSizesForSearchModel: r));
    });
  }*/

  FutureOr<void> _onGetFirebaseSettingForNotificationEvent(
    GetFirebaseSettingForNotificationEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        getFirebaseSettingForNotificationStatus:
            GetFirebaseSettingForNotificationStatus.loading,
      ),
    );
    final response = await getMyFirebaseSettingsUseCase(NoParams());

    response.fold(
      (l) {
        if (ErrorManager.shouldRetry(
          'GetFirebaseSettingForNotificationEvent',
          l.statusCode,
        )) {
          add(const GetFirebaseSettingForNotificationEvent());

          ErrorManager.incrementRetry('GetFirebaseSettingForNotificationEvent');
        }
        emit(
          state.copyWith(
            getFirebaseSettingForNotificationStatus:
                GetFirebaseSettingForNotificationStatus.failure,
          ),
        );
      },
      (r) async {
        ErrorManager.resetRetry('GetFirebaseSettingForNotificationEvent');
        emit(
          state.copyWith(
            firebaseSettingForNotificationModel: r,
            getFirebaseSettingForNotificationStatus:
                GetFirebaseSettingForNotificationStatus.success,
          ),
        );
      },
    );
  }

  FutureOr<void> _onUnSubscribeTopicForNotificationEvent(
    UnSubscribeTopicForNotificationEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        getFirebaseSettingForNotificationStatus:
            GetFirebaseSettingForNotificationStatus.loading,
      ),
    );
    final response = await unSubscribeTopicFornotificationUseCase(
      UnSubscribeTopicForNotificationParams(
        topic: event.topic,
        variant: event.variant?.replaceAll("_", "-"),
      ),
    );

    response.fold(
      (l) {
        if (ErrorManager.shouldRetry(
          'UnSubscribeTopicForNotificationEvent',
          l.statusCode,
        )) {
          add(
            UnSubscribeTopicForNotificationEvent(
              topic: event.topic,
              variant: event.variant?.replaceAll("_", "-"),
            ),
          );

          ErrorManager.incrementRetry('UnSubscribeTopicForNotificationEvent');
        }
        emit(
          state.copyWith(
            getFirebaseSettingForNotificationStatus:
                GetFirebaseSettingForNotificationStatus.failure,
          ),
        );
      },
      (r) async {
        ErrorManager.resetRetry('UnSubscribeTopicForNotificationEvent');
        emit(
          state.copyWith(
            firebaseSettingForNotificationModel: r,
            getFirebaseSettingForNotificationStatus:
                GetFirebaseSettingForNotificationStatus.success,
          ),
        );
      },
    );
  }

  FutureOr<void> _onChangeCountryLanguageForNotificationEvent(
    ChangeCountryLanguageForNotificationEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        getFirebaseSettingForNotificationStatus:
            GetFirebaseSettingForNotificationStatus.loading,
      ),
    );
    final response = await changeCountryLanguageFornotificationUseCase(
      ChangeCountryLanguageFornotificationParams(
        country: event.country,
        languageCode: event.languageCode,
      ),
    );

    response.fold(
      (l) {
        if (ErrorManager.shouldRetry(
          'ChangeCountryLanguageForNotificationEvent',
          l.statusCode,
        )) {
          add(
            ChangeCountryLanguageForNotificationEvent(
              country: event.country,
              languageCode: event.languageCode,
            ),
          );

          ErrorManager.incrementRetry(
            'ChangeCountryLanguageForNotificationEvent',
          );
        }

        emit(
          state.copyWith(
            getFirebaseSettingForNotificationStatus:
                GetFirebaseSettingForNotificationStatus.failure,
          ),
        );
      },
      (r) async {
        ErrorManager.resetRetry('ChangeCountryLanguageForNotificationEvent');
        emit(
          state.copyWith(
            firebaseSettingForNotificationModel: r,
            getFirebaseSettingForNotificationStatus:
                GetFirebaseSettingForNotificationStatus.success,
          ),
        );
      },
    );
  }

  _onAddCurrentSelectedColorEvent(
    AddCurrentSelectedColorEvent event,
    Emitter<HomeState> emit,
  ) {
    if (kDebugMode)
      devLog(
        "SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS${event.currentSelectedColor}  ${event.productSlug}",
      );
    emit(
      state.copyWith(
        currentSelectedColorForEveryProductStatus:
            CurrentSelectedColorForEveryProductStatus.loading,
      ),
    );
    Map<String, int> currentSelectedColorForEveryProduct = Map.of(
      state.currentSelectedColorForEveryProduct,
    );
    if (currentSelectedColorForEveryProduct[event.productSlug] == null) {
      currentSelectedColorForEveryProduct.addAll({
        event.productSlug: event.currentSelectedColor,
      });
    } else {
      currentSelectedColorForEveryProduct[event.productSlug] =
          event.currentSelectedColor;
    }
    if (kDebugMode)
      devLog(
        "888888888888888888888///////////////////////////////////****${currentSelectedColorForEveryProduct}",
      );

    emit(
      state.copyWith(
        currentSelectedColorForEveryProductStatus:
            CurrentSelectedColorForEveryProductStatus.success,
        currentSelectedColorForEveryProduct: Map.of(
          currentSelectedColorForEveryProduct,
        ),
      ),
    );
  }

  _onClearAllAppCashEvent(ClearAllAppCashEvent event, Emitter<HomeState> emit) {
    prefsRepository.removeBoutiqueHasPerfechedWhenOpenApp(true);
    prefsRepository.removeMainCategoryHasPerfechedWhenOpenApp(true);

    prefsRepository.removeFiveFilterHasPerfechedWhenOpenApp();
    GetIt.I<BoutiqueBloc>().add(ClearAllBoutiquesEvent());

    prefsRepository.removeMainCategoryWhenOpenApp();
    emit(
      state.copyWith(
        currentSelectedColorForEveryProduct: {},
        reRequestTheseProductListingInBoutiques: {},
        reRequestProductWithFilters: {},
        productStatus: {},
        cartIdsHurryUPTimerStarted: {},
        listOfErrorSendedToMobileErrorLog: [],
        listitemForAddToCart: [],
        getAndAddCountViewOfProductStatus: {},
        getProductDetailWithoutSimilarRelatedProductsStatus:
            GetProductDetailWithoutSimilarRelatedProductsStatus.init,
        getStartingSettingsStatus: GetStartingSettingsStatus.init,
        //  getListOfProductsFoundedInCartStatus:
        //    GetListOfProductsFoundedInCartStatus.init,
        convertItemFromcartToOldCartStatus:
            ConvertItemFromcartToOldCartStatus.init,
        cachedProductWithoutRelatedProductsModel: {},
        //productITemForCart: {},
        cartCollection: [],
        oldCartCollection: [],
      ),
    );
  }

  Future<void> _onGetStoryEvent(
    GetStoryForProductEvent event,
    Emitter<HomeState> emit,
  ) async {
    /*if ((state.finishGetAllStory && event.withPaginition) ||
        (state.getStoryWithPagintionStatusLoading && event.withPaginition)) {
      return;
    }*/
    emit(
      state.copyWith(
        getStoryWithPagintionStatusLoading: true,
        storiesCollections: [],
        // finishGetAllStory:
        //   event.withPaginition ? state.finishGetAllStory : false,
        currentPage: /* event.withPaginition ? state.currentPage + 1 :*/ 1,
        getStoriesForProductStatus: GetStoriesForProductStatus.loading,
      ),
    );
    final response = await getStoryForProductUseCase(
      /*page: state.currentPage.toString()*/ event.productId,
    );

    response.fold(
      (l) {
        if (ErrorManager.shouldRetry('GetStoryEvent', l.statusCode)) {
          ErrorManager.incrementRetry('GetStoryEvent');
          add(
            GetStoryForProductEvent(
              productId:
                  event.productId /*withPaginition: event.withPaginition*/,
            ),
          );
          return;
        }
        emit(
          state.copyWith(
            getStoriesForProductStatus: GetStoriesForProductStatus.failure,
            getStoryWithPagintionStatusLoading: false,
          ),
        );
      },
      (r) {
        ErrorManager.resetRetry('GetStoryEvent');
        Map<int, int> currentStoryInEachCollection = {};
        int i = 0;
        List<CollectionStoryModel>? collections = r.data!.collections;
        /*  if (!(event.withPaginition)) {
        if ((collections?.length ?? 0) > 1) {
          int myStoriesIndex = collections!.indexWhere((element) =>
              GetIt.I<PrefsRepository>().myStoriesId ==
              element.stories![0].userId);
          if (myStoriesIndex != -1) {
            CollectionStoryModel collectionStoryModel =
                collections.removeAt(myStoriesIndex);

            collections.insert(
                (r.data!.collections!.length), collectionStoryModel);
          }
        }
      }*/
        r.data?.collections?.forEach((element) {
          currentStoryInEachCollection[i++] = 0;
        });
        /*    if (event.withPaginition) {
        int i = (state.storiesCollections).length;
        r.data?.collections?.forEach((element) {
          currentStoryInEachCollection[i++] = 0;
        });
      }*/

        emit(
          state.copyWith(
            getStoryWithPagintionStatusLoading: false,
            finishGetAllStory: (r.data?.collections?.length ?? 0) < 10,
            getStoriesForProductStatus: GetStoriesForProductStatus.success,
            storiesCollections: /* event.withPaginition
              ? [...(state.storiesCollections), ...(collections ?? [])]
              : */
                collections,
            currentStoryInEachCollection: currentStoryInEachCollection,
          ),
        );
      },
    );
  }
  /* FutureOr<void> _onGetProductsWithFiltersUsingPaginationEvent(
      GetProductsWithFiltersUsingPaginationEvent event,
      Emitter<HomeState> emit) async {
    Map<String, PaginationModel<product.Products>?>
        getProductListingWithFiltersPaginationModels =
        Map.of(state.getProductListingWithFiltersPaginationModels);

    String keyWithoutFilter = '${event.boutiqueSlug}' +
        '${(event.cashedOrginalBoutique) ? 'withoutFilter' : ""}' +
        '${(event.category ?? '')}';
    String key = '${event.boutiqueSlug}' + '${(event.category ?? '')}';

    if (getProductListingWithFiltersPaginationModels[keyWithoutFilter] ==
        null) {
      getProductListingWithFiltersPaginationModels[keyWithoutFilter] =
          PaginationModel.init();
    }
    if (getProductListingWithFiltersPaginationModels[keyWithoutFilter]
                ?.paginationStatus ==
            PaginationStatus.loading ||
        getProductListingWithFiltersPaginationModels[keyWithoutFilter]!
            .hasReachedMax) {
      return;
    }
    Map<String, filters_model.GetProductFiltersModel?> prevAppliedFiltersByUser,
        prevChoosedFiltersByUser;
    prevChoosedFiltersByUser = Map.of(state.choosedFiltersByUser);
    prevAppliedFiltersByUser = Map.of(state.appliedFiltersByUser);
    filters_model.Prices? prePrice =
        state.appliedFiltersByUser[key]?.filters?.prices;
    filters_model.Filter filters = event.fromChoosed ?? false
        ? state.choosedFiltersByUser[key]?.filters
                ?.copyWithSaveOtherField(searchText: event.searchText) ??
            filters_model.Filter()
        : state.appliedFiltersByUser[key]?.filters?.copyWithSaveOtherField(
                searchText: event.searchText, prices: prePrice) ??
            filters_model.Filter();

    // List<filters_model.Attribute>? attribute;
    // attribute = filters.attributes.isNullOrEmpty
    //     ? ((state.appliedFiltersByUser?.filters?.attributes?.isNullOrEmpty ??
    //             true)
    //         ? null
    //         : state.appliedFiltersByUser!.filters!.attributes!)
    //     : filters.attributes;
    // if (!attribute.isNullOrEmpty &&
    //     !filters.attributes.isNullOrEmpty &&
    //     !(state.appliedFiltersByUser?.filters?.attributes?.isNullOrEmpty ??
    //         true)) {
    //   attribute![0] = attribute[0].copyWith(options: [
    //     ...filters.attributes![0].options ?? [],
    //     ...state.appliedFiltersByUser!.filters!.attributes![0].options ?? []
    //   ]);
    // }
    // filters = filters.copyWithSaveOtherField(
    //   brands: [
    //     ...filters.brands ?? [],
    //     ...state.appliedFiltersByUser?.filters?.brands ?? []
    //   ],
    //   categories: [
    //     ...filters.categories ?? [],
    //     ...state.appliedFiltersByUser?.filters?.categories ?? []
    //   ],
    //   colors: [
    //     ...filters.colors ?? [],
    //     ...state.appliedFiltersByUser?.filters?.colors ?? []
    //   ],
    //   attributes: attribute,
    //   prices: filters.prices ?? state.appliedFiltersByUser?.filters?.prices,
    //   searchText: event.searchText,
    //   boutiques: (event.fromSearch ?? false)
    //       ? [
    //           ...filters.boutiques ?? [],
    //           ...state.appliedFiltersByUser?.filters?.boutiques ?? []
    //         ]
    //       : [],
    // );
    if ((!(event.cashedOrginalBoutique &&
        getProductListingWithFiltersPaginationModels[keyWithoutFilter]
                ?.paginationStatus ==
            PaginationStatus.success))) {
      getProductListingWithFiltersPaginationModels[keyWithoutFilter] =
          getProductListingWithFiltersPaginationModels[keyWithoutFilter]!
              .copyWith(
        paginationStatus: PaginationStatus.loading,
      );
    }
    Map<String, filters_model.GetProductFiltersModel?> choosedFilters =
        Map.of(state.choosedFiltersByUser);
    Map<String, filters_model.GetProductFiltersModel?> appliedFilters =
        Map.of(state.appliedFiltersByUser);
    if (event.resetChoosedFilters) {
      choosedFilters[key] = null;
    }
    if (!(event.fromChoosed ?? false)) {
      if (((filters.colors?.isNullOrEmpty ?? true) &&
          (filters.brands?.isNullOrEmpty ?? true) &&
          (filters.attributes?.isNullOrEmpty ?? true) &&
          (filters.boutiques?.isNullOrEmpty ?? true) &&
          (filters.categories?.isNullOrEmpty ?? true) &&
          (filters.searchText == null) &&
          filters.prices == null)) {
        appliedFilters[key] = null;
      } else {
        appliedFilters[key] =
            filters_model.GetProductFiltersModel(filters: filters);
      }
    }
    devLog('9999999999999 ${state.hashCode}');
    emit(state.copyWith(
      cashedOrginalBoutique: event.cashedOrginalBoutique,
      isGettingProductListingWithPagination: true,
      isGettingProductListingWithPaginationForAppearProduct: true,
      //  reRequestProductWithFilters: Map.of(reRequestProductWithFilters),
      getProductListingWithFiltersPaginationModels:
          Map.of(getProductListingWithFiltersPaginationModels),
      choosedFiltersByUser: Map.of(choosedFilters),
      appliedFiltersByUser: Map.of(appliedFilters),
    ));
    devLog('66666666666666666666 ${state.hashCode}');

    if (state.appliedFiltersByUser[key] == null) {}

    final response = await getProductsWithFiltersUseCase(
        GetProductsWithFiltersParams(
            scroll_id: null,
            brandSlugs:
                filters.brands?.map((e) => '"${e.slug.toString()}"').toList(),
            categorySlugs: event.category != null && event.category != ""
                ? [
                    ...(filters.categories
                            ?.map((e) => '"${e.slug.toString()}"')
                            .toList() ??
                        []),
                    '"${event.category}"'
                  ]
                : filters.categories
                    ?.map((e) => '"${e.slug.toString()}"')
                    .toList(),
            boutiqueSlugs: event.fromSearch ?? false
                ? filters.boutiques
                    ?.map((e) => '"${e.slug.toString()}"')
                    .toList()
                : ['"${event.boutiqueSlug}"'],
            offset: "",
            attributes: filters.attributes.isNullOrEmpty
                ? null
                : [
                    {
                      '"id"': filters.attributes![0].id,
                      '"name"': filters.attributes![0].name,
                      '"options"': filters.attributes![0].options,
                    }
                  ],
            colors: filters.colors?.map((e) => '"${e.toString()}"').toList(),
            limit: event.limit ?? 10,
            prices: (prevAppliedFiltersByUser[key]?.filters?.prices?.maxPrice !=
                        null &&
                    prevAppliedFiltersByUser[key]?.filters?.prices?.minPrice !=
                        null)
                ? [
                    '"${prevAppliedFiltersByUser[key]?.filters?.prices?.minPrice}-${prevAppliedFiltersByUser[key]?.filters?.prices?.maxPrice}"'
                  ]
                : null,
            searchText: filters.searchText ??
                state.appliedFiltersByUser[key]?.filters?.searchText));

    response.fold((l) {
      Map<String, PaginationModel<product.Products>?>
          getProductListingWithFiltersPaginationModels =
          Map.of(state.getProductListingWithFiltersPaginationModels);
      if (!isFailedTheFirstTime
          .contains('GetProductsWithFiltersUsingPaginationEvent')) {
        add(GetProductsWithFiltersUsingPaginationEvent(
          cashedOrginalBoutique: event.cashedOrginalBoutique,
          offset: event.offset,
          boutiqueSlug: event.boutiqueSlug,
          fromChoosed: event.fromChoosed,
          fromSearch: event.fromSearch,
          getWithoutFilter: event.getWithoutFilter,
          resetChoosedFilters: event.resetChoosedFilters,
          category: event.category,
          limit: event.limit,
          searchText: event.searchText,
        ));
        isFailedTheFirstTime.add('GetProductsWithFiltersUsingPaginationEvent');
      }
      getProductListingWithFiltersPaginationModels[keyWithoutFilter] =
          getProductListingWithFiltersPaginationModels[keyWithoutFilter]!
              .copyWith(paginationStatus: PaginationStatus.failure);
      emit(state.copyWith(
          choosedFiltersByUser: Map.of(prevChoosedFiltersByUser),
          getProductListingWithFiltersPaginationModels:
              Map.of(getProductListingWithFiltersPaginationModels),
          appliedFiltersByUser: Map.of(prevAppliedFiltersByUser)));
    }, (r) {
      Map<String, PaginationModel<product.Products>?>
          getProductListingWithFiltersPaginationModels =
          <String, PaginationModel<product.Products>?>{};
      state.getProductListingWithFiltersPaginationModels.forEach((key, value) {
        if (key == keyWithoutFilter) {
          getProductListingWithFiltersPaginationModels.addAll({
            key: value!.copyWith(
                paginationStatus: PaginationStatus.success,
                page: value.page + 1,
                hasReachedMax: (r.data!.products?.length ?? 0) < kPageSize,
                items: [...List.of(value.items), ...r.data!.products ?? []])
          });
          return;
        }
        getProductListingWithFiltersPaginationModels.addAll({key: value});
      });
      //  if (state.idForRequest == idForRequest || state.cashedOrginalBoutique) {
      isFailedTheFirstTime.remove('GetProductsWithFiltersEvent');

      Map<String, filters_model.GetProductFiltersModel?> data =
          Map.of(state.getProductFiltersModel);
      List<filters_model.PriceRange> ranges = r.data!.prices?.priceRanges ?? [];
      ranges.removeWhere((element) => element.count == 0);
      data[key] = filters_model.GetProductFiltersModel(
          filters: filters_model.Filter(
        totalSize: r.data?.totalSize,
        //  boutiqueSlug: r.data?.boutiqueSlug,
        brands: r.data!.brands,
        attributes: r.data!.attributes,
        prices: r.data!.prices?.copyWith(priceRanges: ranges),
        boutiques: r.data!.boutiques,
        colors: r.data!.colors,
        searchText: filters.searchText,
        categories: r.data!.categories,
      ));
      /* getProductListingWithFiltersPaginationModels.removeWhere((key,
                  value) =>
              !(key.contains(idForRequest) || key.contains('withoutFilter')));*/
      devLog(
          'kkkkkkkkkkk ${getProductListingWithFiltersPaginationModels['women-section-67withoutFilter']?.paginationStatus}');
      devLog('sssssssssss ${state.hashCode}');
      emit(state.copyWith(
        getProductListingWithFiltersPaginationModels:
            getProductListingWithFiltersPaginationModels,
        countOfProductExpectedByFiltering:
            Map.of({event.boutiqueSlug: r.data!.totalSize ?? 0}),
        getProductFiltersModel: Map.of(data),
        isGettingProductListingWithPagination: false,
        // removeAlreadyChoosedFilters(
        //     filters_model.GetProductFiltersModel(
        //         filters: filters_model.Filter(
        //           brands: r.data!.brands,
        //           attributes: r.data!.attributes,
        //           prices: r.data!.prices,
        //           //boutiques: r.da,
        //           colors: r.data!.colors,
        //           categories: r.data!.categories,
        //         )),
        //     filters),
      ));
    });
  }*/

  filters_model.GetProductFiltersModel removeAlreadyChoosedFilters(
    filters_model.GetProductFiltersModel r,
    filters_model.Filter filters,
  ) {
    List<String> colors = List.of(r.filters?.colors ?? []);
    List<Category> categories = List.of(r.filters?.categories ?? []);
    List<filters_model.Boutique> boutiques = List.of(
      r.filters?.boutiques ?? [],
    );
    List<filters_model.Brand> brands = List.of(r.filters?.brands ?? []);
    List<filters_model.Attribute> attributes = List.of(
      r.filters?.attributes ?? [],
    );
    if (!filters.colors.isNullOrEmpty) {
      colors.removeWhere((element) => filters.colors!.contains(element));
    }
    if (!filters.categories.isNullOrEmpty) {
      categories.removeWhere(
        (element) =>
            filters.categories!.indexWhere(
              (category) => category.slug == element.slug,
            ) !=
            -1,
      );
    }
    if (!filters.brands.isNullOrEmpty) {
      brands.removeWhere(
        (element) =>
            filters.brands!.indexWhere((brand) => brand.slug == element.slug) !=
            -1,
      );
    }
    if (!filters.boutiques.isNullOrEmpty) {
      boutiques.removeWhere(
        (element) =>
            filters.boutiques!.indexWhere(
              (boutique) => boutique.slug == element.slug,
            ) !=
            -1,
      );
    }

    if (!filters.attributes.isNullOrEmpty && attributes.isNotEmpty) {
      if (!filters.attributes![0].options.isNullOrEmpty) {
        attributes[0].options!.removeWhere(
          (element) =>
              filters.attributes![0].options?.indexWhere(
                (option) => option == element,
              ) !=
              -1,
        );
      }
    }
    return r.copyWithSendValue(
      filters:
          (r.filters!.prices == null &&
              brands.isEmpty &&
              boutiques.isEmpty &&
              categories.isEmpty &&
              attributes.isEmpty &&
              filters.searchText == null &&
              colors.isEmpty)
          ? null
          : filters_model.Filter(
              prices: r.filters!.prices,
              searchText: filters.searchText,
              brands: brands,
              categories: categories,
              colors: colors,
              attributes: attributes,
            ),
    );
  }

  FutureOr<void> _onAddSizesForColorsEvent(
    AddSizesForColorsEvent event,
    Emitter<HomeState> emit,
  ) async {
    List<String> sizes = [];
    List<int> sizesQuantities = [];
    List<String> colors = [];
    List<int> colorsQuantities = [];
    String size;
    String color;
    emit(
      state.copyWith(
        changeSizesForEveryProduct: ChangeSizesForEveryProduct.loading,
      ),
    );

    //emit(state.copyWith(sizes: sizes));
    if (!event.variation.isNullOrEmpty) {
      event.variation!.forEach((element) {
        if (event.currentColorName != "") {
          color = element.type!.split("-")[0];
          colors.add(color);
          colorsQuantities.add((element.qty ?? 0).round());
        }

        if (element.type!.split("-")[0] == event.currentColorName ||
            event.currentColorName == '') {
          try {
            size = element.type!.split(
              "-",
            )[event.currentColorName == '' ? 0 : 1];
            sizes.add(size);
            sizesQuantities.add((element.qty ?? 0).round());
            // if (element.variantNotifyForUser) {}
          } catch (e) {
            devLog('home_bloc.dart: ignored error', e);
          }
        }
      });
    } else {}

    emit(
      state.copyWith(
        sizesForEachColor: sizes,
        colorsForEachProduct: colors,
        colorsQuantitiesForProduct: colorsQuantities,
        changeSizesForEveryProduct: ChangeSizesForEveryProduct.success,
        sizesQuantitiesForEachColor: sizesQuantities,
      ),
    );
  }

  FutureOr<void> _onChangeStatusOFGetProductsDetailsToSuccessEvent(
    ChangeStatusOFGetProductsDetailsToSuccessEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (event.isStatusInitaial ?? false) {
      emit(
        state.copyWith(
          getProductDetailWithoutSimilarRelatedProductsStatus:
              GetProductDetailWithoutSimilarRelatedProductsStatus.init,
        ),
      );
    } else {
      await Future.delayed(const Duration(milliseconds: 300), () {
        Map<String, int> currentSelectedColorForEveryProduct = Map.of(
          state.currentSelectedColorForEveryProduct,
        );
        if (event.index != -1 &&
            event.index != null &&
            event.productSlug != null) {
          if (currentSelectedColorForEveryProduct[event.productSlug] == null) {
            currentSelectedColorForEveryProduct.addAll({
              event.productSlug!: event.index!,
            });
          } else {
            currentSelectedColorForEveryProduct[event.productSlug!] =
                event.index!;
          }
        }
        if (kDebugMode)
          devLog(
            "888888888888888888888///////////////////////////////////${currentSelectedColorForEveryProduct}",
          );
        emit(
          state.copyWith(
            currentSelectedColorForEveryProduct: Map.of(
              currentSelectedColorForEveryProduct,
            ),
            enableAddToCardAfterChangeVariantZero:
                EnableAddToCardAfterChangeVariantZero.success,
            getFullProductDetailsStatus: GetFullProductDetailsStatus.success,
            getProductDetailWithoutSimilarRelatedProductsStatus:
                GetProductDetailWithoutSimilarRelatedProductsStatus.success,
          ),
        );
      });
      await Future.delayed(const Duration(milliseconds: 300), () {
        emit(
          state.copyWith(
            enableAddToCardAfterChangeVariantZero:
                EnableAddToCardAfterChangeVariantZero.success,
          ),
        );
      });
    }
  }

  FutureOr<void> _onGetProductDatailsWithoutRelatedProductsEvent(
    GetProductDatailsWithoutRelatedProductsEvent event,
    Emitter<HomeState> emit,
  ) async {
    add(FetchAuthProductDetailsEvent(event.productSlug ?? ""));
    //  if (state.cachedProductWithoutRelatedProductsModel
    //      .containsKey(event.productId)) return;
    Map<String, GetProductDetailWithoutSimilarRelatedProductsStatus>
    productStatus = Map.from(state.productStatus ?? {});
    /*if (productStatus[event.productId] != null) {
      if (productStatus[event.productId] ==
          GetProductDetailWithoutSimilarRelatedProductsStatus.loading) {
        return;
      }
    }*/
    PaginationModel<FqaComment> getFqaCommentsPaginationModel =
        const PaginationModel<FqaComment>(
          paginationStatus: PaginationStatus.loading,
          items: [],
          page: 0,
          hasReachedMax: false,
          offset: "",
        );
    PaginationModel<BuyersComment> getBuyersCommentsPaginationModel =
        const PaginationModel<BuyersComment>(
          paginationStatus: PaginationStatus.loading,
          items: [],
          page: 0,
          hasReachedMax: false,
          offset: "",
        );
    emit(
      state.copyWith(
        getProductDetailWithoutSimilarRelatedProductsStatus:
            GetProductDetailWithoutSimilarRelatedProductsStatus.loading,
        getBuyersCommentsPaginationModel: {
          "all": getBuyersCommentsPaginationModel,
        },
        getFqaCommentsPaginationModel: {"all": getFqaCommentsPaginationModel},
        currentSlugToRefreshFromNotification: event.productSlug,
      ),
    );

    final response = await getProductDetailWithoutRelatedProductsUseCase(
      event.productSlug!,
    );

    response.fold(
      (l) {
        if (ErrorManager.shouldRetry(
          'GetProductDatailsWithoutRelatedProductsEvent',
          l.statusCode,
        )) {
          add(
            GetProductDatailsWithoutRelatedProductsEvent(
              currentColorOption: event.currentColorOption,
              productId: event.productId,
              productSlug: event.productSlug,
            ),
          );
          ErrorManager.incrementRetry(
            'GetProductDatailsWithoutRelatedProductsEvent',
          );
        }
        emit(
          state.copyWith(
            getProductDetailWithoutSimilarRelatedProductsStatus:
                GetProductDetailWithoutSimilarRelatedProductsStatus.failure,
          ),
        );
      },
      (r) {
        add(
          GetRelatedProductsEvent(
                productSlug: r.product?.id,
                color: event.currentColorOption ?? "",
              )
              as HomeEvent,
        );

        add(DeliveredOrdersResponseEvent(r.product!.id!));

        GetIt.I<ChatBloc>().add(const ChangeStatusShareProructToInitialEvent());
        if (r.product?.isRedeem == true) {
          GetIt.I<PrefsRepository>().setRedeemDateForProduct(
            r.product!.id.toString(),
            "52",
          );
        }
        if ((event.fromListingPage ?? false) == false) {
          /*  add(
            GetAndAddCountViewOfProductEvent(
              productId: r.product!.id.toString(),
            ),
          );*/
          // add(GetCommentForProductEvent(productId: r.product!.id.toString()));
          add(GetStoryForProductEvent(productId: r.product!.id.toString()));
          /*    GetIt.I<ChatBloc>().add(
              GetSharedProductCountEvent(productId: r.product!.id.toString()));*/
        }

        productStatus = Map.from(state.productStatus ?? {});
        productStatus.removeWhere((key, value) => key == event.productId!);
        productStatus.addAll({
          event.productId!:
              GetProductDetailWithoutSimilarRelatedProductsStatus.success,
        });
        apisMustNotToRequest.add(
          'GetProductDatailsWithoutRelatedProductsEvent',
        );

        ErrorManager.resetRetry('GetProductDatailsWithoutRelatedProductsEvent');

        Map<String, GetProductDetailWithoutRelatedProductsModel> newCached =
            Map.of(state.cachedProductWithoutRelatedProductsModel);
        // إنشاء خريطة لترتيب الألوان
        List<SyncColorImageProduct> syncColorImage =
            r.product?.syncColorImages ?? [];
        List<SyncColorImageProduct> syncColorImageReally = [];
        List<ProductColor> productColor = r.product?.colors ?? [];
        List<String> colorFound = [];
        productColor.forEach((element) => colorFound.add(element.option ?? ""));

        for (var i = 0; i < syncColorImage.length; i++) {
          if ((colorFound.contains(syncColorImage[i].colorOption))) {
            syncColorImageReally.add(syncColorImage[i]);
          }
        }

        final syncColorImageOrder = {
          for (var i = 0; i < syncColorImageReally.length; i++)
            syncColorImageReally[i].colorOption: i,
        };

        // ترتيب syncColorImages حسب ترتيب colors
        productColor.sort(
          (a, b) => (syncColorImageOrder[a.option] ?? 999).compareTo(
            (syncColorImageOrder[b.option] ?? 999),
          ),
        );

        // بعد الترتيب، syncColorImages ستكون بترتيب: Green, Red, White
        newCached.removeWhere((key, value) => key == event.productId!);
        newCached.addAll({
          event.productId!: r.copyWith(
            data: r.product?.copyWith(
              colors: productColor,
              syncColorImages: syncColorImageReally,
              slug: event.productSlug ?? r.product?.slug,
            ),
          ),
        });
        int index = -1;

        if (event.currentColorOption != null) {
          index = productColor.indexWhere(
            (element) => element.option == event.currentColorOption,
          );
        }

        /* PaginationModel<Comment>? getCommentsFromAnalyticsPaginationModel =
          PaginationModel<Comment>(
              paginationStatus: PaginationStatus.success,
              items: r.product?.comments ?? [],
              page: 0,
              hasReachedMax: (r.product?.comments?.length ?? 0) < 10,
              offset: r.product?.commentOffset?.toString());*/
        PaginationModel<FqaComment>? getFqaCommentsPaginationModel =
            PaginationModel<FqaComment>(
              paginationStatus: PaginationStatus.success,
              items: r.product?.fqaQuestions?.comments ?? [],
              page: 0,
              total: r.product?.fqaQuestions?.total,
              hasReachedMax:
                  (r.product?.fqaQuestions?.comments?.length ?? 0) < 10 ||
                  r.product?.fqaQuestions?.offset == null ||
                  r.product?.fqaQuestions?.offset == "null",
              offset: r.product?.fqaQuestions?.offset?.toString(),
            );
        PaginationModel<BuyersComment>? getBuyersCommentsPaginationModel =
            PaginationModel<BuyersComment>(
              paginationStatus: PaginationStatus.success,
              items: r.product?.buyersComment?.comments ?? [],
              page: 0,
              total: r.product?.buyersComment?.total,
              hasReachedMax:
                  (r.product?.buyersComment?.comments?.length ?? 0) < 10 ||
                  r.product?.buyersComment?.offset == null ||
                  r.product?.buyersComment?.offset == "null",
              offset: r.product?.buyersComment?.offset?.toString(),
            );

        emit(
          state.copyWith(
            cachedProductWithoutRelatedProductsModel: Map.of(newCached),
            // getCommentsFromAnalyticsPaginationModel:
            //     getCommentsFromAnalyticsPaginationModel,
            getBuyersCommentsPaginationModel: {
              "all": getBuyersCommentsPaginationModel,
            },
            getFqaCommentsPaginationModel: {
              "all": getFqaCommentsPaginationModel,
            },
            productStatus: Map.of(productStatus),
          ),
        );
        add(
          ChangeStatusOFGetProductsDetailsToSuccessEvent(
            index: index,
            productSlug: event.productSlug ?? r.product?.slug ?? "",
          ),
        );
      },
    );
  }

  @override
  HomeState? fromJson(Map<String, dynamic> json) {
    return HomeState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(HomeState state) {
    final map = state
        .copyWith(
          // Heavy, re-fetchable caches are excluded from persistence: they
          // bloat every hydrated write (toJson runs on the main thread on each
          // emit) and are cheaply rebuilt from the network after a restart.
          // حالة صفحة المقارنة عابرة بطبيعتها: لا معنى لاستعادة منتجات
          // اختارها المستخدم في جلسة سابقة، وحفظها يُثقل كل كتابة مُهدرَتة.
          compareProducts: {},
          compareProductDetailsStatus: {},
          compareSlugs: {},
          compareOrder: [],
          cachedProductWithoutRelatedProductsModel: {},
          getProductListingPaginationWithoutFiltersModel: {},
          getFqaCommentsPaginationModel: {},
          getBuyersCommentsPaginationModel: {},
          relatedProducts: [],
          currentSelectedColorForEveryProduct: {},
          reRequestTheseProductListingInBoutiques: {},
          reRequestProductWithFilters: {},
          productStatus: {},
          cartIdsHurryUPTimerStarted: {},
          listOfErrorSendedToMobileErrorLog: [],
          listitemForAddToCart: [],
          getAndAddCountViewOfProductStatus: {},
          addItemInCartStatus: AddItemInCartStatus.init,
          uploadUserPhotoCloudinaryStatus: UploadUserPhotoCloudinaryStatus.init,
          updateItemInCartStatus: UpdateItemInCartStatus.init,
          deleteItemInCartStatus: DeleteItemInCartStatus.init,
          getCartItemsStatus: GetCartItemsStatus.init,
          updateLikeCommentRatingStatus: UpdateLikeCommentRatingStatus.init,
          getOldCartItemsStatus: GetOLdCartItemsStatus.init,
          getProductDetailWithoutSimilarRelatedProductsStatus:
              GetProductDetailWithoutSimilarRelatedProductsStatus.init,
          getStartingSettingsStatus: GetStartingSettingsStatus.init,
          translateCommentStatus: TranslateCommentStatus.init,
          checkAvailabilityProductCartStatus:
              CheckAvailabilityProductCartStatus.init,
          checkWithGetCartStatus: CheckWithGetCartStatus.init,
          getUserNotificationModel: const PaginationModel.init(),
          // Checklist membership is server-owned and re-fetched on every
          // product open, so persisting it would only risk showing a stale
          // green row after a restart.
          checklistItemStatus: {},
          productInChecklist: {},
          getChecklistStatus: GetChecklistStatus.init,
        )
        .toJson();

    // Strip the OTP id token from the persisted user. It is auth material and
    // lives authoritatively in secure storage (prefsRepository.idToken); keeping
    // it here rewrites the JWT into the plaintext hydrated box on every emit.
    // The in-memory state keeps its token — only the on-disk copy is scrubbed.
    final userInfoMap = map['userInfo'];
    if (userInfoMap is Map) {
      userInfoMap['last_otp_id_token'] = null;
    }
    return map;
  }

  /* FutureOr<void> _onGetCommentForProductEvent(
      GetCommentForProductEvent event, Emitter<HomeState> emit) async {
    String keyForCacheData = event.productId;
    Map<String, GetCommentForProductModel> getCommentForProduct =
        Map.of(state.getCommentForProductModel);

    // if (getCommentForProduct[keyForCacheData] == null) {
    //   emit(state.copyWith(
    //       getCommentForProductStatus: GetCommentForProductStatus.init));
    // }

    /*if (!state.getCommentForProductModel.containsKey(keyForCacheData)) {
      emit(state.copyWith(
          getCommentForProductStatus: GetCommentForProductStatus.loading));
    }*/
    emit(state.copyWith(
        getCommentForProductStatus: GetCommentForProductStatus.loading));

    final response = await getCommentForProductUseCase(event.productId);

    response.fold((l) {
      if (ErrorManager.shouldRetry('GetCommentForProductEvent', l.statusCode)) {
        add(GetCommentForProductEvent(productId: event.productId));
        ErrorManager.incrementRetry('GetCommentForProductEvent');
      }
      emit(state.copyWith(
          getCommentForProductModel: Map.of(getCommentForProduct),
          getCommentForProductStatus: GetCommentForProductStatus.failure));
    }, (r) {
      getCommentForProduct = Map.of(state.getCommentForProductModel);
      ErrorManager.resetRetry('GetCommentForProductEvent');
      if (
          //getCommentForProduct[keyForCacheData] == null ||
          !state.getCommentForProductModel.containsKey(keyForCacheData)) {
        getCommentForProduct.addAll({keyForCacheData: r});
      }

      emit(state.copyWith(
        getCommentForProductModel: getCommentForProduct.map((key, value) {
          if (key == keyForCacheData) {
            return MapEntry(key, r);
          } else {
            return MapEntry(key, value);
          }
        }),
        getCommentForProductStatus: GetCommentForProductStatus.success,
      ));
    });
  }
*/
  FutureOr<void> _onGetCartItemEvent(
    GetCartItemEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (state.getCartOverviewStatus == GetCartOverviewStatus.loading) {
      Future.delayed(const Duration(seconds: 5), () {
        add(const GetCartItemEvent());
      });
      return;
    }
    emit(state.copyWith(getCartItemsStatus: GetCartItemsStatus.loading));
    final response = await getCartItemUseCase(NoParams());
    response.fold(
      (l) {
        if (ErrorManager.shouldRetry('GetCartItemEvent', l.statusCode)) {
          add(const GetCartItemEvent());
          ErrorManager.incrementRetry('GetCartItemEvent');
        }
        emit(state.copyWith(getCartItemsStatus: GetCartItemsStatus.failure));
      },
      (r) {
        if (state.getCartOverviewStatus == GetCartOverviewStatus.loading ||
            state.updateItemInCartStatus == UpdateItemInCartStatus.loading ||
            state.addItemInCartStatus == AddItemInCartStatus.loading ||
            state.deleteItemInCartStatus == DeleteItemInCartStatus.loading) {
          Future.delayed(const Duration(seconds: 5), () {
            add(const GetCartItemEvent());
          });

          return;
        }
        List<Cart> carts;
        List<Cart> cartCollection = [];
        Map<String, Map<int, List<List<String>>>> addImagesToProductIdForCart =
            {};
        Map<String, Map<String, String>> addVariationToCartId = {};
        r.data?.cart?.forEach(
          (element) => addVariationToCartId.addAll({
            element.id.toString(): {
              "size": element.variations == null
                  ? ""
                  : "${element.variations?.sizeOption ?? ""}",
              "color": element.variations == null
                  ? ""
                  : "${element.variations?.colorOption ?? ""}",
            },
          }),
        );
        emit(state.copyWith(currentQuantityForCart: {}));
        List<String> cartIdIsFound = [];
        r.data?.cart?.forEach((element) {
          cartIdIsFound.add(element.id.toString());
          add(
            AddQuantityForCartEvent(
              quantity: element.quantity ?? 0,
              productId: element.productId.toString(),
              currentSize: element.variations == null
                  ? ""
                  : element.variations?.sizeOption ?? "",
              cartId: element.id ?? 0,
              colorName: element.variations == null
                  ? ""
                  : element.variations?.colorOption ?? "",
            ),
          );

          if (addImagesToProductIdForCart[element.productId.toString()] ==
              null) {
            addImagesToProductIdForCart[element.productId.toString()] = {};
          }
          if (!addImagesToProductIdForCart[element.productId
                  .toString()]![element.id]
              .isNullOrEmpty) {
            for (int i = 0; i < element.quantity!; i++) {
              addImagesToProductIdForCart[element
                    ..productId.toString()]![element.id]!
                  .add([
                    element.image ?? "",
                    element.variations == null
                        ? "null"
                        : element.variations == null
                        ? "null"
                        : element.variations?.color ?? "null",
                    element.variations == null
                        ? "null"
                        : element.variations?.size ?? "null",
                  ]);
            }
            ;
          } else {
            addImagesToProductIdForCart[element.productId.toString()]!.addAll({
              element.id!: [],
            });

            addImagesToProductIdForCart[element.productId
                    .toString()]![element.id!] =
                [];

            for (int i = 0; i < element.quantity!; i++) {
              addImagesToProductIdForCart[element.productId
                      .toString()]![element.id]!
                  .add([
                    element.image ?? "",
                    element.variations == null
                        ? "null"
                        : element.variations == null
                        ? "null"
                        : element.variations?.color ?? "null",
                    element.variations == null
                        ? "null"
                        : element.variations?.size ?? "null",
                  ]);
            }
            ;
          }
        });

        carts = r.data!.cart!;
        carts.forEach((element) {
          cartCollection.add(element);
        });

        ErrorManager.resetRetry('GetCartItemEvent');

        //   Map<String, int> cartIdsHurryUPTimerStarted =
        //    Map.of(state.cartIdsHurryUPTimerStarted);

        /* for (var i = 0; i < cartCollection.length; i++) {
        if ((cartCollection[i].haveHurryUpNotifyTimeLeft ?? false) &&
            (cartIdsHurryUPTimerStarted[cartCollection[i].id.toString()] ==
                null)) {
          add(AddTimerStartedToHurryUpEvent(
              cartId: cartCollection[i].id.toString(),
              isAddToList: true,
              timeLeft: (DateTime.now().millisecondsSinceEpoch +
                      1000 *
                          60 *
                          (((cartCollection[i].timeLeftInMinutes ?? 0)
                                  .toDouble()) +
                              1))
                  .round()));
        }
      }*/
        /* if (cartIdsHurryUPTimerStarted.isNotEmpty) {
        for (var i = 0; i < cartIdsHurryUPTimerStarted.length; i++) {
          if (!cartCollection.contains(cartIdsHurryUPTimerStarted[i])) {
            add(AddTimerStartedToHurryUpEvent(
                cartId: cartIdsHurryUPTimerStarted.keys.toList()[i],
                isAddToList: false,
                timeLeft: 0));
          }
        }
      }*/
        emit(
          state.copyWith(
            getCartOverviewStatus: GetCartOverviewStatus.success,
            addImagesToProductIdForCart: addImagesToProductIdForCart,
            addVariationToCartId: addVariationToCartId,
            getCartShippingItemsModel: r,
            cartCollection: List.of(cartCollection),
            getCartItemsStatus: GetCartItemsStatus.success,
          ),
        );

        ////////////////////   ///////////////////
        List<Map<String, String>> analyticsCartList = [];
        cartCollection.forEach((element) {
          Map<String, String> item = {
            'item_id': element.productId.toString(),
            'item_name': element.name.toString(),
            'price': element.price.toString(),
            'quantity': element.quantity.toString(),
            'brand': element.brand!.name.toString(),
            'category': '',
            'item_variant': element.variant.toString(),
          };

          analyticsCartList.add(item);
        });

        /////////////////////////////////
        Future.delayed(const Duration(milliseconds: 300), () {
          try {
            FirebaseAnalyticsService.logEventForSession(
              eventName: AnalyticsEventsConst.VIEW_CART,
              extraParams: {
                'currency': state
                    .getCurrencyForCountryModel!
                    .data!
                    .currency!
                    .symbol
                    .toString(),
                'value': state.getCartShippingItemsModel!.data!.total
                    .toString(),
                'items': analyticsCartList.toString(),
                'screen_name': GlobalScreenConst.CART_SCREEN,
              },
              executedEventName: AnalyticsButtonsEventNameConst.CART_ICON,
            );
          } catch (e) {
            devLog('home_bloc.dart: ignored error', e);
          }
        });

        //////////////////////////////////
        // add(AddItemToCartEvent());
        add(const GetOldCartItemEvent());
      },
    );
  }

  bool isInPlaceOrder = false;

  FutureOr<void> _onCheckWithGetCartEvent(
    CheckWithGetCartEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(checkWithGetCartStatus: CheckWithGetCartStatus.loading),
    );
    final response = await getCartItemUseCase(NoParams());
    response.fold(
      (l) {
        if (ErrorManager.shouldRetry('CheckWithGetCartEvent', l.statusCode)) {
          add(CheckWithGetCartEvent(isForPlaceOrder: event.isForPlaceOrder));
          ErrorManager.incrementRetry('CheckWithGetCartEvent');
          return;
        }
        emit(
          state.copyWith(
            checkWithGetCartStatus: CheckWithGetCartStatus.failure,
          ),
        );
      },
      (r) {
        List<Cart> carts;
        List<Cart> cartCollection = [];
        Map<String, Map<int, List<List<String>>>> addImagesToProductIdForCart =
            {};

        emit(state.copyWith(currentQuantityForCart: {}));
        List<String> cartIdIsFound = [];
        r.data?.cart?.forEach((element) {
          cartIdIsFound.add(element.id.toString());
          add(
            AddQuantityForCartEvent(
              quantity: element.quantity ?? 0,
              productId: element.productId.toString(),
              currentSize: element.variations == null
                  ? ""
                  : element.variations?.sizeOption ?? "",
              cartId: element.id ?? 0,
              colorName: element.variations == null
                  ? ""
                  : element.variations?.colorOption ?? "",
            ),
          );
          if (addImagesToProductIdForCart[element.productId.toString()] ==
              null) {
            addImagesToProductIdForCart[element.productId.toString()] = {};
          }
          if (!addImagesToProductIdForCart[element.productId
                  .toString()]![element.id]
              .isNullOrEmpty) {
            for (int i = 0; i < element.quantity!; i++) {
              addImagesToProductIdForCart[element
                    ..productId.toString()]![element.id]!
                  .add([
                    element.image ?? "",
                    element.variations == null
                        ? "null"
                        : element.variations == null
                        ? "null"
                        : element.variations?.color ?? "null",
                    element.variations == null
                        ? "null"
                        : element.variations?.size ?? "null",
                  ]);
            }
            ;
          } else {
            addImagesToProductIdForCart[element.productId.toString()]!.addAll({
              element.id!: [],
            });

            addImagesToProductIdForCart[element.productId
                    .toString()]![element.id!] =
                [];

            for (int i = 0; i < element.quantity!; i++) {
              addImagesToProductIdForCart[element.productId
                      .toString()]![element.id]!
                  .add([
                    element.image ?? "",
                    element.variations == null
                        ? "null"
                        : element.variations == null
                        ? "null"
                        : element.variations?.color ?? "null",
                    element.variations == null
                        ? "null"
                        : element.variations?.size ?? "null",
                  ]);
            }
            ;
          }
        });

        carts = r.data!.cart!;
        carts.forEach((element) {
          cartCollection.add(element);
        });

        ErrorManager.resetRetry('CheckWithGetCartEvent');

        emit(
          state.copyWith(
            addImagesToProductIdForCart: addImagesToProductIdForCart,
            getCartShippingItemsModel: r,
            cartCollection: List.of(cartCollection),
            checkWithGetCartStatus: event.isForPlaceOrder
                ? CheckWithGetCartStatus.successForPlaceOrder
                : CheckWithGetCartStatus.successForCart,
          ),
        );
      },
    );

    add(const GetOldCartItemEvent());
  }

  FutureOr<void> _onGetOldCartItemEvent(
    GetOldCartItemEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(getOldCartItemsStatus: GetOLdCartItemsStatus.loading));
    final response = await getOldCartItemUseCase(NoParams());
    response.fold(
      (l) {
        if (ErrorManager.shouldRetry('GetoldCartItemEvent', l.statusCode)) {
          add(const GetOldCartItemEvent());
          ErrorManager.incrementRetry('GetoldCartItemEvent');
          return;
        }
        emit(state.copyWith(getCartItemsStatus: GetCartItemsStatus.failure));
      },
      (r) {
        List<oldCart.OldCart> oldCartCollection = [];
        List<oldCart.OldCart>? oldCarts;
        if (state.hideItemInOldCartStatus == HideItemInOldCartStatus.loading) {
          add(const GetOldCartItemEvent());
          emit(
            state.copyWith(
              hideItemInOldCartStatus: HideItemInOldCartStatus.success,
            ),
          );
          return;
        }
        oldCarts = r.data?.oldCart;
        oldCarts?.forEach((element) {
          oldCartCollection.add(element);
        });
        state.cartCollection?.forEach((elements) {
          oldCartCollection.removeWhere(
            (element) =>
                elements.variations?.colorOption ==
                    element.variations?.colorOption &&
                elements.variations?.sizeOption ==
                    element.variations?.sizeOption &&
                elements.productId == element.productId,
          );
        });

        //Map<String, Products> productITemForCart =
        //    Map.of(state.productITemForCart);

        // List<String> productIdsInCart = [];
        /* state.cartCollection?.forEach(
        (element) {
          productIdsInCart.add(element.productId.toString());
        },
      );
      oldCartCollection.forEach(
        (element) {
          productIdsInCart.add(element.productId.toString());
        },
      );
      productITemForCart.removeWhere(
        (key, value) => !productIdsInCart.contains(key),
      );*/

        ErrorManager.resetRetry('GetoldCartItemEvent');
        emit(
          state.copyWith(
            //  productITemForCart: productITemForCart,
            getOldCartModel: r,
            oldCartCollection: List.of(oldCartCollection),
            getOldCartItemsStatus: GetOLdCartItemsStatus.success,
          ),
        );
      },
    );
  }

  /*FutureOr<void> _onGetProductsListInCartEventEvent(
      GetProductsListInCartEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(
        getListOfProductsFoundedInCartStatus:
            GetListOfProductsFoundedInCartStatus.loading));

    /* if (productITemForCart.isNotEmpty) {
      return;
    }*/
    final response = await getProductsListInCartUseCase(NoParams());
    response.fold((l) {
      emit(state.copyWith(
          getListOfProductsFoundedInCartStatus:
              GetListOfProductsFoundedInCartStatus.failure));
    }, (r) {
      Map<String, Products> productITemForCart = {};
      r.data?.forEach(
        (element) {
          productITemForCart.addAll({element.productId.toString(): element});
        },
      );

      emit(state.copyWith(
        getListOfProductsFoundedInCartStatus:
            GetListOfProductsFoundedInCartStatus.success,
        productITemForCart: productITemForCart,
      ));
    });
  }*/

  FutureOr<void> _onSaveUserInfoEvent(
    SaveUserInfoFromAuthEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        userInfo: event.userInfo,
        statusCodeOfCommentProcess: "200",
      ),
    );
  }

  FutureOr<void> _onSendErrorToMobileErrorLogEvent(
    SendErrorToMobileErrorLogEvent event,
    Emitter<HomeState> emit,
  ) async {
    List<String> listOfErrorSendedToMobileErrorLog = List.of(
      state.listOfErrorSendedToMobileErrorLog,
    );
    String key =
        event.errorExption +
        event.errorPath +
        event.messageFromeBackend +
        event.urlBackend;
    if (event.errorExption.contains("RenderFlex") ||
        (event.errorExption.toString().contains(
          "https://res.cloudinary.com",
        )) ||
        (event.errorExption.toString().contains("SocketException"))) {
      return;
    }
    if (listOfErrorSendedToMobileErrorLog.contains(key)) {
      return;
    }
    listOfErrorSendedToMobileErrorLog.add(key);
    emit(
      state.copyWith(
        listOfErrorSendedToMobileErrorLog: listOfErrorSendedToMobileErrorLog,
      ),
    );
    final requests = prefsRepository.getRequestsData();
    Map<String, dynamic>? lastApiRequest;
    if (requests.isNotEmpty) {
      // استبعد أي طلبات flutter_error
      requests.removeWhere(
        (element) =>
            (element.containsKey('flutter_error') ||
            element["url"].contains("mobile_error_log")),
      );
      if (requests.isNotEmpty) {
        lastApiRequest = requests.last;
      }
    }

    final userInfo = {
      "flutterVersion": applicationVersion,
      "deviceInfo": await HelperFunctions.getDeviceId(),
      "clientIp":
          "${GetIt.I<AuthBloc>().state.getUserCountryResponseModel?.ip}  ${GetIt.I<AuthBloc>().state.getUserCountryResponseModel?.countryCode}",
      "errorType": event.errorExption,
      "lastFourPageVisited": event.lastForPageHasBeenVisited,
      "userMarketId": prefsRepository.myMarketId ?? "",
      "userMarketName": prefsRepository.myMarketName ?? "",
      "userMarketPhone": prefsRepository.myPhoneNumber ?? "",
      "userChatId": prefsRepository.myChatId ?? "",
      "userChatName": prefsRepository.myChatName ?? "",
      "userWalletToken": prefsRepository.walletToken ?? "",
      "userStoriesName": prefsRepository.myStoriesName ?? "",
      "userChatPhoto": prefsRepository.myChatPhoto ?? "",
      "userStoriesId": prefsRepository.myStoriesId ?? "",
      "userProfilePhoto": prefsRepository.myProfilePhoto ?? "",
      "userCountryIso": prefsRepository.countryIso ?? "",
      "userCountryIsAvailable": prefsRepository.userCountryIsAvailable ?? "",
      "userUserChoosedCountryIso": prefsRepository.userChoosedCountryIso ?? "",
      "userMarketToken": prefsRepository.marketToken ?? "",
      "userChatToken": prefsRepository.chatToken ?? "",
      "userStoriesToken": prefsRepository.storiesToken ?? "",
      "userVerifiedPhone": prefsRepository.isVerifiedPhone ?? "",
      "language": prefsRepository.language ?? "",
      "urlBackend": event.urlBackend,
      "messageFromeBackend": event.messageFromeBackend,
      "lastApiRequest": lastApiRequest?.toString(),
      "errorPath": event.errorPath,
    };
    final errorMessage = jsonEncode(userInfo);

    final response = await sendErrorToMobileErrorLogUseCase(
      SendErrorToMobileErrorLogParams(errorDescription: errorMessage),
    );
    response.fold((l) {}, (r) {});
  }

  FutureOr<void> _onAddCurrentSizeColorEvent(
    AddCurrentColorSizeEvent event,
    Emitter<HomeState> emit,
  ) async {
    Map<String, String> sizeColor;

    sizeColor = {
      "size": event.choice_1 ?? "",
      "choiceOption": event.choiceOption ?? "",
    };
    emit(state.copyWith(currentColorSizeForCart: sizeColor));
  }

  FutureOr<void> _onAddItemToCartEvent(
    AddItemToCartEvent event,
    Emitter<HomeState> emit,
  ) async {
    String currentSize = event.choiceOption!;
    Map<String, List<int>> currentQuantity = Map.of(
      state.currentQuantityForCart ?? {},
    );

    String key =
        "${event.products.productId.toString()}" +
        "${event.colorOption}" +
        "${currentSize}";

    if (event.quantity == 0) {
      return;
    }
    if (!currentQuantity[key].isNullOrEmpty) {
      int? quantity = event.quantity!.round() + currentQuantity[key]![0];
      if (quantity > (double.tryParse(event.maxAllowed ?? "0") ?? 0) &&
          (double.tryParse(event.maxAllowed ?? "0") ?? 0) != 0) {
        showMessage(
          "${LocaleKeys.you_reach_the_max_allowed_quantity.tr()} \n (${double.tryParse(event.maxAllowed ?? "0")?.round()} ${LocaleKeys.item.tr()}) ${LocaleKeys.of_this_product.tr()} \n ${LocaleKeys.you_can_add_only.tr()} ${((double.tryParse(event.maxAllowed ?? "0") ?? 0) - (currentQuantity.isEmpty ? 0 : currentQuantity[key]![0])).round()} ${LocaleKeys.item.tr()}",
          foreGroundColor: Colors.white,
          backGroundColor: Colors.black,
          hasError: true,
          showInRelease: true,
        );
        return;
      }
      if (currentQuantity[key]![0] > 0) {
        currentQuantity[key]![0] = quantity;
        emit(state.copyWith(currentQuantityForCart: currentQuantity));
        add(
          UpdateItemInCartEvent(
            fromCartPage: event.fromCartPage,
            newQuantity: event.quantity!.round(),
            fishAddAllTheItems: event.finishAddAllTheItems,
            image: event.image,
            currentSize: currentSize,
            maxAllowed: (double.tryParse(event.maxAllowed ?? "0") ?? 0),
            colorOption: event.colorOption,
            productId: event.products.productId.toString(),
            totalQuantity: quantity,
            cartId: currentQuantity[key]![1].toString(),
            boutiqueId: event.boutiqueId.toString(),
          ),
        );
        return;
      }
    } else {
      currentQuantity[key]?[0] = event.quantity ?? 0;
      emit(state.copyWith(currentQuantityForCart: currentQuantity));
      if (event.quantity!.round() >
              (double.tryParse(event.maxAllowed ?? "0") ?? 0) &&
          (double.tryParse(event.maxAllowed ?? "0") ?? 0) != 0) {
        showMessage(
          "${LocaleKeys.you_reach_the_max_allowed_quantity.tr()} \n (${double.tryParse(event.maxAllowed ?? "0")?.round()} ${LocaleKeys.item.tr()}) ${LocaleKeys.of_this_product.tr()} \n ${LocaleKeys.you_can_add_only.tr()} ${((double.tryParse(event.maxAllowed ?? "0") ?? 0) - (currentQuantity.isEmpty ? 0 : currentQuantity[key]![0])).round()} ${LocaleKeys.item.tr()}",
          foreGroundColor: Colors.white,
          backGroundColor: Colors.black,
          hasError: true,
          showInRelease: true,
        );
        return;
      }
    }

    CartBrand brand = CartBrand(
      icon: CartIcon(
        originalHeight: "50",
        filePath: event.products.brand != null
            ? event.products.brand!.icon != null
                  ? event.products.brand!.icon!.filePath
                  : ""
            : "",
        originalWidth: "50",
      ),
    );
    VariationCart variation = VariationCart(
      color: event.colorName,
      colorOption: event.colorOption,
      size: event.sizeName,
      sizeOption: event.choiceOption,
    );
    String currentUuid = const Uuid().v4();
    BoutiquesCart boutiquesCart = BoutiquesCart(
      icon: IconCart(filePath: event.boutiqueIcon),
      id: event.boutiqueId,
    );
    Cart cart = Cart(
      uuid: currentUuid,
      countOfPieces: event.countOfPieces,
      image: event.image,
      boutique: boutiquesCart,
      isRedeem: event.isRedeem,
      offerPrice: event.isRedeem
          ? event.redeemVariantPrice
          : event.products.offerPrice,
      name: event.products.name,
      price: event.products.price,
      quantity: event.quantity,
      brand: brand,
      variations: variation,
      productId: event.products.productId,
    );
    List<Cart>? cartCollection = List.of(state.cartCollection ?? []);
    List<oldCart.OldCart>? oldCartCollection = List.of(
      state.oldcartCollection ?? [],
    );
    /* if (cartCollection == {}) {
      emit(state
          .copyWith(cartCollection: {"${event.boutiqueId.toString()}": []}));
    }*/

    cartCollection.insert(0, cart);

    oldCart.OldCart? PreOldCart = oldCartCollection.firstWhere(
      (element) =>
          element.image == event.image &&
          (element.variations != null
              ? ((element.variations?.colorOption ?? '') ==
                    (variation.colorOption ?? ''))
              : true) &&
          (element.variations != null
              ? ((element.variations?.sizeOption ?? '') ==
                    (variation.sizeOption ?? ''))
              : true),
      orElse: () => oldCart.OldCart(id: -1),
    );
    oldCartCollection.removeWhere(
      (element) =>
          element.image == event.image &&
          (element.variations != null
              ? ((element.variations?.colorOption ?? "") ==
                    (variation.colorOption ?? ""))
              : true) &&
          (element.variations != null
              ? ((element.variations?.sizeOption ?? "") ==
                    (variation.sizeOption ?? ''))
              : true),
    );
    emit(
      state.copyWith(
        oldCartCollection: oldCartCollection,
        cartCollection: cartCollection,
        addItemInCartStatus: AddItemInCartStatus.loading,
      ),
    );

    final response = await addItemToCartUseCase(
      AddITemToCartParams(
        image: event.image.split("/").last,
        variationId: event.variationId,
        isRedeem: event.isRedeem,

        id: event.products.productId.toString(),
        quantity: event.quantity,
      ),
    );

    response.fold(
      (l) {
        if (ErrorManager.shouldRetry('AddCartItemEvent', l.statusCode)) {
          add(
            AddItemToCartEvent(
              fromCartPage: event.fromCartPage,
              isRedeem: event.isRedeem,
              redeemVariantPrice: event.redeemVariantPrice,
              colorName: event.colorName,
              sizeName: event.sizeName,
              boutiqueIcon: event.boutiqueIcon,
              variationId: event.variationId,
              boutiqueId: event.boutiqueId,
              finishAddAllTheItems: event.finishAddAllTheItems,
              countOfPieces: event.countOfPieces,
              colorOption: event.colorOption,
              productSlugForTopic: event.productSlugForTopic,
              image: event.image,
              products: event.products,
              choiceOption: event.choiceOption,
              maxAllowed: event.maxAllowed,
              color: event.color,
              quantity: event.quantity,
            ),
          );

          ErrorManager.incrementRetry('AddCartItemEvent');
          add(
            UpdateListOfItemForAddToCartEvent(
              imageForAddToCart: ImageForAddToCart(),
              operation: "remove",
              productId: event.products.productId.toString(),
              resetTheList: true,
            ),
          );

          state.cartCollection!.remove(cart);

          if (PreOldCart.id != -1) {
            state.oldcartCollection!.add(PreOldCart);
          }

          emit(
            state.copyWith(
              cartCollection: state.cartCollection,
              oldCartCollection: state.oldcartCollection,
            ),
          );
          return;
        }

        add(
          UpdateListOfItemForAddToCartEvent(
            imageForAddToCart: ImageForAddToCart(),
            operation: "remove",
            productId: event.products.productId.toString(),
            resetTheList: true,
          ),
        );

        state.cartCollection!.remove(cart);

        if (PreOldCart.id != -1) {
          state.oldcartCollection!.add(PreOldCart);
        }

        emit(
          state.copyWith(
            cartCollection: state.cartCollection,
            addItemInCartStatus: AddItemInCartStatus.failure,
            oldCartCollection: state.oldcartCollection,
          ),
        );

        if (l.statusCode != 401) {
          showMessage(
            l.message,
            foreGroundColor: Colors.white,
            hasError: true,
            backGroundColor: Colors.black,
          );
        }
      },
      (r) {
        add(GetCartOverviewEvent());
        Variation? variation;
        GetAuthProductDetailsModel getAuthProductDetailsModel =
            state.authProductDetailsModel ?? GetAuthProductDetailsModel();
        List<Variation> listVariation =
            getAuthProductDetailsModel.data?.variation ?? [];
        int availableQuantity =
            getAuthProductDetailsModel.data?.availableQuantity ?? 0;

        int index = listVariation.indexWhere(
          (element) =>
              element.type ==
              "${event.colorOption}${(event.colorOption != "" && event.choiceOption != "") ? "-" : ""}${event.choiceOption}",
        );
        ErrorManager.resetRetry('AddCartItemEvent');
        add(
          UpdateListOfItemForAddToCartEvent(
            imageForAddToCart: ImageForAddToCart(),
            operation: "remove",
            productId: event.products.productId.toString(),
            resetTheList: true,
          ),
        );

        if (r.data == null || r.data == "" || (r.data?.status ?? 0) != 1) {
          if (index != -1) {
            variation = listVariation[index];
            listVariation.removeAt(index);

            variation = variation.copyWith(qty: 0);
            listVariation.insert(index, variation);

            getAuthProductDetailsModel = getAuthProductDetailsModel.copyWith(
              data: getAuthProductDetailsModel.data!.copyWith(
                variation: listVariation,
              ),
            );
          }
          showDialog(
            context: navigatorKey.currentState!.context,
            builder: (context) => AlertDialog(
              title: MyTextWidget(
                "${r.message}",
                style: context.textTheme.labelMedium?.copyWith(
                  color: Colors.red,
                  height: 1.25,
                ),
              ),
              actions: <Widget>[
                SingleChildScrollView(
                  child: Column(
                    children: [
                      MyTextWidget(
                        "${LocaleKeys.do_you_want_to_notify_You_when_your_choose_available.tr()}",
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: Colors.black,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppElevatedButton(
                            child: Text(
                              "${LocaleKeys.not_now.tr()}",
                              style: const TextStyle(color: Colors.red),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          AppElevatedButton(
                            child: Text(
                              "${LocaleKeys.notify_me.tr()}",
                              style: const TextStyle(color: Colors.green),
                            ),
                            onPressed: () {
                              add(
                                RequestForNotificationWhenProductBecameAvailableEvent(
                                  event.products.productId.toString(),
                                  state.startingSetting?.notificationTypes
                                          ?.firstWhere(
                                            (type) =>
                                                type.name ==
                                                'product availability',
                                            orElse: () =>
                                                NotificationType(id: -1),
                                          )
                                          .id ??
                                      -1,
                                  event.choiceOption ?? "",
                                  event.colorOption,
                                  true,
                                ),
                              );
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );

          cartCollection.remove(cart);
          if (!event.fromCartPage) {
            add(
              AddSizesForColorsEvent(
                currentColorName:
                    state
                            .cachedProductWithoutRelatedProductsModel[event
                                .products
                                .productId
                                .toString()]!
                            .product
                            ?.colors
                            ?.isNullOrEmpty ??
                        true
                    ? ""
                    : state
                              .cachedProductWithoutRelatedProductsModel[event
                                  .products
                                  .productId
                                  .toString()]!
                              .product!
                              .colors?[state
                                      .currentSelectedColorForEveryProduct[event
                                      .products
                                      .slug] ??
                                  0]
                              .option ??
                          "",
                variation: listVariation,
              ),
            );
          }

          emit(
            state.copyWith(
              addItemInCartStatus: AddItemInCartStatus.success,
              cartCollection: cartCollection,

              authProductDetailsModel: getAuthProductDetailsModel,
            ),
          );

          /* if (event.fishAddAllTheItems) {
          showMessage(r.message!,
              foreGroundColor: Colors.white,
              backGroundColor: Colors.black,
              showInRelease: true,
              timeShowing: Toast.LENGTH_SHORT);
          isFailedTheFirstTime.remove('AddCartItemEvent');
          add(GetCartItemEvent());
        }*/

          return;
        } else {
          if (index != -1) {
            variation = listVariation[index];
            listVariation.removeAt(index);
            variation = variation.copyWith(
              qty: ((variation.qty)! - (event.quantity ?? 0)),
            );
            listVariation.insert(index, variation);
          }
          getAuthProductDetailsModel = getAuthProductDetailsModel.copyWith(
            data: getAuthProductDetailsModel.data!.copyWith(
              variation: listVariation,
              availableQuantity: ((availableQuantity) - (event.quantity ?? 0))
                  .round(),
            ),
          );
          Map<String, Map<String, String>> addVariationToCartId = Map.of(
            state.addVariationToCartId ?? {},
          );
          addVariationToCartId.addAll({
            r.data!.idCart.toString(): {
              "size": "${event.choiceOption ?? ""}",
              "color": "${event.colorOption}",
            },
          });
          Map<String, Map<int, List<List<String>>>>
          addImagesToProductIdForCart = Map.from(
            state.addImagesToProductIdForCart,
          );
          if (addImagesToProductIdForCart[event.products.productId
                  .toString()] ==
              null) {
            addImagesToProductIdForCart[event.products.productId.toString()] =
                {};
          }
          if (!addImagesToProductIdForCart[event.products.productId
                  .toString()]![r.data!.idCart!]
              .isNullOrEmpty) {
            for (int i = 0; i < event.quantity!; i++) {
              addImagesToProductIdForCart[event.products.productId
                      .toString()]![r.data!.idCart!]!
                  .add([
                    event.image,
                    event.colorName == "" ? "null" : event.colorName,
                    event.sizeName == "" ? "null" : event.sizeName,
                  ]);
            }
            ;
          } else {
            addImagesToProductIdForCart[event.products.productId
                    .toString()]![r.data!.idCart!] =
                [];
            for (int i = 0; i < event.quantity!; i++) {
              addImagesToProductIdForCart[event.products.productId
                      .toString()]![r.data!.idCart!]!
                  .add([
                    event.image,
                    event.colorName == "" ? "null" : event.colorName,
                    event.sizeName == "" ? "null" : event.sizeName,
                  ]);
            }
            ;
          }
          add(
            AddQuantityForCartEvent(
              currentSize: currentSize,
              colorName: event.colorOption,
              cartId: r.data!.idCart!,
              quantity: event.quantity!,
              productId: event.products.productId.toString(),
            ),
          );
          cartCollection.removeWhere((element) => element.uuid == currentUuid);

          cart = cart.copyWith(id: r.data!.idCart!);
          cartCollection.insert(0, cart);
          if (!event.fromCartPage) {
            add(
              AddSizesForColorsEvent(
                currentColorName:
                    state
                            .cachedProductWithoutRelatedProductsModel[event
                                .products
                                .productId
                                .toString()]!
                            .product
                            ?.colors
                            ?.isNullOrEmpty ??
                        true
                    ? ""
                    : state
                              .cachedProductWithoutRelatedProductsModel[event
                                  .products
                                  .productId
                                  .toString()]!
                              .product!
                              .colors?[state
                                      .currentSelectedColorForEveryProduct[event
                                      .products
                                      .slug] ??
                                  0]
                              .option ??
                          "",
                variation: listVariation,
              ),
            );
          }

          emit(
            state.copyWith(
              addItemInCartStatus: AddItemInCartStatus.success,
              authProductDetailsModel: getAuthProductDetailsModel,
              addVariationToCartId: addVariationToCartId,
              cartCollection: cartCollection,
              addImagesToProductIdForCart: addImagesToProductIdForCart,
            ),
          );
        }
        if (event.finishAddAllTheItems) {
          showMessage(
            r.message!,
            foreGroundColor: Colors.white,
            backGroundColor: Colors.black,
            showInRelease: true,
            timeShowing: Toast.LENGTH_SHORT,
          );
        }
      },
    );
  }

  /* FutureOr<void> _onAddProductItemForCartEvent(
      AddProductItemForCartEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(addItemInCartStatus: AddItemInCartStatus.init));
   // Map<String, Products> productsForCart = Map.of(state.productITemForCart);
    if (productsForCart.containsKey(event.productId)) {
      productsForCart[event.productId] = event.product!;
    } else {
      productsForCart.addAll({event.productId: event.product!});
    }
    emit(state.copyWith(productITemForCart: Map.of(productsForCart)));
  }*/

  FutureOr<void> _onRemoveItemToCartEvent(
    RemoveItemFormCartEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(deleteItemInCartStatus: DeleteItemInCartStatus.init));

    Cart cart = state.cartCollection!.firstWhere(
      (element) => element.id.toString() == event.itemId,
    );
    List<Cart>? cartCollection = List.of(state.cartCollection!);
    cartCollection.remove(cart);

    Map<String, Map<int, List<List<String>>>> addImagesToProductIdForCart =
        Map.of(state.addImagesToProductIdForCart);
    List<List<String>> preListImage = [];
    if (addImagesToProductIdForCart[event.productId] != null) {
      if (!addImagesToProductIdForCart[event.productId]![int.parse(
            event.itemId,
          )]
          .isNullOrEmpty) {
        addImagesToProductIdForCart[event.productId]![int.parse(event.itemId)]!
            .forEach((element) {
              if (element[0] == event.image) {
                preListImage.add(element);
              }
            });
        addImagesToProductIdForCart[event.productId]![int.parse(event.itemId)]!
            .removeWhere((element) => element[0] == event.image);
      }
    }
    emit(
      state.copyWith(
        cartCollection: cartCollection,
        addImagesToProductIdForCart: addImagesToProductIdForCart,
        deleteItemInCartStatus: DeleteItemInCartStatus.loading,
      ),
    );
    final response = await removeItemToCartUseCase(
      RemoveITemToCartParams(id: event.itemId),
    );

    response.fold(
      (l) {
        Map<String, Map<int, List<List<String>>>>
        preAddImagesToProductIdForCart = Map.of(
          state.addImagesToProductIdForCart,
        );
        preAddImagesToProductIdForCart[event.productId]![int.parse(
              event.itemId,
            )]
            ?.addAll(preListImage);

        List<Cart>? cartCollection = List.of(state.cartCollection!);

        cartCollection.add(cart);

        emit(
          state.copyWith(
            addImagesToProductIdForCart: preAddImagesToProductIdForCart,
            cartCollection: cartCollection,
            deleteItemInCartStatus: DeleteItemInCartStatus.failure,
          ),
        );
        if (ErrorManager.shouldRetry('RemoveCartItemEvent', l.statusCode)) {
          ErrorManager.incrementRetry('RemoveCartItemEvent');

          add(
            RemoveItemFormCartEvent(
              image: event.image,
              currentSize: event.currentSize,
              fromCartPage: event.fromCartPage,
              colorName: event.colorName,
              itemId: event.itemId,
              boutiqueId: event.boutiqueId,
              productId: event.productId,
            ),
          );
          return;
        }
        if (l.statusCode != 401) {
          showMessage(
            "${LocaleKeys.your_request_faild.tr()}",
            foreGroundColor: Colors.white,
            hasError: true,
            backGroundColor: Colors.black,
          );
        }
      },
      (r) {
        add(GetCartOverviewEvent());
        Variation? variation;
        GetAuthProductDetailsModel getAuthProductDetailsModel =
            state.authProductDetailsModel ?? GetAuthProductDetailsModel();
        int availableQuantity =
            getAuthProductDetailsModel.data?.availableQuantity ?? 0;
        List<Variation> listVariation =
            getAuthProductDetailsModel.data?.variation ?? [];

        int index = listVariation.indexWhere(
          (element) =>
              element.type ==
              "${event.colorName}${(event.colorName != "" && event.currentSize != "") ? "-" : ""}${event.currentSize}",
        );
        if (index != -1 && (!event.fromCartPage)) {
          variation = listVariation[index];
          listVariation.removeAt(index);
          variation = variation.copyWith(qty: ((variation.qty)! + 1));
          listVariation.insert(index, variation);
          getAuthProductDetailsModel = getAuthProductDetailsModel.copyWith(
            data: getAuthProductDetailsModel.data?.copyWith(
              variation: listVariation,
              availableQuantity: availableQuantity + 1,
            ),
          );
        }

        Map<String, Map<String, String>> addVariationToCartId = Map.of(
          state.addVariationToCartId ?? {},
        );
        addVariationToCartId.removeWhere(
          (key, value) => key == event.itemId.toString(),
        );
        Map<String, Map<int, List<List<String>>>> addImagesToProductIdForCart =
            Map.from(state.addImagesToProductIdForCart);
        if (!addImagesToProductIdForCart[event.productId]![int.parse(
              event.itemId,
            )]
            .isNullOrEmpty) {
          addImagesToProductIdForCart[event.productId]![int.parse(
                event.itemId,
              )]!
              .removeWhere((element) => element[0] == event.image);
        }

        emit(
          state.copyWith(
            authProductDetailsModel: getAuthProductDetailsModel,
            addVariationToCartId: addVariationToCartId,
            addImagesToProductIdForCart: addImagesToProductIdForCart,
            deleteItemInCartStatus: DeleteItemInCartStatus.success,
          ),
        );

        add(
          AddQuantityForCartEvent(
            currentSize: event.currentSize,
            colorName: event.colorName,
            cartId: int.tryParse(event.itemId)!,
            quantity: 0,
            productId: event.productId,
          ),
        );
        add(
          AddSizesForColorsEvent(
            currentColorName: event.colorName,
            variation: listVariation,
          ),
        );
        ErrorManager.resetRetry('RemoveCartItemEvent');

        // Log remove from cart event
        try {
          FirebaseAnalyticsService.logEventForSession(
            eventName: AnalyticsEventsConst.REMOVE_FROM_CART,
            executedEventName:
                AnalyticsButtonsEventNameConst.REMOVE_PRODUCT_FROM_CART,
            extraParams: {
              'item_id': event.productId,
              'item_name': cart.name.toString(),
              'quantity': cart.quantity.toString(),
              'price': cart.price.toString(),
            },
          );
        } catch (e) {
          devLog('home_bloc.dart: ignored error', e);
        }

        showMessage(
          "${LocaleKeys.item_was_hidden_successfuly.tr()}",
          foreGroundColor: Colors.white,
          backGroundColor: Colors.black,
        );
      },
    );
  }

  FutureOr<void> _onHideItemInOldCartEvent(
    HideItemInOldCartEvent event,
    Emitter<HomeState> emit,
  ) async {
    List<oldCart.OldCart>? preOldCartCollection = state.oldcartCollection;
    List<oldCart.OldCart>? oldCartCollection = preOldCartCollection;
    oldCart.OldCart? cart;
    if (!(event.hideAll ?? false)) {
      cart = state.oldcartCollection!.firstWhere(
        (element) => element.id.toString() == event.oldCartId.toString(),
      );

      oldCartCollection!.remove(cart);
    }

    emit(
      state.copyWith(
        oldCartCollection: (event.hideAll ?? false) ? [] : oldCartCollection,
        hideItemInOldCartStatus: HideItemInOldCartStatus.loading,
      ),
    );
    final response = await hideItemsInOldCartUseCase(
      HideItemsInOldCartParams(
        hideAll: event.hideAll ?? false,
        oLdCartId: event.oldCartId,
      ),
    );

    response.fold(
      (l) {
        if (ErrorManager.shouldRetry('HideItemInOldCartEvent', l.statusCode)) {
          ErrorManager.incrementRetry('HideItemInOldCartEvent');
          add(
            HideItemInOldCartEvent(
              hideAll: event.hideAll,
              oldCartId: event.oldCartId,
            ),
          );
          return;
        }
        List<oldCart.OldCart>? oldCartCollection = List.of(
          state.oldcartCollection!,
        );
        if (!(event.hideAll ?? false)) {
          oldCartCollection.add(cart!);
        }

        emit(
          state.copyWith(
            oldCartCollection: (event.hideAll ?? false)
                ? preOldCartCollection
                : oldCartCollection,
            hideItemInOldCartStatus: HideItemInOldCartStatus.failure,
          ),
        );
        if (ErrorManager.shouldRetry('HideItemInOldCartEvent', l.statusCode)) {
          ErrorManager.incrementRetry('HideItemInOldCartEvent');
          add(
            HideItemInOldCartEvent(
              hideAll: event.hideAll,
              oldCartId: event.oldCartId,
            ),
          );
          return;
        }
        showMessage(
          "${LocaleKeys.your_request_faild.tr()}",
          foreGroundColor: Colors.white,
          backGroundColor: Colors.black,
          hasError: true,
        );
      },
      (r) {
        ErrorManager.resetRetry('HideItemInOldCartEvent');
        add(const GetOldCartItemEvent());
        emit(
          state.copyWith(
            hideItemInOldCartStatus: HideItemInOldCartStatus.success,
          ),
        );
        showMessage(
          "${LocaleKeys.item_was_hidden_successfuly.tr()}",
          foreGroundColor: Colors.white,
          backGroundColor: Colors.black,
        );
      },
    );
  }

  /*  FutureOr<void> _onConvertItemFromOldcartToCartEvent(
      ConvertItemFromOldcartToCartEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(
        convertItemFromOldcartToCartStatus:
            ConvertItemFromOldcartToCartStatus.init));
    Map<String, List<oldCart.OldCart>>? OldCartCollection =
        state.oldcartCollection;
    oldCart.OldCart? oldCartt;

    oldCartt = state.oldcartCollection![event.boutiqueId]!.firstWhere(
        (element) => element.id.toString() == event.oldCartId.toString());

    OldCartCollection![event.boutiqueId]!.remove(oldCartt);
    if (OldCartCollection[event.boutiqueId.toString()].isNullOrEmpty) {
      OldCartCollection.remove(event.boutiqueId.toString());
    }
    CartBrand brand = CartBrand(image: oldCartt.brand?.image);
    Cart cart = Cart(
      id: oldCartt.id,
      countOfPieces: oldCartt.countOfPieces,
      image: oldCartt.image,
      boutique: oldCartt.boutique,
      offerPrice: oldCartt.priceOfVariant,
      offerPriceFormatted: oldCartt.priceOfVariant.toString(),
      name: oldCartt.name,
      price: oldCartt.priceOfVariant,
      quantity: oldCartt.quantity,
      brand: brand,
      variations: oldCartt.variations,
      productId: oldCartt.productId,
    );
    Map<String, List<Cart>>? cartCollection =
        Map.of(state.cartCollection ?? {});
    /* if (cartCollection == {}) {
      emit(state
          .copyWith(cartCollection: {"${event.boutiqueId.toString()}": []}));
    }*/
    if (cartCollection.containsKey(event.boutiqueId.toString())) {
      cartCollection[event.boutiqueId.toString()]!.add(cart);
    } else {
      Map<String, List<Cart>> cartMap = {
        event.boutiqueId.toString(): [cart]
      };

      cartCollection.addAll(cartMap);
    }

    emit(state.copyWith(
        cartCollection: cartCollection,
        oldCartCollection: OldCartCollection,
        convertItemFromOldcartToCartStatus:
            ConvertItemFromOldcartToCartStatus.loading));
    final response = await convertItemFromOldcartToCartUsecase(
        ConvertItemFromOldcartToCartParams(oLdCartId: event.oldCartId));

    response.fold((l) {
      Map<String, List<Cart>>? cartCollection =
          Map.of(state.cartCollection ?? {});
      cartCollection[event.boutiqueId.toString()]!.remove(cart);
      if (cartCollection[event.boutiqueId.toString()].isNullOrEmpty) {
        cartCollection.remove(event.boutiqueId.toString());
      }
      Map<String, List<oldCart.OldCart>>? oldCartCollection =
          Map.of(state.oldcartCollection!);

      if (oldCartCollection[event.boutiqueId].isNullOrEmpty) {
        oldCartCollection[event.boutiqueId!] = [];
      }
      oldCartCollection[event.boutiqueId]!.add(oldCartt!);

      emit(state.copyWith(
          cartCollection: cartCollection,
          oldCartCollection: oldCartCollection,
          convertItemFromOldcartToCartStatus:
              ConvertItemFromOldcartToCartStatus.failure));
      showMessage(
        "Item Was't Converted to Cart",
        foreGroundColor: Colors.white,
        backGroundColor: Colors.black,
      );
    }, (r) {
      Map<String, List<Cart>>? cartCollection = state.cartCollection;
      Cart? cart;

      cart = state.cartCollection![event.boutiqueId]!.firstWhere(
          (element) => element.id.toString() == event.oldCartId.toString());

      cartCollection![event.boutiqueId]!.remove(cart);
      cartCollection[event.boutiqueId]!.add(cart.copyWith(
          id: r.data?.id, offerPrice: r.data?.offerPrice?.toDouble()));
      add(GetCartItemEvent());
      Map<String, Map<int, List<String>>> addImagesToProductIdForCart =
          Map.from(state.addImagesToProductIdForCart);
      if (addImagesToProductIdForCart[cart.productId.toString()] == null) {
        addImagesToProductIdForCart[cart.productId.toString()] = {};
      }
      if (!addImagesToProductIdForCart[cart.productId.toString()]![r.data?.id]
          .isNullOrEmpty) {
        for (int i = 0; i < oldCartt!.quantity!; i++) {
          addImagesToProductIdForCart[oldCartt.productId.toString()]![
                  r.data?.id]!
              .add(oldCartt.image!);
        }
        ;
      } else {
        addImagesToProductIdForCart[oldCartt!.productId.toString()]![
            r.data!.id!] = [];
        for (int i = 0; i < oldCartt.quantity!; i++) {
          addImagesToProductIdForCart[oldCartt.productId.toString()]![
                  r.data?.id]!
              .add(oldCartt.image!);
        }
        ;
      }
      devLog(
          "OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO${addImagesToProductIdForCart[oldCartt.productId.toString()]?.values.toList()}");
      add(AddQuantityForCartEvent(
          currentSize: oldCartt.variations![0].size ?? "",
          colorName: oldCartt.variations![0].color ?? "",
          cartId: r.data!.id!,
          quantity: oldCartt.quantity ?? 0,
          productId: oldCartt.productId.toString()));
      emit(state.copyWith(
        cartCollection: cartCollection,
        addImagesToProductIdForCart: addImagesToProductIdForCart,
        convertItemFromOldcartToCartStatus:
            ConvertItemFromOldcartToCartStatus.success,
      ));

      showMessage(
        "Item Converted to Cart successfuly",
        foreGroundColor: Colors.white,
        backGroundColor: Colors.black,
      );
    });
  }*/

  FutureOr<void> _onUpdateItemInCartEvent(
    UpdateItemInCartEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (event.totalQuantity == 0) {
      add(
        RemoveItemFormCartEvent(
          image: event.image,
          currentSize: event.currentSize,
          fromCartPage: event.fromCartPage,
          colorName: event.colorOption,
          itemId: event.cartId,
          boutiqueId: event.boutiqueId,
          productId: event.productId,
        ),
      );
      return;
    }
    if (event.totalQuantity > (event.maxAllowed ?? 0) &&
        event.maxAllowed != 0) {
      showMessage(
        "${LocaleKeys.you_reach_the_max_allowed_quantity.tr()} \n (${(event.maxAllowed ?? 0.0).round()} ${LocaleKeys.item.tr()}) ${LocaleKeys.of_this_product.tr()}",
        foreGroundColor: Colors.white,
        backGroundColor: Colors.black,
        showInRelease: true,
        hasError: true,
      );
      return;
    }

    Cart cart = state.cartCollection!.firstWhere(
      (element) => element.id.toString() == event.cartId,
    );
    Cart PreCart = cart;
    cart = cart.copyWith(quantity: event.totalQuantity);

    List<Cart>? cartCollection = state.cartCollection!.map((e) {
      if (e.id.toString() == event.cartId) {
        return cart;
      } else {
        return e;
      }
    }).toList();
    emit(
      state.copyWith(
        cartCollection: cartCollection,
        updateItemInCartStatus: UpdateItemInCartStatus.loading,
      ),
    );
    final response = await updateItemInCartUseCase(
      UpdateITemInCartParams(id: event.cartId, quantity: event.totalQuantity),
    );

    response.fold(
      (l) {
        List<Cart>? cartCollection = state.cartCollection!.map((e) {
          if (e.id.toString() == event.cartId) {
            return PreCart;
          } else {
            return e;
          }
        }).toList();
        emit(state.copyWith(cartCollection: cartCollection));
        if (ErrorManager.shouldRetry('UpdateCartItemEvent', l.statusCode)) {
          ErrorManager.incrementRetry('UpdateCartItemEvent');
          add(
            UpdateItemInCartEvent(
              image: event.image,
              currentSize: event.currentSize,
              boutiqueId: event.boutiqueId,
              productName: event.productName,
              productPrice: event.productPrice,
              cartId: event.cartId,
              totalQuantity: event.totalQuantity,
              maxAllowed: event.maxAllowed,
              productId: event.productId,
              colorOption: event.colorOption,
              newQuantity: event.newQuantity,
              fishAddAllTheItems: event.fishAddAllTheItems,
              fromCartPage: event.fromCartPage,
            ),
          );
          return;
        }
        if (l.statusCode != 401) {
          showMessage(
            l.message,
            foreGroundColor: Colors.white,
            hasError: true,
            backGroundColor: Colors.black,
          );
        }
        emit(
          state.copyWith(
            updateItemInCartStatus: UpdateItemInCartStatus.failure,
          ),
        );
      },
      (r) {
        ErrorManager.resetRetry('UpdateCartItemEvent');
        add(GetCartOverviewEvent());
        Variation? variation;
        List<Variation> listVariation =
            state.authProductDetailsModel?.data == null
            ? []
            : (state.authProductDetailsModel?.data!.variation) ?? [];
        int availableQuantity =
            state.authProductDetailsModel?.data?.availableQuantity ?? 0;
        GetAuthProductDetailsModel getAuthProductDetailsModel =
            state.authProductDetailsModel ?? GetAuthProductDetailsModel();
        int index = listVariation.indexWhere(
          (element) =>
              element.type ==
              "${event.colorOption}${event.colorOption != "" ? "-" : ""}${event.currentSize}",
        );

        if (kDebugMode)
          devLog(
            "SSSSSSSSSSSSSSSSAAAAAAAAAAAAAAAAAA${index} ${event.colorOption}${event.colorOption != "" ? "-" : ""}${event.currentSize}",
          );
        if ((r.data == null || r.data == "") || (r.data?.status ?? 0) != 1) {
          if (index != -1 &&
              event.totalQuantity == 1 &&
              (!event.fromCartPage)) {
            variation = listVariation[index];
            listVariation.removeAt(index);
            variation = variation.copyWith(qty: 0);
            listVariation.insert(index, variation);

            getAuthProductDetailsModel = getAuthProductDetailsModel.copyWith(
              data: getAuthProductDetailsModel.data?.copyWith(
                variation: listVariation,
              ),
            );
          }

          showDialog(
            context: navigatorKey.currentState!.context,
            builder: (context) => AlertDialog(
              title: MyTextWidget(
                "${r.message}",
                style: context.textTheme.labelMedium?.copyWith(
                  color: Colors.red,
                  height: 1.25,
                ),
              ),
              actions: <Widget>[
                SingleChildScrollView(
                  child: Column(
                    children: [
                      MyTextWidget(
                        "${LocaleKeys.do_you_want_to_notify_You_when_your_choose_available.tr()}",
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: Colors.black,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppElevatedButton(
                            child: Text(
                              "${LocaleKeys.not_now.tr()}",
                              style: const TextStyle(color: Colors.red),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          AppElevatedButton(
                            child: Text(
                              "${LocaleKeys.notify_me.tr()}",
                              style: const TextStyle(color: Colors.green),
                            ),
                            onPressed: () {
                              add(
                                RequestForNotificationWhenProductBecameAvailableEvent(
                                  event.productId,
                                  state.startingSetting?.notificationTypes
                                          ?.firstWhere(
                                            (type) =>
                                                type.name ==
                                                'product availability',
                                            orElse: () =>
                                                NotificationType(id: -1),
                                          )
                                          .id ??
                                      -1,
                                  event.currentSize,
                                  event.colorOption,
                                  true,
                                ),
                              );
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );

          List<Cart>? cartCollection = state.cartCollection!.map((e) {
            if (e.id.toString() == event.cartId) {
              return PreCart;
            } else {
              return e;
            }
          }).toList();
          if (!event.fromCartPage) {
            add(
              AddSizesForColorsEvent(
                currentColorName:
                    state
                            .cachedProductWithoutRelatedProductsModel[event
                                .productId
                                .toString()]!
                            .product
                            ?.colors
                            ?.isNullOrEmpty ??
                        true
                    ? ""
                    : state
                              .cachedProductWithoutRelatedProductsModel[event
                                  .productId
                                  .toString()]!
                              .product!
                              .colors?[state
                                      .currentSelectedColorForEveryProduct[state
                                      .cachedProductWithoutRelatedProductsModel[event
                                          .productId
                                          .toString()]!
                                      .product!
                                      .slug] ??
                                  0]
                              .option ??
                          "",
                variation: listVariation,
              ),
            );
          }
          emit(
            state.copyWith(
              authProductDetailsModel: getAuthProductDetailsModel,
              updateItemInCartStatus: UpdateItemInCartStatus.success,
              cartCollection: cartCollection,
            ),
          );
          return;
        }
        if (r.data!.status == 1) {
          if (index != -1 && (!event.fromCartPage)) {
            variation = listVariation[index];
            listVariation.removeAt(index);
            variation = variation.copyWith(
              qty: ((variation.qty)! - (event.newQuantity)),
            );
            listVariation.insert(index, variation);
            getAuthProductDetailsModel = getAuthProductDetailsModel.copyWith(
              data: getAuthProductDetailsModel.data!.copyWith(
                variation: listVariation,
                availableQuantity: ((availableQuantity) - (event.newQuantity))
                    .round(),
              ),
            );
          }

          Map<String, Map<int, List<List<String>>>>
          addImagesToProductIdForCart = Map.from(
            state.addImagesToProductIdForCart,
          );

          if (!addImagesToProductIdForCart[event.productId]![int.parse(
                event.cartId,
              )]
              .isNullOrEmpty) {
            List<String> elementRemove =
                addImagesToProductIdForCart[event.productId]![int.parse(
                      event.cartId,
                    )]!
                    .firstWhere(
                      (element) => element[0] == event.image,
                      orElse: () => [event.image, "null", "null"],
                    );

            addImagesToProductIdForCart[event.productId]![int.parse(
                  event.cartId,
                )]!
                .removeWhere((element) => element[0] == event.image);
            for (int i = 0; i < event.totalQuantity; i++) {
              addImagesToProductIdForCart[event.productId]![int.parse(
                    event.cartId,
                  )]!
                  .add([event.image, elementRemove[1], elementRemove[2]]);
            }
            ;
          } else {
            addImagesToProductIdForCart[event.productId]![int.parse(
                  event.cartId,
                )] =
                [];
            for (int i = 0; i < event.totalQuantity; i++) {
              addImagesToProductIdForCart[event.productId]![int.parse(
                    event.cartId,
                  )]!
                  .add([event.image, "null", "null"]);
            }
            ;
          }

          add(
            AddQuantityForCartEvent(
              currentSize: event.currentSize,
              colorName: event.colorOption,
              cartId: int.tryParse(event.cartId)!,
              quantity: event.totalQuantity,
              productId: event.productId,
            ),
          );

          if (event.fishAddAllTheItems) {
            showMessage(
              r.message!,
              foreGroundColor: Colors.white,
              backGroundColor: Colors.black,
              showInRelease: true,
              timeShowing: Toast.LENGTH_SHORT,
            );
            ErrorManager.resetRetry('AddCartItemEvent');
          }
          if (!event.fromCartPage) {
            add(
              AddSizesForColorsEvent(
                currentColorName:
                    state
                            .cachedProductWithoutRelatedProductsModel[event
                                .productId
                                .toString()]!
                            .product
                            ?.colors
                            ?.isNullOrEmpty ??
                        true
                    ? ""
                    : state
                              .cachedProductWithoutRelatedProductsModel[event
                                  .productId
                                  .toString()]!
                              .product!
                              .colors?[state
                                      .currentSelectedColorForEveryProduct[state
                                      .cachedProductWithoutRelatedProductsModel[event
                                          .productId
                                          .toString()]!
                                      .product!
                                      .slug] ??
                                  0]
                              .option ??
                          "",
                variation: listVariation,
              ),
            );
          }

          emit(
            state.copyWith(
              addImagesToProductIdForCart: addImagesToProductIdForCart,
              authProductDetailsModel: getAuthProductDetailsModel,
              updateItemInCartStatus: UpdateItemInCartStatus.success,
            ),
          );
        }

        ErrorManager.resetRetry('UpdateCartItemEvent');
        ////////////////////////
        if (event.totalQuantity == 0 || event.newQuantity == -1) {
          Future.delayed(const Duration(milliseconds: 300), () {
            FirebaseAnalyticsService.logEventForSession(
              executedEventName:
                  AnalyticsButtonsEventNameConst.REMOVE_PRODUCT_FROM_CART,
              eventName: AnalyticsEventsConst.REMOVE_FROM_CART,
              extraParams: {
                'items': [
                  {
                    'item_id': event.productId.toString(),
                    'item_name': event.productName.toString(),
                    'price': event.productPrice.toString(),
                    'quantity': event.totalQuantity.toString(),
                    'item_variant': '${event.colorOption}-${event.currentSize}',
                  },
                ].toString(),
              },
            );
          });
        }
      },
    );
  }

  Future<void> _onGetCurrencyForCountryEvent(
    GetCurrencyForCountryEvent event,
    Emitter<HomeState> emit,
  ) async {
    final response = await getCurrencyForCountryUseCase(NoParams());
    response.fold(
      (l) {
        if (ErrorManager.shouldRetry(
          'GetCurrencyForCountryEvent',
          l.statusCode,
        )) {
          ErrorManager.incrementRetry('GetCurrencyForCountryEvent');
          add(GetCurrencyForCountryEvent());
          return;
        }
      },
      (r) {
        ErrorManager.resetRetry('GetCurrencyForCountryEvent');
        emit(state.copyWith(getCurrencyForCountryModel: r));
      },
    );
  }

  FutureOr<void> _onAddCurrentQuantityForCartEvent(
    AddQuantityForCartEvent event,
    Emitter<HomeState> emit,
  ) async {
    Map<String, List<int>> currentQuantity = state.currentQuantityForCart ?? {};
    String key =
        "${event.productId}" + "${event.colorName}" + "${event.currentSize}";
    if (!currentQuantity[key].isNullOrEmpty) {
      currentQuantity[key] = [event.quantity, event.cartId];
    } else {
      currentQuantity.addAll({
        key: [event.quantity, event.cartId],
      });
    }
    currentQuantity.removeWhere((key, value) => value[0] == 0);
    emit(state.copyWith(currentQuantityForCart: currentQuantity));
  }

  FutureOr<void> _onGetNotificationTypeProductEvent(
    GetNotificationTypeProductEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        getNotificationTypeProductStatus:
            GetNotificationTypeProductStatus.loading,
      ),
    );
    final response = await getNotificationTypeProductUseCase(NoParams());
    response.fold(
      (l) {
        if (ErrorManager.shouldRetry(
          'GetNotificationTypeProductEvent',
          l.statusCode,
        )) {
          ErrorManager.incrementRetry('GetNotificationTypeProductEvent');
          add(const GetNotificationTypeProductEvent());
          return;
        }
        emit(
          state.copyWith(
            getNotificationTypeProductStatus:
                GetNotificationTypeProductStatus.failure,
          ),
        );
      },
      (r) {
        ErrorManager.resetRetry('GetNotificationTypeProductEvent');
        emit(
          state.copyWith(
            notificationTypeForProductModel: r,
            getNotificationTypeProductStatus:
                GetNotificationTypeProductStatus.success,
          ),
        );
      },
    );
  }

  FutureOr<void> _onConvertItemFromCartToOldCartEvent(
    ConvertItemFromCartToOldCartEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        convertItemFromcartToOldCartStatus:
            ConvertItemFromcartToOldCartStatus.loading,
      ),
    );
    final response = await convertItemFromcartToOldCartUsecase(
      ConvertItemFromcartToOldCartParams(CartId: event.cartId),
    );
    response.fold(
      (l) {
        if (ErrorManager.shouldRetry(
          'ConvertItemFromCartToOldCartEvent',
          l.statusCode,
        )) {
          add(ConvertItemFromCartToOldCartEvent(cartId: event.cartId));
          ErrorManager.incrementRetry('ConvertItemFromCartToOldCartEvent');
          return;
        }
        showMessage(
          l.message,
          foreGroundColor: Colors.white,
          backGroundColor: Colors.black,
          showInRelease: true,
          hasError: true,
        );
        emit(
          state.copyWith(
            convertItemFromcartToOldCartStatus:
                ConvertItemFromcartToOldCartStatus.failure,
          ),
        );
      },
      (r) {
        ErrorManager.resetRetry('ConvertItemFromCartToOldCartEvent');
        add(const GetCartItemEvent());
        List<oldCart.OldCart>? oldcartCollection = List.of(
          state.oldcartCollection ?? [],
        );
        List<Cart>? cartCollection = List.of(state.cartCollection ?? []);
        Cart cart = cartCollection.firstWhere(
          (element) => element.id.toString() == event.cartId,
          orElse: () => Cart(id: -1),
        );
        if (cart.id != -1) {
          cartCollection.removeWhere(
            (element) => element.id.toString() == event.cartId,
          );

          oldcartCollection.add(
            oldCart.OldCart(
              boutique: cart.boutique,
              brand: oldCart.Brand(
                icon: oldCart.Icon(
                  filePath: cart.brand?.icon?.filePath,
                  originalHeight: cart.brand?.icon?.originalHeight,
                  originalWidth: cart.brand?.icon?.originalWidth,
                ),
                name: cart.name,
              ),
              image: cart.image,

              countOfPieces: cart.countOfPieces,
              offerPrice: cart.offerPrice,
              productId: cart.productId,
              variations: cart.variations,
              shippingDays: cart.shippingDays,
              quantity: cart.quantity,
              thumbnail: cart.thumbnail,
              id: cart.id,
            ),
          );
        }
        ErrorManager.resetRetry('ConvertItemFromCartToOldCartEvent');

        emit(
          state.copyWith(
            convertItemFromcartToOldCartStatus:
                ConvertItemFromcartToOldCartStatus.success,
            oldCartCollection: oldcartCollection,
            cartCollection: cartCollection,
          ),
        );
        showMessage(
          r.message ?? "",
          foreGroundColor: Colors.white,
          backGroundColor: Colors.black,
          showInRelease: true,
        );
      },
    );
  }

  FutureOr<void> _onGetPopularSearchItemEvent(
    GetPopularSearchItemEvent event,
    Emitter<HomeState> emit,
  ) async {
    final response = await getPopularSearchItemUseCase(NoParams());
    response.fold(
      (l) {
        if (ErrorManager.shouldRetry(
          'getPopularSearchItemEvent',
          l.statusCode,
        )) {
          add(const GetPopularSearchItemEvent());
          ErrorManager.incrementRetry('getPopularSearchItemEvent');
        }
      },
      (r) {
        ErrorManager.resetRetry('getPopularSearchItemEvent');
        List<PopularSearchTerm> popularSearchTerm = [];
        popularSearchTerm = r.popularSearchTerms ?? [];
        emit(state.copyWith(popularSearchTerm: popularSearchTerm));
      },
    );
  }
  /* FutureOr<void> _onGetSearchResultEventEvent(
      GetSearchREsultEvent event, Emitter<HomeState> emit) async {
>>>>>>> 7753aa7f79edf679b9a3b6994c672dc77f57e59e
    emit(state.copyWith(getSearchResultStatus: GetSearchResultStatus.loading));
    final response = await getProductsWithFiltersUseCase(
        GetProductsWithFiltersParams(
            brandSlugs:
            state.selectedBoutiqueBrandCategorySlugsForSearch["brand"],
            categorySlugs:
            state.selectedBoutiqueBrandCategorySlugsForSearch["category"],
            searchText: event.searchTitle,
            boutiqueSlugs:
            state.selectedBoutiqueBrandCategorySlugsForSearch["boutique"]));

    response.fold((l) {
      if (!isFailedTheFirstTime.contains('GetSearchResultEvent')) {
     add(GetSearchREsultEvent(searchTitle: event.searchTitle));
        isFailedTheFirstTime.add('GetSearchResultEvent');
      }
      emit(
          state.copyWith(getSearchResultStatus: GetSearchResultStatus.failure));
    }, (r) {
      isFailedTheFirstTime.remove('GetSearchResultEvent');

      emit(state.copyWith(
          searchResultModel: r,
          getSearchResultStatus: GetSearchResultStatus.success));
    });
  }*/

  FutureOr<void> _onAddSearchTextToHistoryEvent(
    AddSearchTextToHistoryEvent event,
    Emitter<HomeState> emit,
  ) async {
    List<String> searchHistory = state.searchHistory ?? [];
    if (searchHistory.contains(event.searchTitle)) {
      return;
    }
    searchHistory.add(event.searchTitle);
    emit(state.copyWith(searchHistory: searchHistory));
  }

  FutureOr<void> _onRemoveSearchTextToHistoryEvent(
    RemoveSearchTextfromHistoryEvent event,
    Emitter<HomeState> emit,
  ) async {
    List<String> searchHistory = state.searchHistory ?? [];
    if (event.clearAll) {
      List<String> searchHistory = [];
      emit(state.copyWith(searchHistory: searchHistory));
      return;
    }
    searchHistory.remove(event.searchTitle);
    emit(state.copyWith(searchHistory: searchHistory));
  }

  /* Future<void> _onGetBrandEvent(
      GetBrandEvent event, Emitter<HomeState> emit) async {
    final response = await getBrandUseCase(NoParams());

    response.fold((l) {
      add(GetBrandEvent());
    }, (r) {
      emit(state.copyWith(
        brands: r.data!.brands,
      ));
    });
  }*/

  /*Future<void> _onGetCategoryEvent(
      GetCategoryEvent event, Emitter<HomeState> emit) async {
    final response = await getCategoryUseCase(NoParams());

    response.fold((l) {
      add(GetCategoryEvent());
    }, (r) {
      emit(state.copyWith(
        category: r.data!.categories,
      ));
    });
  }*/

  FutureOr<void> _onAddMultiItemsToCartEvent(
    AddMultiItemsToCartEvent event,
    Emitter<HomeState> emit,
  ) {
    List<ImageForAddToCart>? listitemForAddToCart = List.of(
      state.listitemForAddToCart ?? [],
    );
    listitemForAddToCart.removeWhere((element) => element.quantity == 0);
    for (var i = 0; i < listitemForAddToCart.length; i++) {
      add(
        AddItemToCartEvent(
          fromCartPage: event.fromCartPage,
          isRedeem: event.isRedeem,
          variationId: listitemForAddToCart[i].variationId,
          redeemVariantPrice: event.redeemVariantPrice,
          finishAddAllTheItems: i == listitemForAddToCart.length - 1,
          countOfPieces: listitemForAddToCart[i].countOfPieces,
          image: listitemForAddToCart[i].images!,
          productSlugForTopic: event.productSlugForTopic,
          color: listitemForAddToCart[i].colorNum,
          colorOption: listitemForAddToCart[i].colorOption!,
          products: event.products,
          maxAllowed: event.maxAllowed,
          boutiqueIcon: event.boutiqueIcon,
          boutiqueId: event.boutiqueId,
          choiceOption: listitemForAddToCart[i].choiceOption,
          colorName: listitemForAddToCart[i].colorName!,
          sizeName: listitemForAddToCart[i].choiceName!,
          quantity: listitemForAddToCart[i].quantity,
        ),
      );
      /////////////////////////////////
      Future.delayed(const Duration(milliseconds: 300), () {
        try {
          FirebaseAnalyticsService.logEventForSession(
            eventName: AnalyticsEventsConst.ADD_TO_CART,
            executedEventName:
                AnalyticsButtonsEventNameConst.ADD_TO_CART_BUTTON,
            extraParams: {
              'currency': state
                  .getCurrencyForCountryModel!
                  .data!
                  .currency!
                  .symbol
                  .toString(),
              'value': state.getCartShippingItemsModel!.data!.total.toString(),
              'items': [
                {
                  'item_id': event.id.toString(),
                  'item_name': event.products.name.toString(),
                  'price': event.products.price.toString(),
                  'quantity': listitemForAddToCart[i].quantity.toString(),
                  'brand': event.products.brand?.name.toString(),
                  'category': event.products.category?.name.toString(),
                  'count_likes': event.products.countOfLikes.toString(),
                  'review_count': event.products.reviewsCount.toString(),
                  'item_variant':
                      '${listitemForAddToCart[i].colorOption}-${listitemForAddToCart[i].choiceOption}',
                },
              ].toString(),
            },
          );
        } catch (e) {
          devLog('home_bloc.dart: ignored error', e);
        }
      });
    }

    emit(state.copyWith(listitemForAddToCart: []));
  }

  FutureOr<void> _onGetAllowedCountriesEvent(
    GetAllowedCountriesEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        getAllowedCountriesStatus: GetAllowedCountriesStatus.loading,
      ),
    );
    final response = await getAllowedCountryUseCase(NoParams());
    response.fold(
      (l) {
        emit(
          state.copyWith(
            getAllowedCountriesStatus: GetAllowedCountriesStatus.failure,
          ),
        );
        if (ErrorManager.shouldRetry('GetAllowCountryEvent', l.statusCode)) {
          add(GetAllowedCountriesEvent());
          ErrorManager.incrementRetry('GetAllowCountryEvent');
        }
      },
      (r) {
        ErrorManager.resetRetry('GetAllowCountryEvent');

        emit(
          state.copyWith(
            getAllowedCountriesModel: r,
            getAllowedCountriesStatus: GetAllowedCountriesStatus.success,
          ),
        );
      },
    );
  }

  FutureOr<void> _onUpdateListOfItemForAddToCartEvent(
    UpdateListOfItemForAddToCartEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (event.resetTheList) {
      emit(state.copyWith(listitemForAddToCart: []));
      return;
    }

    ImageForAddToCart imageForAddToCart = ImageForAddToCart(
      variationId: event.imageForAddToCart.variationId,
      colorNum: event.imageForAddToCart.colorNum,
      colorOption: event.imageForAddToCart.colorOption,
      quantity: event.imageForAddToCart.quantity,
      countOfPieces: event.imageForAddToCart.countOfPieces,
      images: event.imageForAddToCart.images,
      colorName: event.imageForAddToCart.colorName,
      choiceName: state.currentColorSizeForCart != null
          ? state.currentColorSizeForCart!["size"]
          : "",
      choiceOption: state.currentColorSizeForCart != null
          ? state.currentColorSizeForCart!["choiceOption"]
          : "",
    );

    List<ImageForAddToCart>? listitemForAddToCart =
        state.listitemForAddToCart ?? [];
    ImageForAddToCart? newImageToAddToCart = imageForAddToCart;
    if (event.operation == "+") {
      if (listitemForAddToCart.isNullOrEmpty) {
        listitemForAddToCart.addAll([imageForAddToCart]);
        emit(state.copyWith(listitemForAddToCart: listitemForAddToCart));
        return;
      }
      for (var i = 0; i < listitemForAddToCart.length; i++) {
        ImageForAddToCart element = listitemForAddToCart[i];

        if (element.images == imageForAddToCart.images &&
            element.variationId == imageForAddToCart.variationId) {
          element.quantity = element.quantity! + 1;
          newImageToAddToCart = ImageForAddToCart(
            countOfPieces: element.countOfPieces,
            variationId: element.variationId,
            isDuplicate: true,
            quantity: 0,
            choiceOption: element.choiceOption,
            colorOption: element.colorOption,
            colorName: element.colorName,
            choiceName: element.choiceName,
            images: element.images,
          );
          break;
        } else {
          if (!listitemForAddToCart.any(
            (element) =>
                (element.images == imageForAddToCart.images &&
                element.variationId == imageForAddToCart.variationId),
          )) {
            newImageToAddToCart = imageForAddToCart;
          }
        }
      }
      emit(
        state.copyWith(
          listitemForAddToCart: [...listitemForAddToCart, newImageToAddToCart!],
        ),
      );
    } else {
      if (listitemForAddToCart.last.isDuplicate == true) {
        ImageForAddToCart itemLast = listitemForAddToCart.last;

        if (itemLast.isDuplicate == true) {
          listitemForAddToCart = listitemForAddToCart.map((e) {
            if (e.quantity! > 0 &&
                e.variationId == itemLast.variationId &&
                e.images == itemLast.images) {
              return ImageForAddToCart(
                countOfPieces: e.countOfPieces,
                colorOption: itemLast.colorOption,
                colorName: itemLast.colorName,
                variationId: itemLast.variationId,
                choiceName: itemLast.choiceName,
                images: e.images,
                quantity: e.quantity! - 1,
                choiceOption: itemLast.choiceOption,
              );
            }
            return e;
          }).toList();
          listitemForAddToCart.removeLast();
        }
      } else {
        listitemForAddToCart.removeLast();
      }
      emit(state.copyWith(listitemForAddToCart: listitemForAddToCart));
    }
  }

  FutureOr<void> _onAddOrRemoveLikeForProductEvent(
    AddOrRemoveLikeForProductEvent event,
    Emitter<HomeState> emit,
  ) async {
    Map<String, GetProductDetailWithoutRelatedProductsModel>
    cachedProductWithoutRelatedProductsModel = Map.of(
      state.cachedProductWithoutRelatedProductsModel,
    );

    if (!cachedProductWithoutRelatedProductsModel.containsKey(
      event.productId,
    )) {
      cachedProductWithoutRelatedProductsModel.addAll({
        event.productId: GetProductDetailWithoutRelatedProductsModel(),
      });
    }

    Product? product =
        cachedProductWithoutRelatedProductsModel[event.productId]?.product;
    int countOfLikes = product?.countOfLikes ?? 0;
    if (event.isFavourite) {
      countOfLikes = countOfLikes + 1;
    } else {
      if (countOfLikes > 0) {
        countOfLikes = countOfLikes - 1;
      }
    }

    product = product?.copyWith(
      countOfLikes: countOfLikes,
      isLiked: event.isFavourite ? true : false,
    );
    cachedProductWithoutRelatedProductsModel[event.productId] =
        cachedProductWithoutRelatedProductsModel[event.productId]!.copyWith(
          data: product,
        );
    emit(
      state.copyWith(
        cachedProductWithoutRelatedProductsModel:
            cachedProductWithoutRelatedProductsModel,
        addOrRemoveLikeOfProductStatus: AddOrRemoveLikeOfProductStatus.loading,
      ),
    );

    final response = event.isFavourite
        ? await addLikeToProductUsecase(
            AddLikeToProductParams(
              productId: event.productId,
              userId: GetIt.I<PrefsRepository>().myMarketId,
            ),
          )
        : await deleteLikeOfProductUsecase(
            DeleteLikeOfParams(
              productId: event.productId,
              userId: GetIt.I<PrefsRepository>().myMarketId,
            ),
          );

    response.fold(
      (l) {
        if (ErrorManager.shouldRetry(
          'AddOrRemoveLikeForProductEvent',
          l.statusCode,
        )) {
          ErrorManager.incrementRetry('AddOrRemoveLikeForProductEvent');
          add(
            AddOrRemoveLikeForProductEvent(
              productId: event.productId,
              isFavourite: event.isFavourite,
              productSlugForTopic: event.productSlugForTopic,
              productSlug: event.productSlug,
            ),
          );
          return;
        }
        Map<String, GetProductDetailWithoutRelatedProductsModel>
        cachedProductWithoutRelatedProductsModel = Map.of(
          state.cachedProductWithoutRelatedProductsModel,
        );
        Product? product =
            cachedProductWithoutRelatedProductsModel[event.productId]?.product;
        int countOfLikes = product?.countOfLikes ?? 0;
        if (event.isFavourite) {
          countOfLikes = countOfLikes - 1;
        } else {
          countOfLikes = countOfLikes + 1;
        }

        product = product?.copyWith(
          countOfLikes: countOfLikes,
          isLiked: event.isFavourite ? false : true,
        );
        cachedProductWithoutRelatedProductsModel[event.productId] =
            cachedProductWithoutRelatedProductsModel[event.productId]!.copyWith(
              data: product,
            );

        emit(
          state.copyWith(
            cachedProductWithoutRelatedProductsModel:
                cachedProductWithoutRelatedProductsModel,
            statusCodeOfCommentProcess: l.statusCode.toString(),
            addOrRemoveLikeOfProductStatus:
                AddOrRemoveLikeOfProductStatus.failure,
          ),
        );
      },
      (r) {
        add(UpdateLikeSocialSharedProductsEvent(productId: event.productId));
        ErrorManager.resetRetry('AddOrRemoveLikeForProductEvent');
        emit(
          state.copyWith(
            addOrRemoveLikeOfProductStatus:
                AddOrRemoveLikeOfProductStatus.success,
          ),
        );
      },
    );
  }

  FutureOr<void> _onChangeCurrentIndexForUpdatCartEvent(
    ChangeCurrentIndexForUpdatCartEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(currentIndexForUpdateCart: event.index));
  }

  FutureOr<void> _onAddTimerStartedToHurryUpEvent(
    AddTimerStartedToHurryUpEvent event,
    Emitter<HomeState> emit,
  ) async {
    Map<String, int> cartIdsHurryUPTimerStarted = Map.of(
      state.cartIdsHurryUPTimerStarted,
    );
    if (event.isAddToList) {
      cartIdsHurryUPTimerStarted.addAll({event.cartId: event.timeLeft});
    } else {
      cartIdsHurryUPTimerStarted.removeWhere(
        (key, value) => key == event.cartId,
      );
    }
    emit(
      state.copyWith(cartIdsHurryUPTimerStarted: cartIdsHurryUPTimerStarted),
    );
  }

  FutureOr<void> _onRequestForNotificationWhenProductBecameAvailableEvent(
    RequestForNotificationWhenProductBecameAvailableEvent event,
    Emitter<HomeState> emit,
  ) async {
    String variant = "";
    if (event.size != "") {
      variant = event.selectedColorName == ''
          ? event.size
          : "${event.selectedColorName}-${event.size}";
    } else {
      variant = event.selectedColorName == '' ? "" : event.selectedColorName;
    }

    if (event.subsecribe) {
      add(
        SubscribeTopicForNotificationEvent(
          topic: "product_availability_${event.productId}",
          variant: variant.replaceAll("_", "-"),
        ),
      );
    } else {
      add(
        UnSubscribeTopicForNotificationEvent(
          topic: "product_availability_${event.productId}",
          variant: variant.replaceAll("_", "-"),
        ),
      );
    }
    /*  if (isVariantRequestNotification
        .contains("${event.productId}_${variant}")) {
      return;
    }

    isVariantRequestNotification.add("${event.productId}_${variant}");

    emit(state.copyWith(
        isVariantRequestNotification: isVariantRequestNotification));*/

    /*  final response =
        await requestForNotificationWhenProductBecameAvailableUseCase(
            RequestForNotificationWhenProductBecameAvailableParams(
                event.productId,
                event.notificationTypeId,
                variant,
                prefsRepository.myMarketId!));
    response.fold((l) {
      showMessage(l.message,
          foreGroundColor: Colors.white,
          backGroundColor: Colors.black,
          showInRelease: true,
          timeShowing: Toast.LENGTH_SHORT);

      isVariantRequestNotification =
          List.of(state.isVariantRequestNotification);
      isVariantRequestNotification.remove("${event.productId}_${variant}");
      emit(state.copyWith(
          isVariantRequestNotification: isVariantRequestNotification));
    }, (r) {
      showMessage("${LocaleKeys.your_request_add_successfuly.tr()}",
          foreGroundColor: Colors.white,
          backGroundColor: Colors.black,
          showInRelease: true,
          timeShowing: Toast.LENGTH_SHORT);
    });*/
  }

  FutureOr<void> _onGetAndAddCountViewOfProductEvent(
    GetAndAddCountViewOfProductEvent event,
    Emitter<HomeState> emit,
  ) async {
    Map<String, GetAndAddCountViewOfProductStatus>
    getAndAddCountViewOfProductStatus = Map.of(
      state.getAndAddCountViewOfProductStatus,
    );
    if (getAndAddCountViewOfProductStatus.containsKey(event.productId)) {
      getAndAddCountViewOfProductStatus[event.productId] =
          GetAndAddCountViewOfProductStatus.loading;
    } else {
      getAndAddCountViewOfProductStatus.addAll({
        event.productId: GetAndAddCountViewOfProductStatus.loading,
      });
    }
    emit(
      state.copyWith(
        getAndAddCountViewOfProductStatus: getAndAddCountViewOfProductStatus,
      ),
    );
    final response = await getAndAddCountViewOfProductUsecase(
      getAndAddCountViewOfProductParams(
        productId: event.productId,
        userId: GetIt.I<PrefsRepository>().myMarketId,
      ),
    );
    response.fold(
      (l) {
        Map<String, GetAndAddCountViewOfProductStatus>
        getAndAddCountViewOfProductStatus = Map.of(
          state.getAndAddCountViewOfProductStatus,
        );

        getAndAddCountViewOfProductStatus[event.productId] =
            GetAndAddCountViewOfProductStatus.failure;

        emit(
          state.copyWith(
            getAndAddCountViewOfProductStatus:
                getAndAddCountViewOfProductStatus,
          ),
        );
        emit(
          state.copyWith(
            getAndAddCountViewOfProductStatus:
                getAndAddCountViewOfProductStatus,
          ),
        );
      },
      (r) {
        /*    Map<String, GetAndAddCountViewOfProductStatus>
        getAndAddCountViewOfProductStatus = Map.of(
          state.getAndAddCountViewOfProductStatus,
        );

        getAndAddCountViewOfProductStatus[event.productId] =
            GetAndAddCountViewOfProductStatus.success;

        Map<String, GetProductDetailWithoutRelatedProductsModel>
        cachedProductWithoutRelatedProductsModel = Map.of(
          state.cachedProductWithoutRelatedProductsModel,
        );
        try {
          Product? product =
              cachedProductWithoutRelatedProductsModel[event.productId]
                  ?.product;
          int countViews = r.viewCount ?? 0;

          product = product?.copyWith(viewsCount: countViews);
          cachedProductWithoutRelatedProductsModel[event.productId] =
              cachedProductWithoutRelatedProductsModel[event.productId]!
                  .copyWith(data: product);
        } catch (e) {
          devLog('home_bloc.dart: ignored error', e);
        }

        emit(
          state.copyWith(
            cachedProductWithoutRelatedProductsModel:
                cachedProductWithoutRelatedProductsModel,
            getAndAddCountViewOfProductStatus:
                getAndAddCountViewOfProductStatus,
          ),
        );*/
      },
    );
  }

  FutureOr<void> _onGetFullProductDetailsEvent(
    GetFullProductDetailsEvent event,
    Emitter<HomeState> emit,
  ) async {
    add(FetchAuthProductDetailsEvent(event.productSlug));
    emit(
      state.copyWith(
        productContentForStatusOfOpeningProductDetailsDirectly: Products(
          isProductNotifiedForUser: false,
        ),
        getFullProductDetailsStatus: GetFullProductDetailsStatus.loading,
        currentSlugToRefreshFromNotification: event.productSlug,
      ),
    );
    final response = await getFullProductDetailsUseCase(
      event.productSlug.toString(),
    );
    response.fold(
      (l) {
        if (ErrorManager.shouldRetry(
          'GetFullProductDetailsEvent',
          l.statusCode,
        )) {
          ErrorManager.incrementRetry('GetFullProductDetailsEvent');
          add(
            GetFullProductDetailsEvent(
              productSlug: event.productSlug,
              currentColorName: event.currentColorName,
            ),
          );
          return;
        }
        emit(
          state.copyWith(
            getFullProductDetailsStatus: GetFullProductDetailsStatus.failure,
          ),
        );
      },
      (r) {
        if (r.productItem?.productId == null) {
          emit(
            state.copyWith(
              getFullProductDetailsStatus: GetFullProductDetailsStatus.failure,
            ),
          );
          return;
        }
        add(
          GetRelatedProductsEvent(
                productSlug: r.productItem!.productId,
                color: "",
              )
              as HomeEvent,
        );

        add(DeliveredOrdersResponseEvent(r.productItem!.productId!));

        GetIt.I<ChatBloc>().add(const ChangeStatusShareProructToInitialEvent());
        ErrorManager.resetRetry('GetFullProductDetailsEvent');
        if (r.productItem?.productId == null) {
          emit(
            state.copyWith(
              productContentForStatusOfOpeningProductDetailsDirectly: Products(
                isProductNotifiedForUser: false,
              ),
              getFullProductDetailsStatus: GetFullProductDetailsStatus.success,
            ),
          );

          return;
        }
        List<SyncColorImageProduct> syncColorImage =
            r.productItem?.syncColorImages ?? [];
        List<SyncColorImageProduct> syncColorImageReally = [];
        List<ProductColor> productColor = r.productItem?.colors ?? [];
        List<String> colorFound = [];
        productColor.forEach((element) => colorFound.add(element.option ?? ""));
        for (var i = 0; i < syncColorImage.length; i++) {
          if ((colorFound.contains(syncColorImage[i].colorOption))) {
            syncColorImageReally.add(syncColorImage[i]);
          }
        }
        final syncColorImageOrder = {
          for (var i = 0; i < syncColorImageReally.length; i++)
            syncColorImageReally[i].colorOption: i,
        };

        // ترتيب syncColorImages حسب ترتيب colors
        productColor.sort(
          (a, b) => (syncColorImageOrder[a.option] ?? 999).compareTo(
            (syncColorImageOrder[b.option] ?? 999),
          ),
        );
        if (event.currentColorName != null) {
          int index = -1;
          index = productColor.indexWhere(
            (element) => element.option == event.currentColorName,
          );
          if (index != -1) {
            add(
              AddCurrentSelectedColorEvent(
                currentSelectedColor: index,
                productSlug: event.productSlug,
              ),
            );
          }
        }

        /*  add(
          GetAndAddCountViewOfProductEvent(
            productId: r.productItem!.productId.toString(),
          ),
        );*/
        // add(GetCommentForProductEvent(
        //    productId: r.productItem!.productId.toString()));
        add(
          GetStoryForProductEvent(
            productId: r.productItem!.productId.toString(),
          ),
        );
        /*  GetIt.I<ChatBloc>().add(GetSharedProductCountEvent(
            productId: r.productItem!.productId.toString()));*/

        Map<String, GetProductDetailWithoutRelatedProductsModel> cachedData =
            Map.of(state.cachedProductWithoutRelatedProductsModel);
        Map<String, GetProductDetailWithoutSimilarRelatedProductsStatus>
        productStatus = Map.from(state.productStatus ?? {});
        productStatus[r.productItem!.productId.toString()] =
            GetProductDetailWithoutSimilarRelatedProductsStatus.success;

        GetProductDetailWithoutRelatedProductsModel?
        getProductDetailWithoutRelatedProductsModel = r
            .getProductDetailWithoutRelatedProductsModel
            ?.copyWith(
              data: r.getProductDetailWithoutRelatedProductsModel?.product
                  ?.copyWith(
                    slug: event.productSlug,
                    syncColorImages: syncColorImageReally,
                    colors: productColor,
                  ),
            );
        cachedData.removeWhere(
          (key, value) => key == r.productItem!.productId.toString(),
        );
        cachedData.addAll({
          r.productItem!.productId.toString():
              getProductDetailWithoutRelatedProductsModel!,
        });
        if (r.productItem!.isRedeem == true) {
          GetIt.I<PrefsRepository>().setRedeemDateForProduct(
            r.productItem!.productId.toString(),
            "52",
          );
        }
        /*PaginationModel<Comment>? getCommentsFromAnalyticsPaginationModel =
          PaginationModel<Comment>(
              paginationStatus: PaginationStatus.success,
              items: r.productItem?.comments ?? [],
              page: 0,
              hasReachedMax: (r.productItem?.comments?.length ?? 0) < 10,
              offset: r.productItem?.commentOffset?.toString());*/

        PaginationModel<FqaComment>? getFqaCommentsPaginationModel =
            PaginationModel<FqaComment>(
              paginationStatus: PaginationStatus.success,
              items: r.productItem?.fqaQuestions?.comments ?? [],
              page: 0,
              hasReachedMax:
                  (r.productItem?.fqaQuestions?.comments?.length ?? 0) < 10 ||
                  r.productItem?.fqaQuestions?.offset == null ||
                  r.productItem?.fqaQuestions?.offset == "null",
              total: r.productItem?.fqaQuestions?.total,
              offset: r.productItem?.fqaQuestions?.offset?.toString(),
            );
        PaginationModel<BuyersComment>? getBuyersCommentsPaginationModel =
            PaginationModel<BuyersComment>(
              paginationStatus: PaginationStatus.success,
              items: r.productItem?.buyersComment?.comments ?? [],
              total: r.productItem?.buyersComment?.total,
              page: 0,
              hasReachedMax:
                  (r.productItem?.buyersComment?.comments?.length ?? 0) < 10 ||
                  r.productItem?.buyersComment?.offset == null ||
                  r.productItem?.buyersComment?.offset == "null",
              offset: r.productItem?.buyersComment?.offset?.toString(),
            );
        emit(
          state.copyWith(
            productStatus: productStatus,
            getBuyersCommentsPaginationModel: {
              "all": getBuyersCommentsPaginationModel,
            },
            getFqaCommentsPaginationModel: {
              "all": getFqaCommentsPaginationModel,
            },
            cachedProductWithoutRelatedProductsModel: cachedData,
            // getCommentsFromAnalyticsPaginationModel:
            //     getCommentsFromAnalyticsPaginationModel,
            productContentForStatusOfOpeningProductDetailsDirectly: r
                .productItem
                ?.copyWith(
                  colors: productColor,
                  syncColorImages: syncColorImageReally,
                  slug: event.productSlug,
                ),
          ),
        );

        add(const ChangeStatusOFGetProductsDetailsToSuccessEvent());
      },
    );
  }

  /*FutureOr<void> _onAddCommentEvent(
      AddCommentEvent event, Emitter<HomeState> emit) async {
    if (event.comment.length == 0) {
      return;
    }
    emit(state.copyWith(addCommentStatus: AddCommentStatus.loading));
    final response = await addCommentUseCase(
        AddCommentParams(productId: event.productId, comment: event.comment));

    response.fold((l) {
      if (ErrorManager.shouldRetry('AddCommentEvent', l.statusCode)) {
        ErrorManager.incrementRetry('AddCommentEvent');
        add(AddCommentEvent(
            productId: event.productId,
            comment: event.comment,
            productSlugForTopic: event.productSlugForTopic,
            productSlug: event.productSlug));
        return;
      }
      emit(state.copyWith(addCommentStatus: AddCommentStatus.failure));
    }, (r) {
      add(UpdateLikeSocialSharedProductsEvent(
        productId: event.productId,
      ));
      ErrorManager.resetRetry('AddCommentEvent');
      Map<String, GetProductDetailWithoutRelatedProductsModel> cachedProducts =
          Map.of(state.cachedProductWithoutRelatedProductsModel);
      cachedProducts[event.productId] = cachedProducts[event.productId]!
          .copyWith(
              data: cachedProducts[event.productId]?.product?.copyWith(
                  comments: [
            r,
            ...cachedProducts[event.productId]?.product?.comments ?? []
          ],
                  commentsCount: (cachedProducts[event.productId]
                              ?.product
                              ?.commentsCount ??
                          0) +
                      1));
      emit(state.copyWith(
          addCommentStatus: AddCommentStatus.success,
          cachedProductWithoutRelatedProductsModel: cachedProducts));
    });
  }
*/
  FutureOr<void> _onStoreFcmTokenOfMarketEvent(
    StoreFcmTokenOfMarketEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (event.userId == -1) {
      return;
    }
    final response = await storeFcmTokenOfMarketUseCase(
      StoreFcmTokenOfMarketUseCaseParams(
        fcmToken: event.fcmToken,
        userId: event.userId,
      ),
    );

    response.fold(
      (l) {
        if (ErrorManager.shouldRetry(
          'StoreFcmTokenOfMarketEvent',
          l.statusCode,
        )) {
          ErrorManager.incrementRetry('StoreFcmTokenOfMarketEvent');
          add(
            StoreFcmTokenOfMarketEvent(
              fcmToken: event.fcmToken,
              userId: event.userId,
            ),
          );
          return;
        }
      },
      (firebaseTokenId) {
        if (kDebugMode)
          devLog("StoreFcmTokenOfMarketEvent success${firebaseTokenId}");
        ErrorManager.resetRetry('StoreFcmTokenOfMarketEvent');
        prefsRepository.setFcmMarketTokenId(firebaseTokenId);
      },
    );
  }

  FutureOr<void> _onSendAcceptOfNotificationMarketEvent(
    SendAcceptOfNotificationMarketEvent event,
    Emitter<HomeState> emit,
  ) async {
    final response = await sendAcceptOfNotificationsUseCase(
      SendAcceptOfNotificationsUseCaseParams(
        firebaseTokenId: event.firebaseTokenId,
      ),
    );
    response.fold(
      (l) {
        if (ErrorManager.shouldRetry(
          'SendAcceptOfNotificationMarketEvent',
          l.statusCode,
        )) {
          add(
            SendAcceptOfNotificationMarketEvent(
              firebaseTokenId: event.firebaseTokenId,
            ),
          );
          ErrorManager.incrementRetry('SendAcceptOfNotificationMarketEvent');
        }
      },
      (r) {
        ErrorManager.resetRetry('SendAcceptOfNotificationMarketEvent');
      },
    );
  }

  FutureOr<void> _onCheckAvailabilityProductCartEvent(
    CheckAvailabilityProductCartEvent event,
    Emitter<HomeState> emit,
  ) async {
    ///////////////////////////
    emit(
      state.copyWith(
        checkAvailabilityProductCartStatus:
            CheckAvailabilityProductCartStatus.loading,
      ),
    );

    final response = await checkAvailabilityProductCartUsecase(NoParams());

    response.fold(
      (l) {
        if (ErrorManager.shouldRetry(
          'CheckAvailabilityProductCartEvent',
          l.statusCode,
        )) {
          add(CheckAvailabilityProductCartEvent());
          ErrorManager.incrementRetry('CheckAvailabilityProductCartEvent');
        }

        emit(
          state.copyWith(
            checkAvailabilityProductCartStatus:
                CheckAvailabilityProductCartStatus.failure,
          ),
        );
      },
      (r) {
        ErrorManager.resetRetry('CheckAvailabilityProductCartEvent');

        debugPrint('CheckAvailabilityProductCartEvent success');

        ////////////////////////////
        emit(
          state.copyWith(
            checkAvailabilityProductCartStatus:
                CheckAvailabilityProductCartStatus.success,
            checkAvailabilityProductCartModel: r,
          ),
        );
      },
    );
  }

  FutureOr<void> _onGetCartOverviewEvent(
    GetCartOverviewEvent event,
    Emitter<HomeState> emit,
  ) async {
    ///////////////////////////
    emit(state.copyWith(getCartOverviewStatus: GetCartOverviewStatus.loading));

    final response = await getCartOverviewUseCase(NoParams());

    response.fold(
      (l) {
        if (ErrorManager.shouldRetry('GetCartOverviewEvent', l.statusCode)) {
          add(GetCartOverviewEvent());
          ErrorManager.incrementRetry('GetCartOverviewEvent');
        }

        emit(
          state.copyWith(getCartOverviewStatus: GetCartOverviewStatus.failure),
        );
      },
      (r) {
        List<Cart>? cart = state.getCartShippingItemsModel?.data?.cart;
        GetCartShippingItemsModel? getCartShippingItemsModel = r.copyWith(
          data: r.data?.copyWith(cart: cart),
        );

        ErrorManager.resetRetry('GetCartOverviewEvent');

        debugPrint('GetCartOverviewEvent success');

        ////////////////////////////
        emit(
          state.copyWith(
            getCartOverviewStatus: GetCartOverviewStatus.success,
            getCartShippingItemsModel: getCartShippingItemsModel,
          ),
        );
      },
    );
  }

  FutureOr<void> _onGetUserNotificationEvent(
    GetUserNotificationEvent event,
    Emitter<HomeState> emit,
  ) async {
    PaginationModel<NotificationItemModel>? getUserNotificationModel =
        !event.getWithPagination
        ? const PaginationModel.init(page: 1)
        : state.getUserNotificationModel;

    if (getUserNotificationModel == null) {
      (getUserNotificationModel =
          const PaginationModel<NotificationItemModel>.init(page: 1));
    }
    ///////////////////////////////////////
    if (event.getWithPagination &&
        (getUserNotificationModel.hasReachedMax ||
            getUserNotificationModel.paginationStatus ==
                PaginationStatus.loading)) {
      return;
    }
    ///////////////////////////
    emit(
      state.copyWith(
        getUserNotificationModel: getUserNotificationModel.copyWith(
          paginationStatus: PaginationStatus.loading,
        ),
      ),
    );
    ///////////////////////////////

    final response = await getUserNotificationUseCase(
      event.getWithPagination ? getUserNotificationModel.page : 1,
    );

    response.fold(
      (l) {
        getUserNotificationModel = state.getUserNotificationModel;

        if (ErrorManager.shouldRetry(
          'GetUserNotificationEvent',
          l.statusCode,
        )) {
          add(
            GetUserNotificationEvent(
              getWithPagination: event.getWithPagination,
            ),
          );
          ErrorManager.incrementRetry('GetUserNotificationEvent');
        }

        emit(
          state.copyWith(
            getUserNotificationModel: getUserNotificationModel!.copyWith(
              paginationStatus: PaginationStatus.failure,
            ),
          ),
        );
      },
      (r) {
        debugPrint('GetUserNotificationEvent success');

        getUserNotificationModel = state.getUserNotificationModel;

        ErrorManager.resetRetry('GetUserNotificationEvent');

        List<NotificationItemModel> notifications =
            getUserNotificationModel!.items;

        ////////////////////////////
        emit(
          state.copyWith(
            getUserNotificationModel: getUserNotificationModel!.copyWith(
              hasReachedMax: (r.data!.notifications!.length) < kPageSize,
              paginationStatus: PaginationStatus.success,
              page: event.getWithPagination
                  ? getUserNotificationModel!.page + 1
                  : 2,
              items: !event.getWithPagination
                  ? [...r.data!.notifications ?? []]
                  : [...notifications, ...r.data!.notifications ?? []],
            ),
          ),
        );
      },
    );
  }

  //****************************** Checklist ******************************/

  // Note on `productInChecklist`: the map is rebuilt with a spread on every
  // write because HomeState is immutable — mutating the existing map in place
  // would not trigger a rebuild (Equatable would see the same instance). Since
  // map keys are unique, `{...old, id: value}` overwrites an existing entry
  // rather than appending a duplicate.

  /// Per-product status write. Rebuilds the map with a spread because
  /// HomeState is immutable — mutating in place would not trigger a rebuild
  /// (Equatable would see the same instance). Map keys are unique, so this
  /// overwrites an existing entry rather than appending a duplicate.
  Map<String, ChecklistItemStatus> _withChecklistStatus(
    String productId,
    ChecklistItemStatus status,
  ) => {...state.checklistItemStatus, productId: status};

  bool _isChecklistBusy(String productId) =>
      state.checklistItemStatus[productId] == ChecklistItemStatus.loading;

  FutureOr<void> _onCheckChecklistExistEvent(
    CheckChecklistExistEvent event,
    Emitter<HomeState> emit,
  ) async {
    final int? productId = int.tryParse(event.productId);
    if (productId == null) return;

    // A toggle already in flight for this product knows the membership better
    // than a check started before it — never let a stale check overwrite it.
    if (_isChecklistBusy(event.productId)) return;

    emit(
      state.copyWith(
        checklistItemStatus: _withChecklistStatus(
          event.productId,
          ChecklistItemStatus.loading,
        ),
      ),
    );

    final response = await checkChecklistExistUseCase(productId);

    response.fold(
      (l) {
        emit(
          state.copyWith(
            checklistItemStatus: _withChecklistStatus(
              event.productId,
              ChecklistItemStatus.failure,
            ),
          ),
        );
      },
      (r) {
        emit(
          state.copyWith(
            checklistItemStatus: _withChecklistStatus(
              event.productId,
              ChecklistItemStatus.success,
            ),
            productInChecklist: {
              ...state.productInChecklist,
              event.productId: r.isExist,
            },
          ),
        );
      },
    );
  }

  FutureOr<void> _onToggleChecklistEvent(
    ToggleChecklistEvent event,
    Emitter<HomeState> emit,
  ) async {
    final int? productId = int.tryParse(event.productId);
    if (productId == null) return;

    // Guard against a double tap while this product's call is still running.
    if (_isChecklistBusy(event.productId)) return;

    final bool isCurrentlyInChecklist =
        state.productInChecklist[event.productId] ?? false;

    emit(
      state.copyWith(
        checklistItemStatus: _withChecklistStatus(
          event.productId,
          ChecklistItemStatus.loading,
        ),
      ),
    );

    final response = isCurrentlyInChecklist
        ? await deleteFromChecklistUseCase(productId)
        : await addToChecklistUseCase(productId);

    response.fold(
      (l) {
        emit(
          state.copyWith(
            checklistItemStatus: _withChecklistStatus(
              event.productId,
              ChecklistItemStatus.failure,
            ),
          ),
        );
        showMessage(
          LocaleKeys.something_went_wrong.tr(),
          hasError: true,
          showInRelease: true,
        );
      },
      (r) {
        emit(
          state.copyWith(
            checklistItemStatus: _withChecklistStatus(
              event.productId,
              ChecklistItemStatus.success,
            ),
            productInChecklist: {
              ...state.productInChecklist,
              event.productId: !isCurrentlyInChecklist,
            },
          ),
        );
      },
    );
  }

  FutureOr<void> _onGetChecklistEvent(
    GetChecklistEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(getChecklistStatus: GetChecklistStatus.loading));

    final response = await getChecklistUseCase(
      GetChecklistParams(page: event.page, pageSize: kPageSize),
    );

    response.fold(
      (l) {
        emit(state.copyWith(getChecklistStatus: GetChecklistStatus.failure));
      },
      (r) {
        // Deleting the last row of a page (or a concurrent delete from another
        // device) can leave us past the end. Self-heal by walking back a page
        // instead of stranding the user on an empty view with no controls.
        final bool isEmptyBeyondFirstPage =
            (r.data?.items?.isEmpty ?? true) && event.page > 1;
        if (isEmptyBeyondFirstPage) {
          add(GetChecklistEvent(page: event.page - 1));
          return;
        }

        emit(
          state.copyWith(
            getChecklistStatus: GetChecklistStatus.success,
            checklistPageData: r.data,
          ),
        );
      },
    );
  }

  FutureOr<void> _onDeleteChecklistItemEvent(
    DeleteChecklistItemEvent event,
    Emitter<HomeState> emit,
  ) async {
    final int? productId = int.tryParse(event.productId);
    if (productId == null) return;

    if (_isChecklistBusy(event.productId)) return;

    emit(
      state.copyWith(
        checklistItemStatus: _withChecklistStatus(
          event.productId,
          ChecklistItemStatus.loading,
        ),
      ),
    );

    final response = await deleteFromChecklistUseCase(productId);

    response.fold(
      (l) {
        emit(
          state.copyWith(
            checklistItemStatus: _withChecklistStatus(
              event.productId,
              ChecklistItemStatus.failure,
            ),
          ),
        );
        showMessage(
          LocaleKeys.something_went_wrong.tr(),
          hasError: true,
          showInRelease: true,
        );
      },
      (r) {
        emit(
          state.copyWith(
            checklistItemStatus: _withChecklistStatus(
              event.productId,
              ChecklistItemStatus.success,
            ),
            productInChecklist: {
              ...state.productInChecklist,
              event.productId: false,
            },
          ),
        );

        // Reload the page we are on. `_onGetChecklistEvent` walks back a page
        // if this delete emptied it, so no page math is needed here — which
        // also makes concurrent deletes on the same page safe.
        add(GetChecklistEvent(page: state.checklistPageData?.currentPage ?? 1));
      },
    );
  }

  FutureOr<void> _onUpdateProfileEvent(
    UpdateProfileEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (event.changeStatusToInit ?? false) {
      emit(state.copyWith(updateProfileStatus: UpdateProfileStatus.init));
      return;
    }
    ///////////////////////////
    emit(state.copyWith(updateProfileStatus: UpdateProfileStatus.loading));
    ///////////////////////////////

    final response = await updateProfileUseCase(
      UpdateProfileParams(
        gender: event.gender,
        name: event.name,
        email: event.email,
        image: event.image,
        tall: event.tall,
        idToken: event.idToken,
        weight: event.weight,
        alternative_phone: event.alternative_phone,
        phone: event.phone,
      ),
    );

    response.fold(
      (l) {
        if (ErrorManager.shouldRetry('UpdateProfileEvent', l.statusCode)) {
          add(
            UpdateProfileEvent(
              alternative_phone: event.alternative_phone,
              email: event.email,
              gender: event.gender,
              idToken: event.idToken,
              image: event.image,
              name: event.name,
              phone: event.phone,
              tall: event.tall,
              weight: event.weight,
            ),
          );
          ErrorManager.incrementRetry('UpdateProfileEvent');
        }

        emit(state.copyWith(updateProfileStatus: UpdateProfileStatus.failure));
      },
      (r) async {
        prefsRepository.setMyProfilePhoto((r.data?.image ?? "").toString());
        showMessage(
          r.message ?? "",
          foreGroundColor: Colors.white,
          backGroundColor: Colors.black,
          showInRelease: true,
        );
        ErrorManager.resetRetry('UpdateProfileEvent');
        prefsRepository.setMyMarketName(r.data?.name ?? "");
        prefsRepository.setVerifiedPhone(r.data?.isPhoneVerified == 1);
        prefsRepository.setPhoneNumber(r.data?.phone ?? "");
        ////////////////////////////

        if ((prefsRepository.chatToken?.length ?? 0) > 6 &&
            (event.name != null ||
                event.image != null ||
                event.phone != null)) {
          GetIt.I<ChatBloc>().add(
            UpdateProfileInChatEvent(
              userId: prefsRepository.myMarketId.toString(),
              name: r.data?.name ?? "",
              phone: r.data?.phone ?? "",
              photo: r.data?.image ?? "",
            ),
          );
        }
        if ((prefsRepository.storiesToken?.length ?? 0) > 6 &&
            (event.name != null ||
                event.image != null ||
                event.phone != null)) {
          prefsRepository.setMyStoriesName((r.data?.name ?? 'No Name'));

          GetIt.I<AuthBloc>().add(
            UpdateStoriesUserEvent(
              name: r.data?.name ?? "",
              phone: r.data?.phone ?? "",
              photo: r.data?.image ?? "",
            ),
          );
        }
        emit(
          state.copyWith(
            userInfo: r.data,
            updateProfileStatus: UpdateProfileStatus.success,
          ),
        );
        if (event.fromGuest ?? false) {
          GetIt.I<AuthBloc>().add(
            LoginToStoriesEvent(
              originalUserId: r.data?.id.toString(),
              otpIdToken: prefsRepository.idToken,
              name: r.data?.name,
              phone: r.data?.phone,
            ),
          );
          /*   GetIt.I<AuthBloc>().add(
            LoginToWalletEvent(
              otpIdToken: prefsRepository.idToken,
              name: r.data?.name,
              phone: r.data?.phone,
            ),
          );*/
          await NotificationProcess().fcmToken(
            r.data?.phone,
            r.data?.name,
            r.data?.id.toString(),
            prefsRepository.idToken,
          );
        }
      },
    );
  }

  _onUploadUserPhotoCloudinaryEvent(
    UploadUserPhotoCloudinaryEvent event,
    Emitter emit,
  ) async {
    if (event.changeStatusToFailure ?? false) {
      emit(
        state.copyWith(
          uploadUserPhotoCloudinaryStatus:
              UploadUserPhotoCloudinaryStatus.failure,
        ),
      );

      showMessage(
        '${LocaleKeys.your_request_faild.tr()}',
        foreGroundColor: Colors.white,
        backGroundColor: Colors.black,
        hasError: true,
        showInRelease: true,
      );
      return;
    }
    emit(
      state.copyWith(
        uploadUserPhotoCloudinaryStatus:
            UploadUserPhotoCloudinaryStatus.loading,
      ),
    );
    final response = await uploadFileCloudinaryUseCase(
      UpdatePhotoParams(path: "customers/profile", image: event.file),
    );

    // Fluttertoast.showToast(msg: 'tosss');
    response.fold(
      (l) {
        if (ErrorManager.shouldRetry(
          'UploadUserPhptoCloudinaryEvent',
          l.statusCode,
        )) {
          ErrorManager.incrementRetry('UploadUserPhptoCloudinaryEvent');
          add(
            UploadUserPhotoCloudinaryEvent(
              event.file,
              event.changeStatusToFailure,
            ),
          );
        }
      },
      (r) {
        add(UpdateProfileEvent(image: r.data?.subPath));
        emit(
          state.copyWith(
            uploadUserPhotoCloudinaryStatus:
                UploadUserPhotoCloudinaryStatus.success,
          ),
        );
        ErrorManager.resetRetry('UploadUserPhptoCloudinaryEvent');
      },
    );
  }

  FutureOr<void> _onFetchAuthProductDetailsEvent(
    FetchAuthProductDetailsEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        authProductDetailsStatus: AuthProductDetailsStatus.loading,
        authProductDetailsModel: GetAuthProductDetailsModel(),
      ),
    );
    final response = await getAuthProductDetailsUseCase(event.productSlug);
    response.fold(
      (failure) {
        if (ErrorManager.shouldRetry(
          'FetchAuthProductDetailsEvent',
          failure.statusCode,
        )) {
          ErrorManager.incrementRetry('FetchAuthProductDetailsEvent');
          add(FetchAuthProductDetailsEvent(event.productSlug));
        }
        emit(
          state.copyWith(
            authProductDetailsStatus: AuthProductDetailsStatus.failure,
          ),
        );
      },
      (details) {
        ErrorManager.resetRetry('FetchAuthProductDetailsEvent');
        emit(
          state.copyWith(
            authProductDetailsStatus: AuthProductDetailsStatus.success,
            authProductDetailsModel: details,
          ),
        );
      },
    );
  }

  /* FutureOr<void> _onGetCommentsFromAnalyticsEvent(
    GetCommentsFromAnalyticsEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (state.getCommentsFromAnalyticsPaginationModel?.paginationStatus ==
            PaginationStatus.loading ||
        state.getCommentsFromAnalyticsPaginationModel?.hasReachedMax == true) {
      return;
    }
    List<dynamic> offsetList = [];
    offsetList.add(state.getCommentsFromAnalyticsPaginationModel?.offset
        ?.split('[')
        .last
        .split(',')[0]);
    offsetList.add(
        '"${state.getCommentsFromAnalyticsPaginationModel?.offset?.split(',').last.split(']')[0]}"');
    emit(state.copyWith(
        getCommentsFromAnalyticsPaginationModel: state
            .getCommentsFromAnalyticsPaginationModel
            ?.copyWith(paginationStatus: PaginationStatus.loading)));
    final response = await getCommentsFromAnalyticsUsecase(
        getCommentsFromAnalyticsParams(
            offset: offsetList.toString(), productId: event.productId));
    response.fold((l) {
      emit(state.copyWith(
          getCommentsFromAnalyticsPaginationModel: state
              .getCommentsFromAnalyticsPaginationModel
              ?.copyWith(paginationStatus: PaginationStatus.failure)));
    }, (r) {
      emit(state.copyWith(
          getCommentsFromAnalyticsPaginationModel:
              state.getCommentsFromAnalyticsPaginationModel?.copyWith(
        paginationStatus: PaginationStatus.success,
        items: [
          ...state.getCommentsFromAnalyticsPaginationModel?.items ?? [],
          ...r.data?.comments ?? []
        ],
        hasReachedMax: (r.data?.comments?.length ?? 0) < 10,
        offset: r.data?.searchAfter?.toString(),
      )));
    });
  }*/

  FutureOr<void> _onGetFqaCommentsEvent(
    GetFqaCommentsEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (event.getWithPagination &&
        (state
                    .getFqaCommentsPaginationModel?[event.currentFilter]
                    ?.paginationStatus ==
                PaginationStatus.loading ||
            state
                    .getFqaCommentsPaginationModel?[event.currentFilter]
                    ?.hasReachedMax ==
                true)) {
      return;
    }
    Map<String, PaginationModel<FqaComment>> getFqaCommentsPaginationModel =
        Map.of(state.getFqaCommentsPaginationModel ?? {});
    if (getFqaCommentsPaginationModel[event.currentFilter] == null) {
      getFqaCommentsPaginationModel.addAll({
        event.currentFilter: const PaginationModel<FqaComment>(
          hasReachedMax: false,
          items: [],
          page: 0,
          offset: "",
          paginationStatus: PaginationStatus.initial,
          total: 0,
        ),
      });
    }
    List<dynamic> offsetList = [];
    if (event.getWithPagination) {
      offsetList.add(
        state.getFqaCommentsPaginationModel?[event.currentFilter]?.offset
            ?.split('[')
            .last
            .split(',')[0],
      );
      offsetList.add(
        '"${state.getFqaCommentsPaginationModel?[event.currentFilter]?.offset?.split(',').last.split(']')[0]}"',
      );
    }
    getFqaCommentsPaginationModel[event.currentFilter] =
        getFqaCommentsPaginationModel[event.currentFilter]!.copyWith(
          paginationStatus: PaginationStatus.loading,
        );

    emit(
      state.copyWith(
        getFqaCommentsPaginationModel: getFqaCommentsPaginationModel,
      ),
    );

    final response = await getFqaCommentsUsecase(
      GetFqaCommentsParams(
        filter: event.currentFilter == "all" ? null : event.currentFilter,
        offset: offsetList.toString(),
        productId: event.productId,
      ),
    );
    response.fold(
      (l) {
        Map<String, PaginationModel<FqaComment>> getFqaCommentsPaginationModel =
            Map.of(state.getFqaCommentsPaginationModel ?? {});
        getFqaCommentsPaginationModel[event.currentFilter] =
            getFqaCommentsPaginationModel[event.currentFilter]!.copyWith(
              paginationStatus: PaginationStatus.failure,
            );
        emit(
          state.copyWith(
            getFqaCommentsPaginationModel: getFqaCommentsPaginationModel,
          ),
        );
      },
      (r) {
        Map<String, PaginationModel<FqaComment>> getFqaCommentsPaginationModel =
            Map.of(state.getFqaCommentsPaginationModel ?? {});
        getFqaCommentsPaginationModel[event.currentFilter] =
            getFqaCommentsPaginationModel[event.currentFilter]!.copyWith(
              paginationStatus: PaginationStatus.success,
              total: r.data?.total,
              items: event.getWithPagination
                  ? [
                      ...getFqaCommentsPaginationModel[event.currentFilter]
                              ?.items ??
                          [],
                      ...r.data?.fqaComments ?? [],
                    ]
                  : [...r.data?.fqaComments ?? []],
              hasReachedMax:
                  (r.data?.fqaComments?.length ?? 0) < 10 ||
                  r.data?.offset == null ||
                  r.data?.offset == "null",
              offset: r.data?.offset?.toString(),
            );
        emit(
          state.copyWith(
            getFqaCommentsPaginationModel: getFqaCommentsPaginationModel,
          ),
        );
      },
    );
  }

  FutureOr<void> _onGetBuyersCommentsEvent(
    GetBuyersCommentsEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (event.getWithPagination &&
        (state
                    .getBuyersCommentsPaginationModel?[event.currentFilter]
                    ?.paginationStatus ==
                PaginationStatus.loading ||
            state
                    .getBuyersCommentsPaginationModel?[event.currentFilter]
                    ?.hasReachedMax ==
                true)) {
      return;
    }
    Map<String, PaginationModel<BuyersComment>>
    getBuyersCommentsPaginationModel = Map.of(
      state.getBuyersCommentsPaginationModel ?? {},
    );
    if (getBuyersCommentsPaginationModel[event.currentFilter] == null) {
      getBuyersCommentsPaginationModel.addAll({
        event.currentFilter: const PaginationModel<BuyersComment>(
          hasReachedMax: false,
          items: [],
          page: 0,
          offset: "",
          paginationStatus: PaginationStatus.initial,
          total: 0,
        ),
      });
    }
    List<dynamic> offsetList = [];
    if (event.getWithPagination) {
      offsetList.add(
        state.getBuyersCommentsPaginationModel?[event.currentFilter]?.offset
            ?.split('[')
            .last
            .split(',')[0],
      );
      offsetList.add(
        '"${state.getBuyersCommentsPaginationModel?[event.currentFilter]?.offset?.split(',').last.split(']')[0]}"',
      );
    }
    getBuyersCommentsPaginationModel[event.currentFilter] =
        getBuyersCommentsPaginationModel[event.currentFilter]!.copyWith(
          paginationStatus: PaginationStatus.loading,
        );
    emit(
      state.copyWith(
        getBuyersCommentsPaginationModel: getBuyersCommentsPaginationModel,
      ),
    );
    final response = await getBuyerCommentsUsecase(
      GetBuyersCommentsParams(
        offset: (event.getWithPagination) ? "" : offsetList.toString(),
        filter: event.currentFilter == "all" ? null : event.currentFilter,
        productId: event.productId,
      ),
    );
    response.fold(
      (l) {
        Map<String, PaginationModel<BuyersComment>>
        getBuyersCommentsPaginationModel = Map.of(
          state.getBuyersCommentsPaginationModel ?? {},
        );
        getBuyersCommentsPaginationModel[event.currentFilter] =
            getBuyersCommentsPaginationModel[event.currentFilter]!.copyWith(
              paginationStatus: PaginationStatus.failure,
            );
        emit(
          state.copyWith(
            getBuyersCommentsPaginationModel: getBuyersCommentsPaginationModel,
          ),
        );
      },
      (r) {
        Map<String, PaginationModel<BuyersComment>>
        getBuyersCommentsPaginationModel = Map.of(
          state.getBuyersCommentsPaginationModel ?? {},
        );
        getBuyersCommentsPaginationModel[event.currentFilter] =
            getBuyersCommentsPaginationModel[event.currentFilter]!.copyWith(
              paginationStatus: PaginationStatus.success,
              total: r.data?.total,
              items: (event.getWithPagination)
                  ? [
                      ...getBuyersCommentsPaginationModel[event.currentFilter]
                              ?.items ??
                          [],
                      ...r.data?.buyersComments ?? [],
                    ]
                  : [...r.data?.buyersComments ?? []],
              hasReachedMax:
                  (r.data?.buyersComments?.length ?? 0) < 10 ||
                  r.data?.offset == null ||
                  r.data?.offset == "null",
              offset: r.data?.offset?.toString(),
            );
        emit(
          state.copyWith(
            getBuyersCommentsPaginationModel: getBuyersCommentsPaginationModel,
          ),
        );
      },
    );
  }

  FutureOr<void> _onGetOrderRatingEvent(
    GetOrderRatingEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        getOrderRatingStatus: GetOrderRatingStatus.loading,
        getOrderRatingComments: [],
      ),
    );
    final response = await getOrderRatingUsecase(
      getOrderRatingParams(
        orderDetailIds: event.orderDetailIds,
        userId: event.userId,
      ),
    );
    response.fold(
      (l) {
        if (ErrorManager.shouldRetry('GetOrderRatingEvent', l.statusCode)) {
          ErrorManager.incrementRetry('GetOrderRatingEvent');
          add(
            GetOrderRatingEvent(
              orderDetailIds: event.orderDetailIds,
              userId: event.userId,
            ),
          );
          return;
        }
        emit(
          state.copyWith(getOrderRatingStatus: GetOrderRatingStatus.failure),
        );
      },
      (r) {
        ErrorManager.resetRetry('GetOrderRatingEvent');
        emit(
          state.copyWith(
            createCommentRatingStatus: CreateCommentRatingStatus.success,
            getOrderRatingStatus: GetOrderRatingStatus.success,
            getOrderRatingComments: r.data?.comments ?? [],
          ),
        );
      },
    );
  }

  FutureOr<void> _onCreateCommentRatingEvent(
    CreateCommentRatingEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        updateOrderCommentRatingStatus: UpdateOrderCommentRatingStatus.init,
        createCommentRatingStatus: CreateCommentRatingStatus.loading,
      ),
    );
    final response = await createOrderRatingUseCase(
      CreateOrderCommentRatingParams(
        text: event.text,
        productId: event.productId,
        ownerId: event.ownerId,
        images: event.images,
        slug: event.slug,
        ownerType: event.ownerType,
        variant: event.variant?.replaceAll("_", "-"),
        rating: event.rating,
        orderDetailsId: event.orderDetailsId,
      ),
    );
    response.fold(
      (l) {
        if (ErrorManager.shouldRetry(
          'CreateCommentRatingEvent',
          l.statusCode,
        )) {
          ErrorManager.incrementRetry('CreateCommentRatingEvent');
          add(
            CreateCommentRatingEvent(
              text: event.text,
              productId: event.productId,
              ownerId: event.ownerId,
              ownerType: event.ownerType,
              images: event.images,
              slug: event.slug,
              variant: event.variant?.replaceAll("_", "-"),
              rating: event.rating,
              orderDetailsId: event.orderDetailsId,
            ),
          );
          return;
        }
        if (l.statusCode == 401) {
          // showMessage(LocaleKeys.please_login_to_add_comment.tr());
        } else {
          showMessage(l.message);
        }
        emit(
          state.copyWith(
            createCommentRatingStatus: CreateCommentRatingStatus.failure,
            statusCodeOfCommentProcess: l.statusCode.toString(),
          ),
        );
      },
      (r) {
        ErrorManager.resetRetry('CreateCommentRatingEvent');
        add(
          UpdateLikeSocialSharedProductsEvent(productId: event.productId ?? ""),
        );
        showMessage(r.message ?? "");
        Map<String, PaginationModel<FqaComment>> getFqaCommentsPaginationModel =
            Map.of(state.getFqaCommentsPaginationModel ?? {});
        getFqaCommentsPaginationModel["all"] =
            getFqaCommentsPaginationModel["all"]!.copyWith(
              total: (getFqaCommentsPaginationModel["all"]?.total ?? 0) + 1,
              paginationStatus: PaginationStatus.success,
              items: [
                FqaComment(
                  comment: r.data?.text,
                  createdAt: r.data?.createdAt,
                  hasReply: false,
                  variant: r.data?.variant,
                  id: r.data?.commentId,
                  productId: r.data?.productId,
                  customer: CommentCustomer(
                    id: r.data?.userId,
                    image: r.data?.userAvatar,
                    name: r.data?.userName,
                  ),
                ),
                ...getFqaCommentsPaginationModel["all"]?.items ?? [],
              ],
            );
        emit(
          state.copyWith(
            getFqaCommentsPaginationModel: getFqaCommentsPaginationModel,
            createCommentRatingStatus: CreateCommentRatingStatus.success,
          ),
        );
      },
    );
  }

  FutureOr<void> _onUpdateCommentRatingEvent(
    UpdateCommentRatingEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        createCommentRatingStatus: CreateCommentRatingStatus.init,
        tapCommentIndex: event.tapCommentIndex,
        updateOrderCommentRatingStatus: UpdateOrderCommentRatingStatus.loading,
      ),
    );

    final response = await updateOrderCommentRatingUseCase(
      UpdateOrderCommentRatingParams(
        text: event.text,
        commentId: event.commentId,
        productId: event.productId,
        variant: event.variant,
        ownerId: event.ownerId,
        ownerType: event.ownerType,
        images: event.images,
        slug: event.slug,
        rating: event.rating,
        orderDetailsId: event.orderDetailsId,
      ),
    );
    response.fold(
      (l) {
        if (ErrorManager.shouldRetry(
          'UpdateCommentRatingEvent',
          l.statusCode,
        )) {
          ErrorManager.incrementRetry('UpdateCommentRatingEvent');
          add(
            UpdateCommentRatingEvent(
              text: event.text,
              commentId: event.commentId,
              productId: event.productId,
              currentFilter: event.currentFilter,
              images: event.images,
              slug: event.slug,
              variant: event.variant,
              ownerId: event.ownerId,
              ownerType: event.ownerType,
              tapCommentIndex: event.tapCommentIndex,
              rating: event.rating,
              orderDetailsId: event.orderDetailsId,
            ),
          );
          return;
        }
        if (l.statusCode == 401) {
          //    showMessage(LocaleKeys.must_login_to_edit_comment.tr());
        } else {
          showMessage(l.message);
        }

        emit(
          state.copyWith(
            updateOrderCommentRatingStatus:
                UpdateOrderCommentRatingStatus.failure,
            statusCodeOfCommentProcess: l.statusCode.toString(),
          ),
        );
      },
      (r) {
        ErrorManager.resetRetry('UpdateCommentRatingEvent');
        add(
          UpdateLikeSocialSharedProductsEvent(productId: event.productId ?? ""),
        );
        Map<String, PaginationModel<FqaComment>> getFqaCommentsPaginationModel =
            Map.of(state.getFqaCommentsPaginationModel ?? {});
        Map<String, PaginationModel<BuyersComment>>
        getBuyersCommentsPaginationModel = Map.of(
          state.getBuyersCommentsPaginationModel ?? {},
        );
        showMessage(r.message ?? "");
        if (event.fromBuyerComments) {
          List<BuyersComment> buyersCommentItems =
              getBuyersCommentsPaginationModel[event.currentFilter]?.items ??
              [];
          int index = buyersCommentItems.indexWhere(
            (element) => element.id == event.commentId,
          );
          if (index != -1) {
            BuyersComment buyersComment = buyersCommentItems.removeAt(index);
            buyersCommentItems.insert(
              index,
              buyersComment.copyWith(comment: event.text, isTran: false),
            );
          }

          getBuyersCommentsPaginationModel[event.currentFilter] =
              getBuyersCommentsPaginationModel[event.currentFilter]!.copyWith(
                paginationStatus: PaginationStatus.success,
                items: buyersCommentItems,
              );
        } else {
          List<FqaComment> fqaCommentItems =
              getFqaCommentsPaginationModel[event.currentFilter]?.items ?? [];
          int index = fqaCommentItems.indexWhere(
            (element) => element.id == event.commentId,
          );
          if (index != -1) {
            FqaComment fqaComment = fqaCommentItems.removeAt(index);
            fqaCommentItems.insert(
              index,
              fqaComment.copyWith(comment: event.text, isTran: false),
            );
          }

          getFqaCommentsPaginationModel[event.currentFilter] =
              getFqaCommentsPaginationModel[event.currentFilter]!.copyWith(
                paginationStatus: PaginationStatus.success,
                items: fqaCommentItems,
              );
        }
        emit(
          state.copyWith(
            getBuyersCommentsPaginationModel: getBuyersCommentsPaginationModel,
            getFqaCommentsPaginationModel: getFqaCommentsPaginationModel,
            updateOrderCommentRatingStatus:
                UpdateOrderCommentRatingStatus.success,
          ),
        );
      },
    );
  }

  FutureOr<void> _onDeleteCommentRatingEvent(
    DeleteCommentRatingEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        tapCommentIndex: event.tapCommentIndex,
        deleteOrderCommentRatingStatus: DeleteOrderCommentRatingStatus.loading,
      ),
    );
    final response = await deleteOrderCommentRatingUseCase(
      DeleteOrderCommentRatingParams(commentId: event.commentId),
    );
    response.fold(
      (l) {
        if (ErrorManager.shouldRetry(
          'DeleteCommentRatingEvent',
          l.statusCode,
        )) {
          ErrorManager.incrementRetry('DeleteCommentRatingEvent');
          add(
            DeleteCommentRatingEvent(
              commentId: event.commentId,
              productId: event.productId,
              currentFilter: event.currentFilter,
              tapCommentIndex: event.tapCommentIndex,
            ),
          );
          return;
        }
        if (l.statusCode == 401) {
          //   showMessage(LocaleKeys.must_login_to_delete_comment.tr());
        } else {
          showMessage(l.message);
        }
        emit(
          state.copyWith(
            deleteOrderCommentRatingStatus:
                DeleteOrderCommentRatingStatus.failure,
            statusCodeOfCommentProcess: l.statusCode.toString(),
          ),
        );
      },
      (r) {
        ErrorManager.resetRetry('DeleteCommentRatingEvent');
        add(
          UpdateLikeSocialSharedProductsEvent(productId: event.productId ?? ""),
        );
        showMessage(r.message ?? "");
        Map<String, PaginationModel<BuyersComment>>
        getBuyersCommentsPaginationModel = Map.of(
          state.getBuyersCommentsPaginationModel ?? {},
        );
        Map<String, PaginationModel<FqaComment>> getFqaCommentsPaginationModel =
            Map.of(state.getFqaCommentsPaginationModel ?? {});

        if (event.fromBuyerComments) {
          List<BuyersComment> buyersCommentItems =
              getBuyersCommentsPaginationModel[event.currentFilter]?.items ??
              [];
          int index = buyersCommentItems.indexWhere(
            (element) => element.id == event.commentId,
          );
          if (index != -1) {
            buyersCommentItems.removeAt(index);
          }

          getBuyersCommentsPaginationModel[event.currentFilter] =
              getBuyersCommentsPaginationModel[event.currentFilter]!.copyWith(
                paginationStatus: PaginationStatus.success,
                total:
                    (getBuyersCommentsPaginationModel[event.currentFilter]
                            ?.total ??
                        0) -
                    1,
                items: buyersCommentItems,
              );
        } else {
          List<FqaComment> fqaCommentItems =
              state
                  .getFqaCommentsPaginationModel?[event.currentFilter]
                  ?.items ??
              [];
          int index = fqaCommentItems.indexWhere(
            (element) => element.id == event.commentId,
          );
          if (index != -1) {
            fqaCommentItems.removeAt(index);
          }

          getFqaCommentsPaginationModel[event.currentFilter] =
              getFqaCommentsPaginationModel[event.currentFilter]!.copyWith(
                paginationStatus: PaginationStatus.success,
                total:
                    (getFqaCommentsPaginationModel[event.currentFilter]
                            ?.total ??
                        0) -
                    1,
                items: fqaCommentItems,
              );
        }

        emit(
          state.copyWith(
            getFqaCommentsPaginationModel: getFqaCommentsPaginationModel,
            deleteOrderCommentRatingStatus:
                DeleteOrderCommentRatingStatus.success,
          ),
        );
      },
    );
  }

  FutureOr<void> _onUpdateLikeCommentEvent(
    UpdateLikeCommentEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (state.updateLikeCommentRatingStatus ==
        UpdateLikeCommentRatingStatus.loading) {
      return;
    }
    emit(
      state.copyWith(
        tapCommentIndex: event.tapCommentIndex,
        likeForReplayComment: event.fromReplayComments,
        updateLikeCommentRatingStatus: UpdateLikeCommentRatingStatus.loading,
      ),
    );

    final response = await updateLikeCommentUseCase(
      UpdateLikeCommentParams(
        commentId: event.commentId,
        productId: event.productId,
        toLike: event.toAddLike,
        type: event.fromReplayComments ? "seller_reply" : "comment",
      ),
    );
    response.fold(
      (l) {
        emit(
          state.copyWith(
            tapCommentIndex: -1,
            updateLikeCommentRatingStatus:
                UpdateLikeCommentRatingStatus.failure,
            statusCodeOfCommentProcess: l.statusCode.toString(),
          ),
        );
        if (ErrorManager.shouldRetry('UpdateLikeCommentEvent', l.statusCode)) {
          ErrorManager.incrementRetry('UpdateLikeCommentEvent');
          add(
            UpdateLikeCommentEvent(
              commentId: event.commentId,
              fromBuyerComments: event.fromBuyerComments,
              fromReplayComments: event.fromReplayComments,
              toAddLike: event.toAddLike,
              productId: event.productId,
              currentFilter: event.currentFilter,
              tapCommentIndex: event.tapCommentIndex,
            ),
          );
        }

        if (l.statusCode == 401) {
          // showMessage(LocaleKeys.must_login_to_edit_comment.tr());
        } else {
          showMessage(l.message);
        }
      },
      (r) {
        ErrorManager.resetRetry('UpdateLikeCommentEvent');
        add(
          UpdateLikeSocialSharedProductsEvent(productId: event.productId ?? ""),
        );
        Map<String, PaginationModel<FqaComment>> getFqaCommentsPaginationModel =
            Map.of(state.getFqaCommentsPaginationModel ?? {});
        Map<String, PaginationModel<BuyersComment>>
        getBuyersCommentsPaginationModel = Map.of(
          state.getBuyersCommentsPaginationModel ?? {},
        );
        showMessage(r.message ?? "");
        if (event.fromBuyerComments) {
          List<BuyersComment> buyersCommentItems =
              getBuyersCommentsPaginationModel[event.currentFilter]?.items ??
              [];
          int index = buyersCommentItems.indexWhere(
            (element) => element.id == event.commentId,
          );
          if (index != -1) {
            BuyersComment buyersComment = buyersCommentItems.removeAt(index);
            buyersCommentItems.insert(
              index,
              buyersComment.copyWith(
                isLiked: event.toAddLike,
                totalLikes: event.toAddLike
                    ? ((buyersComment.totalLikes ?? 0) + 1)
                    : ((buyersComment.totalLikes ?? 0) - 1),
              ),
            );
          }

          getBuyersCommentsPaginationModel[event.currentFilter] =
              getBuyersCommentsPaginationModel[event.currentFilter]!.copyWith(
                paginationStatus: PaginationStatus.success,
                items: buyersCommentItems,
              );
        } else {
          List<FqaComment> fqaCommentItems =
              getFqaCommentsPaginationModel[event.currentFilter]?.items ?? [];
          int index = fqaCommentItems.indexWhere(
            (element) => element.id == event.commentId,
          );
          if (index != -1) {
            FqaComment fqaComment = fqaCommentItems.removeAt(index);
            fqaCommentItems.insert(
              index,
              fqaComment.copyWith(
                isLiked: event.fromReplayComments
                    ? fqaComment.isLiked
                    : event.toAddLike,
                totalLikes: event.fromReplayComments
                    ? fqaComment.totalLikes
                    : event.toAddLike
                    ? ((fqaComment.totalLikes ?? 0) + 1)
                    : ((fqaComment.totalLikes ?? 0) - 1),
                replyIsLiked: !event.fromReplayComments
                    ? fqaComment.replyIsLiked
                    : event.toAddLike,
                replyTotalLikes: !event.fromReplayComments
                    ? fqaComment.replyTotalLikes
                    : event.toAddLike
                    ? ((fqaComment.replyTotalLikes ?? 0) + 1)
                    : ((fqaComment.replyTotalLikes ?? 0) - 1),
              ),
            );
          }

          getFqaCommentsPaginationModel[event.currentFilter] =
              getFqaCommentsPaginationModel[event.currentFilter]!.copyWith(
                paginationStatus: PaginationStatus.success,
                items: fqaCommentItems,
              );
        }
        emit(
          state.copyWith(
            getBuyersCommentsPaginationModel: getBuyersCommentsPaginationModel,
            getFqaCommentsPaginationModel: getFqaCommentsPaginationModel,
            updateLikeCommentRatingStatus:
                UpdateLikeCommentRatingStatus.success,
          ),
        );
      },
    );
  }

  FutureOr<void> _onTranslateCommentEvent(
    TranslateCommentEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        translateCommentStatus: TranslateCommentStatus.loading,
        tapCommentIndex: event.tapCommentIndex,
      ),
    );

    if (event.showOriginal ?? false) {
      await Future.delayed(const Duration(milliseconds: 300));
      Map<String, PaginationModel<FqaComment>> getFqaCommentsPaginationModel =
          Map.of(state.getFqaCommentsPaginationModel ?? {});
      Map<String, PaginationModel<BuyersComment>>
      getBuyersCommentsPaginationModel = Map.of(
        state.getBuyersCommentsPaginationModel ?? {},
      );

      if (event.fromBuyerComments) {
        List<BuyersComment> buyersCommentItems =
            getBuyersCommentsPaginationModel[event.currentFilter]?.items ?? [];
        int index = buyersCommentItems.indexWhere(
          (element) => element.id == event.commentId,
        );
        if (index != -1) {
          BuyersComment buyersComment = buyersCommentItems.removeAt(index);
          buyersCommentItems.insert(
            index,
            buyersComment.copyWith(isTran: false),
          );
        }

        getBuyersCommentsPaginationModel[event.currentFilter] =
            getBuyersCommentsPaginationModel[event.currentFilter]!.copyWith(
              paginationStatus: PaginationStatus.success,
              items: buyersCommentItems,
            );
      } else {
        List<FqaComment> fqaCommentItems =
            getFqaCommentsPaginationModel[event.currentFilter]?.items ?? [];
        int index = fqaCommentItems.indexWhere(
          (element) => element.id == event.commentId,
        );
        if (index != -1) {
          FqaComment fqaComment = fqaCommentItems.removeAt(index);
          fqaCommentItems.insert(index, fqaComment.copyWith(isTran: false));
        }

        getFqaCommentsPaginationModel[event.currentFilter] =
            getFqaCommentsPaginationModel[event.currentFilter]!.copyWith(
              paginationStatus: PaginationStatus.success,
              items: fqaCommentItems,
            );
      }
      emit(
        state.copyWith(
          getBuyersCommentsPaginationModel: getBuyersCommentsPaginationModel,
          getFqaCommentsPaginationModel: getFqaCommentsPaginationModel,
          translateCommentStatus: TranslateCommentStatus.success,
        ),
      );

      return;
    }
    final response = await translateCommentUsecase(
      TranslateCommentParam(
        commentId: event.commentId,
        isSeller: event.fromSellerComments,
      ),
    );
    response.fold(
      (l) {
        if (l.statusCode == 401) {
          //  showMessage(LocaleKeys.must_login_to_edit_comment.tr());
        } else {
          showMessage(l.message);
        }

        emit(
          state.copyWith(
            translateCommentStatus: TranslateCommentStatus.failure,
            statusCodeOfCommentProcess: l.statusCode.toString(),
          ),
        );
      },
      (r) {
        ErrorManager.resetRetry('TranslateCommentEvent');
        if (kDebugMode)
          devLog(
            "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF${event.fromSellerComments}           ${r.translatedText}",
          );
        Map<String, PaginationModel<FqaComment>> getFqaCommentsPaginationModel =
            Map.of(state.getFqaCommentsPaginationModel ?? {});
        Map<String, PaginationModel<BuyersComment>>
        getBuyersCommentsPaginationModel = Map.of(
          state.getBuyersCommentsPaginationModel ?? {},
        );

        if (event.fromBuyerComments) {
          List<BuyersComment> buyersCommentItems =
              getBuyersCommentsPaginationModel[event.currentFilter]?.items ??
              [];
          int index = buyersCommentItems.indexWhere(
            (element) => element.id == event.commentId,
          );
          if (index != -1) {
            BuyersComment buyersComment = buyersCommentItems.removeAt(index);
            buyersCommentItems.insert(
              index,
              buyersComment.copyWith(
                commentTran: r.translatedText,
                isTran: true,
              ),
            );
          }

          getBuyersCommentsPaginationModel[event.currentFilter] =
              getBuyersCommentsPaginationModel[event.currentFilter]!.copyWith(
                paginationStatus: PaginationStatus.success,
                items: buyersCommentItems,
              );
        } else {
          List<FqaComment> fqaCommentItems =
              getFqaCommentsPaginationModel[event.currentFilter]?.items ?? [];
          int index = fqaCommentItems.indexWhere(
            (element) => element.id == event.commentId,
          );
          if (index != -1) {
            FqaComment fqaComment = fqaCommentItems.removeAt(index);
            fqaCommentItems.insert(
              index,
              fqaComment.copyWith(
                commentTran: !event.fromSellerComments
                    ? r.translatedText
                    : fqaComment.commentTran,
                isTran: true,
                sellerReplyTran: event.fromSellerComments
                    ? r.translatedText
                    : fqaComment.sellerReplyTran,
              ),
            );
          }

          getFqaCommentsPaginationModel[event.currentFilter] =
              getFqaCommentsPaginationModel[event.currentFilter]!.copyWith(
                paginationStatus: PaginationStatus.success,
                items: fqaCommentItems,
              );
        }
        emit(
          state.copyWith(
            getBuyersCommentsPaginationModel: getBuyersCommentsPaginationModel,
            getFqaCommentsPaginationModel: getFqaCommentsPaginationModel,
            translateCommentStatus: TranslateCommentStatus.success,
          ),
        );
        if (event.fromSellerComments) {
          add(
            TranslateCommentEvent(
              commentId: event.commentId,
              showOriginal: event.showOriginal,
              currentFilter: event.currentFilter,
              fromBuyerComments: event.fromBuyerComments,
              tapCommentIndex: event.tapCommentIndex,
            ),
          );
        }
      },
    );
  }

  FutureOr<void> _onReportAboutStoryEvent(
    ReportAboutStoryEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(reportingAboutStory: ReportingAboutStory.loading));

    final result = await reportAboutStoryUseCase(
      ReportAboutStoryParams(
        userId: event.userId,
        storyId: event.storyId,
        reasons: event.reasons,
        notes: event.notes,
      ),
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            reportingAboutStory: ReportingAboutStory.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (response) {
        emit(state.copyWith(reportingAboutStory: ReportingAboutStory.success));
      },
    );
  }

  FutureOr<void> _onDeliveredOrdersResponseEvent(
    DeliveredOrdersResponseEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        getDeliveredOrdersResponseStatus:
            GetDeliveredOrdersResponseStatus.loading,
      ),
    );

    final result = await getDeliveredOrdersResponseUseCase(event.productId);
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            getDeliveredOrdersResponseStatus:
                GetDeliveredOrdersResponseStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (response) {
        emit(
          state.copyWith(
            getDeliveredOrdersResponseStatus:
                GetDeliveredOrdersResponseStatus.success,
            deliveredOrdersResponse: response,
          ),
        );
      },
    );
  }

  /// تفاصيل منتج لعمود واحد في صفحة المقارنة.
  ///
  /// مستقلّ عن [_onGetFullProductDetailsEvent] عمداً: ذاك يُطلق منتجات مرتبطة
  /// وطلبات مُسلَّمة وحدثاً في ChatBloc ويعيد بناء مزامنة ألوان الصور — وكلّها
  /// آثار جانبية تخصّ شاشة تفاصيل المنتج ولا محلّ لها هنا، بل تُفسد حالتها.
  FutureOr<void> _onGetProductDetailsForCompareEvent(
    GetProductDetailsForCompareEvent event,
    Emitter<HomeState> emit,
  ) async {
    // تسجيل المُعرِّف والترتيب هنا أيضاً: هذا الحدث يصل من صفحة المقارنة
    // مباشرةً (اختيار من البحث) لا من زرّ التفاصيل وحده، ولولاه لبقي الزرّ
    // في صفحة التفاصيل بلا لون رغم أن المنتج في المقارنة.
    final Map<int, String> slugs = Map<int, String>.of(state.compareSlugs);
    slugs[event.side] = event.productSlug;
    final List<int> order = List<int>.of(state.compareOrder)
      ..remove(event.side)
      ..add(event.side);
    emit(state.copyWith(compareSlugs: slugs, compareOrder: order));

    _emitCompareStatus(
      emit,
      event.side,
      GetCompareProductDetailsStatus.loading,
    );

    final response = await getFullProductDetailsUseCase(event.productSlug);

    response.fold(
      (l) => _emitCompareStatus(
        emit,
        event.side,
        GetCompareProductDetailsStatus.failure,
      ),
      (r) {
        final Products? item = r.productItem;
        if (item == null) {
          _emitCompareStatus(
            emit,
            event.side,
            GetCompareProductDetailsStatus.failure,
          );
          return;
        }
        final Map<int, Products> products = Map<int, Products>.of(
          state.compareProducts,
        );
        products[event.side] = item;
        _emitCompareStatus(
          emit,
          event.side,
          GetCompareProductDetailsStatus.success,
          products: products,
        );
      },
    );
  }

  FutureOr<void> _onClearCompareProductEvent(
    ClearCompareProductEvent event,
    Emitter<HomeState> emit,
  ) {
    emit(
      state.copyWith(
        compareProducts: Map<int, Products>.of(state.compareProducts)
          ..remove(event.side),
        compareProductDetailsStatus:
            Map<int, GetCompareProductDetailsStatus>.of(
              state.compareProductDetailsStatus,
            )..remove(event.side),
        compareSlugs: Map<int, String>.of(state.compareSlugs)
          ..remove(event.side),
        compareOrder: List<int>.of(state.compareOrder)..remove(event.side),
      ),
    );
  }

  /// إضافة/إزالة منتج من المقارنة بضغطة واحدة.
  ///
  /// يحجز العمود ويسجّل المُعرِّف **فوراً** ثم يجلب التفاصيل، فيتلوّن الزرّ في
  /// اللحظة نفسها بدل انتظار الشبكة.
  FutureOr<void> _onToggleCompareProductEvent(
    ToggleCompareProductEvent event,
    Emitter<HomeState> emit,
  ) {
    final Map<int, String> slugs = Map<int, String>.of(state.compareSlugs);

    // موجود؟ إزالة.
    for (final MapEntry<int, String> entry in slugs.entries) {
      if (entry.value == event.productSlug) {
        add(ClearCompareProductEvent(entry.key));
        return null;
      }
    }

    final List<int> order = List<int>.of(state.compareOrder);
    final Map<int, Products> products = Map<int, Products>.of(
      state.compareProducts,
    );
    final Map<int, GetCompareProductDetailsStatus> statuses =
        Map<int, GetCompareProductDetailsStatus>.of(
          state.compareProductDetailsStatus,
        );

    // العمود الهدف: أول فارغ، وإلا الأقدم استعمالاً.
    final int side;
    if (!slugs.containsKey(0)) {
      side = 0;
    } else if (!slugs.containsKey(1)) {
      side = 1;
    } else {
      side = order.isNotEmpty ? order.first : 0;
      order.remove(side);
    }

    slugs[side] = event.productSlug;
    products.remove(side); // تفاصيل المنتج السابق لم تعد تخصّ هذا العمود
    statuses[side] = GetCompareProductDetailsStatus.loading;
    order.add(side);

    emit(
      state.copyWith(
        compareSlugs: slugs,
        compareProducts: products,
        compareProductDetailsStatus: statuses,
        compareOrder: order,
      ),
    );

    add(
      GetProductDetailsForCompareEvent(
        productSlug: event.productSlug,
        side: side,
      ),
    );
    return null;
  }

  /// يكتب حالة عمود واحد دون المساس بالآخر. نسخ الخريطة ضروري: تعديلها في
  /// مكانها يجعل Equatable يرى الحالتين متطابقتين فيُسقط الانبعاث.
  void _emitCompareStatus(
    Emitter<HomeState> emit,
    int side,
    GetCompareProductDetailsStatus status, {
    Map<int, Products>? products,
  }) {
    final Map<int, GetCompareProductDetailsStatus> statuses =
        Map<int, GetCompareProductDetailsStatus>.of(
          state.compareProductDetailsStatus,
        );
    statuses[side] = status;
    emit(
      state.copyWith(
        compareProductDetailsStatus: statuses,
        compareProducts: products ?? state.compareProducts,
      ),
    );
  }
}
