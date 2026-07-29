import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:trydos/features/home/data/models/get_product_filters_model.dart'
    show Boutique;
import '../../../data/models/get_product_filters_model.dart' as get_filters;
import 'package:json_annotation/json_annotation.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as product;
import '../../../../../core/data/model/pagination_model.dart';

enum GetProductFiltersStatus { init, loading, success, failure }

/// حالة بحث المقارنة لعمود واحد.
enum SearchProductsForCompareStatus { init, loading, success, failure }

enum GetFiltersForNavigatorFromLinkToListingPageStatus {
  init,
  loading,
  success,
  failure
}

@JsonSerializable(explicitToJson: true)
@immutable
class BoutiqueState extends Equatable {
  const BoutiqueState({
    this.sizeAndColorFilterinTextToSearch = const {},
    // this.getProductListingWithFiltersPaginationWithPrefetchModels = const {},
    //this.getProductFiltersWithPrefetchModel = const {},
    this.searchWithFilterOffset,
    this.getProductFiltersStatus = const {},
    this.isGettingProductListingWithPaginationForAppearProduct = false,
    this.cashedOrginalBoutique = false,
    this.isExpandedForListingPage = false,
    this.finishGetAllFilter = false,
    this.getProductListingWithFiltersPaginationModels = const {},
    this.getProductFiltersModel = const {},
    this.getFiltersForNavigatorFromLinkToListingPageStatus,
    this.prefAppliedFilterForExtendFilter,
    this.boutiquesToNavigatorFromLink,
    this.isGettingProductListingWithPagination = false,
    this.choosedFiltersByUser = const {},
    this.appliedFiltersByUser = const {},
    this.filterOffset = 1,
    this.currentMainCategoryTaped,
    this.boutiquesThatDidPrefetch = const {},
    this.countOfProductExpectedByFiltering,
        this.suggestion,
    this.sortKey = "",
    this.compareSearchResults = const {},
    this.compareSearchStatus = const {},
  });

  /// نتائج بحث صفحة المقارنة، مفتاحها رقم العمود (0 و1).
  ///
  /// منفصلة تماماً عن قوائم المنتجات القائمة حتى لا يتداخل بحث المقارنة مع
  /// نتائج صفحة القوائم أو البوتيك.
  final Map<int, List<product.Products>> compareSearchResults;

  /// حالة بحث كل عمود على حدة — فالعمودان يبحثان مستقلَّين.
  final Map<int, SearchProductsForCompareStatus> compareSearchStatus;
  final Map<String, List<String>> sizeAndColorFilterinTextToSearch;

  /// Currently selected sort key for the listing page (e.g. best_selling,
  /// newest, price_asc, name_desc). Empty = default relevance order.
  /// Reset to "" when the user leaves the listing page.
  final String sortKey;

  ///final Map<String, PaginationModel<product.Products>?>
//getProductListingWithFiltersPaginationWithPrefetchModels;
  final Map<String, int>? countOfProductExpectedByFiltering;
  final get_filters.Filter? prefAppliedFilterForExtendFilter;
  final Map<String, bool> boutiquesThatDidPrefetch;
  final Map<String, GetProductFiltersStatus> getProductFiltersStatus;

  final Map<String, get_filters.GetProductFiltersModel?> appliedFiltersByUser;
  final Map<String, get_filters.GetProductFiltersModel?> choosedFiltersByUser;
  final bool cashedOrginalBoutique;
  final GetFiltersForNavigatorFromLinkToListingPageStatus?
      getFiltersForNavigatorFromLinkToListingPageStatus;
  final List<Boutique>? boutiquesToNavigatorFromLink;
  final bool finishGetAllFilter;
  final bool isGettingProductListingWithPagination;

  final bool? isExpandedForListingPage;
  final String? currentMainCategoryTaped;
  final Map<String, PaginationModel<product.Products>?>
      getProductListingWithFiltersPaginationModels;
  final bool isGettingProductListingWithPaginationForAppearProduct;
  // final Map<String, get_filters.GetProductFiltersModel?>
  //   getProductFiltersWithPrefetchModel;
  final int? filterOffset;
  final Map<String, List<double>>? searchWithFilterOffset;
  final Map<String, get_filters.GetProductFiltersModel?> getProductFiltersModel;
    final String? suggestion;

  @override
  List<Object?> get props => [
        sizeAndColorFilterinTextToSearch,
        countOfProductExpectedByFiltering,
        boutiquesToNavigatorFromLink,
        //   getProductFiltersWithPrefetchModel,
        prefAppliedFilterForExtendFilter,
        cashedOrginalBoutique,
        isExpandedForListingPage,
        currentMainCategoryTaped,
        getFiltersForNavigatorFromLinkToListingPageStatus,
        filterOffset,
        getProductFiltersStatus,
        finishGetAllFilter,
        getProductFiltersModel,
        isGettingProductListingWithPaginationForAppearProduct,
        getProductListingWithFiltersPaginationModels,
        suggestion,
        boutiquesThatDidPrefetch,
        isGettingProductListingWithPagination,
        appliedFiltersByUser,
        choosedFiltersByUser,
        sortKey,
        // كان غائباً عن props: أي انبعاث يغيّر عامل الترقيم وحده كان يُسقَط
        // بصمت. يُبعث اليوم دائماً مرفقاً بحقول أخرى فلم يظهر أثره، لكنه
        // يبقى فخّاً لأول انبعاث مستقبلي يمسّه منفرداً.
        searchWithFilterOffset,
        compareSearchResults,
        compareSearchStatus,
        //   getProductListingWithFiltersPaginationWithPrefetchModels,
      ];

