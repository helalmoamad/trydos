import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart' as tran;
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/features/dashBoard/data/models/get_users_model.dart';
import 'pagination_widget.dart';
import 'change_role_dialog.dart';

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
    return Directionality(
      textDirection: TextDirection.ltr,

      child: Column(
        children: [
          // Users Table
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(0),
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
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
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
                            flex: 3,
                            child: Text(
                              LocaleKeys.name_phone.tr(),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            flex: 3,
                            child: Text(
                              LocaleKeys.role_label.tr(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            flex: 4,
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

                    // Table Body
                    Expanded(
                      child: ListView.separated(
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
      ),
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
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      child: Row(
        children: [
          // Name / Phone
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name ?? LocaleKeys.not_available.tr(),
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

          SizedBox(width: 8.w),

          // Role
          Expanded(
            flex: 3,
            child: Text(
              user.role?.name ?? LocaleKeys.not_available.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700),
            ),
          ),

          SizedBox(width: 8.w),

          // Actions
          Expanded(
            flex: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Change Role Button (عرضه ضعف زر الحذف)
                Flexible(
                  child: TextButton(
                    onPressed: () {
                      if (onChangeRole != null) {
                        showDialog(
                          context: context,
                          builder: (context) => ChangeRoleDialog(
                            userId: user.id.toString(),
                            onRoleSelected: onChangeRole!,
                          ),
                        );
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      minimumSize: Size(0, 32.h),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: Colors.grey.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.r),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Text(
                      LocaleKeys.change_role.tr(),
                      style: TextStyle(fontSize: 12.sp, color: Colors.black87),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                SizedBox(width: 6.w),

                // Delete Button
                Flexible(
                  child: TextButton(
                    onPressed: () {
                      if (onDeleteUser != null) {
                        onDeleteUser!(user.id.toString());
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 6.h,
                      ),
                      minimumSize: Size(0, 32.h),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: Colors.red.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.r),
                        side: BorderSide(color: Colors.red.shade200),
                      ),
                    ),
                    child: Text(
                      LocaleKeys.delete.tr(),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.red.shade700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
