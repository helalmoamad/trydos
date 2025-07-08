import 'package:equatable/equatable.dart';
import '../../../data/models/get_list_of_customer_addresses_model.dart';
import '../../../domain/use_cases/place_order_usecase.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();
}

class PlaceOrderEvent extends OrderEvent {
  final PlaceOrderParams placeOrderParams;

  PlaceOrderEvent({
    required this.placeOrderParams,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [placeOrderParams];
}

class SaveLastAddress extends OrderEvent {
  final CustomerAddressesInfo lastAddress;

  SaveLastAddress({
    required this.lastAddress,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [lastAddress];
}

class GetOrdersByOrderGroupIDEvent extends OrderEvent {
  final String orderGroupId;

  GetOrdersByOrderGroupIDEvent({
    required this.orderGroupId,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [orderGroupId];
}

class SaveCurrentOrederStatusEvent extends OrderEvent {
  final String currentOrederStatus;

  SaveCurrentOrederStatusEvent({
    required this.currentOrederStatus,
  });
  @override
  // TODO: implement props
  List<Object?> get props => [currentOrederStatus];
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

  GetOrdersByCartGroupIDEvent({
    required this.cartGroupId,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [cartGroupId];
}

class GetCustomerWalletEvent extends OrderEvent {
  final int limit;
  final int offset;
  GetCustomerWalletEvent({required this.limit, required this.offset});

  @override
  // TODO: implement props
  List<Object?> get props => [limit, offset];
}

class GetOrdersEvent extends OrderEvent {
  final String status;
  final bool getWithPagination;
  GetOrdersEvent({
    required this.status,
    required this.getWithPagination,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [status, getWithPagination];
}

class SetCustomerAddressDefaultEvent extends OrderEvent {
  final int? adressId;

  const SetCustomerAddressDefaultEvent({required this.adressId});

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
  const EditAdressInfoClassEvent(
      {required this.addressInfoClassToSave, required this.preIdToEdit});

  @override
  // TODO: implement props
  List<Object?> get props => [addressInfoClassToSave, preIdToEdit];
}

class GetAddressByCoordinatesEvent extends OrderEvent {
  final double latitude;
  final double longitude;
  GetAddressByCoordinatesEvent(
      {required this.longitude, required this.latitude});

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
