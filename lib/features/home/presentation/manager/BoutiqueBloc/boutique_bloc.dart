import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:flutter/material.dart';

import 'package:trydos/core/data/model/pagination_model.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/blocs/pre_caching_image_bloc/pre_caching_image_bloc.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/home/data/models/get_product_filters_model.dart'
    as filters_model;
import 'package:trydos/features/home/data/models/get_product_listing_with_filters_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as product;
import 'package:get_it/get_it.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart';
import 'package:trydos/features/home/domain/use_cases/get_featured_products_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_product_filters_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_products_with_filters_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_recommend_products_usecase.dart';

import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_event.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_state.dart';
import 'package:trydos/features/home/presentation/manager/categoryBloc/category_bloc.dart';
import 'package:trydos/features/home/presentation/manager/categoryBloc/category_event.dart';
import 'package:trydos/main.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_events.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_buttons_event_name.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import 'package:trydos/service/firebase_analytics_service/firebase_analytics_service.dart';

import '../../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../../core/error/error_manager.dart';

const throttleDuration = Duration(minutes: 2);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

@LazySingleton()
class BoutiqueBloc extends Bloc<BoutiqueEvent, BoutiqueState> {
  BoutiqueBloc(
    this.getFeaturedProductsUseCase,
    this.getProductsWithFiltersUseCase,
    this.getRecommendProductsUseCase,
    this.getProductFiltersUseCase,
  ) : super(const BoutiqueState()) {
    on<BoutiqueEvent>((event, emit) {});

    on<GetProductsWithFiltersEvent>(
      _onGetProductsWithFiltersEvent,
      transformer: restartable(),
    );
    on<GetProductsWithFiltersWithPaginationEvent>(
      _onGetProductsWithFiltersWithPaginationEvent,
    );

    on<GetFiltersWithPaginatioEvent>(_onGetFiltersWithPaginatioEvent);
    on<AddCurrentMainCategoryTapedEvent>(_onAddCurrentMainCategoryTapedEvent);
    on<ClearAllBoutiquesEvent>(_onClearAllBoutiquesEvent);
    on<ResetAllSelectedAppliedFilterEvent>(
      _onResetAllSelectedAppliedFilterEvent,
    );
    on<AddIsExpandedForLidtingPageEvent>(_onAddIsExpandedForListingPageEvent);
    on<AddPrefAppliedFilterForExtendFilterEvent>(
      _onAddPrefAppliedFilterForExtendFilterEvent,
    );
    on<GetProductWithFiltersWithoutCancelingPreviousEvents>(
      _onGetWithProductFiltersWithoutCancelingPreviousEvents,
    );
    on<GetFiltersEvent>(_onGetProductFiltersEvent, transformer: restartable());
    on<GetFiltersForNavigatorFromLinkToListingPageEvent>(
      _onGetFiltersForNavigatorFromLinkToListingPageEvent,
    );
    on<ChangeSelectedFiltersEvent>(_onChangeSelectedFiltersEvent);

    on<ChangeAppliedFiltersEvent>(_onChangeAppliedFiltersEvent);
    on<IscashedOreiginBotiqueEvent>(_onIscashedOreiginBotiqueEvent);

    /*on<GetProductsWithFiltersWithPrefetchForFiveFiltersEvent>(
      _onGetProductsWithFiltersWithPrefetchForFiveFiltersEvent,
    );
*/
    on<AddSizeAndColorFilterinTextToSearchEvent>(
      _onAddSizeAndColorFilterinTextToSearchEvent,
    );
  }
  final GetProductsWithFiltersUseCase getProductsWithFiltersUseCase;
  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  final GetProductFiltersUseCase getProductFiltersUseCase;
  final GetFeaturedProductsUseCase getFeaturedProductsUseCase;
  final GetRecommendProductsUseCase getRecommendProductsUseCase;

  /* PrefetchProductsForFirstFiveFilter(
      {filters_model.Filter? filter,
      String? boutiqueSlug,
      String? categorySlug}) {
    if (boutiqueSlug == "*featured*" || boutiqueSlug == "*flashDeal*") {
      return;
    }
    Future.delayed(
      Duration(seconds: 7),
      () {
        int countOfPreFetchForFiveFilters = 0;
        if ((filter?.categories?.length ?? 0) > 0) {
          countOfPreFetchForFiveFilters = countOfPreFetchForFiveFilters + 1;
          for (var i = 0; i < (filter?.categories?.length ?? 0); i++) {
            add(GetProductsWithFiltersWithPrefetchForFiveFiltersEvent(
                filterType: "category",
                boutiqueSlug: boutiqueSlug!,
                category: categorySlug,
                attribute: null,
                filterSlug: filter?.categories![i].slug ?? ""));
            if (countOfPreFetchForFiveFilters == 6) {
              break;
            }
          }
        }
        if ((filter?.brands?.length ?? 0) > 0 &&
            countOfPreFetchForFiveFilters < 6) {
          for (var i = 0; i < (filter?.brands?.length ?? 0); i++) {
            countOfPreFetchForFiveFilters = countOfPreFetchForFiveFilters + 1;

            add(GetProductsWithFiltersWithPrefetchForFiveFiltersEvent(
                filterType: "brand",
                boutiqueSlug: boutiqueSlug!,
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
          for (var i = 0;
              i < (filter?.attributes![0].options?.length ?? 0);
              i++) {
            countOfPreFetchForFiveFilters = countOfPreFetchForFiveFilters + 1;
            add(GetProductsWithFiltersWithPrefetchForFiveFiltersEvent(
                filterType: "attribute",
                boutiqueSlug: boutiqueSlug!,
                category: categorySlug,
                attribute: filter?.attributes![0]
                    .copyWith(options: [filter.attributes![0].options![i]]),
                filterSlug: filter?.attributes![0].options![i] ?? ""));
            if (countOfPreFetchForFiveFilters == 6) {
              break;
            }
          }
        }

        if ((filter?.colors?.length ?? 0) > 0 &&
            countOfPreFetchForFiveFilters < 6) {
          for (var i = 0; i < (filter?.colors?.length ?? 0); i++) {
            countOfPreFetchForFiveFilters = countOfPreFetchForFiveFilters + 1;
            add(GetProductsWithFiltersWithPrefetchForFiveFiltersEvent(
                filterType: "color",
                boutiqueSlug: boutiqueSlug!,
                category: categorySlug,
                attribute: null,
                filterSlug: filter?.colors![i] ?? ""));
            if (countOfPreFetchForFiveFilters == 6) {
              break;
            }
          }
        }
        List<filters_model.PriceRange> ranges =
            filter?.prices?.priceRanges ?? [];
        ranges.removeWhere((element) => element.count == 0);
        if ((ranges.length) > 0 && countOfPreFetchForFiveFilters < 6) {
          for (var i = 0; i < (ranges.length); i++) {
            countOfPreFetchForFiveFilters = countOfPreFetchForFiveFilters + 1;
            add(GetProductsWithFiltersWithPrefetchForFiveFiltersEvent(
                filterType: "price",
                boutiqueSlug: boutiqueSlug!,
                category: categorySlug,
                attribute: null,
                filterSlug: "${ranges[i].minPrice}-${ranges[i].maxPrice}"));
            if (countOfPreFetchForFiveFilters == 6) {
              break;
            }
          }
        }
      },
    );
  }*/

  FutureOr<void> _onClearAllBoutiquesEvent(
    ClearAllBoutiquesEvent event,
    Emitter<BoutiqueState> emit,
  ) async {
    emit(state.copyWith(getProductListingWithFiltersPaginationModels: {}));
  }

  FutureOr<void> _onAddCurrentMainCategoryTapedEvent(
    AddCurrentMainCategoryTapedEvent event,
    Emitter<BoutiqueState> emit,
  ) async {
    emit(
      state.copyWith(currentMainCategoryTaped: event.currentMainCategoryTaped),
    );
  }

  FutureOr<void> _onAddSizeAndColorFilterinTextToSearchEvent(
    AddSizeAndColorFilterinTextToSearchEvent event,
    Emitter<BoutiqueState> emit,
  ) async {
    emit(
      state.copyWith(
        sizeAndColorFilterinTextToSearch:
            event.sizeAndColorFilterinTextToSearch,
      ),
    );
  }

  /* FutureOr<void> _onGetProductsWithFiltersWithPrefetchForFiveFiltersEvent(
    GetProductsWithFiltersWithPrefetchForFiveFiltersEvent event,
    Emitter<BoutiqueState> emit,
  ) async {
    String key = '${event.boutiqueSlug}' +
        '${event.filterSlug}' +
        '${(event.category ?? '')}';
    List<String> keyForFirstFiveFilterList = GetIt.I<PrefsRepository>()
            .getFiveFilterForEachBoutiqueHasPrefechInHomePage() ??
        [];

    if (keyForFirstFiveFilterList.contains(key) || key == event.boutiqueSlug) {
      return;
    }

    //  await prefechFiveFilter.acquire();
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
      offset: [],
      limit: 20,
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
      // prefechFiveFilter.release();
      Map<String, PaginationModel<product.Products>?>?
          getProductListingWithFiltersPaginationWithPrefetchModels = Map.of(
              state.getProductListingWithFiltersPaginationWithPrefetchModels);
      if (ErrorManager.shouldRetry('GetProductsWithFiltersWithPrefetchForFiveFiltersEvent', l.statusCode)) {
        ErrorManager.incrementRetry('GetProductsWithFiltersWithPrefetchForFiveFiltersEvent');
        add(GetProductsWithFiltersWithPrefetchForFiveFiltersEvent(
          filterSlug: event.filterSlug,
          filterType: event.filterType,
          attribute: event.attribute,
          boutiqueSlug: event.boutiqueSlug,
          category: event.category,
        ));
        return;
      }
      getProductListingWithFiltersPaginationWithPrefetchModels[key] =
          getProductListingWithFiltersPaginationWithPrefetchModels[key]!
              .copyWith(paginationStatus: PaginationStatus.failure);
      emit(state.copyWith(
        getProductListingWithFiltersPaginationWithPrefetchModels:
            Map.of(getProductListingWithFiltersPaginationWithPrefetchModels),
      ));
    }, (r) {
      //  prefechFiveFilter.release();
      prefsRepository.setPrefechForFiveFilterForEachBoutiqueInHomePage(
          key, jsonEncode(r.data));
      Map<String, List<double>> searchWithFilterOffset =
          Map.of(state.searchWithFilterOffset ?? {});
      if (searchWithFilterOffset.containsKey(key)) {
        searchWithFilterOffset[key] = r.data?.offset ?? [];
      } else {
        searchWithFilterOffset.addAll({key: r.data?.offset ?? []});
      }

      //  if (state.idForRequest == idForRequest || state.cashedOrginalBoutique) {
      ErrorManager.resetRetry('GetProductsWithFiltersWithPrefetchForFiveFiltersEvent');
      try {
        Map<String, PaginationModel<product.Products>?>
            getProductListingWithFiltersPaginationWithPrefetchModel = Map.of(
                state.getProductListingWithFiltersPaginationWithPrefetchModels);
        getProductListingWithFiltersPaginationWithPrefetchModel.removeWhere(
          (key, value) => !key.contains(event.boutiqueSlug),
        );
        List<Products>? productsResult = r.data?.products ?? [];
        if (event.filterType == "color") {
          productsResult = [];
          r.data!.products?.forEach(
            (element) {
              List<product.SyncColorImage>? syncColorImageList =
                  element.syncColorImages;
              List<product.Color>? colorsForSync = element.colors;
              if (syncColorImageList?.length == 3 ||
                  syncColorImageList?.length == 2) {
                product.SyncColorImage firstImage = syncColorImageList![0];
                product.Color firstColor = colorsForSync![0];
                firstImage = syncColorImageList.removeAt(0);
                firstColor = colorsForSync.removeAt(0);
                syncColorImageList.insert(1, firstImage);
                colorsForSync.insert(1, firstColor);
              } else if ((syncColorImageList?.length ?? 0) > 3) {
                product.SyncColorImage firstImage = syncColorImageList![0];
                product.Color firstColor = colorsForSync![0];
                firstColor = colorsForSync.removeAt(0);
                firstImage = syncColorImageList.removeAt(0);
                colorsForSync.insert(
                    ((syncColorImageList.length ~/ 2) +
                        (syncColorImageList.length % 2 == 0 ? 0 : 1)),
                    firstColor);
                syncColorImageList.insert(
                    ((syncColorImageList.length ~/ 2) +
                        (syncColorImageList.length % 2 == 0 ? 0 : 1)),
                    firstImage);
              }
              productsResult?.add(element.copyWith(
                  syncColorImages: syncColorImageList, colors: colorsForSync));
            },
          );
        }

        getProductListingWithFiltersPaginationWithPrefetchModel.addAll({
          key: PaginationModel<Products>(
              paginationStatus: PaginationStatus.success,
              page: 1,
              offset: "${r.data?.offset}",
              hasReachedMax: (r.data!.products?.length ?? 0) < 20,
              items: productsResult)
        });

        List<filters_model.PriceRange> ranges =
            r.data!.prices?.priceRanges ?? [];
        ranges.removeWhere((element) => element.count == 0);
        Map<String, filters_model.GetProductFiltersModel?> data =
            Map.of(state.getProductFiltersWithPrefetchModel);
        data.removeWhere(
          (key, value) => !key.contains(event.boutiqueSlug),
        );

        data.addAll({
          key: filters_model.GetProductFiltersModel(
              filters: filters_model.Filter(
            brands: r.data!.brands,
            attributes: r.data!.attributes,
            totalSize: r.data?.totalSize,
            //   boutiqueSlug: r.data?.boutiqueSlug,
            prices: r.data!.prices?.copyWith(priceRanges: ranges),
            boutiques: r.data!.boutiques,
            colors: r.data!.colors,
            categories: r.data!.categories,
          ))
        });
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
  }*/

  FutureOr<void> _onIscashedOreiginBotiqueEvent(
    IscashedOreiginBotiqueEvent event,
    Emitter<BoutiqueState> emit,
  ) async {
    emit(state.copyWith(cashedOrginalBoutique: event.iscashedOreiginBotique));
  }

