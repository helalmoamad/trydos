import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:trydos/features/home/data/models/get_orders_model.dart';
import 'package:trydos/features/home/domain/use_cases/cancel_return_request_product_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/order_return_requests_view_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/store_return_request_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/update_return_request_product_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/wallet_checkout_usecase.dart';
import '../../../data/models/get_list_of_customer_addresses_model.dart';
import '../../../domain/use_cases/place_order_usecase.dart';
import '../../../domain/use_cases/cancel_order_item_usecase.dart';
import '../../../domain/use_cases/cancel_order_usecase.dart';
import '../../../domain/use_cases/change_order_address_usecase.dart';
import '../../../domain/use_cases/change_order_item_variant_usecase.dart';
import '../../../domain/use_cases/store_return_request_product_usecase.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();
}

class PlaceOrderEvent extends OrderEvent {
  final PlaceOrderParams placeOrderParams;

  PlaceOrderEvent({required this.placeOrderParams});

  @override
  // TODO: implement props
  List<Object?> get props => [placeOrderParams];
}

class SaveLastAddress extends OrderEvent {
  final CustomerAddressesInfo lastAddress;

  SaveLastAddress({required this.lastAddress});

  @override
  // TODO: implement props
  List<Object?> get props => [lastAddress];
}

class GetOrdersByOrderGroupIDEvent extends OrderEvent {
  final String orderGroupId;
  final String status;
  final bool firstOpenPage;
  final bool fromNotification;

  GetOrdersByOrderGroupIDEvent({
    required this.orderGroupId,
    this.firstOpenPage = false,
    this.fromNotification = false,
    this.status = "false",
  });

  @override
  // TODO: implement props
  List<Object?> get props => [orderGroupId, firstOpenPage, status];
}

class SaveCurrentOrederStatusEvent extends OrderEvent {
  final String currentOrderStatus;

  SaveCurrentOrederStatusEvent({required this.currentOrderStatus});
  @override
  // TODO: implement props
  List<Object?> get props => [currentOrderStatus];
}

class ChangeOrderByGroupStatus extends OrderEvent {
  final bool loading;
  ChangeOrderByGroupStatus({this.loading = false});

  @override
  // TODO: implement props
  List<Object?> get props => [loading];
}

class GetOrdersByCartGroupIDEvent extends OrderEvent {
  final String cartGroupId;

  GetOrdersByCartGroupIDEvent({required this.cartGroupId});

  @override
  // TODO: implement props
  List<Object?> get props => [cartGroupId];
}

