import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/features/chat/presentation/pages/conversation_design.dart';
import 'package:trydos/features/chat/presentation/pages/profile_page_design.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_v2/animated_emoji_v2.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_v2/reaction_fly_v2.dart';

/// سطر الأعلام فوق رسالة: وسمُها ورمزُ تذكيرها.
///
/// منقولٌ بالبكسل من `chat/messages.tsx` على فرع `development`:
///
/// > الأعلام فوق الرسالة: وسمُها حبّةً بلون الوسم (كلمات بيضاء 9 Medium)،
/// > وتذكيرُها حبّةً رمادية فيها جرس القائمة والوقت. سطرٌ 16 في جهة
/// > الرسالة، على بعد 3 فوقها؛ ولا شيء إن لم تحمل أيّاً منهما.
///
/// وهذا يحلّ محلّ أيقونتَي القلم والجرس اللتين كنّا نضعهما في ذيل الفقاعة:
/// التصميم الجديد ينقلهما فوقها حبّتين مكتوبتين.
class MessageFlagsLine extends StatelessWidget {
  const MessageFlagsLine({
    super.key,
    required this.isMine,
    this.categoryName,
    this.categoryColor,
    this.reminderText,
  });

  final bool isMine;

  /// اسم الوسم ولونه. الاسم بلا لون يأخذ البنفسجي الافتراضي.
  final String? categoryName;
  final Color? categoryColor;

  /// وقت التذكير كما يطبعه العلم.
  final String? reminderText;

  static const double height = 16;
  static const double radius = 8;

  @override
  Widget build(BuildContext context) {
    final bool hasCategory = categoryName != null && categoryName!.isNotEmpty;
    final bool hasReminder = reminderText != null && reminderText!.isNotEmpty;
    if (!hasCategory && !hasReminder) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(
        bottom: 3.h,
        left: isMine ? 0 : 12.w,
        right: isMine ? 12.w : 0,
      ),
      child: Row(
        // جهةٌ مطلقة كجهة الفقاعة.
        textDirection: TextDirection.ltr,
        mainAxisAlignment: isMine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasCategory) _categoryPill(),
          if (hasCategory && hasReminder) SizedBox(width: 4.w),
          if (hasReminder) _reminderPill(),
        ],
      ),
    );
  }

  /// حبّة الوسم: بلونه وكلماتها بيضاء.
  Widget _categoryPill() {
    return Container(
      height: height.h,
      padding: EdgeInsets.symmetric(horizontal: 7.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: categoryColor ?? ContactDesign.purple,
        borderRadius: BorderRadius.circular(radius.r),
      ),
      child: DesignText(
        categoryName!,
        size: 9,
        family: 'Quicksand-Medium',
        color: Colors.white,
      ),
    );
  }

  /// حبّة التذكير: رمادية، فيها الجرس ثم الوقت. حشوُها غير متناظر —
  /// 5 قبل الجرس و7 بعد الوقت.
  Widget _reminderPill() {
    return Container(
      height: height.h,
      padding: EdgeInsetsDirectional.only(start: 5.w, end: 7.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ChatDesign.callCard,
        borderRadius: BorderRadius.circular(radius.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const XdIcon('menuRemind', width: 10, height: 10),
          SizedBox(width: 3.w),
          DesignText(reminderText!, size: 9, family: 'Quicksand-Medium'),
        ],
      ),
    );
  }
}

/// رقاقة التفاعل على رسالة.
///
/// > الرمز الذي وضعه المتسوّق على رسالة، كما يعرضه واتساب: حبّةٌ بيضاء
/// > صغيرة في جهة الرسالة، تركب فوق حافّة الفقاعة السفلى.
///
/// ورمزٌ اختير للتوّ من الشريط **يطير** من خانته إلى هنا: الحبّة تسأل
/// [ReactionFlyStore] عند تركيبها، فإن وجدت طيراناً يقصدها انطلقت من موضع
/// الخانة ومقاسها، وإلّا انبثقت مكانها — وهو ما يفعله الويب لحبّةٍ كانت
/// موجودةً أصلاً.
class ReactionChipV2 extends StatefulWidget {
  const ReactionChipV2({
    super.key,
    required this.isMine,
    required this.emoji,
    this.messageId,
  });

  final bool isMine;
  final String emoji;

  /// معرّف الرسالة — به تعرف الحبّةُ أن الطيران المعلَّق يقصدها هي.
  final String? messageId;

  /// مقاس الرمز داخل الرقاقة.
  static const double emojiSize = 14;

  /// ارتفاع الحبّة البيضاء وحشوها الأفقي.
  ///
  /// الملف يجعلها 22 بحشو 7 حول رمزٍ 16 — أي 30×22 — ونصفُ قطرها 11.
  /// وقرّرها المالك أصغر قليلاً، فهي هنا 19 بحشو 5 حول رمزٍ 14: 24×19.
  ///
  /// وهي أرقامٌ مترابطة: نصف القطر نصفُ الارتفاع فتبقى الحافّة نصفَ دائرة،
  /// و[rideUp] يُحسب منها كذلك — فتغييرُ الارتفاع وحده يكفي لتكبيرها أو
  /// تصغيرها دون أن ينكسر شيء.
  static const double chipHeight = 19;
  static const double chipPadX = 5;

