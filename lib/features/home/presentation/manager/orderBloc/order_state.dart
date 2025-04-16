import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../../../../core/data/model/pagination_model.dart';
import '../../../data/models/apply_coupon_model.dart';
import '../../../data/models/customer_wallet_model.dart';
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
    this.getOrdersModel = const {},
    this.setCustomerAddressDefaultStatus = SetCustomerAddressDefaultStatus.init,
    this.getCustomerAddressStatus = GetCustomerAddressesStatus.init,
    this.currentAddressChoosed,
    this.listOfAddressInfoClassToSave = const [],
    this.removeAddressToOrderStatus = RemoveAddressToOrderStatus.init,
    this.addAddressToOrderStatus = AddAddressToOrderStatus.init,
    this.editAddressToOrderStatus = EditAddressToOrderStatus.init,
    this.getAddressByCoordinatesStatus = GetAddressByCoordinatesStatus.init,
    this.getAddressByCoordinatesModel,
    this.getAddressByTextStatus = GetAddressByTextStatus.init,
    this.applyCouponStatus = ApplyCouponStatus.init,
    this.resultSearch = const [],
    this.applyCouponModel,
  });

  final OrdersGroupModel? placeOrderModel;
  final PlaceOrderStatus? placeOrderStatus;
  final OrdersGroupModel? getOrdersByOrderGroupIDModel;
  final GetOrdersByOrderGroupIDStatus? getOrdersByOrderGroupIDStatus;
  final CustomerWalletModel? customerWalletModel;
  final GetCustomerWalletStatus? getCustomerWalletStatus;
  final Map<String, PaginationModel<OrderListModel>> getOrdersModel;
  // final PaginationModel<OrderListModel>? getOrdersModel;
  final OrdersGroupModel? getOrdersByCartGroupIDModel;
  final GetOrdersByCartGroupIDStatus? getOrdersByCartGroupIDStatus;
  final SetCustomerAddressDefaultStatus? setCustomerAddressDefaultStatus;
  final GetCustomerAddressesStatus? getCustomerAddressStatus;
  final int? currentAddressChoosed;
  final List<CustomerAddressesInfo>? listOfAddressInfoClassToSave;
  final RemoveAddressToOrderStatus? removeAddressToOrderStatus;
  final AddAddressToOrderStatus? addAddressToOrderStatus;
  final EditAddressToOrderStatus? editAddressToOrderStatus;
  final GetAddressByCoordinatesStatus? getAddressByCoordinatesStatus;
  final GetAddressByCoordinatesModel? getAddressByCoordinatesModel;
  final GetAddressByTextStatus? getAddressByTextStatus;
  final List<ResultSearch>? resultSearch;
  final ApplyCouponStatus? applyCouponStatus;
  final ApplyCouponModel? applyCouponModel;

  @override
  List<Object?> get props => [
        placeOrderModel,
        placeOrderStatus,
        getOrdersByOrderGroupIDStatus,
        getOrdersByOrderGroupIDModel,
        getOrdersByCartGroupIDStatus,
        getOrdersByCartGroupIDModel,
        getCustomerWalletStatus,
        customerWalletModel,
        getOrdersModel,
        setCustomerAddressDefaultStatus,
        getCustomerAddressStatus,
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
    final Map<String, PaginationModel<OrderListModel>>? getOrdersModel,
    final SetCustomerAddressDefaultStatus? setCustomerAddressDefaultStatus,
    final GetCustomerAddressesStatus? getCustomerAddressesStatus,
    final int? currentAddressChoosed,
    final List<CustomerAddressesInfo>? listOfAdressInfoClassToSave,
    final RemoveAddressToOrderStatus? removeAddressToOrderStatus,
    final AddAddressToOrderStatus? addAddressToOrderStatus,
    final EditAddressToOrderStatus? editAddressToOrderStatus,
    final GetAddressByCoordinatesStatus? getAddressByCoordinatesStatus,
    final GetAddressByCoordinatesModel? getAddressByCoordinatesModel,
    final GetAddressByTextStatus? getAddressByTextStatus,
    final List<ResultSearch>? resultSearch,
    final ApplyCouponStatus? applyCouponStatus,
    final ApplyCouponModel? applyCouponModel,
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
      getOrdersByCartGroupIDStatus:
          getOrdersByCartGroupIDStatus ?? this.getOrdersByCartGroupIDStatus,
      getCustomerWalletStatus:
          getCustomerWalletStatus ?? this.getCustomerWalletStatus,
      customerWalletModel: customerWalletModel ?? this.customerWalletModel,
      getOrdersModel: getOrdersModel ?? this.getOrdersModel,
      setCustomerAddressDefaultStatus: setCustomerAddressDefaultStatus ??
          this.setCustomerAddressDefaultStatus,
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
    );
  }

  factory OrderState.fromJson(Map<String, dynamic> data) =>
      _$OrderStateFromJson(data);

  Map<String, dynamic> toJson() => _$OrderStateToJson(this);
}
