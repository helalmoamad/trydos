import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/features/chat/presentation/pages/conversation_design.dart';
import 'package:trydos/features/chat/presentation/pages/profile_page_design.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_v2/message_menu_v2.dart';

/// صفّ رسالة واحدة بحركتَي واتساب على الآيفون.
///
/// منقولٌ من `web_design/components/DemoApp1/chat/MessageRow.tsx`:
///
/// > **السحب للردّ** — يتبع الصفُّ الإصبعَ بمقاومة، وتخرج من خلف الرسالة
/// > علامةُ ردٍّ دائرية تكبر مع السحب. وبعد [replyPull] تمتلئ بنفسجياً
/// > (ويهتزّ الهاتف حيث يستطيع)، فإن رُفع الإصبع هناك رُدّ على الرسالة.
/// > والصفّ يرتدّ في الحالتين. والسحب العمودي يمرّر المحادثة كالعادة.
/// >
/// > **الضغط المطوّل** — إصبعٌ يثبت [holdDuration] بلا حركة يرفع الرسالة
/// > ويفتح قائمتها.
class MessageRowV2 extends StatefulWidget {
  const MessageRowV2({
    super.key,
    required this.isMine,
    required this.child,
    this.gap = 0,
    this.isWide = false,
    this.canReply = true,
    this.isLifted = false,
    this.shift = 0,
    this.onReply,
    this.onHold,
    this.flash = 0,
    this.flags,
    this.reaction,
    this.menuCanEdit = false,
    this.menuCanForward = true,
    this.menuBuilder,
    this.onCloseMenu,
    this.holeInset = bubbleMargin,
  });

  /// عدّادُ ومضة: كل رقمٍ جديد يُشعلها مرّةً، و`0` لا يُشعل شيئاً.
  ///
  /// تُعلّم الرسالةَ التي قفز إليها اقتباسٌ مضغوط — ضوءٌ يمتدّ عرض المحادثة
  /// ثم يخبو، كما يفعل واتساب.
  final int flash;

  final bool isMine;
  final Widget child;

  /// الفراغ فوق الصفّ.
  final double gap;

  /// الرسالة تأخذ العرض كاملاً — الصوتية ترسم صفوفها بنفسها.
  final bool isWide;

  final bool canReply;

  /// قائمة هذا الصفّ مفتوحة: يبقى فوق الضباب.
  final bool isLifted;

  /// إزاحة الصفّ أثناء فتح قائمته، كي تظهر هي والرسالة معاً.
  final double shift;

  final VoidCallback? onReply;
  final VoidCallback? onHold;

  /// هل تعرض القائمةُ صفَّ التعديل وصفَّ التحويل — لحساب ارتفاعها قبل فتحها.
  ///
  /// يُمرَّران كما يُمرَّران إلى [MessageMenuV2] نفسها، فإزاحةُ الصفّ تُحسب
  /// على ارتفاع القائمة الفعليّ لا على أقصاه.
  final bool menuCanEdit;
  final bool menuCanForward;

  /// باني قائمةِ هذا الصفّ — يأخذ صندوقَ الفقاعة وعرضَ الشاشة.
  ///
  /// دالّةٌ لا ودجت: القائمة ترسم الشريط فوق الفقاعة والبطاقة تحتها،
  /// فتحتاج صندوقَها — ولا يُعرف إلّا بعد القياس، أي داخل الصفّ لا خارجه.
  final Widget Function(Rect hole, double screenWidth)? menuBuilder;

  /// نقرةٌ على الغشاوة — تُغلق القائمة، كما `onClick={close}` في الويب.
  final VoidCallback? onCloseMenu;

  /// ما يُقتطع من ثقب الغشاوة في جهة الرسالة ليحضن حدود الفقاعة وحدها.
  ///
  /// الثقب يُقاس من [child]، وفيه ما ليس من الفقاعة في تلك الجهة: هامشُها
  /// الخارجي 3 دائماً، وتزيد عليه **النقطة** حيث تكون أختاً للفقاعة لا
  /// داخلها — 4 عرضاً و5 هامشاً — فيصير المجموع [MessageMenuV2.edge].
  ///
  /// وبلا هذا كان ثقبُ الرسالة النصّية أعرض من فقاعتها بتسعة من جهة حافّة
  /// الشاشة، فلا تنطبق الغشاوة على حدّها.
  final double holeInset;

