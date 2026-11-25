/// حركةُ الشعار — نقلٌ لـ`web_design/NewLoginDesign/animations/`.
///
/// > «الشعارُ ثلاثةُ أشياء: النقطتان، والكلمة، وحلقةُ اللافتة المنقّطة.
/// > ونمطٌ يُحرّك النقطتين وحدَهما يُحرّك ثلثَ العلامة.»
///
/// والويبُ يحمل **عشرةَ أنماط**، تسعةٌ منها مُنتقي الديمو. والمنتَجُ لا
/// يُشغّل إلّا اثنين، كما يُثبّتهما `logoScreenConfig.ts`:
///
///   - `relay` «المناوبة» — كلُّ شاشةٍ من الشروط إلى النجاح، ثلاثُ ثوانٍ
///     للدورة، تتكرّر؛
///   - `reveal` «البناءُ السينمائيّ» — كلمةُ المعاينة السريعة (مرّةً بلا
///     تكرار، **ولا تمسّ الكلمة**)، وأوّلُ خطوةٍ في «ابدأ» ثمّ تُسلّم إلى
///     المناوبة.
///
/// ## قواعدُ الويب التي يحفظها هذا الملفّ
///
///   1. **لا يُعاد تشكيلُ حرف.** لا خطَّ ولا مُرشِّحَ ولا لوناً جديداً
///      للكلمة: تُحرَّك كاملةً، أو يُخفى جزءٌ منها بقصٍّ، لا غير.
///   2. **لا تُكتب الرسمةُ من جديد.** الأصولُ الثلاثةُ (`badge_ring.svg` و
///      `badge_word.svg` و`header_word.svg`) **مقطوعةٌ آليّاً** من
///      `badge.svg` و`wordmark.svg` بمساراتها وتحويلاتها كما هي، فلا يفترق
///      جزءٌ عن كلّه. والنقطتان دائرتان (نصفُ قطرهما 11.322 و11.321)،
///      فتُرسمان رسماً.
///   3. **الزخرفةُ خلفَ العلامة** — ظلُّ الكلمة يُرسم أوّلاً.
///   4. **كلُّ دورةٍ تعود إلى حيث بدأت بالضبط**: آخرُ مفتاحٍ يساوي أوّلَه.
///   5. **تقليلُ الحركة يفوز**: إن طلب الجهازُ ذلك ظهرت العلامةُ ساكنةً كما
///      رُسمت، لا بطيئةً.
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'auth_logo.dart' show AuthBadgeTone, kAuthSvg;

// ════════════════════════════════════════════════════════════════════════
//  الهندسة — `geometry.ts`: من أين يتعلّم النمطُ إحداثيّاته
// ════════════════════════════════════════════════════════════════════════

enum LogoVariant { header, badgeRing }

/// أين يقع كلُّ جزءٍ من العلامة، بوحدات `viewBox` الخاصّة بها.
class LogoGeometry {
  const LogoGeometry({
    required this.width,
    required this.height,
    required this.dotR,
    required this.leftDot,
    required this.rightDot,
    required this.wordmark,
    required this.wordAsset,
    this.ring,
  });

  final double width;
  final double height;

  /// نصفُ قطر نقطتي العلامة.
  final double dotR;
  final Offset leftDot;
  final Offset rightDot;

  /// صندوقُ حبر الكلمة، مقيسٌ في متصفّحٍ بـ`getBBox()` لا مُقدَّراً — وقصُّ
  /// البناء يتّكئ عليه، فتقديرٌ أقصرُ ببكسلين يقطع نازلَ الـ«y» بلا أن يُرى.
  final Rect wordmark;

  final String wordAsset;

  /// حلقةُ اللافتة المنقّطة. و`null` في لوحة الرأس، فلا حلقةَ لها.
  final ({double cx, double cy, double r})? ring;

  /// الفراغُ بين حافّتي النقطتين — كلُّ مسافاتِ المناوبة كسورٌ منه، فتُعيد
  /// الحركةُ قياسَ نفسها لو تبدّلت الرسمة.
  double get freeSpace => rightDot.dx - leftDot.dx - dotR * 2;
}

/// لوحةُ الرأس — `viewBox "0 0 176.18 87.574"`.
const LogoGeometry kHeaderGeometry = LogoGeometry(
  width: 176.18,
  height: 87.574,
  dotR: 11.321,
  leftDot: Offset(23.93, 11.321),
  rightDot: Offset(54.12, 11.321),
  wordmark: Rect.fromLTWH(0, 32.516, 176.191, 55.058),
  wordAsset: 'header_word',
);

