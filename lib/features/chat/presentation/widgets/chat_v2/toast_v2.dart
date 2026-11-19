import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/features/chat/presentation/pages/conversation_design.dart';

/// كلمةُ تأكيدٍ قصيرة تظهر لحظةً ثم تغيب.
///
/// منقولةٌ بالبكسل من `web_design/components/DemoApp1/chat/Toast.tsx` على فرع
/// `development`:
///
/// > كلمةُ تأكيدٍ قصيرة («نُسخ»، «أُرشف») في حبّة تلميح القائمة الداكنة
/// > (اللوحة `– 44`: `#404040`، نصف قطر 8، SF Pro Rounded، بيضاء). تصعد من
/// > أسفل، وتبقى 1800، ثم تهبط.
abstract class ToastV2 {
  /// ما تبقاه الحبّة على الشاشة.
  static const Duration stay = Duration(milliseconds: 1800);

  /// صعودها: نابضٌ صلابته 500 وتخميده 32 — ما يقابله هنا 260 بمنحنى مرن.
  static const Duration rise = Duration(milliseconds: 260);

  /// هبوطها أسرع من صعودها.
  static const Duration sink = Duration(milliseconds: 180);

  /// بعدها عن أسفل الشاشة.
  static const double bottom = 90;

  /// يُظهر حبّةً فوق المحادثة.
  ///
  /// تُعرض في `Overlay` لا في شجرة الصفحة، فلا تدفع تخطيطاً ولا تتأثّر بإعادة
  /// بنائه، ولا تحتاج حالةً في الشاشة الحاضنة.
  static void show(BuildContext context, String text) {
    final OverlayState? overlay = Overlay.maybeOf(context);
    if (overlay == null || text.isEmpty) return;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastPill(
        text: text,
        // `mounted` حرسٌ ثانٍ: إزالةُ طبقةٍ مُزالةٍ ترمي.
        onGone: () {
          if (entry.mounted) entry.remove();
        },
      ),
    );
    overlay.insert(entry);
  }
}

class _ToastPill extends StatefulWidget {
  const _ToastPill({required this.text, required this.onGone});

  final String text;

  /// تمّت الحركة وانتهى الظهور: تُزال من الـ`Overlay`.
  final VoidCallback onGone;

  @override
  State<_ToastPill> createState() => _ToastPillState();
}

class _ToastPillState extends State<_ToastPill> {
  /// ظاهرةٌ الآن. تبدأ مخفيّةً ثم تُرفع في أوّل إطار، فتُرى الحركة.
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      setState(() => _shown = true);
      await Future<void>.delayed(ToastV2.stay);
      if (!mounted) return;
      setState(() => _shown = false);
      await Future<void>.delayed(ToastV2.sink);
      // لو فُكِّكت الشاشة أثناء الخبوّ لكانت الطبقة قد أُزيلت معها، فنداءُ
      // `remove` ثانيةً يرمي.
      if (!mounted) return;
      widget.onGone();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: ToastV2.bottom.h + MediaQuery.of(context).padding.bottom,
      // `Material` شفّافة: الحبّة في `Overlay`، ونصٌّ بلا `Material` فوقه
      // يرسمه Flutter مخطَّطاً بالأصفر.
      child: Material(
        type: MaterialType.transparency,
        child: IgnorePointer(
          child: Center(
            child: AnimatedSlide(
              offset: Offset(0, _shown ? 0 : 0.6),
              duration: _shown ? ToastV2.rise : ToastV2.sink,
              curve: _shown ? Curves.easeOutBack : Curves.easeIn,
              child: AnimatedScale(
                scale: _shown ? 1 : 0.9,
                duration: _shown ? ToastV2.rise : ToastV2.sink,
                curve: Curves.easeOut,
                child: AnimatedOpacity(
                  opacity: _shown ? 1 : 0,
                  duration: _shown ? ToastV2.rise : ToastV2.sink,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: ChatDesign.tooltip,
                      borderRadius: BorderRadius.circular(8.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x33000000),
                          blurRadius: 3,
                          offset: Offset(0, 3.h),
                        ),
                      ],
                    ),
                    child: Text(
                      widget.text,
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: 'SF-Pro-Rounded-Regular',
                        fontSize: 12.sp,
                        height: 15 / 12,
                        leadingDistribution: TextLeadingDistribution.even,
                        letterSpacing: 12 * 0.01,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