  /// هامش الفقاعة الخارجي في جهتها — `ChatBubbleV2` يضعه دائماً.
  static const double bubbleMargin = 3;

  /// سطر الوسم والتذكير فوق الفقاعة — [MessageFlagsLine].
  ///
  /// هنا لا في كل نوع رسالة: الصفّ يلفّ الأنواع جميعاً، فسطرٌ واحد يكفيها.
  final Widget? flags;

  /// حبّة التفاعل المعلَّقة أسفل الفقاعة — [ReactionChipV2].
  ///
  /// هامشها العلوي سالب، فتركب حافّة الفقاعة كما في الملف.
  final Widget? reaction;

  /// المسافة التي يجب سحبها لتفعيل الردّ.
  static const double replyPull = 56;

  /// المدّة التي يثبت فيها الإصبع لفتح القائمة.
  static const Duration holdDuration = Duration(milliseconds: 360);

  /// كم تكبر الرسالة المضغوطة، وأقصى زيادةٍ بالبكسل.
  ///
  /// التكبير من وسطها، فنصف الزيادة يذهب إلى الفراغ 12 فوقها والنصف الآخر
  /// إلى الفراغ تحتها. و**السقف بالبكسل ضروري**: تكبيرٌ بالنسبة وحده يأخذ
  /// 3.5٪ من الارتفاع لكل جهة، فصورةٌ طويلة تلامس الشريط والقائمة معاً.
  static const double heldScale = 1.07;
  static const double heldGrow = 6;

  /// مدّة ومضة الرسالة التي يقفز إليها اقتباسٌ مضغوط.
  static const Duration flashDuration = Duration(milliseconds: 1600);

  @override
  State<MessageRowV2> createState() => _MessageRowV2State();
}

