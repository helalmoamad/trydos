import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../../../../core/data/model/pagination_model.dart';
import '../../../data/models/apply_coupon_model.dart';
import '../../../data/models/cancel_order_item_model.dart';
import '../../../data/models/customer_wallet_model.dart';
import '../../../data/models/color_size_for_product.dart';
import '../../../data/models/get_address_by_coordinates_model.dart';
import '../../../data/models/get_address_by_text_model.dart';
import '../../../data/models/get_list_of_customer_addresses_model.dart';
import '../../../data/models/get_orders_model.dart';
import '../../../data/models/place_order_model.dart';

part 'order_state.g.dart';

enum PlaceOrderStatus { init, loading, success, failure, unavailable }

enum GetOrdersByOrderGroupIDStatus { init, loading, success, failure }

enum GetOrdersByCartGroupIDStatus { init, loading, success, failure }

enum GetCustomerWalletStatus { init, loading, success, failure }

enum SetCustomerAddressDefaultStatus { init, loading, success, failure }

enum GetCustomerAddressesStatus { init, loading, success, failure }

enum RemoveAddressToOrderStatus { init, loading, success, failure }

enum AddAddressToOrderStatus { init, loading, success, failure }

enum EditAddressToOrderStatus { init, loading, success, failure }

enum GetAddressByCoordinatesStatus { init, loading, success, failure }

enum GetAddressByTextStatus { init, loading, success, failure }

enum ApplyCouponStatus { init, loading, success, failure }

enum CancelOrderItemStatus { init, loading, success, failure }

enum CancelOrderStatus { init, loading, success, failure }

enum ChangeOrderAddressStatus { init, loading, success, failure }

enum GetProductColorSizeSyncAttributeStatus { init, loading, success, failure }

enum ChangeOrderItemVariantStatus { init, loading, success, failure }

@JsonSerializable(explicitToJson: true)
@immutable
class OrderState extends Equatable {
  const OrderState({
    this.placeOrderModel,
    this.placeOrderStatus = PlaceOrderStatus.init,
    this.getOrdersByOrderGroupIDModel,
    this.getOrdersByOrderGroupIDStatus = GetOrdersByOrderGroupIDStatus.init,
    this.getOrdersByCartGroupIDModel,
    this.getOrdersByCartGroupIDStatus = GetOrdersByCartGroupIDStatus.init,
    this.getCustomerWalletStatus = GetCustomerWalletStatus.init,
    this.customerWalletModel,
    this.lastAdressInfoClassToSave,
    this.getOrdersModel = const {},
    this.orderTotalSize = 0,
    this.setCustomerAddressDefaultStatus = SetCustomerAddressDefaultStatus.init,
    this.getCustomerAddressStatus = GetCustomerAddressesStatus.init,
    this.currentAddressChoosed,
    this.currentOrederStatus,
    this.listOfAddressInfoClassToSave = const [],
    this.removeAddressToOrderStatus = RemoveAddressToOrderStatus.init,
    this.addAddressToOrderStatus = AddAddressToOrderStatus.init,
    this.editAddressToOrderStatus = EditAddressToOrderStatus.init,
    this.getAddressByCoordinatesStatus = GetAddressByCoordinatesStatus.init,
    this.getAddressByCoordinatesModel,
    this.getAddressByTextStatus = GetAddressByTextStatus.init,
    this.applyCouponStatus = ApplyCouponStatus.init,
    this.applyCouponModel,
    this.cancelOrderItemStatus = CancelOrderItemStatus.init,
    this.cancelOrderStatus = CancelOrderStatus.init,
    this.changeOrderAddressStatus = ChangeOrderAddressStatus.init,
    this.getProductColorSizeSyncAttributeStatus =
        GetProductColorSizeSyncAttributeStatus.init,
    this.colorSizeForProductModel,
    this.resultSearch = const [],
    this.provincesByIso = const [],
    this.changeOrderItemVariantStatus = ChangeOrderItemVariantStatus.init,
  });

