import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../my_cached_network_image.dart';
import 'nav_bar_design.dart';
import 'nav_scroll_scale.dart';

/// الشريط السفليّ للتصميم الجديد (لوح `Home Page`)، بحركة الشريط المبنيّة
/// لصفحة /navigation في الويب:
///
///   - مرِّر نزولاً فيصغر الشريط إلى مركزه، وصعوداً فيعود — [NavScrollScale]
///     نفسه، مستمعاً إلى أيّ صندوقٍ يُمرَّر في الجسم. والتمرير نفسه يُنزل
///     الشريط أيضاً، حتّى [NavBarDesign.drop] (35): صفحةُ الملفّ الممرَّرة
///     (`Home Page – 9`) ترسم الشريط 20 بكسلاً تحت حافّة الشاشة، وصفحةُ
///     الراحة (`Home Page`) 15 فوقها. والحجم حركةُ العرض نفسه (الملفّ يرسم
///     الشريط الممرَّر بحجمه الكامل)، والنزول من الملفّ؛
///   - الضغط يُنبض الشريط كلّه نبضةً واحدة ويُصغّر الأيقونة تحت الإصبع؛
///   - اضغط واسحب بلا رفع، فيتبع الضغطُ الإصبع؛ ورفعُه يختار؛
///   - الأيقونة التي تصبح نشطة تكبر، والتي تُزاح تصغر، على نابضٍ واحد.
///
/// وما لا ينقله: الحبّة الرماديّة خلف العنصر النشط. لا حبّة في التصميم.
///
/// ولا نصوص تحت الأيقونات — التصميم الجديد لا يرسمها. أسماء الخانات تبقى
/// لقارئ الشاشة وحده في [labels].
class AppBottomNavV2 extends StatefulWidget {
  const AppBottomNavV2({
    super.key,
    required this.active,
    required this.labels,
    required this.onSelect,
    required this.resetKey,
    this.onLongPress,
    this.photo,
    this.verified = false,
    this.cartCount = 0,
    this.chatCount = 0,
    this.busy = const <int>{},
  });

  /// الخانة النشطة بترتيب التصميم: 0 الرئيسيّة، 1 البحث، 2 السلّة،
  /// 3 الدردشة، 4 الحساب. و`null` لا نشطة.
  final int? active;

  /// اسم كلّ خانةٍ لقارئ الشاشة، خمسةٌ بترتيب التصميم.
  final List<String> labels;

  final void Function(int index) onSelect;

  /// ضغطٌ مطوّل على خانة. لا وجود له في الويب — أدوات المطوّر عندنا.
  /// وقوعُه يُلغي الاختيار عند رفع الإصبع، كما كان `InkWell` يفعل.
  final void Function(int index)? onLongPress;

  /// الشاشة المعروضة. الشاشة الجديدة تبدأ من أعلاها، فيعود الشريط إلى حجمه
  /// الكامل — `resetKey` في الويب.
  final Object? resetKey;

  /// صورة المستخدم، أو `null` فيُرسم المربّع الرماديّ برمز المستخدم.
  final String? photo;

  /// موثَّق الهاتف. غير الموثَّق يحمل خطّاً برتقاليّاً حول صورته.
  final bool verified;

  /// العدّادان. الويب يُثبّتهما على 3 و11 لأنّ العرض بلا سلّةٍ ولا دردشة —
  /// "يُظهران تصميم الشارة لا بياناتٍ حقيقيّة". وعندنا بياناتٌ حقيقيّة،
  /// فتُمرَّر. والصفر لا يُرسم، كما كان الشريط السابق يفعل.
  final int cartCount;
  final int chatCount;

  /// خاناتٌ تنتظر طلباً: يحلّ مكان أيقونتها مؤشّر تحميل. لا وجود لهذه في
  /// الويب — منطقُنا نحن (تسجيل الدخول إلى الدردشة، تسجيل زائر) وقد أبقيناه.
  final Set<int> busy;

  @override
  State<AppBottomNavV2> createState() => _AppBottomNavV2State();
}

