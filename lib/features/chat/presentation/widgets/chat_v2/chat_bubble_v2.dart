// `Bidi` من `intl` — به يُعرَف اتجاه حروف الرسالة من محتواها.
import 'package:intl/intl.dart' show Bidi;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/features/chat/presentation/pages/conversation_design.dart';
import 'package:trydos/features/chat/presentation/pages/profile_page_design.dart';

/// حالة تسليم الرسالة، كما يرسمها الملف.
enum BubbleStatus {
  /// علامة واحدة بيضاء.
  sent,

  /// علامتان بيضاوان.
  delivered,

  /// علامتان زرقاوان.
  read,
}

/// فقاعة رسالة نصّية بالتصميم الجديد.
///
/// منقولةٌ بالبكسل من `chat/messages.tsx` (لوحة XD `Home Page – 44`):
///
/// > الواردة فقاعة `#4A31E7` من x=12 بزوايا `2/50/2/30` ونقطة 4 عند x=5؛
/// > والمرسَلة `#8D00E5` تنتهي عند x=418 بزوايا `50/2/30/2` ونقطتها
/// > `#883BF2` عند x=421. الحروف 13 Regular بيضاء على أسطر 18، وأول خطّ
/// > أساس 21 تحت أعلى الفقاعة؛ والوقت 9 Regular على خطّ أساس 10 فوق أسفلها.
class ChatBubbleV2 extends StatelessWidget {
  const ChatBubbleV2({
    super.key,
    required this.text,
    required this.time,
    required this.isMine,
    this.status,
    this.isReplied = false,
    this.isEdited = false,
    this.isForwarded = false,
    this.editedLabel = '',
    this.forwardedLabel = '',
  });

  final String text;
  final String time;

  /// أرسلتُها أنا — تغيّر اللون والزوايا وجهة الوقت.
  final bool isMine;

  /// حالة التسليم. للمرسَلة وحدها.
  final BubbleStatus? status;

  /// عليها علامة ردّ بيضاء قبل الوقت (آخر رسالة في اللوحة).
  final bool isReplied;

  final bool isEdited;
  final bool isForwarded;
  final String editedLabel;
  final String forwardedLabel;

  static const String _regular = 'Quicksand-Regular';

