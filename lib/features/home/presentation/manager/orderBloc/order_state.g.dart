// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderState _$OrderStateFromJson(Map<String, dynamic> json) => OrderState(
  placeOrderModel: json['placeOrderModel'] == null
      ? null
      : OrdersGroupModel.fromJson(
          json['placeOrderModel'] as Map<String, dynamic>,
        ),
  walletCheckoutStatus:
      $enumDecodeNullable(
        _$WalletCheckoutStatusEnumMap,
        json['walletCheckoutStatus'],
      ) ??
      WalletCheckoutStatus.init,
  placeOrderStatus:
      $enumDecodeNullable(
        _$PlaceOrderStatusEnumMap,
        json['placeOrderStatus'],
      ) ??
      PlaceOrderStatus.init,
  getOrdersByOrderGroupIDModel: json['getOrdersByOrderGroupIDModel'] == null
      ? null
      : OrdersGroupModel.fromJson(
          json['getOrdersByOrderGroupIDModel'] as Map<String, dynamic>,
        ),
  getOrdersByOrderGroupIDStatus:
      $enumDecodeNullable(
        _$GetOrdersByOrderGroupIDStatusEnumMap,
        json['getOrdersByOrderGroupIDStatus'],
      ) ??
      GetOrdersByOrderGroupIDStatus.init,
  getOrdersByCartGroupIDModel: json['getOrdersByCartGroupIDModel'] == null
      ? null
      : OrdersGroupModel.fromJson(
          json['getOrdersByCartGroupIDModel'] as Map<String, dynamic>,
        ),
  getOrdersByCartGroupIDStatus:
      $enumDecodeNullable(
        _$GetOrdersByCartGroupIDStatusEnumMap,
        json['getOrdersByCartGroupIDStatus'],
      ) ??
      GetOrdersByCartGroupIDStatus.init,
  getCustomerWalletStatus:
      $enumDecodeNullable(
        _$GetCustomerWalletStatusEnumMap,
        json['getCustomerWalletStatus'],
      ) ??
      GetCustomerWalletStatus.init,
  customerWalletModel: json['customerWalletModel'] == null
      ? null
      : CustomerWalletModel.fromJson(
          json['customerWalletModel'] as Map<String, dynamic>,
        ),
  lastAdressInfoClassToSave: json['lastAdressInfoClassToSave'] == null
      ? null
      : CustomerAddressesInfo.fromJson(
          json['lastAdressInfoClassToSave'] as Map<String, dynamic>,
        ),
  getOrdersModel:
      (json['getOrdersModel'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          k,
          PaginationModel<List<OrderListModel>>.fromJson(
            e as Map<String, dynamic>,
            (value) => (value as List<dynamic>)
                .map((e) => OrderListModel.fromJson(e as Map<String, dynamic>))
                .toList(),
          ),
        ),
      ) ??
      const {},
  orderTotalSize: (json['orderTotalSize'] as num?)?.toInt() ?? 0,
  setCustomerAddressDefaultStatus:
      $enumDecodeNullable(
        _$SetCustomerAddressDefaultStatusEnumMap,
        json['setCustomerAddressDefaultStatus'],
      ) ??
      SetCustomerAddressDefaultStatus.init,
  getCustomerAddressStatus:
      $enumDecodeNullable(
        _$GetCustomerAddressesStatusEnumMap,
        json['getCustomerAddressStatus'],
      ) ??
      GetCustomerAddressesStatus.init,
  currentAddressChoosed: (json['currentAddressChoosed'] as num?)?.toInt(),
  orderReturnRequestsViewStatus: $enumDecodeNullable(
    _$OrderReturnRequestsViewStatusEnumMap,
    json['orderReturnRequestsViewStatus'],
  ),
  confirmReturnRequestStatus: $enumDecodeNullable(
    _$ConfirmReturnRequestStatusEnumMap,
    json['confirmReturnRequestStatus'],
  ),
  currentOrederStatus: json['currentOrederStatus'] as String?,
  updateReturnRequestProductStatus:
      $enumDecodeNullable(
        _$UpdateReturnRequestProductStatusEnumMap,
        json['updateReturnRequestProductStatus'],
      ) ??
      UpdateReturnRequestProductStatus.init,
  listOfAddressInfoClassToSave:
      (json['listOfAddressInfoClassToSave'] as List<dynamic>?)
          ?.map(
            (e) => CustomerAddressesInfo.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  removeAddressToOrderStatus:
      $enumDecodeNullable(
        _$RemoveAddressToOrderStatusEnumMap,
        json['removeAddressToOrderStatus'],
      ) ??
      RemoveAddressToOrderStatus.init,
  addAddressToOrderStatus:
      $enumDecodeNullable(
        _$AddAddressToOrderStatusEnumMap,
        json['addAddressToOrderStatus'],
      ) ??
      AddAddressToOrderStatus.init,
  editAddressToOrderStatus:
      $enumDecodeNullable(
        _$EditAddressToOrderStatusEnumMap,
        json['editAddressToOrderStatus'],
      ) ??
      EditAddressToOrderStatus.init,
  getAddressByCoordinatesStatus:
      $enumDecodeNullable(
        _$GetAddressByCoordinatesStatusEnumMap,
        json['getAddressByCoordinatesStatus'],
      ) ??
      GetAddressByCoordinatesStatus.init,
  getAddressByCoordinatesModel: json['getAddressByCoordinatesModel'] == null
      ? null
      : GetAddressByCoordinatesModel.fromJson(
          json['getAddressByCoordinatesModel'] as Map<String, dynamic>,
        ),
  uploadImagesForReturnProductStatus:
      $enumDecodeNullable(
        _$UploadImagesForReturnProductStatusEnumMap,
        json['uploadImagesForReturnProductStatus'],
      ) ??
      UploadImagesForReturnProductStatus.init,
  uploadImagesToCloudinaryStatus:
      $enumDecodeNullable(
        _$UploadImagesToCloudinaryStatusEnumMap,
        json['uploadImagesToCloudinaryStatus'],
      ) ??
      UploadImagesToCloudinaryStatus.init,
  reportOrderProductStatus:
      $enumDecodeNullable(
        _$ReportOrderProductStatusEnumMap,
        json['reportOrderProductStatus'],
      ) ??
      ReportOrderProductStatus.init,
  getAddressByTextStatus:
      $enumDecodeNullable(
        _$GetAddressByTextStatusEnumMap,
        json['getAddressByTextStatus'],
      ) ??
      GetAddressByTextStatus.init,
  applyCouponStatus:
      $enumDecodeNullable(
        _$ApplyCouponStatusEnumMap,
        json['applyCouponStatus'],
      ) ??
      ApplyCouponStatus.init,
  applyCouponModel: json['applyCouponModel'] == null
      ? null
      : ApplyCouponModel.fromJson(
          json['applyCouponModel'] as Map<String, dynamic>,
        ),
  imagesForReturn:
      (json['imagesForReturn'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  imagesForComment:
      (json['imagesForComment'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  cancelOrderItemStatus:
      $enumDecodeNullable(
        _$CancelOrderItemStatusEnumMap,
        json['cancelOrderItemStatus'],
      ) ??
      CancelOrderItemStatus.init,
  cancelOrderStatus:
      $enumDecodeNullable(
        _$CancelOrderStatusEnumMap,
        json['cancelOrderStatus'],
      ) ??
      CancelOrderStatus.init,
  changeOrderAddressStatus:
      $enumDecodeNullable(
        _$ChangeOrderAddressStatusEnumMap,
        json['changeOrderAddressStatus'],
      ) ??
      ChangeOrderAddressStatus.init,
  getProductColorSizeSyncAttributeStatus:
      $enumDecodeNullable(
        _$GetProductColorSizeSyncAttributeStatusEnumMap,
        json['getProductColorSizeSyncAttributeStatus'],
      ) ??
      GetProductColorSizeSyncAttributeStatus.init,
  colorSizeForProductModel: json['colorSizeForProductModel'] == null
      ? null
      : ColorSizeForProductModel.fromJson(
          json['colorSizeForProductModel'] as Map<String, dynamic>,
        ),
  resultSearch:
      (json['resultSearch'] as List<dynamic>?)
          ?.map((e) => ResultSearch.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  provincesByIso:
      (json['provincesByIso'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  changeOrderItemVariantStatus:
      $enumDecodeNullable(
        _$ChangeOrderItemVariantStatusEnumMap,
        json['changeOrderItemVariantStatus'],
      ) ??
      ChangeOrderItemVariantStatus.init,
  getReturnReasonsStatus:
      $enumDecodeNullable(
        _$GetReturnReasonsStatusEnumMap,
        json['getReturnReasonsStatus'],
      ) ??
      GetReturnReasonsStatus.init,
  returnReasonsModel: json['returnReasonsModel'] == null
      ? null
      : ReturnReasonsModel.fromJson(
          json['returnReasonsModel'] as Map<String, dynamic>,
        ),
  storeReturnRequestStatus: $enumDecodeNullable(
    _$StoreReturnRequestStatusEnumMap,
    json['storeReturnRequestStatus'],
  ),
  storeReturnRequestProductStatus:
      $enumDecodeNullable(
        _$StoreReturnRequestProductStatusEnumMap,
        json['storeReturnRequestProductStatus'],
      ) ??
      StoreReturnRequestProductStatus.init,
  cancelReturnRequestStatus:
      $enumDecodeNullable(
        _$CancelReturnRequestStatusEnumMap,
        json['cancelReturnRequestStatus'],
      ) ??
      CancelReturnRequestStatus.init,
  cancelReturnRequestProductStatus:
      $enumDecodeNullable(
        _$CancelReturnRequestProductStatusEnumMap,
        json['cancelReturnRequestProductStatus'],
      ) ??
      CancelReturnRequestProductStatus.init,
  orderReturnDetailsStatus:
      $enumDecodeNullable(
        _$OrderReturnDetailsStatusEnumMap,
        json['orderReturnDetailsStatus'],
      ) ??
      OrderReturnDetailsStatus.init,
  orderReturnDetailsModel: json['orderReturnDetailsModel'] == null
      ? null
      : GetOrderReturntDetailsModel.fromJson(
          json['orderReturnDetailsModel'] as Map<String, dynamic>,
        ),
  getHiddenOrdersStatus:
      $enumDecodeNullable(
        _$GetHiddenOrdersStatusEnumMap,
        json['getHiddenOrdersStatus'],
      ) ??
      GetHiddenOrdersStatus.init,
  getHiddenOrdersModel: json['getHiddenOrdersModel'] == null
      ? null
      : GetHiddenOrdersModel.fromJson(
          json['getHiddenOrdersModel'] as Map<String, dynamic>,
        ),
  restoreOrderVisibilityStatus:
      $enumDecodeNullable(
        _$RestoreOrderVisibilityStatusEnumMap,
        json['restoreOrderVisibilityStatus'],
      ) ??
      RestoreOrderVisibilityStatus.init,
  hideOrderVisibilityStatus:
      $enumDecodeNullable(
        _$HideOrderVisibilityStatusEnumMap,
        json['hideOrderVisibilityStatus'],
      ) ??
      HideOrderVisibilityStatus.init,
);

Map<String, dynamic> _$OrderStateToJson(
  OrderState instance,
) => <String, dynamic>{
  'orderReturnRequestsViewStatus':
      _$OrderReturnRequestsViewStatusEnumMap[instance
          .orderReturnRequestsViewStatus],
  'confirmReturnRequestStatus':
      _$ConfirmReturnRequestStatusEnumMap[instance.confirmReturnRequestStatus],
  'placeOrderModel': instance.placeOrderModel?.toJson(),
  'placeOrderStatus': _$PlaceOrderStatusEnumMap[instance.placeOrderStatus],
  'storeReturnRequestStatus':
      _$StoreReturnRequestStatusEnumMap[instance.storeReturnRequestStatus],
  'getOrdersByOrderGroupIDModel': instance.getOrdersByOrderGroupIDModel
      ?.toJson(),
  'getOrdersByOrderGroupIDStatus':
      _$GetOrdersByOrderGroupIDStatusEnumMap[instance
          .getOrdersByOrderGroupIDStatus],
  'customerWalletModel': instance.customerWalletModel?.toJson(),
  'getCustomerWalletStatus':
      _$GetCustomerWalletStatusEnumMap[instance.getCustomerWalletStatus],
  'getOrdersModel': instance.getOrdersModel?.map(
    (k, e) =>
        MapEntry(k, e.toJson((value) => value.map((e) => e.toJson()).toList())),
  ),
  'getOrdersByCartGroupIDModel': instance.getOrdersByCartGroupIDModel?.toJson(),
  'getOrdersByCartGroupIDStatus':
      _$GetOrdersByCartGroupIDStatusEnumMap[instance
          .getOrdersByCartGroupIDStatus],
  'setCustomerAddressDefaultStatus':
      _$SetCustomerAddressDefaultStatusEnumMap[instance
          .setCustomerAddressDefaultStatus],
  'getCustomerAddressStatus':
      _$GetCustomerAddressesStatusEnumMap[instance.getCustomerAddressStatus],
  'currentAddressChoosed': instance.currentAddressChoosed,
  'listOfAddressInfoClassToSave': instance.listOfAddressInfoClassToSave
      ?.map((e) => e.toJson())
      .toList(),
  'removeAddressToOrderStatus':
      _$RemoveAddressToOrderStatusEnumMap[instance.removeAddressToOrderStatus],
  'addAddressToOrderStatus':
      _$AddAddressToOrderStatusEnumMap[instance.addAddressToOrderStatus],
  'lastAdressInfoClassToSave': instance.lastAdressInfoClassToSave?.toJson(),
  'editAddressToOrderStatus':
      _$EditAddressToOrderStatusEnumMap[instance.editAddressToOrderStatus],
  'getAddressByCoordinatesStatus':
      _$GetAddressByCoordinatesStatusEnumMap[instance
          .getAddressByCoordinatesStatus],
  'getAddressByCoordinatesModel': instance.getAddressByCoordinatesModel
      ?.toJson(),
  'getAddressByTextStatus':
      _$GetAddressByTextStatusEnumMap[instance.getAddressByTextStatus],
  'resultSearch': instance.resultSearch?.map((e) => e.toJson()).toList(),
  'provincesByIso': instance.provincesByIso,
  'imagesForReturn': instance.imagesForReturn,
  'imagesForComment': instance.imagesForComment,
  'orderTotalSize': instance.orderTotalSize,
  'currentOrederStatus': instance.currentOrederStatus,
  'applyCouponStatus': _$ApplyCouponStatusEnumMap[instance.applyCouponStatus],
  'applyCouponModel': instance.applyCouponModel?.toJson(),
  'cancelOrderItemStatus':
      _$CancelOrderItemStatusEnumMap[instance.cancelOrderItemStatus],
  'cancelOrderStatus': _$CancelOrderStatusEnumMap[instance.cancelOrderStatus],
  'changeOrderAddressStatus':
      _$ChangeOrderAddressStatusEnumMap[instance.changeOrderAddressStatus],
  'getProductColorSizeSyncAttributeStatus':
      _$GetProductColorSizeSyncAttributeStatusEnumMap[instance
          .getProductColorSizeSyncAttributeStatus],
  'colorSizeForProductModel': instance.colorSizeForProductModel?.toJson(),
  'changeOrderItemVariantStatus':
      _$ChangeOrderItemVariantStatusEnumMap[instance
          .changeOrderItemVariantStatus],
  'updateReturnRequestProductStatus':
      _$UpdateReturnRequestProductStatusEnumMap[instance
          .updateReturnRequestProductStatus],
  'getReturnReasonsStatus':
      _$GetReturnReasonsStatusEnumMap[instance.getReturnReasonsStatus],
  'returnReasonsModel': instance.returnReasonsModel?.toJson(),
  'walletCheckoutStatus':
      _$WalletCheckoutStatusEnumMap[instance.walletCheckoutStatus],
  'uploadImagesForReturnProductStatus':
      _$UploadImagesForReturnProductStatusEnumMap[instance
          .uploadImagesForReturnProductStatus]!,
  'uploadImagesToCloudinaryStatus':
      _$UploadImagesToCloudinaryStatusEnumMap[instance
          .uploadImagesToCloudinaryStatus]!,
  'reportOrderProductStatus':
      _$ReportOrderProductStatusEnumMap[instance.reportOrderProductStatus]!,
  'storeReturnRequestProductStatus':
      _$StoreReturnRequestProductStatusEnumMap[instance
          .storeReturnRequestProductStatus],
  'cancelReturnRequestStatus':
      _$CancelReturnRequestStatusEnumMap[instance.cancelReturnRequestStatus],
  'cancelReturnRequestProductStatus':
      _$CancelReturnRequestProductStatusEnumMap[instance
          .cancelReturnRequestProductStatus],
  'orderReturnDetailsStatus':
      _$OrderReturnDetailsStatusEnumMap[instance.orderReturnDetailsStatus]!,
  'orderReturnDetailsModel': instance.orderReturnDetailsModel?.toJson(),
  'getHiddenOrdersStatus':
      _$GetHiddenOrdersStatusEnumMap[instance.getHiddenOrdersStatus],
  'getHiddenOrdersModel': instance.getHiddenOrdersModel?.toJson(),
  'restoreOrderVisibilityStatus':
      _$RestoreOrderVisibilityStatusEnumMap[instance
          .restoreOrderVisibilityStatus],
  'hideOrderVisibilityStatus':
      _$HideOrderVisibilityStatusEnumMap[instance.hideOrderVisibilityStatus],
};

const _$WalletCheckoutStatusEnumMap = {
  WalletCheckoutStatus.init: 'init',
  WalletCheckoutStatus.loading: 'loading',
  WalletCheckoutStatus.success: 'success',
  WalletCheckoutStatus.failure: 'failure',
  WalletCheckoutStatus.unAuth: 'unAuth',
};

const _$PlaceOrderStatusEnumMap = {
  PlaceOrderStatus.init: 'init',
  PlaceOrderStatus.loading: 'loading',
  PlaceOrderStatus.success: 'success',
  PlaceOrderStatus.failure: 'failure',
  PlaceOrderStatus.unavailable: 'unavailable',
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

const _$GetCustomerWalletStatusEnumMap = {
  GetCustomerWalletStatus.init: 'init',
  GetCustomerWalletStatus.loading: 'loading',
  GetCustomerWalletStatus.success: 'success',
  GetCustomerWalletStatus.failure: 'failure',
};

const _$SetCustomerAddressDefaultStatusEnumMap = {
  SetCustomerAddressDefaultStatus.init: 'init',
  SetCustomerAddressDefaultStatus.loading: 'loading',
  SetCustomerAddressDefaultStatus.success: 'success',
  SetCustomerAddressDefaultStatus.failure: 'failure',
};

const _$GetCustomerAddressesStatusEnumMap = {
  GetCustomerAddressesStatus.init: 'init',
  GetCustomerAddressesStatus.loading: 'loading',
  GetCustomerAddressesStatus.success: 'success',
  GetCustomerAddressesStatus.failure: 'failure',
};

const _$OrderReturnRequestsViewStatusEnumMap = {
  OrderReturnRequestsViewStatus.init: 'init',
  OrderReturnRequestsViewStatus.loading: 'loading',
  OrderReturnRequestsViewStatus.success: 'success',
  OrderReturnRequestsViewStatus.failure: 'failure',
};

const _$ConfirmReturnRequestStatusEnumMap = {
  ConfirmReturnRequestStatus.init: 'init',
  ConfirmReturnRequestStatus.loading: 'loading',
  ConfirmReturnRequestStatus.success: 'success',
  ConfirmReturnRequestStatus.failure: 'failure',
};

const _$UpdateReturnRequestProductStatusEnumMap = {
  UpdateReturnRequestProductStatus.init: 'init',
  UpdateReturnRequestProductStatus.loading: 'loading',
  UpdateReturnRequestProductStatus.success: 'success',
  UpdateReturnRequestProductStatus.failure: 'failure',
};

const _$RemoveAddressToOrderStatusEnumMap = {
  RemoveAddressToOrderStatus.init: 'init',
  RemoveAddressToOrderStatus.loading: 'loading',
  RemoveAddressToOrderStatus.success: 'success',
  RemoveAddressToOrderStatus.failure: 'failure',
};

const _$AddAddressToOrderStatusEnumMap = {
  AddAddressToOrderStatus.init: 'init',
  AddAddressToOrderStatus.loading: 'loading',
  AddAddressToOrderStatus.success: 'success',
  AddAddressToOrderStatus.failure: 'failure',
};

const _$EditAddressToOrderStatusEnumMap = {
  EditAddressToOrderStatus.init: 'init',
  EditAddressToOrderStatus.loading: 'loading',
  EditAddressToOrderStatus.success: 'success',
  EditAddressToOrderStatus.failure: 'failure',
};

const _$GetAddressByCoordinatesStatusEnumMap = {
  GetAddressByCoordinatesStatus.init: 'init',
  GetAddressByCoordinatesStatus.loading: 'loading',
  GetAddressByCoordinatesStatus.success: 'success',
  GetAddressByCoordinatesStatus.failure: 'failure',
};

const _$UploadImagesForReturnProductStatusEnumMap = {
  UploadImagesForReturnProductStatus.init: 'init',
  UploadImagesForReturnProductStatus.loading: 'loading',
  UploadImagesForReturnProductStatus.success: 'success',
  UploadImagesForReturnProductStatus.failure: 'failure',
};

const _$UploadImagesToCloudinaryStatusEnumMap = {
  UploadImagesToCloudinaryStatus.init: 'init',
  UploadImagesToCloudinaryStatus.loading: 'loading',
  UploadImagesToCloudinaryStatus.success: 'success',
  UploadImagesToCloudinaryStatus.failure: 'failure',
};

const _$ReportOrderProductStatusEnumMap = {
  ReportOrderProductStatus.init: 'init',
  ReportOrderProductStatus.loading: 'loading',
  ReportOrderProductStatus.success: 'success',
  ReportOrderProductStatus.failure: 'failure',
};

const _$GetAddressByTextStatusEnumMap = {
  GetAddressByTextStatus.init: 'init',
  GetAddressByTextStatus.loading: 'loading',
  GetAddressByTextStatus.success: 'success',
  GetAddressByTextStatus.failure: 'failure',
};

const _$ApplyCouponStatusEnumMap = {
  ApplyCouponStatus.init: 'init',
  ApplyCouponStatus.loading: 'loading',
  ApplyCouponStatus.success: 'success',
  ApplyCouponStatus.failure: 'failure',
};

const _$CancelOrderItemStatusEnumMap = {
  CancelOrderItemStatus.init: 'init',
  CancelOrderItemStatus.loading: 'loading',
  CancelOrderItemStatus.success: 'success',
  CancelOrderItemStatus.failure: 'failure',
};

const _$CancelOrderStatusEnumMap = {
  CancelOrderStatus.init: 'init',
  CancelOrderStatus.loading: 'loading',
  CancelOrderStatus.success: 'success',
  CancelOrderStatus.failure: 'failure',
};

const _$ChangeOrderAddressStatusEnumMap = {
  ChangeOrderAddressStatus.init: 'init',
  ChangeOrderAddressStatus.loading: 'loading',
  ChangeOrderAddressStatus.success: 'success',
  ChangeOrderAddressStatus.failure: 'failure',
};

const _$GetProductColorSizeSyncAttributeStatusEnumMap = {
  GetProductColorSizeSyncAttributeStatus.init: 'init',
  GetProductColorSizeSyncAttributeStatus.loading: 'loading',
  GetProductColorSizeSyncAttributeStatus.success: 'success',
  GetProductColorSizeSyncAttributeStatus.failure: 'failure',
};

const _$ChangeOrderItemVariantStatusEnumMap = {
  ChangeOrderItemVariantStatus.init: 'init',
  ChangeOrderItemVariantStatus.loading: 'loading',
  ChangeOrderItemVariantStatus.success: 'success',
  ChangeOrderItemVariantStatus.failure: 'failure',
};

const _$GetReturnReasonsStatusEnumMap = {
  GetReturnReasonsStatus.init: 'init',
  GetReturnReasonsStatus.loading: 'loading',
  GetReturnReasonsStatus.success: 'success',
  GetReturnReasonsStatus.failure: 'failure',
};

const _$StoreReturnRequestStatusEnumMap = {
  StoreReturnRequestStatus.init: 'init',
  StoreReturnRequestStatus.loading: 'loading',
  StoreReturnRequestStatus.success: 'success',
  StoreReturnRequestStatus.failure: 'failure',
};

const _$StoreReturnRequestProductStatusEnumMap = {
  StoreReturnRequestProductStatus.init: 'init',
  StoreReturnRequestProductStatus.loading: 'loading',
  StoreReturnRequestProductStatus.success: 'success',
  StoreReturnRequestProductStatus.failure: 'failure',
};

const _$CancelReturnRequestStatusEnumMap = {
  CancelReturnRequestStatus.init: 'init',
  CancelReturnRequestStatus.loading: 'loading',
  CancelReturnRequestStatus.success: 'success',
  CancelReturnRequestStatus.failure: 'failure',
};

const _$CancelReturnRequestProductStatusEnumMap = {
  CancelReturnRequestProductStatus.init: 'init',
  CancelReturnRequestProductStatus.loading: 'loading',
  CancelReturnRequestProductStatus.success: 'success',
  CancelReturnRequestProductStatus.failure: 'failure',
};

const _$OrderReturnDetailsStatusEnumMap = {
  OrderReturnDetailsStatus.init: 'init',
  OrderReturnDetailsStatus.loading: 'loading',
  OrderReturnDetailsStatus.success: 'success',
  OrderReturnDetailsStatus.failure: 'failure',
};

const _$GetHiddenOrdersStatusEnumMap = {
  GetHiddenOrdersStatus.init: 'init',
  GetHiddenOrdersStatus.loading: 'loading',
  GetHiddenOrdersStatus.success: 'success',
  GetHiddenOrdersStatus.failure: 'failure',
};

const _$RestoreOrderVisibilityStatusEnumMap = {
  RestoreOrderVisibilityStatus.init: 'init',
  RestoreOrderVisibilityStatus.loading: 'loading',
  RestoreOrderVisibilityStatus.success: 'success',
  RestoreOrderVisibilityStatus.failure: 'failure',
};

const _$HideOrderVisibilityStatusEnumMap = {
  HideOrderVisibilityStatus.init: 'init',
  HideOrderVisibilityStatus.loading: 'loading',
  HideOrderVisibilityStatus.success: 'success',
  HideOrderVisibilityStatus.failure: 'failure',
};
