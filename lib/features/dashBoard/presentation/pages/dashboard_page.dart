import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/constant/design/assets_provider.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/dashBoard/data/models/get_new_ordersToDashboard.dart';
import 'package:trydos/features/dashBoard/presentation/pages/order_details_page.dart';
import 'package:trydos/features/dashBoard/presentation/widgets/order_status.dart';
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
      _dashboardBloc.add(NewGetOrdersEvent());
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
                        _dashboardBloc.add(NewGetOrdersEvent());
                      } else if (index == 4 && widget.canAddUser) {
                        _dashboardBloc.add(GetUserRolesEvent());
                      }
                    });
                  },
                  productsCount: state.productsMeta?.total ?? 0,
                  boutiquesCount: state.boutiquesMeta?.total ?? 0,
                  ordersCount: state.new_orders?.length ?? 0,
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
    return Column(
      children: [
        buildStatusBar(),
        SizedBox(height: 25.h),

        Expanded(
          child: BlocBuilder<DashboardBloc, DashBoardState>(
            builder: (context, state) {
              if (state.newGetOrdersStatus == NewGetOrdersStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.newGetOrdersStatus == NewGetOrdersStatus.failure) {
                return const Center(child: Text("Something went wrong"));
              }

              if (state.newGetOrdersStatus == NewGetOrdersStatus.success) {
                final ordersList = state.new_orders ?? [];

                if (ordersList.isEmpty) {
                  return const Center(child: Text("No orders found"));
                }

                return Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: ListView.separated(
                    itemCount: ordersList.length,
                    separatorBuilder: (_, __) => SizedBox(height: 10.h),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetailsNew(
                                orderNumber: '00${ordersList[index].id}',
                                orders: ordersList[index],
                                indexGroupe: index,
                              ),
                            ),
                          );
                        },

                        child: buildOrderItemWidget(
                          context: context,
                          item: ordersList[index],
                          indexInGroup: index + 1,
                        ),
                      );
                    },
                  ),
                );
              }

              return const SizedBox();
            },
          ),
        ),
      ],
    );
  }

  final ValueNotifier<ConstOrderStatus> currentStatusOfOrder = ValueNotifier(
    ConstOrderStatus.all,
  );


  Widget buildStatusBar() {
    return ValueListenableBuilder<ConstOrderStatus>(
      valueListenable: currentStatusOfOrder,
      builder: (context, _currentStatus, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 17),
          child: SizedBox(
            height: 26,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: ConstOrderStatus.values.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return SvgPicture.asset(
                    AppAssets.orderStatusFilterSvg,
                    width: 25,
                  );
                }

                final status = ConstOrderStatus.values[index - 1];
                final bool isSelected = _currentStatus == status;

                return InkWell(
                  onTap: () {
                    currentStatusOfOrder.value = status;
                    final String statusForApi = status.apiValue;
                    _dashboardBloc.ordersStatus = statusForApi;
                    if (kDebugMode) print('Selected status: ${_dashboardBloc.ordersStatus}');
                    _dashboardBloc.add(NewGetOrdersEvent());
                  },
                  child: Container(
                    height: 26,
                    width: status == ConstOrderStatus.all ? 60 : 130,
                    decoration: BoxDecoration(
                      color: const Color(0xffF8F8F8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xff388CFF)
                            : const Color(0xffF8F8F8),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        getStatusLabel(status),
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodyMedium?.rq.copyWith(
                          color: const Color(0xff8D8D8D),
                          letterSpacing: 0.18,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(width: 10),
            ),
          ),
        );
      },
    );
  }

  Widget buildOrderItemWidget({
    required BuildContext context,
    required UserOrderNew item,
    required int indexInGroup,
  }) {
    final details = item.details;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xffF8F8F8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            buildInfoWidget(
              context: context,
              isSecondInfo: false,
              isTextSpan: false,
              orderGroupId: indexInGroup.toString(),
              text1:
                  item.createdAt.date +
                  ' | ' +
                  (item.createdAt.time) +
                  ' | Remain ' +
                  item.remainingInMinutes.toString() +
                  'm',
              text2: '00' + indexInGroup.toString(),
              svgIcon1: AppAssets.orderClockSvg,
              svgIcon2: AppAssets.orderBag1Svg,
              amount: '',
              currency: '',
              itemsCount: '',
            ),
            const SizedBox(height: 11),
            buildInfoWidget(
              context: context,
              isSecondInfo: true,
              isTextSpan: true,
              orderGroupId: item.id.toString(),
              text1: item.orderStatus,
              text2: '',
              svgIcon1: AppAssets.cartCart,
              svgIcon2: AppAssets.orderInvoice2Svg,
              secondInfoSvgIcon: AppAssets.pendeingBlackCheck,
              amount: item.orderAmount.toString(),
              currency: 'USD',
              itemsCount: details.length.toString(),
            ),
            const SizedBox(height: 11),
            SizedBox(
              height: 125,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: details.length,
                separatorBuilder: (_, __) => const SizedBox(width: 5),
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: MyCachedNetworkImage(
                      imageUrl: details[index].cartImage,
                      width: 91,
                      height: 125,
                      imageFit: BoxFit.cover,
                      radius: 15,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoWidget({
    required bool isSecondInfo,
    required BuildContext context,
    required String svgIcon1,
    required String svgIcon2,
    String? secondInfoSvgIcon,
    required String orderGroupId,
    required String text1,
    required String text2,
    required bool isTextSpan,
    required String itemsCount,
    required String amount,
    required String currency,
  }) {
    return SizedBox(
      height: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                svgIcon1 == ""
                    ? const SizedBox.shrink()
                    : SvgPicture.asset(svgIcon1, width: 15),
                ///////////////////////////
                const SizedBox(width: 2),
                ///////////////////////////
                Flexible(
                  child: Text(
                    text1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyMedium?.rq.copyWith(
                      color: const Color(0xff1D1D1D),
                      letterSpacing: 0.18,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ),
                ////////////////////////////
                isSecondInfo
                    ? const SizedBox(width: 5)
                    : const SizedBox.shrink(),
                ///////////////////
                isSecondInfo
                    ? SvgPicture.asset(secondInfoSvgIcon ?? '', width: 15)
                    : const SizedBox.shrink(),
              ],
            ),
          ),
          /////////////////////////
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SvgPicture.asset(svgIcon2, width: 15),
                ///////////////////////////
                const SizedBox(width: 5),
                ///////////////////////////
                isTextSpan
                    ? Flexible(
                        child: RichText(
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: context.textTheme.bodyMedium?.rq.copyWith(
                              color: const Color(0xff505050),
                              letterSpacing: 0.18,
                              fontSize: 12,
                              height: 1.3,
                            ),
                            children: [
                              TextSpan(
                                text: itemsCount,
                                style: context.textTheme.bodyMedium?.bq
                                    .copyWith(
                                      color: const Color(0xff505050),
                                      letterSpacing: 0.18,
                                      fontSize: 12,
                                      height: 1.3,
                                    ),
                              ),
                              TextSpan(text: ' ${LocaleKeys.item.tr()} . '),
                              TextSpan(
                                text: amount,
                                style: context.textTheme.bodyMedium?.bq
                                    .copyWith(
                                      color: const Color(0xff505050),
                                      letterSpacing: 0.18,
                                      fontSize: 12,
                                      height: 1.3,
                                    ),
                              ),
                              TextSpan(text: ' $currency'),
                            ],
                          ),
                        ),
                      )
                    : Flexible(
                        child: Text(
                          text2,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodyMedium?.rq.copyWith(
                            color: const Color(0xff1D1D1D),
                            letterSpacing: 0.18,
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //////////////////////////////////////////////////////////////////////////////////////////'
  ///
  ///////////////////////////////////////////////////
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
