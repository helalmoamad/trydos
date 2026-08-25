// // import 'package:flutter/foundation.dart' hide Category;
// // import 'package:flutter/material.dart';
// // import 'package:easy_localization/easy_localization.dart';
// // import 'package:flutter_svg/svg.dart';
// // import 'package:get_it/get_it.dart';
// // import 'package:trydos/common/constant/design/assets_provider.dart';
// // import 'package:trydos/config/theme/typography.dart';
// // import 'package:trydos/core/domin/repositories/prefs_repository.dart';
// // import 'package:trydos/core/utils/extensions/build_context.dart';
// // import 'package:trydos/features/app/my_cached_network_image.dart';
// // import 'package:trydos/features/dashBoard/data/models/get_new_ordersToDashboard.dart';
// // import 'package:trydos/features/dashBoard/presentation/pages/order_details_page.dart';
// // import 'package:trydos/features/dashBoard/presentation/widgets/order_status.dart';
// // import 'package:trydos/generated/locale_keys.g.dart';
// // import 'package:flutter_screenutil/flutter_screenutil.dart';
// // import '../widgets/dashboard_header.dart';
// // import '../widgets/dashboard_tab_bar.dart';
// // import '../widgets/empty_state_widget.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import '../bloc/dashBoard_bloc.dart';
// // import '../widgets/permission_card.dart';
// // import '../widgets/add_user_widget.dart';
// // import '../widgets/products_grid_widget.dart';
// // import '../widgets/boutiques_grid_widget.dart';
// // import '../widgets/dashboard_permission_checker.dart';
// // import '../widgets/seller_stories_widget.dart';

// // class DashboardPage extends StatefulWidget {
// //   final String shopName;
// //   final String sellerId;
// //   final List<String> permissions;
// //   final bool canAddUser;
// //   final bool canGetProducts;
// //   final bool canGetBoutiques;
// //   final bool canGetOrders;

// //   const DashboardPage({
// //     Key? key,
// //     required this.shopName,
// //     required this.sellerId,
// //     required this.permissions,
// //     this.canAddUser = true,
// //     this.canGetProducts = true,
// //     this.canGetBoutiques = true,
// //     this.canGetOrders = true,
// //   }) : super(key: key);

// //   @override
// //   State<DashboardPage> createState() => _DashboardPageState();
// // }

// // class _DashboardPageState extends State<DashboardPage> {
// //   int _selectedTabIndex = 0;
// //   late DashboardBloc _dashboardBloc;
// //   late final DashboardPermissionChecker _permissionChecker;

// //   // Get the first available tab index
// //   int _getFirstAvailableTabIndex() {
// //     if (_permissionChecker.canSeeProducts()) return 0;
// //     if (_permissionChecker.canSeeBoutiques()) return 1;
// //     if (_permissionChecker.canSeeOrders()) return 2;
// //     return 3; // Permissions tab is always available
// //   }

// //   @override
// //   void initState() {
// //     super.initState();
// //     _permissionChecker = DashboardPermissionChecker(widget.permissions);
// //     GetIt.I.get<PrefsRepository>().setXSellerId(widget.sellerId);
// //     _dashboardBloc = BlocProvider.of<DashboardBloc>(context);

// //     // Adjust selected index if current tab is not visible
// //     if (_selectedTabIndex == 0 && !_permissionChecker.canSeeProducts()) {
// //       _selectedTabIndex = _getFirstAvailableTabIndex();
// //     } else if (_selectedTabIndex == 1 &&
// //         !_permissionChecker.canSeeBoutiques()) {
// //       _selectedTabIndex = _getFirstAvailableTabIndex();
// //     } else if (_selectedTabIndex == 2 && !_permissionChecker.canSeeOrders()) {
// //       _selectedTabIndex = _getFirstAvailableTabIndex();
// //     } else if (_selectedTabIndex == 4 && !_permissionChecker.canSeeUsers()) {
// //       _selectedTabIndex = _getFirstAvailableTabIndex();
// //     } else if (_selectedTabIndex == 5) {
// //       _selectedTabIndex = _getFirstAvailableTabIndex();
// //     }

// //     // Load initial data based on selected tab
// //     if (_selectedTabIndex == 0 && _permissionChecker.canSeeProducts()) {
// //       _dashboardBloc.add(GetProductsEvent());
// //     } else if (_selectedTabIndex == 1 && _permissionChecker.canSeeBoutiques()) {
// //       _dashboardBloc.add(GetBoutiquesEvent());
// //     } else if (_selectedTabIndex == 2 && _permissionChecker.canSeeOrders()) {
// //       _dashboardBloc.add(NewGetOrdersEvent());
// //     } else if (_selectedTabIndex == 5) {
// //       _dashboardBloc.add(GetSellerStoriesEvent());
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.grey.shade50,
// //       body: SafeArea(
// //         child: Column(
// //           children: [
// //             // Header
// //             DashboardHeader(
// //               shopName: widget.shopName,
// //               sellerId: widget.sellerId,
// //             ),

// //             // Tab Bar
// //             BlocBuilder<DashboardBloc, DashBoardState>(
// //               buildWhen: (previous, current) =>
// //                   previous.getProductsStatus != current.getProductsStatus ||
// //                   previous.getBoutiquesStatus != current.getBoutiquesStatus ||
// //                   previous.getOrdersStatus != current.getOrdersStatus ||
// //                   previous.storiesStatus != current.storiesStatus,
// //               builder: (context, state) {
// //                 return DashboardTabBar(
// //                   selectedIndex: _selectedTabIndex,
// //                   permissions: widget.permissions,
// //                   onTabSelected: (index) {
// //                     setState(() {
// //                       _selectedTabIndex = index;
// //                     });
// //                     Future.delayed(const Duration(milliseconds: 50), () {
// //                       if (index == 0 && widget.canGetProducts) {
// //                         _dashboardBloc.add(GetProductsEvent());
// //                       } else if (index == 1 && widget.canGetBoutiques) {
// //                         _dashboardBloc.add(GetBoutiquesEvent());
// //                       } else if (index == 2 && widget.canGetOrders) {
// //                         _dashboardBloc.add(NewGetOrdersEvent());
// //                       } else if (index == 4 && widget.canAddUser) {
// //                         _dashboardBloc.add(GetUserRolesEvent());
// //                       } else if (index == 5) {
// //                         _dashboardBloc.add(GetSellerStoriesEvent());
// //                       }
// //                     });
// //                   },
// //                   productsCount: state.productsMeta?.total ?? 0,
// //                   boutiquesCount: state.boutiquesMeta?.total ?? 0,
// //                   ordersCount: state.new_orders?.length ?? 0,
// //                   permissionsCount: widget.permissions.length,
// //                   storiesCount: state.stories?.length ?? 0,
// //                 );
// //               },
// //             ),

// //             // Content
// //             Expanded(child: _buildTabContent()),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildTabContent() {
// //     switch (_selectedTabIndex) {
// //       case 0:
// //         return _buildProductsTab();
// //       case 1:
// //         return _buildBoutiquesTab();
// //       case 2:
// //         return _buildOrdersTab();
// //       case 3:
// //         return _buildPermissionsTab();
// //       case 4:
// //         return _buildUsersTab();
// //       case 5:
// //         return _buildStoriesTab();
// //       default:
// //         return _buildProductsTab();
// //     }
// //   }

// //   Widget _buildProductsTab() {
// //     return BlocBuilder<DashboardBloc, DashBoardState>(
// //       buildWhen: (previous, current) =>
// //           previous.getProductsStatus != current.getProductsStatus ||
// //           previous.products != current.products ||
// //           previous.productsMeta?.currentPage !=
// //               current.productsMeta?.currentPage,
// //       builder: (context, state) {
// //         if (state.getProductsStatus == GetProductsStatus.loading &&
// //             (state.products?.length ?? 0) == 0) {
// //           return const Center(child: CircularProgressIndicator());
// //         }

// //         // Check if products exist and are not empty
// //         if (state.products != null && state.products!.isNotEmpty) {
// //           return BlocBuilder<DashboardBloc, DashBoardState>(
// //             buildWhen: (previous, current) =>
// //                 previous.productsMeta?.currentPage !=
// //                     current.productsMeta?.currentPage ||
// //                 previous.getProductsStatus != current.getProductsStatus,
// //             builder: (context, paginationState) {
// //               // Show loading overlay only during pagination (when loading and data exists)
// //               final isPaginationLoading =
// //                   paginationState.getProductsStatus ==
// //                   GetProductsStatus.loading;
// //               return Stack(
// //                 children: [
// //                   ProductsGridWidget(
// //                     products: state.products!,
// //                     meta: state.productsMeta,
// //                     onAddProduct: () {
// //                       // TODO: Add onAddProduct callback
// //                     },
// //                     onPageChanged: (page) {
// //                       _dashboardBloc.add(GetProductsEvent(page: page));
// //                     },
// //                   ),
// //                   if (isPaginationLoading)
// //                     Container(
// //                       // ignore: deprecated_member_use
// //                       color: Colors.black.withOpacity(0.1),
// //                       child: const Center(child: CircularProgressIndicator()),
// //                     ),
// //                 ],
// //               );
// //             },
// //           );
// //         }

// //         // Show empty state when no products
// //         return EmptyStateWidget(
// //           message: LocaleKeys.no_products_found_dashboard.tr(),
// //           icon: Icons.inventory_2_outlined,
// //           actionText: LocaleKeys.add_product.tr(),
// //           // TODO: Add onActionPressed callback
// //         );
// //       },
// //     );
// //   }

// //   Widget _buildBoutiquesTab() {
// //     return BlocBuilder<DashboardBloc, DashBoardState>(
// //       buildWhen: (previous, current) =>
// //           previous.getBoutiquesStatus != current.getBoutiquesStatus ||
// //           previous.boutiques != current.boutiques ||
// //           previous.boutiquesMeta?.currentPage !=
// //               current.boutiquesMeta?.currentPage,
// //       builder: (context, state) {
// //         if (state.getBoutiquesStatus == GetBoutiquesStatus.loading &&
// //             (state.boutiques?.length ?? 0) == 0) {
// //           return const Center(child: CircularProgressIndicator());
// //         }

// //         // Check if boutiques exist and are not empty
// //         if (state.boutiques != null && state.boutiques!.isNotEmpty) {
// //           return BlocBuilder<DashboardBloc, DashBoardState>(
// //             buildWhen: (previous, current) =>
// //                 previous.boutiquesMeta?.currentPage !=
// //                     current.boutiquesMeta?.currentPage ||
// //                 previous.getBoutiquesStatus != current.getBoutiquesStatus,
// //             builder: (context, paginationState) {
// //               // Show loading overlay only during pagination (when loading and data exists)
// //               final isPaginationLoading =
// //                   paginationState.getBoutiquesStatus ==
// //                   GetBoutiquesStatus.loading;
// //               return Stack(
// //                 children: [
// //                   BoutiquesGridWidget(
// //                     boutiques: state.boutiques!,
// //                     meta: state.boutiquesMeta,
// //                     onAddBoutique: () {
// //                       // TODO: Add onAddBoutique callback
// //                     },
// //                     onPageChanged: (page) {
// //                       _dashboardBloc.add(GetBoutiquesEvent(page: page));
// //                     },
// //                   ),
// //                   if (isPaginationLoading)
// //                     Container(
// //                       // ignore: deprecated_member_use
// //                       color: Colors.black.withOpacity(0.1),
// //                       child: const Center(child: CircularProgressIndicator()),
// //                     ),
// //                 ],
// //               );
// //             },
// //           );
// //         }

// //         // Show empty state when no boutiques
// //         return EmptyStateWidget(
// //           message: LocaleKeys.no_boutiques_found.tr(),
// //           icon: Icons.store_outlined,
// //           actionText: LocaleKeys.add_boutique.tr(),
// //           // TODO: Add onActionPressed callback
// //         );
// //       },
// //     );
// //   }

