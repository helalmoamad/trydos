/// «اختر طريقة التحقّق» — نقلٌ لـ
/// `web_design/NewLoginDesign/NewSelectMethodScreen.tsx`.
///
/// > الشبكةُ نفسُها، وهذه الشاشةُ تُضيف صفَّ الرقم — فينزل سطرُ الخصوصيّة من
/// > 389 إلى 412 ([AuthXd.headLine4WithRow]).
/// >
/// > من أعلى إلى أسفل:
/// >   - إكسُ الإغلاق، والشعارُ على 116؛
/// >   - العنوانُ 30 Bold على 288 (بحسب المسار)؛
/// >   - «اختر طريقة التحقّق» 16 **Medium** على 338؛
/// >   - «سنرسل رمز التحقّق إلى الرقم» 12 **عاديّ** على 366، وعلامةُ الشريحة
/// >     بعدها بفراغ [AuthIconGap.method]؛
/// >   - الرقمُ و«تعديل» على 389: **سطرٌ أزرقُ واحدٌ مسطّح** — المقاسُ نفسُه
/// >     والوزنُ نفسُه واللونُ نفسُه، بلا خطٍّ تحته؛
/// >   - سطرُ الخصوصيّة على 412؛
/// >   - زرّا الطريقة على 503: 193 لكلٍّ، بينهما 4، على x 20 و217.
/// >
/// > وأيقونةُ الزرّ **تركب حافّتَه العليا**: 12 من الداخل و10 فوقها، وخلفَها
/// > مربّعٌ أبيضُ هو ما يقطع الشرطات.
library;

import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:trydos/common/constant/design/xd_design.dart';
import 'package:trydos/common/constant/design/xd_svg.dart';
import 'package:trydos/common/constant/design/xd_ui.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import 'auth_design.dart';
import 'auth_logo.dart';
import 'auth_parts.dart';
import 'enter_phone_screen_v2.dart';

/// طريقتا إيصال الرمز.
enum AuthMethod { whatsapp, sms }

class SelectMethodScreenV2 extends StatelessWidget {
  const SelectMethodScreenV2({
    super.key,
    required this.flow,
    required this.phone,
    required this.onMethod,
    this.method,
    this.onChangeNumber,
    this.onClose,
    this.error,
    this.busy = false,
    this.blocked = false,
  });

  final AuthFlow flow;

  /// الرقمُ كاملاً بمفتاح دولته، بلا «+».
  final String phone;

  final ValueChanged<AuthMethod> onMethod;
  final AuthMethod? method;
  final VoidCallback? onChangeNumber;
  final VoidCallback? onClose;

  /// رسالةُ إرسالٍ فاشل، مترجمةً عند المتّصل.
  final String? error;

  final bool busy;

  /// مُنع الإرسالُ (انتظارٌ أو بلوغُ الحدّ)، فالزرّان باهتان لا يُضغطان.
  final bool blocked;

  /// الدرعُ بعد سطر الخصوصيّة، والفراغُ بين الرقم و«تعديل».
  static const double _shieldGap = 10.5;
  static const double _editGap = 5;

  /// x الزرّين.
  static double _left(AuthMethod kind) => switch (kind) {
    AuthMethod.whatsapp => AuthXd.boxLeft,
    AuthMethod.sms => AuthXd.boxLeft + AuthXd.methodWidth + AuthXd.methodGap,
  };

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
            LocaleKeys.choose_verification_method.tr(),
            size: 16,
            weight: XdWeight.medium,
            maxLines: 2,
          ),
        ),
        Positioned(
          top: AuthXd.headLine3.h,
          left: AuthXd.textLeft.w,
          right: AuthXd.boxLeft.w,
          child: _iconLine(
            text: LocaleKeys.we_will_send_code.tr(),
            size: 12,
            icon: 'sim',
            iconSize: 15,
            gap: AuthIconGap.method,
          ),
        ),
        // الرقمُ و«تعديل»: سطرٌ أزرقُ واحدٌ مسطّح.
        Positioned(
          top: AuthXd.headLine4.h,
          left: AuthXd.textLeft.w,
          right: AuthXd.boxLeft.w,
          child: Row(
            children: <Widget>[
              Flexible(
                child: XdText(
                  '+$phone',
                  size: 12,
                  weight: XdWeight.medium,
                  color: AuthColors.termsLink,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onChangeNumber != null) ...<Widget>[
                SizedBox(width: _editGap.w),
                XdTap(
                  scale: 1,
                  onTap: onChangeNumber,
                  child: XdText(
                    LocaleKeys.edit.tr(),
                    size: 12,
                    weight: XdWeight.medium,
                    color: AuthColors.termsLink,
                  ),
                ),
              ],
            ],
          ),
        ),
        Positioned(
          top: AuthXd.headLine4WithRow.h,
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
        _button(
          kind: AuthMethod.whatsapp,
          icon: 'whatsapp',
          label: LocaleKeys.send_whatsapp.tr(),
        ),
        _button(
          kind: AuthMethod.sms,
          icon: 'sms',
          label: LocaleKeys.send_sms.tr(),
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

  /// زرُّ طريقةٍ: 193 × 60، وأيقونتُه تركب حافّتَه العليا.
  Widget _button({
    required AuthMethod kind,
    required String icon,
    required String label,
  }) {
    final bool selected = method == kind;
    return Positioned(
      top: AuthXd.boxTop.h,
      left: _left(kind).w,
      child: Opacity(
        opacity: blocked ? 0.5 : 1,
        child: XdTap(
          scale: 0.98,
          onTap: busy || blocked ? null : () => onMethod(kind),
          child: SizedBox(
            width: AuthXd.methodWidth.w,
            height: AuthXd.boxHeight.h,
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Positioned.fill(
                  child: DottedBorder(
                    padding: EdgeInsets.zero,
                    borderType: BorderType.RRect,
                    strokeCap: StrokeCap.round,
                    strokeWidth: 0.5,
                    dashPattern: const <double>[3, 3],
                    radius: Radius.circular(AuthXd.boxRadius.r),
                    color: selected && !blocked
                        ? AuthColors.termsLink
                        : XdColors.hint,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: selected
                            ? AuthColors.buttonStarted
                            : Colors.white,
                        borderRadius: BorderRadius.circular(AuthXd.boxRadius.r),
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
                Positioned(
                  top: Xd.gapTo(0, 36, 16).h,
                  left: 0,
                  right: 0,
                  child: XdText(
                    label,
                    size: 16,
                    align: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // الأيقونةُ تركب الحافّة، وخلفَها مربّعٌ أبيضُ يقطع الشرطات.
                PositionedDirectional(
                  start: AuthXd.methodIconLeft.w,
                  top: -AuthXd.methodIconAbove.h,
                  child: ColoredBox(
                    color: Colors.white,
                    child: SvgPicture.asset(
                      'assets/svg/$kAuthSvg/$icon.svg',
                      width: AuthXd.methodIconSize.w,
                      height: AuthXd.methodIconSize.w,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconLine({
    required String text,
    required double size,
    required String icon,
    required double iconSize,
    required double gap,
    Color color = XdColors.ink,
  }) {
    return Row(
      children: <Widget>[
        Flexible(
          child: XdText(
            text,
            size: size,
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
