/// شبكة التصميم الجديد، مقروءةً من ملفّ XD — نقلٌ كاملٌ لـ
/// `web_design/components/DemoApp/demoLayout.ts`.
///
/// كلّ رقمٍ هنا بكسلُ تصميمٍ على لوح 430 × 932. والعرض المرن في الويب يرسم
/// بكسل التصميم بكسلاً واحداً من CSS؛ وعندنا يُحوَّل بـ`.w` و`.h` و`.sp` من
/// `flutter_screenutil` (مقاسنا 428 × 923، ففارقٌ أقلّ من نصف بالمئة).
///
/// شريط الحالة
/// -----------
/// كلّ لوحٍ يرسم شريط حالة الهاتف في أعلى 50 بكسلاً منه (الوقت والشبكة
/// والبطّاريّة). والهاتف الحقيقيّ يرسم شريطه، فلا يرسمه التطبيق. فـ[statusBar]
/// هو أعلى التطبيق.
///
/// وهذا الملفّ هو المصدر الواحد لهذه الأرقام. و`ContactDesign` في
/// `features/chat/presentation/pages/profile_page_design.dart` يُحيل إليه،
/// فلا تتفرّق النسخ.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// أرقام اللوح ودوالّ النصّ — `demoLayout.ts`.
abstract class Xd {
  static const double designW = 430;
  static const double designH = 932;

  /// شريط حالة الهاتف الذي يرسمه كلّ لوح في أعلاه.
  static const double statusBar = 50;

  /// خطّ الأساس الذي يخزّنه XD → أعلى صندوق النصّ.
  ///
  /// XD يحفظ **خطّ أساس** النصّ الموضوع. وصاعدُ Quicksand يساوي `1.0em`
  /// بالضبط، فأعلى صندوق CSS هو الأساس ناقص مقاس الخطّ.
  static double textTop(double baseline, double size) => baseline - size;

  /// ارتفاع السطر الذي يُبقي خطّ أساس النصّ على `1.0em` تحت أعلى صندوقه.
  ///
  /// `line-height: 1.25` صحيحٌ على الورق، لكنّ المتصفّحات تُقرّب النازل
  /// (`0.25em`) إلى بكسلٍ كامل أوّلاً، فيصير نصفُ الرصّ سالباً عند 10 و11 و14
  /// و15 و18، فيُرسم النصّ أعلى بكسلاً ممّا يضعه الملفّ. وصندوقُ سطرٍ يساوي
  /// الصاعد المقرَّب زائد النازل بلا رصٍّ يضع الأساس حيث يضعه الملفّ، بكلّ
  /// مقاس.
  static double lineBox(double size) => size + (size / 4).round();

  /// حيث ينتهي صندوق سطر النصّ على اللوح.
  static double textBottom(double baseline, double size) =>
      textTop(baseline, size) + lineBox(size);

  /// الهامش فوق نصٍّ ليحلّ خطُّ أساسه على `baseline` من الملفّ، والكتلةُ التي
  /// فوقه تنتهي على `above`.
  static double gapTo(double above, double baseline, double size) =>
      textTop(baseline, size) - above;

  /// أعلى صندوق **فقرةٍ** ارتفاع سطرها `lineHeight`، من خطّ أساس سطرها الأوّل.
  ///
  /// ارتفاع السطر الزائد يُوزَّع فوق النصّ وتحته، فيهبط الأساس الأوّل بنصفه.
  static double paraTop(double baseline, double size, double lineHeight) =>
      textTop(baseline, size) - (lineHeight - lineBox(size)) / 2;

  /// أعلى صندوق سطرٍ بخطّ SF Pro Rounded.
  ///
  /// صاعد SF Pro يساوي `0.952em` ونازله `0.241em`، ويُقرَّب كلٌّ منهما إلى
  /// بكسلٍ كامل ثمّ يُقسَم ما تبقّى من السطر فوقهما وتحتهما.
  static double sfTop(double baseline, double size, double lineHeight) {
    final double ascent = (0.952 * size).roundToDouble();
    final double descent = (0.241 * size).roundToDouble();
    return baseline - ((lineHeight - (ascent + descent)) / 2 + ascent);
  }

