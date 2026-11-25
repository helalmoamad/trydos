/// شبكةُ شاشات الدخول، منقولةً حرفياً عن
/// `web_design/NewLoginDesign/authLayout.ts`.
///
/// > كلُّ رقمٍ بكسلُ تصميمٍ مقيسٌ من أعلى يسار لوح 430 × 932 — اللوحُ نفسُه
/// > الذي تُرسم عليه بقيّةُ أقسام التطبيق، فدوالُّ [Xd] تصلح هنا كما هناك:
/// > خطُّ الأساس الذي يخزّنه XD، وصندوقُ السطر، والفراغُ إلى خطّ أساس.
/// >
/// > «واقرأ الأرقامَ من هنا لا من غيره. قبل هذا الملفّ كانت كلُّ شاشةٍ تكتب
/// > هوامشَها، فتنتهي الكتلةُ الواحدة على ثلاثة أسطرٍ مختلفةٍ في ثلاث شاشات.»
///
/// ## فرقُ القياس عن بقيّة الأقسام
///
/// الويبُ يرسم هذا اللوحَ بمقياسٍ **واحدٍ** للبعدين (`AppScaler`)، ويُعالج
/// الشاشةَ الأقصرَ بـ«عجزٍ» (`--xd-flex-deficit`) يرفع الكتلَ السفليّة وحدَها.
/// وعندنا `.w` للعرض و`.h` للطول كبقيّة النقل، و[fromBottom] هي المقابل:
/// ما وسمه الملفُّ بـ`fromBottom()` يُسنَد إلى **أسفل** الشاشة لا إلى أعلاها،
/// فيبقى فوق لوحة المفاتيح وشريطِ المتصفّح كما أراد.
///
/// وما يُسنَد إلى الأسفل: كلُّ ما تحت موضع الشعار المنخفض في «ابدأ» و«الشروط»،
/// وعنقودُ الأزرار (`cta`) في كلّ شاشة. أمّا كتلةُ العنوان وصفُّ الإدخال
/// وأزرارُ الزوايا فتبقى من الأعلى.
library;

import 'package:flutter/material.dart';

import 'package:trydos/common/constant/design/xd_design.dart';
import 'package:trydos/main.dart' show kDesignV2;

/// أرقامُ اللوح — `XD` في `authLayout.ts`.
abstract class AuthXd {
  /// اللوحُ نفسُه: 430 × 932 ([Xd.designW] و[Xd.designH]).

  /// زرُّ الزاوية العليا اليمنى. كلاهما 30 عن الحافّة.
  static const double controlTop = 60;

  /// 10 تحت شريط حالة الجهاز.
  static const double controlCloseTop = 10;
  static const double controlRight = 30;

  /// إكسُ الإغلاق في الشاشات الستّ التي تُغلق.
  static const double controlCloseSize = 15;

  /// أيقونةُ «امسح رمز QR» في «ابدأ».
  static const double controlQrSize = 25;

  /// الشعار: 150 × 150 حيثما ظهر.
  static const double logoSize = 150;

  /// الهاتفُ والطريقةُ والرمزُ وشاشاتُ النتيجة الأربع.
  static const double logoTop = 116;

  /// «ابدأ» و«الشروط»: الشعارُ منخفضٌ والأزرارُ تحته.
  static const double logoCentre = 390;

  /// المعاينةُ السريعة، تحت لافتة الشعار.
  static const double logoQuickPreview = 98;

  /// كتلةُ العنوان: أربعةُ أسطرٍ لكلٍّ مرساتُه، لأنّ الملفَّ لا يُباعد بينها
  /// بانتظامٍ ولا تُعيدها سلسلةُ هوامش.
  ///
  /// العنوان 30 Bold `#1D1D1D`.
  static const double headTitle = 288;

  /// السطر الثاني 16.
  static const double headLine2 = 338;

  /// الثالث 12.
  static const double headLine3 = 366;

  /// الرابع 11 `#4A31E7` — سطرُ الخصوصيّة.
  static const double headLine4 = 389;

  /// وشاشتا الطريقة والرمز تُضيفان صفّاً فوقه، فينزل.
  static const double headLine4WithRow = 412;

  /// وشاشةُ الرمز المنتهي تدفعه مرّةً أخرى.
  static const double headLine4Expired = 435;

  /// النصُّ يبدأ على 40. والصناديقُ على 20 وعرضُها 390. ولا شيءَ على 30.
  static const double textLeft = 40;

