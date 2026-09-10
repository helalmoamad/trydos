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
    this.asBottomSheet = false,
    this.inline = false,
    this.onClose,
    this.onHeightChanged,
    this.initialPhone,
    this.startAtMethods = false,
  });

  final VoidCallback? onVerified;
  final bool fromProfile;
  final bool fromExpired;
  final bool fromLogin;

  /// The number to verify, when the host already has one. The profile passes
  /// the number the user just typed into the phone field.
  final String? initialPhone;

  /// Opens straight on "choose how to receive the code", skipping welcome,
  /// create-account and enter-phone. For a host that already knows both the
  /// account and the number — changing a phone from the profile — those three
  /// steps ask questions that were answered before the flow started.
  ///
  /// Requires [initialPhone]: the methods step is what sends the OTP, and it
  /// sends it to this number.
  final bool startAtMethods;

  /// Presentation only. `false` keeps the centred dialog every caller has used
  /// so far; `true` slides the same flow up from the bottom edge. The steps,
  /// the blocs and the callbacks are identical either way.
  final bool asBottomSheet;

  /// Built straight into a host's tree instead of pushed as a route — the cart
  /// puts it in place of its Confirm & Continue button, inside the sliding
  /// panel. An inline flow carries no chrome of its own: the host already
  /// draws the surface it sits on.
  final bool inline;

  /// How an inline flow asks to be dismissed. Popping the route would close the
  /// host page, so a host that builds this inline must pass this.
  final VoidCallback? onClose;

  /// The height the current step needs. An inline host has to grow its own
  /// container by hand, so it is told on every step change.
  final ValueChanged<double>? onHeightChanged;

  static bool _isOpen = false;

  static Future<void> show(
    BuildContext context, {
    VoidCallback? onVerified,
    bool fromProfile = false,
    bool fromExpired = true,
    bool fromLogin = false,
    bool asBottomSheet = false,
    String? initialPhone,
    bool startAtMethods = false,
  }) async {
    assert(
      !startAtMethods || (initialPhone?.isNotEmpty ?? false),
      'startAtMethods sends the OTP straight away, so it needs a number to '
      'send it to',
    );
    if (_isOpen) return;
    _isOpen = true;
    final Widget flow = GuestPhoneVerificationDialog(
      onVerified: onVerified,
      fromProfile: fromProfile,
      fromExpired: fromExpired,
      fromLogin: fromLogin,
      asBottomSheet: asBottomSheet,
      initialPhone: initialPhone,
      startAtMethods: startAtMethods,
    );
    if (asBottomSheet) {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        // Mirrors `barrierDismissible: false` — the flow closes through its own
        // X button or on success, never by a tap outside or a drag down.
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Colors.transparent,
        builder: (_) => flow,
      );
    } else {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => flow,
      );
    }
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

  late final PageController _pageController = PageController(
    initialPage: _page,
  );
  final FocusNode _focusNode = FocusNode();
  late String _phoneNumber = widget.initialPhone?.replaceAll(' ', '') ?? '';
  int _isVisWhatsApp = 1;
  late int _page = widget.startAtMethods ? _methods : 0;
  late bool _fromLogin = widget.fromLogin;

  @override
  void initState() {
    super.initState();
    if (widget.onHeightChanged != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onHeightChanged!(_contentHeight);
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _close() {
    // Inline there is no route of our own to pop — popping would take the host
    // page with it.
    if (widget.onClose != null) {
      widget.onClose!();
      return;
    }
    Navigator.of(context).pop();
  }

  void _animateTo(int page) {
    setState(() => _page = page);
    widget.onHeightChanged?.call(_contentHeight);
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  /// The centred dialog keeps the height it always had. The sheet instead takes
  /// only the space the current step needs, so it grows and shrinks with the
  /// flow and the phone field lands where the cart button was. The OTP step is
  /// the tallest — six pin fields and their spacers — so it keeps the old
  /// height. Tune the numbers here if a step looks tight.
  double get _contentHeight {
    if (!widget.asBottomSheet && !widget.inline) return 1.sh / 2.1;
    // None of these steps has an intrinsic height — each was written to fill a
    // whole page — so the host has to be told a number. These are measured
    // against the 428x923 design size, each step in the longest state it can
    // reach. Keep them tight: every one of these widgets lays its column out
    // with center or end alignment, so spare height here turns into blank
    // space above the content, not below it.
    switch (_page) {
      case _createAccount:
        // ~375: the terms paragraph, the terms art, the link and the button.
        return 1.sh / 2.1;
      case _phone:
        return 210.h; // ~174 on sign-up, which carries the extra privacy line
      case _methods:
        return 250.h; // ~210 when the retry timer is showing
      case _otp:
        return 340.h; // ~331 with the error line and the expiry link showing
      default:
        return 360.h; // welcome ~311: description, two buttons, "later" link
    }
  }

  @override
  Widget build(BuildContext context) {
    return _chrome(
      context,
      AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: _contentHeight,
        child: Stack(
          children: [
            PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _pageController,
              children: [
                // Maybe an existing account, maybe a new one — same choice as
                // the first-install welcome screen.
                WelcomeSection(
                  // Inline there is no route of ours to pop; on a route this
                  // is the pop it always did.
                  onDismiss: widget.inline ? _close : null,
                  goToLoginSection: () {
                    _fromLogin = true;
                    _animateTo(_phone);
                  },
                  goToCreateAccount: () {
                    _fromLogin = false;
                    _animateTo(_createAccount);
                  },
                ),
                CreateAccountSection(
                  onDismiss: widget.inline ? _close : null,
                  moveToNextStep: () => _animateTo(_phone),
                ),
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
                  // The enter-phone step is not in this flow when the host
                  // supplied the number, so "edit" hands the user back to the
                  // field they typed it in.
                  goBackToPhone: () =>
                      widget.startAtMethods ? _close() : _animateTo(_phone),
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
                  // `VerifyOtp` reports success down a different callback for
                  // each verify event. `fromProfile` answers here — the guest
                  // flow never reaches it, and it never reached the one below.
                  navigateToProfile: () {
                    widget.onVerified?.call();
                    _close();
                  },
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

  /// The whole difference between the two presentations. The flow inside
  /// [content] is the same widget tree in both.
  Widget _chrome(BuildContext context, Widget content) {
    // The host owns the surface, the corners and the keyboard inset.
    if (widget.inline) return content;
    if (!widget.asBottomSheet) {
      return Dialog(
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: content,
      );
    }
    // Slides up from the bottom edge and rides above the keyboard, which the
    // phone step and the OTP step both open.
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        width: 1.sw,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SafeArea(top: false, child: content),
      ),
    );
  }
}
