import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:trydos/features/authentication/data/models/verify_otp_sign_up_and_in_response_model.dart';
import 'package:trydos/features/home/data/models/get_list_of_customer_addresses_model.dart';
import 'package:trydos/features/home/data/models/get_product_detail_without_related_products_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_sheet_bottom_bar.dart';

import '../../data/models/get_product_filters_model.dart';
import '../../domain/use_cases/place_order_usecase.dart';

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

class ChangeCountryLanguageForNotificationEvent extends HomeEvent {
  final String country;
  final String languageCode;
  const ChangeCountryLanguageForNotificationEvent(
      {required this.languageCode, required this.country});

  @override
  // TODO: implement props
  List<Object?> get props => [country, languageCode];
}

class SubscribeTopicForNotificationEvent extends HomeEvent {
  final String topic;
  final String? variant;
  const SubscribeTopicForNotificationEvent({required this.topic, this.variant});

  @override
  // TODO: implement props
  List<Object?> get props => [topic];
}

class UnSubscribeTopicForNotificationEvent extends HomeEvent {
  final String topic;
  final String? variant;
  const UnSubscribeTopicForNotificationEvent(
      {required this.topic, this.variant});

  @override
  // TODO: implement props
  List<Object?> get props => [topic];
}

class UpdateEmailNotificationEvent extends HomeEvent {
  final int email;

  const UpdateEmailNotificationEvent({required this.email});

  @override
  // TODO: implement props
  List<Object?> get props => [email];
}

class UpdateFirebaseNotificationEvent extends HomeEvent {
  final int firebase;

  const UpdateFirebaseNotificationEvent({required this.firebase});

  @override
  // TODO: implement props
  List<Object?> get props => [firebase];
}

class UpdateWhatsappNotificationEvent extends HomeEvent {
  final int whatsapp;

  const UpdateWhatsappNotificationEvent({required this.whatsapp});

  @override
  // TODO: implement props
  List<Object?> get props => [whatsapp];
}

class UpdateNotificationFrequencyEvent extends HomeEvent {
  final String notificationFrequency;

  const UpdateNotificationFrequencyEvent({required this.notificationFrequency});

  @override
  // TODO: implement props
  List<Object?> get props => [notificationFrequency];
}

class GetFirebaseSettingForNotificationEvent extends HomeEvent {
  const GetFirebaseSettingForNotificationEvent();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class AddTimerStartedToHurryUpEvent extends HomeEvent {
  final bool isAddToList;
  final String cartId;
  final int timeLeft;

  const AddTimerStartedToHurryUpEvent(
      {required this.cartId,
      required this.isAddToList,
      required this.timeLeft});

  @override
  // TODO: implement props
  List<Object?> get props => [cartId];
}

class ConvertItemFromCartToOldCartEvent extends HomeEvent {
  final String cartId;

  const ConvertItemFromCartToOldCartEvent({required this.cartId});

