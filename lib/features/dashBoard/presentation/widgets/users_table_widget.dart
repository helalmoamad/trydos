import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/features/dashBoard/data/models/get_users_model.dart';
import 'pagination_widget.dart';

class UsersTableWidget extends StatelessWidget {
  final List<User> users;
  final Meta? meta;
  final Function(int page)? onPageChanged;
  final Function(String userId, String roleId)? onChangeRole;
  final Function(String userId)? onDeleteUser;

  const UsersTableWidget({
    Key? key,
    required this.users,
    this.meta,
    this.onPageChanged,
    this.onChangeRole,
    this.onDeleteUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Users Table
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Container(
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
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12.r),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Name / Phone',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Role',
                            //roles
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Actions',
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

                  // Table Body
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: users.length,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: Colors.grey.shade200),
                    itemBuilder: (context, index) {
                      return UserRow(
                        user: users[index],
                        onChangeRole: onChangeRole,
                        onDeleteUser: onDeleteUser,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),

        // Pagination
        if (meta != null && (meta!.lastPage ?? 1) > 1)
          PaginationWidget(
            currentPage: meta!.currentPage ?? 1,
            totalPages: meta!.lastPage ?? 1,
            onPrevious: () {
              if (onPageChanged != null && (meta!.currentPage ?? 1) > 1) {
                onPageChanged!((meta!.currentPage ?? 1) - 1);
              }
            },
            onNext: () {
              if (onPageChanged != null &&
                  (meta!.currentPage ?? 1) < (meta!.lastPage ?? 1)) {
                onPageChanged!((meta!.currentPage ?? 1) + 1);
              }
            },
          ),
      ],
    );
  }
}

class UserRow extends StatelessWidget {
  final User user;
  final Function(String userId, String roleId)? onChangeRole;
  final Function(String userId)? onDeleteUser;

  const UserRow({
    Key? key,
    required this.user,
    this.onChangeRole,
    this.onDeleteUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          // Name / Phone
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name ?? 'N/A',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (user.phone != null)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      user.phone!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Role
          Expanded(
            flex: 2,
            child: Text(
              user.role?.name ?? 'N/A',
              style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700),
            ),
          ),

          // Actions
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Change Role Button
                TextButton(
                  onPressed: () {
                    // TODO: Show dialog to change role
                    if (onChangeRole != null) {
                      // onChangeRole!(user.id.toString(), newRoleId);
                    }
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    backgroundColor: Colors.grey.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.r),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Text(
                    'Change role',
                    style: TextStyle(fontSize: 12.sp, color: Colors.black87),
                  ),
                ),

                SizedBox(width: 8.w),

                // Delete Button
                TextButton(
                  onPressed: () {
                    if (onDeleteUser != null) {
                      onDeleteUser!(user.id.toString());
                    }
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    backgroundColor: Colors.red.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.r),
                      side: BorderSide(color: Colors.red.shade200),
                    ),
                  ),
                  child: Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.red.shade700,
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
}