  @override
  Widget build(BuildContext context) {
    final bool inn = !isMine;

    return Container(
      // جهاتٌ مطلقة لا اتجاهية: الصفّ يرسم رسائلي يميناً والواردة يساراً في
      // كل اللغات، و`Row.textDirection` لا يمسّ `Directionality` للأبناء —
      // فحشوٌ اتجاهيّ هنا كان ينقلب في العربية وحدها.
      margin: EdgeInsets.only(left: inn ? 3.w : 0, right: inn ? 0 : 3.w),
      // الحشو غير متناظر في الملف: المرسَلة 13 من جهة البداية لا 12.
      padding: EdgeInsets.fromLTRB(inn ? 12.w : 13.w, 7.h, 12.w, 8.h),
      decoration: BoxDecoration(
        color: inn ? ChatDesign.inBubble : ChatDesign.sent,
        borderRadius: inn ? ChatDesign.inRadius : ChatDesign.outRadius,
      ),
      // `IntrinsicWidth` ضروريّ ولا بديل عنه هنا.
      //
      // سطر الوقت يُحاذى إلى جهةٍ غير جهة الحروف، وهذا في Flutter يحتاج
      // `Align` — و`Align` **تتمدّد إلى كامل العرض المتاح** ما لم تُقيَّد.
      // فكانت الفقاعة تمتدّ عرض الشاشة مهما قصر نصّها.
      //
      // `IntrinsicWidth` تجعل عرض العمود عرضَ أعرض أبنائه الطبيعي، فتحاذي
      // `Align` داخله لا داخل الشاشة.
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isForwarded)
              Padding(
                padding: EdgeInsets.only(left: inn ? 0 : 30.w, bottom: 2.h),
                child: Opacity(
                  opacity: 0.8,
                  child: Text(
                    forwardedLabel,
                    style: TextStyle(
                      fontFamily: _regular,
                      fontSize: 9.sp,
                      height: ContactDesign.lineBox(9) / 9,
                      leadingDistribution: TextLeadingDistribution.even,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

            // الفراغ بعد الحروف الواردة (أو قبل المرسَلة) حيث يتركه الملف:
            // 22 بعد الواردة — و37 على الرسالة ذات الردّ — و30 قبل المرسَلة.
            Padding(
              padding: EdgeInsets.only(
                right: inn ? (isReplied ? 37.w : 22.w) : 0,
                left: inn ? 0 : 30.w,
              ),
              // اتجاه الحروف من محتواها لا من لغة التطبيق: رسالةٌ عربية
              // تُحاذى يميناً وإن كانت الواجهة إنجليزية، والعكس — كما تفعل
              // واتساب. وهندسةُ الفقاعة حولها مثبَّتةٌ على LTR في
              // `MessageRowV2`، فلا تتأثّر بهذا.
              child: Text(
                text,
                textDirection: Bidi.detectRtlDirectionality(text)
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                style: TextStyle(
                  fontFamily: _regular,
                  fontSize: 13.sp,
                  height: 18 / 13,
                  leadingDistribution: TextLeadingDistribution.even,
                  // الملف يباعد حروف الواردة وحدها.
                  letterSpacing: inn ? ChatDesign.inLetterSpacing : null,
                  color: Colors.white,
                ),
              ),
            ),

            // سطر الوقت: في نهاية الواردة وبداية المرسَلة.
            Align(
              alignment: inn ? Alignment.centerRight : Alignment.centerLeft,
              // هامش سالب بواحد: الملف يرفع سطر الوقت بكسلاً فوق موضعه
              // الطبيعي، فيقترب من الحروف فوقه.
              child: Transform.translate(
                offset: Offset(0, -1.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (inn && isReplied) ...[
                      const XdIcon('replyMarkWhite', width: 11, height: 11),
                      SizedBox(width: 4.w),
                    ],
                    if (!inn && status != null) _Mark(status: status!),
                    if (isEdited)
                      Opacity(opacity: 0.8, child: _Caption('$editedLabel ')),
                    _Caption(time),
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

/// نصّ 9 Regular أبيض — الوقت وما يجاوره.
class _Caption extends StatelessWidget {
  const _Caption(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: ChatBubbleV2._regular,
        fontSize: 9.sp,
        height: ContactDesign.lineBox(9) / 9,
        leadingDistribution: TextLeadingDistribution.even,
        color: Colors.white,
      ),
    );
  }
}

/// علامتا التسليم قبل وقت الرسالة المرسَلة.
///
/// الملف يرسم `||` عريضتين بالأزرق على كل رسالة (كلّها مقروءة)؛ وفي الطريق
/// إليه تظهر واحدة بيضاء ثم اثنتان، كما تفعل صفوف المحادثات.
class _Mark extends StatelessWidget {
  const _Mark({required this.status});

  final BubbleStatus status;

  @override
  Widget build(BuildContext context) {
    return Text(
      status == BubbleStatus.sent ? '| ' : '|| ',
      style: TextStyle(
        fontFamily: ChatBubbleV2._regular,
        fontSize: 9.sp,
        height: ContactDesign.lineBox(9) / 9,
        leadingDistribution: TextLeadingDistribution.even,
        fontWeight: FontWeight.bold,
        color: status == BubbleStatus.read ? ChatDesign.callBlue : Colors.white,
      ),
    );
  }
}

/// النقطة الصغيرة بجانب الفقاعة — 4 بكسل.
class BubbleDot extends StatelessWidget {
  const BubbleDot({super.key, required this.isMine});

  final bool isMine;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: isMine ? 0 : 5.w, right: isMine ? 5.w : 0),
      width: 4.w,
      height: 4.w,
      decoration: BoxDecoration(
        color: isMine ? ChatDesign.sentDot : ContactDesign.purple,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// حبّة التاريخ بين أيام المحادثة.
///
/// 74 عرضاً أدنى، 22 ارتفاعاً، نصف قطر 15، خلفية `#F4F4F4`، ونصّها 11 على
/// خطّ أساس 15.
class ChatDayPill extends StatelessWidget {
  const ChatDayPill({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: 74.w),
      height: 22.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: ChatDesign.callCard,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: ContactDesign.textTop(15, 11).h),
        child: DesignText(
          label,
          size: 11,
          family: ChatBubbleV2._regular,
          center: true,
          letterSpacing: 11 * 0.01,
        ),
      ),
    );
  }
}