  /// عرضٌ يُبقي `left` إلى الحافّة اليسرى و`right` إلى اليمنى — `fill` في
  /// `demo1Layout.ts`. على شاشة 430 يُعيد عرض الملفّ نفسه: `fill(20)` = 390.
  static double fill(double left, [double? right]) =>
      1.sw - (left + (right ?? left)).w;

  /// العرض الذي يرسمه الملفّ `w` على `left` من لوح 430، مرناً: يُبقي مسافة
  /// الملفّ إلى الحافّتين — `fillFrom`.
  static double fillFrom(double left, double w) =>
      fill(left, designW - left - w);

  /// الهامشُ الأيسر الذي يُبقي كتلةً على مسافة الملفّ من **مركز** الشاشة —
  /// `fromCentre` في `ui.tsx`: `calc(50% + (x − 430/2)px)`.
  ///
  /// تستعمله الكتلُ التي يُوسّطها الملفُّ ولا تتمدّد: الرموز والعلامات
  /// وصفوفُ الإجراءات.
  static double fromCentre(double x) => 1.sw / 2 + (x - designW / 2).w;
}

/// الألوان التي يستعملها التصميم، بأسماء وظائفها — `C` في `demoLayout.ts`.
abstract class XdColors {
  static const Color ink = Color(0xFF1D1D1D);
  static const Color inkSoft = Color(0xFF404040);
  static const Color label = Color(0xFF505050);
  static const Color grey = Color(0xFF8D8D8D);
  static const Color hint = Color(0xFFC3C3C3);
  static const Color line = Color(0xFFD3D3D3);
  static const Color placeholder = Color(0xFFD3D3D3);
  static const Color purple = Color(0xFF4A31E7);

  /// البنفسجيّ الباهت خلف «موصى به» في نافذة السحب.
  static const Color purpleTint = Color(0xFFF5F4FF);

  /// التبويب المختار في نموذج السحب.
  static const Color green = Color(0xFF79E9B3);
  static const Color blue = Color(0xFF388CFF);

  /// خطّ حقل المبلغ حين لا يكفي الرصيد (`Home Page – 20`).
  static const Color orange = Color(0xFFF4BB7A);

  /// خلف «رصيدك غير كافٍ» (`– 20`).
  static const Color orangeTint = Color(0xFFFFF8F4);

  /// خلف «لا يستلم المبلغ إلّا المذكور اسمه !» (`– 27`).
  static const Color noteTint = Color(0xFFFFF8F2);

  /// الخطّ المتقطّع لزرّ «رجوع» (`– 30`).
  static const Color lineDark = Color(0xFF5D5C5D);

  /// التبويب المختار ووسم الشبكة في نافذة الإيداع (`– 26`، `– 33`، `– 37`).
  static const Color yellow = Color(0xFFFAE26B);

  /// «أوافق» والوقت المتبقّي على رمز العملة (`– 39`، `– 37`).
  static const Color cryptoBlue = Color(0xFF3066CC);

  /// خطّ «أوافق» (`– 39`).
  static const Color agreeLine = Color(0xFF3EAA72);

  /// الخطّ حول نافذةٍ تقع فوق نافذةٍ أخرى (`– 39`).
  static const Color sheetEdge = Color(0xFF707070);

  /// حلقات قائمة السلامة ونصّها الصغير (`– 39`).
  static const Color ring = Color(0xFF8E8E8E);

  /// نقاط قائمة السلامة: تمّ (أخضر) واحترس (كهرمانيّ).
  static const Color safeGreen = Color(0xFF00DD80);
  static const Color safeAmber = Color(0xFFF2B835);

  /// أسطر انتهاء رمز العملة (`– 37`، `– 38`).
  static const Color expiry = Color(0xFFF4780E);
  static const Color red = Color(0xFFFF5F61);

  /// الخطّ حول بطاقة المحفظة في الدفع حين لا يغطّي الرصيد السلّة
  /// (`Home Page – 83`).
  static const Color lowBalance = Color(0xFFFF7F00);

