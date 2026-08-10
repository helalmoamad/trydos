import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../../../../core/data/model/pagination_model.dart';
import '../../../data/models/apply_coupon_model.dart';

import '../../../data/models/customer_wallet_model.dart';
import '../../../data/models/color_size_for_product.dart';
import '../../../data/models/get_address_by_coordinates_model.dart';
import '../../../data/models/get_address_by_text_model.dart';
import '../../../data/models/get_list_of_customer_addresses_model.dart';
import '../../../data/models/get_hidden_orders_model.dart';
import '../../../data/models/get_orders_model.dart';
import '../../../data/models/place_order_model.dart';

import '../../../data/models/return_reasons_model.dart';

import '../../../data/models/get_order_details_return_model.dart';

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

enum UploadImagesForReturnProductStatus { init, loading, success, failure }

enum UploadImagesToCloudinaryStatus { init, loading, success, failure }

/// حالة إرسال بلاغ عن منتج داخل طلب
enum ReportOrderProductStatus { init, loading, success, failure }

enum CancelOrderStatus { init, loading, success, failure }

enum ChangeOrderAddressStatus { init, loading, success, failure }

enum GetProductColorSizeSyncAttributeStatus { init, loading, success, failure }

enum ChangeOrderItemVariantStatus { init, loading, success, failure }

//enum AddOrderCommentStatus { init, loading, success, failure }

//enum UpdateOrderCommentStatus { init, loading, success, failure }

enum GetReturnReasonsStatus { init, loading, success, failure }

enum StoreReturnRequestProductStatus { init, loading, success, failure }

enum UpdateReturnRequestProductStatus { init, loading, success, failure }

enum CancelReturnRequestStatus { init, loading, success, failure }

enum CancelReturnRequestProductStatus { init, loading, success, failure }

enum StoreReturnRequestStatus { init, loading, success, failure }

enum OrderReturnRequestsViewStatus { init, loading, success, failure }

enum ConfirmReturnRequestStatus { init, loading, success, failure }

enum WalletCheckoutStatus { init, loading, success, failure, unAuth }

enum OrderReturnDetailsStatus { init, loading, success, failure }

enum GetHiddenOrdersStatus { init, loading, success, failure }

enum RestoreOrderVisibilityStatus { init, loading, success, failure }

enum HideOrderVisibilityStatus { init, loading, success, failure }

@JsonSerializable(explicitToJson: true)
@immutable
class OrderState extends Equatable {
  const OrderState({
    this.placeOrderModel,
    this.walletCheckoutStatus = WalletCheckoutStatus.init,
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
    this.orderReturnRequestsViewStatus,
    this.confirmReturnRequestStatus,
    this.currentOrederStatus,
    this.updateReturnRequestProductStatus =
        UpdateReturnRequestProductStatus.init,
    this.listOfAddressInfoClassToSave = const [],
    this.removeAddressToOrderStatus = RemoveAddressToOrderStatus.init,
    this.addAddressToOrderStatus = AddAddressToOrderStatus.init,
    this.editAddressToOrderStatus = EditAddressToOrderStatus.init,
    this.getAddressByCoordinatesStatus = GetAddressByCoordinatesStatus.init,
    this.getAddressByCoordinatesModel,
    this.uploadImagesForReturnProductStatus =
        UploadImagesForReturnProductStatus.init,
    this.uploadImagesToCloudinaryStatus = UploadImagesToCloudinaryStatus.init,
    this.reportOrderProductStatus = ReportOrderProductStatus.init,
    this.getAddressByTextStatus = GetAddressByTextStatus.init,
    this.applyCouponStatus = ApplyCouponStatus.init,
    this.applyCouponModel,
    this.imagesForReturn = const [],
    this.imagesForComment = const [],
    this.cancelOrderItemStatus = CancelOrderItemStatus.init,
    this.cancelOrderStatus = CancelOrderStatus.init,
    this.changeOrderAddressStatus = ChangeOrderAddressStatus.init,
    this.getProductColorSizeSyncAttributeStatus =
        GetProductColorSizeSyncAttributeStatus.init,
    this.colorSizeForProductModel,
    this.resultSearch = const [],
    this.provincesByIso = const [],
    this.changeOrderItemVariantStatus = ChangeOrderItemVariantStatus.init,
    // this.addOrderCommentStatus = AddOrderCommentStatus.init,
    //this.updateOrderCommentStatus = UpdateOrderCommentStatus.init,
    this.getReturnReasonsStatus = GetReturnReasonsStatus.init,
    this.returnReasonsModel,
    this.storeReturnRequestStatus,
    this.storeReturnRequestProductStatus = StoreReturnRequestProductStatus.init,
    this.cancelReturnRequestStatus = CancelReturnRequestStatus.init,
    this.cancelReturnRequestProductStatus =
        CancelReturnRequestProductStatus.init,
    this.orderReturnDetailsStatus = OrderReturnDetailsStatus.init,
    this.orderReturnDetailsModel,
    this.getHiddenOrdersStatus = GetHiddenOrdersStatus.init,
    this.getHiddenOrdersModel,
    this.restoreOrderVisibilityStatus = RestoreOrderVisibilityStatus.init,
    this.hideOrderVisibilityStatus = HideOrderVisibilityStatus.init,
  });
  final OrderReturnRequestsViewStatus? orderReturnRequestsViewStatus;
  final ConfirmReturnRequestStatus? confirmReturnRequestStatus;
  final OrdersGroupModel? placeOrderModel;
  final PlaceOrderStatus? placeOrderStatus;
  final StoreReturnRequestStatus? storeReturnRequestStatus;
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
  final List<String>? imagesForReturn;
  final List<String>? imagesForComment;
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
  //final AddOrderCommentStatus? addOrderCommentStatus;
  final UpdateReturnRequestProductStatus? updateReturnRequestProductStatus;
  // final UpdateOrderCommentStatus? updateOrderCommentStatus;
  final GetReturnReasonsStatus? getReturnReasonsStatus;
  final ReturnReasonsModel? returnReasonsModel;
  final WalletCheckoutStatus? walletCheckoutStatus;
  final UploadImagesForReturnProductStatus uploadImagesForReturnProductStatus;
  final UploadImagesToCloudinaryStatus uploadImagesToCloudinaryStatus;
  final ReportOrderProductStatus reportOrderProductStatus;
  final StoreReturnRequestProductStatus? storeReturnRequestProductStatus;
  final CancelReturnRequestStatus? cancelReturnRequestStatus;
  final CancelReturnRequestProductStatus? cancelReturnRequestProductStatus;
  final OrderReturnDetailsStatus orderReturnDetailsStatus;
  final GetOrderReturntDetailsModel? orderReturnDetailsModel;
  final GetHiddenOrdersStatus? getHiddenOrdersStatus;
  final GetHiddenOrdersModel? getHiddenOrdersModel;
  final RestoreOrderVisibilityStatus? restoreOrderVisibilityStatus;
  final HideOrderVisibilityStatus? hideOrderVisibilityStatus;

