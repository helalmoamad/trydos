// `Bidi` من `intl` — به يُعرَف اتجاه الحروف المقتبسة من محتواها.
import 'package:intl/intl.dart' show Bidi;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/features/chat/presentation/pages/conversation_design.dart';
import 'package:trydos/features/chat/presentation/pages/profile_page_design.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_v2/chat_bubble_v2.dart';

/// بقية أنواع الرسائل بالتصميم الجديد: الصورة، الاقتباس، الملاحظة، وبطاقة
/// المكالمة.
///
/// منقولةٌ بالبكسل من `web_design/components/DemoApp1/chat/messages.tsx`
/// (لوحة XD `Home Page – 44`).

/// صورةٌ صغيرة 25×25 بنصف قطر 12 وخطٍّ أبيض حولها.
class SmallChatPhoto extends StatelessWidget {
  const SmallChatPhoto({
    super.key,
    required this.image,
    required this.lineWidth,
  });

  final Widget image;

  /// سماكة الخطّ الأبيض — الملف يرسمه 1 حول صورة المحادث و0.5 حول صورتي.
  final double lineWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 25.w,
      height: 25.w,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r)),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white, width: lineWidth),
      ),
      child: image,
    );
  }
}

/// صفّ الصورتين أعلى جسم المحادثة، عند y=104.
///
/// > صورة كل طرف 25×25 بنصف قطر 12، ومعها نقطة 6 على بعد 4 من حافّة
/// > الشاشة: بنفسجية في جهة المحادث، و`#8D00E5` في جهتي.
class ChatSidePhotosRow extends StatelessWidget {
  const ChatSidePhotosRow({
    super.key,
    required this.contactPhoto,
    required this.myPhoto,
  });

  final Widget contactPhoto;
  final Widget myPhoto;

  @override
  Widget build(BuildContext context) {
    // اتجاهٌ مثبَّت: صورة المحادث في جهة رسائله — يساراً في كل اللغات —
    // وصورتي في جهة رسائلي. ولولا التثبيت لانقلبت الصورتان في العربية
    // بينما تبقى الرسائل في مكانها.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: EdgeInsets.only(top: 4.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dot(ContactDesign.purple, start: 4, top: 10),
            Padding(
              padding: EdgeInsetsDirectional.only(start: 2.w),
              child: SmallChatPhoto(image: contactPhoto, lineWidth: 1),
            ),
            const Spacer(),
            SmallChatPhoto(image: myPhoto, lineWidth: 0.5),
            _dot(ChatDesign.sent, start: 2, end: 4, top: 10),
          ],
        ),
      ),
    );
  }

  /// نقطة 6 — أكبر من نقطة الفقاعة التي هي 4.
  Widget _dot(Color color, {double start = 0, double end = 0, double top = 0}) {
    return Container(
      margin: EdgeInsetsDirectional.only(
        start: start.w,
        end: end.w,
        top: top.h,
      ),
      width: 6.w,
      height: 6.w,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// رسالة صورة: 300×300 بزوايا الفقاعة وخطٍّ 1 بلون المرسِل.
///
/// > المرسَلة صورةٌ معكوسة، وعليها الوقت وعلامتا التسليم.
class PhotoMessageV2 extends StatelessWidget {
  const PhotoMessageV2({
    super.key,
    required this.image,
    required this.time,
    required this.isMine,
    this.status,
  });

  /// الصورة نفسها — تُبنى خارجاً لأن مصدرها يخصّ الشاشة الحاضنة.
  final Widget image;
  final String time;
  final bool isMine;
  final BubbleStatus? status;

  @override
  Widget build(BuildContext context) {
    final bool inn = !isMine;
    final BorderRadius radius = inn
        ? ChatDesign.inRadius
        : ChatDesign.outRadius;

    return Container(
      margin: EdgeInsetsDirectional.only(
        start: inn ? 3.w : 0,
        end: inn ? 0 : 3.w,
      ),
      width: 300.w,
      height: 300.w,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: radius),
      // الخطّ فوق الصورة لا تحتها، وإلّا قُصّ عند الزوايا.
      foregroundDecoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: inn ? ContactDesign.purple : ChatDesign.sent),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          image,
          // الوقت على الصورة المرسَلة وحدها: 14 من النهاية و8 من الأسفل.
          if (!inn)
            PositionedDirectional(
              end: 14.w,
              bottom: 8.h,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: const Color(0x59000000),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (status != null) PhotoTimeMark(status: status!),
                    PhotoTimeText(time),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// نصّ الوقت فوق الصورة — 9 Regular أبيض.
class PhotoTimeText extends StatelessWidget {
  const PhotoTimeText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Quicksand-Regular',
        fontSize: 9.sp,
        height: ContactDesign.lineBox(9) / 9,
        leadingDistribution: TextLeadingDistribution.even,
        color: Colors.white,
      ),
    );
  }
}

/// علامتا التسليم فوق الصورة.
class PhotoTimeMark extends StatelessWidget {
  const PhotoTimeMark({super.key, required this.status});

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
        color: status == BubbleStatus.read ? ChatDesign.callBlue : Colors.white,
      ),
    );
  }
}

