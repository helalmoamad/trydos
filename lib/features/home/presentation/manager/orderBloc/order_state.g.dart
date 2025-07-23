// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderState _$OrderStateFromJson(Map<String, dynamic> json) => OrderState(
      placeOrderModel: json['placeOrderModel'] == null
          ? null
          : OrdersGroupModel.fromJson(
              json['placeOrderModel'] as Map<String, dynamic>),
      placeOrderStatus: $enumDecodeNullable(
              _$PlaceOrderStatusEnumMap, json['placeOrderStatus']) ??
          PlaceOrderStatus.init,
      getOrdersByOrderGroupIDModel: json['getOrdersByOrderGroupIDModel'] == null
          ? null
          : OrdersGroupModel.fromJson(
              json['getOrdersByOrderGroupIDModel'] as Map<String, dynamic>),
      getOrdersByOrderGroupIDStatus: $enumDecodeNullable(
              _$GetOrdersByOrderGroupIDStatusEnumMap,
              json['getOrdersByOrderGroupIDStatus']) ??
          GetOrdersByOrderGroupIDStatus.init,
      getOrdersByCartGroupIDModel: json['getOrdersByCartGroupIDModel'] == null
          ? null
          : OrdersGroupModel.fromJson(
              json['getOrdersByCartGroupIDModel'] as Map<String, dynamic>),
      getOrdersByCartGroupIDStatus: $enumDecodeNullable(
              _$GetOrdersByCartGroupIDStatusEnumMap,
              json['getOrdersByCartGroupIDStatus']) ??
          GetOrdersByCartGroupIDStatus.init,
      getCustomerWalletStatus: $enumDecodeNullable(
              _$GetCustomerWalletStatusEnumMap,
              json['getCustomerWalletStatus']) ??
          GetCustomerWalletStatus.init,
      customerWalletModel: json['customerWalletModel'] == null
          ? null
          : CustomerWalletModel.fromJson(
              json['customerWalletModel'] as Map<String, dynamic>),
      lastAdressInfoClassToSave: json['lastAdressInfoClassToSave'] == null
          ? null
          : CustomerAddressesInfo.fromJson(
              json['lastAdressInfoClassToSave'] as Map<String, dynamic>),
      getOrdersModel: (json['getOrdersModel'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
                k,
                PaginationModel<List<OrderListModel>>.fromJson(
                    e as Map<String, dynamic>,
                    (value) => (value as List<dynamic>)
                        .map((e) =>
                            OrderListModel.fromJson(e as Map<String, dynamic>))
                        .toList())),
          ) ??
          const {},
      orderTotalSize: (json['orderTotalSize'] as num?)?.toInt() ?? 0,
      setCustomerAddressDefaultStatus: $enumDecodeNullable(
              _$SetCustomerAddressDefaultStatusEnumMap,
              json['setCustomerAddressDefaultStatus']) ??
          SetCustomerAddressDefaultStatus.init,
      getCustomerAddressStatus: $enumDecodeNullable(
              _$GetCustomerAddressesStatusEnumMap,
              json['getCustomerAddressStatus']) ??
          GetCustomerAddressesStatus.init,
      currentAddressChoosed: (json['currentAddressChoosed'] as num?)?.toInt(),
      currentOrederStatus: json['currentOrederStatus'] as String?,
      listOfAddressInfoClassToSave:
          (json['listOfAddressInfoClassToSave'] as List<dynamic>?)
                  ?.map((e) =>
                      CustomerAddressesInfo.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              const [],
      removeAddressToOrderStatus: $enumDecodeNullable(
              _$RemoveAddressToOrderStatusEnumMap,
              json['removeAddressToOrderStatus']) ??
          RemoveAddressToOrderStatus.init,
      addAddressToOrderStatus: $enumDecodeNullable(
              _$AddAddressToOrderStatusEnumMap,
              json['addAddressToOrderStatus']) ??
          AddAddressToOrderStatus.init,
      editAddressToOrderStatus: $enumDecodeNullable(
              _$EditAddressToOrderStatusEnumMap,
              json['editAddressToOrderStatus']) ??
          EditAddressToOrderStatus.init,
      getAddressByCoordinatesStatus: $enumDecodeNullable(
              _$GetAddressByCoordinatesStatusEnumMap,
              json['getAddressByCoordinatesStatus']) ??
          GetAddressByCoordinatesStatus.init,
      getAddressByCoordinatesModel: json['getAddressByCoordinatesModel'] == null
          ? null
          : GetAddressByCoordinatesModel.fromJson(
              json['getAddressByCoordinatesModel'] as Map<String, dynamic>),
      getAddressByTextStatus: $enumDecodeNullable(
              _$GetAddressByTextStatusEnumMap,
              json['getAddressByTextStatus']) ??
          GetAddressByTextStatus.init,
      applyCouponStatus: $enumDecodeNullable(
              _$ApplyCouponStatusEnumMap, json['applyCouponStatus']) ??
          ApplyCouponStatus.init,
      applyCouponModel: json['applyCouponModel'] == null
          ? null
          : ApplyCouponModel.fromJson(
              json['applyCouponModel'] as Map<String, dynamic>),
      cancelOrderItemStatus: $enumDecodeNullable(
              _$CancelOrderItemStatusEnumMap, json['cancelOrderItemStatus']) ??
          CancelOrderItemStatus.init,
      cancelOrderStatus: $enumDecodeNullable(
              _$CancelOrderStatusEnumMap, json['cancelOrderStatus']) ??
          CancelOrderStatus.init,
      changeOrderAddressStatus: $enumDecodeNullable(
              _$ChangeOrderAddressStatusEnumMap,
              json['changeOrderAddressStatus']) ??
          ChangeOrderAddressStatus.init,
      getProductColorSizeSyncAttributeStatus: $enumDecodeNullable(
              _$GetProductColorSizeSyncAttributeStatusEnumMap,
              json['getProductColorSizeSyncAttributeStatus']) ??
          GetProductColorSizeSyncAttributeStatus.init,
      colorSizeForProductModel: json['colorSizeForProductModel'] == null
          ? null
          : ColorSizeForProductModel.fromJson(
              json['colorSizeForProductModel'] as Map<String, dynamic>),
      resultSearch: (json['resultSearch'] as List<dynamic>?)
              ?.map((e) => ResultSearch.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      provincesByIso: (json['provincesByIso'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      changeOrderItemVariantStatus: $enumDecodeNullable(
              _$ChangeOrderItemVariantStatusEnumMap,
              json['changeOrderItemVariantStatus']) ??
          ChangeOrderItemVariantStatus.init,
    );

Map<String, dynamic> _$OrderStateToJson(OrderState instance) =>
    <String, dynamic>{
      'placeOrderModel': instance.placeOrderModel?.toJson(),
      'placeOrderStatus': _$PlaceOrderStatusEnumMap[instance.placeOrderStatus],
      'getOrdersByOrderGroupIDModel':
          instance.getOrdersByOrderGroupIDModel?.toJson(),
      'getOrdersByOrderGroupIDStatus': _$GetOrdersByOrderGroupIDStatusEnumMap[
          instance.getOrdersByOrderGroupIDStatus],
      'customerWalletModel': instance.customerWalletModel?.toJson(),
      'getCustomerWalletStatus':
          _$GetCustomerWalletStatusEnumMap[instance.getCustomerWalletStatus],
      'getOrdersModel': instance.getOrdersModel?.map((k, e) => MapEntry(
          k,
          e.toJson(
            (value) => value.map((e) => e.toJson()).toList(),
          ))),
      'getOrdersByCartGroupIDModel':
          instance.getOrdersByCartGroupIDModel?.toJson(),
      'getOrdersByCartGroupIDStatus': _$GetOrdersByCartGroupIDStatusEnumMap[
          instance.getOrdersByCartGroupIDStatus],
      'setCustomerAddressDefaultStatus':
          _$SetCustomerAddressDefaultStatusEnumMap[
              instance.setCustomerAddressDefaultStatus],
      'getCustomerAddressStatus': _$GetCustomerAddressesStatusEnumMap[
          instance.getCustomerAddressStatus],
      'currentAddressChoosed': instance.currentAddressChoosed,
      'listOfAddressInfoClassToSave': instance.listOfAddressInfoClassToSave
          ?.map((e) => e.toJson())
          .toList(),
      'removeAddressToOrderStatus': _$RemoveAddressToOrderStatusEnumMap[
          instance.removeAddressToOrderStatus],
      'addAddressToOrderStatus':
          _$AddAddressToOrderStatusEnumMap[instance.addAddressToOrderStatus],
      'lastAdressInfoClassToSave': instance.lastAdressInfoClassToSave?.toJson(),
      'editAddressToOrderStatus':
          _$EditAddressToOrderStatusEnumMap[instance.editAddressToOrderStatus],
      'getAddressByCoordinatesStatus': _$GetAddressByCoordinatesStatusEnumMap[
          instance.getAddressByCoordinatesStatus],
      'getAddressByCoordinatesModel':
          instance.getAddressByCoordinatesModel?.toJson(),
      'getAddressByTextStatus':
          _$GetAddressByTextStatusEnumMap[instance.getAddressByTextStatus],
      'resultSearch': instance.resultSearch?.map((e) => e.toJson()).toList(),
      'provincesByIso': instance.provincesByIso,
      'orderTotalSize': instance.orderTotalSize,
      'currentOrederStatus': instance.currentOrederStatus,
      'applyCouponStatus':
          _$ApplyCouponStatusEnumMap[instance.applyCouponStatus],
      'applyCouponModel': instance.applyCouponModel?.toJson(),
      'cancelOrderItemStatus':
          _$CancelOrderItemStatusEnumMap[instance.cancelOrderItemStatus],
      'cancelOrderStatus':
          _$CancelOrderStatusEnumMap[instance.cancelOrderStatus],
      'changeOrderAddressStatus':
          _$ChangeOrderAddressStatusEnumMap[instance.changeOrderAddressStatus],
      'getProductColorSizeSyncAttributeStatus':
          _$GetProductColorSizeSyncAttributeStatusEnumMap[
              instance.getProductColorSizeSyncAttributeStatus],
      'colorSizeForProductModel': instance.colorSizeForProductModel?.toJson(),
      'changeOrderItemVariantStatus': _$ChangeOrderItemVariantStatusEnumMap[
          instance.changeOrderItemVariantStatus],
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
