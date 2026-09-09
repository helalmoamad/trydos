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

  /// Check if user can read the shop's public profile (Shop Info screen)
  /// Returns true if user has SUPER_ADMIN or READ_SHOP_INFO permission
  ///
  /// Note: this list cannot say "unknown". It arrives as a non-null
  /// `List<String>` built with `shop.permissions ?? []` at shop selection, so a
  /// permission list that failed to load and one that grants nothing are the
  /// same empty list here. See `_specs/connect-shop-info-widget-to-shop-info-api`
  /// (AC-7, accepted as unmet).
  bool canReadShopInfo() {
    return isSuperAdmin ||
        permissions.contains(DashBoardPermission.READ_SHOP_INFO.value);
  }

  /// Check if user can edit the shop's public profile
  /// Returns true if user has SUPER_ADMIN or UPDATE_SHOP_INFO permission
  ///
  /// The write gate fails closed: anything other than an explicit grant means
  /// the save and image controls stay unavailable, because the save replaces the
  /// whole profile.
  bool canUpdateShopInfo() {
    return isSuperAdmin ||
        permissions.contains(DashBoardPermission.UPDATE_SHOP_INFO.value);
  }

  // --- Locations ---------------------------------------------------------
  //
  // Four permissions, one per action, each `SUPER_ADMIN`-or-the-named-one. They
  // are read through these methods, never as a loose string compare at a call
  // site.
  //
  // The gate lives inside the screen only: the Locations tab entry stays
  // visible to every member (AC-28), and opening it without the read
  // permission shows a message instead of calling the backend.
  //
  // Like `canReadShopInfo`, this list cannot say "unknown". A permission list
  // that failed to load and one that genuinely grants nothing are the same
  // empty list here, so the read fails closed and the two cannot be told apart
  // (AC-18, a recorded limitation).

  /// Open the tab and see the list.
  bool canReadLocations() {
    return isSuperAdmin ||
        permissions.contains(DashBoardPermission.READ_LOCATIONS.value);
  }

  /// Show the "add location" control, and open the add form.
  bool canCreateLocation() {
    return isSuperAdmin ||
        permissions.contains(DashBoardPermission.CREATE_LOCATION.value);
  }

  /// Show a row's edit control, and open the edit form.
  bool canUpdateLocation() {
    return isSuperAdmin ||
        permissions.contains(DashBoardPermission.UPDATE_LOCATION.value);
  }

  /// Show a row's activate / deactivate control.
  bool canChangeLocationStatus() {
    return isSuperAdmin ||
        permissions.contains(DashBoardPermission.CHANGE_LOCATION_STATUS.value);
  }

  /// Check if user can see Stories tab
  /// The backend does not expose a dedicated stories permission yet, so the tab
  /// is visible to every shop member. Gate it here once the permission exists.
  bool canSeeStories() {
    return true;
  }
}
