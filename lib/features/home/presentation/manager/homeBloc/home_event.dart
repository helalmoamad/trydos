import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:trydos/features/authentication/data/models/verify_otp_sign_up_and_in_response_model.dart';
import 'package:trydos/features/home/data/models/get_product_detail_without_related_products_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_sheet_bottom_bar.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
}

class GetStartingSettingsEvent extends HomeEvent {
  const GetStartingSettingsEvent();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class StorySelectedEvent extends HomeEvent {
  final int collectionIndex;
  final int selectedStoryIndexInCollection;
  final int currentPage;
  const StorySelectedEvent({
    required this.collectionIndex,
    required this.selectedStoryIndexInCollection,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [
    collectionIndex,
    selectedStoryIndexInCollection,
    currentPage,
  ];
}

class GetCurrenciesForWalletEvent extends HomeEvent {
  final String currencySymbol;
  GetCurrenciesForWalletEvent({this.currencySymbol = ""});
  @override
  List<Object?> get props => [currencySymbol];
}

class GetCoutryBoundaryByIsoEvent extends HomeEvent {
  const GetCoutryBoundaryByIsoEvent();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class UpdateLikeSocialSharedProductsEvent extends HomeEvent {
  final String productId;
  const UpdateLikeSocialSharedProductsEvent({required this.productId});

  @override
  // TODO: implement props
  List<Object?> get props => [productId];
}

class AddCurrentSelectedColorEvent extends HomeEvent {
  final int currentSelectedColor;
  final String productSlug;

  const AddCurrentSelectedColorEvent({
    required this.currentSelectedColor,
    required this.productSlug,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [currentSelectedColor, productSlug];
}

class AddCurrentHeightWhenAddToBagEvent extends HomeEvent {
  final int currentHeightWhenAddToBag;

  const AddCurrentHeightWhenAddToBagEvent({
    required this.currentHeightWhenAddToBag,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [currentHeightWhenAddToBag];
}

class IncreaseCountShareOfProductEvent extends HomeEvent {
  final String productId;
  final String socialMediaName;
  final Products product;

  const IncreaseCountShareOfProductEvent({
    required this.productId,
    required this.socialMediaName,
    required this.product,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [];
}
/* GetCommentForProductEvent extends HomeEvent {
  final String productId;

  const GetCommentForProductEvent({required this.productId});

  @override
  // TODO: implement props
  List<Object?> get props => [productId];
}*/

class ChangeCountryLanguageForNotificationEvent extends HomeEvent {
  final String country;
  final String languageCode;
  const ChangeCountryLanguageForNotificationEvent({
    required this.languageCode,
    required this.country,
  });

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
  const UnSubscribeTopicForNotificationEvent({
    required this.topic,
    this.variant,
  });

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

  const AddTimerStartedToHurryUpEvent({
    required this.cartId,
    required this.isAddToList,
    required this.timeLeft,
  });

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
  final String lastForPageHasBeenVisited;
  const SendErrorToMobileErrorLogEvent({
    required this.errorExption,
    required this.errorPath,
    required this.urlBackend,
    required this.messageFromeBackend,
    required this.lastForPageHasBeenVisited,
  });

  @override
  List<Object?> get props => [
    errorExption,
    errorPath,
    urlBackend,
    messageFromeBackend,
    lastForPageHasBeenVisited,
  ];
}

/*class GetProductsListInCartEvent extends HomeEvent {
  const GetProductsListInCartEvent(
      //  {this.getWithPagination = false}
      );

  @override
  // TODO: implement props
  List<Object?> get props => [];
}*/

/*class GeColorsAndSizesForSearchEvent extends HomeEvent {
  const GeColorsAndSizesForSearchEvent();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}*/

class StoreFcmTokenOfMarketEvent extends HomeEvent {
  final int userId;
  final String fcmToken;

  const StoreFcmTokenOfMarketEvent({
    required this.userId,
    required this.fcmToken,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [userId, fcmToken];
}

class GetProductDatailsWithoutRelatedProductsEvent extends HomeEvent {
  final String? productId;
  final String? productSlug;
  final String? currentColorOption;
  final bool? fromListingPage;
  const GetProductDatailsWithoutRelatedProductsEvent({
    this.productId,
    this.productSlug,
    this.currentColorOption,
    this.fromListingPage,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [productId, productSlug];
}

class GetRelatedProductsEvent extends HomeEvent {
  final int? productSlug;
  final String? color;

  GetRelatedProductsEvent({required this.productSlug, required this.color});
  
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class GetFullProductDetailsEvent extends HomeEvent {
  final String productSlug;
  final String? currentColorName;
  const GetFullProductDetailsEvent({
    required this.productSlug,
    this.currentColorName,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [productSlug];
}

class GetNotificationTypeProductEvent extends HomeEvent {
  const GetNotificationTypeProductEvent();

  @override
  // TODO: implement props
  List<Object?> get props => [];
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

class UploadUserPhotoCloudinaryEvent extends HomeEvent {
  final File file;
  final bool? changeStatusToFailure;
  const UploadUserPhotoCloudinaryEvent(this.file, this.changeStatusToFailure);

  @override
  List<Object?> get props => [];
}

class GetStoryForProductEvent extends HomeEvent {
  final String productId;

  GetStoryForProductEvent({required this.productId});

  @override
  // TODO: implement props
  List<Object?> get props => [productId];
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
  final String? idToken;
  final String? gender;
  final bool? fromGuest;

  UpdateProfileEvent({
    this.name,
    this.email,
    this.idToken,
    this.fromGuest,
    this.gender,
    this.changeStatusToInit,
    this.image,
    this.tall,
    this.weight,
    this.alternative_phone,
    this.phone,
  });
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
    this.subsecribe,
  );

  @override
  List<Object?> get props => [
    productId,
    notificationTypeId,
    size,
    selectedColorName,
  ];
}

class AddSizesForColorsEvent extends HomeEvent {
  final String currentColorName;
  final List<Variation>? variation;

  const AddSizesForColorsEvent({
    required this.currentColorName,
    required this.variation,
  });

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

class IsChangedVariationWhenQtyZeroEvent extends HomeEvent {
  final bool isChangedVariationWhenQtyZero;
  final bool finishLoadingAfterChangedVariationWhenQtyZero;
  const IsChangedVariationWhenQtyZeroEvent({
    required this.isChangedVariationWhenQtyZero,
    this.finishLoadingAfterChangedVariationWhenQtyZero = true,
  });

  @override
  List<Object?> get props => [isChangedVariationWhenQtyZero];
}

class ChangeStatusOFGetProductsDetailsToSuccessEvent extends HomeEvent {
  final bool? isStatusInitaial;
  final int? index;
  final String? productSlug;
  const ChangeStatusOFGetProductsDetailsToSuccessEvent({
    this.isStatusInitaial,
    this.index,
    this.productSlug,
  });

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
  final String? variationId;
  final int? countOfPieces;
  final String? boutiqueIcon;
  final String? choiceOption;
  final int? boutiqueId;
  final String colorOption;
  final String colorName;
  final String sizeName;
  final String? maxAllowed;
  final bool fromCartPage;
  final bool finishAddAllTheItems;
  final bool isRedeem;
  final double redeemVariantPrice;
  final Products products;
  final String productSlugForTopic;

  AddItemToCartEvent({
    this.quantity,
    required this.fromCartPage,
    this.boutiqueIcon,
    this.finishAddAllTheItems = true,
    this.boutiqueId,
    required this.isRedeem,
    this.variationId,
    required this.redeemVariantPrice,
    required this.colorName,
    required this.sizeName,
    required this.maxAllowed,
    required this.image,
    required this.productSlugForTopic,
    required this.countOfPieces,
    required this.colorOption,
    this.color,
    this.choiceOption,
    required this.products,
  });

  @override
  List<Object?> get props => [];
}

class AddMultiItemsToCartEvent extends HomeEvent {
  final String? id;

  final String? boutiqueIcon;
  final String productSlugForTopic;
  final int? boutiqueId;
  final String? maxAllowed;
  final bool fromCartPage;
  final Products products;
  final bool isRedeem;
  final double redeemVariantPrice;

  AddMultiItemsToCartEvent({
    this.id,
    this.boutiqueIcon,
    required this.isRedeem,
    required this.fromCartPage,
    required this.redeemVariantPrice,
    required this.maxAllowed,
    required this.productSlugForTopic,
    this.boutiqueId,
    required this.products,
  });

  @override
  List<Object?> get props => [];
}

class AddCurrentColorSizeEvent extends HomeEvent {
  final String? choice_1;
  final String? choiceOption;

  AddCurrentColorSizeEvent({this.choice_1, this.choiceOption});

  @override
  List<Object?> get props => [choice_1, choiceOption];
}

/*class AddProductItemForCartEvent extends HomeEvent {
  final Products? product;
  final String productId;

  AddProductItemForCartEvent({this.product, required this.productId});

  @override
  List<Object?> get props => [productId, product];
}*/

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
  final bool fromCartPage;

  final String colorName;
  final String image;
  RemoveItemFormCartEvent({
    required this.itemId,
    required this.boutiqueId,
    required this.image,
    required this.currentSize,
    required this.fromCartPage,
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
  final bool fromCartPage;
  final String currentSize;
  final String productId;
  final bool fishAddAllTheItems;
  final String colorOption;
  final String image;
  final String boutiqueId;
  final String? productName;
  final String? productPrice;

  final double? maxAllowed;

  UpdateItemInCartEvent({
    required this.totalQuantity,
    required this.colorOption,
    required this.newQuantity,
    this.fishAddAllTheItems = true,
    required this.cartId,
    required this.fromCartPage,
    required this.image,
    required this.maxAllowed,
    required this.currentSize,
    required this.productId,
    required this.boutiqueId,
    this.productName,
    this.productPrice,
  });

  @override
  List<Object?> get props => [];
}

/*class AddCommentEvent extends HomeEvent {
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
}*/

class AddQuantityForCartEvent extends HomeEvent {
  final String productId;
  final int quantity;
  final String currentSize;
  final int cartId;
  final String colorName;

  AddQuantityForCartEvent({
    required this.quantity,
    required this.productId,
    required this.currentSize,
    required this.cartId,
    required this.colorName,
  });

  @override
  List<Object?> get props => [];
}

class AddSearchTextToHistoryEvent extends HomeEvent {
  final String searchTitle;

  AddSearchTextToHistoryEvent({required this.searchTitle});

  @override
  List<Object?> get props => [];
}

class AddProductIdToSaveRedeemTimerEvent extends HomeEvent {
  final List<String> productIdToSaveRedeemTimer;
  final bool on;
  AddProductIdToSaveRedeemTimerEvent({
    required this.productIdToSaveRedeemTimer,
    required this.on,
  });

  @override
  List<Object?> get props => [productIdToSaveRedeemTimer];
}

/*class GetCommentsFromAnalyticsEvent extends HomeEvent {
  final String? productId;

  GetCommentsFromAnalyticsEvent({this.productId});
  @override
  List<Object?> get props => [productId];
}*/

class GetFqaCommentsEvent extends HomeEvent {
  final String? productId;
  final String currentFilter;
  final bool getWithPagination;
  GetFqaCommentsEvent({
    this.productId,
    this.currentFilter = "all",
    this.getWithPagination = false,
  });
  @override
  List<Object?> get props => [productId, getWithPagination, currentFilter];
}

class GetBuyersCommentsEvent extends HomeEvent {
  final String? productId;
  final String currentFilter;
  final bool getWithPagination;
  GetBuyersCommentsEvent({
    this.productId,
    this.currentFilter = "all",
    this.getWithPagination = false,
  });
  @override
  List<Object?> get props => [productId, getWithPagination, currentFilter];
}

class CreateCommentRatingEvent extends HomeEvent {
  final String? text;
  final String? productId;
  final String? rating;
  final String? variant;
  final String? ownerType;
  final List<String>? images;
  final String? slug;
  final String? ownerId;
  final String? orderDetailsId;
  CreateCommentRatingEvent({
    this.productId,
    this.text,
    this.rating,
    this.slug,
    this.images,
    this.ownerType,
    this.ownerId,
    this.orderDetailsId,
    this.variant,
  });
  @override
  List<Object?> get props => [
    productId,
    text,
    rating,
    orderDetailsId,
    images,
    variant,
    slug,
    ownerType,
    ownerId,
  ];
}

class UpdateCommentRatingEvent extends HomeEvent {
  final String? text;
  final String? productId;
  final String? rating;
  final String? variant;
  final List<String>? images;
  final String? slug;
  final String? orderDetailsId;
  final String? commentId;
  final String? ownerType;
  final String? ownerId;
  final int? tapCommentIndex;
  final String currentFilter;
  final bool fromBuyerComments;
  UpdateCommentRatingEvent({
    this.productId,
    this.text,
    this.ownerType,
    this.slug,
    this.images,
    this.currentFilter = "all",
    this.fromBuyerComments = false,
    this.ownerId,
    this.rating,
    this.tapCommentIndex,
    this.orderDetailsId,
    this.commentId,
    this.variant,
  });
  @override
  List<Object?> get props => [
    productId,
    text,
    rating,

    fromBuyerComments,
    ownerType,
    currentFilter,
    ownerId,
    orderDetailsId,
    images,
    variant,
    slug,
    commentId,
    tapCommentIndex,
  ];
}

class TranslateCommentEvent extends HomeEvent {
  final String? commentId;
  final String currentFilter;
  final int? tapCommentIndex;
  final bool fromSellerComments;
  final bool? showOriginal;
  final bool fromBuyerComments;
  TranslateCommentEvent({
    this.fromSellerComments = false,
    this.commentId,
    this.showOriginal = false,
    this.tapCommentIndex,
    this.currentFilter = "all",
    this.fromBuyerComments = false,
  });
  @override
  List<Object?> get props => [
    fromSellerComments,
    commentId,
    showOriginal,
    currentFilter,
    tapCommentIndex,
    fromBuyerComments,
  ];
}

class DeleteCommentRatingEvent extends HomeEvent {
  final String? commentId;
  final String? productId;
  final bool fromBuyerComments;
  final String currentFilter;
  final int? tapCommentIndex;
  DeleteCommentRatingEvent({
    this.productId,
    this.tapCommentIndex,
    this.currentFilter = "all",
    this.fromBuyerComments = false,
    this.commentId,
  });
  @override
  List<Object?> get props => [
    commentId,
    productId,
    tapCommentIndex,
    fromBuyerComments,
    currentFilter,
  ];
}

class UpdateLikeCommentEvent extends HomeEvent {
  final String? commentId;
  final String? productId;
  final bool fromBuyerComments;
  final String currentFilter;
  final bool fromReplayComments;
  final bool toAddLike;
  final int? tapCommentIndex;
  UpdateLikeCommentEvent({
    this.productId,
    this.tapCommentIndex,
    this.fromBuyerComments = false,
    this.toAddLike = false,
    this.currentFilter = "all",
    this.fromReplayComments = false,
    this.commentId,
  });
  @override
  List<Object?> get props => [
    commentId,
    productId,
    tapCommentIndex,
    currentFilter,
    fromBuyerComments,
    fromReplayComments,
    toAddLike,
  ];
}

class GetOrderRatingEvent extends HomeEvent {
  final List<int>? orderDetailIds;
  final String? userId;
  GetOrderRatingEvent({this.orderDetailIds, this.userId});
  @override
  List<Object?> get props => [orderDetailIds, userId];
}

class RemoveSearchTextfromHistoryEvent extends HomeEvent {
  final String searchTitle;
  final bool clearAll;

  RemoveSearchTextfromHistoryEvent({
    required this.searchTitle,
    required this.clearAll,
  });

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

class GetCurrencyForCountryEvent extends HomeEvent {
  GetCurrencyForCountryEvent();
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
  AddOrRemoveLikeForProductEvent({
    required this.isFavourite,
    required this.productId,
    required this.productSlugForTopic,
    required this.productSlug,
  });
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

class CheckAvailabilityProductCartEvent extends HomeEvent {
  CheckAvailabilityProductCartEvent();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class GetCartOverviewEvent extends HomeEvent {
  GetCartOverviewEvent();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class SendAcceptOfNotificationMarketEvent extends HomeEvent {
  final String firebaseTokenId;
  SendAcceptOfNotificationMarketEvent({required this.firebaseTokenId});

  @override
  List<Object?> get props => [firebaseTokenId];
}

class GetUserNotificationEvent extends HomeEvent {
  final bool getWithPagination;
  GetUserNotificationEvent({required this.getWithPagination});

  @override
  // TODO: implement props
  List<Object?> get props => [getWithPagination];
}

class FetchAuthProductDetailsEvent extends HomeEvent {
  final String productSlug;
  const FetchAuthProductDetailsEvent(this.productSlug);

  @override
  List<Object?> get props => [productSlug];
}