// //   Widget _buildOrdersTab() {
// //     return Column(
// //       children: [
// //         buildStatusBar(),
// //         SizedBox(height: 25.h),

// //         Expanded(
// //           child: BlocBuilder<DashboardBloc, DashBoardState>(
// //             builder: (context, state) {
// //               if (state.newGetOrdersStatus == NewGetOrdersStatus.loading) {
// //                 return const Center(child: CircularProgressIndicator());
// //               }

// //               if (state.newGetOrdersStatus == NewGetOrdersStatus.failure) {
// //                 return const Center(child: Text("Something went wrong"));
// //               }

// //               if (state.newGetOrdersStatus == NewGetOrdersStatus.success) {
// //                 final ordersList = state.new_orders ?? [];

// //                 if (ordersList.isEmpty) {
// //                   return const Center(child: Text("No orders found"));
// //                 }

// //                 return Padding(
// //                   padding: EdgeInsets.only(bottom: 10.h),
// //                   child: ListView.separated(
// //                     itemCount: ordersList.length,
// //                     separatorBuilder: (_, __) => SizedBox(height: 10.h),
// //                     itemBuilder: (context, index) {
// //                       return InkWell(
// //                         onTap: () {
// //                           Navigator.push(
// //                             context,
// //                             MaterialPageRoute(
// //                               builder: (context) => OrderDetailsNew(
// //                                 orderNumber: '00${ordersList[index].id}',
// //                                 orders: ordersList[index],
// //                                 indexGroupe: index,
// //                               ),
// //                             ),
// //                           );
// //                         },

// //                         child: buildOrderItemWidget(
// //                           context: context,
// //                           item: ordersList[index],
// //                           indexInGroup: index + 1,
// //                         ),
// //                       );
// //                     },
// //                   ),
// //                 );
// //               }

