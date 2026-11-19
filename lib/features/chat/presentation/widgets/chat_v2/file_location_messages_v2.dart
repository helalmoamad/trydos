import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/features/chat/presentation/pages/conversation_design.dart';
import 'package:trydos/features/chat/presentation/pages/profile_page_design.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_v2/chat_bubble_v2.dart';

/// رسالة ملف.
///
/// منقولةٌ بالبكسل من `chat/messages.tsx` على فرع `development`:
///
/// > شكل بطاقة المكالمة (50 ارتفاعاً، زوايا الفقاعة، البطاقة الرمادية) مع
/// > علامة الورقة في صندوق 40×42، واسم الملف 13 Medium في سطر، وتحته حجمه
/// > ونوعه 11 Regular، والوقت (وعلاماتي) في الطرف البعيد.
class FileMessageV2 extends StatelessWidget {
  const FileMessageV2({
    super.key,
    required this.name,
    required this.sizeText,
    required this.time,
    required this.isMine,
    this.status,
    this.onTap,
  });

  final String name;

  /// حجم الملف مكتوباً — «2.4 MB».
  final String sizeText;

  final String time;
  final bool isMine;
  final BubbleStatus? status;
  final VoidCallback? onTap;

  /// عرض البطاقة في الملف.
  static const double width = 260;
  static const double height = 50;

  /// نوع الملف من امتداد اسمه: «report.pdf» ← «PDF».
  ///
  /// خمسة أحرفٍ على الأكثر، فامتدادٌ طويل لا يكسر السطر.
  static String kindOf(String fileName) {
    final int dot = fileName.lastIndexOf('.');
    if (dot <= 0) return '';
    final String ext = fileName.substring(dot + 1);
    return ext.substring(0, ext.length > 5 ? 5 : ext.length).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final bool inn = !isMine;

    final Widget box = Container(
      width: 40.w,
      height: 42.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: inn ? ChatDesign.incomingIconBox : ChatDesign.outgoingIconBox,
        borderRadius: inn ? ChatDesign.iconBoxIn : ChatDesign.iconBoxOut,
      ),
      child: const XdIcon('chatSendFile', width: 18, height: 18),
    );

