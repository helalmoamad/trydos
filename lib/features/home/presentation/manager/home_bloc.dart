import 'dart:async';
import 'dart:math';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smartlook/flutter_smartlook.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/home/data/models/get_cart_item_model.dart'
    as cart;
import 'package:trydos/features/home/data/models/get_cart_item_model.dart';

import 'package:trydos/features/home/data/models/get_comment_for_product_model.dart';
import 'package:trydos/features/home/data/models/get_home_boutiqes_model.dart';
import 'package:trydos/features/home/data/models/get_product_detail_without_related_products_model.dart';
import 'package:trydos/features/home/data/models/get_product_filters_model.dart'
    as filters_model;
import 'package:trydos/features/home/data/models/get_product_listing_with_filters_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_with_filters_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as product;
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart';

import 'package:trydos/features/home/domain/use_cases/GetCommentForProductUseCase.dart';
import 'package:trydos/features/home/domain/use_cases/get_allowed_country_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_brand_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_cart_item_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_category_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_currency_for_country.dart';
import 'package:trydos/features/home/domain/use_cases/get_home_boutiqes_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_home_sections_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_main_categories_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_product_detail_without_related_products_uswcase.dart';
import 'package:trydos/features/home/domain/use_cases/get_product_filters_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_products_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_products_with_filters_usecase.dart';

