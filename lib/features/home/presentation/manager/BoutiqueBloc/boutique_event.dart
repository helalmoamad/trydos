import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:trydos/features/home/data/models/get_product_filters_model.dart';

abstract class BoutiqueEvent extends Equatable {
  const BoutiqueEvent();
}

class GetFiltersEvent extends BoutiqueEvent {
  const GetFiltersEvent(
      {this.category,
      this.fromHomePageSearch = false,
      this.getWithoutFilter = false,
      required this.boutiqueSlug,
      this.searchText,
      this.fromExpandPage = false,
      this.cashedOrginalBoutique = false,
      this.getProductsFilterPreFetch = false,
      this.forceUpdate = false,
      this.resetAppliesFilters = false,
      this.filtersChoosedByUser});

  final String boutiqueSlug;

  final bool cashedOrginalBoutique;
  final bool getProductsFilterPreFetch;
  final String? searchText;
  final bool getWithoutFilter;
  final String? category;
  final bool forceUpdate;

  final bool fromHomePageSearch;
  final bool fromExpandPage;
  final bool resetAppliesFilters;
  final GetProductFiltersModel? filtersChoosedByUser;

  @override
  // TODO: implement props
  List<Object?> get props => [category, boutiqueSlug, forceUpdate];
}

class GetFiltersWithPaginatioEvent extends BoutiqueEvent {
  const GetFiltersWithPaginatioEvent(
      {this.category,
      this.fromHomePageSearch = false,
      this.getWithoutFilter = false,
      required this.boutiqueSlug,
      this.searchText,
      this.fromExpandPage = false,
      this.cashedOrginalBoutique = false,
      this.getProductsFilterPreFetch = false,
      this.forceUpdate = false,
      this.resetAppliesFilters = false,
      this.filtersChoosedByUser});

  final String boutiqueSlug;

  final bool cashedOrginalBoutique;
  final bool getProductsFilterPreFetch;
  final String? searchText;
  final bool getWithoutFilter;
  final String? category;
  final bool forceUpdate;

  final bool fromHomePageSearch;
  final bool fromExpandPage;
  final bool resetAppliesFilters;
  final GetProductFiltersModel? filtersChoosedByUser;

  @override
  // TODO: implement props
  List<Object?> get props => [category, boutiqueSlug, forceUpdate];
}

class GetProductWithFiltersWithoutCancelingPreviousEvents
    extends BoutiqueEvent {
  const GetProductWithFiltersWithoutCancelingPreviousEvents(
      {this.category,
      this.fromHomePageSearch = false,
      required this.boutiqueSlug,
      required this.context,
      this.getWithoutFilter = false,
      this.indexOfCategory = 0,
      this.searchText,
      required this.categorySlugs,
      this.fromExpandPage = false,
      this.cashedOrginalBoutique = false,
      this.forceUpdate = false,
      this.resetAppliesFilters = false,
      this.filtersChoosedByUser});

  final String boutiqueSlug;
  final bool cashedOrginalBoutique;
  final bool getWithoutFilter;
  final String? searchText;
  final String? category;
  final int indexOfCategory;
  final bool forceUpdate;
  final BuildContext context;
  final List<String> categorySlugs;
  final bool fromHomePageSearch;
  final bool fromExpandPage;
  final bool resetAppliesFilters;
  final GetProductFiltersModel? filtersChoosedByUser;

  @override
  // TODO: implement props
  List<Object?> get props => [category, boutiqueSlug, forceUpdate];
}

class ChangeSelectedFiltersEvent extends BoutiqueEvent {
  final GetProductFiltersModel? filtersChoosedByUser;
  final bool resetChoosedFilters;
  final bool requestToUpdateFilters;
  final bool fromHomePageSearch;
  final String boutiqueSlug;
  final String? category;
  final bool? isExpandedForListing;