  /// كم تركب الحبّةُ حافّةَ الفقاعة السفلى — `marginTop: -9` في الويب،
  /// وبنسبتها إلى ارتفاعٍ أصغر هنا.
  static const double rideUp = 8;

  @override
  State<ReactionChipV2> createState() => _ReactionChipV2State();
}

class _ReactionChipV2State extends State<ReactionChipV2>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );

  /// الطيران الذي يقصد هذه الحبّة، إن وُجد.
  ReactionFly? _fly;

  /// مفتاح الحبّة — لقياس موضعها ومنه تُحسب مسافة الطيران.
  final GlobalKey _chipKey = GlobalKey();

  /// إزاحةُ الانطلاق: من خانة الشريط إلى موضع الحبّة.
  Offset _from = Offset.zero;

  @override
  void initState() {
    super.initState();
    final String? id = widget.messageId;
    _fly = id == null ? null : ReactionFlyStore.peek(id, widget.emoji);

    if (_fly == null) {
      // لا طيران: انبثاقةٌ مكانها كما في الويب.
      _controller.forward();
      return;
    }
    ReactionFlyStore.drop();
    // الموضع لا يُعرف قبل أول تخطيط، فتُقاس الإزاحة في أول إطار ثم تنطلق.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final Offset? here = centerOfKey(_chipKey);
      if (here != null) setState(() => _from = _fly!.center - here);
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> curve = CurvedAnimation(
      parent: _controller,
      // طيرانٌ ينتهي هادئاً، وانبثاقةٌ ترتدّ.
      curve: _fly == null ? Curves.elasticOut : Curves.easeOutCubic,
    );

    // الحبّة تركب حافّة الفقاعة السفلى — `marginTop: -9` في الويب.
    //
    // و`Container.margin` السالب يرمي في Flutter: يتحوّل إلى `Padding`،
    // وهو يؤكّد أن حشوَه غير سالب. فهذا ما كان يُظهر الخطأ عند اختيار رمز.
    //
    // و`Align` بـ`heightFactor` يفعل ما يفعله الهامش السالب بالضبط: يحجز
    // ما دون [ReactionChipV2.rideUp] في التخطيط، وتُحاذى الحبّة إلى أسفله
    // فتفيض بقدره فوقه.
    //
    // وموضعها من حافّة الفقاعة: `marginLeft: 16` للواردة و`marginRight: 16`
    // للمرسَلة في الويب. والحشو **خارج** الحركة لا داخلها: `Transform` في
    // Flutter يقع بعد التخطيط، فحشوٌ داخله يُكبَّر مع الحبّة فيتبدّل موضعها
    // أثناء الطيران.
    const double h = ReactionChipV2.chipHeight;
    final bool inn = !widget.isMine;
    Widget lift(Widget chip) => Padding(
      padding: EdgeInsets.only(left: inn ? 16.w : 0, right: inn ? 0 : 16.w),
      child: Align(
        alignment: Alignment.bottomCenter,
        widthFactor: 1,
        heightFactor: (h - ReactionChipV2.rideUp) / h,
        child: chip,
      ),
    );

    if (_fly != null) {
      return lift(
        AnimatedBuilder(
          animation: curve,
          builder: (context, child) {
            final double t = curve.value;
            return Transform.translate(
              offset: _from * (1 - t),
              child: Transform.scale(
                // تبدأ بمقاس خانة الشريط وتصل مقاس الحبّة.
                scale: (_fly!.size / ReactionChipV2.emojiSize) * (1 - t) + t,
                child: Opacity(
                  opacity: (0.4 + 0.6 * t).clamp(0.0, 1.0),
                  child: child,
                ),
              ),
            );
          },
          child: _chip(),
        ),
      );
    }

    return lift(
      ScaleTransition(
        // انبثاقةٌ بارتداد — نابضٌ متيبّس في الويب.
        scale: curve,
        child: _chip(),
      ),
    );
  }

  Widget _chip() {
    return KeyedSubtree(
      key: _chipKey,
      child: Container(
        height: ReactionChipV2.chipHeight.h,
        padding: EdgeInsets.symmetric(horizontal: ReactionChipV2.chipPadX.w),
        // بلا `alignment`: `Container` بمحاذاةٍ **يتمدّد إلى أقصى ما تسمح به
        // قيوده** — فكانت الحبّة مستطيلاً أبيض طويلاً بعرض الفقاعة كلّها.
        // والحشو وحده يوسّط الرمز.
        decoration: BoxDecoration(
          color: Colors.white,
          // نصفُ الارتفاع، فتبقى الحافّة نصفَ دائرة مهما تغيّر.
          borderRadius: BorderRadius.circular(
            (ReactionChipV2.chipHeight / 2).r,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x2E000000),
              offset: Offset(0, 1),
              blurRadius: 3,
            ),
            // الحدّ الشعريّ `0 0 0 0.5px` — ظلٌّ بلا تمويه وبانتشار نصف
            // بكسل، وهو ما يكافئ `box-shadow` الثانية في الويب.
            BoxShadow(color: Color(0x0D000000), spreadRadius: 0.5),
          ],
        ),
        child: AnimatedEmoji(
          emoji: widget.emoji,
          size: ReactionChipV2.emojiSize,
        ),
      ),
    );
  }
}
