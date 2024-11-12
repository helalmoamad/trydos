import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:bloc_concurrency/bloc_concurrency.dart';
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
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/blocs/pre_caching_image_bloc/pre_caching_image_bloc.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/home/data/models/get_cart_item_model.dart';

import 'package:trydos/features/home/data/models/get_comment_for_product_model.dart';
import 'package:trydos/features/home/data/models/get_home_boutiqes_model.dart';
import 'package:trydos/features/home/data/models/get_old_cart_model.dart'
    as oldCart;
import 'package:trydos/features/home/data/models/get_product_detail_without_related_products_model.dart';
import 'package:trydos/features/home/data/models/get_product_filters_model.dart'
    as filters_model;
import 'package:trydos/features/home/data/models/get_product_listing_with_filters_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as product;
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart';
import 'package:trydos/features/home/domain/use_cases/GetCommentForProductUseCase.dart';
import 'package:trydos/features/home/domain/use_cases/add_comment_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/add_like_to_product_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/convert_item_from_oldCart_to_Cart_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/delete_like_of_product_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_allowed_country_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_cart_item_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_count_view_of_product_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_currency_for_country_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_full_product_details_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_home_boutiqes_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_main_categories_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_old_cart_item_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_product_detail_without_related_products_uswcase.dart';
import 'package:trydos/features/home/domain/use_cases/get_product_filters_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_product_list_in_cart_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_products_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_products_with_filters_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_starting_settings_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/hide_item_from_oldCart_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/remove_item_from_cart_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/request_for_notification_when_product_became_available_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/update_item_from_cart_usecase.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_sheet_bottom_bar.dart';
import 'package:trydos/features/story/domain/useCases/get_width_and_height_usecase.dart';
import 'package:trydos/features/story/presentation/bloc/story_state.dart';
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
import '../../domain/use_cases/get_stories_for_product_usecase.dart';
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
    // this.getBrandUseCase,
    //  this.getCategoryUseCase,
    this.deleteLikeOfProductUsecase,
    this.addLikeToProductUsecase,
    this.updateItemInCartUseCase,
    this.addItemToCartUseCase,
    this.getCommentForProductUseCase,
    this.getHomeBoutiqesUseCase,
    this.getProductsListInCartUseCase,
    this.getProductFiltersUseCase,
    this.getAllowedCountryUseCase,
    this.getWidthAndHeightUseCase,
    this.getProductDetailWithoutRelatedProductsUseCase,
    this.getStartingSettingsUseCase,
    this.getCurrencyForCountryUseCase,
    this.hideItemsInOldCartUseCase,
    this.getFullProductDetailsUseCase,
    this.getAndAddCountViewOfProductUsecase,
    this.getProductsWithoutFiltersUseCase,
    this.addCommentUseCase,
    this.requestForNotificationWhenProductBecameAvailableUseCase,
    this.getProductsWithFiltersUseCase,
  ) : super(HomeState()) {
    on<HomeEvent>((event, emit) {});

    on<ResetAllSelectedAppliedFilterEvent>(
      _onResetAllSelectedAppliedFilterEvent,
    );
    on<GetAndAddCountViewOfProductEvent>(
      _onGetAndAddCountViewOfProductEvent,
    );
    on<ConvertItemFromOldcartToCartEvent>(
      _onConvertItemFromOldcartToCartEvent,
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
    on<UpdateListOfItemForAddToCartEvent>(
      _onUpdateListOfItemForAddToCartEvent,
    );
    on<GetProductsListInCartEvent>(
      _onGetProductsListInCartEventEvent,
    );

    on<AddPrefAppliedFilterForExtendFilterEvent>(
      _onAddPrefAppliedFilterForExtendFilterEvent,
    );
    on<RequestForNotificationWhenProductBecameAvailableEvent>(
      _onRequestForNotificationWhenProductBecameAvailableEvent,
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
    on<GetCartItemEvent>(_onGetCartItemEvent,
        transformer: throttleDroppable(Duration(seconds: 5)));

    on<GetAllowedCountriesEvent>(_onGetAllowedCountriesEvent,
        transformer: throttleDroppable(throttleDuration));

    on<GetStartingSettingsEvent>(_onGetStartingSettingsEvent,
        transformer: throttleDroppable(throttleDuration));
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
    on<UpdateItemInCartEvent>(
      _onUpdateItemInCartEvent,
    );
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
    on<AddSizesFotColorsEvent>(
      _onAddSizesFotColorsEvent,
    );
    on<GetOldCartItemEvent>(
      _onGetOldCartItemEvent,
    );

    on<RemoveItemFormCartEvent>(
      _onRemoveItemToCartEvent,
    );

    on<AddCommentEvent>(
      _onAddCommentEvent,
    );

    on<GetProductDatailsWithoutRelatedProductsEvent>(
      _onGetProductDatailsWithoutRelatedProductsEvent,
    );

    on<GetFullProductDetailsEvent>(
      _onGetFullProductDetailsEvent,
    );

    on<GetCommentForProductEvent>(
      _onGetCommentForProductEvent,
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
  final ConvertItemFromOldcartToCartUsecase convertItemFromOldcartToCartUsecase;
  final GetAndAddCountViewOfProductUsecase getAndAddCountViewOfProductUsecase;
  final AddCommentUseCase addCommentUseCase;
  final GetProductsListInCartUseCase getProductsListInCartUseCase;
  final GetCommentForProductUseCase getCommentForProductUseCase;
  final GetStoryForProductUseCase getStoryUseCase;
  final GetProductDetailWithoutRelatedProductsUseCase
      getProductDetailWithoutRelatedProductsUseCase;
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
  final UpdateItemInCartUseCase updateItemInCartUseCase;
  final HideItemsInOldCartUseCase hideItemsInOldCartUseCase;
  final GetAllowedCountryUseCase getAllowedCountryUseCase;
  final GetFullProductDetailsUseCase getFullProductDetailsUseCase;

  final Smartlook smartLook = Smartlook.instance;

  FutureOr<void> _onGetStartingSettingsEvent(
      GetStartingSettingsEvent event, Emitter<HomeState> emit) async {
    if (apisMustNotToRequest.contains('GetStartingSettingsEvent')) return;
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
      // if (r.data!.startingSetting!.smartLook ?? false) {
      //   Logger(printer: PrettyPrinter(methodCount: 0)).i('SMARTLOOK STARTED!');
      // initializeSmartLook();
      // }
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

  FutureOr<void> _onGetMainCategoriesEvent(
      GetMainCategoriesEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(
        getMainCategoriesStatus: GetMainCategoriesStatus.loading));
    final response = await getMainCategoriesUseCase(NoParams());

    response.fold((l) {
      if (!isFailedTheFirstTime.contains('GetMainCategoriesEvent')) {
        add(GetMainCategoriesEvent(context: event.context));
        isFailedTheFirstTime.add('GetMainCategoriesEvent');
      }
      emit(state.copyWith(
          getMainCategoriesStatus: GetMainCategoriesStatus.failure));
    }, (r) async {
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
      if (event.getWithPrefech) {
        Future.delayed(Duration(seconds: 5), () {
          for (var i = 0;
              i < min(categorySlugs.length, (1.sw - 55) ~/ 40);
              i++) {
            if (state.boutiquesForEveryMainCategoryThatDidPrefetch[
                    categorySlugs[i]] !=
                true) {
              add(GetHomeBoutiqesEvent(
                getWithPrefetchForBoutiques: true,
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
    currentSelectedColorForEveryProduct[event.productId] =
        event.currentSelectedColor;
    emit(state.copyWith(
        currentSelectedColorForEveryProduct:
            Map.of(currentSelectedColorForEveryProduct)));
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
                PaginationStatus.loading)) {
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
          event.offset == '1') {
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
    final response = await getHomeBoutiqesUseCase(GetHomeBoutiqesParams(
        offset: event.offset == '1' ? null : event.offset,
        categorySlug:
            event.categorySlug == "Empty" ? null : event.categorySlug));

    response.fold((l) {
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
      if (state.getMainCategoriesStatus == GetMainCategoriesStatus.success) {
        requestAPIAfterHome();
      }
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

      if (!event.getWithPagination && event.getWithPrefetchForBoutiques) {
        prefetchBoutiques(event.categorySlug, event.context);
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
    print(
        "&&&&&&&&&&&&&&&&&&&&&&&&&&${event.boutiqueSlug}&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&7");
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
    print(
        "&&&&&&&&&&&&&&&&&&&&${event.fromSearch}&${keyWithoutFilter}&&&&&&&&&&&&&&&&${((event.cashedOrginalBoutique && !(event.fromSearch ?? false)) && getProductListingWithFiltersPaginationModels[keyWithoutFilter]?.paginationStatus == PaginationStatus.success)}");
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
    emit(state.copyWith(
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
    print(
        "%%%%%%%%%%%%%%%%%${event.searchText}%%%%%%%%%%%%%%%%%%%%%%%%%%%%%${filters.searchText}%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%&${event.fromSearch}");
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
            : filters.categories?.map((e) => '"${e.slug.toString()}"').toList(),
        boutiqueSlugs: event.fromSearch ?? false
            ? filters.boutiques?.map((e) => '"${e.slug.toString()}"').toList()
            : ['"${event.boutiqueSlug}"'],
        offset:
            /*!event.getWithPagination
            ? 1
            : getProductListingWithFiltersPaginationModels[keyWithoutFilter]!
                .page,*/
            !event.getWithPagination
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

      state.getProductListingWithFiltersPaginationModels.forEach((key, value) {
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
      //  if (state.idForRequest == idForRequest || state.cashedOrginalBoutique) {
      isFailedTheFirstTime.remove('GetProductsWithFiltersEvent');

      Map<String, filters_model.GetProductFiltersModel?> data =
          Map.of(state.getProductFiltersModel);
      List<filters_model.PriceRange> ranges = r.data!.prices?.priceRanges ?? [];
      ranges.removeWhere((element) => element.count == 0);
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
      if (event.cashedOrginalBoutique &&
          !(event.fromSearch ?? false) &&
          !event.getWithPagination) {
        PrefetchProductsForFirstFiveFilter(
            filter: data[key]?.filters,
            boutiqueSlug: event.boutiqueSlug,
            categorySlug: event.category);
      }
      /* getProductListingWithFiltersPaginationModels.removeWhere((key,
                  value) =>
              !(key.contains(idForRequest) || key.contains('withoutFilter')));*/

      emit(state.copyWith(
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

  FutureOr<void> _onAddSizesFotColorsEvent(
      AddSizesFotColorsEvent event, Emitter<HomeState> emit) async {
    List<String> sizes = [];
    List<int> sizesQuantities = [];
    List<String> isSizeRequestNotification = [];
    String size;

    //emit(state.copyWith(sizes: sizes));
    if (event.variation != null) {
      event.variation!.forEach((element) {
        if (element.type!.split("-")[0] == event.currentColorName ||
            event.currentColorName == '') {
          size = element.type!.split("-")[event.currentColorName == '' ? 0 : 1];
          sizes.add(size);
          sizesQuantities.add(element.qty ?? 0);
          if (element.variantNotifyForUser) {
            isSizeRequestNotification.add(size);
          }
        }
      });
    }

    emit(state.copyWith(
        sizes: sizes,
        sizesQuantities: sizesQuantities,
        isSizeRequestNotification: isSizeRequestNotification));
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
              GetProductDetailWithoutSimilarRelatedProductsStatus.success &&
          state.cachedProductWithoutRelatedProductsModel[event.productId]
                  ?.product?.boutique?.id !=
              null &&
          state.cachedProductWithoutRelatedProductsModel[event.productId] !=
              null) {
        print(
            "****************////////////${state.cachedProductWithoutRelatedProductsModel[event.productId]?.product?.boutique?.id ?? 15}////////////////////////////////////1111111111111111111111111111111111111111111/");

        if (state.cachedProductWithoutRelatedProductsModel[event.productId]!
                .product !=
            null) {
          return;
        }
      }
    }

    emit(state.copyWith(
        getProductDetailWithoutSimilarRelatedProductsStatus:
            GetProductDetailWithoutSimilarRelatedProductsStatus.loading));

    final response =
        await getProductDetailWithoutRelatedProductsUseCase(event.productId!);

    response.fold((l) {
      if (!isFailedTheFirstTime
          .contains('GetProductDatailsWithoutRelatedProductsEvent')) {
        add(const GetProductDatailsWithoutRelatedProductsEvent());
        isFailedTheFirstTime
            .add('GetProductDatailsWithoutRelatedProductsEvent');
      }
      emit(state.copyWith(
          getProductDetailWithoutSimilarRelatedProductsStatus:
              GetProductDetailWithoutSimilarRelatedProductsStatus.failure));
    }, (r) {
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

  prefetchBoutiques(String currentSlug, BuildContext context) {
    int maxItemsVisible = (1.sh -
                (GetIt.I<StoryBloc>().state.getStoriesStatus !=
                        GetStoriesStatus.success
                    ? 220
                    : 0) -
                50) ~/
            235 +
        1;
    int boutiqueItemsCount = state
            .getHomeBoutiquesPaginationObjectByMainCategory[currentSlug]
            ?.items
            .length ??
        -1;

    int itemsToPrefetch = min(maxItemsVisible, boutiqueItemsCount);

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

    final response =
        await getProductsWithFiltersUseCase(GetProductsWithFiltersParams(
      scroll_id: null,
      offset:
          //1,
          //  state.searchWithFilterOffset?[keyWithoutFilter] ?? "",
          null,
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
                  ordinalWidth: double.tryParse(image.originalWidth.toString()),
                  ordinalHeight:
                      double.tryParse(image.originalHeight.toString()));
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
              ordinalWidth: double.tryParse(image.originalWidth.toString()),
              ordinalHeight: double.tryParse(image.originalHeight.toString()));
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
            ordinalWidth: double.tryParse(
                category.mostViewedProductThumbnail!.originalWidth.toString()),
            ordinalHeight: double.tryParse(category
                .mostViewedProductThumbnail!.originalHeight
                .toString()));
        prefetchImages(url, event.context);
        category.subCategories?.forEach((sub) {
          url = addSuitableWidthAndHeightToImage(
              imageUrl: sub.mostViewedProductThumbnail!.filePath!,
              width: 50,
              // the width of the image in the ui
              height: 50,
              // the height of the image in the ui
              ordinalWidth: double.tryParse(
                  sub.mostViewedProductThumbnail!.originalWidth.toString()),
              ordinalHeight: double.tryParse(
                  sub.mostViewedProductThumbnail!.originalHeight.toString()));
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
        print(
            "******************--------------//////////////////**********&${state.getProductListingWithFiltersPaginationModels[keyWithoutFilter]?.items.length}----///////////////////////////////////////////////////////");
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

  FutureOr<void> _onGetCartItemEvent(
      GetCartItemEvent event, Emitter<HomeState> emit) async {
    Map<String, List<Cart>> cartCollection = {};
    List<Cart> carts;
    emit(state.copyWith(getCartItemsStatus: GetCartItemsStatus.loading));
    final response = await getCartItemUseCase(NoParams());
    response.fold((l) {
      if (!isFailedTheFirstTime.contains('GetCartItemEvent')) {
        add(GetCartItemEvent());
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
        if (cartCollection.containsKey(element.boutique!.id.toString())) {
          cartCollection[element.boutique!.id.toString()]!.add(element);
        } else {
          cartCollection.addAll({
            element.boutique!.id.toString(): [element]
          });
        }
      });
      apisMustNotToRequest.add('GetCartItemEvent');
      isFailedTheFirstTime.remove('GetCartItemEvent');
      emit(state.copyWith(
          currentQuantityForCart: currentQuantity,
          addImagesToProductIdForCart: addImagesToProductIdForCart,
          getCartShippingItemsModel: r,
          cartCollection: Map.of(cartCollection),
          getCartItemsStatus: GetCartItemsStatus.success));
      // add(AddItemToCartEvent());
    });
    add(GetOldCartItemEvent());
  }

  FutureOr<void> _onGetOldCartItemEvent(
      GetOldCartItemEvent event, Emitter<HomeState> emit) async {
    Map<String, List<oldCart.OldCart>> oldCartCollection = {};
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
        if (oldCartCollection.containsKey(element.boutique?.id.toString())) {
          oldCartCollection[element.boutique!.id.toString()]!.add(element);
        } else {
          oldCartCollection.addAll({
            element.boutique!.id.toString(): [element]
          });
        }
      });
      Map<String, Products> productITemForCart =
          Map.of(state.productITemForCart);
      print("%%%%%%%%%%${productITemForCart.keys.toList()}%%%%%%/////////");

      List<String> productIdsInCart = [];
      state.cartCollection?.forEach(
        (key, value) {
          value.forEach(
            (element) {
              productIdsInCart.add(element.productId.toString());
            },
          );
        },
      );
      oldCartCollection.forEach(
        (key, value) {
          value.forEach(
            (element) {
              productIdsInCart.add(element.productId.toString());
            },
          );
        },
      );
      print(
          "%%%%%%%%%%${productITemForCart.keys.toList()}%%%%%%%%%%%%%%%%%%${productIdsInCart}");
      productITemForCart.removeWhere(
        (key, value) => !productIdsInCart.contains(key),
      );
      apisMustNotToRequest.add('GetoldCartItemEvent');
      isFailedTheFirstTime.remove('GetoldCartItemEvent');
      emit(state.copyWith(
          productITemForCart: productITemForCart,
          getOldCartModel: r,
          oldCartCollection: Map.of(oldCartCollection),
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
          productITemForCart.addAll({element.id.toString(): element});
        },
      );

      emit(state.copyWith(
        getListOfProductsFoundedInCartStatus:
            GetListOfProductsFoundedInCartStatus.success,
        productITemForCart: productITemForCart,
      ));
    });
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
    Map<String, List<int>> CurrentQuantity = state.currentQuantityForCart ?? {};
    String key = "${event.products.id.toString()}" +
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
            "you reach the max allowed quantity \n (${double.tryParse(event.maxAllowed ?? "0")?.round()} items) of this Product \n you can Add only ${((double.tryParse(event.maxAllowed ?? "0") ?? 0) - (CurrentQuantity.isEmpty ? 0 : CurrentQuantity[key]![0])).round()} items",
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
            fishAddAllTheItems: event.fishAddAllTheItems,
            countOfPieces: event.countOfPieces,
            image: event.image,
            currentSize: currentSize,
            maxAllowed: (double.tryParse(event.maxAllowed ?? "0") ?? 0),
            colorName: event.colorName,
            productId: event.products.id.toString(),
            quantity: quantity,
            cartId: CurrentQuantity[key]![1].toString(),
            boutiqueId: event.boutiqueId.toString()));
        return;
      }
    } else {
      if (event.quantity!.round() >
              (double.tryParse(event.maxAllowed ?? "0") ?? 0) &&
          (double.tryParse(event.maxAllowed ?? "0") ?? 0) != 0) {
        showMessage(
            "you reach the max allowed quantity \n (${double.tryParse(event.maxAllowed ?? "0")?.round()} items) of this Product \n you can Add only ${((double.tryParse(event.maxAllowed ?? "0") ?? 0) - (CurrentQuantity.isEmpty ? 0 : CurrentQuantity[key]![0])).round()} items",
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
    BoutiquesCart boutiquesCart = BoutiquesCart(
        icon: IconCart(filePath: event.boutiqueIcon), id: event.boutiqueId);
    Cart cart = Cart(
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
      productId: event.products.id,
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
        addItemInCartStatus: AddItemInCartStatus.loading));

    final response = await addItemToCartUseCase(
      AddITemToCartParams(
        image: event.image.split("/").last,
        choice_1: event.choice_1,
        color: event.color,
        id: event.products.id.toString(),
        quantity: event.quantity,
      ),
    );

    response.fold((l) {
      add(UpdateListOfItemForAddToCartEvent(
          imageForAddToCart: ImageForAddToCart(),
          operation: "remove",
          productId: event.products.id.toString(),
          resetTheList: true));
      if (!isFailedTheFirstTime.contains('AddCartItemEvent')) {
        add(AddItemToCartEvent(
            fishAddAllTheItems: event.fishAddAllTheItems,
            countOfPieces: event.countOfPieces,
            colorName: event.colorName,
            image: event.image,
            products: event.products,
            choice_1: event.choice_1,
            maxAllowed: event.maxAllowed,
            color: event.color,
            quantity: event.quantity));
        isFailedTheFirstTime.add('AddCartItemEvent');
      }
      emit(state.copyWith(addItemInCartStatus: AddItemInCartStatus.failure));
      state.cartCollection![event.boutiqueId.toString()]!.remove(cart);
      if (state.cartCollection![event.boutiqueId.toString()].isNullOrEmpty) {
        state.cartCollection!.remove(event.boutiqueId.toString());
      }
      emit(state.copyWith(cartCollection: state.cartCollection));

      showMessage(
        l.message,
        foreGroundColor: Colors.white,
        backGroundColor: Colors.black,
      );
    }, (r) {
      add(UpdateListOfItemForAddToCartEvent(
          imageForAddToCart: ImageForAddToCart(),
          operation: "remove",
          productId: event.products.id.toString(),
          resetTheList: true));
      emit(state.copyWith(addItemInCartStatus: AddItemInCartStatus.success));
      if (r.data == null || r.data == "") {
        state.cartCollection![event.boutiqueId.toString()]!.remove(cart);
        if (state.cartCollection![event.boutiqueId.toString()].isNullOrEmpty) {
          state.cartCollection!.remove(event.boutiqueId.toString());
        }
        emit(state.copyWith(cartCollection: state.cartCollection));
        if (event.fishAddAllTheItems) {
          showMessage(r.message!,
              foreGroundColor: Colors.white,
              backGroundColor: Colors.black,
              showInRelease: true,
              timeShowing: Toast.LENGTH_SHORT);
          isFailedTheFirstTime.remove('AddCartItemEvent');
          add(GetCartItemEvent());
        }

        return;
      }
      if (r.data!.status != 1) {
        state.cartCollection![event.boutiqueId.toString()]!.remove(cart);
        if (state.cartCollection![event.boutiqueId.toString()].isNullOrEmpty) {
          state.cartCollection!.remove(event.boutiqueId.toString());
        }
        emit(state.copyWith(cartCollection: state.cartCollection));
      } else {
        Map<String, Map<int, List<String>>> addImagesToProductIdForCart =
            Map.from(state.addImagesToProductIdForCart);
        if (addImagesToProductIdForCart[event.products.id.toString()] == null) {
          addImagesToProductIdForCart[event.products.id.toString()] = {};
        }
        if (!addImagesToProductIdForCart[event.products.id.toString()]![
                r.data!.idCart!]
            .isNullOrEmpty) {
          for (int i = 0; i < event.quantity!; i++) {
            addImagesToProductIdForCart[event.products.id.toString()]![
                    r.data!.idCart!]!
                .add(event.image);
          }
          ;
        } else {
          addImagesToProductIdForCart[event.products.id.toString()]![
              r.data!.idCart!] = [];
          for (int i = 0; i < event.quantity!; i++) {
            addImagesToProductIdForCart[event.products.id.toString()]![
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
            productId: event.products.id.toString()));

        state.cartCollection![event.boutiqueId.toString()]!.remove(cart);
        cart = cart.copyWith(id: r.data!.idCart!);
        state.cartCollection![event.boutiqueId.toString()]!.add(cart);
        emit(state.copyWith(
            cartCollection: state.cartCollection,
            addImagesToProductIdForCart: addImagesToProductIdForCart));
        add(AddProductItemForCartEvent(
            productId: event.products.id.toString(), product: event.products));
      }

      if (event.fishAddAllTheItems) {
        add(GetCartItemEvent());
        showMessage(r.message!,
            foreGroundColor: Colors.white,
            backGroundColor: Colors.black,
            showInRelease: true,
            timeShowing: Toast.LENGTH_SHORT);
        isFailedTheFirstTime.remove('AddCartItemEvent');
      }
    });
  }

  FutureOr<void> _onAddProductItemForCartEvent(
      AddProductItemForCartEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(addItemInCartStatus: AddItemInCartStatus.init));
    Map<String, Products> productsForCart =
        Map.of(state.productITemForCart ?? {});
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
    Cart cart = state.cartCollection![event.boutiqueId]!
        .firstWhere((element) => element.id.toString() == event.itemId);
    Map<String, List<Cart>>? cartCollection = Map.of(state.cartCollection!);
    cartCollection[event.boutiqueId]!.remove(cart);
    if (cartCollection[event.boutiqueId.toString()].isNullOrEmpty) {
      cartCollection.remove(event.boutiqueId.toString());
    }
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
      Map<String, List<Cart>>? cartCollection = Map.of(state.cartCollection!);
      if (cartCollection[event.boutiqueId].isNullOrEmpty) {
        cartCollection[event.boutiqueId] = [];
      }
      cartCollection[event.boutiqueId]!.add(cart);

      emit(state.copyWith(
          addImagesToProductIdForCart: preAddImagesToProductIdForCart,
          cartCollection: cartCollection,
          deleteItemInCartStatus: DeleteItemInCartStatus.failure));
      showMessage(
        "Item Was't Deleted",
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
        "Item Was Deleted successfuly",
        foreGroundColor: Colors.white,
        backGroundColor: Colors.black,
      );
    });
  }

  FutureOr<void> _onHideItemInOldCartEvent(
      HideItemInOldCartEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(hideItemInOldCartStatus: HideItemInOldCartStatus.init));
    Map<String, List<oldCart.OldCart>>? preOldCartCollection =
        state.oldcartCollection;
    oldCart.OldCart? cart;
    if (!(event.hideAll ?? false)) {
      cart = state.oldcartCollection![event.boutiqueId]!.firstWhere(
          (element) => element.id.toString() == event.oldCartId.toString());

      preOldCartCollection![event.boutiqueId]!.remove(cart);
      if (preOldCartCollection[event.boutiqueId.toString()].isNullOrEmpty) {
        preOldCartCollection.remove(event.boutiqueId.toString());
      }
    }

    emit(state.copyWith(
        oldCartCollection: (event.hideAll ?? false) ? {} : preOldCartCollection,
        hideItemInOldCartStatus: HideItemInOldCartStatus.loading));
    final response = await hideItemsInOldCartUseCase(HideItemsInOldCartParams(
        hideAll: event.hideAll ?? false, oLdCartId: event.oldCartId));

    response.fold((l) {
      Map<String, List<oldCart.OldCart>>? oldCartCollection =
          Map.of(state.oldcartCollection!);
      if (!(event.hideAll ?? false)) {
        if (oldCartCollection[event.boutiqueId].isNullOrEmpty) {
          oldCartCollection[event.boutiqueId!] = [];
        }
        oldCartCollection[event.boutiqueId]!.add(cart!);
      }

      emit(state.copyWith(
          oldCartCollection: (event.hideAll ?? false)
              ? preOldCartCollection
              : oldCartCollection,
          hideItemInOldCartStatus: HideItemInOldCartStatus.failure));
      showMessage(
        "Item Was't Hidden",
        foreGroundColor: Colors.white,
        backGroundColor: Colors.black,
      );
    }, (r) {
      emit(state.copyWith(
        hideItemInOldCartStatus: HideItemInOldCartStatus.success,
      ));

      showMessage(
        "Item Was Hidden successfuly",
        foreGroundColor: Colors.white,
        backGroundColor: Colors.black,
      );
    });
  }

  FutureOr<void> _onConvertItemFromOldcartToCartEvent(
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
  }

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
          "you reach the max allowed quantity \n (${(event.maxAllowed ?? 0.0).round()} items) of this Product",
          foreGroundColor: Colors.white,
          backGroundColor: Colors.black,
          showInRelease: true,
          timeShowing: Toast.LENGTH_LONG);
      return;
    }
    emit(state.copyWith(updateItemInCartStatus: UpdateItemInCartStatus.init));
    Cart cart = state.cartCollection![event.boutiqueId]!
        .firstWhere((element) => element.id.toString() == event.cartId);
    Cart PreCart = cart;
    cart = cart.copyWith(quantity: event.quantity);

    state.cartCollection![event.boutiqueId] =
        state.cartCollection![event.boutiqueId]!.map((e) {
      if (e.id.toString() == event.cartId) {
        return cart;
      } else {
        return e;
      }
    }).toList();
    emit(state.copyWith(
        cartCollection: state.cartCollection,
        updateItemInCartStatus: UpdateItemInCartStatus.loading));
    final response = await updateItemInCartUseCase(
        UpdateITemInCartParams(id: event.cartId, quantity: event.quantity));

    response.fold((l) {
      isFailedTheFirstTime.add('UpdateCartItemEvent');
      state.cartCollection![event.boutiqueId] =
          state.cartCollection![event.boutiqueId]!.map((e) {
        if (e.id.toString() == event.cartId) {
          return PreCart;
        } else {
          return e;
        }
      }).toList();
      emit(state.copyWith(cartCollection: state.cartCollection));
      showMessage(
        l.message,
        foreGroundColor: Colors.white,
        backGroundColor: Colors.black,
      );
      emit(state.copyWith(
          updateItemInCartStatus: UpdateItemInCartStatus.failure));
    }, (r) {
      emit(state.copyWith(
          updateItemInCartStatus: UpdateItemInCartStatus.success));
      if (r.data == null || r.data == "") {
        state.cartCollection![event.boutiqueId] =
            state.cartCollection![event.boutiqueId]!.map((e) {
          if (e.id.toString() == event.cartId) {
            return PreCart;
          } else {
            return e;
          }
        }).toList();

        emit(state.copyWith(
          cartCollection: state.cartCollection,
        ));
        if (event.fishAddAllTheItems) {
          add(GetCartItemEvent());
          showMessage(r.message!,
              foreGroundColor: Colors.white,
              backGroundColor: Colors.black,
              showInRelease: true,
              timeShowing: Toast.LENGTH_SHORT);
          isFailedTheFirstTime.remove('AddCartItemEvent');
        }
        isFailedTheFirstTime.remove('UpdateCartItemEvent');
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
          add(GetCartItemEvent());
          showMessage(r.message!,
              foreGroundColor: Colors.white,
              backGroundColor: Colors.black,
              showInRelease: true,
              timeShowing: Toast.LENGTH_SHORT);
          isFailedTheFirstTime.remove('AddCartItemEvent');
        }
      } else {
        state.cartCollection![event.boutiqueId] =
            state.cartCollection![event.boutiqueId]!.map((e) {
          if (e.id.toString() == event.cartId) {
            return PreCart;
          } else {
            return e;
          }
        }).toList();
        emit(state.copyWith(cartCollection: state.cartCollection));

        isFailedTheFirstTime.remove('UpdateCartItemEvent');
        if (event.fishAddAllTheItems) {
          add(GetCartItemEvent());
          showMessage(r.message!,
              foreGroundColor: Colors.white,
              backGroundColor: Colors.black,
              showInRelease: true,
              timeShowing: Toast.LENGTH_SHORT);
          isFailedTheFirstTime.remove('AddCartItemEvent');
        }
      }
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
          isExpandedForLidtingPage: event.isExpandedForListing
      ),
    );
  }

  FutureOr<void> _onChangeSelectedFiltersEvent(
      ChangeSelectedFiltersEvent event, Emitter<HomeState> emit) {
    bool makeChoosedFiltersNull = false;
    String key = event.boutiqueSlug + (event.category ?? '');
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
      choosedFilters[key] = null;
    } else {
      choosedFilters[key] = event.filtersChoosedByUser;
    }
    emit(state.copyWith(
        choosedFiltersByUser: Map.of(choosedFilters),
        isExpandedForLidtingPage: event.isExpandedForListing,
        theReplyFromGemini: event.resetChoosedFilters ? "" : null));
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
    print("//////////////////////////////////////111${event.maxAllowed}");
    List<ImageForAddToCart>? listitemForAddToCart =
        List.of(state.ListitemForAddToCart ?? []);
    listitemForAddToCart.removeWhere((element) => element.quantity == 0);
    for (var i = 0; i < listitemForAddToCart.length; i++) {
      add(AddItemToCartEvent(
          fishAddAllTheItems: i == listitemForAddToCart.length - 1,
          countOfPieces: listitemForAddToCart[i].countOfPieces,
          image: listitemForAddToCart[i].images!,
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
        size: state.CurrentColorSizeForCart != null
            ? state.CurrentColorSizeForCart!["size"]
            : "");
    List<ImageForAddToCart>? ListitemForAddToCart =
        state.ListitemForAddToCart ?? [];
    if (event.operation == "+") {
      if (ListitemForAddToCart.isNullOrEmpty) {
        ListitemForAddToCart.addAll([imageForAddToCart]);
        emit(state.copyWith(ListitemForAddToCart: ListitemForAddToCart));
        return;
      }
      ListitemForAddToCart.forEach((element) {
        if (element.images == imageForAddToCart.images &&
            element.colorName == imageForAddToCart.colorName &&
            element.size == imageForAddToCart.size) {
          element.quantity = element.quantity! + 1;
          ListitemForAddToCart!.addAll([
            ImageForAddToCart(
                countOfPieces: element.countOfPieces,
                isDuplicate: true,
                quantity: 0,
                size: element.size,
                colorName: element.colorName,
                images: element.images)
          ]);
        } else {
          if (!ListitemForAddToCart!.any((element) =>
              (element.images == imageForAddToCart.images &&
                  element.colorName == imageForAddToCart.colorName &&
                  element.size == imageForAddToCart.size))) {
            ListitemForAddToCart.add(imageForAddToCart);
          }
        }
      });
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
    }
    emit(state.copyWith(ListitemForAddToCart: ListitemForAddToCart));
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
    emit(state.copyWith(
        addOrRemoveLikeOfProductStatus: AddOrRemoveLikeOfProductStatus.init));
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
      offset: null,
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
      if (!isFailedTheFirstTime.contains('GetProductsWithFiltersEvent')) {
        add(GetProductsWithFiltersWithPrefetchForFiveFiltersEvent(
          filterSlug: event.filterSlug,
          filterType: event.filterType,
          attribute: event.attribute,
          boutiqueSlug: event.boutiqueSlug,
          category: event.category,
        ));
        isFailedTheFirstTime.add('GetProductsWithFiltersEvent');
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
      isFailedTheFirstTime.remove('GetProductsWithFiltersEvent');
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
    List<String> isSizeRequestNotification =
        List.of(state.isSizeRequestNotification);
    isSizeRequestNotification.add(event.size);
    String variant = event.selectedColorName == ''
        ? event.size
        : "${event.selectedColorName}-${event.size}";
    emit(state.copyWith(isSizeRequestNotification: isSizeRequestNotification));
    final response =
        await requestForNotificationWhenProductBecameAvailableUseCase(
            RequestForNotificationWhenProductBecameAvailableParams(
                event.productId,
                event.notificationTypeId,
                variant,
                prefsRepository.myMarketId!));
    response.fold((l) {
      isSizeRequestNotification = List.of(state.isSizeRequestNotification);
      isSizeRequestNotification.remove(event.size);
      emit(
          state.copyWith(isSizeRequestNotification: isSizeRequestNotification));
    }, (r) {});
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
        await getFullProductDetailsUseCase(event.productId.toString());
    response.fold((l) {
      emit(state.copyWith(
          getFullProductDetailsStatus: GetFullProductDetailsStatus.failure));
    }, (r) {
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
}
