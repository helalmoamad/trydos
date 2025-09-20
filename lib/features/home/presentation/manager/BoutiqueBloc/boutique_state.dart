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
  });
  final Map<String, List<String>> sizeAndColorFilterinTextToSearch;

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
        boutiquesThatDidPrefetch,
        isGettingProductListingWithPagination,
        appliedFiltersByUser,
        choosedFiltersByUser,
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
        filterOffset: filterOffset ?? this.filterOffset);
  }
}
