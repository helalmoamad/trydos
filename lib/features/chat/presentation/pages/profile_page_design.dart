import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../common/constant/design/xd_design.dart';

/// ثوابت تصميم شاشة بروفايل المحادثة، منقولة حرفياً من الويب.
///
/// المصدر: `web_design/components/DemoApp1/screens/ContactScreen.tsx` وثوابت
/// `components/DemoApp/demoLayout.ts`. لوحة XD عرضها 430 ومقاس التصميم عندنا
/// 428، ففارق أقلّ من نصف بالمئة — تُنقل الأرقام كما هي مع `.w` و`.h` و`.sp`
/// بلا معامل تصحيح.
///
/// وهذه الأرقام كلّها من `demoLayout.ts`، ومصدرها الواحد صار
/// `common/constant/design/xd_design.dart` — فما دونه هنا إحالاتٌ إليه، لا
/// نسخةٌ ثانية. تبقى الأسماء كما هي كي لا تُمَسّ مواضع الاستعمال في الدردشة.
abstract class ContactDesign {
  // ---- الألوان (demoLayout.ts → C) ----
  static const Color ink = XdColors.ink;

  /// حبرٌ أخفّ — السطر الثاني في بطاقة ملف أو مكالمة.
  static const Color inkSoft = XdColors.inkSoft;
  static const Color grey = XdColors.grey;

  /// خطوط الفصل والحدود الفاتحة.
  static const Color line = XdColors.line;
  static const Color purple = XdColors.purple;
  static const Color blue = XdColors.blue;
  static const Color card = XdColors.card;
  static const Color red = XdColors.red;

  /// `CHAT.greyText` في `demoChat.ts` — لون كلمات الأسفل.
  static const Color greyText = XdColors.lineDark;

  /// `C.label` — عنوان الحقل الصغير فوق قيمته في نماذج `Field`.
  static const Color label = XdColors.label;

  // ---- الصفوف (demoLayout.ts → ROW) ----
  static const double rowX = XdRow.x;
  static const double rowHeight = 60;
  static const double rowRadius = XdRow.radius;

  /// الفراغ بين صفّين في قائمة المحادثات — من `ChatListScreen` لا من `ROW`.
  static const double rowGap = 2;

  // ---- شريط الحالة المرسوم في اللوحة ----
  static const double statusBar = Xd.statusBar;

  /// خطّ الأساس الذي يخزّنه XD → أعلى صندوق النصّ، لخطّ Quicksand.
  static double textTop(double baseline, double size) =>
      Xd.textTop(baseline, size);

  /// ارتفاع السطر الذي يُبقي خطّ الأساس على `1.0em` تحت أعلى الصندوق.
  static double lineBox(double size) => Xd.lineBox(size);

  /// أسفل صندوق النصّ.
  static double textBottom(double baseline, double size) =>
      Xd.textBottom(baseline, size);

  /// أعلى **فقرةٍ** ارتفاع سطرها غير ارتفاع صندوق الخطّ.
  ///
  /// وبه تُوضع معاينةُ صفّ المحادثة: `paraTop(46, 12, 17)` = 33.
  static double paraTop(double baseline, double size, double lineHeight) =>
      Xd.paraTop(baseline, size, lineHeight);

  /// أعلى صندوق سطرٍ بخطّ SF Pro Rounded.
  static double sfTop(double baseline, double size, double lineHeight) =>
      Xd.sfTop(baseline, size, lineHeight);
}

/// نصّ Quicksand بخطّ أساسٍ مضبوط كما في الويب.
///
/// `leadingDistribution: even` يضع النصّ في وسط صندوق السطر كما تفعل CSS —
/// وبدونه ينزلق خطّ الأساس وتفشل المطابقة مهما ضُبط الهامش.
class DesignText extends StatelessWidget {
  const DesignText(
    this.text, {
    super.key,
    required this.size,
    required this.family,
    this.color = ContactDesign.ink,
    this.center = false,
    this.letterSpacing,
  });

  final String text;
  final double size;
  final String family;
  final Color color;
  final bool center;
  final double? letterSpacing;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: center ? TextAlign.center : null,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: family,
        fontSize: size.sp,
        height: ContactDesign.lineBox(size) / size,
        leadingDistribution: TextLeadingDistribution.even,
        letterSpacing: letterSpacing,
        color: color,
      ),
    );
  }
}

/// أيقونة من ملفات XD المنقولة إلى `assets/svg/chat_v2/`.
class XdIcon extends StatelessWidget {
  const XdIcon(this.name, {super.key, required this.width, this.height});

  final String name;
  final double width;

  /// ارتفاع الأيقونة كما في `xdIcons.ts`. غيابه يعني مربّعاً.
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/svg/chat_v2/$name.svg',
      width: width.w,
      height: (height ?? width).h,
    );
  }
}