import 'package:trydos/features/home/domain/use_cases/get_starting_settings_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/remove_item_from_cart_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/update_item_from_cart_usecase.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_sheet_bottom_bar.dart';
import 'package:trydos/features/story/domain/useCases/get_width_and_height_usecase.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:uuid/uuid.dart';
import '../../../../common/helper/helper_functions.dart';
import '../../../../core/data/model/pagination_model.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../main.dart';
import '../../../chat/presentation/manager/chat_bloc.dart';
import '../../../chat/presentation/manager/chat_event.dart';
import '../../data/models/get_category_model.dart';
import '../../domain/use_cases/add_item_to_cart_usecase.dart';
import '../../domain/use_cases/get_stories_for_product_usecase.dart';
import 'home_event.dart';
import 'dart:convert' as convert;

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
    this.getCartItemUseCase,
    // this.getBrandUseCase,
    //  this.getCategoryUseCase,
    this.updateItemInCartUseCase,
    this.addItemToCartUseCase,
    this.getCommentForProductUseCase,
    this.getHomeBoutiqesUseCase,
    this.getProductFiltersUseCase,
    this.getAllowedCountryUseCase,
    this.getWidthAndHeightUseCase,
    this.getProductDetailWithoutRelatedProductsUseCase,
    this.getStartingSettingsUseCase,
    this.getCurrencyForCountryUseCase,
    this.getProductsWithoutFiltersUseCase,
    this.getProductsWithFiltersUseCase,
  ) : super(HomeState()) {
    on<HomeEvent>((event, emit) {});

    on<ResetAllSelectedAppliedFilterEvent>(
      _onResetAllSelectedAppliedFilterEvent,
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

    on<AddPrefAppliedFilterForExtendFilterEvent>(
      _onAddPrefAppliedFilterForExtendFilterEvent,
    );
    on<AddQuantityForCartEvent>(
      _onAddCurrentQuantityForCartEvent,
    );
    on<GetCurrencyForCountryEvent>(_onGetCurrencyForCountryEvent,
        transformer: throttleDroppable(throttleDuration));
    /* on<GetSearchREsultEvent>(
      _onGetSearchResultEventEvent,
    );*/

    on<GetProductFiltersEvent>(_onGetProductFiltersEvent,
        transformer: restartable());
    on<ChangeSelectedFiltersEvent>(_onChangeSelectedFiltersEvent);
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
    on<GetMainCategoriesEvent>(_onGetMainCategoriesEvent,
        transformer: throttleDroppable(throttleDuration));
    on<AddItemToCartEvent>(
      _onAddItemToCartEvent,
    );

    on<AddMultiItemsToCartEvent>(
      _onAddMultiItemsToCartEvent,
    );
    on<GetSearchListingResultEvent>(
      _onGetSearchListingResultEventEvent,
    );

    on<GetProductsWithFiltersEvent>(_onGetProductsWithFiltersEvent,
        transformer: restartable());
    on<UpdateItemInCartEvent>(
      _onUpdateItemInCartEvent,
    );
    on<RemoveSearchTextfromHistoryEvent>(
      _onRemoveSearchTextToHistoryEvent,
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

    on<RemoveItemFormCartEvent>(
      _onRemoveItemToCartEvent,
    );
    on<GetProductDatailsWithoutRelatedProductsEvent>(
      _onGetProductDatailsWithoutRelatedProductsEvent,
    );

    on<GetCommentForProductEvent>(
      _onGetCommentForProductEvent,
    );
  }

  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  final GetStartingSettingsUseCase getStartingSettingsUseCase;
  final GetWidthAndHeightUseCase getWidthAndHeightUseCase;
  final GetHomeBoutiqesUseCase getHomeBoutiqesUseCase;
  final GetCartItemUseCase getCartItemUseCase;
  final GetCurrencyForCountryUseCase getCurrencyForCountryUseCase;
  final GetCommentForProductUseCase getCommentForProductUseCase;
  final GetStoryForProductUseCase getStoryUseCase;
  final GetProductDetailWithoutRelatedProductsUseCase
      getProductDetailWithoutRelatedProductsUseCase;

  // final GetBrandUseCase getBrandUseCase;

  // final GetCategoryUseCase getCategoryUseCase;
  final GetProductsWithFiltersUseCase getProductsWithFiltersUseCase;
  final RemoveItemToCartUseCase removeItemToCartUseCase;
  final GetMainCategoriesUseCase getMainCategoriesUseCase;
  final GetProductFiltersUseCase getProductFiltersUseCase;
  final GetProductsWithoutFiltersUseCase getProductsWithoutFiltersUseCase;
  final AddItemToCartUseCase addItemToCartUseCase;
  final UpdateItemInCartUseCase updateItemInCartUseCase;
  final GetAllowedCountryUseCase getAllowedCountryUseCase;

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
      initializeSmartLook();
      // }
      emit(state.copyWith(
          startingSetting: r.data!.startingSetting,
          getStartingSettingsStatus: GetStartingSettingsStatus.success));
    });
  }

  FutureOr<void> _onGetMainCategoriesEvent(
      GetMainCategoriesEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(
        getMainCategoriesStatus: GetMainCategoriesStatus.loading));
    final response = await getMainCategoriesUseCase(NoParams());

    response.fold((l) {
      if (!isFailedTheFirstTime.contains('GetMainCategoriesEvent')) {
        add(GetMainCategoriesEvent());
        isFailedTheFirstTime.add('GetMainCategoriesEvent');
      }
      emit(state.copyWith(
          getMainCategoriesStatus: GetMainCategoriesStatus.failure));
    }, (r) {
      apisMustNotToRequest.add('GetMainCategoriesEvent');
      isFailedTheFirstTime.remove('GetMainCategoriesEvent');

      if (state.getHomeBoutiquesPaginationObjectByMainCategory['Empty']
              ?.paginationStatus ==
          PaginationStatus.success) {
        requestAPIAfterHome();
      }
      emit(state.copyWith(
          mainCategoriesResponseModel: r,
          getMainCategoriesStatus: GetMainCategoriesStatus.success));
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
    await smartLook.preferences
        .setProjectKey('c8c465313d257c63e0a282ba9856a427973888fe');
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

    Map<String, bool> reRequestTheseBoutiques =
        Map.of(state.reRequestTheseBoutiques);
    if (getHomeBoutiquesPaginationObjectByMainCategory[event.categorySlug] ==
        null) {
      getHomeBoutiquesPaginationObjectByMainCategory[event.categorySlug] =
          const PaginationModel<Boutique>.init();
    }
    if (!state.reRequestTheseBoutiques.containsKey(event.categorySlug)) {
      getHomeBoutiquesPaginationObjectByMainCategory[event.categorySlug] =
          getHomeBoutiquesPaginationObjectByMainCategory[event.categorySlug]!
              .copyWith(
                  paginationStatus: PaginationStatus.initial,
                  page: 0,
                  hasReachedMax: false);
    }
    if ((event.getWithPagination &&
        (getHomeBoutiquesPaginationObjectByMainCategory[event.categorySlug]!
                .hasReachedMax ||
            getHomeBoutiquesPaginationObjectByMainCategory[event.categorySlug]!
                    .paginationStatus ==
                PaginationStatus.loading))) {
      return;
    }
    /* if ((!event.getWithPagination &&
            getHomeBoutiquesPaginationObjectByMainCategory[event.categorySlug]!
                    .paginationStatus ==
                PaginationStatus.loading) ||
        (event.getWithPagination &&
            getHomeBoutiquesPaginationObjectByMainCategory[event.categorySlug]!
                .hasReachedMax)) {
      return;
    }*/
    print('scscscs ${event.categorySlug}');
    emit(state.copyWith(getHomeBoutiquesPaginationObjectByMainCategory:
        getHomeBoutiquesPaginationObjectByMainCategory.map((key, value) {
      if (key == event.categorySlug)
        return MapEntry(
            key, value.copyWith(paginationStatus: PaginationStatus.loading));
      return MapEntry(key, value);
    })));

    final response = await getHomeBoutiqesUseCase(GetHomeBoutiqesParams(
        offset: event.offset, categorySlug: event.categorySlug));

    response.fold((l) {
      if (!isFailedTheFirstTime.contains('GetHomeBoutiqesEvent')) {
        add(GetHomeBoutiqesEvent(
            offset: event.offset,
            getWithPagination: event.getWithPagination,
            categorySlug: event.categorySlug));
        isFailedTheFirstTime.add('GetHomeBoutiqesEvent');
      }
      emit(state.copyWith(getHomeBoutiquesPaginationObjectByMainCategory:
          getHomeBoutiquesPaginationObjectByMainCategory.map((key, value) {
        if (key == event.categorySlug)
          return MapEntry(
              key, value.copyWith(paginationStatus: PaginationStatus.failure));
        return MapEntry(key, value);
      })));
    }, (r) {
      isFailedTheFirstTime.remove('GetHomeBoutiqesEvent');
      if (state.getMainCategoriesStatus == GetMainCategoriesStatus.success) {
        requestAPIAfterHome();
      }
      List<Boutique> boutiques = List.of(
          getHomeBoutiquesPaginationObjectByMainCategory[event.categorySlug]!
              .items);
      /*for (int i = 0; i < (r.data!.boutiques?.length ?? 0); i++) {
        int index = boutiques
            .indexWhere((element) => element.id == r.data!.boutiques![i].id);
        if (index == -1) {
          boutiques.add(r.data!.boutiques![i]);
        } else {
          boutiques[index] = r.data!.boutiques![i];
        }
      }
        for (int i = 0; i < (boutiques.length ); i++) {
        int index = r.data!.boutiques!
            .indexWhere((element) => element.id == r.data!.boutiques![i].id);
        if (index == -1) {
          boutiques.remove(r.data!.boutiques![index]);
        } else {
          boutiques[i] = r.data!.boutiques![index];
        }
      }
*/
      reRequestTheseBoutiques[event.categorySlug] = true;
      if (!event.getWithPagination) {
        prefetchBoutiques(event.categorySlug);
      }
      emit(state.copyWith(
          reRequestTheseBoutiques: Map.of(reRequestTheseBoutiques),
          getHomeBoutiquesPaginationObjectByMainCategory:
              getHomeBoutiquesPaginationObjectByMainCategory.map((key, value) {
            if (key == event.categorySlug) {
              return MapEntry(
                  key,
                  value.copyWith(
                      paginationStatus: PaginationStatus.success,
                      page: event.getWithPagination
                          ? getHomeBoutiquesPaginationObjectByMainCategory[
                                      event.categorySlug]!
                                  .page +
                              1
                          : 2,
                      hasReachedMax:
                          (r.data!.boutiques?.length ?? kPageSize) < kPageSize,
                      items: !event.getWithPagination
                          ? [...r.data!.boutiques ?? []]
                          : [...boutiques, ...r.data!.boutiques ?? []]));
            } else {
              return MapEntry(key, value);
            }
          })));
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
    print(
        "5////////////****************************************************************************${event.cashedOrginalBoutique}");
    emit(state.copyWith(cashedOrginalBoutique: event.cashedOrginalBoutique));

    Map<String, PaginationModel<product.Products>?>
        getProductListingWithFiltersPaginationModels =
        Map.of(state.getProductListingWithFiltersPaginationModels);

    String keyWithoutFilter = '${event.boutiqueSlug}' +
        '${(event.cashedOrginalBoutique) ? 'withoutFilter' : ""}' +
        '${(event.category ?? '')}';
    print(keyWithoutFilter);
    String key = '${event.boutiqueSlug}' + '${(event.category ?? '')}';
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
    getProductListingWithFiltersPaginationModels[keyWithoutFilter] =
        getProductListingWithFiltersPaginationModels[keyWithoutFilter]!
            .copyWith(
      paginationStatus: PaginationStatus.loading,
    );

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
    emit(state.copyWith(
      //  reRequestProductWithFilters: Map.of(reRequestProductWithFilters),
      getProductListingWithFiltersPaginationModels:
          Map.of(getProductListingWithFiltersPaginationModels),
      choosedFiltersByUser: Map.of(choosedFilters),
      appliedFiltersByUser: Map.of(appliedFilters),
    ));
    if (state.appliedFiltersByUser[key] == null) {}

    final response = await getProductsWithFiltersUseCase(
        GetProductsWithFiltersParams(
            brandSlugs:
                filters.brands?.map((e) => '"${e.slug.toString()}"').toList(),
            categorySlugs: filters.categories
                ?.map((e) => '"${e.slug.toString()}"')
                .toList(),
            boutiqueSlugs: event.fromSearch ?? false
                ? filters.boutiques
                    ?.map((e) => '"${e.slug.toString()}"')
                    .toList()
                : ['"${event.boutiqueSlug}"'],
            offset: event.offset,
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
            limit: event.limit,
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
      if (!isFailedTheFirstTime.contains('GetProductsWithFiltersEvent')) {
        add(GetProductsWithFiltersEvent(
          cashedOrginalBoutique: event.cashedOrginalBoutique,
          offset: event.offset,
          boutiqueSlug: event.boutiqueSlug,
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
          choosedFiltersByUser: Map.of(prevChoosedFiltersByUser),
          getProductListingWithFiltersPaginationModels:
              Map.of(getProductListingWithFiltersPaginationModels),
          appliedFiltersByUser: Map.of(prevAppliedFiltersByUser)));
    }, (r) {
      //  if (state.idForRequest == idForRequest || state.cashedOrginalBoutique) {
      isFailedTheFirstTime.remove('GetProductsWithFiltersEvent');
      try {
        getProductListingWithFiltersPaginationModels[keyWithoutFilter] =
            getProductListingWithFiltersPaginationModels[keyWithoutFilter]!
                .copyWith(
                    paginationStatus: PaginationStatus.success,
                    page: event.getWithPagination
                        ? getProductListingWithFiltersPaginationModels[
                                    keyWithoutFilter]!
                                .page +
                            1
                        : 2,
                    hasReachedMax: (r.data!.products?.length ?? 0) < kPageSize,
                    items: event.getWithPagination
                        ? [
                            ...getProductListingWithFiltersPaginationModels[
                                    keyWithoutFilter]!
                                .items,
                            ...r.data!.products ?? []
                          ]
                        : r.data!.products);

        Map<String, filters_model.GetProductFiltersModel?> data =
            Map.of(state.getProductFiltersModel);
        List<filters_model.PriceRange> ranges =
            r.data!.prices?.priceRanges ?? [];
        ranges.removeWhere((element) => element.count == 0);
        data[key] = filters_model.GetProductFiltersModel(
            filters: filters_model.Filter(
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
        emit(state.copyWith(
          getProductListingWithFiltersPaginationModels:
              Map.of(getProductListingWithFiltersPaginationModels),
          countOfProductExpectedByFiltering: r.data!.totalSize,
          getProductFiltersModel: Map.of(data),
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
      } catch (e, st) {
        print(e);
        print(st);
      }
    });
  }

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
    ;
    List<String> sizes = [];

    emit(state.copyWith(sizes: sizes));
    if (event.variation != null) {
      event.variation!.forEach((element) {
        if (element.type!.split("-")[0] == event.currentColorName &&
            element.qty != null) {
          if (element.qty! > 0 && element.type!.split("-").length > 1) {
            sizes.add(element.type!.split("-")[1]);
          }
        }
      });
    }

    emit(state.copyWith(sizes: sizes));
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
          state.cachedProductWithoutRelatedProductsModel[event.productId] !=
              null) {
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
      productStatus.addAll({
        event.productId!:
            GetProductDetailWithoutSimilarRelatedProductsStatus.success
      });
      apisMustNotToRequest.add('GetProductDatailsWithoutRelatedProductsEvent');
      isFailedTheFirstTime
          .remove('GetProductDatailsWithoutRelatedProductsEvent');
      Map<String, GetProductDetailWithoutRelatedProductsModel> newCached =
          Map.of(state.cachedProductWithoutRelatedProductsModel);
      newCached[event.productId!] = r;
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
          choosedFiltersByUser: {},
          appliedFiltersByUser: {},
          cashedOrginalBoutique: false,
          ListitemForAddToCart: [],
          getMainCategoriesStatus: GetMainCategoriesStatus.init,
          getProductDetailWithoutSimilarRelatedProductsStatus:
              GetProductDetailWithoutSimilarRelatedProductsStatus.init,
          getStartingSettingsStatus: GetStartingSettingsStatus.init,
        )
        .toJson();
  }

  prefetchBoutiques(String currentSlug) {
    for (int i = 0;
        i <
            min(
                (1.sh - 220 - 50) ~/ 235,
                (state
                        .getHomeBoutiquesPaginationObjectByMainCategory[
                            currentSlug]
                        ?.items
                        .length ??
                    1000000));
        i++) {
      String slug = state
          .getHomeBoutiquesPaginationObjectByMainCategory[currentSlug]!
          .items[i]
          .slug
          .toString();
      if (state.boutiquesThatDidPrefetch[slug] != true) {
        add(GetProductFiltersEvent(
            cashedOrginalBoutique: true,
            fromHomePageSearch: false,
            boutiqueSlug: slug,
            category: null,
            searchText: null));
        add(GetProductsWithFiltersEvent(
            cashedOrginalBoutique: true,
            boutiqueSlug: slug,
            fromSearch: false,
            category: null,
            searchText: null,
            offset: 1));
      }
    }
  }

  FutureOr<void> _onGetProductFiltersEvent(
      GetProductFiltersEvent event, Emitter<HomeState> emit) async {
    String key = event.boutiqueSlug + (event.category ?? '');
    Map<String, bool> boutiquesThatDidPrefetch =
        Map.of(state.boutiquesThatDidPrefetch);
    boutiquesThatDidPrefetch[key] = true;
    Map<String, GetProductFiltersStatus> statuses =
        Map.of(state.getProductFiltersStatus);
    statuses[key] = GetProductFiltersStatus.loading;
    emit(state.copyWith(
        getProductFiltersStatus: Map.of(statuses),
        boutiquesThatDidPrefetch: Map.of(boutiquesThatDidPrefetch)));
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
      searchText: filters.searchText ?? event.searchText,
      brandSlugs: filters.brands?.map((e) => '"${e.slug.toString()}"').toList(),
      categorySlugs: event.category != null
          ? [
              ...(filters.categories
                      ?.map((e) => '"${e.slug.toString()}"')
                      .toList() ??
                  []),
              event.category!
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
      if (!isFailedTheFirstTime.contains('GetProductFiltersEvent')) {
        add(GetProductFiltersEvent(
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
            totalProductNumber: r.filters!.totalSize,
            countOfProductExpectedByFiltering: r.filters!.totalSize,
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

  FutureOr<void> _onGetCommentForProductEvent(
      GetCommentForProductEvent event, Emitter<HomeState> emit) async {
    String keyForCacheData = event.productId;
    Map<String, GetCommentForProductModel> getCommentForProduct =
        Map.of(state.getCommentForProductModel);

    if (getCommentForProduct[keyForCacheData] == null) {
      emit(state.copyWith(
          getCommentForProductStatus: GetCommentForProductStatus.init));
    }

    if (!state.getCommentForProductModel.containsKey(keyForCacheData)) {
      emit(state.copyWith(
          getCommentForProductStatus: GetCommentForProductStatus.loading));
    }

    final response = await getCommentForProductUseCase(event.productId);

    response.fold((l) {
      if (!isFailedTheFirstTime.contains('GetCommentForProductEvent')) {
        add(GetCommentForProductEvent(productId: event.productId));
        isFailedTheFirstTime.add('GetCommentForProductEvent');
      }
      emit(state.copyWith(
          getCommentForProductModel: Map.of(getCommentForProduct),
          getCommentForProductStatus: GetCommentForProductStatus.init));
    }, (r) {
      isFailedTheFirstTime.remove('GetCommentForProductEvent');
      if (getCommentForProduct[keyForCacheData] == null ||
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
          getCartShippingItemsModel: r,
          cartCollection: Map.of(cartCollection),
          getCartItemsStatus: GetCartItemsStatus.success));
      // add(AddItemToCartEvent());
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

    if (!CurrentQuantity[key].isNullOrEmpty) {
      if (CurrentQuantity[key]![0] > 0) {
        add(UpdateItemInCartEvent(
            countOfPieces: event.countOfPieces,
            image: event.image,
            currentSize: currentSize,
            colorName: event.colorName,
            productId: event.products.id.toString(),
            quantity: event.quantity!,
            cartId: CurrentQuantity[key]![1].toString(),
            boutiqueId: event.boutiqueId.toString()));
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
    if (state.cartCollection == null) {
      emit(state
          .copyWith(cartCollection: {"${event.boutiqueId.toString()}": []}));
    }
    if (state.cartCollection!.containsKey(event.boutiqueId.toString())) {
      state.cartCollection![event.boutiqueId.toString()]!.add(cart);
    } else {
      Map<String, List<Cart>> cartMap = {
        event.boutiqueId.toString(): [cart]
      };
      Map<String, List<Cart>>? cartCollection = state.cartCollection;
      cartCollection!.addAll(cartMap);
    }

    emit(state.copyWith(cartCollection: state.cartCollection));

    final response = await addItemToCartUseCase(AddITemToCartParams(
        image: event.image.split("/").last,
        choice_1: event.choice_1,
        color: event.color,
        id: event.products.id.toString(),
        quantity: event.quantity));

    response.fold((l) {
      if (!isFailedTheFirstTime.contains('AddCartItemEvent')) {
        add(AddItemToCartEvent(
            countOfPieces: event.countOfPieces,
            colorName: event.colorName,
            image: event.image,
            products: event.products,
            choice_1: event.choice_1,
            color: event.color,
            quantity: event.quantity));
        isFailedTheFirstTime.add('AddCartItemEvent');
      }
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
      if (r.data == null || r.data == "") {
        state.cartCollection![event.boutiqueId.toString()]!.remove(cart);
        if (state.cartCollection![event.boutiqueId.toString()].isNullOrEmpty) {
          state.cartCollection!.remove(event.boutiqueId.toString());
        }
        emit(state.copyWith(cartCollection: state.cartCollection));
        showMessage(r.message!,
            foreGroundColor: Colors.white,
            backGroundColor: Colors.black,
            showInRelease: true,
            timeShowing: Toast.LENGTH_SHORT);
        isFailedTheFirstTime.remove('AddCartItemEvent');
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
      showMessage(r.message!,
          foreGroundColor: Colors.white,
          backGroundColor: Colors.black,
          showInRelease: true,
          timeShowing: Toast.LENGTH_SHORT);
      isFailedTheFirstTime.remove('AddCartItemEvent');
    });
  }

  FutureOr<void> _onAddProductItemForCartEvent(
      AddProductItemForCartEvent event, Emitter<HomeState> emit) async {
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
    Cart cart = state.cartCollection![event.boutiqueId]!
        .firstWhere((element) => element.id.toString() == event.itemId);

    state.cartCollection![event.boutiqueId]!.remove(cart);
    if (state.cartCollection![event.boutiqueId.toString()].isNullOrEmpty) {
      state.cartCollection!.remove(event.boutiqueId.toString());
    }

    emit(state.copyWith(cartCollection: state.cartCollection));
    final response =
        await removeItemToCartUseCase(RemoveITemToCartParams(id: event.itemId));

    response.fold((l) {
      isFailedTheFirstTime.add('RemoveCartItemEvent');
      if (state.cartCollection![event.boutiqueId].isNullOrEmpty) {
        state.cartCollection![event.boutiqueId] = [];
      }
      state.cartCollection![event.boutiqueId]!.add(cart);

      emit(state.copyWith(cartCollection: state.cartCollection));
      showMessage(
        "Item Wan't Deleted",
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
          addImagesToProductIdForCart: addImagesToProductIdForCart));

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
    emit(state.copyWith(cartCollection: state.cartCollection));
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
    }, (r) {
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
        showMessage(r.message!,
            foreGroundColor: Colors.white,
            backGroundColor: Colors.black,
            showInRelease: true,
            timeShowing: Toast.LENGTH_SHORT);
        isFailedTheFirstTime.remove('AddCartItemEvent');
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
        showMessage(r.message!,
            foreGroundColor: Colors.white,
            backGroundColor: Colors.black,
            showInRelease: true,
            timeShowing: Toast.LENGTH_SHORT);
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
        showMessage(r.message!,
            foreGroundColor: Colors.white,
            backGroundColor: Colors.black,
            showInRelease: true,
            timeShowing: Toast.LENGTH_SHORT);
      }
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
    print(
        "ddddddd111111111111111{${event.filtersAppliedByUser?.filters?.brands}}11111111111111111111111ddddddddddddddddddddddddddddddddddddddddddddddddddd");

    String key = event.boutiqueSlug + (event.category ?? '');
    Map<String, filters_model.GetProductFiltersModel?> appliedFilters =
        Map.of(state.appliedFiltersByUser);
    filters_model.Filter filters =
        event.filtersAppliedByUser?.filters ?? filters_model.Filter();
    if (event.resetAppliedFilters ||
        !(((filters.colors?.isNotEmpty ?? false) ||
            (filters.brands?.isNotEmpty ?? false) ||
            (filters.attributes?.isNotEmpty ?? false) ||
            (filters.categories?.isNotEmpty ?? false) ||
            (filters.boutiques?.isNotEmpty ?? false) ||
            filters.searchText != null ||
            (filters.prices?.maxPrice != null ||
                filters.prices?.minPrice != null)))) {
      appliedFilters[key] = null;
    } else {
      appliedFilters[key] = event.filtersAppliedByUser;
    }
    emit(state.copyWith(
      appliedFiltersByUser: Map.of(appliedFilters),
    ));
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
    ));
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
    state.ListitemForAddToCart!.forEach((element) {
      if (element.quantity! > 0) {
        add(AddItemToCartEvent(
            countOfPieces: element.countOfPieces,
            image: element.images!,
            color: element.colorNum,
            colorName: element.colorName!,
            products: event.products,
            boutiqueIcon: event.boutiqueIcon,
            boutiqueId: event.boutiqueId,
            choice_1: element.size,
            quantity: element.quantity));
      }
      emit(state.copyWith(ListitemForAddToCart: []));
    });
  }

  Future<void> _onGetCurrencyForCountryEvent(
      GetCurrencyForCountryEvent event, Emitter<HomeState> emit) async {
    final response = await getCurrencyForCountryUseCase(NoParams());

    response.fold((l) {
      add(GetCurrencyForCountryEvent());
    }, (r) {
      emit(state.copyWith(
        getCurrencyForCountryModel: r,
      ));
    });
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
            print(element.images == imageForAddToCart.images);
            print(element.colorName == imageForAddToCart.colorName);

            print(element.size == imageForAddToCart.size);

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

  FutureOr<void> _onResetAllSelectedAppliedFilterEvent(
      ResetAllSelectedAppliedFilterEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(
        choosedFiltersByUser: {},
        appliedFiltersByUser: {},
        prefAppliedFilterForExtendFilter: filters_model.Filter()));
  }
}
