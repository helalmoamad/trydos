import 'package:flutter/material.dart';

/// ثوابت شاشة قائمة المحادثات، منقولةٌ حرفياً من الويب.
///
/// المصدر: `web_design/components/DemoApp1/screens/ChatListScreen.tsx` على فرع
/// `development`، وألواح XD `Home Page – 41` (تبويب المحادثات) و`– 42` (صفٌّ
/// مسحوبٌ يميناً وآخر يساراً) و`– 43` (تبويب المكالمات).
///
/// وصفُ الملف للشاشة كلّها:
///
/// > **الترويسة 50 .. 150، بيضاء، لاصقة:**
/// >
/// > * حقل البحث 406×38 عند (12، 56)، نصف قطر 12، `#F8F8F8`، العدسة عند
/// >   (21.5، 65.5)، والكلمات عند x=52 على خطّ الأساس 80 بخطّ 14 Regular
/// >   `#8D8D8D`. وللشريط ظلُّ الملف (0 0 3 بأسود 10٪)، والشريط الأبيض تحته
/// >   يغطّي ذلك الظلّ.
/// * **شريط «المحادثات | المكالمات» 100 .. 150**: الظرف (25×25 عند 129، 113)
/// >   والهاتف (265، 113) وعدداهما بعدهما بـ4.26 على خطّ الأساس 125 بخطّ
/// >   12 Medium. والكتلة عرضها 172.5 وموسَّطة. والتبويب المفتوح وحده يُظهر
/// >   كلمتَه، محاذاةً إلى اليمين قبل أيقونته بـ7 (محادثات) أو 6 (مكالمات)،
/// >   على خطّ الأساس 135.
/// >
/// > **المحادثات**: صفوفٌ 430×100 من y=152، بينها 2، بيضاء بخطٍّ 0.3
/// > `#D3D3D3`؛ وصفُّ المحادثة المفتوحة بخطٍّ 0.5 `#4A31E7` وشريطٍ بنفسجيّ 4
/// > على حافّته اليسرى. الصورة 66×76 عند (12، 12 داخل الصفّ) بنصف قطر 15
/// > (وخطٌّ بنفسجيّ 1 على ذلك الصفّ)؛ والاسم 14 Medium عند x=90 على خطّ
/// > الأساس 26؛ والوقت 11 Medium `#8D8D8D` ينتهي قبل الحافّة اليمنى بـ13 على
/// > خطّ الأساس 23؛ والمعاينة 12 Regular بأسطر 17، عرضها 295 من x=90، أوّل
/// > خطّ أساسٍ لها 46، وسطران على الأكثر.
/// >
/// > **الصفّ المسحوب يساراً** يُظهر «كتم» و«حذف» و«أرشفة» (71×100 لكلٍّ،
/// > بينها 2، ملتصقةً باليمين: الصفّ يتحرّك 219)؛ **والمسحوب يميناً** يُظهر
/// > «غير مقروءة» و«تثبيت» عند x=2 و75 (الصفّ يتحرّك 148). وأيقونة الخانة
/// > 25×25 على بعد 20 من الأعلى، وكلمتُها 12 Regular على خطّ الأساس 77
/// > موسَّطة. وصفٌّ واحد مفتوحٌ في كل لحظة: سحبُ غيره يُغلقه، ونقرةٌ في أيّ
/// > مكانٍ تُغلقه.
/// >
/// > **المكالمات**: صفوفٌ 430×90 بلون `#FCFCFC` من y=152، الصورة 66×66،
/// > والاسم 16 Medium على خطّ الأساس 36 (و30 في الصفّ الذي له سطرٌ ثانٍ)،
/// > وحالةُ المكالمة تحته.
abstract class ChatListDesign {
  // ---- الترويسة ----

  /// ارتفاع شريط البحث — من 50 إلى 100 في الملف.
  static const double searchStrip = 50;

  /// ارتفاع شريط التبويبين — من 100 إلى 150.
  static const double tabStrip = 50;

  /// حقل البحث: 406×38 عند (12، 56) بنصف قطر 12.
  static const double fieldHeight = 38;
  static const double fieldRadius = 12;
  static const double fieldX = 12;