class _MessageRowV2State extends State<MessageRowV2>
    with SingleTickerProviderStateMixin {
  double _x = 0;
  Timer? _hold;

  /// اهتزّ الهاتف عند تجاوز الحدّ — مرّةً واحدة لا مع كل بكسل.
  bool _ticked = false;

  /// الإصبع يسحب الآن: الصفّ يتبعه بلا حركة، ويرتدّ بحركة عند الإفلات.
  bool _dragging = false;

  /// مفتاحٌ لقياس ارتفاع الرسالة، لحساب سقف التكبير بالبكسل.
  final GlobalKey _childKey = GlobalKey();

  /// مفتاح **الفقاعة وحدها** — منه يُقاس ثقب الغشاوة.
  ///
  /// لا [_childKey]: ذاك يلفّ الصفّ بسطر الأعلام فوق الفقاعة وحبّة التفاعل
  /// تحتها والوقت بجانبها، فكان الثقب مستطيلاً أوسع من الفقاعة وأطول —
  /// يظهر حول الرسالة إطارٌ أبيض غير مضبَّب، وتقع فيه حبّةُ التفاعل بعد
  /// اختيارها. والثقب يجب أن يحضن حدود الفقاعة وحدها.
  final GlobalKey _bubbleKey = GlobalKey();

  /// نسبة تكبير الرسالة المضغوطة بعد تطبيق السقف.
  ///
  /// تُقرأ من آخر قياس. وقبل أوّل رسمٍ لا قياس بعد، فتُستعمل النسبة كاملةً
  /// — والفرق لا يُرى لأن الضغط المطوّل يقع بعد الرسم بوقتٍ طويل.
  double get _heldScale {
    final RenderBox? box =
        _childKey.currentContext?.findRenderObject() as RenderBox?;
    final double height = box?.hasSize == true ? box!.size.height : 0;
    if (height <= 0) return MessageRowV2.heldScale;
    final double capped = 1 + MessageRowV2.heldGrow / height;
    return capped < MessageRowV2.heldScale ? capped : MessageRowV2.heldScale;
  }

  /// متحكّم الومضة. دورتها: صعودٌ سريع إلى 0.16 ثم ثباتٌ ثم خبوّ.
  late final AnimationController _flashController = AnimationController(
    vsync: this,
    duration: MessageRowV2.flashDuration,
  );

  late final Animation<double> _flashOpacity = TweenSequence<double>([
    // 0 → 0.16 في أوّل 10٪.
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.16), weight: 10),
    // ثباتٌ حتى 55٪.
    TweenSequenceItem(tween: ConstantTween(0.16), weight: 45),
    // خبوٌّ في الباقي.
    TweenSequenceItem(tween: Tween(begin: 0.16, end: 0.0), weight: 45),
  ]).animate(_flashController);

  Color? get _flashColor => _flashOpacity.value == 0
      ? null
      : ContactDesign.purple.withValues(alpha: _flashOpacity.value);

  @override
  void initState() {
    super.initState();
    _flashController.addListener(() {
      if (mounted) setState(() {});
    });

    // صفٌّ يولد مرفوعاً: تُركَّب طبقتُه هنا، لا في `didUpdateWidget` وحده.
    //
    // تمريرُ المحادثة إلى الوسط قد يُعيد بناء هذا الصفّ من جديد — القائمة
    // تُدوِّر عناصرها — فيُستبدل هذا الكائن بآخر يصله `isLifted: true` من
    // أوّل لحظة. و`didUpdateWidget` لا تُنادى حينها، فلا تُركَّب الطبقة:
    // تنتقل الرسالة إلى الوسط ولا تكبر ولا تُفتح خياراتها حتى تُضغط ثانيةً.
    //
    // وبلا قياسٍ ولا تمرير: الموضع استقرّ بالفعل، وإعادةُ التمرير تُزيحه ثانيةً.
    if (widget.isLifted) _showLifted();
  }

  @override
  void didUpdateWidget(MessageRowV2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.flash != oldWidget.flash && widget.flash != 0) {
      _flashController.forward(from: 0);
    }

    // الطبقة المرفوعة: تُركَّب مع فتح القائمة وتُزال مع إغلاقها، وتُحدَّث
    // متى تغيّر ما فيها (التفاعل المختار مثلاً).
    if (widget.isLifted != oldWidget.isLifted) {
      if (widget.isLifted) {
        // بلا قياسٍ ولا تمرير: الطبقة تُركَّب فوراً، والقائمة تضبط موضعها
        // داخل الشاشة بنفسها. والتمرير إلى الوسط كان يؤخّر الفتح — ويُعيد
        // بناء الصفّ أحياناً فلا تُفتح القائمة إلّا بضغطةٍ ثانية.
        _showLifted();
      } else {
        _hideLifted();
      }
    } else if (widget.isLifted && _entry != null) {
      // بعد الإطار لا في أثنائه، كالتركيب.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _entry?.markNeedsBuild();
      });
    }
  }

  // ---- الطبقة المرفوعة فوق الغشاوة ----

  /// يربط نسخةَ الصفّ المرفوعة بموضع نسخته في القائمة.
  final LayerLink _link = LayerLink();

  OverlayEntry? _entry;

  /// س بداية سحبةٍ على الغشاوة — منها تُقاس مسافة الإغلاق.
  double _scrimDownY = 0;

  /// تركيب الطبقة وإزالتها **بعد** الإطار لا في أثنائه.
  ///
  /// `didUpdateWidget` يُنفَّذ في طور البناء، و`OverlayState.insert` ينادي
  /// `setState` على `Overlay` — فالتركيب المباشر يرمي «setState() called
  /// during build». وتأجيلُه إطاراً واحداً يحلّه، ولا يُرى الفرق.
  void _showLifted() {
    // فتحٌ جديد قبل أن يتمّ تلاشي سابقه: يُرفع علم الخروج وإلّا بُنيت
    // الغشاوة الجديدة شفّافةً ولم يُعِد شيءٌ بناءها بعد انتهاء المهلة.
    _closing = false;

    void insert() {
      if (!mounted || !widget.isLifted) return;
      final OverlayState? overlay = Overlay.maybeOf(context);
      if (overlay == null || _entry != null) return;
      _entry = OverlayEntry(builder: _buildLifted);
      overlay.insert(_entry!);
    }

    // في الإطار التالي مباشرةً.
    //
    // `OverlayState.insert` ينادي `setState` على `Overlay`، و`_showLifted`
    // تُنادى من `didUpdateWidget` أي في طور البناء — فالتركيب المباشر يرمي
    // «setState() called during build». وإطارٌ واحد لا يُرى.
    WidgetsBinding.instance.addPostFrameCallback((_) => insert());
  }

  /// تُطوى الطبقة بعد أن تتلاشى الغشاوة، لا فجأةً.
  ///
  /// الويب يُخرجها بـ`AnimatePresence` في 180 (`MENU_FADE`)، فنُعلِم الغشاوة
  /// أن تخبو ثم نُزيل الطبقة بعد المدّة نفسها.
  void _hideLifted({bool now = false}) {
    final OverlayEntry? entry = _entry;
    if (entry == null) return;
    _entry = null;

    if (now) {
      if (entry.mounted) entry.remove();
      return;
    }

    _closing = true;
    // **بعد الإطار** لا في أثنائه: `_hideLifted` تُنادى من `didUpdateWidget`،
    // أي في طور البناء. و`markNeedsBuild` على عنصرٍ في شجرة `Overlay` حينها
    // يُفسد ترتيب البناء — وهو ما كان يُسقط التطبيق عند الضغط المطوّل
    // بتأكيدٍ في `InheritedElement.notifyClients`.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (entry.mounted) entry.markNeedsBuild();
    });
    Future<void>.delayed(ChatDesign.menuFade, () {
      // قد تكون أُزيلت مع تفكيك الصفّ في أثناء الانتظار.
      if (entry.mounted) entry.remove();
      _closing = false;
    });
  }

  /// الطبقة في طريقها إلى الخروج: الغشاوة تخبو والصفّ معها.
  bool _closing = false;

  /// الصندوق الذي تُبقيه الغشاوة صافياً — فقاعةُ الرسالة المضغوطة.
  ///
  /// الصفُّ يبقى في القائمة ولا يُنسَخ، والغشاوة تُثقَب عنده. والبديل — رسمُ
  /// نسخةٍ منه في الطبقة — كان يُركّب مضيفَه ثانيةً: فضغطةٌ مطوّلة على ملفٍ
  /// أرسلتُه تبدأ تنزيلاً ثانياً، وعلى فيديو تُنشئ مشغّلاً ثانياً، وعلى
  /// صوتٍ مشغّلَ صوتٍ إضافياً. ولا سبيل إلى نقل الودجت بين الشجرتين في
  /// إطارين مختلفين بلا فقدان حالتها.
  Rect? get _holeRect {
    final RenderBox? box =
        _bubbleKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;

    // بالمصفوفة الكاملة لا بالموضع والمقاس منفصلين: `localToGlobal` يُرجع
    // موضعاً **بعد** التكبير والإزاحة، و`box.size` مقاسَ التخطيط **قبلهما**
    // — فجمعُهما يُعطي صندوقاً لا يطابق ما يُرى. و`getTransformTo` يحمل
    // التحويلين معاً، فيخرج الصندوق كما هو على الشاشة.
    final Rect seen = MatrixUtils.transformRect(
      box.getTransformTo(null),
      Offset.zero & box.size,
    );

    // ما ليس من الفقاعة في جهتها يُقتطع — انظر [MessageRowV2.holeInset].
    // ويُضرب بنسبة التكبير لأن `seen` مقيسٌ **بعدها**.
    final double inset = widget.holeInset.w * _heldScale;
    return widget.isMine
        ? Rect.fromLTRB(seen.left, seen.top, seen.right - inset, seen.bottom)
        : Rect.fromLTRB(seen.left + inset, seen.top, seen.right, seen.bottom);
  }

  /// النقطة داخل ثقب الغشاوة — أي على الفقاعة المضغوطة نفسها.
  bool _insideHole(Offset global) => _holeRect?.contains(global) ?? false;

  /// الغشاوة المثقوبة عند الفقاعة، وتحتها قائمتُها.
  Widget _buildLifted(BuildContext overlayContext) {
    final double width = MediaQuery.of(overlayContext).size.width;
    // صندوق الفقاعة كما يُرى: يُقاس مرّةً وتُبنى عليه الغشاوةُ والقائمة معاً،
    // فلا يختلف ثقبُها عن موضعهما.
    final Rect? hole = _holeRect;

    // `Material` شفّافة فوق الطبقة كلّها.
    //
    // `Overlay` خارج شجرة `Material`، ونصٌّ بلا `Material` فوقه يرسمه Flutter
    // مخطَّطاً بالأصفر — وهي الخطوط التي ظهرت تحت كل خيار. وهي تعطي
    // `InkWell` سطحَه أيضاً، فيظهر تظليل الضغط.
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // غشاوةٌ واحدة على الشاشة كلّها: تضبيبٌ 5 وأسودٌ 30٪، تظهر في 180.
          //
          // وهي تحجب ما تحتها وتُغلق القائمة: بنقرةٍ، أو بسحبةٍ تتجاوز 24
          // (`DRAG_CLOSE`). ودفعةٌ أصغر لا تفعل شيئاً، والمحادثة لا تتزحزح.
          Positioned.fill(
            child: Listener(
              onPointerDown: (e) => _scrimDownY = e.position.dy,
              onPointerMove: (e) {
                if (_insideHole(e.position)) return;
                if ((e.position.dy - _scrimDownY).abs() >
                    ChatDesign.menuDragClose) {
                  widget.onCloseMenu?.call();
                }
              },
              onPointerUp: (e) {
                // نقرةٌ على الفقاعة المضغوطة لا تُغلق: في الملف هي **فوق**
                // الغشاوة فلا تصلها النقرة. و`ClipPath` يقصّ الرسم لا
                // الإصابة، فنستثني الثقب بأنفسنا.
                if (_insideHole(e.position)) return;
                if ((e.position.dy - _scrimDownY).abs() <=
                    ChatDesign.menuDragClose) {
                  widget.onCloseMenu?.call();
                }
              },
              behavior: HitTestBehavior.opaque,
              child: _MenuScrim(
                isClosing: _closing,
                hole: hole,
                // زوايا الفقاعة نفسها: `2/50/2/30` للواردة
                // و`50/2/30/2` للمرسَلة.
                holeRadius: widget.isMine
                    ? ChatDesign.outRadius
                    : ChatDesign.inRadius,
              ),
            ),
          ),
          // القائمة تُبنى من صندوق الفقاعة مباشرةً وتملأ الشاشة.
          //
          // و`CompositedTransformFollower` كان يُحاذيها بـ[LayerLink] إلى
          // **الشريط** — والفقاعة مكبَّرةٌ داخله وقد تكون أضيقَ منه بكثير،
          // فتخرج القائمة في غير موضعها. وصندوقُ الفقاعة محسوبٌ بالمصفوفة
          // الكاملة، فالربط به يضعها حيث تُرى بالضبط.
          if (hole != null)
            Positioned.fill(
              // اتجاهٌ مثبَّت: جهاتُها من الملف المطلق، فتأخذ صفوفُها
              // ترتيبَه — الأيقونة في البداية والكلمة بعدها.
              child: Directionality(
                textDirection: TextDirection.ltr,
                child:
                    widget.menuBuilder?.call(hole, width) ??
                    const SizedBox.shrink(),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // بلا تأجيلٍ هنا: الصفّ يُفكَّك، فلا أحد ينتظر تلاشياً.
    _hideLifted(now: true);
    _hold?.cancel();
    _flashController.dispose();
    super.dispose();
  }

  void _startHold() {
    _hold?.cancel();
    _hold = Timer(MessageRowV2.holdDuration, () {
      if (mounted) widget.onHold?.call();
    });
  }

  void _cancelHold() {
    _hold?.cancel();
    _hold = null;
  }

  /// اتجاه سحب الردّ: كلُّ رسالةٍ تُسحب **إلى داخل الشاشة** بعيداً عن حافّتها.
  ///
  /// فرسائلي عند اليمين تُسحب يميناً، والواردة عند اليسار تُسحب يساراً —
  /// فتخرج علامةُ الردّ من خلف الرسالة في الجهة المقابلة دائماً.
  ///
  /// والملف يسحب الاثنتين يميناً (`dragElastic: {left: 0, right: 0.75}`)، لكنه
  /// بفأرةٍ على شاشةٍ عريضة؛ وعلى الهاتف يسحب الإبهامُ الرسالةَ بعيداً عن
  /// حافّتها لا نحوها — فقرّر المالك عكسَها للواردة.
  double get _pullSign => widget.isMine ? 1 : -1;

  void _onDragUpdate(DragUpdateDetails details) {
    // أيّ حركة تلغي الضغط المطوّل — الإصبع لم يثبت.
    _cancelHold();
    _dragging = true;
    setState(() {
      // `_x` مقدارٌ دائماً موجب: المسافة المسحوبة نحو جهة الردّ.
      // مقاومة: الجزء بعد الحدّ يتحرّك بثلث السرعة، فيُحسّ المستخدم بالحدّ.
      final double next = _x + details.delta.dx * _pullSign;
      _x = next <= MessageRowV2.replyPull
          ? next.clamp(0.0, MessageRowV2.replyPull)
          : MessageRowV2.replyPull + (next - MessageRowV2.replyPull) / 3;
    });

    final bool over = _x >= MessageRowV2.replyPull;
    if (over && !_ticked) HapticFeedback.selectionClick();
    _ticked = over;
  }

  void _onDragEnd(DragEndDetails details) {
    if (_x >= MessageRowV2.replyPull) widget.onReply?.call();
    // يُرفع العلم أوّلاً، فالارتداد إلى الصفر يكون بحركة.
    setState(() {
      _dragging = false;
      _x = 0;
    });
    _ticked = false;
  }

  /// الصفُّ كما يُرسم: علامةُ الردّ وراءه، وسطرُ الأعلام فوقه، وحبّةُ
  /// التفاعل تحته، ثم تكبيرُه وإزاحته إن كانت قائمتُه مفتوحة.
  Widget _rowContent() {
    final bool inn = !widget.isMine;

    // الفقاعة وما يعلوها ويتبعها: السطر فوقها والحبّة تحتها، كلاهما في
    // جهتها. وتغيب العموديّة حين لا يكون شيءٌ منهما، فلا تُضاف طبقةٌ بلا داع.
    final Widget bubble = KeyedSubtree(key: _bubbleKey, child: widget.child);
    Widget body = bubble;
    if (widget.flags != null || widget.reaction != null) {
      body = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: inn
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          if (widget.flags != null) widget.flags!,
          bubble,
          if (widget.reaction != null) widget.reaction!,
        ],
      );
    }

    Widget row = Stack(
      clipBehavior: Clip.none,
      alignment: inn ? Alignment.centerLeft : Alignment.centerRight,
      children: [if (widget.canReply) _replyMark(), body],
    );

    // المفتاح عليه: منه يُقاس ارتفاع الفقاعة وصندوقُ ثقب الغشاوة.
    row = KeyedSubtree(key: _childKey, child: row);

    // الرسالة المضغوطة تكبر قليلاً — بسقفٍ بالبكسل لا بالنسبة وحدها.
    //
    // السقف يُلزِم حين يتجاوز الارتفاع ~86 بكسلاً (6 ÷ 0.07). وما دون ذلك
    // تأخذ النسبة كاملةً.
    if (widget.isLifted) {
      row = Transform.scale(scale: _heldScale, child: row);
    }

    // الصفّ يتبع الإصبع **بلا حركة**، ويرتدّ **بحركة**.
    //
    // وكانت المدّة 180 في الحالتين: فكلُّ حركةِ إصبعٍ تبدأ انتقالاً جديداً
    // يُلغي سابقه قبل أن يكتمل، فيتخلّف الصفُّ عن الإصبع حتى يبدو واقفاً —
    // فيرفع المستخدم إصبعه قبل الحدّ ولا يُرسَل ردّ. وهذا ما ظهر كأن
    // «الردّ لا يعمل».
    row = AnimatedContainer(
      duration: _dragging ? Duration.zero : const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      // `_x` مقدارٌ موجب، فيُضرب بجهة السحب ليتحرّك الصفّ نحوها.
      transform: Matrix4.translationValues(_x * _pullSign, widget.shift, 0),
      child: row,
    );

    Widget band = Container(
      padding: EdgeInsets.only(top: widget.gap.h),
      // الضوء يمتدّ عرض المحادثة لا عرض الفقاعة.
      color: _flashColor,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        // أفقيٌّ وحده — والعمودي يُترك للتمرير.
        onHorizontalDragUpdate: _onDragUpdate,
        onHorizontalDragEnd: _onDragEnd,
        onHorizontalDragCancel: () => setState(() {
          _dragging = false;
          _x = 0;
        }),
        onTapDown: (_) => _startHold(),
        onTapUp: (_) => _cancelHold(),
        onTapCancel: _cancelHold,
        child: Row(
          // جهةٌ مطلقة لا اتجاهية: رسائلي يميناً والواردة يساراً في كل
          // اللغات، كما في التصميم.
          //
          // `MainAxisAlignment.start` تعني اليمين في العربية، فكانت الجهتان
          // تنقلبان مع اللغة. والكود القديم تجنّبه بعكس الثابتين يدوياً
          // (`!isSent ? end : start` للعربية) — وهي حيلةٌ تُنسى عند كل
          // إضافة. وتثبيت الاتجاه هنا يجعل الجهة خاصّيةً للصفّ لا للغة.
          textDirection: TextDirection.ltr,
          mainAxisAlignment: inn
              ? MainAxisAlignment.start
              : MainAxisAlignment.end,
          children: [
            if (widget.isWide)
              Expanded(child: row)
            else
              // أعرض فقاعة في الملف: عرض الصفّ ناقص 74.
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 74.w,
                ),
                child: row,
              ),
          ],
        ),
      ),
    );

    // هدف [LayerLink] هو **الشريط بعرضه الكامل** لا الفقاعة: النسخة المرفوعة
    // تُحاذي فقاعتَها بنفسها كما يفعل هذا الشريط، فلو كان الهدف الفقاعة
    // لانطلقت النسخة من حافّتها — ورسالتي حافّتُها في أقصى اليمين، فتخرج
    // قائمتُها عن الشاشة.
    band = CompositedTransformTarget(link: _link, child: band);

    // ولا إزاحةَ هنا ولا تمرير: القائمة تضبط موضعها داخل الشاشة بنفسها،
    // والرسالة تبقى مكانها فتُفتح خياراتها في اللحظة — انظر `MessageMenuV2`.

    // اتجاهٌ مثبَّت للصفّ كلّه.
    //
    // `Row.textDirection` أعلاه يضبط اتجاه **ذلك الصفّ وحده** ولا يمسّ
    // `Directionality` للأبناء. فكلُّ حشوٍ اتجاهيّ داخل الفقاعات وبطاقات
    // الملفّات والرسائل الصوتية كان ينقلب في العربية — والملف يضع تلك
    // الأرقام مطلقةً (`marginLeft`، `paddingRight`) لأنه إنجليزيٌّ وحده.
    //
    // وتثبيتُه هنا يُصلحها جميعاً بموضعٍ واحد. أمّا حروفُ الرسالة نفسها
    // فتأخذ اتجاهها من محتواها في [ChatBubbleV2]، فلا تُحشر العربية يساراً.
    return Directionality(textDirection: TextDirection.ltr, child: band);
  }

  @override
  Widget build(BuildContext context) => _rowContent();

  /// علامة الردّ خلف الرسالة.
  ///
  /// تخرج مع الرسالة 44 بكسلاً ثم تثبت بينما تمضي الرسالة، وتظهر وتكبر مع
  /// السحب، وتمتلئ بنفسجياً عند تجاوز الحدّ.
  Widget _replyMark() {
    final double progress = (_x / MessageRowV2.replyPull).clamp(0.0, 1.0);
    final bool armed = _x >= MessageRowV2.replyPull;
    // العلامة تركب 44 ثم تتوقّف: إزاحتها هي الفرق بين الاثنين.
    final double markX = (_x < 44 ? _x : 44) - _x;

    // العلامة تخرج من خلف الرسالة من الجهة **المقابلة** لجهة السحب: السحب
    // يميناً يُظهرها من اليسار، والعكس في العربية.
    final bool rtl = _pullSign < 0;
    return Positioned(
      left: rtl ? null : -36.w,
      right: rtl ? -36.w : null,
      child: Transform.translate(
        offset: Offset(markX * _pullSign, 0),
        child: Opacity(
          opacity: (_x / 30).clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.5 + progress * 0.5,
            child: Container(
              width: 30.w,
              height: 30.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: armed ? ContactDesign.purple : ChatDesign.menu,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x29000000),
                    offset: Offset(0, 2),
                    blurRadius: 5,
                  ),
                ],
              ),
              // والعلامة نفسها تتبدّل عند الحدّ لا لونُ القرص وحده: الملف
              // يضع طبقتين في القرص، تخبو إحداهما وتظهر الأخرى —
              // `menuReply` ما دون الحدّ، و`replyMarkWhite` 14 فوقه على
              // البنفسجي. فيعرف الإصبع أن الردّ قد انعقد قبل أن يُرفع.
              child: armed
                  ? const XdIcon('replyMarkWhite', width: 14, height: 14)
                  : const XdIcon('menuReply', width: 16, height: 15),
            ),
          ),
        ),
      ),
    );
  }
}