  /// كلُّ حقلٍ عريضٍ وكلُّ زرّ.
  static const double boxLeft = 20;
  static const double boxWidth = 390;
  static const double boxHeight = 60;
  static const double boxRadius = 20;

  /// حقلُ الهاتف، وصفُّ الطريقة، وصفُّ الرمز.
  static const double boxTop = 503;

  /// وصفُّ الرمز يرتفع في شاشتي الخطأ والانتهاء.
  static const double boxTopLifted = 493;

  /// صناديقُ الرمز الستّة، من 20 إلى 410.
  static const double otpSize = 60;
  static const double otpGap = 6;
  static const double otpRadius = 15;

  /// زرّا الطريقة على x 20 و217.
  static const double methodWidth = 193;
  static const double methodGap = 4;

  /// والأيقونةُ تركب الحافّةَ العليا: 12 من الداخل و10 فوقها.
  static const double methodIconSize = 20;
  static const double methodIconLeft = 12;
  static const double methodIconAbove = 10;

  /// الرسالةُ تحت صفّ الرمز في شاشتي الخطأ والانتهاء.
  static const double otpMessageTop = 561;

  /// لا شيءَ يُلمس تحت هذا الخطّ — لوحةُ المفاتيح تبدأ هنا.
  static const double keyboardTop = 583;

  /// أسفلُ كلّ شاشة. وكلُّها تُسنَد إلى أسفل الشاشة — انظر [fromBottom].
  ///
  /// الأعلى من الزرّين حيث للشاشة زرّان.
  static const double ctaSecond = 721;

  /// الزرُّ الأساس.
  static const double ctaPrimary = 789;

  /// والرابطُ 14 تحته.
  static const double ctaLink = 879;

  /// «ابدأ» وحدَها.
  static const double getStartedTitle = 649;

  /// «الشروط» وحدَها.
  static const double termsBody = 600;
  static const double termsBodyLineHeight = 1.43;
  static const double termsIconLeft = 202;
  static const double termsIconTop = 688;
  static const double termsIconSize = 25;
  static const double termsLinkLine = 721;

  /// المعاينةُ السريعة وحدَها.
  ///
  /// ولافتةُ الشعار: الملفُّ يرسمها نصّاً موضوعاً بـ12 من اللافتة على كلّ
  /// جانب، فتضيق باللافتة وتتّسع — 206 لـ«. رفيقُك الجديد في التسوّق .»،
  /// وعرضٌ آخرُ لكلّ شعارٍ غيره. فلا عرضَ ثابتٌ يُنقل.
  static const double pillTop = 56;
  static const double pillPaddingX = 12;
  static const double pillHeight = 30;
  static const double pillRadius = 12;

  static const double previewTitle = 268;
  static const double previewCardTop = 326;
  static const double previewCardHeight = 473;

  static const double previewDotsTop = 809;
  static const double previewDotStep = 14;
  static const double previewDotGap = 6;
  static const double previewDotActiveWidth = 16;
  static const double previewDotSize = 8;

  static const double previewButton = 837;

  /// نافذةُ QR، من لوح `Registration - 1`.
  static const double qrSheetTop = 90;
  static const double qrSheetRadius = 30;
  static const double qrHandleLeft = 195;
  static const double qrHandleTop = 102;
  static const double qrHandleWidth = 40;
  static const double qrHandleHeight = 2;
  static const double qrCodeLeft = 90;
  static const double qrCodeTop = 171.5;
  static const double qrCodeSize = 250;
  static const double qrParagraphLineHeight = 1.54;

  /// حشوةُ عمود النافذة — `px-xd-35 pb-xd-10`.
  static const double qrPadX = 35;
  static const double qrPadBottom = 10;

  /// وبعد الرمز 70 ثمّ يبدأ النصّ. والويبُ يحسبها كما هي هنا، لا رقماً
  /// مكتوباً: `code.top − top + code.size + 70` = 401.5 من رأس النافذة.
  static const double qrTextGap = 70;
  static const double qrTextTop =
      qrCodeTop - qrSheetTop + qrCodeSize + qrTextGap;

  /// فقرةُ النافذة: عرضُها 350 ولا تتجاوز، وفراغُها عن العنوان 12 —
  /// ومثلُه قبل الأسطر الثلاثة، وبينها 8.
  static const double qrParagraphWidth = 350;
  static const double qrBlockGap = 12;
  static const double qrBulletGap = 8;

