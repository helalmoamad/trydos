import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:trydos/features/home/presentation/manager/categoryBloc/category_state.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();
}

class GetMainCategoriesEvent extends CategoryEvent {
  final bool getWithPrefech;
  const GetMainCategoriesEvent({this.context, this.getWithPrefech = true});

  final BuildContext? context;
  @override
  // TODO: implement props
  List<Object?> get props => [context];
}

class ReplyFromGeminiEvent extends CategoryEvent {
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

class ChangeCurrentIndexForMainCategoryEvent extends CategoryEvent {
  final int index;

  ChangeCurrentIndexForMainCategoryEvent({this.index = 0});

  @override
  List<Object?> get props => [];
}

// ignore: must_be_immutable
class GetHomeBoutiqesEvent extends CategoryEvent {
  // final bool getWithPagination;
  final String offset;
  final bool getWithPagination;
  final bool forRefresh;
  final bool getWithOutPrefetchForEachBoutiques;
  bool? withSemaphore;
  final bool getWithPrefetchToStoreInMemory;
  final String categorySlug;
  final BuildContext context;

  GetHomeBoutiqesEvent({
    required this.offset,
    required this.context,
    this.withSemaphore,
    required this.getWithPrefetchToStoreInMemory,
    this.forRefresh = false,
    this.getWithOutPrefetchForEachBoutiques = false,
    this.getWithPagination = false,
    required this.categorySlug,
  }
      //  {this.getWithPagination = false}
      );

  @override
  // TODO: implement props
  List<Object?> get props => [];
}
