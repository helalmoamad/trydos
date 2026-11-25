/// شبكةُ مدخل الديمو — من ألواح `Ramaaz pay signin – 16`/`– 15`
/// و`Sign In request` و`Home Page – 90`، كما تقرؤها
/// `web_design/components/DemoApp1/screens/`.
///
/// > ولا شيءَ هنا محسوبٌ على العين: كلُّ رقمٍ موضعُه في الملفّ، وما كان في
/// > الويب تعبيراً حسابيّاً يبقى تعبيراً.
library;

import 'package:flutter/material.dart';

/// مجلّدُ أيقونات الديمو.
const String kDemoSvg = 'demo_v2';

/// منتقي الدولة: الخريطةُ وصفوفُها.
abstract class PickerXd {
  /// صندوقُ الخريطة في الملفّ: `viewBox` وموضعُها — 406.5×286.5 على
  /// (11.75، 287.75).
  static const double mapX = 11.75;
  static const double mapY = 287.75;
  static const double mapW = 406.5;
  static const double mapH = 286.5;

  /// حيث تنتهي لافتةُ الشعار في الملفّ: أعلاها 98 وطولُها 150. ومسافاتُ هذا
  /// الجزء كلُّها تُقاس من حافّتها السفلى، لأنّ عمودَ المعاينة يرسم ما فوقها.
  static const double logoEnd = 98 + 150;

  /// أوّلُ صفٍّ على 594، وبين كلّ صفّين 4. وآخرُ صفٍّ ينتهي على 846،
  /// وما بعده إلى طرف اللوح (932) فراغٌ أسفلَ العمود.
  static const double firstRow = 594;
  static const double rowGap = 4;
  static const double lastRowEnd = 846;

  /// تلوينُ الدولة المختارة: الرماديُّ ينتشر من موضع اللمس إلى الدولة كلّها.
  static const Duration fill = Duration(milliseconds: 700);
  static const Cubic fillEase = Cubic(0.22, 1, 0.36, 1);

  /// حدُّ الرماديّ اللَيّن، نسبةً إلى نصف قطر التدرّج.
  static const double fillEdge = 0.02;

  /// ونصفُ قطرِ القرص 1.5: يغطّي صندوقَ الدولة من أيّ ركنٍ بدأ (قطرُه 1.42).
  static const double fillRadius = 1.5;

  /// وينتشر إلى 1.05 لا إلى 1، فيستوي الصندوقُ كلُّه رماديّاً من أيّ بداية.
  static const double fillOvershoot = 1.05;

  /// كم تبقى الصفحةُ بعد اللمس قبل أن تُسلّم: التلوينُ ثمّ لحظةٌ على
  /// الاختيار التامّ (`– 15`).
  static const Duration hold = Duration(milliseconds: 1000);

  /// دولةٌ غيرُ مختارة: `#F4F4F4` بخطٍّ 0.5 رماديّ.
  static const Color empty = Color(0xFFF4F4F4);
  static const double mapStroke = 0.5;

  /// ترتيبُ الملفّ على الخريطة — تركيا آخراً فتعلو ما قبلها.
  static const List<String> mapOrder = <String>['sy', 'lb', 'iq', 'tr'];
}

/// صفُّ الدولة — كما يرسمه `Home Page – 95` و`Ramaaz pay signin – 15`:
/// 406×60 بنصف قطر 15 على 12 من الحافّتين، والعلمُ 30 على 12، والاسمُ 14
/// من x 66.
abstract class CountryRowXd {
  static const double height = 60;
  static const double flag = 30;
  static const double flagInset = 12;

  /// والاسمُ على 66 من حافّة الشاشة: 12 (الصندوق) + 12 (العلم) + 30 + 12.
  static const double nameGap = 12;

  /// خطُّ الصفّ المختار — وهو ليس بنفسجيَّ الخريطة: `#402CDD` لا `#4A31E7`.
  static const Color stroke = Color(0xFF402CDD);
}

