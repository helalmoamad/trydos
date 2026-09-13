import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/features/dashBoard/presentation/bloc/dashBoard_bloc.dart';

class ChangeRoleDialog extends StatefulWidget {
  final String userId;
  final Function(String userId, String roleId) onRoleSelected;

  const ChangeRoleDialog({
    Key? key,
    required this.userId,
    required this.onRoleSelected,
  }) : super(key: key);

  @override
  State<ChangeRoleDialog> createState() => _ChangeRoleDialogState();
}

class _ChangeRoleDialogState extends State<ChangeRoleDialog> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  String _searchQuery = '';
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    // تحميل الأدوار الأولية
    context.read<DashboardBloc>().add(GetUserRolesEvent());

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();

    // إلغاء الـ timer السابق
    _debounceTimer?.cancel();

    // إذا كان النص أقل من حرفين، لا تبحث
    if (query.length < 2 && query.isNotEmpty) {
      return;
    }

    // إنشاء timer جديد - يبدأ البحث بعد ثانية واحدة
    _debounceTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _searchQuery = query;
          _currentPage = 1;
        });
        context.read<DashboardBloc>().add(
          GetUserRolesEvent(
            search: _searchQuery.isNotEmpty ? _searchQuery : null,
          ),
        );
      }
    });
  }

  void _loadMore() {
    final meta = context.read<DashboardBloc>().state.rolesMeta;
    if (meta != null &&
        _currentPage < (meta.lastPage ?? 1) &&
        context.read<DashboardBloc>().state.getUserRolesStatus !=
            GetUserRolesStatus.loading) {
      final nextPage = _currentPage + 1;
      setState(() {
        _currentPage = nextPage;
      });
      context.read<DashboardBloc>().add(
        GetUserRolesEvent(
          search: _searchQuery.isNotEmpty ? _searchQuery : null,
          page: nextPage,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // العنوان
            Text(
              LocaleKeys.change_role.tr(),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16.h),

            // حقل البحث
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search roles...',
                prefixIcon: Icon(Icons.search, size: 20.sp),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 12.h,
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // قائمة الأدوار
            Expanded(
              child: BlocBuilder<DashboardBloc, DashBoardState>(
                builder: (context, state) {
                  if (state.getUserRolesStatus == GetUserRolesStatus.loading &&
                      state.shopRoles == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final roles = state.shopRoles ?? [];

                  if (roles.isEmpty) {
                    return Center(
                      child: Text(
                        state.getUserRolesStatus == GetUserRolesStatus.loading
                            ? 'Loading...'
                            : 'No roles found',
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount:
                        roles.length +
                        (state.rolesMeta != null &&
                                _currentPage < (state.rolesMeta!.lastPage ?? 1)
                            ? 1
                            : 0),
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      if (index >= roles.length) {
                        // زر Load More
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          child: TextButton(
                            onPressed: _loadMore,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.r),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child:
                                state.getUserRolesStatus ==
                                    GetUserRolesStatus.loading
                                ? SizedBox(
                                    width: 20.w,
                                    height: 20.h,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    LocaleKeys.load_more.tr(),
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.black87,
                                    ),
                                  ),
                          ),
                        );
                      }

                      final role = roles[index];
                      return InkWell(
                        onTap: () {
                          widget.onRoleSelected(
                            widget.userId,
                            role.id.toString(),
                          );
                          // Pop dialog and return the role for add_user_widget usage
                          // Use rootNavigator: false to ensure we're popping the dialog, not the page
                          if (Navigator.canPop(context)) {
                            Navigator.of(context).pop(role);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 12.h,
                            horizontal: 12.w,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                role.name ?? '',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              if (role.description != null &&
                                  role.description!.isNotEmpty) ...[
                                SizedBox(height: 4.h),
                                Text(
                                  role.description!,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
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
