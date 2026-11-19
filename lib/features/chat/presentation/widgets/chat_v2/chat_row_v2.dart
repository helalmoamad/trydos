import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/features/chat/presentation/pages/chat_list_design.dart';
import 'package:trydos/features/chat/presentation/pages/profile_page_design.dart';

/// علامة تسليم آخر رسالةٍ أرسلتُها، تتصدّر معاينة الصفّ.
///
/// > المعاينة تبدأ بـ`|` ثخينة (أُرسلت، والمعاينة رمادية)، أو `||` (وصلت)،
/// > أو `||` زرقاء (قُرئت).
enum ChatRowMarkV2 { sent, delivered, read }

/// سطرٌ من أسطر «أرسِل …» التي يعرضها صفٌّ لا رسالة فيه بعد.
typedef ChatSendLineV2 = ({String icon, String label});

/// وجه صفّ المحادثة بالتصميم الجديد.
///
/// منقولٌ بالبكسل من `ChatRowFace` في
/// `web_design/components/DemoApp1/screens/ChatListScreen.tsx` على فرع
/// `development` (لوح XD `Home Page – 41`):
///
/// > صفٌّ 430×100 أبيض بخطٍّ 0.3 `#D3D3D3`؛ وصفُّ المحادثة المفتوحة بخطٍّ
/// > 0.5 `#4A31E7` وشريطٍ بنفسجيّ 4 على حافّته اليسرى. الصورة 66×76 عند
/// > (12، 12) بنصف قطر 15؛ والاسم 14 Medium عند x=90 على خطّ الأساس 26؛
/// > والوقت 11 Medium `#8D8D8D` ينتهي قبل الحافّة اليمنى بـ13 على خطّ
/// > الأساس 23؛ والمعاينة 12 Regular بأسطر 17، عرضها 295 من x=90، أوّل خطّ
/// > أساسٍ لها 46، وسطران على الأكثر.
/// >
/// > ثم يرسم كلُّ صفٍّ شيئاً واحداً زائداً:
/// >
/// > * عدّاد غير المقروء «1» (`#7756E9`، 11 Medium، خطّ الأساس 84) وعلامةُ
/// >   الظرف المفتوح 11×14 عند (407، 73)؛
/// > * علامة الكتابة 14×14 عند (90، 74) و«Typing…» 11 `#388CFF` عند x=108
/// >   على خطّ الأساس 85 — «Typing» Regular والنقاط Bold؛
/// > * «Send Photo» بعلامتها 15 عند (90، 36)، ومن x=227 أسطرُ الصوت والفيديو
/// >   والملفّ والموقع متباعدةً 19 من y=12 — حتى تصير للمحادثة رسالةٌ تُعايَن؛
/// > * وصفٌّ مثبَّت يُظهر الدبّوس 10×14 عند (406، 74).
///
/// شكلٌ خالص: لا يعرف بلوكاً ولا نموذجَ محادثة — الشاشةُ الحاضنة تقرأ كلَّ
/// شيءٍ من حالتها وتمرّره، كما تفعل مع بقيّة ودجات `chat_v2`.
class ChatRowFaceV2 extends StatelessWidget {
  const ChatRowFaceV2({
    super.key,
    required this.name,
    required this.time,
    required this.preview,
    required this.photo,
    this.initials,
    this.selected = false,
    this.pinned = false,
    this.muted = false,
    this.typing = false,
    this.typingLabel = '',
    this.unread = 0,
    this.mark,
    this.sendLines = const [],
    this.previewIcon,
  });

  final String name;
  final String time;

  /// سطرا المعاينة. تُهمَل حين تكون [sendLines] غير فارغة.
  final String preview;

  /// صورة المحادث — تُبنى خارجاً لأن مصدرها يخصّ الشاشة الحاضنة.
  final Widget photo;

  /// حرفان بدل الصورة حين لا صورة له.
  final String? initials;

  /// المحادثة المفتوحة آخرَ مرّة: الخطّ البنفسجي والشريط.
  final bool selected;

