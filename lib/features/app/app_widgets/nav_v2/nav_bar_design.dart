/// أرقام الشريط السفليّ وألوانه، منقولةً حرفياً عن الويب.
///
/// المصادر:
///  - `components/DemoApp/demoLayout.ts`    → `TAB_BAR`
///  - `components/DemoApp/DemoBottomNav.tsx` → `SLOTS` و`PROFILE` و`GROW`
///                                             والنوابض والعدّادات
///  - `components/DemoApp1/Demo1BottomNav.tsx` → `fileCentre` و`SLOT_INSET`
///  - `components/NavigationDemo/BottomNav.tsx` → حركة التمرير والنبضة
///
/// كلّ رقمٍ هنا بوحدة لوح التصميم (430 × 932). التحويل إلى الشاشة يقع في
/// الودجات نفسها بـ`.w` و`.h` و`.sp`.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:trydos/main.dart' show kDesignV2;

/// الشريط السفليّ الجديد. يُطفئه مفتاحُ التصميم الواحد في `main.dart`
/// ([kDesignV2]) فيعود شريط الأربع خاناتٍ القديم كما هو — لم يُحذف، بل بقي
/// الفرع الآخر في `app_bottom_navigation_bar.dart`.
const bool kNavDesignV2 = kDesignV2;

/// شكل الشريط ومادّته — `TAB_BAR` في `demoLayout.ts`.
class NavBarDesign {
  const NavBarDesign._();

  /// يُبقي الشريط 22 إلى كلّ حافّة من حافّتي الشاشة.
  static const double x = 22;

  /// أعلى الشريط على اللوح. تُقاس منه مواضع الأيقونات.
  static const double y = 859;

  /// عرضه على لوح 430. عندنا العرض مرن: `1.sw - 2*x`.
  static const double width = 386;

  static const double height = 58;

  /// أين حافّة الشريط السفلى، فوق شريط أدوات المتصفّح: 6 — `TAB_BAR_BOTTOM`.
  ///
  /// كانت 15 قبل تحديث الويب. وهي نفسها بالحجم الكامل وبعد التصغير على
  /// التمرير (انظر [drop])، وفي كلّ شاشة.
  ///
  /// وحسابُ سفاري (`BAND`/`SAFARI_SHIFT`) لا يلزمنا: هو لشريط أدوات سفاري 26
  /// العائم على صفحة الويب، ولا نظير له في تطبيق.
  static const double bottomGap = 6;

  /// أصغر ما يصير إليه الشريط: حبّةٌ 143 × 31 — `TAB_BAR_MIN`.
  static const double minWidth = 143;
  static const double minHeight = 31;

  /// الزوايا: 10 أعلى و40 أسفل — "حرف D مقلوبٌ على جنبه".
  static const BorderRadius radius = BorderRadius.only(
    topLeft: Radius.circular(10),
    topRight: Radius.circular(10),
    bottomLeft: Radius.circular(40),
    bottomRight: Radius.circular(40),
  );

  /// `background blur` في الملف: تمويه 30 وسطوع +15% وتعبئة بشفافيّةٍ تامّة
  /// — فلا لون للشريط نفسه، بل ما خلفه مُمَوَّهاً ومُفتَّحاً.
  static const double glassBlur = 30;
  static const double glassBrightness = 1.15;

  /// كم ينزل الشريط وهو يصغر: نصفُ الارتفاع الذي يفقده، (58 - 31) / 2
  /// — `TAB_BAR_DROP`. والشريط يُكبَّر حول مركزه، فهذا يُبقي حافّته السفلى على
  /// [bottomGap] في كلّ حال.
  ///
  /// كانت 35 قبل تحديث الويب، فكان جزءٌ من الشريط ينزل تحت الشاشة عند
  /// التصغير. وهذا ما أصلحه التحديث.
  static const double drop = (height - minHeight) / 2;

  /// كم نزلت حافّة الشريط **العليا** عند حجمٍ `scale` (1 = الحجم الكامل):
  /// صفرٌ كاملاً، و27 أصغرَ ما يكون — `tabBarTopDrop`.
  ///
  /// الشريط يُكبَّر حول مركزه وينزل بالحصّة نفسها من [drop]، فتثبت حافّته
  /// السفلى وتنزل العليا بكلّ ما فقده من ارتفاع. وصندوقٌ يستند إلى حافّته
  /// العليا (لوحةُ السعر في السلّة) ينزل بهذا القدر ويحفظ حجمه.
  static double topDrop(double scale) => height * (1 - scale);

