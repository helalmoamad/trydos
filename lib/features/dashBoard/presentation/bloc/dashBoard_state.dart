part of 'dashBoard_bloc.dart';

enum GetUserPermissionStatus { init, loading, success, failure }

enum GetUserRolesStatus { init, loading, success, failure }

enum AddUserStatus { init, loading, success, failure }

enum GetBoutiquesStatus { init, loading, success, failure }

enum GetOrdersStatus { init, loading, success, failure }

enum GetProductsStatus { init, loading, success, failure }

enum GetUsersStatus { init, loading, success, failure }

enum ChangeOrderStatusStatus { init, loading, success, failure }

enum DeleteUserStatus { init, loading, success, failure }

enum ChangeUserRoleStatus { init, loading, success, failure }

enum LeaveShopStatus { init, loading, success, failure }

@immutable
class DashBoardState extends Equatable {
  final GetUserPermissionStatus getUserPermissionStatus;
  final GetUserRolesStatus getUserRolesStatus;
  final GetBoutiquesStatus getBoutiquesStatus;
  final GetOrdersStatus getOrdersStatus;
  final GetProductsStatus getProductsStatus;
  final GetUsersStatus getUsersStatus;
  final ChangeOrderStatusStatus changeOrderStatusStatus;
  final AddUserStatus addUserStatus;
  final DeleteUserStatus deleteUserStatus;
  final ChangeUserRoleStatus changeUserRoleStatus;
  final LeaveShopStatus leaveShopStatus;
  final List<Shop>? shops;
  final List<ShopRole>? shopRoles;
  final Meta? rolesMeta;
  final List<boutiques_model.Boutique>? boutiques;
  final boutiques_model.Meta? boutiquesMeta;
  final List<orders_model.UserOrder>? orders;
  final orders_model.Meta? ordersMeta;
  final orders_model.UserAbilities? ordersUserAbilities;
  final List<products_model.Product>? products;
  final products_model.Meta? productsMeta;
  final List<users_model.User>? users;
  final users_model.Meta? usersMeta;
  DashBoardState({
    this.getUserPermissionStatus = GetUserPermissionStatus.init,
    this.getUserRolesStatus = GetUserRolesStatus.init,
    this.addUserStatus = AddUserStatus.init,
    this.getBoutiquesStatus = GetBoutiquesStatus.init,
    this.getOrdersStatus = GetOrdersStatus.init,
    this.getProductsStatus = GetProductsStatus.init,
    this.getUsersStatus = GetUsersStatus.init,
    this.changeOrderStatusStatus = ChangeOrderStatusStatus.init,
    this.deleteUserStatus = DeleteUserStatus.init,
    this.changeUserRoleStatus = ChangeUserRoleStatus.init,
    this.leaveShopStatus = LeaveShopStatus.init,
    this.shops,
    this.shopRoles,
    this.boutiques,
    this.boutiquesMeta,
    this.orders,
    this.ordersMeta,
    this.ordersUserAbilities,
    this.products,
    this.productsMeta,
    this.users,
    this.usersMeta,
    this.rolesMeta,
  });
  DashBoardState copyWith({
    GetUserPermissionStatus? getUserPermissionStatus,
    GetUserRolesStatus? getUserRolesStatus,
    GetBoutiquesStatus? getBoutiquesStatus,
    GetOrdersStatus? getOrdersStatus,
    GetProductsStatus? getProductsStatus,
    GetUsersStatus? getUsersStatus,
    ChangeOrderStatusStatus? changeOrderStatusStatus,
    AddUserStatus? addUserStatus,
    DeleteUserStatus? deleteUserStatus,
    ChangeUserRoleStatus? changeUserRoleStatus,
    LeaveShopStatus? leaveShopStatus,
    List<Shop>? shops,
    List<ShopRole>? shopRoles,
    Meta? rolesMeta,
    List<boutiques_model.Boutique>? boutiques,
    boutiques_model.Meta? boutiquesMeta,
    List<orders_model.UserOrder>? orders,
    orders_model.Meta? ordersMeta,
    orders_model.UserAbilities? ordersUserAbilities,
    List<products_model.Product>? products,
    products_model.Meta? productsMeta,
    List<users_model.User>? users,
    users_model.Meta? usersMeta,
  }) {
    return DashBoardState(
      getUserPermissionStatus:
          getUserPermissionStatus ?? this.getUserPermissionStatus,
      getUserRolesStatus: getUserRolesStatus ?? this.getUserRolesStatus,
      getBoutiquesStatus: getBoutiquesStatus ?? this.getBoutiquesStatus,
      getOrdersStatus: getOrdersStatus ?? this.getOrdersStatus,
      getProductsStatus: getProductsStatus ?? this.getProductsStatus,
      getUsersStatus: getUsersStatus ?? this.getUsersStatus,
      changeOrderStatusStatus:
          changeOrderStatusStatus ?? this.changeOrderStatusStatus,
      addUserStatus: addUserStatus ?? this.addUserStatus,
      deleteUserStatus: deleteUserStatus ?? this.deleteUserStatus,
      changeUserRoleStatus: changeUserRoleStatus ?? this.changeUserRoleStatus,
      leaveShopStatus: leaveShopStatus ?? this.leaveShopStatus,
      shops: shops ?? this.shops,
      shopRoles: shopRoles ?? this.shopRoles,
      rolesMeta: rolesMeta ?? this.rolesMeta,
      boutiques: boutiques ?? this.boutiques,
      boutiquesMeta: boutiquesMeta ?? this.boutiquesMeta,
      orders: orders ?? this.orders,
      ordersMeta: ordersMeta ?? this.ordersMeta,
      ordersUserAbilities: ordersUserAbilities ?? this.ordersUserAbilities,
      products: products ?? this.products,
      productsMeta: productsMeta ?? this.productsMeta,
      users: users ?? this.users,
      usersMeta: usersMeta ?? this.usersMeta,
    );
  }

  @override
  List<Object?> get props => [
    getUserPermissionStatus,
    getUserRolesStatus,
    getBoutiquesStatus,
    getOrdersStatus,
    getProductsStatus,
    getUsersStatus,
    changeOrderStatusStatus,
    addUserStatus,
    deleteUserStatus,
    changeUserRoleStatus,
    leaveShopStatus,
    shops,
    shopRoles,
    rolesMeta,
    boutiques,
    boutiquesMeta,
    orders,
    ordersMeta,
    ordersUserAbilities,
    products,
    productsMeta,
    users,
    usersMeta,
  ];
}
