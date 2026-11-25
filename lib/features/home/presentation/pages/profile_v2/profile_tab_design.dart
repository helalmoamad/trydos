/// أرقام تبويب الملفّ وألوانه، منقولةً حرفياً عن
/// `web_design/components/DemoApp1/screens/ProfileScreen.tsx`.
///
/// لوح XD: `Home Page – 9`، اللوح الطويل الوحيد (430 × 1129).
///
/// > الصفحة كلّها تُمرَّر، والشعار معها؛ ولا يثبت إلّا الشريط السفليّ. وكلّ y
/// > أدناه من الملفّ. تفتح الصفحة على:
/// >   - الشعار (23.5، 69.5) ومفتاحَي الويب والقفل على يمينه؛
/// >   - بطاقة العميل 406 × 140 على (12، 124): رمز QR والمعرّف والاسم والهاتف
/// >     والعنوان، ومربّع الصورة بشريطه الداكن «أضف صورة»؛
/// >   - ثلاث بطاقاتٍ 406 × 108 تُمرَّر أفقياً على y 268، بينها 4، والثانية
/// >     تُطلّ من الحافّة اليمنى؛
/// >   - الطلبات ومحفظة Trydos، 201 × 94، جنباً إلى جنب على y 380؛
/// >   - القائمة: ثمانية صفوفٍ 60، أيقوناتها 18 على x 24 ونصّها على x 54.
///
/// وكلّ كتلةٍ تبعد عمّا فوقها بفراغ الملفّ نفسه (انظر [menu] للصفّ الوحيد
/// الذي يُراكبه الملفّ).
library;

import 'package:flutter/material.dart';

import 'package:trydos/main.dart' show kDesignV2;

/// تبويب الملفّ بالتصميم الجديد — من مفتاح التصميم الواحد في `main.dart`
/// ([kDesignV2]). يُطفأ فتعود الصفحة القديمة كما هي — لم تُحذف، بل بقي
/// الفرع الآخر في `profile_page.dart`.
///
/// وتغيب معها بطاقةُ المحفظة، فمدخلُ `WalletPageV2` فيها وحدَها.
const bool kProfileDesignV2 = kDesignV2;

/// مجلّد أيقونات هذه الشاشة تحت `assets/svg/`.
const String kProfileSvg = 'profile_v2';

/// أرقام تبويب الملفّ.
abstract class ProfileTabDesign {
  /// ارتفاع اللوح: الصفحة لا تقصر عنه.
  static const double contentHeight = 1129;

  /// حيث يبدأ المحتوى — `scrollTop` في `ScreenPage`.
  static const double scrollTop = 50;

  // ---- الصفّ الأعلى ----

  /// الشعار على (23.49، 69.5)، 85.5 × 43.
  static const double wordmarkX = 23.49;
  static const double wordmarkY = 69.5;
  static const double wordmarkW = 85.5;
  static const double wordmarkH = 43;

  /// مفتاحان 26 عرضاً و44 طولاً، على x 335.49 و380.49، وأيقونتهما 25.99.
  static const double switchW = 26;
  static const double switchH = 44;
  static const double switchIcon = 25.99;

  /// خطّ أساس نصّ المفتاح، 10 بكسلاً.
  static const double switchLabelBaseline = 109;
  static const double switchLabelSize = 10;

  // ---- بطاقة العميل ----

  /// 406 × 140 على (12، 124)، 12 عن الحافّتين.
  static const double cardY = 124;
  static const double cardH = 140;
  static const double cardPad = 12;
  static const double cardRadius = 15;

  /// رمز QR، 50 × 50.
  static const double qr = 50;

  /// خطّا أساس المعرّف والاسم، 13 بكسلاً.
  static const double idBaseline = 207;
  static const double nameBaseline = 229;
  static const double idSize = 13;

  /// الهاتف والعنوان: علامتان 14 على x 24 و147، y 238، ونصُّهما 11 بعد كلٍّ
  /// منهما بـ6، على خطّ الأساس 249.
  static const double markY = 238;
  static const double markSize = 14;
  static const double markGap = 6;
  static const double phoneSlot = 147 - 24;
  static const double lineSize = 11;

  /// مربّع الصورة، 116 × 115 على (290، 136): 12 نزولاً و12 عن حافّة البطاقة
  /// اليمنى. ليس مربّعاً تماماً، والشريط الداكن على 230 ينتهي 1 تحته.
  static const double photoW = 116;
  static const double photoH = 115;

  /// رمز المستخدم، 73.99 × 87.49 على (21، 13.75) من المربّع.
  static const double avatarW = 73.99;
  static const double avatarH = 87.49;
  static const double avatarX = 21;
  static const double avatarY = 13.75;

