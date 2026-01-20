import 'permission_enum.dart';

/// Utility class for checking dashboard permissions
/// This class centralizes all permission checks to avoid code duplication
class DashboardPermissionChecker {
  final List<String> permissions;

  DashboardPermissionChecker(this.permissions);

  /// Check if user has SUPER_ADMIN permission
  bool get isSuperAdmin {
    return permissions.contains(DashBoardPermission.SUPER_ADMIN.value);
  }

  /// Check if user can see Products tab
  /// Returns true if user has SUPER_ADMIN or READ_PRODUCTS permission
  bool canSeeProducts() {
    return isSuperAdmin ||
        permissions.contains(DashBoardPermission.READ_PRODUCTS.value);
  }

  /// Check if user can see Boutiques tab
  /// Returns true if user has SUPER_ADMIN, READ_BOUTIQUES, or READ_BUTIKS permission
  bool canSeeBoutiques() {
    return isSuperAdmin ||
        permissions.contains(DashBoardPermission.READ_BOUTIQUES.value) ||
        permissions.contains(DashBoardPermission.READ_BUTIKS.value);
  }

  /// Check if user can see Orders tab
  /// Returns true if user has SUPER_ADMIN, READ_ORDERS, or any order status change permission
  bool canSeeOrders() {
    return isSuperAdmin ||
        permissions.contains(DashBoardPermission.READ_ORDERS.value) ||
        permissions.contains(
          DashBoardPermission.CHANGE_ORDER_STATUS_CANCELED.value,
        ) ||
        permissions.contains(
          DashBoardPermission.CHANGE_ORDER_STATUS_PACKAGED.value,
        ) ||
        permissions.contains(DashBoardPermission.CHANGE_ORDER_STATUS.value);
  }

  /// Check if user can see Users tab
  /// Returns true only if user has SUPER_ADMIN permission
  bool canSeeUsers() {
    return isSuperAdmin;
  }
}
