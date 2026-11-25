/// شاشةُ النجاح — نقلٌ لـ`web_design/NewLoginDesign/NewSuccessScreen.tsx`.
///
/// > «النهايتان شاشتان في التصميم لا واحدة.
/// >
/// > `Registration - 27` (تمّ التسجيل) نعناعيٌّ `#D8FFEA` بشعارٍ أخضر، و
/// > `Registration - 33` (أهلاً بعودتك) كريميٌّ `#FFFEF2` بالشعار البنفسجيّ.
/// > وكان الكودُ قد دمجهما في شاشةٍ خضراءَ واحدة؛ والتصميمُ يُفرّقهما، فكذلك
/// > هذه.»
/// >
/// > وفي كلتيهما: الشعارُ على 116، والعنوانُ 30 Bold على 288، والسطرُ 16
/// > Medium على 338. وتزيد «أهلاً بعودتك» سطراً ثالثاً 12 على 366.
library;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:trydos/common/constant/design/xd_svg.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import 'auth_design.dart';
import 'auth_logo.dart';
import 'auth_parts.dart';

/// أيُّ النهايتين.
enum AuthSuccess {
  /// «أهلاً بك !» — دخولٌ إلى حسابٍ قائم: كريميٌّ بالشعار البنفسجيّ.
  login,

  /// «تمّ التسجيل بنجاح !» — نعناعيٌّ بالشعار الأخضر.
  signup,
}

class SuccessScreenV2 extends StatefulWidget {
  const SuccessScreenV2({
    super.key,
    required this.variant,
    required this.onDone,
    this.name,
    this.delay = const Duration(milliseconds: 2500),
  });

  final AuthSuccess variant;

  /// تُنادى بعد [delay] — الشاشةُ تعرض ولا تنتظر لمسة.
  final VoidCallback onDone;

  /// اسمُ الداخل، يظهر في «أهلاً بك».
  final String? name;

  final Duration delay;

  /// أرضيّةُ كلٍّ — `SUCCESS_BG`.
  static const Color loginBg = Color(0xFFFFFEF2);
  static const Color signupBg = Color(0xFFD8FFEA);

  /// ولونُ شعارها.
  static AuthBadgeTone toneOf(AuthSuccess v) =>
      v == AuthSuccess.login ? AuthBadgeTone.purple : AuthBadgeTone.green;

  @override
  State<SuccessScreenV2> createState() => _SuccessScreenV2State();
}

class _SuccessScreenV2State extends State<SuccessScreenV2> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delay, () {
      if (mounted) widget.onDone();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool login = widget.variant == AuthSuccess.login;
    return AuthBoard(
      bg: login ? SuccessScreenV2.loginBg : SuccessScreenV2.signupBg,
      children: <Widget>[
        Positioned(
          top: AuthXd.headTitle.h,
          left: AuthXd.textLeft.w,
          right: AuthXd.boxLeft.w,
          child: XdText(
            (login
                    ? LocaleKeys.welcome_excl
                    : LocaleKeys.sign_up_successfully_excl)
                .tr(),
            size: 30,
            weight: XdWeight.bold,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Positioned(
          top: AuthXd.headLine2.h,
          left: AuthXd.textLeft.w,
          right: AuthXd.boxLeft.w,
          child: XdText(
            login ? (widget.name ?? '') : LocaleKeys.last_step.tr(),
            size: 16,
            weight: XdWeight.medium,
            maxLines: 2,
          ),
        ),
        if (login)
          Positioned(
            top: AuthXd.headLine3.h,
            left: AuthXd.textLeft.w,
            right: AuthXd.boxLeft.w,
            child: XdText(
              LocaleKeys.enjoy_with_our_services.tr(),
              size: 12,
              maxLines: 2,
            ),
          ),
      ],
    );
  }
}
