import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../generated/locale_keys.g.dart';
import '../bloc/dashBoard_bloc.dart';
import '../../data/models/get_user_roles_model.dart';

class AddUserWidget extends StatefulWidget {
  final String sellerId;

  const AddUserWidget({Key? key, required this.sellerId}) : super(key: key);

  @override
  State<AddUserWidget> createState() => _AddUserWidgetState();
}

class _AddUserWidgetState extends State<AddUserWidget> {
  ShopRole? _selectedRole;
  final TextEditingController _phoneController = TextEditingController();
  late DashboardBloc _dashboardBloc;
  @override
  void initState() {
    super.initState();
    _dashboardBloc = BlocProvider.of<DashboardBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashBoardState>(
      buildWhen: (previous, current) =>
          previous.getUserRolesStatus != current.getUserRolesStatus ||
          previous.addUserStatus != current.addUserStatus,
      builder: (context, state) {
        final roles = state.shopRoles ?? [];
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
                    TextFormField(
                      controller: _phoneController,
                      decoration: _inputDecoration('+(country_code)XXX'),
                      keyboardType: TextInputType.phone,
                      onChanged: (value) {
                        if (value.isNotEmpty && !value.startsWith('+')) {
                          _phoneController.text = '+' + value;
                          _phoneController
                              .selection = TextSelection.fromPosition(
                            TextPosition(offset: _phoneController.text.length),
                          );
                        }
                      },
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
                    DropdownButtonFormField<ShopRole>(
                      // ignore: deprecated_member_use
                      value: _selectedRole,
                      items: roles.map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(role.name ?? ""),
                        );
                      }).toList(),
                      onChanged: isLoading
                          ? null
                          : (value) {
                              setState(() {
                                _selectedRole = value;
                              });
                            },
                      decoration: _inputDecoration(
                        isLoading
                            ? "Loading roles..."
                            : LocaleKeys.select_role_hint.tr(),
                      ),
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.black54,
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
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: isAddingUser
                          ? Shimmer.fromColors(
                              baseColor: const Color(0xFF90B0FF),
                              // ignore: deprecated_member_use
                              highlightColor: Colors.white.withOpacity(0.5),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF90B0FF),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: _selectedRole == null
                                  ? null
                                  : () {
                                      _dashboardBloc.add(
                                        AddUserEvent(
                                          phone: _phoneController.text,
                                          role_id: _selectedRole!.id.toString(),
                                          seller_id: widget.sellerId,
                                        ),
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF90B0FF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                LocaleKeys.add_user_button.tr(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // Available Roles Section
              Container(
                width: double.infinity,
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
                      LocaleKeys.available_roles.tr(),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff111827),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    if (isLoading)
                      Wrap(
                        spacing: 12.w,
                        runSpacing: 12.h,
                        children: List.generate(4, (index) {
                          return Shimmer.fromColors(
                            baseColor: Colors.grey.shade100,
                            highlightColor: Colors.grey.shade50,
                            child: Container(
                              width: 80.w,
                              height: 38.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                          );
                        }),
                      )
                    else if (roles.isEmpty)
                      Container(
                        height: 150.h,
                        alignment: Alignment.center,
                        child: Text(
                          LocaleKeys.no_roles_available.tr(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 12.w,
                        runSpacing: 12.h,
                        children: roles.map((role) {
                          return IntrinsicWidth(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 10.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(color: Colors.grey.shade100),
                              ),
                              child: Text(
                                role.name ?? "",
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
