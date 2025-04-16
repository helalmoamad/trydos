import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:trydos/core/data/model/pagination_model.dart';

import 'package:trydos/features/home/data/models/get_home_boutiqes_model.dart'
    as boutiques_model;

import '../../../data/models/main_categories_response_model.dart';

enum GetMainCategoriesStatus { init, loading, success, failure }

enum SendRequestToGeminiStatus { init, loading, success, failure }

@JsonSerializable(explicitToJson: true)
@immutable
class CategoryState extends Equatable {
  const CategoryState({
    this.boutiquesForEveryMainCategoryThatDidPrefetch = const {},
    this.getHomeBoutiquesPaginationObjectByMainCategory = const {},
    this.currentIndexForMainCategoryEvent = -1,
    this.sendRequestToGeminiStatus = SendRequestToGeminiStatus.init,
    this.getMainCategoriesStatus = GetMainCategoriesStatus.init,
    this.theReplyFromGemini,
    this.mainCategoriesResponseModel,
    this.fromSearchForSearchWithGemini = false,
  });
  final Map<String, bool> boutiquesForEveryMainCategoryThatDidPrefetch;
  final Map<String, PaginationModel<boutiques_model.Boutique>>
      getHomeBoutiquesPaginationObjectByMainCategory;

  final GetMainCategoriesStatus getMainCategoriesStatus;
  final int currentIndexForMainCategoryEvent;
  final MainCategoriesResponseModel? mainCategoriesResponseModel;
  final String? theReplyFromGemini;
  final bool? fromSearchForSearchWithGemini;
  final SendRequestToGeminiStatus sendRequestToGeminiStatus;

  @override
  List<Object?> get props => [
        boutiquesForEveryMainCategoryThatDidPrefetch,
        getHomeBoutiquesPaginationObjectByMainCategory,
        getMainCategoriesStatus,
        sendRequestToGeminiStatus,
        theReplyFromGemini,
        currentIndexForMainCategoryEvent,
        fromSearchForSearchWithGemini,
        mainCategoriesResponseModel,
      ];

  CategoryState copyWith({
    final Map<String, bool>? boutiquesForEveryMainCategoryThatDidPrefetch,
    final Map<String, PaginationModel<boutiques_model.Boutique>>?
        getHomeBoutiquesPaginationObjectByMainCategory,
    final SendRequestToGeminiStatus? sendRequestToGeminiStatus,
    final GetMainCategoriesStatus? getMainCategoriesStatus,
    final bool? fromSearchForSearchWithGemini,
    final String? theReplyFromGemini,
    int? currentIndexForMainCategory,
    final MainCategoriesResponseModel? mainCategoriesResponseModel,
  }) {
    return CategoryState(
      boutiquesForEveryMainCategoryThatDidPrefetch:
          boutiquesForEveryMainCategoryThatDidPrefetch ??
              this.boutiquesForEveryMainCategoryThatDidPrefetch,
      getHomeBoutiquesPaginationObjectByMainCategory:
          getHomeBoutiquesPaginationObjectByMainCategory ??
              this.getHomeBoutiquesPaginationObjectByMainCategory,
      sendRequestToGeminiStatus:
          sendRequestToGeminiStatus ?? this.sendRequestToGeminiStatus,
      currentIndexForMainCategoryEvent:
          currentIndexForMainCategory ?? this.currentIndexForMainCategoryEvent,
      getMainCategoriesStatus:
          getMainCategoriesStatus ?? this.getMainCategoriesStatus,
      fromSearchForSearchWithGemini:
          fromSearchForSearchWithGemini ?? this.fromSearchForSearchWithGemini,
      mainCategoriesResponseModel:
          mainCategoriesResponseModel ?? this.mainCategoriesResponseModel,
      theReplyFromGemini: theReplyFromGemini ?? this.theReplyFromGemini,
    );
  }
}