/// نافذةُ طلب الدخول — لوح `Sign In request`.
abstract class SignInXd {
  /// رأسُ النافذة، وظلُّ حافّتها العليا.
  static const double top = 285;
  static const List<BoxShadow> shadow = <BoxShadow>[
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, -3), blurRadius: 10),
  ];

  /// الشعارُ كلُّه داكنٌ، 150×150 على (140، 327).
  static const double logoTop = 327;
  static const double logoSize = 150;

  /// سطران في المنتصف، 14، قاعدتاهما 521 و541 وارتفاعُ سطرهما 20.
  static const double line1 = 521;
  static const double lineHeight = 20;

  /// البطاقةُ 390×186 على (20، 565) بنصف قطر 20 وخطٍّ 0.5 بنفسجيّ.
  static const double cardTop = 565;
  static const double cardHeight = 186;
  static const double cardRadius = 20;
  static const double cardLine = 0.5;

  /// وأقلُّ طولٍ تنزل إليه في الويب على نافذةٍ قصيرة — نصفُ الـ186 تقريباً.
  /// محفوظٌ من الملفّ؛ ولا يحتاجه النقلُ لأنّ أرقامَه كلَّها `.h` من 932.
  static const double cardMin = 96;

  /// الفراغُ بين بطاقتين وهما تنزلقان — فراغُ المعاينة نفسُه.
  static const double slideGap = 20;

  /// نقاطُ الصفحات على 761: المختارةُ حبّةٌ 16×8، وسواها حلقاتٌ 8 بخطٍّ 1.
  static const double dotsTop = 761;
  static const double dotPill = 16;
  static const double dotSize = 8;
  static const double dotGap = 6;
  static const Duration dotMove = Duration(milliseconds: 300);

  /// «ابدأ» 390×60 على (20، 789) بنصف قطر 20، `#FAFAFA` بخطٍّ 0.5 متقطّعٍ
  /// 3 ظاهرٍ و3 خافٍ، وكلماتُه 16 `#3C3C3C`.
  static const double ctaTop = 789;
  static const double ctaHeight = 60;
  static const double ctaRadius = 20;
  static const Color ctaFill = Color(0xFFFAFAFA);
  static const Color ctaInk = Color(0xFF3C3C3C);

  /// «لاحقاً، ألقِ نظرةً على التطبيق» 14 `#4D84FF` على قاعدة 893. والملفُّ
  /// يُوسّطها على x 216 — بكسلاً واحداً يمينَ منتصف الشاشة.
  static const double laterBaseline = 893;
  static const double laterOffset = 2;

  /// وما تحتها أبيضُ إلى طرف اللوح.
  static const double endGap = 932;

  /// الشريحةُ: أيقونةٌ في دائرة، ثمّ عنوانٌ 20 Bold، ثمّ سطرٌ 14 بـ1.6
  /// وعرضٍ 320 على الأكثر. والبطاقةُ 186 لا 473، فدائرتُها 56 لا 100.
  static const double iconCircle = 56;
  static const double iconSize = 28;
  static const double iconGap = 10;

  /// وعلى بطاقةٍ قصيرةٍ تصغر الدائرة، ثمّ تُطرح الأيقونةُ وتبقى الكلمات.
  static const double iconCircleSmall = 44;
  static const double iconSizeSmall = 22;
  static const double iconGapSmall = 8;

  static const Color iconBg = Color(0xFFF4F0FE);
  static const Color iconRing = Color(0xFFECE9FE);

  /// أقلُّ بياضٍ فوق محتوى الشريحة وتحته، والفراغُ بين عنوانها وسطرها.
  static const double slidePad = 8;
  static const double titleGap = 6;
  static const double slideTextMax = 320;
  static const double slideTextLine = 1.6;
  static const double slidePadX = 20;
}

/// المعاينةُ السريعة — لوحا `Ramaaz pay signin - 14` (مطويّاً) و`- 13`.
///
/// > «عمودٌ واحدٌ يبدأ تحت حافّة الشاشة ويصعد. وكلُّ فراغٍ فيه فرقٌ بين
/// > مرساتين في الملفّ، فمجموعُه اللوحُ كلُّه بالضبط:
/// >
/// >   56 + لافتة(30) + 12 + شعار(150) + 20 + عنوان(37.5) + 20.5
/// >      + بطاقة(473) + 10 + نقاط(8) + 20 + زرّ(60) + 35 = 932
/// >
/// > وهي فراغاتٌ لا مواضعُ مطلقة، لأنّ العمودَ كلَّه يتحرّك — وحدَه في
/// > التصميم يفعل ذلك، ولذلك تُرسي كلُّ شاشةٍ أُخرى كتلَها.»
abstract class PreviewXd {
  /// فراغاتُ العمود، بأسمائها في الويب.
  static const double abovePill = 56;
  static const double pillToLogo = 12;
  static const double logoToTitle = 20;
  static const double titleToCard = 20.5;
  static const double cardToDots = 10;
  static const double dotsToButton = 20;
  static const double belowButton = 35;

