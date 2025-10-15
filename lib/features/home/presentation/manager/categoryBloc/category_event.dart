import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';


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
  final File? image;
  final bool resetTheReply;
  final bool fromSearch;

  ReplyFromGeminiEvent(
      {this.image, required this.fromSearch, this.resetTheReply = false});
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
