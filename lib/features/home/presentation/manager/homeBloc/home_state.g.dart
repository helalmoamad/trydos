// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomeState _$HomeStateFromJson(Map<String, dynamic> json) => HomeState(
  getAndAddCountViewOfProductStatus:
      (json['getAndAddCountViewOfProductStatus'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          k,
          $enumDecode(_$GetAndAddCountViewOfProductStatusEnumMap, e),
        ),
      ) ??
      const {},
  addItemInCartStatus: $enumDecodeNullable(
    _$AddItemInCartStatusEnumMap,
    json['addItemInCartStatus'],
  ),
  convertItemFromcartToOldCartStatus:
      $enumDecodeNullable(
        _$ConvertItemFromcartToOldCartStatusEnumMap,
        json['convertItemFromcartToOldCartStatus'],
      ) ??
      ConvertItemFromcartToOldCartStatus.init,
  hideItemInOldCartStatus: $enumDecodeNullable(
    _$HideItemInOldCartStatusEnumMap,
    json['hideItemInOldCartStatus'],
  ),
  updateEmailappNotificationStatus: $enumDecodeNullable(
    _$UpdateEmailappNotificationStatusEnumMap,
    json['updateEmailappNotificationStatus'],
  ),
  tapCommentIndex: (json['tapCommentIndex'] as num?)?.toInt() ?? -1,
  createCommentRatingStatus:
      $enumDecodeNullable(
        _$CreateCommentRatingStatusEnumMap,
        json['createCommentRatingStatus'],
      ) ??
      CreateCommentRatingStatus.init,
  updateWhatsappNotificationStatus: $enumDecodeNullable(
    _$UpdateWhatsappNotificationStatusEnumMap,
    json['updateWhatsappNotificationStatus'],
  ),
  translateCommentStatus:
      $enumDecodeNullable(
        _$TranslateCommentStatusEnumMap,
        json['translateCommentStatus'],
      ) ??
      TranslateCommentStatus.init,
  changeSizesForEveryProduct: $enumDecodeNullable(
    _$ChangeSizesForEveryProductEnumMap,
    json['changeSizesForEveryProduct'],
  ),
  getFqaCommentsPaginationModel:
      (json['getFqaCommentsPaginationModel'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          k,
          PaginationModel<FqaComment>.fromJson(
            e as Map<String, dynamic>,
            (value) => FqaComment.fromJson(value as Map<String, dynamic>),
          ),
        ),
      ),
  getBuyersCommentsPaginationModel:
      (json['getBuyersCommentsPaginationModel'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          k,
          PaginationModel<BuyersComment>.fromJson(
            e as Map<String, dynamic>,
            (value) => BuyersComment.fromJson(value as Map<String, dynamic>),
          ),
        ),
      ),
  getOrderRatingComments:
      (json['getOrderRatingComments'] as List<dynamic>?)
          ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  uploadUserPhotoCloudinaryStatus: $enumDecodeNullable(
    _$UploadUserPhotoCloudinaryStatusEnumMap,
    json['uploadUserPhotoCloudinaryStatus'],
  ),
  searchWithOutFilterOffset:
      (json['searchWithOutFilterOffset'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
  updateProfileStatus: $enumDecodeNullable(
    _$UpdateProfileStatusEnumMap,
    json['updateProfileStatus'],
  ),
  addProductIdToSaveRedeemTimerStatus:
      $enumDecodeNullable(
        _$AddProductIdToSaveRedeemTimerStatusEnumMap,
        json['addProductIdToSaveRedeemTimerStatus'],
      ) ??
      AddProductIdToSaveRedeemTimerStatus.init,
  getAllowedCountriesStatus: $enumDecodeNullable(
    _$GetAllowedCountriesStatusEnumMap,
    json['getAllowedCountriesStatus'],
  ),
  getProductDetailWithoutSimilarRelatedProductsStatus:
      $enumDecodeNullable(
        _$GetProductDetailWithoutSimilarRelatedProductsStatusEnumMap,
        json['getProductDetailWithoutSimilarRelatedProductsStatus'],
      ) ??
      GetProductDetailWithoutSimilarRelatedProductsStatus.init,
  getStartingSettingsStatus:
      $enumDecodeNullable(
        _$GetStartingSettingsStatusEnumMap,
        json['getStartingSettingsStatus'],
      ) ??
      GetStartingSettingsStatus.init,
  relatedProducts: (json['relatedProducts'] as List<dynamic>?)
      ?.map((e) => Products.fromJson(e as Map<String, dynamic>))
      .toList(),
  currentSelectedColorForEveryProductStatus: $enumDecodeNullable(
    _$CurrentSelectedColorForEveryProductStatusEnumMap,
    json['currentSelectedColorForEveryProductStatus'],
  ),
  isChangedvariationWhenQtyZero:
      json['isChangedvariationWhenQtyZero'] as bool? ?? false,
  getOrderRatingStatus:
      $enumDecodeNullable(
        _$GetOrderRatingStatusEnumMap,
        json['getOrderRatingStatus'],
      ) ??
      GetOrderRatingStatus.init,
  getFullProductDetailsStatus:
      $enumDecodeNullable(
        _$GetFullProductDetailsStatusEnumMap,
        json['getFullProductDetailsStatus'],
      ) ??
      GetFullProductDetailsStatus.init,
  getRelatedProductsStatus:
      $enumDecodeNullable(
        _$GetRelatedProductsStatusEnumMap,
        json['getRelatedProductsStatus'],
      ) ??
      GetRelatedProductsStatus.init,
  startingSetting: json['startingSetting'] == null
      ? null
      : StartingSetting.fromJson(
          json['startingSetting'] as Map<String, dynamic>,
        ),
  sizesForEachColor:
      (json['sizesForEachColor'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  colorsForEachProduct:
      (json['colorsForEachProduct'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  colorsQuantitiesForEachProduct:
      (json['colorsQuantitiesForEachProduct'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  sizesQuantitiesForEachColor:
      (json['sizesQuantitiesForEachColor'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  isVariantRequestNotification:
      (json['isVariantRequestNotification'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  deleteItemInCartStatus: $enumDecodeNullable(
    _$DeleteItemInCartStatusEnumMap,
    json['deleteItemInCartStatus'],
  ),
  oldcartCollection: (json['oldcartCollection'] as List<dynamic>?)
      ?.map((e) => OldCart.fromJson(e as Map<String, dynamic>))
      .toList(),
  enableAddToCardAfterChangeVariantZero: $enumDecodeNullable(
    _$EnableAddToCardAfterChangeVariantZeroEnumMap,
    json['enableAddToCardAfterChangeVariantZero'],
  ),
  getCurrenciesForWalletStatus:
      $enumDecodeNullable(
        _$GetCurrenciesForWalletStatusEnumMap,
        json['getCurrenciesForWalletStatus'],
      ) ??
      GetCurrenciesForWalletStatus.init,
  walletCurrencies: json['walletCurrencies'] == null
      ? null
      : CurrenciesForWalletResponseModel.fromJson(
          json['walletCurrencies'] as Map<String, dynamic>,
        ),
  getOldCartItemsStatus:
      $enumDecodeNullable(
        _$GetOLdCartItemsStatusEnumMap,
        json['getOldCartItemsStatus'],
      ) ??
      GetOLdCartItemsStatus.init,
  getOldCartModel: json['getOldCartModel'] == null
      ? null
      : GetOldCartModel.fromJson(
          json['getOldCartModel'] as Map<String, dynamic>,
        ),
  countryCoordinatesBorders:
      (json['countryCoordinatesBorders'] as List<dynamic>?)
          ?.map((e) => geod.LatLng.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  getUserNotificationModel: json['getUserNotificationModel'] == null
      ? null
      : PaginationModel<NotificationItemModel>.fromJson(
          json['getUserNotificationModel'] as Map<String, dynamic>,
          (value) =>
              NotificationItemModel.fromJson(value as Map<String, dynamic>),
        ),
  checkAvailabilityProductCartModel:
      json['checkAvailabilityProductCartModel'] == null
      ? null
      : CheckAvailabilityProductCartModel.fromJson(
          json['checkAvailabilityProductCartModel'] as Map<String, dynamic>,
        ),
  currentPage: (json['currentPage'] as num?)?.toInt() ?? 0,
  productStatus: (json['productStatus'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(
      k,
      $enumDecode(
        _$GetProductDetailWithoutSimilarRelatedProductsStatusEnumMap,
        e,
      ),
    ),
  ),
  updateItemInCartStatus: $enumDecodeNullable(
    _$UpdateItemInCartStatusEnumMap,
    json['updateItemInCartStatus'],
  ),
  getCartShippingItemsModel: json['getCartShippingItemsModel'] == null
      ? null
      : GetCartShippingItemsModel.fromJson(
          json['getCartShippingItemsModel'] as Map<String, dynamic>,
        ),
  reRequestTheseProductListingInBoutiques:
      (json['reRequestTheseProductListingInBoutiques'] as Map<String, dynamic>?)
          ?.map((k, e) => MapEntry(k, e as bool)) ??
      const {},
  reRequestProductWithFilters:
      (json['reRequestProductWithFilters'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as bool),
      ) ??
      const {},
  getProductListingStatus:
      $enumDecodeNullable(
        _$GetProductListingStatusEnumMap,
        json['getProductListingStatus'],
      ) ??
      GetProductListingStatus.init,
  selectedCollection: (json['selectedCollection'] as num?)?.toInt(),
  productContentForStatusOfOpeningProductDetailsDirectly:
      json['productContentForStatusOfOpeningProductDetailsDirectly'] == null
      ? null
      : Products.fromJson(
          json['productContentForStatusOfOpeningProductDetailsDirectly']
              as Map<String, dynamic>,
        ),
  cartCollection:
      (json['cartCollection'] as List<dynamic>?)
          ?.map((e) => Cart.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  getStoriesForProductStatus:
      $enumDecodeNullable(
        _$GetStoriesForProductStatusEnumMap,
        json['getStoriesForProductStatus'],
      ) ??
      GetStoriesForProductStatus.init,
  currentColorSizeForCart:
      (json['currentColorSizeForCart'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
  currentQuantityForCart:
      (json['currentQuantityForCart'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          k,
          (e as List<dynamic>).map((e) => (e as num).toInt()).toList(),
        ),
      ),
  addVariationToCartId:
      (json['addVariationToCartId'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, Map<String, String>.from(e as Map)),
      ) ??
      const {},
  addImagesToProductIdForCart:
      (json['addImagesToProductIdForCart'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          k,
          (e as Map<String, dynamic>).map(
            (k, e) => MapEntry(
              int.parse(k),
              (e as List<dynamic>)
                  .map(
                    (e) =>
                        (e as List<dynamic>).map((e) => e as String).toList(),
                  )
                  .toList(),
            ),
          ),
        ),
      ) ??
      const {},
  searchHistory: (json['searchHistory'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  getAllowedCountriesModel: json['getAllowedCountriesModel'] == null
      ? null
      : GetAllowedCountriesModel.fromJson(
          json['getAllowedCountriesModel'] as Map<String, dynamic>,
        ),
  cartIdsHurryUPTimerStarted:
      (json['cartIdsHurryUPTimerStarted'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
  listitemForAddToCart: (json['listitemForAddToCart'] as List<dynamic>?)
      ?.map((e) => ImageForAddToCart.fromJson(e as Map<String, dynamic>))
      .toList(),
  getCurrencyForCountryModel: json['getCurrencyForCountryModel'] == null
      ? null
      : GetCurrencyForCountryModel.fromJson(
          json['getCurrencyForCountryModel'] as Map<String, dynamic>,
        ),
  storiesCollections:
      (json['storiesCollections'] as List<dynamic>?)
          ?.map((e) => CollectionStoryModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  selectedVideoStatus:
      $enumDecodeNullable(
        _$SelectedVideoStatusEnumMap,
        json['selectedVideoStatus'],
      ) ??
      SelectedVideoStatus.init,
  storyLink: json['storyLink'] as String?,
  errorMessage: json['errorMessage'] as String?,
  finishGetAllStory: json['finishGetAllStory'] as bool? ?? false,
  storyOffset: (json['storyOffset'] as num?)?.toInt() ?? 0,
  getStoryWithPagintionStatusLoading:
      json['getStoryWithPagintionStatusLoading'] as bool? ?? false,
  currentStoryInEachCollection:
      (json['currentStoryInEachCollection'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(int.parse(k), (e as num?)?.toInt()),
      ) ??
      const {},
  productIdToSaveRedeemTimer:
      (json['productIdToSaveRedeemTimer'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  popularSearchTerm: (json['popularSearchTerm'] as List<dynamic>?)
      ?.map((e) => PopularSearchTerm.fromJson(e as Map<String, dynamic>))
      .toList(),
  updateOrderCommentRatingStatus:
      $enumDecodeNullable(
        _$UpdateOrderCommentRatingStatusEnumMap,
        json['updateOrderCommentRatingStatus'],
      ) ??
      UpdateOrderCommentRatingStatus.init,
  updateLikeCommentRatingStatus:
      $enumDecodeNullable(
        _$UpdateLikeCommentRatingStatusEnumMap,
        json['updateLikeCommentRatingStatus'],
      ) ??
      UpdateLikeCommentRatingStatus.init,
  deleteOrderCommentRatingStatus:
      $enumDecodeNullable(
        _$DeleteOrderCommentRatingStatusEnumMap,
        json['deleteOrderCommentRatingStatus'],
      ) ??
      DeleteOrderCommentRatingStatus.init,
  getCartOverviewStatus:
      $enumDecodeNullable(
        _$GetCartOverviewStatusEnumMap,
        json['getCartOverviewStatus'],
      ) ??
      GetCartOverviewStatus.init,
  checkAvailabilityProductCartStatus:
      $enumDecodeNullable(
        _$CheckAvailabilityProductCartStatusEnumMap,
        json['checkAvailabilityProductCartStatus'],
      ) ??
      CheckAvailabilityProductCartStatus.init,
  statusCodeOfCommentProcess:
      json['statusCodeOfCommentProcess'] as String? ?? "",
  currentSlugToRefreshFromNotification:
      json['currentSlugToRefreshFromNotification'] as String?,
  getCartItemsStatus:
      $enumDecodeNullable(
        _$GetCartItemsStatusEnumMap,
        json['getCartItemsStatus'],
      ) ??
      GetCartItemsStatus.init,
  checkWithGetCartStatus:
      $enumDecodeNullable(
        _$CheckWithGetCartStatusEnumMap,
        json['checkWithGetCartStatus'],
      ) ??
      CheckWithGetCartStatus.init,
  addOrRemoveLikeOfProductStatus:
      $enumDecodeNullable(
        _$AddOrRemoveLikeOfProductStatusEnumMap,
        json['addOrRemoveLikeOfProductStatus'],
      ) ??
      AddOrRemoveLikeOfProductStatus.init,
  getProductListingPaginationWithoutFiltersModel:
      (json['getProductListingPaginationWithoutFiltersModel']
              as Map<String, dynamic>?)
          ?.map(
            (k, e) => MapEntry(
              k,
              PaginationModel<Products>.fromJson(
                e as Map<String, dynamic>,
                (value) => Products.fromJson(value as Map<String, dynamic>),
              ),
            ),
          ) ??
      const {},
  currentSelectedColorForEveryProduct:
      (json['currentSelectedColorForEveryProduct'] as Map<String, dynamic>?)
          ?.map((k, e) => MapEntry(k, (e as num).toInt())) ??
      const {},
  notificationTypeForProductModel:
      json['notificationTypeForProductModel'] == null
      ? null
      : NotificationTypeForProductModel.fromJson(
          json['notificationTypeForProductModel'] as Map<String, dynamic>,
        ),
  getNotificationTypeProductStatus: $enumDecodeNullable(
    _$GetNotificationTypeProductStatusEnumMap,
    json['getNotificationTypeProductStatus'],
  ),
  likeForReplayComment: json['likeForReplayComment'] as bool?,
  currentHeightWhenAddToBag:
      (json['currentHeightWhenAddToBag'] as num?)?.toInt() ?? 0,
  currentIndexForUpdateCart: (json['currentIndexForUpdateCart'] as num?)
      ?.toInt(),
  getCountryBoundaryByIsoStatus: $enumDecodeNullable(
    _$GetCountryBoundaryByIsoStatusEnumMap,
    json['getCountryBoundaryByIsoStatus'],
  ),
  userInfo: json['userInfo'] == null
      ? null
      : User.fromJson(json['userInfo'] as Map<String, dynamic>),
  finishLoadingAfterChangedVariationWhenQtyZero:
      json['finishLoadingAfterChangedVariationWhenQtyZero'] as bool?,
  listOfErrorSendedToMobileErrorLog:
      (json['listOfErrorSendedToMobileErrorLog'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  cachedProductWithoutRelatedProductsModel:
      (json['cachedProductWithoutRelatedProductsModel']
              as Map<String, dynamic>?)
          ?.map(
            (k, e) => MapEntry(
              k,
              GetProductDetailWithoutRelatedProductsModel.fromJson(
                e as Map<String, dynamic>,
              ),
            ),
          ) ??
      const {},
  getFirebaseSettingForNotificationStatus: $enumDecodeNullable(
    _$GetFirebaseSettingForNotificationStatusEnumMap,
    json['getFirebaseSettingForNotificationStatus'],
  ),
  firebaseSettingForNotificationModel:
      json['firebaseSettingForNotificationModel'] == null
      ? null
      : FirebaseSettingForNotificationModel.fromJson(
          json['firebaseSettingForNotificationModel'] as Map<String, dynamic>,
        ),
  authProductDetailsStatus:
      $enumDecodeNullable(
        _$AuthProductDetailsStatusEnumMap,
        json['authProductDetailsStatus'],
      ) ??
      AuthProductDetailsStatus.init,
  authProductDetailsModel: json['authProductDetailsModel'] == null
      ? null
      : GetAuthProductDetailsModel.fromJson(
          json['authProductDetailsModel'] as Map<String, dynamic>,
        ),
  reportingAboutStory:
      $enumDecodeNullable(
        _$ReportingAboutStoryEnumMap,
        json['reportingAboutStory'],
      ) ??
      ReportingAboutStory.init,
  getDeliveredOrdersResponseStatus:
      $enumDecodeNullable(
        _$GetDeliveredOrdersResponseStatusEnumMap,
        json['getDeliveredOrdersResponseStatus'],
      ) ??
      GetDeliveredOrdersResponseStatus.init,
  deliveredOrdersResponse: json['deliveredOrdersResponse'] == null
      ? null
      : DeliveredOrdersResponse.fromJson(
          json['deliveredOrdersResponse'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$HomeStateToJson(HomeState instance) => <String, dynamic>{
  'deliveredOrdersResponse': instance.deliveredOrdersResponse?.toJson(),
  'reportingAboutStory':
      _$ReportingAboutStoryEnumMap[instance.reportingAboutStory]!,
  'getDeliveredOrdersResponseStatus':
      _$GetDeliveredOrdersResponseStatusEnumMap[instance
          .getDeliveredOrdersResponseStatus]!,
  'getFirebaseSettingForNotificationStatus':
      _$GetFirebaseSettingForNotificationStatusEnumMap[instance
          .getFirebaseSettingForNotificationStatus],
  'getCountryBoundaryByIsoStatus':
      _$GetCountryBoundaryByIsoStatusEnumMap[instance
          .getCountryBoundaryByIsoStatus],
  'firebaseSettingForNotificationModel': instance
      .firebaseSettingForNotificationModel
      ?.toJson(),
  'deleteOrderCommentRatingStatus':
      _$DeleteOrderCommentRatingStatusEnumMap[instance
          .deleteOrderCommentRatingStatus]!,
  'updateOrderCommentRatingStatus':
      _$UpdateOrderCommentRatingStatusEnumMap[instance
          .updateOrderCommentRatingStatus]!,
  'updateLikeCommentRatingStatus':
      _$UpdateLikeCommentRatingStatusEnumMap[instance
          .updateLikeCommentRatingStatus]!,
  'updateProfileStatus':
      _$UpdateProfileStatusEnumMap[instance.updateProfileStatus],
  'getOrderRatingStatus':
      _$GetOrderRatingStatusEnumMap[instance.getOrderRatingStatus]!,
  'getAllowedCountriesStatus':
      _$GetAllowedCountriesStatusEnumMap[instance.getAllowedCountriesStatus],
  'getCurrenciesForWalletStatus':
      _$GetCurrenciesForWalletStatusEnumMap[instance
          .getCurrenciesForWalletStatus]!,
  'walletCurrencies': instance.walletCurrencies?.toJson(),
  'getFqaCommentsPaginationModel': instance.getFqaCommentsPaginationModel?.map(
    (k, e) => MapEntry(k, e.toJson((value) => value.toJson())),
  ),
  'getBuyersCommentsPaginationModel': instance.getBuyersCommentsPaginationModel
      ?.map((k, e) => MapEntry(k, e.toJson((value) => value.toJson()))),
  'getStartingSettingsStatus':
      _$GetStartingSettingsStatusEnumMap[instance.getStartingSettingsStatus]!,
  'relatedProducts': instance.relatedProducts?.map((e) => e.toJson()).toList(),
  'currentSelectedColorForEveryProduct':
      instance.currentSelectedColorForEveryProduct,
  'currentSlugToRefreshFromNotification':
      instance.currentSlugToRefreshFromNotification,
  'userInfo': instance.userInfo?.toJson(),
  'createCommentRatingStatus':
      _$CreateCommentRatingStatusEnumMap[instance.createCommentRatingStatus]!,
  'storiesCollections': instance.storiesCollections
      .map((e) => e.toJson())
      .toList(),
  'currentPage': instance.currentPage,
  'tapCommentIndex': instance.tapCommentIndex,
  'currentHeightWhenAddToBag': instance.currentHeightWhenAddToBag,
  'selectedVideoStatus':
      _$SelectedVideoStatusEnumMap[instance.selectedVideoStatus]!,
  'storyOffset': instance.storyOffset,
  'getStoryWithPagintionStatusLoading':
      instance.getStoryWithPagintionStatusLoading,
  'finishGetAllStory': instance.finishGetAllStory,
  'getOrderRatingComments': instance.getOrderRatingComments
      .map((e) => e.toJson())
      .toList(),
  'storyLink': instance.storyLink,
  'translateCommentStatus':
      _$TranslateCommentStatusEnumMap[instance.translateCommentStatus],
  'statusCodeOfCommentProcess': instance.statusCodeOfCommentProcess,
  'selectedCollection': instance.selectedCollection,
  'currentStoryInEachCollection': instance.currentStoryInEachCollection.map(
    (k, e) => MapEntry(k.toString(), e),
  ),
  'errorMessage': instance.errorMessage,
  'addProductIdToSaveRedeemTimerStatus':
      _$AddProductIdToSaveRedeemTimerStatusEnumMap[instance
          .addProductIdToSaveRedeemTimerStatus],
  'currentSelectedColorForEveryProductStatus':
      _$CurrentSelectedColorForEveryProductStatusEnumMap[instance
          .currentSelectedColorForEveryProductStatus],
  'uploadUserPhotoCloudinaryStatus':
      _$UploadUserPhotoCloudinaryStatusEnumMap[instance
          .uploadUserPhotoCloudinaryStatus],
  'productIdToSaveRedeemTimer': instance.productIdToSaveRedeemTimer,
  'enableAddToCardAfterChangeVariantZero':
      _$EnableAddToCardAfterChangeVariantZeroEnumMap[instance
          .enableAddToCardAfterChangeVariantZero],
  'isChangedvariationWhenQtyZero': instance.isChangedvariationWhenQtyZero,
  'convertItemFromcartToOldCartStatus':
      _$ConvertItemFromcartToOldCartStatusEnumMap[instance
          .convertItemFromcartToOldCartStatus]!,
  'getNotificationTypeProductStatus':
      _$GetNotificationTypeProductStatusEnumMap[instance
          .getNotificationTypeProductStatus],
  'hideItemInOldCartStatus':
      _$HideItemInOldCartStatusEnumMap[instance.hideItemInOldCartStatus],
  'notificationTypeForProductModel': instance.notificationTypeForProductModel
      ?.toJson(),
  'getAndAddCountViewOfProductStatus': instance
      .getAndAddCountViewOfProductStatus
      .map(
        (k, e) => MapEntry(k, _$GetAndAddCountViewOfProductStatusEnumMap[e]!),
      ),
  'popularSearchTerm': instance.popularSearchTerm
      ?.map((e) => e.toJson())
      .toList(),
  'getUserNotificationModel': instance.getUserNotificationModel?.toJson(
    (value) => value.toJson(),
  ),
  'getCartOverviewStatus':
      _$GetCartOverviewStatusEnumMap[instance.getCartOverviewStatus],
  'checkAvailabilityProductCartModel': instance
      .checkAvailabilityProductCartModel
      ?.toJson(),
  'checkAvailabilityProductCartStatus':
      _$CheckAvailabilityProductCartStatusEnumMap[instance
          .checkAvailabilityProductCartStatus],
  'listitemForAddToCart': instance.listitemForAddToCart
      ?.map((e) => e.toJson())
      .toList(),
  'getAllowedCountriesModel': instance.getAllowedCountriesModel?.toJson(),
  'getCurrencyForCountryModel': instance.getCurrencyForCountryModel?.toJson(),
  'addItemInCartStatus':
      _$AddItemInCartStatusEnumMap[instance.addItemInCartStatus],
  'updateItemInCartStatus':
      _$UpdateItemInCartStatusEnumMap[instance.updateItemInCartStatus],
  'deleteItemInCartStatus':
      _$DeleteItemInCartStatusEnumMap[instance.deleteItemInCartStatus],
  'addOrRemoveLikeOfProductStatus':
      _$AddOrRemoveLikeOfProductStatusEnumMap[instance
          .addOrRemoveLikeOfProductStatus]!,
  'countryCoordinatesBorders': instance.countryCoordinatesBorders
      .map((e) => e.toJson())
      .toList(),
  'searchHistory': instance.searchHistory,
  'listOfErrorSendedToMobileErrorLog':
      instance.listOfErrorSendedToMobileErrorLog,
  'searchWithOutFilterOffset': instance.searchWithOutFilterOffset,
  'addImagesToProductIdForCart': instance.addImagesToProductIdForCart.map(
    (k, e) => MapEntry(k, e.map((k, e) => MapEntry(k.toString(), e))),
  ),
  'addVariationToCartId': instance.addVariationToCartId,
  'productStatus': instance.productStatus?.map(
    (k, e) => MapEntry(
      k,
      _$GetProductDetailWithoutSimilarRelatedProductsStatusEnumMap[e]!,
    ),
  ),
  'cartCollection': instance.cartCollection?.map((e) => e.toJson()).toList(),
  'cartIdsHurryUPTimerStarted': instance.cartIdsHurryUPTimerStarted,
  'updateEmailappNotificationStatus':
      _$UpdateEmailappNotificationStatusEnumMap[instance
          .updateEmailappNotificationStatus],
  'updateWhatsappNotificationStatus':
      _$UpdateWhatsappNotificationStatusEnumMap[instance
          .updateWhatsappNotificationStatus],
  'oldcartCollection': instance.oldcartCollection
      ?.map((e) => e.toJson())
      .toList(),
  'reRequestTheseProductListingInBoutiques':
      instance.reRequestTheseProductListingInBoutiques,
  'reRequestProductWithFilters': instance.reRequestProductWithFilters,
  'getProductDetailWithoutSimilarRelatedProductsStatus':
      _$GetProductDetailWithoutSimilarRelatedProductsStatusEnumMap[instance
          .getProductDetailWithoutSimilarRelatedProductsStatus]!,
  'getFullProductDetailsStatus':
      _$GetFullProductDetailsStatusEnumMap[instance
          .getFullProductDetailsStatus]!,
  'getRelatedProductsStatus':
      _$GetRelatedProductsStatusEnumMap[instance.getRelatedProductsStatus]!,
  'getCartItemsStatus':
      _$GetCartItemsStatusEnumMap[instance.getCartItemsStatus]!,
  'checkWithGetCartStatus':
      _$CheckWithGetCartStatusEnumMap[instance.checkWithGetCartStatus]!,
  'getOldCartItemsStatus':
      _$GetOLdCartItemsStatusEnumMap[instance.getOldCartItemsStatus]!,
  'productContentForStatusOfOpeningProductDetailsDirectly': instance
      .productContentForStatusOfOpeningProductDetailsDirectly
      ?.toJson(),
  'getProductListingStatus':
      _$GetProductListingStatusEnumMap[instance.getProductListingStatus]!,
  'getStoriesForProductStatus':
      _$GetStoriesForProductStatusEnumMap[instance.getStoriesForProductStatus]!,
  'sizesForEachColor': instance.sizesForEachColor,
  'colorsForEachProduct': instance.colorsForEachProduct,
  'sizesQuantitiesForEachColor': instance.sizesQuantitiesForEachColor,
  'colorsQuantitiesForEachProduct': instance.colorsQuantitiesForEachProduct,
  'isVariantRequestNotification': instance.isVariantRequestNotification,
  'finishLoadingAfterChangedVariationWhenQtyZero':
      instance.finishLoadingAfterChangedVariationWhenQtyZero,
  'getProductListingPaginationWithoutFiltersModel': instance
      .getProductListingPaginationWithoutFiltersModel
      .map((k, e) => MapEntry(k, e.toJson((value) => value.toJson()))),
  'getCartShippingItemsModel': instance.getCartShippingItemsModel?.toJson(),
  'getOldCartModel': instance.getOldCartModel?.toJson(),
  'changeSizesForEveryProduct':
      _$ChangeSizesForEveryProductEnumMap[instance.changeSizesForEveryProduct],
  'currentIndexForUpdateCart': instance.currentIndexForUpdateCart,
  'startingSetting': instance.startingSetting?.toJson(),
  'currentColorSizeForCart': instance.currentColorSizeForCart,
  'currentQuantityForCart': instance.currentQuantityForCart,
  'cachedProductWithoutRelatedProductsModel': instance
      .cachedProductWithoutRelatedProductsModel
      .map((k, e) => MapEntry(k, e.toJson())),
  'likeForReplayComment': instance.likeForReplayComment,
  'authProductDetailsStatus':
      _$AuthProductDetailsStatusEnumMap[instance.authProductDetailsStatus]!,
  'authProductDetailsModel': instance.authProductDetailsModel?.toJson(),
};

const _$GetAndAddCountViewOfProductStatusEnumMap = {
  GetAndAddCountViewOfProductStatus.init: 'init',
  GetAndAddCountViewOfProductStatus.loading: 'loading',
  GetAndAddCountViewOfProductStatus.success: 'success',
  GetAndAddCountViewOfProductStatus.failure: 'failure',
};

const _$AddItemInCartStatusEnumMap = {
  AddItemInCartStatus.init: 'init',
  AddItemInCartStatus.loading: 'loading',
  AddItemInCartStatus.success: 'success',
  AddItemInCartStatus.failure: 'failure',
};

const _$ConvertItemFromcartToOldCartStatusEnumMap = {
  ConvertItemFromcartToOldCartStatus.init: 'init',
  ConvertItemFromcartToOldCartStatus.loading: 'loading',
  ConvertItemFromcartToOldCartStatus.success: 'success',
  ConvertItemFromcartToOldCartStatus.failure: 'failure',
};

const _$HideItemInOldCartStatusEnumMap = {
  HideItemInOldCartStatus.init: 'init',
  HideItemInOldCartStatus.loading: 'loading',
  HideItemInOldCartStatus.success: 'success',
  HideItemInOldCartStatus.failure: 'failure',
};

const _$UpdateEmailappNotificationStatusEnumMap = {
  UpdateEmailappNotificationStatus.init: 'init',
  UpdateEmailappNotificationStatus.loading: 'loading',
  UpdateEmailappNotificationStatus.success: 'success',
  UpdateEmailappNotificationStatus.failure: 'failure',
};

const _$CreateCommentRatingStatusEnumMap = {
  CreateCommentRatingStatus.init: 'init',
  CreateCommentRatingStatus.loading: 'loading',
  CreateCommentRatingStatus.success: 'success',
  CreateCommentRatingStatus.failure: 'failure',
};

const _$UpdateWhatsappNotificationStatusEnumMap = {
  UpdateWhatsappNotificationStatus.init: 'init',
  UpdateWhatsappNotificationStatus.loading: 'loading',
  UpdateWhatsappNotificationStatus.success: 'success',
  UpdateWhatsappNotificationStatus.failure: 'failure',
};

const _$TranslateCommentStatusEnumMap = {
  TranslateCommentStatus.init: 'init',
  TranslateCommentStatus.loading: 'loading',
  TranslateCommentStatus.success: 'success',
  TranslateCommentStatus.failure: 'failure',
};

const _$ChangeSizesForEveryProductEnumMap = {
  ChangeSizesForEveryProduct.init: 'init',
  ChangeSizesForEveryProduct.loading: 'loading',
  ChangeSizesForEveryProduct.success: 'success',
  ChangeSizesForEveryProduct.failure: 'failure',
};

const _$UploadUserPhotoCloudinaryStatusEnumMap = {
  UploadUserPhotoCloudinaryStatus.init: 'init',
  UploadUserPhotoCloudinaryStatus.loading: 'loading',
  UploadUserPhotoCloudinaryStatus.success: 'success',
  UploadUserPhotoCloudinaryStatus.failure: 'failure',
};

const _$UpdateProfileStatusEnumMap = {
  UpdateProfileStatus.init: 'init',
  UpdateProfileStatus.loading: 'loading',
  UpdateProfileStatus.success: 'success',
  UpdateProfileStatus.failure: 'failure',
};

const _$AddProductIdToSaveRedeemTimerStatusEnumMap = {
  AddProductIdToSaveRedeemTimerStatus.init: 'init',
  AddProductIdToSaveRedeemTimerStatus.on: 'on',
  AddProductIdToSaveRedeemTimerStatus.off: 'off',
};

const _$GetAllowedCountriesStatusEnumMap = {
  GetAllowedCountriesStatus.init: 'init',
  GetAllowedCountriesStatus.loading: 'loading',
  GetAllowedCountriesStatus.success: 'success',
  GetAllowedCountriesStatus.failure: 'failure',
};

const _$GetProductDetailWithoutSimilarRelatedProductsStatusEnumMap = {
  GetProductDetailWithoutSimilarRelatedProductsStatus.init: 'init',
  GetProductDetailWithoutSimilarRelatedProductsStatus.loading: 'loading',
  GetProductDetailWithoutSimilarRelatedProductsStatus.success: 'success',
  GetProductDetailWithoutSimilarRelatedProductsStatus.failure: 'failure',
};

const _$GetStartingSettingsStatusEnumMap = {
  GetStartingSettingsStatus.init: 'init',
  GetStartingSettingsStatus.loading: 'loading',
  GetStartingSettingsStatus.success: 'success',
  GetStartingSettingsStatus.failure: 'failure',
};

const _$CurrentSelectedColorForEveryProductStatusEnumMap = {
  CurrentSelectedColorForEveryProductStatus.init: 'init',
  CurrentSelectedColorForEveryProductStatus.loading: 'loading',
  CurrentSelectedColorForEveryProductStatus.success: 'success',
  CurrentSelectedColorForEveryProductStatus.failure: 'failure',
};

const _$GetOrderRatingStatusEnumMap = {
  GetOrderRatingStatus.init: 'init',
  GetOrderRatingStatus.loading: 'loading',
  GetOrderRatingStatus.success: 'success',
  GetOrderRatingStatus.failure: 'failure',
};

const _$GetFullProductDetailsStatusEnumMap = {
  GetFullProductDetailsStatus.init: 'init',
  GetFullProductDetailsStatus.loading: 'loading',
  GetFullProductDetailsStatus.success: 'success',
  GetFullProductDetailsStatus.failure: 'failure',
};

const _$GetRelatedProductsStatusEnumMap = {
  GetRelatedProductsStatus.init: 'init',
  GetRelatedProductsStatus.loading: 'loading',
  GetRelatedProductsStatus.success: 'success',
  GetRelatedProductsStatus.failure: 'failure',
};

const _$DeleteItemInCartStatusEnumMap = {
  DeleteItemInCartStatus.init: 'init',
  DeleteItemInCartStatus.loading: 'loading',
  DeleteItemInCartStatus.success: 'success',
  DeleteItemInCartStatus.failure: 'failure',
};

const _$EnableAddToCardAfterChangeVariantZeroEnumMap = {
  EnableAddToCardAfterChangeVariantZero.init: 'init',
  EnableAddToCardAfterChangeVariantZero.loading: 'loading',
  EnableAddToCardAfterChangeVariantZero.success: 'success',
  EnableAddToCardAfterChangeVariantZero.failure: 'failure',
};

const _$GetCurrenciesForWalletStatusEnumMap = {
  GetCurrenciesForWalletStatus.init: 'init',
  GetCurrenciesForWalletStatus.loading: 'loading',
  GetCurrenciesForWalletStatus.success: 'success',
  GetCurrenciesForWalletStatus.failure: 'failure',
};

const _$GetOLdCartItemsStatusEnumMap = {
  GetOLdCartItemsStatus.init: 'init',
  GetOLdCartItemsStatus.loading: 'loading',
  GetOLdCartItemsStatus.success: 'success',
  GetOLdCartItemsStatus.failure: 'failure',
};

const _$UpdateItemInCartStatusEnumMap = {
  UpdateItemInCartStatus.init: 'init',
  UpdateItemInCartStatus.loading: 'loading',
  UpdateItemInCartStatus.success: 'success',
  UpdateItemInCartStatus.failure: 'failure',
};

const _$GetProductListingStatusEnumMap = {
  GetProductListingStatus.init: 'init',
  GetProductListingStatus.loading: 'loading',
  GetProductListingStatus.success: 'success',
  GetProductListingStatus.failure: 'failure',
};

const _$GetStoriesForProductStatusEnumMap = {
  GetStoriesForProductStatus.init: 'init',
  GetStoriesForProductStatus.loading: 'loading',
  GetStoriesForProductStatus.success: 'success',
  GetStoriesForProductStatus.failure: 'failure',
};

const _$SelectedVideoStatusEnumMap = {
  SelectedVideoStatus.init: 'init',
  SelectedVideoStatus.loading: 'loading',
  SelectedVideoStatus.success: 'success',
  SelectedVideoStatus.failure: 'failure',
};

const _$UpdateOrderCommentRatingStatusEnumMap = {
  UpdateOrderCommentRatingStatus.init: 'init',
  UpdateOrderCommentRatingStatus.loading: 'loading',
  UpdateOrderCommentRatingStatus.success: 'success',
  UpdateOrderCommentRatingStatus.failure: 'failure',
};

const _$UpdateLikeCommentRatingStatusEnumMap = {
  UpdateLikeCommentRatingStatus.init: 'init',
  UpdateLikeCommentRatingStatus.loading: 'loading',
  UpdateLikeCommentRatingStatus.success: 'success',
  UpdateLikeCommentRatingStatus.failure: 'failure',
};

const _$DeleteOrderCommentRatingStatusEnumMap = {
  DeleteOrderCommentRatingStatus.init: 'init',
  DeleteOrderCommentRatingStatus.loading: 'loading',
  DeleteOrderCommentRatingStatus.success: 'success',
  DeleteOrderCommentRatingStatus.failure: 'failure',
};

const _$GetCartOverviewStatusEnumMap = {
  GetCartOverviewStatus.init: 'init',
  GetCartOverviewStatus.loading: 'loading',
  GetCartOverviewStatus.success: 'success',
  GetCartOverviewStatus.failure: 'failure',
};

const _$CheckAvailabilityProductCartStatusEnumMap = {
  CheckAvailabilityProductCartStatus.init: 'init',
  CheckAvailabilityProductCartStatus.loading: 'loading',
  CheckAvailabilityProductCartStatus.success: 'success',
  CheckAvailabilityProductCartStatus.failure: 'failure',
};

const _$GetCartItemsStatusEnumMap = {
  GetCartItemsStatus.init: 'init',
  GetCartItemsStatus.loading: 'loading',
  GetCartItemsStatus.success: 'success',
  GetCartItemsStatus.available: 'available',
  GetCartItemsStatus.failure: 'failure',
};

const _$CheckWithGetCartStatusEnumMap = {
  CheckWithGetCartStatus.init: 'init',
  CheckWithGetCartStatus.loading: 'loading',
  CheckWithGetCartStatus.successForCart: 'successForCart',
  CheckWithGetCartStatus.successForPlaceOrder: 'successForPlaceOrder',
  CheckWithGetCartStatus.available: 'available',
  CheckWithGetCartStatus.failure: 'failure',
};

const _$AddOrRemoveLikeOfProductStatusEnumMap = {
  AddOrRemoveLikeOfProductStatus.init: 'init',
  AddOrRemoveLikeOfProductStatus.loading: 'loading',
  AddOrRemoveLikeOfProductStatus.success: 'success',
  AddOrRemoveLikeOfProductStatus.failure: 'failure',
};

const _$GetNotificationTypeProductStatusEnumMap = {
  GetNotificationTypeProductStatus.init: 'init',
  GetNotificationTypeProductStatus.loading: 'loading',
  GetNotificationTypeProductStatus.success: 'success',
  GetNotificationTypeProductStatus.failure: 'failure',
};

const _$GetCountryBoundaryByIsoStatusEnumMap = {
  GetCountryBoundaryByIsoStatus.init: 'init',
  GetCountryBoundaryByIsoStatus.loading: 'loading',
  GetCountryBoundaryByIsoStatus.success: 'success',
  GetCountryBoundaryByIsoStatus.failure: 'failure',
};

const _$GetFirebaseSettingForNotificationStatusEnumMap = {
  GetFirebaseSettingForNotificationStatus.init: 'init',
  GetFirebaseSettingForNotificationStatus.loading: 'loading',
  GetFirebaseSettingForNotificationStatus.success: 'success',
  GetFirebaseSettingForNotificationStatus.failure: 'failure',
};

const _$AuthProductDetailsStatusEnumMap = {
  AuthProductDetailsStatus.init: 'init',
  AuthProductDetailsStatus.loading: 'loading',
  AuthProductDetailsStatus.success: 'success',
  AuthProductDetailsStatus.failure: 'failure',
};

const _$ReportingAboutStoryEnumMap = {
  ReportingAboutStory.init: 'init',
  ReportingAboutStory.loading: 'loading',
  ReportingAboutStory.success: 'success',
  ReportingAboutStory.failure: 'failure',
};

const _$GetDeliveredOrdersResponseStatusEnumMap = {
  GetDeliveredOrdersResponseStatus.init: 'init',
  GetDeliveredOrdersResponseStatus.loading: 'loading',
  GetDeliveredOrdersResponseStatus.success: 'success',
  GetDeliveredOrdersResponseStatus.failure: 'failure',
};
