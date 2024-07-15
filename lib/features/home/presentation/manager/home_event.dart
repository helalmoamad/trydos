import 'package:equatable/equatable.dart';
import 'package:trydos/features/home/data/models/get_product_detail_without_related_products_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart';

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
      {this.category, this.boutiqueSlug, this.forceUpdate = false});

  final String? boutiqueSlug;
  final String? category;
  final bool forceUpdate;

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

  const GetHomeBoutiqesEvent({
    required this.offset,
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

class GetProductsWithFiltersEvent extends HomeEvent {
  final String? category;
  final String? searchText;
  final int offset;
  final int? limit;
  final String boutiqueSlug;
  final bool getWithPagination;
  final GetProductFiltersModel? filtersChoosedByUser;

  GetProductsWithFiltersEvent(
      {this.filtersChoosedByUser,
      required this.boutiqueSlug,
      this.getWithPagination = false,
      this.searchText,
      required this.offset,
      this.limit,
      this.category});

  @override
  // TODO: implement props
  List<Object?> get props => [
        category,
        getWithPagination,
        filtersChoosedByUser,
        searchText,
        offset,
        limit,
        boutiqueSlug
      ];
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
  final String? id;
  final String? color;
  final String thumbnail;
  final int? quantity;
  final String? iconBoutique;
  final String? choice_1;
  final int? boutiqueId;
  final String colorName;
  final Products products;

  AddItemToCartEvent(
      {this.id,
      this.quantity,
      this.iconBoutique,
      this.boutiqueId,
      required this.thumbnail,
      required this.colorName,
      this.color,
      this.choice_1,
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
  final String ColoName;

  RemoveItemFormCartEvent({
    required this.itemId,
    required this.boutiqueId,
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
  final String boutiqueId;

  UpdateItemInCartEvent({
    required this.quantity,
    required this.colorName,
    required this.cartId,
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

class GetSearchREsultEvent extends HomeEvent {
  final String searchTitle;

  GetSearchREsultEvent({
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

class AddSelectedBoutiqueCategoryBrandSlugsForSearchEvent extends HomeEvent {
  bool withBoutique;

  bool withBrand;
  final List<String> selectedBoutiqueBrandCategorySlugsForSearch;

  AddSelectedBoutiqueCategoryBrandSlugsForSearchEvent({
    required this.selectedBoutiqueBrandCategorySlugsForSearch,
    required this.withBoutique,
    required this.withBrand,
  });

  @override
  List<Object?> get props => [];
}

class GetBrandEvent extends HomeEvent {
  GetBrandEvent();

  @override
  List<Object?> get props => [];
}

class GetCategoryEvent extends HomeEvent {
  GetCategoryEvent();

  @override
  List<Object?> get props => [];
}