  /// كم تعلو حافّةُ اللافتة العليا حافّةَ الشاشة السفلى وهو مطويّ — من لوح
  /// `- 14`: صندوقُ اللافتة 829→859 واللوحُ 932، فالذيلُ 103. وتحتها فراغُ
  /// الـ12 ثمّ أعلى 61 من حلقة الشعار، وهي الإطلالةُ التي يرسمها اللوح.
  static const double collapsedTail = 103;

  /// كم تبقى الكلمةُ في منتصف الشاشة قبل أن يصعد العمود.
  static const Duration wordmarkHold = Duration(seconds: 8);

  /// وصعودُه: إلى إطلالته في 0.8ث، ثمّ إلى أعلى الشاشة في 1.1ث.
  static const Duration riseToPeek = Duration(milliseconds: 800);
  static const Duration riseToTop = Duration(milliseconds: 1100);
  static const Cubic riseEase = Cubic(0.25, 1, 0.5, 1);

  /// وخروجُ الكلمة: تخبو وتصغر إلى 0.9 في نصف ثانية.
  static const Duration wordmarkFade = Duration(milliseconds: 500);
  static const double wordmarkExitScale = 0.9;
  static const double wordmarkWidth = 176;
  static const double wordmarkHeight = 88;

  /// اللافتةُ تتقلّب كلَّ 1400مث: تدور على محور x من −90 إلى 0، والخارجةُ
  /// إلى +90، في 300مث.
  static const Duration flipEvery = Duration(milliseconds: 1400);
  static const Duration flipTurn = Duration(milliseconds: 300);

  /// وأرضيّتُها — لافتةُ الشعار في الملفّ.
  static const Color pillFill = Color(0xFFF8F7FF);

  /// البطاقة: 390×473 بنصف قطر 20 وخطٍّ **مُصمت** 0.5 بنفسجيّ (لا متقطّع).
  /// والملفُّ يُطفئ ظلَّها (`visible: false`)، فلا ظلَّ هنا.
  static const double cardHeight = 473;

  /// والفراغُ بين بطاقتين — يُرى في السحب وحدَه.
  static const double slideGap = 20;

  /// وفي البطاقة: دائرةٌ 100 بأيقونةٍ 50، ثمّ 20، ثمّ عنوانٌ 20 Bold، ثمّ 8،
  /// ثمّ سطرٌ 14 `#5D5C5D` بارتفاع 1.6 وعرضٍ 320 على الأكثر، وحشوةٌ 20.
  static const double iconCircle = 100;
  static const double iconSize = 50;
  static const double iconToTitle = 20;
  static const double titleToLine = 8;

  /// زرُّ «التالي»: `#FCFCFC` بخطٍّ متقطّعٍ بنفسجيٍّ وكلماتٍ `#5D5C5D`.
  /// وزرُّ «ابدأ» في آخر شريحة: بنفسجيٌّ مُصمتٌ بكلماتٍ بيضاء.
  static const Color nextFill = Color(0xFFFCFCFC);
}

/// نافذةُ رمز البريد — لوح `Home Page – 90`.
abstract class EmailCodeXd {
  static const double top = 90;

  /// «تحقّقُ البريد !» 30 Bold على قاعدة 318، والسطرُ تحته 16 Medium على 354.
  static const double title = 318;
  static const double line = 354;

  /// صفُّ العنوان و«أعد الإرسال» — صفٌّ 15 من 366.
  static const double rowTop = 366;
  static const double rowHeight = 15;

  /// وسطرُ الخصوصيّة البنفسجيُّ بدرعه — صفٌّ 14 من 389.
  static const double privacyTop = 389;
  static const double privacyHeight = 14;

  /// وصناديقُ الرمز الستّة على 502 — صناديقُ الدخول نفسُها.
  static const double boxesTop = 502;

  /// الكلُّ على 40، والصناديقُ على 20.
  static const double textLeft = 40;
  static const double boxesLeft = 20;

  /// فراغاتُ صفّ العنوان: 5 قبل «أعد الإرسال»، و3.5 قبل علامته، و6 قبل الدرع.
  static const double resendGap = 5;
  static const double helpGap = 3.5;
  static const double shieldGap = 6;
}
