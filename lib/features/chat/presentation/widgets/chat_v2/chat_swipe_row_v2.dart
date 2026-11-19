import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/features/chat/presentation/pages/chat_list_design.dart';
import 'package:trydos/features/chat/presentation/pages/profile_page_design.dart';

/// فعلٌ في خانات سحب صفّ المحادثة.
enum ChatSwipeActionV2 { mute, delete, archive, unread, pin }

/// جهة الصفّ المفتوحة.
enum ChatSwipeSideV2 { left, right }

/// صفُّ محادثةٍ ينزلق جانبياً فوق خانات أفعاله.
///
/// منقولٌ من `SwipeRow` في
/// `web_design/components/DemoApp1/screens/ChatListScreen.tsx` على فرع
/// `development` (لوح XD `Home Page – 42`):
///
/// > الصفّ المسحوب **يساراً** يُظهر «كتم» و«حذف» و«أرشفة» (71×100 لكلٍّ،
/// > بينها 2، ملتصقةً باليمين: الصفّ يتحرّك 219)؛ **والمسحوب يميناً** يُظهر
/// > «غير مقروءة» و«تثبيت» عند x=2 و75 (الصفّ يتحرّك 148).
/// >
/// > اسحبه فينفتح إذا تجاوز نصف المسافة؛ ونقرةٌ على صفٍّ مفتوح تُغلقه،
/// > وعلى صفٍّ مغلق تفتح المحادثة.
/// >
/// > **القائمة تملك أيَّ صفٍّ مفتوح**: الصفّ يقول متى بدأ يتحرّك
/// > ([onActivate])، ومتى رُفع الإصبع ([onRelease])، ومتى استقرّ مغلقاً
/// > ([onRest])؛ وصفٌّ لم يعد هو [active] ينزلق مغلقاً من تلقائه.
class ChatSwipeRowV2 extends StatefulWidget {
  const ChatSwipeRowV2({
    super.key,
    required this.child,
    required this.active,
    required this.onActivate,
    required this.onRelease,
    required this.onRest,
    required this.onOpen,
    required this.onAct,
    required this.labelOf,
  });

  /// وجه الصفّ — [ChatRowFaceV2] عادةً.
  final Widget child;

  /// هذا الصفّ هو المفتوح الآن في القائمة.
  final bool active;

  /// بدأ الصفّ يتحرّك تحت إصبع.
  final VoidCallback onActivate;

  /// رُفع الإصبع عن الصفّ.
  final VoidCallback onRelease;

  /// استقرّ الصفّ مغلقاً.
  final VoidCallback onRest;

  /// نقرةٌ على صفٍّ مغلق — تفتح المحادثة.
  final VoidCallback onOpen;

  final ValueChanged<ChatSwipeActionV2> onAct;

  /// اسم الفعل بلغة التطبيق.
  ///
  /// الكلمة تنقلب بحالة المحادثة — «كتم»/«إلغاء الكتم»، «أرشفة»/«إخراج من
  /// الأرشيف»، «تعليم كغير مقروءة»/«تعليم كمقروءة» — والشاشة الحاضنة وحدها
  /// تعرف الحالة، فهي التي تختار الكلمة. والأيقونة لا تنقلب، كما في الملف.
  final String Function(ChatSwipeActionV2) labelOf;

  /// الخانات الثلاث التي تظهر بالسحب يساراً.
  static const List<ChatSwipeActionV2> rightActions = [
    ChatSwipeActionV2.mute,
    ChatSwipeActionV2.delete,
    ChatSwipeActionV2.archive,
  ];

  /// والخانتان اللتان تظهران بالسحب يميناً.
  static const List<ChatSwipeActionV2> leftActions = [
    ChatSwipeActionV2.unread,
    ChatSwipeActionV2.pin,
  ];

  /// نابض الانزلاق — `TRAVEL` في الويب: `stiffness 560, damping 38, mass 0.85`.
  static const SpringDescription travel = SpringDescription(
    mass: 0.85,
    stiffness: 560,
    damping: 38,
  );

  @override
  State<ChatSwipeRowV2> createState() => _ChatSwipeRowV2State();
}