class _AppBottomNavV2State extends State<AppBottomNavV2>
    with TickerProviderStateMixin {
  late final NavScrollScale _scroll;

  /// نبضةُ الشريط عند الضغط — تُضرب بحجم التمرير لا تحلّ مكانه، فلمسةٌ أثناء
  /// تمريرٍ لا تُرجع الشريط إلى حجمه الكامل.
  late final AnimationController _pulse;
  late final Animation<double> _pulseValue;
  Duration _lastPulse = Duration.zero;

  /// الخانة تحت الإصبع الآن.
  int? _pressed;
  bool _dragging = false;

  /// وقع ضغطٌ مطوّل في هذه اللمسة، فلا يُختار شيءٌ عند رفع الإصبع.
  bool _longPressed = false;

  ScrollNotificationObserverState? _observer;

  @override
  void initState() {
    super.initState();
    _scroll = NavScrollScale(vsync: this);
    _pulse = AnimationController(duration: NavMotion.pulse, vsync: this);
    _pulseValue = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1,
          end: NavMotion.pulsePeak,
        ).chain(CurveTween(curve: NavMotion.pulseEase)),
        weight: NavMotion.pulsePeakAt,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: NavMotion.pulsePeak,
          end: 1,
        ).chain(CurveTween(curve: NavMotion.pulseEase)),
        weight: 1 - NavMotion.pulsePeakAt,
      ),
    ]).animate(_pulse);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // `Scaffold` يُركّب [ScrollNotificationObserver] حول محتواه كلّه — الجسم
    // والشريط السفليّ معاً — فهو بديلُ `scope: "any"` في الويب: به نسمع تمرير
    // أيّ صفحةٍ في الجسم دون أن نلمس بناء الصفحة الأساسيّة.
    final ScrollNotificationObserverState? next =
        ScrollNotificationObserver.maybeOf(context);
    if (next == _observer) return;
    _observer?.removeListener(_onScroll);
    _observer = next;
    _observer?.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(AppBottomNavV2 old) {
    super.didUpdateWidget(old);
    if (old.resetKey != widget.resetKey) _scroll.reset();
  }

  @override
  void dispose() {
    _observer?.removeListener(_onScroll);
    _pulse.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll(ScrollNotification notification) => _scroll.feed(notification);

  void _firePulse() {
    final Duration now = Duration(
      microseconds: (SchedulerBinding.instance.currentSystemFrameTimeStamp)
          .inMicroseconds,
    );
    if (now - _lastPulse < NavMotion.pulseGap) return;
    _lastPulse = now;
    _pulse.forward(from: 0);
  }

  /// أيّ خانةٍ تحت هذا الموضع على الشريط.
  int _nearest(double localX, double barW) {
    final double inset = NavBarDesign.slotInset.w;
    final double slotW = (barW - 2 * inset) / NavBarDesign.slotCount;
    int best = widget.active ?? 0;
    double bestDistance = double.infinity;
    for (int i = 0; i < NavBarDesign.slotCount; i++) {
      final double centre = inset + slotW * i + slotW / 2;
      final double d = (localX - centre).abs();
      if (d < bestDistance) {
        bestDistance = d;
        best = i;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final double barW = 1.sw - 2 * NavBarDesign.x.w;
    final double barH = NavBarDesign.height.h;
    final double safeBottom = MediaQuery.paddingOf(context).bottom;

    return SizedBox(
      width: 1.sw,
      // الغرفة التي يأخذها الشريط: حافّته العليا بالحجم الكامل، فوق الحافّة
      // الآمنة — [navTabRoom].
      height: NavBarDesign.top.h + safeBottom,
      child: Align(
        alignment: Alignment.topCenter,
        child: AnimatedBuilder(
          animation: Listenable.merge(<Listenable>[_scroll, _pulseValue]),
          builder: (context, _) {
            final double scale = _scroll.scale;

            // لا حصر على النزول: الشريط يُكبَّر حول مركزه فترتفع حافّته
            // السفلى `barH·(1-scale)/2`، والنزول [NavBarDesign.drop] هو هذا
            // المقدار نفسه عند الأرضيّة — فتثبت الحافّة السفلى على
            // [NavBarDesign.bottomGap] في كلّ حال ولا يخرج شيءٌ عن الشاشة.
            //
            // (كان هنا حصرٌ على النزول لمّا كان `drop` خمسةً وثلاثين، فكان
            // جزءٌ من الشريط يقع تحت الشاشة. وتحديثُ الويب أصلحها من أصلها
            // بـ`TAB_BAR_DROP = (58 - 31) / 2`، فسقط الحصر.)
            final double drop = _scroll.drop.h;

            // عرض الصندوق **قبل** التكبير. على الشاشة (بعد التكبير) يذهب
            // الشريط من عرضه الكامل إلى [NavBarDesign.minWidth] وهو يصغر،
            // فيصير عند الأرضيّة حبّةً في البعدين — `boxWidth` في الويب.
            final double done = (1 - scale) / (1 - NavScroll.minScale);
            final double boxW =
                (barW * (1 - done) + NavBarDesign.minWidth.w * done) / scale;

            return Transform.translate(
              offset: Offset(0, drop),
              child: Transform.scale(
                scale: scale * _pulseValue.value,
                child: SizedBox(
                  width: boxW,
                  height: barH,
                  child: _bar(boxW, barH),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _bar(double barW, double barH) {
    return Listener(
      onPointerDown: (PointerDownEvent e) {
        _firePulse();
        _longPressed = false;
        setState(() {
          _pressed = _nearest(e.localPosition.dx, barW);
          _dragging = true;
        });
      },
      // الضغط والسحب: يتبع الضغطُ الإصبع، ورفعُه يختار.
      onPointerMove: (PointerMoveEvent e) {
        if (!_dragging) return;
        final int next = _nearest(e.localPosition.dx, barW);
        if (next != _pressed) setState(() => _pressed = next);
      },
      onPointerUp: (PointerUpEvent e) {
        final int? picked = _pressed;
        setState(() {
          _pressed = null;
          _dragging = false;
        });
        if (picked != null && !_longPressed) widget.onSelect(picked);
      },
      onPointerCancel: (PointerCancelEvent e) => setState(() {
        _pressed = null;
        _dragging = false;
      }),
      child: _glass(barW, barH),
    );
  }

  /// المادّة: تمويه 30 وسطوع +15% ولا تعبئة — فما تراه هو ما خلف الشريط،
  /// مُمَوَّهاً ومُفتَّحاً. و`blur(30)` في CSS تعني انحرافاً معياريّاً 15.
  ///
  /// والزجاج طبقةٌ خاصّةٌ به تحت الأيقونات، لا العنصر الذي يُكبَّر: سفاري على
  /// الآيفون يقصّ `backdrop-filter` خطأً إن حمل العنصر نفسه تحويلاً. وعندنا
  /// لا تلك العلّة، لكنّ البنية تبقى كما هي لتبقى مقارنةُ الملفّين ممكنة.
  Widget _glass(double barW, double barH) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10.r),
        topRight: Radius.circular(10.r),
        bottomLeft: Radius.circular(40.r),
        bottomRight: Radius.circular(40.r),
      ),
      child: BackdropFilter(
        filter: ui.ImageFilter.compose(
          outer: const ColorFilter.matrix(<double>[
            NavBarDesign.glassBrightness, 0, 0, 0, 0, //
            0, NavBarDesign.glassBrightness, 0, 0, 0, //
            0, 0, NavBarDesign.glassBrightness, 0, 0, //
            0, 0, 0, 1, 0, //
          ]),
          inner: ui.ImageFilter.blur(
            sigmaX: NavBarDesign.glassBlur / 2,
            sigmaY: NavBarDesign.glassBlur / 2,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            for (int i = 0; i < NavBarDesign.slotCount; i++)
              _slot(i, barW, barH),
          ],
        ),
      ),
    );
  }

  Widget _slot(int index, double barW, double barH) {
    final double inset = NavBarDesign.slotInset.w;
    final double slotW = (barW - 2 * inset) / NavBarDesign.slotCount;
    final bool on = index == widget.active;

    return Positioned(
      left: inset + slotW * index,
      top: 0,
      width: slotW,
      height: barH,
      child: Semantics(
        button: true,
        selected: on,
        label: widget.labels[index],
        child: _NavSlotView(
          index: index,
          onLongPress: widget.onLongPress == null
              ? null
              : () {
                  _longPressed = true;
                  widget.onLongPress!(index);
                },
          on: on,
          pressed: _pressed == index,
          slotWidth: slotW,
          busy: widget.busy.contains(index),
          photo: widget.photo,
          verified: widget.verified,
          cartCount: widget.cartCount,
          chatCount: widget.chatCount,
        ),
      ),
    );
  }
}

/// خانةٌ واحدة: تكبيرُها ونزولُ الضغط عليها، وأيقونتاها الساكنة والنشطة.
class _NavSlotView extends StatefulWidget {
  const _NavSlotView({
    required this.index,
    required this.onLongPress,
    required this.on,
    required this.pressed,
    required this.slotWidth,
    required this.busy,
    required this.photo,
    required this.verified,
    required this.cartCount,
    required this.chatCount,
  });

  final int index;
  final VoidCallback? onLongPress;
  final bool on;
  final bool pressed;
  final double slotWidth;
  final bool busy;
  final String? photo;
  final bool verified;
  final int cartCount;
  final int chatCount;

  @override
  State<_NavSlotView> createState() => _NavSlotViewState();
}

class _NavSlotViewState extends State<_NavSlotView>
    with TickerProviderStateMixin {
  /// 0 ساكنة و1 نشطة. النابض يتجاوز الواحد قليلاً، وهو المقصود.
  late final AnimationController _grow;

  /// حجم الخانة تحت الإصبع.
  late final AnimationController _press;

  static const SpringDescription _growSpring = SpringDescription(
    mass: NavMotion.growMass,
    stiffness: NavMotion.growStiffness,
    damping: NavMotion.growDamping,
  );
  static const SpringDescription _pressSpring = SpringDescription(
    mass: NavMotion.pressMass,
    stiffness: NavMotion.pressStiffness,
    damping: NavMotion.pressDamping,
  );
  static const SpringDescription _travelSpring = SpringDescription(
    mass: NavMotion.travelMass,
    stiffness: NavMotion.travelStiffness,
    damping: NavMotion.travelDamping,
  );

  @override
  void initState() {
    super.initState();
    _grow = AnimationController.unbounded(
      vsync: this,
      value: widget.on ? 1 : 0,
    );
    _press = AnimationController.unbounded(vsync: this, value: 1);
  }

  @override
  void didUpdateWidget(_NavSlotView old) {
    super.didUpdateWidget(old);
    if (old.on != widget.on) _spring(_grow, _growSpring, widget.on ? 1 : 0);
    if (old.pressed != widget.pressed) {
      _spring(
        _press,
        // ينزل بنابض الضغط ويعود بنابض السفر، كما في الويب.
        widget.pressed ? _pressSpring : _travelSpring,
        widget.pressed ? NavMotion.pressScale : 1,
      );
    }
  }

  void _spring(AnimationController c, SpringDescription spring, double target) {
    c.animateWith(SpringSimulation(spring, c.value, target, c.velocity));
  }

  @override
  void dispose() {
    _grow.dispose();
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool profile = widget.index == NavBarDesign.slotCount - 1;
    final NavBox idle = profile
        ? NavSlots.profileIdle
        : NavSlots.list[widget.index].idle;
    final NavBox active = profile
        ? NavSlots.profileActive
        : NavSlots.list[widget.index].active;

    return GestureDetector(
      // `Listener` في الأعلى لا يدخل حلبة الإيماءات، فهذا الكاشف يسمع الضغط
      // المطوّل دون أن ينزع منه السحبَ ولا النبضة.
      behavior: HitTestBehavior.translucent,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _press,
        builder: (context, child) =>
            Transform.scale(scale: _press.value, child: child),
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Positioned(
              // موضع المربّع النشط داخل الخانة: مسافةُ الملفّ عن مركزها.
              left:
                  widget.slotWidth / 2 +
                  (active.x - NavBarDesign.fileCentre(widget.index)).w,
              top: (active.y - NavBarDesign.y).h,
              width: active.size.w,
              height: active.size.w,
              child: widget.busy
                  ? const Center(
                      child: SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : _growBox(idle, active, profile),
            ),
          ],
        ),
      ),
    );
  }

  /// الأيقونة مرسومةً على مربّعها **النشط** ومُصغَّرةً إلى مربّعها الساكن ما
  /// لم تكن الخانة نشطة. أصل التحويل الزاوية العليا اليسرى، فالانتقال إلى
  /// زاوية الساكن والتصغير هناك يحلّان على مربّع الساكن تماماً؛ والنابض
  /// يُجري الانتقال والتصغير معاً.
  Widget _growBox(NavBox idle, NavBox active, bool profile) {
    return AnimatedBuilder(
      animation: _grow,
      builder: (context, child) {
        final double t = _grow.value;
        final double dx = ui.lerpDouble(idle.x - active.x, 0, t)!;
        final double dy = ui.lerpDouble(idle.y - active.y, 0, t)!;
        final double scale = ui.lerpDouble(idle.size / active.size, 1, t)!;
        return Transform.translate(
          offset: Offset(dx.w, dy.h),
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.topLeft,
            child: child,
          ),
        );
      },
      child: profile
          ? _NavProfileTab(
              on: widget.on,
              photo: widget.photo,
              verified: widget.verified,
            )
          : _icons(active),
    );
  }

  /// الأيقونتان فوق بعضهما: الساكنة تخبو والنشطة تظهر، في 180ms.
  ///
  /// وكلّ أيقونةٍ مرسومةٌ بمقاسها النشط ومُصغَّرة ساكنةً: الجهاز يرسم صورةً
  /// مُصغَّرة حادّة، والمكبَّرة فوق مقاس تخطيطها قد تخرج ناعمة.
  Widget _icons(NavBox active) {
    final NavSlot slot = NavSlots.list[widget.index];
    final int? count = switch (widget.index) {
      2 => widget.cartCount,
      3 => widget.chatCount,
      _ => null,
    };
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        AnimatedOpacity(
          opacity: widget.on ? 0 : 1,
          duration: NavMotion.swap,
          curve: Curves.easeOut,
          child: _NavIcon(slot.icon, size: active.size),
        ),
        AnimatedOpacity(
          opacity: widget.on ? 1 : 0,
          duration: NavMotion.swap,
          curve: Curves.easeOut,
          child: _NavIcon(slot.activeIcon, size: active.size),
        ),
        if (slot.count != null && (count ?? 0) > 0)
          _NavTabCount(
            count: slot.count!,
            text: '$count',
            on: widget.on,
            size: active.size,
          ),
      ],
    );
  }
}

/// أيقونةٌ من `assets/svg/nav_v2/`.
///
/// البعدان كلاهما بـ`.w`: هذه حلقاتٌ ومربّعات، وتمديدُ أحد بعديها بنسبةٍ
/// مختلفة يُرى. ومواضعُها الرأسيّة تبقى بـ`.h` كبقيّة الارتفاعات في النقل.
class _NavIcon extends StatelessWidget {
  const _NavIcon(this.name, {required this.size});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/svg/nav_v2/$name.svg',
      width: size.w,
      height: size.w,
    );
  }
}

