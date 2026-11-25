/// القطعُ التي تتقاسمها شاشاتُ الدخول — نقلٌ لما تكرّره ملفّاتُ
/// `web_design/NewLoginDesign/New*Screen.tsx`.
///
/// > والشاشةُ هناك لوحٌ مطلقُ المواضع: كلُّ كتلةٍ على `top` من الملفّ، لأنّ
/// > المصمّمَ لا يُباعد بين الكتل بانتظامٍ ولا تُعيد ذلك سلسلةُ هوامش. فهي
/// > هنا `Stack` بمواضعَ مثلها، لا عمودٌ بهوامش.
library;

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:trydos/common/constant/design/xd_design.dart';
import 'package:trydos/common/constant/design/xd_svg.dart';
import 'package:trydos/common/constant/design/xd_ui.dart';

import 'auth_design.dart';
import 'auth_logo.dart';

/// ألوانُ شاشات الدخول التي لا تُشبه ألوانَ بقيّة التطبيق.
abstract class AuthColors {
  /// الخطُّ المتقطّع في الزرّ، ولونُ كلماته في «ابدأ».
  static const Color dash = Color(0xFF5D5C5D);

  /// أرضيّةُ زرّ «ابدأ».
  static const Color buttonStarted = Color(0xFFFCFCFC);

  /// أرضيّةُ زرّ «أوافق وأتابع» وكلماتُه.
  static const Color buttonAgree = Color(0xFFFAFAFA);
  static const Color buttonAgreeInk = Color(0xFF3C3C3C);

  /// الرابطُ أسفلَ الشاشة.
  static const Color link = Color(0xFF4D84FF);

  /// رابطُ «شروط الخدمة» في شاشة الشروط.
  static const Color termsLink = Color(0xFF388CFF);
}

/// لوحُ شاشةٍ: أرضيّةٌ بيضاء ومواضعُ مطلقةٌ كما في الملفّ.
class AuthBoard extends StatelessWidget {
  const AuthBoard({super.key, required this.children, this.bg = Colors.white});

  final List<Widget> children;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: bg,
      child: SizedBox.expand(child: Stack(children: children)),
    );
  }
}

/// زرُّ الزاوية العليا: إكسُ الإغلاق أو ماسحُ QR — `XD.control`.
class AuthCorner extends StatelessWidget {
  const AuthCorner({
    super.key,
    required this.icon,
    required this.size,
    required this.onTap,
    required this.semantics,
  });

  final String icon;
  final double size;
  final VoidCallback onTap;
  final String semantics;

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      top: AuthXd.controlTop.h,
      end: AuthXd.controlRight.w,
      child: Semantics(
        button: true,
        label: semantics,
        child: XdTap(
          scale: 0.92,
          onTap: onTap,
          child: SvgPicture.asset(
            'assets/svg/$kAuthSvg/$icon.svg',
            width: size.w,
            height: size.w,
          ),
        ),
      ),
    );
  }
}

/// الزرُّ العريض: 390 × 60 على x 20 بزاوية 20، وكلماتُه 16 على 20 من أعلاه —
/// فتحلّ في وسطه.
///
/// وخطُّه المتقطّع خطُّ الملفّ الواحد: **0.5 عرضاً، 3 ظاهرٌ و3 فارغ، داخلَ
/// الصندوق**. والويبُ يرسمه SVG لا `border: dashed` لأنّ المتصفّح يختار طولَ
/// الشرطة من عرض الخطّ فيُخرج شرطاتٍ 1.5 — وهنا `DottedBorder` للسبب نفسه.
class AuthWideButton extends StatelessWidget {
  const AuthWideButton({
    super.key,
    required this.top,
    required this.label,
    required this.onTap,
    this.fill = AuthColors.buttonStarted,
    this.ink = AuthColors.dash,
    this.dashed = true,
    this.dashColor = AuthColors.dash,
    this.tracking = 0,
  });

  /// y أعلى الزرّ على الشاشة، محسوبةً من أسفلها ([authFromBottom]).
  final double top;