  /// الشريط الداكن: 22 طولاً من y 94، يغطّي آخر 7.24 من الرمز كما رُسم.
  static const double stripY = 94;
  static const double stripH = 22;

  /// علامة «أضف صورة» 13 على (26، 5)، ونصُّها 10 على x 43.
  static const double addPhotoIcon = 13;
  static const double addPhotoIconX = 26;
  static const double addPhotoIconY = 5;
  static const double addPhotoTextX = 43;
  static const double addPhotoSize = 10;

  // ---- بطاقتا الطلبات والمحفظة ----

  /// 201 × 94 على y 380، بينهما 4. تتقاسمان الصفّ الذي يُبقي 12 عن الحافّتين.
  static const double statH = 94;
  static const double statGap = 4;
  static const double statIcon = 30;

  /// خطّا الأساس 61 و81 في البطاقة.
  static const double statTitleBaseline = 61;
  static const double statTitleSize = 13;
  static const double statValueBaseline = 81;
  static const double statValueSize = 11;

  // ---- بطاقات العروض ----

  /// الفراغ بين بطاقتين — `PROMO_GAP`.
  static const double promoGap = 4;

  /// «Scroll Group 88» في الملفّ: ثلاث بطاقاتٍ 406 × 108 على y 268.
  static const double promoH = 108;

  /// في البطاقة: علامة 14 على (12، 12)، والعنوان 11 Medium من x 32 على خطّ
  /// الأساس 23، وعلامة المساعدة (15) على (379.5، 11.5)، والنصّ على خطّ
  /// الأساس 43، والزرّ 382 × 38 على (12، 58).
  static const double promoPad = 12;
  static const double promoIcon = 14;
  static const double promoTitleX = 32;
  static const double promoTitleBaseline = 23;
  static const double promoTitleSize = 11;
  static const double promoHelp = 14.99;

  /// علامة المساعدة تُبقي 11.5 عن حافّة البطاقة اليمنى، وهي أعلى من العنوان
  /// بنصف بكسل وأطول منه ببكسل.
  static const double promoHelpRight = 406 - 394.5;
  static const double promoTextBaseline = 43;
  static const double promoButtonY = 58;
  static const double promoButtonH = 38;
  static const double promoButtonW = 382;

  /// نابض الانتقال بين البطاقات.
  static const double promoStiffness = 260;
  static const double promoDamping = 32;

  /// نفضةٌ تزيد سرعتُها على هذا تدفع البطاقة نصفَ خطوةٍ إلى الأمام.
  static const double promoFlick = 400;

  /// جرُّ ما بعد الطرفين — `dragElastic`.
  static const double promoElastic = 0.15;

  // ---- القائمة ----

  /// صفوف القائمة، 60 طولاً، من y 486 (12 تحت الطلبات والمحفظة)، بينها 4 —
  /// إلّا «من نحن»، فالملفّ يضعها 58 تحت «المعلومات القانونيّة»: يتراكب
  /// الصفّان بكسلين لا يُرَيان على الأبيض، فهامشها -2.
  static const double rowH = 60;
  static const double rowIcon = 18;
  static const double rowTextX = 54;
  static const double rowTextSize = 14;
}

/// بطاقة عرضٍ في الشريط الأفقيّ — `Promo` في الويب.
class ProfilePromo {
  const ProfilePromo({
    required this.bg,
    required this.button,
    required this.contentX,
    required this.buttonX,
    this.icon,
    this.buttonIcon,
    required this.title,
    required this.text,
    required this.action,
    this.hideWhenVerified = false,
  });

  final Color bg;
  final Color button;

  /// حيث يبدأ محتوى الزرّ، من حافّته اليسرى (الملفّ لا يُوسّطه).
  final double contentX;

  /// حافّة الزرّ اليسرى في البطاقة: 12 في الأولى و13 في الأخريين.
  final double buttonX;

  final String? icon;
  final String? buttonIcon;

  /// مفاتيح الترجمة.
  final String title;
  final String text;
  final String action;

  /// تسقط البطاقة لحسابٍ موثَّق.
  ///
  /// الملفّ يرسم الثلاث دائماً لأنّه عرض. و«حساب غير موثّق» لا معنى لها
  /// لموثَّق، و«احصل على Trydos للأعمال» كذلك — فجسمُها في الملفّ جملةُ
  /// التوثيق نفسها (سهوٌ من المصمّم: نسخها ونسي تبديلها).
  final bool hideWhenVerified;
}