  final OrdersGroupModel? placeOrderModel;
  final PlaceOrderStatus? placeOrderStatus;
  final OrdersGroupModel? getOrdersByOrderGroupIDModel;
  final GetOrdersByOrderGroupIDStatus? getOrdersByOrderGroupIDStatus;
  final CustomerWalletModel? customerWalletModel;
  final GetCustomerWalletStatus? getCustomerWalletStatus;
  final Map<String, PaginationModel<List<OrderListModel>>>? getOrdersModel;
  // final PaginationModel<OrderListModel>? getOrdersModel;
  final OrdersGroupModel? getOrdersByCartGroupIDModel;
  final GetOrdersByCartGroupIDStatus? getOrdersByCartGroupIDStatus;
  final SetCustomerAddressDefaultStatus? setCustomerAddressDefaultStatus;
  final GetCustomerAddressesStatus? getCustomerAddressStatus;
  final int? currentAddressChoosed;
  final List<CustomerAddressesInfo>? listOfAddressInfoClassToSave;
  final RemoveAddressToOrderStatus? removeAddressToOrderStatus;
  final AddAddressToOrderStatus? addAddressToOrderStatus;
  final CustomerAddressesInfo? lastAdressInfoClassToSave;
  final EditAddressToOrderStatus? editAddressToOrderStatus;
  final GetAddressByCoordinatesStatus? getAddressByCoordinatesStatus;
  final GetAddressByCoordinatesModel? getAddressByCoordinatesModel;
  final GetAddressByTextStatus? getAddressByTextStatus;
  final List<ResultSearch>? resultSearch;
  final List<String>? provincesByIso;
  final int orderTotalSize;
  final String? currentOrederStatus;
  final ApplyCouponStatus? applyCouponStatus;
  final ApplyCouponModel? applyCouponModel;
  final CancelOrderItemStatus? cancelOrderItemStatus;
  final CancelOrderStatus? cancelOrderStatus;
  final ChangeOrderAddressStatus? changeOrderAddressStatus;
  final GetProductColorSizeSyncAttributeStatus?
      getProductColorSizeSyncAttributeStatus;
  final ColorSizeForProductModel? colorSizeForProductModel;
  final ChangeOrderItemVariantStatus? changeOrderItemVariantStatus;

  @override
  List<Object?> get props => [
        placeOrderModel,
        provincesByIso,
        placeOrderStatus,
        lastAdressInfoClassToSave,
        getOrdersByOrderGroupIDStatus,
        getOrdersByOrderGroupIDModel,
        getOrdersByCartGroupIDStatus,
        getOrdersByCartGroupIDModel,
        currentOrederStatus,
        getCustomerWalletStatus,
        customerWalletModel,
        getOrdersModel,
        setCustomerAddressDefaultStatus,
        getCustomerAddressStatus,
        orderTotalSize,
        currentAddressChoosed,
        listOfAddressInfoClassToSave,
        removeAddressToOrderStatus,
        addAddressToOrderStatus,
        editAddressToOrderStatus,
        getAddressByCoordinatesStatus,
        getAddressByCoordinatesModel,
        getAddressByTextStatus,
        resultSearch,
        applyCouponStatus,
        applyCouponModel,
        cancelOrderItemStatus,
        cancelOrderStatus,
        changeOrderAddressStatus,
        getProductColorSizeSyncAttributeStatus,
        colorSizeForProductModel,
        changeOrderItemVariantStatus,
      ];

