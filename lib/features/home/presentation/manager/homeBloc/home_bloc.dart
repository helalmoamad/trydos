import 'dart:async';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_smartlook/flutter_smartlook.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/app_elvated_button.dart';
import 'package:trydos/features/app/my_text_widget.dart';

import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/home/data/models/get_cart_item_model.dart';
import 'package:trydos/features/home/data/models/get_comment_for_product_model.dart';
import 'package:trydos/features/home/data/models/get_old_cart_model.dart'
    as oldCart;
import 'package:trydos/features/home/data/models/get_product_detail_without_related_products_model.dart';
import 'package:trydos/features/home/data/models/get_product_filters_model.dart'
    as filters_model;
import 'package:trydos/features/home/data/models/get_product_listing_with_filters_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart';
import 'package:trydos/features/home/data/models/popular_search_terms_model.dart';
import 'package:trydos/features/home/data/models/starting_settings_response_model.dart';
import 'package:trydos/features/home/domain/use_cases/GetCommentForProductUseCase.dart';
import 'package:trydos/features/home/domain/use_cases/add_comment_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/add_like_to_product_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/change_country_language_for_notification_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/convert_item_from_oldCart_to_Cart_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/delete_like_of_product_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_allowed_country_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_cart_item_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_colors_sizes_for_search_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_count_view_of_product_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_currency_for_country_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_full_product_details_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_my_firebase_settings_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_notification_type_for_product_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_old_cart_item_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_popular_search_terms_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_product_detail_without_related_products_uswcase.dart';
import 'package:trydos/features/home/domain/use_cases/get_product_list_in_cart_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_products_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_starting_settings_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/hide_item_from_oldCart_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/remove_item_from_cart_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/request_for_notification_when_product_became_available_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/send_error_to_mobile_error_log.dart';
import 'package:trydos/features/home/domain/use_cases/store_fcm_token_of_market_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/subscribe_topic_for_notification_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/un_subscribe_topic_for_notification_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/update_email_notification_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/update_firebase_notification_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/update_item_from_cart_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/update_notification_frequency_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/update_profile_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/update_whatsapp_notification_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/upload_user_photo_usecase.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_bloc.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_event.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_sheet_bottom_bar.dart';
import 'package:trydos/features/story/domain/useCases/get_width_and_height_usecase.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/notification_service/notification_service/handle_notification/notification_process.dart';
import 'package:uuid/uuid.dart';
import '../../../../../common/helper/helper_functions.dart';
import '../../../../../core/data/model/pagination_model.dart';
import '../../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../../main.dart';
import '../../../../../service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../../../service/firebase_analytics_service/analytics_const/analytics_executed_event_name.dart';
import '../../../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../../../chat/presentation/manager/chat_bloc.dart';
import '../../../../chat/presentation/manager/chat_event.dart';
import '../../../data/models/get_user_notifications_model.dart';
import '../../../domain/use_cases/add_item_to_cart_usecase.dart';

import '../../../domain/use_cases/check_availability_product_cart_usecase.dart';
import '../../../domain/use_cases/get_cart_overview_usecase.dart';
import '../../../domain/use_cases/get_stories_for_product_usecase.dart';
import '../../../domain/use_cases/get_user_notification_usecase.dart';
import 'home_event.dart';

