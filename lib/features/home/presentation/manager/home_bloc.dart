import 'dart:async';
import 'dart:math';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:get_it/get_it.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/home/data/models/get_cart_item_model.dart';

import 'package:trydos/features/home/data/models/get_comment_for_product_model.dart';
import 'package:trydos/features/home/data/models/get_home_boutiqes_model.dart';
import 'package:trydos/features/home/data/models/get_product_detail_without_related_products_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as product;
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart';

import 'package:trydos/features/home/domain/use_cases/GetCommentForProductUseCase.dart';
import 'package:trydos/features/home/domain/use_cases/get_cart_item_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_home_boutiqes_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_home_sections_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_main_categories_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_product_detail_without_related_products_uswcase.dart';
import 'package:trydos/features/home/domain/use_cases/get_product_filters_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_products_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_starting_settings_usecase.dart';
import 'package:trydos/features/story/domain/useCases/get_width_and_height_usecase.dart';
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
      this.getCartItemUseCase,
      this.addItemToCartUseCase,
      this.getCommentForProductUseCase,
      this.getHomeBoutiqesUseCase,
      this.getProductFiltersUseCase,
      this.getWidthAndHeightUseCase,
      this.getProductDetailWithoutRelatedProductsUseCase,
      this.getStartingSettingsUseCase,
      this.getProductsWithoutFiltersUseCase)
      : super(HomeState()) {
    on<HomeEvent>((event, emit) {});

    on<AddCurrentColorSizeEvent>(
      _onAddCurrentSizeColorEvent,
    );
    on<AddCurrentSelectedColorEvent>(
      _onAddCurrentSelectedColorEvent,
    );
    on<GetProductFiltersEvent>(_onGetProductFiltersEvent,
        transformer: throttleDroppable(throttleDuration));
    on<GetHomeBoutiqesEvent>(_onGetHomeBoutiquesEvent,
        transformer: throttleDroppable(throttleDuration));
    on<GetCartItemEvent>(
      _onGetCartItemEvent,
    );

    on<GetStartingSettingsEvent>(_onGetStartingSettingsEvent,
        transformer: throttleDroppable(throttleDuration));
    on<GetMainCategoriesEvent>(_onGetMainCategoriesEvent,
        transformer: throttleDroppable(throttleDuration));
    on<AddItemToCartEvent>(_onAddItemToCartEvent,
        transformer: throttleDroppable(Duration(seconds: 5)));

    on<GetProductsWithoutFiltersEvent>(_onGetProductsWithoutFiltersEvent,
        transformer: throttleDroppable(Duration(seconds: 5)));
    on<GetStoryForProductEvent>(_onGetStoryEvent,
        transformer: throttleDroppable(Duration(seconds: 5)));
    on<AddProductItemForCartEvent>(_onAddProductItemForCartEvent,
        transformer: throttleDroppable(Duration(seconds: 5)));
    on<AddSizesFotColorsEvent>(
      _onAddSizesFotColorsEvent,
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
  final GetCommentForProductUseCase getCommentForProductUseCase;
  final GetStoryForProductUseCase getStoryUseCase;
  final GetProductDetailWithoutRelatedProductsUseCase
      getProductDetailWithoutRelatedProductsUseCase;

  final GetMainCategoriesUseCase getMainCategoriesUseCase;
  final GetProductFiltersUseCase getProductFiltersUseCase;
  final GetProductsWithoutFiltersUseCase getProductsWithoutFiltersUseCase;
  final AddItemToCartUseCase addItemToCartUseCase;

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
      add(GetHomeBoutiqesEvent(
          offset: "1",
          categorySlug: GetIt.I<HomeBloc>()
              .state
              .mainCategoriesResponseModel!
              .data!
              .mainCategories![0]
              .slug!));
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
      bool resetListAfterGetData =
          !(reRequestTheseBoutiques[event.categorySlug] ?? false);
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
                      items: [
                        ...resetListAfterGetData
                            ? []
                            : getHomeBoutiquesPaginationObjectByMainCategory[
                                    event.categorySlug]!
                                .items,
                        ...r.data!.boutiques ?? []
                      ]));
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

    if (!state.reRequestTheseProductListingInBoutiques
        .containsKey(keyForCacheData)) {
      getProductsWithoutFilters[keyForCacheData] =
          getProductsWithoutFilters[keyForCacheData]!.copyWith(
              paginationStatus: PaginationStatus.initial,
              page: 0,
              hasReachedMax: false);
    }
    if ((!event.getWithPagination &&
            getProductsWithoutFilters[keyForCacheData]!.paginationStatus ==
                PaginationStatus.loading) ||
        (event.getWithPagination &&
            getProductsWithoutFilters[keyForCacheData]!.hasReachedMax)) {
      return;
    }
    emit(state.copyWith(getProductListingPaginationWithoutFiltersModel:
        getProductsWithoutFilters.map((key, value) {
      if (key == keyForCacheData) {
        return MapEntry(
            key, value.copyWith(paginationStatus: PaginationStatus.loading));
      } else {
        return MapEntry(key, value);
      }
    })));
    final response = await getProductsWithoutFiltersUseCase(
        GetProductsWithoutFiltersParams(
            offset: event.offset,
            boutiqueSlug: event.boutiqueSlug,
            attributes: event.attributes,
            brands: event.brands,
            category: event.category,
            limit: event.limit,
            prices: event.prices,
            searchText: event.searchText));

    response.fold((l) {
      if (!isFailedTheFirstTime.contains('GetProductsWithoutFiltersEvent')) {
        add(GetProductsWithoutFiltersEvent(
          offset: event.offset,
          attributes: event.attributes,
          brands: event.brands,
          boutiqueSlug: event.boutiqueSlug,
          category: event.category,
          limit: event.limit,
          prices: event.prices,
          searchText: event.searchText,
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
      emit(state.copyWith(getProductListingPaginationWithoutFiltersModel:
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

  FutureOr<void> _onAddSizesFotColorsEvent(
      AddSizesFotColorsEvent event, Emitter<HomeState> emit) async {
    ;
    List<String> sizes = [];
    if (event.variation != null) {
      event.variation!.forEach((element) {
        if (element.type!.split("-")[0] == event.currentColorName &&
            element.qty != null) {
          if (element.qty! > 0) {
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
    emit(state.copyWith(
        getProductDetailWithoutSimilarRelatedProductsStatus:
            GetProductDetailWithoutSimilarRelatedProductsStatus.loading));

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
      getStartingSettingsStatus: GetStartingSettingsStatus.init,
      getProductFiltersStatus: GetProductFiltersStatus.loading,
    ).toJson();
  }

  FutureOr<void> _onGetProductFiltersEvent(
      GetProductFiltersEvent event, Emitter<HomeState> emit) async {
    if(state.getProductFiltersStatus == GetProductFiltersStatus.success) return;
    emit(state.copyWith(
        getProductFiltersStatus: GetProductFiltersStatus.loading));
    final response = await getProductFiltersUseCase(NoParams());

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
          getProductFiltersModel: r,
          getProductFiltersStatus: GetProductFiltersStatus.success));
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
      print(
          "777777777777777777777777777777777++++++++++++++++++++++++++++++++++77777777++++++++99999999999999999999ng()]}");

      if (!isFailedTheFirstTime.contains('GetProductsWithoutFiltersEvent')) {
        add(GetCommentForProductEvent(productId: event.productId));
        isFailedTheFirstTime.add('GetProductsWithoutFiltersEvent');
      }
      emit(state.copyWith(
          getCommentForProductModel: getCommentForProduct,
          getCommentForProductStatus: GetCommentForProductStatus.init));
    }, (r) {
      isFailedTheFirstTime.remove('GetProductsWithoutFiltersEvent');
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
    emit(state.copyWith(getCartItemsStatus: GetCartItemsStatus.loading));
    final response = await getCartItemUseCase(NoParams());
    response.fold((l) {
      if (!isFailedTheFirstTime.contains('GetCartItemEvent')) {
        add(GetCartItemEvent());
        isFailedTheFirstTime.add('GetCartItemEvent');
      }
      emit(state.copyWith(getCartItemsStatus: GetCartItemsStatus.failure));
    }, (r) {
      apisMustNotToRequest.add('GetCartItemEvent');
      isFailedTheFirstTime.remove('GetCartItemEvent');
      emit(state.copyWith(
          getCartShippingItemsModel: r,
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
    // List<Cart> carts;
    // GetCartShippingItemsModel getCartShippingItemsModel =
    //     state.getCartShippingItemsModel!;
    // carts = state.getCartShippingItemsModel!.data!.cart ?? [];
    //  Cart cart;
    /* cart = Cart(
        name: "helal",
        thumbnail: "asset",
        offerPriceFormatted: "250 #",
        quantity: 2,
        priceNum: 233,
        variations: Variations(color: "dfdaf", size: "34 rw"));
    carts.add(cart);
    getCartShippingItemsModel.data!.cart != carts;
    emit(state.copyWith(
      getCartShippingItemsModel: getCartShippingItemsModel,
    ));*/

    final response = await addItemToCartUseCase(AddITemToCartParams(
        choice_1: state.CurrentColorSizeForCart!["size"],
        color: event.color,
        id: event.id,
        quantity: event.quantity));

    response.fold((l) {
      //carts.remove(cart);
      //   getCartShippingItemsModel.data!.cart != carts;
      //   emit(state.copyWith(
      //     getCartShippingItemsModel: getCartShippingItemsModel,
      //   ));
      if (!isFailedTheFirstTime.contains('AddCartItemEvent')) {
        add(AddItemToCartEvent(
            products: event.products,
            choice_1: state.CurrentColorSizeForCart!["size"],
            color: event.color,
            id: event.id,
            quantity: event.quantity));
        isFailedTheFirstTime.add('AddCartItemEvent');
      }
    }, (r) {
      add(GetCartItemEvent());
      add(AddProductItemForCartEvent(
          productId: event.id!, product: event.products));
    });
  }

  FutureOr<void> _onAddProductItemForCartEvent(
      AddProductItemForCartEvent event, Emitter<HomeState> emit) async {
    Map<String, Products> productsForCart = Map.of(state.productITemForCart);
    if (productsForCart.containsKey(event.productId)) {
      productsForCart[event.productId] = event.product!;
    } else {
      productsForCart.addAll({event.productId: event.product!});
    }
    emit(state.copyWith(productITemForCart: productsForCart));
  }
}
