part of 'dashBoard_bloc.dart';

abstract class DashBoardEvent {}

class GetUserPermissionEvent extends DashBoardEvent {
  GetUserPermissionEvent();
}

class GetUserRolesEvent extends DashBoardEvent {
  GetUserRolesEvent();
}

class AddUserEvent extends DashBoardEvent {
  final String phone;
  final String role_id;
  final String seller_id;
  AddUserEvent({
    required this.phone,
    required this.role_id,
    required this.seller_id,
  });
}

class GetBoutiquesEvent extends DashBoardEvent {
  GetBoutiquesEvent();
}

class GetOrdersEvent extends DashBoardEvent {
  GetOrdersEvent();
}

class GetProductsEvent extends DashBoardEvent {
  GetProductsEvent();
}

class ChangeOrderStatusEvent extends DashBoardEvent {
  final String order_id;
  final String status;
  ChangeOrderStatusEvent({required this.order_id, required this.status});
}
