import 'package:equatable/equatable.dart';

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

class AddCurrentSelectedColorEvent extends HomeEvent {
  final int currentSelectedColor;
  final String productId;
  const AddCurrentSelectedColorEvent({required this.currentSelectedColor ,required this.productId});
  @override
  // TODO: implement props
  List<Object?> get props => [currentSelectedColor , productId];
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

class StorySelectEvent extends HomeEvent {
  final int collectionIndex;
  final int selectedStoryIndexInCollection;
  final int currentPage;
  const StorySelectEvent(
      {required this.collectionIndex,
      required this.selectedStoryIndexInCollection,
      required this.currentPage});

  @override
  List<Object?> get props =>
      [collectionIndex, selectedStoryIndexInCollection, currentPage];
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
  final List<String>? prices;
  final List<int>? brands;
  final List<Map<String, dynamic>>? attributes;
  final String? searchText;
  final int? offset;
  final int? limit;
  final String? boutique_slug;

  GetProductsWithoutFiltersEvent(
      {this.prices,
      this.brands,
      this.attributes,
      this.boutique_slug,
      this.searchText,
      this.offset,
      this.limit,
      this.category});

  @override
  // TODO: implement props
  List<Object?> get props =>
      [category, prices, brands, attributes, searchText, offset, limit];
}

class GetStoryForProductEvent extends HomeEvent {
  const GetStoryForProductEvent();

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

