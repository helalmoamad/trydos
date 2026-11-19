import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/features/chat/presentation/pages/conversation_design.dart';
import 'package:trydos/features/chat/presentation/pages/profile_page_design.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_v2/animated_emoji_v2.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_v2/reaction_fly_v2.dart';

/// فعلٌ في قائمة الضغط المطوّل.
enum MessageMenuAction { reply, forward, copy, edit, category, remind, delete }

/// قائمة الضغط المطوّل على رسالة، وشريط التفاعلات.
///
/// منقولةٌ بالبكسل من `web_design/components/DemoApp1/chat/MessageMenu.tsx`
/// على فرع `development`:
///
/// > **الشريط فوق الرسالة** (`bottom: 100%` وفراغ 12): ارتفاعه 48 ونصف قطره
/// > نصفُه، مصنفرٌ بزجاج الشريط السفلي، فيه سبعة رموز خاناتُها 38 وقرصُ «+»
/// > (30) فوق حافّة آخرها. حافّتُه في جهة الرسالة على بعد 12 من حافّة الصفّ.
/// > ينمو من زاويته السفلى في تلك الجهة: 0.42 إلى 1 في 0.21، وكلُّ رمزٍ
/// > ينبثق من 0.4 بعد سابقه بـ0.018.
/// >
/// > **القائمة تحتها** (`top: 100%` وفراغ 12): عرضها 220 ونصف قطرها 26،
/// > وحشوها 8 أعلى وأسفل، وصفوفٌ 38 حشوُها 23 من البداية — أيقونةٌ في صندوق
/// > 18 مقاسُها 15 (و17 لسهم التحويل) وكلمةٌ **15** بعدها على بعد 12. ثم خطٌّ
/// > شعريٌّ 0.5 بحشو 22، و`Delete` بالأحمر. تنمو من زاويتها العليا: 0.48
/// > إلى 1 مع صعودٍ 4.
class MessageMenuV2 extends StatefulWidget {
  const MessageMenuV2({
    super.key,
    required this.isMine,
    required this.canEdit,
    required this.canForward,
    required this.onPick,
    required this.labelOf,
    required this.hole,
    required this.screenWidth,
    this.onReact,
    this.onMore,
    this.reaction,
  });

  final bool isMine;

  /// النصّ المرسَل مني وحده يُعدَّل؛ وإلّا **يسقط الصفّ** — لا يبهت.
  final bool canEdit;

  /// بطاقة المكالمة والملاحظة لا تُحوَّل، فيسقط صفّها.
  final bool canForward;

  final ValueChanged<MessageMenuAction> onPick;

  /// اسم الفعل بلغة التطبيق.
  final String Function(MessageMenuAction) labelOf;

  /// صندوق الفقاعة المضغوطة على الشاشة — عليه تُبنى الطبقة.
  ///
  /// الشريط يعلوه والبطاقة تهبط تحته، وكلاهما يُحاذي حافّته في جهة الرسالة.
  /// وربطُهما بصندوق **الصفّ** كان يخطئ: الفقاعة مكبَّرةٌ داخله، فحافّتُها
  /// ليست حافّته.
  final Rect hole;

  /// عرض الشاشة — لحساب الحافّة المقابلة.
  final double screenWidth;

  /// رمزٌ اختاره المستخدم من الشريط، ومعه مركزُ خانته ومقاسُه على الشاشة —
  /// منهما تطير الحبّة إلى الرسالة.
  final void Function(String emoji, Offset from, double size)? onReact;

  /// زرّ «+» في نهاية الشريط.
  final VoidCallback? onMore;

  /// الرمز الذي تحمله الرسالة الآن — يُعلَّم في الشريط.
  final String? reaction;

  // ---- أرقام الشريط ----
  static const double reactionBarHeight = 48;
  static const double reactionGap = 12;
  static const double cell = 38;
  static const double plus = 30;
  static const double lead = 4;

