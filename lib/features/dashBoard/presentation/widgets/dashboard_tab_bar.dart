import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../generated/locale_keys.g.dart';
import 'dashboard_permission_checker.dart';

class DashboardTabBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;
  final int productsCount;
  final int boutiquesCount;
  final int ordersCount;
  final int permissionsCount;
  final List<String> permissions;

  DashboardTabBar({
    Key? key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.permissions,
    this.productsCount = 0,
    this.boutiquesCount = 0,
    this.ordersCount = 0,
    this.permissionsCount = 0,
  }) : super(key: key);

  DashboardPermissionChecker get _permissionChecker =>
      DashboardPermissionChecker(permissions);

  @override
  Widget build(BuildContext context) {
    // Build list of visible tabs based on permissions
    final List<_TabInfo> visibleTabs = [];
    int visualIndex = 0;

    // Products tab (index 0)
    if (_permissionChecker.canSeeProducts()) {
      visibleTabs.add(
        _TabInfo(
          visualIndex: visualIndex++,
          actualIndex: 0,
          title: LocaleKeys.products.tr(),
          count: productsCount,
        ),
      );
    }

    // Boutiques tab (index 1)
    if (_permissionChecker.canSeeBoutiques()) {
      visibleTabs.add(
        _TabInfo(
          visualIndex: visualIndex++,
          actualIndex: 1,
          title: LocaleKeys.boutiques.tr(),
          count: boutiquesCount,
        ),
      );
    }

    // Orders tab (index 2)
    if (_permissionChecker.canSeeOrders()) {
      visibleTabs.add(
        _TabInfo(
          visualIndex: visualIndex++,
          actualIndex: 2,
          title: LocaleKeys.orders.tr(),
          count: ordersCount,
        ),
      );
    }

    // Permissions tab (index 3) - always visible
    visibleTabs.add(
      _TabInfo(
        visualIndex: visualIndex++,
        actualIndex: 3,
        title: LocaleKeys.permissions.tr(),
        count: permissionsCount,
      ),
    );

    // Users tab (index 4)
    if (_permissionChecker.canSeeUsers()) {
      visibleTabs.add(
        _TabInfo(
          visualIndex: visualIndex++,
          actualIndex: 4,
          title: LocaleKeys.users.tr(),
        ),
      );
    }

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
        children: visibleTabs.map((tab) {
          return _buildTab(
            context,
            index: tab.visualIndex,
            actualIndex: tab.actualIndex,
            title: tab.title,
            count: tab.count,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTab(
    BuildContext context, {
    required int index,
    required int actualIndex,
    required String title,
    int? count,
  }) {
    final isSelected = selectedIndex == actualIndex;

    return InkWell(
      onTap: () => onTabSelected(actualIndex),
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
            if (count != null && count > 0) ...[
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

// Helper class to map visual index to actual index
class _TabInfo {
  final int visualIndex;
  final int actualIndex;
  final String title;
  final int? count;

  _TabInfo({
    required this.visualIndex,
    required this.actualIndex,
    required this.title,
    this.count,
  });
}
