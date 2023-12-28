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

class GetHomeSectionsEvent extends HomeEvent {
  final String categorySlug;

  const GetHomeSectionsEvent(this.categorySlug);

  @override
  // TODO: implement props
  List<Object?> get props => [categorySlug];
}

class GetProductsWithoutFiltersEvent extends HomeEvent {
  final String? category;
  final List<String>? prices;
  final List<int>? brands;
  final List<Map<String, dynamic>>? attributes;
  final String? searchText;
  final int? offset;
  final int? limit;

  GetProductsWithoutFiltersEvent(
      {this.prices,
      this.brands,
      this.attributes,
      this.searchText,
      this.offset,
      this.limit,
      this.category});

  @override
  // TODO: implement props
  List<Object?> get props =>
      [category, prices, brands, attributes, searchText, offset, limit];
}