  /// ذيل الشريط بعد آخر خانة — يسع قرصَ «+» كاملاً.
  ///
  /// الملف يجعله 21 فيقع القرص (30 على بعد 7) **فوق حافّة آخر رمز**، ونصُّه
  /// يقول إنها نيّةٌ مقصودة «كما في واتساب». لكنه يغطّي نحو 40٪ من الرمز،
  /// فقرّر المالك إخراجه بعدها: `7 + 30 + 2` فيبقى الرمز كاملاً.
  static const double tail = plusInset + plus + 2;
  static const double plusInset = 7;
  static const double emojiSize = 31;

  /// الرموز السبعة بترتيب الشريط.
  static const List<String> reactions = [
    '👍',
    '❤️',
    '😂',
    '😮',
    '😢',
    '🙏',
    '😘',
  ];

  static double get reactionBarWidth => lead + cell * reactions.length + tail;

  // ---- أرقام القائمة ----
  static const double menuGap = 12;
  static const double menuWidth = 220;
  static const double rowHeightMenu = 38;
  static const double menuPad = 8;
  static const double menuSeparator = 16;
  static const double menuRadius = 26;

  /// من حافّة الصفّ إلى حافّة الفقاعة: النقطة (5+4) وحشو الفقاعة 3.
  static const double edge = 12;

  /// أقلّ ما يفصل الشريط والبطاقة عن حافّة الشاشة.
  static const double screenEdge = 10;

  /// حشوة الشريط والقائمة فوق زجاج الشريط السفلي.
  static const Color barFill = Color(0xB8F6F5F3);
  static const Color menuFill = Color(0xC7F0EEEB);

  /// زجاج الشريط السفلي: `blur(30) brightness(1.15)`.
  static ui.ImageFilter get glass =>
      ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30);

  /// تأخّر كل رمزٍ عن سابقه، وتأخّر الأول.
  static const Duration stagger = Duration(microseconds: 18000);
  static const Duration popDelay = Duration(microseconds: 15000);

  /// منحنى تسارع iOS — `cubic-bezier(0.16, 1, 0.3, 1)`.
  static const Cubic iosOpenEase = Cubic(0.16, 1, 0.3, 1);

  /// منحنى انبثاق الرمز — `cubic-bezier(0.22, 1.12, 0.36, 1)`.
  static const Cubic emojiPopEase = Cubic(0.22, 1.12, 0.36, 1);

  static const Duration openDuration = Duration(milliseconds: 210);
  static const Duration closeDuration = Duration(milliseconds: 140);

  /// صفوف القائمة بترتيبها. يسقط `Forward` و`Edit` حين لا تقبلهما الرسالة.
  static const List<({MessageMenuAction action, String icon})> rows = [
    (action: MessageMenuAction.reply, icon: 'menuReply'),
    (action: MessageMenuAction.forward, icon: 'forwardMark'),
    (action: MessageMenuAction.copy, icon: 'menuCopy'),
    (action: MessageMenuAction.edit, icon: 'menuEdit'),
    (action: MessageMenuAction.category, icon: 'menuCategory'),
    (action: MessageMenuAction.remind, icon: 'menuRemind'),
  ];

  /// ارتفاع القائمة الكامل.
  static double get fullHeight =>
      menuPad * 2 + rowHeightMenu * (rows.length + 1) + menuSeparator;

  /// ارتفاعها لرسالةٍ بعينها، بعد إسقاط ما لا تقبله — `menuHeight` في الويب.
  ///
  /// يُعرف **قبل** الرسم، فتُحسب إزاحةُ الصفّ وتُفتح القائمة في رسمةٍ واحدة.
  static double heightFor({required bool canEdit, required bool canForward}) =>
      fullHeight -
      (canEdit ? 0 : rowHeightMenu) -
      (canForward ? 0 : rowHeightMenu);

  /// الفراغ تحت آخر رسالة ليتّسع لقائمتها — `MENU_GAP + MENU_H + 8`.
  static double get lastMessageRoom => menuGap + fullHeight + 8;

  @override
  State<MessageMenuV2> createState() => _MessageMenuV2State();
}