// //               return const SizedBox();
// //             },
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   final ValueNotifier<ConstOrderStatus> currentStatusOfOrder = ValueNotifier(
// //     ConstOrderStatus.all,
// //   );

// //   Widget buildStatusBar() {
// //     return ValueListenableBuilder<ConstOrderStatus>(
// //       valueListenable: currentStatusOfOrder,
// //       builder: (context, _currentStatus, _) {
// //         return Padding(
// //           padding: const EdgeInsets.symmetric(horizontal: 17),
// //           child: SizedBox(
// //             height: 26,
// //             child: ListView.separated(
// //               scrollDirection: Axis.horizontal,
// //               itemCount: ConstOrderStatus.values.length + 1,
// //               itemBuilder: (context, index) {
// //                 if (index == 0) {
// //                   return SvgPicture.asset(
// //                     AppAssets.orderStatusFilterSvg,
// //                     width: 25,
// //                   );
// //                 }

// //                 final status = ConstOrderStatus.values[index - 1];
// //                 final bool isSelected = _currentStatus == status;

// //                 return InkWell(
// //                   onTap: () {
// //                     currentStatusOfOrder.value = status;
// //                     final String statusForApi = status.apiValue;
// //                     _dashboardBloc.ordersStatus = statusForApi;
// //                     if (kDebugMode)
// //                       print('Selected status: ${_dashboardBloc.ordersStatus}');
// //                     _dashboardBloc.add(NewGetOrdersEvent());
// //                   },
// //                   child: Container(
// //                     height: 26,
// //                     width: status == ConstOrderStatus.all ? 60 : 130,
// //                     decoration: BoxDecoration(
// //                       color: const Color(0xffF8F8F8),
// //                       borderRadius: BorderRadius.circular(10),
// //                       border: Border.all(
// //                         color: isSelected
// //                             ? const Color(0xff388CFF)
// //                             : const Color(0xffF8F8F8),
// //                       ),
// //                     ),
// //                     child: Center(
// //                       child: Text(
// //                         getStatusLabel(status),
// //                         overflow: TextOverflow.ellipsis,
// //                         style: context.textTheme.bodyMedium?.rq.copyWith(
// //                           color: const Color(0xff8D8D8D),
// //                           letterSpacing: 0.18,
// //                           fontSize: 12,
// //                           height: 1.3,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 );
// //               },
// //               separatorBuilder: (context, index) => const SizedBox(width: 10),
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   Widget buildOrderItemWidget({
// //     required BuildContext context,
// //     required UserOrderNew item,
// //     required int indexInGroup,
// //   }) {
// //     final details = item.details;

// //     return Padding(
// //       padding: const EdgeInsets.symmetric(horizontal: 12),
// //       child: Container(
// //         padding: const EdgeInsets.all(12),
// //         decoration: BoxDecoration(
// //           color: const Color(0xffF8F8F8),
// //           borderRadius: BorderRadius.circular(10),
// //         ),
// //         child: Column(
// //           children: [
// //             buildInfoWidget(
// //               context: context,
// //               isSecondInfo: false,
// //               isTextSpan: false,
// //               orderGroupId: indexInGroup.toString(),
// //               text1:
// //                   item.createdAt.date +
// //                   ' | ' +
// //                   (item.createdAt.time) +
// //                   ' | Remain ' +
// //                   item.remainingInMinutes.toString() +
// //                   'm',
// //               text2: '00' + indexInGroup.toString(),
// //               svgIcon1: AppAssets.orderClockSvg,
// //               svgIcon2: AppAssets.orderBag1Svg,
// //               amount: '',
// //               currency: '',
// //               itemsCount: '',
// //             ),
// //             const SizedBox(height: 11),
// //             buildInfoWidget(
// //               context: context,
// //               isSecondInfo: true,
// //               isTextSpan: true,
// //               orderGroupId: item.id.toString(),
// //               text1: item.orderStatus,
// //               text2: '',
// //               svgIcon1: AppAssets.cartCart,
// //               svgIcon2: AppAssets.orderInvoice2Svg,
// //               secondInfoSvgIcon: AppAssets.pendeingBlackCheck,
// //               amount: item.orderAmount.toString(),
// //               currency: 'USD',
// //               itemsCount: details.length.toString(),
// //             ),
// //             const SizedBox(height: 11),
// //             SizedBox(
// //               height: 125,
// //               child: ListView.separated(
// //                 scrollDirection: Axis.horizontal,
// //                 itemCount: details.length,
// //                 separatorBuilder: (_, __) => const SizedBox(width: 5),
// //                 itemBuilder: (context, index) {
// //                   return ClipRRect(
// //                     borderRadius: BorderRadius.circular(15),
// //                     child: MyCachedNetworkImage(
// //                       imageUrl: details[index].cartImage,
// //                       width: 91,
// //                       height: 125,
// //                       imageFit: BoxFit.cover,
// //                       radius: 15,
// //                     ),
// //                   );
// //                 },
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget buildInfoWidget({
// //     required bool isSecondInfo,
// //     required BuildContext context,
// //     required String svgIcon1,
// //     required String svgIcon2,
// //     String? secondInfoSvgIcon,
// //     required String orderGroupId,
// //     required String text1,
// //     required String text2,
// //     required bool isTextSpan,
// //     required String itemsCount,
// //     required String amount,
// //     required String currency,
// //   }) {
// //     return SizedBox(
// //       height: 16,
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //         children: [
// //           Expanded(
// //             child: Row(
// //               children: [
// //                 svgIcon1 == ""
// //                     ? const SizedBox.shrink()
// //                     : SvgPicture.asset(svgIcon1, width: 15),
// //                 ///////////////////////////
// //                 const SizedBox(width: 2),
// //                 ///////////////////////////
// //                 Flexible(
// //                   child: Text(
// //                     text1,
// //                     overflow: TextOverflow.ellipsis,
// //                     style: context.textTheme.bodyMedium?.rq.copyWith(
// //                       color: const Color(0xff1D1D1D),
// //                       letterSpacing: 0.18,
// //                       fontSize: 12,
// //                       height: 1.3,
// //                     ),
// //                   ),
// //                 ),
// //                 ////////////////////////////
// //                 isSecondInfo
// //                     ? const SizedBox(width: 5)
// //                     : const SizedBox.shrink(),
// //                 ///////////////////
// //                 isSecondInfo
// //                     ? SvgPicture.asset(secondInfoSvgIcon ?? '', width: 15)
// //                     : const SizedBox.shrink(),
// //               ],
// //             ),
// //           ),
// //           /////////////////////////
// //           Expanded(
// //             child: Row(
// //               mainAxisAlignment: MainAxisAlignment.end,
// //               children: [
// //                 SvgPicture.asset(svgIcon2, width: 15),
// //                 ///////////////////////////
// //                 const SizedBox(width: 5),
// //                 ///////////////////////////
// //                 isTextSpan
// //                     ? Flexible(
// //                         child: RichText(
// //                           overflow: TextOverflow.ellipsis,
// //                           text: TextSpan(
// //                             style: context.textTheme.bodyMedium?.rq.copyWith(
// //                               color: const Color(0xff505050),
// //                               letterSpacing: 0.18,
// //                               fontSize: 12,
// //                               height: 1.3,
// //                             ),
// //                             children: [
// //                               TextSpan(
// //                                 text: itemsCount,
// //                                 style: context.textTheme.bodyMedium?.bq
// //                                     .copyWith(
// //                                       color: const Color(0xff505050),
// //                                       letterSpacing: 0.18,
// //                                       fontSize: 12,
// //                                       height: 1.3,
// //                                     ),
// //                               ),
// //                               TextSpan(text: ' ${LocaleKeys.item.tr()} . '),
// //                               TextSpan(
// //                                 text: amount,
// //                                 style: context.textTheme.bodyMedium?.bq
// //                                     .copyWith(
// //                                       color: const Color(0xff505050),
// //                                       letterSpacing: 0.18,
// //                                       fontSize: 12,
// //                                       height: 1.3,
// //                                     ),
// //                               ),
// //                               TextSpan(text: ' $currency'),
// //                             ],
// //                           ),
// //                         ),
// //                       )
// //                     : Flexible(
// //                         child: Text(
// //                           text2,
// //                           overflow: TextOverflow.ellipsis,
// //                           style: context.textTheme.bodyMedium?.rq.copyWith(
// //                             color: const Color(0xff1D1D1D),
// //                             letterSpacing: 0.18,
// //                             fontSize: 12,
// //                             height: 1.3,
// //                           ),
// //                         ),
// //                       ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   //////////////////////////////////////////////////////////////////////////////////////////'
// //   ///
// //   ///////////////////////////////////////////////////
// //   Widget _buildPermissionsTab() {
// //     if (widget.permissions.isEmpty) {
// //       return EmptyStateWidget(
// //         message: LocaleKeys.no_permissions_assigned.tr(),
// //         icon: Icons.admin_panel_settings_outlined,
// //       );
// //     }

// //     return ListView.builder(
// //       padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
// //       itemCount: widget.permissions.length,
// //       itemBuilder: (context, index) {
// //         final permission = widget.permissions[index];
// //         return PermissionCard(permissionName: permission);
// //       },
// //     );
// //   }

// //   Widget _buildUsersTab() {
// //     if (!widget.canAddUser) {
// //       return EmptyStateWidget(
// //         title: LocaleKeys.access_denied.tr(),
// //         message: LocaleKeys.no_permission_to_manage_users.tr(),
// //       );
// //     }

// //     return AddUserWidget(sellerId: widget.sellerId);
// //   }

// //   Widget _buildStoriesTab() {
// //     // if (!_permissionChecker.canSeeStories()) {
// //     //   return EmptyStateWidget(
// //     //     title: LocaleKeys.access_denied.tr(),
// //     //     message: LocaleKeys.no_permissions_assigned.tr(),
// //     //   );
// //     // }

// //     return const SellerStoriesWidget();
// //   }
// // }

// import 'package:flutter/foundation.dart' hide Category;
// import 'package:flutter/material.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get_it/get_it.dart';
// import 'package:trydos/common/constant/design/assets_provider.dart';
// import 'package:trydos/config/theme/typography.dart';
// import 'package:trydos/core/domin/repositories/prefs_repository.dart';
// import 'package:trydos/core/utils/extensions/build_context.dart';
// import 'package:trydos/features/app/my_cached_network_image.dart';
// import 'package:trydos/features/dashBoard/data/models/get_new_ordersToDashboard.dart';
// import 'package:trydos/features/dashBoard/presentation/pages/order_details_page.dart';
// import 'package:trydos/features/dashBoard/presentation/widgets/order_status.dart';
// import 'package:trydos/generated/locale_keys.g.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../widgets/dashboard_header.dart';
// import '../widgets/empty_state_widget.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../bloc/dashBoard_bloc.dart';
// import '../widgets/permission_card.dart';
// import '../widgets/add_user_widget.dart';
// import '../widgets/products_grid_widget.dart';
// import '../widgets/boutiques_grid_widget.dart';
// import '../widgets/dashboard_permission_checker.dart';
// import '../widgets/seller_stories_widget.dart';

// class DashboardPage extends StatefulWidget {
//   final String shopName;
//   final String sellerId;
//   final List<String> permissions;
//   final bool canAddUser;
//   final bool canGetProducts;
//   final bool canGetBoutiques;
//   final bool canGetOrders;

//   const DashboardPage({
//     Key? key,
//     required this.shopName,
//     required this.sellerId,
//     required this.permissions,
//     this.canAddUser = true,
//     this.canGetProducts = true,
//     this.canGetBoutiques = true,
//     this.canGetOrders = true,
//   }) : super(key: key);

//   @override
//   State<DashboardPage> createState() => _DashboardPageState();
// }

// class _DashboardPageState extends State<DashboardPage> {
//   int _selectedTabIndex = 0;
//   late DashboardBloc _dashboardBloc;
//   late final DashboardPermissionChecker _permissionChecker;

//   // Get the first available tab index
//   int _getFirstAvailableTabIndex() {
//     if (_permissionChecker.canSeeProducts()) return 0;
//     if (_permissionChecker.canSeeBoutiques()) return 1;
//     if (_permissionChecker.canSeeOrders()) return 2;
//     return 3; // Permissions tab is always available
//   }

//   @override
//   void initState() {
//     super.initState();
//     _permissionChecker = DashboardPermissionChecker(widget.permissions);
//     GetIt.I.get<PrefsRepository>().setXSellerId(widget.sellerId);
//     _dashboardBloc = BlocProvider.of<DashboardBloc>(context);

//     // Adjust selected index if current tab is not visible
//     if (_selectedTabIndex == 0 && !_permissionChecker.canSeeProducts()) {
//       _selectedTabIndex = _getFirstAvailableTabIndex();
//     } else if (_selectedTabIndex == 1 &&
//         !_permissionChecker.canSeeBoutiques()) {
//       _selectedTabIndex = _getFirstAvailableTabIndex();
//     } else if (_selectedTabIndex == 2 && !_permissionChecker.canSeeOrders()) {
//       _selectedTabIndex = _getFirstAvailableTabIndex();
//     } else if (_selectedTabIndex == 4 && !_permissionChecker.canSeeUsers()) {
//       _selectedTabIndex = _getFirstAvailableTabIndex();
//     } else if (_selectedTabIndex == 5) {
//       _selectedTabIndex = _getFirstAvailableTabIndex();
//     }

//     // Load initial data based on selected tab
//     if (_selectedTabIndex == 0 && _permissionChecker.canSeeProducts()) {
//       _dashboardBloc.add(GetProductsEvent());
//     } else if (_selectedTabIndex == 1 && _permissionChecker.canSeeBoutiques()) {
//       _dashboardBloc.add(GetBoutiquesEvent());
//     } else if (_selectedTabIndex == 2 && _permissionChecker.canSeeOrders()) {
//       _dashboardBloc.add(NewGetOrdersEvent());
//     } else if (_selectedTabIndex == 5) {
//       _dashboardBloc.add(GetSellerStoriesEvent());
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade50,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Header
//             DashboardHeader(
//               shopName: widget.shopName,
//               sellerId: widget.sellerId,
//             ),

//             // Tab Bar -> replaced with card-list design (same data/logic as before)
//             BlocBuilder<DashboardBloc, DashBoardState>(
//               buildWhen: (previous, current) =>
//                   previous.getProductsStatus != current.getProductsStatus ||
//                   previous.getBoutiquesStatus != current.getBoutiquesStatus ||
//                   previous.getOrdersStatus != current.getOrdersStatus ||
//                   previous.storiesStatus != current.storiesStatus,
//               builder: (context, state) {
//                 final int productsCount = state.productsMeta?.total ?? 0;
//                 final int boutiquesCount = state.boutiquesMeta?.total ?? 0;
//                 final int ordersCount = state.new_orders?.length ?? 0;
//                 final int permissionsCount = widget.permissions.length;
//                 final int storiesCount = state.stories?.length ?? 0;

//                 void onTabSelected(int index) {
//                   setState(() {
//                     _selectedTabIndex = index;
//                   });
//                   Future.delayed(const Duration(milliseconds: 50), () {
//                     if (index == 0 && widget.canGetProducts) {
//                       _dashboardBloc.add(GetProductsEvent());
//                     } else if (index == 1 && widget.canGetBoutiques) {
//                       _dashboardBloc.add(GetBoutiquesEvent());
//                     } else if (index == 2 && widget.canGetOrders) {
//                       _dashboardBloc.add(NewGetOrdersEvent());
//                     } else if (index == 4 && widget.canAddUser) {
//                       _dashboardBloc.add(GetUserRolesEvent());
//                     } else if (index == 5) {
//                       _dashboardBloc.add(GetSellerStoriesEvent());
//                     }
//                   });
//                 }

//                 final items = <_FilterItem>[
//                   _FilterItem(
//                     index: 0,
//                     icon: Icons.inventory_2_outlined,
//                     // TODO: replace with your real LocaleKeys.xxx.tr() for this label
//                     title: 'المنتجات',
//                     count: productsCount,
//                     visible: _permissionChecker.canSeeProducts(),
//                   ),
//                   _FilterItem(
//                     index: 1,
//                     icon: Icons.storefront_outlined,
//                     // TODO: replace with your real LocaleKeys.xxx.tr() for this label
//                     title: 'المتاجر',
//                     count: boutiquesCount,
//                     visible: _permissionChecker.canSeeBoutiques(),
//                   ),
//                   _FilterItem(
//                     index: 2,
//                     icon: Icons.assignment_outlined,
//                     // TODO: replace with your real LocaleKeys.xxx.tr() for this label
//                     title: 'الطلبات',
//                     count: ordersCount,
//                     visible: _permissionChecker.canSeeOrders(),
//                   ),
//                   _FilterItem(
//                     index: 3,
//                     icon: Icons.admin_panel_settings_outlined,
//                     // TODO: replace with your real LocaleKeys.xxx.tr() for this label
//                     title: 'الصلاحيات',
//                     count: permissionsCount,
//                     visible: true, // permissions tab always available, same as before
//                   ),
//                   _FilterItem(
//                     index: 4,
//                     icon: Icons.person_add_alt_outlined,
//                     // TODO: replace with your real LocaleKeys.xxx.tr() for this label
//                     title: 'المستخدمون',
//                     count: 0,
//                     visible: _permissionChecker.canSeeUsers(),
//                   ),
//                   _FilterItem(
//                     index: 5,
//                     icon: Icons.photo_library_outlined,
//                     // TODO: replace with your real LocaleKeys.xxx.tr() for this label
//                     title: 'القصص',
//                     count: storiesCount,
//                     visible: true, // no explicit permission gate in original code
//                   ),
//                 ].where((i) => i.visible).toList();

//                 return Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Column(
//                     children: items.map((item) {
//                       final bool isSelected = item.index == _selectedTabIndex;
//                       return Padding(
//                         padding: const EdgeInsets.only(bottom: 10),
//                         child: InkWell(
//                           onTap: () => onTabSelected(item.index),
//                           borderRadius: BorderRadius.circular(14),
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 14,
//                               vertical: 12,
//                             ),
//                             decoration: BoxDecoration(
//                               color: const Color(0xffF8F8F8),
//                               borderRadius: BorderRadius.circular(14),
//                               border: Border.all(
//                                 color: isSelected
//                                     ? const Color(0xff388CFF)
//                                     : Colors.transparent,
//                                 width: 1,
//                               ),
//                             ),
//                             child: Row(
//                               children: [
//                                 Container(
//                                   width: 42,
//                                   height: 42,
//                                   alignment: Alignment.center,
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   child: Icon(
//                                     item.icon,
//                                     size: 20,
//                                     color: const Color(0xff1D1D1D),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Expanded(
//                                   child: Text(
//                                     item.title,
//                                     style: const TextStyle(
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w700,
//                                       color: Color(0xff1D1D1D),
//                                     ),
//                                   ),
//                                 ),
//                                 if (item.count > 0) ...[
//                                   Container(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 8,
//                                       vertical: 3,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: const Color(0xffEFEFEF),
//                                       borderRadius: BorderRadius.circular(20),
//                                     ),
//                                     child: Text(
//                                       '${item.count}',
//                                       style: const TextStyle(
//                                         fontSize: 11,
//                                         color: Color(0xff505050),
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(width: 8),
//                                 ],
//                                 const Icon(
//                                   Icons.chevron_right,
//                                   size: 20,
//                                   color: Color(0xffBDBDBD),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                 );
//               },
//             ),

//             // Content
//             Expanded(child: _buildTabContent()),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTabContent() {
//     switch (_selectedTabIndex) {
//       case 0:
//         return _buildProductsTab();
//       case 1:
//         return _buildBoutiquesTab();
//       case 2:
//         return _buildOrdersTab();
//       case 3:
//         return _buildPermissionsTab();
//       case 4:
//         return _buildUsersTab();
//       case 5:
//         return _buildStoriesTab();
//       default:
//         return _buildProductsTab();
//     }
//   }

//   Widget _buildProductsTab() {
//     return BlocBuilder<DashboardBloc, DashBoardState>(
//       buildWhen: (previous, current) =>
//           previous.getProductsStatus != current.getProductsStatus ||
//           previous.products != current.products ||
//           previous.productsMeta?.currentPage !=
//               current.productsMeta?.currentPage,
//       builder: (context, state) {
//         if (state.getProductsStatus == GetProductsStatus.loading &&
//             (state.products?.length ?? 0) == 0) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         // Check if products exist and are not empty
//         if (state.products != null && state.products!.isNotEmpty) {
//           return BlocBuilder<DashboardBloc, DashBoardState>(
//             buildWhen: (previous, current) =>
//                 previous.productsMeta?.currentPage !=
//                     current.productsMeta?.currentPage ||
//                 previous.getProductsStatus != current.getProductsStatus,
//             builder: (context, paginationState) {
//               // Show loading overlay only during pagination (when loading and data exists)
//               final isPaginationLoading =
//                   paginationState.getProductsStatus ==
//                   GetProductsStatus.loading;
//               return Stack(
//                 children: [
//                   ProductsGridWidget(
//                     products: state.products!,
//                     meta: state.productsMeta,
//                     onAddProduct: () {
//                       // TODO: Add onAddProduct callback
//                     },
//                     onPageChanged: (page) {
//                       _dashboardBloc.add(GetProductsEvent(page: page));
//                     },
//                   ),
//                   if (isPaginationLoading)
//                     Container(
//                       // ignore: deprecated_member_use
//                       color: Colors.black.withOpacity(0.1),
//                       child: const Center(child: CircularProgressIndicator()),
//                     ),
//                 ],
//               );
//             },
//           );
//         }

//         // Show empty state when no products
//         return EmptyStateWidget(
//           message: LocaleKeys.no_products_found_dashboard.tr(),
//           icon: Icons.inventory_2_outlined,
//           actionText: LocaleKeys.add_product.tr(),
//           // TODO: Add onActionPressed callback
//         );
//       },
//     );
//   }

//   Widget _buildBoutiquesTab() {
//     return BlocBuilder<DashboardBloc, DashBoardState>(
//       buildWhen: (previous, current) =>
//           previous.getBoutiquesStatus != current.getBoutiquesStatus ||
//           previous.boutiques != current.boutiques ||
//           previous.boutiquesMeta?.currentPage !=
//               current.boutiquesMeta?.currentPage,
//       builder: (context, state) {
//         if (state.getBoutiquesStatus == GetBoutiquesStatus.loading &&
//             (state.boutiques?.length ?? 0) == 0) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         // Check if boutiques exist and are not empty
//         if (state.boutiques != null && state.boutiques!.isNotEmpty) {
//           return BlocBuilder<DashboardBloc, DashBoardState>(
//             buildWhen: (previous, current) =>
//                 previous.boutiquesMeta?.currentPage !=
//                     current.boutiquesMeta?.currentPage ||
//                 previous.getBoutiquesStatus != current.getBoutiquesStatus,
//             builder: (context, paginationState) {
//               // Show loading overlay only during pagination (when loading and data exists)
//               final isPaginationLoading =
//                   paginationState.getBoutiquesStatus ==
//                   GetBoutiquesStatus.loading;
//               return Stack(
//                 children: [
//                   BoutiquesGridWidget(
//                     boutiques: state.boutiques!,
//                     meta: state.boutiquesMeta,
//                     onAddBoutique: () {
//                       // TODO: Add onAddBoutique callback
//                     },
//                     onPageChanged: (page) {
//                       _dashboardBloc.add(GetBoutiquesEvent(page: page));
//                     },
//                   ),
//                   if (isPaginationLoading)
//                     Container(
//                       // ignore: deprecated_member_use
//                       color: Colors.black.withOpacity(0.1),
//                       child: const Center(child: CircularProgressIndicator()),
//                     ),
//                 ],
//               );
//             },
//           );
//         }

//         // Show empty state when no boutiques
//         return EmptyStateWidget(
//           message: LocaleKeys.no_boutiques_found.tr(),
//           icon: Icons.store_outlined,
//           actionText: LocaleKeys.add_boutique.tr(),
//           // TODO: Add onActionPressed callback
//         );
//       },
//     );
//   }

//   Widget _buildOrdersTab() {
//     return Column(
//       children: [
//         buildStatusBar(),
//         SizedBox(height: 25.h),

//         Expanded(
//           child: BlocBuilder<DashboardBloc, DashBoardState>(
//             builder: (context, state) {
//               if (state.newGetOrdersStatus == NewGetOrdersStatus.loading) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               if (state.newGetOrdersStatus == NewGetOrdersStatus.failure) {
//                 return const Center(child: Text("Something went wrong"));
//               }

//               if (state.newGetOrdersStatus == NewGetOrdersStatus.success) {
//                 final ordersList = state.new_orders ?? [];

//                 if (ordersList.isEmpty) {
//                   return const Center(child: Text("No orders found"));
//                 }

//                 return Padding(
//                   padding: EdgeInsets.only(bottom: 10.h),
//                   child: ListView.separated(
//                     itemCount: ordersList.length,
//                     separatorBuilder: (_, __) => SizedBox(height: 10.h),
//                     itemBuilder: (context, index) {
//                       return InkWell(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => OrderDetailsNew(
//                                 orderNumber: '00${ordersList[index].id}',
//                                 orders: ordersList[index],
//                                 indexGroupe: index,
//                               ),
//                             ),
//                           );
//                         },

//                         child: buildOrderItemWidget(
//                           context: context,
//                           item: ordersList[index],
//                           indexInGroup: index + 1,
//                         ),
//                       );
//                     },
//                   ),
//                 );
//               }

//               return const SizedBox();
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   final ValueNotifier<ConstOrderStatus> currentStatusOfOrder = ValueNotifier(
//     ConstOrderStatus.all,
//   );

//   Widget buildStatusBar() {
//     return ValueListenableBuilder<ConstOrderStatus>(
//       valueListenable: currentStatusOfOrder,
//       builder: (context, _currentStatus, _) {
//         return Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 17),
//           child: SizedBox(
//             height: 26,
//             child: ListView.separated(
//               scrollDirection: Axis.horizontal,
//               itemCount: ConstOrderStatus.values.length + 1,
//               itemBuilder: (context, index) {
//                 if (index == 0) {
//                   return SvgPicture.asset(
//                     AppAssets.orderStatusFilterSvg,
//                     width: 25,
//                   );
//                 }

//                 final status = ConstOrderStatus.values[index - 1];
//                 final bool isSelected = _currentStatus == status;

//                 return InkWell(
//                   onTap: () {
//                     currentStatusOfOrder.value = status;
//                     final String statusForApi = status.apiValue;
//                     _dashboardBloc.ordersStatus = statusForApi;
//                     if (kDebugMode)
//                       print('Selected status: ${_dashboardBloc.ordersStatus}');
//                     _dashboardBloc.add(NewGetOrdersEvent());
//                   },
//                   child: Container(
//                     height: 26,
//                     width: status == ConstOrderStatus.all ? 60 : 130,
//                     decoration: BoxDecoration(
//                       color: const Color(0xffF8F8F8),
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(
//                         color: isSelected
//                             ? const Color(0xff388CFF)
//                             : const Color(0xffF8F8F8),
//                       ),
//                     ),
//                     child: Center(
//                       child: Text(
//                         getStatusLabel(status),
//                         overflow: TextOverflow.ellipsis,
//                         style: context.textTheme.bodyMedium?.rq.copyWith(
//                           color: const Color(0xff8D8D8D),
//                           letterSpacing: 0.18,
//                           fontSize: 12,
//                           height: 1.3,
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//               separatorBuilder: (context, index) => const SizedBox(width: 10),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget buildOrderItemWidget({
//     required BuildContext context,
//     required UserOrderNew item,
//     required int indexInGroup,
//   }) {
//     final details = item.details;

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: const Color(0xffF8F8F8),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Column(
//           children: [
//             buildInfoWidget(
//               context: context,
//               isSecondInfo: false,
//               isTextSpan: false,
//               orderGroupId: indexInGroup.toString(),
//               text1:
//                   item.createdAt.date +
//                   ' | ' +
//                   (item.createdAt.time) +
//                   ' | Remain ' +
//                   item.remainingInMinutes.toString() +
//                   'm',
//               text2: '00' + indexInGroup.toString(),
//               svgIcon1: AppAssets.orderClockSvg,
//               svgIcon2: AppAssets.orderBag1Svg,
//               amount: '',
//               currency: '',
//               itemsCount: '',
//             ),
//             const SizedBox(height: 11),
//             buildInfoWidget(
//               context: context,
//               isSecondInfo: true,
//               isTextSpan: true,
//               orderGroupId: item.id.toString(),
//               text1: item.orderStatus,
//               text2: '',
//               svgIcon1: AppAssets.cartCart,
//               svgIcon2: AppAssets.orderInvoice2Svg,
//               secondInfoSvgIcon: AppAssets.pendeingBlackCheck,
//               amount: item.orderAmount.toString(),
//               currency: 'USD',
//               itemsCount: details.length.toString(),
//             ),
//             const SizedBox(height: 11),
//             SizedBox(
//               height: 125,
//               child: ListView.separated(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: details.length,
//                 separatorBuilder: (_, __) => const SizedBox(width: 5),
//                 itemBuilder: (context, index) {
//                   return ClipRRect(
//                     borderRadius: BorderRadius.circular(15),
//                     child: MyCachedNetworkImage(
//                       imageUrl: details[index].cartImage,
//                       width: 91,
//                       height: 125,
//                       imageFit: BoxFit.cover,
//                       radius: 15,
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildInfoWidget({
//     required bool isSecondInfo,
//     required BuildContext context,
//     required String svgIcon1,
//     required String svgIcon2,
//     String? secondInfoSvgIcon,
//     required String orderGroupId,
//     required String text1,
//     required String text2,
//     required bool isTextSpan,
//     required String itemsCount,
//     required String amount,
//     required String currency,
//   }) {
//     return SizedBox(
//       height: 16,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Expanded(
//             child: Row(
//               children: [
//                 svgIcon1 == ""
//                     ? const SizedBox.shrink()
//                     : SvgPicture.asset(svgIcon1, width: 15),
//                 ///////////////////////////
//                 const SizedBox(width: 2),
//                 ///////////////////////////
//                 Flexible(
//                   child: Text(
//                     text1,
//                     overflow: TextOverflow.ellipsis,
//                     style: context.textTheme.bodyMedium?.rq.copyWith(
//                       color: const Color(0xff1D1D1D),
//                       letterSpacing: 0.18,
//                       fontSize: 12,
//                       height: 1.3,
//                     ),
//                   ),
//                 ),
//                 ////////////////////////////
//                 isSecondInfo
//                     ? const SizedBox(width: 5)
//                     : const SizedBox.shrink(),
//                 ///////////////////
//                 isSecondInfo
//                     ? SvgPicture.asset(secondInfoSvgIcon ?? '', width: 15)
//                     : const SizedBox.shrink(),
//               ],
//             ),
//           ),
//           /////////////////////////
//           Expanded(
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 SvgPicture.asset(svgIcon2, width: 15),
//                 ///////////////////////////
//                 const SizedBox(width: 5),
//                 ///////////////////////////
//                 isTextSpan
//                     ? Flexible(
//                         child: RichText(
//                           overflow: TextOverflow.ellipsis,
//                           text: TextSpan(
//                             style: context.textTheme.bodyMedium?.rq.copyWith(
//                               color: const Color(0xff505050),
//                               letterSpacing: 0.18,
//                               fontSize: 12,
//                               height: 1.3,
//                             ),
//                             children: [
//                               TextSpan(
//                                 text: itemsCount,
//                                 style: context.textTheme.bodyMedium?.bq
//                                     .copyWith(
//                                       color: const Color(0xff505050),
//                                       letterSpacing: 0.18,
//                                       fontSize: 12,
//                                       height: 1.3,
//                                     ),
//                               ),
//                               TextSpan(text: ' ${LocaleKeys.item.tr()} . '),
//                               TextSpan(
//                                 text: amount,
//                                 style: context.textTheme.bodyMedium?.bq
//                                     .copyWith(
//                                       color: const Color(0xff505050),
//                                       letterSpacing: 0.18,
//                                       fontSize: 12,
//                                       height: 1.3,
//                                     ),
//                               ),
//                               TextSpan(text: ' $currency'),
//                             ],
//                           ),
//                         ),
//                       )
//                     : Flexible(
//                         child: Text(
//                           text2,
//                           overflow: TextOverflow.ellipsis,
//                           style: context.textTheme.bodyMedium?.rq.copyWith(
//                             color: const Color(0xff1D1D1D),
//                             letterSpacing: 0.18,
//                             fontSize: 12,
//                             height: 1.3,
//                           ),
//                         ),
//                       ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   //////////////////////////////////////////////////////////////////////////////////////////'
//   ///
//   ///////////////////////////////////////////////////
//   Widget _buildPermissionsTab() {
//     if (widget.permissions.isEmpty) {
//       return EmptyStateWidget(
//         message: LocaleKeys.no_permissions_assigned.tr(),
//         icon: Icons.admin_panel_settings_outlined,
//       );
//     }

//     return ListView.builder(
//       padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
//       itemCount: widget.permissions.length,
//       itemBuilder: (context, index) {
//         final permission = widget.permissions[index];
//         return PermissionCard(permissionName: permission);
//       },
//     );
//   }

//   Widget _buildUsersTab() {
//     if (!widget.canAddUser) {
//       return EmptyStateWidget(
//         title: LocaleKeys.access_denied.tr(),
//         message: LocaleKeys.no_permission_to_manage_users.tr(),
//       );
//     }

//     return AddUserWidget(sellerId: widget.sellerId);
//   }

//   Widget _buildStoriesTab() {
//     // if (!_permissionChecker.canSeeStories()) {
//     //   return EmptyStateWidget(
//     //     title: LocaleKeys.access_denied.tr(),
//     //     message: LocaleKeys.no_permissions_assigned.tr(),
//     //   );
//     // }

//     return const SellerStoriesWidget();
//   }
// }

// class _FilterItem {
//   final int index;
//   final IconData icon;
//   final String title;
//   final int count;
//   final bool visible;

//   _FilterItem({
//     required this.index,
//     required this.icon,
//     required this.title,
//     required this.count,
//     required this.visible,
//   });
// }

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:open_file/open_file.dart';
import 'package:trydos/common/constant/design/assets_provider.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/dashBoard/data/models/getExcelCategoriesModel.dart';
import 'package:trydos/features/dashBoard/data/models/get_new_ordersToDashboard.dart';
import 'package:trydos/features/dashBoard/presentation/pages/order_details_page.dart';
import 'package:trydos/features/dashBoard/presentation/widgets/order_status.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/empty_state_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/dashBoard_bloc.dart';
import '../widgets/permission_card.dart';
import '../widgets/add_user_widget.dart';
import '../widgets/products_grid_widget.dart';
import '../widgets/boutiques_grid_widget.dart';
import '../widgets/dashboard_permission_checker.dart';
import '../widgets/seller_stories_widget.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/core/utils/media_display_url.dart';
import 'package:trydos/features/dashBoard/data/models/GetShopInfoModel.dart';

/// -----------------------------------------------------------------------
/// MAIN DASHBOARD PAGE
/// Now this page ONLY shows the header + the list of filter buttons.
/// Tapping a button PUSHES a new page (DashboardContentPage) instead of
/// swapping content below the list.
/// -----------------------------------------------------------------------
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
  late DashboardBloc _dashboardBloc;

  late final DashboardPermissionChecker _permissionChecker;

  @override
  void initState() {
    super.initState();
    _permissionChecker = DashboardPermissionChecker(widget.permissions);
    GetIt.I.get<PrefsRepository>().setXSellerId(widget.sellerId);
    _dashboardBloc = BlocProvider.of<DashboardBloc>(context);
  }

  // Fires the correct fetch event for a given tab index (same logic as before,
  // just triggered right before we push the new page).
  void _loadDataFor(int index) {
    if (index == 0 && widget.canGetProducts) {
      _dashboardBloc.add(GetProductsEvent());
    } else if (index == 1 && widget.canGetBoutiques) {
      _dashboardBloc.add(GetBoutiquesEvent());
    } else if (index == 2 && widget.canGetOrders) {
      _dashboardBloc.add(NewGetOrdersEvent());
    } else if (index == 4 && widget.canAddUser) {
      _dashboardBloc.add(GetUserRolesEvent());
    } else if (index == 5) {
      _dashboardBloc.add(GetSellerStoriesEvent());
    } else if (index == 6) {
      _dashboardBloc.add(GetExcelCategoriesEvent());
    }
  }

  void _openTab(int index, String title) {
    _loadDataFor(index);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: _dashboardBloc,
          child: DashboardContentPage(
            index: index,
            title: title,
            sellerId: widget.sellerId,
            permissions: widget.permissions,
            canAddUser: widget.canAddUser,
          ),
        ),
      ),
    );
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

            // Filter / navigation list — tapping now opens a NEW PAGE
            Expanded(
              child: BlocBuilder<DashboardBloc, DashBoardState>(
                buildWhen: (previous, current) =>
                    previous.getProductsStatus != current.getProductsStatus ||
                    previous.getBoutiquesStatus != current.getBoutiquesStatus ||
                    previous.getOrdersStatus != current.getOrdersStatus ||
                    previous.storiesStatus != current.storiesStatus,
                builder: (context, state) {
                  final int productsCount = state.productsMeta?.total ?? 0;
                  final int boutiquesCount = state.boutiquesMeta?.total ?? 0;
                  final int ordersCount = state.new_orders?.length ?? 0;
                  final int permissionsCount = widget.permissions.length;
                  final int storiesCount = state.stories?.length ?? 0;

                  final items = <_FilterItem>[
                    _FilterItem(
                      index: 0,
                      icon: Icons.view_in_ar_outlined,
                      title: LocaleKeys.products.tr(),
                      subtitle: 'Browse and manage your catalogue',
                      count: productsCount,
                      visible: _permissionChecker.canSeeProducts(),
                    ),
                    _FilterItem(
                      index: 1,
                      icon: Icons.local_offer_outlined,
                      title: LocaleKeys.boutiques.tr(),
                      subtitle: 'Storefronts under this shop',
                      count: boutiquesCount,
                      visible: _permissionChecker.canSeeBoutiques(),
                    ),
                    _FilterItem(
                      index: 2,
                      icon: Icons.assignment_outlined,
                      title: LocaleKeys.orders.tr(),
                      subtitle: 'Track and fulfil customer orders',
                      count: ordersCount,
                      visible: _permissionChecker.canSeeOrders(),
                    ),
                    _FilterItem(
                      index: 3,
                      icon: Icons.gpp_good_outlined,
                      title: LocaleKeys.permissions.tr(),
                      subtitle: 'Review your access in this shop',
                      count: permissionsCount,
                      visible: true,
                    ),
                    _FilterItem(
                      index: 4,
                      icon: Icons.people_outline,
                      title: LocaleKeys.users.tr(),
                      subtitle: 'Manage team members and roles',
                      count: 0,
                      visible: _permissionChecker.canSeeUsers(),
                    ),
                    _FilterItem(
                      index: 5,
                      icon: Icons.auto_stories_outlined,
                      title: LocaleKeys.stories.tr(),
                      subtitle: 'Share photo & video stories',
                      count: storiesCount,
                      visible: true,
                    ),
                    _FilterItem(
                      index: 6,
                      icon: Icons.insert_drive_file_outlined,
                      title: LocaleKeys.upload_excel_file.tr(),
                      subtitle: 'Bulk-import products by template',
                      count: 0,
                      visible: true,
                    ),
                    _FilterItem(
                      index: 7,
                      icon: Icons.storefront_outlined,
                      title: LocaleKeys.shop_information.tr(),
                      subtitle: 'Edit shop name, contact & media',
                      count: 0,
                      visible: true,
                    ),
                    _FilterItem(
                      index: 8,
                      icon: Icons.location_on_outlined,
                      title: LocaleKeys.locations.tr(),
                      subtitle: 'Warehouses and pickup points for this shop',
                      count: 0,
                      visible: true,
                    ),
                    _FilterItem(
                      index: 9,
                      icon: Icons.image_outlined,
                      title: LocaleKeys.gallery.tr(),
                      subtitle: 'Upload and reuse product images',
                      count: 0,
                      visible: true,
                    ),
                    _FilterItem(
                      index: 10,
                      icon: Icons.chat_bubble_outline,
                      title: LocaleKeys.customers_comments.tr(),
                      subtitle: 'Reply to reviews and FAQ',
                      count: 0,
                      visible: true,
                    ),
                  ].where((i) => i.visible).toList();

                  return ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    children: items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: const Color(0xffF7F7F8),
                          borderRadius: BorderRadius.circular(18),
                          child: InkWell(
                            onTap: () => _openTab(item.index, item.title),
                            borderRadius: BorderRadius.circular(18),
                            splashColor: const Color(
                              0xff1D1D1D,
                            ).withValues(alpha: 0.04),
                            highlightColor: const Color(
                              0xff1D1D1D,
                            ).withValues(alpha: 0.02),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                    child: Icon(
                                      item.icon,
                                      size: 21,
                                      color: const Color(0xff1D1D1D),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          item.title,
                                          style: const TextStyle(
                                            fontSize: 14.5,
                                            letterSpacing: -0.2,
                                            color: Color(0xff15171A),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          item.subtitle,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xffA0A0A0),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (item.count > 0) ...[
                                    const SizedBox(width: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xff1D1D1D),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${item.count}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(width: 10),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 14,
                                    color: Color(0xffCBCBCB),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterItem {
  final int index;
  final IconData icon;
  final String title;
  final String subtitle;
  final int count;
  final bool visible;

  _FilterItem({
    required this.index,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.count,
    required this.visible,
  });
}

/// -----------------------------------------------------------------------
/// NEW PAGE: shown after tapping a filter button.
/// Contains exactly the same tab-building logic that used to live inline
/// in DashboardPage, just moved here and opened as its own screen with
/// an AppBar (with a back button automatically provided by Navigator.push).
/// -----------------------------------------------------------------------
class DashboardContentPage extends StatefulWidget {
  final int index;
  final String title;
  final String sellerId;
  final List<String> permissions;
  final bool canAddUser;

  const DashboardContentPage({
    Key? key,
    required this.index,
    required this.title,
    required this.sellerId,
    required this.permissions,
    required this.canAddUser,
  }) : super(key: key);

  @override
  State<DashboardContentPage> createState() => _DashboardContentPageState();
}

class _DashboardContentPageState extends State<DashboardContentPage> {
  late DashboardBloc _dashboardBloc;
  final ValueNotifier<ConstOrderStatus> currentStatusOfOrder = ValueNotifier(
    ConstOrderStatus.all,
  );

  @override
  void initState() {
    super.initState();
    _dashboardBloc = BlocProvider.of<DashboardBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: const Color(0xff1D1D1D),
      ),
      body: SafeArea(child: _buildTabContent()),
    );
  }

  Widget _buildTabContent() {
    switch (widget.index) {
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
      case 5:
        return _buildStoriesTab();
      case 6:
        return const UploadExcelWidget();
      case 7:
        return ShopInfoWidget(permissions: widget.permissions);
      case 8:
        return const LocationsWidget();
      case 9:
        return const GalleryScreen();
      case 10:
        return Center(child: Text(LocaleKeys.customers_comments.tr()));
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

        if (state.products != null && state.products!.isNotEmpty) {
          return BlocBuilder<DashboardBloc, DashBoardState>(
            buildWhen: (previous, current) =>
                previous.productsMeta?.currentPage !=
                    current.productsMeta?.currentPage ||
                previous.getProductsStatus != current.getProductsStatus,
            builder: (context, paginationState) {
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

        if (state.boutiques != null && state.boutiques!.isNotEmpty) {
          return BlocBuilder<DashboardBloc, DashBoardState>(
            buildWhen: (previous, current) =>
                previous.boutiquesMeta?.currentPage !=
                    current.boutiquesMeta?.currentPage ||
                previous.getBoutiquesStatus != current.getBoutiquesStatus,
            builder: (context, paginationState) {
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
                    if (kDebugMode) {
                      print('Selected status: ${_dashboardBloc.ordersStatus}');
                    }
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
                const SizedBox(width: 2),
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
                isSecondInfo
                    ? const SizedBox(width: 5)
                    : const SizedBox.shrink(),
                isSecondInfo
                    ? SvgPicture.asset(secondInfoSvgIcon ?? '', width: 15)
                    : const SizedBox.shrink(),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SvgPicture.asset(svgIcon2, width: 15),
                const SizedBox(width: 5),
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

  Widget _buildStoriesTab() {
    return const SellerStoriesWidget();
  }
}

/// -----------------------------------------------------------------------
/// UPLOAD EXCEL SCREEN
/// -----------------------------------------------------------------------
class UploadExcelWidget extends StatefulWidget {
  const UploadExcelWidget({Key? key}) : super(key: key);

  @override
  State<UploadExcelWidget> createState() => _UploadExcelWidgetState();
}

class _UploadExcelWidgetState extends State<UploadExcelWidget> {
  ExcelCategories? _selectedCategory;
  late DashboardBloc _dashboardBloc;
  String? _pickedFileName;
  bool _isUploading = false;

  // TODO: replace with the real uploaded-files list from your bloc/state.
  // final List<String> _uploadedFiles = const [];

  Future<void> _pickFile() async {
    setState(() {
      _pickedFileName = 'example_file.xlsx';
    });
  }

  void _downloadTemplate() {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Select a category first')));
      return;
    }
    _dashboardBloc.add(
      DownloadExcelTemplateEvent(categoryId: _selectedCategory!.id!),
    );
  }

  Future<void> _uploadFile() async {
    if (_selectedCategory == null || _pickedFileName == null) return;

    setState(() => _isUploading = true);

    // TODO: replace with your real upload call, e.g.:
    // _dashboardBloc.add(UploadExcelEvent(category: _selectedCategory!, filePath: _pickedFilePath));
    await Future.delayed(const Duration(seconds: 1)); // placeholder

    setState(() {
      _isUploading = false;
      _pickedFileName = null;
    });
  }

  void _refreshUploadedFiles() {
    _dashboardBloc.add(GetUploadedExcelFilesEvent());
  }

  @override
  void initState() {
    super.initState();
    _dashboardBloc = BlocProvider.of<DashboardBloc>(context);
    _dashboardBloc.add(GetUploadedExcelFilesEvent());
  }

  @override
  Widget build(BuildContext context) {
    final bool canUpload = _selectedCategory != null && _pickedFileName != null;

    return BlocListener<DashboardBloc, DashBoardState>(
      listenWhen: (previous, current) =>
          previous.downloadExcelTemplateStatus !=
          current.downloadExcelTemplateStatus,
      listener: (context, state) {
        if (state.downloadExcelTemplateStatus ==
            DownloadExcelTemplateStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحميل القالب بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state.downloadExcelTemplateStatus ==
            DownloadExcelTemplateStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('فشل تحميل القالب'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xffEDEDED)),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.description_outlined,
                    size: 36,
                    color: Color(0xff1D1D1D),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Upload Excel File',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff1D1D1D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Pick a category, download its template, fill it in, then upload it.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Color(0xff8D8D8D)),
                  ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Category',
                      style: TextStyle(fontSize: 12, color: Color(0xff8D8D8D)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  BlocBuilder<DashboardBloc, DashBoardState>(
                    buildWhen: (previous, current) =>
                        previous.getExcelCategoriesStatus !=
                            current.getExcelCategoriesStatus ||
                        previous.excelCategoriesModel !=
                            current.excelCategoriesModel,
                    builder: (context, state) {
                      if (state.getExcelCategoriesStatus ==
                          GetExcelCategoriesStatus.loading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state.getExcelCategoriesStatus ==
                          GetExcelCategoriesStatus.failure) {
                        return const Center(
                          child: Text('Failed to load categories'),
                        );
                      }

                      if (state.getExcelCategoriesStatus ==
                          GetExcelCategoriesStatus.success) {
                        // مهم: لا تستخدم !
                        final categories =
                            state.excelCategoriesModel?.data ??
                            <ExcelCategories>[];

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xffF3F3F3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<ExcelCategories>(
                              isExpanded: true,
                              value: categories.contains(_selectedCategory)
                                  ? _selectedCategory
                                  : null,

                              hint: const Text(
                                'Select a category',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xff8D8D8D),
                                ),
                              ),

                              icon: const Icon(Icons.keyboard_arrow_down),

                              items: categories.map((category) {
                                return DropdownMenuItem<ExcelCategories>(
                                  value: category,
                                  child: Text(
                                    category.displayName ?? category.name ?? '',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),

                              onChanged: categories.isEmpty
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _selectedCategory = value;
                                        // _dashboardBloc.add(
                                        //   DownloadExcelTemplateEvent(
                                        //     categoryId: value!.id!,
                                        //   ),
                                        // );
                                      });
                                    },
                            ),
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),

                  const SizedBox(height: 14),

                  BlocBuilder<DashboardBloc, DashBoardState>(
                    buildWhen: (previous, current) =>
                        previous.downloadExcelTemplateStatus !=
                            current.downloadExcelTemplateStatus ||
                        previous.downloadedTemplatePath !=
                            current.downloadedTemplatePath,
                    builder: (context, state) {
                      final bool isLoadingTemplate =
                          state.downloadExcelTemplateStatus ==
                          DownloadExcelTemplateStatus.loading;
                      final bool hasDownloaded =
                          state.downloadExcelTemplateStatus ==
                              DownloadExcelTemplateStatus.success &&
                          state.downloadedTemplatePath != null;

                      return Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed:
                                  _selectedCategory == null || isLoadingTemplate
                                  ? null
                                  : _downloadTemplate,
                              icon: isLoadingTemplate
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.download_outlined,
                                      size: 18,
                                    ),
                              label: Text(
                                isLoadingTemplate
                                    ? 'جاري التحميل...'
                                    : 'Download Template',
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                side: const BorderSide(
                                  color: Color(0xff388CFF),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),

                          if (hasDownloaded) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xffE8F8ED),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(
                                    0xff2ECC71,
                                  ).withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Color(0xff2ECC71),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      state.downloadedTemplatePath!
                                          .split('/')
                                          .last,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xff1D1D1D),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      OpenFile.open(
                                        state.downloadedTemplatePath!,
                                      );
                                    },
                                    child: const Text('فتح الملف'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 14),
                  InkWell(
                    onTap: _pickFile,
                    borderRadius: BorderRadius.circular(12),
                    child: DottedBorderBox(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 28),
                        child: Column(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: Color(0xffEFEFEF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.upload_outlined,
                                color: Color(0xff505050),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _pickedFileName ??
                                  'Drag & drop Excel file here, or click to select',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xff1D1D1D),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Supports .xlsx, .xls, .xlsm, .xlsb',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xffBDBDBD),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: canUpload && !_isUploading
                          ? _uploadFile
                          : null,
                      icon: _isUploading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.upload, size: 18),
                      label: Text(
                        _isUploading ? 'Uploading...' : 'Upload Excel',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canUpload
                            ? const Color(0xff388CFF)
                            : const Color(0xffBDBDBD),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xffEDEDED)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.insert_drive_file_outlined,
                        size: 18,
                        color: Color(0xff388CFF),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Uploaded Excel Files',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xff1D1D1D),
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _refreshUploadedFiles,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Refresh'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  BlocBuilder<DashboardBloc, DashBoardState>(
                    buildWhen: (previous, current) =>
                        previous.getUploadedExcelFilesStatus !=
                            current.getUploadedExcelFilesStatus ||
                        previous.uploadedExcelFilesModel !=
                            current.uploadedExcelFilesModel,
                    builder: (context, state) {
                      if (state.getUploadedExcelFilesStatus ==
                          GetUploadedExcelFilesStatus.loading) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (state.getUploadedExcelFilesStatus ==
                          GetUploadedExcelFilesStatus.failure) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'فشل تحميل قائمة الملفات',
                            style: TextStyle(color: Colors.red),
                          ),
                        );
                      }

                      final files = state.uploadedExcelFilesModel?.data ?? [];

                      if (files.isEmpty) {
                        return Column(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: Color(0xffEFEFEF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.insert_drive_file_outlined,
                                color: Color(0xffBDBDBD),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'No files uploaded yet.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xff8D8D8D),
                              ),
                            ),
                          ],
                        );
                      }

                      return Column(
                        children: files.map((f) {
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(
                              Icons.insert_drive_file_outlined,
                              color: Color(0xff388CFF),
                            ),
                            title: Text(
                              f.fileName ?? 'ملف بدون اسم',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: f.createdAt != null
                                ? Text(f.createdAt!)
                                : null,
                            trailing: f.status != null
                                ? Text(
                                    f.status!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xff8D8D8D),
                                    ),
                                  )
                                : null,
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple dashed-border container used for the drag & drop area (no external package needed).
class DottedBorderBox extends StatelessWidget {
  final Widget child;
  const DottedBorderBox({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _DashedBorderPainter(), child: child);
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xffBDBDBD)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const double dashWidth = 6;
    const double dashSpace = 4;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(12),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// -----------------------------------------------------------------------
/// LOCATIONS SCREEN
/// Matches the requested design:
///  - Header: pin icon + "Locations" + count badge
///  - "Add Location" button top-right
///  - "All statuses" dropdown filter
///  - List of location cards: icon, name, status badge, subtitle,
///    country tag, Edit / Deactivate buttons
///
/// NOTE ON WIRING THIS UP:
///   - `_locations`     -> replace with the real list from your bloc/state
///                         (e.g. state.locations).
///   - `_statusFilter`  -> wire to your real status enum / filter logic.
///   - `_onAddLocation` -> open your real "add location" page/dialog.
///   - `_onEdit`        -> open your real "edit location" page/dialog.
///   - `_onDeactivate`  -> dispatch your real deactivate bloc event.
/// -----------------------------------------------------------------------
class LocationModel {
  final String id;
  final String name;
  final String subtitle;
  final String country;
  final bool isActive;

  LocationModel({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.country,
    required this.isActive,
  });
}

class LocationsWidget extends StatefulWidget {
  const LocationsWidget({Key? key}) : super(key: key);

  @override
  State<LocationsWidget> createState() => _LocationsWidgetState();
}

class _LocationsWidgetState extends State<LocationsWidget> {
  // TODO: replace with the real list coming from your bloc/state.
  final List<LocationModel> _locations = [
    LocationModel(
      id: '1',
      name: 'A',
      subtitle: 'A',
      country: 'Syrian Arab Republic',
      isActive: true,
    ),
  ];

  String _statusFilter = 'All statuses';
  final List<String> _statusOptions = const [
    'All statuses',
    'Active',
    'Inactive',
  ];

  List<LocationModel> get _filteredLocations {
    if (_statusFilter == 'All statuses') return _locations;
    final wantActive = _statusFilter == 'Active';
    return _locations.where((l) => l.isActive == wantActive).toList();
  }

  void _onAddLocation() {
    // TODO: navigate to / open the real "Add Location" page or dialog.
  }

  void _onEdit(LocationModel location) {
    // TODO: navigate to / open the real "Edit Location" page or dialog.
  }

  void _onDeactivate(LocationModel location) {
    // TODO: dispatch your real deactivate/activate bloc event, e.g.:
    // _dashboardBloc.add(ToggleLocationStatusEvent(id: location.id));
    setState(() {
      final index = _locations.indexWhere((l) => l.id == location.id);
      if (index != -1) {
        _locations[index] = LocationModel(
          id: location.id,
          name: location.name,
          subtitle: location.subtitle,
          country: location.country,
          isActive: !location.isActive,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 20,
                color: Color(0xff1D1D1D),
              ),
              const SizedBox(width: 8),
              const Text(
                'Locations',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff1D1D1D),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xffEFEFEF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_locations.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xff505050),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _onAddLocation,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Location'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff3D3D3D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Status filter dropdown
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xffEDEDED)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _statusFilter,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: _statusOptions
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(
                            s,
                            style: const TextStyle(color: Color(0xff5B5FEB)),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _statusFilter = value);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Locations list
          Expanded(
            child: _filteredLocations.isEmpty
                ? const Center(
                    child: Text(
                      'No locations found',
                      style: TextStyle(color: Color(0xff8D8D8D)),
                    ),
                  )
                : ListView.separated(
                    itemCount: _filteredLocations.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final location = _filteredLocations[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xffEDEDED)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xffF3F3F3),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.location_on_outlined,
                                    color: Color(0xff505050),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            location.name,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xff1D1D1D),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: location.isActive
                                                  ? const Color(0xffE6F7EC)
                                                  : const Color(0xffF3F3F3),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              location.isActive
                                                  ? 'Active'
                                                  : 'Inactive',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: location.isActive
                                                    ? const Color(0xff2E9E5B)
                                                    : const Color(0xff8D8D8D),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        location.subtitle,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xffBDBDBD),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xffEFF4FF),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 12,
                                      color: Color(0xff388CFF),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      location.country,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xff388CFF),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Divider(height: 1, color: Color(0xffEDEDED)),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => _onEdit(location),
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 16,
                                    color: Color(0xff388CFF),
                                  ),
                                  label: const Text(
                                    'Edit',
                                    style: TextStyle(color: Color(0xff388CFF)),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: Color(0xff388CFF),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                TextButton(
                                  onPressed: () => _onDeactivate(location),
                                  style: TextButton.styleFrom(
                                    backgroundColor: const Color(0xffFCEAEA),
                                    foregroundColor: const Color(0xffE05B5B),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                  ),
                                  child: Text(
                                    location.isActive
                                        ? 'Deactivate'
                                        : 'Activate',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// -----------------------------------------------------------------------
/// EDIT SHOP INFO SCREEN
/// Matches the requested design:
///  - Title: store icon + "Edit Shop Info"
///  - Left column: Shop Name, Contact (+ helper text), Address (multiline)
///  - Right column: Shop Logo preview + "Change" button
///  - Below: Shop Banner (ratio label) preview + "Change Banner" button
///  - Divider + "Save Changes" button bottom-right
///
/// NOTE ON WIRING THIS UP:
///   - Prefill the controllers with the real shop data (from bloc/state).
///   - `_pickLogo` / `_pickBanner` -> use `file_picker` or `image_picker`
///     to actually pick an image, then upload it.
///   - `_saveChanges` -> dispatch your real "update shop info" bloc event
///     with the controller values + picked images.
/// -----------------------------------------------------------------------
/// شاشة "معلومات المتجر": قراءة وتعديل الملف العام للمتجر.
///
/// الصلاحيات تصل كمعامل بانٍ لا من الـ bloc: هي لقطة مجمّدة منذ اختيار
/// المتجر، وتصل هنا عبر `DashboardContentPage.permissions`.
class ShopInfoWidget extends StatefulWidget {
  final List<String> permissions;

  const ShopInfoWidget({Key? key, required this.permissions}) : super(key: key);

  @override
  State<ShopInfoWidget> createState() => _ShopInfoWidgetState();
}

class _ShopInfoWidgetState extends State<ShopInfoWidget> {
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final DashboardPermissionChecker _permissionChecker =
      DashboardPermissionChecker(widget.permissions);

  /// معاينة محلية لما اختير قبل الحفظ: لا يُعاد تنزيل ما رُفِع للتوّ.
  File? _pickedLogo;
  File? _pickedBanner;

  /// سقف حجم الملف المرفوع. رفضٌ لا تصغير: لا يوجد مسار ضغط في
  /// المشروع (`flutter_image_compress` مُعطّل في `pubspec.yaml`). الرقم نفسه
  /// المستعمل للستوري (`_kMaxStoryFileBytes`) فيُعاد استعمال رسالته.
  static const int _kMaxShopMediaBytes = 10 * 1024 * 1024;

  /// عرض الفكّ للمعاينة المحلية: حجم الملف لا يحدّ حجم الفكّ في
  /// الذاكرة، فصورة 4 ميغا قد تفكّ إلى عشرات الميغابايت.
  static const int _kPreviewDecodeWidth = 600;

  /// المتجر الذي فُتِحت الشاشة عليه.
  String? _sellerIdAtOpen;

  bool get _canRead => _permissionChecker.canReadShopInfo();

  bool get _canUpdate => _permissionChecker.canUpdateShopInfo();

  @override
  void initState() {
    super.initState();
    _sellerIdAtOpen = GetIt.I<PrefsRepository>().getXSellerId;

    // مرّة واحدة عند الفتح — ليس في `build`، وإلا أُطلِق الحدث مع كل إعادة بناء.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final DashboardBloc bloc = context.read<DashboardBloc>();
      final String? loadedFor = bloc.state.shopInfo.loadedForSellerId;

      // سجلّ يخصّ متجراً آخر: يُمسح قبل أن يُعرض أي شيء.
      if (loadedFor != null && loadedFor != _sellerIdAtOpen) {
        bloc.add(ClearShopInfoEvent());
      }
      bloc.add(GetShopInfoEvent(canRead: _canRead));
    });
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  /// التعبئة تتمّ من `BlocListener` عند تغيّر حالة التحميل فقط.
  /// كتابة `controller.text` داخل `builder` تمسح ما يكتبه المستخدم
  /// مع كل إصدار من أي تبويب آخر، لأن الحالة مشتركة.
  void _prefill(GetShopInfoModel info) {
    _shopNameController.text = info.name ?? '';
    _contactController.text = info.contact ?? '';
    _addressController.text = info.address ?? '';
  }

  Future<File?> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      // بلا قراءة البايتات إلى الذاكرة: `size` متاح بدونها،
      // فيقع فحص الحجم قبل تحميل أي شيء.
      withData: false,
    );
    if (result == null || result.files.isEmpty) return null;

    final PlatformFile picked = result.files.single;
    if (picked.path == null) return null;

    if (picked.size > _kMaxShopMediaBytes) {
      showMessage(
        LocaleKeys.photo_or_video_up_to_10mb.tr(),
        hasError: true,
        context: context,
      );
      return null;
    }
    return File(picked.path!);
  }

  Future<void> _pickLogo() async {
    final File? file = await _pickImage();
    if (file == null || !mounted) return;
    setState(() => _pickedLogo = file);
    context.read<DashboardBloc>().add(
      UploadShopMediaEvent(file: file, isBanner: false),
    );
  }

  Future<void> _pickBanner() async {
    final File? file = await _pickImage();
    if (file == null || !mounted) return;
    setState(() => _pickedBanner = file);
    context.read<DashboardBloc>().add(
      UploadShopMediaEvent(file: file, isBanner: true),
    );
  }

  void _saveChanges(GetShopInfoModel info) {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<DashboardBloc>().add(
      UpdateShopInfoEvent(
        name: _shopNameController.text.trim(),
        address: _addressController.text.trim(),
        contact: _contactController.text.trim(),
        image: info.image,
        banner: info.banner,
        expectedSellerId: info.loadedForSellerId ?? _sellerIdAtOpen,
      ),
    );
  }

  Widget _fieldLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(fontSize: 12, color: Color(0xff8D8D8D)),
    ),
  );

  InputDecoration _fieldDecoration({String? hint}) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: const Color(0xffF3F3F3),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
  );

  String? _requiredValidator(String? value, String message) {
    if ((value ?? '').trim().isEmpty) return message;
    return null;
  }

  String? _contactValidator(String? value) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) return LocaleKeys.shop_info_contact_required.tr();
    // نفس قاعدة عميل الويب: أرقام مع `+` اختيارية في البداية، بلا فحص طول.
    if (!RegExp(r'^\+?\d+$').hasMatch(text)) {
      return LocaleKeys.shop_info_contact_invalid.tr();
    }
    return null;
  }

  /// معاينة محلية لملف مختار، وإلا صورة الخادم عبر المخبأ المشترك.
  Widget _imageBox({
    required File? localFile,
    required String? storedValue,
    double width = 100,
    double height = 100,
  }) {
    final BorderRadius radius = BorderRadius.circular(10);
    Widget child = const SizedBox.shrink();

    if (localFile != null) {
      child = Image.file(
        localFile,
        width: width,
        height: height,
        fit: BoxFit.cover,
        // يحدّ ذاكرة الفكّ، وإلا فُكّت صورة كاملة لمربّع صغير.
        cacheWidth: _kPreviewDecodeWidth,
      );
    } else if (storedValue != null && storedValue.trim().isNotEmpty) {
      child = MyCachedNetworkImage(
        imageUrl: mediaDisplayUrl(storedValue, legacyFolder: 'seller'),
        width: width,
        height: height,
        imageFit: BoxFit.cover,
      );
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xffF3F3F3),
        borderRadius: radius,
      ),
      child: ClipRRect(borderRadius: radius, child: child),
    );
  }

  Widget _outlinedIconButton({
    required String label,
    required VoidCallback? onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(
        Icons.upload_outlined,
        size: 16,
        color: onTap == null ? Colors.grey : const Color(0xff388CFF),
      ),
      label: Text(
        label,
        style: TextStyle(
          color: onTap == null ? Colors.grey : const Color(0xff388CFF),
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: onTap == null ? Colors.grey : const Color(0xff388CFF),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// رسالة منع الصلاحية: بلا دوّارة وبلا زرّ إعادة محاولة، لأن الإعادة
  /// لا يمكن أن تنجح.
  Widget _permissionDenied() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_outline, size: 40, color: Color(0xff8D8D8D)),
          const SizedBox(height: 12),
          Text(
            LocaleKeys.shop_info_no_read_permission.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Color(0xff8D8D8D)),
          ),
        ],
      ),
    ),
  );

  Widget _loadFailed(String? message) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message ?? LocaleKeys.something_went_wrong.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Color(0xff8D8D8D)),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => context.read<DashboardBloc>().add(
              GetShopInfoEvent(canRead: _canRead),
            ),
            child: Text(LocaleKeys.try_again.tr()),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardBloc, DashBoardState>(
      // الحالة مشتركة مع كل التبويبات، فنحدّ الإصغاء وإعادة البناء بحقول هذه
      // الشاشة وحدها.
      listenWhen: (previous, current) =>
          previous.getShopInfoStatus != current.getShopInfoStatus,
      listener: (context, state) {
        if (state.getShopInfoStatus == GetShopInfoStatus.success) {
          _prefill(state.shopInfo);
        }
      },
      buildWhen: (previous, current) =>
          previous.getShopInfoStatus != current.getShopInfoStatus ||
          previous.updateShopInfoStatus != current.updateShopInfoStatus ||
          previous.uploadShopMediaStatus != current.uploadShopMediaStatus ||
          previous.shopInfo != current.shopInfo ||
          previous.shopInfoMessage != current.shopInfoMessage,
      builder: (context, state) {
        if (state.getShopInfoStatus == GetShopInfoStatus.permissionDenied) {
          return _permissionDenied();
        }
        if (state.getShopInfoStatus == GetShopInfoStatus.loading ||
            state.getShopInfoStatus == GetShopInfoStatus.init) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.getShopInfoStatus == GetShopInfoStatus.failure) {
          return _loadFailed(state.shopInfoMessage);
        }

        final GetShopInfoModel info = state.shopInfo;
        final bool isSaving =
            state.updateShopInfoStatus == UpdateShopInfoStatus.loading;
        final bool isUploading =
            state.uploadShopMediaStatus == UploadShopMediaStatus.uploading;
        // لا حفظ قبل تحميل ناجح للمتجر الحالي: حفظ مبنيّ على تحميل
        // فاشل يمسح الشعار والغلاف الحيّين (AC-28).
        final bool canSave =
            _canUpdate && !isSaving && !isUploading && !info.isEmpty;

        return Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.storefront_outlined,
                      size: 18,
                      color: Color(0xff1D1D1D),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      LocaleKeys.shop_info_edit_title.tr(),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff1D1D1D),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isWide = constraints.maxWidth > 600;
                    final Widget left = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel(LocaleKeys.shop_name.tr()),
                        TextFormField(
                          controller: _shopNameController,
                          enabled: _canUpdate,
                          decoration: _fieldDecoration(),
                          validator: (v) => _requiredValidator(
                            v,
                            LocaleKeys.shop_name_is_required.tr(),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _fieldLabel(LocaleKeys.shop_info_contact.tr()),
                        TextFormField(
                          controller: _contactController,
                          enabled: _canUpdate,
                          keyboardType: TextInputType.phone,
                          decoration: _fieldDecoration(),
                          validator: _contactValidator,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          LocaleKeys.shop_info_country_code_hint.tr(),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xffE0A45B),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _fieldLabel(LocaleKeys.shop_info_address.tr()),
                        TextFormField(
                          controller: _addressController,
                          enabled: _canUpdate,
                          maxLines: 3,
                          decoration: _fieldDecoration(),
                          validator: (v) => _requiredValidator(
                            v,
                            LocaleKeys.shop_info_address_required.tr(),
                          ),
                        ),
                      ],
                    );

                    final Widget right = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel(LocaleKeys.shop_info_logo.tr()),
                        Row(
                          children: [
                            _imageBox(
                              localFile: _pickedLogo,
                              storedValue: info.image,
                            ),
                            const SizedBox(width: 12),
                            _outlinedIconButton(
                              label: LocaleKeys.shop_info_change.tr(),
                              onTap: (_canUpdate && !isUploading)
                                  ? _pickLogo
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    );

                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: left),
                          const SizedBox(width: 32),
                          Expanded(child: right),
                        ],
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [left, const SizedBox(height: 24), right],
                    );
                  },
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    _fieldLabel(LocaleKeys.shop_info_banner.tr()),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        LocaleKeys.shop_info_banner_ratio.tr(),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xff388CFF),
                        ),
                      ),
                    ),
                  ],
                ),
                _imageBox(
                  localFile: _pickedBanner,
                  storedValue: info.banner,
                  width: double.infinity,
                  height: 140,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: _outlinedIconButton(
                    label: LocaleKeys.shop_info_change_banner.tr(),
                    onTap: (_canUpdate && !isUploading) ? _pickBanner : null,
                  ),
                ),

                if (isUploading) ...[
                  const SizedBox(height: 12),
                  const LinearProgressIndicator(minHeight: 2),
                ],

                if (!_canUpdate) ...[
                  const SizedBox(height: 16),
                  Text(
                    LocaleKeys.shop_info_no_update_permission.tr(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xff8D8D8D),
                    ),
                  ),
                ],

                const SizedBox(height: 24),
                const Divider(height: 1, color: Color(0xffEDEDED)),
                const SizedBox(height: 16),

                if (_canUpdate)
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: ElevatedButton.icon(
                      onPressed: canSave ? () => _saveChanges(info) : null,
                      icon: isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check, size: 16),
                      label: Text(
                        isSaving
                            ? LocaleKeys.shop_info_saving.tr()
                            : LocaleKeys.shop_info_save_changes.tr(),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff3D3D3D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class GalleryScreen extends StatefulWidget {
  final int? productId;

  const GalleryScreen({super.key, this.productId});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final List<_GalleryImage> _localUploads = [];
  bool _isDragging = false;

  bool _selectionMode = false;
  final Set<int> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _fetchUploadedImages();
  }

  // ---------------------------------------------------------------------
  // جلب الصور المرفوعة سابقاً
  // ---------------------------------------------------------------------
  void _fetchUploadedImages({int page = 1}) {
    context.read<DashboardBloc>().add(
      GetGalleryImagesEvent(page: page, perPage: 20),
    );
  }

  // ---------------------------------------------------------------------
  // اختيار ملفات (صور فردية أو متعددة)
  // ---------------------------------------------------------------------
  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result == null || result.files.isEmpty) return;

    final paths = result.files
        .where((f) => f.path != null)
        .map((f) => f.path!)
        .toList();

    await _uploadPaths(paths);
  }

  // ---------------------------------------------------------------------
  // اختيار مجلد كامل (سطح المكتب / الويب فقط — غير مدعوم على الموبايل)
  // ---------------------------------------------------------------------
  Future<void> _pickFolder() async {
    final dirPath = await FilePicker.platform.getDirectoryPath();
    if (dirPath == null) return;

    final dir = Directory(dirPath);
    if (!dir.existsSync()) return;

    const imageExtensions = {'.jpg', '.jpeg', '.png', '.webp', '.gif'};

    final imagePaths = dir
        .listSync()
        .whereType<File>()
        .where((f) {
          final ext = f.path.split('.').last.toLowerCase();
          return imageExtensions.contains('.$ext');
        })
        .map((f) => f.path)
        .toList();

    if (imagePaths.isEmpty) {
      _showSnack('لا توجد صور داخل هذا المجلد');
      return;
    }

    await _uploadPaths(imagePaths);
  }

  // ---------------------------------------------------------------------
  // منطق الرفع الفعلي — مربوط بـ DashboardBloc الموجود
  // ---------------------------------------------------------------------
  Future<void> _uploadPaths(List<String> paths) async {
    for (final path in paths) {
      final placeholder = _GalleryImage.local(
        localPath: path,
        status: _UploadStatus.uploading,
      );

      setState(() => _localUploads.insert(0, placeholder));

      final mimeType = _guessMimeType(path);

      context.read<DashboardBloc>().add(
        UploadDocumentEvent(filePath: path, mimeType: mimeType),
      );
    }
  }

  String _guessMimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ---------------------------------------------------------------------
  // وضع التحديد والحذف
  // ---------------------------------------------------------------------
  void _enterSelectionMode(int id) {
    setState(() {
      _selectionMode = true;
      _selectedIds.add(id);
    });
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
      if (_selectedIds.isEmpty) _selectionMode = false;
    });
  }

  void _cancelSelection() {
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  Future<void> _confirmDeleteSelected() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الصور'),
        content: Text('هل تريد حذف ${_selectedIds.length} صورة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    context.read<DashboardBloc>().add(
      DeleteGalleryImagesEvent(ids: _selectedIds.toList()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DashboardBloc, DashBoardState>(
      listenWhen: (previous, current) =>
          previous.uploadDocumentStatus != current.uploadDocumentStatus ||
          previous.getGalleryImagesStatus != current.getGalleryImagesStatus ||
          previous.deleteGalleryImagesStatus !=
              current.deleteGalleryImagesStatus,
      listener: (context, state) {
        // ---- رفع صورة جديدة ----
        if (state.uploadDocumentStatus == UploadDocumentStatus.success) {
          setState(() {
            final idx = _localUploads.indexWhere(
              (img) => img.status == _UploadStatus.uploading,
            );
            if (idx != -1) {
              _localUploads[idx] = _localUploads[idx].copyWith(
                status: _UploadStatus.done,
              );
            }
          });
          // بعد نجاح الرفع الفعلي (S3)، يفترض استدعاء Save endpoint
          // (`POST /shop/products/images`) ثم إعادة الجلب. إذا كان هذا
          // الاستدعاء غير موجود بعد بالـ Bloc، أخبرني لأضيفه كخطوة تالية.
          _fetchUploadedImages();
        } else if (state.uploadDocumentStatus == UploadDocumentStatus.failure) {
          setState(() {
            final idx = _localUploads.indexWhere(
              (img) => img.status == _UploadStatus.uploading,
            );
            if (idx != -1) {
              _localUploads[idx] = _localUploads[idx].copyWith(
                status: _UploadStatus.failed,
              );
            }
          });
          _showSnack('فشل رفع إحدى الصور');
        }

        // ---- جلب الصور ----
        if (state.getGalleryImagesStatus == GetGalleryImagesStatus.failure) {
          _showSnack('فشل تحميل الصور');
        }

        // ---- حذف الصور ----
        if (state.deleteGalleryImagesStatus ==
            DeleteGalleryImagesStatus.success) {
          _showSnack('تم حذف الصور بنجاح');
          _cancelSelection();
        } else if (state.deleteGalleryImagesStatus ==
            DeleteGalleryImagesStatus.failure) {
          _showSnack('فشل حذف الصور');
        }
      },
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_selectionMode) ...[
                _buildDropZone(),
                const SizedBox(height: 24),
              ],
              _buildImagesSection(),
            ],
          ),
        ),
      ),
    );
  }

 
  // ---------------------------------------------------------------------
  // منطقة السحب والإفلات + الأزرار (حسب التصميم المرسل)
  // ---------------------------------------------------------------------
  Widget _buildDropZone() {
    return DragTarget<Object>(
      onWillAcceptWithDetails: (_) {
        setState(() => _isDragging = true);
        return true;
      },
      onLeave: (_) => setState(() => _isDragging = false),
      onAcceptWithDetails: (_) => setState(() => _isDragging = false),
      builder: (context, candidateData, rejectedData) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 40),
          decoration: BoxDecoration(
            color: _isDragging ? Colors.grey.shade100 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1.5,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Icon(Icons.file_upload_outlined, size: 26),
              ),
              const SizedBox(height: 16),
              const Text(
                'Drop images here',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'or choose files / folder',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickFiles,
                    icon: const Icon(Icons.file_upload_outlined, size: 18),
                    label: const Text('Select Files'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade800,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: _pickFolder,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Select Folder'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------
  // شبكة عرض الصور (المرفوعة سابقاً من السيرفر + الجاري رفعها محلياً)
  // ---------------------------------------------------------------------
  Widget _buildImagesSection() {
    return BlocBuilder<DashboardBloc, DashBoardState>(
      buildWhen: (previous, current) =>
          previous.getGalleryImagesStatus != current.getGalleryImagesStatus ||
          previous.galleryImages != current.galleryImages,
      builder: (context, state) {
        final isLoading =
            state.getGalleryImagesStatus == GetGalleryImagesStatus.loading &&
            (state.galleryImages == null || state.galleryImages!.isEmpty);

        if (isLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 60),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final remoteImages = (state.galleryImages ?? [])
            .map((m) => _GalleryImage.remote(id: m.id, url: m.url))
            .toList();

        // الجديدة الجاري رفعها تظهر أولاً، ثم الموجودة مسبقاً بالسيرفر
        final allImages = [..._localUploads, ...remoteImages];

        if (allImages.isEmpty) {
          return Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.image_outlined,
                  color: Colors.grey.shade400,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No images found',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Uploaded product images will appear here.',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
            ],
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: allImages.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) => _buildImageTile(allImages[index]),
        );
      },
    );
  }

  Widget _buildImageTile(_GalleryImage image) {
    final isSelectable = image.isRemote && image.id != null;
    final isSelected = isSelectable && _selectedIds.contains(image.id);

    return GestureDetector(
      onLongPress: isSelectable ? () => _enterSelectionMode(image.id!) : null,
      onTap: _selectionMode && isSelectable
          ? () => _toggleSelection(image.id!)
          : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildImageContent(image),
            if (image.status == _UploadStatus.uploading)
              Container(
                color: Colors.black.withOpacity(0.4),
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            if (image.status == _UploadStatus.failed)
              Container(
                color: Colors.red.withOpacity(0.4),
                child: const Center(
                  child: Icon(Icons.error_outline, color: Colors.white),
                ),
              ),
            if (isSelected)
              Container(
                color: Colors.black.withOpacity(0.3),
                alignment: Alignment.topRight,
                padding: const EdgeInsets.all(6),
                child: const CircleAvatar(
                  radius: 11,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.check, size: 14, color: Colors.white),
                ),
              )
            else if (isSelectable)
              Container(
                alignment: Alignment.topRight,
                padding: const EdgeInsets.all(6),
                child: CircleAvatar(
                  radius: 11,
                  backgroundColor: Colors.white.withOpacity(0.7),
                  child: Icon(
                    Icons.circle_outlined,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageContent(_GalleryImage image) {
    if (image.isRemote) {
      return Image.network(
        image.url ?? '',
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: Colors.grey.shade100,
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey.shade200,
          child: const Icon(Icons.broken_image_outlined),
        ),
      );
    }

    return Image.file(
      File(image.localPath!),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: Colors.grey.shade200,
        child: const Icon(Icons.broken_image_outlined),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// نموذج بيانات موحّد: يمثّل صورة محلية (جاري رفعها) أو صورة بعيدة (موجودة)
// ---------------------------------------------------------------------
enum _UploadStatus { none, uploading, done, failed }

class _GalleryImage {
  final bool isRemote;
  final int? id; // موجود فقط للصور البعيدة (نحتاجه للحذف)
  final String? url; // للصور البعيدة
  final String? localPath; // للصور المحلية الجاري رفعها
  final _UploadStatus status;

  const _GalleryImage._({
    required this.isRemote,
    this.id,
    this.url,
    this.localPath,
    this.status = _UploadStatus.none,
  });

  factory _GalleryImage.local({
    required String localPath,
    required _UploadStatus status,
  }) {
    return _GalleryImage._(
      isRemote: false,
      localPath: localPath,
      status: status,
    );
  }

  factory _GalleryImage.remote({required int id, String? url}) {
    return _GalleryImage._(
      isRemote: true,
      id: id,
      url: url,
      status: _UploadStatus.done,
    );
  }

  _GalleryImage copyWith({_UploadStatus? status}) {
    return _GalleryImage._(
      isRemote: isRemote,
      id: id,
      url: url,
      localPath: localPath,
      status: status ?? this.status,
    );
  }
}
