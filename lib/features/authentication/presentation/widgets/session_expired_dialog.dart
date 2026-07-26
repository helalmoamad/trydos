import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/service/language_service.dart';
import '../../../../common/constant/constant.dart';
import '../../../../generated/locale_keys.g.dart';
import 'verification_methods.dart';
import 'verify_otp.dart';

/// Shown at base_page when a verified user's session expires (refresh failed).
/// The user is already browsing as a fresh guest; this dialog lets them log
/// back into their own account (OTP prefilled with their phone) or dismiss and
/// keep browsing as the guest. It never logs the user out.
class SessionExpiredDialog extends StatefulWidget {
  const SessionExpiredDialog({super.key, this.phoneNumber});

  final String? phoneNumber;

  static bool _isOpen = false;

  static Future<void> show(BuildContext context, {String? phoneNumber}) async {
    if (_isOpen) return;
    _isOpen = true;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => SessionExpiredDialog(phoneNumber: phoneNumber),
    );
    _isOpen = false;
  }

  @override
  State<SessionExpiredDialog> createState() => _SessionExpiredDialogState();
}

class _SessionExpiredDialogState extends State<SessionExpiredDialog> {
  final PageController _pageController = PageController();
  bool _showLogin = false;
  int _isVisWhatsApp = 1;

  String get _phone => widget.phoneNumber ?? "";

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _close() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        child: _showLogin ? _buildLoginFlow() : _buildExpiredPrompt(),
      ),
    );
  }

  Widget _buildExpiredPrompt() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64.w,
            height: 64.w,
            decoration: const BoxDecoration(
              color: Color(0xffFDEDED),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              AppAssets.loginAfterExpiredSvg,
              width: 30.w,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            LocaleKeys.your_session_has_expired.tr(),
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.bq.copyWith(
              color: const Color(0xff1D1D1D),
              fontSize: 16.sp,
              height: 1.3,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            LocaleKeys.please_login_again_or_continue_guest.tr(),
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.rq.copyWith(
              color: const Color(0xff8D8D8D),
              fontSize: 13.sp,
              height: 1.4,
            ),
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _showLogin = true),
                  child: Container(
                    height: 46.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xffFF5F61),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      LocaleKeys.login.tr(),
                      style: context.textTheme.bodyMedium?.mq.copyWith(
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: InkWell(
                  onTap: _close,
                  child: Container(
                    height: 46.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xffECECEC),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      LocaleKeys.continue_as_guest.tr(),
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodyMedium?.mq.copyWith(
                        color: const Color(0xff1D1D1D),
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoginFlow() {
    return SizedBox(
      height: 300.h,
      child: Stack(
        children: [
          PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _pageController,
            children: [
              // The user's phone is known — skip the phone-entry step and start
              // from choosing the verification method.
              VerificationMethods(
                isFromLogin: true,
                phoneNumber: _phone,
                onChooseWhatsapp: () {
                  _isVisWhatsApp = 1;
                  _pageController.animateToPage(
                    1,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                },
                onChooseSms: () {
                  _isVisWhatsApp = 0;
                  _pageController.animateToPage(
                    1,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                },
                goBackToPhone: () => setState(() => _showLogin = false),
              ),
              VerifyOtp(
                fromProfile: false,
                fromExpired: true,
                fromLogin: true,
                isVisWhatsApp: _isVisWhatsApp,
                phoneNumber: _phone,
                methodIcon: _isVisWhatsApp == 1
                    ? AppAssets.whatsappSvg
                    : AppAssets.smsSvg,
                navigateToAddName: () {},
                navigateToProfile: () {},
                // OTP verified -> the guest was merged/promoted back into the
                // user's account; close the dialog.
                navigateTocartOrProfile: _close,
                onLoginFailed: () {},
                goBack: () {
                  _pageController.animateToPage(
                    0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ],
          ),
          Positioned(
            top: 6,
            left: LanguageService.languageCode == "ar" ? 6 : null,
            right: LanguageService.languageCode == "ar" ? null : 6,
            child: InkWell(
              onTap: _close,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: SvgPicture.asset(AppAssets.closeSvg, height: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