  final bool pinned;
  final bool muted;

  final bool typing;

  /// «يكتب…» بلغة التطبيق. النقاط تُرسم ثخينةً كما في الملف.
  final String typingLabel;

  final int unread;
  final ChatRowMarkV2? mark;

  /// علامةٌ 15 قبل كلمات المعاينة حين تكون آخرُ رسالةٍ وسيطاً — صورةً أو
  /// فيديو أو ملفّاً أو صوتاً أو موقعاً.
  ///
  /// الملف يرسم هذه العلامات في أسطر «أرسِل …» لمحادثةٍ فارغة، وعيّنتُه
  /// نصوصٌ كلُّها فلا معاينةَ وسيطٍ فيها. وقرّر المالك أن تحمل المعاينة
  /// علامةَ نوعها أيضاً، فهي علاماتُ الملف نفسها في موضعٍ ثانٍ.
  final String? previewIcon;

  /// أسطر «أرسِل …» بدل المعاينة. الأوّل يقع تحت الاسم والبقيّة في عمودٍ
  /// ثانٍ من x=227، كما يفعل الملف.
  final List<ChatSendLineV2> sendLines;

  // خطوط الأساس محسوبةٌ مرّةً هنا، فكلُّ حشوٍ أدناه فرقٌ بين اثنين منها.
  static double get _nameTop => ContactDesign.textTop(26, 14);
  static double get _nameBottom => _nameTop + ContactDesign.lineBox(14);
  static double get _previewTop => ContactDesign.paraTop(
    ChatListDesign.previewBaseline,
    ChatListDesign.previewSize,
    ChatListDesign.previewLine,
  );
  static double get _previewBottom =>
      _previewTop + ChatListDesign.previewLines * ChatListDesign.previewLine;

