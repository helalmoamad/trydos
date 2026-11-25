import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:trydos/main.dart' show kDesignV2;

/// يُفعّل تصميم الدردشة الجديد — من مفتاح التصميم الواحد في `main.dart`
/// ([kDesignV2]).
///
/// وقائمةُ الدردشات وحقلُ الكتابة يعودان بإطفائه، ففروعُهما القديمةُ قائمةٌ
/// في ملفّيهما. وأمّا **شاشةُ المحادثة** فأُعيد تصميمُها في موضعها ولم يبقَ
/// فيها فرعٌ قديمٌ كامل — فنسختُها القديمةُ في ملفٍّ مجاور، واختيارُها في
/// `single_page_chat_host.dart`. ومثلُها صفحةُ معلومات المحادثة وحوارا
/// التذكير والوسم.
const bool kChatDesignV2 = kDesignV2;

/// ارتفاع ترويسة المحادثة وشريطِ التطبيق معاً.
///
/// الملف يرسم الترويسة **50 تماماً** (من 50 إلى 100)، ويضع صفَّ الصورتين
/// بعدها عند 104 — أي بأربعة لا أكثر.
///
/// و50 هي الحدّ الأدنى لا اختياراً: الاسم ينتهي عند 35، وسطرُ الحالة — وهو
/// إضافةٌ عندنا لا وجود لها في الملف — يأخذ نحو 14 تحته (`titleMedium` 12sp)،
/// فالمحتوى نحو 49. أي أن سطرنا يسكن الفراغ الأبيض الذي يتركه الملف تحت
/// الاسم (35 إلى 50) ولا يتجاوزه. وما دون ذلك يُقصّ السطر.
///
/// ورقمٌ واحد للاثنين ضروريّ: الشريط هو ما يُزيح جسم المحادثة، والترويسة هي
/// ما يُرى. فإن اختلفا بقي بينهما فراغٌ يُبعد صفَّ الصورتين عن الترويسة
/// (إن كان الشريط أطول)، أو فاضت الترويسة فركبت ما تحتها (إن كان أقصر).
const double kHeaderHeight = 50;

/// ثوابت تصميم شاشة المحادثة، منقولة حرفياً من الويب.
///
/// المصدر: `web_design/components/DemoApp/demoChat.ts` و
/// `components/DemoApp1/screens/ConversationScreen.tsx` و`chat/messages.tsx`.
/// ألواح XD: `Home Page – 41` .. `– 45`.
///
/// دوالّ خطّ الأساس في [ContactDesign] — مشتركةٌ بين الشاشتين.
abstract class ChatDesign {
  // ---- الفقاعات ----
  /// فقاعة رسالة واردة.
  static const Color inBubble = Color(0xFF4A31E7);

  /// فقاعة رسالة أرسلتُها، ونقطتها.
  static const Color sent = Color(0xFF8D00E5);
  static const Color sentDot = Color(0xFF883BF2);

  /// نصف أقطار الفقاعة. الواردة `2/50/2/30` والمرسَلة معكوسةٌ عنها.
  static const BorderRadius inRadius = BorderRadius.only(
    topLeft: Radius.circular(2),
    topRight: Radius.circular(50),
    bottomRight: Radius.circular(2),
    bottomLeft: Radius.circular(30),
  );
  static const BorderRadius outRadius = BorderRadius.only(
    topLeft: Radius.circular(50),
    topRight: Radius.circular(2),
    bottomRight: Radius.circular(30),
    bottomLeft: Radius.circular(2),
  );

  /// صندوق أيقونة بطاقة المكالمة.
  static const BorderRadius iconBoxIn = BorderRadius.only(
    topLeft: Radius.circular(2),
    topRight: Radius.circular(30),
    bottomRight: Radius.circular(2),
    bottomLeft: Radius.circular(30),
  );
  static const BorderRadius iconBoxOut = BorderRadius.only(
    topLeft: Radius.circular(30),
    topRight: Radius.circular(2),
    bottomRight: Radius.circular(30),
    bottomLeft: Radius.circular(2),
  );

  // ---- ألوان أخرى ----
  /// عدّاد غير المقروء على صفّ المحادثة.
  static const Color unreadCount = Color(0xFF7756E9);

  /// علامتا القراءة الزرقاوان.
  static const Color read = Color(0xFF007CFF);
  static const Color typing = Color(0xFF388CFF);

