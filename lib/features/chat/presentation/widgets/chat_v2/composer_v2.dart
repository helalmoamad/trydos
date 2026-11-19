import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/features/chat/presentation/pages/conversation_design.dart';
import 'package:trydos/features/chat/presentation/pages/profile_page_design.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_v2/chat_icons_v2.dart';

/// مرفقٌ في قائمة «إرسال …».
enum ComposerAttachment { photo, voice, video, file, location }

/// ما يُعرض فوق الحقل: ردٌّ على رسالة، أو تعديلُ واحدة.
sealed class ComposerContext {
  const ComposerContext();
}

/// ردٌّ على رسالة.
class ComposerReply extends ComposerContext {
  const ComposerReply({required this.name, required this.text});

  final String name;
  final String text;
}

/// تعديل رسالة.
class ComposerEdit extends ComposerContext {
  const ComposerEdit({required this.text});

  final String text;
}

/// حالة تسجيلٍ جارٍ.
class ComposerRecording {
  const ComposerRecording({required this.elapsed, this.slide = 0});

  /// ما مضى من التسجيل — يُعرض ساعةً `00:00`.
  final Duration elapsed;

  /// ما سحبه الإصبع نحو البداية، بالبكسل. عند [ComposerV2.cancelSlide]
  /// يُلغى التسجيل.
  final double slide;

  /// `00:00` من المدّة.
  String get clock {
    final int m = elapsed.inMinutes;
    final int s = elapsed.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// شفافية «اسحب للإلغاء» — تتلاشى مع السحب.
  double get hintOpacity =>
      (1 - slide.abs() / ComposerV2.cancelSlide).clamp(0.0, 1.0);
}

/// حقل الكتابة في نهاية المحادثة.
///
/// منقولٌ من `web_design/components/DemoApp1/chat/Composer.tsx`. ولوحة XD لا
/// ترسم حقلاً، فهذا مبنيٌّ من أجزاء ألواح الدردشة نفسها كما فعل الويب:
///
/// > شريطٌ أبيض بظلّ الترويسة `0 0 3` أسود 10٪؛ والحقل ارتفاعه 38 بنصف قطر
/// > 12 ولون `#F8F8F8` ونصّه 14 Regular ونصّه الشبح `#8D8D8D` — وهو حقل
/// > البحث في اللوحة `– 41`، ويكبر إلى خمسة أسطر؛ وعلامة الجمع، والكاميرا
/// > داخل الحقل، وزرٌّ بنفسجي دائري في النهاية: ميكروفونٌ ما دام الحقل
/// > فارغاً، وسهمُ إرسالٍ متى صارت فيه حروف.
class ComposerV2 extends StatelessWidget {
  const ComposerV2({
    super.key,
    required this.controller,
    required this.hintText,
    required this.hasText,
    required this.isAttachOpen,
    required this.onToggleAttach,
    required this.onSend,
    required this.onMicHold,
    required this.onCamera,
    required this.onPickAttachment,
    required this.attachmentLabelOf,
    this.context,
    this.onCloseContext,
    this.recording,
    this.slideToCancelText = '',
  });

  final TextEditingController controller;
  final String hintText;

  /// في الحقل حروف: يتبدّل الميكروفون إلى سهم الإرسال.
  final bool hasText;

  final bool isAttachOpen;
  final VoidCallback onToggleAttach;
  final VoidCallback onSend;

  /// ضغطٌ مطوّل على الميكروفون — بدء تسجيل.
  final VoidCallback onMicHold;

  final VoidCallback onCamera;
  final ValueChanged<ComposerAttachment> onPickAttachment;
  final String Function(ComposerAttachment) attachmentLabelOf;

  /// الردّ أو التعديل المعروض فوق الحقل.
  final ComposerContext? context;
  final VoidCallback? onCloseContext;

  /// حالة التسجيل الجارية، أو `null` إن لم يكن هناك تسجيل.
  final ComposerRecording? recording;

  /// نصّ «اسحب للإلغاء».
  final String slideToCancelText;

  /// ارتفاع الشريط.
  static const double height = 54;

  /// أقلّ مدّة ثباتٍ على الميكروفون ليبدأ التسجيل.
  static const Duration minRecord = Duration(milliseconds: 600);

  /// المسافة التي يسحبها الإصبع نحو البداية لإلغاء التسجيل.
  static const double cancelSlide = 90;

