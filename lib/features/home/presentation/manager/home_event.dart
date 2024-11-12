import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:trydos/features/home/data/models/get_old_cart_model.dart'
    as oldCarts;
import 'package:trydos/features/home/data/models/get_product_detail_without_related_products_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
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
  final bool getWithPrefech;
  const GetMainCategoriesEvent({this.context, this.getWithPrefech = true});

  final BuildContext? context;
  @override
  // TODO: implement props
  List<Object?> get props => [context];
}

class GetProductFiltersEvent extends HomeEvent {
  const GetProductFiltersEvent(
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

class GetProductWithFiltersWithoutCancelingPreviousEvents extends HomeEvent {
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

class GetProductsListInCartEvent extends HomeEvent {
  const GetProductsListInCartEvent(
      //  {this.getWithPagination = false}
      );

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class GetHomeBoutiqesEvent extends HomeEvent {
  // final bool getWithPagination;
  final String offset;
  final bool getWithPagination;
  final bool getWithPrefetchForBoutiques;
  final String categorySlug;
  final BuildContext context;

  const GetHomeBoutiqesEvent({
    required this.offset,
    required this.context,
    this.getWithPrefetchForBoutiques = false,
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

class GetFullProductDetailsEvent extends HomeEvent {
  final String? productId;

  const GetFullProductDetailsEvent({this.productId});

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
  List<Object?> get props =>
      [filtersChoosedByUser, boutiqueSlug, resetChoosedFilters, category , isExpandedForListing];
}

class ChangeAppliedFiltersEvent extends HomeEvent {
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
  List<Object?> get props =>
      [filtersAppliedByUser, boutiqueSlug, resetAppliedFilters, category , isExpandedForListing];
}

/*class GetProductsWithFiltersEventWithoutCancelingPreviousEvents
    extends HomeEvent {
  final String? category;
  final bool getWithoutFilter;
  final String? searchText;
  final int offset;
  final List<String> categorySlugs;
  final int? limit;
  final int? indexOfCategory;
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

      required this.categorySlugs,
      this.getWithPagination = false,
      this.getWithoutFilter = false,
      this.resetChoosedFilters = true,
      this.searchText,
      this.indexOfCategory = 0,
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
*/

class GetProductsWithFiltersEvent extends HomeEvent {
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
  final bool getWithPagination;

  GetProductsWithFiltersEvent(
      {required this.boutiqueSlug,
      this.getWithoutFilter = false,
      this.resetChoosedFilters = true,
      this.searchText,
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

class GetProductsWithFiltersUsingPaginationEvent extends HomeEvent {
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

class GetStoryForProductEvent extends HomeEvent {
  final String productId;

  GetStoryForProductEvent({required this.productId});

  @override
  // TODO: implement props
  List<Object?> get props => [productId];
}

class LoadFailureEvent extends HomeEvent {
  final int collectionId;

  const LoadFailureEvent({required this.collectionId});

  @override
  List<Object?> get props => [collectionId];
}

class RequestForNotificationWhenProductBecameAvailableEvent extends HomeEvent {
  final String productId;
  final int notificationTypeId;
  final String size;
  final String selectedColorName;

  RequestForNotificationWhenProductBecameAvailableEvent(this.productId,
      this.notificationTypeId, this.size, this.selectedColorName);

  @override
  List<Object?> get props =>
      [productId, notificationTypeId, size, selectedColorName];
}

class IscashedOreiginBotiqueEvent extends HomeEvent {
  final bool iscashedOreiginBotique;

  const IscashedOreiginBotiqueEvent({required this.iscashedOreiginBotique});

  @override
  List<Object?> get props => [iscashedOreiginBotique];
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

class GetOldCartItemEvent extends HomeEvent {
  const GetOldCartItemEvent();

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
  final String? maxAllowed;
  final bool fishAddAllTheItems;
  final Products products;

  AddItemToCartEvent(
      {this.quantity,
      this.boutiqueIcon,
      this.fishAddAllTheItems = true,
      this.boutiqueId,
      required this.maxAllowed,
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
  final String? maxAllowed;

  final Products products;

  AddMultiItemsToCartEvent(
      {this.id,
      this.boutiqueIcon,
      required this.maxAllowed,
      this.boutiqueId,
      required this.products});

  @override
  List<Object?> get props => [];
}

class AddCurrentColorSizeEvent extends HomeEvent {
  final String? choice_1;

  AddCurrentColorSizeEvent({
    this.choice_1,
  });

  @override
  List<Object?> get props => [choice_1];
}

class AddPrefAppliedFilterForExtendFilterEvent extends HomeEvent {
  final Filter? prefAppliedFilter;

  AddPrefAppliedFilterForExtendFilterEvent({
    this.prefAppliedFilter,
  });

  @override
  List<Object?> get props => [prefAppliedFilter];
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
  List<Object?> get props => [productId, product];
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
  final bool fishAddAllTheItems;
  final String colorName;
  final String image;
  final String boutiqueId;
  final int? countOfPieces;
  final double? maxAllowed;

  UpdateItemInCartEvent({
    required this.quantity,
    required this.colorName,
    this.fishAddAllTheItems = true,
    required this.cartId,
    required this.image,
    required this.maxAllowed,
    required this.countOfPieces,
    required this.currentSize,
    required this.productId,
    required this.boutiqueId,
  });

  @override
  List<Object?> get props => [];
}

class AddCommentEvent extends HomeEvent {
  final String productId;
  final String comment;
  AddCommentEvent({required this.productId, required this.comment});

  @override
  // TODO: implement props
  List<Object?> get props => [productId, comment];
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

class HideItemInOldCartEvent extends HomeEvent {
  final int? oldCartId;
  final bool? hideAll;
  final String? boutiqueId;
  HideItemInOldCartEvent({this.oldCartId, this.boutiqueId, this.hideAll});

  @override
  List<Object?> get props => [];
}

class ConvertItemFromOldcartToCartEvent extends HomeEvent {
  final int? oldCartId;

  final String? boutiqueId;
  ConvertItemFromOldcartToCartEvent({this.oldCartId, this.boutiqueId});

  @override
  List<Object?> get props => [];
}

class AddIsExpandedForLidtingPageEvent extends HomeEvent {
  final bool isExpandedForLidting;

  AddIsExpandedForLidtingPageEvent({required this.isExpandedForLidting});

  @override
  List<Object?> get props => [];
}

class GetCurrencyForCountryEvent extends HomeEvent {
  GetCurrencyForCountryEvent();
  @override
  List<Object?> get props => [];
}

class ReplyFromGeminiEvent extends HomeEvent {
  final String theReplyFromGemini;
  final bool resetTheReply;
  final bool fromSearch;
  final SendRequestToGeminiStatus? sendRequestToGeminiStatus;
  ReplyFromGeminiEvent(
      {required this.theReplyFromGemini,
      required this.fromSearch,
      this.sendRequestToGeminiStatus,
      this.resetTheReply = false});
  @override
  List<Object?> get props => [];
}

class ChangeCurrentIndexForMainCategoryEvent extends HomeEvent {
  final int index;

  ChangeCurrentIndexForMainCategoryEvent({this.index = 0});

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

class AddOrRemoveLikeForProductEvent extends HomeEvent {
  final bool isFavourite;
  final String productId;
  AddOrRemoveLikeForProductEvent(
      {required this.isFavourite, required this.productId});
  @override
  List<Object?> get props => [isFavourite, productId];
}

class GetAndAddCountViewOfProductEvent extends HomeEvent {
  final String productId;
  GetAndAddCountViewOfProductEvent({required this.productId});
  @override
  List<Object?> get props => [productId];
}

class UpdateListOfItemForAddToCartEvent extends HomeEvent {
  final ImageForAddToCart imageForAddToCart;
  final String operation;
  final String productId;
  final bool resetTheList;
  UpdateListOfItemForAddToCartEvent({
    required this.imageForAddToCart,
    required this.operation,
    this.resetTheList = false,
    required this.productId,
  });

  @override
  List<Object?> get props => [];
}

class GetProductsWithFiltersWithPrefetchForFiveFiltersEvent extends HomeEvent {
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

class GetProductFiltersWithPrefetchForFiveFiltersEvent extends HomeEvent {
  const GetProductFiltersWithPrefetchForFiveFiltersEvent({
    this.category,
    required this.filterSlug,
    this.attribute,
    required this.filterType,
    required this.boutiqueSlug,
  });

  final String boutiqueSlug;
  final String filterType;
  final Attribute? attribute;
  final String filterSlug;
  final String? category;

  @override
  // TODO: implement props
  List<Object?> get props => [
        category,
        filterSlug,
        boutiqueSlug,
      ];
}