  /// سطرُ الخصوصيّة في الأسفل: درعٌ 14 ثمّ 4 ثمّ كلماتُه 11، ثمّ 30 فراغاً.
  static const double qrShieldSize = 14;
  static const double qrShieldGap = 4;
  static const double qrBottomSpace = 30;

  /// دوّارةُ بدء الكاميرا — `w-8 h-8 border-3`.
  static const double qrSpinnerSize = 32;
  static const double qrSpinnerStroke = 3;

  /// خطُّ المسح: 3 سماكةً، يمضي من أعلى الإطار إلى أسفله ويعود في 2.4ث.
  static const double qrLaserHeight = 3;
  static const Duration qrLaserPeriod = Duration(milliseconds: 2400);

  /// وبطاقةُ «حاول مرّةً أخرى» فوق الإطار.
  static const double qrRetryPad = 16;
  static const double qrRetryPadX = 24;
  static const double qrRetryRadius = 16;
  static const double qrRetryGap = 12;

  /// أركانُ الإطار: ذراعٌ 28 بسماكة 3 — وهذا وحدَه ليس في الويب، لأنّ
  /// الويبَ يرسم رمزاً والتطبيقُ يصوّره. فأُخذ نصفُ قطر صناديق الملفّ (20)
  /// وأزرقُه (`#388CFF`) كما هما.
  static const double qrFrameArm = 28;
  static const double qrFrameStroke = 3;
}

/// الفراغُ بعد السطر الثالث قبل أيقونته — `XD_LINE3_ICON_GAP`.
///
/// > الأيقونةُ تتبع الجملةَ بفراغٍ لا على x ثابت، لأنّ الجملةَ مترجمةٌ
/// > ويتبدّل طولُها.
/// >
/// > وهذا الموضعُ الوحيدُ الذي يخالف فيه الملفُّ نفسَه: علامةُ الشريحة نفسُها
/// > في الصفّ نفسِه تقع على 320.1 (الهاتف) و316.1 (الطريقة) و322.1 (الرمز) في
/// > ثلاثة ألواح. فتحفظ كلُّ شاشةٍ رقمَها بدل وسيطٍ يُخطئ الثلاثة.
abstract class AuthIconGap {
  static const double phone = 23.1;
  static const double method = 19.1;
  static const double code = 19.1;

  /// والفراغُ بعد رقم هاتفٍ مكتوبٍ «+90 552 800 200 0» في شاشتي النتيجة.
  static const double afterPhone = 6.6;
}

/// التباعدُ الحرفيُّ الوحيد في الملفّ كلِّه — `XD_WIDE_LABEL_TRACKING`.
///
/// XD يضعه على ثلاث كلماتٍ لا غير: «ادخل وتابع»، و«أنشئ حساباً جديداً وتابع»،
/// و«ألغِ وألقِ نظرةً على التطبيق». وXD يعدّ بالألف من الـem، فالعشرةُ 0.01em.
const double kAuthWideTracking = 0.01;

/// شاشاتُ الدخول بالتصميم الجديد — من مفتاح التصميم الواحد في `main.dart`
/// ([kDesignV2]).
///
/// يُطفأ فتعود `RegistrationPage` القديمةُ بسبع صفحاتها كما هي — لم تُحذف،
/// والاختيارُ في `registration_host.dart`.
const bool kAuthDesignV2 = kDesignV2;

/// الانزلاقُ بين شاشتي دخول: الجديدةُ تدخل من اليمين والقديمةُ تخرج يساراً،
/// وكلتاهما تخبو — `AUTH_SLIDE`.
abstract class AuthSlide {
  static const Duration duration = Duration(milliseconds: 350);
  static const Cubic ease = Cubic(0.4, 0, 0.2, 1);
}

/// y من **أسفل** اللوح: ما يحفظ مسافتَه من أسفل الصفحة — `fromBottom`.
///
/// الويبُ يرفع هذه الكتلَ بقدر ما تنقص الشاشةُ عن 932، فتبقى فوق شريط
/// المتصفّح ويقصر الفراغُ فوق الشعار بدلَها. وعندنا تُسنَد إلى الأسفل بهذا
/// القدر، فيُحصّل الأثرُ نفسُه.
double authFromBottom(double top) => Xd.designH - top;