  @override
  List<Object?> get props => [
    placeOrderModel,
    provincesByIso,
    placeOrderStatus,
    lastAdressInfoClassToSave,
    getOrdersByOrderGroupIDStatus,
    getOrdersByOrderGroupIDModel,
    walletCheckoutStatus,
    getOrdersByCartGroupIDStatus,
    getOrdersByCartGroupIDModel,
    currentOrederStatus,
    getCustomerWalletStatus,
    customerWalletModel,
    getOrdersModel,
    updateReturnRequestProductStatus,
    setCustomerAddressDefaultStatus,
    getCustomerAddressStatus,
    storeReturnRequestStatus,
    orderTotalSize,
    uploadImagesForReturnProductStatus,
    currentAddressChoosed,
    listOfAddressInfoClassToSave,
    removeAddressToOrderStatus,
    addAddressToOrderStatus,
    uploadImagesToCloudinaryStatus,
    reportOrderProductStatus,
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
    // addOrderCommentStatus,
    // updateOrderCommentStatus,
    getReturnReasonsStatus,
    returnReasonsModel,
    storeReturnRequestProductStatus,
    cancelReturnRequestStatus,
    confirmReturnRequestStatus,
    cancelReturnRequestProductStatus,
    orderReturnRequestsViewStatus,
    imagesForReturn,
    imagesForComment,
    orderReturnDetailsStatus,
    orderReturnDetailsModel,
    getHiddenOrdersStatus,
    getHiddenOrdersModel,
    restoreOrderVisibilityStatus,
    hideOrderVisibilityStatus,
  ];

