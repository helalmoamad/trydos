import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../data/models/get_user_permission_model.dart';
import '../bloc/dashBoard_bloc.dart';
import 'dashboard_page.dart';

class SelectShopPage extends StatefulWidget {
  const SelectShopPage({Key? key}) : super(key: key);

  @override
  State<SelectShopPage> createState() => _SelectShopPageState();
}

class _SelectShopPageState extends State<SelectShopPage> {
  late DashboardBloc dashboardBloc;
  @override
  void initState() {
    super.initState();
    dashboardBloc = context.read<DashboardBloc>();
    dashboardBloc.add(GetUserPermissionEvent());
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

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.all(24.w),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LocaleKeys.please_select_a_shop.tr(),
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: const Color(0xff4B5563),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          width: 40.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade400,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: _buildShopCard(context, shops[index]),
                      );
                    }, childCount: shops.length),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildShopCard(BuildContext context, Shop shop) {
    return Hero(
      tag: 'shop_${shop.sellerId}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DashboardPage(
                  shopName: shop.shopName ?? '',
                  sellerId: shop.sellerId?.toString() ?? '0',
                  permissions: shop.permissions ?? [],
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20.r),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.blue.shade900.withOpacity(0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    top: -20,
                    child: CircleAvatar(
                      radius: 50,
                      // ignore: deprecated_member_use
                      backgroundColor: Colors.blue.shade50.withOpacity(0.3),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Row(
                      children: [
                        Container(
                          width: 64.w,
                          height: 64.w,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade400,
                                Colors.blue.shade600,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18.r),
                            boxShadow: [
                              BoxShadow(
                                // ignore: deprecated_member_use
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.store_rounded,
                            color: Colors.white,
                            size: 32.w,
                          ),
                        ),
                        SizedBox(width: 18.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                shop.shopName ?? 'Unknown Shop',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xff111827),
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.badge_outlined,
                                    size: 14.w,
                                    color: Colors.grey.shade400,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '${LocaleKeys.seller_id.tr()}: ${shop.sellerId}',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: const Color(0xff6B7280),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.grey.shade400,
                            size: 14.w,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