/// فقاعة «يكتب الآن»: فقاعةٌ واردة بثلاث نقاط بيضاء تتصاعد تباعاً.
class TypingBubbleV2 extends StatefulWidget {
  const TypingBubbleV2({super.key});

  @override
  State<TypingBubbleV2> createState() => _TypingBubbleV2State();
}

class _TypingBubbleV2State extends State<TypingBubbleV2>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: EdgeInsetsDirectional.only(start: 5.w),
          width: 4.w,
          height: 4.w,
          decoration: const BoxDecoration(
            color: ContactDesign.purple,
            shape: BoxShape.circle,
          ),
        ),
        Container(
          margin: EdgeInsetsDirectional.only(start: 3.w),
          height: 34.h,
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          decoration: const BoxDecoration(
            color: ContactDesign.purple,
            borderRadius: ChatDesign.inRadius,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) => _dot(i)),
          ),
        ),
      ],
    );
  }

  /// نقطة واحدة. تأخّر كلٍّ عن سابقتها 0.15 ثانية من أصل 0.9.
  Widget _dot(int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double t = (_controller.value - index * (0.15 / 0.9)) % 1.0;
        // صعودٌ ثم هبوط: جيبٌ كامل على المدّة.
        final double wave = t < 0.5 ? t * 2 : (1 - t) * 2;
        final double eased = Curves.easeInOut.transform(wave);
        return Padding(
          padding: EdgeInsetsDirectional.only(end: index < 2 ? 4.w : 0),
          child: Transform.translate(
            offset: Offset(0, -4 * eased),
            child: Opacity(opacity: 0.5 + 0.5 * eased, child: child),
          ),
        );
      },
      child: Container(
        width: 6.w,
        height: 6.w,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// الغشاوة فوق المحادثة أثناء فتح قائمة.
///
/// منقولةٌ من `demo-chat-menu-backdrop` في `ConversationScreen.tsx`: تضبيبٌ
/// 5 (`backdropFilter`) وأسودٌ 30٪ (`MENU_DIM`)، تظهر وتغيب في 180
/// (`MENU_FADE`). وهي طبقةٌ **واحدة** على الشاشة كلّها — لا تضبيبٌ على كل
/// صفّ — فتُعتَّم فجوات الرسائل والترويسة وحقل الكتابة معها.
class _MenuScrim extends StatefulWidget {
  const _MenuScrim({
    required this.isClosing,
    required this.holeRadius,
    this.hole,
  });

  /// الطبقة في طريقها إلى الخروج: تخبو بنفس المدّة التي ظهرت بها.
  final bool isClosing;

  /// صندوقٌ تُستثنيه الغشاوة — فقاعة الرسالة المضغوطة تبقى صافية.
  ///
  /// الملف يرفع الفقاعة فوق الغشاوة؛ ونحن نُبقيها في مكانها ونثقب الغشاوة
  /// عندها، فالنتيجة واحدة وتبقى الفقاعة ودجتاً واحدة بحالةٍ واحدة.
  final Rect? hole;

  /// زوايا الفقاعة — بها يُقصّ الثقب بشكلها لا بمستطيلها.
  final BorderRadius holeRadius;

  @override
  State<_MenuScrim> createState() => _MenuScrimState();
}

class _MenuScrimState extends State<_MenuScrim> {
  /// ظهرت. تبدأ شفّافةً وتُرفع في أوّل إطار، فيُرى التلاشي.
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _shown = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget wash = BackdropFilter(
      filter: ChatDesign.menuFilter,
      child: const ColoredBox(color: ChatDesign.menuScrim),
    );

    // ثقبٌ عند الفقاعة: تبقى صافيةً غيرَ مضبَّبة وغيرَ معتَّمة، كما لو
    // كانت مرفوعةً فوق الغشاوة.
    final Rect? hole = widget.hole;
    if (hole != null) {
      wash = ClipPath(
        clipper: _HoleClipper(hole, widget.holeRadius),
        child: wash,
      );
    }

    return AnimatedOpacity(
      opacity: _shown && !widget.isClosing ? 1 : 0,
      duration: ChatDesign.menuFade,
      curve: Curves.easeOut,
      child: wash,
    );
  }
}

/// يقصّ الغشاوة عن الرسالة المضغوطة **بشكلها** لا بمستطيلها.
///
/// وكان مستطيلاً، فيبقى عند الزوايا المستديرة هلالٌ صافٍ خارج الفقاعة —
/// تظهر معه الشفافية مستطيلةً حولها بينما بقيّةُ الشاشة ضبابية.
class _HoleClipper extends CustomClipper<Path> {
  const _HoleClipper(this.hole, this.radius);

  final Rect hole;

  /// زوايا الفقاعة: `2/50/2/30` للواردة و`50/2/30/2` للمرسَلة.
  final BorderRadius radius;

  @override
  Path getClip(Size size) => Path.combine(
    PathOperation.difference,
    Path()..addRect(Offset.zero & size),
    Path()..addRRect(radius.toRRect(hole)),
  );

  @override
  bool shouldReclip(_HoleClipper old) =>
      old.hole != hole || old.radius != radius;
}
