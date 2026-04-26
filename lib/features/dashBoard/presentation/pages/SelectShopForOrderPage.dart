import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/dashBoard/presentation/pages/main_orders_page.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../data/models/get_user_permission_model.dart';
import '../bloc/dashBoard_bloc.dart';

class SelectShopForOrderPage extends StatefulWidget {
  const SelectShopForOrderPage({Key? key}) : super(key: key);

  @override
  State<SelectShopForOrderPage> createState() => _SelectShopPageState();
}

class _SelectShopPageState extends State<SelectShopForOrderPage> {
  late DashboardBloc dashboardBloc;
  @override
  void initState() {
    super.initState();
    dashboardBloc = context.read<DashboardBloc>();
    //dashboardBloc.add(GetUserPermissionEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9FAFB),
      appBar: AppBar(
        title: Text(
          LocaleKeys.select_shop.tr(),
          style: TextStyle(
            color: const Color(0xff111827),
            fontWeight: FontWeight.w800,
            fontSize: 20.sp,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xff111827)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          dashboardBloc.add(GetUserPermissionEvent());
        },
        child: BlocBuilder<DashboardBloc, DashBoardState>(
          builder: (context, state) {
            if (state.getUserPermissionStatus ==
                GetUserPermissionStatus.loading) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  height: 0.8.sh,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(color: Colors.blue),
                ),
              );
            }

            if (state.getUserPermissionStatus ==
                GetUserPermissionStatus.failure) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  height: 0.8.sh,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.error_outline,
                          size: 48.w,
                          color: Colors.red.shade400,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        LocaleKeys.failed_load_shops.tr(),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff374151),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        LocaleKeys.check_internet_connection.tr(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xff6B7280),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      ElevatedButton(
                        onPressed: () =>
                            dashboardBloc.add(GetUserPermissionEvent()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 32.w,
                            vertical: 12.h,
                          ),
                        ),
                        child: Text(
                          LocaleKeys.try_again.tr(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final shops = state.shops ?? [];

            if (shops.isEmpty &&
                state.getUserPermissionStatus ==
                    GetUserPermissionStatus.success) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  height: 0.8.sh,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.storefront_outlined,
                        size: 60.w,
                        color: Colors.grey.shade300,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        LocaleKeys.no_boutiques_found.tr(),
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    LocaleKeys.please_select_a_shop.tr(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: const Color(0xff111827),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  // Table
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Table Header
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12.r),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  LocaleKeys.shop_name.tr(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  LocaleKeys.seller_id.tr(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  LocaleKeys.actions.tr(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Table Rows
                        ...shops.asMap().entries.map((entry) {
                          final index = entry.key;
                          final shop = entry.value;
                          return _buildShopRow(
                            context,
                            shop,
                            index == shops.length - 1,
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildShopRow(BuildContext context, Shop shop, bool isLast) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              shop.shopName ?? 'Unknown Shop',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.black87),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            flex: 2,
            child: Text(
              shop.sellerId?.toString() ?? '0',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.black87),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                // Enter Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      GetIt.I.get<PrefsRepository>().setXSellerId(
                        shop.sellerId!.toString(),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainOrdersPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3366FF),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      minimumSize: Size(0, 36.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      LocaleKeys.enter_button.tr(),
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                // Leave Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _showLeaveShopConfirmation(context, shop);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      minimumSize: Size(0, 36.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.r),
                        side: BorderSide(color: Colors.red.shade200),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      LocaleKeys.leave_button.tr(),
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                      ),
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

  void _showLeaveShopConfirmation(BuildContext context, Shop shop) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            LocaleKeys.confirm_leave_shop_title.tr(),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          content: Text(
            LocaleKeys.confirm_leave_shop_message.tr(),
            style: TextStyle(fontSize: 14.sp, color: Colors.black54),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                LocaleKeys.cancel.tr(),
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                dashboardBloc.add(LeaveShopEvent());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                LocaleKeys.confirm.tr(),
                style: TextStyle(fontSize: 14.sp, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