/// الرسالة المقتبسة فوق ردّ.
///
/// > فقاعة بنفسجية 297×43 من x=121، داخلها من 3 بكسل لونه `#EFEBFF`؛
/// > الحروف المقتبسة 13 Regular بلون `#8D8D8D` على بعد 9، وعلامة الردّ
/// > والوقت في النهاية. والنقطة البنفسجية عند x=114 قبلها.
class QuotedMessageV2 extends StatelessWidget {
  const QuotedMessageV2({
    super.key,
    required this.text,
    required this.time,
    this.onOpen,
  });

  final String text;
  final String time;

  /// نقرةٌ على الفقاعة تقفز إلى الرسالة المقتبسة، كما تفعل واتساب.
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    // اتجاهٌ مثبَّت على الاقتباس كلّه، لا على صفّه وحده.
    //
    // الاقتباس يُرسم **شقيقاً** للصفّ لا داخله، فلا يصله تثبيتُ
    // `MessageRowV2`. و`Row.textDirection` كان يُرتّب أبناءه ولا يمنع
    // هامشَ الفقاعة (3 من جهةٍ و12 من الأخرى) من الانقلاب في العربية.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const BubbleDot(isMine: false),
          GestureDetector(
            onTap: onOpen,
            behavior: HitTestBehavior.opaque,
            child: Container(
              margin: EdgeInsetsDirectional.only(start: 3.w, end: 12.w),
              // من x=121 إلى 12 قبل الحافّة المقابلة.
              width: (430 - 121 - 12).w,
              height: 43.h,
              // الحدّ البنفسجي 3 بكسل من جهة البداية وحدها — يرسمه الملف بحشوٍ
              // على فقاعةٍ بنفسجية، لا بإطار.
              padding: EdgeInsetsDirectional.only(start: 3.w),
              decoration: const BoxDecoration(
                color: ContactDesign.purple,
                borderRadius: ChatDesign.inRadius,
              ),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  color: ChatDesign.quote,
                  borderRadius: ChatDesign.inRadius,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.only(
                        start: 9.w,
                        end: 12.w,
                        top: ContactDesign.textTop(21, 13).h,
                      ),
                      // اتجاه الحروف المقتبسة من محتواها، كحروف الفقاعة.
                      child: Directionality(
                        textDirection: Bidi.detectRtlDirectionality(text)
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        child: DesignText(
                          text,
                          size: 13,
                          family: 'Quicksand-Regular',
                          color: ContactDesign.grey,
                          letterSpacing: ChatDesign.inLetterSpacing,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: EdgeInsetsDirectional.only(end: 12.w),
                      child: Row(
                        // `max` لا `min`: الملف يضع علامة الردّ والوقت **في
                        // النهاية** (*the reply mark and the time at the
                        // right*). و`min` تجعل الصفَّ يحتضن ابنَيه فلا يبقى
                        // لـ`mainAxisAlignment.end` ما تُزيحه — فيستقرّان في
                        // بداية الفقاعة. والفقاعة عرضُها معلوم (297)، فالصفّ
                        // يملؤه ويُزيحهما إلى طرفه.
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.only(
                              top: 1.h,
                              end: 2.w,
                            ),
                            child: const XdIcon(
                              'replyQuoteMark',
                              width: 11,
                              height: 9,
                            ),
                          ),
                          DesignText(
                            time,
                            size: 9,
                            family: 'Quicksand-Regular',
                            color: ContactDesign.grey,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// الملاحظة تحت مكالمة فائتة: من x=60 بلون البطاقة الأحمر الباهت، بلا وقت.
class ChatNoteV2 extends StatelessWidget {
  const ChatNoteV2({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsetsDirectional.only(start: 60.w),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: const BoxDecoration(
            color: ChatDesign.missedCard,
            borderRadius: ChatDesign.inRadius,
          ),
          child: DesignText(text, size: 13, family: 'Quicksand-Regular'),
        ),
      ],
    );
  }
}

/// نوع بطاقة المكالمة — يحدّد الأيقونة ولون صندوقها.
enum CallCardTone { missed, incoming, outgoing }

/// بطاقة مكالمة.
///
/// > ارتفاعها 50 بزوايا الفقاعة، وصندوق 40×42 على بعد 4 بزوايا `2/30/2/30`
/// > وفي وسطه هاتف 18؛ والعنوان 13 Medium بعد الصندوق بـ4 على خطّ أساس 21،
/// > والسطر الثاني 11 Regular تحته على 39، والوقت 9 Regular على 40 وعلى بعد
/// > 9 من الحافّة البعيدة.
class CallCardV2 extends StatelessWidget {
  const CallCardV2({
    super.key,
    required this.tone,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isMine,
    this.status,
  });

  final CallCardTone tone;
  final String title;
  final String subtitle;
  final String time;
  final bool isMine;
  final BubbleStatus? status;

  Color get _boxColor => switch (tone) {
    CallCardTone.missed => ChatDesign.missedIconBox,
    CallCardTone.incoming => ChatDesign.incomingIconBox,
    CallCardTone.outgoing => ChatDesign.outgoingIconBox,
  };

  Color get _cardColor =>
      tone == CallCardTone.missed ? ChatDesign.missedCard : ChatDesign.callCard;

  String get _icon => switch (tone) {
    CallCardTone.missed => 'callMissed',
    CallCardTone.incoming => 'callIncoming',
    CallCardTone.outgoing => 'callOutgoing',
  };

  double get _iconSize => tone == CallCardTone.incoming ? 15 : 18;

  /// العنوان الفرعي: يأخذ ما بقي من السطر ويتوسّطه — `grow text-center`.
  ///
  /// وبه يُدفع الوقتُ إلى أقصى الزاوية بدل أن يلتصق بالكلمات. و`Expanded`
  /// هنا لا تمدّ البطاقة لأن `IntrinsicWidth` أدناه تحدّ عرضَ العمود بأعرض
  /// سطرَيه قبل أن يراه هذا الصفّ.
  Widget _sub(String text) => Expanded(
    child: DesignText(
      text,
      size: 11,
      family: 'Quicksand-Regular',
      center: true,
    ),
  );

  /// الوقت على خطّ الأساس 40 بينما السطر على 39 — فينزل بالفرق.
  Widget _timeAt(Widget timeText) => Padding(
    padding: EdgeInsets.only(
      top: (ContactDesign.textTop(40, 9) - ContactDesign.textTop(39, 11)).h,
    ),
    child: timeText,
  );

  @override
  Widget build(BuildContext context) {
    final bool inn = !isMine;

    final Widget box = Container(
      width: 40.w,
      height: 42.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _boxColor,
        borderRadius: inn ? ChatDesign.iconBoxIn : ChatDesign.iconBoxOut,
      ),
      child: XdIcon(_icon, width: _iconSize, height: _iconSize),
    );

    // الوقت — ومعه علامتا التسليم في المرسَلة — على **السطر الثاني** مع
    // العنوان الفرعي، في الزاوية السفلية البعيدة عن الصندوق.
    //
    // وكان على السطر الأول مع العنوان، وهو خطأ: الملف يضعه على خطّ الأساس 40
    // أي مع السطر الثاني (39)، لا مع العنوان (21).
    final Widget timeText = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!inn && status != null) _CardMark(status: status!),
        DesignText(time, size: 9, family: 'Quicksand-Regular'),
      ],
    );

    // نسخةٌ خفيّة منه على السطر الأول — `className="invisible"` في الملف.
    //
    // ليست زينة: هي تحجز للعنوان عرضاً يساوي ما يحجزه الوقتُ تحته، فيستقرّ
    // العنوان في مكانه نفسه سواءٌ أكانت البطاقة واردةً أم مرسَلة، ولا يزحف
    // مع طول الوقت («12:56 | 3 Ring» أطول من «12:56»).
    final Widget ghost = Opacity(opacity: 0, child: timeText);

    final Widget column = Padding(
      // جهاتٌ مطلقة لا اتجاهية: البطاقة تتبع جهة الرسالة لا جهة اللغة —
      // وكانت `EdgeInsetsDirectional` تقلب حشوَها في العربية.
      padding: EdgeInsets.only(
        left: inn ? 4.w : 0,
        right: inn ? 0 : 4.w,
        top: (ContactDesign.textTop(21, 13) - 4).h,
      ),
      // `IntrinsicWidth` ولا بديل عنها هنا.
      //
      // الملف يعرف عرضَ البطاقة سلفاً (`width: m.width` لكل رسالة)، فيملأ
      // العنوانُ الفرعي ما بقي منه ويُدفع الوقتُ إلى أقصى الزاوية. وعرضُنا
      // يتبع المحتوى، فلا عرضَ معلوماً تُقاس منه «البقية».
      //
      // و`IntrinsicWidth` تجعل عرض العمود عرضَ أعرض سطرَيه، ثم `stretch`
      // تمدّ السطر الأقصر إليه — فيجد `Expanded` فراغاً يملؤه ويُزيح الوقت
      // إلى الحافّة. وبلا `IntrinsicWidth` تأخذ `stretch` أقصى عرضٍ متاح
      // فتمتدّ البطاقة عرضَ الشاشة.
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              textDirection: TextDirection.ltr,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: inn
                  ? [
                      Flexible(
                        child: DesignText(
                          title,
                          size: 13,
                          family: 'Quicksand-Medium',
                        ),
                      ),
                      ghost,
                    ]
                  : [
                      ghost,
                      SizedBox(width: 4.w),
                      Flexible(
                        child: DesignText(
                          title,
                          size: 13,
                          family: 'Quicksand-Medium',
                        ),
                      ),
                    ],
            ),
            Padding(
              padding: EdgeInsets.only(
                top:
                    (ContactDesign.textTop(39, 11) -
                            ContactDesign.textBottom(21, 13))
                        .h,
              ),
              child: Row(
                textDirection: TextDirection.ltr,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: inn
                    ? [_sub(subtitle), _timeAt(timeText)]
                    : [_timeAt(timeText), SizedBox(width: 4.w), _sub(subtitle)],
              ),
            ),
          ],
        ),
      ),
    );

    return Container(
      // أدنى ارتفاع لا ارتفاعٌ ثابت.
      //
      // الملف يرسمها 50، لكنّ `.h` تقيس بالارتفاع و`.sp` تقيس الخطّ بنسبةٍ
      // أخرى — فعلى جهازٍ نسبته مختلفة يتجاوز المحتوى الصندوقَ بكسراتٍ من
      // البكسل. وهذا ما أعطى `BOTTOM OVERFLOWED BY 0.779 PIXELS`.
      constraints: BoxConstraints(
        minHeight: 50.h,
        // سقفُ عرضها في الملف: `calc(100% - 20px)`. وبلا سقفٍ كان عنوانٌ
        // طويل يمدّها إلى حافّة الشاشة.
        maxWidth: (430 - 20).w,
      ),
      // حشوٌ غير متناظر كما في الملف: `4px 9px 0 4px` للواردة و`4px 4px 0 9px`
      // للمرسَلة. وجهاتٌ مطلقة لا اتجاهية — البطاقة تتبع جهة الرسالة لا
      // جهة اللغة، وكانت `EdgeInsetsDirectional` تقلبها في العربية.
      //
      // وأسفلُها 4 لا صفر: الملف يثبّت الارتفاع 50 فيستقرّ النصّ بخطوط
      // الأساس وحدها، ونحن نقيس بـ`minHeight` لأن `.h` و`.sp` لا تتّفقان —
      // فبلا حشوٍ أسفل يلامس السطرُ الثاني حافّةَ البطاقة.
      padding: EdgeInsets.fromLTRB(inn ? 4.w : 9.w, 4.h, inn ? 9.w : 4.w, 4.h),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: inn ? ChatDesign.inRadius : ChatDesign.outRadius,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        // الصندوق قبل العمود في الواردة وبعده في المرسَلة — جهةٌ مطلقة
        // كجهة الفقاعة.
        textDirection: TextDirection.ltr,
        children: inn
            ? [box, Flexible(child: column)]
            : [Flexible(child: column), box],
      ),
    );
  }
}

/// علامتا التسليم داخل بطاقة المكالمة — بلون البطاقة لا بالأبيض.
class _CardMark extends StatelessWidget {
  const _CardMark({required this.status});

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