  /// المهلة التي يُعطاها الهاتف ليجد موقع المستخدم.
  ///
  /// بلا مهلة يبقى الزرّ ينتظر إلى ما لا نهاية حين يتعذّر التحديد.
  static const Duration locateTimeout = Duration(seconds: 12);

  /// المرفقات بترتيب الملف.
  static const List<({ComposerAttachment value, String icon})> attachments = [
    (value: ComposerAttachment.photo, icon: 'chatSendPhoto'),
    (value: ComposerAttachment.voice, icon: 'chatSendVoice'),
    (value: ComposerAttachment.video, icon: 'chatSendVideo'),
    (value: ComposerAttachment.file, icon: 'chatSendFile'),
    (value: ComposerAttachment.location, icon: 'chatSendLocation'),
  ];

  @override
  Widget build(BuildContext buildContext) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: ChatDesign.headerShadow,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (context != null) _contextBar(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _plusButton(),
                  SizedBox(width: 4.w),
                  Expanded(child: _field()),
                  SizedBox(width: 8.w),
                  _sendButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// شريط الردّ أو التعديل فوق الحقل.
  ///
  /// كالاقتباس في المحادثة: فقاعةٌ بنفسجية حشوها 3 من جهة البداية، وداخلها
  /// `#EFEBFF`.
  Widget _contextBar() =>
      ComposerContextBarV2(data: context!, onClose: onCloseContext);

  /// علامة الجمع — تدور 45° حين تُفتح قائمة المرفقات فتصير ✕.
  Widget _plusButton() {
    return GestureDetector(
      onTap: onToggleAttach,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 38.w,
        height: 38.h,
        child: Center(
          child: AnimatedRotation(
            turns: isAttachOpen ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: ChatIconsV2.plus(color: ContactDesign.purple),
          ),
        ),
      ),
    );
  }