  /// حافّة الشريط العليا بالحجم الكامل، فوق أسفل الشاشة (دون الحافّة الآمنة)
  /// — `TAB_BAR_TOP`.
  static const double top = bottomGap + height;

  /// المسافة بين خانتين، و5 خانات تتقاسم الشريط.
  static const double slotW = 76;
  static const int slotCount = 5;

  /// مركز الخانة `index` على لوح 430 — `fileCentre` في الويب.
  static double fileCentre(int index) => 63 + index * slotW;

  /// الفراغ بين طرفي الشريط وأوّل خانةٍ وآخرها: 63 - 22 - 38 = 3.
  static double get slotInset => fileCentre(0) - x - slotW / 2;
}

/// الغرفة التي يأخذها الشريط أسفل شاشة تبويب، كي لا يبقى صفُّها الأخير تحته
/// — `TAB_ROOM` في `demo1Layout.ts`: `calc(TAB_BAR_TOP px + SAFE_BOTTOM)`.
///
/// ولازمةٌ لأنّ `Scaffold` عندنا `extendBody: true`، فالصفحة تمتدّ تحت
/// الشريط — وهذا ما يجعل زجاجه يُموّه المحتوى حقّاً ولا تظهر غرفةٌ فارغة حين
/// يصغر الشريط.
/// وهي صفرٌ مع التصميم القديم: شريطُه القديم يشغل مكانَه في الصفحة ولا
/// يطفو، فلا غرفةَ تُحجز تحته.
double navTabRoom(BuildContext context) => kNavDesignV2
    ? NavBarDesign.top.h + MediaQuery.paddingOf(context).bottom
    : 0;

/// [navTabRoom] سليفراً، يُضاف آخر `slivers` في شاشة تبويب.
class SliverNavTabRoom extends StatelessWidget {
  const SliverNavTabRoom({super.key});

  @override
  Widget build(BuildContext context) =>
      SliverToBoxAdapter(child: SizedBox(height: navTabRoom(context)));
}

/// مربّع أيقونةٍ على اللوح: زاويته العليا اليسرى وعرضه.
class NavBox {
  const NavBox({required this.x, required this.y, required this.size});

  final double x;
  final double y;
  final double size;

  /// المربّع نفسه مُكبَّراً بـ[NavSlots.grow] حول مركزه — `grown` في الويب.
  NavBox get grown {
    final double s = size * NavSlots.grow;
    final double shift = (s - size) / 2;
    return NavBox(x: x - shift, y: y - shift, size: s);
  }
}

/// عدّادٌ يرسمه الملف على خانة: Quicksand Bold 12، بحافّته اليسرى وخطّ
/// أساسه داخل مربّع 34 من الخانة. العدّاد النشط أخفض بـ1.
class NavCount {
  const NavCount({
    required this.text,
    required this.x,
    required this.idleBaseline,
    required this.idleColor,
    required this.activeBaseline,
    required this.activeColor,
  });

  final String text;
  final double x;
  final double idleBaseline;
  final Color idleColor;
  final double activeBaseline;
  final Color activeColor;
}

/// خانةٌ واحدة: أيقونتها ساكنةً ونشطةً، ومربّعاها.
class NavSlot {
  const NavSlot({
    required this.icon,
    required this.activeIcon,
    required this.idle,
    required this.active,
    this.count,
  });

  final String icon;
  final String activeIcon;
  final NavBox idle;
  final NavBox active;
  final NavCount? count;
}

/// الخانات الخمس كما في `SLOTS` و`PROFILE`.
///
/// الأيقونات النشطة هي الطاقم الذي يحفظه الملف على لوح العمل تحت `Home Page`:
/// علامة `try` البنفسجيّة في حلقتها المنقّطة (42)، وحلقة البحث البنفسجيّة،
/// والحقيبة البنفسجيّة بمقبضها الأصفر، وفقاعتا الدردشة البنفسجيّتان، ومربّع
/// الحساب البنفسجيّ. الأيقونة الساكنة تخبو والنشطة تظهر أثناء التكبير.
class NavSlots {
  const NavSlots._();

  static const Color purple = Color(0xFF4A31E7);

  /// مربّع العدّادات في الملف.
  static const double countBox = 34;
  static const double countSize = 12;

  /// كم تكبر البحث في الملف: أيقونة 34.99 تصبح حلقة 42.98.
  static const double grow = 42.98 / 34.99;

  static const NavBox _cart = NavBox(x: 198, y: 871, size: 34);
  static const NavBox _chat = NavBox(x: 274, y: 871, size: 34);