/// عدّاد خانة، في مربّع الملفّ (34).
///
/// الويب يرسم المربّع ثمّ يُكبّره إلى حجم الأيقونة النشطة، فيكبر العدّاد مع
/// الأيقونة ويحلّ على 12 من الملفّ وهي ساكنة. وهنا يُحسب المقاس النهائيّ
/// مباشرةً (`k = حجم النشط / 34`) بدل تكبيرٍ متداخل، فلا يُضرب قياس الخطّ
/// مرّتين.
///
/// والعدّاد الساكن والنشط يخبوان في بعضهما مع الأيقونتين: النشط أخفض بـ1،
/// وأبيض على فقاعة الدردشة.
class _NavTabCount extends StatelessWidget {
  const _NavTabCount({
    required this.count,
    required this.text,
    required this.on,
    required this.size,
  });

  final NavCount count;
  final String text;
  final bool on;

  /// حجم الأيقونة النشطة، وهو المربّع الذي يُرسم فيه هذا العدّاد.
  final double size;

  @override
  Widget build(BuildContext context) {
    final double k = size / NavSlots.countBox;
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        _one(k, count.idleBaseline, count.idleColor, !on),
        _one(k, count.activeBaseline, count.activeColor, on),
      ],
    );
  }

  Widget _one(double k, double baseline, Color color, bool shown) {
    final double fontSize = NavSlots.countSize * k;
    final double lineHeight = (NavSlots.countSize + 3) * k;
    return Positioned(
      left: (count.x * k).w,
      // `textTop(baseline, size) = baseline - size` في الويب.
      top: ((baseline - NavSlots.countSize) * k).h,
      child: AnimatedOpacity(
        opacity: shown ? 1 : 0,
        duration: NavMotion.swap,
        curve: Curves.easeOut,
        child: Text(
          text,
          maxLines: 1,
          softWrap: false,
          style: TextStyle(
            fontFamily: 'Quicksand-Bold',
            fontSize: fontSize.sp,
            height: lineHeight / fontSize,
            leadingDistribution: TextLeadingDistribution.even,
            color: color,
          ),
        ),
      ),
    );
  }
}