  /// العدسة عند (21.5، 65.5) — أي 9.5 داخل الحقل.
  static const double glassInset = 9.5;

  /// كلمات الحقل عند x=52؛ والعدسة تنتهي عند 21.5+19.
  static const double fieldTextX = 52;

  /// كتلة التبويبين: 172.5 عرضاً وموسَّطة، والظرف عند 129 والهاتف عند 265.
  static const double tabBlockWidth = 172.5;
  static const double tabIconSize = 25;
  static const double callsTabLeft = 265 - 129;

  /// الأيقونات عند y=113 وشريط التبويبين يبدأ عند 100.
  static const double tabIconTop = 13;

  /// الفراغ بين الأيقونة وعددها — 158.26 ناقص 154.
  static const double tabCountGap = 158.26 - 154;

  /// الفراغ بين كلمة التبويب وأيقونته: 7 للمحادثات و6 للمكالمات.
  static const double chatsLabelGap = 7;
  static const double callsLabelGap = 6;

  // ---- صفّ المحادثة ----

  static const double rowHeight = 100;
  static const double rowGap = 2;

  /// صورة الصفّ 66×76 عند (12، 12) بنصف قطر 15.
  static const double photoW = 66;
  static const double photoH = 76;
  static const double photoRadius = 15;
  static const double photoX = 12;
  static const double photoY = 12;

  /// الاسم والمعاينة يبدآن عند x=90 — أي بعد الصورة بـ12.
  static const double textX = 90;

  /// الوقت ينتهي قبل الحافّة اليمنى بـ13.
  static const double timeRight = 13;

  /// سطرا المعاينة: 12 Regular بصندوق سطرٍ 17، وأوّل خطّ أساسٍ 46.
  static const double previewSize = 12;
  static const double previewLine = 17;
  static const double previewBaseline = 46;
  static const int previewLines = 2;

  /// المعاينة تنتهي قبل الحافّة بـ45 — عرضها 295 من x=90.
  static const double previewRight = 45;

  /// شريط الصفّ المفتوح على حافّته.
  static const double selectedBar = 4;

  /// خطّ الصفّ: 0.3 رماديّ، و0.5 بنفسجيّ للمفتوح.
  static const double rowLine = 0.3;
  static const double rowLineOpen = 0.5;

  /// صفّ الأرشيف فوق القائمة.
  static const double archivedHeight = 50;

  // ---- خانات السحب ----

  static const double cellWidth = 71;
  static const double cellGap = 2;
  static const double cellIconTop = 20;

  /// كلمة الخانة على خطّ الأساس 77، وأيقونتُها تنتهي عند 45.
  static const double cellLabelBaseline = 77;

  /// كم يتحرّك الصفّ ليُظهر خاناته — ثلاثٌ يساراً واثنتان يميناً.
  static const double openLeft = -3 * (cellWidth + cellGap);
  static const double openRight = 2 * (cellWidth + cellGap) + cellGap;

  // ---- صفّ المكالمة ----

  static const double callRowHeight = 90;
  static const double callPhoto = 66;

  // ---- الزرّ الدائري ----

  /// زرّ المحادثة الجديدة: 52 دائرياً، على بعد 20 من اليمين و16 فوق الشريط.
  static const double fabSize = 52;
  static const double fabRight = 20;
  static const double fabAboveBar = 16;

  // ---- الألوان ----

  /// `C` في `demoLayout.ts`.
  static const Color ink = Color(0xFF1D1D1D);
  static const Color inkSoft = Color(0xFF404040);
  static const Color grey = Color(0xFF8D8D8D);
  static const Color line = Color(0xFFD3D3D3);
  static const Color purple = Color(0xFF4A31E7);
  static const Color field = Color(0xFFF8F8F8);
  static const Color page = Color(0xFFFCFCFC);
  static const Color white = Color(0xFFFFFFFF);

  /// `CHAT` في `demoChat.ts`.
  static const Color unreadCount = Color(0xFF7756E9);
  static const Color read = Color(0xFF007CFF);
  static const Color typing = Color(0xFF388CFF);
  static const Color red = Color(0xFFFF0508);

  /// ظلّ شريط البحث — `0 0 3` بأسود 10٪.
  static const List<BoxShadow> stripShadow = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 3),
  ];
}