  @override
  Widget build(BuildContext context) {
    // اتجاهٌ مثبَّت: الصورة قبل الكلمات في كل اللغات، كما في الملف — وهو
    // إنجليزيٌّ وحده فأرقامُه مطلقة (`marginLeft`، `right`).
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        height: ChatListDesign.rowHeight.h,
        color: ChatListDesign.white,
        // الخطّ فوق المحتوى لا تحته، وداخل الصندوق — `align: "inside"`.
        foregroundDecoration: BoxDecoration(
          border: Border.all(
            color: selected ? ChatListDesign.purple : ChatListDesign.line,
            width: selected
                ? ChatListDesign.rowLineOpen
                : ChatListDesign.rowLine,
          ),
        ),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: ChatListDesign.photoX.w,
                    top: ChatListDesign.photoY.h,
                  ),
                  child: RowPhotoV2(
                    width: ChatListDesign.photoW,
                    height: ChatListDesign.photoH,
                    initials: initials,
                    line: selected ? ChatListDesign.purple : null,
                    child: photo,
                  ),
                ),
                Expanded(
                  child: sendLines.isNotEmpty ? _sendColumns() : _textColumn(),
                ),
              ],
            ),

            // شريط الصفّ المفتوح على حافّته اليسرى.
            if (selected)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: ChatListDesign.selectedBar.w,
                  color: ChatListDesign.purple,
                ),
              ),

            // الدبّوس عند (416، 74) — أي 14 من الحافّة اليمنى.
            if (pinned)
              Positioned(
                right: (430 - 416).w,
                top: 74.h,
                child: const XdIcon('chatPinned', width: 10, height: 14),
              ),
          ],
        ),
      ),
    );
  }

  /// العمود المعتاد: الاسم والوقت، ثم سطرا المعاينة، ثم زائدةُ الصفّ.
  Widget _textColumn() {
    return Padding(
      padding: EdgeInsets.only(left: 12.w, top: _nameTop.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            // الوقت في نهاية السطر لا ملاصقاً للاسم — `ml-auto` في الملف.
            //
            // و`spaceBetween` لا `Spacer`: الاسم `Flexible` بالفعل، فإضافةُ
            // مرنٍ ثانٍ تجعل الاثنين يقتسمان العرض نصفين — فيُقصّ اسمٌ قصير
            // بلا سبب.
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: DesignText(name, size: 14, family: 'Quicksand-Medium'),
              ),
              RowTimeV2(time: time, muted: muted),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              top: (_previewTop - _nameBottom).h,
              right: ChatListDesign.previewRight.w,
            ),
            child: _preview(),
          ),
          if (unread > 0)
            Padding(
              // «1» على خطّ الأساس 84 — أي أعلى صندوقها 73.
              padding: EdgeInsets.only(top: (73 - _previewBottom).h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  DesignText(
                    '$unread',
                    size: 11,
                    family: 'Quicksand-Medium',
                    color: ChatListDesign.unreadCount,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 2.w, right: 12.w),
                    child: const XdIcon(
                      'chatUnreadMark',
                      width: 11,
                      height: 14,
                    ),
                  ),
                ],
              ),
            ),
          if (typing)
            Padding(
              padding: EdgeInsets.only(top: (74 - _previewBottom).h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const XdIcon('chatTyping', width: 14, height: 14),
                  Padding(
                    // العلامة عند 90 وعرضُها 14، والكلمات عند 108.
                    padding: EdgeInsets.only(left: (108 - 104).w),
                    child: _typingText(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// المعاينة: علامةُ التسليم ثخينةً ثم الكلمات، سطران يُقصّان بلا «…».
  Widget _preview() {
    final Color inkColor = mark == ChatRowMarkV2.sent
        ? ChatListDesign.grey
        : ChatListDesign.ink;
    final TextStyle base = TextStyle(
      fontFamily: 'Quicksand-Regular',
      fontSize: ChatListDesign.previewSize.sp,
      height: ChatListDesign.previewLine / ChatListDesign.previewSize,
      leadingDistribution: TextLeadingDistribution.even,
      color: inkColor,
    );

    return Text.rich(
      TextSpan(
        children: [
          if (mark != null)
            TextSpan(
              text: mark == ChatRowMarkV2.sent ? '|' : '||',
              style: base.copyWith(
                fontFamily: 'Quicksand-Bold',
                fontWeight: FontWeight.bold,
                color: mark == ChatRowMarkV2.read
                    ? ChatListDesign.read
                    : ChatListDesign.ink,
              ),
            ),
          if (previewIcon != null) ...[
            if (mark != null) const TextSpan(text: ' '),
            // داخل الفقرة لا قبلها: المعاينة سطران يلتفّان، وعلامةٌ خارجها
            // تبقى في السطر الأول وحدها فينكسر الالتفاف.
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: EdgeInsets.only(right: 4.w),
                child: XdIcon(previewIcon!, width: 15, height: 15),
              ),
            ),
            TextSpan(text: preview),
          ] else
            TextSpan(text: mark != null ? ' $preview' : preview),
        ],
      ),
      style: base,
      maxLines: ChatListDesign.previewLines,
      // الملف يقصّ السطرين بلا نقاط.
      overflow: TextOverflow.clip,
    );
  }

  /// «يكتب» عاديةً ونقاطُها ثخينة، كما يفصلهما الملف.
  Widget _typingText() {
    final TextStyle base = TextStyle(
      fontFamily: 'Quicksand-Regular',
      fontSize: 11.sp,
      height: ContactDesign.lineBox(11) / 11,
      leadingDistribution: TextLeadingDistribution.even,
      color: ChatListDesign.typing,
    );
    // النقاط الثلاث تُفصل عن الكلمة أيّاً كانت لغتها.
    final String word = typingLabel.replaceAll(RegExp(r'[.…]+$'), '');
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: word),
          TextSpan(
            text: '…',
            style: base.copyWith(
              fontFamily: 'Quicksand-Bold',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      style: base,
      maxLines: 1,
    );
  }

  /// صفُّ محادثةٍ لا رسالة فيها بعد: أسطر «أرسِل …» في عمودين.
  Widget _sendColumns() {
    final ChatSendLineV2 first = sendLines.first;
    final List<ChatSendLineV2> rest = sendLines.skip(1).toList();

    return Padding(
      padding: EdgeInsets.only(left: 12.w, top: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العمود الأيسر 137: من x=90 إلى الأيقونات عند 227.
          SizedBox(
            width: (227 - 90).w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                DesignText(name, size: 14, family: 'Quicksand-Medium'),
                SendLineV2(
                  icon: first.icon,
                  label: first.label,
                  top: 36 - (12 + ContactDesign.lineBox(14)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < rest.length; i++)
                SendLineV2(
                  icon: rest[i].icon,
                  label: rest[i].label,
                  top: i == 0 ? 0 : 4,
                ),
            ],
          ),
          // وكذلك هنا: الوقت في نهاية السطر بعد عمودَي «أرسِل …».
          const Spacer(),
          RowTimeV2(time: time, muted: muted),
        ],
      ),
    );
  }
}

