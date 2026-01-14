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
  @override
  void initState() {
    super.initState();
    GetIt.I.get<PrefsRepository>().setXSellerId(widget.sellerId);
    _dashboardBloc = BlocProvider.of<DashboardBloc>(context);
    _dashboardBloc.add(GetProductsEvent());
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
                  productsCount: state.products?.length ?? 0,
                  boutiquesCount: state.boutiques?.length ?? 0,
                  ordersCount: state.orders?.length ?? 0,
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
          previous.productsMeta != current.productsMeta,
      builder: (context, state) {
        print(state.getProductsStatus);
        if (state.getProductsStatus == GetProductsStatus.loading &&
            state.products?.length == 0) {
          return const Center(child: CircularProgressIndicator());
        }

        // Check if products exist and are not empty
        if (state.products != null && state.products!.isNotEmpty) {
          return ProductsGridWidget(
            products: state.products!,
            meta: state.productsMeta,
            onAddProduct: () {
              // TODO: Add onAddProduct callback
            },
            onPageChanged: (page) {
              _dashboardBloc.add(GetProductsEvent(page: page));
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
          previous.boutiquesMeta != current.boutiquesMeta,
      builder: (context, state) {
        print(state.getBoutiquesStatus);
        if (state.getBoutiquesStatus == GetBoutiquesStatus.loading &&
            state.boutiques?.length == 0) {
          return const Center(child: CircularProgressIndicator());
        }

        // Check if boutiques exist and are not empty
        if (state.boutiques != null && state.boutiques!.isNotEmpty) {
          return BoutiquesGridWidget(
            boutiques: state.boutiques!,
            meta: state.boutiquesMeta,
            onAddBoutique: () {
              // TODO: Add onAddBoutique callback
            },
            onPageChanged: (page) {
              _dashboardBloc.add(GetBoutiquesEvent(page: page));
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
          previous.ordersMeta != current.ordersMeta,
      builder: (context, state) {
        if (state.getOrdersStatus == GetOrdersStatus.loading &&
            state.orders?.length == 0) {
          return const Center(child: CircularProgressIndicator());
        }

        // Check if orders exist and are not empty
        if (state.orders != null && state.orders!.isNotEmpty) {
          return OrdersListWidget(
            orders: state.orders!,
            meta: state.ordersMeta,
            onPageChanged: (page) {
              _dashboardBloc.add(GetOrdersEvent(page: page));
            },
            onStatusChanged: (orderId, status) {
              _dashboardBloc.add(
                ChangeOrderStatusEvent(order_id: orderId, status: status),
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