  ChangeSelectedFiltersEvent({
    this.filtersChoosedByUser,
    required this.boutiqueSlug,
    this.resetChoosedFilters = false,
    this.fromHomePageSearch = false,
    this.requestToUpdateFilters = true,
    this.category,
    this.isExpandedForListing,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [
        filtersChoosedByUser,
        boutiqueSlug,
        resetChoosedFilters,
        category,
        isExpandedForListing
      ];
}

class ChangeAppliedFiltersEvent extends BoutiqueEvent {
  final GetProductFiltersModel? filtersAppliedByUser;
  final bool resetAppliedFilters;
  final String boutiqueSlug;
  final String? category;
  final bool? isExpandedForListing;
  ChangeAppliedFiltersEvent({
    this.filtersAppliedByUser,
    required this.boutiqueSlug,
    this.resetAppliedFilters = false,
    this.category,
    this.isExpandedForListing,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [
        filtersAppliedByUser,
        boutiqueSlug,
        resetAppliedFilters,
        category,
        isExpandedForListing
      ];
}

class GetProductsWithFiltersEvent extends BoutiqueEvent {
  final String? category;
  final String? searchText;
  final int offset;
  final bool getWithoutFilter;
  final int? limit;
  final String boutiqueSlug;
  final bool cashedOrginalBoutique;
  final bool? fromSearch;
  final BuildContext? context;
  final bool? fromNotification;
  final bool? fromChoosed;
  final bool resetChoosedFilters;
  final bool getWithPagination;

  GetProductsWithFiltersEvent(
      {required this.boutiqueSlug,
      this.getWithoutFilter = false,
      this.context = null,
      this.resetChoosedFilters = true,
      this.searchText,
      this.fromNotification = false,
      this.cashedOrginalBoutique = false,
      this.getWithPagination = false,
      this.fromChoosed = false,
      this.fromSearch,
      required this.offset,
      this.limit,
      this.category});

  @override
  // TODO: implement props
  List<Object?> get props =>
      [category, searchText, offset, limit, getWithPagination, boutiqueSlug];
}

class GetProductsWithFiltersUsingPaginationEvent extends BoutiqueEvent {
  final String? category;
  final String? searchText;
  final int offset;
  final bool getWithoutFilter;
  final int? limit;
  final String boutiqueSlug;
  final bool cashedOrginalBoutique;
  final bool? fromSearch;
  final bool? fromChoosed;
  final bool resetChoosedFilters;

  GetProductsWithFiltersUsingPaginationEvent(
      {required this.boutiqueSlug,
      this.getWithoutFilter = false,
      this.resetChoosedFilters = true,
      this.searchText,
      this.cashedOrginalBoutique = false,
      this.fromChoosed = false,
      this.fromSearch,
      required this.offset,
      this.limit,
      this.category});

  @override
  // TODO: implement props
  List<Object?> get props =>
      [category, searchText, offset, limit, boutiqueSlug];
}

class AddSizeAndColorFilterinTextToSearchEvent extends BoutiqueEvent {
  final Map<String, List<String>> sizeAndColorFilterinTextToSearch;
  AddSizeAndColorFilterinTextToSearchEvent(
      {required this.sizeAndColorFilterinTextToSearch});

  @override
  // TODO: implement props
  List<Object?> get props => [sizeAndColorFilterinTextToSearch];
}

class AddIsExpandedForLidtingPageEvent extends BoutiqueEvent {
  final bool isExpandedForLidting;

  AddIsExpandedForLidtingPageEvent({required this.isExpandedForLidting});

  @override
  List<Object?> get props => [];
}

class IscashedOreiginBotiqueEvent extends BoutiqueEvent {
  final bool iscashedOreiginBotique;

  const IscashedOreiginBotiqueEvent({required this.iscashedOreiginBotique});

  @override
  List<Object?> get props => [iscashedOreiginBotique];
}

class AddPrefAppliedFilterForExtendFilterEvent extends BoutiqueEvent {
  final Filter? prefAppliedFilter;

  AddPrefAppliedFilterForExtendFilterEvent({
    this.prefAppliedFilter,
  });

  @override
  List<Object?> get props => [prefAppliedFilter];
}

class ResetAllSelectedAppliedFilterEvent extends BoutiqueEvent {
  ResetAllSelectedAppliedFilterEvent();

  @override
  List<Object?> get props => [];
}

class AddIsExpandedForListingPageEvent extends BoutiqueEvent {
  final bool isExpandedForLidting;

  AddIsExpandedForListingPageEvent({required this.isExpandedForLidting});

  @override
  List<Object?> get props => [];
}

class GetProductsWithFiltersWithPrefetchForFiveFiltersEvent
    extends BoutiqueEvent {
  final String? category;
  final String filterSlug;
  final String filterType;
  final Attribute? attribute;
  final String boutiqueSlug;

  GetProductsWithFiltersWithPrefetchForFiveFiltersEvent(
      {required this.boutiqueSlug,
      required this.filterType,
      this.attribute,
      required this.filterSlug,
      this.category});

  @override
  // TODO: implement props
  List<Object?> get props => [category, boutiqueSlug, filterSlug];
}