class GetCustomerWalletEvent extends OrderEvent {
  final String assetId;
  final bool statusInitToRefreshAmount;
  GetCustomerWalletEvent({
    required this.assetId,
    this.statusInitToRefreshAmount = false,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [assetId, statusInitToRefreshAmount];
}

class GetOrdersEvent extends OrderEvent {
  final String status;
  final bool getWithPagination;
  final int index;
  final List<OrderListModel> orders;
  GetOrdersEvent({
    required this.status,
    this.index = -1,
    this.orders = const [],
    required this.getWithPagination,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [status, getWithPagination];
}

class SetCustomerAddressDefaultEvent extends OrderEvent {
  final int? adressId;
  final int? index;

  const SetCustomerAddressDefaultEvent({
    required this.adressId,
    this.index = -1,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [adressId];
}

class GetCustomerAddressesEvent extends OrderEvent {
  final bool? setDefault;
  GetCustomerAddressesEvent({this.setDefault = false});

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class DeleteAdressInfoClassEvent extends OrderEvent {
  final int? adressInfoClassId;

  const DeleteAdressInfoClassEvent({required this.adressInfoClassId});

  @override
  // TODO: implement props
  List<Object?> get props => [adressInfoClassId];
}

class AddAddressInfoClassEvent extends OrderEvent {
  final CustomerAddressesInfo? addressInfoClassToSave;

  const AddAddressInfoClassEvent({required this.addressInfoClassToSave});

  @override
  // TODO: implement props
  List<Object?> get props => [addressInfoClassToSave];
}

class GetProvincesByIsoEvent extends OrderEvent {
  const GetProvincesByIsoEvent();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class EditAdressInfoClassEvent extends OrderEvent {
  final CustomerAddressesInfo? addressInfoClassToSave;
  final int preIdToEdit;
  const EditAdressInfoClassEvent({
    required this.addressInfoClassToSave,
    required this.preIdToEdit,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [addressInfoClassToSave, preIdToEdit];
}

class GetAddressByCoordinatesEvent extends OrderEvent {
  final double latitude;
  final double longitude;
  GetAddressByCoordinatesEvent({
    required this.longitude,
    required this.latitude,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [longitude, latitude];
}

class GetAddressByTextEvent extends OrderEvent {
  final String query;
  final bool reset;

  GetAddressByTextEvent({required this.query, required this.reset});

  @override
  // TODO: implement props
  List<Object?> get props => [query];
}

class SetCurrentAddressChoosedEvent extends OrderEvent {
  final int? index;

  const SetCurrentAddressChoosedEvent({required this.index});

  @override
  // TODO: implement props
  List<Object?> get props => [index];
}

class ApplyCouponEvent extends OrderEvent {
  final String code;
  ApplyCouponEvent({required this.code});

  @override
  // TODO: implement props
  List<Object?> get props => [code];
}

class CancelOrderItemEvent extends OrderEvent {
  final CancelOrderItemParams cancelOrderItemParams;

  CancelOrderItemEvent({required this.cancelOrderItemParams});

  @override
  // TODO: implement props
  List<Object?> get props => [cancelOrderItemParams];
}

class CancelOrderEvent extends OrderEvent {
  final CancelOrderParams cancelOrderParams;

  CancelOrderEvent({required this.cancelOrderParams});

  @override
  // TODO: implement props
  List<Object?> get props => [cancelOrderParams];
}

class ChangeOrderAddressEvent extends OrderEvent {
  final ChangeOrderAddressParams changeOrderAddressParams;

  ChangeOrderAddressEvent({required this.changeOrderAddressParams});

  @override
  // TODO: implement props
  List<Object?> get props => [changeOrderAddressParams];
}

/// Hide (or unhide) a whole order/pack. On success the bloc re-fetches the
/// order group so the hidden pack no longer comes back from the backend.
class HideOrderEvent extends OrderEvent {
  final String orderId;
  final String orderGroupId;
  final bool isHidden;

  const HideOrderEvent({
    required this.orderId,
    required this.orderGroupId,
    this.isHidden = true,
  });

  @override
  List<Object?> get props => [orderId, orderGroupId, isHidden];
}

/// Hide (or unhide) a single product (order detail) inside a pack. On success
/// the bloc re-fetches the order group so the hidden product no longer comes
/// back from the backend.
class HideOrderDetailEvent extends OrderEvent {
  final String detailId;
  final String orderGroupId;
  final bool isHidden;

  const HideOrderDetailEvent({
    required this.detailId,
    required this.orderGroupId,
    this.isHidden = true,
  });

  @override
  List<Object?> get props => [detailId, orderGroupId, isHidden];
}

/// Fetch the list of hidden orders/products for the Hidden Orders page.
class GetHiddenOrdersEvent extends OrderEvent {
  const GetHiddenOrdersEvent();

  @override
  List<Object?> get props => [];
}

/// Restore (unhide) a whole order from the Hidden Orders page. On success the
/// bloc re-fetches both the hidden list and the main orders list.
class RestoreOrderEvent extends OrderEvent {
  final String orderId;

  const RestoreOrderEvent({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

/// Restore (unhide) a single product from the Hidden Orders page. On success
/// the bloc re-fetches both the hidden list and the main orders list.
class RestoreProductEvent extends OrderEvent {
  final String detailId;

  const RestoreProductEvent({required this.detailId});

  @override
  List<Object?> get props => [detailId];
}

class GetProductColorSizeSyncAttributeEvent extends OrderEvent {
  final String id;

  GetProductColorSizeSyncAttributeEvent({required this.id});

  @override
  // TODO: implement props
  List<Object?> get props => [id];
}

class ChangeOrderItemVariantEvent extends OrderEvent {
  final ChangeOrderItemVariantParams params;
  const ChangeOrderItemVariantEvent({required this.params});

  @override
  List<Object?> get props => [params];
}

/*class AddOrderCommentEvent extends OrderEvent {
  final AddOrderCommentParams params;

  const AddOrderCommentEvent({required this.params});

  @override
  List<Object?> get props => [params];
}

class UpdateOrderCommentEvent extends OrderEvent {
  final UpdateOrderCommentParams params;

  const UpdateOrderCommentEvent({required this.params});

  @override
  List<Object?> get props => [params];
}*/

class GetReturnReasonsEvent extends OrderEvent {
  const GetReturnReasonsEvent();

  @override
  List<Object?> get props => [];
}

class StoreReturnRequestProductEvent extends OrderEvent {
  final ReturnRequestProductParams params;
  final bool withConfirm;
  final List<String> returnRequestId;
  final String orderGroupId;
  const StoreReturnRequestProductEvent({
    required this.params,
    required this.withConfirm,
    required this.returnRequestId,
    required this.orderGroupId,
  });

  @override
  List<Object?> get props => [params];
}

class UpdateReturnRequestProductEvent extends OrderEvent {
  final UpdateReturnRequestProductParams params;
  final bool withConfirm;
  final List<String> returnRequestId;
  final String orderGroupId;

  const UpdateReturnRequestProductEvent({
    required this.params,
    required this.withConfirm,
    required this.returnRequestId,
    required this.orderGroupId,
  });

  @override
  List<Object?> get props => [params];
}

class CancelReturnRequestEvent extends OrderEvent {
  final List<String> returnRequestId;
  final String orderGroupId;
  const CancelReturnRequestEvent({
    required this.returnRequestId,
    required this.orderGroupId,
  });

  @override
  List<Object?> get props => [returnRequestId];
}

class StoreImagesForUpdateReturnEvent extends OrderEvent {
  final List<String> images;
  const StoreImagesForUpdateReturnEvent({required this.images});

  @override
  List<Object?> get props => [images];
}

class CancelReturnRequestProductEvent extends OrderEvent {
  final int returnRequestId;
  final String orderGroupId;
  final CancelReturnRequestProductParams params;

  const CancelReturnRequestProductEvent({
    required this.params,
    required this.returnRequestId,
    required this.orderGroupId,
  });

  @override
  List<Object?> get props => [params];
}

class StoreReturnRequestEvent extends OrderEvent {
  final ReturnRequestParams params;
  final String orderGroupId;
  const StoreReturnRequestEvent({
    required this.params,
    required this.orderGroupId,
  });

  @override
  List<Object?> get props => [params];
}

class ResetAllStatusEvent extends OrderEvent {
  const ResetAllStatusEvent();

  @override
  List<Object?> get props => [];
}

class ConfirmReturnRequestEvent extends OrderEvent {
  final List<String> returnRequestId;
  final String orderGroupId;

  const ConfirmReturnRequestEvent({
    required this.returnRequestId,
    required this.orderGroupId,
  });

  @override
  List<Object?> get props => [returnRequestId];
}

class UploadImagesForReturnProductEvent extends OrderEvent {
  final File file;
  const UploadImagesForReturnProductEvent(this.file);

  @override
  List<Object?> get props => [file];
}

class UploadImagesToCloudinaryEvent extends OrderEvent {
  final File file;
  const UploadImagesToCloudinaryEvent(this.file);

  @override
  List<Object?> get props => [file];
}

class RemoveImagesForReturnProductEvent extends OrderEvent {
  final int index;
  const RemoveImagesForReturnProductEvent(this.index);

  @override
  List<Object?> get props => [index];
}

class RemoveImagesForCommentEvent extends OrderEvent {
  final int index;
  final List<String>? initialImages;
  const RemoveImagesForCommentEvent(this.index, this.initialImages);

  @override
  List<Object?> get props => [index, initialImages];
}

class OrderReturnRequestsViewEvent extends OrderEvent {
  final OrderReturnRequestsViewParams params;

  const OrderReturnRequestsViewEvent({required this.params});

  @override
  List<Object?> get props => [params];
}

class FetchOrderReturnDetailsEvent extends OrderEvent {
  final String orderGroupId;
  final bool notFound;
  const FetchOrderReturnDetailsEvent(
    this.orderGroupId, {
    this.notFound = false,
  });

  @override
  List<Object?> get props => [orderGroupId];
}

/// Wallet Checkout Event
class WalletCheckoutEvent extends OrderEvent {
  final WalletCheckoutParams params;

  const WalletCheckoutEvent({required this.params});

  @override
  List<Object?> get props => [params];
}
