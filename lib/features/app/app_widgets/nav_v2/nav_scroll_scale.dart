import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'nav_bar_design.dart';

/// حجم الشريط مدفوعاً بالتمرير — نقلٌ حرفيٌّ لـ`useScrollScale`
/// (`components/NavigationDemo/BottomNav.tsx`).
///
/// شيئان يُقرّران كم يتحرّك الشريط، وكلاهما مهمّ:
///
///   القيمة  كم مرّرت. [NavScroll.distance] بكسلاً من تمريرٍ غير مستعجل تغطّي
///           الطريق كلّه من الحجم الكامل إلى الأرضيّة. وهذا ما يجعل الشريط
///           يستجيب لجرّةٍ بطيئةٍ متعمَّدة أصلاً.
///   السرعة  كم أسرعت. النفضة تستحقّ للبكسل أكثر من الزحف، حتّى
///           [NavScroll.maxGain] أضعاف.
///
/// وهما يتضاربان: بكسلٌ واحد من التمرير يستحقّ (1/distance)·gain من الطريق،
/// وgain من السرعة. التمرير نزولاً يُضيف وصعوداً يطرح، بالقاعدة نفسها في
/// الاتّجاهين — الصعود ليس حالةً خاصّة.
///
/// البديل — السرعة وحدها — هو ما كان عليه هذا سابقاً وكان خطأً: كان يُصغّر
/// الشريط أيّاً كان اتّجاهك ويرجع فوراً حين تتوقّف، فلا يثبت الشريط على حجم
/// ولا يفعل الصعود شيئاً.
///
/// من أين يأتي التمرير
/// --------------------
/// في الويب `scope: "any"` يستمع في طور الالتقاط على المستند، فيسمع كلّ
/// عنصرٍ يُمرَّر صعوداً ونزولاً. وعندنا بديلُه
/// [ScrollNotificationObserver] الذي يُركّبه `Scaffold` حول محتواه كلّه، فيسمع
/// الشريط به تمريرَ أيّ صفحةٍ في الجسم. والصندوق الذي لا يُمرَّر صعوداً
/// ونزولاً (صفُّ رقاقاتٍ أفقيّ) غير محسوب، فسحبُه لا يُحرّك الشريط.
///
/// وفرقٌ واحد لصالحنا: الويب يحسب `y - lastY` بنفسه فيحتاج أن يتذكّر الصندوق
/// الذي جاء منه آخر تمرير لئلّا تُقرأ قفزةً عند تبدّل الصندوق.
/// و[ScrollUpdateNotification.scrollDelta] يُعطينا الفرق جاهزاً، فالمسألة
/// تزول من أصلها.
class NavScrollScale extends ChangeNotifier {
  NavScrollScale({required TickerProvider vsync}) {
    _ticker = vsync.createTicker(_tick);
  }

  late final Ticker _ticker;

  /// كم بلغنا من التغيّر: 0 عند الحجم الكامل، و1 عند الأرضيّة، ومحصورٌ بينهما
  /// دائماً. التمرير نزولاً يدفعه نحو 1 وصعوداً يسحبه نحو 0، ويبقى حيث تُرك
  /// حين تتوقّف الصفحة.
  double _travelled = 0;

  /// وبينه وبين الشاشة نابض، فما يرسمه الجهاز منحنىً ناعم حتّى حيث يصل
  /// التمرير كُتَلاً.
  double _eased = 0;
  double _velocity = 0;

  /// بكسلاتٌ موقَّعة مُرَّرت منذ نظرة الإطار الأخيرة. المستقبِل يُضيف إليها
  /// والإطار يُفرغها، فلا يُحسب شيءٌ مرّتين ولا يضيع شيءٌ بين حدثين يقعان في
  /// الإطار نفسه. وموقَّعة، فتمريرٌ نزولاً وآخر صعوداً داخل إطارٍ واحد
  /// يتلاشيان — وهو ما حدث فعلاً.
  double _pending = 0;
  double _speed = 0;
  int _idleFrames = 0;
  Duration _last = Duration.zero;

  /// آخر موضعٍ قرأناه، لحكم [NavScroll.topHold].
  double _lastPixels = 0;