  OrderState copyWith({
    final PlaceOrderStatus? placeOrderStatus,
    final OrdersGroupModel? placeOrderModel,
    final WalletCheckoutStatus? walletCheckoutStatus,
    final List<String>? imagesForReturn,
    final List<String>? imagesForComment,
    final OrderReturnRequestsViewStatus? orderReturnRequestsViewStatus,
    final ConfirmReturnRequestStatus? confirmReturnRequestStatus,
    final OrdersGroupModel? getOrdersByOrderGroupIDModel,
    final GetOrdersByOrderGroupIDStatus? getOrdersByOrderGroupIDStatus,
    final OrdersGroupModel? getOrdersByCartGroupIDModel,
    final GetOrdersByCartGroupIDStatus? getOrdersByCartGroupIDStatus,
    final CustomerWalletModel? customerWalletModel,
    final GetCustomerWalletStatus? getCustomerWalletStatus,
    final UploadImagesForReturnProductStatus?
    uploadImagesForReturnProductStatus,
    final UploadImagesToCloudinaryStatus? uploadImagesToCloudinaryStatus,
    final ReportOrderProductStatus? reportOrderProductStatus,
    final Map<String, PaginationModel<List<OrderListModel>>>? getOrdersModel,
    final SetCustomerAddressDefaultStatus? setCustomerAddressDefaultStatus,
    final GetCustomerAddressesStatus? getCustomerAddressesStatus,
    final int? currentAddressChoosed,
    final StoreReturnRequestStatus? storeReturnRequestStatus,
    final UpdateReturnRequestProductStatus? updateReturnRequestProductStatus,
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
    // final AddOrderCommentStatus? addOrderCommentStatus,
    //final UpdateOrderCommentStatus? updateOrderCommentStatus,
    final GetReturnReasonsStatus? getReturnReasonsStatus,
    final ReturnReasonsModel? returnReasonsModel,
    final StoreReturnRequestProductStatus? storeReturnRequestProductStatus,
    final CancelReturnRequestStatus? cancelReturnRequestStatus,
    final CancelReturnRequestProductStatus? cancelReturnRequestProductStatus,
    final OrderReturnDetailsStatus? orderReturnDetailsStatus,
    final GetOrderReturntDetailsModel? orderReturnDetailsModel,
    final GetHiddenOrdersStatus? getHiddenOrdersStatus,
    final GetHiddenOrdersModel? getHiddenOrdersModel,
    final RestoreOrderVisibilityStatus? restoreOrderVisibilityStatus,
    final HideOrderVisibilityStatus? hideOrderVisibilityStatus,
  }) {
    return OrderState(
      placeOrderModel: placeOrderModel ?? this.placeOrderModel,
      placeOrderStatus: placeOrderStatus ?? this.placeOrderStatus,
      getOrdersByOrderGroupIDModel:
          getOrdersByOrderGroupIDModel ?? this.getOrdersByOrderGroupIDModel,
      updateReturnRequestProductStatus:
          updateReturnRequestProductStatus ??
          this.updateReturnRequestProductStatus,
      walletCheckoutStatus: walletCheckoutStatus ?? this.walletCheckoutStatus,
      storeReturnRequestStatus:
          storeReturnRequestStatus ?? this.storeReturnRequestStatus,
      getOrdersByOrderGroupIDStatus:
          getOrdersByOrderGroupIDStatus ?? this.getOrdersByOrderGroupIDStatus,
      uploadImagesForReturnProductStatus:
          uploadImagesForReturnProductStatus ??
          this.uploadImagesForReturnProductStatus,

      uploadImagesToCloudinaryStatus:
          uploadImagesToCloudinaryStatus ?? this.uploadImagesToCloudinaryStatus,
      reportOrderProductStatus:
          reportOrderProductStatus ?? this.reportOrderProductStatus,
      getOrdersByCartGroupIDModel:
          getOrdersByCartGroupIDModel ?? this.getOrdersByCartGroupIDModel,
      imagesForReturn: imagesForReturn ?? this.imagesForReturn,
      imagesForComment: imagesForComment ?? this.imagesForComment,
      provincesByIso: provincesByIso ?? this.provincesByIso,
      getOrdersByCartGroupIDStatus:
          getOrdersByCartGroupIDStatus ?? this.getOrdersByCartGroupIDStatus,
      getCustomerWalletStatus:
          getCustomerWalletStatus ?? this.getCustomerWalletStatus,
      orderReturnRequestsViewStatus:
          orderReturnRequestsViewStatus ?? this.orderReturnRequestsViewStatus,
      confirmReturnRequestStatus:
          confirmReturnRequestStatus ?? this.confirmReturnRequestStatus,
      customerWalletModel: customerWalletModel ?? this.customerWalletModel,
      getOrdersModel: getOrdersModel ?? this.getOrdersModel,
      setCustomerAddressDefaultStatus:
          setCustomerAddressDefaultStatus ??
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
      //   addOrderCommentStatus:
      //       addOrderCommentStatus ?? this.addOrderCommentStatus,
      //  updateOrderCommentStatus:
      //    updateOrderCommentStatus ?? this.updateOrderCommentStatus,
      getReturnReasonsStatus:
          getReturnReasonsStatus ?? this.getReturnReasonsStatus,
      returnReasonsModel: returnReasonsModel ?? this.returnReasonsModel,
      storeReturnRequestProductStatus:
          storeReturnRequestProductStatus ??
          this.storeReturnRequestProductStatus,
      cancelReturnRequestStatus:
          cancelReturnRequestStatus ?? this.cancelReturnRequestStatus,
      cancelReturnRequestProductStatus:
          cancelReturnRequestProductStatus ??
          this.cancelReturnRequestProductStatus,
      orderReturnDetailsStatus:
          orderReturnDetailsStatus ?? this.orderReturnDetailsStatus,
      orderReturnDetailsModel:
          orderReturnDetailsModel ?? this.orderReturnDetailsModel,
      getHiddenOrdersStatus:
          getHiddenOrdersStatus ?? this.getHiddenOrdersStatus,
      getHiddenOrdersModel: getHiddenOrdersModel ?? this.getHiddenOrdersModel,
      restoreOrderVisibilityStatus:
          restoreOrderVisibilityStatus ?? this.restoreOrderVisibilityStatus,
      hideOrderVisibilityStatus:
          hideOrderVisibilityStatus ?? this.hideOrderVisibilityStatus,
    );
  }

  factory OrderState.fromJson(Map<String, dynamic> data) =>
      _$OrderStateFromJson(data);

  Map<String, dynamic> toJson() => _$OrderStateToJson(this);
}
