import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/features/chat/presentation/pages/conversation_design.dart';
import 'package:trydos/features/chat/presentation/pages/profile_page_design.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_v2/chat_bubble_v2.dart';

/// رسالة صوتية بالتصميم الجديد.
///
/// منقولةٌ بالبكسل من `chat/messages.tsx` (لوحة XD `Home Page – 44`,
/// y 1015 و1130):
///
/// > العلامة 16×16 وكلمتا «Voice Message» 13 Regular في سطر؛ وتحتها بـ18
/// > علامة التشغيل 30×30 وخمس موجات 51.72×30 (الأولى بلون المرسِل والبقية
/// > `#C3C3C3`)؛ ورأس التشغيل خطٌّ 0.5 بارتفاع 23 على بعد 15.5 من الأعلى،
/// > وتحته المدّة في حبّة 38×19 بخطّ 0.4 ونصف قطر 15؛ والوقت 9 Regular عند
/// > نهاية الموجات على بعد 36.
///
/// الشكل وحده: التشغيل الفعلي يأتي من الشاشة الحاضنة عبر [onTogglePlay]
/// و[progress]، فلا يعرف هذا الملف مشغّلاً ولا ملفّ صوت.
class VoiceMessageV2 extends StatelessWidget {
  const VoiceMessageV2({
    super.key,
    required this.isMine,
    required this.time,
    required this.label,
    required this.durationText,
    required this.isPlaying,
    required this.onTogglePlay,
    this.progress = 0,
    this.status,
    this.isReplied = false,
    this.onSeek,
  });

  final bool isMine;
  final String time;

  /// كلمتا «رسالة صوتية» بلغة التطبيق.
  final String label;

  /// المدّة المعروضة: الكلّية عند السكون، والمنقضية أثناء التشغيل.
  final String durationText;

  final bool isPlaying;
  final VoidCallback onTogglePlay;

  /// ما انقضى من الرسالة، من 0 إلى 1.
  final double progress;

  final BubbleStatus? status;
  final bool isReplied;

  /// سحب رأس التشغيل. يصل بنسبةٍ من 0 إلى 1.
  final ValueChanged<double>? onSeek;

  /// عرض موجةٍ واحدة كما في الملف. خمسٌ منها تصنع المسار.
  static const double waveWidth = 51.72;
  static const double wavesWidth = 5 * waveWidth;

  /// موضع رأس التشغيل عند السكون: الملف يضعه بعد الموجة الأولى تقريباً،
  /// ويختلف بين الواردة والمرسَلة.
  double get _restHead => isMine ? 52.2 : 48.5;

  Color get _tint => isMine ? ChatDesign.sent : ContactDesign.purple;

  /// لون الكلمتين. المرسَلة بلون أغمق قليلاً من فقاعتها في الملف.
  Color get _labelColor =>
      isMine ? const Color(0xFF8C01E5) : ContactDesign.purple;

