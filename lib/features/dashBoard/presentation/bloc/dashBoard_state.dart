part of 'dashBoard_bloc.dart';

enum GetUserPermissionStatus { init, loading, success, failure }

enum GetUserRolesStatus { init, loading, success, failure }

enum AddUserStatus { init, loading, success, failure }

enum GetBoutiquesStatus { init, loading, success, failure }

enum GetOrdersStatus { init, loading, success, failure }

enum GetProductsStatus { init, loading, success, failure }

enum ChangeOrderStatusStatus { init, loading, success, failure }

@immutable
class DashBoardState extends Equatable {
  final GetUserPermissionStatus getUserPermissionStatus;
  final GetUserRolesStatus getUserRolesStatus;
  final GetBoutiquesStatus getBoutiquesStatus;
  final GetOrdersStatus getOrdersStatus;
  final GetProductsStatus getProductsStatus;
  final ChangeOrderStatusStatus changeOrderStatusStatus;
  final AddUserStatus addUserStatus;
  final List<Shop>? shops;
  final List<ShopRole>? shopRoles;
  final List<Boutique>? boutiques;
  final List<UserOrder>? orders;
  final List<Product>? products;
  DashBoardState({
    this.getUserPermissionStatus = GetUserPermissionStatus.init,
    this.getUserRolesStatus = GetUserRolesStatus.init,
    this.addUserStatus = AddUserStatus.init,
    this.getBoutiquesStatus = GetBoutiquesStatus.init,
    this.getOrdersStatus = GetOrdersStatus.init,
    this.getProductsStatus = GetProductsStatus.init,
    this.changeOrderStatusStatus = ChangeOrderStatusStatus.init,
    this.shops,
    this.shopRoles,
    this.boutiques,
    this.orders,
    this.products,
  });
  DashBoardState copyWith({
    GetUserPermissionStatus? getUserPermissionStatus,
    GetUserRolesStatus? getUserRolesStatus,
    GetBoutiquesStatus? getBoutiquesStatus,
    GetOrdersStatus? getOrdersStatus,
    GetProductsStatus? getProductsStatus,
    ChangeOrderStatusStatus? changeOrderStatusStatus,
    AddUserStatus? addUserStatus,
    List<Shop>? shops,
    List<ShopRole>? shopRoles,
    List<Boutique>? boutiques,
    List<UserOrder>? orders,
    List<Product>? products,
  }) {
    return DashBoardState(
      getUserPermissionStatus:
          getUserPermissionStatus ?? this.getUserPermissionStatus,
      getUserRolesStatus: getUserRolesStatus ?? this.getUserRolesStatus,
      getBoutiquesStatus: getBoutiquesStatus ?? this.getBoutiquesStatus,
      getOrdersStatus: getOrdersStatus ?? this.getOrdersStatus,
      getProductsStatus: getProductsStatus ?? this.getProductsStatus,
      changeOrderStatusStatus:
          changeOrderStatusStatus ?? this.changeOrderStatusStatus,
      addUserStatus: addUserStatus ?? this.addUserStatus,
      shops: shops ?? this.shops,
      shopRoles: shopRoles ?? this.shopRoles,
      boutiques: boutiques ?? this.boutiques,
      orders: orders ?? this.orders,
      products: products ?? this.products,
    );
  }

  @override
  List<Object?> get props => [
    getUserPermissionStatus,
    getUserRolesStatus,
    getBoutiquesStatus,
    getOrdersStatus,
    getProductsStatus,
    changeOrderStatusStatus,
    addUserStatus,
    shops,
    shopRoles,
    boutiques,
    orders,
    products,
  ];
}