  final String label;
  final VoidCallback? onTap;
  final Color fill;
  final Color ink;
  final bool dashed;

  /// لونُ الخطّ المتقطّع — `#707070` في لوحَي النتيجة.
  final Color dashColor;

  /// التباعدُ الحرفيُّ بالـem — [kAuthWideTracking] لثلاث كلماتٍ لا غير.
  final double tracking;

  @override
  Widget build(BuildContext context) => Positioned(
    top: top,
    left: AuthXd.boxLeft.w,
    child: AuthWideBody(
      label: label,
      onTap: onTap,
      fill: fill,
      ink: ink,
      dashed: dashed,
      dashColor: dashColor,
      tracking: tracking,
    ),
  );
}

/// جسمُ الزرّ العريض وحدَه: 390×60 بنصف قطر 20، وكلماتُه 16 على 20 من أعلاه.
///
/// [AuthWideButton] تضعه على y من الملفّ في `Stack`؛ ونافذةُ طلب الدخول
/// تضعه في عمودها — والأرقامُ واحدةٌ في اللوحين.
class AuthWideBody extends StatelessWidget {
  const AuthWideBody({
    super.key,
    required this.label,
    required this.onTap,
    this.fill = AuthColors.buttonStarted,
    this.ink = AuthColors.dash,
    this.dashed = true,
    this.dashColor = AuthColors.dash,
    this.tracking = 0,
  });

  final String label;
  final VoidCallback? onTap;
  final Color fill;
  final Color ink;
  final bool dashed;
  final Color dashColor;
  final double tracking;

  @override
  Widget build(BuildContext context) {
    final Widget body = Container(
      width: Xd.fill(AuthXd.boxLeft),
      height: AuthXd.boxHeight.h,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(AuthXd.boxRadius.r),
      ),
      child: Column(
        children: <Widget>[
          // الكلماتُ على 20 من أعلى الزرّ: صندوقُ سطرِ 16 طولُه 20، فتحلّ
          // في وسط الستّين.
          Padding(
            padding: EdgeInsets.only(top: Xd.gapTo(0, 36, 16).h),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: xdTextStyle(
                  size: 16,
                  color: ink,
                ).copyWith(letterSpacing: tracking * 16),
              ),
            ),
          ),
        ],
      ),
    );
    return XdTap(
      scale: 0.98,
      onTap: onTap,
      child: dashed
          ? DottedBorder(
              padding: EdgeInsets.zero,
              borderType: BorderType.RRect,
              strokeCap: StrokeCap.round,
              strokeWidth: 0.5,
              dashPattern: const <double>[3, 3],
              radius: Radius.circular(AuthXd.boxRadius.r),
              color: dashColor,
              child: body,
            )
          : body,
    );
  }
}

/// سطرٌ موسَّطٌ على عرض الشاشة، بخطّ أساسٍ من الملفّ.
class AuthCentredLine extends StatelessWidget {
  const AuthCentredLine({
    super.key,
    required this.top,
    required this.text,
    required this.size,
    this.weight = XdWeight.regular,
    this.color = XdColors.ink,
    this.onTap,
    this.maxLines = 1,
    this.tracking = 0,
  });

  /// y أعلى صندوق السطر على الشاشة.
  final double top;

  final String text;
  final double size;
  final XdWeight weight;
  final Color color;
  final VoidCallback? onTap;
  final int maxLines;

  /// التباعدُ الحرفيُّ بالـem — [kAuthWideTracking] لثلاث كلماتٍ لا غير.
  final double tracking;

  @override
  Widget build(BuildContext context) {
    final Widget line = SizedBox(
      width: double.infinity,
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: xdTextStyle(
          size: size,
          weight: weight,
          color: color,
        ).copyWith(letterSpacing: tracking * size),
      ),
    );
    return Positioned(
      top: top,
      left: 0,
      right: 0,
      child: onTap == null ? line : XdTap(scale: 1, onTap: onTap, child: line),
    );
  }
}