  @override
  Widget build(BuildContext context) {
    final bool inn = !isMine;
    // رأس التشغيل: عند السكون موضعه من الملف، وأثناء التشغيل يتبع النسبة.
    final double head = progress > 0
        ? progress.clamp(0.0, 1.0) * wavesWidth
        : _restHead;

    return Column(
      crossAxisAlignment: inn
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        _titleRow(inn),
        SizedBox(height: 18.h),
        // الصفّ يتقلّص بنسبه إن ضاقت الشاشة، ولا يفيض.
        //
        // مجموعه 312.6 من 428 (12 + 30 + 12 + 258.6)، فيتّسع عادةً — لكن
        // جهازاً ضيّقاً أو مقياسَ خطٍّ كبيراً يجعله يتجاوز بكسراتٍ، وهو ما
        // أعطى `RIGHT OVERFLOWED BY 7.2`. و`scaleDown` يصغّره عند الحاجة
        // وحدها، فتبقى نِسَبُ الموجات ورأسِ التشغيل كما في الملف.
        SizedBox(
          height: 57.h,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: inn ? Alignment.centerLeft : Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (inn) SizedBox(width: 12.w),
                GestureDetector(
                  onTap: onTogglePlay,
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: 30.w,
                    height: 30.w,
                    // العلامتان تتبادلان بدورانٍ سريع ونموّ — 0.18 ثانية.
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      transitionBuilder: (child, animation) =>
                          RotationTransition(
                            turns: Tween<double>(
                              begin: -0.25,
                              end: 0,
                            ).animate(animation),
                            child: ScaleTransition(
                              scale: animation,
                              child: child,
                            ),
                          ),
                      child: isPlaying
                          ? _PauseMark(
                              key: const ValueKey('pause'),
                              color: _tint,
                            )
                          : XdIcon(
                              isMine ? 'playMagenta' : 'playPurple',
                              key: const ValueKey('play'),
                              width: 30,
                              height: 30,
                            ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                _waves(inn, head),
                if (!inn) SizedBox(width: 12.w),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// سطر العلامة والكلمتين — ترتيبه ينعكس بين الوارد والمرسَل.
  Widget _titleRow(bool inn) {
    final Widget mark = XdIcon(
      inn ? 'voiceMarkPurple' : 'voiceMarkMagenta',
      width: 16,
      height: 16,
    );
    final Widget words = DesignText(
      label,
      size: 13,
      family: 'Quicksand-Regular',
      color: _labelColor,
      letterSpacing: ChatDesign.inLetterSpacing,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: inn
          ? [
              const BubbleDot(isMine: false),
              Padding(
                padding: EdgeInsetsDirectional.only(start: 3.w),
                child: mark,
              ),
              // مرنةٌ لا بعرضها الطبيعي: «voice message» قصيرة في الملف،
              // و«رسالة صوتية» ونظيراتها أطول — فنصٌّ بلا حدٍّ يتجاوز
              // عرض الصفّ. و`Flexible` يجب أن يكون ابناً مباشراً للصفّ،
              // فالحشو داخله لا حوله.
              Flexible(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(start: 4.w),
                  child: words,
                ),
              ),
            ]
          : [
              Flexible(child: words),
              Padding(
                padding: EdgeInsetsDirectional.only(start: 4.w),
                child: mark,
              ),
              Padding(
                padding: EdgeInsetsDirectional.only(start: 3.w),
                child: const BubbleDot(isMine: true),
              ),
            ],
    );
  }

  /// مسار الموجات: رماديةٌ كاملة، وفوقها الملوّنة مقصوصةً عند رأس التشغيل.
  Widget _waves(bool inn, double head) {
    return GestureDetector(
      // سحبٌ أفقي يحرّك رأس التشغيل؛ والعمودي يبقى للتمرير.
      // `localPosition` محسوبةٌ أصلاً داخل مربّع الموجات، فلا حاجة لقياس
      // الصندوق.
      onHorizontalDragUpdate: onSeek == null
          ? null
          : (details) => onSeek!(
              (details.localPosition.dx / wavesWidth.w).clamp(0.0, 1.0),
            ),
      onTapDown: onSeek == null
          ? null
          : (details) => onSeek!(
              (details.localPosition.dx / wavesWidth.w).clamp(0.0, 1.0),
            ),
      child: SizedBox(
        width: wavesWidth.w,
        height: 57.h,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(children: _waveRow('waveGrey')),

            // الجزء المُشغَّل: الموجات الملوّنة مقصوصةً عند الرأس.
            ClipRect(
              clipper: _HeadClipper(head.w),
              child: Row(
                children: _waveRow(inn ? 'wavePurple' : 'waveMagenta'),
              ),
            ),

            // رأس التشغيل: خطٌّ 0.5 بارتفاع 23 على بعد 15.5 من الأعلى.
            PositionedDirectional(
              start: head.w,
              top: 15.5.h,
              child: Container(width: 0.5, height: 23.h, color: _tint),
            ),

            // حبّة المدّة: تتبع الرأس ولا تخرج عن بدايته.
            PositionedDirectional(
              start: (head - 19.5).clamp(0.0, wavesWidth).w,
              top: 38.h,
              child: _DurationPill(text: durationText, color: _tint),
            ),

            // الوقت عند نهاية الموجات.
            PositionedDirectional(
              end: 0,
              top: 36.h,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (inn && isReplied) ...[
                    const XdIcon('replyMarkPurple', width: 11, height: 11),
                    SizedBox(width: 4.w),
                  ],
                  if (!inn && status != null) _InkMark(status: status!),
                  DesignText(time, size: 9, family: 'Quicksand-Regular'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _waveRow(String name) =>
      List.generate(5, (_) => XdIcon(name, width: waveWidth, height: 30));
}

/// يقصّ الموجات الملوّنة عند موضع رأس التشغيل.
class _HeadClipper extends CustomClipper<Rect> {
  const _HeadClipper(this.head);

  final double head;

  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, head, size.height);

  @override
  bool shouldReclip(_HeadClipper oldClipper) => oldClipper.head != head;
}

/// حبّة المدّة: 38×19 بخطٍّ 0.4 ونصف قطر 9.5.
///
/// الملف يكتب «نصف قطر 15» على حبّةٍ ارتفاعها 19 — أي طرفان دائريان تماماً،
/// وهو 9.5 لا 15. نصفُ قطرٍ أكبر من نصف الارتفاع يصنع زوايا بيضوية.
class _DurationPill extends StatelessWidget {
  const _DurationPill({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38.w,
      height: 19.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9.5.r),
        border: Border.all(color: color, width: 0.4),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: ContactDesign.textTop(13, 9).h),
        child: DesignText(
          text,
          size: 9,
          family: 'Quicksand-Medium',
          color: color,
          center: true,
        ),
      ),
    );
  }
}

/// علامتا التسليم بلون الحبر — الخلفية هنا فاتحة لا فقاعة.
class _InkMark extends StatelessWidget {
  const _InkMark({required this.status});

  final BubbleStatus status;

  @override
  Widget build(BuildContext context) {
    return Text(
      status == BubbleStatus.sent ? '| ' : '|| ',
      style: TextStyle(
        fontFamily: 'Quicksand-Regular',
        fontSize: 9.sp,
        height: ContactDesign.lineBox(9) / 9,
        leadingDistribution: TextLeadingDistribution.even,
        fontWeight: FontWeight.bold,
        color: status == BubbleStatus.read
            ? ChatDesign.callBlue
            : ContactDesign.ink,
      ),
    );
  }
}

/// علامة الإيقاف: عمودان مستديران في صندوق التشغيل 30×30.
///
/// الملف يرسم علامة التشغيل وحدها، فهذه مبنيّةٌ من أجزائه.
class _PauseMark extends StatelessWidget {
  const _PauseMark({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30.w,
      height: 30.w,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _bar(),
            SizedBox(width: 4.w),
            _bar(),
          ],
        ),
      ),
    );
  }

  Widget _bar() => Container(
    width: 3.w,
    height: 12.h,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(1.5.r),
    ),
  );
}