/// حلقةُ اللافتة — `viewBox "0 0 150 150"`. ونقطُها الصغيرةُ نصفُ قطرها
/// 0.938، فمركزُ مسارها 75 − 0.938.
const LogoGeometry kBadgeGeometry = LogoGeometry(
  width: 150,
  height: 150,
  dotR: 11.322,
  leftDot: Offset(59.928, 42.953),
  rightDot: Offset(90.12, 42.953),
  wordmark: Rect.fromLTWH(35.397, 69.367, 79.259, 49.997),
  wordAsset: 'badge_word',
  ring: (cx: 75, cy: 75, r: 74.062),
);

LogoGeometry geometryOf(LogoVariant v) =>
    v == LogoVariant.header ? kHeaderGeometry : kBadgeGeometry;

/// ألوانُ العلامة — لا تُحسب: الكلمةُ `#1d1d1d` دائماً، والنقطتان لونُ
/// الشاشة، والحلقةُ تبقى بنفسجيّةً إلّا في الأخضر.
abstract class LogoInk {
  static const Color word = Color(0xFF1D1D1D);
  static const Color purple = Color(0xFF402CDD);
  static const Color amber = Color(0xFFFAAA2E);
  static const Color green = Color(0xFF28C452);

  static Color dots(AuthBadgeTone tone) => switch (tone) {
    AuthBadgeTone.purple => purple,
    AuthBadgeTone.amber => amber,
    AuthBadgeTone.green => green,
  };

  /// وفي «غيرُ مسجَّل» تتحوّل النقطتان وحدَهما، والحلقةُ تبقى بنفسجيّة.
  static Color ring(AuthBadgeTone tone) =>
      tone == AuthBadgeTone.green ? green : purple;

