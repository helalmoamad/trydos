import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_tab_bar.dart';
import '../widgets/empty_state_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/dashBoard_bloc.dart';
import '../widgets/permission_card.dart';
import '../widgets/add_user_widget.dart';
import '../widgets/products_grid_widget.dart';
import '../widgets/boutiques_grid_widget.dart';
import '../widgets/orders_list_widget.dart';
import '../widgets/dashboard_permission_checker.dart';

class DashboardPage extends StatefulWidget {
  final String shopName;
  final String sellerId;
  final List<String> permissions;
  final bool canAddUser;
  final bool canGetProducts;
  final bool canGetBoutiques;
  final bool canGetOrders;

  const DashboardPage({
    Key? key,
    required this.shopName,
    required this.sellerId,
    required this.permissions,
    this.canAddUser = true,
    this.canGetProducts = true,
    this.canGetBoutiques = true,
    this.canGetOrders = true,
  }) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedTabIndex = 0;
  late DashboardBloc _dashboardBloc;
  late final DashboardPermissionChecker _permissionChecker;

  // Get the first available tab index
  int _getFirstAvailableTabIndex() {
    if (_permissionChecker.canSeeProducts()) return 0;
    if (_permissionChecker.canSeeBoutiques()) return 1;
    if (_permissionChecker.canSeeOrders()) return 2;
    return 3; // Permissions tab is always available
  }