/// خانة الحساب، مرسومةً على 42 النشط ومُصغَّرةً بمُكبِّرها.
///
/// بلا صورة: ساكنةً مربّع 34 الرماديّ (`#EFEFEF`) برمز المستخدم الرماديّ،
/// ونشطةً المربّع البنفسجيّ (`#D4D4FC`) بالرمز البنفسجيّ (`#8888E5`).
/// والرمزان يخبوان في بعضهما، كأيقونات الخانات الأخرى.
///
/// وبصورة: الصورةُ نفسها، بظلّ XD الداخليّ (0 4 3، أبيض 50%) في كلّ حال،
/// والخطُّ الذي يختاره [NavSlots.profileLine].
///
/// والزاوية (12) والخطوط أرقامُ الملفّ بمقاسها على الشاشة، فتُضبط ساكنةً
/// أكبر بـ[NavSlots.profileUnscale] لتُلغي التصغير.
class _NavProfileTab extends StatelessWidget {
  const _NavProfileTab({
    required this.on,
    required this.photo,
    required this.verified,
  });

  final bool on;
  final String? photo;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    final double unscale = on ? 1 : NavSlots.profileUnscale;
    final double radius = NavSlots.profileRadius * unscale;
    final ({Color color, double width})? line = NavSlots.profileLine(
      on,
      photo != null && photo!.isNotEmpty,
      verified,
    );
    final bool hasPhoto = photo != null && photo!.isNotEmpty;

