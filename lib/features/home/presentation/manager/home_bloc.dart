import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smartlook/flutter_smartlook.dart';
import 'package:flutter_svg_image/flutter_svg_image.dart';
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
import 'package:trydos/features/app/blocs/pre_caching_image_bloc/pre_caching_image_bloc.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/authentication/domain/use_cases/get_customer_info_usecase.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/home/data/models/get_address_by_coordinates_model.dart';
import 'package:trydos/features/home/data/models/get_address_by_text_model.dart';
import 'package:trydos/features/home/data/models/get_cart_item_model.dart';
import 'package:trydos/features/home/data/models/get_comment_for_product_model.dart';
import 'package:trydos/features/home/data/models/get_home_boutiqes_model.dart';
import 'package:trydos/features/home/data/models/get_list_of_customer_addresses_model.dart';
import 'package:trydos/features/home/data/models/get_old_cart_model.dart'
    as oldCart;
import 'package:trydos/features/home/data/models/get_product_detail_without_related_products_model.dart';
import 'package:trydos/features/home/data/models/get_product_filters_model.dart'
    as filters_model;
import 'package:trydos/features/home/data/models/get_product_listing_with_filters_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as product;
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart';
import 'package:trydos/features/home/data/models/main_categories_response_model.dart';
import 'package:trydos/features/home/data/models/popular_search_terms_model.dart';
import 'package:trydos/features/home/data/models/starting_settings_response_model.dart';
import 'package:trydos/features/home/domain/use_cases/GetCommentForProductUseCase.dart';
import 'package:trydos/features/home/domain/use_cases/add_comment_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/add_customer_address_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/add_like_to_product_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/change_country_language_for_notification_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/convert_item_from_oldCart_to_Cart_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/delete_customer_address_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/delete_like_of_product_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_address_by_coordinate_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_address_by_text_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_allowed_country_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_cart_item_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_count_view_of_product_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_currency_for_country_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_customer_addresses_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_full_product_details_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_home_boutiqes_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_main_categories_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_my_firebase_settings_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_notification_type_for_product_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_old_cart_item_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_popular_search_terms_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_product_detail_without_related_products_uswcase.dart';
import 'package:trydos/features/home/domain/use_cases/get_product_filters_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_product_list_in_cart_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_products_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_products_with_filters_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_starting_settings_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/hide_item_from_oldCart_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/remove_item_from_cart_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/request_for_notification_when_product_became_available_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/send_error_to_mobile_error_log.dart';
import 'package:trydos/features/home/domain/use_cases/store_fcm_token_of_market_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/subscribe_topic_for_notification_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/un_subscribe_topic_for_notification_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/update_customer_address_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/update_email_notification_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/update_firebase_notification_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/update_item_from_cart_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/update_notification_frequency_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/update_whatsapp_notification_usecase.dart';
import 'package:trydos/features/home/presentation/widgets/cart_section/add_shipping_address.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_sheet_bottom_bar.dart';
import 'package:trydos/features/story/domain/useCases/get_width_and_height_usecase.dart';
import 'package:trydos/features/story/presentation/bloc/story_state.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/notification_service/notification_service/handle_notification/handling_market_notifications.dart';
import 'package:uuid/uuid.dart';
import '../../../../common/helper/helper_functions.dart';
import '../../../../core/data/model/pagination_model.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../main.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_executed_event_name.dart';
import '../../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../../app/my_cached_network_image.dart';
import '../../../chat/presentation/manager/chat_bloc.dart';
import '../../../chat/presentation/manager/chat_event.dart';
import '../../../story/presentation/bloc/story_bloc.dart';
import '../../domain/use_cases/add_item_to_cart_usecase.dart';
import '../../domain/use_cases/get_customer_wallet_usecase.dart';
import '../../domain/use_cases/get_orders_by_order_group_usecase.dart';
import '../../domain/use_cases/get_stories_for_product_usecase.dart';
import '../../domain/use_cases/place_order_usecase.dart';
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
    this.getMainCategoriesUseCase,
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
    this.getHomeBoutiqesUseCase,
    this.deleteCustomerAddressUseCase,
    this.addCustomerAddressUseCase,
    this.updateCustomerAddressUseCase,
    this.getProductsListInCartUseCase,
    this.getProductFiltersUseCase,
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
    this.getAddressByCoordinatesUsecase,
    this.getAddressByTextUsecase,
    this.getCustomerAddressesUseCase,
    this.getCurrencyForCountryUseCase,
    this.hideItemsInOldCartUseCase,
    this.getFullProductDetailsUseCase,
    this.getCustomerInfoUseCase,
    this.getAndAddCountViewOfProductUsecase,
    this.sendErrorToMobileErrorLogUseCase,
    this.getProductsWithoutFiltersUseCase,
    this.addCommentUseCase,
    this.requestForNotificationWhenProductBecameAvailableUseCase,
    this.getProductsWithFiltersUseCase,
    this.getCustomerWalletUseCase,
    this.placeOrderUsecase,
    this.getOrdersByOrderGroupIDUsecase,
  ) : super(HomeState()) {
    on<HomeEvent>((event, emit) {});

    on<ResetAllSelectedAppliedFilterEvent>(
      _onResetAllSelectedAppliedFilterEvent,
    );
    on<GetAndAddCountViewOfProductEvent>(
      _onGetAndAddCountViewOfProductEvent,
    );
    on<GetAddressByCoordinatesEvent>(
      _onGetAddressByCoordinatesEvent,
    );
    on<GetCustomerWalletEvent>(
      _onGetCustomerWalletEvent,
    );
    on<GetAddressByTextEvent>(_onGetAddressByTextEvent,
        transformer: restartable());

    on<EditAdressInfoClassEvent>(
      _onEditAdressInfoClassEvent,
    );
    on<GetCustomerAddressesEvent>(
      _onGetCustomerAddressesEvent,
    );
    on<GetNotificationTypeProductEvent>(_onGetNotificationTypeProductEvent);
    on<DeleteAdressInfoClassEvent>(
      _onDeleteAdressInfoClassEvent,
    );
    on<AddAddressInfoClassEvent>(
      _onAddAddressInfoClassEvent,
    );

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

    on<AddPrefAppliedFilterForExtendFilterEvent>(
      _onAddPrefAppliedFilterForExtendFilterEvent,
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
    on<AddOrRemoveLikeForProductEvent>(_onAddOrRemoveLikeForProductEvent,
        transformer: throttleDroppable(Duration(seconds: 3)));

    on<AddIsExpandedForLidtingPageEvent>(
      _onAddIsExpandedForLidtingPageEvent,
    );
    /* on<GetSearchREsultEvent>(
      _onGetSearchResultEventEvent,
    );*/

    on<GetProductWithFiltersWithoutCancelingPreviousEvents>(
        _onGetWithProductFiltersWithoutCancelingPreviousEvents);
    on<GetProductFiltersEvent>(_onGetProductFiltersEvent,
        transformer: restartable());
    on<ChangeSelectedFiltersEvent>(_onChangeSelectedFiltersEvent);
    on<ReplyFromGeminiEvent>(_onReplyFromGeminiEvent);
    on<ChangeAppliedFiltersEvent>(_onChangeAppliedFiltersEvent);
    on<AddSearchTextToHistoryEvent>(
      _onAddSearchTextToHistoryEvent,
    );
    // on<GetBrandEvent>(_onGetBrandEvent,
    //     transformer: throttleDroppable(throttleDuration));
    //  on<GetCategoryEvent>(_onGetCategoryEvent,
//transformer: throttleDroppable(throttleDuration));
    on<GetHomeBoutiqesEvent>(
      _onGetHomeBoutiquesEvent,
    );
    on<GetCartItemEvent>(_onGetCartItemEvent, transformer: restartable());

    on<GetAllowedCountriesEvent>(_onGetAllowedCountriesEvent,
        transformer: throttleDroppable(throttleDuration));

    on<GetStartingSettingsEvent>(
      _onGetStartingSettingsEvent,
    );
    on<GetMainCategoriesEvent>(
      _onGetMainCategoriesEvent,
    );
    on<IscashedOreiginBotiqueEvent>(
      _onIscashedOreiginBotiqueEvent,
    );
    on<AddItemToCartEvent>(
      _onAddItemToCartEvent,
    );
    on<ChangeCurrentIndexForMainCategoryEvent>(
      _onChangeCurrentIndexForMainCategoryEvent,
    );

    on<AddMultiItemsToCartEvent>(
      _onAddMultiItemsToCartEvent,
    );
    on<AddTimerStartedToHurryUpEvent>(
      _onAddTimerStartedToHurryUpEvent,
    );

    on<GetSearchListingResultEvent>(
      _onGetSearchListingResultEventEvent,
    );

    on<GetProductsWithFiltersEvent>(_onGetProductsWithFiltersEvent,
        transformer: restartable());
    /*  on<GetProductsWithFiltersUsingPaginationEvent>(
        _onGetProductsWithFiltersUsingPaginationEvent,
        transformer: restartable());*/

    on<GetProductFiltersWithPrefetchForFiveFiltersEvent>(
      _onGetProductFiltersWithPrefetchForFiveFiltersEvent,
    );
    on<GetProductsWithFiltersWithPrefetchForFiveFiltersEvent>(
      _onGetProductsWithFiltersWithPrefetchForFiveFiltersEvent,
    );

    /* on<GetProductsWithFiltersEventWithoutCancelingPreviousEvents>(
        _onGetProductsWithFiltersEventWithoutCancelingPreviousEvents);*/
    on<UpdateItemInCartEvent>(_onUpdateItemInCartEvent,
        transformer: restartable());
    on<RemoveSearchTextfromHistoryEvent>(
      _onRemoveSearchTextToHistoryEvent,
    );
    on<HideItemInOldCartEvent>(
      _onHideItemInOldCartEvent,
    );

    on<GetProductsWithoutFiltersEvent>(
      _onGetProductsWithoutFiltersEvent,
    );
    on<GetStoryForProductEvent>(_onGetStoryEvent,
        transformer: throttleDroppable(Duration(seconds: 5)));
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
    );

    on<GetFullProductDetailsEvent>(
      _onGetFullProductDetailsEvent,
    );

    on<ConvertItemFromCartToOldCartEvent>(
      _onConvertItemFromCartToOldCartEvent,
    );
    on<GetCommentForProductEvent>(
      _onGetCommentForProductEvent,
    );
    on<PlaceOrderEvent>(
      _onPlaceOrderEvent,
    );
    on<GetOrdersByOrderGroupIDEvent>(
      _onGetOrdersByOrderGroupIDEvent,
    );
  }

  Map<String, bool> boutiquesThatEnablesToRequestItsProductsUsingFiveFilters =
      {};
  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  final GetStartingSettingsUseCase getStartingSettingsUseCase;

  final GetWidthAndHeightUseCase getWidthAndHeightUseCase;
  final GetHomeBoutiqesUseCase getHomeBoutiqesUseCase;
  final GetCartItemUseCase getCartItemUseCase;
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
  final GetCustomerAddressesUseCase getCustomerAddressesUseCase;
  final GetCustomerInfoUseCase getCustomerInfoUseCase;
  final GetProductDetailWithoutRelatedProductsUseCase
      getProductDetailWithoutRelatedProductsUseCase;
  final GetAddressByTextUsecase getAddressByTextUsecase;
  final GetAddressByCoordinatesUsecase getAddressByCoordinatesUsecase;
  final GetPopularSearchItemUseCase getPopularSearchItemUseCase;
  final GetCurrencyForCountryUseCase getCurrencyForCountryUseCase;
  final RequestForNotificationWhenProductBecameAvailableUseCase
      requestForNotificationWhenProductBecameAvailableUseCase;
  final AddLikeToProductUsecase addLikeToProductUsecase;
  final DeleteLikeOfProductUsecase deleteLikeOfProductUsecase;
  // final GetBrandUseCase getBrandUseCase;

  // final GetCategoryUseCase getCategoryUseCase;
  final GetProductsWithFiltersUseCase getProductsWithFiltersUseCase;
  final RemoveItemToCartUseCase removeItemToCartUseCase;
  final GetMainCategoriesUseCase getMainCategoriesUseCase;
  final GetProductFiltersUseCase getProductFiltersUseCase;
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
  final AddCustomerAddressUseCase addCustomerAddressUseCase;
  final UpdateCustomerAddressUseCase updateCustomerAddressUseCase;
  final DeleteCustomerAddressUseCase deleteCustomerAddressUseCase;
  final PlaceOrderUsecase placeOrderUsecase;
  final GetOrdersByOrderGroupIDUsecase getOrdersByOrderGroupIDUsecase;

  final GetCustomerWalletUseCase getCustomerWalletUseCase;

  final SubscribeTopicFornotificationUseCase
      subscribeTopicFornotificationUseCase;
  final UnSubscribeTopicFornotificationUseCase
      unSubscribeTopicFornotificationUseCase;
  final ChangeCountryLanguageFornotificationUseCase
      changeCountryLanguageFornotificationUseCase;
  final GetMyFirebaseSettingsUseCase getMyFirebaseSettingsUseCase;

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

      /*   if (!(prefsRepository.isSmartlookStarted ?? false)) {
        prefsRepository.setIsSmartlookStarted(true);
        Logger(printer: PrettyPrinter(methodCount: 0)).i('SMARTLOOK STARTED!');
     initializeSmartLook();
      }
*/
      emit(state.copyWith(
          startingSetting: r.data!.startingSetting,
          getStartingSettingsStatus: GetStartingSettingsStatus.success));
    });
  }

  FutureOr<void> _onReplyFromGeminiEvent(
      ReplyFromGeminiEvent event, Emitter<HomeState> emit) async {
    if (event.sendRequestToGeminiStatus != null) {
      emit(state.copyWith(
          theReplyFromGemini:
              !event.resetTheReply ? event.theReplyFromGemini : "",
          fromSearchForSearchWithGemini: event.fromSearch,
          sendRequestToGeminiStatus: event.sendRequestToGeminiStatus));
    }

    emit(state.copyWith(
      theReplyFromGemini: !event.resetTheReply ? event.theReplyFromGemini : "",
      fromSearchForSearchWithGemini: event.fromSearch,
    ));
  }

  FutureOr<void> _onAddAddressInfoClassEvent(
      AddAddressInfoClassEvent event, Emitter<HomeState> emit) async {
    final List<CustomerAddressesInfo> listOfAddressInfoClassToSave =
        List.of(state.listOfAddressInfoClassToSave ?? []);
    CustomerAddressesInfo adressInfoClassToSave = event.addressInfoClassToSave!;
    listOfAddressInfoClassToSave.insert(0, adressInfoClassToSave);
    emit(state.copyWith(
        listOfAdressInfoClassToSave: listOfAddressInfoClassToSave,
        addAddressToOrderStatus: AddAddressToOrderStatus.loading));

    final response = await addCustomerAddressUseCase(AddCustomerAddressParams(
      address: event.addressInfoClassToSave?.address ?? "",
      addressDetail: event.addressInfoClassToSave?.addressDetail ?? "",
      country: event.addressInfoClassToSave?.regionDetails?.country ?? "",
      city: event.addressInfoClassToSave?.regionDetails?.city ?? "",
      district: event.addressInfoClassToSave?.regionDetails?.city ?? "",
      town: event.addressInfoClassToSave?.regionDetails?.town ?? "",
      street: event.addressInfoClassToSave?.regionDetails?.street ?? "",
      zip: "",
      phone: event.addressInfoClassToSave?.contactInfo?.phone ?? "",
      alternativePhone:
          event.addressInfoClassToSave?.contactInfo?.alternativePhone ?? "",
      latitude: event.addressInfoClassToSave?.location?.latitude ?? "",
      longitude: event.addressInfoClassToSave?.location?.longitude ?? "",
      province: event.addressInfoClassToSave?.regionDetails?.province ?? "",
      building: event.addressInfoClassToSave?.regionDetails?.building ?? "",
      contactPersonName: event.addressInfoClassToSave?.contactInfo?.name ?? "",
    ));

    response.fold((l) {
      if (!isFailedTheFirstTime.contains('addCustomerAddress')) {
        add(AddAddressInfoClassEvent(
            addressInfoClassToSave: event.addressInfoClassToSave));
        isFailedTheFirstTime.add('addCustomerAddress');
      }
      showMessage(l.message,
          foreGroundColor: Colors.white,
          backGroundColor: Colors.black,
          showInRelease: true,
          timeShowing: Toast.LENGTH_LONG);
      final List<CustomerAddressesInfo> listOfAddressInfoClassToSave =
          List.of(state.listOfAddressInfoClassToSave ?? []);
      listOfAddressInfoClassToSave.removeAt(0);
      emit(state.copyWith(
          listOfAdressInfoClassToSave: listOfAddressInfoClassToSave,
          addAddressToOrderStatus: AddAddressToOrderStatus.failure));
    }, (r) async {
      add(GetCustomerAddressesEvent());
      showMessage(r.message ?? "",
          foreGroundColor: Colors.white,
          backGroundColor: Colors.black,
          showInRelease: true,
          timeShowing: Toast.LENGTH_LONG);
      isFailedTheFirstTime.remove('addCustomerAddress');

      emit(state.copyWith(
          addAddressToOrderStatus: AddAddressToOrderStatus.success,
          listOfAdressInfoClassToSave: listOfAddressInfoClassToSave));
    });
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

  FutureOr<void> _onGetCustomerAddressesEvent(
      GetCustomerAddressesEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(
        getCustomerAddressesStatus: GetCustomerAddressesStatus.loading));
    final response = await getCustomerAddressesUseCase(NoParams());

    response.fold((l) {
      if (!isFailedTheFirstTime.contains('getCustomerAddresses')) {
        add(GetCustomerAddressesEvent());
        isFailedTheFirstTime.add('getCustomerAddresses');
      }

      emit(state.copyWith(
          getCustomerAddressesStatus: GetCustomerAddressesStatus.failure));
    }, (r) async {
      isFailedTheFirstTime.remove('getCustomerAddresses');
      List<CustomerAddressesInfo>? listOfAdressInfoClassToSave = [];
      listOfAdressInfoClassToSave = [...r.data!];
      emit(state.copyWith(
        listOfAdressInfoClassToSave: List.of(listOfAdressInfoClassToSave),
        getCustomerAddressesStatus: GetCustomerAddressesStatus.success,
      ));
    });
  }

  FutureOr<void> _onDeleteAdressInfoClassEvent(
      DeleteAdressInfoClassEvent event, Emitter<HomeState> emit) async {
    final List<CustomerAddressesInfo> listOfAddressInfoClassToSave =
        List.of(state.listOfAddressInfoClassToSave ?? []);
    int index = listOfAddressInfoClassToSave
        .indexWhere((element) => element.id == event.adressInfoClassId);
    CustomerAddressesInfo preCustomerAddress =
        listOfAddressInfoClassToSave[index];

    listOfAddressInfoClassToSave
        .removeWhere((element) => element.id == event.adressInfoClassId);
    emit(state.copyWith(
        listOfAdressInfoClassToSave: listOfAddressInfoClassToSave,
        removeAddressToOrderStatus: RemoveAddressToOrderStatus.loading));
    final response = await deleteCustomerAddressUseCase(
        DeleteCustomerAddressParams(addressId: event.adressInfoClassId ?? 0));

    response.fold((l) {
      if (!isFailedTheFirstTime.contains('deleteCustomerAddress')) {
        add(DeleteAdressInfoClassEvent(
            adressInfoClassId: event.adressInfoClassId));
        isFailedTheFirstTime.add('deleteCustomerAddress');
      }
      showMessage(l.message,
          foreGroundColor: Colors.white,
          backGroundColor: Colors.black,
          showInRelease: true,
          timeShowing: Toast.LENGTH_LONG);
      final List<CustomerAddressesInfo> listOfAddressInfoClassToSave =
          List.of(state.listOfAddressInfoClassToSave ?? []);
      listOfAddressInfoClassToSave.insert(index, preCustomerAddress);
      emit(state.copyWith(
          listOfAdressInfoClassToSave: listOfAddressInfoClassToSave,
          removeAddressToOrderStatus: RemoveAddressToOrderStatus.failure));
    }, (r) async {
      add(GetCustomerAddressesEvent());
      showMessage(r.message ?? "",
          foreGroundColor: Colors.white,
          backGroundColor: Colors.black,
          showInRelease: true,
          timeShowing: Toast.LENGTH_LONG);
      isFailedTheFirstTime.remove('deleteCustomerAddress');

      emit(state.copyWith(
          removeAddressToOrderStatus: RemoveAddressToOrderStatus.success,
          listOfAdressInfoClassToSave: listOfAddressInfoClassToSave));
    });
  }

  FutureOr<void> _onEditAdressInfoClassEvent(
      EditAdressInfoClassEvent event, Emitter<HomeState> emit) async {
    final List<CustomerAddressesInfo> listOfAddressInfoClassToSave =
        List.of(state.listOfAddressInfoClassToSave ?? []);

    int index = listOfAddressInfoClassToSave
        .indexWhere((element) => element.id == event.preIdToEdit);
    CustomerAddressesInfo preCustomerAddresses =
        listOfAddressInfoClassToSave[index];
    listOfAddressInfoClassToSave
        .removeWhere((element) => element.id == event.preIdToEdit);

    listOfAddressInfoClassToSave.insert(index, event.addressInfoClassToSave!);
    emit(state.copyWith(
        listOfAdressInfoClassToSave: listOfAddressInfoClassToSave,
        editAddressToOrderStatus: EditAddressToOrderStatus.loading));
    final response =
        await updateCustomerAddressUseCase(UpdateCustomerAddressParams(
      id: event.preIdToEdit,
      address: event.addressInfoClassToSave?.address ?? "",
      addressDetail: event.addressInfoClassToSave?.addressDetail ?? "",
      country: event.addressInfoClassToSave?.regionDetails?.country ?? "",
      city: event.addressInfoClassToSave?.regionDetails?.city ?? "",
      district: event.addressInfoClassToSave?.regionDetails?.city ?? "",
      town: event.addressInfoClassToSave?.regionDetails?.town ?? "",
      street: event.addressInfoClassToSave?.regionDetails?.street ?? "",
      zip: "",
      phone: event.addressInfoClassToSave?.contactInfo?.phone ?? "",
      alternativePhone:
          event.addressInfoClassToSave?.contactInfo?.alternativePhone ?? "",
      latitude: event.addressInfoClassToSave?.location?.latitude ?? "",
      longitude: event.addressInfoClassToSave?.location?.longitude ?? "",
      province: event.addressInfoClassToSave?.regionDetails?.province ?? "",
      building: event.addressInfoClassToSave?.regionDetails?.building ?? "",
      contactPersonName: event.addressInfoClassToSave?.contactInfo?.name ?? "",
    ));

    response.fold((l) {
      if (!isFailedTheFirstTime.contains('updateCustomerAddress')) {
        add(EditAdressInfoClassEvent(
          addressInfoClassToSave: event.addressInfoClassToSave,
          preIdToEdit: event.preIdToEdit,
        ));
        showMessage(l.message,
            foreGroundColor: Colors.white,
            backGroundColor: Colors.black,
            showInRelease: true,
            timeShowing: Toast.LENGTH_LONG);
        isFailedTheFirstTime.add('updateCustomerAddress');
      }
      final List<CustomerAddressesInfo> listOfAddressInfoClassToSave =
          List.of(state.listOfAddressInfoClassToSave ?? []);
      listOfAddressInfoClassToSave.insert(index, preCustomerAddresses);
      emit(state.copyWith(
          listOfAdressInfoClassToSave: listOfAddressInfoClassToSave,
          editAddressToOrderStatus: EditAddressToOrderStatus.failure));
    }, (r) async {
      add(GetCustomerAddressesEvent());
      showMessage(r.message ?? "",
          foreGroundColor: Colors.white,
          backGroundColor: Colors.black,
          showInRelease: true,
          timeShowing: Toast.LENGTH_LONG);
      isFailedTheFirstTime.remove('updateCustomerAddress');

      emit(state.copyWith(
          editAddressToOrderStatus: EditAddressToOrderStatus.success,
          listOfAdressInfoClassToSave: listOfAddressInfoClassToSave));
    });
  }

  FutureOr<void> _onGetMainCategoriesEvent(
      GetMainCategoriesEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(
        getMainCategoriesStatus: GetMainCategoriesStatus.loading));
    /* Future.delayed(
      Duration(seconds: 50),
      () {
        if (state.getMainCategoriesStatus == GetMainCategoriesStatus.loading) {
          emit(state.copyWith(moveUrlFromElasticToMarketServer: true));

          add(GetMainCategoriesEvent(getWithPrefech: event.getWithPrefech));
        }
      },
    );
*/
    final response = await getMainCategoriesUseCase(GetMainCategoryParams());

    response.fold((l) {
      /* if (l.statusCode == 400 &&
          !isFailedTheFirstTime.contains('GetMainCategoriesEvent')) {
        emit(state.copyWith(moveUrlFromElasticToMarketServer: true));
        add(GetMainCategoriesEvent(getWithPrefech: event.getWithPrefech));
        isFailedTheFirstTime.add('GetMainCategoriesEvent');
        return;
      }*/

      if (!isFailedTheFirstTime.contains('GetMainCategoriesEvent')) {
        add(GetMainCategoriesEvent(context: event.context));
        isFailedTheFirstTime.add('GetMainCategoriesEvent');
      }
      emit(state.copyWith(
          getMainCategoriesStatus: GetMainCategoriesStatus.failure));
    }, (r) async {
      requestAPIAfterHome();

      apisMustNotToRequest.add('GetMainCategoriesEvent');
      isFailedTheFirstTime.remove('GetMainCategoriesEvent');
      if (state.boutiquesForEveryMainCategoryThatDidPrefetch['Empty'] != true) {
        add(GetHomeBoutiqesEvent(
          getWithPrefetchForBoutiques: true,
          context: event.context ?? navigatorKey.currentContext!,
          categorySlug: 'Empty',
          offset: "1",
        ));
      }
      emit(state.copyWith(
          mainCategoriesResponseModel: r,
          getMainCategoriesStatus: GetMainCategoriesStatus.success));
      List<String> categorySlugs = [];
      for (var i = 0; i < r.data!.mainCategories!.length; i++) {
        categorySlugs.add(r.data!.mainCategories![i].slug ?? "");
      }
      print(
          "12222222222222222222222221111${categorySlugs}11///////////////////////////////////////////////////////////////////////////////////////");

      if (event.getWithPrefech) {
        Future.delayed(Duration(seconds: 5), () {
          for (var i = 0;
              i < min(categorySlugs.length, (1.sw - 55) ~/ 40);
              i++) {
            if (state.boutiquesForEveryMainCategoryThatDidPrefetch[
                    categorySlugs[i]] !=
                true) {
              add(GetHomeBoutiqesEvent(
                getWithPrefetchForBoutiques: false,
                context: event.context ?? navigatorKey.currentContext!,
                categorySlug: categorySlugs[i],
                offset: "1",
              ));
            }
          }
        });
      }
    });
  }

  void requestAPIAfterHome() {
    if (prefsRepository.marketToken != null) {
      GetIt.I<AuthBloc>().add(GetCustomerInfoEvent());
    }
    add(GetStartingSettingsEvent());
    if (GetIt.I<ChatBloc>().state.firstRequestForGetChats) {
      if (prefsRepository.chatToken != null) {
        GetIt.I<ChatBloc>().add(GetChatsEvent(limit: 10));
      }
    }
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
    Map<String, int> currentSelectedColorForEveryProduct =
        Map.of(state.currentSelectedColorForEveryProduct);
    if (currentSelectedColorForEveryProduct[event.productId] == null) {
      currentSelectedColorForEveryProduct
          .addAll({event.productId: event.currentSelectedColor});
    } else {
      currentSelectedColorForEveryProduct[event.productId] =
          event.currentSelectedColor;
    }

    emit(state.copyWith(
        currentSelectedColorForEveryProduct:
            Map.of(currentSelectedColorForEveryProduct)));
  }

  _onClearAllAppCashEvent(ClearAllAppCashEvent event, Emitter<HomeState> emit) {
    emit(state.copyWith(
      currentSelectedColorForEveryProduct: {},
      reRequestTheseProductListingInBoutiques: {},
      reRequestTheseBoutiques: {},
      reRequestProductWithFilters: {},
      getProductFiltersStatus: {},
      productStatus: {},
      boutiquesThatDidPrefetch: {},
      cartIdsHurryUPTimerStarted: {},
      listOfErrorSendedToMobileErrorLog: [],
      getProductFiltersWithPrefetchModel: {},
      getProductListingWithFiltersPaginationWithPrefetchModels: {},
      boutiquesForEveryMainCategoryThatDidPrefetch: {},
      choosedFiltersByUser: {},
      appliedFiltersByUser: {},
      cashedOrginalBoutique: false,
      isGettingProductListingWithPagination: false,
      ListitemForAddToCart: [],
      getMainCategoriesStatus: GetMainCategoriesStatus.init,
      getAndAddCountViewOfProductStatus: {},
      getProductDetailWithoutSimilarRelatedProductsStatus:
          GetProductDetailWithoutSimilarRelatedProductsStatus.init,
      getStartingSettingsStatus: GetStartingSettingsStatus.init,
      mainCategoriesResponseModel: MainCategoriesResponseModel(),
      getListOfProductsFoundedInCartStatus:
          GetListOfProductsFoundedInCartStatus.init,
      cachedProductWithoutRelatedProductsModel: {},
      getProductListingWithFiltersPaginationModels: {},
      getHomeBoutiquesPaginationObjectByMainCategory: {},
      productITemForCart: {},
      getProductListingStatus: GetProductListingStatus.init,
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
        GetIt.I<HomeBloc>()
            .add(GetStoryForProductEvent(productId: event.productId));
      }
    }, (r) {
      apisMustNotToRequest.add('GetStoryEvent');

      emit(state.copyWith(
        storiesForProduct: r.data!.story,
        getStoriesForProductStatus: GetStoriesForProductStatus.success,
      ));
    });
  }

  /* Map<String, PaginationModel<HomeSectionDataObject>>
        getHomeSectionsPaginationObject =
        Map.of(state.getHomeSectionsPaginationObject);
    if (getHomeSectionsPaginationObject[event.categorySlug] == null) {
      getHomeSectionsPaginationObject[event.categorySlug] =
          const PaginationModel<HomeSectionDataObject>.init();
    }
    if (!event.getWithPagination &&
        (getHomeSectionsPaginationObject[event.categorySlug]!
                .items
                .isNotEmpty ||
            getHomeSectionsPaginationObject[event.categorySlug]!
                    .paginationStatus ==
                PaginationStatus.loading)) {
      print('zzzzzzzzzzzzzzzz');
      print('$getHomeSectionsPaginationObject');
      print('${!event.getWithPagination}');
      print(
          '${getHomeSectionsPaginationObject[event.categorySlug]!.items.isNotEmpty}');
      print(
          '${getHomeSectionsPaginationObject[event.categorySlug]!.paginationStatus == PaginationStatus.loading}');
      return;
    }
    getHomeSectionsPaginationObject[event.categorySlug] =
        getHomeSectionsPaginationObject[event.categorySlug]!
            .copyWith(paginationStatus: PaginationStatus.loading);
    emit(state.copyWith(
        getHomeSectionsPaginationObject: getHomeSectionsPaginationObject));
    final response =
        await getHomeSectionsUseCase(GetHomeSectionsParams(event.categorySlug));

    response.fold((l) {
      if (!isFailedTheFirstTime.contains('GetHomeSectionsEvent')) {
        add(GetHomeSectionsEvent(event.categorySlug));
        isFailedTheFirstTime.add('GetHomeSectionsEvent');
      }
      getHomeSectionsPaginationObject[event.categorySlug] =
          getHomeSectionsPaginationObject[event.categorySlug]!
              .copyWith(paginationStatus: PaginationStatus.failure);
      emit(state.copyWith(
          getHomeSectionsPaginationObject: getHomeSectionsPaginationObject));
    }, (r) {
      isFailedTheFirstTime.remove('GetHomeSectionsEvent');
      if (state.getMainCategoriesStatus == GetMainCategoriesStatus.success) {
        requestAPIAfterHome();
      }
      getHomeSectionsPaginationObject[event.categorySlug] =
          getHomeSectionsPaginationObject[event.categorySlug]!.copyWith(
              paginationStatus: PaginationStatus.success,
              page:
                  getHomeSectionsPaginationObject[event.categorySlug]!.page + 1,
              hasReachedMax: r.data!.length >= kPageSize,
              items: [
            ...getHomeSectionsPaginationObject[event.categorySlug]!.items,
            ...r.data!
          ]);
      emit(state.copyWith(
          getHomeSectionsPaginationObject: getHomeSectionsPaginationObject));
    });
  }
  */

  FutureOr<void> _onGetHomeBoutiquesEvent(
      GetHomeBoutiqesEvent event, Emitter<HomeState> emit) async {
    Map<String, PaginationModel<Boutique>>
        getHomeBoutiquesPaginationObjectByMainCategory =
        Map.of(state.getHomeBoutiquesPaginationObjectByMainCategory);

    if (getHomeBoutiquesPaginationObjectByMainCategory[event.categorySlug] ==
        null) {
      getHomeBoutiquesPaginationObjectByMainCategory[event.categorySlug] =
          const PaginationModel<Boutique>.init();
    }

    if (event.getWithPagination &&
        (getHomeBoutiquesPaginationObjectByMainCategory[event.categorySlug]!
                .hasReachedMax ||
            getHomeBoutiquesPaginationObjectByMainCategory[event.categorySlug]!
                    .paginationStatus ==
                PaginationStatus.loading) &&
        !event.forRefresh) {
      return;
    }
    Map<String, bool> boutiquesForEveryMainCategoryThatDidPrefetch =
        Map.of(state.boutiquesForEveryMainCategoryThatDidPrefetch);
    if (!event.getWithPrefetchForBoutiques) {
      if (boutiquesForEveryMainCategoryThatDidPrefetch[event.categorySlug] ==
          null) {
        boutiquesForEveryMainCategoryThatDidPrefetch
            .addAll({event.categorySlug: false});
      }
      if (boutiquesForEveryMainCategoryThatDidPrefetch[event.categorySlug] ==
              true &&
          event.offset == '1' &&
          !event.forRefresh) {
        return;
      }
      boutiquesForEveryMainCategoryThatDidPrefetch[event.categorySlug] = true;
    }
    emit(state.copyWith(
        boutiquesForEveryMainCategoryThatDidPrefetch:
            Map.of(boutiquesForEveryMainCategoryThatDidPrefetch),
        getHomeBoutiquesPaginationObjectByMainCategory:
            getHomeBoutiquesPaginationObjectByMainCategory.map((key, value) {
          if (key == event.categorySlug)
            return MapEntry(key,
                value.copyWith(paginationStatus: PaginationStatus.loading));
          return MapEntry(key, value);
        })));
    /*Future.delayed(
      Duration(seconds: 50),
      () {
        if (state
                .getHomeBoutiquesPaginationObjectByMainCategory[
                    event.categorySlug]
                ?.paginationStatus ==
            PaginationStatus.loading) {
          emit(state.copyWith(moveUrlFromElasticToMarketServer: true));

          add(GetHomeBoutiqesEvent(
              getWithPrefetchForBoutiques: event.getWithPrefetchForBoutiques,
              offset: event.offset,
              context: event.context,
              categorySlug: event.categorySlug,
              getWithPagination: event.getWithPagination));
        }
      },
    );*/
    final response = await getHomeBoutiqesUseCase(GetHomeBoutiqesParams(
        page: event.getWithPagination
            ? (getHomeBoutiquesPaginationObjectByMainCategory[
                        event.categorySlug]
                    ?.page ??
                1)
            : 1,
        offset: event.offset == '1' ? null : event.offset,
        categorySlug:
            event.categorySlug == "Empty" ? null : event.categorySlug));
    /*await Future.delayed(
      Duration(seconds: 50),
      () {
        if (getHomeBoutiquesPaginationObjectByMainCategory[event.categorySlug]!
                .paginationStatus ==
            PaginationStatus.loading) {
          emit(state.copyWith(moveUrlFromElasticToMarketServer: true));
          add(GetHomeBoutiqesEvent(
              getWithPrefetchForBoutiques: event.getWithPrefetchForBoutiques,
              offset: event.offset,
              context: event.context,
              categorySlug: event.categorySlug,
              getWithPagination: event.getWithPagination));
        }
      },
    );*/
    response.fold((l) {
      /*     if (l.statusCode == 400 &&
          !isFailedTheFirstTime
              .contains('GetHomeBoutiqesEvent' + "${event.categorySlug}")) {
        emit(state.copyWith(moveUrlFromElasticToMarketServer: true));
        add(GetHomeBoutiqesEvent(
            getWithPrefetchForBoutiques: event.getWithPrefetchForBoutiques,
            offset: event.offset,
            context: event.context,
            categorySlug: event.categorySlug,
            getWithPagination: event.getWithPagination));
        isFailedTheFirstTime
            .add('GetHomeBoutiqesEvent' + "${event.categorySlug}");
        return;
      }*/
      Map<String, PaginationModel<Boutique>>
          getHomeBoutiquesPaginationObjectByMainCategory =
          Map.of(state.getHomeBoutiquesPaginationObjectByMainCategory);
      Map<String, bool> boutiquesForEveryMainCategoryThatDidPrefetch =
          Map.of(state.boutiquesForEveryMainCategoryThatDidPrefetch);
      if (!event.getWithPrefetchForBoutiques) {
        boutiquesForEveryMainCategoryThatDidPrefetch[event.categorySlug] =
            false;
      }

      if (!isFailedTheFirstTime
          .contains('GetHomeBoutiqesEvent' + "${event.categorySlug}")) {
        add(GetHomeBoutiqesEvent(
            getWithPrefetchForBoutiques: event.getWithPrefetchForBoutiques,
            offset: event.offset,
            context: event.context,
            categorySlug: event.categorySlug,
            getWithPagination: event.getWithPagination));
        isFailedTheFirstTime
            .add('GetHomeBoutiqesEvent' + "${event.categorySlug}");
      }

      emit(
        state.copyWith(
          boutiquesForEveryMainCategoryThatDidPrefetch:
              boutiquesForEveryMainCategoryThatDidPrefetch,
          getHomeBoutiquesPaginationObjectByMainCategory:
              getHomeBoutiquesPaginationObjectByMainCategory.map(
            (key, value) {
              if (key == event.categorySlug)
                return MapEntry(key,
                    value.copyWith(paginationStatus: PaginationStatus.failure));
              return MapEntry(key, value);
            },
          ),
        ),
      );
      print(
          "///////////////////----------${state.getHomeBoutiquesPaginationObjectByMainCategory[event.categorySlug]!.paginationStatus}-----------------------------wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww");
    }, (r) {
      /////////////////////////////
      getHomeBoutiquesPaginationObjectByMainCategory =
          Map.of(state.getHomeBoutiquesPaginationObjectByMainCategory);
      String url = '';
      int numOfBanners = -1;
      r.data?.boutiques?.forEach((boutique) {
        // boutique images
        numOfBanners = boutique.banners?.length ?? 0;
        boutique.banners?.forEach((banner) {
          if (url == '') {
            // background of boutique
            url = addSuitableWidthAndHeightToImage(
                imageUrl: banner.filePath!, width: 1.sw, height: 235);
            prefetchImages(url, event.context);
          }
          url = addSuitableWidthAndHeightToImage(
              imageUrl: banner.filePath!,
              width: 1.sw,
              height: numOfBanners == 1 ? 135 : 155);
          prefetchImages(url, event.context);
        });

        // boutique categories images
        boutique.childCategoriesForProductIds?.forEach((category) {
          url = addSuitableWidthAndHeightToImage(
              imageUrl: category.mostViewedProductThumbnail!.filePath!,
              width: 40.w,
              height: 40.w);
          prefetchImages(url, event.context);
        });
      });
      isFailedTheFirstTime
          .remove('GetHomeBoutiqesEvent' + "${event.categorySlug}");

      getHomeBoutiquesPaginationObjectByMainCategory =
          Map.of(state.getHomeBoutiquesPaginationObjectByMainCategory);
      List<Boutique> boutiques = List.of(
          getHomeBoutiquesPaginationObjectByMainCategory[event.categorySlug]!
              .items);

      emit(state.copyWith(getHomeBoutiquesPaginationObjectByMainCategory:
          getHomeBoutiquesPaginationObjectByMainCategory.map((key, value) {
        if (key == event.categorySlug) {
          return MapEntry(
              key,
              value.copyWith(
                  hasReachedMax:
                      (r.data!.boutiques?.length ?? kPageSize) < kPageSize,
                  paginationStatus: PaginationStatus.success,
                  page: event.getWithPagination
                      ? getHomeBoutiquesPaginationObjectByMainCategory[
                                  event.categorySlug]!
                              .page +
                          1
                      : 2,
                  offset: r.data?.offset,
                  items: !event.getWithPagination
                      ? [...r.data!.boutiques ?? []]
                      : [...boutiques, ...r.data!.boutiques ?? []]));
        } else {
          return MapEntry(key, value);
        }
      })));
      print(
          "#11111111111111111111111@@@@@@@@@@@@@@@@@@@@@@@@@@@!!!!!!!!!!!!!!!!!!!!!!!!!${!event.getWithPagination}3333333334${event.getWithPrefetchForBoutiques}");

      if (!event.getWithPagination && event.getWithPrefetchForBoutiques) {
        prefetchBoutiques(event.categorySlug, event.context, 0);
      }
    });
  }

  FutureOr<void> _onGetProductsWithoutFiltersEvent(
      GetProductsWithoutFiltersEvent event, Emitter<HomeState> emit) async {
    String keyForCacheData = event.boutiqueSlug + (event.category ?? '');
    Map<String, PaginationModel<product.Products>> getProductsWithoutFilters =
        Map.of(state.getProductListingPaginationWithoutFiltersModel);

    if (getProductsWithoutFilters[keyForCacheData] == null) {
      getProductsWithoutFilters[keyForCacheData] =
          const PaginationModel<product.Products>.init();
    }
    Map<String, bool> reRequestTheseProductListingInBoutiques =
        Map.of(state.reRequestTheseProductListingInBoutiques);
    if (!reRequestTheseProductListingInBoutiques.containsKey(keyForCacheData)) {
      getProductsWithoutFilters[keyForCacheData] =
          getProductsWithoutFilters[keyForCacheData]!.copyWith(
              paginationStatus: PaginationStatus.initial,
              page: 0,
              hasReachedMax: false);
    }
    /* if ((!event.getWithPagination &&
            (getProductsWithoutFilters[keyForCacheData]!.paginationStatus ==
                    PaginationStatus.loading ||
                getProductsWithoutFilters[keyForCacheData]!.paginationStatus ==
                    PaginationStatus.success)) ||
        (event.getWithPagination &&
            getProductsWithoutFilters[keyForCacheData]!.hasReachedMax)) {
      return;
    }*/
    emit(state.copyWith(
      getProductListingPaginationWithoutFiltersModel:
          getProductsWithoutFilters.map((key, value) {
        if (key == keyForCacheData) {
          return MapEntry(
              key, value.copyWith(paginationStatus: PaginationStatus.loading));
        } else {
          return MapEntry(key, value);
        }
      }),
    ));
    final response =
        await getProductsWithoutFiltersUseCase(GetProductsWithoutFiltersParams(
      offset: event.offset,
      boutiqueSlug: event.boutiqueSlug,
      category: event.category,
      limit: event.limit,
    ));

    response.fold((l) {
      if (!isFailedTheFirstTime.contains('GetProductsWithoutFiltersEvent')) {
        add(GetProductsWithoutFiltersEvent(
          offset: event.offset,
          boutiqueSlug: event.boutiqueSlug,
          category: event.category,
          limit: event.limit,
        ));
        isFailedTheFirstTime.add('GetProductsWithoutFiltersEvent');
      }
      emit(state.copyWith(getProductListingPaginationWithoutFiltersModel:
          getProductsWithoutFilters.map((key, value) {
        if (key == keyForCacheData) {
          return MapEntry(
              key, value.copyWith(paginationStatus: PaginationStatus.failure));
        } else {
          return MapEntry(key, value);
        }
      })));
    }, (r) {
      getProductsWithoutFilters =
          Map.of(state.getProductListingPaginationWithoutFiltersModel);
      isFailedTheFirstTime.remove('GetProductsWithoutFiltersEvent');
      bool resetListAfterGetData =
          !(reRequestTheseProductListingInBoutiques[keyForCacheData] ?? false);
      reRequestTheseProductListingInBoutiques[keyForCacheData] = true;
      emit(state.copyWith(
          reRequestTheseProductListingInBoutiques:
              Map.of(reRequestTheseProductListingInBoutiques),
          getProductListingPaginationWithoutFiltersModel:
              getProductsWithoutFilters.map((key, value) {
            if (key == keyForCacheData) {
              return MapEntry(
                  key,
                  value.copyWith(
                      paginationStatus: PaginationStatus.success,
                      page: event.getWithPagination
                          ? getProductsWithoutFilters[keyForCacheData]!.page + 1
                          : 2,
                      hasReachedMax:
                          (r.data!.products?.length ?? kPageSize) < kPageSize,
                      items: [
                        ...resetListAfterGetData
                            ? []
                            : event.getWithPagination
                                ? getProductsWithoutFilters[keyForCacheData]!
                                    .items
                                : [],
                        ...r.data?.products ?? []
                      ]));
            } else {
              return MapEntry(key, value);
            }
          })));
    });
  }

  FutureOr<void> _onGetProductsWithFiltersEvent(
      GetProductsWithFiltersEvent event, Emitter<HomeState> emit) async {
    // String idForRequest = Uuid().v4();
    /*  if (event.getWithPagination) {
      idForRequest = state.idForRequest ?? "";
    }
    if (!event.cashedOrginalBoutique) {
      emit(state.copyWith(
        idForRequest: idForRequest,
      ));
    }*/

    Map<String, PaginationModel<product.Products>?>
        getProductListingWithFiltersPaginationModels =
        Map.of(state.getProductListingWithFiltersPaginationModels);

    String keyWithoutFilter = '${event.boutiqueSlug}' +
        '${(event.cashedOrginalBoutique) ? 'withoutFilter' : ""}' +
        '${(event.category ?? '')}';
    String key = '${event.boutiqueSlug}' + '${(event.category ?? '')}';
    filters_model.Filter filter =
        state.getProductFiltersModel[key]?.filters ?? filters_model.Filter();
    if (!(event.fromSearch ??
        false || event.getWithPagination || !event.cashedOrginalBoutique)) {
      PrefetchProductsForFirstFiveFilter(
          boutiqueSlug: event.boutiqueSlug,
          categorySlug: event.category,
          filter: filter);
    }

    if (getProductListingWithFiltersPaginationModels[keyWithoutFilter] ==
        null) {
      getProductListingWithFiltersPaginationModels[keyWithoutFilter] =
          PaginationModel.init();
    }

    /*Map<String, bool> reRequestProductWithFilters =
        Map.of(state.reRequestProductWithFilters);
    if (!reRequestProductWithFilters.containsKey(keyWithoutFilter)) {
      getProductListingWithFiltersPaginationModels[keyWithoutFilter] =
          getProductListingWithFiltersPaginationModels[keyWithoutFilter]!
              .copyWith(
                  paginationStatus: PaginationStatus.initial,
                  page: 0,
                  hasReachedMax: false);
    }
    reRequestProductWithFilters[keyWithoutFilter] = true;*/
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
    if (!((event.cashedOrginalBoutique && !(event.fromSearch ?? false)) &&
        getProductListingWithFiltersPaginationModels[keyWithoutFilter]
                ?.paginationStatus ==
            PaginationStatus.success)) {
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

    bool checkForFilter = ((filters.colors?.isNullOrEmpty ?? true) &&
        (filters.brands?.isNullOrEmpty ?? true) &&
        (filters.attributes?.isNullOrEmpty ?? true) &&
        (filters.boutiques?.isNullOrEmpty ?? true) &&
        (filters.categories?.isNullOrEmpty ?? true) &&
        (filters.searchText == null) &&
        filters.prices == null);

    List<String>? brandsForAnalytics =
        filters.brands?.map((e) => e.slug.toString()).toList();
    List<String>? categoriesForAnalytics =
        filters.categories?.map((e) => e.slug.toString()).toList();
    List<String>? boutiquesForAnalytics = event.fromSearch ?? false
        ? filters.boutiques?.map((e) => e.slug.toString()).toList()
        : [event.boutiqueSlug];
    List<String>? colorsForAnalytics = filters.colors;
    List<String>? pricesForAnalytics =
        (prevAppliedFiltersByUser[key]?.filters?.prices?.maxPrice != null &&
                prevAppliedFiltersByUser[key]?.filters?.prices?.minPrice !=
                    null)
            ? [
                '${prevAppliedFiltersByUser[key]?.filters?.prices?.minPrice}-${prevAppliedFiltersByUser[key]?.filters?.prices?.maxPrice}'
              ]
            : null;
    List<String>? optionsForAnalytics = filters.attributes?[0].options;
    String? searchTextForAnalytics = filters.searchText ??
        state.appliedFiltersByUser[key]?.filters?.searchText;

    if (!(event.fromChoosed ?? false)) {
      if (checkForFilter) {
        appliedFilters[key] = null;
      } else {
        appliedFilters[key] =
            filters_model.GetProductFiltersModel(filters: filters);
        ///////////////////////////////
        Future.delayed(
          Duration(milliseconds: 100),
          () => FirebaseAnalyticsService.logEventForSession(
            eventName: AnalyticsEventsConst.programmingEvent,
            executedEventName:
                AnalyticsExecutedEventNameConst.appliedFiltersEvent,
            extraParams: {
              'brands': json.encode(brandsForAnalytics ?? []),
              'categories': json.encode(categoriesForAnalytics ?? []),
              'boutiques': json.encode(boutiquesForAnalytics ?? []),
              'colors': json.encode(colorsForAnalytics ?? []),
              'prices': json.encode(pricesForAnalytics ?? []),
              'options': json.encode(optionsForAnalytics ?? []),
              'searchText': json.encode(searchTextForAnalytics ?? ''),
            },
          ),
        );
      }
    } else {
      if (!checkForFilter) {
        ///////////////////////////////
        Future.delayed(
          Duration(milliseconds: 100),
          () => FirebaseAnalyticsService.logEventForSession(
            eventName: AnalyticsEventsConst.programmingEvent,
            executedEventName:
                AnalyticsExecutedEventNameConst.appliedFiltersEvent,
            extraParams: {
              'brands': json.encode(brandsForAnalytics ?? []),
              'categories': json.encode(categoriesForAnalytics ?? []),
              'boutiques': json.encode(boutiquesForAnalytics ?? []),
              'colors': json.encode(colorsForAnalytics ?? []),
              'prices': json.encode(pricesForAnalytics ?? []),
              'options': json.encode(optionsForAnalytics ?? []),
              'searchText': json.encode(searchTextForAnalytics ?? ''),
            },
          ),
        );
      }
    }
    Map<String, GetProductFiltersStatus>? getProductFiltersStatus =
        Map.of(state.getProductFiltersStatus);
    if (getProductFiltersStatus[key] == null) {
      getProductFiltersStatus.addAll({key: GetProductFiltersStatus.loading});
    } else {
      getProductFiltersStatus[key] = GetProductFiltersStatus.loading;
    }
    emit(state.copyWith(
      getProductFiltersStatus: getProductFiltersStatus,
      cashedOrginalBoutique: event.cashedOrginalBoutique,
      isGettingProductListingWithPaginationForAppearProduct:
          event.getWithPagination,
      isGettingProductListingWithPagination: event.getWithPagination,
      //  reRequestProductWithFilters: Map.of(reRequestProductWithFilters),
      getProductListingWithFiltersPaginationModels:
          Map.of(getProductListingWithFiltersPaginationModels),
      choosedFiltersByUser: Map.of(choosedFilters),
      appliedFiltersByUser: Map.of(appliedFilters),
    ));

    final response = await getProductsWithFiltersUseCase(
      GetProductsWithFiltersParams(
        scroll_id: null,
        brandSlugs:
            filters.brands?.map((e) => '"${e.slug.toString()}"').toList(),
        categorySlugs: (event.category != null && event.category != "")
            ? [
                ...(filters.categories
                        ?.map((e) => '"${e.slug.toString()}"')
                        .toList() ??
                    []),
                (event.resetChoosedFilters == true &&
                        (event.fromSearch ?? false))
                    ? ""
                    : '"${event.category}"'
              ]
            : filters.categories?.map((e) => '"${e.slug.toString()}"').toList(),
        boutiqueSlugs: event.fromSearch ?? false
            ? filters.boutiques?.map((e) => '"${e.slug.toString()}"').toList()
            : ['"${event.boutiqueSlug}"'],
        offset: !event.getWithPagination
            ? null
            : state.searchWithFilterOffset?[keyWithoutFilter] ?? "",
        attributes: filters.attributes.isNullOrEmpty
            ? null
            : [
                {
                  '"id"': '"${filters.attributes![0].id}"',
                  '"name"': '"${filters.attributes![0].name}"',
                  '"options"': filters.attributes![0].options
                      ?.map(
                        (e) => '"${e}"',
                      )
                      .toList(),
                }
              ],
        colors: filters.colors?.map((e) => '"${e.toString()}"').toList(),
        limit: event.limit ?? 10,
        prices:
            (prevAppliedFiltersByUser[key]?.filters?.prices?.maxPrice != null &&
                    prevAppliedFiltersByUser[key]?.filters?.prices?.minPrice !=
                        null)
                ? [
                    '"${prevAppliedFiltersByUser[key]?.filters?.prices?.minPrice}-${prevAppliedFiltersByUser[key]?.filters?.prices?.maxPrice}"'
                  ]
                : null,
        searchText: filters.searchText ??
            state.appliedFiltersByUser[key]?.filters?.searchText,
      ),
    );

    response.fold((l) {
      Map<String, PaginationModel<product.Products>?>
          getProductListingWithFiltersPaginationModels =
          Map.of(state.getProductListingWithFiltersPaginationModels);
      if (!isFailedTheFirstTime.contains('GetProductsWithFiltersEvent')) {
        add(GetProductsWithFiltersEvent(
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
        isFailedTheFirstTime.add('GetProductsWithFiltersEvent');
      }
      getProductListingWithFiltersPaginationModels[keyWithoutFilter] =
          getProductListingWithFiltersPaginationModels[keyWithoutFilter]!
              .copyWith(paginationStatus: PaginationStatus.failure);
      emit(state.copyWith(
          isGettingProductListingWithPagination: false,
          choosedFiltersByUser: Map.of(prevChoosedFiltersByUser),
          getProductListingWithFiltersPaginationModels:
              Map.of(getProductListingWithFiltersPaginationModels),
          appliedFiltersByUser: Map.of(prevAppliedFiltersByUser)));
    }, (r) {
      Map<String, String> searchWithFilterOffset =
          Map.of(state.searchWithFilterOffset ?? {});

      if (searchWithFilterOffset.containsKey(keyWithoutFilter)) {
        searchWithFilterOffset[keyWithoutFilter] = r.data?.offset ?? "";
      } else {
        searchWithFilterOffset.addAll({keyWithoutFilter: r.data?.offset ?? ""});
      }
      Map<String, PaginationModel<product.Products>?>
          getProductListingWithFiltersPaginationModels =
          <String, PaginationModel<product.Products>?>{};

      //  if (state.idForRequest == idForRequest || state.cashedOrginalBoutique) {
      isFailedTheFirstTime.remove('GetProductsWithFiltersEvent');

      Map<String, filters_model.GetProductFiltersModel?> data =
          Map.of(state.getProductFiltersModel);
      List<filters_model.PriceRange> ranges = r.data!.prices?.priceRanges ?? [];
      ranges.removeWhere((element) => element.count == 0);
      if (event.fromNotification ?? false) {
        data.addAll({
          key: filters_model.GetProductFiltersModel(
              filters: filters_model.Filter(
            totalSize: r.data?.totalSize,
            //   boutiqueSlug: r.data?.boutiqueSlug,
            brands: r.data!.brands,
            attributes: r.data!.attributes,
            prices: r.data!.prices?.copyWith(priceRanges: ranges),
            boutiques: r.data!.boutiques,
            colors: r.data!.colors,
            searchText: filters.searchText,
            categories: r.data!.categories,
          ))
        });
      } else {
        data[key] = filters_model.GetProductFiltersModel(
            filters: filters_model.Filter(
          totalSize: r.data?.totalSize,
          //   boutiqueSlug: r.data?.boutiqueSlug,
          brands: r.data!.brands,
          attributes: r.data!.attributes,
          prices: r.data!.prices?.copyWith(priceRanges: ranges),
          boutiques: r.data!.boutiques,
          colors: r.data!.colors,
          searchText: filters.searchText,
          categories: r.data!.categories,
        ));
      }

      if (event.cashedOrginalBoutique &&
          !(event.fromSearch ?? false) &&
          !event.getWithPagination) {
        PrefetchProductsForFirstFiveFilter(
            filter: data[key]?.filters,
            boutiqueSlug: event.boutiqueSlug,
            categorySlug: event.category);
      }
      if (event.fromNotification ?? false) {
        PaginationModel<Products>? value = PaginationModel<Products>(
          items: event.getWithPagination
              ? [
                  ...List.of(getProductListingWithFiltersPaginationModels[
                              keyWithoutFilter]
                          ?.items ??
                      []),
                  ...r.data!.products ?? []
                ]
              : r.data!.products ?? [],
          page: (event.getWithPagination
              ? (getProductListingWithFiltersPaginationModels[keyWithoutFilter]
                          ?.page ??
                      0) +
                  1
              : 2),
          paginationStatus: PaginationStatus.success,
          hasReachedMax: (r.data?.products?.length ?? 0) < kPageSize,
        );
        getProductListingWithFiltersPaginationModels.addAll({key: value});
      } else {
        state.getProductListingWithFiltersPaginationModels
            .forEach((key, value) {
          if (key == keyWithoutFilter) {
            getProductListingWithFiltersPaginationModels.addAll({
              key: value!.copyWith(
                  paginationStatus: PaginationStatus.success,
                  page: event.getWithPagination ? value.page + 1 : 2,
                  hasReachedMax: (r.data?.products?.length ?? 0) < kPageSize,
                  items: event.getWithPagination
                      ? [...List.of(value.items), ...r.data!.products ?? []]
                      : r.data!.products)
            });
            return;
          }
          getProductListingWithFiltersPaginationModels.addAll({key: value});
        });
      }
      Map<String, GetProductFiltersStatus>? getProductFiltersStatus =
          Map.of(state.getProductFiltersStatus);
      getProductFiltersStatus[key] = GetProductFiltersStatus.success;
      /* getProductListingWithFiltersPaginationModels.removeWhere((key,
                  value) =>
              !(key.contains(idForRequest) || key.contains('withoutFilter')));*/

      emit(state.copyWith(
        getProductFiltersStatus: getProductFiltersStatus,
        searchWithFilterOffset: searchWithFilterOffset,
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
        sizesForEachColor: [],
        changeSizesForEveryProduct: ChangeSizesForEveryProduct.loading));

    //emit(state.copyWith(sizes: sizes));
    if (!event.variation.isNullOrEmpty) {
      event.variation!.forEach((element) {
        if (event.currentColorName != "") {
          color = element.type!.split("-")[0];
          colors.add(color);
          colorsQuantities.add(element.qty ?? 0);
        }

        if (element.type!.split("-")[0] == event.currentColorName ||
            event.currentColorName == '') {
          try {
            size =
                element.type!.split("-")[event.currentColorName == '' ? 0 : 1];
            sizes.add(size);
            sizesQuantities.add(element.qty ?? 0);
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

  FutureOr<void> _onGetProductDatailsWithoutRelatedProductsEvent(
      GetProductDatailsWithoutRelatedProductsEvent event,
      Emitter<HomeState> emit) async {
    //  if (state.cachedProductWithoutRelatedProductsModel
    //      .containsKey(event.productId)) return;
    Map<String, GetProductDetailWithoutSimilarRelatedProductsStatus>
        productStatus = Map.from(state.productStatus ?? {});
    if (productStatus[event.productId] != null) {
      if (productStatus[event.productId] ==
          GetProductDetailWithoutSimilarRelatedProductsStatus.loading) {
        return;
      }
    }

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
      Future.delayed(Duration(seconds: 2), () {
        add(GetAndAddCountViewOfProductEvent(
            productId: r.product!.id.toString()));
        add(GetCommentForProductEvent(productId: r.product!.id.toString()));
        add(GetStoryForProductEvent(productId: r.product!.id.toString()));
        GetIt.I<ChatBloc>().add(
            GetSharedProductCountEvent(productId: r.product!.id.toString()));
      });

      productStatus = Map.from(state.productStatus ?? {});
      productStatus.addAll({
        event.productId!:
            GetProductDetailWithoutSimilarRelatedProductsStatus.success
      });
      apisMustNotToRequest.add('GetProductDatailsWithoutRelatedProductsEvent');
      isFailedTheFirstTime
          .remove('GetProductDatailsWithoutRelatedProductsEvent');
      Map<String, GetProductDetailWithoutRelatedProductsModel> newCached =
          Map.of(state.cachedProductWithoutRelatedProductsModel);
      newCached.addAll({event.productId!: r});
      emit(state.copyWith(
          cachedProductWithoutRelatedProductsModel: Map.of(newCached),
          getProductDetailWithoutSimilarRelatedProductsStatus:
              GetProductDetailWithoutSimilarRelatedProductsStatus.success,
          productStatus: Map.of(productStatus)));
    });
  }

  @override
  HomeState? fromJson(Map<String, dynamic> json) {
    return HomeState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(HomeState state) {
    return state
        .copyWith(
          currentSelectedColorForEveryProduct: {},
          reRequestTheseProductListingInBoutiques: {},
          reRequestTheseBoutiques: {},
          reRequestProductWithFilters: {},
          productStatus: {},
          boutiquesThatDidPrefetch: {},
          cartIdsHurryUPTimerStarted: {},
          listOfErrorSendedToMobileErrorLog: [],
          getProductFiltersWithPrefetchModel: {},
          getProductListingWithFiltersPaginationWithPrefetchModels: {},
          boutiquesForEveryMainCategoryThatDidPrefetch: {},
          choosedFiltersByUser: {},
          appliedFiltersByUser: {},
          cashedOrginalBoutique: false,
          isGettingProductListingWithPagination: false,
          ListitemForAddToCart: [],
          getMainCategoriesStatus: GetMainCategoriesStatus.init,
          getAndAddCountViewOfProductStatus: {},
          getProductDetailWithoutSimilarRelatedProductsStatus:
              GetProductDetailWithoutSimilarRelatedProductsStatus.init,
          getStartingSettingsStatus: GetStartingSettingsStatus.init,
        )
        .toJson();
  }

  prefetchBoutiques(String currentSlug, BuildContext context,
      int boutiqueItemsCountWithScroll) {
    int maxItemsVisible = (1.sh -
                (GetIt.I<StoryBloc>().state.getStoriesStatus !=
                        GetStoriesStatus.success
                    ? 220
                    : 0) -
                50) ~/
            235 +
        1;
    int maxItemsVisibleWithScroll =
        max(maxItemsVisible, boutiqueItemsCountWithScroll);
    int boutiqueItemsCount = state
            .getHomeBoutiquesPaginationObjectByMainCategory[currentSlug]
            ?.items
            .length ??
        -1;

    int itemsToPrefetch = min(maxItemsVisibleWithScroll, boutiqueItemsCount);

    debugPrint(
        '///////// Boutique items To Prefetch : $itemsToPrefetch /////////');
    try {
      for (int i = 0; i < itemsToPrefetch; i++) {
        String slug = state
            .getHomeBoutiquesPaginationObjectByMainCategory[currentSlug]!
            .items[i]
            .slug
            .toString();
        List<String> categorySlugs = [];
        // state.getHomeBoutiquesPaginationObjectByMainCategory[currentSlug]!
        //     .items[i].childCategoriesForProductIds
        //     ?.forEach(
        //   (element) {
        //     categorySlugs.add(element.categorySlug ?? "");
        //   },
        // );

        add(GetProductWithFiltersWithoutCancelingPreviousEvents(
            categorySlugs: categorySlugs,
            context: context,
            cashedOrginalBoutique: true,
            fromHomePageSearch: false,
            boutiqueSlug: slug,
            category: null,
            searchText: null));
      }
    } catch (e, st) {
      print(e);
      print(st);
    }
  }

  PrefetchProductsForFirstFiveFilter(
      {filters_model.Filter? filter,
      String? boutiqueSlug,
      String? categorySlug}) {
    add(GetProductsWithFiltersWithPrefetchForFiveFiltersEvent(
        filterType: "Empty",
        boutiqueSlug: boutiqueSlug!,
        category: categorySlug,
        attribute: null,
        filterSlug: "Empty"));

    int countOfPreFetchForFiveFilters = 0;
    if ((filter?.categories?.length ?? 0) > 0) {
      for (var i = 0; i < (filter?.categories?.length ?? 0); i++) {
        add(GetProductsWithFiltersWithPrefetchForFiveFiltersEvent(
            filterType: "category",
            boutiqueSlug: boutiqueSlug,
            category: categorySlug,
            attribute: null,
            filterSlug: filter?.categories![i].slug ?? ""));
      }
    }
    if ((filter?.brands?.length ?? 0) > 0) {
      for (var i = 0; i < (filter?.brands?.length ?? 0); i++) {
        countOfPreFetchForFiveFilters = countOfPreFetchForFiveFilters + 1;
        add(GetProductsWithFiltersWithPrefetchForFiveFiltersEvent(
            filterType: "brand",
            boutiqueSlug: boutiqueSlug,
            category: categorySlug,
            attribute: null,
            filterSlug: filter?.brands![i].slug ?? ""));
        if (countOfPreFetchForFiveFilters == 6) {
          break;
        }
      }
    }

    if ((filter?.attributes?.length ?? 0) > 0 &&
        countOfPreFetchForFiveFilters < 6) {
      for (var i = 0; i < (filter?.attributes![0].options?.length ?? 0); i++) {
        countOfPreFetchForFiveFilters = countOfPreFetchForFiveFilters + 1;
        add(GetProductsWithFiltersWithPrefetchForFiveFiltersEvent(
            filterType: "attribute",
            boutiqueSlug: boutiqueSlug,
            category: categorySlug,
            attribute: filter?.attributes![0]
                .copyWith(options: [filter.attributes![0].options![i]]),
            filterSlug: filter?.attributes![0].options![i] ?? ""));
      }
    }

    if ((filter?.colors?.length ?? 0) > 0 &&
        countOfPreFetchForFiveFilters < 6) {
      for (var i = 0; i < (filter?.colors?.length ?? 0); i++) {
        countOfPreFetchForFiveFilters = countOfPreFetchForFiveFilters + 1;
        add(GetProductsWithFiltersWithPrefetchForFiveFiltersEvent(
            filterType: "color",
            boutiqueSlug: boutiqueSlug,
            category: categorySlug,
            attribute: null,
            filterSlug: filter?.colors![i] ?? ""));
      }
    }
    List<filters_model.PriceRange> ranges = filter?.prices?.priceRanges ?? [];
    ranges.removeWhere((element) => element.count == 0);
    if ((ranges.length) > 0 && countOfPreFetchForFiveFilters < 6) {
      for (var i = 0; i < (ranges.length); i++) {
        countOfPreFetchForFiveFilters = countOfPreFetchForFiveFilters + 1;
        add(GetProductsWithFiltersWithPrefetchForFiveFiltersEvent(
            filterType: "price",
            boutiqueSlug: boutiqueSlug,
            category: categorySlug,
            attribute: null,
            filterSlug: "${ranges[i].minPrice}-${ranges[i].maxPrice}"));
      }
    }
  }

  FutureOr<void> _onGetProductFiltersEvent(
      GetProductFiltersEvent event, Emitter<HomeState> emit) async {
    String key = event.boutiqueSlug + (event.category ?? '');
    if (event.getProductsFilterPreFetch &&
        !event.fromHomePageSearch &&
        event.cashedOrginalBoutique &&
        (state.getProductFiltersModel[key]?.filters?.totalSize ?? 0) > 0) {}
    Map<String, GetProductFiltersStatus> statuses =
        Map.of(state.getProductFiltersStatus);
    statuses[key] = GetProductFiltersStatus.loading;
    if (event.cashedOrginalBoutique &&
        statuses[key] == GetProductFiltersStatus.success) {
      statuses[key] = GetProductFiltersStatus.success;
    }
    emit(state.copyWith(
      getProductFiltersStatus: Map.of(statuses),
    ));
    filters_model.Filter filters =
        event.filtersChoosedByUser?.filters ?? filters_model.Filter();

    List<filters_model.Attribute>? attribute;
    try {
      attribute = filters.attributes.isNullOrEmpty
          ? ((state.appliedFiltersByUser[key]?.filters?.attributes
                      ?.isNullOrEmpty ??
                  true)
              ? null
              : state.appliedFiltersByUser[key]?.filters!.attributes!)
          : filters.attributes;
      if (!attribute.isNullOrEmpty &&
          !filters.attributes.isNullOrEmpty &&
          !(state.appliedFiltersByUser[key]?.filters?.attributes
                  ?.isNullOrEmpty ??
              true)) {
        attribute![0] = attribute[0].copyWith(options: [
          ...filters.attributes![0].options ?? [],
          ...state.appliedFiltersByUser[key]?.filters!.attributes![0].options ??
              []
        ]);
      }
      filters = filters.copyWithSaveOtherField(
        brands: [
          ...filters.brands ?? [],
          ...state.appliedFiltersByUser[key]?.filters?.brands ?? []
        ],
        categories: [
          ...filters.categories ?? [],
          ...state.appliedFiltersByUser[key]?.filters?.categories ?? []
        ],
        colors: [
          ...filters.colors ?? [],
          ...state.appliedFiltersByUser[key]?.filters?.colors ?? []
        ],
        attributes: attribute,
        prices:
            filters.prices ?? state.choosedFiltersByUser[key]?.filters?.prices,
        searchText: filters.searchText ??
            state.appliedFiltersByUser[key]?.filters?.searchText,
        boutiques: event.fromHomePageSearch
            ? [
                ...filters.boutiques ?? [],
                ...state.appliedFiltersByUser[key]?.filters?.boutiques ?? []
              ]
            : [],
      );
    } catch (e, st) {
      print(e);
      print(st);
    }

    final response = await getProductFiltersUseCase(GetProductsFiltersParams(
      limit: 10,
      scroll_id: null,
      searchText: filters.searchText ?? event.searchText,
      brandSlugs: filters.brands?.map((e) => '"${e.slug.toString()}"').toList(),
      categorySlugs: event.category != null && event.category != ""
          ? [
              ...(filters.categories
                      ?.map((e) => '"${e.slug.toString()}"')
                      .toList() ??
                  []),
              '"${event.category}"'
            ]
          : filters.categories?.map((e) => '"${e.slug.toString()}"').toList(),
      boutiqueSlugs: event.fromHomePageSearch
          ? filters.boutiques?.map((e) => '"${e.slug.toString()}"').toList()
          : ['"${event.boutiqueSlug}"'],
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
      prices:
          filters.prices?.maxPrice != null && filters.prices?.minPrice != null
              ? ['"${filters.prices!.minPrice}-${filters.prices!.maxPrice}"']
              : null,
    ));
    response.fold((l) {
      Map<String, GetProductFiltersStatus> statuses =
          Map.of(state.getProductFiltersStatus);
      if (!isFailedTheFirstTime.contains('GetProductFiltersEvent')) {
        add(GetProductFiltersEvent(
            getProductsFilterPreFetch: event.getProductsFilterPreFetch,
            cashedOrginalBoutique: event.cashedOrginalBoutique,
            fromExpandPage: event.fromExpandPage,
            resetAppliesFilters: event.resetAppliesFilters,
            getWithoutFilter: event.getWithoutFilter,
            filtersChoosedByUser: event.filtersChoosedByUser,
            category: event.category,
            boutiqueSlug: event.boutiqueSlug,
            forceUpdate: event.forceUpdate,
            fromHomePageSearch: event.fromHomePageSearch,
            searchText: filters.searchText ?? event.searchText));
        isFailedTheFirstTime.add('GetProductFiltersEvent');
      }
      statuses[key] = GetProductFiltersStatus.failure;
      emit(state.copyWith(getProductFiltersStatus: statuses));
    }, (r) {
      Map<String, GetProductFiltersStatus> statuses =
          Map.of(state.getProductFiltersStatus);
      if (event.getProductsFilterPreFetch &&
          !event.fromHomePageSearch &&
          event.cashedOrginalBoutique) {
        PrefetchProductsForFirstFiveFilter(
            filter: r.filters,
            boutiqueSlug: event.boutiqueSlug,
            categorySlug: event.category);
      }

      apisMustNotToRequest.add('GetProductFiltersEvent');
      isFailedTheFirstTime.remove('GetProductFiltersEvent');
      try {
        statuses[key] = GetProductFiltersStatus.success;
        Map<String, filters_model.GetProductFiltersModel?> data =
            Map.of(state.getProductFiltersModel);
        List<filters_model.PriceRange> ranges =
            r.filters!.prices?.priceRanges ?? [];
        ranges.removeWhere((element) => element.count == 0);

        data[key] = r.copyWith(
            filters: r.filters?.copyWithSaveOtherField(
                prices: r.filters?.prices?.copyWith(priceRanges: ranges),
                searchText: r.filters?.searchText));

        emit(state.copyWith(
            countOfProductExpectedByFiltering:
                Map.of({event.boutiqueSlug: r.filters?.totalSize ?? 0}),
            getProductFiltersStatus: Map.of(statuses),
            getProductFiltersModel:
                Map.of(data) //removeAlreadyChoosedFilters(r, filters),
            ));
      } catch (e, st) {
        print(e);
        print(st);
      }
    });
  }

  FutureOr<void> _onGetWithProductFiltersWithoutCancelingPreviousEvents(
      GetProductWithFiltersWithoutCancelingPreviousEvents event,
      Emitter<HomeState> emit) async {
    String keyWithoutFilter =
        '${event.boutiqueSlug}' + 'withoutFilter' + '${(event.category ?? '')}';
    String key = event.boutiqueSlug + (event.category ?? '');
    Map<String, bool> boutiquesThatDidPrefetch =
        Map.of(state.boutiquesThatDidPrefetch);
    print(
        "#ppppppppppppppppppppppppppppppppppp@@@@@@@@@@@@@@@@@@@@@@@@@@@!!!!!!!!!!!!!!!!!!!!!!!!!${boutiquesThatDidPrefetch[key]}33333333");
    if (boutiquesThatDidPrefetch[key] == true) {
      return;
    }
    if (boutiquesThatDidPrefetch[key] == null) {
      boutiquesThatDidPrefetch.addAll({key: false});
    }
    boutiquesThatDidPrefetch[key] = true;
    // if (boutiquesThatDidPrefetch[key] == true) {
    //   if (event.indexOfCategory < event.categorySlugs.length &&
    //       event.categorySlugs.length > 0) {
    //     add(GetProductWithFiltersWithoutCancelingPreviousEvents(
    //         getWithoutFilter: true,
    //         context: event.context,
    //         categorySlugs: event.categorySlugs,
    //         cashedOrginalBoutique: true,
    //         fromHomePageSearch: false,
    //         boutiqueSlug: event.boutiqueSlug,
    //         indexOfCategory: event.indexOfCategory + 1,
    //         category: event.category == null
    //             ? event.categorySlugs[0]
    //             : event.categorySlugs[event.indexOfCategory],
    //         searchText: null));
    //   }
    //   return;
    // }

    emit(state.copyWith(boutiquesThatDidPrefetch: boutiquesThatDidPrefetch));

    filters_model.Filter filters =
        event.filtersChoosedByUser?.filters ?? filters_model.Filter();
    // if ((data[key]?.filters?.totalSize ?? 0) > 0) {
    //   if (event.indexOfCategory < event.categorySlugs.length &&
    //       event.categorySlugs.length > 0) {
    //     add(GetProductWithFiltersWithoutCancelingPreviousEvents(
    //         getWithoutFilter: true,
    //         context: event.context,
    //         categorySlugs: event.categorySlugs,
    //         cashedOrginalBoutique: true,
    //         fromHomePageSearch: false,
    //         boutiqueSlug: event.boutiqueSlug,
    //         indexOfCategory: event.indexOfCategory + 1,
    //         category: event.category == null
    //             ? event.categorySlugs[0]
    //             : event.categorySlugs[event.indexOfCategory],
    //         searchText: null));
    //   }
    // }
    List<filters_model.Attribute>? attribute;
    try {
      attribute = filters.attributes.isNullOrEmpty
          ? ((state.appliedFiltersByUser[key]?.filters?.attributes
                      ?.isNullOrEmpty ??
                  true)
              ? null
              : state.appliedFiltersByUser[key]?.filters!.attributes!)
          : filters.attributes;
      if (!attribute.isNullOrEmpty &&
          !filters.attributes.isNullOrEmpty &&
          !(state.appliedFiltersByUser[key]?.filters?.attributes
                  ?.isNullOrEmpty ??
              true)) {
        attribute![0] = attribute[0].copyWith(options: [
          ...filters.attributes![0].options ?? [],
          ...state.appliedFiltersByUser[key]?.filters!.attributes![0].options ??
              []
        ]);
      }
      filters = filters.copyWithSaveOtherField(
        brands: [
          ...filters.brands ?? [],
          ...state.appliedFiltersByUser[key]?.filters?.brands ?? []
        ],
        categories: [
          ...filters.categories ?? [],
          ...state.appliedFiltersByUser[key]?.filters?.categories ?? []
        ],
        colors: [
          ...filters.colors ?? [],
          ...state.appliedFiltersByUser[key]?.filters?.colors ?? []
        ],
        attributes: attribute,
        prices:
            filters.prices ?? state.choosedFiltersByUser[key]?.filters?.prices,
        searchText: filters.searchText ??
            state.appliedFiltersByUser[key]?.filters?.searchText,
        boutiques: event.fromHomePageSearch
            ? [
                ...filters.boutiques ?? [],
                ...state.appliedFiltersByUser[key]?.filters?.boutiques ?? []
              ]
            : [],
      );
    } catch (e, st) {
      print(e);
      print(st);
    }
    print(
        "#@@@@@@@@@@@@@@@@@@ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd");

    final response =
        await getProductsWithFiltersUseCase(GetProductsWithFiltersParams(
      scroll_id: null,
      offset: "1",
      limit: 10,
      searchText: filters.searchText ?? event.searchText,
      brandSlugs: filters.brands?.map((e) => '"${e.slug.toString()}"').toList(),
      categorySlugs: event.category != null ? ['"${event.category}"'] : null,
      boutiqueSlugs: event.fromHomePageSearch
          ? filters.boutiques?.map((e) => '"${e.slug.toString()}"').toList()
          : ['"${event.boutiqueSlug}"'],
      attributes: filters.attributes.isNullOrEmpty
          ? null
          : [
              {
                '"id"': '"${filters.attributes![0].id}"',
                '"name"': '"${filters.attributes![0].name}"',
                '"options"': filters.attributes![0].options
                    ?.map(
                      (e) => '"${e}"',
                    )
                    .toList(),
              }
            ],
      colors: filters.colors?.map((e) => '"${e.toString()}"').toList(),
      prices:
          filters.prices?.maxPrice != null && filters.prices?.minPrice != null
              ? ['"${filters.prices!.minPrice}-${filters.prices!.maxPrice}"']
              : null,
    ));
    response.fold((l) {
      Map<String, bool> boutiquesThatDidPrefetch =
          Map.of(state.boutiquesThatDidPrefetch);
      boutiquesThatDidPrefetch[key] = false;

      emit(state.copyWith(boutiquesThatDidPrefetch: boutiquesThatDidPrefetch));
      // if (!isFailedTheFirstTime.contains('GetProductFiltersEvent'
      //     "${event.category}")) {
      //   add(GetProductWithFiltersWithoutCancelingPreviousEvents(
      //       categorySlugs: event.categorySlugs,
      //       context: event.context,
      //       cashedOrginalBoutique: true,
      //       fromHomePageSearch: false,
      //       boutiqueSlug: event.boutiqueSlug,
      //       indexOfCategory: event.indexOfCategory,
      //       category: event.category,
      //       searchText: null));
      //   isFailedTheFirstTime.add('GetProductFiltersEvent'
      //       "${event.categorySlugs[event.indexOfCategory]}");
      // }
    }, (r) async {
      Map<String, String> searchWithFilterOffset =
          Map.of(state.searchWithFilterOffset ?? {});
      if (searchWithFilterOffset.containsKey(keyWithoutFilter)) {
        searchWithFilterOffset[keyWithoutFilter] = r.data?.offset ?? "";
      } else {
        searchWithFilterOffset.addAll({keyWithoutFilter: r.data?.offset ?? ""});
      }

      List<String> cachedLinksOfImages = [];
      String url, url2;
      r.data?.products?.forEach((product) {
        product.syncColorImages?.forEach((image) {
          if (!image.images.isNullOrEmpty) {
            image.images?.forEach((image) {
              url = addSuitableWidthAndHeightToImage(
                  imageUrl: image.filePath!,
                  width: 200,
                  // the width of the image in the ui
                  height: 290,
                  // the height of the image in the ui
                  ordinalWidth: double.tryParse(image.originalWidth.toString()),
                  ordinalHeight:
                      double.tryParse(image.originalHeight.toString()));
              url2 = addSuitableWidthAndHeightToImage(
                imageUrl: image.filePath!,
                width: 320,
                // the width of the image in the ui
                height: 464,
                // the height of the image in the ui
                /*   ordinalWidth: double.tryParse(image.originalWidth.toString()),
                  ordinalHeight:
                      double.tryParse(image.originalHeight.toString())*/
              );
              cachedLinksOfImages.add(url);
              cachedLinksOfImages.add(url2);
              prefetchImages(url, event.context);
              prefetchImages(
                url2,
                event.context,
              );
            });
          }
        });

        product.syncColorImages?.forEach((image) {
          if (!image.images.isNullOrEmpty) {
            url = addSuitableWidthAndHeightToImage(
                imageUrl: image.images![0].filePath!,
                width: 40,
                // the width of the image in the ui
                height: 40,
                // the height of the image in the ui
                ordinalWidth:
                    double.tryParse(image.images![0].originalWidth.toString()),
                ordinalHeight: double.tryParse(
                    image.images![0].originalHeight.toString()));
            prefetchImages(
              url,
              event.context,
            );
          }
        });

        product.images?.forEach((image) {
          url = addSuitableWidthAndHeightToImage(
              imageUrl: image.filePath!,
              width: 200,
              // the width of the image in the ui
              height: 290,
              // the height of the image in the ui
              ordinalWidth: double.tryParse(image.originalWidth.toString()),
              ordinalHeight: double.tryParse(image.originalHeight.toString()));
          url2 = addSuitableWidthAndHeightToImage(
            imageUrl: image.filePath!,
            width: 320,
            // the width of the image in the ui
            height: 464,
            // the height of the image in the ui
            /*   ordinalWidth: double.tryParse(image.originalWidth.toString()),
              ordinalHeight: double.tryParse(image.originalHeight.toString())*/
          );
          if (!cachedLinksOfImages.contains(url)) {
            prefetchImages(url, event.context);
          }
          if (!cachedLinksOfImages.contains(url2)) {
            prefetchImages(url2, event.context);
          }
        });
      });
      r.data?.categories?.forEach((category) {
        url = addSuitableWidthAndHeightToImage(
          imageUrl: category.mostViewedProductThumbnail!.filePath!,
          width: 70,
          // the width of the image in the ui
          height: 70,
          // the height of the image in the ui
          /*   ordinalWidth: double.tryParse(
                category.mostViewedProductThumbnail!.originalWidth.toString()),
            ordinalHeight: double.tryParse(category
                .mostViewedProductThumbnail!.originalHeight
                .toString())*/
        );
        prefetchImages(url, event.context);
        category.subCategories?.forEach((sub) {
          url = addSuitableWidthAndHeightToImage(
            imageUrl: sub.mostViewedProductThumbnail!.filePath!,
            width: 50,
            // the width of the image in the ui
            height: 50,
            // the height of the image in the ui
            /*ordinalWidth: double.tryParse(
                  sub.mostViewedProductThumbnail!.originalWidth.toString()),
              ordinalHeight: double.tryParse(
                  sub.mostViewedProductThumbnail!.originalHeight.toString())*/
          );
          prefetchImages(
            url,
            event.context,
          );
        });
      });
      r.data?.brands?.forEach((brand) {
        prefetchSvgImages(brand.icon!.filePath.toString(), event.context,
            ordinalWidth: double.tryParse(brand.icon!.originalWidth.toString()),
            ordinalHeight:
                double.tryParse(brand.icon!.originalHeight.toString()));
      });

      Map<String, GetProductFiltersStatus> statuses =
          Map.of(state.getProductFiltersStatus);

      List<filters_model.PriceRange> ranges = r.data?.prices?.priceRanges ?? [];
      ranges.removeWhere((element) => element.count == 0);

      Map<String, bool> boutiquesThatDidPrefetch =
          Map.of(state.boutiquesThatDidPrefetch);
      boutiquesThatDidPrefetch[key] = true;

      Map<String, filters_model.GetProductFiltersModel?> data =
          Map.of(state.getProductFiltersModel);

      if (data[key] == null) {
        data.addAll({
          key: filters_model.GetProductFiltersModel(
              filters: filters_model.Filter(
            brands: r.data!.brands,
            totalSize: r.data?.totalSize,
            //    boutiqueSlug: r.data?.boutiqueSlug,
            attributes: r.data!.attributes,
            prices: r.data!.prices?.copyWith(priceRanges: ranges),
            boutiques: r.data!.boutiques,
            colors: r.data!.colors,
            searchText: filters.searchText,
            categories: r.data!.categories,
          ))
        });
      }

      data[key] = filters_model.GetProductFiltersModel(
          filters: filters_model.Filter(
        brands: r.data!.brands,
        attributes: r.data!.attributes,
        totalSize: r.data?.totalSize,
        //      boutiqueSlug: r.data?.boutiqueSlug,
        prices: r.data!.prices?.copyWith(priceRanges: ranges),
        boutiques: r.data!.boutiques,
        colors: r.data!.colors,
        searchText: filters.searchText,
        categories: r.data!.categories,
      ));

      emit(state.copyWith(
          searchWithFilterOffset: searchWithFilterOffset,
          boutiquesThatDidPrefetch: boutiquesThatDidPrefetch,
          getProductFiltersModel: Map.of(data)));

      // Future.delayed(Duration(seconds: 5), () {
      //   PrefetchProductsForFirstFiveFilter(
      //       filter: data[key]?.filters,
      //       boutiqueSlug: event.boutiqueSlug,
      //       categorySlug: event.category);
      // });

      if (boutiquesThatEnablesToRequestItsProductsUsingFiveFilters[key] ==
          true) {
        boutiquesThatEnablesToRequestItsProductsUsingFiveFilters[key] = false;
        Future.delayed(Duration(seconds: 5), () {
          PrefetchProductsForFirstFiveFilter(
              filter: data[key]?.filters,
              boutiqueSlug: event.boutiqueSlug,
              categorySlug: event.category);
        });
      }

      if (state.getProductFiltersStatus[key] ==
              GetProductFiltersStatus.success ||
          state.getProductFiltersStatus[key] ==
              GetProductFiltersStatus.loading) {
        return;
      }
      if (statuses[key] == null) {
        statuses.addAll({key: GetProductFiltersStatus.success});
      } else {
        statuses[key] = GetProductFiltersStatus.success;
      }
      emit(state.copyWith(getProductFiltersStatus: statuses));

      apisMustNotToRequest.add('GetProductFiltersEvent'
          "${event.category}");
      isFailedTheFirstTime.remove('GetProductFiltersEvent'
          "${event.category}");
      try {
        Map<String, PaginationModel<product.Products>?>
            getProductListingWithFiltersPaginationModels =
            Map.of(state.getProductListingWithFiltersPaginationModels);
        if (getProductListingWithFiltersPaginationModels[keyWithoutFilter] ==
            null) {
          getProductListingWithFiltersPaginationModels[keyWithoutFilter] =
              PaginationModel.init();
        }
        getProductListingWithFiltersPaginationModels[keyWithoutFilter] =
            getProductListingWithFiltersPaginationModels[keyWithoutFilter]!
                .copyWith(
                    paginationStatus: PaginationStatus.success,
                    page: 2,
                    hasReachedMax: (r.data!.products?.length ?? 0) < kPageSize,
                    items: r.data!.products);

        emit(state.copyWith(
          getProductListingWithFiltersPaginationModels:
              getProductListingWithFiltersPaginationModels,

          countOfProductExpectedByFiltering:
              Map.of({event.boutiqueSlug: r.data!.totalSize ?? 0}),
          //removeAlreadyChoosedFilters(r, filters),
        ));
        // if (event.indexOfCategory < event.categorySlugs.length &&
        //     event.categorySlugs.length > 0) {
        //   add(GetProductWithFiltersWithoutCancelingPreviousEvents(
        //       getWithoutFilter: true,
        //       categorySlugs: event.categorySlugs,
        //       context: event.context,
        //       cashedOrginalBoutique: true,
        //       fromHomePageSearch: false,
        //       boutiqueSlug: event.boutiqueSlug,
        //       indexOfCategory: event.indexOfCategory + 1,
        //       category: event.category == null
        //           ? event.categorySlugs[0]
        //           : event.categorySlugs[event.indexOfCategory],
        //       searchText: null));
        // }
      } catch (e, st) {
        print(e);
        print(st);
      }
    });
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

  FutureOr<void> _onGetCustomerWalletEvent(
    GetCustomerWalletEvent event,
    Emitter<HomeState> emit,
  ) async {
    ///////////////////////////
    emit(
      state.copyWith(
        getCustomerWalletStatus: GetCustomerWalletStatus.loading,
      ),
    );

    final response = await getCustomerWalletUseCase.call(
      CustomerWalletParams(limit: event.limit, offset: event.offset),
    );

    response.fold(
      (l) {
        if (!isFailedTheFirstTime.contains('GetCustomerWalletEvent')) {
          add(
            GetCustomerWalletEvent(limit: event.limit, offset: event.offset),
          );
          isFailedTheFirstTime.add('GetCustomerWalletEvent');
        }
        emit(
          state.copyWith(
            getCustomerWalletStatus: GetCustomerWalletStatus.failure,
          ),
        );
      },
      (r) {
        isFailedTheFirstTime.remove('GetCustomerWalletEvent');

        emit(
          state.copyWith(
            getCustomerWalletStatus: GetCustomerWalletStatus.success,
            customerWalletModel: r,
          ),
        );
      },
    );
  }

  FutureOr<void> _onGetAddressByCoordinatesEvent(
      GetAddressByCoordinatesEvent event, Emitter<HomeState> emit) async {
    if (event.latitude == 0 && event.longitude == 0) {
      return;
    }
    ///////////////////////////
    emit(
      state.copyWith(
        getAddressByCoordinatesStatus: GetAddressByCoordinatesStatus.loading,
      ),
    );

    final response = await getAddressByCoordinatesUsecase(
      GetAddressByCoordinatesParams(
        latitude: event.latitude,
        longitude: event.longitude,
      ),
    );

    response.fold(
      (l) {
        if (!isFailedTheFirstTime.contains('GetAddressByCoordinatesEvent')) {
          isFailedTheFirstTime.add('GetAddressByCoordinatesEvent');
        }
        emit(
          state.copyWith(
            getAddressByCoordinatesStatus:
                GetAddressByCoordinatesStatus.failure,
          ),
        );
      },
      (r) {
        isFailedTheFirstTime.remove('GetAddressByCoordinatesEvent');
        emit(
          state.copyWith(
              getAddressByCoordinatesStatus:
                  GetAddressByCoordinatesStatus.success,
              getAddressByCoordinatesModel: r),
        );
      },
    );
    await Future.delayed(
      Duration(seconds: 5),
      () {
        emit(state.copyWith(
          getAddressByCoordinatesStatus: GetAddressByCoordinatesStatus.failure,
        ));
      },
    );
  }

  FutureOr<void> _onGetAddressByTextEvent(
      GetAddressByTextEvent event, Emitter<HomeState> emit) async {
    if (event.reset) {}
    emit(
        state.copyWith(getAddressByTextStatus: GetAddressByTextStatus.loading));
    if (event.reset) {
      emit(state.copyWith(
          getAddressByTextStatus: GetAddressByTextStatus.success,
          resultSearch: []));
      return;
    }
    final response = await getAddressByTextUsecase(
        GetAddressByTextParams(query: event.query));

    response.fold((l) {
      if (!isFailedTheFirstTime.contains('GetAddressByTextEvent')) {
        ;
        isFailedTheFirstTime.add('GetAddressByTextEvent');
      }
      emit(state.copyWith(
          getAddressByTextStatus: GetAddressByTextStatus.failure));
    }, (r) {
      List<ResultSearch>? resultSearch = [];
      resultSearch = r.results ?? [];
      isFailedTheFirstTime.remove('GetAddressByTextEvent');

      emit(state.copyWith(
        resultSearch: List.of(resultSearch),
        getAddressByTextStatus: GetAddressByTextStatus.success,
      ));
    });
  }

  FutureOr<void> _onGetCartItemEvent(
      GetCartItemEvent event, Emitter<HomeState> emit) async {
    List<Cart> cartCollection = [];
    List<Cart> carts;

    emit(state.copyWith(getCartItemsStatus: GetCartItemsStatus.loading));
    final response = await getCartItemUseCase(NoParams());
    response.fold((l) {
      print('${l.hashCode}' +
          '133333333333333333333333333222222222222222222222222222222222222222222222222222222222222');
      if (!isFailedTheFirstTime.contains('GetCartItemEvent')) {
        add(GetCartItemEvent(
            fromTerminitedStatusl: event.fromTerminitedStatusl));
        isFailedTheFirstTime.add('GetCartItemEvent');
      }
      emit(state.copyWith(getCartItemsStatus: GetCartItemsStatus.failure));
    }, (r) {
      Map<String, Map<int, List<String>>> addImagesToProductIdForCart =
          Map.of(state.addImagesToProductIdForCart);
      List<String> cartIdIsFound = [];
      r.data?.cart?.forEach(
        (element) => cartIdIsFound.add(element.id.toString()),
      );
      addImagesToProductIdForCart.forEach((key, value) {
        value.removeWhere(
          (keyes, valuees) {
            return !cartIdIsFound.contains(keyes.toString());
          },
        );
      });
      addImagesToProductIdForCart.removeWhere(
        (key, value) => value.isEmpty,
      );
      Map<String, List<int>> currentQuantity =
          Map.of(state.currentQuantityForCart ?? {});
      currentQuantity.removeWhere(
          (key, value) => !cartIdIsFound.contains(value[1].toString()));
      carts = r.data!.cart!;
      carts.forEach((element) {
        cartCollection.add(element);
      });
      apisMustNotToRequest.add('GetCartItemEvent');
      isFailedTheFirstTime.remove('GetCartItemEvent');
      if (event.fromTerminitedStatusl ?? false) {
        emit(state.copyWith(
          currentQuantityForCart: currentQuantity,
          addImagesToProductIdForCart: addImagesToProductIdForCart,
        ));
      }
      Map<String, int> cartIdsHurryUPTimerStarted =
          Map.of(state.cartIdsHurryUPTimerStarted);

      for (var i = 0; i < cartCollection.length; i++) {
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
      }
      if (cartIdsHurryUPTimerStarted.isNotEmpty) {
        for (var i = 0; i < cartIdsHurryUPTimerStarted.length; i++) {
          if (!cartCollection.contains(cartIdsHurryUPTimerStarted[i])) {
            add(AddTimerStartedToHurryUpEvent(
                cartId: cartIdsHurryUPTimerStarted.keys.toList()[i],
                isAddToList: false,
                timeLeft: 0));
          }
        }
      }
      emit(state.copyWith(
          //  currentQuantityForCart: currentQuantity,
          //    addImagesToProductIdForCart: addImagesToProductIdForCart,
          getCartShippingItemsModel: r,
          cartCollection: List.of(cartCollection),
          getCartItemsStatus: GetCartItemsStatus.success));
      // add(AddItemToCartEvent());
      add(GetOldCartItemEvent());
    });
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
    emit(state.copyWith(CurrentColorSizeForCart: sizeColor));
  }

  FutureOr<void> _onAddItemToCartEvent(
      AddItemToCartEvent event, Emitter<HomeState> emit) async {
    String currentSize = event.choice_1!;
    Map<String, List<int>> CurrentQuantity =
        Map.of(state.currentQuantityForCart ?? {});
    String key = "${event.products.productId.toString()}" +
        "${event.colorName}" +
        "${currentSize}";

    if (event.quantity == 0) {
      return;
    }
    if (!CurrentQuantity[key].isNullOrEmpty) {
      int? quantity = event.quantity!.round() + CurrentQuantity[key]![0];
      if (quantity > (double.tryParse(event.maxAllowed ?? "0") ?? 0) &&
          (double.tryParse(event.maxAllowed ?? "0") ?? 0) != 0) {
        showMessage(
            "${LocaleKeys.you_reach_the_max_allowed_quantity.tr()} \n (${double.tryParse(event.maxAllowed ?? "0")?.round()} ${LocaleKeys.item.tr()}) ${LocaleKeys.of_this_product.tr()} \n ${LocaleKeys.you_can_add_only.tr()} ${((double.tryParse(event.maxAllowed ?? "0") ?? 0) - (CurrentQuantity.isEmpty ? 0 : CurrentQuantity[key]![0])).round()} ${LocaleKeys.item.tr()}",
            foreGroundColor: Colors.white,
            backGroundColor: Colors.black,
            showInRelease: true,
            timeShowing: Toast.LENGTH_LONG);
        return;
      }
      if (CurrentQuantity[key]![0] > 0) {
        CurrentQuantity[key]![0] = quantity;
        emit(state.copyWith(currentQuantityForCart: CurrentQuantity));
        add(UpdateItemInCartEvent(
            fishAddAllTheItems: event.finishAddAllTheItems,
            countOfPieces: event.countOfPieces,
            image: event.image,
            currentSize: currentSize,
            maxAllowed: (double.tryParse(event.maxAllowed ?? "0") ?? 0),
            colorName: event.colorName,
            productId: event.products.productId.toString(),
            quantity: quantity,
            cartId: CurrentQuantity[key]![1].toString(),
            boutiqueId: event.boutiqueId.toString()));
        return;
      }
    } else {
      CurrentQuantity[key]?[0] = event.quantity ?? 0;
      emit(state.copyWith(currentQuantityForCart: CurrentQuantity));
      if (event.quantity!.round() >
              (double.tryParse(event.maxAllowed ?? "0") ?? 0) &&
          (double.tryParse(event.maxAllowed ?? "0") ?? 0) != 0) {
        showMessage(
            "${LocaleKeys.you_reach_the_max_allowed_quantity.tr()} \n (${double.tryParse(event.maxAllowed ?? "0")?.round()} ${LocaleKeys.item.tr()}) ${LocaleKeys.of_this_product.tr()} \n ${LocaleKeys.you_can_add_only.tr()} ${((double.tryParse(event.maxAllowed ?? "0") ?? 0) - (CurrentQuantity.isEmpty ? 0 : CurrentQuantity[key]![0])).round()} ${LocaleKeys.item.tr()}",
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
      offerPriceFormatted: event.products.offerPriceFormatted,
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
              ? (element.variations?[0].color == variation.color)
              : true) &&
          (element.variations!.isNotEmpty
              ? (element.variations?[0].size == variation.size)
              : true),
      orElse: () => oldCart.OldCart(id: -1),
    );
    oldCartCollection.removeWhere(
      (element) =>
          element.image == event.image &&
          (element.variations!.isNotEmpty
              ? (element.variations?[0].color == variation.color)
              : true) &&
          (element.variations!.isNotEmpty
              ? (element.variations?[0].size == variation.size)
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
      isFailedTheFirstTime.remove('AddCartItemEvent');
      add(UpdateListOfItemForAddToCartEvent(
          imageForAddToCart: ImageForAddToCart(),
          operation: "remove",
          productId: event.products.productId.toString(),
          resetTheList: true));
      emit(state.copyWith(addItemInCartStatus: AddItemInCartStatus.success));
      if (r.data == null || r.data == "" || (r.data?.status ?? 0) != 1) {
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
                                print(state.startingSetting
                                    ?.notificationTypes?[0].name);
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

        emit(state.copyWith(cartCollection: cartCollection));
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
      }
      if (r.data!.status != 1) {
        cartCollection.remove(cart);

        emit(state.copyWith(cartCollection: cartCollection));
      } else {
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
            cartCollection: cartCollection,
            addImagesToProductIdForCart: addImagesToProductIdForCart));
        add(AddProductItemForCartEvent(
            productId: event.products.productId.toString(),
            product: event.products));
      }

      if (event.finishAddAllTheItems) {
        add(GetCartItemEvent());
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
          addImagesToProductIdForCart: addImagesToProductIdForCart,
          deleteItemInCartStatus: DeleteItemInCartStatus.success));

      add(AddQuantityForCartEvent(
          currentSize: event.currentSize,
          colorName: event.ColoName,
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
    emit(state.copyWith(hideItemInOldCartStatus: HideItemInOldCartStatus.init));
    List<oldCart.OldCart>? preOldCartCollection = state.oldcartCollection;
    oldCart.OldCart? cart;
    if (!(event.hideAll ?? false)) {
      cart = state.oldcartCollection!.firstWhere(
          (element) => element.id.toString() == event.oldCartId.toString());

      preOldCartCollection!.remove(cart);
    }

    emit(state.copyWith(
        oldCartCollection: (event.hideAll ?? false) ? [] : preOldCartCollection,
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
      emit(state.copyWith(
        hideItemInOldCartStatus: HideItemInOldCartStatus.success,
      ));
      print(
          "LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL");
      showMessage(
        "${LocaleKeys.item_was_hidden_successfuly.tr()}",
        foreGroundColor: Colors.white,
        backGroundColor: Colors.black,
      );
      print(
          "10000000000000000000000000000000000LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL");
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
    if (event.quantity == 0) {
      add(RemoveItemFormCartEvent(
          countOfPieces: event.countOfPieces,
          image: event.image,
          currentSize: event.currentSize,
          ColoName: event.colorName,
          itemId: event.cartId,
          boutiqueId: event.boutiqueId,
          productId: event.productId));
      return;
    }
    if (event.quantity > (event.maxAllowed ?? 0) && event.maxAllowed != 0) {
      showMessage(
          "${LocaleKeys.you_reach_the_max_allowed_quantity.tr()} \n (${(event.maxAllowed ?? 0.0).round()} ${LocaleKeys.item.tr()}) ${LocaleKeys.of_this_product.tr()}",
          foreGroundColor: Colors.white,
          backGroundColor: Colors.black,
          showInRelease: true,
          timeShowing: Toast.LENGTH_LONG);
      return;
    }
    emit(state.copyWith(updateItemInCartStatus: UpdateItemInCartStatus.init));
    Cart cart = state.cartCollection!
        .firstWhere((element) => element.id.toString() == event.cartId);
    Cart PreCart = cart;
    cart = cart.copyWith(quantity: event.quantity);

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
    final response = await updateItemInCartUseCase(
        UpdateITemInCartParams(id: event.cartId, quantity: event.quantity));

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
      emit(state.copyWith(
          updateItemInCartStatus: UpdateItemInCartStatus.loading));
      if ((r.data == null || r.data == "") || (r.data?.status ?? 0) != 1) {
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
                                print(state.startingSetting
                                    ?.notificationTypes?[0].name);
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
          cartCollection: cartCollection,
        ));
        if (event.fishAddAllTheItems) {
          /*   showMessage(r.message!,
              foreGroundColor: Colors.white,
              backGroundColor: Colors.black,
              showInRelease: true,
              timeShowing: Toast.LENGTH_SHORT);
          isFailedTheFirstTime.remove('AddCartItemEvent');*/
        }
        isFailedTheFirstTime.remove('UpdateCartItemEvent');
        emit(state.copyWith(
            updateItemInCartStatus: UpdateItemInCartStatus.success));
        return;
      }
      if (r.data!.status == 1) {
        Map<String, Map<int, List<String>>> addImagesToProductIdForCart =
            Map.from(state.addImagesToProductIdForCart);

        if (!addImagesToProductIdForCart[event.productId]![
                int.parse(event.cartId)]
            .isNullOrEmpty) {
          addImagesToProductIdForCart[event.productId]![
                  int.parse(event.cartId)]!
              .removeWhere((element) => element == event.image);
          for (int i = 0; i < event.quantity; i++) {
            addImagesToProductIdForCart[event.productId]![
                    int.parse(event.cartId)]!
                .add(event.image);
          }
          ;
        } else {
          addImagesToProductIdForCart[event.productId]![
              int.parse(event.cartId)] = [];
          for (int i = 0; i < event.quantity; i++) {
            addImagesToProductIdForCart[event.productId]![
                    int.parse(event.cartId)]!
                .add(event.image);
          }
          ;
        }
        emit(state.copyWith(
            addImagesToProductIdForCart: addImagesToProductIdForCart));

        add(AddQuantityForCartEvent(
            currentSize: event.currentSize,
            colorName: event.colorName,
            cartId: int.tryParse(event.cartId)!,
            quantity: event.quantity,
            productId: event.productId));
        isFailedTheFirstTime.remove('UpdateCartItemEvent');
        if (event.fishAddAllTheItems) {
          showMessage(r.message!,
              foreGroundColor: Colors.white,
              backGroundColor: Colors.black,
              showInRelease: true,
              timeShowing: Toast.LENGTH_SHORT);
          isFailedTheFirstTime.remove('AddCartItemEvent');
        }
      } else {
        List<Cart>? cartCollection = state.cartCollection!.map((e) {
          if (e.id.toString() == event.cartId) {
            return PreCart;
          } else {
            return e;
          }
        }).toList();
        emit(state.copyWith(cartCollection: cartCollection));

        isFailedTheFirstTime.remove('UpdateCartItemEvent');
        if (event.fishAddAllTheItems) {
          showMessage(r.message!,
              foreGroundColor: Colors.white,
              backGroundColor: Colors.black,
              showInRelease: true,
              timeShowing: Toast.LENGTH_SHORT);
          isFailedTheFirstTime.remove('AddCartItemEvent');
        }
      }
      emit(state.copyWith(
          updateItemInCartStatus: UpdateItemInCartStatus.success));
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
    Map<String, List<int>> CurrentQuantity = state.currentQuantityForCart ?? {};
    String key =
        "${event.productId}" + "${event.colorName}" + "${event.currentSize}";
    if (!CurrentQuantity[key].isNullOrEmpty) {
      CurrentQuantity[key] = [event.quantity, event.cartId];
    } else {
      CurrentQuantity.addAll({
        key: [event.quantity, event.cartId]
      });
    }
    emit(state.copyWith(currentQuantityForCart: CurrentQuantity));
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

  FutureOr<void> _onChangeAppliedFiltersEvent(
      ChangeAppliedFiltersEvent event, Emitter<HomeState> emit) {
    String key = event.boutiqueSlug + (event.category ?? '');
    Map<String, filters_model.GetProductFiltersModel?> appliedFilters =
        Map.of(state.appliedFiltersByUser);
    filters_model.Filter filters =
        event.filtersAppliedByUser?.filters ?? filters_model.Filter();
    if (event.resetAppliedFilters ||
        !((filters.colors?.isNotEmpty ?? false) ||
            (filters.brands?.isNotEmpty ?? false) ||
            (filters.attributes?.isNotEmpty ?? false) ||
            (filters.categories?.isNotEmpty ?? false) ||
            (filters.boutiques?.isNotEmpty ?? false) ||
            filters.searchText != null ||
            (filters.prices?.maxPrice != null ||
                filters.prices?.minPrice != null))) {
      appliedFilters[key] = null;
    } else {
      appliedFilters[key] = event.filtersAppliedByUser;
    }
    emit(
      state.copyWith(
          theReplyFromGemini: event.resetAppliedFilters ? "" : null,
          appliedFiltersByUser: Map.of(appliedFilters),
          isExpandedForLidtingPage: event.isExpandedForListing),
    );
  }

  FutureOr<void> _onChangeSelectedFiltersEvent(
      ChangeSelectedFiltersEvent event, Emitter<HomeState> emit) {
    bool makeChoosedFiltersNull = false;
    String key = event.boutiqueSlug + (event.category ?? '');
    print("AAAAAAAAAAAAAQQQQQQQQQQQQAAQQAQAQ${key}");
    Map<String, filters_model.GetProductFiltersModel?> choosedFilters =
        Map.of(state.choosedFiltersByUser);
    if (event.filtersChoosedByUser?.filters != null) {
      if (event.filtersChoosedByUser!.filters!.colors.isNullOrEmpty &&
          event.filtersChoosedByUser!.filters!.brands.isNullOrEmpty &&
          event.filtersChoosedByUser!.filters!.attributes.isNullOrEmpty &&
          event.filtersChoosedByUser!.filters!.boutiques.isNullOrEmpty &&
          event.filtersChoosedByUser!.filters!.categories.isNullOrEmpty &&
          event.filtersChoosedByUser!.filters!.searchText == null &&
          (event.filtersChoosedByUser!.filters!.prices?.minPrice == null ||
              event.filtersChoosedByUser!.filters!.prices?.maxPrice == null)) {
        makeChoosedFiltersNull = true;
      }
    } else {
      makeChoosedFiltersNull = true;
    }
    if (event.resetChoosedFilters || makeChoosedFiltersNull) {
      print(
          "111111111111AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQQQQQQQQQQQQQQQQQQQQQQQQQQQQ");

      choosedFilters[key] = null;
    } else {
      print(
          "222222222222AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQQQQQQQQQQQQQQQQQQQQQQQQQQ");

      choosedFilters[key] = event.filtersChoosedByUser;
    }
    print(
        "222222${choosedFilters[key]?.filters?.categories?.length}222222AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQQQQQQQQQQQQQQQQQQQQQQQQQQ");

    emit(state.copyWith(
        choosedFiltersByUser: Map.of(choosedFilters),
        isExpandedForLidtingPage: event.isExpandedForListing,
        theReplyFromGemini: event.resetChoosedFilters ? "" : null));
    print(
        ".......222222${state.choosedFiltersByUser[key]?.filters?.categories?.length}222222AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQQQQQQQQQQQQQQQQQQQQQQQQQQ");

    if (event.requestToUpdateFilters) {
      add(GetProductFiltersEvent(
          category: event.category,
          boutiqueSlug: event.boutiqueSlug,
          fromHomePageSearch: event.fromHomePageSearch,
          filtersChoosedByUser:
              makeChoosedFiltersNull ? null : event.filtersChoosedByUser));
    }
  }

  FutureOr<void> _onAddMultiItemsToCartEvent(
      AddMultiItemsToCartEvent event, Emitter<HomeState> emit) {
    List<ImageForAddToCart>? listitemForAddToCart =
        List.of(state.ListitemForAddToCart ?? []);
    print(
        "/////////////////////////////////////8888888888888888${listitemForAddToCart.length}");
    listitemForAddToCart.removeWhere((element) => element.quantity == 0);
    print(
        "///////////////////////////////////999999999999999999${listitemForAddToCart.length}");
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

    emit(state.copyWith(ListitemForAddToCart: []));
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
      emit(state.copyWith(ListitemForAddToCart: []));
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

    List<ImageForAddToCart>? ListitemForAddToCart =
        state.ListitemForAddToCart ?? [];
    print(
        "///////////////////////////////////999999999999999999${ListitemForAddToCart.length}");
    ImageForAddToCart? newImageToAddToCart = imageForAddToCart;
    if (event.operation == "+") {
      if (ListitemForAddToCart.isNullOrEmpty) {
        ListitemForAddToCart.addAll([imageForAddToCart]);
        emit(state.copyWith(ListitemForAddToCart: ListitemForAddToCart));
        print(
            "///////////////////////////////////999999999999999999${ListitemForAddToCart.length}");
        return;
      }
      for (var i = 0; i < ListitemForAddToCart.length; i++) {
        ImageForAddToCart element = ListitemForAddToCart[i];

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
          if (!ListitemForAddToCart.any((element) =>
              (element.images == imageForAddToCart.images &&
                  element.colorName == imageForAddToCart.colorName &&
                  element.size == imageForAddToCart.size))) {
            newImageToAddToCart = imageForAddToCart;
          }
        }
      }
      emit(state.copyWith(ListitemForAddToCart: [
        ...ListitemForAddToCart,
        newImageToAddToCart!
      ]));
    } else {
      if (ListitemForAddToCart.last.isDuplicate == true) {
        ImageForAddToCart itemLast = ListitemForAddToCart.last;

        if (itemLast.isDuplicate == true) {
          ListitemForAddToCart = ListitemForAddToCart.map((e) {
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
          ListitemForAddToCart.removeLast();
        }
      } else {
        ListitemForAddToCart.removeLast();
      }
      emit(state.copyWith(ListitemForAddToCart: ListitemForAddToCart));
    }
  }

  FutureOr<void> _onGetSearchListingResultEventEvent(
      GetSearchListingResultEvent event, Emitter<HomeState> emit) async {
    final response =
        await getProductsWithFiltersUseCase(GetProductsWithFiltersParams(
      scroll_id: null,
      categorySlugs:
          event.CategorySlug != "" ? ['"${event.CategorySlug}"'] : [],
      searchText: event.searchTitle,
      boutiqueSlugs:
          event.boutiqueSlug != "" ? ['"${event.boutiqueSlug}"'] : [],
    ));

    response.fold((l) {
      if (!isFailedTheFirstTime.contains('GetSearchResultEvent')) {
        // add(GetSearchREsultEvent(searchTitle: event.searchTitle));
        isFailedTheFirstTime.add('GetSearchResultEvent');
      }
    }, (r) {
      isFailedTheFirstTime.remove('GetSearchResultEvent');
    });
  }

  FutureOr<void> _onAddPrefAppliedFilterForExtendFilterEvent(
      AddPrefAppliedFilterForExtendFilterEvent event, Emitter<HomeState> emit) {
    emit(state.copyWith(
        prefAppliedFilterForExtendFilter: event.prefAppliedFilter));
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

  FutureOr<void> _onResetAllSelectedAppliedFilterEvent(
      ResetAllSelectedAppliedFilterEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(
        choosedFiltersByUser: {},
        appliedFiltersByUser: {},
        theReplyFromGemini: "",
        prefAppliedFilterForExtendFilter: filters_model.Filter()));
  }

  FutureOr<void> _onChangeCurrentIndexForMainCategoryEvent(
      ChangeCurrentIndexForMainCategoryEvent event,
      Emitter<HomeState> emit) async {
    emit(state.copyWith(currentIndexForMainCategoryEvent: event.index));
  }

  FutureOr<void> _onAddIsExpandedForLidtingPageEvent(
      AddIsExpandedForLidtingPageEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(isExpandedForLidtingPage: event.isExpandedForLidting));
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

  FutureOr<void> _onGetProductsWithFiltersWithPrefetchForFiveFiltersEvent(
      GetProductsWithFiltersWithPrefetchForFiveFiltersEvent event,
      Emitter<HomeState> emit) async {
    String key = '${event.boutiqueSlug}' +
        '${event.filterSlug}' +
        '${(event.category ?? '')}';

    Map<String, PaginationModel<product.Products>?>?
        getProductListingWithFiltersPaginationWithPrefetchModels =
        Map.of(state.getProductListingWithFiltersPaginationWithPrefetchModels);

    if (getProductListingWithFiltersPaginationWithPrefetchModels[key] == null) {
      getProductListingWithFiltersPaginationWithPrefetchModels[key] =
          PaginationModel.init();
    }

    emit(state.copyWith(
        getProductListingWithFiltersPaginationWithPrefetchModels:
            getProductListingWithFiltersPaginationWithPrefetchModels));

    if (getProductListingWithFiltersPaginationWithPrefetchModels[key]
            ?.paginationStatus ==
        PaginationStatus.success) {
      return;
    }

    final response =
        await getProductsWithFiltersUseCase(GetProductsWithFiltersParams(
      brandSlugs:
          event.filterType == "brand" ? ['"${event.filterSlug}"'] : null,
      categorySlugs: event.filterType == "category"
          ? event.category != null
              ? ['"${event.filterSlug}"', '"${event.category}"']
              : ['"${event.filterSlug}"']
          : event.category != null
              ? ['"${event.category}"']
              : null,
      offset: "1",
      limit: 10,
      boutiqueSlugs: ['"${event.boutiqueSlug}"'],
      attributes: event.filterType != "attribute"
          ? null
          : [
              {
                '"id"': '"${event.attribute?.id}"',
                '"name"': '"${event.attribute?.name}"',
                '"options"': event.attribute?.options
                    ?.map(
                      (e) => '"${e}"',
                    )
                    .toList(),
              }
            ],
      colors: event.filterType == "color" ? ['"${event.filterSlug}"'] : null,
      prices: event.filterType == "price" ? ['"${event.filterSlug}"'] : null,
    ));

    response.fold((l) {
      Map<String, PaginationModel<product.Products>?>?
          getProductListingWithFiltersPaginationWithPrefetchModels = Map.of(
              state.getProductListingWithFiltersPaginationWithPrefetchModels);
      if (!isFailedTheFirstTime
          .contains('GetProductsWithFiltersWithPrefetchForFiveFiltersEvent')) {
        add(GetProductsWithFiltersWithPrefetchForFiveFiltersEvent(
          filterSlug: event.filterSlug,
          filterType: event.filterType,
          attribute: event.attribute,
          boutiqueSlug: event.boutiqueSlug,
          category: event.category,
        ));
        isFailedTheFirstTime
            .add('GetProductsWithFiltersWithPrefetchForFiveFiltersEvent');
      }
      getProductListingWithFiltersPaginationWithPrefetchModels[key] =
          getProductListingWithFiltersPaginationWithPrefetchModels[key]!
              .copyWith(paginationStatus: PaginationStatus.failure);
      emit(state.copyWith(
        getProductListingWithFiltersPaginationWithPrefetchModels:
            Map.of(getProductListingWithFiltersPaginationWithPrefetchModels),
      ));
    }, (r) {
      Map<String, String> searchWithFilterOffset =
          Map.of(state.searchWithFilterOffset ?? {});
      if (searchWithFilterOffset.containsKey(key)) {
        searchWithFilterOffset[key] = r.data?.offset ?? "";
      } else {
        searchWithFilterOffset.addAll({key: r.data?.offset ?? ""});
      }

      //  if (state.idForRequest == idForRequest || state.cashedOrginalBoutique) {
      isFailedTheFirstTime
          .remove('GetProductsWithFiltersWithPrefetchForFiveFiltersEvent');
      try {
        Map<String, PaginationModel<product.Products>?>
            getProductListingWithFiltersPaginationWithPrefetchModel = Map.of(
                state.getProductListingWithFiltersPaginationWithPrefetchModels);

        getProductListingWithFiltersPaginationWithPrefetchModel[key] =
            getProductListingWithFiltersPaginationWithPrefetchModel[key]!
                .copyWith(
                    paginationStatus: PaginationStatus.success,
                    page: 1,
                    hasReachedMax: (r.data!.products?.length ?? 0) < kPageSize,
                    items: r.data!.products);
        List<filters_model.PriceRange> ranges =
            r.data!.prices?.priceRanges ?? [];
        ranges.removeWhere((element) => element.count == 0);
        Map<String, filters_model.GetProductFiltersModel?> data =
            Map.of(state.getProductFiltersWithPrefetchModel);
        if (data[key] == null) {
          data.addAll({
            key: filters_model.GetProductFiltersModel(
                filters: filters_model.Filter(
              brands: r.data!.brands,
              totalSize: r.data?.totalSize,
              // boutiqueSlug: r.data?.boutiqueSlug,
              attributes: r.data!.attributes,
              prices: r.data!.prices?.copyWith(priceRanges: ranges),
              boutiques: r.data!.boutiques,
              colors: r.data!.colors,
              categories: r.data!.categories,
            ))
          });
        }

        data[key] = filters_model.GetProductFiltersModel(
            filters: filters_model.Filter(
          brands: r.data!.brands,
          attributes: r.data!.attributes,
          totalSize: r.data?.totalSize,
          //   boutiqueSlug: r.data?.boutiqueSlug,
          prices: r.data!.prices?.copyWith(priceRanges: ranges),
          boutiques: r.data!.boutiques,
          colors: r.data!.colors,
          categories: r.data!.categories,
        ));
        emit(state.copyWith(
            searchWithFilterOffset: searchWithFilterOffset,
            getProductListingWithFiltersPaginationWithPrefetchModels:
                getProductListingWithFiltersPaginationWithPrefetchModel,
            countOfProductExpectedByFiltering:
                Map.of({event.boutiqueSlug: r.data!.totalSize ?? 0}),
            getProductFiltersWithPrefetchModel: data));
      } catch (e, st) {
        print(e);
        print(st);
      }
    });
  }

  FutureOr<void> _onIscashedOreiginBotiqueEvent(
      IscashedOreiginBotiqueEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(cashedOrginalBoutique: event.iscashedOreiginBotique));
  }

  FutureOr<void> _onGetProductFiltersWithPrefetchForFiveFiltersEvent(
      GetProductFiltersWithPrefetchForFiveFiltersEvent event,
      Emitter<HomeState> emit) async {
    /*  String key = event.boutiqueSlug + event.filterSlug + (event.category ?? '');
    if (state.getProductListingWithFiltersPaginationWithPrefetchModels[key]
            ?.paginationStatus ==
        PaginationStatus.success) {
      return;
    }
    final response = await getProductFiltersUseCase(GetProductsFiltersParams(
      brandSlugs:
          event.filterType == "brand" ? ['"${event.filterSlug}"'] : null,
      categorySlugs: event.filterType == "category"
          ? event.category != null
              ? ['"${event.filterSlug}"', '"${event.category}"']
              : ['"${event.filterSlug}"']
          : event.category != null
              ? ['"${event.category}"']
              : null,
      boutiqueSlugs: ['"${event.boutiqueSlug}"'],
      attributes: event.filterType != "attribute"
          ? null
          : [
              {
                '"id"': event.attribute!.id,
                '"name"': event.attribute!.name,
                '"options"': event.attribute!.options,
              }
            ],
      colors: event.filterType == "color" ? ['"${event.filterSlug}"'] : null,
      prices: event.filterType == "price" ? ['"${event.filterSlug}"'] : null,
    ));
    response.fold((l) {
      if (!isFailedTheFirstTime.contains('GetProductFiltersEvent')) {
        add(GetProductFiltersWithPrefetchForFiveFiltersEvent(
          filterSlug: event.filterSlug,
          filterType: event.filterType,
          attribute: event.attribute,
          boutiqueSlug: event.boutiqueSlug,
          category: event.category,
        ));
        isFailedTheFirstTime.add('GetProductFiltersEvent');
      }
    }, (r) {
      add(GetProductsWithFiltersWithPrefetchForFiveFiltersEvent(
          boutiqueSlug: event.boutiqueSlug,
          filterType: event.filterType,
          filterSlug: event.filterSlug,
          attribute: event.attribute,
          category: event.category));
      apisMustNotToRequest.add('GetProductFiltersEvent');
      isFailedTheFirstTime.remove('GetProductFiltersEvent');
      try {
        List<filters_model.PriceRange> ranges =
            r.filters!.prices?.priceRanges ?? [];
        ranges.removeWhere((element) => element.count == 0);
        Map<String, filters_model.GetProductFiltersModel?> data =
            state.getProductFiltersWithPrefetchModel;
        data[key] = r.copyWith(
            filters: r.filters?.copyWithSaveOtherField(
                prices: r.filters?.prices?.copyWith(priceRanges: ranges)));

        emit(state.copyWith(
            getProductFiltersWithPrefetchModel:
                data //removeAlreadyChoosedFilters(r, filters),
            ));
      } catch (e, st) {
        print(e);
        print(st);
      }
    });*/
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

  prefetchImages(String url, BuildContext context) async {
    GetIt.I<PreCachingImageBloc>()
        .add(CacheImageEvent(imageUrl: url, context: context));
  }

  prefetchSvgImages(
    String imageUrl,
    BuildContext context, {
    double? ordinalHeight,
    double? ordinalWidth,
  }) async {
    precacheImage(
        SvgImage.cachedNetwork(
          imageUrl,
          width: ordinalWidth,
          height: ordinalHeight,
          cacheManager: CustomCacheManager(),
        ),
        context);
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
      productStatus[event.productId!] =
          GetProductDetailWithoutSimilarRelatedProductsStatus.success;
      cachedData.addAll(
          {event.productId!: r.getProductDetailWithoutRelatedProductsModel!});
      emit(state.copyWith(
        productStatus: productStatus,
        cachedProductWithoutRelatedProductsModel: cachedData,
        productContentForStatusOfOpeningProductDetailsDirectly: r.productItem,
        getFullProductDetailsStatus: GetFullProductDetailsStatus.success,
      ));
    });
  }

  FutureOr<void> _onAddCommentEvent(
      AddCommentEvent event, Emitter<HomeState> emit) async {
    print("${event.productSlug}");
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

  FutureOr<void> _onPlaceOrderEvent(
    PlaceOrderEvent event,
    Emitter<HomeState> emit,
  ) async {
    debugPrint(event.placeOrderParams.paymentMethod);
    debugPrint(event.placeOrderParams.addressId.toString());
    debugPrint(event.placeOrderParams.payByWallet.toString());
    ///////////////////////////
    emit(
      state.copyWith(
        placeOrderStatus: PlaceOrderStatus.loading,
      ),
    );

    final response = await placeOrderUsecase.call(
      event.placeOrderParams,
    );

    response.fold(
      (l) {
        if (!isFailedTheFirstTime.contains('PlaceOrderEvent')) {
          add(
            PlaceOrderEvent(placeOrderParams: event.placeOrderParams),
          );
          isFailedTheFirstTime.add('PlaceOrderEvent');
        }
        emit(
          state.copyWith(
            placeOrderStatus: PlaceOrderStatus.failure,
          ),
        );
      },
      (r) {
        isFailedTheFirstTime.remove('PlaceOrderEvent');

        debugPrint('PlaceOrderStatus success');

        debugPrint('orders length : ${r.data!.length}');
        ////////////////////////////
        emit(
          state.copyWith(
            placeOrderStatus: PlaceOrderStatus.success,
            placeOrderModel: r,
          ),
        );
      },
    );
  }

  FutureOr<void> _onGetOrdersByOrderGroupIDEvent(
    GetOrdersByOrderGroupIDEvent event,
    Emitter<HomeState> emit,
  ) async {
    ///////////////////////////
    emit(
      state.copyWith(
        getOrdersByOrderGroupIDStatus: GetOrdersByOrderGroupIDStatus.loading,
      ),
    );

    final response = await getOrdersByOrderGroupIDUsecase.call(
      event.orderGroupId,
    );

    response.fold(
      (l) {
        if (!isFailedTheFirstTime.contains('GetOrdersByOrderGroupIDEvent') &&
            l.statusCode != 400) {
          add(
            GetOrdersByOrderGroupIDEvent(orderGroupId: event.orderGroupId),
          );
          isFailedTheFirstTime.add('GetOrdersByOrderGroupIDEvent');
        }

        emit(
          state.copyWith(
            getOrdersByOrderGroupIDStatus:
                GetOrdersByOrderGroupIDStatus.failure,
          ),
        );
      },
      (r) {
        isFailedTheFirstTime.remove('GetOrdersByOrderGroupIDEvent');

        debugPrint('GetOrdersByOrderGroupIDEvent success');

        debugPrint('orders length : ${r.data!.length}');
        ////////////////////////////
        emit(
          state.copyWith(
            getOrdersByOrderGroupIDStatus:
                GetOrdersByOrderGroupIDStatus.success,
            getOrdersByOrderGroupIDModel: r,
          ),
        );
      },
    );
  }
}
