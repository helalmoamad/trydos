// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomeState _$HomeStateFromJson(Map<String, dynamic> json) => HomeState(
      storiesForProduct: (json['storiesForProduct'] as List<dynamic>?)
          ?.map((e) => Story.fromJson(e as Map<String, dynamic>))
          .toList(),
      getAndAddCountViewOfProductStatus:
          (json['getAndAddCountViewOfProductStatus'] as Map<String, dynamic>?)
                  ?.map(
                (k, e) => MapEntry(k,
                    $enumDecode(_$GetAndAddCountViewOfProductStatusEnumMap, e)),
              ) ??
              const {},
      addItemInCartStatus: $enumDecodeNullable(
          _$AddItemInCartStatusEnumMap, json['addItemInCartStatus']),
      convertItemFromOldcartToCartStatus: $enumDecodeNullable(
          _$ConvertItemFromOldcartToCartStatusEnumMap,
          json['convertItemFromOldcartToCartStatus']),
      resultSearch: (json['resultSearch'] as List<dynamic>?)
              ?.map((e) => ResultSearch.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      hideItemInOldCartStatus: $enumDecodeNullable(
          _$HideItemInOldCartStatusEnumMap, json['hideItemInOldCartStatus']),
      updateEmailappNotificationStatus: $enumDecodeNullable(
          _$UpdateEmailappNotificationStatusEnumMap,
          json['updateEmailappNotificationStatus']),
      updateWhatsappNotificationStatus: $enumDecodeNullable(
          _$UpdateWhatsappNotificationStatusEnumMap,
          json['updateWhatsappNotificationStatus']),
      changeSizesForEveryProduct: $enumDecodeNullable(
          _$ChangeSizesForEveryProductEnumMap,
          json['changeSizesForEveryProduct']),
      searchWithOutFilterOffset:
          (json['searchWithOutFilterOffset'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      searchWithFilterOffset:
          (json['searchWithFilterOffset'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      getProductDetailWithoutSimilarRelatedProductsStatus: $enumDecodeNullable(
              _$GetProductDetailWithoutSimilarRelatedProductsStatusEnumMap,
              json['getProductDetailWithoutSimilarRelatedProductsStatus']) ??
          GetProductDetailWithoutSimilarRelatedProductsStatus.init,
      getStartingSettingsStatus: $enumDecodeNullable(
              _$GetStartingSettingsStatusEnumMap,
              json['getStartingSettingsStatus']) ??
          GetStartingSettingsStatus.init,
      getMainCategoriesStatus: $enumDecodeNullable(
              _$GetMainCategoriesStatusEnumMap,
              json['getMainCategoriesStatus']) ??
          GetMainCategoriesStatus.init,
      getCommentForProductStatus: $enumDecodeNullable(
              _$GetCommentForProductStatusEnumMap,
              json['getCommentForProductStatus']) ??
          GetCommentForProductStatus.init,
      editAddressToOrderStatus: $enumDecodeNullable(
          _$EditAddressToOrderStatusEnumMap, json['editAddressToOrderStatus']),
      currentSelectedColorForEveryProductStatus: $enumDecodeNullable(
          _$CurrentSelectedColorForEveryProductStatusEnumMap,
          json['currentSelectedColorForEveryProductStatus']),
      addAddressToOrderStatus: $enumDecodeNullable(
          _$AddAddressToOrderStatusEnumMap, json['addAddressToOrderStatus']),
      removeAddressToOrderStatus: $enumDecodeNullable(
          _$RemoveAddressToOrderStatusEnumMap,
          json['removeAddressToOrderStatus']),
      getFullProductDetailsStatus: $enumDecodeNullable(
              _$GetFullProductDetailsStatusEnumMap,
              json['getFullProductDetailsStatus']) ??
          GetFullProductDetailsStatus.init,
      addCommentStatus: $enumDecodeNullable(
              _$AddCommentStatusEnumMap, json['addCommentStatus']) ??
          AddCommentStatus.init,
      startingSetting: json['startingSetting'] == null
          ? null
          : StartingSetting.fromJson(
              json['startingSetting'] as Map<String, dynamic>),
      sizesForEachColor: (json['sizesForEachColor'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      colorsForEachProduct: (json['colorsForEachProduct'] as List<dynamic>?)
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
          _$DeleteItemInCartStatusEnumMap, json['deleteItemInCartStatus']),
      oldcartCollection: (json['oldcartCollection'] as List<dynamic>?)
          ?.map((e) => OldCart.fromJson(e as Map<String, dynamic>))
          .toList(),
      getOldCartItemsStatus: $enumDecodeNullable(
              _$GetOLdCartItemsStatusEnumMap, json['getOldCartItemsStatus']) ??
          GetOLdCartItemsStatus.init,
      getOldCartModel: json['getOldCartModel'] == null
          ? null
          : GetOldCartModel.fromJson(
              json['getOldCartModel'] as Map<String, dynamic>),
      isGettingProductListingWithPagination:
          json['isGettingProductListingWithPagination'] as bool? ?? false,
      isGettingProductListingWithPaginationForAppearProduct:
          json['isGettingProductListingWithPaginationForAppearProduct']
                  as bool? ??
              false,
      getProductFiltersStatus:
          (json['getProductFiltersStatus'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(
                    k, $enumDecode(_$GetProductFiltersStatusEnumMap, e)),
              ) ??
              const {},
      getProductFiltersModel:
          (json['getProductFiltersModel'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(
                    k,
                    e == null
                        ? null
                        : GetProductFiltersModel.fromJson(
                            e as Map<String, dynamic>)),
              ) ??
              const {},
      choosedFiltersByUser:
          (json['choosedFiltersByUser'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(
                    k,
                    e == null
                        ? null
                        : GetProductFiltersModel.fromJson(
                            e as Map<String, dynamic>)),
              ) ??
              const {},
      getAddressByCoordinatesModel: json['getAddressByCoordinatesModel'] == null
          ? null
          : GetAddressByCoordinatesModel.fromJson(
              json['getAddressByCoordinatesModel'] as Map<String, dynamic>),
      customerWalletModel: json['customerWalletModel'] == null
          ? null
          : CustomerWalletModel.fromJson(
              json['customerWalletModel'] as Map<String, dynamic>),
      setCustomerAddressDefaultStatus: $enumDecodeNullable(
          _$SetCustomerAddressDefaultStatusEnumMap,
          json['setCustomerAddressDefaultStatus']),
      placeOrderModel: json['placeOrderModel'] == null
          ? null
          : OrdersGroupModel.fromJson(
              json['placeOrderModel'] as Map<String, dynamic>),
      applyCouponModel: json['applyCouponModel'] == null
          ? null
          : ApplyCouponModel.fromJson(
              json['applyCouponModel'] as Map<String, dynamic>),
      getCartOverviewModel: json['getCartOverviewModel'] == null
          ? null
          : GetCartShippingItemsModel.fromJson(
              json['getCartOverviewModel'] as Map<String, dynamic>),
      getOrdersByOrderGroupIDModel: json['getOrdersByOrderGroupIDModel'] == null
          ? null
          : OrdersGroupModel.fromJson(
              json['getOrdersByOrderGroupIDModel'] as Map<String, dynamic>),
      getOrdersByCartGroupIDModel: json['getOrdersByCartGroupIDModel'] == null
          ? null
          : OrdersGroupModel.fromJson(
              json['getOrdersByCartGroupIDModel'] as Map<String, dynamic>),
      checkAvailabilityProductCartModel:
          json['checkAvailabilityProductCartModel'] == null
              ? null
              : CheckAvailabilityProductCartModel.fromJson(
                  json['checkAvailabilityProductCartModel']
                      as Map<String, dynamic>),
      appliedFiltersByUser:
          (json['appliedFiltersByUser'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(
                    k,
                    e == null
                        ? null
                        : GetProductFiltersModel.fromJson(
                            e as Map<String, dynamic>)),
              ) ??
              const {},
      currentPage: (json['currentPage'] as num?)?.toInt() ?? 0,
      productStatus: (json['productStatus'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
            k,
            $enumDecode(
                _$GetProductDetailWithoutSimilarRelatedProductsStatusEnumMap,
                e)),
      ),
      updateItemInCartStatus: $enumDecodeNullable(
          _$UpdateItemInCartStatusEnumMap, json['updateItemInCartStatus']),
      getCustomerAddressStatus: $enumDecodeNullable(
          _$GetCustomerAddressesStatusEnumMap,
          json['getCustomerAddressStatus']),
      theReplyFromGemini: json['theReplyFromGemini'] as String?,
      productITemForCart:
          (json['productITemForCart'] as Map<String, dynamic>?)?.map(
                (k, e) =>
                    MapEntry(k, Products.fromJson(e as Map<String, dynamic>)),
              ) ??
              const {},
      getCartShippingItemsModel: json['getCartShippingItemsModel'] == null
          ? null
          : GetCartShippingItemsModel.fromJson(
              json['getCartShippingItemsModel'] as Map<String, dynamic>),
      reRequestTheseBoutiques:
          (json['reRequestTheseBoutiques'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, e as bool),
              ) ??
              const {},
      getCommentForProductModel: (json['getCommentForProductModel']
                  as Map<String, dynamic>?)
              ?.map(
            (k, e) => MapEntry(k,
                GetCommentForProductModel.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
      reRequestTheseProductListingInBoutiques:
          (json['reRequestTheseProductListingInBoutiques']
                      as Map<String, dynamic>?)
                  ?.map(
                (k, e) => MapEntry(k, e as bool),
              ) ??
              const {},
      reRequestProductWithFilters:
          (json['reRequestProductWithFilters'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, e as bool),
              ) ??
              const {},
      getProductListingStatus: $enumDecodeNullable(
              _$GetProductListingStatusEnumMap,
              json['getProductListingStatus']) ??
          GetProductListingStatus.init,
      selectedCollection: (json['selectedCollection'] as num?)?.toInt(),
      productContentForStatusOfOpeningProductDetailsDirectly:
          json['productContentForStatusOfOpeningProductDetailsDirectly'] == null
              ? null
              : Products.fromJson(
                  json['productContentForStatusOfOpeningProductDetailsDirectly']
                      as Map<String, dynamic>),
      cartCollection: (json['cartCollection'] as List<dynamic>?)
              ?.map((e) => Cart.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      getProductListingWithFiltersPaginationModels: (json[
                      'getProductListingWithFiltersPaginationModels']
                  as Map<String, dynamic>?)
              ?.map(
            (k, e) => MapEntry(
                k,
                e == null
                    ? null
                    : PaginationModel<Products>.fromJson(
                        e as Map<String, dynamic>,
                        (value) =>
                            Products.fromJson(value as Map<String, dynamic>))),
          ) ??
          const {},
      getStoriesForProductStatus: $enumDecodeNullable(
              _$GetStoriesForProductStatusEnumMap,
              json['getStoriesForProductStatus']) ??
          GetStoriesForProductStatus.init,
      mainCategoriesResponseModel: json['mainCategoriesResponseModel'] == null
          ? null
          : MainCategoriesResponseModel.fromJson(
              json['mainCategoriesResponseModel'] as Map<String, dynamic>),
      sendRequestToGeminiStatus: $enumDecodeNullable(
              _$SendRequestToGeminiStatusEnumMap,
              json['sendRequestToGeminiStatus']) ??
          SendRequestToGeminiStatus.init,
      currentColorSizeForCart:
          (json['currentColorSizeForCart'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      currentQuantityForCart:
          (json['currentQuantityForCart'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
            k, (e as List<dynamic>).map((e) => (e as num).toInt()).toList()),
      ),
      addImagesToProductIdForCart:
          (json['addImagesToProductIdForCart'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(
                    k,
                    (e as Map<String, dynamic>).map(
                      (k, e) => MapEntry(
                          int.parse(k),
                          (e as List<dynamic>)
                              .map((e) => e as String)
                              .toList()),
                    )),
              ) ??
              const {},
      searchHistory: (json['searchHistory'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      cashedOrginalBoutique: json['cashedOrginalBoutique'] as bool? ?? false,
      currentAddressChoosed: (json['currentAddressChoosed'] as num?)?.toInt(),
      getAllowedCountriesModel: json['getAllowedCountriesModel'] == null
          ? null
          : GetAllowedCountriesModel.fromJson(
              json['getAllowedCountriesModel'] as Map<String, dynamic>),
      currentIndexForMainCategoryEvent:
          (json['currentIndexForMainCategoryEvent'] as num?)?.toInt() ?? -1,
      prefAppliedFilterForExtendFilter:
          json['prefAppliedFilterForExtendFilter'] == null
              ? null
              : Filter.fromJson(json['prefAppliedFilterForExtendFilter']
                  as Map<String, dynamic>),
      cartIdsHurryUPTimerStarted:
          (json['cartIdsHurryUPTimerStarted'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, (e as num).toInt()),
              ) ??
              const {},
      fromSearchForSearchWithGemini:
          json['fromSearchForSearchWithGemini'] as bool? ?? false,
      listitemForAddToCart: (json['listitemForAddToCart'] as List<dynamic>?)
          ?.map((e) => ImageForAddToCart.fromJson(e as Map<String, dynamic>))
          .toList(),
      getListOfProductsFoundedInCartStatus: $enumDecodeNullable(
              _$GetListOfProductsFoundedInCartStatusEnumMap,
              json['getListOfProductsFoundedInCartStatus']) ??
          GetListOfProductsFoundedInCartStatus.init,
      getCurrencyForCountryModel: json['getCurrencyForCountryModel'] == null
          ? null
          : GetCurrencyForCountryModel.fromJson(
              json['getCurrencyForCountryModel'] as Map<String, dynamic>),
      isExpandedForListingPage:
          json['isExpandedForListingPage'] as bool? ?? false,
      popularSearchTerm: (json['popularSearchTerm'] as List<dynamic>?)
          ?.map((e) => PopularSearchTerm.fromJson(e as Map<String, dynamic>))
          .toList(),
      getAddressByCoordinatesStatus: $enumDecodeNullable(
          _$GetAddressByCoordinatesStatusEnumMap,
          json['getAddressByCoordinatesStatus']),
      getCustomerWalletStatus: $enumDecodeNullable(
          _$GetCustomerWalletStatusEnumMap, json['getCustomerWalletStatus']),
      placeOrderStatus: $enumDecodeNullable(
              _$PlaceOrderStatusEnumMap, json['placeOrderStatus']) ??
          PlaceOrderStatus.init,
      applyCouponStatus: $enumDecodeNullable(
              _$ApplyCouponStatusEnumMap, json['applyCouponStatus']) ??
          ApplyCouponStatus.init,
      getCartOverviewStatus: $enumDecodeNullable(
              _$GetCartOverviewStatusEnumMap, json['getCartOverviewStatus']) ??
          GetCartOverviewStatus.init,
      getOrdersByOrderGroupIDStatus: $enumDecodeNullable(
              _$GetOrdersByOrderGroupIDStatusEnumMap,
              json['getOrdersByOrderGroupIDStatus']) ??
          GetOrdersByOrderGroupIDStatus.init,
      getOrdersByCartGroupIDStatus: $enumDecodeNullable(
              _$GetOrdersByCartGroupIDStatusEnumMap,
              json['getOrdersByCartGroupIDStatus']) ??
          GetOrdersByCartGroupIDStatus.init,
      checkAvailabilityProductCartStatus: $enumDecodeNullable(
              _$CheckAvailabilityProductCartStatusEnumMap,
              json['checkAvailabilityProductCartStatus']) ??
          CheckAvailabilityProductCartStatus.init,
      getAddressByTextStatus: $enumDecodeNullable(
          _$GetAddressByTextStatusEnumMap, json['getAddressByTextStatus']),
      countOfProductExpectedByFiltering:
          (json['countOfProductExpectedByFiltering'] as Map<String, dynamic>?)
              ?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
      getCartItemsStatus: $enumDecodeNullable(
              _$GetCartItemsStatusEnumMap, json['getCartItemsStatus']) ??
          GetCartItemsStatus.init,
      getProductDetailWithoutRelatedProductsModel:
          json['getProductDetailWithoutRelatedProductsModel'] == null
              ? null
              : GetProductDetailWithoutRelatedProductsModel.fromJson(
                  json['getProductDetailWithoutRelatedProductsModel']
                      as Map<String, dynamic>),
      addOrRemoveLikeOfProductStatus: $enumDecodeNullable(
              _$AddOrRemoveLikeOfProductStatusEnumMap,
              json['addOrRemoveLikeOfProductStatus']) ??
          AddOrRemoveLikeOfProductStatus.init,
      getProductListingPaginationWithoutFiltersModel:
          (json['getProductListingPaginationWithoutFiltersModel']
                      as Map<String, dynamic>?)
                  ?.map(
                (k, e) => MapEntry(
                    k,
                    PaginationModel<Products>.fromJson(
                        e as Map<String, dynamic>,
                        (value) =>
                            Products.fromJson(value as Map<String, dynamic>))),
              ) ??
              const {},
      getProductListingWithFiltersPaginationWithPrefetchModels:
          (json['getProductListingWithFiltersPaginationWithPrefetchModels']
                      as Map<String, dynamic>?)
                  ?.map(
                (k, e) => MapEntry(
                    k,
                    e == null
                        ? null
                        : PaginationModel<Products>.fromJson(
                            e as Map<String, dynamic>,
                            (value) => Products.fromJson(
                                value as Map<String, dynamic>))),
              ) ??
              const {},
      getProductFiltersWithPrefetchModel:
          (json['getProductFiltersWithPrefetchModel'] as Map<String, dynamic>?)
                  ?.map(
                (k, e) => MapEntry(
                    k,
                    e == null
                        ? null
                        : GetProductFiltersModel.fromJson(
                            e as Map<String, dynamic>)),
              ) ??
              const {},
      currentSelectedColorForEveryProduct:
          (json['currentSelectedColorForEveryProduct'] as Map<String, dynamic>?)
                  ?.map(
                (k, e) => MapEntry(k, (e as num).toInt()),
              ) ??
              const {},
      boutiquesThatDidPrefetch:
          (json['boutiquesThatDidPrefetch'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, e as bool),
              ) ??
              const {},
      notificationTypeForProductModel:
          json['notificationTypeForProductModel'] == null
              ? null
              : NotificationTypeForProductModel.fromJson(
                  json['notificationTypeForProductModel']
                      as Map<String, dynamic>),
      getNotificationTypeProductStatus: $enumDecodeNullable(
          _$GetNotificationTypeProductStatusEnumMap,
          json['getNotificationTypeProductStatus']),
      currentIndexForUpdateCart:
          (json['currentIndexForUpdateCart'] as num?)?.toInt(),
      listOfAddressInfoClassToSave:
          (json['listOfAddressInfoClassToSave'] as List<dynamic>?)
                  ?.map((e) =>
                      CustomerAddressesInfo.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              const [],
      listOfErrorSendedToMobileErrorLog:
          (json['listOfErrorSendedToMobileErrorLog'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              const [],
      boutiquesForEveryMainCategoryThatDidPrefetch:
          (json['boutiquesForEveryMainCategoryThatDidPrefetch']
                      as Map<String, dynamic>?)
                  ?.map(
                (k, e) => MapEntry(k, e as bool),
              ) ??
              const {},
      cachedProductWithoutRelatedProductsModel:
          (json['cachedProductWithoutRelatedProductsModel']
                      as Map<String, dynamic>?)
                  ?.map(
                (k, e) => MapEntry(
                    k,
                    GetProductDetailWithoutRelatedProductsModel.fromJson(
                        e as Map<String, dynamic>)),
              ) ??
              const {},
      getHomeBoutiquesPaginationObjectByMainCategory:
          (json['getHomeBoutiquesPaginationObjectByMainCategory']
                      as Map<String, dynamic>?)
                  ?.map(
                (k, e) => MapEntry(
                    k,
                    PaginationModel<boutiques_model.Boutique>.fromJson(
                        e as Map<String, dynamic>,
                        (value) => boutiques_model.Boutique.fromJson(
                            value as Map<String, dynamic>))),
              ) ??
              const {},
      getFirebaseSettingForNotificationStatus: $enumDecodeNullable(
          _$GetFirebaseSettingForNotificationStatusEnumMap,
          json['getFirebaseSettingForNotificationStatus']),
      firebaseSettingForNotificationModel:
          json['firebaseSettingForNotificationModel'] == null
              ? null
              : FirebaseSettingForNotificationModel.fromJson(
                  json['firebaseSettingForNotificationModel']
                      as Map<String, dynamic>),
    );

Map<String, dynamic> _$HomeStateToJson(HomeState instance) => <String, dynamic>{
      'boutiquesThatDidPrefetch': instance.boutiquesThatDidPrefetch,
      'getFirebaseSettingForNotificationStatus':
          _$GetFirebaseSettingForNotificationStatusEnumMap[
              instance.getFirebaseSettingForNotificationStatus],
      'firebaseSettingForNotificationModel':
          instance.firebaseSettingForNotificationModel?.toJson(),
      'boutiquesForEveryMainCategoryThatDidPrefetch':
          instance.boutiquesForEveryMainCategoryThatDidPrefetch,
      'getStartingSettingsStatus': _$GetStartingSettingsStatusEnumMap[
          instance.getStartingSettingsStatus]!,
      'currentSelectedColorForEveryProduct':
          instance.currentSelectedColorForEveryProduct,
      'getCommentForProductStatus': _$GetCommentForProductStatusEnumMap[
          instance.getCommentForProductStatus]!,
      'productITemForCart':
          instance.productITemForCart.map((k, e) => MapEntry(k, e.toJson())),
      'currentSelectedColorForEveryProductStatus':
          _$CurrentSelectedColorForEveryProductStatusEnumMap[
              instance.currentSelectedColorForEveryProductStatus],
      'convertItemFromOldcartToCartStatus':
          _$ConvertItemFromOldcartToCartStatusEnumMap[
              instance.convertItemFromOldcartToCartStatus],
      'getMainCategoriesStatus':
          _$GetMainCategoriesStatusEnumMap[instance.getMainCategoriesStatus]!,
      'getNotificationTypeProductStatus':
          _$GetNotificationTypeProductStatusEnumMap[
              instance.getNotificationTypeProductStatus],
      'hideItemInOldCartStatus':
          _$HideItemInOldCartStatusEnumMap[instance.hideItemInOldCartStatus],
      'getCustomerAddressStatus': _$GetCustomerAddressesStatusEnumMap[
          instance.getCustomerAddressStatus],
      'notificationTypeForProductModel':
          instance.notificationTypeForProductModel?.toJson(),
      'getAndAddCountViewOfProductStatus':
          instance.getAndAddCountViewOfProductStatus.map((k, e) =>
              MapEntry(k, _$GetAndAddCountViewOfProductStatusEnumMap[e]!)),
      'popularSearchTerm':
          instance.popularSearchTerm?.map((e) => e.toJson()).toList(),
      'setCustomerAddressDefaultStatus':
          _$SetCustomerAddressDefaultStatusEnumMap[
              instance.setCustomerAddressDefaultStatus],
      'resultSearch': instance.resultSearch?.map((e) => e.toJson()).toList(),
      'getAddressByCoordinatesModel':
          instance.getAddressByCoordinatesModel?.toJson(),
      'customerWalletModel': instance.customerWalletModel?.toJson(),
      'placeOrderModel': instance.placeOrderModel?.toJson(),
      'placeOrderStatus': _$PlaceOrderStatusEnumMap[instance.placeOrderStatus],
      'applyCouponModel': instance.applyCouponModel?.toJson(),
      'applyCouponStatus':
          _$ApplyCouponStatusEnumMap[instance.applyCouponStatus],
      'getCartOverviewModel': instance.getCartOverviewModel?.toJson(),
      'getCartOverviewStatus':
          _$GetCartOverviewStatusEnumMap[instance.getCartOverviewStatus],
      'getOrdersByOrderGroupIDModel':
          instance.getOrdersByOrderGroupIDModel?.toJson(),
      'getOrdersByOrderGroupIDStatus': _$GetOrdersByOrderGroupIDStatusEnumMap[
          instance.getOrdersByOrderGroupIDStatus],
      'getOrdersByCartGroupIDModel':
          instance.getOrdersByCartGroupIDModel?.toJson(),
      'getOrdersByCartGroupIDStatus': _$GetOrdersByCartGroupIDStatusEnumMap[
          instance.getOrdersByCartGroupIDStatus],
      'checkAvailabilityProductCartModel':
          instance.checkAvailabilityProductCartModel?.toJson(),
      'checkAvailabilityProductCartStatus':
          _$CheckAvailabilityProductCartStatusEnumMap[
              instance.checkAvailabilityProductCartStatus],
      'listitemForAddToCart':
          instance.listitemForAddToCart?.map((e) => e.toJson()).toList(),
      'getAddressByTextStatus':
          _$GetAddressByTextStatusEnumMap[instance.getAddressByTextStatus],
      'getAddressByCoordinatesStatus': _$GetAddressByCoordinatesStatusEnumMap[
          instance.getAddressByCoordinatesStatus],
      'getCustomerWalletStatus':
          _$GetCustomerWalletStatusEnumMap[instance.getCustomerWalletStatus],
      'getAllowedCountriesModel': instance.getAllowedCountriesModel?.toJson(),
      'removeAddressToOrderStatus': _$RemoveAddressToOrderStatusEnumMap[
          instance.removeAddressToOrderStatus],
      'editAddressToOrderStatus':
          _$EditAddressToOrderStatusEnumMap[instance.editAddressToOrderStatus],
      'addAddressToOrderStatus':
          _$AddAddressToOrderStatusEnumMap[instance.addAddressToOrderStatus],
      'getProductFiltersStatus': instance.getProductFiltersStatus
          .map((k, e) => MapEntry(k, _$GetProductFiltersStatusEnumMap[e]!)),
      'getProductListingWithFiltersPaginationModels': instance
          .getProductListingWithFiltersPaginationModels
          .map((k, e) => MapEntry(
              k,
              e?.toJson(
                (value) => value.toJson(),
              ))),
      'listOfAddressInfoClassToSave': instance.listOfAddressInfoClassToSave
          ?.map((e) => e.toJson())
          .toList(),
      'getCurrencyForCountryModel':
          instance.getCurrencyForCountryModel?.toJson(),
      'getProductListingWithFiltersPaginationWithPrefetchModels': instance
          .getProductListingWithFiltersPaginationWithPrefetchModels
          .map((k, e) => MapEntry(
              k,
              e?.toJson(
                (value) => value.toJson(),
              ))),
      'sendRequestToGeminiStatus': _$SendRequestToGeminiStatusEnumMap[
          instance.sendRequestToGeminiStatus]!,
      'addItemInCartStatus':
          _$AddItemInCartStatusEnumMap[instance.addItemInCartStatus],
      'updateItemInCartStatus':
          _$UpdateItemInCartStatusEnumMap[instance.updateItemInCartStatus],
      'deleteItemInCartStatus':
          _$DeleteItemInCartStatusEnumMap[instance.deleteItemInCartStatus],
      'addCommentStatus': _$AddCommentStatusEnumMap[instance.addCommentStatus]!,
      'getProductFiltersModel': instance.getProductFiltersModel
          .map((k, e) => MapEntry(k, e?.toJson())),
      'getProductFiltersWithPrefetchModel': instance
          .getProductFiltersWithPrefetchModel
          .map((k, e) => MapEntry(k, e?.toJson())),
      'addOrRemoveLikeOfProductStatus': _$AddOrRemoveLikeOfProductStatusEnumMap[
          instance.addOrRemoveLikeOfProductStatus]!,
      'appliedFiltersByUser':
          instance.appliedFiltersByUser.map((k, e) => MapEntry(k, e?.toJson())),
      'choosedFiltersByUser':
          instance.choosedFiltersByUser.map((k, e) => MapEntry(k, e?.toJson())),
      'selectedCollection': instance.selectedCollection,
      'currentPage': instance.currentPage,
      'currentAddressChoosed': instance.currentAddressChoosed,
      'isExpandedForListingPage': instance.isExpandedForListingPage,
      'isGettingProductListingWithPagination':
          instance.isGettingProductListingWithPagination,
      'isGettingProductListingWithPaginationForAppearProduct':
          instance.isGettingProductListingWithPaginationForAppearProduct,
      'searchHistory': instance.searchHistory,
      'listOfErrorSendedToMobileErrorLog':
          instance.listOfErrorSendedToMobileErrorLog,
      'searchWithFilterOffset': instance.searchWithFilterOffset,
      'searchWithOutFilterOffset': instance.searchWithOutFilterOffset,
      'addImagesToProductIdForCart': instance.addImagesToProductIdForCart.map(
          (k, e) => MapEntry(k, e.map((k, e) => MapEntry(k.toString(), e)))),
      'productStatus': instance.productStatus?.map((k, e) => MapEntry(
          k, _$GetProductDetailWithoutSimilarRelatedProductsStatusEnumMap[e]!)),
      'cartCollection':
          instance.cartCollection?.map((e) => e.toJson()).toList(),
      'cartIdsHurryUPTimerStarted': instance.cartIdsHurryUPTimerStarted,
      'getListOfProductsFoundedInCartStatus':
          _$GetListOfProductsFoundedInCartStatusEnumMap[
              instance.getListOfProductsFoundedInCartStatus]!,
      'updateEmailappNotificationStatus':
          _$UpdateEmailappNotificationStatusEnumMap[
              instance.updateEmailappNotificationStatus],
      'updateWhatsappNotificationStatus':
          _$UpdateWhatsappNotificationStatusEnumMap[
              instance.updateWhatsappNotificationStatus],
      'oldcartCollection':
          instance.oldcartCollection?.map((e) => e.toJson()).toList(),
      'reRequestTheseBoutiques': instance.reRequestTheseBoutiques,
      'reRequestTheseProductListingInBoutiques':
          instance.reRequestTheseProductListingInBoutiques,
      'reRequestProductWithFilters': instance.reRequestProductWithFilters,
      'getProductDetailWithoutSimilarRelatedProductsStatus':
          _$GetProductDetailWithoutSimilarRelatedProductsStatusEnumMap[
              instance.getProductDetailWithoutSimilarRelatedProductsStatus]!,
      'getFullProductDetailsStatus': _$GetFullProductDetailsStatusEnumMap[
          instance.getFullProductDetailsStatus]!,
      'theReplyFromGemini': instance.theReplyFromGemini,
      'getCartItemsStatus':
          _$GetCartItemsStatusEnumMap[instance.getCartItemsStatus]!,
      'getOldCartItemsStatus':
          _$GetOLdCartItemsStatusEnumMap[instance.getOldCartItemsStatus]!,
      'productContentForStatusOfOpeningProductDetailsDirectly': instance
          .productContentForStatusOfOpeningProductDetailsDirectly
          ?.toJson(),
      'getProductListingStatus':
          _$GetProductListingStatusEnumMap[instance.getProductListingStatus]!,
      'getStoriesForProductStatus': _$GetStoriesForProductStatusEnumMap[
          instance.getStoriesForProductStatus]!,
      'getHomeBoutiquesPaginationObjectByMainCategory': instance
          .getHomeBoutiquesPaginationObjectByMainCategory
          .map((k, e) => MapEntry(
              k,
              e.toJson(
                (value) => value.toJson(),
              ))),
      'storiesForProduct':
          instance.storiesForProduct?.map((e) => e.toJson()).toList(),
      'sizesForEachColor': instance.sizesForEachColor,
      'colorsForEachProduct': instance.colorsForEachProduct,
      'sizesQuantitiesForEachColor': instance.sizesQuantitiesForEachColor,
      'colorsQuantitiesForEachProduct': instance.colorsQuantitiesForEachProduct,
      'isVariantRequestNotification': instance.isVariantRequestNotification,
      'countOfProductExpectedByFiltering':
          instance.countOfProductExpectedByFiltering,
      'prefAppliedFilterForExtendFilter':
          instance.prefAppliedFilterForExtendFilter?.toJson(),
      'getProductListingPaginationWithoutFiltersModel': instance
          .getProductListingPaginationWithoutFiltersModel
          .map((k, e) => MapEntry(
              k,
              e.toJson(
                (value) => value.toJson(),
              ))),
      'getCartShippingItemsModel': instance.getCartShippingItemsModel?.toJson(),
      'getOldCartModel': instance.getOldCartModel?.toJson(),
      'getCommentForProductModel': instance.getCommentForProductModel
          .map((k, e) => MapEntry(k, e.toJson())),
      'mainCategoriesResponseModel':
          instance.mainCategoriesResponseModel?.toJson(),
      'getProductDetailWithoutRelatedProductsModel':
          instance.getProductDetailWithoutRelatedProductsModel?.toJson(),
      'changeSizesForEveryProduct': _$ChangeSizesForEveryProductEnumMap[
          instance.changeSizesForEveryProduct],
      'cashedOrginalBoutique': instance.cashedOrginalBoutique,
      'currentIndexForMainCategoryEvent':
          instance.currentIndexForMainCategoryEvent,
      'currentIndexForUpdateCart': instance.currentIndexForUpdateCart,
      'startingSetting': instance.startingSetting?.toJson(),
      'currentColorSizeForCart': instance.currentColorSizeForCart,
      'fromSearchForSearchWithGemini': instance.fromSearchForSearchWithGemini,
      'currentQuantityForCart': instance.currentQuantityForCart,
      'cachedProductWithoutRelatedProductsModel': instance
          .cachedProductWithoutRelatedProductsModel
          .map((k, e) => MapEntry(k, e.toJson())),
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

const _$ConvertItemFromOldcartToCartStatusEnumMap = {
  ConvertItemFromOldcartToCartStatus.init: 'init',
  ConvertItemFromOldcartToCartStatus.loading: 'loading',
  ConvertItemFromOldcartToCartStatus.success: 'success',
  ConvertItemFromOldcartToCartStatus.failure: 'failure',
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

const _$UpdateWhatsappNotificationStatusEnumMap = {
  UpdateWhatsappNotificationStatus.init: 'init',
  UpdateWhatsappNotificationStatus.loading: 'loading',
  UpdateWhatsappNotificationStatus.success: 'success',
  UpdateWhatsappNotificationStatus.failure: 'failure',
};

const _$ChangeSizesForEveryProductEnumMap = {
  ChangeSizesForEveryProduct.init: 'init',
  ChangeSizesForEveryProduct.loading: 'loading',
  ChangeSizesForEveryProduct.success: 'success',
  ChangeSizesForEveryProduct.failure: 'failure',
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

const _$GetMainCategoriesStatusEnumMap = {
  GetMainCategoriesStatus.init: 'init',
  GetMainCategoriesStatus.loading: 'loading',
  GetMainCategoriesStatus.success: 'success',
  GetMainCategoriesStatus.failure: 'failure',
};

const _$GetCommentForProductStatusEnumMap = {
  GetCommentForProductStatus.init: 'init',
  GetCommentForProductStatus.loading: 'loading',
  GetCommentForProductStatus.success: 'success',
  GetCommentForProductStatus.failure: 'failure',
};

const _$EditAddressToOrderStatusEnumMap = {
  EditAddressToOrderStatus.init: 'init',
  EditAddressToOrderStatus.loading: 'loading',
  EditAddressToOrderStatus.success: 'success',
  EditAddressToOrderStatus.failure: 'failure',
};

const _$CurrentSelectedColorForEveryProductStatusEnumMap = {
  CurrentSelectedColorForEveryProductStatus.init: 'init',
  CurrentSelectedColorForEveryProductStatus.loading: 'loading',
  CurrentSelectedColorForEveryProductStatus.success: 'success',
  CurrentSelectedColorForEveryProductStatus.failure: 'failure',
};

const _$AddAddressToOrderStatusEnumMap = {
  AddAddressToOrderStatus.init: 'init',
  AddAddressToOrderStatus.loading: 'loading',
  AddAddressToOrderStatus.success: 'success',
  AddAddressToOrderStatus.failure: 'failure',
};

const _$RemoveAddressToOrderStatusEnumMap = {
  RemoveAddressToOrderStatus.init: 'init',
  RemoveAddressToOrderStatus.loading: 'loading',
  RemoveAddressToOrderStatus.success: 'success',
  RemoveAddressToOrderStatus.failure: 'failure',
};

const _$GetFullProductDetailsStatusEnumMap = {
  GetFullProductDetailsStatus.init: 'init',
  GetFullProductDetailsStatus.loading: 'loading',
  GetFullProductDetailsStatus.success: 'success',
  GetFullProductDetailsStatus.failure: 'failure',
};

const _$AddCommentStatusEnumMap = {
  AddCommentStatus.init: 'init',
  AddCommentStatus.loading: 'loading',
  AddCommentStatus.success: 'success',
  AddCommentStatus.failure: 'failure',
};

const _$DeleteItemInCartStatusEnumMap = {
  DeleteItemInCartStatus.init: 'init',
  DeleteItemInCartStatus.loading: 'loading',
  DeleteItemInCartStatus.success: 'success',
  DeleteItemInCartStatus.failure: 'failure',
};

const _$GetOLdCartItemsStatusEnumMap = {
  GetOLdCartItemsStatus.init: 'init',
  GetOLdCartItemsStatus.loading: 'loading',
  GetOLdCartItemsStatus.success: 'success',
  GetOLdCartItemsStatus.failure: 'failure',
};

const _$GetProductFiltersStatusEnumMap = {
  GetProductFiltersStatus.init: 'init',
  GetProductFiltersStatus.loading: 'loading',
  GetProductFiltersStatus.success: 'success',
  GetProductFiltersStatus.failure: 'failure',
};

const _$SetCustomerAddressDefaultStatusEnumMap = {
  SetCustomerAddressDefaultStatus.init: 'init',
  SetCustomerAddressDefaultStatus.loading: 'loading',
  SetCustomerAddressDefaultStatus.success: 'success',
  SetCustomerAddressDefaultStatus.failure: 'failure',
};

const _$UpdateItemInCartStatusEnumMap = {
  UpdateItemInCartStatus.init: 'init',
  UpdateItemInCartStatus.loading: 'loading',
  UpdateItemInCartStatus.success: 'success',
  UpdateItemInCartStatus.failure: 'failure',
};

const _$GetCustomerAddressesStatusEnumMap = {
  GetCustomerAddressesStatus.init: 'init',
  GetCustomerAddressesStatus.loading: 'loading',
  GetCustomerAddressesStatus.success: 'success',
  GetCustomerAddressesStatus.failure: 'failure',
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

const _$SendRequestToGeminiStatusEnumMap = {
  SendRequestToGeminiStatus.init: 'init',
  SendRequestToGeminiStatus.loading: 'loading',
  SendRequestToGeminiStatus.success: 'success',
  SendRequestToGeminiStatus.failure: 'failure',
};

const _$GetListOfProductsFoundedInCartStatusEnumMap = {
  GetListOfProductsFoundedInCartStatus.init: 'init',
  GetListOfProductsFoundedInCartStatus.loading: 'loading',
  GetListOfProductsFoundedInCartStatus.success: 'success',
  GetListOfProductsFoundedInCartStatus.failure: 'failure',
};

const _$GetAddressByCoordinatesStatusEnumMap = {
  GetAddressByCoordinatesStatus.init: 'init',
  GetAddressByCoordinatesStatus.loading: 'loading',
  GetAddressByCoordinatesStatus.success: 'success',
  GetAddressByCoordinatesStatus.failure: 'failure',
};

const _$GetCustomerWalletStatusEnumMap = {
  GetCustomerWalletStatus.init: 'init',
  GetCustomerWalletStatus.loading: 'loading',
  GetCustomerWalletStatus.success: 'success',
  GetCustomerWalletStatus.failure: 'failure',
};

const _$PlaceOrderStatusEnumMap = {
  PlaceOrderStatus.init: 'init',
  PlaceOrderStatus.loading: 'loading',
  PlaceOrderStatus.success: 'success',
  PlaceOrderStatus.failure: 'failure',
  PlaceOrderStatus.unavailable: 'unavailable',
};

const _$ApplyCouponStatusEnumMap = {
  ApplyCouponStatus.init: 'init',
  ApplyCouponStatus.loading: 'loading',
  ApplyCouponStatus.success: 'success',
  ApplyCouponStatus.failure: 'failure',
};

const _$GetCartOverviewStatusEnumMap = {
  GetCartOverviewStatus.init: 'init',
  GetCartOverviewStatus.loading: 'loading',
  GetCartOverviewStatus.success: 'success',
  GetCartOverviewStatus.failure: 'failure',
};

const _$GetOrdersByOrderGroupIDStatusEnumMap = {
  GetOrdersByOrderGroupIDStatus.init: 'init',
  GetOrdersByOrderGroupIDStatus.loading: 'loading',
  GetOrdersByOrderGroupIDStatus.success: 'success',
  GetOrdersByOrderGroupIDStatus.failure: 'failure',
};

const _$GetOrdersByCartGroupIDStatusEnumMap = {
  GetOrdersByCartGroupIDStatus.init: 'init',
  GetOrdersByCartGroupIDStatus.loading: 'loading',
  GetOrdersByCartGroupIDStatus.success: 'success',
  GetOrdersByCartGroupIDStatus.failure: 'failure',
};

const _$CheckAvailabilityProductCartStatusEnumMap = {
  CheckAvailabilityProductCartStatus.init: 'init',
  CheckAvailabilityProductCartStatus.loading: 'loading',
  CheckAvailabilityProductCartStatus.success: 'success',
  CheckAvailabilityProductCartStatus.failure: 'failure',
};

const _$GetAddressByTextStatusEnumMap = {
  GetAddressByTextStatus.init: 'init',
  GetAddressByTextStatus.loading: 'loading',
  GetAddressByTextStatus.success: 'success',
  GetAddressByTextStatus.failure: 'failure',
};

const _$GetCartItemsStatusEnumMap = {
  GetCartItemsStatus.init: 'init',
  GetCartItemsStatus.loading: 'loading',
  GetCartItemsStatus.success: 'success',
  GetCartItemsStatus.failure: 'failure',
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

const _$GetFirebaseSettingForNotificationStatusEnumMap = {
  GetFirebaseSettingForNotificationStatus.init: 'init',
  GetFirebaseSettingForNotificationStatus.loading: 'loading',
  GetFirebaseSettingForNotificationStatus.success: 'success',
  GetFirebaseSettingForNotificationStatus.failure: 'failure',
};