  FutureOr<void> _onChangeAppliedFiltersEvent(
    ChangeAppliedFiltersEvent event,
    Emitter<BoutiqueState> emit,
  ) {
    String key = event.boutiqueSlug + (event.category ?? '');
    Map<String, filters_model.GetProductFiltersModel?> appliedFilters = Map.of(
      state.appliedFiltersByUser,
    );
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
    if (event.resetAppliedFilters) {
      GetIt.I<CategoryBloc>().add(
        ReplyFromGeminiEvent(resetTheReply: true, fromSearch: true),
      );
      GetIt.I<CategoryBloc>().add(
        ReplyFromGeminiEvent(resetTheReply: true, fromSearch: false),
      );
    }
    emit(
      state.copyWith(
        appliedFiltersByUser: Map.of(appliedFilters),
        isExpandedForListingPage: event.isExpandedForListing,
      ),
    );
  }

  FutureOr<void> _onAddIsExpandedForListingPageEvent(
    AddIsExpandedForLidtingPageEvent event,
    Emitter<BoutiqueState> emit,
  ) async {
    emit(state.copyWith(isExpandedForListingPage: event.isExpandedForLidting));
  }

  FutureOr<void> _onChangeSelectedFiltersEvent(
    ChangeSelectedFiltersEvent event,
    Emitter<BoutiqueState> emit,
  ) {
    bool makeChoosedFiltersNull = false;
    String key = event.boutiqueSlug + (event.category ?? '');
    Map<String, filters_model.GetProductFiltersModel?> choosedFilters = Map.of(
      state.choosedFiltersByUser,
    );
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
    if (event.resetChoosedFilters) {
      GetIt.I<CategoryBloc>().add(
        ReplyFromGeminiEvent(
          resetTheReply: true,
          fromSearch: event.fromHomePageSearch,
        ),
      );
    }

    emit(
      state.copyWith(
        choosedFiltersByUser: Map.of(choosedFilters),
        isExpandedForListingPage: event.isExpandedForListing,
      ),
    );

    if (event.requestToUpdateFilters) {
      add(
        GetFiltersEvent(
          category: event.category,
          boutiqueSlug: event.boutiqueSlug,
          fromHomePageSearch: event.fromHomePageSearch,
          filtersChoosedByUser: makeChoosedFiltersNull
              ? null
              : event.filtersChoosedByUser,
        ),
      );
    }
  }

