import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../generated/locale_keys.g.dart';

class DashboardTabBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;
  final int productsCount;
  final int boutiquesCount;
  final int ordersCount;
  final int permissionsCount;

  const DashboardTabBar({
    Key? key,
    required this.selectedIndex,
    required this.onTabSelected,
    this.productsCount = 0,
    this.boutiquesCount = 0,
    this.ordersCount = 0,
    this.permissionsCount = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      height: 60.h,
      margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        children: [
          _buildTab(
            context,
            index: 0,
            title: LocaleKeys.products.tr(),
            count: productsCount,
          ),
          _buildTab(
            context,
            index: 1,
            title: LocaleKeys.boutiques.tr(),
            count: boutiquesCount,
          ),
          _buildTab(
            context,
            index: 2,
            title: LocaleKeys.orders.tr(),
            count: ordersCount,
          ),
          _buildTab(
            context,
            index: 3,
            title: LocaleKeys.permissions.tr(),
            count: permissionsCount,
          ),
          _buildTab(context, index: 4, title: LocaleKeys.users.tr()),
        ],
      ),
    );
  }

  Widget _buildTab(
    BuildContext context, {
    required int index,
    required String title,
    int? count,
  }) {
    final isSelected = selectedIndex == index;

    return InkWell(
      onTap: () => onTabSelected(index),
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFF3366FF) : Colors.transparent,
              width: 3.h,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF3366FF)
                    : Colors.grey.shade600,
              ),
            ),
            if (count != null) ...[
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: isSelected
                      // ignore: deprecated_member_use
                      ? const Color(0xFF3366FF).withOpacity(0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? const Color(0xFF3366FF)
                        : Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
