import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import '../../../../generated/locale_keys.g.dart';
import '../bloc/dashBoard_bloc.dart';
import '../../data/models/get_user_roles_model.dart';
import 'users_table_widget.dart';
import 'change_role_dialog.dart';

class AddUserWidget extends StatefulWidget {
  final String sellerId;

  const AddUserWidget({Key? key, required this.sellerId}) : super(key: key);

  @override
  State<AddUserWidget> createState() => _AddUserWidgetState();
}

class _AddUserWidgetState extends State<AddUserWidget> {
  ShopRole? _selectedRole;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  late DashboardBloc _dashboardBloc;
  @override
  void initState() {
    super.initState();
    _dashboardBloc = BlocProvider.of<DashboardBloc>(context);
    // Load users when widget initializes
    _dashboardBloc.add(GetUsersEvent());
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DashboardBloc, DashBoardState>(
      listenWhen: (previous, current) =>
          previous.addUserStatus != current.addUserStatus &&
          current.addUserStatus == AddUserStatus.success,
      listener: (context, state) {
        // تفريغ الحقول بعد إضافة المستخدم بنجاح
        _phoneController.clear();
        _roleController.clear();
        setState(() {
          _selectedRole = null;
        });
      },
      child: BlocBuilder<DashboardBloc, DashBoardState>(
        buildWhen: (previous, current) =>
            previous.getUserRolesStatus != current.getUserRolesStatus ||
            previous.addUserStatus != current.addUserStatus ||
            previous.getUsersStatus != current.getUsersStatus ||
            previous.deleteUserStatus != current.deleteUserStatus ||
            previous.changeUserRoleStatus != current.changeUserRoleStatus ||
            previous.users != current.users ||
            previous.usersMeta != current.usersMeta,
        builder: (context, state) {
          final isLoading =
              state.getUserRolesStatus == GetUserRolesStatus.loading;
          final isAddingUser = state.addUserStatus == AddUserStatus.loading;

          return SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                // Add User Form Section
                Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocaleKeys.add_user_to_shop.tr(),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff111827),
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // Phone Number Label
                      _buildLabel(LocaleKeys.phone_number_label.tr()),
                      SizedBox(height: 8.h),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: TextFormField(
                          controller: _phoneController,
                          decoration: _inputDecoration('+(country_code)XXX'),
                          keyboardType: TextInputType.phone,
                          onChanged: (value) {
                            if (value.isNotEmpty && !value.startsWith('+')) {
                              _phoneController.text = '+' + value;
                              _phoneController.selection =
                                  TextSelection.fromPosition(
                                    TextPosition(
                                      offset: _phoneController.text.length,
                                    ),
                                  );
                            }
                            // تحديث حالة الزر عند تغيير رقم الهاتف
                            setState(() {});
                          },
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        LocaleKeys.phone_format_hint.tr(),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // Role Label
                      _buildLabel(LocaleKeys.role_label.tr()),
                      SizedBox(height: 8.h),
                      Builder(
                        builder: (context) => TextFormField(
                          readOnly: true,
                          controller: _roleController,
                          onTap: isLoading
                              ? null
                              : () async {
                                  // Show dialog and wait for role selection
                                  final selectedRole = await showDialog<ShopRole>(
                                    context: context,
                                    builder: (dialogContext) => ChangeRoleDialog(
                                      userId:
                                          '', // Not used in add user context
                                      onRoleSelected: (userId, roleId) {
                                        // This callback is called before pop, but we use the returned value instead
                                      },
                                    ),
                                  );
                                  if (selectedRole != null && mounted) {
                                    setState(() {
                                      _selectedRole = selectedRole;
                                      _roleController.text =
                                          selectedRole.name ?? '';
                                    });
                                  }
                                },
                          decoration:
                              _inputDecoration(
                                isLoading
                                    ? "Loading roles..."
                                    : LocaleKeys.select_role_hint.tr(),
                              ).copyWith(
                                suffixIcon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Colors.black54,
                                ),
                              ),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: _selectedRole == null
                                ? Colors.grey.shade400
                                : Colors.black87,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // Seller ID Label
                      _buildLabel(LocaleKeys.seller_id_label.tr()),
                      SizedBox(height: 8.h),
                      TextFormField(
                        initialValue: widget.sellerId,
                        readOnly: true,
                        decoration: _inputDecoration(''),
                        style: const TextStyle(color: Colors.black87),
                      ),
                      SizedBox(height: 32.h),

                      // Add User Button
                      Builder(
                        builder: (context) {
                          final isFormValid =
                              _selectedRole != null &&
                              _phoneController.text.trim().isNotEmpty &&
                              _phoneController.text.trim().length >
                                  3; // على الأقل +9611

                          return SizedBox(
                            width: double.infinity,
                            height: 50.h,
                            child: isAddingUser
                                ? Shimmer.fromColors(
                                    baseColor: const Color(0xFF90B0FF),
                                    // ignore: deprecated_member_use
                                    highlightColor: Colors.white.withOpacity(
                                      0.5,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF90B0FF),
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                    ),
                                  )
                                : ElevatedButton(
                                    onPressed: isFormValid
                                        ? () {
                                            _dashboardBloc.add(
                                              AddUserEvent(
                                                phone: _phoneController.text
                                                    .trim(),
                                                role_id: _selectedRole!.id
                                                    .toString(),
                                                seller_id: widget.sellerId,
                                              ),
                                            );
                                          }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isFormValid
                                          ? const Color(0xFF90B0FF)
                                          : Colors.grey.shade300,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      LocaleKeys.add_user_button.tr(),
                                      style: TextStyle(
                                        color: isFormValid
                                            ? Colors.white
                                            : Colors.grey.shade600,
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // Users Section
                SizedBox(height: 24.h),
                Text(
                  'Users',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff111827),
                  ),
                ),
                SizedBox(height: 16.h),

                // Users Table or Loading/Empty State
                if (state.getUsersStatus == GetUsersStatus.loading ||
                    state.addUserStatus == AddUserStatus.loading ||
                    state.deleteUserStatus == DeleteUserStatus.loading ||
                    state.changeUserRoleStatus == ChangeUserRoleStatus.loading)
                  Container(
                    height: 200.h,
                    alignment: Alignment.center,
                    child: TrydosLoader(size: 20.r, color: Colors.black),
                  )
                else if (state.users != null && state.users!.isNotEmpty)
                  SizedBox(
                    height: 400.h,
                    child: UsersTableWidget(
                      users: state.users!,
                      meta: state.usersMeta,
                      onPageChanged: (page) {
                        _dashboardBloc.add(GetUsersEvent(page: page));
                      },
                      onChangeRole: (userId, roleId) {
                        _dashboardBloc.add(
                          ChangeUserRoleEvent(userId: userId, roleId: roleId),
                        );
                      },
                      onDeleteUser: (userId) {
                        _dashboardBloc.add(DeleteUserEvent(userId: userId));
                      },
                    ),
                  )
                else
                  Container(
                    height: 150.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'No users found',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xff374151),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey.shade400),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: Color(0xFF3366FF), width: 1.5),
      ),
    );
  }
}
