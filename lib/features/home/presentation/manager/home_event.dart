
import 'package:equatable/equatable.dart';


abstract class HomeEvent extends Equatable {
  const HomeEvent();
}

class GetStartingSettingsEvent extends HomeEvent{
  const GetStartingSettingsEvent();
  @override
  // TODO: implement props
  List<Object?> get props => [];

}

class GetMainCategoriesEvent extends HomeEvent{
  const GetMainCategoriesEvent();
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class GetHomeSectionsEvent extends HomeEvent{
  final String categorySlug;
  const GetHomeSectionsEvent(this.categorySlug);
  @override
  // TODO: implement props
  List<Object?> get props => [categorySlug];
}

