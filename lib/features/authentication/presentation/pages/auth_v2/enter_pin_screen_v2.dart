/// «أدخل الرمز» — نقلٌ لـ`web_design/NewLoginDesign/NewEnterPinScreen.tsx`.
///
/// > من أعلى إلى أسفل:
/// >   - إكسُ الإغلاق، والشعارُ على 116، والعنوانُ على 288؛
/// >   - «أدخل رمز التحقّق المرسل إلى …» 16 Medium على 338؛
/// >   - «أرسلنا رمز التحقّق إلى الرقم» 12 على 366، وعلامةُ الشريحة بعدها
/// >     بفراغ [AuthIconGap.code]؛
/// >   - الرقمُ على 389 عند حافّة النصّ، و**التلميحُ بعده على x ثابت** 146 —
/// >     لا بفراغ، لأنّ طولَ الرقم يتبدّل بالدولة. وقد قُرئ من اللوح: الرقمُ
/// >     ينتهي على 141.1 وهذا أوّلُ ما يليه في الصفّ؛
/// >   - وحين يحلّ وقتُ الإعادة: صفُّ «أعد الإرسال أو غيّر الرقم أو الطريقة»
/// >     على 412 — سطرٌ أزرقُ واحدٌ مسطّح؛
/// >   - سطرُ الخصوصيّة: على 412 عادةً، وعلى **435** حين يظهر صفُّ الإعادة
/// >     فوقه (لوح `Registration - 16`)؛
/// >   - صناديقُ الرمز على 503، وترتفع إلى **493** في حالَي الخطأ والانتهاء،
/// >     وتحتها الرسالةُ على 561.
library;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:trydos/common/constant/design/xd_design.dart';
import 'package:trydos/common/constant/design/xd_svg.dart';
import 'package:trydos/common/constant/design/xd_ui.dart';
import 'package:trydos/features/wallet/presentation/pages/wallet_pin_boxes.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import 'auth_design.dart';
import 'auth_logo.dart';
import 'auth_parts.dart';
import 'enter_phone_screen_v2.dart';
import 'select_method_screen_v2.dart';

class EnterPinScreenV2 extends StatelessWidget {
  const EnterPinScreenV2({
    super.key,
    required this.flow,
    required this.phone,
    required this.method,
    required this.onComplete,
    required this.secondsLeft,
    this.onResend,
    this.onChangeNumber,
    this.onChangeMethod,
    this.onClose,
    this.error,
    this.state = WalletPinState.typing,
    this.expired = false,
  });

  final AuthFlow flow;

  /// الرقمُ كاملاً بمفتاح دولته، بلا «+».
  final String phone;

  final AuthMethod method;

  /// اكتملت الأرقامُ الستّة.
  final ValueChanged<String> onComplete;

  /// ما بقي من مهلة الإعادة بالثواني. والصفرُ يُظهر صفَّ الإعادة.
  final int secondsLeft;

  final VoidCallback? onResend;
  final VoidCallback? onChangeNumber;
  final VoidCallback? onChangeMethod;
  final VoidCallback? onClose;

  /// رسالةُ تحقّقٍ فاشل، مترجمةً عند المتّصل.
  final String? error;

  final WalletPinState state;

  /// انتهت مدّةُ الرمز.
  final bool expired;

  /// حيث يبدأ التلميحُ الرماديُّ بعد الرقم — `HINT_LEFT`.
  static const double hintLeft = 146;

  /// فراغاتُ الصفوف.
  static const double _hintGap = 11.6;
  static const double _shieldGap = 10.5;
  static const double _linkGap = 5;

  bool get _canAskAgain => secondsLeft <= 0;

  /// لوحا الخطأ والانتهاء يرفعان صفَّ الرمز ويضعان رسالةً تحته. وما سواهما
  /// يترك الصفَّ على 503.
  bool get _lifted => expired || state == WalletPinState.invalid;

