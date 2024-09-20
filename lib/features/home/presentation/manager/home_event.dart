import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:trydos/features/home/data/models/get_product_detail_without_related_products_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_sheet_bottom_bar.dart';

import '../../data/models/get_product_filters_model.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
}

class GetStartingSettingsEvent extends HomeEvent {
  const GetStartingSettingsEvent();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class GetMainCategoriesEvent extends HomeEvent {
  const GetMainCategoriesEvent();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class GetProductFiltersEvent extends HomeEvent {
  const GetProductFiltersEvent(
      {this.category,
      this.fromHomePageSearch = false,
      required this.boutiqueSlug,
      this.searchText,
      this.fromExpandPage = false,
      this.cashedOrginalBoutique = false,
      this.forceUpdate = false,
      this.resetAppliesFilters = false,
      this.filtersChoosedByUser});

  final String boutiqueSlug;
  final bool cashedOrginalBoutique;
  final String? searchText;
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

class GetProductFiltersWithoutCancelingPreviousEvents extends HomeEvent {
  const GetProductFiltersWithoutCancelingPreviousEvents(
      {this.category,
      this.fromHomePageSearch = false,
      required this.boutiqueSlug,
      required this.context,
      this.searchText,
      this.fromExpandPage = false,
      this.cashedOrginalBoutique = false,
      this.forceUpdate = false,
      this.resetAppliesFilters = false,
      this.filtersChoosedByUser});

  final String boutiqueSlug;
  final bool cashedOrginalBoutique;
  final String? searchText;
  final String? category;
  final bool forceUpdate;
  final BuildContext context;
  final bool fromHomePageSearch;
  final bool fromExpandPage;
  final bool resetAppliesFilters;
  final GetProductFiltersModel? filtersChoosedByUser;

  @override
  // TODO: implement props
  List<Object?> get props => [category, boutiqueSlug, forceUpdate];
}

class AddCurrentSelectedColorEvent extends HomeEvent {
  final int currentSelectedColor;
  final String productId;

  const AddCurrentSelectedColorEvent(
      {required this.currentSelectedColor, required this.productId});

  @override
  // TODO: implement props
  List<Object?> get props => [currentSelectedColor, productId];
}

class GetCommentForProductEvent extends HomeEvent {
  final String productId;

  const GetCommentForProductEvent({required this.productId});

  @override
  // TODO: implement props
  List<Object?> get props => [productId];
}

class GetHomeBoutiqesEvent extends HomeEvent {
  // final bool getWithPagination;
  final String offset;
  final bool getWithPagination;
  final String categorySlug;
  final BuildContext context;

  const GetHomeBoutiqesEvent({
    required this.offset,
    required this.context,
    this.getWithPagination = false,
    required this.categorySlug,
  }
      //  {this.getWithPagination = false}
      );

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class GetProductDatailsWithoutRelatedProductsEvent extends HomeEvent {
  final String? productId;

  const GetProductDatailsWithoutRelatedProductsEvent({this.productId});

  @override
  // TODO: implement props
  List<Object?> get props => [productId];
}

class GetProductsWithoutFiltersEvent extends HomeEvent {
  final String? category;
  final int offset;
  final int? limit;
  final String boutiqueSlug;
  final bool getWithPagination;

  GetProductsWithoutFiltersEvent(
      {required this.boutiqueSlug,
      this.getWithPagination = false,
      required this.offset,
      this.limit,
      this.category});

  @override
  // TODO: implement props
  List<Object?> get props =>
      [category, getWithPagination, offset, limit, boutiqueSlug];
}

class ChangeSelectedFiltersEvent extends HomeEvent {
  final GetProductFiltersModel? filtersChoosedByUser;
  final bool resetChoosedFilters;
  final bool requestToUpdateFilters;
  final bool fromHomePageSearch;
  final String boutiqueSlug;
  final String? category;

  ChangeSelectedFiltersEvent({
    this.filtersChoosedByUser,
    required this.boutiqueSlug,
    this.resetChoosedFilters = false,
    this.fromHomePageSearch = false,
    this.requestToUpdateFilters = true,
    this.category,
  });

  @override
  // TODO: implement props
  List<Object?> get props =>
      [filtersChoosedByUser, boutiqueSlug, resetChoosedFilters, category];
}

class ChangeAppliedFiltersEvent extends HomeEvent {
  final GetProductFiltersModel? filtersAppliedByUser;
  final bool resetAppliedFilters;
  final String boutiqueSlug;
  final String? category;

  ChangeAppliedFiltersEvent({
    this.filtersAppliedByUser,
    required this.boutiqueSlug,
    this.resetAppliedFilters = false,
    this.category,
  });

  @override
  // TODO: implement props
  List<Object?> get props =>
      [filtersAppliedByUser, boutiqueSlug, resetAppliedFilters, category];
}

class GetProductsWithFiltersEventWithoutCancelingPreviousEvents extends HomeEvent {
  final String? category;
  final String? searchText;
  final int offset;
  final int? limit;
  final String boutiqueSlug;
  final bool cashedOrginalBoutique;
  final bool? fromSearch;
  final bool? fromChoosed;
  final bool getWithPagination;
  final bool resetChoosedFilters;
  final BuildContext context;


  GetProductsWithFiltersEventWithoutCancelingPreviousEvents(
      {required this.boutiqueSlug,
        this.getWithPagination = false,
        this.resetChoosedFilters = true,
        this.searchText,
        required this.context,
        this.cashedOrginalBoutique = false,
        this.fromChoosed = false,
        this.fromSearch,
        required this.offset,
        this.limit,
        this.category});

  @override
  // TODO: implement props
  List<Object?> get props =>
      [category, getWithPagination, searchText, offset, limit, boutiqueSlug];
}

class GetProductsWithFiltersEvent extends HomeEvent {
  final String? category;
  final String? searchText;
  final int offset;
  final int? limit;
  final String boutiqueSlug;
  final bool cashedOrginalBoutique;
  final bool? fromSearch;
  final bool? fromChoosed;
  final bool getWithPagination;
  final bool resetChoosedFilters;

  GetProductsWithFiltersEvent(
      {required this.boutiqueSlug,
      this.getWithPagination = false,
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
      [category, getWithPagination, searchText, offset, limit, boutiqueSlug];
}

class GetStoryForProductEvent extends HomeEvent {
  final String productId;

  GetStoryForProductEvent({required this.productId});

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class LoadFailureEvent extends HomeEvent {
  final int collectionId;

  const LoadFailureEvent({required this.collectionId});

  @override
  List<Object?> get props => [collectionId];
}

class AddSizesFotColorsEvent extends HomeEvent {
  final String currentColorName;
  final List<Variation>? variation;

  const AddSizesFotColorsEvent(
      {required this.currentColorName, required this.variation});

  @override
  List<Object?> get props => [currentColorName];
}

class GetCartItemEvent extends HomeEvent {
  const GetCartItemEvent();

  @override
  List<Object?> get props => [];
}

class AddItemToCartEvent extends HomeEvent {
  final String? color;
  final String image;
  final int? quantity;
  final int? countOfPieces;
  final String? boutiqueIcon;
  final String? choice_1;
  final int? boutiqueId;
  final String colorName;
  final Products products;

  AddItemToCartEvent(
      {this.quantity,
      this.boutiqueIcon,
      this.boutiqueId,
      required this.image,
      required this.countOfPieces,
      required this.colorName,
      this.color,
      this.choice_1,
      required this.products});

  @override
  List<Object?> get props => [];
}

class AddMultiItemsToCartEvent extends HomeEvent {
  final String? id;

  final String? boutiqueIcon;

  final int? boutiqueId;

  final Products products;

  AddMultiItemsToCartEvent(
      {this.id, this.boutiqueIcon, this.boutiqueId, required this.products});

  @override
  List<Object?> get props => [];
}

class AddCurrentColorSizeEvent extends HomeEvent {
  final String? choice_1;

  AddCurrentColorSizeEvent({
    this.choice_1,
  });

  @override
  List<Object?> get props => [];
}

class AddPrefAppliedFilterForExtendFilterEvent extends HomeEvent {
  final Filter? prefAppliedFilter;

  AddPrefAppliedFilterForExtendFilterEvent({
    this.prefAppliedFilter,
  });

  @override
  List<Object?> get props => [];
}

class ResetAllSelectedAppliedFilterEvent extends HomeEvent {
  ResetAllSelectedAppliedFilterEvent();

  @override
  List<Object?> get props => [];
}

class AddProductItemForCartEvent extends HomeEvent {
  final Products? product;
  final String productId;

  AddProductItemForCartEvent({this.product, required this.productId});

  @override
  List<Object?> get props => [];
}


class RemoveItemFormCartEvent extends HomeEvent {
  final String boutiqueId;
  final String itemId;
  final String productId;
  final String currentSize;
  final int? countOfPieces;
  final String ColoName;
  final String image;
  RemoveItemFormCartEvent({
    required this.itemId,
    required this.countOfPieces,
    required this.boutiqueId,
    required this.image,
    required this.currentSize,
    required this.ColoName,
    required this.productId,
  });

  @override
  List<Object?> get props => [];
}

class UpdateItemInCartEvent extends HomeEvent {
  final String cartId;
  final int quantity;
  final String currentSize;
  final String productId;
  final String colorName;
  final String image;
  final String boutiqueId;
  final int? countOfPieces;

  UpdateItemInCartEvent({
    required this.quantity,
    required this.colorName,
    required this.cartId,
    required this.image,
    required this.countOfPieces,
    required this.currentSize,
    required this.productId,
    required this.boutiqueId,
  });

  @override
  List<Object?> get props => [];
}

class AddQuantityForCartEvent extends HomeEvent {
  final String productId;
  final int quantity;
  final String currentSize;
  final int cartId;
  final String colorName;

  AddQuantityForCartEvent(
      {required this.quantity,
      required this.productId,
      required this.currentSize,
      required this.cartId,
      required this.colorName});

  @override
  List<Object?> get props => [];
}

class GetSearchListingResultEvent extends HomeEvent {
  final String searchTitle;
  final String boutiqueSlug;
  final String CategorySlug;
  GetSearchListingResultEvent({
    required this.boutiqueSlug,
    required this.CategorySlug,
    required this.searchTitle,
  });

  @override
  List<Object?> get props => [];
}

class AddSearchTextToHistoryEvent extends HomeEvent {
  final String searchTitle;

  AddSearchTextToHistoryEvent({
    required this.searchTitle,
  });

  @override
  List<Object?> get props => [];
}

class RemoveSearchTextfromHistoryEvent extends HomeEvent {
  final String searchTitle;
  final bool clearAll;

  RemoveSearchTextfromHistoryEvent(
      {required this.searchTitle, required this.clearAll});

  @override
  List<Object?> get props => [];
}

/*class GetBrandEvent extends HomeEvent {
  GetBrandEvent();

  @override
  List<Object?> get props => [];
}
*/
/*class GetCategoryEvent extends HomeEvent {
  GetCategoryEvent();

  @override
  List<Object?> get props => [];
}*/

class GetAllowedCountriesEvent extends HomeEvent {
  GetAllowedCountriesEvent();

  @override
  List<Object?> get props => [];
}

class UpdateListOfItemForAddToCartEvent extends HomeEvent {
  final ImageForAddToCart imageForAddToCart;
  final String operation;
  final String productId;
  UpdateListOfItemForAddToCartEvent({
    required this.imageForAddToCart,
    required this.operation,
    required this.productId,
  });

  @override
  List<Object?> get props => [];
}
