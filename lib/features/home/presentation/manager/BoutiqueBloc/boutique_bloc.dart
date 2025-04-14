import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:flutter/material.dart';
import 'package:trydos/base_page.dart';
import 'package:trydos/core/data/model/pagination_model.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/blocs/pre_caching_image_bloc/pre_caching_image_bloc.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/home/data/models/get_product_filters_model.dart'
    as filters_model;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/features/home/data/models/get_product_listing_with_filters_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as product;
import 'package:get_it/get_it.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart';
import 'package:trydos/features/home/domain/use_cases/get_product_filters_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_products_with_filters_usecase.dart';

import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_event.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_state.dart';
import 'package:trydos/features/home/presentation/manager/categoryBloc/category_bloc.dart';
import 'package:trydos/features/home/presentation/manager/categoryBloc/category_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/main.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_events.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_executed_event_name.dart';
import 'package:trydos/service/firebase_analytics_service/firebase_analytics_service.dart';

import '../../../../../core/domin/repositories/prefs_repository.dart';
import '../../../data/models/get_product_listing_without_filters_model.dart';

const throttleDuration = Duration(minutes: 2);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

@LazySingleton()
class BoutiqueBloc extends Bloc<BoutiqueEvent, BoutiqueState> {
  BoutiqueBloc(
    this.getProductsWithFiltersUseCase,
    this.getProductFiltersUseCase,
  ) : super(BoutiqueState()) {
    on<BoutiqueEvent>((event, emit) {});

    on<GetProductsWithFiltersEvent>(_onGetProductsWithFiltersEvent,
        transformer: restartable());
    on<ResetAllSelectedAppliedFilterEvent>(
      _onResetAllSelectedAppliedFilterEvent,
    );
    on<AddIsExpandedForLidtingPageEvent>(
      _onAddIsExpandedForLidtingPageEvent,
    );
    on<AddPrefAppliedFilterForExtendFilterEvent>(
      _onAddPrefAppliedFilterForExtendFilterEvent,
    );
    on<GetProductWithFiltersWithoutCancelingPreviousEvents>(
        _onGetWithProductFiltersWithoutCancelingPreviousEvents);
    on<GetProductFiltersEvent>(_onGetProductFiltersEvent,
        transformer: restartable());
    on<ChangeSelectedFiltersEvent>(_onChangeSelectedFiltersEvent);

    on<ChangeAppliedFiltersEvent>(_onChangeAppliedFiltersEvent);
    on<IscashedOreiginBotiqueEvent>(
      _onIscashedOreiginBotiqueEvent,
    );

    on<GetProductsWithFiltersWithPrefetchForFiveFiltersEvent>(
      _onGetProductsWithFiltersWithPrefetchForFiveFiltersEvent,
    );

    on<AddSizeAndColorFilterinTextToSearchEvent>(
      _onAddSizeAndColorFilterinTextToSearchEvent,
    );
  }
  final GetProductsWithFiltersUseCase getProductsWithFiltersUseCase;
  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  final GetProductFiltersUseCase getProductFiltersUseCase;
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
            boutiqueSlug: boutiqueSlug,
            category: categorySlug,
            attribute: null,
            filterSlug: filter?.colors![i] ?? ""));
        if (countOfPreFetchForFiveFilters == 6) {
          break;
        }
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
        if (countOfPreFetchForFiveFilters == 6) {
          break;
        }
      }
    }
  }

  FutureOr<void> _onAddSizeAndColorFilterinTextToSearchEvent(
      AddSizeAndColorFilterinTextToSearchEvent event,
      Emitter<BoutiqueState> emit) async {
    emit(state.copyWith(
        sizeAndColorFilterinTextToSearch:
            event.sizeAndColorFilterinTextToSearch));
  }

  FutureOr<void> _onGetProductsWithFiltersWithPrefetchForFiveFiltersEvent(
      GetProductsWithFiltersWithPrefetchForFiveFiltersEvent event,
      Emitter<BoutiqueState> emit) async {
    String key = '${event.boutiqueSlug}' +
        '${event.filterSlug}' +
        '${(event.category ?? '')}';
    List<String> keyForFirstFiveFilterList =
        prefsRepository.getFiveFilterForEachBoutiqueHasPrefechInHomePage() ??
            [];
    if (keyForFirstFiveFilterList.contains(key)) {
      return;
    }

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
      offset: [],
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
      print(
          "###########################...............11111111111111111111111111111111111111111${key}111111111111111111111111111111111${jsonEncode(r.data)}+++++++++++");

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
      IscashedOreiginBotiqueEvent event, Emitter<BoutiqueState> emit) async {
    emit(state.copyWith(cashedOrginalBoutique: event.iscashedOreiginBotique));
  }

  FutureOr<void> _onChangeAppliedFiltersEvent(
      ChangeAppliedFiltersEvent event, Emitter<BoutiqueState> emit) {
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
    if (event.resetAppliedFilters) {
      GetIt.I<CategoryBloc>()
          .add(ReplyFromGeminiEvent(theReplyFromGemini: "", fromSearch: true));
      GetIt.I<CategoryBloc>()
          .add(ReplyFromGeminiEvent(theReplyFromGemini: "", fromSearch: false));
    }
    emit(
      state.copyWith(
          appliedFiltersByUser: Map.of(appliedFilters),
          isExpandedForListingPage: event.isExpandedForListing),
    );
  }

  FutureOr<void> _onAddIsExpandedForLidtingPageEvent(
      AddIsExpandedForLidtingPageEvent event,
      Emitter<BoutiqueState> emit) async {
    emit(state.copyWith(isExpandedForListingPage: event.isExpandedForLidting));
  }

  FutureOr<void> _onChangeSelectedFiltersEvent(
      ChangeSelectedFiltersEvent event, Emitter<BoutiqueState> emit) {
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
    if (event.resetChoosedFilters) {
      GetIt.I<CategoryBloc>().add(ReplyFromGeminiEvent(
          theReplyFromGemini: "", fromSearch: event.fromHomePageSearch));
    }

    emit(state.copyWith(
      choosedFiltersByUser: Map.of(choosedFilters),
      isExpandedForListingPage: event.isExpandedForListing,
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

  FutureOr<void> _onGetProductFiltersEvent(
      GetProductFiltersEvent event, Emitter<BoutiqueState> emit) async {
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
    print(
        "2222222222222222222222222222222222222222222223333333333333333333333333${filters.searchText ?? event.searchText}");
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
      /*  if (event.getProductsFilterPreFetch &&
          !event.fromHomePageSearch &&
          event.cashedOrginalBoutique) {
        PrefetchProductsForFirstFiveFilter(
            filter: r.filters,
            boutiqueSlug: event.boutiqueSlug,
            categorySlug: event.category);
      }*/

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
      Emitter<BoutiqueState> emit) async {
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

    emit(state.copyWith(boutiquesThatDidPrefetch: boutiquesThatDidPrefetch));

    final response =
        await getProductsWithFiltersUseCase(GetProductsWithFiltersParams(
      scroll_id: null,
      offset: [],
      limit: 10,
      searchText: null,
      brandSlugs: null,
      categorySlugs: null,
      boutiqueSlugs: ['"${event.boutiqueSlug}"'],
      attributes: null,
      colors: null,
      prices: null,
    ));
    response.fold((l) {
      Map<String, bool> boutiquesThatDidPrefetch =
          Map.of(state.boutiquesThatDidPrefetch);
      boutiquesThatDidPrefetch[key] = false;

      emit(state.copyWith(boutiquesThatDidPrefetch: boutiquesThatDidPrefetch));
    }, (r) async {
      prefsRepository.setPrefechOfProductsForEachBoutiqueInHomePage(
          key, jsonEncode(r.data));
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
          height: 70,
        );
        prefetchImages(
          url,
          event.context,
        );
        category.subCategories?.forEach((sub) {
          url = addSuitableWidthAndHeightToImage(
            imageUrl: sub.mostViewedProductThumbnail!.filePath!,
            width: 50,
            height: 50,
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

      List<filters_model.PriceRange> ranges = r.data?.prices?.priceRanges ?? [];
      ranges.removeWhere((element) => element.count == 0);
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
  }) {
    GetIt.I<PreCachingImageBloc>().add(CacheSvgEvent(
        svgUrl: imageUrl,
        width: ordinalWidth,
        height: ordinalHeight,
        context: context));
  }

  FutureOr<void> _onAddPrefAppliedFilterForExtendFilterEvent(
      AddPrefAppliedFilterForExtendFilterEvent event,
      Emitter<BoutiqueState> emit) {
    emit(state.copyWith(
        prefAppliedFilterForExtendFilter: event.prefAppliedFilter));
  }

  FutureOr<void> _onResetAllSelectedAppliedFilterEvent(
      ResetAllSelectedAppliedFilterEvent event,
      Emitter<BoutiqueState> emit) async {
    GetIt.I<CategoryBloc>()
        .add(ReplyFromGeminiEvent(theReplyFromGemini: "", fromSearch: true));
    GetIt.I<CategoryBloc>()
        .add(ReplyFromGeminiEvent(theReplyFromGemini: "", fromSearch: false));
    emit(state.copyWith(
        choosedFiltersByUser: {},
        appliedFiltersByUser: {},
        prefAppliedFilterForExtendFilter: filters_model.Filter()));
  }

  FutureOr<void> _onGetProductsWithFiltersEvent(
      GetProductsWithFiltersEvent event, Emitter<BoutiqueState> emit) async {
    Map<String, PaginationModel<product.Products>?>
        getProductListingWithFiltersPaginationModels =
        Map.of(state.getProductListingWithFiltersPaginationModels);

    Map<String, filters_model.GetProductFiltersModel?> data =
        Map.of(state.getProductFiltersModel);
    Map<String, filters_model.GetProductFiltersModel?> dataForFirstFiveFilter =
        {};
    Map<String, PaginationModel<product.Products>?>
        getProductListingWithFiltersForFirstFiveFilter = {};
    String keyWithoutFilter = '${event.boutiqueSlug}' +
        '${(event.getWithPagination) ? ((state.cashedOrginalBoutique) ? 'withoutFilter' : "") : ((event.cashedOrginalBoutique) ? 'withoutFilter' : "")}' +
        '${(event.category ?? '')}';
    String key = '${event.boutiqueSlug}' + '${(event.category ?? '')}';
    if (event.cashedOrginalBoutique &&
        !(event.fromSearch ?? false) &&
        !(event.getWithPagination)) {
      List<String> keyForFirstFiveFilterList =
          prefsRepository.getFiveFilterForEachBoutiqueHasPrefechInHomePage() ??
              [];
      keyForFirstFiveFilterList
          .removeWhere((element) => !element.contains(event.boutiqueSlug));

      for (var i = 0; i < keyForFirstFiveFilterList.length; i++) {
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
                        10,
                items: getProductListingWithFiltersForFirstFiveFilterModel
                        .products ??
                    [],
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
      ));
      if (!data.containsValue(key)) {
        data.addAll({key: filters_model.GetProductFiltersModel()});
      }
      if (!getProductListingWithFiltersPaginationModels.containsValue(key)) {
        getProductListingWithFiltersPaginationModels
            .addAll({key: PaginationModel.init()});
      }
      data.removeWhere((key, value) =>
          !(key.contains(event.boutiqueSlug)) && !(key.contains("search")));
      getProductListingWithFiltersPaginationModels.removeWhere((key, value) =>
          !(key.contains(event.boutiqueSlug)) && !(key.contains("search")));
      final responseFromSharedPrefrence = jsonDecode(
          prefsRepository.getPrefechOfProductsForEachBoutiqueInHomePage(key) ??
              "{}");

      DataGetProductListingWithFiltersModel getProductListingWithFiltersModel =
          responseFromSharedPrefrence == {}
              ? DataGetProductListingWithFiltersModel()
              : DataGetProductListingWithFiltersModel.fromJson(
                  responseFromSharedPrefrence);

      getProductListingWithFiltersPaginationModels[keyWithoutFilter] =
          PaginationModel<product.Products>(
              hasReachedMax:
                  (getProductListingWithFiltersModel.products?.length ?? 0) <
                      10,
              items: getProductListingWithFiltersModel.products ?? [],
              page: 1,
              paginationStatus: PaginationStatus.success);

      List<filters_model.PriceRange> ranges =
          getProductListingWithFiltersModel.prices?.priceRanges ?? [];
      ranges.removeWhere((element) => element.count == 0);
      data[key] = filters_model.GetProductFiltersModel(
          filters: filters_model.Filter(
        totalSize: getProductListingWithFiltersModel.totalSize,
        brands: getProductListingWithFiltersModel.brands,
        attributes: getProductListingWithFiltersModel.attributes,
        prices: getProductListingWithFiltersModel.prices
            ?.copyWith(priceRanges: ranges),
        boutiques: getProductListingWithFiltersModel.boutiques,
        colors: getProductListingWithFiltersModel.colors,
        searchText: null,
        categories: getProductListingWithFiltersModel.categories,
      ));
    }
    //  filters_model.Filter filter =
    //    state.getProductFiltersModel[key]?.filters ?? filters_model.Filter();
    /* if (!(event.fromSearch ??
        false || event.getWithPagination || !event.cashedOrginalBoutique)) {
      PrefetchProductsForFirstFiveFilter(
          boutiqueSlug: event.boutiqueSlug,
          categorySlug: event.category,
          filter: filter);
    }*/

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
    List<String>? optionsForAnalytics =
        filters.attributes.isNullOrEmpty ? [] : filters.attributes?[0].options;
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
            : state.searchWithFilterOffset?[keyWithoutFilter] ?? [],
        attributes: filters.attributes.isNullOrEmpty
            ? null
            : [
                {
                  '"id"': '"${filters.attributes![0].id}"',
                  '"name"': '"${filters.attributes![0].name}"',
                  '"options"': [
                    ...(filters.attributes![0].options) ?? [],
                    ...(state.sizeAndColorFilterinTextToSearch!["size"]
                                .isNullOrEmpty
                            ? []
                            : state
                                .sizeAndColorFilterinTextToSearch!["size"]) ??
                        []
                  ]
                      .map(
                        (e) => '"${e}"',
                      )
                      .toList(),
                }
              ],
        colors: ([
          ...filters.colors ?? [],
          ...(state.sizeAndColorFilterinTextToSearch!["color"].isNullOrEmpty
                  ? []
                  : state.sizeAndColorFilterinTextToSearch!["color"]) ??
              []
        ]).map((e) => '"${e.toString()}"').toList(),
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
      if (event.cashedOrginalBoutique &&
          !(event.fromSearch ?? false) &&
          !(event.getWithPagination)) {
        prefsRepository.setPrefechOfProductsForEachBoutiqueInHomePage(
            key, jsonEncode(r.data));
      }
      Map<String, List<double>> searchWithFilterOffset =
          Map.of(state.searchWithFilterOffset ?? {});

      if (searchWithFilterOffset.containsKey(keyWithoutFilter)) {
        searchWithFilterOffset[keyWithoutFilter] = r.data?.offset ?? [];
      } else {
        searchWithFilterOffset.addAll({keyWithoutFilter: r.data?.offset ?? []});
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
        ));
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
      emit(state.copyWith(
        getProductFiltersStatus: getProductFiltersStatus,
        searchWithFilterOffset: searchWithFilterOffset,
        getProductListingWithFiltersPaginationModels:
            getProductListingWithFiltersPaginationModels,
        countOfProductExpectedByFiltering:
            Map.of({event.boutiqueSlug: r.data!.totalSize ?? 0}),
        getProductFiltersModel: Map.of(data),
        isGettingProductListingWithPagination: false,
      ));
    });
  }
}
