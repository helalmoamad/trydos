/// «أدخل رقمك» — نقلٌ لـ`web_design/NewLoginDesign/NewEnterPhoneScreen.tsx`.
///
/// > كلُّ كتلةٍ على y من الملفّ مباشرةً. واللوحُ دائماً 430 × 932، فالـ`top`
/// > هو الـ`top` على كلّ جهاز. ورصُّ هذه الكتل بهوامشَ هو ما رفع الشاشةَ
/// > كلَّها 15 إلى 27 بكسلاً قبلُ.
/// >
/// > من أعلى إلى أسفل:
/// >   - إكسُ الإغلاق 15 في الزاوية؛
/// >   - الشعارُ على 116 — الرقمُ نفسُه في سبع شاشات، فلا يتحرّك وهي تنزلق؛
/// >   - العنوان 30 Bold على 288، وهو يتبدّل بنوع المسار ([AuthFlow])؛
/// >   - «أدخل رقمك المسجَّل عندنا» 16 على 338؛
/// >   - «سنرسل رمز التحقّق إلى الرقم» 12 Medium على 366، وبعدها علامةُ
/// >     الشريحة 15 بفراغ [AuthIconGap.phone]؛
/// >   - «خصوصيّتك آمنةٌ تماماً» 11 `#4A31E7` على 389، ودرعُها 14 بفراغ 10.5؛
/// >   - حقلُ الهاتف على 503؛
/// >   - ورسالةُ الخطأ 12 Medium حمراءُ موسَّطةٌ على 10 تحت الحقل.
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
import 'auth_phone_box.dart';

/// المسارُ الذي فتح الشاشة، وبه يتبدّل عنوانُها — `AuthFlowType`.
///
/// وثلاثُ شاشاتٍ تتقاسم الخريطةَ نفسَها (الهاتفُ والطريقةُ والرمز)، فلا يأخذ
/// مسارٌ عنوانَ غيره في خطوةٍ ويُصيب في التالية.
enum AuthFlow {
  signIn,
  signUp,

  /// تأكيدُ رقمٍ يملكه الحسابُ سلفاً: بوّابةُ الطلب المسبق، وإعادةُ التوثيق،
  /// و«وثّق الآن» في الإعدادات. وليس دخولاً — فالمشتري داخلٌ أصلاً.
  verify,

  /// الإعدادات: كتب المشتري رقماً **جديداً** ويُثبت ملكيّتَه.
  changePhone,
}

/// عنوانُ كلّ مسار — `HEADING_KEYS`.
String authHeadingKey(AuthFlow flow) => switch (flow) {
  AuthFlow.signIn => LocaleKeys.login_excl,
  AuthFlow.signUp => LocaleKeys.sign_up_excl,
  AuthFlow.verify => LocaleKeys.verify_your_number_excl,
  AuthFlow.changePhone => LocaleKeys.change_your_number_excl,
};

class EnterPhoneScreenV2 extends StatelessWidget {
  const EnterPhoneScreenV2({
    super.key,
    required this.flow,
    required this.phone,
    required this.onPhone,
    required this.onSubmit,
    required this.dialCode,
    required this.flag,
    this.onClose,
    this.error,
    this.valid = false,
    this.busy = false,
  });

  final AuthFlow flow;
  final String phone;
  final ValueChanged<String> onPhone;
  final VoidCallback onSubmit;
  final String dialCode;
  final String flag;
  final VoidCallback? onClose;

  /// رسالةُ إرسالٍ أو تحقّقٍ فاشل، مترجمةً عند المتّصل.
  final String? error;

  final bool valid;
  final bool busy;

  /// الدرعُ بعد سطر الخصوصيّة بفراغ 10.5.
  static const double _shieldGap = 10.5;

  @override
  Widget build(BuildContext context) {
    return AuthBoard(
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
            authHeadingKey(flow).tr(),
            size: 30,
            weight: XdWeight.bold,
          ),
        ),
        Positioned(
          top: AuthXd.headLine2.h,
          left: AuthXd.textLeft.w,
          right: AuthXd.boxLeft.w,
          child: XdText(
            LocaleKeys.enter_your_phonenumber_registered_with_us.tr(),
            size: 16,
            maxLines: 2,
          ),
        ),
        // السطرُ الثالثُ وعلامتُه: الأيقونةُ تتبع الجملةَ بفراغٍ من الملفّ،
        // لا على x ثابت — فالجملةُ مترجمةٌ ويتبدّل طولُها.
        Positioned(
          top: AuthXd.headLine3.h,
          left: AuthXd.textLeft.w,
          right: AuthXd.boxLeft.w,
          child: _iconLine(
            text: LocaleKeys.we_will_send_code.tr(),
            size: 12,
            weight: XdWeight.medium,
            icon: 'sim',
            iconSize: 15,
            gap: AuthIconGap.phone,
          ),
        ),
        Positioned(
          top: AuthXd.headLine4.h,
          left: AuthXd.textLeft.w,
          right: AuthXd.boxLeft.w,
          child: _iconLine(
            text: LocaleKeys.your_privacy_is_completely_safe.tr(),
            size: 11,
            color: XdColors.purple,
            icon: 'shield',
            iconSize: 14,
            gap: _shieldGap,
          ),
        ),
        Positioned(
          top: AuthXd.boxTop.h,
          left: AuthXd.boxLeft.w,
          child: AuthPhoneBox(
            value: phone,
            onChanged: onPhone,
            onSend: onSubmit,
            dialCode: dialCode,
            flag: flag,
            hint: LocaleKeys.enter_your_number.tr(),
            valid: valid,
            busy: busy,
          ),
        ),
        if (error != null && error!.isNotEmpty)
          Positioned(
            top: (AuthXd.boxTop + AuthXd.boxHeight + 10).h,
            left: AuthXd.boxLeft.w,
            right: AuthXd.boxLeft.w,
            child: XdText(
              error!,
              size: 12,
              weight: XdWeight.medium,
              color: XdColors.red,
              align: TextAlign.center,
              maxLines: 3,
            ),
          ),
      ],
    );
  }

  /// سطرٌ تتبعه أيقونتُه بفراغ الملفّ.
  Widget _iconLine({
    required String text,
    required double size,
    required String icon,
    required double iconSize,
    required double gap,
    XdWeight weight = XdWeight.regular,
    Color color = XdColors.ink,
  }) {
    return Row(
      children: <Widget>[
        Flexible(
          child: XdText(
            text,
            size: size,
            weight: weight,
            color: color,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: gap.w),
        SvgPicture.asset(
          'assets/svg/$kAuthSvg/$icon.svg',
          width: iconSize.w,
          height: iconSize.w,
        ),
      ],
    );
  }
}