class _MessageMenuV2State extends State<MessageMenuV2>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: MessageMenuV2.openDuration,
  )..forward();

  /// الرمز الذي اختير للتوّ — يغادر الشريط فوراً.
  String? _picked;

  /// مفتاحٌ لكل خانةٍ في الشريط، لقياس موضعها عند الاختيار.
  final List<GlobalKey> _cellKeys = List<GlobalKey>.generate(
    MessageMenuV2.reactions.length,
    (_) => GlobalKey(),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<({MessageMenuAction action, String icon})> get _rows => MessageMenuV2
      .rows
      .where(
        (r) =>
            (r.action != MessageMenuAction.edit || widget.canEdit) &&
            (r.action != MessageMenuAction.forward || widget.canForward),
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    final Animation<double> curve = CurvedAnimation(
      parent: _controller,
      curve: MessageMenuV2.iosOpenEase,
    );
    final bool inn = !widget.isMine;

    // الرسالة بين الاثنين: الشريط فوق أعلى الفقاعة بفراغ 12، والبطاقة تحت
    // أسفلها بفراغ 12 — ولا حشوَ غيرهما. وكلاهما يُحاذي حافّتها في جهتها.
    final Rect hole = widget.hole;

    // كلاهما يُحاذي حافّة الفقاعة في جهتها، ثم يُزحزح إن لامس حافّة الشاشة.
    //
    // فقاعةٌ عند الطرف تدفع الشريط (عرضه نحو 309) أو البطاقة (220) خارج
    // الشاشة أو تلصقهما بحدّها. و[screenEdge] أقلّ ما يفصلهما عنها.
    ({double? left, double? right}) place(double width) {
      final double w = width.w;
      final double m = MessageMenuV2.screenEdge.w;
      // أقصى بدايةٍ تُبقي الطرف الآخر داخل الشاشة — ولا تنزل تحت [m] مهما
      // ضاقت، فشاشةٌ أضيق من العنصر تُبقيه ملتصقاً بالحدّ لا خارجه.
      final double far = (widget.screenWidth - m - w) < m
          ? m
          : widget.screenWidth - m - w;
      final double start = inn ? hole.left : widget.screenWidth - hole.right;
      final double v = start.clamp(m, far);
      return inn ? (left: v, right: null) : (left: null, right: v);
    }

    final bar = place(MessageMenuV2.reactionBarWidth);
    final card = place(MessageMenuV2.menuWidth);

    // ثم رأسياً: التصميم كما هو — الرموز فوق الفقاعة والخيارات تحتها — لكن
    // لا يخرج أيٌّ منهما عن الشاشة.
    //
    // وكانت **المحادثة تُمرَّر** لتستقرّ الرسالة في الوسط فيتّسع للطرفين.
    // وذاك يؤخّر الفتح: التمرير يُعيد بناء الصفّ أحياناً، فلا تُفتح القائمة
    // إلّا بضغطةٍ ثانية. فالرسالة تبقى مكانها وتُفتح في اللحظة، ويُحجَز
    // الطرفان هنا بدلاً منها.
    final MediaQueryData media = MediaQuery.of(context);
    final double m = MessageMenuV2.screenEdge.h;
    final double pageTop = media.padding.top + m;
    final double pageBottom = media.size.height - media.viewInsets.bottom - m;

    final double barH = MessageMenuV2.reactionBarHeight.h;
    final double cardH =
        (MessageMenuV2.menuPad * 2 +
                MessageMenuV2.rowHeightMenu * (_rows.length + 1) +
                MessageMenuV2.menuSeparator)
            .h;

    double cardTop = hole.bottom + MessageMenuV2.menuGap.h;
    double barTop = hole.top - MessageMenuV2.reactionGap.h - barH;

    // رسالةٌ في أسفل الشاشة: البطاقة **تنتقل فوق الفقاعة** والشريط فوقها.
    //
    // وكانت تُزحزح إلى أعلى وحسب حتى تدخل الشاشة، فتركب الفقاعة وتعلو
    // الرموز — فينقلب الترتيب وتتداخل الطبقات. والانتقال يُبقي الترتيب
    // سليماً: الرموز ثم الخيارات ثم الرسالة، بلا تداخل، وداخل الشاشة.
    final bool below = cardTop + cardH <= pageBottom;
    if (!below) {
      cardTop = hole.top - MessageMenuV2.menuGap.h - cardH;
      barTop = cardTop - MessageMenuV2.reactionGap.h - barH;
    }

    // ثم تُحجَز داخل الشاشة **بترتيبها**: الشريط أوّلاً، والبطاقة لا تعلوه.
    //
    // وكان كلٌّ منهما يُحجَز وحده عند [pageTop]. ورسالةٌ طويلة — بطاقةُ منتجٍ
    // مثلاً — لا تتّسع لها الشاشة فوق ولا تحت، فيُحجَز الاثنان عند الحدّ
    // نفسه فيركب أحدهما الآخر. وهو ما ظهر: الرموز تحت الخيارات في أعلى
    // الشاشة.
    //
    // فالشريط يأخذ مكانه أوّلاً، ثم تبدأ البطاقة من تحته لا من فوقه.
    if (barTop < pageTop) barTop = pageTop;

    final double floor = barTop + barH + MessageMenuV2.reactionGap.h;
    if (cardTop < floor) cardTop = floor;
    if (cardTop + cardH > pageBottom) cardTop = pageBottom - cardH;
    // وإن ضاقت الشاشة عن الاثنين معاً فأعلى البطاقة أولى: أسفلُها يُقصّ
    // ولا يختفي أوّل الخيارات، ولا يُركَب الشريط.
    if (cardTop < floor) cardTop = floor;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: barTop,
          left: bar.left,
          right: bar.right,
          child: _reactionBar(curve, inn),
        ),
        Positioned(
          top: cardTop,
          left: card.left,
          right: card.right,
          child: _menuCard(curve, inn, below),
        ),
      ],
    );
  }

  /// شريط الرموز: ينمو من زاويته السفلى في جهة الرسالة.
  Widget _reactionBar(Animation<double> curve, bool inn) {
    return AnimatedBuilder(
      animation: curve,
      builder: (context, child) => Opacity(
        opacity: (curve.value * 2).clamp(0.0, 1.0),
        child: Transform.scale(
          scale: 0.42 + 0.58 * curve.value,
          alignment: inn ? Alignment.bottomLeft : Alignment.bottomRight,
          child: child,
        ),
      ),
      child: Container(
        width: MessageMenuV2.reactionBarWidth.w,
        height: MessageMenuV2.reactionBarHeight.h,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            MessageMenuV2.reactionBarHeight.h / 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0x1F000000),
              offset: Offset(0, 6.h),
              blurRadius: 24,
            ),
            const BoxShadow(color: Color(0x0A000000), spreadRadius: 0.5),
          ],
        ),
        child: BackdropFilter(
          filter: MessageMenuV2.glass,
          child: ColoredBox(
            color: MessageMenuV2.barFill,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: MessageMenuV2.lead.w),
                  child: Row(
                    children: [
                      for (int i = 0; i < MessageMenuV2.reactions.length; i++)
                        _emojiCell(i, curve, inn),
                    ],
                  ),
                ),
                // قرص «+» فوق حافّة آخر رمز، على بعد 7 من طرف الشريط.
                //
                // مساحةُ لمسه تملأ ارتفاع الشريط وتمتدّ `plusInset` على
                // جانبيه، فالقرص 30 وحده هدفٌ ضيّق صعب الإصابة — وهو عند طرف
                // الشريط حيث لا يُخطئ المستخدم إلّا إلى الخارج.
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: widget.onMore,
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      width:
                          (MessageMenuV2.plus + MessageMenuV2.plusInset * 2).w,
                      child: Center(child: _plusDisc(curve, inn)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// خانةُ رمزٍ 38: تنبثق من 0.4 بترتيبها من جهة الفقاعة.
  Widget _emojiCell(int index, Animation<double> curve, bool inn) {
    final int order = inn ? index : MessageMenuV2.reactions.length - 1 - index;
    final double start =
        (MessageMenuV2.popDelay.inMicroseconds +
            order * MessageMenuV2.stagger.inMicroseconds) /
        MessageMenuV2.openDuration.inMicroseconds;
    final String emoji = MessageMenuV2.reactions[index];
    final bool gone = _picked == emoji;
    final GlobalKey cellKey = _cellKeys[index];

    return SizedBox(
      width: MessageMenuV2.cell.w,
      height: MessageMenuV2.reactionBarHeight.h,
      child: Center(
        // `AnimatedBuilder` خاصٌّ بالخانة، وقراءةُ `curve.value` **داخل**
        // بانيه.
        //
        // وكانت الخانات تُبنى في `child:` الباني الخارجي — وهو جزءٌ لا يُعاد
        // بناؤه مع كل إطار، فكانت `t` تُحسب مرّةً واحدة عند الفتح و`curve.value`
        // حينها صفر، فتبقى الشفافية صفراً إلى الأبد: شريطٌ أبيض فارغ بلا رموز.
        //
        // وهذا التقسيم يُبقي الظلَّ و`BackdropFilter` (تضبيب 30) خارج إعادة
        // البناء، فلا يُعاد حسابُ التضبيب ستين مرّةً في الثانية — وهو ما كان
        // يُثقل الحركة.
        child: AnimatedBuilder(
          animation: curve,
          // الرمز نفسه خارج الباني: مفتاحُه عامّ وحركتُه Lottie لها حالة،
          // فإعادةُ بنائه كلَّ إطار تُعيد الحركة من أوّلها.
          child: GestureDetector(
            onTap: () {
              // موضع الخانة يُقاس **قبل** إخفائها، فمنه تطير الحبّة.
              final Offset? center = centerOfKey(cellKey);
              setState(() => _picked = emoji);
              widget.onReact?.call(
                emoji,
                center ?? Offset.zero,
                MessageMenuV2.emojiSize,
              );
            },
            behavior: HitTestBehavior.opaque,
            child: AnimatedEmoji(
              key: cellKey,
              emoji: emoji,
              size: MessageMenuV2.emojiSize,
            ),
          ),
          builder: (context, child) {
            final double t = ((curve.value - start) / (1 - start)).clamp(
              0.0,
              1.0,
            );
            return Opacity(
              opacity: gone ? 0 : t,
              child: Transform.scale(
                scale: 0.4 + 0.6 * MessageMenuV2.emojiPopEase.transform(t),
                child: child,
              ),
            );
          },
        ),
      ),
    );
  }

  /// قرص «+»: دائرةٌ فاتحة فيها علامةُ جمعٍ 13×1.5.
  Widget _plusDisc(Animation<double> curve, bool inn) {
    final int order = inn ? MessageMenuV2.reactions.length : 0;
    final double start =
        (MessageMenuV2.popDelay.inMicroseconds +
            order * MessageMenuV2.stagger.inMicroseconds) /
        MessageMenuV2.openDuration.inMicroseconds;
    // بانٍ خاصٌّ به كخانات الرموز — انظر تعليق `_emojiCell`.
    return AnimatedBuilder(
      animation: curve,
      builder: (context, child) {
        final double t = ((curve.value - start) / (1 - start)).clamp(0.0, 1.0);
        return Opacity(
          opacity: t,
          child: Transform.scale(
            scale: 0.4 + 0.6 * MessageMenuV2.emojiPopEase.transform(t),
            child: child,
          ),
        );
      },
      // الرسم وحده: اللمس على الصندوق الأوسع الذي يحضنه في `_reactionBar`.
      child: Container(
        width: MessageMenuV2.plus.w,
        height: MessageMenuV2.plus.w,
        decoration: const BoxDecoration(
          color: Color(0xFFEDEBE8),
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 13.w,
              height: 1.5,
              decoration: BoxDecoration(
                color: ContactDesign.ink,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            Container(
              width: 1.5,
              height: 13.w,
              decoration: BoxDecoration(
                color: ContactDesign.ink,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// بطاقة القائمة: 220 بنصف قطر 26، تنمو من زاويتها العليا مع صعودٍ 4.
  Widget _menuCard(Animation<double> curve, bool inn, bool below) {
    // تنمو من الزاوية الأقرب إلى الفقاعة: العليا حين تهبط تحتها، والسفلى
    // حين تنتقل فوقها — وإلّا بدت كأنها تنبت من الجهة البعيدة.
    final Alignment from = below
        ? (inn ? Alignment.topLeft : Alignment.topRight)
        : (inn ? Alignment.bottomLeft : Alignment.bottomRight);

    return AnimatedBuilder(
      animation: curve,
      builder: (context, child) => Opacity(
        opacity: (curve.value * 2).clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, (below ? -4 : 4) * (1 - curve.value)),
          child: Transform.scale(
            scale: 0.48 + 0.52 * curve.value,
            alignment: from,
            child: child,
          ),
        ),
      ),
      child: Container(
        width: MessageMenuV2.menuWidth.w,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(MessageMenuV2.menuRadius.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0x29000000),
              offset: Offset(0, 8.h),
              blurRadius: 30,
            ),
            const BoxShadow(color: Color(0x0D000000), spreadRadius: 0.5),
          ],
        ),
        child: BackdropFilter(
          filter: MessageMenuV2.glass,
          child: ColoredBox(
            color: MessageMenuV2.menuFill,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: MessageMenuV2.menuPad.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final r in _rows) _row(r.action, r.icon),
                  // خطٌّ شعريٌّ 0.5 منزاحٌ 22، في مساحةٍ 16.
                  SizedBox(
                    height: MessageMenuV2.menuSeparator.h,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 22.w),
                        child: Container(
                          height: 0.5,
                          color: const Color(0x4A3C3C43),
                        ),
                      ),
                    ),
                  ),
                  _row(MessageMenuAction.delete, 'menuDelete', isDanger: true),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// صفٌّ واحد: 38 ارتفاعاً، حشوُه 23 من البداية، وكلمتُه 15 على بعد 12.
  Widget _row(MessageMenuAction action, String icon, {bool isDanger = false}) {
    final Color color = isDanger ? ChatDesign.missedRed : ContactDesign.ink;
    // سهم التحويل 17 وبقيّة الأيقونات 15.
    final double size = icon == 'forwardMark' ? 17 : 15;

    return InkWell(
      onTap: () => widget.onPick(action),
      // ضغطةٌ تُظلّل الصفّ بأسودٍ 5٪ — `active:bg-black/5`.
      highlightColor: const Color(0x0D000000),
      splashColor: const Color(0x0D000000),
      child: SizedBox(
        height: MessageMenuV2.rowHeightMenu.h,
        child: Row(
          children: [
            SizedBox(width: 23.w),
            SizedBox(
              width: 18.w,
              child: Center(
                child: _InkIcon(icon, size: size, color: color),
              ),
            ),
            SizedBox(width: 12.w),
            DesignText(
              widget.labelOf(action),
              size: 15,
              family: 'Quicksand-Regular',
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}

/// أيقونةُ صفٍّ ملوّنةٌ بلون الصفّ.
///
/// ملفّات XD بألوانها، و`srcIn` يستبدل ألوانها بلونٍ واحد — فيصير `Delete`
/// أحمرَ بأيقونته بلا ملفٍّ ثانٍ.
class _InkIcon extends StatelessWidget {
  const _InkIcon(this.name, {required this.size, required this.color});

  final String name;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      child: XdIcon(name, width: size, height: size),
    );
  }
}