    final Widget column = Padding(
      padding: EdgeInsetsDirectional.only(
        start: inn ? 8.w : 4.w,
        end: inn ? 4.w : 8.w,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          DesignText(name, size: 13, family: 'Quicksand-Medium'),
          Row(
            children: [
              Expanded(
                child: DesignText(
                  // الحجم قد يغيب (ملفٌّ لم ينزل بعد)، فلا يُترك فراغه
                  // قبل النوع.
                  '$sizeText${sizeText.isEmpty ? '' : '  '}${kindOf(name)}',
                  size: 11,
                  family: 'Quicksand-Regular',
                  color: ContactDesign.inkSoft,
                  letterSpacing: ChatDesign.inLetterSpacing,
                ),
              ),
              SizedBox(width: 10.w),
              // خطّ أساس الوقت 40 لا 39 كخطّ السطر بجانبه — فرقُ بكسل
              // مقصودٌ في الملف.
              Padding(
                padding: EdgeInsets.only(
                  top:
                      (ContactDesign.textTop(40, 9) -
                              ContactDesign.textTop(39, 11))
                          .h,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!inn && status != null) _InkMark(status: status!),
                    DesignText(time, size: 9, family: 'Quicksand-Regular'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsetsDirectional.only(
          start: inn ? 3.w : 0,
          end: inn ? 0 : 3.w,
        ),
        width: width.w,
        constraints: BoxConstraints(minHeight: height.h),
        // حشوٌ غير متناظر: 9 من جهة الكلمات و4 من جهة الصندوق.
        padding: EdgeInsetsDirectional.fromSTEB(
          inn ? 4.w : 9.w,
          4.h,
          inn ? 9.w : 4.w,
          0,
        ),
        decoration: BoxDecoration(
          color: ChatDesign.callCard,
          borderRadius: inn ? ChatDesign.inRadius : ChatDesign.outRadius,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: TextDirection.ltr,
          children: inn
              ? [box, Expanded(child: column)]
              : [Expanded(child: column), box],
        ),
      ),
    );
  }
}

/// رسالة فيديو.
///
/// > إطار 300×225 بزوايا الفقاعة وخطٍّ بلون المرسِل، كالصورة. في وسطه قرصٌ
/// > أبيض فيه علامة تشغيل الرسالة الصوتية؛ والمدّة «00:12» في حبّةٍ داكنة
/// > أسفل اليسار، وعلى المرسَلة العلامتان والوقت أسفل اليمين كالصورة.
class VideoMessageV2 extends StatelessWidget {
  const VideoMessageV2({
    super.key,
    required this.preview,
    required this.durationText,
    required this.time,
    required this.isMine,
    required this.isPlaying,
    required this.onTogglePlay,
    this.status,
  });

  /// اللقطة الأولى أو المشغّل — يُبنى خارجاً.
  final Widget preview;

  /// المدّة `00:12`.
  final String durationText;

  final String time;
  final bool isMine;
  final bool isPlaying;
  final VoidCallback onTogglePlay;
  final BubbleStatus? status;

  static const double width = 300;
  static const double height = 225;

  @override
  Widget build(BuildContext context) {
    final bool inn = !isMine;
    final BorderRadius radius = inn
        ? ChatDesign.inRadius
        : ChatDesign.outRadius;

    return GestureDetector(
      onTap: onTogglePlay,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsetsDirectional.only(
          start: inn ? 3.w : 0,
          end: inn ? 0 : 3.w,
        ),
        width: width.w,
        height: height.h,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: radius),
        foregroundDecoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(
            color: inn ? ContactDesign.purple : ChatDesign.sent,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            preview,

            // قرص التشغيل 56 في الوسط — يختفي أثناء التشغيل.
            if (!isPlaying)
              Center(
                child: Container(
                  width: 56.w,
                  height: 56.w,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  // علامة التشغيل مزاحةٌ 3 إلى اليمين: مثلّثٌ مركزه
                  // البصري ليس مركزه الهندسي.
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(start: 3.w),
                    child: XdIcon(
                      inn ? 'playPurple' : 'playMagenta',
                      width: 30,
                      height: 30,
                    ),
                  ),
                ),
              ),

            // المدّة أسفل البداية — على الواردة والمرسَلة معاً، وتغيب حين
            // لا يعرف الخادم مدّة الفيديو.
            if (durationText.isNotEmpty)
              PositionedDirectional(
                start: 14.w,
                bottom: 8.h,
                child: _DarkPill(child: _white(durationText)),
              ),

            // الوقت أسفل النهاية — على المرسَلة وحدها.
            if (!inn)
              PositionedDirectional(
                end: 14.w,
                bottom: 8.h,
                child: _DarkPill(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (status != null) _WhiteMark(status: status!),
                      _white(time),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _white(String text) => DesignText(
    text,
    size: 9,
    family: 'Quicksand-Regular',
    color: Colors.white,
  );
}

/// حبّةٌ داكنة شفّافة فوق صورة أو فيديو.
class _DarkPill extends StatelessWidget {
  const _DarkPill({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: const Color(0x59000000),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: child,
    );
  }
}

/// رسالة موقع.
///
/// > خريطةٌ 300×160 بزوايا الفقاعة وخطٍّ بلون المرسِل، وعليها علامة الموضع؛
/// > ونقرةٌ تفتحها في الخرائط.
///
/// الخريطة نفسها تُمرَّر من الخارج: الويب يرسمها بلوحاتٍ من خادم خرائط،
/// وعندنا تأتي صورةً ثابتة أو خريطةً حيّة بحسب ما يقرّره المستدعي.
class LocationMessageV2 extends StatelessWidget {
  const LocationMessageV2({
    super.key,
    required this.map,
    required this.time,
    required this.isMine,
    this.status,
    this.onTap,
  });

  /// الخريطة — تُبنى خارجاً.
  final Widget map;
  final String time;
  final bool isMine;
  final BubbleStatus? status;
  final VoidCallback? onTap;

  static const double width = 300;
  static const double height = 160;

  @override
  Widget build(BuildContext context) {
    final bool inn = !isMine;
    final BorderRadius radius = inn
        ? ChatDesign.inRadius
        : ChatDesign.outRadius;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsetsDirectional.only(
          start: inn ? 3.w : 0,
          end: inn ? 0 : 3.w,
        ),
        width: width.w,
        height: height.h,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: radius),
        foregroundDecoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(
            color: inn ? ContactDesign.purple : ChatDesign.sent,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            map,
            // الوقت على الموقع المرسَل وحده، كالصورة.
            if (!inn)
              PositionedDirectional(
                end: 14.w,
                bottom: 8.h,
                child: _DarkPill(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (status != null) _WhiteMark(status: status!),
                      DesignText(
                        time,
                        size: 9,
                        family: 'Quicksand-Regular',
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// علامتا التسليم بلون الحبر — على خلفيةٍ فاتحة.
class _InkMark extends StatelessWidget {
  const _InkMark({required this.status});

  final BubbleStatus status;

  @override
  Widget build(BuildContext context) => _mark(
    status,
    status == BubbleStatus.read ? ChatDesign.callBlue : ContactDesign.ink,
  );
}

/// علامتا التسليم بيضاء — فوق صورة أو خريطة.
class _WhiteMark extends StatelessWidget {
  const _WhiteMark({required this.status});

  final BubbleStatus status;

  @override
  Widget build(BuildContext context) => _mark(
    status,
    status == BubbleStatus.read ? ChatDesign.callBlue : Colors.white,
  );
}

Widget _mark(BubbleStatus status, Color color) {
  return Text(
    status == BubbleStatus.sent ? '| ' : '|| ',
    style: TextStyle(
      fontFamily: 'Quicksand-Regular',
      fontSize: 9.sp,
      height: ContactDesign.lineBox(9) / 9,
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.bold,
      color: color,
    ),
  );
}