    return AnimatedContainer(
      duration: NavMotion.profileFade,
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: !hasPhoto && on
            ? NavSlots.profileFillActive
            : NavSlots.profileFill,
        borderRadius: BorderRadius.circular(radius.r),
        border: line == null
            ? null
            : Border.all(color: line.color, width: line.width * unscale),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: <Widget>[
          if (hasPhoto)
            MyCachedNetworkImage(
              imageUrl: photo!,
              width: NavSlots.profileActive.size.w,
              height: NavSlots.profileActive.size.w,
              imageFit: BoxFit.cover,
              radius: 0,
            )
          else ...<Widget>[
            _glyph(
              'navUser',
              NavSlots.userIcon,
              NavSlots.userIconX,
              NavSlots.userIconY,
              !on,
            ),
            _glyph(
              'navUserActive',
              NavSlots.userIconActive,
              NavSlots.userIconActiveX,
              NavSlots.userIconActiveY,
              on,
            ),
          ],
          // ظلّ XD الداخليّ (0 4 3، أبيض 50%) فوق الصورة كي لا يختفي تحتها.
          // ولا ظلّ داخليّاً في فلَتَر، فهو هنا تدرّجٌ أبيض من الأعلى بعُمق
          // الإزاحة + التمويه (4 + 3).
          if (hasPhoto)
            IgnorePointer(
              child: Align(
                alignment: Alignment.topCenter,
                child: FractionallySizedBox(
                  heightFactor: 7 / NavSlots.profileActive.size,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[Color(0x80FFFFFF), Color(0x00FFFFFF)],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _glyph(String name, double size, double x, double y, bool shown) {
    final double k = NavSlots.profileUnscale;
    return Positioned(
      left: (x * k).w,
      top: (y * k).h,
      child: AnimatedOpacity(
        opacity: shown ? 1 : 0,
        duration: NavMotion.swap,
        curve: Curves.easeOut,
        child: _NavIcon(name, size: size * k),
      ),
    );
  }
}
