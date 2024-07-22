import 'dart:async';
import 'dart:math';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
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
import 'package:trydos/features/home/data/models/get_product_filters_model.dart';
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
import 'package:trydos/features/story/domain/useCases/get_width_and_height_usecase.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import '../../../../common/helper/helper_functions.dart';
import '../../../../core/data/model/pagination_model.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../main.dart';
import '../../../chat/presentation/manager/chat_bloc.dart';
import '../../../chat/presentation/manager/chat_event.dart';
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
    this.getBrandUseCase,
    this.getCategoryUseCase,
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

    on<AddCurrentColorSizeEvent>(
      _onAddCurrentSizeColorEvent,
    );
    on<AddCurrentSelectedColorEvent>(
      _onAddCurrentSelectedColorEvent,
    );
    on<AddQuantityForCartEvent>(
      _onAddCurrentQuantityForCartEvent,
    );
    on<GetCurrencyForCountryEvent>(_onGetCurrencyForCountryEvent,
        transformer: throttleDroppable(throttleDuration));
    on<GetSearchREsultEvent>(
      _onGetSearchResultEventEvent,
    );

    on<GetProductFiltersEvent>(
      _onGetProductFiltersEvent,
    );
    on<ChangeSelectedFiltersEvent>(_onChangeSelectedFiltersEvent);
    on<AddSearchTextToHistoryEvent>(
      _onAddSearchTextToHistoryEvent,
    );
    on<GetBrandEvent>(_onGetBrandEvent,
        transformer: throttleDroppable(throttleDuration));
    on<GetCategoryEvent>(_onGetCategoryEvent,
        transformer: throttleDroppable(throttleDuration));
    on<GetHomeBoutiqesEvent>(_onGetHomeBoutiquesEvent,
        transformer: throttleDroppable(Duration(seconds: 5)));
    on<GetCartItemEvent>(_onGetCartItemEvent,
        transformer: throttleDroppable(Duration(seconds: 5)));

    on<AddSelectedBoutiqueCategoryBrandSlugsForSearchEvent>(
      _onAddSelectedBoutiqueSlugsForSearchEvent,
    );
    on<GetAllowedCountriesEvent>(_onGetAllowedCountriesEvent,
        transformer: throttleDroppable(throttleDuration));

    on<GetStartingSettingsEvent>(_onGetStartingSettingsEvent,
        transformer: throttleDroppable(throttleDuration));
    on<GetMainCategoriesEvent>(_onGetMainCategoriesEvent,
        transformer: throttleDroppable(throttleDuration));
    on<AddItemToCartEvent>(
      _onAddItemToCartEvent,
    );
    on<GetSearchListingResultEvent>(
      _onGetSearchListingResultEventEvent,
    );

    on<GetProductsWithFiltersEvent>(
      _onGetProductsWithFiltersEvent,
    );
    on<UpdateItemInCartEvent>(
      _onUpdateItemInCartEvent,
    );
    on<RemoveSearchTextfromHistoryEvent>(
      _onRemoveSearchTextToHistoryEvent,
    );

    on<GetProductsWithoutFiltersEvent>(_onGetProductsWithoutFiltersEvent,
        transformer: throttleDroppable(Duration(seconds: 5)));
    on<GetStoryForProductEvent>(_onGetStoryEvent,
        transformer: throttleDroppable(Duration(seconds: 5)));
    on<AddProductItemForCartEvent>(_onAddProductItemForCartEvent,
        transformer: throttleDroppable(Duration(seconds: 5)));
    on<AddSizesFotColorsEvent>(
      _onAddSizesFotColorsEvent,
    );

    on<RemoveItemFormCartEvent>(_onRemoveItemToCartEvent,
        transformer: throttleDroppable(Duration(seconds: 5)));
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
  final GetBrandUseCase getBrandUseCase;

  final GetCategoryUseCase getCategoryUseCase;
  final GetProductsWithFiltersUseCase getProductsWithFiltersUseCase;
  final RemoveItemToCartUseCase removeItemToCartUseCase;
  final GetMainCategoriesUseCase getMainCategoriesUseCase;
  final GetProductFiltersUseCase getProductFiltersUseCase;
  final GetProductsWithoutFiltersUseCase getProductsWithoutFiltersUseCase;
  final AddItemToCartUseCase addItemToCartUseCase;
  final UpdateItemInCartUseCase updateItemInCartUseCase;
  final GetAllowedCountryUseCase getAllowedCountryUseCase;

  //final Smartlook smartLook = Smartlook.instance;

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
      //   initializeSmartLook();
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

      /*if (state.getHomeBoutiquesPaginationObjectByMainCategory['Men_36']
              ?.paginationStatus ==
          PaginationStatus.success) {
        requestAPIAfterHome();
      }*/
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
    if (prefsRepository.chatToken != null) {
      GetIt.I<ChatBloc>().add(GetChatsEvent(limit: 10));
    }
  }

  // initializeSmartLook() async {
  //   String deviceId = (await HelperFunctions.getDeviceId()).toString();
  //   await smartLook.preferences
  //       .setProjectKey('db8b1330aa8b622827ae6092023f88bf4e56be53');
  //   await smartLook.preferences.setFrameRate(2);
  //   await smartLook.user.setIdentifier(deviceId);
  //   await smartLook.user
  //       .setName(GetIt.I<PrefsRepository>().myChatName ?? 'No_Name');
  //   await smartLook.start();
  // }

  _onAddCurrentSelectedColorEvent(
      AddCurrentSelectedColorEvent event, Emitter<HomeState> emit) {
    Map<String, int> currentSelectedColorForEveryProduct =
        Map.of(state.currentSelectedColorForEveryProduct);
    currentSelectedColorForEveryProduct[event.productId] =
        event.currentSelectedColor;
    emit(state.copyWith(
        currentSelectedColorForEveryProduct:
            currentSelectedColorForEveryProduct));
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
    if ((!event.getWithPagination &&
            getHomeBoutiquesPaginationObjectByMainCategory[event.categorySlug]!
                    .paginationStatus ==
                PaginationStatus.loading) ||
        (event.getWithPagination &&
            getHomeBoutiquesPaginationObjectByMainCategory[event.categorySlug]!
                .hasReachedMax)) {
      return;
    }

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
      if (!isFailedTheFirstTime.contains('GetHomeSectionsEvent')) {
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
      for (int i = 0; i < (r.data!.boutiques?.length ?? 0); i++) {
        int index = boutiques
            .indexWhere((element) => element.id == r.data!.boutiques![i].id);
        if (index == -1) {
          boutiques.add(r.data!.boutiques![i]);
        } else {
          boutiques[index] = r.data!.boutiques![i];
        }
      }
      if (event.categorySlug == "Empty") {
        emit(state.copyWith(boutiques: boutiques));
      }
      reRequestTheseBoutiques[event.categorySlug] = true;
      emit(state.copyWith(
          reRequestTheseBoutiques: reRequestTheseBoutiques,
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
                      items: boutiques));
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

    Map<String, bool> reRequestTheseProductListingInBoutiques =
        Map.of(state.reRequestTheseProductListingInBoutiques);
    if (getProductsWithoutFilters[keyForCacheData] == null) {
      getProductsWithoutFilters[keyForCacheData] =
          const PaginationModel<product.Products>.init();
    }

    if (!reRequestTheseProductListingInBoutiques.containsKey(keyForCacheData)) {
      getProductsWithoutFilters[keyForCacheData] =
          getProductsWithoutFilters[keyForCacheData]!.copyWith(
              paginationStatus: PaginationStatus.initial,
              page: 0,
              hasReachedMax: false);
    }
    if ((!event.getWithPagination &&
            (getProductsWithoutFilters[keyForCacheData]!.paginationStatus ==
                    PaginationStatus.loading ||
                getProductsWithoutFilters[keyForCacheData]!.paginationStatus ==
                    PaginationStatus.success)) ||
        (event.getWithPagination &&
            getProductsWithoutFilters[keyForCacheData]!.hasReachedMax)) {
      return;
    }
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
              reRequestTheseProductListingInBoutiques,
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
                            : getProductsWithoutFilters[keyForCacheData]!.items,
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
    PaginationModel<product.Products>
        getProductListingWithFiltersPaginationModels =
        state.getProductListingWithFiltersPaginationModels ??
            PaginationModel.init();

    GetProductFiltersModel? prevAppliedFiltersByUser,
        prevChoosedFiltersByUser,
        appliedFiltersByUser;
    prevAppliedFiltersByUser = state.appliedFiltersByUser;
    prevChoosedFiltersByUser = state.choosedFiltersByUser;
    appliedFiltersByUser =
        event.filtersAppliedByUser ?? GetProductFiltersModel(filters: Filter());

    emit(state.copyWith(
      getProductListingWithFiltersPaginationModels:
          getProductListingWithFiltersPaginationModels.copyWith(
              paginationStatus: PaginationStatus.loading),
      choosedFiltersByUser: null,
      resetAppliedFilters:
          !((appliedFiltersByUser.filters!.colors?.isNotEmpty ?? false) ||
              (appliedFiltersByUser.filters!.brands?.isNotEmpty ?? false) ||
              (appliedFiltersByUser.filters!.attributes?.isNotEmpty ?? false) ||
              (appliedFiltersByUser.filters!.categories?.isNotEmpty ?? false) ||
              appliedFiltersByUser.filters!.prices != null),
      appliedFiltersByUser: appliedFiltersByUser,
    ));
    final response = await getProductsWithFiltersUseCase(
        GetProductsWithFiltersParams(
            offset: event.offset,
            boutiqueSlug: event.boutiqueSlug,
            attributes: appliedFiltersByUser.filters!.attributes.isNullOrEmpty
                ? null
                : [
                    {
                      "id": appliedFiltersByUser.filters!.attributes![0].id,
                      "name": appliedFiltersByUser.filters!.attributes![0].name,
                      "options":
                          appliedFiltersByUser.filters!.attributes![0].options,
                    }
                  ],
            brands: appliedFiltersByUser.filters!.brands
                ?.map((e) => e.id.toString())
                .toList(),
            categories: appliedFiltersByUser.filters!.categories
                ?.map((e) => e.id.toString())
                .toList(),
            colors: appliedFiltersByUser.filters!.colors
                ?.map((e) => e.toString())
                .toList(),
            category: event.category,
            limit: event.limit,
            prices: appliedFiltersByUser.filters!.prices != null
                ? [
                    '${appliedFiltersByUser.filters!.prices!.minPrice}-${appliedFiltersByUser.filters!.prices!.maxPrice}'
                  ]
                : null,
            searchText: event.searchText));

    response.fold((l) {
      if (!isFailedTheFirstTime.contains('GetProductsWithFiltersEvent')) {
        add(GetProductsWithFiltersEvent(
          offset: event.offset,
          boutiqueSlug: event.boutiqueSlug,
          category: event.category,
          limit: event.limit,
          filtersAppliedByUser: event.filtersAppliedByUser,
          searchText: event.searchText,
        ));
        isFailedTheFirstTime.add('GetProductsWithFiltersEvent');
      }
      emit(state.copyWith(
          choosedFiltersByUser: prevChoosedFiltersByUser,
          getProductListingWithFiltersPaginationModels:
              getProductListingWithFiltersPaginationModels.copyWith(
                  paginationStatus: PaginationStatus.failure),
          appliedFiltersByUser: prevAppliedFiltersByUser));
    }, (r) {
      isFailedTheFirstTime.remove('GetProductsWithFiltersEvent');
      emit(state.copyWith(
        getProductListingWithFiltersPaginationModels:
            getProductListingWithFiltersPaginationModels.copyWith(
                paginationStatus: PaginationStatus.success,
                page: event.getWithPagination
                    ? getProductListingWithFiltersPaginationModels.page + 1
                    : 2,
                hasReachedMax: (r.data!.products?.length ?? 0) < kPageSize,
                items: event.getWithPagination
                    ? [
                        ...getProductListingWithFiltersPaginationModels.items,
                        ...r.data!.products ?? []
                      ]
                    : r.data!.products),
        getProductFiltersModel: GetProductFiltersModel(
            filters: Filter(
          brands: r.data!.brands,
          attributes: r.data!.attributes,
          prices: r.data!.prices,
          colors: r.data!.colors,
          categories: r.data!.categories,
        )),
      ));
    });
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
      apisMustNotToRequest.add('GetProductDatailsWithoutRelatedProductsEvent');
      isFailedTheFirstTime
          .remove('GetProductDatailsWithoutRelatedProductsEvent');
      Map<String, GetProductDetailWithoutRelatedProductsModel> newCached =
          Map.of(state.cachedProductWithoutRelatedProductsModel);
      newCached[event.productId!] = r;
      emit(state.copyWith(
          cachedProductWithoutRelatedProductsModel: newCached,
          getProductDetailWithoutSimilarRelatedProductsStatus:
              GetProductDetailWithoutSimilarRelatedProductsStatus.success));
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
      reRequestTheseBoutiques: {},
      getMainCategoriesStatus: GetMainCategoriesStatus.init,
      getProductDetailWithoutSimilarRelatedProductsStatus:
          GetProductDetailWithoutSimilarRelatedProductsStatus.init,
      getStartingSettingsStatus: GetStartingSettingsStatus.init,
    ).toJson();
  }

  FutureOr<void> _onGetProductFiltersEvent(
      GetProductFiltersEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(
      getProductFiltersStatus: GetProductFiltersStatus.loading,
      choosedFiltersByUser: event.filtersChoosedByUser,
      resetAppliedFilters: event.filtersChoosedByUser == null,
    ));
    Filter filters = event.filtersChoosedByUser?.filters ?? Filter();
    final response = await getProductFiltersUseCase(GetProductsFiltersParams(
      category: event.category,
      boutiqueSlug: event.boutiqueSlug,
      attributes: filters.attributes.isNullOrEmpty
          ? null
          : [
              {
                "id": filters.attributes![0].id,
                "name": filters.attributes![0].name,
                "options": filters.attributes![0].options,
              }
            ],
      brands: filters.brands?.map((e) => e.id.toString()).toList(),
      categories: filters.categories?.map((e) => e.id.toString()).toList(),
      colors: filters.colors?.map((e) => e.toString()).toList(),
      prices: filters.prices != null
          ? ['${filters.prices!.minPrice}-${filters.prices!.maxPrice}']
          : null,
    ));
    response.fold((l) {
      if (!isFailedTheFirstTime.contains('GetProductFiltersEvent')) {
        add(GetMainCategoriesEvent());
        isFailedTheFirstTime.add('GetProductFiltersEvent');
      }
      emit(state.copyWith(
          getProductFiltersStatus: GetProductFiltersStatus.failure));
    }, (r) {
      apisMustNotToRequest.add('GetProductFiltersEvent');
      isFailedTheFirstTime.remove('GetProductFiltersEvent');
      emit(state.copyWith(
          getProductFiltersStatus: GetProductFiltersStatus.success,
          getProductFiltersModel: r,
          choosedFiltersByUser: event.filtersChoosedByUser));
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
          getCommentForProductModel: getCommentForProduct,
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
          cartCollection: cartCollection,
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
    String currentSize = state.CurrentColorSizeForCart!["size"] ?? "";
    Map<String, List<int>> CurrentQuantity = state.currentQuantityForCart ?? {};
    String key = "${event.products.id.toString()}" +
        "${event.colorName}" +
        "${currentSize}";

    if (!CurrentQuantity[key].isNullOrEmpty) {
      if (CurrentQuantity[key]![0] > 0) {
        add(UpdateItemInCartEvent(
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
        image: event.products.brand != null ? event.products.brand!.image : "");
    VariationCart variation = VariationCart(
        color: event.colorName, size: state.CurrentColorSizeForCart!["size"]);
    BoutiquesCart boutiquesCart = BoutiquesCart(
        icon: IconCart(filePath: event.boutiqueIcon), id: event.boutiqueId);
    Cart cart = Cart(
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
        choice_1: state.CurrentColorSizeForCart != null
            ? state.CurrentColorSizeForCart!["size"]
            : "",
        color: event.color,
        id: event.id,
        quantity: event.quantity));

    response.fold((l) {
      if (!isFailedTheFirstTime.contains('AddCartItemEvent')) {
        add(AddItemToCartEvent(
            colorName: event.colorName,
            image: event.image,
            products: event.products,
            choice_1: state.CurrentColorSizeForCart!["size"],
            color: event.color,
            id: event.id,
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
            productId: event.id!, product: event.products));
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
    emit(state.copyWith(productITemForCart: productsForCart));
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
    if (CurrentQuantity.containsKey(key)) {
      CurrentQuantity[key] = [event.quantity, event.cartId];
    } else {
      CurrentQuantity.addAll({
        key: [event.quantity, event.cartId]
      });
    }
    emit(state.copyWith(currentQuantityForCart: CurrentQuantity));
  }

  FutureOr<void> _onGetSearchResultEventEvent(
      GetSearchREsultEvent event, Emitter<HomeState> emit) async {
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
  }

  FutureOr<void> _onGetSearchListingResultEventEvent(
      GetSearchListingResultEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(getSearchResultStatus: GetSearchResultStatus.loading));
    final response =
        await getProductsWithFiltersUseCase(GetProductsWithFiltersParams(
      categorySlugs: event.CategorySlug != "" ? [event.CategorySlug] : [],
      searchText: event.searchTitle,
      boutiqueSlugs: event.boutiqueSlug != "" ? [event.boutiqueSlug] : [],
    ));

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
  }

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

  FutureOr<void> _onAddSelectedBoutiqueSlugsForSearchEvent(
      AddSelectedBoutiqueCategoryBrandSlugsForSearchEvent event,
      Emitter<HomeState> emit) async {
    Map<String, List<String>>? selectedBoutiqueBrandCategorySlugsForSearch =
        state.selectedBoutiqueBrandCategorySlugsForSearch;
    event.withBoutique
        ? selectedBoutiqueBrandCategorySlugsForSearch["boutique"] =
            event.selectedBoutiqueBrandCategorySlugsForSearch
        : event.withBrand
            ? selectedBoutiqueBrandCategorySlugsForSearch["brand"] =
                event.selectedBoutiqueBrandCategorySlugsForSearch
            : selectedBoutiqueBrandCategorySlugsForSearch["category"] =
                event.selectedBoutiqueBrandCategorySlugsForSearch;
    emit(state.copyWith(
        selectedBoutiqueBrandCategorySlugsForSearch:
            selectedBoutiqueBrandCategorySlugsForSearch));
  }

  Future<void> _onGetBrandEvent(
      GetBrandEvent event, Emitter<HomeState> emit) async {
    final response = await getBrandUseCase(NoParams());

    response.fold((l) {
      add(GetBrandEvent());
    }, (r) {
      emit(state.copyWith(
        brands: r.data!.brands,
      ));
    });
  }

  Future<void> _onGetCategoryEvent(
      GetCategoryEvent event, Emitter<HomeState> emit) async {
    final response = await getCategoryUseCase(NoParams());

    response.fold((l) {
      add(GetCategoryEvent());
    }, (r) {
      emit(state.copyWith(
        category: r.data!.categories,
      ));
    });
  }

  FutureOr<void> _onChangeSelectedFiltersEvent(
      ChangeSelectedFiltersEvent event, Emitter<HomeState> emit) {
    add(GetProductFiltersEvent(
        category: event.category,
        boutiqueSlug: event.boutiqueSlug,
        filtersChoosedByUser: event.filtersChoosedByUser));
    Filter filters = event.filtersChoosedByUser?.filters ?? Filter();
    emit(state.copyWith(
        choosedFiltersByUser: ((filters.colors?.isNotEmpty ?? false) ||
                (filters.brands?.isNotEmpty ?? false) ||
                (filters.attributes?.isNotEmpty ?? false) ||
                (filters.categories?.isNotEmpty ?? false) ||
                filters.prices != null)
            ? event.filtersChoosedByUser
            : null,
        getProductListingWithFiltersPaginationModels:
            event.filtersChoosedByUser == null
                ? PaginationModel.init()
                : state.getProductListingWithFiltersPaginationModels));
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
}