  /// الأربع الأُوَل. الخامسة هي [profile] — لا `SLOTS[4]` في الويب.
  static final List<NavSlot> list = <NavSlot>[
    const NavSlot(
      icon: 'navTry',
      activeIcon: 'navTryActive',
      idle: NavBox(x: 45.5, y: 870.5, size: 35),
      // علامة try بمقاس 42، على المركز نفسه (63، 888).
      active: NavBox(x: 42, y: 867, size: 42),
    ),
    const NavSlot(
      icon: 'navSearch',
      activeIcon: 'navSearchActive',
      idle: NavBox(x: 121.5, y: 870.5, size: 34.99),
      active: NavBox(x: 113.5, y: 866.5, size: 42.98),
    ),
    NavSlot(
      icon: 'navCartCount',
      activeIcon: 'navCartActiveCount',
      idle: _cart,
      active: _cart.grown,
      count: const NavCount(
        text: '3',
        x: 17,
        idleBaseline: 26,
        idleColor: purple,
        activeBaseline: 27,
        activeColor: purple,
      ),
    ),
    NavSlot(
      icon: 'navChatCount',
      activeIcon: 'navChatActiveCount',
      idle: _chat,
      active: _chat.grown,
      count: const NavCount(
        text: '11',
        x: 20,
        idleBaseline: 26,
        idleColor: purple,
        activeBaseline: 27,
        activeColor: Color(0xFFFFFFFF),
      ),
    ),
  ];

  /// خانة الحساب: مربّع 34 (`#EFEFEF` بخطّ 0.3 `#1D1D1D`) يصبح صورةً 42 نشطاً.
  static const NavBox profileIdle = NavBox(x: 350, y: 871, size: 34);
  static const NavBox profileActive = NavBox(x: 346, y: 865, size: 42);
  static const double profileRadius = 12;

  /// ساكناً يُرسم مربّع الحساب بـ34/42 من حجمه، فتُرسم زاويته وخطّه أكبر
  /// بهذه النسبة ليحلّا على قيم الملف.
  static double get profileUnscale => profileActive.size / profileIdle.size;

  /// المربّع الرماديّ بلا صورة، والبنفسجيّ نشطاً بلا صورة.
  static const Color profileFill = Color(0xFFEFEFEF);
  static const Color profileFillActive = Color(0xFFD4D4FC);

  /// رمز المستخدم ساكناً — 17.9 على (8.05، 6.06) — ونشطاً — 16.91 على (8.5، 6.6).
  static const double userIcon = 17.9;
  static const double userIconX = 8.05;
  static const double userIconY = 6.06;
  static const double userIconActive = 16.91;
  static const double userIconActiveX = 8.5;
  static const double userIconActiveY = 6.6;

  /// الخطّ حول مربّع الحساب، من لوح العمل تحت `Home Page`: خطّ 0.3 `#1D1D1D`
  /// على المربّع بلا صورة، نشطاً كان أو ساكناً؛ وعلى صورةٍ خطٌّ بنفسجيّ 1 نشطاً
  /// وبرتقاليّ 1 ما بقي على المستخدم أن يوثّق؛ ولا خطّ على صورة موثَّقٍ ساكنة.
  static ({Color color, double width})? profileLine(
    bool on,
    bool photo,
    bool verified,
  ) {
    if (!photo) return (color: const Color(0xFF1D1D1D), width: 0.3);
    if (on) return (color: purple, width: 1);
    return verified ? null : (color: const Color(0xFFF5A03C), width: 1);
  }
}

/// نوابض الشريط ومُدَده — كلّها من الويب.
class NavMotion {
  const NavMotion._();

  /// تكبير الأيقونة النشطة وتصغيرها. أقلّ قليلاً من التخميد الحرجّ
  /// (26 مقابل 2·√(420·0.8) = 36.7)، فتتجاوز الأيقونة الجديدة حجمها بنسبةٍ
  /// صغيرة ثم تستقرّ — "جواب" اللمسة — في نحو 0.4 ثانية.
  static const double growStiffness = 420;
  static const double growDamping = 26;
  static const double growMass = 0.8;

  /// تبديل الأيقونة الساكنة بالنشطة أثناء التكبير — `SWAP`.
  static const Duration swap = Duration(milliseconds: 180);

  /// خبوّ مربّع الحساب — `PROFILE_FADE`.
  static const Duration profileFade = Duration(milliseconds: 250);