  String get _clock {
    final String m = (secondsLeft ~/ 60).toString().padLeft(2, '0');
    final String s = (secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final String methodLabel = method == AuthMethod.whatsapp
        ? LocaleKeys.whatsApp.tr()
        : LocaleKeys.sms.tr();
    // صفُّ الإعادة صفٌّ قائمٌ بذاته، فيدفع سطرَ الخصوصيّة إلى أسفل — وهو ما
    // يُظهره لوحُ الرمز المنتهي بالضبط.
    final double privacyTop = _canAskAgain
        ? AuthXd.headLine4Expired
        : AuthXd.headLine4WithRow;

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
            '${LocaleKeys.enter_verification_code_sent_to_your.tr()} '
            '$methodLabel',
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
            text: LocaleKeys.we_have_sent_a_verification_code_to_the_number
                .tr(),
            size: 12,
            icon: 'sim',
            iconSize: 15,
            gap: AuthIconGap.code,
          ),
        ),
        // الرقمُ عند حافّة النصّ.
        Positioned(
          top: AuthXd.headLine4.h,
          left: AuthXd.textLeft.w,
          child: XdText('+$phone', size: 12),
        ),
        // والتلميحُ بعده على x ثابتٍ لا بفراغ.
        Positioned(
          top: AuthXd.headLine4.h,
          left: hintLeft.w,
          right: AuthXd.boxLeft.w,
          child: _iconLine(
            text: _canAskAgain
                ? LocaleKeys.didnt_receive_code.tr()
                : '${LocaleKeys.resend_after_dash.tr()} $_clock',
            size: 12,
            color: XdColors.hint,
            icon: 'info',
            iconSize: 15,
            gap: _hintGap,
          ),
        ),
        if (_canAskAgain)
          Positioned(
            top: AuthXd.headLine4WithRow.h,
            left: AuthXd.textLeft.w,
            right: AuthXd.boxLeft.w,
            child: _resendRow(),
          ),
        Positioned(
          top: privacyTop.h,
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
          top: (_lifted ? AuthXd.boxTopLifted : AuthXd.boxTop).h,
          left: AuthXd.boxLeft.w,
          child: WalletPinBoxes(
            state: expired ? WalletPinState.expired : state,
            onComplete: onComplete,
          ),
        ),
        if (expired)
          _message(LocaleKeys.the_code_sent_has_expired.tr(), XdColors.ink)
        else if (error != null && error!.isNotEmpty)
          _message(error!, XdColors.red),
      ],
    );
  }

  /// الرسالةُ تحت صناديق الرمز، على 561.
  Widget _message(String text, Color color) => Positioned(
    top: AuthXd.otpMessageTop.h,
    left: AuthXd.boxLeft.w,
    right: AuthXd.boxLeft.w,
    child: XdText(
      text,
      size: 11,
      weight: XdWeight.medium,
      color: color,
      align: TextAlign.center,
      maxLines: 3,
    ),
  );

  /// صفُّ «أعد الإرسال أو غيّر الرقم أو الطريقة» — سطرٌ أزرقُ واحدٌ مسطّح:
  /// مقاسٌ واحدٌ ووزنٌ واحدٌ ولونٌ واحد، بلا خطٍّ تحت شيءٍ منه.
  Widget _resendRow() {
    Widget link(String text, VoidCallback? onTap) => XdTap(
      scale: 1,
      onTap: onTap,
      child: XdText(
        text,
        size: 12,
        weight: XdWeight.medium,
        color: AuthColors.termsLink,
      ),
    );
    Widget or() => Padding(
      padding: EdgeInsets.symmetric(horizontal: _linkGap.w),
      child: XdText(
        LocaleKeys.or.tr(),
        size: 12,
        weight: XdWeight.medium,
        color: AuthColors.termsLink,
      ),
    );

    return Row(
      children: <Widget>[
        link(LocaleKeys.resend_code.tr(), onResend),
        if (onChangeNumber != null) ...<Widget>[
          or(),
          link(LocaleKeys.change_number_link.tr(), onChangeNumber),
        ],
        if (onChangeMethod != null) ...<Widget>[
          or(),
          link(LocaleKeys.method_link.tr(), onChangeMethod),
        ],
      ],
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
