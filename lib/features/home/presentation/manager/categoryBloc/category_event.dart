import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:trydos/features/authentication/data/models/verify_otp_sign_up_and_in_response_model.dart';
import 'package:trydos/features/home/data/models/get_list_of_customer_addresses_model.dart';
import 'package:trydos/features/home/data/models/get_product_detail_without_related_products_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart';
import 'package:trydos/features/home/presentation/manager/categoryBloc/category_state.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_sheet_bottom_bar.dart';

import '../../../data/models/get_product_filters_model.dart';
import '../../../domain/use_cases/place_order_usecase.dart';

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
