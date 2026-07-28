import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:trydos/service/language_service.dart';
import '../../../../common/constant/design/assets_provider.dart';
import 'create_account_section.dart';
import 'insert_phone_tab.dart';
import 'verification_methods.dart';
import 'verify_otp.dart';
import 'welcome_section.dart';

/// Reusable guest phone-verification flow shown as a dialog.
///
/// Mirrors the first-install registration sequence so a guest can either log
/// into a previous account or create a new one:
/// welcome (login / create) -> create-account -> enter phone -> choose method
/// -> verify OTP.
///
/// Used wherever a guest must confirm a phone number to unlock a feature
/// (cart, comments, orders, product details...). Replaces the per-page
/// `_veryfiedOtp` copies. The [VerifyOtp] flags ([fromProfile], [fromExpired])
/// pass through; [fromLogin] seeds the initial mode (welcome overrides it).
/// On success [onVerified] is called and the dialog closes.
class GuestPhoneVerificationDialog extends StatefulWidget {
  const GuestPhoneVerificationDialog({
    super.key,
    this.onVerified,
    this.fromProfile = false,
    this.fromExpired = true,
    this.fromLogin = false,
  });

  final VoidCallback? onVerified;
  final bool fromProfile;
  final bool fromExpired;
  final bool fromLogin;

  static bool _isOpen = false;

  static Future<void> show(
    BuildContext context, {
    VoidCallback? onVerified,
    bool fromProfile = false,
    bool fromExpired = true,
    bool fromLogin = false,
  }) async {
    if (_isOpen) return;
    _isOpen = true;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => GuestPhoneVerificationDialog(
        onVerified: onVerified,
        fromProfile: fromProfile,
        fromExpired: fromExpired,
        fromLogin: fromLogin,
      ),
    );
    _isOpen = false;
  }

  @override
  State<GuestPhoneVerificationDialog> createState() =>
      _GuestPhoneVerificationDialogState();
}

class _GuestPhoneVerificationDialogState
    extends State<GuestPhoneVerificationDialog> {
  // PageView indices (welcome = 0, the initial page).
  static const int _createAccount = 1;
  static const int _phone = 2;
  static const int _methods = 3;
  static const int _otp = 4;

  final PageController _pageController = PageController();
  final FocusNode _focusNode = FocusNode();
  String _phoneNumber = '';
  int _isVisWhatsApp = 1;
  late bool _fromLogin = widget.fromLogin;

  @override
  void dispose() {
    _pageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _close() => Navigator.of(context).pop();

  void _animateTo(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: SizedBox(
        height: 1.sh / 2.1,
        child: Stack(
          children: [
            PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _pageController,
              children: [
                // Maybe an existing account, maybe a new one — same choice as
                // the first-install welcome screen.
                WelcomeSection(
                  goToLoginSection: () {
                    _fromLogin = true;
                    _animateTo(_phone);
                  },
                  goToCreateAccount: () {
                    _fromLogin = false;
                    _animateTo(_createAccount);
                  },
                ),
                CreateAccountSection(moveToNextStep: () => _animateTo(_phone)),
                InsertPhoneTab(
                  fromLogin: _fromLogin,
                  focusNode: _focusNode,
                  moveToNextStep: (String phoneNumber) {
                    _phoneNumber = phoneNumber.replaceAll(' ', '');
                    _animateTo(_methods);
                    setState(() {});
                  },
                ),
                VerificationMethods(
                  isFromLogin: _fromLogin,
                  phoneNumber: _phoneNumber,
                  onChooseWhatsapp: () {
                    _isVisWhatsApp = 1;
                    _animateTo(_otp);
                  },
                  onChooseSms: () {
                    _isVisWhatsApp = 0;
                    _animateTo(_otp);
                  },
                  goBackToPhone: () => _animateTo(_phone),
                ),
                VerifyOtp(
                  fromProfile: widget.fromProfile,
                  fromExpired: widget.fromExpired,
                  fromLogin: _fromLogin,
                  isVisWhatsApp: _isVisWhatsApp,
                  phoneNumber: _phoneNumber,
                  methodIcon: _isVisWhatsApp == 1
                      ? AppAssets.whatsappSvg
                      : AppAssets.smsSvg,
                  navigateToAddName: () {},
                  navigateToProfile: () {},
                  navigateTocartOrProfile: () {
                    widget.onVerified?.call();
                    _close();
                  },
                  onLoginFailed: () {},
                  goBack: () => _animateTo(_methods),
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
      ),
    );
  }
}