  @override
  void initState() {
    super.initState();
    _permissionChecker = DashboardPermissionChecker(widget.permissions);
    GetIt.I.get<PrefsRepository>().setXSellerId(widget.sellerId);
    _dashboardBloc = BlocProvider.of<DashboardBloc>(context);

    // Adjust selected index if current tab is not visible
    if (_selectedTabIndex == 0 && !_permissionChecker.canSeeProducts()) {
      _selectedTabIndex = _getFirstAvailableTabIndex();
    } else if (_selectedTabIndex == 1 &&
        !_permissionChecker.canSeeBoutiques()) {
      _selectedTabIndex = _getFirstAvailableTabIndex();
    } else if (_selectedTabIndex == 2 && !_permissionChecker.canSeeOrders()) {
      _selectedTabIndex = _getFirstAvailableTabIndex();
    } else if (_selectedTabIndex == 4 && !_permissionChecker.canSeeUsers()) {
      _selectedTabIndex = _getFirstAvailableTabIndex();
    }

    // Load initial data based on selected tab
    if (_selectedTabIndex == 0 && _permissionChecker.canSeeProducts()) {
      _dashboardBloc.add(GetProductsEvent());
    } else if (_selectedTabIndex == 1 && _permissionChecker.canSeeBoutiques()) {
      _dashboardBloc.add(GetBoutiquesEvent());
    } else if (_selectedTabIndex == 2 && _permissionChecker.canSeeOrders()) {
      _dashboardBloc.add(GetOrdersEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            DashboardHeader(
              shopName: widget.shopName,
              sellerId: widget.sellerId,
            ),

            // Tab Bar
            BlocBuilder<DashboardBloc, DashBoardState>(
              buildWhen: (previous, current) =>
                  previous.getProductsStatus != current.getProductsStatus ||
                  previous.getBoutiquesStatus != current.getBoutiquesStatus ||
                  previous.getOrdersStatus != current.getOrdersStatus,
              builder: (context, state) {
                return DashboardTabBar(
                  selectedIndex: _selectedTabIndex,
                  permissions: widget.permissions,
                  onTabSelected: (index) {
                    setState(() {
                      _selectedTabIndex = index;
                    });
                    Future.delayed(const Duration(milliseconds: 50), () {
                      if (index == 0 && widget.canGetProducts) {
                        _dashboardBloc.add(GetProductsEvent());
                      } else if (index == 1 && widget.canGetBoutiques) {
                        _dashboardBloc.add(GetBoutiquesEvent());
                      } else if (index == 2 && widget.canGetOrders) {
                        _dashboardBloc.add(GetOrdersEvent());
                      } else if (index == 4 && widget.canAddUser) {
                        _dashboardBloc.add(GetUserRolesEvent());
                      }
                    });
                  },
                  productsCount: state.productsMeta?.total ?? 0,
                  boutiquesCount: state.boutiquesMeta?.total ?? 0,
                  ordersCount: state.ordersMeta?.total ?? 0,
                  permissionsCount: widget.permissions.length,
                );
              },
            ),

            // Content
            Expanded(child: _buildTabContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildProductsTab();
      case 1:
        return _buildBoutiquesTab();
      case 2:
        return _buildOrdersTab();
      case 3:
        return _buildPermissionsTab();
      case 4:
        return _buildUsersTab();
      default:
        return _buildProductsTab();
    }
  }

  Widget _buildProductsTab() {
    return BlocBuilder<DashboardBloc, DashBoardState>(
      buildWhen: (previous, current) =>
          previous.getProductsStatus != current.getProductsStatus ||
          previous.products != current.products ||
          previous.productsMeta?.currentPage !=
              current.productsMeta?.currentPage,
      builder: (context, state) {
        if (state.getProductsStatus == GetProductsStatus.loading &&
            (state.products?.length ?? 0) == 0) {
          return const Center(child: CircularProgressIndicator());
        }

        // Check if products exist and are not empty
        if (state.products != null && state.products!.isNotEmpty) {
          return BlocBuilder<DashboardBloc, DashBoardState>(
            buildWhen: (previous, current) =>
                previous.productsMeta?.currentPage !=
                    current.productsMeta?.currentPage ||
                previous.getProductsStatus != current.getProductsStatus,
            builder: (context, paginationState) {
              // Show loading overlay only during pagination (when loading and data exists)
              final isPaginationLoading =
                  paginationState.getProductsStatus ==
                  GetProductsStatus.loading;
              return Stack(
                children: [
                  ProductsGridWidget(
                    products: state.products!,
                    meta: state.productsMeta,
                    onAddProduct: () {
                      // TODO: Add onAddProduct callback
                    },
                    onPageChanged: (page) {
                      _dashboardBloc.add(GetProductsEvent(page: page));
                    },
                  ),
                  if (isPaginationLoading)
                    Container(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.1),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              );
            },
          );
        }

        // Show empty state when no products
        return EmptyStateWidget(
          message: LocaleKeys.no_products_found_dashboard.tr(),
          icon: Icons.inventory_2_outlined,
          actionText: LocaleKeys.add_product.tr(),
          // TODO: Add onActionPressed callback
        );
      },
    );
  }

  Widget _buildBoutiquesTab() {
    return BlocBuilder<DashboardBloc, DashBoardState>(
      buildWhen: (previous, current) =>
          previous.getBoutiquesStatus != current.getBoutiquesStatus ||
          previous.boutiques != current.boutiques ||
          previous.boutiquesMeta?.currentPage !=
              current.boutiquesMeta?.currentPage,
      builder: (context, state) {
        if (state.getBoutiquesStatus == GetBoutiquesStatus.loading &&
            (state.boutiques?.length ?? 0) == 0) {
          return const Center(child: CircularProgressIndicator());
        }

        // Check if boutiques exist and are not empty
        if (state.boutiques != null && state.boutiques!.isNotEmpty) {
          return BlocBuilder<DashboardBloc, DashBoardState>(
            buildWhen: (previous, current) =>
                previous.boutiquesMeta?.currentPage !=
                    current.boutiquesMeta?.currentPage ||
                previous.getBoutiquesStatus != current.getBoutiquesStatus,
            builder: (context, paginationState) {
              // Show loading overlay only during pagination (when loading and data exists)
              final isPaginationLoading =
                  paginationState.getBoutiquesStatus ==
                  GetBoutiquesStatus.loading;
              return Stack(
                children: [
                  BoutiquesGridWidget(
                    boutiques: state.boutiques!,
                    meta: state.boutiquesMeta,
                    onAddBoutique: () {
                      // TODO: Add onAddBoutique callback
                    },
                    onPageChanged: (page) {
                      _dashboardBloc.add(GetBoutiquesEvent(page: page));
                    },
                  ),
                  if (isPaginationLoading)
                    Container(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.1),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              );
            },
          );
        }

        // Show empty state when no boutiques
        return EmptyStateWidget(
          message: LocaleKeys.no_boutiques_found.tr(),
          icon: Icons.store_outlined,
          actionText: LocaleKeys.add_boutique.tr(),
          // TODO: Add onActionPressed callback
        );
      },
    );
  }

  Widget _buildOrdersTab() {
    return BlocBuilder<DashboardBloc, DashBoardState>(
      buildWhen: (previous, current) =>
          previous.getOrdersStatus != current.getOrdersStatus ||
          previous.orders != current.orders ||
          previous.ordersMeta?.currentPage != current.ordersMeta?.currentPage ||
          previous.ordersUserAbilities != current.ordersUserAbilities,
      builder: (context, state) {
        if (state.getOrdersStatus == GetOrdersStatus.loading &&
            (state.orders?.length ?? 0) == 0) {
          return const Center(child: CircularProgressIndicator());
        }

        // Check if orders exist and are not empty
        if (state.orders != null && state.orders!.isNotEmpty) {
          return BlocBuilder<DashboardBloc, DashBoardState>(
            buildWhen: (previous, current) =>
                previous.ordersMeta?.currentPage !=
                    current.ordersMeta?.currentPage ||
                previous.getOrdersStatus != current.getOrdersStatus,
            builder: (context, paginationState) {
              // Show loading overlay only during pagination (when loading and data exists)
              final isPaginationLoading =
                  paginationState.getOrdersStatus == GetOrdersStatus.loading;
              return Stack(
                children: [
                  OrdersListWidget(
                    orders: state.orders!,
                    meta: state.ordersMeta,
                    userAbilities: state.ordersUserAbilities,
                    onPageChanged: (page) {
                      _dashboardBloc.add(GetOrdersEvent(page: page));
                    },
                    onStatusChanged: (orderId, status) {
                      _dashboardBloc.add(
                        ChangeOrderStatusEvent(
                          order_id: orderId,
                          status: status,
                        ),
                      );
                    },
                  ),
                  if (isPaginationLoading)
                    Container(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.1),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              );
            },
          );
        }

        // Show empty state when no orders
        return EmptyStateWidget(
          message: LocaleKeys.no_orders_found.tr(),
          icon: Icons.shopping_bag_outlined,
        );
      },
    );
  }

  Widget _buildPermissionsTab() {
    if (widget.permissions.isEmpty) {
      return EmptyStateWidget(
        message: LocaleKeys.no_permissions_assigned.tr(),
        icon: Icons.admin_panel_settings_outlined,
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      itemCount: widget.permissions.length,
      itemBuilder: (context, index) {
        final permission = widget.permissions[index];
        return PermissionCard(permissionName: permission);
      },
    );
  }

  Widget _buildUsersTab() {
    if (!widget.canAddUser) {
      return EmptyStateWidget(
        title: LocaleKeys.access_denied.tr(),
        message: LocaleKeys.no_permission_to_manage_users.tr(),
      );
    }

    return AddUserWidget(sellerId: widget.sellerId);
  }
}
