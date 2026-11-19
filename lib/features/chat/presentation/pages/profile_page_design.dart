import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// ثوابت تصميم شاشة بروفايل المحادثة، منقولة حرفياً من الويب.
///
/// المصدر: `web_design/components/DemoApp1/screens/ContactScreen.tsx` وثوابت
/// `components/DemoApp/demoLayout.ts`. لوحة XD عرضها 430 ومقاس التصميم عندنا
/// 428، ففارق أقلّ من نصف بالمئة — تُنقل الأرقام كما هي مع `.w` و`.h` و`.sp`
/// بلا معامل تصحيح.
abstract class ContactDesign {
  // ---- الألوان (demoLayout.ts → C) ----
  static const Color ink = Color(0xFF1D1D1D);

  /// حبرٌ أخفّ — السطر الثاني في بطاقة ملف أو مكالمة.
  static const Color inkSoft = Color(0xFF404040);
  static const Color grey = Color(0xFF8D8D8D);

  /// خطوط الفصل والحدود الفاتحة.
  static const Color line = Color(0xFFD3D3D3);
  static const Color purple = Color(0xFF4A31E7);
  static const Color blue = Color(0xFF388CFF);
  static const Color card = Color(0xFFFCFCFC);
  static const Color red = Color(0xFFFF5F61);

  /// `CHAT.greyText` في `demoChat.ts` — لون كلمات الأسفل.
  static const Color greyText = Color(0xFF5D5C5D);

  /// `C.label` — عنوان الحقل الصغير فوق قيمته في نماذج `Field`.
  static const Color label = Color(0xFF505050);

  // ---- الصفوف (demoLayout.ts → ROW) ----
  static const double rowX = 12;
  static const double rowHeight = 60;
  static const double rowRadius = 15;
  static const double rowGap = 2;

  // ---- شريط الحالة المرسوم في اللوحة ----
  static const double statusBar = 50;

  /// خطّ الأساس الذي يخزّنه XD → أعلى صندوق النصّ، لخطّ Quicksand.
  ///
  /// صاعد Quicksand يساوي `1.0em` بالضبط، فأعلى الصندوق هو الأساس ناقص
  /// مقاس الخطّ. هذا تعريف `textTop` في الويب حرفياً.
  static double textTop(double baseline, double size) => baseline - size;

  /// ارتفاع السطر الذي يُبقي خطّ الأساس على `1.0em` تحت أعلى الصندوق.
  static double lineBox(double size) => size + (size / 4).round();

  /// أسفل صندوق النصّ.
  static double textBottom(double baseline, double size) =>
      textTop(baseline, size) + lineBox(size);

  /// أعلى **فقرةٍ** ارتفاع سطرها غير ارتفاع صندوق الخطّ.
  ///
  /// سطرٌ أطول من صندوقه يوزّع الزيادة فوقه وتحته بالتساوي، فيهبط خطُّ الأساس
  /// بنصفها — فيُرفع أعلى الفقرة بنفس النصف ليعود الأساس إلى موضعه. هذا
  /// تعريف `paraTop` في الويب حرفياً، وبه تُوضع معاينةُ صفّ المحادثة:
  /// `paraTop(46, 12, 17)` = 33.
  static double paraTop(double baseline, double size, double lineHeight) =>
      textTop(baseline, size) - (lineHeight - lineBox(size)) / 2;

  /// أعلى صندوق سطرٍ بخطّ SF Pro Rounded.
  ///
  /// صاعد SF Pro يساوي `0.952em` ونازله `0.241em`، ويُقرَّب كلٌّ منهما إلى
  /// بكسل كامل ثم يُقسَم ما تبقّى من السطر فوقه وتحته. هذا تعريف `sfTop`.
  static double sfTop(double baseline, double size, double lineHeight) {
    final double ascent = (0.952 * size).roundToDouble();
    final double descent = (0.241 * size).roundToDouble();
    return baseline - ((lineHeight - (ascent + descent)) / 2 + ascent);
  }
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
