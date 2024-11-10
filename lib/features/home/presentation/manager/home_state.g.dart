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
      hideItemInOldCartStatus: $enumDecodeNullable(
          _$HideItemInOldCartStatusEnumMap, json['hideItemInOldCartStatus']),
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
      sizes:
          (json['sizes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      sizesQuantities: (json['sizesQuantities'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      isSizeRequestNotification:
          (json['isSizeRequestNotification'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              const [],
      deleteItemInCartStatus: $enumDecodeNullable(
          _$DeleteItemInCartStatusEnumMap, json['deleteItemInCartStatus']),
      oldcartCollection:
          (json['oldcartCollection'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
            k,
            (e as List<dynamic>)
                .map((e) => oldCart.OldCart.fromJson(e as Map<String, dynamic>))
                .toList()),
      ),
      getOldCartItemsStatus: $enumDecodeNullable(
              _$GetOLdCartItemsStatusEnumMap, json['getOldCartItemsStatus']) ??
          GetOLdCartItemsStatus.init,
      getOldCartModel: json['getOldCartModel'] == null
          ? null
          : oldCart.GetOldCartModel.fromJson(
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
                        : get_filters.GetProductFiltersModel.fromJson(
                            e as Map<String, dynamic>)),
              ) ??
              const {},
      choosedFiltersByUser:
          (json['choosedFiltersByUser'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(
                    k,
                    e == null
                        ? null
                        : get_filters.GetProductFiltersModel.fromJson(
                            e as Map<String, dynamic>)),
              ) ??
              const {},
      appliedFiltersByUser:
          (json['appliedFiltersByUser'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(
                    k,
                    e == null
                        ? null
                        : get_filters.GetProductFiltersModel.fromJson(
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
      cartCollection: (json['cartCollection'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
                k,
                (e as List<dynamic>)
                    .map((e) => Cart.fromJson(e as Map<String, dynamic>))
                    .toList()),
          ) ??
          const {},
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
      CurrentColorSizeForCart:
          (json['CurrentColorSizeForCart'] as Map<String, dynamic>?)?.map(
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
      getAllowedCountriesModel: json['getAllowedCountriesModel'] == null
          ? null
          : GetAllowedCountriesModel.fromJson(
              json['getAllowedCountriesModel'] as Map<String, dynamic>),
      currentIndexForMainCategoryEvent:
          (json['currentIndexForMainCategoryEvent'] as num?)?.toInt() ?? 0,
      prefAppliedFilterForExtendFilter:
          json['prefAppliedFilterForExtendFilter'] == null
              ? null
              : get_filters.Filter.fromJson(json['prefAppliedFilterForExtendFilter']
                  as Map<String, dynamic>),
      fromSearchForSearchWithGemini:
          json['fromSearchForSearchWithGemini'] as bool? ?? false,
      ListitemForAddToCart: (json['ListitemForAddToCart'] as List<dynamic>?)
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
                        : get_filters.GetProductFiltersModel.fromJson(
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
                    PaginationModel<Boutique>.fromJson(
                        e as Map<String, dynamic>,
                        (value) =>
                            Boutique.fromJson(value as Map<String, dynamic>))),
              ) ??
              const {},
    );

Map<String, dynamic> _$HomeStateToJson(HomeState instance) => <String, dynamic>{
      'boutiquesThatDidPrefetch': instance.boutiquesThatDidPrefetch,
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
      'convertItemFromOldcartToCartStatus':
          _$ConvertItemFromOldcartToCartStatusEnumMap[
              instance.convertItemFromOldcartToCartStatus],
      'getMainCategoriesStatus':
          _$GetMainCategoriesStatusEnumMap[instance.getMainCategoriesStatus]!,
      'hideItemInOldCartStatus':
          _$HideItemInOldCartStatusEnumMap[instance.hideItemInOldCartStatus],
      'getAndAddCountViewOfProductStatus':
          instance.getAndAddCountViewOfProductStatus.map((k, e) =>
              MapEntry(k, _$GetAndAddCountViewOfProductStatusEnumMap[e]!)),
      'ListitemForAddToCart':
          instance.ListitemForAddToCart?.map((e) => e.toJson()).toList(),
      'getAllowedCountriesModel': instance.getAllowedCountriesModel?.toJson(),
      'getProductFiltersStatus': instance.getProductFiltersStatus
          .map((k, e) => MapEntry(k, _$GetProductFiltersStatusEnumMap[e]!)),
      'getProductListingWithFiltersPaginationModels': instance
          .getProductListingWithFiltersPaginationModels
          .map((k, e) => MapEntry(
              k,
              e?.toJson(
                (value) => value.toJson(),
              ))),
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
      'isExpandedForListingPage': instance.isExpandedForListingPage,
      'isGettingProductListingWithPagination':
          instance.isGettingProductListingWithPagination,
      'isGettingProductListingWithPaginationForAppearProduct':
          instance.isGettingProductListingWithPaginationForAppearProduct,
      'searchHistory': instance.searchHistory,
      'searchWithFilterOffset': instance.searchWithFilterOffset,
      'searchWithOutFilterOffset': instance.searchWithOutFilterOffset,
      'addImagesToProductIdForCart': instance.addImagesToProductIdForCart.map(
          (k, e) => MapEntry(k, e.map((k, e) => MapEntry(k.toString(), e)))),
      'productStatus': instance.productStatus?.map((k, e) => MapEntry(
          k, _$GetProductDetailWithoutSimilarRelatedProductsStatusEnumMap[e]!)),
      'cartCollection': instance.cartCollection
          ?.map((k, e) => MapEntry(k, e.map((e) => e.toJson()).toList())),
      'getListOfProductsFoundedInCartStatus':
          _$GetListOfProductsFoundedInCartStatusEnumMap[
              instance.getListOfProductsFoundedInCartStatus]!,
      'oldcartCollection': instance.oldcartCollection
          ?.map((k, e) => MapEntry(k, e.map((e) => e.toJson()).toList())),
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
      'sizes': instance.sizes,
      'sizesQuantities': instance.sizesQuantities,
      'isSizeRequestNotification': instance.isSizeRequestNotification,
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
      'cashedOrginalBoutique': instance.cashedOrginalBoutique,
      'currentIndexForMainCategoryEvent':
          instance.currentIndexForMainCategoryEvent,
      'startingSetting': instance.startingSetting?.toJson(),
      'CurrentColorSizeForCart': instance.CurrentColorSizeForCart,
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