  /// الحقل نفسه، وفيه الكاميرا عند النهاية.
  Widget _field() {
    if (recording != null) return _recordingStrip();
    return Container(
      constraints: BoxConstraints(minHeight: 38.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: TextField(
                controller: controller,
                // يكبر إلى خمسة أسطر ثم يُمرَّر.
                minLines: 1,
                maxLines: 5,
                style: TextStyle(
                  fontFamily: 'Quicksand-Regular',
                  fontSize: 14.sp,
                  height: ContactDesign.lineBox(14) / 14,
                  leadingDistribution: TextLeadingDistribution.even,
                  color: ContactDesign.ink,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: hintText,
                  hintStyle: TextStyle(
                    fontFamily: 'Quicksand-Regular',
                    fontSize: 14.sp,
                    color: ContactDesign.grey,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                ),
              ),
            ),
          ),
          // الكاميرا تختفي متى صارت في الحقل حروف — الويب يوسّع الهامش
          // من 12 إلى 40 ليفرغ مكانها.
          if (!hasText)
            GestureDetector(
              onTap: onCamera,
              behavior: HitTestBehavior.opaque,
              child: Container(
                // 4 من النهاية و36×38، كما في الويب.
                margin: EdgeInsetsDirectional.only(end: 4.w),
                width: 36.w,
                height: 38.h,
                alignment: Alignment.center,
                child: ChatIconsV2.camera(color: ContactDesign.purple),
              ),
            ),
        ],
      ),
    );
  }

  /// شريط التسجيل: يحلّ محلّ الحقل أثناء تسجيل رسالة صوتية.
  ///
  Widget _recordingStrip() => RecordingStripV2(
    recording: recording!,
    slideToCancelText: slideToCancelText,
  );

  /// الزرّ البنفسجي: ميكروفون ما دام الحقل فارغاً، وسهمٌ متى امتلأ.
  ///
  /// يتبادلان بنفس دوران علامتَي التشغيل والإيقاف في الرسالة الصوتية.
  Widget _sendButton() {
    return GestureDetector(
      onTap: hasText ? onSend : null,
      onLongPress: hasText ? null : onMicHold,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 38.w,
        height: 38.h,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: ContactDesign.purple,
          shape: BoxShape.circle,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          transitionBuilder: (child, animation) => RotationTransition(
            turns: Tween<double>(begin: -0.25, end: 0).animate(animation),
            child: ScaleTransition(scale: animation, child: child),
          ),
          child: SizedBox(
            key: ValueKey<bool>(hasText),
            child: hasText
                ? ChatIconsV2.send(color: Colors.white)
                : ChatIconsV2.mic(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

/// شريط التسجيل: نقطةٌ حمراء تنبض، وساعة، و«‹ اسحب للإلغاء» تتلاشى مع السحب.
///
/// والشريط كلّه ينزاح مع الإصبع — `x: recording.slide` في الويب.
///
/// مفصولٌ عن [ComposerV2] ليستعمله حقلُ الكتابة الحقيقي: الأرقام هنا وحدها،
/// فلا تُنسخ في موضعين.
class RecordingStripV2 extends StatelessWidget {
  const RecordingStripV2({
    super.key,
    required this.recording,
    required this.slideToCancelText,
  });

  final ComposerRecording recording;
  final String slideToCancelText;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(recording.slide, 0),
      child: Container(
        height: 38.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            const _PulsingDot(color: ChatDesign.missedRed),
            SizedBox(width: 8.w),
            DesignText(recording.clock, size: 14, family: 'Quicksand-Regular'),
            const Spacer(),
            Opacity(
              opacity: recording.hintOpacity,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ChatIconsV2.chevronStart(color: ContactDesign.grey),
                  SizedBox(width: 2.w),
                  DesignText(
                    slideToCancelText,
                    size: 13,
                    family: 'Quicksand-Regular',
                    color: ContactDesign.grey,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// النقطة الحمراء التي تنبض أثناء التسجيل — دورة 1.1 ثانية بين 1 و0.25.
class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color});

  final Color color;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(
        begin: 1,
        end: 0.25,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: ChatIconsV2.recordDot(color: widget.color),
    );
  }
}

/// قائمة «إرسال …» التي تفتحها علامة الجمع.
///
/// في صندوق القائمة `#FAFAFA` نفسه، بأيقونات اللوحة `– 41`.
class ComposerAttachMenu extends StatelessWidget {
  const ComposerAttachMenu({
    super.key,
    required this.onPick,
    required this.labelOf,
  });

  final ValueChanged<ComposerAttachment> onPick;
  final String Function(ComposerAttachment) labelOf;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: ChatDesign.menu,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x29000000),
            offset: Offset(0, 2),
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in ComposerV2.attachments)
            GestureDetector(
              onTap: () => onPick(item.value),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    XdIcon(item.icon, width: 15, height: 15),
                    SizedBox(width: 10.w),
                    DesignText(
                      labelOf(item.value),
                      size: 13,
                      family: 'Quicksand-Medium',
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// حبّة الاقتباس فوق حقل الكتابة: ردٌّ على رسالة أو تعديلُ واحدة.
///
/// > فوق الحقل، حين يُردّ على رسالة أو تُعدَّل: حبّةُ الاقتباس — بنفسجيةٌ
/// > من خارج و`#EFEBFF` من داخل — فيها الاسم والحروف وعلامةُ إغلاق.
///
/// مفصولةٌ عن [ComposerV2] ليستعملها حقلُ الكتابة الحقيقي: الشريط الأخضر
/// 103 الذي كان فوق الحقل من التصميم القديم.
class ComposerContextBarV2 extends StatelessWidget {
  const ComposerContextBarV2({
    super.key,
    required this.data,
    required this.onClose,
  });

  final ComposerContext data;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final bool isEdit = data is ComposerEdit;
    final String title = isEdit ? '' : (data as ComposerReply).name;
    final String body = isEdit
        ? (data as ComposerEdit).text
        : (data as ComposerReply).text;

    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 0),
      child: Container(
        padding: EdgeInsetsDirectional.only(start: 3.w),
        decoration: BoxDecoration(
          color: ContactDesign.purple,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Container(
          padding: EdgeInsetsDirectional.only(
            start: 10.w,
            end: 8.w,
            top: 6.h,
            bottom: 6.h,
          ),
          decoration: BoxDecoration(
            color: ChatDesign.quote,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              if (isEdit)
                Padding(
                  padding: EdgeInsetsDirectional.only(end: 8.w),
                  child: const XdIcon('menuEdit', width: 15, height: 15),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title.isNotEmpty)
                      DesignText(
                        title,
                        size: 13,
                        family: 'Quicksand-Medium',
                        color: ContactDesign.purple,
                      ),
                    DesignText(
                      body,
                      size: 13,
                      family: 'Quicksand-Regular',
                      color: ContactDesign.grey,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onClose,
                behavior: HitTestBehavior.opaque,
                child: ChatIconsV2.close(color: ContactDesign.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