  /// مكالمة فائتة، وبطاقتها وصندوق أيقونتها.
  static const Color missedRed = Color(0xFFFF0508);
  static const Color missedCard = Color(0xFFFFF6F5);
  static const Color missedIconBox = Color(0xFFFFE6E5);

  /// بقية بطاقات المكالمات وصناديق أيقوناتها.
  static const Color callCard = Color(0xFFF4F4F4);
  static const Color incomingIconBox = Color(0xFFEFEBFF);
  static const Color outgoingIconBox = Color(0xFFF8EDFF);

  /// الرسالة المقتبسة داخل ردّ.
  static const Color quote = Color(0xFFEFEBFF);

  /// قائمة الضغط المطوّل، وتلميحها.
  static const Color menu = Color(0xFFFAFAFA);
  static const Color tooltip = Color(0xFF404040);

  static const Color callBlue = Color(0xFF388CFF);

  /// خلفية صفحة المحادثة — `#FCFCFC` كما في اللوحة.
  static const Color page = Color(0xFFFCFCFC);

  // ---- الترويسة: من y=50 إلى 100 ----
  static const double headerHeight = 50;

  /// ظلّ الترويسة: `0 0 3` بأسود 10%.
  static const List<BoxShadow> headerShadow = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 3),
  ];

  // ---- قائمة الضغط المطوّل ----
  /// تضبيب الخلفية خلف قائمةٍ مفتوحة — `MENU_BLUR`.
  static const double menuBlur = 5;

  /// مدّة ظهور الغشاوة واختفائها — `MENU_FADE` = 0.18.
  static const Duration menuFade = Duration(milliseconds: 180);

  /// الغشاوة فوق المحادثة أثناء فتح قائمة — `MENU_DIM`.
  ///
  /// أسودٌ بـ30٪ فوق تضبيبٍ 5، غشاوةً **واحدة** على المحادثة كلّها لا
  /// تضبيباً على كل صفّ. والرسالة المضغوطة تبقى فوقها.
  static const Color menuScrim = Color(0x4D000000);

  // الفراغ تحت آخر رسالة انتقل إلى `MessageMenuV2.lastMessageRoom`: يُحسب من
  // أرقام القائمة، وهي تعيش هناك — واستيرادها هنا يصنع دائرة.

  /// سحبةٌ تتجاوزها تُغلق القائمة — `DRAG_CLOSE` في الويب.
  ///
  /// والمحادثة لا تتزحزح ما دامت القائمة مفتوحة: دفعةٌ صغيرة لا تفعل شيئاً،
  /// وسحبةٌ حقيقية تُغلق ولا تُمرّر.
  static const double menuDragClose = 24;

  /// مرشِّح الغشاوة خلف القائمة — تضبيبٌ 5 كما في `backdropFilter`.
  static ui.ImageFilter get menuFilter =>
      ui.ImageFilter.blur(sigmaX: menuBlur, sigmaY: menuBlur);

  // ---- الفجوات بين الرسائل ----
  /// الفراغ فوق رسالةٍ ما، كما يحسبه `gapAbove` في الويب.
  ///
  /// > ٢ تحت رسالةٍ من نفس الجهة، و١٢ بعد أي شيءٍ آخر.
  ///
  /// والتفصيل أدقّ من ذلك: نصٌّ بعد نصٍّ من نفس الجهة وحده يأخذ ٢؛ أمّا
  /// الصوت وبطاقة المكالمة فكلٌّ منهما مجموعةٌ قائمة بذاتها ولو كانت من
  /// نفس الجهة، فتأخذ ١٢.
  ///
  /// [isSameSide] — الرسالتان من جهة واحدة.
  /// [bothText] — كلتاهما نصّية.
  static double gapAbove({
    required bool isFirst,
    required bool isDayPill,
    required bool afterDayPill,
    required bool isNote,
    required bool isSameSide,
    required bool bothText,
  }) {
    if (isFirst) return 16;
    if (isDayPill || afterDayPill) return 12;
    if (isNote) return 0;
    if (isSameSide && bothText) return 2;
    return 12;
  }

  // ---- النصّ داخل الفقاعة ----
  /// حروف الرسالة الواردة متباعدةٌ 0.012em في الملف.
  static const double inLetterSpacing = 13 * 0.012;
}
