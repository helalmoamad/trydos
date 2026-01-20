part of 'dashBoard_bloc.dart';

abstract class DashBoardEvent {}

class GetUserPermissionEvent extends DashBoardEvent {
  GetUserPermissionEvent();
}

class GetUserRolesEvent extends DashBoardEvent {
  final String? search;
  final int page;
  GetUserRolesEvent({this.search, this.page = 1});
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
  final int page;
  GetBoutiquesEvent({this.page = 1});
}

class GetOrdersEvent extends DashBoardEvent {
  final int page;
  GetOrdersEvent({this.page = 1});
}

class GetProductsEvent extends DashBoardEvent {
  final int page;
  GetProductsEvent({this.page = 1});
}

class ChangeOrderStatusEvent extends DashBoardEvent {
  final int order_id;
  final String status;
  ChangeOrderStatusEvent({required this.order_id, required this.status});
}

class GetUsersEvent extends DashBoardEvent {
  final int page;
  GetUsersEvent({this.page = 1});
}

class DeleteUserEvent extends DashBoardEvent {
  final String userId;
  DeleteUserEvent({required this.userId});
}

class ChangeUserRoleEvent extends DashBoardEvent {
  final String userId;
  final String roleId;
  ChangeUserRoleEvent({required this.userId, required this.roleId});
}

class LeaveShopEvent extends DashBoardEvent {
  LeaveShopEvent();
}