import 'home_state.dart';

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
    this.getStoryUseCase,
    this.removeItemToCartUseCase,
    this.convertItemFromOldcartToCartUsecase,
    this.getCartItemUseCase,
    this.getOldCartItemUseCase,
    this.storeFcmTokenOfMarketUseCase,
    // this.getBrandUseCase,
    //  this.getCategoryUseCase,
    this.deleteLikeOfProductUsecase,
    this.addLikeToProductUsecase,
    this.updateItemInCartUseCase,
    this.addItemToCartUseCase,
    this.getCommentForProductUseCase,
    this.getProductsListInCartUseCase,
    this.updateProfileUseCase,
    this.getAllowedCountryUseCase,
    this.getNotificationTypeProductUseCase,
    this.getWidthAndHeightUseCase,
    this.getMyFirebaseSettingsUseCase,
    this.updateEmailNotificationUseCase,
    this.updateFirebaseNotificationUseCase,
    this.updateNotificationFrequencyUseCase,
    this.updateWhatsappNotificationUseCase,
    this.changeCountryLanguageFornotificationUseCase,
    this.subscribeTopicFornotificationUseCase,
    this.unSubscribeTopicFornotificationUseCase,
    this.getProductDetailWithoutRelatedProductsUseCase,
    this.getStartingSettingsUseCase,
    this.getPopularSearchItemUseCase,
    this.uploadFileCloudinaryUseCase,
    this.getCurrencyForCountryUseCase,
    this.hideItemsInOldCartUseCase,
    this.getFullProductDetailsUseCase,
    //this.getCustomerInfoUseCase,
    this.getAndAddCountViewOfProductUsecase,
    this.sendErrorToMobileErrorLogUseCase,
    this.getProductsWithoutFiltersUseCase,
    this.getColorsAndSizesForSearchUseCase,
    this.addCommentUseCase,
    this.requestForNotificationWhenProductBecameAvailableUseCase,
    this.checkAvailabilityProductCartUsecase,
    this.getCartOverviewUseCase,
    this.getUserNotificationUseCase,
  ) : super(HomeState()) {
    on<HomeEvent>((event, emit) {});

    on<GetAndAddCountViewOfProductEvent>(
      _onGetAndAddCountViewOfProductEvent,
    );

    on<IsChangedVariationWhenQtyZeroEvent>(
      _onIsChangedvariationWhenQtyZeroEvent,
    );

    on<IsChangedColorBeforOpenPanelEvent>(
      _onIsChangedColorBeforOpenPanelEvent,
    );

    on<SaveUserInfoFromAuthEvent>(
      _onSaveUserInfoEvent,
    );

    on<UpdateProfileEvent>(
      _onUpdateProfileEvent,
    );

    on<UploadUserPhotoCloudinaryEvent>(_onUploadUserPhptoCloudinaryEvent);

    on<ChangeStatusOFGetProductsDetailsToSuccessEvent>(
      _onChangeStatusOFGetProductsDetailsToSuccessEvent,
    );

    on<GetNotificationTypeProductEvent>(_onGetNotificationTypeProductEvent);

    on<ClearAllAppCashEvent>(
      _onClearAllAppCashEvent,
    );

    on<GetCurrencyForCountryEvent>(
      _onGetCurrencyForCountryEvent,
    );
    on<AddCurrentColorSizeEvent>(
      _onAddCurrentSizeColorEvent,
    );
    on<AddCurrentSelectedColorEvent>(
      _onAddCurrentSelectedColorEvent,
    );

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

    on<UpdateListOfItemForAddToCartEvent>(
      _onUpdateListOfItemForAddToCartEvent,
    );
    on<GetProductsListInCartEvent>(_onGetProductsListInCartEventEvent,
        transformer: restartable());
    on<SendErrorToMobileErrorLogEvent>(
      _onSendErrorToMobileErrorLogEvent,
    );

    on<RequestForNotificationWhenProductBecameAvailableEvent>(
      _onRequestForNotificationWhenProductBecameAvailableEvent,
    );
    on<StoreFcmTokenOfMarketEvent>(
      _onStoreFcmTokenOfMarketEvent,
    );
    on<UpdateEmailNotificationEvent>(
      _onUpdateEmailNotificationEvent,
    );
    on<UpdateFirebaseNotificationEvent>(
      _onUpdateFirebaseNotificationEvent,
    );
    on<UpdateNotificationFrequencyEvent>(
      _onUpdateNotificationFrequencyEvent,
    );
    on<UpdateWhatsappNotificationEvent>(
      _onUpdateWhatsappNotificationEvent,
    );
    on<AddQuantityForCartEvent>(
      _onAddCurrentQuantityForCartEvent,
    );

    on<CheckWithGetCartEvent>(
      _onCheckWithGetCartEvent,
    );

    on<AddOrRemoveLikeForProductEvent>(_onAddOrRemoveLikeForProductEvent,
        transformer: throttleDroppable(Duration(seconds: 3)));

    on<AddSearchTextToHistoryEvent>(
      _onAddSearchTextToHistoryEvent,
    );

    on<GetCartItemEvent>(_onGetCartItemEvent, transformer: restartable());

    on<GetAllowedCountriesEvent>(_onGetAllowedCountriesEvent,
        transformer: throttleDroppable(throttleDuration));

    on<GetStartingSettingsEvent>(
      _onGetStartingSettingsEvent,
    );

    on<AddItemToCartEvent>(
      _onAddItemToCartEvent,
    );

    on<ChangeCurrentIndexForUpdatCartEvent>(
      _onChangeCurrentIndexForUpdatCartEvent,
    );

    on<AddMultiItemsToCartEvent>(
      _onAddMultiItemsToCartEvent,
    );
    on<AddTimerStartedToHurryUpEvent>(
      _onAddTimerStartedToHurryUpEvent,
    );

    on<UpdateItemInCartEvent>(
      _onUpdateItemInCartEvent,
    );
    on<RemoveSearchTextfromHistoryEvent>(
      _onRemoveSearchTextToHistoryEvent,
    );
    on<HideItemInOldCartEvent>(
      _onHideItemInOldCartEvent,
    );

    on<GetStoryForProductEvent>(
      _onGetStoryEvent,
      transformer: throttleDroppable(
        Duration(seconds: 5),
      ),
    );

    on<AddProductItemForCartEvent>(
      _onAddProductItemForCartEvent,
    );

    on<AddSizesForColorsEvent>(
      _onAddSizesForColorsEvent,
    );
    on<GetOldCartItemEvent>(_onGetOldCartItemEvent, transformer: restartable());

    on<RemoveItemFormCartEvent>(
      _onRemoveItemToCartEvent,
    );

    on<AddCommentEvent>(
      _onAddCommentEvent,
    );
    on<GetPopularSearchItemEvent>(
      _onGetPopularSearchItemEvent,
    );

    on<GetProductDatailsWithoutRelatedProductsEvent>(
        _onGetProductDatailsWithoutRelatedProductsEvent,
        transformer: restartable());

    on<GetFullProductDetailsEvent>(
      _onGetFullProductDetailsEvent,
    );

    on<ConvertItemFromCartToOldCartEvent>(
      _onConvertItemFromCartToOldCartEvent,
    );
    on<GetCommentForProductEvent>(
      _onGetCommentForProductEvent,
    );
    on<GeColorsAndSizesForSearchEvent>(
      _onGeColorsAndSizesForSearchEvent,
    );

    on<RemoveItemsFromCartAfterOrderSuccessEvent>(
      _onRemoveItemsFromCartAfterOrderSuccessEvent,
    );
    on<CheckAvailabilityProductCartEvent>(
      _onCheckAvailabilityProductCartEvent,
    );
    on<GetCartOverviewEvent>(
      _onGetCartOverviewEvent,
      transformer: restartable(),
    );

    on<GetUserNotificationEvent>(
      _onGetUserNotificationEvent,
    );
  }

  Map<String, bool> boutiquesThatEnablesToRequestItsProductsUsingFiveFilters =
      {};
  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  final GetStartingSettingsUseCase getStartingSettingsUseCase;

  final GetWidthAndHeightUseCase getWidthAndHeightUseCase;
  final UpdateUserPhotoUseCase uploadFileCloudinaryUseCase;

  final GetCartItemUseCase getCartItemUseCase;
  final GetCartOverviewUseCase getCartOverviewUseCase;
  final GetOldCartItemUseCase getOldCartItemUseCase;
  final GetNotificationTypeProductUseCase getNotificationTypeProductUseCase;
  final ConvertItemFromOldcartToCartUsecase convertItemFromOldcartToCartUsecase;
  final GetAndAddCountViewOfProductUsecase getAndAddCountViewOfProductUsecase;
  final AddCommentUseCase addCommentUseCase;
  final GetProductsListInCartUseCase getProductsListInCartUseCase;
  final SendErrorToMobileErrorLogUseCase sendErrorToMobileErrorLogUseCase;
  final StoreFcmTokenOfMarketUseCase storeFcmTokenOfMarketUseCase;
  final GetCommentForProductUseCase getCommentForProductUseCase;
  final GetStoryForProductUseCase getStoryUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  // final GetCustomerInfoUseCase getCustomerInfoUseCase;
  final GetProductDetailWithoutRelatedProductsUseCase
      getProductDetailWithoutRelatedProductsUseCase;

  final GetPopularSearchItemUseCase getPopularSearchItemUseCase;
  final GetCurrencyForCountryUseCase getCurrencyForCountryUseCase;
  final RequestForNotificationWhenProductBecameAvailableUseCase
      requestForNotificationWhenProductBecameAvailableUseCase;
  final AddLikeToProductUsecase addLikeToProductUsecase;
  final DeleteLikeOfProductUsecase deleteLikeOfProductUsecase;

  final RemoveItemToCartUseCase removeItemToCartUseCase;

  final GetProductsWithoutFiltersUseCase getProductsWithoutFiltersUseCase;
  final AddItemToCartUseCase addItemToCartUseCase;
  final UpdateEmailNotificationUseCase updateEmailNotificationUseCase;
  final UpdateFirebaseNotificationUseCase updateFirebaseNotificationUseCase;
  final UpdateWhatsappNotificationUseCase updateWhatsappNotificationUseCase;
  final UpdateNotificationFrequencyUseCase updateNotificationFrequencyUseCase;
  final UpdateItemInCartUseCase updateItemInCartUseCase;
  final HideItemsInOldCartUseCase hideItemsInOldCartUseCase;
  final GetAllowedCountryUseCase getAllowedCountryUseCase;
  final GetFullProductDetailsUseCase getFullProductDetailsUseCase;
  final GetColorsAndSizesForSearchUseCase getColorsAndSizesForSearchUseCase;
  final CheckAvailabilityProductCartUsecase checkAvailabilityProductCartUsecase;

  final SubscribeTopicFornotificationUseCase
      subscribeTopicFornotificationUseCase;
  final UnSubscribeTopicFornotificationUseCase
      unSubscribeTopicFornotificationUseCase;
  final ChangeCountryLanguageFornotificationUseCase
      changeCountryLanguageFornotificationUseCase;
  final GetMyFirebaseSettingsUseCase getMyFirebaseSettingsUseCase;

  final GetUserNotificationUseCase getUserNotificationUseCase;

  final Smartlook smartLook = Smartlook.instance;

  FutureOr<void> _onGetStartingSettingsEvent(
      GetStartingSettingsEvent event, Emitter<HomeState> emit) async {
    //  if (apisMustNotToRequest.contains('GetStartingSettingsEvent')) return;
    emit(state.copyWith(
        getStartingSettingsStatus: GetStartingSettingsStatus.loading));
    final response = await getStartingSettingsUseCase(NoParams());

    response.fold((l) {
      if (!isFailedTheFirstTime.contains('GetStartingSettingsEvent')) {
        add(GetStartingSettingsEvent());
        isFailedTheFirstTime.add('GetStartingSettingsEvent');
      }
      emit(state.copyWith(
          getStartingSettingsStatus: GetStartingSettingsStatus.failure));
    }, (r) {
      apisMustNotToRequest.add('GetStartingSettingsEvent');
      isFailedTheFirstTime.remove('GetStartingSettingsEvent');

      emit(state.copyWith(
          startingSetting: r.data!.startingSetting,
          getStartingSettingsStatus: GetStartingSettingsStatus.success));
    });
  }

  FutureOr<void> _onIsChangedvariationWhenQtyZeroEvent(
      IsChangedVariationWhenQtyZeroEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(
        isChangedvariationWhenQtyZero: event.isChangedVariationWhenQtyZero));
  }

  FutureOr<void> _onIsChangedColorBeforOpenPanelEvent(
      IsChangedColorBeforOpenPanelEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(
        isChangedColorBeforeOpenPanel: event.iChangedColorBeforOpenPanelEvent));
  }

  FutureOr<void> _onRemoveItemsFromCartAfterOrderSuccessEvent(
      RemoveItemsFromCartAfterOrderSuccessEvent event,
      Emitter<HomeState> emit) async {
    emit(state.copyWith(
      cartCollection: [],
      currentQuantityForCart: {},
      addImagesToProductIdForCart: {},
      addVariationToCartId: {},
      listitemForAddToCart: [],
    ));
  }

  FutureOr<void> _onUpdateWhatsappNotificationEvent(
      UpdateWhatsappNotificationEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(
        updateWhatsappNotificationStatus:
            UpdateWhatsappNotificationStatus.loading));
    final response = await updateWhatsappNotificationUseCase(
        UpdateWhatsappNotificationParams(whatsapp: event.whatsapp));

    response.fold((l) {
      if (!isFailedTheFirstTime.contains('UpdateWhatsappNotificationEvent')) {
        if (prefsRepository.isTokenExpired ?? false) {
          Future.delayed(
              Duration(seconds: 5),
              () => add(
                  UpdateWhatsappNotificationEvent(whatsapp: event.whatsapp)));
        } else {
          add(UpdateWhatsappNotificationEvent(whatsapp: event.whatsapp));
        }
        isFailedTheFirstTime.add('UpdateWhatsappNotificationEvent');
      }
      emit(state.copyWith(
          updateWhatsappNotificationStatus:
              UpdateWhatsappNotificationStatus.failure));
    }, (r) async {
      isFailedTheFirstTime.remove('UpdateWhatsappNotificationEvent');
      emit(state.copyWith(
        firebaseSettingForNotificationModel: r,
        updateWhatsappNotificationStatus:
            UpdateWhatsappNotificationStatus.success,
      ));
    });
  }

  FutureOr<void> _onUpdateEmailNotificationEvent(
      UpdateEmailNotificationEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(
        updateEmailappNotificationStatus:
            UpdateEmailappNotificationStatus.loading));
    final response = await updateEmailNotificationUseCase(
        UpdateEmailNotificationParams(email: event.email));

    response.fold((l) {
      if (!isFailedTheFirstTime.contains('UpdateEmailNotificationEvent')) {
        if (prefsRepository.isTokenExpired ?? false) {
          Future.delayed(Duration(seconds: 5),
              () => add(UpdateEmailNotificationEvent(email: event.email)));
        } else {
          add(UpdateEmailNotificationEvent(email: event.email));
        }
        isFailedTheFirstTime.add('UpdateEmailNotificationEvent');
      }
      emit(state.copyWith(
          updateEmailappNotificationStatus:
              UpdateEmailappNotificationStatus.failure));
      showMessage(l.message,
          foreGroundColor: Colors.white,
          backGroundColor: Colors.black,
          showInRelease: true,
          timeShowing: Toast.LENGTH_LONG);
    }, (r) async {
      isFailedTheFirstTime.remove('UpdateEmailNotificationEvent');
      emit(state.copyWith(
        firebaseSettingForNotificationModel: r,
        updateEmailappNotificationStatus:
            UpdateEmailappNotificationStatus.success,
      ));
    });
  }

  FutureOr<void> _onUpdateFirebaseNotificationEvent(
      UpdateFirebaseNotificationEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(
        getFirebaseSettingForNotificationStatus:
            GetFirebaseSettingForNotificationStatus.loading));
    final response = await updateFirebaseNotificationUseCase(
        UpdateFirebaseNotificationParams(firebase: event.firebase));

    response.fold((l) {
      if (!isFailedTheFirstTime.contains('UpdateFirebaseNotificationEvent')) {
        if (prefsRepository.isTokenExpired ?? false) {
          Future.delayed(
              Duration(seconds: 5),
              () => add(
                  UpdateFirebaseNotificationEvent(firebase: event.firebase)));
        } else {
          add(UpdateFirebaseNotificationEvent(firebase: event.firebase));
        }
        isFailedTheFirstTime.add('UpdateFirebaseNotificationEvent');
      }
      emit(state.copyWith(
          getFirebaseSettingForNotificationStatus:
              GetFirebaseSettingForNotificationStatus.failure));
    }, (r) async {
      isFailedTheFirstTime.remove('UpdateFirebaseNotificationEvent');
      emit(state.copyWith(
        firebaseSettingForNotificationModel: r,
        getFirebaseSettingForNotificationStatus:
            GetFirebaseSettingForNotificationStatus.success,
      ));
    });
  }

  FutureOr<void> _onUpdateNotificationFrequencyEvent(
      UpdateNotificationFrequencyEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(
        getFirebaseSettingForNotificationStatus:
            GetFirebaseSettingForNotificationStatus.loading));
    final response = await updateNotificationFrequencyUseCase(
        UpdateNotificationFrequencyParams(
            notificationFrequency: event.notificationFrequency));

    response.fold((l) {
      if (!isFailedTheFirstTime.contains('UpdateNotificationFrequencyEvent')) {
        if (prefsRepository.isTokenExpired ?? false) {
          Future.delayed(
              Duration(seconds: 5),
              () => add(UpdateNotificationFrequencyEvent(
                  notificationFrequency: event.notificationFrequency)));
        } else {
          add(UpdateNotificationFrequencyEvent(
              notificationFrequency: event.notificationFrequency));
        }
        isFailedTheFirstTime.add('UpdateNotificationFrequencyEvent');
      }
      emit(state.copyWith(
          getFirebaseSettingForNotificationStatus:
              GetFirebaseSettingForNotificationStatus.failure));
    }, (r) async {
      isFailedTheFirstTime.remove('UpdateNotificationFrequencyEvent');
      emit(state.copyWith(
        firebaseSettingForNotificationModel: r,
        getFirebaseSettingForNotificationStatus:
            GetFirebaseSettingForNotificationStatus.success,
      ));
    });
  }

  FutureOr<void> _onSubscribeTopicForNotificationEvent(
      SubscribeTopicForNotificationEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(
        getFirebaseSettingForNotificationStatus:
            GetFirebaseSettingForNotificationStatus.loading));
    final response = await subscribeTopicFornotificationUseCase(
        SubscribeTopicForNotificationParams(
            topic: event.topic, variant: event.variant));

    response.fold((l) {
      if (!isFailedTheFirstTime
          .contains('SubscribeTopicForNotificationEvent')) {
        if (prefsRepository.isTokenExpired ?? false) {
          Future.delayed(
              Duration(seconds: 5),
              () => add(SubscribeTopicForNotificationEvent(
                  topic: event.topic, variant: event.variant)));
        } else {
          add(SubscribeTopicForNotificationEvent(
              topic: event.topic, variant: event.variant));
        }
        isFailedTheFirstTime.add('SubscribeTopicForNotificationEvent');
      }
      emit(state.copyWith(
          getFirebaseSettingForNotificationStatus:
              GetFirebaseSettingForNotificationStatus.failure));
    }, (r) async {
      isFailedTheFirstTime.remove('SubscribeTopicForNotificationEvent');
      emit(state.copyWith(
        firebaseSettingForNotificationModel: r,
        getFirebaseSettingForNotificationStatus:
            GetFirebaseSettingForNotificationStatus.success,
      ));
    });
  }

  FutureOr<void> _onGeColorsAndSizesForSearchEvent(
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
  }

  FutureOr<void> _onGetFirebaseSettingForNotificationEvent(
      GetFirebaseSettingForNotificationEvent event,
      Emitter<HomeState> emit) async {
    emit(state.copyWith(
        getFirebaseSettingForNotificationStatus:
            GetFirebaseSettingForNotificationStatus.loading));
    final response = await getMyFirebaseSettingsUseCase(NoParams());

    response.fold((l) {
      if (!isFailedTheFirstTime
          .contains('GetFirebaseSettingForNotificationEvent')) {
        if (prefsRepository.isTokenExpired ?? false) {
          Future.delayed(Duration(seconds: 5),
              () => add(GetFirebaseSettingForNotificationEvent()));
        } else {
          add(GetFirebaseSettingForNotificationEvent());
        }
        isFailedTheFirstTime.add('GetFirebaseSettingForNotificationEvent');
      }
      emit(state.copyWith(
          getFirebaseSettingForNotificationStatus:
              GetFirebaseSettingForNotificationStatus.failure));
    }, (r) async {
      isFailedTheFirstTime.remove('GetFirebaseSettingForNotificationEvent');
      emit(state.copyWith(
        firebaseSettingForNotificationModel: r,
        getFirebaseSettingForNotificationStatus:
            GetFirebaseSettingForNotificationStatus.success,
      ));
    });
  }

  FutureOr<void> _onUnSubscribeTopicForNotificationEvent(
      UnSubscribeTopicForNotificationEvent event,
      Emitter<HomeState> emit) async {
    emit(state.copyWith(
        getFirebaseSettingForNotificationStatus:
            GetFirebaseSettingForNotificationStatus.loading));
    final response = await unSubscribeTopicFornotificationUseCase(
        UnSubscribeTopicForNotificationParams(
            topic: event.topic, variant: event.variant));

    response.fold((l) {
      if (!isFailedTheFirstTime
          .contains('UnSubscribeTopicForNotificationEvent')) {
        if (prefsRepository.isTokenExpired ?? false) {
          Future.delayed(
              Duration(seconds: 5),
              () => add(UnSubscribeTopicForNotificationEvent(
                  topic: event.topic, variant: event.variant)));
        } else {
          add(UnSubscribeTopicForNotificationEvent(
              topic: event.topic, variant: event.variant));
        }
        isFailedTheFirstTime.add('UnSubscribeTopicForNotificationEvent');
      }
      emit(state.copyWith(
          getFirebaseSettingForNotificationStatus:
              GetFirebaseSettingForNotificationStatus.failure));
    }, (r) async {
      isFailedTheFirstTime.remove('UnSubscribeTopicForNotificationEvent');
      emit(state.copyWith(
        firebaseSettingForNotificationModel: r,
        getFirebaseSettingForNotificationStatus:
            GetFirebaseSettingForNotificationStatus.success,
      ));
    });
  }

  FutureOr<void> _onChangeCountryLanguageForNotificationEvent(
      ChangeCountryLanguageForNotificationEvent event,
      Emitter<HomeState> emit) async {
    emit(state.copyWith(
        getFirebaseSettingForNotificationStatus:
            GetFirebaseSettingForNotificationStatus.loading));
    final response = await changeCountryLanguageFornotificationUseCase(
        ChangeCountryLanguageFornotificationParams(
            country: event.country, languageCode: event.languageCode));

    response.fold((l) {
      if (!isFailedTheFirstTime
          .contains('ChangeCountryLanguageForNotificationEvent')) {
        if (prefsRepository.isTokenExpired ?? false) {
          Future.delayed(
              Duration(seconds: 5),
              () => add(ChangeCountryLanguageForNotificationEvent(
                  country: event.country, languageCode: event.languageCode)));
        } else {
          add(ChangeCountryLanguageForNotificationEvent(
              country: event.country, languageCode: event.languageCode));
        }
        isFailedTheFirstTime.add('ChangeCountryLanguageForNotificationEvent');
      }

      emit(state.copyWith(
          getFirebaseSettingForNotificationStatus:
              GetFirebaseSettingForNotificationStatus.failure));
    }, (r) async {
      isFailedTheFirstTime.remove('ChangeCountryLanguageForNotificationEvent');
      emit(state.copyWith(
        firebaseSettingForNotificationModel: r,
        getFirebaseSettingForNotificationStatus:
            GetFirebaseSettingForNotificationStatus.success,
      ));
    });
  }

  initializeSmartLook() async {
    String deviceId = (await HelperFunctions.getDeviceId()).toString();
    await smartLook.preferences.setProjectKey(dotenv.env['SMART_LOOK_KEY']!);
    await smartLook.preferences.setFrameRate(2);
    await smartLook.user.setIdentifier(deviceId);
    await smartLook.user
        .setName(GetIt.I<PrefsRepository>().myChatName ?? 'No_Name');
    await smartLook.start();
  }

  _onAddCurrentSelectedColorEvent(
      AddCurrentSelectedColorEvent event, Emitter<HomeState> emit) {
    emit(state.copyWith(
        currentSelectedColorForEveryProductStatus:
            CurrentSelectedColorForEveryProductStatus.loading));
    Map<String, int> currentSelectedColorForEveryProduct =
        Map.of(state.currentSelectedColorForEveryProduct);
    if (currentSelectedColorForEveryProduct[event.productSlug] == null) {
      currentSelectedColorForEveryProduct
          .addAll({event.productSlug: event.currentSelectedColor});
    } else {
      currentSelectedColorForEveryProduct[event.productSlug] =
          event.currentSelectedColor;
    }
    emit(state.copyWith(
        currentSelectedColorForEveryProductStatus:
            CurrentSelectedColorForEveryProductStatus.success,
        currentSelectedColorForEveryProduct:
            Map.of(currentSelectedColorForEveryProduct)));
  }

  _onClearAllAppCashEvent(ClearAllAppCashEvent event, Emitter<HomeState> emit) {
    prefsRepository.removeBoutiqueHasPerfechedWhenOpenApp(true);
    prefsRepository.removeMainCategoryHasPerfechedWhenOpenApp(true);

    prefsRepository.removeFiveFilterHasPerfechedWhenOpenApp();
    GetIt.I<BoutiqueBloc>().add(ClearAllBoutiquesEvent());

    prefsRepository.removeMainCategoryWhenOpenApp();
    emit(state.copyWith(
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
      getListOfProductsFoundedInCartStatus:
          GetListOfProductsFoundedInCartStatus.init,
      cachedProductWithoutRelatedProductsModel: {},
      productITemForCart: {},
      cartCollection: [],
      oldCartCollection: [],
    ));
  }

  Future<void> _onGetStoryEvent(
      GetStoryForProductEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(
        getStoriesForProductStatus: GetStoriesForProductStatus.loading));
    final response = await getStoryUseCase(event.productId);

    response.fold((l) {
      if (isFailedTheFirstTime.contains('GetStoryEvent')) {
        isFailedTheFirstTime.remove('GetStoryEvent');
        emit(state.copyWith(
            getStoriesForProductStatus: GetStoriesForProductStatus.failure));
      } else {
        isFailedTheFirstTime.insert(
            isFailedTheFirstTime.length, 'GetStoryEvent');

        add(GetStoryForProductEvent(productId: event.productId));
      }
    }, (r) {
      apisMustNotToRequest.add('GetStoryEvent');

      emit(state.copyWith(
        storiesForProduct: r.data!.story,
        getStoriesForProductStatus: GetStoriesForProductStatus.success,
      ));
    });
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
    print('9999999999999 ${state.hashCode}');
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
    print('66666666666666666666 ${state.hashCode}');

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
      print(
          'kkkkkkkkkkk ${getProductListingWithFiltersPaginationModels['women-section-67withoutFilter']?.paginationStatus}');
      print('sssssssssss ${state.hashCode}');
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
      filters_model.GetProductFiltersModel r, filters_model.Filter filters) {
    List<String> colors = List.of(r.filters?.colors ?? []);
    List<Category> categories = List.of(r.filters?.categories ?? []);
    List<filters_model.Boutique> boutiques =
        List.of(r.filters?.boutiques ?? []);
    List<filters_model.Brand> brands = List.of(r.filters?.brands ?? []);
    List<filters_model.Attribute> attributes =
        List.of(r.filters?.attributes ?? []);
    if (!filters.colors.isNullOrEmpty) {
      colors.removeWhere((element) => filters.colors!.contains(element));
    }
    if (!filters.categories.isNullOrEmpty) {
      categories.removeWhere((element) =>
          filters.categories!
              .indexWhere((category) => category.slug == element.slug) !=
          -1);
    }
    if (!filters.brands.isNullOrEmpty) {
      brands.removeWhere((element) =>
          filters.brands!.indexWhere((brand) => brand.slug == element.slug) !=
          -1);
    }
    if (!filters.boutiques.isNullOrEmpty) {
      boutiques.removeWhere((element) =>
          filters.boutiques!
              .indexWhere((boutique) => boutique.slug == element.slug) !=
          -1);
    }

    if (!filters.attributes.isNullOrEmpty && attributes.isNotEmpty) {
      if (!filters.attributes![0].options.isNullOrEmpty) {
        attributes[0].options!.removeWhere((element) =>
            filters.attributes![0].options
                ?.indexWhere((option) => option == element) !=
            -1);
      }
    }
    return r.copyWithSendValue(
        filters: (r.filters!.prices == null &&
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
                attributes: attributes));
  }

  FutureOr<void> _onAddSizesForColorsEvent(
      AddSizesForColorsEvent event, Emitter<HomeState> emit) async {
    List<String> sizes = [];
    List<int> sizesQuantities = [];
    List<String> colors = [];
    List<int> colorsQuantities = [];
    String size;
    String color;
    emit(state.copyWith(
        changeSizesForEveryProduct: ChangeSizesForEveryProduct.loading));

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
            size =
                element.type!.split("-")[event.currentColorName == '' ? 0 : 1];
            sizes.add(size);
            sizesQuantities.add((element.qty ?? 0).round());
            if (element.variantNotifyForUser) {}
          } catch (e) {}
        }
      });
    } else {}

    emit(state.copyWith(
      sizesForEachColor: sizes,
      colorsForEachProduct: colors,
      colorsQuantitiesForProduct: colorsQuantities,
      changeSizesForEveryProduct: ChangeSizesForEveryProduct.success,
      sizesQuantitiesForEachColor: sizesQuantities,
    ));
  }

  FutureOr<void> _onChangeStatusOFGetProductsDetailsToSuccessEvent(
      ChangeStatusOFGetProductsDetailsToSuccessEvent event,
      Emitter<HomeState> emit) async {
    if (event.isStatusInitaial ?? false) {
      emit(state.copyWith(
          getProductDetailWithoutSimilarRelatedProductsStatus:
              GetProductDetailWithoutSimilarRelatedProductsStatus.init));
    } else {
      await Future.delayed(
        Duration(seconds: 1),
        () {
          emit(state.copyWith(
              enableAddToCardAfterChangeVariantZero:
                  EnableAddToCardAfterChangeVariantZero.loading,
              getProductDetailWithoutSimilarRelatedProductsStatus:
                  GetProductDetailWithoutSimilarRelatedProductsStatus.success));
        },
      );
      await Future.delayed(
        Duration(seconds: 1),
        () {
          emit(state.copyWith(
            enableAddToCardAfterChangeVariantZero:
                EnableAddToCardAfterChangeVariantZero.success,
          ));
        },
      );
    }
  }

  FutureOr<void> _onGetProductDatailsWithoutRelatedProductsEvent(
      GetProductDatailsWithoutRelatedProductsEvent event,
      Emitter<HomeState> emit) async {
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

    emit(state.copyWith(
        getProductDetailWithoutSimilarRelatedProductsStatus:
            GetProductDetailWithoutSimilarRelatedProductsStatus.loading));

    final response =
        await getProductDetailWithoutRelatedProductsUseCase(event.productSlug!);

    response.fold((l) {
      if (!isFailedTheFirstTime
          .contains('GetProductDatailsWithoutRelatedProductsEvent')) {
        add(GetProductDatailsWithoutRelatedProductsEvent(
            productId: event.productId, productSlug: event.productSlug));
        isFailedTheFirstTime
            .add('GetProductDatailsWithoutRelatedProductsEvent');
      }
      emit(state.copyWith(
          getProductDetailWithoutSimilarRelatedProductsStatus:
              GetProductDetailWithoutSimilarRelatedProductsStatus.failure));
    }, (r) {
      if ((event.fromListingPage ?? false) == false) {
        Future.delayed(Duration(seconds: 2), () {
          add(GetAndAddCountViewOfProductEvent(
              productId: r.product!.id.toString()));
          add(GetCommentForProductEvent(productId: r.product!.id.toString()));
          add(GetStoryForProductEvent(productId: r.product!.id.toString()));
          GetIt.I<ChatBloc>().add(
              GetSharedProductCountEvent(productId: r.product!.id.toString()));
        });
      }

      productStatus = Map.from(state.productStatus ?? {});
      productStatus.removeWhere((key, value) => key == event.productId!);
      productStatus.addAll({
        event.productId!:
            GetProductDetailWithoutSimilarRelatedProductsStatus.success
      });
      apisMustNotToRequest.add('GetProductDatailsWithoutRelatedProductsEvent');
      isFailedTheFirstTime
          .remove('GetProductDatailsWithoutRelatedProductsEvent');
      Map<String, GetProductDetailWithoutRelatedProductsModel> newCached =
          Map.of(state.cachedProductWithoutRelatedProductsModel);
      newCached.removeWhere((key, value) => key == event.productId!);
      newCached.addAll({event.productId!: r});

      emit(state.copyWith(
          cachedProductWithoutRelatedProductsModel: Map.of(newCached),
          productStatus: Map.of(productStatus)));

      add(ChangeStatusOFGetProductsDetailsToSuccessEvent());
    });
  }

  @override
  HomeState? fromJson(Map<String, dynamic> json) {
    return HomeState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(HomeState state) {
    return state.copyWith(
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
      getOldCartItemsStatus: GetOLdCartItemsStatus.init,
      getProductDetailWithoutSimilarRelatedProductsStatus:
          GetProductDetailWithoutSimilarRelatedProductsStatus.init,
      getStartingSettingsStatus: GetStartingSettingsStatus.init,
      checkAvailabilityProductCartStatus:
          CheckAvailabilityProductCartStatus.init,
      checkWithGetCartStatus: CheckWithGetCartStatus.init,
      getUserNotificationModel: PaginationModel.init(),
    ).toJson();
  }

  FutureOr<void> _onGetCommentForProductEvent(
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
      if (!isFailedTheFirstTime.contains('GetCommentForProductEvent')) {
        add(GetCommentForProductEvent(productId: event.productId));
        isFailedTheFirstTime.add('GetCommentForProductEvent');
      }
      emit(state.copyWith(
          getCommentForProductModel: Map.of(getCommentForProduct),
          getCommentForProductStatus: GetCommentForProductStatus.failure));
    }, (r) {
      getCommentForProduct = Map.of(state.getCommentForProductModel);
      isFailedTheFirstTime.remove('GetCommentForProductEvent');
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

  FutureOr<void> _onGetCartItemEvent(
      GetCartItemEvent event, Emitter<HomeState> emit) async {
    if (state.getCartOverviewStatus == GetCartOverviewStatus.loading) {
      Future.delayed(Duration(seconds: 5), () {
        add(GetCartItemEvent());
      });
      return;
    }
    emit(state.copyWith(getCartItemsStatus: GetCartItemsStatus.loading));
    final response = await getCartItemUseCase(NoParams());
    response.fold((l) {
      if (!isFailedTheFirstTime.contains('GetCartItemEvent')) {
        add(GetCartItemEvent());
        isFailedTheFirstTime.add('GetCartItemEvent');
      }
      emit(state.copyWith(getCartItemsStatus: GetCartItemsStatus.failure));
    }, (r) {
      if (state.getCartOverviewStatus == GetCartOverviewStatus.loading ||
          state.updateItemInCartStatus == UpdateItemInCartStatus.loading ||
          state.addItemInCartStatus == AddItemInCartStatus.loading ||
          state.deleteItemInCartStatus == DeleteItemInCartStatus.loading) {
        Future.delayed(Duration(seconds: 5), () {
          add(GetCartItemEvent());
        });

        return;
      }
      List<Cart> carts;
      List<Cart> cartCollection = [];
      Map<String, Map<int, List<String>>> addImagesToProductIdForCart = {};
      Map<String, Map<String, String>> addVariationToCartId = {};
      r.data?.cart?.forEach((element) => addVariationToCartId.addAll({
            element.id.toString(): {
              "size": "${element.variations?[0].size ?? ""}",
              "color": "${element.variations?[0].color ?? ""}"
            }
          }));
      emit(state.copyWith(currentQuantityForCart: {}));
      List<String> cartIdIsFound = [];
      r.data?.cart?.forEach((element) {
        cartIdIsFound.add(element.id.toString());
        add(AddQuantityForCartEvent(
            quantity: element.quantity ?? 0,
            productId: element.productId.toString(),
            currentSize: element.variations.isNullOrEmpty
                ? ""
                : element.variations?[0].size ?? "",
            cartId: element.id ?? 0,
            colorName: element.variations.isNullOrEmpty
                ? ""
                : element.variations?[0].color ?? ""));

        if (addImagesToProductIdForCart[element.productId.toString()] == null) {
          addImagesToProductIdForCart[element.productId.toString()] = {};
        }
        if (!addImagesToProductIdForCart[element.productId.toString()]![
                element.id]
            .isNullOrEmpty) {
          for (int i = 0; i < element.quantity!; i++) {
            addImagesToProductIdForCart[element..productId.toString()]![
                    element.id]!
                .add(element.image ?? "");
          }
          ;
        } else {
          addImagesToProductIdForCart[element.productId.toString()]!
              .addAll({element.id!: []});

          addImagesToProductIdForCart[element.productId.toString()]![
              element.id!] = [];

          for (int i = 0; i < element.quantity!; i++) {
            addImagesToProductIdForCart[element.productId.toString()]![
                    element.id]!
                .add(element.image ?? "");
          }
          ;
        }
      });

      carts = r.data!.cart!;
      carts.forEach((element) {
        cartCollection.add(element);
      });

      isFailedTheFirstTime.remove('GetCartItemEvent');

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
      emit(state.copyWith(
          getCartOverviewStatus: GetCartOverviewStatus.success,
          addImagesToProductIdForCart: addImagesToProductIdForCart,
          addVariationToCartId: addVariationToCartId,
          getCartShippingItemsModel: r,
          cartCollection: List.of(cartCollection),
          getCartItemsStatus: GetCartItemsStatus.success));

      // add(AddItemToCartEvent());
      add(GetOldCartItemEvent());
    });
  }

  bool isInPlaceOrder = false;

  FutureOr<void> _onCheckWithGetCartEvent(
    CheckWithGetCartEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(
        state.copyWith(checkWithGetCartStatus: CheckWithGetCartStatus.loading));
    final response = await getCartItemUseCase(NoParams());
    response.fold(
      (l) {
        if (!isFailedTheFirstTime.contains('CheckWithGetCartEvent')) {
          add(CheckWithGetCartEvent(isForPlaceOrder: event.isForPlaceOrder));
          isFailedTheFirstTime.add('CheckWithGetCartEvent');
        }
        emit(state.copyWith(
            checkWithGetCartStatus: CheckWithGetCartStatus.failure));
      },
      (r) {
        List<Cart> carts;
        List<Cart> cartCollection = [];
        Map<String, Map<int, List<String>>> addImagesToProductIdForCart = {};

        emit(state.copyWith(currentQuantityForCart: {}));
        List<String> cartIdIsFound = [];
        r.data?.cart?.forEach((element) {
          cartIdIsFound.add(element.id.toString());
          add(AddQuantityForCartEvent(
              quantity: element.quantity ?? 0,
              productId: element.productId.toString(),
              currentSize: element.variations.isNullOrEmpty
                  ? ""
                  : element.variations?[0].size ?? "",
              cartId: element.id ?? 0,
              colorName: element.variations.isNullOrEmpty
                  ? ""
                  : element.variations?[0].color ?? ""));
          if (addImagesToProductIdForCart[element.productId.toString()] ==
              null) {
            addImagesToProductIdForCart[element.productId.toString()] = {};
          }
          if (!addImagesToProductIdForCart[element.productId.toString()]![
                  element.id]
              .isNullOrEmpty) {
            for (int i = 0; i < element.quantity!; i++) {
              addImagesToProductIdForCart[element..productId.toString()]![
                      element.id]!
                  .add(element.image ?? "");
            }
            ;
          } else {
            addImagesToProductIdForCart[element.productId.toString()]!
                .addAll({element.id!: []});

            addImagesToProductIdForCart[element.productId.toString()]![
                element.id!] = [];

            for (int i = 0; i < element.quantity!; i++) {
              addImagesToProductIdForCart[element.productId.toString()]![
                      element.id]!
                  .add(element.image ?? "");
            }
            ;
          }
        });

        carts = r.data!.cart!;
        carts.forEach((element) {
          cartCollection.add(element);
        });

        isFailedTheFirstTime.remove('CheckWithGetCartEvent');

        emit(
          state.copyWith(
              addImagesToProductIdForCart: addImagesToProductIdForCart,
              getCartShippingItemsModel: r,
              cartCollection: List.of(cartCollection),
              checkWithGetCartStatus: event.isForPlaceOrder
                  ? CheckWithGetCartStatus.successForPlaceOrder
                  : CheckWithGetCartStatus.successForCart),
        );
      },
    );

    add(GetOldCartItemEvent());
  }

  FutureOr<void> _onGetOldCartItemEvent(
      GetOldCartItemEvent event, Emitter<HomeState> emit) async {
    List<oldCart.OldCart> oldCartCollection = [];
    List<oldCart.OldCart>? oldCarts;

    emit(state.copyWith(getOldCartItemsStatus: GetOLdCartItemsStatus.loading));
    final response = await getOldCartItemUseCase(NoParams());
    response.fold((l) {
      if (!isFailedTheFirstTime.contains('GetoldCartItemEvent')) {
        add(GetOldCartItemEvent());
        isFailedTheFirstTime.add('GetoldCartItemEvent');
      }
      emit(state.copyWith(getCartItemsStatus: GetCartItemsStatus.failure));
    }, (r) {
      if (state.hideItemInOldCartStatus == HideItemInOldCartStatus.loading) {
        add(GetOldCartItemEvent());
        emit(state.copyWith(
            hideItemInOldCartStatus: HideItemInOldCartStatus.success));
        return;
      }
      oldCarts = r.data?.original?.data?.oldCart;
      oldCarts?.forEach((element) {
        oldCartCollection.add(element);
      });
      Map<String, Products> productITemForCart =
          Map.of(state.productITemForCart);

      List<String> productIdsInCart = [];
      state.cartCollection?.forEach(
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
      );

      isFailedTheFirstTime.remove('GetoldCartItemEvent');
      emit(state.copyWith(
          productITemForCart: productITemForCart,
          getOldCartModel: r,
          oldCartCollection: List.of(oldCartCollection),
          getOldCartItemsStatus: GetOLdCartItemsStatus.success));
    });
  }

  FutureOr<void> _onGetProductsListInCartEventEvent(
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
  }

  FutureOr<void> _onSaveUserInfoEvent(
      SaveUserInfoFromAuthEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(userInfo: event.userInfo));
  }

  FutureOr<void> _onSendErrorToMobileErrorLogEvent(
      SendErrorToMobileErrorLogEvent event, Emitter<HomeState> emit) async {
    List<String> listOfErrorSendedToMobileErrorLog =
        List.of(state.listOfErrorSendedToMobileErrorLog);
    String key = event.errorExption +
        event.errorPath +
        event.messageFromeBackend +
        event.urlBackend;

    if (listOfErrorSendedToMobileErrorLog.contains(key)) {
      return;
    }
    listOfErrorSendedToMobileErrorLog.add(key);
    emit(state.copyWith(
        listOfErrorSendedToMobileErrorLog: listOfErrorSendedToMobileErrorLog));

    /* if (productITemForCart.isNotEmpty) {
      return;
    }*/
    final response = await sendErrorToMobileErrorLogUseCase(
        SendErrorToMobileErrorLogParams(
            errorDescription:
                "{Error Type :${event.errorExption} - Error Path :${event.errorPath} - Url Market :${event.urlBackend} - Error Message From Backend :${event.messageFromeBackend} - User Id : ${prefsRepository.myMarketId ?? ""} - User Token :${prefsRepository.marketToken ?? ""} }"));

    response.fold((l) {}, (r) {});
  }

  FutureOr<void> _onAddCurrentSizeColorEvent(
      AddCurrentColorSizeEvent event, Emitter<HomeState> emit) async {
    Map<String, String> sizeColor;

    sizeColor = {
      "size": event.choice_1 ?? "",
    };
    emit(state.copyWith(currentColorSizeForCart: sizeColor));
  }

  FutureOr<void> _onAddItemToCartEvent(
      AddItemToCartEvent event, Emitter<HomeState> emit) async {
    String currentSize = event.choice_1!;
    Map<String, List<int>> currentQuantity =
        Map.of(state.currentQuantityForCart ?? {});

    String key = "${event.products.productId.toString()}" +
        "${event.colorName}" +
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
            showInRelease: true,
            timeShowing: Toast.LENGTH_LONG);
        return;
      }
      if (currentQuantity[key]![0] > 0) {
        currentQuantity[key]![0] = quantity;
        emit(state.copyWith(currentQuantityForCart: currentQuantity));
        add(UpdateItemInCartEvent(
            newQuantity: event.quantity!.round(),
            fishAddAllTheItems: event.finishAddAllTheItems,
            image: event.image,
            currentSize: currentSize,
            maxAllowed: (double.tryParse(event.maxAllowed ?? "0") ?? 0),
            colorName: event.colorName,
            productId: event.products.productId.toString(),
            totalQuantity: quantity,
            cartId: currentQuantity[key]![1].toString(),
            boutiqueId: event.boutiqueId.toString()));
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
            showInRelease: true,
            timeShowing: Toast.LENGTH_LONG);
        return;
      }
    }

    CartBrand brand = CartBrand(
        image: event.products.brand != null
            ? event.products.brand!.icon != null
                ? event.products.brand!.icon!.filePath
                : ""
            : "");
    VariationCart variation =
        VariationCart(color: event.colorName, size: event.choice_1);
    String currentUuid = const Uuid().v4();
    BoutiquesCart boutiquesCart = BoutiquesCart(
        icon: IconCart(filePath: event.boutiqueIcon), id: event.boutiqueId);
    Cart cart = Cart(
      uuid: currentUuid,
      countOfPieces: event.countOfPieces,
      image: event.image,
      boutique: boutiquesCart,
      offerPrice: event.products.offerPrice,
      name: event.products.name,
      price: event.products.price,
      quantity: event.quantity,
      brand: brand,
      variations: [variation],
      productId: event.products.productId,
    );
    List<Cart>? cartCollection = List.of(state.cartCollection ?? []);
    List<oldCart.OldCart>? oldCartCollection =
        List.of(state.oldcartCollection ?? []);
    /* if (cartCollection == {}) {
      emit(state
          .copyWith(cartCollection: {"${event.boutiqueId.toString()}": []}));
    }*/

    cartCollection.add(cart);

    oldCart.OldCart? PreOldCart = oldCartCollection.firstWhere(
      (element) =>
          element.image == event.image &&
          (element.variations!.isNotEmpty
              ? ((element.variations?[0].color ?? '') ==
                  (variation.color ?? ''))
              : true) &&
          (element.variations!.isNotEmpty
              ? ((element.variations?[0].size ?? '') == (variation.size ?? ''))
              : true),
      orElse: () => oldCart.OldCart(id: -1),
    );
    oldCartCollection.removeWhere(
      (element) =>
          element.image == event.image &&
          (element.variations!.isNotEmpty
              ? ((element.variations?[0].color ?? "") ==
                  (variation.color ?? ""))
              : true) &&
          (element.variations!.isNotEmpty
              ? ((element.variations?[0].size ?? "") == (variation.size ?? ''))
              : true),
    );
    emit(state.copyWith(
        oldCartCollection: oldCartCollection,
        cartCollection: cartCollection,
        addItemInCartStatus: AddItemInCartStatus.loading));

    final response = await addItemToCartUseCase(
      AddITemToCartParams(
        image: event.image.split("/").last,
        choice_1: event.choice_1,
        color: event.color,
        id: event.products.productId.toString(),
        quantity: event.quantity,
      ),
    );

    response.fold((l) {
      if (!isFailedTheFirstTime.contains('AddCartItemEvent')) {
        if (prefsRepository.isTokenExpired ?? false) {
          Future.delayed(
            Duration(seconds: 5),
            () {
              add(AddItemToCartEvent(
                  finishAddAllTheItems: event.finishAddAllTheItems,
                  countOfPieces: event.countOfPieces,
                  colorName: event.colorName,
                  productSlugForTopic: event.productSlugForTopic,
                  image: event.image,
                  products: event.products,
                  choice_1: event.choice_1,
                  maxAllowed: event.maxAllowed,
                  color: event.color,
                  quantity: event.quantity));
              isFailedTheFirstTime.add('AddCartItemEvent');
              return;
            },
          );
        } else {
          add(AddItemToCartEvent(
              finishAddAllTheItems: event.finishAddAllTheItems,
              countOfPieces: event.countOfPieces,
              colorName: event.colorName,
              productSlugForTopic: event.productSlugForTopic,
              image: event.image,
              products: event.products,
              choice_1: event.choice_1,
              maxAllowed: event.maxAllowed,
              color: event.color,
              quantity: event.quantity));
        }

        isFailedTheFirstTime.add('AddCartItemEvent');
        return;
      }
      add(UpdateListOfItemForAddToCartEvent(
          imageForAddToCart: ImageForAddToCart(),
          operation: "remove",
          productId: event.products.productId.toString(),
          resetTheList: true));
      emit(state.copyWith(addItemInCartStatus: AddItemInCartStatus.failure));
      state.cartCollection!.remove(cart);
      if (PreOldCart.id != -1) {
        state.oldcartCollection!.add(PreOldCart);
      }

      emit(state.copyWith(
          cartCollection: state.cartCollection,
          oldCartCollection: state.oldcartCollection));

      showMessage(
        l.message,
        foreGroundColor: Colors.white,
        backGroundColor: Colors.black,
      );
    }, (r) {
      add(AddProductItemForCartEvent(
          productId: event.products.productId.toString(),
          product: event.products));
      add(GetCartOverviewEvent());
      Variation? variation;
      List<Variation> listVariation =
          (state.cachedProductWithoutRelatedProductsModel[
                          event.products.productId.toString()] !=
                      null
                  ? state
                              .cachedProductWithoutRelatedProductsModel[
                                  event.products.productId.toString()]!
                              .product !=
                          null
                      ? state
                          .cachedProductWithoutRelatedProductsModel[
                              event.products.productId.toString()]!
                          .product!
                          .variation
                      : []
                  : []) ??
              [];
      Map<String, GetProductDetailWithoutRelatedProductsModel>
          cachedProductWithoutRelatedProductsModel =
          Map.of(state.cachedProductWithoutRelatedProductsModel);

      int index = listVariation.indexWhere((element) =>
          element.type ==
          "${event.colorName}${(event.colorName != "" && event.choice_1 != "") ? "-" : ""}${event.choice_1}");
      isFailedTheFirstTime.remove('AddCartItemEvent');
      add(UpdateListOfItemForAddToCartEvent(
          imageForAddToCart: ImageForAddToCart(),
          operation: "remove",
          productId: event.products.productId.toString(),
          resetTheList: true));

      if (r.data == null || r.data == "" || (r.data?.status ?? 0) != 1) {
        if (index != -1) {
          variation = listVariation[index];
          listVariation.removeAt(index);
          variation = variation.copyWith(qty: 0);
          listVariation.insert(index, variation);

          cachedProductWithoutRelatedProductsModel[event.products.productId
              .toString()] = cachedProductWithoutRelatedProductsModel[
                  event.products.productId.toString()]!
              .copyWith(
                  data: cachedProductWithoutRelatedProductsModel[
                          event.products.productId.toString()]!
                      .product!
                      .copyWith(variation: listVariation));
        }
        showDialog(
          context: navigatorKey.currentState!.context,
          builder: (context) => AlertDialog(
              title: MyTextWidget(
                "${r.message}",
                style: context.textTheme.labelMedium
                    ?.copyWith(color: Colors.red, height: 1.25),
              ),
              actions: <Widget>[
                SingleChildScrollView(
                    child: Column(
                  children: [
                    MyTextWidget(
                      "${LocaleKeys.do_you_want_to_notify_You_when_your_choose_available.tr()}",
                      style: context.textTheme.bodyMedium
                          ?.copyWith(color: Colors.black, height: 1.25),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppElevatedButton(
                              child: Text(
                                "${LocaleKeys.not_now.tr()}",
                                style: TextStyle(color: Colors.red),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              }),
                          AppElevatedButton(
                              child: Text(
                                "${LocaleKeys.notify_me.tr()}",
                                style: TextStyle(color: Colors.green),
                              ),
                              onPressed: () {
                                add(RequestForNotificationWhenProductBecameAvailableEvent(
                                    event.products.productId.toString(),
                                    state.startingSetting?.notificationTypes
                                            ?.firstWhere(
                                                (type) =>
                                                    type.name ==
                                                    'product availability',
                                                orElse: () =>
                                                    NotificationType(id: -1))
                                            .id ??
                                        -1,
                                    event.choice_1 ?? "",
                                    event.colorName,
                                    true));
                                Navigator.of(context).pop();
                              }),
                        ]),
                  ],
                ))
              ]),
        );

        cartCollection.remove(cart);

        emit(state.copyWith(
            addItemInCartStatus: AddItemInCartStatus.success,
            cartCollection: cartCollection,
            cachedProductWithoutRelatedProductsModel:
                cachedProductWithoutRelatedProductsModel));
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
              qty: ((variation.qty)! - (event.quantity ?? 0)));
          listVariation.insert(index, variation);

          cachedProductWithoutRelatedProductsModel[event.products.productId
              .toString()] = cachedProductWithoutRelatedProductsModel[
                  event.products.productId.toString()]!
              .copyWith(
                  data: cachedProductWithoutRelatedProductsModel[
                          event.products.productId.toString()]!
                      .product!
                      .copyWith(variation: listVariation));
        }
        Map<String, Map<String, String>> addVariationToCartId =
            Map.of(state.addVariationToCartId ?? {});
        addVariationToCartId.addAll({
          r.data!.idCart.toString(): {
            "size": "${event.choice_1 ?? ""}",
            "color": "${event.colorName}"
          }
        });
        Map<String, Map<int, List<String>>> addImagesToProductIdForCart =
            Map.from(state.addImagesToProductIdForCart);
        if (addImagesToProductIdForCart[event.products.productId.toString()] ==
            null) {
          addImagesToProductIdForCart[event.products.productId.toString()] = {};
        }
        if (!addImagesToProductIdForCart[event.products.productId.toString()]![
                r.data!.idCart!]
            .isNullOrEmpty) {
          for (int i = 0; i < event.quantity!; i++) {
            addImagesToProductIdForCart[event.products.productId.toString()]![
                    r.data!.idCart!]!
                .add(event.image);
          }
          ;
        } else {
          addImagesToProductIdForCart[event.products.productId.toString()]![
              r.data!.idCart!] = [];
          for (int i = 0; i < event.quantity!; i++) {
            addImagesToProductIdForCart[event.products.productId.toString()]![
                    r.data!.idCart!]!
                .add(event.image);
          }
          ;
        }
        add(AddQuantityForCartEvent(
            currentSize: currentSize,
            colorName: event.colorName,
            cartId: r.data!.idCart!,
            quantity: event.quantity!,
            productId: event.products.productId.toString()));
        cartCollection.removeWhere(
          (element) => element.uuid == currentUuid,
        );

        cart = cart.copyWith(id: r.data!.idCart!);
        cartCollection.add(cart);

        emit(state.copyWith(
            addItemInCartStatus: AddItemInCartStatus.success,
            cachedProductWithoutRelatedProductsModel:
                cachedProductWithoutRelatedProductsModel,
            addVariationToCartId: addVariationToCartId,
            cartCollection: cartCollection,
            addImagesToProductIdForCart: addImagesToProductIdForCart));
      }
      if (event.finishAddAllTheItems) {
        showMessage(r.message!,
            foreGroundColor: Colors.white,
            backGroundColor: Colors.black,
            showInRelease: true,
            timeShowing: Toast.LENGTH_SHORT);
      }
    });
  }

  FutureOr<void> _onAddProductItemForCartEvent(
      AddProductItemForCartEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(addItemInCartStatus: AddItemInCartStatus.init));
    Map<String, Products> productsForCart = Map.of(state.productITemForCart);
    if (productsForCart.containsKey(event.productId)) {
      productsForCart[event.productId] = event.product!;
    } else {
      productsForCart.addAll({event.productId: event.product!});
    }
    emit(state.copyWith(productITemForCart: Map.of(productsForCart)));
  }

  FutureOr<void> _onRemoveItemToCartEvent(
      RemoveItemFormCartEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(deleteItemInCartStatus: DeleteItemInCartStatus.init));
    Cart cart = state.cartCollection!
        .firstWhere((element) => element.id.toString() == event.itemId);
    List<Cart>? cartCollection = List.of(state.cartCollection!);
    cartCollection.remove(cart);

    Map<String, Map<int, List<String>>> addImagesToProductIdForCart =
        Map.of(state.addImagesToProductIdForCart);
    List<String> preListImage = [];
    if (addImagesToProductIdForCart[event.productId] != null) {
      if (!addImagesToProductIdForCart[event.productId]![
              int.parse(event.itemId)]
          .isNullOrEmpty) {
        addImagesToProductIdForCart[event.productId]![int.parse(event.itemId)]!
            .forEach(
          (element) {
            if (element == event.image) {
              preListImage.add(element);
            }
          },
        );
        addImagesToProductIdForCart[event.productId]![int.parse(event.itemId)]!
            .removeWhere(
          (element) => element == event.image,
        );
      }
    }
    emit(state.copyWith(
        cartCollection: cartCollection,
        addImagesToProductIdForCart: addImagesToProductIdForCart,
        deleteItemInCartStatus: DeleteItemInCartStatus.loading));
    final response =
        await removeItemToCartUseCase(RemoveITemToCartParams(id: event.itemId));

    response.fold((l) {
      Map<String, Map<int, List<String>>> preAddImagesToProductIdForCart =
          Map.of(state.addImagesToProductIdForCart);
      preAddImagesToProductIdForCart[event.productId]![int.parse(event.itemId)]
          ?.addAll(preListImage);

      isFailedTheFirstTime.add('RemoveCartItemEvent');
      List<Cart>? cartCollection = List.of(state.cartCollection!);

      cartCollection.add(cart);

      emit(state.copyWith(
          addImagesToProductIdForCart: preAddImagesToProductIdForCart,
          cartCollection: cartCollection,
          deleteItemInCartStatus: DeleteItemInCartStatus.failure));
      showMessage(
        "${LocaleKeys.your_request_faild.tr()}",
        foreGroundColor: Colors.white,
        backGroundColor: Colors.black,
      );
    }, (r) {
      add(GetCartOverviewEvent());
      Variation? variation;
      List<Variation> listVariation =
          (state.cachedProductWithoutRelatedProductsModel[
                          event.productId.toString()] !=
                      null
                  ? state
                              .cachedProductWithoutRelatedProductsModel[
                                  event.productId.toString()]!
                              .product !=
                          null
                      ? state
                          .cachedProductWithoutRelatedProductsModel[
                              event.productId.toString()]!
                          .product!
                          .variation
                      : []
                  : []) ??
              [];
      Map<String, GetProductDetailWithoutRelatedProductsModel>
          cachedProductWithoutRelatedProductsModel =
          Map.of(state.cachedProductWithoutRelatedProductsModel);

      int index = listVariation.indexWhere((element) =>
          element.type ==
          "${event.colorName}${(event.colorName != "" && event.currentSize != "") ? "-" : ""}${event.currentSize}");
      if (index != -1) {
        variation = listVariation[index];
        listVariation.removeAt(index);
        variation = variation.copyWith(qty: ((variation.qty)! + 1));
        listVariation.insert(index, variation);

        cachedProductWithoutRelatedProductsModel[event.productId.toString()] =
            cachedProductWithoutRelatedProductsModel[
                    event.productId.toString()]!
                .copyWith(
                    data: cachedProductWithoutRelatedProductsModel[
                            event.productId.toString()]!
                        .product!
                        .copyWith(variation: listVariation));
      }
      Map<String, Map<String, String>> addVariationToCartId =
          Map.of(state.addVariationToCartId ?? {});
      addVariationToCartId
          .removeWhere((key, value) => key == event.itemId.toString());
      Map<String, Map<int, List<String>>> addImagesToProductIdForCart =
          Map.from(state.addImagesToProductIdForCart);
      if (!addImagesToProductIdForCart[event.productId]![
              int.parse(event.itemId)]
          .isNullOrEmpty) {
        addImagesToProductIdForCart[event.productId]![int.parse(event.itemId)]!
            .removeWhere(
          (element) => element == event.image,
        );
      }
      emit(state.copyWith(
          cachedProductWithoutRelatedProductsModel:
              cachedProductWithoutRelatedProductsModel,
          addVariationToCartId: addVariationToCartId,
          addImagesToProductIdForCart: addImagesToProductIdForCart,
          deleteItemInCartStatus: DeleteItemInCartStatus.success));

      add(AddQuantityForCartEvent(
          currentSize: event.currentSize,
          colorName: event.colorName,
          cartId: int.tryParse(event.itemId)!,
          quantity: 0,
          productId: event.productId));
      isFailedTheFirstTime.remove('RemoveCartItemEvent');

      showMessage(
        "${LocaleKeys.item_was_hidden_successfuly.tr()}",
        foreGroundColor: Colors.white,
        backGroundColor: Colors.black,
      );
    });
  }

  FutureOr<void> _onHideItemInOldCartEvent(
      HideItemInOldCartEvent event, Emitter<HomeState> emit) async {
    List<oldCart.OldCart>? preOldCartCollection = state.oldcartCollection;
    List<oldCart.OldCart>? oldCartCollection = preOldCartCollection;
    oldCart.OldCart? cart;
    if (!(event.hideAll ?? false)) {
      cart = state.oldcartCollection!.firstWhere(
          (element) => element.id.toString() == event.oldCartId.toString());

      oldCartCollection!.remove(cart);
    }

    emit(state.copyWith(
        oldCartCollection: (event.hideAll ?? false) ? [] : oldCartCollection,
        hideItemInOldCartStatus: HideItemInOldCartStatus.loading));
    final response = await hideItemsInOldCartUseCase(HideItemsInOldCartParams(
        hideAll: event.hideAll ?? false, oLdCartId: event.oldCartId));

    response.fold((l) {
      List<oldCart.OldCart>? oldCartCollection =
          List.of(state.oldcartCollection!);
      if (!(event.hideAll ?? false)) {
        oldCartCollection.add(cart!);
      }

      emit(state.copyWith(
          oldCartCollection: (event.hideAll ?? false)
              ? preOldCartCollection
              : oldCartCollection,
          hideItemInOldCartStatus: HideItemInOldCartStatus.failure));
      showMessage(
        "${LocaleKeys.your_request_faild.tr()}",
        foreGroundColor: Colors.white,
        backGroundColor: Colors.black,
      );
    }, (r) {
      add(GetOldCartItemEvent());
      emit(state.copyWith(
        hideItemInOldCartStatus: HideItemInOldCartStatus.success,
      ));
      showMessage(
        "${LocaleKeys.item_was_hidden_successfuly.tr()}",
        foreGroundColor: Colors.white,
        backGroundColor: Colors.black,
      );
    });
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
      print(
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
      UpdateItemInCartEvent event, Emitter<HomeState> emit) async {
    if (event.totalQuantity == 0) {
      add(RemoveItemFormCartEvent(
          image: event.image,
          currentSize: event.currentSize,
          colorName: event.colorName,
          itemId: event.cartId,
          boutiqueId: event.boutiqueId,
          productId: event.productId));
      return;
    }
    if (event.totalQuantity > (event.maxAllowed ?? 0) &&
        event.maxAllowed != 0) {
      showMessage(
          "${LocaleKeys.you_reach_the_max_allowed_quantity.tr()} \n (${(event.maxAllowed ?? 0.0).round()} ${LocaleKeys.item.tr()}) ${LocaleKeys.of_this_product.tr()}",
          foreGroundColor: Colors.white,
          backGroundColor: Colors.black,
          showInRelease: true,
          timeShowing: Toast.LENGTH_LONG);
      return;
    }

    Cart cart = state.cartCollection!
        .firstWhere((element) => element.id.toString() == event.cartId);
    Cart PreCart = cart;
    cart = cart.copyWith(quantity: event.totalQuantity);

    List<Cart>? cartCollection = state.cartCollection!.map((e) {
      if (e.id.toString() == event.cartId) {
        return cart;
      } else {
        return e;
      }
    }).toList();
    emit(state.copyWith(
        cartCollection: cartCollection,
        updateItemInCartStatus: UpdateItemInCartStatus.loading));
    final response = await updateItemInCartUseCase(UpdateITemInCartParams(
        id: event.cartId, quantity: event.totalQuantity));

    response.fold((l) {
      isFailedTheFirstTime.add('UpdateCartItemEvent');
      List<Cart>? cartCollection = state.cartCollection!.map((e) {
        if (e.id.toString() == event.cartId) {
          return PreCart;
        } else {
          return e;
        }
      }).toList();
      emit(state.copyWith(cartCollection: cartCollection));
      showMessage(
        l.message,
        foreGroundColor: Colors.white,
        backGroundColor: Colors.black,
      );
      emit(state.copyWith(
          updateItemInCartStatus: UpdateItemInCartStatus.failure));
    }, (r) {
      isFailedTheFirstTime.remove('UpdateCartItemEvent');
      add(GetCartOverviewEvent());
      Variation? variation;
      List<Variation> listVariation =
          (state.cachedProductWithoutRelatedProductsModel[
                          event.productId.toString()] !=
                      null
                  ? state
                              .cachedProductWithoutRelatedProductsModel[
                                  event.productId.toString()]!
                              .product !=
                          null
                      ? state
                          .cachedProductWithoutRelatedProductsModel[
                              event.productId.toString()]!
                          .product!
                          .variation
                      : []
                  : []) ??
              [];
      Map<String, GetProductDetailWithoutRelatedProductsModel>
          cachedProductWithoutRelatedProductsModel =
          Map.of(state.cachedProductWithoutRelatedProductsModel);

      int index = listVariation.indexWhere((element) =>
          element.type ==
          "${event.colorName}${event.colorName != "" ? "-" : ""}${event.currentSize}");

      if ((r.data == null || r.data == "") || (r.data?.status ?? 0) != 1) {
        if (index != -1 && event.totalQuantity == 1) {
          variation = listVariation[index];
          listVariation.removeAt(index);
          variation = variation.copyWith(qty: 0);
          listVariation.insert(index, variation);

          cachedProductWithoutRelatedProductsModel[event.productId.toString()] =
              cachedProductWithoutRelatedProductsModel[
                      event.productId.toString()]!
                  .copyWith(
                      data: cachedProductWithoutRelatedProductsModel[
                              event.productId.toString()]!
                          .product!
                          .copyWith(variation: listVariation));
        }
        showDialog(
          context: navigatorKey.currentState!.context,
          builder: (context) => AlertDialog(
              title: MyTextWidget(
                "${r.message}",
                style: context.textTheme.labelMedium
                    ?.copyWith(color: Colors.red, height: 1.25),
              ),
              actions: <Widget>[
                SingleChildScrollView(
                    child: Column(
                  children: [
                    MyTextWidget(
                      "${LocaleKeys.do_you_want_to_notify_You_when_your_choose_available.tr()}",
                      style: context.textTheme.bodyMedium
                          ?.copyWith(color: Colors.black, height: 1.25),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppElevatedButton(
                              child: Text(
                                "${LocaleKeys.not_now.tr()}",
                                style: TextStyle(color: Colors.red),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              }),
                          AppElevatedButton(
                              child: Text(
                                "${LocaleKeys.notify_me.tr()}",
                                style: TextStyle(color: Colors.green),
                              ),
                              onPressed: () {
                                add(RequestForNotificationWhenProductBecameAvailableEvent(
                                    event.productId,
                                    state.startingSetting?.notificationTypes
                                            ?.firstWhere(
                                                (type) =>
                                                    type.name ==
                                                    'product availability',
                                                orElse: () =>
                                                    NotificationType(id: -1))
                                            .id ??
                                        -1,
                                    event.currentSize,
                                    event.colorName,
                                    true));
                                Navigator.of(context).pop();
                              }),
                        ]),
                  ],
                ))
              ]),
        );

        List<Cart>? cartCollection = state.cartCollection!.map((e) {
          if (e.id.toString() == event.cartId) {
            return PreCart;
          } else {
            return e;
          }
        }).toList();

        emit(state.copyWith(
            cachedProductWithoutRelatedProductsModel:
                cachedProductWithoutRelatedProductsModel,
            updateItemInCartStatus: UpdateItemInCartStatus.success,
            cartCollection: cartCollection));
        return;
      }
      if (r.data!.status == 1) {
        if (index != -1) {
          variation = listVariation[index];
          listVariation.removeAt(index);
          variation =
              variation.copyWith(qty: ((variation.qty)! - (event.newQuantity)));
          listVariation.insert(index, variation);

          cachedProductWithoutRelatedProductsModel[event.productId.toString()] =
              cachedProductWithoutRelatedProductsModel[
                      event.productId.toString()]!
                  .copyWith(
                      data: cachedProductWithoutRelatedProductsModel[
                              event.productId.toString()]!
                          .product!
                          .copyWith(variation: listVariation));
        }

        Map<String, Map<int, List<String>>> addImagesToProductIdForCart =
            Map.from(state.addImagesToProductIdForCart);

        if (!addImagesToProductIdForCart[event.productId]![
                int.parse(event.cartId)]
            .isNullOrEmpty) {
          addImagesToProductIdForCart[event.productId]![
                  int.parse(event.cartId)]!
              .removeWhere((element) => element == event.image);
          for (int i = 0; i < event.totalQuantity; i++) {
            addImagesToProductIdForCart[event.productId]![
                    int.parse(event.cartId)]!
                .add(event.image);
          }
          ;
        } else {
          addImagesToProductIdForCart[event.productId]![
              int.parse(event.cartId)] = [];
          for (int i = 0; i < event.totalQuantity; i++) {
            addImagesToProductIdForCart[event.productId]![
                    int.parse(event.cartId)]!
                .add(event.image);
          }
          ;
        }

        add(AddQuantityForCartEvent(
            currentSize: event.currentSize,
            colorName: event.colorName,
            cartId: int.tryParse(event.cartId)!,
            quantity: event.totalQuantity,
            productId: event.productId));

        if (event.fishAddAllTheItems) {
          showMessage(r.message!,
              foreGroundColor: Colors.white,
              backGroundColor: Colors.black,
              showInRelease: true,
              timeShowing: Toast.LENGTH_SHORT);
          isFailedTheFirstTime.remove('AddCartItemEvent');
        }
        emit(state.copyWith(
            addImagesToProductIdForCart: addImagesToProductIdForCart,
            cachedProductWithoutRelatedProductsModel:
                cachedProductWithoutRelatedProductsModel,
            updateItemInCartStatus: UpdateItemInCartStatus.success));
      }

      isFailedTheFirstTime.remove('UpdateCartItemEvent');
    });
  }

  Future<void> _onGetCurrencyForCountryEvent(
      GetCurrencyForCountryEvent event, Emitter<HomeState> emit) async {
    final response = await getCurrencyForCountryUseCase(NoParams());
    response.fold((l) {}, (r) {
      emit(state.copyWith(
        getCurrencyForCountryModel: r,
      ));
    });
  }

  FutureOr<void> _onAddCurrentQuantityForCartEvent(
      AddQuantityForCartEvent event, Emitter<HomeState> emit) async {
    Map<String, List<int>> currentQuantity = state.currentQuantityForCart ?? {};
    String key =
        "${event.productId}" + "${event.colorName}" + "${event.currentSize}";
    if (!currentQuantity[key].isNullOrEmpty) {
      currentQuantity[key] = [event.quantity, event.cartId];
    } else {
      currentQuantity.addAll({
        key: [event.quantity, event.cartId]
      });
    }
    currentQuantity.removeWhere((key, value) => value[0] == 0);
    emit(state.copyWith(currentQuantityForCart: currentQuantity));
  }

  FutureOr<void> _onGetNotificationTypeProductEvent(
      GetNotificationTypeProductEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(
        getNotificationTypeProductStatus:
            GetNotificationTypeProductStatus.loading));
    final response = await getNotificationTypeProductUseCase(NoParams());
    response.fold((l) {
      emit(state.copyWith(
          getNotificationTypeProductStatus:
              GetNotificationTypeProductStatus.failure));
    }, (r) {
      emit(state.copyWith(
          notificationTypeForProductModel: r,
          getNotificationTypeProductStatus:
              GetNotificationTypeProductStatus.success));
    });
  }

  FutureOr<void> _onConvertItemFromCartToOldCartEvent(
      ConvertItemFromCartToOldCartEvent event, Emitter<HomeState> emit) async {
    List<oldCart.OldCart>? oldcartCollection =
        List.of(state.oldcartCollection ?? []);
    List<Cart>? cartCollection = List.of(state.cartCollection ?? []);
    Cart cart = cartCollection.firstWhere(
      (element) => element.id.toString() == event.cartId,
      orElse: () => Cart(id: -1),
    );
    if (cart.id != -1) {
      cartCollection.removeWhere(
        (element) => element.id.toString() == event.cartId,
      );

      oldcartCollection.add(oldCart.OldCart(
          availableQuantity: cart.availableQuantity?.round(),
          boutique: cart.boutique,
          brand: oldCart.Brand(image: cart.brand?.image, name: cart.name),
          image: cart.image,
          cartGroupId: cart.cartGroupId,
          countOfPieces: cart.countOfPieces,
          discount: cart.discount,
          maxAllowedQty: cart.maxAllowedQty,
          productId: cart.productId,
          variations: cart.variations,
          shippingDays: cart.shippingDays,
          quantity: cart.quantity,
          thumbnail: cart.thumbnail,
          id: cart.id,
          variant: cart.variant,
          priceOfVariant: cart.price,
          choices: [oldCart.Choice(choice1: cart.choices?[0].choice1)]));
    }
    emit(state.copyWith(
        oldCartCollection: oldcartCollection, cartCollection: cartCollection));
  }

  FutureOr<void> _onGetPopularSearchItemEvent(
      GetPopularSearchItemEvent event, Emitter<HomeState> emit) async {
    final response = await getPopularSearchItemUseCase(NoParams());
    response.fold((l) {
      if (!isFailedTheFirstTime.contains('getPopularSearchItemEvent')) {
        add(GetPopularSearchItemEvent());
        isFailedTheFirstTime.add('getPopularSearchItemEvent');
      }
    }, (r) {
      isFailedTheFirstTime.remove('getPopularSearchItemEvent');
      List<PopularSearchTerm> popularSearchTerm = [];
      popularSearchTerm = r.popularSearchTerms ?? [];
      emit(state.copyWith(popularSearchTerm: popularSearchTerm));
    });
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
      AddSearchTextToHistoryEvent event, Emitter<HomeState> emit) async {
    List<String> searchHistory = state.searchHistory ?? [];
    if (searchHistory.contains(event.searchTitle)) {
      return;
    }
    searchHistory.add(event.searchTitle);
    emit(state.copyWith(searchHistory: searchHistory));
  }

  FutureOr<void> _onRemoveSearchTextToHistoryEvent(
      RemoveSearchTextfromHistoryEvent event, Emitter<HomeState> emit) async {
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
      AddMultiItemsToCartEvent event, Emitter<HomeState> emit) {
    List<ImageForAddToCart>? listitemForAddToCart =
        List.of(state.listitemForAddToCart ?? []);
    listitemForAddToCart.removeWhere((element) => element.quantity == 0);
    for (var i = 0; i < listitemForAddToCart.length; i++) {
      add(AddItemToCartEvent(
          finishAddAllTheItems: i == listitemForAddToCart.length - 1,
          countOfPieces: listitemForAddToCart[i].countOfPieces,
          image: listitemForAddToCart[i].images!,
          productSlugForTopic: event.productSlugForTopic,
          color: listitemForAddToCart[i].colorNum,
          colorName: listitemForAddToCart[i].colorName!,
          products: event.products,
          maxAllowed: event.maxAllowed,
          boutiqueIcon: event.boutiqueIcon,
          boutiqueId: event.boutiqueId,
          choice_1: listitemForAddToCart[i].size,
          quantity: listitemForAddToCart[i].quantity));
      //////////////////////////////
      FirebaseAnalyticsService.logEventForSession(
        eventName: AnalyticsEventsConst.programmingEvent,
        executedEventName: AnalyticsExecutedEventNameConst.addedProductEvent,
        extraParams: {
          'product_id': event.id.toString(),
          'max_allowed': event.maxAllowed.toString(),
          'count_of_piece': listitemForAddToCart[i].countOfPieces.toString(),
          'quantity': listitemForAddToCart[i].quantity.toString(),
          'color': listitemForAddToCart[i].colorNum.toString(),
          'choice_1': listitemForAddToCart[i].size.toString(),
        },
      );
    }

    emit(state.copyWith(listitemForAddToCart: []));
  }

  FutureOr<void> _onGetAllowedCountriesEvent(
      GetAllowedCountriesEvent event, Emitter<HomeState> emit) async {
    final response = await getAllowedCountryUseCase(NoParams());
    response.fold((l) {
      if (!isFailedTheFirstTime.contains('GetAllowCountryEvent')) {
        add(GetAllowedCountriesEvent());
        isFailedTheFirstTime.add('GetAllowCountryEvent');
      }
    }, (r) {
      isFailedTheFirstTime.remove('GetAllowCountryEvent');

      emit(state.copyWith(
        getAllowedCountriesModel: r,
      ));
    });
  }

  FutureOr<void> _onUpdateListOfItemForAddToCartEvent(
      UpdateListOfItemForAddToCartEvent event, Emitter<HomeState> emit) async {
    if (event.resetTheList) {
      emit(state.copyWith(listitemForAddToCart: []));
      return;
    }

    ImageForAddToCart imageForAddToCart = ImageForAddToCart(
        colorNum: event.imageForAddToCart.colorNum,
        colorName: event.imageForAddToCart.colorName,
        quantity: event.imageForAddToCart.quantity,
        countOfPieces: event.imageForAddToCart.countOfPieces,
        images: event.imageForAddToCart.images,
        size: state.currentColorSizeForCart != null
            ? state.currentColorSizeForCart!["size"]
            : "");

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
            element.colorName == imageForAddToCart.colorName &&
            element.size == imageForAddToCart.size) {
          element.quantity = element.quantity! + 1;
          newImageToAddToCart = ImageForAddToCart(
              countOfPieces: element.countOfPieces,
              isDuplicate: true,
              quantity: 0,
              size: element.size,
              colorName: element.colorName,
              images: element.images);
          break;
        } else {
          if (!listitemForAddToCart.any((element) =>
              (element.images == imageForAddToCart.images &&
                  element.colorName == imageForAddToCart.colorName &&
                  element.size == imageForAddToCart.size))) {
            newImageToAddToCart = imageForAddToCart;
          }
        }
      }
      emit(state.copyWith(listitemForAddToCart: [
        ...listitemForAddToCart,
        newImageToAddToCart!
      ]));
    } else {
      if (listitemForAddToCart.last.isDuplicate == true) {
        ImageForAddToCart itemLast = listitemForAddToCart.last;

        if (itemLast.isDuplicate == true) {
          listitemForAddToCart = listitemForAddToCart.map((e) {
            if (e.quantity! > 0 &&
                e.colorName == itemLast.colorName &&
                e.size == itemLast.size &&
                e.images == itemLast.images) {
              return ImageForAddToCart(
                  countOfPieces: e.countOfPieces,
                  colorName: itemLast.colorName,
                  images: e.images,
                  quantity: e.quantity! - 1,
                  size: itemLast.size);
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
      AddOrRemoveLikeForProductEvent event, Emitter<HomeState> emit) async {
    Map<String, GetProductDetailWithoutRelatedProductsModel>
        cachedProductWithoutRelatedProductsModel =
        Map.of(state.cachedProductWithoutRelatedProductsModel);

    if (!cachedProductWithoutRelatedProductsModel
        .containsKey(event.productId)) {
      cachedProductWithoutRelatedProductsModel.addAll(
          {event.productId: GetProductDetailWithoutRelatedProductsModel()});
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
        isLiked: event.isFavourite ? true : false, countOfLikes: countOfLikes);
    cachedProductWithoutRelatedProductsModel[event.productId] =
        cachedProductWithoutRelatedProductsModel[event.productId]!
            .copyWith(data: product);
    emit(state.copyWith(
        cachedProductWithoutRelatedProductsModel:
            cachedProductWithoutRelatedProductsModel,
        addOrRemoveLikeOfProductStatus:
            AddOrRemoveLikeOfProductStatus.loading));

    final response = event.isFavourite
        ? await addLikeToProductUsecase(AddLikeToProductParams(
            productId: event.productId,
            userId: GetIt.I<PrefsRepository>().myMarketId))
        : await deleteLikeOfProductUsecase(DeleteLikeOfParams(
            productId: event.productId,
            userId: GetIt.I<PrefsRepository>().myMarketId));

    response.fold((l) {
      Map<String, GetProductDetailWithoutRelatedProductsModel>
          cachedProductWithoutRelatedProductsModel =
          Map.of(state.cachedProductWithoutRelatedProductsModel);
      Product? product =
          cachedProductWithoutRelatedProductsModel[event.productId]?.product;
      int countOfLikes = product?.countOfLikes ?? 0;
      if (event.isFavourite) {
        countOfLikes = countOfLikes - 1;
      } else {
        countOfLikes = countOfLikes + 1;
      }
      product = product?.copyWith(
          isLiked: event.isFavourite ? false : true,
          countOfLikes: countOfLikes);
      cachedProductWithoutRelatedProductsModel[event.productId] =
          cachedProductWithoutRelatedProductsModel[event.productId]!
              .copyWith(data: product);

      emit(state.copyWith(
          cachedProductWithoutRelatedProductsModel:
              cachedProductWithoutRelatedProductsModel,
          addOrRemoveLikeOfProductStatus:
              AddOrRemoveLikeOfProductStatus.failure));
    }, (r) {
      emit(state.copyWith(
        addOrRemoveLikeOfProductStatus: AddOrRemoveLikeOfProductStatus.success,
      ));
    });
  }

  FutureOr<void> _onChangeCurrentIndexForUpdatCartEvent(
      ChangeCurrentIndexForUpdatCartEvent event,
      Emitter<HomeState> emit) async {
    emit(state.copyWith(currentIndexForUpdateCart: event.index));
  }

  FutureOr<void> _onAddTimerStartedToHurryUpEvent(
      AddTimerStartedToHurryUpEvent event, Emitter<HomeState> emit) async {
    Map<String, int> cartIdsHurryUPTimerStarted =
        Map.of(state.cartIdsHurryUPTimerStarted);
    if (event.isAddToList) {
      cartIdsHurryUPTimerStarted.addAll({event.cartId: event.timeLeft});
    } else {
      cartIdsHurryUPTimerStarted
          .removeWhere((key, value) => key == event.cartId);
    }
    emit(
        state.copyWith(cartIdsHurryUPTimerStarted: cartIdsHurryUPTimerStarted));
  }

  FutureOr<void> _onRequestForNotificationWhenProductBecameAvailableEvent(
      RequestForNotificationWhenProductBecameAvailableEvent event,
      Emitter<HomeState> emit) async {
    String variant = "";
    if (event.size != "") {
      variant = event.selectedColorName == ''
          ? event.size
          : "${event.selectedColorName}-${event.size}";
    } else {
      variant = event.selectedColorName == '' ? "" : event.selectedColorName;
    }

    if (event.subsecribe) {
      add(SubscribeTopicForNotificationEvent(
          topic: "product_availability_${event.productId}", variant: variant));
    } else {
      add(UnSubscribeTopicForNotificationEvent(
          topic: "product_availability_${event.productId}", variant: variant));
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
      GetAndAddCountViewOfProductEvent event, Emitter<HomeState> emit) async {
    Map<String, GetAndAddCountViewOfProductStatus>
        getAndAddCountViewOfProductStatus =
        Map.of(state.getAndAddCountViewOfProductStatus);
    if (getAndAddCountViewOfProductStatus.containsKey(event.productId)) {
      getAndAddCountViewOfProductStatus[event.productId] =
          GetAndAddCountViewOfProductStatus.loading;
    } else {
      getAndAddCountViewOfProductStatus
          .addAll({event.productId: GetAndAddCountViewOfProductStatus.loading});
    }
    emit(state.copyWith(
        getAndAddCountViewOfProductStatus: getAndAddCountViewOfProductStatus));
    final response = await getAndAddCountViewOfProductUsecase(
        getAndAddCountViewOfProductParams(
            productId: event.productId,
            userId: GetIt.I<PrefsRepository>().myMarketId));
    response.fold((l) {
      Map<String, GetAndAddCountViewOfProductStatus>
          getAndAddCountViewOfProductStatus =
          Map.of(state.getAndAddCountViewOfProductStatus);

      getAndAddCountViewOfProductStatus[event.productId] =
          GetAndAddCountViewOfProductStatus.failure;

      emit(state.copyWith(
          getAndAddCountViewOfProductStatus:
              getAndAddCountViewOfProductStatus));
      emit(state.copyWith(
          getAndAddCountViewOfProductStatus:
              getAndAddCountViewOfProductStatus));
    }, (r) {
      Map<String, GetAndAddCountViewOfProductStatus>
          getAndAddCountViewOfProductStatus =
          Map.of(state.getAndAddCountViewOfProductStatus);

      getAndAddCountViewOfProductStatus[event.productId] =
          GetAndAddCountViewOfProductStatus.success;
      Map<String, GetProductDetailWithoutRelatedProductsModel>
          cachedProductWithoutRelatedProductsModel =
          Map.of(state.cachedProductWithoutRelatedProductsModel);
      Product? product =
          cachedProductWithoutRelatedProductsModel[event.productId]?.product;
      int countViews = r.viewCount ?? 0;

      product = product?.copyWith(viewsCount: countViews);
      cachedProductWithoutRelatedProductsModel[event.productId] =
          cachedProductWithoutRelatedProductsModel[event.productId]!
              .copyWith(data: product);
      emit(state.copyWith(
          cachedProductWithoutRelatedProductsModel:
              cachedProductWithoutRelatedProductsModel,
          getAndAddCountViewOfProductStatus:
              getAndAddCountViewOfProductStatus));
    });
  }

  FutureOr<void> _onGetFullProductDetailsEvent(
      GetFullProductDetailsEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(
        getFullProductDetailsStatus: GetFullProductDetailsStatus.loading));
    final response =
        await getFullProductDetailsUseCase(event.productSlug.toString());
    response.fold((l) {
      emit(state.copyWith(
          getFullProductDetailsStatus: GetFullProductDetailsStatus.failure));
    }, (r) {
      if (r.productItem?.productId == null) {
        emit(state.copyWith(
          productContentForStatusOfOpeningProductDetailsDirectly:
              Products(isProductNotifiedForUser: false),
          getFullProductDetailsStatus: GetFullProductDetailsStatus.success,
        ));

        return;
      }
      if (event.currentColorName != null) {
        int index = -1;
        index = r.productItem!.colors!.indexWhere(
          (element) => element.name == event.currentColorName,
        );
        if (index != -1) {
          add(AddCurrentSelectedColorEvent(
              currentSelectedColor: index,
              productSlug: r.productItem!.slug ?? ""));
        }
      }
      Future.delayed(Duration(seconds: 2), () {
        add(GetAndAddCountViewOfProductEvent(
            productId: r.productItem!.productId.toString()));
        add(GetCommentForProductEvent(
            productId: r.productItem!.productId.toString()));
        add(GetStoryForProductEvent(
            productId: r.productItem!.productId.toString()));
        GetIt.I<ChatBloc>().add(GetSharedProductCountEvent(
            productId: r.productItem!.productId.toString()));
      });

      Map<String, GetProductDetailWithoutRelatedProductsModel> cachedData =
          Map.of(state.cachedProductWithoutRelatedProductsModel);
      Map<String, GetProductDetailWithoutSimilarRelatedProductsStatus>
          productStatus = Map.from(state.productStatus ?? {});
      productStatus[r.productItem!.productId.toString()] =
          GetProductDetailWithoutSimilarRelatedProductsStatus.success;
      cachedData.addAll({
        r.productItem!.productId.toString():
            r.getProductDetailWithoutRelatedProductsModel!
      });
      emit(state.copyWith(
        productStatus: productStatus,
        cachedProductWithoutRelatedProductsModel: cachedData,
        productContentForStatusOfOpeningProductDetailsDirectly: r.productItem,
        getFullProductDetailsStatus: GetFullProductDetailsStatus.success,
      ));

      add(ChangeStatusOFGetProductsDetailsToSuccessEvent());
    });
  }

  FutureOr<void> _onAddCommentEvent(
      AddCommentEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(addCommentStatus: AddCommentStatus.loading));
    final response = await addCommentUseCase(
        AddCommentParams(productId: event.productId, comment: event.comment));

    response.fold((l) {
      emit(state.copyWith(addCommentStatus: AddCommentStatus.failure));
    }, (r) {
      Map<String, GetCommentForProductModel> getCommentForProductModel =
          Map.of(state.getCommentForProductModel);
      getCommentForProductModel[event.productId] =
          getCommentForProductModel[event.productId]!.copyWith(
              data: getCommentForProductModel[event.productId]!
                  .commentsForProduct!
                  .copyWith(
                      comments: [
            r,
            ...getCommentForProductModel[event.productId]!
                    .commentsForProduct!
                    .comments ??
                []
          ],
                      commentsCount: getCommentForProductModel[event.productId]!
                              .commentsForProduct!
                              .commentsCount! +
                          1));
      emit(state.copyWith(
          addCommentStatus: AddCommentStatus.success,
          getCommentForProductModel: getCommentForProductModel));
    });
  }

  FutureOr<void> _onStoreFcmTokenOfMarketEvent(
      StoreFcmTokenOfMarketEvent event, Emitter<HomeState> emit) async {
    if (event.userId == -1) {
      return;
    }
    final response = await storeFcmTokenOfMarketUseCase(
        StoreFcmTokenOfMarketUseCaseParams(
            fcmToken: event.fcmToken, userId: event.userId));

    response.fold((l) {}, (r) {});
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
        if (!isFailedTheFirstTime
            .contains('CheckAvailabilityProductCartEvent')) {
          add(
            CheckAvailabilityProductCartEvent(),
          );
          isFailedTheFirstTime.add('CheckAvailabilityProductCartEvent');
        }

        emit(
          state.copyWith(
            checkAvailabilityProductCartStatus:
                CheckAvailabilityProductCartStatus.failure,
          ),
        );
      },
      (r) {
        isFailedTheFirstTime.remove('CheckAvailabilityProductCartEvent');

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
    emit(
      state.copyWith(
        getCartOverviewStatus: GetCartOverviewStatus.loading,
      ),
    );

    final response = await getCartOverviewUseCase(NoParams());

    response.fold(
      (l) {
        if (!isFailedTheFirstTime.contains('GetCartOverviewEvent')) {
          add(
            GetCartOverviewEvent(),
          );
          isFailedTheFirstTime.add('GetCartOverviewEvent');
        }

        emit(
          state.copyWith(
            getCartOverviewStatus: GetCartOverviewStatus.failure,
          ),
        );
      },
      (r) {
        List<Cart>? cart = state.getCartShippingItemsModel?.data?.cart;
        GetCartShippingItemsModel? getCartShippingItemsModel =
            r.copyWith(data: r.data?.copyWith(cart: cart));

        isFailedTheFirstTime.remove('GetCartOverviewEvent');

        debugPrint('GetCartOverviewEvent success');

        ////////////////////////////
        emit(
          state.copyWith(
              getCartOverviewStatus: GetCartOverviewStatus.success,
              getCartShippingItemsModel: getCartShippingItemsModel),
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
            ? PaginationModel.init(page: 1)
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
            paginationStatus: PaginationStatus.loading),
      ),
    );
    ///////////////////////////////

    final response = await getUserNotificationUseCase(
      event.getWithPagination ? getUserNotificationModel.page : 1,
    );

    response.fold(
      (l) {
        getUserNotificationModel = state.getUserNotificationModel;

        if (!isFailedTheFirstTime.contains('GetUserNotificationEvent')) {
          add(
            GetUserNotificationEvent(
              getWithPagination: event.getWithPagination,
            ),
          );
          isFailedTheFirstTime.add('GetUserNotificationEvent');
        }

        emit(
          state.copyWith(
            getUserNotificationModel: getUserNotificationModel!
                .copyWith(paginationStatus: PaginationStatus.failure),
          ),
        );
      },
      (r) {
        debugPrint('GetUserNotificationEvent success');

        getUserNotificationModel = state.getUserNotificationModel;

        isFailedTheFirstTime.remove('GetUserNotificationEvent');

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

  FutureOr<void> _onUpdateProfileEvent(
    UpdateProfileEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (event.changeStatusToInit ?? false) {
      emit(
        state.copyWith(updateProfileStatus: UpdateProfileStatus.init),
      );
      return;
    }
    ///////////////////////////
    emit(
      state.copyWith(updateProfileStatus: UpdateProfileStatus.loading),
    );
    ///////////////////////////////

    final response = await updateProfileUseCase(UpdateProfileParams(
        gender: event.gender,
        name: event.name,
        email: event.email,
        image: event.image,
        tall: event.tall,
        idToken: event.idToken,
        weight: event.weight,
        alternative_phone: event.alternative_phone,
        phone: event.phone));

    response.fold(
      (l) {
        if (!isFailedTheFirstTime.contains('UpdateProfileEvent')) {
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
          isFailedTheFirstTime.add('UpdateProfileEvent');
        }

        emit(
          state.copyWith(updateProfileStatus: UpdateProfileStatus.failure),
        );
      },
      (r) async {
        prefsRepository.setMyProfilePhoto((r.data?.image ?? "").toString());
        showMessage(r.message ?? "",
            foreGroundColor: Colors.white,
            backGroundColor: Colors.black,
            showInRelease: true,
            timeShowing: Toast.LENGTH_LONG);
        isFailedTheFirstTime.remove('UpdateProfileEvent');
        prefsRepository.setMyMarketName(r.data?.name ?? "");
        prefsRepository.setVerifiedPhone(r.data?.isPhoneVerified == 1);
        prefsRepository.setPhoneNumber(r.data?.phone ?? "");
        ////////////////////////////

        if ((prefsRepository.chatToken?.length ?? 0) > 6 &&
            (event.name != null ||
                event.image != null ||
                event.phone != null)) {
          GetIt.I<ChatBloc>().add(UpdateProfileInChatEvent(
              userId: prefsRepository.myMarketId.toString(),
              name: r.data?.name ?? "",
              phone: r.data?.phone ?? "",
              photo: r.data?.image ?? ""));

          prefsRepository.setMyChatName((r.data?.name ?? 'No Name'));
          prefsRepository.setMyChatPhoto(r.data?.phone ?? "");
        }
        if ((prefsRepository.storiesToken?.length ?? 0) > 6 &&
            (event.name != null ||
                event.image != null ||
                event.phone != null)) {
          prefsRepository.setMyStoriesName((r.data?.name ?? 'No Name'));

          GetIt.I<AuthBloc>().add(UpdateStoriesUserEvent(
              name: r.data?.name ?? "",
              phone: r.data?.phone ?? "",
              photo: r.data?.image ?? ""));

          prefsRepository.setMyChatName((r.data?.name ?? 'No Name'));
          prefsRepository.setMyChatPhoto(r.data?.phone ?? "");
        }
        emit(
          state.copyWith(
              userInfo: r.data,
              updateProfileStatus: UpdateProfileStatus.success),
        );
        if (event.fromGuest ?? false) {
          GetIt.I<AuthBloc>().add(LoginToStoriesEvent(
            originalUserId: r.data?.id.toString(),
            otpIdToken: prefsRepository.idToken,
            name: r.data?.name,
            phone: r.data?.phone,
          ));
          await NotificationProcess().fcmToken();
          GetIt.I<AuthBloc>().add(LoginToChatEvent(
            fcmToken: NotificationProcess.myFcmToken!,
            mobilePhone: r.data?.phone,
            name: r.data?.name,
            originalUserId: r.data?.id.toString(),
            otpIdToken: prefsRepository.idToken,
          ));
        }
      },
    );
  }

  _onUploadUserPhptoCloudinaryEvent(
      UploadUserPhotoCloudinaryEvent event, Emitter emit) async {
    if (event.changeStatusToFailure ?? false) {
      emit(state.copyWith(
          uploadUserPhotoCloudinaryStatus:
              UploadUserPhotoCloudinaryStatus.failure));

      showMessage('${LocaleKeys.your_request_faild.tr()}',
          foreGroundColor: Colors.white,
          backGroundColor: Colors.black,
          showInRelease: true,
          timeShowing: Toast.LENGTH_LONG);
      return;
    }
    emit(state.copyWith(
        uploadUserPhotoCloudinaryStatus:
            UploadUserPhotoCloudinaryStatus.loading));
    final response = await uploadFileCloudinaryUseCase(
            UpdatePhotoParams(path: "customers/profile", image: event.file))
        .catchError((e) {
      showMessage('${LocaleKeys.your_request_faild.tr()}',
          foreGroundColor: Colors.white,
          backGroundColor: Colors.black,
          showInRelease: true,
          timeShowing: Toast.LENGTH_LONG);
      emit(state.copyWith(
          uploadUserPhotoCloudinaryStatus:
              UploadUserPhotoCloudinaryStatus.failure));
    });
    // Fluttertoast.showToast(msg: 'tosss');
    response.fold(
      (l) {
        if (isFailedTheFirstTime.contains('UploadUserPhptoCloudinaryEvent')) {
          isFailedTheFirstTime.remove('UploadUserPhptoCloudinaryEvent');

          return;
        } else {
          isFailedTheFirstTime.insert(
              isFailedTheFirstTime.length, 'UploadUserPhptoCloudinaryEvent');
          add(UploadUserPhotoCloudinaryEvent(
              event.file, event.changeStatusToFailure));
        }
      },
      (r) {
        add(UpdateProfileEvent(image: r.data?.subPath));
        emit(state.copyWith(
            uploadUserPhotoCloudinaryStatus:
                UploadUserPhotoCloudinaryStatus.success));
        isFailedTheFirstTime.remove('UploadUserPhptoCloudinaryEvent');
      },
    );
  }
}