  FutureOr<void> _onGetFiltersWithPaginatioEvent(
    GetFiltersWithPaginatioEvent event,
    Emitter<BoutiqueState> emit,
  ) async {
    print(
      "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF#####wwwwwwwwwwwwwwwwwwwwwwwwwwwwt",
    );
    String key = event.boutiqueSlug + (event.category ?? '');
    /* if (event.getProductsFilterPreFetch &&
        !event.fromHomePageSearch &&
        event.cashedOrginalBoutique &&
        (state.getProductFiltersModel[key]?.filters?.totalSize ?? 0) > 0) {}*/
    Map<String, GetProductFiltersStatus> statuses = Map.of(
      state.getProductFiltersStatus,
    );
    if (statuses[key] == GetProductFiltersStatus.loading ||
        state.finishGetAllFilter) {
      return;
    }

    statuses[key] = GetProductFiltersStatus.loading;

    emit(
      state.copyWith(
        filterOffset: (state.filterOffset ?? 1) + 1,
        getProductFiltersStatus: Map.of(statuses),
      ),
    );

    filters_model.Filter filters =
        event.filtersChoosedByUser?.filters ?? filters_model.Filter();

    List<filters_model.Attribute>? attribute;
    try {
      attribute = filters.attributes.isNullOrEmpty
          ? ((state
                        .appliedFiltersByUser[key]
                        ?.filters
                        ?.attributes
                        ?.isNullOrEmpty ??
                    true)
                ? null
                : state.appliedFiltersByUser[key]?.filters!.attributes!)
          : filters.attributes;
      if (!attribute.isNullOrEmpty &&
          !filters.attributes.isNullOrEmpty &&
          !(state
                  .appliedFiltersByUser[key]
                  ?.filters
                  ?.attributes
                  ?.isNullOrEmpty ??
              true)) {
        attribute![0] = attribute[0].copyWith(
          options: [
            ...filters.attributes![0].options ?? [],
            ...state
                    .appliedFiltersByUser[key]
                    ?.filters!
                    .attributes![0]
                    .options ??
                [],
          ],
        );
      }
      filters = filters.copyWithSaveOtherField(
        brands: [
          ...filters.brands ?? [],
          ...state.appliedFiltersByUser[key]?.filters?.brands ?? [],
        ],
        categories: [
          ...filters.categories ?? [],
          ...state.appliedFiltersByUser[key]?.filters?.categories ?? [],
        ],
        colors: [
          ...filters.colors ?? [],
          ...state.appliedFiltersByUser[key]?.filters?.colors ?? [],
        ],
        attributes: attribute,
        prices:
            filters.prices ?? state.choosedFiltersByUser[key]?.filters?.prices,
        searchText:
            filters.searchText ??
            state.appliedFiltersByUser[key]?.filters?.searchText,
        boutiques: event.fromHomePageSearch
            ? [
                ...filters.boutiques ?? [],
                ...state.appliedFiltersByUser[key]?.filters?.boutiques ?? [],
              ]
            : [],
      );
    } catch (e, st) {
      print(e);
      print(st);
    }
    final response = await getProductFiltersUseCase(
      GetProductsFiltersParams(
        offsetFilter: "${(state.filterOffset ?? 1)}",
        limit: 20,
        searchText: filters.searchText ?? event.searchText,
        brandSlugs: filters.brands
            ?.map((e) => '"${e.slug.toString()}"')
            .toList(),
        categorySlugs: event.category != null && event.category != ""
            ? [
                ...(filters.categories
                        ?.map((e) => '"${e.slug.toString()}"')
                        .toList() ??
                    []),
                '"${event.category}"',
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
                },
              ],
        colors: filters.colors?.map((e) => '"${e.toString()}"').toList(),
        prices:
            filters.prices?.maxPrice != null && filters.prices?.minPrice != null
            ? ['"${filters.prices!.minPrice}-${filters.prices!.maxPrice}"']
            : null,
      ),
    );
    response.fold(
      (l) {
        Map<String, GetProductFiltersStatus> statuses = Map.of(
          state.getProductFiltersStatus,
        );
        if (ErrorManager.shouldRetry('GetProductFiltersEvent', l.statusCode)) {
          ErrorManager.incrementRetry('GetProductFiltersEvent');
          add(
            GetFiltersWithPaginatioEvent(
              getProductsFilterPreFetch: event.getProductsFilterPreFetch,
              cashedOrginalBoutique: event.cashedOrginalBoutique,
              fromListingPage: event.fromListingPage,
              resetAppliesFilters: event.resetAppliesFilters,
              getWithoutFilter: event.getWithoutFilter,
              filtersChoosedByUser: event.filtersChoosedByUser,
              category: event.category,
              boutiqueSlug: event.boutiqueSlug,
              forceUpdate: event.forceUpdate,
              fromHomePageSearch: event.fromHomePageSearch,
              searchText: filters.searchText ?? event.searchText,
            ),
          );
          return;
        }
        statuses[key] = GetProductFiltersStatus.failure;
        emit(state.copyWith(getProductFiltersStatus: statuses));
      },
      (r) {
        Map<String, GetProductFiltersStatus> statuses = Map.of(
          state.getProductFiltersStatus,
        );
        /*  if (event.getProductsFilterPreFetch &&
          !event.fromHomePageSearch &&
          event.cashedOrginalBoutique) {
        PrefetchProductsForFirstFiveFilter(
            filter: r.filters,
            boutiqueSlug: event.boutiqueSlug,
            categorySlug: event.category);
      }*/

        ErrorManager.resetRetry('GetProductFiltersEvent');
        statuses[key] = GetProductFiltersStatus.success;
        try {
          Map<String, filters_model.GetProductFiltersModel?> data = Map.of(
            state.getProductFiltersModel,
          );
          List<filters_model.PriceRange> ranges =
              r.filters!.prices?.priceRanges ?? [];
          ranges.removeWhere((element) => element.count == 0);

          data[key] = filters_model.GetProductFiltersModel(
            filters: filters_model.Filter(
              attributes: [
                filters_model.Attribute(
                  id: ((data[key]?.filters?.attributes ?? 0) == 0)
                      ? 0
                      : data[key]?.filters?.attributes?[0].id,
                  name: ((data[key]?.filters?.attributes ?? 0) == 0)
                      ? "size"
                      : data[key]?.filters?.attributes?[0].name,
                  options: [
                    ...(((data[key]?.filters?.attributes ?? 0) == 0)
                        ? []
                        : data[key]?.filters?.attributes?[0].options ?? []),
                    ...(((r.filters?.attributes?.length ?? 0) == 0)
                        ? []
                        : r.filters?.attributes?[0].options ?? []),
                  ],
                ),
              ],
              colors: [
                ...(data[key]?.filters?.colors ?? []),
                ...(r.filters?.colors ?? []),
              ],
              prices: r.filters?.prices?.copyWith(
                priceRanges: [
                  ...(data[key]?.filters?.prices?.priceRanges ?? []),
                  ...ranges,
                ],
              ),
              boutiques: [
                ...(data[key]?.filters?.boutiques ?? []),
                ...(r.filters?.boutiques ?? []),
              ],
              brands: [
                ...(data[key]?.filters?.brands ?? []),
                ...(r.filters?.brands ?? []),
              ],
              categories: [
                ...(data[key]?.filters?.categories ?? []),
                ...(r.filters?.categories ?? []),
              ],
              searchText: r.filters?.searchText,
              totalSize: r.filters?.totalSize,
            ),
          );
          bool finishGetAllFilter =
              (r.filters?.boutiques ?? []).length < 20 &&
              (r.filters?.categories ?? []).length < 20 &&
              (r.filters?.brands ?? []).length < 20 &&
              (r.filters?.colors ?? []).length < 20 &&
              (r.filters?.prices?.priceRanges ?? []).length < 20 &&
              (((r.filters?.attributes?.length ?? 0) == 0)
                  ? true
                  : (r.filters?.attributes?[0].options ?? []).length < 20);
          emit(
            state.copyWith(
              finishGetAllFilter: finishGetAllFilter,
              countOfProductExpectedByFiltering: Map.of({
                event.boutiqueSlug: r.filters?.totalSize ?? 0,
              }),
              getProductFiltersStatus: Map.of(statuses),
              getProductFiltersModel: Map.of(
                data,
              ), //removeAlreadyChoosedFilters(r, filters),
            ),
          );
        } catch (e, st) {
          emit(
            state.copyWith(
              getProductFiltersStatus: Map.of(statuses),
              //removeAlreadyChoosedFilters(r, filters),
            ),
          );
          print(e);
          print(st);
        }
      },
    );
  }

  FutureOr<void> _onGetFiltersForNavigatorFromLinkToListingPageEvent(
    GetFiltersForNavigatorFromLinkToListingPageEvent event,
    Emitter<BoutiqueState> emit,
  ) async {
    emit(
      state.copyWith(
        getFiltersForNavigatorFromLinkToListingPageStatus:
            GetFiltersForNavigatorFromLinkToListingPageStatus.loading,
      ),
    );

    filters_model.Filter filters =
        event.filtersChoosedByUser?.filters ?? filters_model.Filter();
    final response = await getProductFiltersUseCase(
      GetProductsFiltersParams(
        offsetFilter: "1",
        limit: 20,
        brandSlugs: event.filtersChoosedByUser?.filters?.brands
            ?.map((e) => '"${e.slug.toString()}"')
            .toList(),
        categorySlugs: filters.categories
            ?.map((e) => '"${e.slug.toString()}"')
            .toList(),
        boutiqueSlugs: event.fromHomePageSearch
            ? filters.boutiques?.map((e) => '"${e.slug.toString()}"').toList()
            : ['"${event.boutiqueSlug}"'],
        attributes: filters.attributes.isNullOrEmpty
            ? null
            : [
                {
                  '"id"': filters.attributes![0].id,
                  '"name"': '"${filters.attributes![0].name}"',
                  '"options"': filters.attributes![0].options
                      ?.map((e) => '"${e.toString()}"')
                      .toList(),
                },
              ],
        colors: filters.colors?.map((e) => '"${e.toString()}"').toList(),
      ),
    );
    response.fold(
      (l) {
        if (ErrorManager.shouldRetry(
          'GetFiltersForNavigatorFromLinkToListingPageEvent',
          l.statusCode,
        )) {
          ErrorManager.incrementRetry(
            'GetFiltersForNavigatorFromLinkToListingPageEvent',
          );
          add(
            GetFiltersForNavigatorFromLinkToListingPageEvent(
              fromHomePageSearch: event.fromHomePageSearch,
              filtersChoosedByUser: event.filtersChoosedByUser,
              boutiqueSlug: event.boutiqueSlug,
            ),
          );
          return;
        }

        emit(
          state.copyWith(
            getFiltersForNavigatorFromLinkToListingPageStatus:
                GetFiltersForNavigatorFromLinkToListingPageStatus.failure,
          ),
        );
      },
      (r) {
        List<Category>? categories = [];
        for (
          var i = 0;
          i < (event.filtersChoosedByUser?.filters?.categories?.length ?? 0);
          i++
        ) {
          categories.add(r.filters!.categories![i]);
        }
        List<filters_model.Brand>? brands = [];
        for (
          var i = 0;
          i < (event.filtersChoosedByUser?.filters?.brands?.length ?? 0);
          i++
        ) {
          brands.add(r.filters!.brands![i]);
        }
        List<filters_model.Boutique>? boutiques = [];

        for (
          var i = 0;
          i < (event.filtersChoosedByUser?.filters?.boutiques?.length ?? 0);
          i++
        ) {
          boutiques.add(r.filters!.boutiques![i]);
        }
        final Map<String, filters_model.GetProductFiltersModel?>
        appliedFiltersByUser = state.appliedFiltersByUser;
        if (appliedFiltersByUser["link"] == null) {
          appliedFiltersByUser.addAll({
            "link": filters_model.GetProductFiltersModel(
              filters: filters_model.Filter(
                boutiques: boutiques,
                categories: categories,
                brands: brands,
                colors: event.filtersChoosedByUser?.filters?.colors,
                attributes: event.filtersChoosedByUser?.filters?.attributes,
              ),
            ),
          });
        } else {
          appliedFiltersByUser["link"] = filters_model.GetProductFiltersModel(
            filters: filters_model.Filter(
              boutiques: boutiques,
              categories: categories,
              brands: brands,
              colors: event.filtersChoosedByUser?.filters?.colors,
              attributes: event.filtersChoosedByUser?.filters?.attributes,
            ),
          );
        }

        emit(
          state.copyWith(
            boutiquesToNavigatorFromLink: r.filters?.boutiques,
            appliedFiltersByUser: appliedFiltersByUser,
            getFiltersForNavigatorFromLinkToListingPageStatus:
                GetFiltersForNavigatorFromLinkToListingPageStatus.success,
          ),
        );

        ErrorManager.resetRetry(
          'GetFiltersForNavigatorFromLinkToListingPageEvent',
        );
      },
    );
  }

  FutureOr<void> _onGetProductFiltersEvent(
    GetFiltersEvent event,
    Emitter<BoutiqueState> emit,
  ) async {
    String key = event.boutiqueSlug + (event.category ?? '');
    print(
      "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF################################${key}",
    );
    /* if (event.getProductsFilterPreFetch &&
        !event.fromHomePageSearch &&
        event.cashedOrginalBoutique &&
        (state.getProductFiltersModel[key]?.filters?.totalSize ?? 0) > 0) {}*/
    Map<String, GetProductFiltersStatus> statuses = Map.of(
      state.getProductFiltersStatus,
    );

    statuses[key] = GetProductFiltersStatus.loading;

    if (event.cashedOrginalBoutique &&
        statuses[key] == GetProductFiltersStatus.success) {
      statuses[key] = GetProductFiltersStatus.success;
    }
    emit(
      state.copyWith(
        filterOffset: 1,
        finishGetAllFilter: false,
        getProductFiltersStatus: Map.of(statuses),
      ),
    );

    filters_model.Filter filters =
        event.filtersChoosedByUser?.filters ?? filters_model.Filter();

    List<filters_model.Attribute>? attribute;
    try {
      attribute = filters.attributes.isNullOrEmpty
          ? ((state
                        .appliedFiltersByUser[key]
                        ?.filters
                        ?.attributes
                        ?.isNullOrEmpty ??
                    true)
                ? null
                : state.appliedFiltersByUser[key]?.filters!.attributes!)
          : filters.attributes;
      if (!attribute.isNullOrEmpty &&
          !filters.attributes.isNullOrEmpty &&
          !(state
                  .appliedFiltersByUser[key]
                  ?.filters
                  ?.attributes
                  ?.isNullOrEmpty ??
              true)) {
        attribute![0] = attribute[0].copyWith(
          options: [
            ...filters.attributes![0].options ?? [],
            ...state
                    .appliedFiltersByUser[key]
                    ?.filters!
                    .attributes![0]
                    .options ??
                [],
          ],
        );
      }
      filters = filters.copyWithSaveOtherField(
        brands: [
          ...filters.brands ?? [],
          ...state.appliedFiltersByUser[key]?.filters?.brands ?? [],
        ],
        categories: [
          ...filters.categories ?? [],
          ...state.appliedFiltersByUser[key]?.filters?.categories ?? [],
        ],
        colors: [
          ...filters.colors ?? [],
          ...state.appliedFiltersByUser[key]?.filters?.colors ?? [],
        ],
        attributes: attribute,
        prices:
            filters.prices ?? state.choosedFiltersByUser[key]?.filters?.prices,
        searchText:
            filters.searchText ??
            state.appliedFiltersByUser[key]?.filters?.searchText,
        boutiques: event.fromHomePageSearch
            ? [
                ...filters.boutiques ?? [],
                ...state.appliedFiltersByUser[key]?.filters?.boutiques ?? [],
              ]
            : [],
      );
    } catch (e, st) {
      print(e);
      print(st);
    }
    final response = await getProductFiltersUseCase(
      GetProductsFiltersParams(
        offsetFilter: "1",
        limit: 20,
        searchText: filters.searchText ?? event.searchText,
        brandSlugs: filters.brands
            ?.map((e) => '"${e.slug.toString()}"')
            .toList(),
        categorySlugs: event.category != null && event.category != ""
            ? [
                ...(filters.categories
                        ?.map((e) => '"${e.slug.toString()}"')
                        .toList() ??
                    []),
                '"${event.category}"',
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
                },
              ],
        colors: filters.colors?.map((e) => '"${e.toString()}"').toList(),
        prices:
            filters.prices?.maxPrice != null && filters.prices?.minPrice != null
            ? ['"${filters.prices!.minPrice}-${filters.prices!.maxPrice}"']
            : null,
      ),
    );
    response.fold(
      (l) {
        Map<String, GetProductFiltersStatus> statuses = Map.of(
          state.getProductFiltersStatus,
        );

        if (ErrorManager.shouldRetry('GetProductFiltersEvent', l.statusCode)) {
          ErrorManager.incrementRetry('GetProductFiltersEvent');
          add(
            GetFiltersEvent(
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
              searchText: filters.searchText ?? event.searchText,
            ),
          );
          return; // لا تحدث الحالة
        }

        statuses[key] = GetProductFiltersStatus.failure;
        emit(state.copyWith(getProductFiltersStatus: statuses));
      },
      (r) {
        Map<String, GetProductFiltersStatus> statuses = Map.of(
          state.getProductFiltersStatus,
        );
        /*  if (event.getProductsFilterPreFetch &&
          !event.fromHomePageSearch &&
          event.cashedOrginalBoutique) {
        PrefetchProductsForFirstFiveFilter(
            filter: r.filters,
            boutiqueSlug: event.boutiqueSlug,
            categorySlug: event.category);
      }*/

        apisMustNotToRequest.add('GetProductFiltersEvent');
        ErrorManager.resetRetry('GetProductFiltersEvent');
        try {
          statuses[key] = GetProductFiltersStatus.success;

          Map<String, filters_model.GetProductFiltersModel?> data = Map.of(
            state.getProductFiltersModel,
          );
          List<filters_model.PriceRange> ranges =
              r.filters!.prices?.priceRanges ?? [];
          ranges.removeWhere((element) => element.count == 0);

          data[key] = r.copyWith(
            filters: r.filters?.copyWithSaveOtherField(
              prices: r.filters?.prices?.copyWith(priceRanges: ranges),
              searchText: r.filters?.searchText,
            ),
          );

          emit(
            state.copyWith(
              countOfProductExpectedByFiltering: Map.of({
                event.boutiqueSlug: r.filters?.totalSize ?? 0,
              }),
              getProductFiltersStatus: Map.of(statuses),
              getProductFiltersModel: Map.of(
                data,
              ), //removeAlreadyChoosedFilters(r, filters),
            ),
          );
        } catch (e, st) {
          print(e);
          print(st);
        }
      },
    );
  }

  FutureOr<void> _onGetWithProductFiltersWithoutCancelingPreviousEvents(
    GetProductWithFiltersWithoutCancelingPreviousEvents event,
    Emitter<BoutiqueState> emit,
  ) async {
    String key = event.boutiqueSlug + (event.category ?? '');
    if ((event.boutiqueSlug != "*featured*" &&
            event.boutiqueSlug != "*flashDeal*" &&
            event.boutiqueSlug != "*recommended*") &&
        ((prefsRepository
                    .getPrefechOfProductsForEachBoutiqueInHomePage(key)
                    ?.length ??
                0) >
            20)) {
      return;
    }
    if (event.boutiqueSlug == "*featured*") {
      try {
        Map<String, PaginationModel<product.Products>?>
        getProductListingWithFiltersPaginationModels = Map.of(
          state.getProductListingWithFiltersPaginationModels,
        );
        Map<String, dynamic> responseFromSharedPrefrence = jsonDecode(
          prefsRepository.getPrefechOfProductsForEachBoutiqueInHomePage(key) ??
              "{}",
        );
        DataGetProductListingWithFiltersModel
        getProductListingWithFiltersModel = responseFromSharedPrefrence == {}
            ? DataGetProductListingWithFiltersModel()
            : DataGetProductListingWithFiltersModel.fromJson(
                responseFromSharedPrefrence,
              );
        if (getProductListingWithFiltersPaginationModels.containsKey(
          "*featured*withoutFilter",
        )) {
          getProductListingWithFiltersPaginationModels["*featured*withoutFilter"] =
              PaginationModel<product.Products>(
                hasReachedMax:
                    (getProductListingWithFiltersModel.products?.length ?? 0) <
                    20,
                items: getProductListingWithFiltersModel.products ?? [],
                page: 1,
                paginationStatus: PaginationStatus.loading,
              );
        } else {
          getProductListingWithFiltersPaginationModels.addAll({
            "*featured*withoutFilter": PaginationModel<product.Products>(
              hasReachedMax:
                  (getProductListingWithFiltersModel.products?.length ?? 0) <
                  20,
              items: getProductListingWithFiltersModel.products ?? [],
              page: 1,
              paginationStatus: PaginationStatus.loading,
            ),
          });
        }
        /* if ((getProductListingWithFiltersModel.products ?? []).length > 0) {
          await Future.delayed(Duration(seconds: 3));
        }*/
        emit(
          state.copyWith(
            getProductListingWithFiltersPaginationModels:
                getProductListingWithFiltersPaginationModels,
          ),
        );
      } catch (e) {}
    } else if (event.boutiqueSlug == "*flashDeal*") {
      try {
        Map<String, PaginationModel<product.Products>?>
        getProductListingWithFiltersPaginationModels = Map.of(
          state.getProductListingWithFiltersPaginationModels,
        );
        Map<String, dynamic> responseFromSharedPrefrence = jsonDecode(
          prefsRepository.getPrefechOfProductsForEachBoutiqueInHomePage(key) ??
              "{}",
        );
        DataGetProductListingWithFiltersModel
        getProductListingWithFiltersModel = responseFromSharedPrefrence == {}
            ? DataGetProductListingWithFiltersModel()
            : DataGetProductListingWithFiltersModel.fromJson(
                responseFromSharedPrefrence,
              );
        if (getProductListingWithFiltersPaginationModels.containsKey(
          "*flashDeal*withoutFilter",
        )) {
          getProductListingWithFiltersPaginationModels["*flashDeal*withoutFilter"] =
              PaginationModel<product.Products>(
                hasReachedMax:
                    (getProductListingWithFiltersModel.products?.length ?? 0) <
                    20,
                items: getProductListingWithFiltersModel.products ?? [],
                page: 1,
                paginationStatus: PaginationStatus.loading,
              );
        } else {
          getProductListingWithFiltersPaginationModels.addAll({
            "*flashDeal*withoutFilter": PaginationModel<product.Products>(
              hasReachedMax:
                  (getProductListingWithFiltersModel.products?.length ?? 0) <
                  20,
              items: getProductListingWithFiltersModel.products ?? [],
              page: 1,
              paginationStatus: PaginationStatus.loading,
            ),
          });
        }

        /* if ((getProductListingWithFiltersModel.products ?? []).length > 0) {
          await Future.delayed(Duration(seconds: 3));
        }*/
        emit(
          state.copyWith(
            getProductListingWithFiltersPaginationModels:
                getProductListingWithFiltersPaginationModels,
          ),
        );
      } catch (e) {}
    } else if (event.boutiqueSlug == "*recommended*") {
      try {
        Map<String, PaginationModel<product.Products>?>
        getProductListingWithFiltersPaginationModels = Map.of(
          state.getProductListingWithFiltersPaginationModels,
        );
        Map<String, dynamic> responseFromSharedPrefrence = jsonDecode(
          prefsRepository.getPrefechOfProductsForEachBoutiqueInHomePage(key) ??
              "{}",
        );
        DataGetProductListingWithFiltersModel
        getProductListingWithFiltersModel = responseFromSharedPrefrence == {}
            ? DataGetProductListingWithFiltersModel()
            : DataGetProductListingWithFiltersModel.fromJson(
                responseFromSharedPrefrence,
              );
        if (getProductListingWithFiltersPaginationModels.containsKey(
          "*recommended*withoutFilter",
        )) {
          getProductListingWithFiltersPaginationModels["*recommended*withoutFilter"] =
              PaginationModel<product.Products>(
                hasReachedMax:
                    (getProductListingWithFiltersModel.products?.length ?? 0) <
                    20,
                items: getProductListingWithFiltersModel.products ?? [],
                page: 1,
                paginationStatus: PaginationStatus.loading,
              );
        } else {
          getProductListingWithFiltersPaginationModels.addAll({
            "*recommended*withoutFilter": PaginationModel<product.Products>(
              hasReachedMax:
                  (getProductListingWithFiltersModel.products?.length ?? 0) <
                  20,
              items: getProductListingWithFiltersModel.products ?? [],
              page: 1,
              paginationStatus: PaginationStatus.loading,
            ),
          });
        }

        /* if ((getProductListingWithFiltersModel.products ?? []).length > 0) {
          await Future.delayed(Duration(seconds: 3));
        }*/
        emit(
          state.copyWith(
            getProductListingWithFiltersPaginationModels:
                getProductListingWithFiltersPaginationModels,
          ),
        );
      } catch (e) {}
    } else {
      Map<String, bool> boutiquesThatDidPrefetch = Map.of(
        state.boutiquesThatDidPrefetch,
      );
      if (boutiquesThatDidPrefetch[key] == true &&
          (event.boutiqueSlug != "*featured*" &&
              event.boutiqueSlug != "*flashDeal*" &&
              event.boutiqueSlug != "*recommended*")) {
        return;
      }
      if (boutiquesThatDidPrefetch[key] == null) {
        boutiquesThatDidPrefetch.addAll({key: false});
      }
      boutiquesThatDidPrefetch[key] = true;

      emit(state.copyWith(boutiquesThatDidPrefetch: boutiquesThatDidPrefetch));
    }

    // await prefechBoutiques.acquire();
    final response = event.boutiqueSlug == "*featured*"
        ? await getFeaturedProductsUseCase(
            GetFeaturedProductsParams(
              limit: 20,
              offset: [],
              categorySlugs:
                  (state.currentMainCategoryTaped == "" ||
                      state.currentMainCategoryTaped == null ||
                      state.currentMainCategoryTaped == "Empty")
                  ? null
                  : ['"${state.currentMainCategoryTaped}"'],
            ),
          )
        : event.boutiqueSlug == "*flashDeal*"
        ? await getProductsWithFiltersUseCase(
            GetProductsWithFiltersParams(
              offset: [],
              limit: 20,
              flashDeal: true,
              categorySlugs:
                  (state.currentMainCategoryTaped == "" ||
                      state.currentMainCategoryTaped == null ||
                      state.currentMainCategoryTaped == "Empty")
                  ? null
                  : ['"${state.currentMainCategoryTaped}"'],
            ),
          )
        : event.boutiqueSlug == "*recommended*"
        ? await getRecommendProductsUseCase(
            GetRecommendProductsParams(
              limit: 20,
              offset: [],
              categorySlugs:
                  (state.currentMainCategoryTaped == "" ||
                      state.currentMainCategoryTaped == null ||
                      state.currentMainCategoryTaped == "Empty")
                  ? null
                  : ['"${state.currentMainCategoryTaped}"'],
            ),
          )
        : await getProductsWithFiltersUseCase(
            GetProductsWithFiltersParams(
              offset: [],
              limit: 20,
              boutiqueSlugs: ['"${event.boutiqueSlug}"'],
            ),
          );
    response.fold(
      (l) {
        //   prefechBoutiques.release();
        Map<String, bool> boutiquesThatDidPrefetch = Map.of(
          state.boutiquesThatDidPrefetch,
        );
        boutiquesThatDidPrefetch[key] = false;

        emit(
          state.copyWith(boutiquesThatDidPrefetch: boutiquesThatDidPrefetch),
        );
        if (ErrorManager.shouldRetry(
          'GetWithProductFiltersWithoutCancelingPreviousEvents',
          l.statusCode,
        )) {
          ErrorManager.incrementRetry(
            'GetWithProductFiltersWithoutCancelingPreviousEvents',
          );
          add(
            GetProductWithFiltersWithoutCancelingPreviousEvents(
              boutiqueSlug: event.boutiqueSlug,
              categorySlugs: event.categorySlugs,
              fromHomePageSearch: event.fromHomePageSearch,
              searchText: event.searchText,
              category: event.category,
              fromExpandPage: event.fromExpandPage,
              resetAppliesFilters: event.resetAppliesFilters,
              getWithoutFilter: event.getWithoutFilter,
              indexOfCategory: event.indexOfCategory,
              filtersChoosedByUser: event.filtersChoosedByUser,
              forceUpdate: event.forceUpdate,
              cashedOrginalBoutique: event.cashedOrginalBoutique,
              context: event.context,
            ),
          );
          return;
        }
        Map<String, PaginationModel<product.Products>?>
        getProductListingWithFiltersPaginationModels = Map.of(
          state.getProductListingWithFiltersPaginationModels,
        );
        if (event.boutiqueSlug == "*featured*") {
          if (getProductListingWithFiltersPaginationModels.containsKey(
            "*featured*withoutFilter",
          )) {
            getProductListingWithFiltersPaginationModels["*featured*withoutFilter"] =
                getProductListingWithFiltersPaginationModels["*featured*withoutFilter"]
                    ?.copyWith(paginationStatus: PaginationStatus.failure);
          }
          emit(
            state.copyWith(
              getProductListingWithFiltersPaginationModels:
                  getProductListingWithFiltersPaginationModels,
            ),
          );
        }
        if (event.boutiqueSlug == "*recommended*") {
          if (getProductListingWithFiltersPaginationModels.containsKey(
            "*recommended*withoutFilter",
          )) {
            getProductListingWithFiltersPaginationModels["*recommended*withoutFilter"] =
                getProductListingWithFiltersPaginationModels["*recommended*withoutFilter"]
                    ?.copyWith(paginationStatus: PaginationStatus.failure);
          }
          emit(
            state.copyWith(
              getProductListingWithFiltersPaginationModels:
                  getProductListingWithFiltersPaginationModels,
            ),
          );
        }
        if (event.boutiqueSlug == "*flashDeal*") {
          if (getProductListingWithFiltersPaginationModels.containsKey(
            "*flashDeal*withoutFilter",
          )) {
            getProductListingWithFiltersPaginationModels["*flashDeal*withoutFilter"] =
                getProductListingWithFiltersPaginationModels["*flashDeal*withoutFilter"]
                    ?.copyWith(paginationStatus: PaginationStatus.failure);
          }
          emit(
            state.copyWith(
              getProductListingWithFiltersPaginationModels:
                  getProductListingWithFiltersPaginationModels,
            ),
          );
        }
      },
      (r) async {
        ErrorManager.resetRetry(
          'GetWithProductFiltersWithoutCancelingPreviousEvents',
        );
        if (event.boutiqueSlug == "*featured*") {
          Map<String, PaginationModel<product.Products>?>
          getProductListingWithFiltersPaginationModels = Map.of(
            state.getProductListingWithFiltersPaginationModels,
          );
          if (getProductListingWithFiltersPaginationModels.containsKey(
            "*featured*withoutFilter",
          )) {
            getProductListingWithFiltersPaginationModels["*featured*withoutFilter"] =
                PaginationModel<product.Products>(
                  offset: "${r.data?.offset}",
                  paginationStatus: PaginationStatus.success,
                  page: 1,
                  hasReachedMax: false,
                  items: r.data?.products ?? [],
                );
            emit(
              state.copyWith(
                getProductListingWithFiltersPaginationModels:
                    getProductListingWithFiltersPaginationModels,
              ),
            );
          } else {
            getProductListingWithFiltersPaginationModels.addAll({
              "*featured*withoutFilter": PaginationModel<product.Products>(
                offset: "${r.data?.offset}",
                paginationStatus: PaginationStatus.success,
                page: 1,
                hasReachedMax: false,
                items: r.data?.products ?? [],
              ),
            });
          }

          emit(
            state.copyWith(
              getProductListingWithFiltersPaginationModels:
                  getProductListingWithFiltersPaginationModels,
            ),
          );
        }

        if (event.boutiqueSlug == "*recommended*") {
          Map<String, PaginationModel<product.Products>?>
          getProductListingWithFiltersPaginationModels = Map.of(
            state.getProductListingWithFiltersPaginationModels,
          );
          if (getProductListingWithFiltersPaginationModels.containsKey(
            "*recommended*withoutFilter",
          )) {
            getProductListingWithFiltersPaginationModels["*recommended*withoutFilter"] =
                PaginationModel<product.Products>(
                  offset: "${r.data?.offset}",
                  paginationStatus: PaginationStatus.success,
                  page: 1,
                  hasReachedMax: false,
                  items: r.data?.products ?? [],
                );
            emit(
              state.copyWith(
                getProductListingWithFiltersPaginationModels:
                    getProductListingWithFiltersPaginationModels,
              ),
            );
          } else {
            getProductListingWithFiltersPaginationModels.addAll({
              "*recommended*withoutFilter": PaginationModel<product.Products>(
                offset: "${r.data?.offset}",
                paginationStatus: PaginationStatus.success,
                page: 1,
                hasReachedMax: false,
                items: r.data?.products ?? [],
              ),
            });
          }

          emit(
            state.copyWith(
              getProductListingWithFiltersPaginationModels:
                  getProductListingWithFiltersPaginationModels,
            ),
          );
        }

        if (event.boutiqueSlug == "*flashDeal*") {
          Map<String, PaginationModel<product.Products>?>
          getProductListingWithFiltersPaginationModels = Map.of(
            state.getProductListingWithFiltersPaginationModels,
          );
          if (getProductListingWithFiltersPaginationModels.containsKey(
            "*flashDeal*withoutFilter",
          )) {
            getProductListingWithFiltersPaginationModels["*flashDeal*withoutFilter"] =
                PaginationModel<product.Products>(
                  offset: "${r.data?.offset}",
                  paginationStatus: PaginationStatus.success,
                  page: 1,
                  hasReachedMax: false,
                  items: r.data?.products ?? [],
                );
          } else {
            getProductListingWithFiltersPaginationModels.addAll({
              "*flashDeal*withoutFilter": PaginationModel<product.Products>(
                offset: "${r.data?.offset}",
                paginationStatus: PaginationStatus.success,
                page: 1,
                hasReachedMax: false,
                items: r.data?.products ?? [],
              ),
            });
          }

          emit(
            state.copyWith(
              getProductListingWithFiltersPaginationModels:
                  getProductListingWithFiltersPaginationModels,
            ),
          );
        }

        //    prefechBoutiques.release();
        prefsRepository.setPrefechOfProductsForEachBoutiqueInHomePage(
          key,
          jsonEncode(r.data),
        );
        List<String> cachedLinksOfImages = [];
        String url;
        if (event.context != null) {
          for (
            var i = 0;
            i <
                ((r.data?.products?.length ?? 0) > 4
                    ? 4
                    : (r.data?.products?.length ?? 0));
            i++
          ) {
            Products product = r.data!.products![i];
            /* product.syncColorImages?.forEach((image) {
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
*/
            /*  product.syncColorImages?.forEach((image) async {
            if (!image.images.isNullOrEmpty) {
              url = addSuitableWidthAndHeightToImage(
                imageUrl: image.images![0].filePath!,
                width: 40,
                // the width of the image in the ui
                height: 40,
                // the height of the image in the ui
              );
              prefetchImages(url, event.context!, "syncColorImages", 40, 40);
            }
          });*/
            if ((product.syncColorImages?.length ?? 0) > 0) {
              if ((product.syncColorImages![0].images?.length ?? 0) > 0) {
                url = addSuitableWidthAndHeightToImage(
                  imageUrl:
                      product.syncColorImages![0].images![0].filePath ?? "",
                  width: 200,
                  // the width of the image in the ui
                  height: 290,
                  // the height of the image in the ui
                  ordinalWidth: double.tryParse(
                    product.syncColorImages![0].images![0].originalWidth
                        .toString(),
                  ),
                  ordinalHeight: double.tryParse(
                    product.syncColorImages![0].images![0].originalHeight
                        .toString(),
                  ),
                );
                if (!cachedLinksOfImages.contains(url)) {
                  prefetchImages(
                    url,
                    event.context!,
                    "productListingImages",
                    200,
                    290,
                  );
                }
              }
            }

            if ((product.images?.length ?? 0) > 0) {
              url = addSuitableWidthAndHeightToImage(
                imageUrl: product.images![0].filePath ?? "",
                width: 200,
                // the width of the image in the ui
                height: 290,
                // the height of the image in the ui
              );
              /*url2 = addSuitableWidthAndHeightToImage(
            imageUrl: image.filePath!,
            width: 200.w,
            // the width of the image in the ui
            height: 350,
          );*/
              if (!cachedLinksOfImages.contains(url)) {
                prefetchImages(
                  url,
                  event.context!,
                  "productListingImages",
                  200,
                  290,
                );
              }
            }
            /*  Future.delayed(Duration(seconds: 5), () {
            if (!cachedLinksOfImages.contains(url2)) {
              prefetchImages(url2, event.context);
            }
          });*/
          }
          r.data?.categories?.forEach((category) {
            url = addSuitableWidthAndHeightToImage(
              imageUrl: category.mostViewedProductThumbnail?.filePath ?? "",
              width: 70,
              height: 70,
            );
            prefetchImages(
              url,
              event.context!,
              "categoryListingImages",
              70,
              70,
            );
            category.subCategories?.forEach((sub) {
              url = addSuitableWidthAndHeightToImage(
                imageUrl: sub.mostViewedProductThumbnail?.filePath ?? "",
                width: 50,
                height: 50,
              );
              prefetchImages(
                url,
                event.context!,
                "categoryListingImages",
                50,
                50,
              );
            });
          });
          r.data?.brands?.forEach((brand) {
            prefetchSvgImages(
              brand.icon!.filePath.toString(),
              event.context!,
              "brandListingImages",
              ordinalWidth: double.tryParse(
                brand.icon!.originalWidth.toString(),
              ),
              ordinalHeight: double.tryParse(
                brand.icon!.originalHeight.toString(),
              ),
            );
          });
        }
      },
    );
  }

  prefetchImages(
    String url,
    BuildContext context,
    String type,
    int width,
    int height,
  ) async {
    List<String> urlHasPredeched =
        prefsRepository.getImageUrlHasPrefeched ?? [];
    if (urlHasPredeched.contains(url) || url == "") {
      return;
    }
    GetIt.I<PreCachingImageBloc>().add(
      CacheImageEvent(
        imageUrl: url,
        context: context,
        type: type,
        height: height,
        width: width,
      ),
    );
  }

  prefetchSvgImages(
    String imageUrl,
    BuildContext context,
    String type, {
    double? ordinalHeight,
    double? ordinalWidth,
  }) {
    GetIt.I<PreCachingImageBloc>().add(
      CacheSvgEvent(
        svgUrl: imageUrl,
        type: type,
        width: ordinalWidth,
        height: ordinalHeight,
        context: context,
      ),
    );
  }

  FutureOr<void> _onAddPrefAppliedFilterForExtendFilterEvent(
    AddPrefAppliedFilterForExtendFilterEvent event,
    Emitter<BoutiqueState> emit,
  ) {
    emit(
      state.copyWith(prefAppliedFilterForExtendFilter: event.prefAppliedFilter),
    );
  }

  FutureOr<void> _onResetAllSelectedAppliedFilterEvent(
    ResetAllSelectedAppliedFilterEvent event,
    Emitter<BoutiqueState> emit,
  ) async {
    GetIt.I<CategoryBloc>().add(
      ReplyFromGeminiEvent(resetTheReply: true, fromSearch: true),
    );
    GetIt.I<CategoryBloc>().add(
      ReplyFromGeminiEvent(resetTheReply: true, fromSearch: false),
    );
    emit(
      state.copyWith(
        choosedFiltersByUser: {},
        appliedFiltersByUser: {},
        prefAppliedFilterForExtendFilter: filters_model.Filter(),
      ),
    );
  }

  FutureOr<void> _onGetProductsWithFiltersEvent(
    GetProductsWithFiltersEvent event,
    Emitter<BoutiqueState> emit,
  ) async {
    Map<String, PaginationModel<product.Products>?>
    getProductListingWithFiltersPaginationModels = Map.of(
      state.getProductListingWithFiltersPaginationModels,
    );

    Map<String, filters_model.GetProductFiltersModel?> data = Map.of(
      state.getProductFiltersModel,
    );
    //   Map<String, filters_model.GetProductFiltersModel?> dataForFirstFiveFilter =
    //      {};

    String keyWithoutFilter =
        '${event.boutiqueSlug}' +
        '${(event.getWithPagination) ? ((state.cashedOrginalBoutique) ? 'withoutFilter' : "") : ((event.cashedOrginalBoutique) ? 'withoutFilter' : "")}' +
        '${(event.category ?? '')}';

    String key = '${event.boutiqueSlug}' + '${(event.category ?? '')}';
    filters_model.Prices? prePrice =
        state.appliedFiltersByUser[key]?.filters?.prices;
    filters_model.Filter filters = event.fromChoosed ?? false
        ? state.choosedFiltersByUser[key]?.filters?.copyWithSaveOtherField(
                searchText: event.searchText,
              ) ??
              filters_model.Filter()
        : state.appliedFiltersByUser[key]?.filters?.copyWithSaveOtherField(
                searchText: event.searchText,
                prices: prePrice,
              ) ??
              filters_model.Filter();
    if ((filters.brands.isNullOrEmpty) &&
        (filters.categories.isNullOrEmpty) &&
        ((event.searchText?.length ?? 0) < 3) &&
        ((filters.searchText?.length ?? 0) < 3) &&
        (filters.prices?.minPrice == null ||
            filters.prices?.maxPrice == null) &&
        (filters.colors.isNullOrEmpty) &&
        (filters.boutiques.isNullOrEmpty) &&
        (filters.attributes.isNullOrEmpty) &&
        GetIt.I<PrefsRepository>().getTagsInUrlToFilter.isNullOrEmpty) {
      keyWithoutFilter =
          '${event.boutiqueSlug}' +
          'withoutFilter' +
          '${(event.category ?? '')}';
    }
    if (event.cashedOrginalBoutique &&
        !(event.fromSearch ?? false) &&
        !(event.getWithPagination)) {
      //    List<String> keyForFirstFiveFilterList =
      //      prefsRepository.getFiveFilterForEachBoutiqueHasPrefechInHomePage() ??
      //         [];

      //  keyForFirstFiveFilterList
      //      .removeWhere((element) => !element.contains(event.boutiqueSlug));

      /*for (var i = 0; i < keyForFirstFiveFilterList.length; i++) {
        String keyForFirstFiveFilter = keyForFirstFiveFilterList[i];
        if (!dataForFirstFiveFilter.containsValue(keyForFirstFiveFilter)) {
          data.addAll(
              {keyForFirstFiveFilter: filters_model.GetProductFiltersModel()});
        }
        if (!getProductListingWithFiltersForFirstFiveFilter
            .containsValue(keyForFirstFiveFilter)) {
          getProductListingWithFiltersForFirstFiveFilter
              .addAll({keyForFirstFiveFilter: PaginationModel.init()});
        }
        final responseFromSharedPrefrence = jsonDecode(
            prefsRepository.getPrefechForFiveFilterForEachBoutiqueInHomePage(
                    keyForFirstFiveFilter) ??
                "{}");

        DataGetProductListingWithFiltersModel
            getProductListingWithFiltersForFirstFiveFilterModel =
            responseFromSharedPrefrence == {}
                ? DataGetProductListingWithFiltersModel()
                : DataGetProductListingWithFiltersModel.fromJson(
                    responseFromSharedPrefrence);

        getProductListingWithFiltersForFirstFiveFilter[keyForFirstFiveFilter] =
            PaginationModel<product.Products>(
                hasReachedMax:
                    (getProductListingWithFiltersForFirstFiveFilterModel
                                .products?.length ??
                            0) <
                        20,
                items: getProductListingWithFiltersForFirstFiveFilterModel
                        .products ??
                    [],
                offset: getProductListingWithFiltersForFirstFiveFilterModel
                    .offset
                    .toString(),
                page: 1,
                paginationStatus: PaginationStatus.success);

        List<filters_model.PriceRange> ranges =
            getProductListingWithFiltersForFirstFiveFilterModel
                    .prices?.priceRanges ??
                [];

        ranges.removeWhere((element) => element.count == 0);
        dataForFirstFiveFilter[keyForFirstFiveFilter] =
            filters_model.GetProductFiltersModel(
                filters: filters_model.Filter(
          totalSize:
              getProductListingWithFiltersForFirstFiveFilterModel.totalSize,
          brands: getProductListingWithFiltersForFirstFiveFilterModel.brands,
          attributes:
              getProductListingWithFiltersForFirstFiveFilterModel.attributes,
          prices: getProductListingWithFiltersForFirstFiveFilterModel.prices
              ?.copyWith(priceRanges: ranges),
          boutiques:
              getProductListingWithFiltersForFirstFiveFilterModel.boutiques,
          colors: getProductListingWithFiltersForFirstFiveFilterModel.colors,
          searchText: null,
          categories:
              getProductListingWithFiltersForFirstFiveFilterModel.categories,
        ));
      }*/

      /* emit(state.copyWith(
        getProductFiltersWithPrefetchModel: Map.of(dataForFirstFiveFilter),
        getProductListingWithFiltersPaginationWithPrefetchModels:
            Map.of(getProductListingWithFiltersForFirstFiveFilter),
      ));*/

      if (!data.containsValue(key)) {
        data.addAll({key: filters_model.GetProductFiltersModel()});
      }
      if (!getProductListingWithFiltersPaginationModels.containsValue(
        event.boutiqueSlug,
      )) {
        getProductListingWithFiltersPaginationModels.addAll({
          keyWithoutFilter: const PaginationModel.init(),
        });
      }
      data.removeWhere(
        (key, value) =>
            !(key.contains(event.boutiqueSlug)) && !(key.contains("search")),
      );
      getProductListingWithFiltersPaginationModels.removeWhere(
        (key, value) =>
            !(key.contains(event.boutiqueSlug)) &&
            !(key.contains("search")) &&
            !(key.contains("*featured*")) &&
            !(key.contains("*recommended*")) &&
            !(key.contains("*flashDeal*")),
      );
      Map<String, dynamic> responseFromSharedPrefrence = jsonDecode(
        prefsRepository.getPrefechOfProductsForEachBoutiqueInHomePage(key) ??
            "{}",
      );
      DataGetProductListingWithFiltersModel getProductListingWithFiltersModel =
          responseFromSharedPrefrence == {}
          ? DataGetProductListingWithFiltersModel()
          : DataGetProductListingWithFiltersModel.fromJson(
              responseFromSharedPrefrence,
            );

      getProductListingWithFiltersPaginationModels[keyWithoutFilter] =
          PaginationModel<product.Products>(
            hasReachedMax:
                (getProductListingWithFiltersModel.products?.length ?? 0) < 20,
            items: getProductListingWithFiltersModel.products ?? [],
            page: 1,
            paginationStatus: /* (keyWithoutFilter.contains("withoutFilter") &&
                      !keyWithoutFilter.contains("*featured*withoutFilter") &&
                      !keyWithoutFilter.contains("*flashDeal*withoutFilter") &&
                      (getProductListingWithFiltersModel.products?.length ??
                              0) >
                          0)
                  ? PaginationStatus.loading
                  : */
                PaginationStatus.loading,
          );

      List<filters_model.PriceRange> ranges =
          getProductListingWithFiltersModel.prices?.priceRanges ?? [];
      ranges.removeWhere((element) => element.count == 0);
      data[key] = filters_model.GetProductFiltersModel(
        filters: filters_model.Filter(
          totalSize: getProductListingWithFiltersModel.totalSize,
          brands: getProductListingWithFiltersModel.brands,
          attributes: getProductListingWithFiltersModel.attributes,
          prices: getProductListingWithFiltersModel.prices?.copyWith(
            priceRanges: ranges,
          ),
          boutiques: getProductListingWithFiltersModel.boutiques,
          colors: getProductListingWithFiltersModel.colors,
          categories: getProductListingWithFiltersModel.categories,
        ),
      );
    }

    Map<String, filters_model.GetProductFiltersModel?> prevAppliedFiltersByUser,
        prevChoosedFiltersByUser;
    prevChoosedFiltersByUser = Map.of(state.choosedFiltersByUser);
    prevAppliedFiltersByUser = Map.of(state.appliedFiltersByUser);

    if (getProductListingWithFiltersPaginationModels[keyWithoutFilter] ==
        null) {
      getProductListingWithFiltersPaginationModels.addAll({
        keyWithoutFilter: const PaginationModel.init(),
      });
    }

    if (!((event.cashedOrginalBoutique && !(event.fromSearch ?? false)) &&
        !(event.getWithPagination) &&
        getProductListingWithFiltersPaginationModels[keyWithoutFilter]
                ?.paginationStatus ==
            PaginationStatus.success)) {
      getProductListingWithFiltersPaginationModels[keyWithoutFilter] =
          getProductListingWithFiltersPaginationModels[keyWithoutFilter]!
              .copyWith(paginationStatus: PaginationStatus.loading);
    }
    if (event.getWithPagination) {
      getProductListingWithFiltersPaginationModels[keyWithoutFilter] =
          getProductListingWithFiltersPaginationModels[keyWithoutFilter]!
              .copyWith(paginationStatus: PaginationStatus.success);
    }
    Map<String, filters_model.GetProductFiltersModel?> choosedFilters = Map.of(
      state.choosedFiltersByUser,
    );
    Map<String, filters_model.GetProductFiltersModel?> appliedFilters = Map.of(
      state.appliedFiltersByUser,
    );
    if (event.resetChoosedFilters) {
      choosedFilters[key] = null;
    }

    bool checkForFilter =
        ((filters.colors?.isNullOrEmpty ?? true) &&
        (filters.brands?.isNullOrEmpty ?? true) &&
        (filters.attributes?.isNullOrEmpty ?? true) &&
        (filters.boutiques?.isNullOrEmpty ?? true) &&
        (filters.categories?.isNullOrEmpty ?? true) &&
        (filters.searchText == null) &&
        filters.prices == null);

    if (!(event.fromChoosed ?? false)) {
      if (checkForFilter) {
        appliedFilters[key] = null;
      } else {
        appliedFilters[key] = filters_model.GetProductFiltersModel(
          filters: filters,
        );
        ///////////////////////////////
        // Future.delayed(
        //   Duration(milliseconds: 100),
        //   () => FirebaseAnalyticsService.logEventForSession(
        //     eventName: AnalyticsEventsConst.programmingEvent,
        //     executedEventName:
        //         AnalyticsButtonsEventNameConst.appliedFiltersEvent,
        //     extraParams: {
        //       'brands': json.encode(brandsForAnalytics ?? []),
        //       'categories': json.encode(categoriesForAnalytics ?? []),
        //       'boutiques': json.encode(boutiquesForAnalytics ?? []),
        //       'colors': json.encode(colorsForAnalytics ?? []),
        //       'prices': json.encode(pricesForAnalytics ?? []),
        //       'options': json.encode(optionsForAnalytics ?? []),
        //       'searchText': json.encode(searchTextForAnalytics ?? ''),
        //     },
        //   ),
        // );
      }
    } else {
      // if (!checkForFilter) {
      //   ///////////////////////////////
      //   Future.delayed(
      //     Duration(milliseconds: 100),
      //     () => FirebaseAnalyticsService.logEventForSession(
      //       eventName: AnalyticsEventsConst.programmingEvent,
      //       executedEventName:
      //           AnalyticsButtonsEventNameConst.appliedFiltersEvent,
      //       extraParams: {
      //         'brands': json.encode(brandsForAnalytics ?? []),
      //         'categories': json.encode(categoriesForAnalytics ?? []),
      //         'boutiques': json.encode(boutiquesForAnalytics ?? []),
      //         'colors': json.encode(colorsForAnalytics ?? []),
      //         'prices': json.encode(pricesForAnalytics ?? []),
      //         'options': json.encode(optionsForAnalytics ?? []),
      //         'searchText': json.encode(searchTextForAnalytics ?? ''),
      //       },
      //     ),
      //   );
      // }
    }

    Map<String, GetProductFiltersStatus>? getProductFiltersStatus = Map.of(
      state.getProductFiltersStatus,
    );
    if (getProductFiltersStatus[key] == null) {
      getProductFiltersStatus.addAll({key: GetProductFiltersStatus.loading});
    } else {
      getProductFiltersStatus[key] = GetProductFiltersStatus.loading;
    }
    emit(
      state.copyWith(
        getProductFiltersModel: Map.of(data),
        getProductFiltersStatus: getProductFiltersStatus,
        cashedOrginalBoutique: (event.getWithPagination)
            ? (state.cashedOrginalBoutique)
            : (event.cashedOrginalBoutique),
        isGettingProductListingWithPaginationForAppearProduct:
            event.getWithPagination,
        isGettingProductListingWithPagination: event.getWithPagination,
        //  reRequestProductWithFilters: Map.of(reRequestProductWithFilters),
        getProductListingWithFiltersPaginationModels:
            getProductListingWithFiltersPaginationModels,
        choosedFiltersByUser: Map.of(choosedFilters),
        appliedFiltersByUser: Map.of(appliedFilters),
      ),
    );

    final response = event.boutiqueSlug == "*featured*"
        ? await getFeaturedProductsUseCase(
            GetFeaturedProductsParams(
              limit: 20,
              categorySlugs:
                  (state.currentMainCategoryTaped == "" ||
                      state.currentMainCategoryTaped == null ||
                      state.currentMainCategoryTaped == "Empty")
                  ? null
                  : ['"${state.currentMainCategoryTaped}"'],
              offset: !event.getWithPagination
                  ? null
                  : state.searchWithFilterOffset?[keyWithoutFilter] ?? [],
            ),
          )
        : event.boutiqueSlug == "*recommended*"
        ? await getRecommendProductsUseCase(
            GetRecommendProductsParams(
              limit: 20,
              offset: !event.getWithPagination
                  ? null
                  : state.searchWithFilterOffset?[keyWithoutFilter] ?? [],
              categorySlugs:
                  (state.currentMainCategoryTaped == "" ||
                      state.currentMainCategoryTaped == null ||
                      state.currentMainCategoryTaped == "Empty")
                  ? null
                  : ['"${state.currentMainCategoryTaped}"'],
            ),
          )
        : event.boutiqueSlug == "*flashDeal*"
        ? await getProductsWithFiltersUseCase(
            GetProductsWithFiltersParams(
              flashDeal: true,
              limit: 20,
              offset: !event.getWithPagination
                  ? null
                  : state.searchWithFilterOffset?[keyWithoutFilter] ?? [],
              categorySlugs:
                  (state.currentMainCategoryTaped == "" ||
                      state.currentMainCategoryTaped == null ||
                      state.currentMainCategoryTaped == "Empty")
                  ? null
                  : ['"${state.currentMainCategoryTaped}"'],
            ),
          )
        : await getProductsWithFiltersUseCase(
            GetProductsWithFiltersParams(
              brandSlugs: filters.brands
                  ?.map((e) => '"${e.slug.toString()}"')
                  .toList(),
              categorySlugs: (event.category != null && event.category != "")
                  ? [
                      ...(filters.categories
                              ?.map((e) => '"${e.slug.toString()}"')
                              .toList() ??
                          []),
                      (event.resetChoosedFilters == true &&
                              (event.fromSearch ?? false))
                          ? ""
                          : '"${event.category}"',
                    ]
                  : filters.categories
                        ?.map((e) => '"${e.slug.toString()}"')
                        .toList(),
              boutiqueSlugs: event.fromSearch ?? false
                  ? filters.boutiques
                        ?.map((e) => '"${e.slug.toString()}"')
                        .toList()
                  : ['"${event.boutiqueSlug}"'],
              offset: !event.getWithPagination
                  ? null
                  : state.searchWithFilterOffset?[keyWithoutFilter] ?? [],
              attributes: filters.attributes.isNullOrEmpty
                  ? null
                  : [
                      {
                        '"id"': '"${filters.attributes![0].id}"',
                        '"name"': '"${filters.attributes![0].name}"',
                        '"options"': [
                          ...(filters.attributes![0].options) ?? [],
                        ].map((e) => '"${e}"').toList(),
                      },
                    ],
              colors: ([
                ...filters.colors ?? [],
              ]).map((e) => '"${e.toString()}"').toList(),
              limit: 20,
              prices:
                  (prevAppliedFiltersByUser[key]?.filters?.prices?.maxPrice !=
                          null &&
                      prevAppliedFiltersByUser[key]
                              ?.filters
                              ?.prices
                              ?.minPrice !=
                          null)
                  ? [
                      '"${prevAppliedFiltersByUser[key]?.filters?.prices?.minPrice}-${prevAppliedFiltersByUser[key]?.filters?.prices?.maxPrice}"',
                    ]
                  : null,
              searchText:
                  filters.searchText ??
                  state.appliedFiltersByUser[key]?.filters?.searchText,
            ),
          );

    response.fold(
      (l) {
        Map<String, PaginationModel<product.Products>?>
        getProductListingWithFiltersPaginationModels = Map.of(
          state.getProductListingWithFiltersPaginationModels,
        );
        if (ErrorManager.shouldRetry(
          'GetProductsWithFiltersEvent',
          l.statusCode,
        )) {
          add(
            GetProductsWithFiltersEvent(
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
            ),
          );
          ErrorManager.incrementRetry('GetProductsWithFiltersEvent');
        }
        getProductListingWithFiltersPaginationModels[keyWithoutFilter] =
            getProductListingWithFiltersPaginationModels[keyWithoutFilter]!
                .copyWith(paginationStatus: PaginationStatus.failure);
        emit(
          state.copyWith(
            isGettingProductListingWithPagination: false,
            choosedFiltersByUser: Map.of(prevChoosedFiltersByUser),
            getProductListingWithFiltersPaginationModels: Map.of(
              getProductListingWithFiltersPaginationModels,
            ),
            appliedFiltersByUser: Map.of(prevAppliedFiltersByUser),
          ),
        );
      },
      (r) {
        FirebaseAnalyticsService.logEventForSession(
          eventName: AnalyticsEventsConst.VIEW_ITEMS_LIST,
          executedEventName:
              AnalyticsButtonsEventNameConst.VIEW_ITEM_LIST_EVENT,
          extraParams: {
            'item_list_id': Random().nextInt(1000000).toString(),
            'items':
                r.data?.products
                    ?.map(
                      (e) => {
                        'item_id': e.productId.toString(),
                        'item_name': e.name.toString(),
                        'brand': e.brand!.name.toString(),
                        'category': e.categories!
                            .map((e) => e.id.toString())
                            .toList()
                            .toString(),
                      },
                    )
                    .toList()
                    .toString() ??
                '',
          },
        ).toString();
        try {
          if (((filters.searchText ??
                          state.appliedFiltersByUser[key]?.filters?.searchText)
                      ?.length ??
                  0) >
              2) {
            FirebaseAnalyticsService.logEventForSession(
              eventName: AnalyticsEventsConst.SEARCH,
              executedEventName:
                  AnalyticsButtonsEventNameConst.SEARCH_WITH_VOICE_BUTTON,
              extraParams: {
                'search_keyword':
                    filters.searchText ??
                    state.appliedFiltersByUser[key]?.filters?.searchText ??
                    '',
                'screen_name': GlobalScreenConst.SEARCH_SCREEN,
                'search_results_count': r.data?.totalSize.toString() ?? '',
                'search_results_limit':
                    r.data?.products?.length.toString() ?? '',
              },
            );
          }
          String url;
          r.data?.products?.forEach((product) {
            if ((product.syncColorImages?.length ?? 0) > 0) {
              //  .forEach((image) {
              //    if (!image.images.isNullOrEmpty) {

              url = addSuitableWidthAndHeightToImage(
                imageUrl: product.syncColorImages![0].images![0].filePath ?? "",
                ordinalHeight: double.tryParse(
                  product.syncColorImages![0].images![0].originalHeight ?? "0",
                ),
                ordinalWidth: double.tryParse(
                  product.syncColorImages![0].images![0].originalHeight ?? "0",
                ),
                width: 320,
                // the width of the image in the ui
                height: 464,
              );

              prefetchImages(
                url,
                event.context!,
                "productDetailsImages",
                320,
                464,
              );
              //   });
              //   }
              //   });
            } else {
              // product.images?.forEach((image) {
              url = addSuitableWidthAndHeightToImage(
                imageUrl: product.images![0].filePath ?? "",
                ordinalHeight: double.tryParse(
                  product.images![0].originalHeight ?? "0",
                ),
                ordinalWidth: double.tryParse(
                  product.images![0].originalHeight ?? "0",
                ),
                width: 320,
                // the width of the image in the ui
                height: 464,
              );

              prefetchImages(
                url,
                event.context!,
                "productDetailsImages",
                320,
                464,
              );
              //    });
            }
          });
        } catch (e) {}
        if (event.cashedOrginalBoutique &&
            !(event.fromSearch ?? false) &&
            !(event.getWithPagination)) {
          prefsRepository.setPrefechOfProductsForEachBoutiqueInHomePage(
            key,
            jsonEncode(r.data),
          );
        }

        Map<String, List<double>> searchWithFilterOffset = Map.of(
          state.searchWithFilterOffset ?? {},
        );

        if (searchWithFilterOffset.containsKey(keyWithoutFilter)) {
          searchWithFilterOffset[keyWithoutFilter] = r.data?.offset ?? [];
        } else {
          searchWithFilterOffset.addAll({
            keyWithoutFilter: r.data?.offset ?? [],
          });
        }
        Map<String, PaginationModel<product.Products>?>
        getProductListingWithFiltersPaginationModels =
            <String, PaginationModel<product.Products>?>{};

        //  if (state.idForRequest == idForRequest || state.cashedOrginalBoutique) {
        ErrorManager.resetRetry('GetProductsWithFiltersEvent');

        Map<String, filters_model.GetProductFiltersModel?> data = Map.of(
          state.getProductFiltersModel,
        );
        List<filters_model.PriceRange> ranges =
            r.data!.prices?.priceRanges ?? [];
        ranges.removeWhere((element) => element.count == 0);
        if (data[key] == null) {
          data.addAll({key: filters_model.GetProductFiltersModel()});
        }

        if (event.fromNotification ?? false) {
          data[key] = filters_model.GetProductFiltersModel(
            filters: filters_model.Filter(
              totalSize: r.data?.totalSize,
              brands: r.data!.brands,
              attributes: r.data!.attributes,
              prices: r.data!.prices?.copyWith(priceRanges: ranges),
              boutiques: r.data!.boutiques,
              colors: r.data!.colors,
              searchText: filters.searchText,
              categories: r.data!.categories,
            ),
          );
        } else {
          data[key] = filters_model.GetProductFiltersModel(
            filters: filters_model.Filter(
              totalSize: r.data?.totalSize,
              brands: r.data!.brands,
              attributes: r.data!.attributes,
              prices: r.data!.prices?.copyWith(priceRanges: ranges),
              boutiques: r.data!.boutiques,
              colors: r.data!.colors,
              searchText: filters.searchText,
              categories: r.data!.categories,
            ),
          );
        }
        /* if (event.cashedOrginalBoutique &&
          !(event.fromSearch ?? false) &&
          !event.getWithPagination) {
        PrefetchProductsForFirstFiveFilter(
            filter: data[key]?.filters,
            boutiqueSlug: event.boutiqueSlug,
            categorySlug: event.category);
      }*/
        List<Products>? productsResult = r.data?.products ?? [];
        /*if (!(event.fromSearch ?? false) && (filters.colors?.length ?? 0) > 0 ||
          ((state.sizeAndColorFilterinTextToSearch["color"]?.length ?? 0) >
              0)) {
        productsResult = [];
        r.data!.products?.forEach(
          (element) {
            List<product.SyncColorImage>? syncColorImageList =
                element.syncColorImages;
            List<product.Color>? colorsForSync = element.colors;
            if (syncColorImageList?.length == 3 ||
                syncColorImageList?.length == 2) {
              product.SyncColorImage firstImage = syncColorImageList![0];
              product.Color firstColor = colorsForSync![0];
              firstImage = syncColorImageList.removeAt(0);
              firstColor = colorsForSync.removeAt(0);
              syncColorImageList.insert(1, firstImage);
              colorsForSync.insert(1, firstColor);
            } else if ((syncColorImageList?.length ?? 0) > 3) {
              product.SyncColorImage firstImage = syncColorImageList![0];
              product.Color firstColor = colorsForSync![0];
              firstColor = colorsForSync.removeAt(0);
              firstImage = syncColorImageList.removeAt(0);
              colorsForSync.insert(
                  ((syncColorImageList.length ~/ 2) +
                      (syncColorImageList.length % 2 == 0 ? 0 : 1)),
                  firstColor);
              syncColorImageList.insert(
                  ((syncColorImageList.length ~/ 2) +
                      (syncColorImageList.length % 2 == 0 ? 0 : 1)),
                  firstImage);
            }
            productsResult?.add(element.copyWith(
                syncColorImages: syncColorImageList, colors: colorsForSync));
          },
        );
      }*/

        if (event.fromNotification ?? false) {
          PaginationModel<Products>? value = PaginationModel<Products>(
            items: event.getWithPagination
                ? [
                    ...List.of(
                      getProductListingWithFiltersPaginationModels[keyWithoutFilter]
                              ?.items ??
                          [],
                    ),
                    ...productsResult,
                  ]
                : productsResult,
            page: (event.getWithPagination
                ? (getProductListingWithFiltersPaginationModels[keyWithoutFilter]
                              ?.page ??
                          0) +
                      1
                : 2),
            paginationStatus: PaginationStatus.success,
            hasReachedMax:
                (r.data?.products?.length ?? 0) < 20 ||
                r.data?.offset == null ||
                r.data?.offset == "null",
          );
          getProductListingWithFiltersPaginationModels.addAll({
            keyWithoutFilter: value,
          });
        } else {
          getProductListingWithFiltersPaginationModels.addAll({
            keyWithoutFilter: PaginationModel<Products>(
              page: 1,
              offset: "${r.data?.offset}",
              hasReachedMax:
                  (r.data?.products?.length ?? 0) < 20 ||
                  r.data?.offset == null ||
                  r.data?.offset == "null",
              items: event.getWithPagination
                  ? [
                      ...List.of(
                        (state
                                .getProductListingWithFiltersPaginationModels[keyWithoutFilter]
                                ?.items) ??
                            [],
                      ),
                      ...productsResult,
                    ]
                  : productsResult,
              paginationStatus: PaginationStatus.success,
            ),
          });

          state.getProductListingWithFiltersPaginationModels.forEach((
            keys,
            value,
          ) {
            if (keys == keyWithoutFilter) {
              /*getProductListingWithFiltersPaginationModels.addAll({
              keys: value!.copyWith(
                  offset: "${r.data?.offset}",
                  paginationStatus: PaginationStatus.success,
                  page: event.getWithPagination ? value.page + 1 : 2,
                  hasReachedMax: (r.data?.products?.length ?? 0) < kPageSize,
                  items: event.getWithPagination
                      ? [...List.of(value.items), ...productsResult ?? []]
                      : productsResult)
            });*/
            } else {
              getProductListingWithFiltersPaginationModels.addAll({
                keys: value,
              });
            }
          });
        }
        Map<String, GetProductFiltersStatus>? getProductFiltersStatus = Map.of(
          state.getProductFiltersStatus,
        );
        getProductFiltersStatus[key] = GetProductFiltersStatus.success;
        emit(
          state.copyWith(
            getProductFiltersStatus: getProductFiltersStatus,
            searchWithFilterOffset: searchWithFilterOffset,
            getProductListingWithFiltersPaginationModels: Map.of(
              getProductListingWithFiltersPaginationModels,
            ),
            countOfProductExpectedByFiltering: Map.of({
              event.boutiqueSlug: r.data!.totalSize ?? 0,
            }),
            getProductFiltersModel: Map.of(data),
            isGettingProductListingWithPagination: false,
          ),
        );
      },
    );
  }

  FutureOr<void> _onGetProductsWithFiltersWithPaginationEvent(
    GetProductsWithFiltersWithPaginationEvent event,
    Emitter<BoutiqueState> emit,
  ) async {
    Map<String, PaginationModel<product.Products>?>
    getProductListingWithFiltersPaginationModels = Map.of(
      state.getProductListingWithFiltersPaginationModels,
    );

    Map<String, filters_model.GetProductFiltersModel?> data = Map.of(
      state.getProductFiltersModel,
    );

    String keyWithoutFilter =
        '${event.boutiqueSlug}' +
        '${(event.getWithPagination) ? ((state.cashedOrginalBoutique) ? 'withoutFilter' : "") : ((event.cashedOrginalBoutique) ? 'withoutFilter' : "")}' +
        '${(event.category ?? '')}';

    String key = '${event.boutiqueSlug}' + '${(event.category ?? '')}';
    filters_model.Prices? prePrice =
        state.appliedFiltersByUser[key]?.filters?.prices;
    filters_model.Filter filters = event.fromChoosed ?? false
        ? state.choosedFiltersByUser[key]?.filters?.copyWithSaveOtherField(
                searchText: event.searchText,
              ) ??
              filters_model.Filter()
        : state.appliedFiltersByUser[key]?.filters?.copyWithSaveOtherField(
                searchText: event.searchText,
                prices: prePrice,
              ) ??
              filters_model.Filter();
    if ((filters.brands.isNullOrEmpty) &&
        (filters.categories.isNullOrEmpty) &&
        ((event.searchText?.length ?? 0) < 3) &&
        ((filters.searchText?.length ?? 0) < 3) &&
        (filters.prices?.minPrice == null ||
            filters.prices?.maxPrice == null) &&
        (filters.colors.isNullOrEmpty) &&
        (filters.boutiques.isNullOrEmpty) &&
        (filters.attributes.isNullOrEmpty) &&
        GetIt.I<PrefsRepository>().getTagsInUrlToFilter.isNullOrEmpty) {
      keyWithoutFilter =
          '${event.boutiqueSlug}' +
          'withoutFilter' +
          '${(event.category ?? '')}';
    }
    if (event.cashedOrginalBoutique &&
        !(event.fromSearch ?? false) &&
        !(event.getWithPagination)) {
      //   List<String> keyForFirstFiveFilterList =
      //    prefsRepository.getFiveFilterForEachBoutiqueHasPrefechInHomePage() ??
      //       [];

      //  keyForFirstFiveFilterList
      //      .removeWhere((element) => !element.contains(event.boutiqueSlug));

      /*for (var i = 0; i < keyForFirstFiveFilterList.length; i++) {
        String keyForFirstFiveFilter = keyForFirstFiveFilterList[i];
        if (!dataForFirstFiveFilter.containsValue(keyForFirstFiveFilter)) {
          data.addAll(
              {keyForFirstFiveFilter: filters_model.GetProductFiltersModel()});
        }
        if (!getProductListingWithFiltersForFirstFiveFilter
            .containsValue(keyForFirstFiveFilter)) {
          getProductListingWithFiltersForFirstFiveFilter
              .addAll({keyForFirstFiveFilter: PaginationModel.init()});
        }
        final responseFromSharedPrefrence = jsonDecode(
            prefsRepository.getPrefechForFiveFilterForEachBoutiqueInHomePage(
                    keyForFirstFiveFilter) ??
                "{}");

        DataGetProductListingWithFiltersModel
            getProductListingWithFiltersForFirstFiveFilterModel =
            responseFromSharedPrefrence == {}
                ? DataGetProductListingWithFiltersModel()
                : DataGetProductListingWithFiltersModel.fromJson(
                    responseFromSharedPrefrence);

        getProductListingWithFiltersForFirstFiveFilter[keyForFirstFiveFilter] =
            PaginationModel<product.Products>(
                hasReachedMax:
                    (getProductListingWithFiltersForFirstFiveFilterModel
                                .products?.length ??
                            0) <
                        20,
                items: getProductListingWithFiltersForFirstFiveFilterModel
                        .products ??
                    [],
                offset: getProductListingWithFiltersForFirstFiveFilterModel
                    .offset
                    .toString(),
                page: 1,
                paginationStatus: PaginationStatus.success);

        List<filters_model.PriceRange> ranges =
            getProductListingWithFiltersForFirstFiveFilterModel
                    .prices?.priceRanges ??
                [];

        ranges.removeWhere((element) => element.count == 0);
        dataForFirstFiveFilter[keyForFirstFiveFilter] =
            filters_model.GetProductFiltersModel(
                filters: filters_model.Filter(
          totalSize:
              getProductListingWithFiltersForFirstFiveFilterModel.totalSize,
          brands: getProductListingWithFiltersForFirstFiveFilterModel.brands,
          attributes:
              getProductListingWithFiltersForFirstFiveFilterModel.attributes,
          prices: getProductListingWithFiltersForFirstFiveFilterModel.prices
              ?.copyWith(priceRanges: ranges),
          boutiques:
              getProductListingWithFiltersForFirstFiveFilterModel.boutiques,
          colors: getProductListingWithFiltersForFirstFiveFilterModel.colors,
          searchText: null,
          categories:
              getProductListingWithFiltersForFirstFiveFilterModel.categories,
        ));
      }

      emit(state.copyWith(
        getProductFiltersWithPrefetchModel: Map.of(dataForFirstFiveFilter),
        getProductListingWithFiltersPaginationWithPrefetchModels:
            Map.of(getProductListingWithFiltersForFirstFiveFilter),
      ));*/
      print(
        "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF66666666666666666699999999999988888888888888888666666666FFFFFFF${event.boutiqueSlug}",
      );

      if (!data.containsValue(key)) {
        data.addAll({key: filters_model.GetProductFiltersModel()});
      }
      if (!getProductListingWithFiltersPaginationModels.containsValue(
        event.boutiqueSlug,
      )) {
        getProductListingWithFiltersPaginationModels.addAll({
          keyWithoutFilter: const PaginationModel.init(),
        });
      }
      data.removeWhere(
        (key, value) =>
            !(key.contains(event.boutiqueSlug)) && !(key.contains("search")),
      );
      getProductListingWithFiltersPaginationModels.removeWhere(
        (key, value) =>
            !(key.contains(event.boutiqueSlug)) &&
            !(key.contains("search")) &&
            !(key.contains("*featured*")) &&
            !(key.contains("*recommended*")) &&
            !(key.contains("*flashDeal*")),
      );
      Map<String, dynamic> responseFromSharedPrefrence = jsonDecode(
        prefsRepository.getPrefechOfProductsForEachBoutiqueInHomePage(key) ??
            "{}",
      );
      DataGetProductListingWithFiltersModel getProductListingWithFiltersModel =
          responseFromSharedPrefrence == {}
          ? DataGetProductListingWithFiltersModel()
          : DataGetProductListingWithFiltersModel.fromJson(
              responseFromSharedPrefrence,
            );

      getProductListingWithFiltersPaginationModels[keyWithoutFilter] =
          PaginationModel<product.Products>(
            hasReachedMax:
                (getProductListingWithFiltersModel.products?.length ?? 0) < 20,
            items: getProductListingWithFiltersModel.products ?? [],
            page: 1,
            paginationStatus:
                (keyWithoutFilter.contains("withoutFilter") &&
                    !keyWithoutFilter.contains("*featured*withoutFilter") &&
                    !keyWithoutFilter.contains("*recommended*withoutFilter") &&
                    !keyWithoutFilter.contains("*flashDeal*withoutFilter") &&
                    (getProductListingWithFiltersModel.products?.length ?? 0) >
                        0)
                ? PaginationStatus.success
                : PaginationStatus.loading,
          );

      List<filters_model.PriceRange> ranges =
          getProductListingWithFiltersModel.prices?.priceRanges ?? [];
      ranges.removeWhere((element) => element.count == 0);
      data[key] = filters_model.GetProductFiltersModel(
        filters: filters_model.Filter(
          totalSize: getProductListingWithFiltersModel.totalSize,
          brands: getProductListingWithFiltersModel.brands,
          attributes: getProductListingWithFiltersModel.attributes,
          prices: getProductListingWithFiltersModel.prices?.copyWith(
            priceRanges: ranges,
          ),
          boutiques: getProductListingWithFiltersModel.boutiques,
          colors: getProductListingWithFiltersModel.colors,
          categories: getProductListingWithFiltersModel.categories,
        ),
      );
    }

    Map<String, filters_model.GetProductFiltersModel?> prevAppliedFiltersByUser,
        prevChoosedFiltersByUser;
    prevChoosedFiltersByUser = Map.of(state.choosedFiltersByUser);
    prevAppliedFiltersByUser = Map.of(state.appliedFiltersByUser);

    if (getProductListingWithFiltersPaginationModels[keyWithoutFilter] ==
        null) {
      getProductListingWithFiltersPaginationModels.addAll({
        keyWithoutFilter: const PaginationModel.init(),
      });
    }

    if (!((event.cashedOrginalBoutique && !(event.fromSearch ?? false)) &&
        !(event.getWithPagination) &&
        getProductListingWithFiltersPaginationModels[keyWithoutFilter]
                ?.paginationStatus ==
            PaginationStatus.success)) {
      getProductListingWithFiltersPaginationModels[keyWithoutFilter] =
          getProductListingWithFiltersPaginationModels[keyWithoutFilter]!
              .copyWith(paginationStatus: PaginationStatus.loading);
    }
    if (event.getWithPagination) {
      getProductListingWithFiltersPaginationModels[keyWithoutFilter] =
          getProductListingWithFiltersPaginationModels[keyWithoutFilter]!
              .copyWith(paginationStatus: PaginationStatus.success);
    }
    Map<String, filters_model.GetProductFiltersModel?> choosedFilters = Map.of(
      state.choosedFiltersByUser,
    );
    Map<String, filters_model.GetProductFiltersModel?> appliedFilters = Map.of(
      state.appliedFiltersByUser,
    );
    if (event.resetChoosedFilters) {
      choosedFilters[key] = null;
    }

    bool checkForFilter =
        ((filters.colors?.isNullOrEmpty ?? true) &&
        (filters.brands?.isNullOrEmpty ?? true) &&
        (filters.attributes?.isNullOrEmpty ?? true) &&
        (filters.boutiques?.isNullOrEmpty ?? true) &&
        (filters.categories?.isNullOrEmpty ?? true) &&
        (filters.searchText == null) &&
        filters.prices == null);

    List<String>? brandsForAnalytics = filters.brands
        ?.map((e) => e.slug.toString())
        .toList();
    List<String>? categoriesForAnalytics = filters.categories
        ?.map((e) => e.slug.toString())
        .toList();
    List<String>? boutiquesForAnalytics = event.fromSearch ?? false
        ? filters.boutiques?.map((e) => e.slug.toString()).toList()
        : [event.boutiqueSlug];
    List<String>? colorsForAnalytics = filters.colors;
    List<String>? pricesForAnalytics =
        (prevAppliedFiltersByUser[key]?.filters?.prices?.maxPrice != null &&
            prevAppliedFiltersByUser[key]?.filters?.prices?.minPrice != null)
        ? [
            '${prevAppliedFiltersByUser[key]?.filters?.prices?.minPrice}-${prevAppliedFiltersByUser[key]?.filters?.prices?.maxPrice}',
          ]
        : null;
    List<String>? optionsForAnalytics = filters.attributes.isNullOrEmpty
        ? []
        : filters.attributes?[0].options;
    String? searchTextForAnalytics =
        filters.searchText ??
        state.appliedFiltersByUser[key]?.filters?.searchText;

    if (!(event.fromChoosed ?? false)) {
      if (checkForFilter) {
        appliedFilters[key] = null;
      } else {
        appliedFilters[key] = filters_model.GetProductFiltersModel(
          filters: filters,
        );
        ///////////////////////////////
        Future.delayed(
          const Duration(milliseconds: 100),
          () => FirebaseAnalyticsService.logEventForSession(
            eventName: AnalyticsEventsConst.PROGRAMMING_EVENT,
            executedEventName:
                AnalyticsButtonsEventNameConst.APPLIED_FILTERS_EVENT,
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
          const Duration(milliseconds: 100),
          () => FirebaseAnalyticsService.logEventForSession(
            eventName: AnalyticsEventsConst.APPLY_FILTER,
            executedEventName:
                AnalyticsButtonsEventNameConst.APPLIED_FILTERS_EVENT,
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

    Map<String, GetProductFiltersStatus>? getProductFiltersStatus = Map.of(
      state.getProductFiltersStatus,
    );
    if (getProductFiltersStatus[key] == null) {
      getProductFiltersStatus.addAll({key: GetProductFiltersStatus.loading});
    } else {
      getProductFiltersStatus[key] = GetProductFiltersStatus.loading;
    }
    emit(
      state.copyWith(
        getProductFiltersModel: Map.of(data),
        getProductFiltersStatus: getProductFiltersStatus,
        cashedOrginalBoutique: (event.getWithPagination)
            ? (state.cashedOrginalBoutique)
            : (event.cashedOrginalBoutique),
        isGettingProductListingWithPaginationForAppearProduct:
            event.getWithPagination,
        isGettingProductListingWithPagination: event.getWithPagination,
        //  reRequestProductWithFilters: Map.of(reRequestProductWithFilters),
        getProductListingWithFiltersPaginationModels:
            getProductListingWithFiltersPaginationModels,
        choosedFiltersByUser: Map.of(choosedFilters),
        appliedFiltersByUser: Map.of(appliedFilters),
      ),
    );
    final response = event.boutiqueSlug == "*featured*"
        ? await getFeaturedProductsUseCase(
            GetFeaturedProductsParams(
              limit: 20,
              categorySlugs:
                  (state.currentMainCategoryTaped == "" ||
                      state.currentMainCategoryTaped == null ||
                      state.currentMainCategoryTaped == "Empty")
                  ? null
                  : ['"${state.currentMainCategoryTaped}"'],
              offset: !event.getWithPagination
                  ? null
                  : state.searchWithFilterOffset?[keyWithoutFilter] ?? [],
            ),
          )
        : event.boutiqueSlug == "*recommended*"
        ? await getRecommendProductsUseCase(
            GetRecommendProductsParams(
              limit: 20,
              offset: !event.getWithPagination
                  ? null
                  : state.searchWithFilterOffset?[keyWithoutFilter] ?? [],
              categorySlugs:
                  (state.currentMainCategoryTaped == "" ||
                      state.currentMainCategoryTaped == null ||
                      state.currentMainCategoryTaped == "Empty")
                  ? null
                  : ['"${state.currentMainCategoryTaped}"'],
            ),
          )
        : event.boutiqueSlug == "*flashDeal*"
        ? await getProductsWithFiltersUseCase(
            GetProductsWithFiltersParams(
              flashDeal: true,
              limit: 20,
              categorySlugs:
                  (state.currentMainCategoryTaped == "" ||
                      state.currentMainCategoryTaped == null ||
                      state.currentMainCategoryTaped == "Empty")
                  ? null
                  : ['"${state.currentMainCategoryTaped}"'],
              offset: !event.getWithPagination
                  ? null
                  : state.searchWithFilterOffset?[keyWithoutFilter] ?? [],
            ),
          )
        : await getProductsWithFiltersUseCase(
            GetProductsWithFiltersParams(
              brandSlugs: filters.brands
                  ?.map((e) => '"${e.slug.toString()}"')
                  .toList(),
              categorySlugs: (event.category != null && event.category != "")
                  ? [
                      ...(filters.categories
                              ?.map((e) => '"${e.slug.toString()}"')
                              .toList() ??
                          []),
                      (event.resetChoosedFilters == true &&
                              (event.fromSearch ?? false))
                          ? ""
                          : '"${event.category}"',
                    ]
                  : filters.categories
                        ?.map((e) => '"${e.slug.toString()}"')
                        .toList(),
              boutiqueSlugs: event.fromSearch ?? false
                  ? filters.boutiques
                        ?.map((e) => '"${e.slug.toString()}"')
                        .toList()
                  : ['"${event.boutiqueSlug}"'],
              offset: !event.getWithPagination
                  ? null
                  : state.searchWithFilterOffset?[keyWithoutFilter] ?? [],
              attributes: filters.attributes.isNullOrEmpty
                  ? null
                  : [
                      {
                        '"id"': '"${filters.attributes![0].id}"',
                        '"name"': '"${filters.attributes![0].name}"',
                        '"options"': [
                          ...(filters.attributes![0].options) ?? [],
                        ].map((e) => '"${e}"').toList(),
                      },
                    ],
              colors: ([
                ...filters.colors ?? [],
              ]).map((e) => '"${e.toString()}"').toList(),
              limit: 20,
              prices:
                  (prevAppliedFiltersByUser[key]?.filters?.prices?.maxPrice !=
                          null &&
                      prevAppliedFiltersByUser[key]
                              ?.filters
                              ?.prices
                              ?.minPrice !=
                          null)
                  ? [
                      '"${prevAppliedFiltersByUser[key]?.filters?.prices?.minPrice}-${prevAppliedFiltersByUser[key]?.filters?.prices?.maxPrice}"',
                    ]
                  : null,
              searchText:
                  filters.searchText ??
                  state.appliedFiltersByUser[key]?.filters?.searchText,
            ),
          );

    response.fold(
      (l) {
        Map<String, PaginationModel<product.Products>?>
        getProductListingWithFiltersPaginationModels = Map.of(
          state.getProductListingWithFiltersPaginationModels,
        );
        if (ErrorManager.shouldRetry(
          'GetProductsWithFiltersEvent',
          l.statusCode,
        )) {
          add(
            GetProductsWithFiltersEvent(
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
            ),
          );
          ErrorManager.incrementRetry('GetProductsWithFiltersEvent');
        }
        getProductListingWithFiltersPaginationModels[keyWithoutFilter] =
            getProductListingWithFiltersPaginationModels[keyWithoutFilter]!
                .copyWith(paginationStatus: PaginationStatus.failure);
        emit(
          state.copyWith(
            isGettingProductListingWithPagination: false,
            choosedFiltersByUser: Map.of(prevChoosedFiltersByUser),
            getProductListingWithFiltersPaginationModels: Map.of(
              getProductListingWithFiltersPaginationModels,
            ),
            appliedFiltersByUser: Map.of(prevAppliedFiltersByUser),
          ),
        );
      },
      (r) {
        try {
          FirebaseAnalyticsService.logEventForSession(
            eventName: AnalyticsEventsConst.VIEW_ITEMS_LIST,
            executedEventName:
                AnalyticsButtonsEventNameConst.VIEW_ITEM_LIST_EVENT,
            extraParams: {
              'item_list_id': Random().nextInt(1000000).toString(),
              'items':
                  r.data?.products
                      ?.map(
                        (e) => {
                          'item_id': e.productId.toString(),
                          'item_name': e.name.toString(),
                          'brand': e.brand!.name.toString(),
                          'category': e.categories!
                              .map((e) => e.id.toString())
                              .toList()
                              .toString(),
                        },
                      )
                      .toList()
                      .toString() ??
                  '',
            },
          ).toString();
          String url;
          r.data?.products?.forEach((product) {
            if ((product.syncColorImages?.length ?? 0) > 0) {
              //  .forEach((image) {
              //    if (!image.images.isNullOrEmpty) {

              url = addSuitableWidthAndHeightToImage(
                imageUrl: product.syncColorImages![0].images![0].filePath ?? "",
                ordinalHeight: double.tryParse(
                  product.syncColorImages![0].images![0].originalHeight ?? "0",
                ),
                ordinalWidth: double.tryParse(
                  product.syncColorImages![0].images![0].originalHeight ?? "0",
                ),
                width: 320,
                // the width of the image in the ui
                height: 464,
              );

              prefetchImages(
                url,
                event.context!,
                "productDetailsImages",
                320,
                464,
              );
              //   });
              //   }
              //   });
            } else {
              // product.images?.forEach((image) {
              url = addSuitableWidthAndHeightToImage(
                imageUrl: product.images![0].filePath ?? "",
                ordinalHeight: double.tryParse(
                  product.images![0].originalHeight ?? "0",
                ),
                ordinalWidth: double.tryParse(
                  product.images![0].originalHeight ?? "0",
                ),
                width: 320,
                // the width of the image in the ui
                height: 464,
              );

              prefetchImages(
                url,
                event.context!,
                "productDetailsImages",
                320,
                464,
              );
              //    });
            }
          });
        } catch (e) {}
        if (event.cashedOrginalBoutique &&
            !(event.fromSearch ?? false) &&
            !(event.getWithPagination)) {
          prefsRepository.setPrefechOfProductsForEachBoutiqueInHomePage(
            key,
            jsonEncode(r.data),
          );
        }

        Map<String, List<double>> searchWithFilterOffset = Map.of(
          state.searchWithFilterOffset ?? {},
        );

        if (searchWithFilterOffset.containsKey(keyWithoutFilter)) {
          searchWithFilterOffset[keyWithoutFilter] = r.data?.offset ?? [];
        } else {
          searchWithFilterOffset.addAll({
            keyWithoutFilter: r.data?.offset ?? [],
          });
        }
        Map<String, PaginationModel<product.Products>?>
        getProductListingWithFiltersPaginationModels =
            <String, PaginationModel<product.Products>?>{};

        //  if (state.idForRequest == idForRequest || state.cashedOrginalBoutique) {
        ErrorManager.resetRetry('GetProductsWithFiltersEvent');

        Map<String, filters_model.GetProductFiltersModel?> data = Map.of(
          state.getProductFiltersModel,
        );
        List<filters_model.PriceRange> ranges =
            r.data!.prices?.priceRanges ?? [];
        ranges.removeWhere((element) => element.count == 0);
        if (data[key] == null) {
          data.addAll({key: filters_model.GetProductFiltersModel()});
        }

        if (event.fromNotification ?? false) {
          data[key] = filters_model.GetProductFiltersModel(
            filters: filters_model.Filter(
              totalSize: r.data?.totalSize,
              brands: r.data!.brands,
              attributes: r.data!.attributes,
              prices: r.data!.prices?.copyWith(priceRanges: ranges),
              boutiques: r.data!.boutiques,
              colors: r.data!.colors,
              searchText: filters.searchText,
              categories: r.data!.categories,
            ),
          );
        } else {
          data[key] = filters_model.GetProductFiltersModel(
            filters: filters_model.Filter(
              totalSize: r.data?.totalSize,
              brands: r.data!.brands,
              attributes: r.data!.attributes,
              prices: r.data!.prices?.copyWith(priceRanges: ranges),
              boutiques: r.data!.boutiques,
              colors: r.data!.colors,
              searchText: filters.searchText,
              categories: r.data!.categories,
            ),
          );
        }

        List<Products>? productsResult = r.data?.products ?? [];
        /*if (!(event.fromSearch ?? false) && (filters.colors?.length ?? 0) > 0 ||
          ((state.sizeAndColorFilterinTextToSearch["color"]?.length ?? 0) >
              0)) {
        productsResult = [];
        r.data!.products?.forEach(
          (element) {
            List<product.SyncColorImage>? syncColorImageList =
                element.syncColorImages;
            List<product.Color>? colorsForSync = element.colors;
            if (syncColorImageList?.length == 3 ||
                syncColorImageList?.length == 2) {
              product.SyncColorImage firstImage = syncColorImageList![0];
              product.Color firstColor = colorsForSync![0];
              firstImage = syncColorImageList.removeAt(0);
              firstColor = colorsForSync.removeAt(0);
              syncColorImageList.insert(1, firstImage);
              colorsForSync.insert(1, firstColor);
            } else if ((syncColorImageList?.length ?? 0) > 3) {
              product.SyncColorImage firstImage = syncColorImageList![0];
              product.Color firstColor = colorsForSync![0];
              firstColor = colorsForSync.removeAt(0);
              firstImage = syncColorImageList.removeAt(0);
              colorsForSync.insert(
                  ((syncColorImageList.length ~/ 2) +
                      (syncColorImageList.length % 2 == 0 ? 0 : 1)),
                  firstColor);
              syncColorImageList.insert(
                  ((syncColorImageList.length ~/ 2) +
                      (syncColorImageList.length % 2 == 0 ? 0 : 1)),
                  firstImage);
            }
            productsResult?.add(element.copyWith(
                syncColorImages: syncColorImageList, colors: colorsForSync));
          },
        );
      }*/

        if (event.fromNotification ?? false) {
          PaginationModel<Products>? value = PaginationModel<Products>(
            items: event.getWithPagination
                ? [
                    ...List.of(
                      getProductListingWithFiltersPaginationModels[keyWithoutFilter]
                              ?.items ??
                          [],
                    ),
                    ...productsResult,
                  ]
                : productsResult,
            page: (event.getWithPagination
                ? (getProductListingWithFiltersPaginationModels[keyWithoutFilter]
                              ?.page ??
                          0) +
                      1
                : 2),
            paginationStatus: PaginationStatus.success,
            hasReachedMax:
                (r.data?.products?.length ?? 0) < 20 ||
                r.data?.offset == null ||
                r.data?.offset == "null",
          );
          getProductListingWithFiltersPaginationModels.addAll({
            keyWithoutFilter: value,
          });
        } else {
          getProductListingWithFiltersPaginationModels.addAll({
            keyWithoutFilter: PaginationModel<Products>(
              page: 1,
              offset: "${r.data?.offset}",
              hasReachedMax:
                  (r.data?.products?.length ?? 0) < 20 ||
                  r.data?.offset == null ||
                  r.data?.offset == "null",
              items: event.getWithPagination
                  ? [
                      ...List.of(
                        (state
                                .getProductListingWithFiltersPaginationModels[keyWithoutFilter]
                                ?.items) ??
                            [],
                      ),
                      ...productsResult,
                    ]
                  : productsResult,
              paginationStatus: PaginationStatus.success,
            ),
          });

          state.getProductListingWithFiltersPaginationModels.forEach((
            keys,
            value,
          ) {
            if (keys == keyWithoutFilter) {
              /*getProductListingWithFiltersPaginationModels.addAll({
              keys: value!.copyWith(
                  offset: "${r.data?.offset}",
                  paginationStatus: PaginationStatus.success,
                  page: event.getWithPagination ? value.page + 1 : 2,
                  hasReachedMax: (r.data?.products?.length ?? 0) < kPageSize,
                  items: event.getWithPagination
                      ? [...List.of(value.items), ...productsResult ?? []]
                      : productsResult)
            });*/
            } else {
              getProductListingWithFiltersPaginationModels.addAll({
                keys: value,
              });
            }
          });
        }
        Map<String, GetProductFiltersStatus>? getProductFiltersStatus = Map.of(
          state.getProductFiltersStatus,
        );
        getProductFiltersStatus[key] = GetProductFiltersStatus.success;
        emit(
          state.copyWith(
            getProductFiltersStatus: getProductFiltersStatus,
            searchWithFilterOffset: searchWithFilterOffset,
            getProductListingWithFiltersPaginationModels:
                getProductListingWithFiltersPaginationModels,
            countOfProductExpectedByFiltering: Map.of({
              event.boutiqueSlug: r.data!.totalSize ?? 0,
            }),
            getProductFiltersModel: Map.of(data),
            isGettingProductListingWithPagination: false,
          ),
        );
      },
    );
  }
}