  /// يُحرّك المؤشّر، ويعيد الأيقونة من ضغطها.
  ///
  /// 38 / (2·√(560·0.85)) = 0.87، فيقطع المسافة سريعاً ويستقرّ بتجاوزٍ
  /// مقداره 0.4% — أصغر من أن يُرى تذبذباً.
  static const double travelStiffness = 560;
  static const double travelDamping = 38;
  static const double travelMass = 0.85;

  /// يستجيب لنزول الإصبع — `PRESS`.
  static const double pressStiffness = 700;
  static const double pressDamping = 38;
  static const double pressMass = 0.6;

  /// حجم الأيقونة تحت الإصبع.
  static const double pressScale = 0.88;

  /// نَفَسٌ واحد للشريط كلّه عند الضغط — `PULSE_*`.
  static const double pulsePeak = 1.035;
  static const Duration pulse = Duration(milliseconds: 400);

  /// ذروة النبضة عند 32% من مدّتها.
  static const double pulsePeakAt = 0.32;
  static const Cubic pulseEase = Cubic(0.22, 1, 0.36, 1);

  /// نبضتان أقرب من هذا نبضةٌ واحدة.
  static const Duration pulseGap = Duration(milliseconds: 260);
}

/// كيف يقرأ الشريط التمرير — `DEFAULT_NAV_THEME` وثوابت `useScrollScale`.
class NavScroll {
  const NavScroll._();

  /// أصغر حجمٍ يُسمح للشريط به: نسبةُ الارتفاعين (31 / 58)
  /// — `TAB_BAR_MIN_SCALE`.
  ///
  /// كانت 0.72 (`DEFAULT_NAV_THEME.minScale`) قبل تحديث الويب. والشريط الآن
  /// يضيق أيضاً وهو يصغر حتّى [NavBarDesign.minWidth]، فيصير حبّةً في
  /// البعدين.
  static const double minScale = NavBarDesign.minHeight / NavBarDesign.height;

  /// بكسلات تمريرٍ غير مستعجل تغطّي التغيّر كلّه، من أعلاه إلى أرضيّته.
  static const double distance = 320;

  /// كم تُحسب سرعةُ التمرير فوق مسافته. الصفر يُلغيها.
  static const double speedEffect = 1;

  /// سرعة التمرير (بكسل/ثانية) التي تضيف وحدة ربحٍ كاملة.
  static const double speedRef = 1200;

  /// ما قد يستحقّه بكسلٌ واحد من التمرير، مقابل 1.0 المجرَّدة.
  ///
  /// الأرضيّة تحت الواحد لتُحرّك الجرّة البطيئة جدّاً الشريطَ ببطءٍ لا بمعدّل
  /// تمريرٍ عاديّ — وهذا كلّ معنى حدّ السرعة. والسقف يمنع نفضةً قد تُبلِّغ
  /// آلاف البكسلات في الثانية من قطع المدى كلّه في إطارين.
  static const double minGain = 0.6;
  static const double maxGain = 2.2;

  /// تنعيمٌ على قراءة السرعة وحدها — لا على الموضع أبداً.
  ///
  /// المتصفّحات تُسلّم التمرير كُتَلاً، فتتأرجح البكسلات/الثانية الخامُ بين
  /// إطارٍ وإطار داخل اللمسة الواحدة. ومتوسّطُها على 80ms يُخرج ذلك من الربح.
  /// وتُترك المسافة مضبوطةً، فهي النصف الذي على الشريط أن يصدُق فيه: مرِّر
  /// 140 بكسلاً وقد صرفتَ 140، كيفما قطّعها المتصفّح.
  static const double speedTau = 0.08;

  /// إطاراتٌ بلا تمريرٍ قبل أن تتوقّف الحلقة عن السؤال.
  static const int idleFrames = 12;

  /// داخل هذا القدر من البكسلات من الأعلى يكون الشريط بحجمه الكامل دائماً.
  static const double topHold = 8;

  /// النابض بين التمرير والشاشة. هو وحده ما يجعل الحركة ناعمة، فمهمّته واحدة:
  /// يبلغ القيمة التي طلبها التمرير، سريعاً، بلا تذبذبٍ حولها.
  ///
  /// النابض حرجُّ التخميد عند damping = 2·√(stiffness·mass)، وهو هنا
  /// 2·√(300·0.85) = 31.9. فتخميد 30 يضع النسبة على 0.94، تحت الحرجّ بقليل:
  /// يستقرّ في نحو 170ms بتجاوزٍ أصغر من أن يُرى.
  static const double glideStiffness = 300;
  static const double glideDamping = 30;
  static const double glideMass = 0.85;
}