  static const Color card = Color(0xFFFCFCFC);
  static const Color field = Color(0xFFF8F8F8);
  static const Color page = Color(0xFFFCFCFC);
  static const Color white = Color(0xFFFFFFFF);
  static const Color backdrop = Color(0xE51D1D1D);

  /// خلف الإيصال: `#1D1D1D` بنصف شفافيّة، فوق تمويه خلفيّة الملفّ.
  static const Color backdropGlass = Color(0x801D1D1D);
}

/// الترويسة التي لكلّ شاشةٍ داخليّة: شريطٌ أبيض 50 تحت شريط الحالة — `HEADER`.
abstract class XdHeader {
  static const double y = 50;
  static const double height = 50;

  /// سهم الرجوع، 12 × 21 على (23.5، 64.5).
  static const double backX = 23.5;
  static const double backY = 64.5;

  /// خطّ أساس العنوان. 16 Medium لكلمةٍ واحدة، و14 لـ«الملف | …».
  static const double titleBaseline = 81;
  static const double crumbBaseline = 80;

  /// إجراء اليمين («إلغاء»، «تعديل»)، 16 Light، ينتهي 30 عن الحافّة.
  static const double actionRight = 30;
}

/// حيث يبدأ المحتوى تحت الترويسة — `BODY_Y`.
const double kXdBodyY = XdHeader.y + XdHeader.height;

/// الشريط الرماديّ تحت الترويسة في نماذج الملفّ — `BANNER`.
abstract class XdBanner {
  static const double y = 100;
  static const double height = 48;
}

/// الزرّ العريض أسفل نموذج: 390 × 60 على (20، 836)، 36 فوق الأسفل — `CTA`.
abstract class XdCta {
  static const double x = 20;
  static const double y = 836;
  static const double width = 390;
  static const double height = 60;
  static const double radius = 20;
}

/// الصفوف والبطاقات — `ROW`.
abstract class XdRow {
  static const double x = 12;
  static const double width = 406;
  static const double radius = 15;
}

/// النوافذ السفليّة — `SHEET`.
abstract class XdSheet {
  static const double radius = 30;

  /// نوافذ المحفظة (`Home Page – 21`، `– 19`) زواياها أكثر استدارة.
  static const double radiusWallet = 50;
  static const double handleWidth = 40;
  static const double handleTop = 12;
  static const double handleHeight = 2;

  /// والنافذةُ ترسمه على `handleTop − 1`، فينتهي 13 تحت حافّتها العليا —
  /// وعليه تُحسب هوامشُ أوّل كتلةٍ في كلّ لوح. وعرضُه 40 بطرفين مستديرين،
  /// فصندوقُه 42.
  static const double handleBoxTop = handleTop - 1;
  static const double handleBoxWidth = handleWidth + handleHeight;
  static const double handleEnd = handleBoxTop + handleHeight;

  /// رماديُّ المقبض في الملفّ.
  static const Color handleColor = Color(0xFFC4C2C2);

  /// شريطُ السحب في أعلى النافذة — `grip` في `Sheet`: 50 بعرضها، يُغلقها
  /// سحبُه إلى أسفل. والمقبضُ خطٌّ 2 لا يُلمس، فالشريطُ هو هدفُ الإصبع.
  static const double gripHeight = 50;

  /// النافذةُ تتبع الإصبعَ بستّة أعشار ما سحب، ولا تصعد فوق موضعها —
  /// `dragElastic: {top: 0, bottom: 0.6}`.
  static const double dragFollow = 0.6;

  /// وتُغلق إن جاوز السحبُ 120 بكسلاً أو جاوزت السرعةُ 600 — `onDragEnd`.
  static const double dragClose = 120;
  static const double dragFling = 600;
}

/// الانزلاق نفسه الذي يستعمله تسجيل الدخول بين شاشاته — `SCREEN_TRANSITION`.
abstract class XdTransition {
  static const Duration duration = Duration(milliseconds: 350);
  static const Cubic ease = Cubic(0.4, 0, 0.2, 1);
}