  /// مزجٌ نحو الأبيض — `lighten` في `color.ts`: كلُّ قناةٍ تُقرَّب نحو 255
  /// بمقدار [amount].
  static Color lighten(Color c, double amount) {
    double mix(double channel) => channel + (1 - channel) * amount;
    return Color.from(
      alpha: c.a,
      red: mix(c.r),
      green: mix(c.g),
      blue: mix(c.b),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
//  المفاتيح — قائمةُ قيمٍ وأزمنةٍ ومنحنىً لكلّ قطعة
// ════════════════════════════════════════════════════════════════════════

/// مسارٌ مُفتَّحٌ: القيمةُ عند أيّ لحظةٍ من الدورة (0 إلى 1).
///
/// ومنحنىً **لكلّ قطعةٍ** لا منحنىً واحدٌ للقائمة: فسحبُ الاستعداد يدخل
/// بلينٍ، والرمي يتسارع، والصدمةُ تقف ميتةً — ولا تصلح لها جميعاً منحنيةٌ
/// واحدة. و[eases] أقصرُ من [values] بواحد، كما يشترط الملفّ.
class LogoTrack {
  const LogoTrack(this.times, this.values, this.eases);

  final List<double> times;
  final List<double> values;
  final List<Curve> eases;

  double at(double t) {
    if (t <= times.first) return values.first;
    if (t >= times.last) return values.last;
    for (int i = 0; i < times.length - 1; i += 1) {
      final double a = times[i];
      final double b = times[i + 1];
      if (t > b) continue;
      if (b <= a) return values[i + 1];
      final double local = (t - a) / (b - a);
      final double eased = eases[i].transform(local.clamp(0.0, 1.0));
      return values[i] + (values[i + 1] - values[i]) * eased;
    }
    return values.last;
  }
}

/// حالةُ نقطةٍ في لحظة.
class DotFrame {
  const DotFrame({
    this.x = 0,
    this.y = 0,
    this.scaleX = 1,
    this.scaleY = 1,
    this.opacity = 1,
  });

  final double x;
  final double y;
  final double scaleX;
  final double scaleY;
  final double opacity;
}

/// حالةُ العلامة كلِّها في لحظة.
class LogoFrame {
  const LogoFrame({
    this.left = const DotFrame(),
    this.right = const DotFrame(),
    this.ringScale = 1,
    this.ringReveal,
    this.wipeWidth,
    this.echoX = 0,
    this.echoOpacity = 0,
  });

  final DotFrame left;
  final DotFrame right;

  /// صدمةُ الحلقة — الحاويةُ تمتصّ الضربة باتّساعٍ 2.2٪.
  final double ringScale;

  /// كم رُسم من الحلقة (0 إلى 1)، و`null` تعني الحلقةَ كاملةً.
  final double? ringReveal;

  /// عرضُ قصّ الكلمة بوحدات الرسمة، و`null` تعني بلا قصّ.
  final double? wipeWidth;

  /// ظلُّ الكلمة: إزاحتُه وعُتمتُه.
  final double echoX;
  final double echoOpacity;
}

// ════════════════════════════════════════════════════════════════════════
//  ٢ — المناوبة (`relay`). لغةُ الحركة: الثِقَل.
// ════════════════════════════════════════════════════════════════════════

/// > «حِملٌ يُسلَّم من نقطةٍ إلى أُخرى ويعود، إلى الأبد. والسوقُ أشياءُ
/// > تتبادل الأيدي، فالعلامةُ تفعل ذلك بالشيئين الوحيدين عندها.
/// >
/// > ولكلّ تسليمٍ أربعُ دقّات، وحياتُه كلُّها في أنّ أطوالَها أربعةٌ مختلفة:
/// >   استعدادٌ 290مث — الرامي يسحب نفسَه **بعيداً** عن المُستلم أوّلاً
/// >   رميٌ     240مث — يستطيل في مساره ويُفلت
/// >   صدمةٌ     96مث — التلاقي، والمستلمُ يُدفع في الإطار نفسِه، لا ينتظر
/// >   متابعةٌ  430مث — يتجاوزان موضعَهما ثمّ يستقرّان
/// >
/// > ثمّ 900مث سكونٌ تامٌّ قبل التمريرة العائدة. والسكونُ يعمل كما تعمل
/// > الحركة: لا تُقرأ النبرةُ نبرةً إلّا إذا لم يكن حولَها شيء.»
///
/// والحجمُ محفوظ: نقطةٌ تستطيل إلى 1.4 عرضاً تُضغط إلى 0.71 طولاً —
/// 1.4 × 0.71 = 0.994. فالشكلُ يتشوّه، وكمّيةُ الحبر لا. ولذلك يُقرأ
/// الاستطالةُ سرعةً لا جِرماً يكبر.
class _Beat {
  const _Beat(this.t, this.x, this.sx, this.sy, this.ease);

  final double t;
  final double x;
  final double sx;
  final double sy;

  /// المنحنى الذي **يُوصِل** إلى هذه الدقّة. ويُهمَل في الأولى.
  final Curve ease;

  _Beat get mirrored => _Beat(t + 0.5, -x, sx, sy, ease);
}

/// تُدمج نصفا الدورة: كلُّ نقطةٍ ترمي مرّةً وتستلم مرّةً، بينهما نصفُ دورة،
/// والنصفُ الثاني هو الأوّلُ معكوساً. فتُكتب الحركةُ مرّةً ويُشتقّ عكسُها —
/// وكتابةُ النصفين بالأيدي هي التي تُخرج تمريرتين بطولين مختلفين قليلاً،
/// فتُقرأ خطأً لا إيقاعاً.
List<_Beat> _fullCycle(List<_Beat> first, List<_Beat> second) {
  final List<_Beat> all = <_Beat>[
    ...first,
    ...second.map((_Beat b) => b.mirrored),
    const _Beat(1, 0, 1, 1, Curves.linear),
  ]..sort((_Beat a, _Beat b) => a.t.compareTo(b.t));
  // ونقطةٌ تبدأ وسطَ الدورة عليها أن تقول أين هي عند الصفر.
  if (all.first.t > 0) {
    all.insert(0, const _Beat(0, 0, 1, 1, Curves.linear));
  }
  return all;
}

({LogoTrack x, LogoTrack sx, LogoTrack sy}) _dotTracks(List<_Beat> beats) {
  final List<double> times = beats.map((_Beat b) => b.t).toList();
  final List<Curve> eases = beats
      .sublist(1)
      .map((_Beat b) => b.ease)
      .toList();
  return (
    x: LogoTrack(times, beats.map((_Beat b) => b.x).toList(), eases),
    sx: LogoTrack(times, beats.map((_Beat b) => b.sx).toList(), eases),
    sy: LogoTrack(times, beats.map((_Beat b) => b.sy).toList(), eases),
  );
}

class RelayPattern {
  RelayPattern(this.geo) {
    final double free = geo.freeSpace;
    final double travel = free * 0.61;
    final double pullBack = free * 0.2;
    final double recoil = free * 0.29;

    final List<_Beat> throwBeats = <_Beat>[
      const _Beat(0, 0, 1, 1, Curves.linear),
      // سحبٌ إلى الوراء قبل المضيّ. وبلا هذا لا ثِقَلَ للرمي.
      _Beat(0.06, -pullBack, 0.88, 1.12, Curves.easeInOut),
      // تسارعٌ إلى التلاقي ثمّ قطع. والرمياتُ الحقيقيّةُ لا تُلَيَّن نهايتُها.
      _Beat(0.11, travel, 1.4, 0.71, Curves.easeIn),
      _Beat(0.13, travel * 0.62, 0.93, 1.06, Curves.easeOut),
      _Beat(0.22, -pullBack * 0.35, 1.04, 0.97, Curves.easeOut),
      const _Beat(0.3, 0, 1, 1, Curves.easeInOut),
    ];

    final List<_Beat> catchBeats = <_Beat>[
      const _Beat(0.11, 0, 1, 1, Curves.linear),
      // يُدفع في إطار التلاقي، لا بعده.
      _Beat(0.13, recoil, 1.2, 0.84, Curves.easeOut),
      _Beat(0.19, recoil * 0.35, 0.94, 1.05, Curves.easeOut),
      const _Beat(0.27, 0, 1.02, 0.98, Curves.easeOut),
      const _Beat(0.32, 0, 1, 1, Curves.easeInOut),
    ];

    // اليسرى ترمي في النصف الأوّل وتستلم في الثاني، واليمنى بالعكس —
    // القائمتان نفسُهما مُبادَلتين.
    _left = _dotTracks(_fullCycle(throwBeats, catchBeats));
    _right = _dotTracks(_fullCycle(catchBeats, throwBeats));
  }

  final LogoGeometry geo;
  late final ({LogoTrack x, LogoTrack sx, LogoTrack sy}) _left;
  late final ({LogoTrack x, LogoTrack sx, LogoTrack sy}) _right;

  /// والكلمةُ تتأخّر عن التمريرة وتصل متأخّرة — ثقيلٌ يجرّه خفيف. الصدمتان
  /// على 0.13 و0.63، وذروةُ الظلّ على 0.17 و0.67.
  static const LogoTrack _echoX = LogoTrack(
    <double>[0, 0.12, 0.17, 0.34, 0.5, 0.62, 0.67, 0.84, 1],
    <double>[0, 0, 1.7, 0, 0, 0, -1.7, 0, 0],
    <Curve>[
      Curves.easeOut,
      Curves.easeOut,
      Curves.easeOut,
      Curves.easeOut,
      Curves.easeOut,
      Curves.easeOut,
      Curves.easeOut,
      Curves.easeOut,
    ],
  );

  static const LogoTrack _echoOpacity = LogoTrack(
    <double>[0, 0.12, 0.17, 0.34, 0.5, 0.62, 0.67, 0.84, 1],
    <double>[0.1, 0.1, 0.2, 0.1, 0.1, 0.1, 0.2, 0.1, 0.1],
    <Curve>[
      Curves.easeOut,
      Curves.easeOut,
      Curves.easeOut,
      Curves.easeOut,
      Curves.easeOut,
      Curves.easeOut,
      Curves.easeOut,
      Curves.easeOut,
    ],
  );

  /// وعلى اللافتة تأخذ الحلقةُ الصدمةَ اتّساعاً 2.2٪.
  static const LogoTrack _ringScale = LogoTrack(
    <double>[0, 0.12, 0.145, 0.24, 0.5, 0.62, 0.645, 0.74, 1],
    <double>[1, 1, 1.022, 1, 1, 1, 1.022, 1, 1],
    <Curve>[
      Curves.easeOut,
      Curves.easeOut,
      Curves.easeOut,
      Curves.easeOut,
      Curves.easeOut,
      Curves.easeOut,
      Curves.easeOut,
      Curves.easeOut,
    ],
  );

  /// منافذُ تجربةٍ على مسارات الزخرفة الثابتة، لتُفحص أطوالُها.
  static LogoTrack get debugEchoX => _echoX;
  static LogoTrack get debugEchoOpacity => _echoOpacity;
  static LogoTrack get debugRingScale => _ringScale;

  LogoFrame frameAt(double t) => LogoFrame(
    left: DotFrame(
      x: _left.x.at(t),
      scaleX: _left.sx.at(t),
      scaleY: _left.sy.at(t),
    ),
    right: DotFrame(
      x: _right.x.at(t),
      scaleX: _right.sx.at(t),
      scaleY: _right.sy.at(t),
    ),
    ringScale: geo.ring == null ? 1 : _ringScale.at(t),
    echoX: _echoX.at(t),
    echoOpacity: _echoOpacity.at(t),
  );
}

// ════════════════════════════════════════════════════════════════════════
//  ٨ — البناءُ السينمائيّ (`reveal`). يبني ثمّ يبقى مبنيّاً.
// ════════════════════════════════════════════════════════════════════════

/// > «تتجمّع العلامةُ في ثلاث دقّاتٍ متراكبةٍ وتقف على العلامة التامّة:
/// >   0٪   تبدأ الحلقةُ ترسم نفسَها من الأعلى
/// >   21٪  تبدأ الكلمةُ تُكشف من اليسار
/// >   66٪  تبدأ النقطتان تهبطان، اليسرى أوّلاً
/// >   100٪ مبنيّة — وتبقى ما دامت الشاشةُ معروضة.
/// >
/// > وكان يُعيد البناءَ معكوساً ثمّ يبدأ من جديد. وذلك خطأٌ لما تفعله
/// > الشاشة: العلامةُ تُعرَّف، وتعريفٌ يُفكّك نفسَه كلَّ ثوانٍ يُقرأ حالةَ
/// > تحميل.»
///
/// ولا تُرسم الكلمةُ بخطٍّ متقطّعٍ يُحرَّك إزاحتُه — فتلك حيلةٌ تحتاج أن
/// **تُضيف** خطّاً إلى حرفٍ محشوّ، وخطُّ 1.5 على شعارٍ عرضُه 176 يُسمِّن كلَّ
/// حرفٍ ويُغلق عيونَ الـ«d» والـ«o». فالقصُّ بدلَها: يُخفي ولا يُشوّه.
class RevealPattern {
  RevealPattern(this.geo, {required this.animateWord}) {
    final bool isBadge = geo.ring != null;

    // واللافتةُ تبدأ متأخّرةً في الدقّتين، فعندها حلقةٌ تُرسم أوّلاً.
    final double wipeStart = isBadge ? 0.3 : 0.15;
    final double wipeEnd = wipeStart + 0.85;
    final double dropStart = isBadge ? 0.95 : 0.75;

    // والبناءُ ينتهي بهبوط آخر نقطة، وهي اليمنى، بعد اليسرى بـ80مث. والقياسُ
    // منها — لا من رقمٍ ثابت — هو ما يجعل المدّةَ كلَّها بناءً: للّافتة حلقةٌ
    // تُرسم أوّلاً فتطول، ولوحةُ الرأس لا شيءَ تنتظره.
    final double build = dropStart + 0.08 + _drop;
    double at(double seconds) => seconds / build;

    _wipe = LogoTrack(
      <double>[0, at(wipeStart), at(wipeEnd), 1],
      <double>[0, 0, geo.wordmark.width + 6, geo.wordmark.width + 6],
      const <Curve>[Curves.linear, _wipeIn, Curves.linear],
    );

    _leftDrop = _dropTracks(at(dropStart), at(dropStart + _overshoot), at(dropStart + _drop));
    _rightDrop = _dropTracks(
      at(dropStart + 0.08),
      at(dropStart + 0.08 + _overshoot),
      at(dropStart + 0.08 + _drop),
    );

    _ringDraw = isBadge
        ? LogoTrack(
            <double>[0, at(1), 1],
            <double>[0, 1, 1],
            const <Curve>[_ringEase, Curves.linear],
          )
        : null;
  }

  final LogoGeometry geo;

  /// `animateWord: false` تسحب القصَّ من النمط، فتقف الكلمةُ وتتحرّك الحلقةُ
  /// والنقطتان — وهو ما يطلبه التصميمُ لكلمة المعاينة السريعة وحدَها:
  /// «بناءٌ سينمائيٌّ لا تُكشف حروفُه».
  final bool animateWord;

  static const double _drop = 0.4;
  static const double _overshoot = 0.22;
  static const Cubic _wipeIn = Cubic(0.22, 1, 0.36, 1);
  static const Cubic _ringEase = Cubic(0.65, 0, 0.35, 1);

  late final LogoTrack _wipe;
  late final LogoTrack? _ringDraw;
  late final ({LogoTrack y, LogoTrack scale, LogoTrack opacity}) _leftDrop;
  late final ({LogoTrack y, LogoTrack scale, LogoTrack opacity}) _rightDrop;

  /// مسيرةُ نقطةٍ كاملة: تنتظر فوق العلامة، وتهبط متجاوزةً موضعَها، وتستقرّ
  /// عليه، وتبقى.
  static ({LogoTrack y, LogoTrack scale, LogoTrack opacity}) _dropTracks(
    double start,
    double over,
    double end,
  ) {
    final List<double> times = <double>[0, start, over, end, 1];
    const List<Curve> eases = <Curve>[
      Curves.linear,
      Curves.easeOut,
      Curves.easeOut,
      Curves.linear,
    ];
    return (
      y: LogoTrack(times, const <double>[-16, -16, 2.5, 0, 0], eases),
      scale: LogoTrack(times, const <double>[0.5, 0.5, 1.06, 1, 1], eases),
      opacity: LogoTrack(times, const <double>[0, 0, 1, 1, 1], eases),
    );
  }

  LogoFrame frameAt(double t) => LogoFrame(
    left: DotFrame(
      y: _leftDrop.y.at(t),
      scaleX: _leftDrop.scale.at(t),
      scaleY: _leftDrop.scale.at(t),
      opacity: _leftDrop.opacity.at(t),
    ),
    right: DotFrame(
      y: _rightDrop.y.at(t),
      scaleX: _rightDrop.scale.at(t),
      scaleY: _rightDrop.scale.at(t),
      opacity: _rightDrop.opacity.at(t),
    ),
    ringReveal: _ringDraw?.at(t),
    wipeWidth: animateWord ? _wipe.at(t) : null,
  );
}

// ════════════════════════════════════════════════════════════════════════
//  إعدادُ الشاشات — `logoScreenConfig.ts`
// ════════════════════════════════════════════════════════════════════════

enum LogoPattern { none, relay, reveal }

class LogoStep {
  const LogoStep(this.animation, this.seconds);

  final LogoPattern animation;
  final double seconds;
}

class LogoSlotConfig {
  const LogoSlotConfig({
    required this.steps,
    required this.loop,
    this.animateWord = true,
  });

  /// تُعرض بالترتيب. وواحدةٌ هي الحالةُ الغالبة.
  final List<LogoStep> steps;

  /// تُبقي الخطوةَ الأخيرةَ إلى الأبد بدل الوقوف على العلامة الساكنة.
  ///
  /// والقائمةُ تُعرض مرّةً في الحالين. والسلسلةُ تعريفٌ يتبعه سكون: «ابدأ»
  /// تبني مرّةً ثمّ تُسلّم. وإعادةُ البناء كلَّ ثوانٍ تُقرأ حالةَ تحميل.
  final bool loop;

  /// يترك النمطَ يمسّ الكلمة.
  final bool animateWord;
}

/// «المناوبة» — ما تعرضه كلُّ شاشةٍ من الشروط إلى النجاح: ثلاثُ ثوانٍ للمرّة.
const LogoSlotConfig kHandOff = LogoSlotConfig(
  steps: <LogoStep>[LogoStep(LogoPattern.relay, 3)],
  loop: true,
);

/// اختياراتُ العميل كما ثبّتها الملفّ في 3 أيلول 2026.
abstract class LogoSlots {
  /// بناءٌ سينمائيٌّ مرّةً، والحروفُ تقف ساكنةً والعيونُ تهبط حولها. ولا
  /// تكرار: تبقى العلامةُ المبنيّةُ للثواني الثماني.
  static const LogoSlotConfig quickPreviewWordmark = LogoSlotConfig(
    steps: <LogoStep>[LogoStep(LogoPattern.reveal, 3)],
    loop: false,
    animateWord: false,
  );

  static const LogoSlotConfig quickPreviewBadge = kHandOff;

  /// السلسلةُ الوحيدةُ في المجموعة: تبني مرّةً ثمّ تُناوب إلى الأبد.
  static const LogoSlotConfig getStarted = LogoSlotConfig(
    steps: <LogoStep>[
      LogoStep(LogoPattern.reveal, 3),
      LogoStep(LogoPattern.relay, 3),
    ],
    loop: true,
  );

  /// وسائرُ الشاشات: الشروطُ والهاتفُ والطريقةُ والرمزُ والنتيجتان والاسمُ
  /// والنجاح.
  static const LogoSlotConfig inner = kHandOff;
}

// ════════════════════════════════════════════════════════════════════════
//  العلامةُ وهي تتحرّك
// ════════════════════════════════════════════════════════════════════════

/// الشعارُ يعرض ما يقوله مكانُه.
///
/// والتسلسلُ يُدار من خارج النمط: كلُّ خطوةٍ تعمل ثوانيها ثمّ تُسلَّم التي
/// بعدها. فإن انتهت القائمةُ ولم يكن المكانُ يُكرّر صارت العلامةُ ساكنةً كما
/// رُسمت؛ وإن كان يُكرّر ثُبِّتت الأخيرةُ إلى الأبد.
class AuthLogoMark extends StatefulWidget {
  const AuthLogoMark({
    super.key,
    required this.variant,
    required this.slot,
    required this.size,
    this.tone = AuthBadgeTone.purple,
  });

  final LogoVariant variant;
  final LogoSlotConfig slot;

  /// عرضُ العلامة ببكسل الشاشة؛ وطولُها يتبع نسبةَ رسمتها.
  final double size;

  final AuthBadgeTone tone;

  @override
  State<AuthLogoMark> createState() => _AuthLogoMarkState();
}

class _AuthLogoMarkState extends State<AuthLogoMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _run = AnimationController(vsync: this);
  int _index = 0;
  Timer? _hand;

  LogoGeometry get _geo => geometryOf(widget.variant);

  List<LogoStep> get _steps => widget.slot.steps.isEmpty
      ? const <LogoStep>[LogoStep(LogoPattern.none, 0)]
      : widget.slot.steps;

  /// الخطوةُ الأخيرةُ في قائمةٍ تُكرّر لا تنتهي، فلا ساعةَ لها.
  bool get _endless => widget.slot.loop && _index == _steps.length - 1;

  LogoStep get _step =>
      _index >= _steps.length ? const LogoStep(LogoPattern.none, 0) : _steps[_index];

  @override
  void initState() {
    super.initState();
    _play();
  }

  @override
  void didUpdateWidget(AuthLogoMark old) {
    super.didUpdateWidget(old);
    // قائمةٌ جديدةٌ عرضٌ جديد، لا متابعةً للقديم.
    if (old.slot != widget.slot) {
      _index = 0;
      _play();
    }
  }

  @override
  void dispose() {
    _hand?.cancel();
    _run.dispose();
    super.dispose();
  }

  void _play() {
    _hand?.cancel();
    final LogoStep step = _step;
    if (step.animation == LogoPattern.none || step.seconds <= 0) {
      _run.stop();
      return;
    }
    _run.duration = Duration(milliseconds: (step.seconds * 1000).round());
    // المناوبةُ تتكرّر، والبناءُ يعمل مرّةً ويقف على آخر مفتاح.
    if (step.animation == LogoPattern.relay) {
      // من الصفر صراحةً: `repeat` تبدأ من حيث وقفت السابقة، فتُقصّ أوّلُ
      // دورةٍ بعد البناء في سلسلة «ابدأ».
      _run.value = 0;
      _run.repeat();
    } else {
      _run.forward(from: 0);
    }
    if (_endless || _index >= _steps.length) return;
    _hand = Timer(
      Duration(milliseconds: (math.max(1, step.seconds) * 1000).round()),
      () {
        if (!mounted) return;
        setState(() => _index += 1);
        _play();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final LogoGeometry geo = _geo;
    final double k = widget.size / geo.width;

    // تقليلُ الحركة يفوز، وهو أوّلُ ما يُفحص: العلامةُ ساكنةٌ كما رُسمت، لا
    // بطيئةً.
    final bool calm = MediaQuery.disableAnimationsOf(context);
    final LogoPattern pattern = calm ? LogoPattern.none : _step.animation;

    final RelayPattern? relay = pattern == LogoPattern.relay
        ? RelayPattern(geo)
        : null;
    final RevealPattern? reveal = pattern == LogoPattern.reveal
        ? RevealPattern(geo, animateWord: widget.slot.animateWord)
        : null;

    return SizedBox(
      width: widget.size,
      height: geo.height * k,
      child: AnimatedBuilder(
        animation: _run,
        builder: (BuildContext context, Widget? _) {
          final double t = _run.value;
          final LogoFrame f = relay?.frameAt(t) ?? reveal?.frameAt(t) ?? const LogoFrame();
          return Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              // الزخرفةُ أوّلاً، فالعلامةُ فوقها دائماً.
              if (f.echoOpacity > 0) _echo(geo, k, f),
              if (geo.ring != null) _ring(geo, k, f),
              _word(geo, k, f),
              _dot(geo, k, geo.leftDot, f.left),
              _dot(geo, k, geo.rightDot, f.right),
            ],
          );
        },
      ),
    );
  }

  /// ظلُّ الكلمة: نسخةٌ ثانيةٌ من الحرف نفسِه **خلف** الحقيقيّ، مُلوَّنةً
  /// ومُحرَّكة. فالحروفُ الحقيقيّةُ لا تُمسّ: هي المسارُ نفسُه بالحشو نفسِه
  /// فوقها. وما يتحرّك ظلٌّ يظهر بكسلين على حافّةٍ واحدة.
  Widget _echo(LogoGeometry geo, double k, LogoFrame f) => Positioned.fill(
    child: Transform.translate(
      offset: Offset(f.echoX * k, 0),
      child: Opacity(
        opacity: f.echoOpacity,
        child: SvgPicture.asset(
          'assets/svg/$kAuthSvg/${geo.wordAsset}.svg',
          colorFilter: ColorFilter.mode(
            LogoInk.lighten(LogoInk.dots(widget.tone), 0.42),
            BlendMode.srcIn,
          ),
        ),
      ),
    ),
  );

  Widget _ring(LogoGeometry geo, double k, LogoFrame f) {
    Widget ring = SvgPicture.asset(
      'assets/svg/$kAuthSvg/badge_ring.svg',
      colorFilter: ColorFilter.mode(
        LogoInk.ring(widget.tone),
        BlendMode.srcIn,
      ),
    );
    final double? drawn = f.ringReveal;
    if (drawn != null && drawn < 1) {
      ring = ClipPath(
        clipper: _RingSweep(geo: geo, scale: k, progress: drawn),
        child: ring,
      );
    }
    return Positioned.fill(
      child: Transform.scale(scale: f.ringScale, child: ring),
    );
  }

  Widget _word(LogoGeometry geo, double k, LogoFrame f) {
    Widget word = SvgPicture.asset(
      'assets/svg/$kAuthSvg/${geo.wordAsset}.svg',
      colorFilter: const ColorFilter.mode(LogoInk.word, BlendMode.srcIn),
    );
    final double? wipe = f.wipeWidth;
    if (wipe != null) {
      word = ClipRect(
        clipper: _WordWipe(geo: geo, scale: k, width: wipe),
        child: word,
      );
    }
    return Positioned.fill(child: word);
  }

  /// النقطةُ دائرةٌ تُرسم رسماً، لا صورةً تُحمَّل — ونصفُ قطرها ومركزُها من
  /// الهندسة.
  Widget _dot(
    LogoGeometry geo,
    double k,
    Offset centre,
    DotFrame d,
  ) => Positioned(
    left: (centre.dx - geo.dotR) * k,
    top: (centre.dy - geo.dotR) * k,
    child: Transform.translate(
      offset: Offset(d.x * k, d.y * k),
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.diagonal3Values(d.scaleX, d.scaleY, 1),
        child: Opacity(
          opacity: d.opacity.clamp(0.0, 1.0),
          child: Container(
            width: geo.dotR * 2 * k,
            height: geo.dotR * 2 * k,
            decoration: BoxDecoration(
              color: LogoInk.dots(widget.tone),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    ),
  );
}

/// قصُّ الكلمة: مستطيلٌ ينمو من اليسار. والويبُ يبدؤه 3 قبل حرفها و4 فوقه
/// ويُنهيه 6 أوسعَ منها، فينفتح أوسعَ من الحروف من جهاته الأربع ويُغلق إلى
/// لا شيء — فكلُّ دورةٍ تبدأ من حيث بدأت الأولى.
class _WordWipe extends CustomClipper<Rect> {
  const _WordWipe({
    required this.geo,
    required this.scale,
    required this.width,
  });

  final LogoGeometry geo;
  final double scale;
  final double width;

  @override
  Rect getClip(Size size) => Rect.fromLTWH(
    (geo.wordmark.left - 3) * scale,
    (geo.wordmark.top - 4) * scale,
    width * scale,
    (geo.wordmark.height + 8) * scale,
  );

  @override
  bool shouldReclip(_WordWipe old) => old.width != width || old.scale != scale;
}

/// رسمُ الحلقة: قطاعٌ يبدأ من أعلى الدائرة ويدور مع عقارب الساعة.
///
/// والويبُ يُقنّعها بخطٍّ متقطّعٍ طولُ شرطته محيطُ الحلقة، تنقص إزاحتُه من
/// المحيط إلى الصفر مع `rotate(-90)` — فيُكشف المسارُ من أعلاه في جهة رسمه،
/// وجهةُ `<circle>` في SVG مع عقارب الساعة. والقطاعُ يكشف المدى نفسَه، فحلقةٌ
/// رقيقةٌ لا يفرّق فيها الاثنان.
class _RingSweep extends CustomClipper<Path> {
  const _RingSweep({
    required this.geo,
    required this.scale,
    required this.progress,
  });

  final LogoGeometry geo;
  final double scale;
  final double progress;

  @override
  Path getClip(Size size) {
    final ({double cx, double cy, double r})? ring = geo.ring;
    if (ring == null || progress <= 0) return Path();
    final Offset centre = Offset(ring.cx * scale, ring.cy * scale);
    // نصفُ قطرٍ أوسعُ من الحلقة، فلا يقصُّ القطاعُ حرفَ نقطةٍ من نقطها.
    final double r = (ring.r + 4) * scale;
    return Path()
      ..moveTo(centre.dx, centre.dy)
      ..arcTo(
        Rect.fromCircle(center: centre, radius: r),
        -math.pi / 2,
        2 * math.pi * progress.clamp(0.0, 1.0),
        false,
      )
      ..close();
  }

  @override
  bool shouldReclip(_RingSweep old) =>
      old.progress != progress || old.scale != scale;
}