  BoutiqueState copyWith({
    final Map<String, List<String>>? sizeAndColorFilterinTextToSearch,
    //final Map<String, PaginationModel<product.Products>?>?
    //    getProductListingWithFiltersPaginationWithPrefetchModels,
    final Map<String, GetProductFiltersStatus>? getProductFiltersStatus,
    Map<String, int>? countOfProductExpectedByFiltering,
    final Map<String, get_filters.GetProductFiltersModel?>?
        appliedFiltersByUser,
    final List<Boutique>? boutiquesToNavigatorFromLink,
    final bool? isGettingProductListingWithPaginationForAppearProduct,
    final Map<String, get_filters.GetProductFiltersModel?>?
        choosedFiltersByUser,
    bool? isExpandedForListingPage,
    final String? currentMainCategoryTaped,
    final bool? isGettingProductListingWithPagination,
    Map<String, PaginationModel<product.Products>?>?
        getProductListingWithFiltersPaginationModels,
    final Map<String, bool>? boutiquesThatDidPrefetch,
    final GetFiltersForNavigatorFromLinkToListingPageStatus?
        getFiltersForNavigatorFromLinkToListingPageStatus,
    final Map<String, get_filters.GetProductFiltersModel?>?
        getProductFiltersModel,
    get_filters.Filter? prefAppliedFilterForExtendFilter,
    bool? cashedOrginalBoutique,
    final bool? finishGetAllFilter,
    final int? filterOffset,
    //  final Map<String, get_filters.GetProductFiltersModel?>?
    //  getProductFiltersWithPrefetchModel,
    final Map<String, List<double>>? searchWithFilterOffset,
        final String? suggestion,
    final String? sortKey,
    final Map<int, List<product.Products>>? compareSearchResults,
    final Map<int, SearchProductsForCompareStatus>? compareSearchStatus,
  }) {
    return BoutiqueState(
        sizeAndColorFilterinTextToSearch: sizeAndColorFilterinTextToSearch ??
            this.sizeAndColorFilterinTextToSearch,
        //  getProductListingWithFiltersPaginationWithPrefetchModels:
        //    getProductListingWithFiltersPaginationWithPrefetchModels ??
        //      this.getProductListingWithFiltersPaginationWithPrefetchModels,
        getProductFiltersModel:
            getProductFiltersModel ?? this.getProductFiltersModel,
        prefAppliedFilterForExtendFilter: prefAppliedFilterForExtendFilter ??
            this.prefAppliedFilterForExtendFilter,
        boutiquesThatDidPrefetch:
            boutiquesThatDidPrefetch ?? this.boutiquesThatDidPrefetch,
        countOfProductExpectedByFiltering: countOfProductExpectedByFiltering ??
            this.countOfProductExpectedByFiltering,
        searchWithFilterOffset:
            searchWithFilterOffset ?? this.searchWithFilterOffset,
        choosedFiltersByUser: choosedFiltersByUser ?? this.choosedFiltersByUser,
        isExpandedForListingPage:
            isExpandedForListingPage ?? this.isExpandedForListingPage,
        currentMainCategoryTaped:
            currentMainCategoryTaped ?? this.currentMainCategoryTaped,
        getFiltersForNavigatorFromLinkToListingPageStatus:
            getFiltersForNavigatorFromLinkToListingPageStatus ??
                this.getFiltersForNavigatorFromLinkToListingPageStatus,
        appliedFiltersByUser: appliedFiltersByUser ?? this.appliedFiltersByUser,
        boutiquesToNavigatorFromLink:
            boutiquesToNavigatorFromLink ?? this.boutiquesToNavigatorFromLink,
        isGettingProductListingWithPagination:
            isGettingProductListingWithPagination ??
                this.isGettingProductListingWithPagination,
        finishGetAllFilter: finishGetAllFilter ?? this.finishGetAllFilter,
        cashedOrginalBoutique:
            cashedOrginalBoutique ?? this.cashedOrginalBoutique,
        getProductFiltersStatus:
            getProductFiltersStatus ?? this.getProductFiltersStatus,
        // getProductFiltersWithPrefetchModel:
//getProductFiltersWithPrefetchModel ??
        //        this.getProductFiltersWithPrefetchModel,
        getProductListingWithFiltersPaginationModels:
            getProductListingWithFiltersPaginationModels ??
                this.getProductListingWithFiltersPaginationModels,
        isGettingProductListingWithPaginationForAppearProduct:
            isGettingProductListingWithPaginationForAppearProduct ??
                this.isGettingProductListingWithPaginationForAppearProduct,
        suggestion: suggestion ?? this.suggestion,
        sortKey: sortKey ?? this.sortKey,
        compareSearchResults: compareSearchResults ?? this.compareSearchResults,
        compareSearchStatus: compareSearchStatus ?? this.compareSearchStatus,
        filterOffset: filterOffset ?? this.filterOffset);
  }
}