/// صورة الصفّ: `width`×`height` بنصف قطر 15، وخطٌّ حولها حين يطلبه الصفّ.
class RowPhotoV2 extends StatelessWidget {
  const RowPhotoV2({
    super.key,
    required this.width,
    required this.height,
    required this.child,
    this.initials,
    this.line,
  });

  final double width;
  final double height;

  /// الصورة نفسها — تُهمَل حين تكون [initials] موجودة.
  final Widget child;

  /// حرفان في صندوقٍ رماديّ بدل الصورة.
  final String? initials;

  /// لون الخطّ حول الصورة، أو `null` فلا خطّ.
  final Color? line;

  @override
  Widget build(BuildContext context) {
    final String? letters = initials;
    return Container(
      width: width.w,
      height: height.h,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: letters != null ? ChatListDesign.field : null,
        borderRadius: BorderRadius.circular(ChatListDesign.photoRadius.r),
      ),
      // الخطّ فوق الصورة لا تحتها — وإلّا قُصّ عند الزوايا.
      foregroundDecoration: line == null
          ? null
          : BoxDecoration(
              borderRadius: BorderRadius.circular(ChatListDesign.photoRadius.r),
              border: Border.all(color: line!),
            ),
      child: letters == null
          ? child
          // «MW» 14 Medium على خطّ الأساس 43 من صندوق 76، موسَّطة.
          : Padding(
              padding: EdgeInsets.only(top: ContactDesign.textTop(43, 14).h),
              child: DesignText(
                letters,
                size: 14,
                family: 'Quicksand-Medium',
                center: true,
              ),
            ),
    );
  }
}

/// وقت الصفّ: 11 Medium رماديّ في نهايته، وقبله علامةُ الكتم إن كان مكتوماً.
class RowTimeV2 extends StatelessWidget {
  const RowTimeV2({
    super.key,
    required this.time,
    this.right = ChatListDesign.timeRight,
    this.top = 0,
    this.muted = false,
  });

  final String time;

  /// بُعدُه عن حافّة الصفّ: 13 في صفّ المحادثة و12 في صفّ المكالمة.
  final double right;

  final double top;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: top.h, right: right.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (muted)
            Padding(
              padding: EdgeInsets.only(top: 1.h, right: 4.w),
              child: const Opacity(
                opacity: 0.55,
                child: XdIcon('swipeMute', width: 12, height: 12),
              ),
            ),
          DesignText(
            time,
            size: 11,
            family: 'Quicksand-Medium',
            color: ChatListDesign.grey,
          ),
        ],
      ),
    );
  }
}

/// سطر «أرسِل …»: أيقونةٌ 15 وكلمةٌ 12 بعدها بـ4.
class SendLineV2 extends StatelessWidget {
  const SendLineV2({
    super.key,
    required this.icon,
    required this.label,
    required this.top,
  });

  final String icon;
  final String label;
  final double top;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: top.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          XdIcon(icon, width: 15, height: 15),
          Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: DesignText(
              label,
              size: 12,
              family: 'Quicksand-Regular',
              color: ChatListDesign.inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}