  OrderState copyWith({
    final PlaceOrderStatus? placeOrderStatus,
    final OrdersGroupModel? placeOrderModel,
    final OrdersGroupModel? getOrdersByOrderGroupIDModel,
    final GetOrdersByOrderGroupIDStatus? getOrdersByOrderGroupIDStatus,
    final OrdersGroupModel? getOrdersByCartGroupIDModel,
    final GetOrdersByCartGroupIDStatus? getOrdersByCartGroupIDStatus,
    final CustomerWalletModel? customerWalletModel,
    final GetCustomerWalletStatus? getCustomerWalletStatus,
    final Map<String, PaginationModel<List<OrderListModel>>>? getOrdersModel,
    final SetCustomerAddressDefaultStatus? setCustomerAddressDefaultStatus,
    final GetCustomerAddressesStatus? getCustomerAddressesStatus,
    final int? currentAddressChoosed,
    final List<CustomerAddressesInfo>? listOfAdressInfoClassToSave,
    final CustomerAddressesInfo? lastAdressInfoClassToSave,
    final int? orderTotalSize,
    final String? currentOrederStatus,
    final RemoveAddressToOrderStatus? removeAddressToOrderStatus,
    final AddAddressToOrderStatus? addAddressToOrderStatus,
    final EditAddressToOrderStatus? editAddressToOrderStatus,
    final GetAddressByCoordinatesStatus? getAddressByCoordinatesStatus,
    final GetAddressByCoordinatesModel? getAddressByCoordinatesModel,
    final GetAddressByTextStatus? getAddressByTextStatus,
    final List<ResultSearch>? resultSearch,
    List<String>? provincesByIso,
    final ApplyCouponStatus? applyCouponStatus,
    final ApplyCouponModel? applyCouponModel,
    final CancelOrderItemStatus? cancelOrderItemStatus,
    final CancelOrderStatus? cancelOrderStatus,
    final ChangeOrderAddressStatus? changeOrderAddressStatus,
    final GetProductColorSizeSyncAttributeStatus?
        getProductColorSizeSyncAttributeStatus,
    final ColorSizeForProductModel? colorSizeForProductModel,
    final ChangeOrderItemVariantStatus? changeOrderItemVariantStatus,
  }) {
    return OrderState(
      placeOrderModel: placeOrderModel ?? this.placeOrderModel,
      placeOrderStatus: placeOrderStatus ?? this.placeOrderStatus,
      getOrdersByOrderGroupIDModel:
          getOrdersByOrderGroupIDModel ?? this.getOrdersByOrderGroupIDModel,
      getOrdersByOrderGroupIDStatus:
          getOrdersByOrderGroupIDStatus ?? this.getOrdersByOrderGroupIDStatus,
      getOrdersByCartGroupIDModel:
          getOrdersByCartGroupIDModel ?? this.getOrdersByCartGroupIDModel,
      provincesByIso: provincesByIso ?? this.provincesByIso,
      getOrdersByCartGroupIDStatus:
          getOrdersByCartGroupIDStatus ?? this.getOrdersByCartGroupIDStatus,
      getCustomerWalletStatus:
          getCustomerWalletStatus ?? this.getCustomerWalletStatus,
      customerWalletModel: customerWalletModel ?? this.customerWalletModel,
      getOrdersModel: getOrdersModel ?? this.getOrdersModel,
      setCustomerAddressDefaultStatus: setCustomerAddressDefaultStatus ??
          this.setCustomerAddressDefaultStatus,
      currentOrederStatus: currentOrederStatus ?? this.currentOrederStatus,
      lastAdressInfoClassToSave:
          lastAdressInfoClassToSave ?? this.lastAdressInfoClassToSave,
      orderTotalSize: orderTotalSize ?? this.orderTotalSize,
      getCustomerAddressStatus:
          getCustomerAddressesStatus ?? this.getCustomerAddressStatus,
      currentAddressChoosed:
          currentAddressChoosed ?? this.currentAddressChoosed,
      listOfAddressInfoClassToSave:
          listOfAdressInfoClassToSave ?? this.listOfAddressInfoClassToSave,
      removeAddressToOrderStatus:
          removeAddressToOrderStatus ?? this.removeAddressToOrderStatus,
      addAddressToOrderStatus:
          addAddressToOrderStatus ?? this.addAddressToOrderStatus,
      editAddressToOrderStatus:
          editAddressToOrderStatus ?? this.editAddressToOrderStatus,
      getAddressByCoordinatesStatus:
          getAddressByCoordinatesStatus ?? this.getAddressByCoordinatesStatus,
      getAddressByCoordinatesModel:
          getAddressByCoordinatesModel ?? this.getAddressByCoordinatesModel,
      getAddressByTextStatus:
          getAddressByTextStatus ?? this.getAddressByTextStatus,
      resultSearch: resultSearch ?? this.resultSearch,
      applyCouponStatus: applyCouponStatus ?? this.applyCouponStatus,
      applyCouponModel: applyCouponModel ?? this.applyCouponModel,
      cancelOrderItemStatus:
          cancelOrderItemStatus ?? this.cancelOrderItemStatus,
      cancelOrderStatus: cancelOrderStatus ?? this.cancelOrderStatus,
      changeOrderAddressStatus:
          changeOrderAddressStatus ?? this.changeOrderAddressStatus,
      getProductColorSizeSyncAttributeStatus:
          getProductColorSizeSyncAttributeStatus ??
              this.getProductColorSizeSyncAttributeStatus,
      colorSizeForProductModel:
          colorSizeForProductModel ?? this.colorSizeForProductModel,
      changeOrderItemVariantStatus:
          changeOrderItemVariantStatus ?? this.changeOrderItemVariantStatus,
    );
  }

  factory OrderState.fromJson(Map<String, dynamic> data) =>
      _$OrderStateFromJson(data);

  Map<String, dynamic> toJson() => _$OrderStateToJson(this);
}