  /// حجم الشريط. الطرفان حدّان صارمان فتُحصر النتيجة بهما: النابض مضبوطٌ تحت
  /// التخميد الحرجّ بقليل ولن يتجاوز الطرف إلّا بكسورِ بالمئة، لكنّ "لن
  /// يتجاوز إلّا" ليست "لا يستطيع"، وعلى الشريط ألّا يُرسم أصغر من الأرضيّة
  /// ولا أكبر من الكامل أبداً.
  double get scale =>
      _clamp(1 + _eased * (NavScroll.minScale - 1), NavScroll.minScale, 1);

  /// كم ينزل الشريط، بوحدة اللوح — `drop` في `Demo1BottomNav`.
  ///
  /// مشتقٌّ من حجم التمرير لا من الحجم المضروب بالنبضة، فالضغط لا يُنزل
  /// الشريط.
  double get drop =>
      ((1 - scale) / (1 - NavScroll.minScale)) * NavBarDesign.drop;

  /// تُغذّيه كلّ إشعارات التمرير من الجسم.
  void feed(ScrollNotification notification) {
    // الصندوق الأفقيّ لا يقول شيئاً عن الأعلى والأسفل.
    if (notification.metrics.axis != Axis.vertical) return;

    _lastPixels = notification.metrics.pixels;

    if (notification is ScrollUpdateNotification) {
      _pending += notification.scrollDelta ?? 0;
    } else if (notification is! ScrollEndNotification) {
      return;
    }

    _start();
  }

  /// يُعيد الشريط إلى حجمه الكامل. تُستدعى عند تبدّل الصفحة المعروضة، فالصفحة
  /// الجديدة تبدأ من أعلاها — `resetKey` في الويب.
  void reset() {
    _travelled = 0;
    _pending = 0;
    _speed = 0;
    _start();
  }

  void _start() {
    if (_ticker.isActive) return;
    _idleFrames = 0;
    _last = Duration.zero;
    _ticker.start();
  }

  void _tick(Duration elapsed) {
    // محصورٌ كي لا تُقسّم لسانٌ راجعٌ من الخلفيّة على فجوةٍ هائلة.
    final double dt = _last == Duration.zero
        ? 1 / 60
        : _clamp((elapsed - _last).inMicroseconds / 1e6, 0.001, 0.1);
    _last = elapsed;

    final double dy = _pending;
    _pending = 0;

    // نعّم السرعة واترك المسافة مضبوطة. انظر [NavScroll.speedTau].
    final double raw = dy.abs() / dt;
    _speed += (raw - _speed) * (1 - math.exp(-dt / NavScroll.speedTau));

    if (dy == 0) {
      _idleFrames += 1;
      if (_idleFrames > NavScroll.idleFrames) _speed = 0;
    } else {
      _idleFrames = 0;
      final double gain = _clamp(
        NavScroll.minGain +
            NavScroll.speedEffect * (_speed / NavScroll.speedRef),
        NavScroll.minGain,
        NavScroll.maxGain,
      );
      // النزول (dy > 0) يُضيف فيُصغّر، والصعود (dy < 0) يطرح فيُكبّر.
      // القاعدة واحدة في الاتّجاهين.
      _travelled = _clamp(_travelled + (dy / NavScroll.distance) * gain, 0, 1);
    }

    // أعلى الصفحة يُظهر الشريط بحجمه الكامل دائماً، كيفما حسبت الأسطر أعلاه.
    if (_lastPixels <= NavScroll.topHold) _travelled = 0;

    // النابض: تكاملٌ صريحٌ شبه ضمنيّ. عند ω = √(300/0.85) = 18.8 راد/ثانية
    // وإطارٍ من 1/60، ωΔt = 0.31 — مستقرٌّ بمراحل.
    final double a =
        (NavScroll.glideStiffness * (_travelled - _eased) -
            NavScroll.glideDamping * _velocity) /
        NavScroll.glideMass;
    _velocity += a * dt;
    _eased += _velocity * dt;

    notifyListeners();

    // لا شيء يتحرّك: أوقف الحلقة واترك الشريط على حجمه — هذا الحجم يتبع
    // التمرير فلا يرجع من تلقائه. وأوّل تمريرٍ تالٍ يُشغّل الحلقة مجدّداً.
    final bool settled =
        (_travelled - _eased).abs() < 0.0005 && _velocity.abs() < 0.0005;
    if (settled && _idleFrames > NavScroll.idleFrames) {
      _eased = _travelled;
      _velocity = 0;
      _ticker.stop();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  static double _clamp(double n, double min, double max) =>
      n < min ? min : (n > max ? max : n);
}