class _ChatSwipeRowV2State extends State<ChatSwipeRowV2>
    with SingleTickerProviderStateMixin {
  late final AnimationController _snap = AnimationController.unbounded(
    vsync: this,
  )..addListener(() => setState(() => _x = _snap.value));

  /// إزاحة الوجه الآن: سالبةٌ إلى اليسار وموجبةٌ إلى اليمين.
  double _x = 0;

  ChatSwipeSideV2? _open;

  /// تحرّك الصفّ منذ آخر ضغطة — فالسحب ليس نقرةً أبداً.
  bool _dragged = false;

  double get _openLeft => ChatListDesign.openLeft.w;
  double get _openRight => ChatListDesign.openRight.w;

  @override
  void dispose() {
    _snap.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ChatSwipeRowV2 old) {
    super.didUpdateWidget(old);
    // صفٌّ آخر أخذ الدور، أو نقرةٌ أغلقت الصفوف: هذا ينغلق.
    if (!widget.active && (_open != null || _x != 0)) {
      _open = null;
      _animateTo(0);
    }
  }

  void _animateTo(double target) {
    _snap.animateWith(SpringSimulation(ChatSwipeRowV2.travel, _x, target, 0));
  }

  void _snapTo(double target) {
    _open = target == 0
        ? null
        : (target < 0 ? ChatSwipeSideV2.left : ChatSwipeSideV2.right);
    _animateTo(target);
    if (_open == null) widget.onRest();
  }

  void _onDragStart(DragStartDetails _) {
    _snap.stop();
    _dragged = true;
    widget.onActivate();
  }

  void _onDragUpdate(DragUpdateDetails d) {
    setState(() {
      final double next = _x + d.delta.dx;
      // مقاومةٌ خارج الحدّين — `dragElastic: 0.08` في الويب.
      if (next < _openLeft) {
        _x = _openLeft + (next - _openLeft) * 0.08;
      } else if (next > _openRight) {
        _x = _openRight + (next - _openRight) * 0.08;
      } else {
        _x = next;
      }
    });
  }

  void _onDragEnd(DragEndDetails _) {
    widget.onRelease();
    if (_x < _openLeft / 2) {
      _snapTo(_openLeft);
    } else if (_x > _openRight / 2) {
      _snapTo(_openRight);
    } else {
      _snapTo(0);
    }
  }

  void _onTap() {
    // نقرةٌ لا نهايةَ سحبة: ضغطةٌ حرّكت الصفَّ تُهمَل هنا.
    if (_dragged) return;
    if (_open != null) {
      _snapTo(0);
    } else {
      widget.onOpen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      // جهاتٌ مطلقة: خانات الكتم والحذف والأرشفة يميناً في كل اللغات،
      // وخانتا غير المقروءة والتثبيت يساراً — كما يرسمها الملف.
      textDirection: TextDirection.ltr,
      child: Container(
        height: ChatListDesign.rowHeight.h,
        margin: EdgeInsets.only(top: ChatListDesign.rowGap.h),
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(),
        child: Stack(
          children: [
            // خانات السحب يساراً، ملتصقةً باليمين.
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              child: Row(
                children: [
                  for (final ChatSwipeActionV2 a in ChatSwipeRowV2.rightActions)
                    Padding(
                      padding: EdgeInsets.only(
                        left: a == ChatSwipeRowV2.rightActions.first
                            ? 0
                            : ChatListDesign.cellGap.w,
                      ),
                      child: ChatActionCellV2(
                        action: a,
                        label: widget.labelOf(a),
                        icon: _iconOf(a),
                        onTap: () => _act(a),
                      ),
                    ),
                ],
              ),
            ),

            // وخانات السحب يميناً، على بعد 2 من اليسار.
            Positioned(
              top: 0,
              bottom: 0,
              left: ChatListDesign.cellGap.w,
              child: Row(
                children: [
                  for (final ChatSwipeActionV2 a in ChatSwipeRowV2.leftActions)
                    Padding(
                      padding: EdgeInsets.only(
                        left: a == ChatSwipeRowV2.leftActions.first
                            ? 0
                            : ChatListDesign.cellGap.w,
                      ),
                      child: ChatActionCellV2(
                        action: a,
                        label: widget.labelOf(a),
                        icon: _iconOf(a),
                        onTap: () => _act(a),
                      ),
                    ),
                ],
              ),
            ),

            // الوجه فوقها، ينزلق بالإصبع.
            Transform.translate(
              offset: Offset(_x, 0),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (_) => _dragged = false,
                onTap: _onTap,
                // أفقيٌّ وحده — والعمودي يُترك لتمرير القائمة.
                onHorizontalDragStart: _onDragStart,
                onHorizontalDragUpdate: _onDragUpdate,
                onHorizontalDragEnd: _onDragEnd,
                onHorizontalDragCancel: () => _snapTo(0),
                child: widget.child,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _act(ChatSwipeActionV2 a) {
    widget.onAct(a);
    _snapTo(0);
  }

  /// أيقونة الخانة — ثابتةٌ لكل فعل، انظر [ChatSwipeRowV2.labelOf].
  String _iconOf(ChatSwipeActionV2 a) => switch (a) {
    ChatSwipeActionV2.mute => 'swipeMute',
    ChatSwipeActionV2.delete => 'swipeDelete',
    ChatSwipeActionV2.archive => 'swipeArchive',
    ChatSwipeActionV2.unread => 'swipeUnread',
    ChatSwipeActionV2.pin => 'swipePin',
  };
}

/// خانةٌ واحدة: 71×100 بيضاء بخطٍّ 0.3، أيقونتُها على بعد 20 من الأعلى
/// وكلمتُها على خطّ الأساس 77 موسَّطة.
class ChatActionCellV2 extends StatelessWidget {
  const ChatActionCellV2({
    super.key,
    required this.action,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final ChatSwipeActionV2 action;
  final String label;
  final String icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: ChatListDesign.cellWidth.w,
        height: ChatListDesign.rowHeight.h,
        color: ChatListDesign.white,
        foregroundDecoration: BoxDecoration(
          border: Border.all(
            color: ChatListDesign.line,
            width: ChatListDesign.rowLine,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(top: ChatListDesign.cellIconTop.h),
              child: XdIcon(icon, width: ChatListDesign.tabIconSize),
            ),
            Padding(
              // الكلمة على خطّ الأساس 77، والأيقونة تنتهي عند 45.
              padding: EdgeInsets.only(
                top:
                    (ContactDesign.textTop(
                              ChatListDesign.cellLabelBaseline,
                              12,
                            ) -
                            (ChatListDesign.cellIconTop +
                                ChatListDesign.tabIconSize))
                        .h,
                left: 2.w,
                right: 2.w,
              ),
              child: DesignText(
                label,
                size: 12,
                family: 'Quicksand-Regular',
                center: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
