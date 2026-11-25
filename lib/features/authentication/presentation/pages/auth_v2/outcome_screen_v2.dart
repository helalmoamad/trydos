/// شاشتا نتيجة الرقم — نقلٌ لـ`NewNotFoundScreen.tsx` و
/// `NewAlreadyExistScreen.tsx` في `web_design/NewLoginDesign/`.
///
/// > لوحان متوأمان: الشبكةُ نفسُها والكتلُ نفسُها، ولا يختلفان إلّا في
/// > الأرضيّة والعنوان والسطر والعلامة ولون الشعار وكلمةِ الزرّ.
/// >
/// > من أعلى إلى أسفل:
/// >   - إكسُ الإغلاق، والشعارُ على 116؛
/// >   - العنوانُ 30 Bold على 288، والسطرُ 16 Medium على 338؛
/// >   - الرقمُ 12 على 366 وبعده علامتُه 15 بفراغ [AuthIconGap.afterPhone]؛
/// >   - الزرُّ العريض على 789: `#FAFAFA` بخطٍّ متقطّعٍ `#707070` وكلماتٍ
/// >     `#1D1D1D`، **وتباعدٍ حرفيٍّ 0.01em** — وهو أحدُ ثلاثة مواضعَ في
/// >     الملفّ كلِّه؛
/// >   - «ألغِ وألقِ نظرةً على التطبيق» 14 `#4D84FF` على 879، بالتباعد نفسِه.
library;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:trydos/common/constant/design/xd_design.dart';
import 'package:trydos/common/constant/design/xd_svg.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import 'auth_design.dart';
import 'auth_logo.dart';
import 'auth_parts.dart';

/// أيُّ اللوحين.
enum AuthOutcome {
  /// الرقمُ غيرُ مسجَّل: أرضيّةٌ كريميّة، وعلامةٌ محذِّرة، ونقطتا الشعار
  /// كهرمانيّتان.
  notRegistered,

  /// الرقمُ مسجَّلٌ سلفاً: أرضيّةٌ زرقاءُ باهتة، وعلامةٌ زرقاء، والشعارُ
  /// بنفسجيٌّ كالمسار.
  alreadyRegistered,
}

class OutcomeScreenV2 extends StatelessWidget {
  const OutcomeScreenV2({
    super.key,
    required this.outcome,
    required this.phone,
    required this.onPrimary,
    required this.onCancel,
    this.onClose,
  });

  final AuthOutcome outcome;

  /// الرقمُ كاملاً بمفتاح دولته، بلا «+».
  final String phone;

  /// «أنشئ حساباً جديداً وتابع» أو «ادخل وتابع».
  final VoidCallback onPrimary;

  /// «ألغِ وألقِ نظرةً على التطبيق» — يخرج من المسار بلا تسجيل.
  final VoidCallback onCancel;

  final VoidCallback? onClose;

  /// أرضيّةُ كلٍّ من اللوحين.
  static const Color _creamBg = Color(0xFFFFF9F0);
  static const Color _blueBg = Color(0xFFF4F8FF);

  /// خطُّ الزرّ في اللوحين.
  static const Color _buttonDash = Color(0xFF707070);

  /// لونُ شعار كلّ لوح.
  AuthBadgeTone get tone => outcome == AuthOutcome.notRegistered
      ? AuthBadgeTone.amber
      : AuthBadgeTone.purple;

  @override
  Widget build(BuildContext context) {
    final bool missing = outcome == AuthOutcome.notRegistered;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        double up(double top) => box.maxHeight - authFromBottom(top).h;

        return AuthBoard(
          bg: missing ? _creamBg : _blueBg,
          children: <Widget>[
            if (onClose != null)
              AuthCorner(
                icon: 'close',
                size: AuthXd.controlCloseSize,
                onTap: onClose!,
                semantics: LocaleKeys.close.tr(),
              ),
            Positioned(
              top: AuthXd.headTitle.h,
              left: AuthXd.textLeft.w,
              child: XdText(
                (missing
                        ? LocaleKeys.not_registered_excl
                        : LocaleKeys.already_registered_excl)
                    .tr(),
                size: 30,
                weight: XdWeight.bold,
              ),
            ),
            Positioned(
              top: AuthXd.headLine2.h,
              left: AuthXd.textLeft.w,
              right: AuthXd.boxLeft.w,
              child: XdText(
                (missing
                        ? LocaleKeys.sorry_this_number_is_not_registered_with_us
                        : LocaleKeys.this_numbber_already)
                    .tr(),
                size: 16,
                weight: XdWeight.medium,
                maxLines: 2,
              ),
            ),
            // الرقمُ وعلامتُه: فراغٌ 6.6 قُرئ من اللوحين — العلامةُ على 148.6
            // والرقمُ ينتهي على 142.
            Positioned(
              top: AuthXd.headLine3.h,
              left: AuthXd.textLeft.w,
              right: AuthXd.boxLeft.w,
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: XdText(
                      '+$phone',
                      size: 12,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: AuthIconGap.afterPhone.w),
                  SvgPicture.asset(
                    'assets/svg/$kAuthSvg/'
                    '${missing ? 'warn-info' : 'blue-info'}.svg',
                    width: 15.w,
                    height: 15.w,
                  ),
                ],
              ),
            ),
            AuthWideButton(
              top: up(AuthXd.ctaPrimary),
              label:
                  (missing
                          ? LocaleKeys.create_new_account_and_continue
                          : LocaleKeys.login_and_continue)
                      .tr(),
              onTap: onPrimary,
              fill: AuthColors.buttonAgree,
              ink: XdColors.ink,
              dashColor: _buttonDash,
              tracking: kAuthWideTracking,
            ),
            AuthCentredLine(
              top: up(AuthXd.ctaLink),
              text: LocaleKeys.cancel_and_take_a_look.tr(),
              size: 14,
              color: AuthColors.link,
              tracking: kAuthWideTracking,
              onTap: onCancel,
            ),
          ],
        );
      },
    );
  }
}