  @override
  // TODO: implement props
  List<Object?> get props => [cartId];
}

class GetPopularSearchItemEvent extends HomeEvent {
  const GetPopularSearchItemEvent();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class SendErrorToMobileErrorLogEvent extends HomeEvent {
  final String errorExption;
  final String errorPath;
  final String urlBackend;
  final String messageFromeBackend;
  const SendErrorToMobileErrorLogEvent(
      {required this.errorExption,
      required this.errorPath,
      required this.urlBackend,
      required this.messageFromeBackend});

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class GetProductsListInCartEvent extends HomeEvent {
  const GetProductsListInCartEvent(
      //  {this.getWithPagination = false}
      );

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class StoreFcmTokenOfMarketEvent extends HomeEvent {
  final int userId;
  final String fcmToken;

  const StoreFcmTokenOfMarketEvent(
      {required this.userId, required this.fcmToken});

  @override
  // TODO: implement props
  List<Object?> get props => [userId, fcmToken];
}

class GetHomeBoutiqesEvent extends HomeEvent {
  // final bool getWithPagination;
  final String offset;
  final bool getWithPagination;
  final bool forRefresh;
  final bool getWithPrefetchForBoutiques;
  final String categorySlug;
  final BuildContext context;

  const GetHomeBoutiqesEvent({
    required this.offset,
    required this.context,
    this.forRefresh = false,
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
  final String? productSlug;
  final bool? fromListingPage;
  const GetProductDatailsWithoutRelatedProductsEvent(
      {this.productId, this.productSlug, this.fromListingPage});

  @override
  // TODO: implement props
  List<Object?> get props => [productId, productSlug];
}

class GetFullProductDetailsEvent extends HomeEvent {
  final String? productId;
  final String productSlug;
  const GetFullProductDetailsEvent({this.productId, required this.productSlug});

  @override
  // TODO: implement props
  List<Object?> get props => [productId, productSlug];
}

class AddAddressInfoClassEvent extends HomeEvent {
  final CustomerAddressesInfo? addressInfoClassToSave;

  const AddAddressInfoClassEvent({required this.addressInfoClassToSave});

  @override
  // TODO: implement props
  List<Object?> get props => [addressInfoClassToSave];
}

class GetNotificationTypeProductEvent extends HomeEvent {
  const GetNotificationTypeProductEvent();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class DeleteAdressInfoClassEvent extends HomeEvent {
  final int? adressInfoClassId;

  const DeleteAdressInfoClassEvent({required this.adressInfoClassId});

  @override
  // TODO: implement props
  List<Object?> get props => [adressInfoClassId];
}

class SetCustomerAddressDefaultEvent extends HomeEvent {
  final int? adressId;

  const SetCustomerAddressDefaultEvent({required this.adressId});

  @override
  // TODO: implement props
  List<Object?> get props => [adressId];
}

class SetCurrentAddressChoosedEvent extends HomeEvent {
  final int? index;

  const SetCurrentAddressChoosedEvent({required this.index});

  @override
  // TODO: implement props
  List<Object?> get props => [index];
}

class EditAdressInfoClassEvent extends HomeEvent {
  final CustomerAddressesInfo? addressInfoClassToSave;
  final int preIdToEdit;
  const EditAdressInfoClassEvent(
      {required this.addressInfoClassToSave, required this.preIdToEdit});

  @override
  // TODO: implement props
  List<Object?> get props => [addressInfoClassToSave, preIdToEdit];
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
  List<Object?> get props => [
        filtersChoosedByUser,
        boutiqueSlug,
        resetChoosedFilters,
        category,
        isExpandedForListing
      ];
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
  List<Object?> get props => [
        filtersAppliedByUser,
        boutiqueSlug,
        resetAppliedFilters,
        category,
        isExpandedForListing
      ];
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
  final bool? fromNotification;
  final bool? fromChoosed;
  final bool resetChoosedFilters;
  final bool getWithPagination;

  GetProductsWithFiltersEvent(
      {required this.boutiqueSlug,
      this.getWithoutFilter = false,
      this.resetChoosedFilters = true,
      this.searchText,
      this.fromNotification = false,
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

class UploadUserPhotoCloudinaryEvent extends HomeEvent {
  final File file;
  final bool? changeStatusToFailure;
  const UploadUserPhotoCloudinaryEvent(this.file, this.changeStatusToFailure);

  @override
  List<Object?> get props => [];
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

class AddSizeAndColorFilterinTextToSearchEvent extends HomeEvent {
  final Map<String, List<String>> sizeAndColorFilterinTextToSearch;
  AddSizeAndColorFilterinTextToSearchEvent(
      {required this.sizeAndColorFilterinTextToSearch});

  @override
  // TODO: implement props
  List<Object?> get props => [sizeAndColorFilterinTextToSearch];
}

class GetAddressByCoordinatesEvent extends HomeEvent {
  final double latitude;
  final double longitude;
  GetAddressByCoordinatesEvent(
      {required this.longitude, required this.latitude});

  @override
  // TODO: implement props
  List<Object?> get props => [longitude, latitude];
}

class GetCustomerWalletEvent extends HomeEvent {
  final int limit;
  final int offset;
  GetCustomerWalletEvent({required this.limit, required this.offset});

  @override
  // TODO: implement props
  List<Object?> get props => [limit, offset];
}

class SaveUserInfoFromAuthEvent extends HomeEvent {
  final User userInfo;

  SaveUserInfoFromAuthEvent({required this.userInfo});

  @override
  // TODO: implement props
  List<Object?> get props => [userInfo];
}

class UpdateProfileEvent extends HomeEvent {
  final bool? changeStatusToInit;
  final String? name;
  final String? phone;
  final String? email;
  final String? image;
  final String? tall;
  final String? weight;
  final String? alternative_phone;
  final String? gender;

  UpdateProfileEvent(
      {this.name,
      this.email,
      this.gender,
      this.changeStatusToInit,
      this.image,
      this.tall,
      this.weight,
      this.alternative_phone,
      this.phone});
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class GetAddressByTextEvent extends HomeEvent {
  final String query;
  final bool reset;

  GetAddressByTextEvent({required this.query, required this.reset});

  @override
  // TODO: implement props
  List<Object?> get props => [query];
}

class GetCustomerAddressesEvent extends HomeEvent {
  GetCustomerAddressesEvent();

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

class RequestForNotificationWhenProductBecameAvailableEvent extends HomeEvent {
  final String productId;
  final int notificationTypeId;
  final String size;
  final String selectedColorName;
  final bool subsecribe;
  RequestForNotificationWhenProductBecameAvailableEvent(
      this.productId,
      this.notificationTypeId,
      this.size,
      this.selectedColorName,
      this.subsecribe);

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

class AddSizesForColorsEvent extends HomeEvent {
  final String currentColorName;
  final List<Variation>? variation;

  const AddSizesForColorsEvent(
      {required this.currentColorName, required this.variation});

  @override
  List<Object?> get props => [currentColorName];
}

class GetCartItemEvent extends HomeEvent {
  const GetCartItemEvent();

  @override
  List<Object?> get props => [];
}

class CheckWithGetCartEvent extends HomeEvent {
  final bool isForPlaceOrder;
  const CheckWithGetCartEvent({required this.isForPlaceOrder});

  @override
  List<Object?> get props => [isForPlaceOrder];
}

class IsChangedvariationWhenQtyZeroEvent extends HomeEvent {
  final bool isChangedvariationWhenQtyZero;
  const IsChangedvariationWhenQtyZeroEvent(
      {required this.isChangedvariationWhenQtyZero});

  @override
  List<Object?> get props => [isChangedvariationWhenQtyZero];
}

class ChangeStatusOFGetProductsDetailsToSuccessEvent extends HomeEvent {
  final bool? isStatusInitaial;
  const ChangeStatusOFGetProductsDetailsToSuccessEvent({this.isStatusInitaial});

  @override
  List<Object?> get props => [];
}

class RemoveItemsFromCartAfterOrderSuccessEvent extends HomeEvent {
  const RemoveItemsFromCartAfterOrderSuccessEvent();

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
  final bool finishAddAllTheItems;
  final Products products;
  final String productSlugForTopic;

  AddItemToCartEvent(
      {this.quantity,
      this.boutiqueIcon,
      this.finishAddAllTheItems = true,
      this.boutiqueId,
      required this.maxAllowed,
      required this.image,
      required this.productSlugForTopic,
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
  final String productSlugForTopic;
  final int? boutiqueId;
  final String? maxAllowed;

  final Products products;

  AddMultiItemsToCartEvent(
      {this.id,
      this.boutiqueIcon,
      required this.maxAllowed,
      required this.productSlugForTopic,
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

class ClearAllAppCashEvent extends HomeEvent {
  const ClearAllAppCashEvent();

  @override
  List<Object?> get props => [];
}

class RemoveItemFormCartEvent extends HomeEvent {
  final String boutiqueId;
  final String itemId;
  final String productId;
  final String currentSize;
  final int? countOfPieces;
  final String colorName;
  final String image;
  RemoveItemFormCartEvent({
    required this.itemId,
    required this.countOfPieces,
    required this.boutiqueId,
    required this.image,
    required this.currentSize,
    required this.colorName,
    required this.productId,
  });

  @override
  List<Object?> get props => [];
}

class UpdateItemInCartEvent extends HomeEvent {
  final String cartId;
  final int totalQuantity;
  final int newQuantity;
  final String currentSize;
  final String productId;
  final bool fishAddAllTheItems;
  final String colorName;
  final String image;
  final String boutiqueId;
  final int? countOfPieces;
  final double? maxAllowed;

  UpdateItemInCartEvent({
    required this.totalQuantity,
    required this.colorName,
    required this.newQuantity,
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
  final String productSlug;
  final String productSlugForTopic;
  final String comment;
  AddCommentEvent(
      {required this.productId,
      required this.productSlugForTopic,
      required this.comment,
      required this.productSlug});

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

class ChangeCurrentIndexForUpdatCartEvent extends HomeEvent {
  final int index;

  ChangeCurrentIndexForUpdatCartEvent({this.index = 0});

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
  final String productSlugForTopic;
  final String productSlug;
  AddOrRemoveLikeForProductEvent(
      {required this.isFavourite,
      required this.productId,
      required this.productSlugForTopic,
      required this.productSlug});
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

class PlaceOrderEvent extends HomeEvent {
  final PlaceOrderParams placeOrderParams;

  PlaceOrderEvent({
    required this.placeOrderParams,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [placeOrderParams];
}

class GetOrdersByOrderGroupIDEvent extends HomeEvent {
  final String orderGroupId;

  GetOrdersByOrderGroupIDEvent({
    required this.orderGroupId,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [orderGroupId];
}

class GetOrdersByCartGroupIDEvent extends HomeEvent {
  final String cartGroupId;

  GetOrdersByCartGroupIDEvent({
    required this.cartGroupId,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [cartGroupId];
}

class CheckAvailabilityProductCartEvent extends HomeEvent {
  CheckAvailabilityProductCartEvent();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class ApplyCouponEvent extends HomeEvent {
  final String code;
  ApplyCouponEvent({required this.code});

  @override
  // TODO: implement props
  List<Object?> get props => [code];
}

class GetCartOverviewEvent extends HomeEvent {
  GetCartOverviewEvent();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class GetUserNotificationEvent extends HomeEvent {
  GetUserNotificationEvent();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class GetOrdersEvent extends HomeEvent {
  final String? status;
  GetOrdersEvent({required this.status});

  @override
  // TODO: implement props
  List<Object?> get props => [status];
}
