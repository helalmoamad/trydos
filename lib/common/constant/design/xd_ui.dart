/// الودجات المشتركة بين شاشات التصميم الجديد — نقلٌ لـ
/// `web_design/components/DemoApp1/ui.tsx` و`DemoApp/ui.tsx`.
///
/// وأرقامُها في [Xd] و[XdHeader] و[XdRow].
library;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:trydos/generated/locale_keys.g.dart';

import 'xd_design.dart';
import 'xd_svg.dart';

/// مجلّد أيقونات الشاشات المشتركة تحت `assets/svg/`.
///
/// `back` وأيقونات الصفوف فيه، وهو مجلّد قسم الملفّ لأنّه أوّل من استعملها.
const String kXdSharedSvg = 'profile_v2';

/// لمسةٌ تُصغّر ما تحتها — `whileTap={{ scale }}` في framer-motion.
class XdTap extends StatefulWidget {
  const XdTap({
    super.key,
    required this.child,
    required this.scale,
    this.onTap,
  });

  final Widget child;
  final double scale;
  final VoidCallback? onTap;

  @override
  State<XdTap> createState() => _XdTapState();
}

class _XdTapState extends State<XdTap> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // الهدفُ صندوقُه كلُّه، لا ما رُسم فيه: بغيره تسقط اللمسةُ على فراغٍ
      // داخل الصندوق فلا تُحسب.
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// الترويسة التي لكلّ شاشةٍ داخليّة: شريطٌ أبيض 50 تحت شريط الحالة
/// — `ScreenHeader`.
///
/// ثلاثة أعمدة: سهم الرجوع في أوّلها، والعنوان موسَّطاً في وسطها، والإجراء
/// في آخرها. والعنوان موسَّطٌ على **الشاشة** لا على ما بقي منها، فيثبت موضعُه
/// سواءٌ أكان ثمّة إجراءٌ أم لا.
class XdScreenHeader extends StatelessWidget implements PreferredSizeWidget {
  const XdScreenHeader({
    super.key,
    this.title,
    this.crumb,
    this.crumbIcon,
    this.crumbIconW,
    this.action,
    this.onBack,
    this.onAction,
    this.shadow = false,
    this.small = false,
    this.nudge = 0,
  });

  /// عنوانٌ من كلمة: 16 Medium (أو 14 إن كان [small]).
  final String? title;

  /// «الملفّ | القسم»: الأوّل عاديّ والثاني Medium، كلاهما 14.
  final (String, String)? crumb;

  /// أيقونةٌ بعد الفتات، 4 بعده. ولها هامشٌ أيمن سالبٌ في الويب كي لا تُزيح
  /// الفتات عن مركزه — وهنا تُرسم فوقه بـ`Stack` للسبب نفسه.
  final String? crumbIcon;
  final double? crumbIconW;

  /// إجراء اليمين («إلغاء»، «تعديل»)، 16 Light، ينتهي 20 عن الحافّة.
  final String? action;

  final VoidCallback? onBack;
  final VoidCallback? onAction;

  final bool shadow;
  final bool small;

  /// يُزيح العنوان الموسَّط هذا القدر يميناً (أو يساراً إن كان سالباً) —
  /// `offCentre` في الويب، والملفّ يُوسّط بعض العناوين بالعين.
  final double nudge;

  @override
  Size get preferredSize => Size.fromHeight(XdHeader.height.h);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      height: XdHeader.height.h,
      decoration: BoxDecoration(
        color: XdColors.white,
        boxShadow: shadow
            ? <BoxShadow>[
                BoxShadow(color: const Color(0x1A000000), blurRadius: 3.r),
              ]
            : null,
      ),
      child: Stack(
        children: <Widget>[
          if (onBack != null)
            PositionedDirectional(
              start: 7.5.w,
              top: 0,
              bottom: 0,
              child: XdTap(
                scale: 1,
                onTap: onBack,
                child: SizedBox(
                  width: 44.w,
                  child: Center(
                    child: Semantics(
                      button: true,
                      label: LocaleKeys.back.tr(),
                      // سهمٌ له جهة: ينقلب رسمُه في العربيّة كما ينقلب موضعُه.
                      child: const XdSvg(
                        'back',
                        folder: kXdSharedSvg,
                        w: 12,
                        h: 21,
                        flipRtl: true,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Center(
            child: Padding(
              // التوسيط بإزاحةٍ: حشوةٌ على جانبٍ واحدٍ ضعفَ الإزاحة، كما
              // يفعل `offCentre`.
              padding: EdgeInsets.only(
                left: nudge > 0 ? (nudge * 2).w : 0,
                right: nudge < 0 ? (-nudge * 2).w : 0,
              ),
              child: _title(),
            ),
          ),
          if (action != null)
            PositionedDirectional(
              end: 20.w,
              top: 0,
              bottom: 0,
              child: Center(
                child: XdTap(
                  scale: 1,
                  onTap: onAction,
                  child: XdText(action!, size: 16, weight: XdWeight.light),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _title() {
    if (crumb != null) {
      final Widget text = Text.rich(
        TextSpan(
          children: <InlineSpan>[
            TextSpan(text: '${crumb!.$1} | ', style: xdTextStyle(size: 14)),
            TextSpan(
              text: crumb!.$2,
              style: xdTextStyle(size: 14, weight: XdWeight.medium),
            ),
          ],
        ),
        maxLines: 1,
        softWrap: false,
      );
      if (crumbIcon == null) return text;
      // الأيقونة بعد الفتات بـ4، ولا تدخل في حسابه: الويب يُلغي عرضها بهامشٍ
      // سالب كي يبقى الفتات موسَّطاً. وهنا تُرسم خارج الصفّ بـ`Stack`.
      return Stack(
        clipBehavior: Clip.none,
        alignment: AlignmentDirectional.centerStart,
        children: <Widget>[
          text,
          PositionedDirectional(
            end: -(4 + (crumbIconW ?? 0)).w,
            child: XdSvg(crumbIcon!, folder: kXdSharedSvg, w: crumbIconW ?? 14),
          ),
        ],
      );
    }
    if (title == null) return const SizedBox.shrink();
    return XdText(title!, size: small ? 14 : 16, weight: XdWeight.medium);
  }
}

/// صفحةٌ داخليّة: ترويسةٌ ثابتة وجسمٌ يُمرَّر — `ScreenPage`.
///
/// والمحتوى يبدأ تحت الترويسة مباشرةً ([kXdBodyY])؛ وشاشةُ تبويبٍ بلا ترويسة
/// تبدأ من [Xd.statusBar] وتُضيف غرفة الشريط السفليّ بنفسها.
class XdScreenPage extends StatelessWidget {
  const XdScreenPage({
    super.key,
    required this.child,
    this.header,
    this.bg = XdColors.white,
    this.footer,
    this.contentHeight,
  });

  final Widget child;
  final XdScreenHeader? header;
  final Color bg;

  /// ما يثبت أسفل الصفحة فوق الجسم — `PageFooter`.
  final Widget? footer;

  /// ارتفاع اللوح: الصفحة لا تقصر عنه.
  final double? contentHeight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      // الترويسة كتلةٌ في الجسم لا `Scaffold.appBar`.
      //
      // خانةُ `appBar` تُعطى ما يقوله `preferredSize` **دون** حشوة شريط
      // الحالة — و`AppBar` وحدَه يُضيفها من داخله. فترويسةٌ طولُها 50 كانت
      // تُرسم تحت شريط الحالة فتختفي كلُّها تقريباً. و`SafeArea` هنا تُنزل
      // الجسم كلَّه تحت الشريط، فتظهر الترويسة بطولها.
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            if (header != null) header!,
            Expanded(
              // ما يثبت أسفل الصفحة **يطفو** فوق المحتوى ولا يأخذ مساحته:
              // الويب يضعه `absolute`. وكان صفّاً في `Column` فيدفع منطقة
              // التمرير لأعلى — فتبقى فجوةٌ في الأسفل والزرُّ مخفيّ،
              // وتتبدّل المساحة كلّما ظهر.
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: SingleChildScrollView(
                      child: contentHeight == null
                          ? child
                          : ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: (contentHeight! - kXdBodyY).h,
                              ),
                              child: child,
                            ),
                    ),
                  ),
                  if (footer != null)
                    Positioned(left: 0, right: 0, bottom: 0, child: footer!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// صفُّ قائمة — `MenuRow`.
///
/// 406 × 60 بزاوية 15 ولون `#FCFCFC`، أيقونتُه على 12 من حافّته ونصُّه 14
/// على [textX] من حافّة الشاشة.
class XdMenuRow extends StatelessWidget {
  const XdMenuRow({
    super.key,
    required this.icon,
    required this.iconSize,
    required this.label,
    required this.textX,
    this.folder = kXdSharedSvg,
    this.mt = 0,
    this.onTap,
  });

  final String icon;

  /// 18 في قائمة تبويب الملفّ، و30 في الشاشات الداخليّة.
  final double iconSize;

  final String label;

  /// حيث يبدأ النصّ من حافّة الشاشة: 54 أو 66.
  final double textX;

  final String folder;

  /// الهامش فوق الصفّ، بوحدة اللوح.
  final double mt;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget tile = XdTap(
      onTap: onTap,
      scale: 0.985,
      child: Container(
        width: Xd.fill(XdRow.x),
        height: 60.h,
        decoration: BoxDecoration(
          color: XdColors.card,
          borderRadius: BorderRadius.circular(XdRow.radius.r),
        ),
        child: Row(
          children: <Widget>[
            SizedBox(width: 12.w),
            XdSvg(icon, folder: folder, w: iconSize),
            SizedBox(width: (textX - XdRow.x - 12 - iconSize).w),
            Expanded(
              child: XdText(label, size: 14, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
    // هامشٌ سالب: `Padding` في فلَتَر يرفضه، فيُرفع الصفّ بـ`Transform`.
    if (mt < 0) {
      return Padding(
        padding: EdgeInsetsDirectional.only(start: XdRow.x.w),
        child: Transform.translate(offset: Offset(0, mt.h), child: tile),
      );
    }
    return Padding(
      padding: EdgeInsetsDirectional.only(top: mt.h, start: XdRow.x.w),
      child: tile,
    );
  }
}

/// الشريط الرماديّ تحت الترويسة في نماذج الملفّ — `InfoBanner`.
///
/// بعرض الشاشة، 48 طولاً، لون `#F8F8F8` بخطّ `#D3D3D3`؛ أيقونةٌ 25 على
/// (11.5، 11.5)، والنصّ 11 `#8D8D8D` على x 48 بارتفاع سطرٍ 16، يُبقي 12 عن
/// الحافّة اليمنى.
class XdInfoBanner extends StatelessWidget {
  const XdInfoBanner({super.key, required this.text, this.purple = false});

  final String text;

  /// نسخةٌ بنفسجيّة لشاشاتٍ بصياغةٍ أخرى.
  final bool purple;

  @override
  Widget build(BuildContext context) {
    final String icon = purple ? 'infoBannerPurple' : 'infoBanner';
    final double iconW = purple ? 26 : 25;
    return Container(
      width: 1.sw,
      height: XdBanner.height.h,
      decoration: const BoxDecoration(
        color: XdColors.field,
        border: Border.fromBorderSide(
          BorderSide(color: XdColors.line, width: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsetsDirectional.only(start: 11.5.w, top: 11.5.h),
            child: XdSvg(
              icon,
              folder: kXdSharedSvg,
              w: iconW,
              h: purple ? 25.99 : 25,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                // النصّ على x 48 من الشاشة، والأيقونة تنتهي على 36.5.
                start: (48 - 11.5 - iconW).w,
                end: 12.w,
                top: (Xd.paraTop(119, 11, 16) - XdBanner.y).h,
              ),
              child: XdText(
                text,
                size: 11,
                color: XdColors.grey,
                height: 16,
                maxLines: null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// حقلٌ في نموذج — `Field`.
///
/// 406 × 55 بزاوية 15، عنوانُه 12 `#505050` على خطّ الأساس +20 وقيمتُه على
/// +43. خلفيّتُه بيضاء وهو قابلٌ للتحرير و`#FCFCFC` وهو للقراءة؛ وخطُّه أزرق
/// ما دام قيد الكتابة، وإلّا `#D3D3D3` — ولا يظهر إلّا وهو قيد الكتابة أو
/// التحرير أو إن طُلب.
class XdField extends StatelessWidget {
  const XdField({
    super.key,
    required this.label,
    required this.editing,
    required this.child,
    this.mt = 0,
    this.inUse = false,
    this.line = false,
    this.onTap,
  });

  final String label;
  final bool editing;
  final Widget child;
  final double mt;

  /// الحقل قيد الكتابة: خطُّه أزرق وعنوانه Medium.
  final bool inUse;

  /// أظهر الخطّ ولو لم يكن قيد التحرير.
  final bool line;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(top: mt.h, start: XdRow.x.w),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: Xd.fill(XdRow.x),
          height: 55.h,
          decoration: BoxDecoration(
            color: editing ? XdColors.white : XdColors.card,
            borderRadius: BorderRadius.circular(XdRow.radius.r),
          ),
          // الخطّ يُرسم **فوق** الحقل لا في إطاره.
          //
          // `BoxDecoration.border` يقتطع عرضَه من مساحة المحتوى، فكان الحقل
          // يضيق نصفَ بكسلٍ من كلّ جهةٍ لحظةَ ظهور الخطّ (عند «تعديل»)
          // فيفيض ما فيه. والويب يرسمه `Stroke` — طبقةً مطلقةً فوق الصندوق
          // لا تأخذ من داخله شيئاً.
          foregroundDecoration: (inUse || editing || line)
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(XdRow.radius.r),
                  border: Border.all(
                    color: inUse ? XdColors.blue : XdColors.line,
                    width: 0.5,
                  ),
                )
              : null,
          padding: EdgeInsetsDirectional.only(start: 12.w, end: 12.w, top: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              XdText(
                label,
                size: 12,
                color: XdColors.label,
                weight: inUse ? XdWeight.medium : XdWeight.regular,
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// سطر قيمة الحقل — `FieldInput`. 3 تحت العنوان، 23 طولاً، 14 بكسلاً.
class XdFieldInput extends StatelessWidget {
  const XdFieldInput({
    super.key,
    required this.controller,
    required this.editing,
    required this.placeholder,
    this.color = XdColors.ink,
    this.keyboardType,
    this.focusNode,
    this.onChanged,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final bool editing;
  final String placeholder;

  /// لون القيمة. الرماديّ لبريدٍ لم يُوثَّق بعد.
  final Color color;

  final TextInputType? keyboardType;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;

  /// تنقيةُ المُدخَل — ما يفعله الويب في `onChange` بـ`replace`.
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 3.h),
      child: SizedBox(
        height: 23.h,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          readOnly: !editing,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          style: xdTextStyle(size: 14, color: color),
          cursorColor: XdColors.blue,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.zero,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            hintText: placeholder,
            hintStyle: xdTextStyle(size: 14, color: XdColors.placeholder),
          ),
        ),
      ),
    );
  }
}

/// الزرّ العريض أسفل نموذج — `WideButton`.
///
/// 390 × 60 بزاوية 20، على 20 من الحافّتين و36 فوق الأسفل. يظهر منزلقاً من
/// تحته مع خبوٍّ في 0.3 ثانية.
class XdWideButton extends StatelessWidget {
  const XdWideButton({
    super.key,
    required this.label,
    required this.onTap,
    this.visible = true,
    this.disabled = false,
    this.fill = XdColors.purple,
    this.color = XdColors.white,
    this.weight = XdWeight.regular,
    this.busy = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool visible;

  /// مُطفأ: الصندوق نفسه في موضعه، رماديّاً `#C3C3C3` بكلماتٍ بيضاء، واللمسة
  /// لا تفعل شيئاً.
  final bool disabled;

  final Color fill;
  final Color color;
  final XdWeight weight;

  /// ينتظر طلباً: مؤشّرٌ مكان النصّ. لا وجود له في الويب — منطقُنا نحن.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: visible ? Offset.zero : const Offset(0, 0.5),
      duration: XdTransition.duration,
      curve: XdTransition.ease,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: XdTransition.duration,
        curve: XdTransition.ease,
        child: IgnorePointer(
          ignoring: !visible,
          child: Padding(
            padding: EdgeInsets.only(
              left: XdCta.x.w,
              right: XdCta.x.w,
              bottom:
                  (Xd.designH - (XdCta.y + XdCta.height)).h +
                  MediaQuery.paddingOf(context).bottom,
            ),
            child: XdTap(
              scale: disabled ? 1 : 0.98,
              onTap: disabled || busy ? null : onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                height: XdCta.height.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: disabled ? XdColors.hint : fill,
                  borderRadius: BorderRadius.circular(XdCta.radius.r),
                ),
                child: busy
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      )
                    : XdText(
                        label,
                        size: 16,
                        weight: weight,
                        color: disabled ? XdColors.white : color,
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// نافذةٌ سفليّة تصعد من y من اللوح — `Sheet`.
///
/// بزاوية [XdSheet.radius] (30) ومقبضٍ 40 × 2 على 12 من أعلاها، وخلفها
/// عتمةٌ تُغلقها اللمسةُ عليها. وتُوضع في `Stack` فوق الصفحة.
class XdSheetLayer extends StatefulWidget {
  const XdSheetLayer({
    super.key,
    required this.open,
    required this.y,
    required this.onClose,
    required this.child,
    this.radius = XdSheet.radius,
    this.lower = 0,
    this.outline,
    this.shadow,
  });

  final bool open;

  /// أعلى النافذة على اللوح (932): 539 لنافذة الدول، و451 للأماكن.
  final double y;

  final VoidCallback onClose;
  final Widget child;
  final double radius;

  /// كم تستقرّ النافذةُ **أخفضَ** من [y] — `lower` في `Sheet`.
  ///
  /// نافذةٌ ذاتُ خطواتٍ تُوضع على y خطوتها الأعلى، وتهبط ما بين y الخطوة
  /// المعروضة وy الوضع. فحين تتبدّل الخطوة تصعد النافذةُ أو تهبط بانزلاق
  /// الملفّ نفسه. والويبُ يُبقي طولَها ويُدلّي ما زاد تحت الشاشة؛ وهنا
  /// يُطرَح الهبوطُ من الطول، فالمنظرُ واحدٌ ومنطقةُ المحتوى صحيحةٌ.
  final double lower;

  /// خطٌّ 0.5 داخل حافّة النافذة — نافذةُ قواعد الأمان (`Home Page – 39`).
  final Color? outline;

  /// ظلٌّ على حافّتها العليا — نافذةُ طلب الدخول (`Sign In request`): ظلٌّ
  /// `0 -3 10` بعشرة في المئة. وسائرُ النوافذ بلا ظلّ.
  final List<BoxShadow>? shadow;

  @override
  State<XdSheetLayer> createState() => _XdSheetLayerState();
}

class _XdSheetLayerState extends State<XdSheetLayer>
    with SingleTickerProviderStateMixin {
  /// دخولُ النافذة وخروجُها: 0 مخفيّةٌ و1 مستقرّة.
  late final AnimationController _enter = AnimationController(
    duration: XdTransition.duration,
    vsync: this,
    value: widget.open ? 1 : 0,
  );

  /// ما سحبه الإصبعُ من المقبض إلى أسفل، بالبكسل.
  double _raw = 0;
  bool _dragging = false;

  /// والنافذةُ تتبع الإصبعَ بستّة أعشار ما سحب — `dragElastic` في الملفّ.
  double get _shown => _raw * XdSheet.dragFollow;

  @override
  void didUpdateWidget(XdSheetLayer old) {
    super.didUpdateWidget(old);
    if (widget.open == old.open) return;
    if (widget.open) {
      _raw = 0;
      _dragging = false;
      _enter.forward();
    } else {
      _enter.reverse();
    }
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  void _dragUpdate(DragUpdateDetails d) {
    setState(() {
      _dragging = true;
      // لا تصعد فوق موضعها: `dragElastic.top = 0`.
      _raw = (_raw + d.delta.dy).clamp(0, double.infinity);
    });
  }

  void _dragEnd(DragEndDetails d) {
    final double v = d.velocity.pixelsPerSecond.dy;
    if (_raw > XdSheet.dragClose.h || v > XdSheet.dragFling) {
      setState(() => _dragging = false);
      widget.onClose();
      return;
    }
    setState(() {
      _dragging = false;
      _raw = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _enter,
      builder: (BuildContext context, Widget? _) {
        // خرجت وانتهت حركتُها: لا شيءَ يُرسم.
        if (!widget.open && _enter.value == 0) return const SizedBox.shrink();
        return Positioned.fill(
          child: Stack(
            children: <Widget>[
              // `Positioned.fill` لازمة: صندوقٌ ملوَّنٌ بلا طفلٍ في `Stack`
              // يأخذ أصغرَ ما تسمح به القيود — صفراً، فلا عتمةَ ولا لمسة.
              Positioned.fill(
                child: GestureDetector(
                  onTap: widget.onClose,
                  child: ColoredBox(
                    color: XdColors.backdrop.withValues(
                      alpha: XdColors.backdrop.a * _enter.value,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: FractionalTranslation(
                  translation: Offset(0, 1 - _enter.value),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: _shown),
                    // تتبع الإصبعَ بلا حركةٍ، وترتدّ إلى موضعها بحركة الملفّ.
                    duration: _dragging ? Duration.zero : XdTransition.duration,
                    curve: XdTransition.ease,
                    builder:
                        (BuildContext context, double drag, Widget? sheet) =>
                            Transform.translate(
                              offset: Offset(0, drag),
                              child: sheet,
                            ),
                    child: _sheet(context),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sheet(BuildContext context) {
    // داخلَ `Material` شفّافة: النصُّ خارجَ `Material` يُرسم بنمط التحذير —
    // خطٌّ أصفرُ مزدوجٌ تحته. وهذه الطبقةُ تُوضع **فوق** `Scaffold` لا تحته،
    // فلا تجد واحدةً.
    return Material(
      type: MaterialType.transparency,
      child: AnimatedContainer(
        width: 1.sw,
        // ما بين y واللوح ناقصاً الهبوط، زائداً الحافّة الآمنة. وهي مُسنَدةٌ
        // إلى الأسفل، فتبدّلُ الطول يُصعِد حافّتَها العليا أو يُنزلها بانزلاق
        // الملفّ نفسه.
        duration: XdTransition.duration,
        curve: XdTransition.ease,
        height:
            (Xd.designH - widget.y - widget.lower).h +
            MediaQuery.paddingOf(context).bottom,
        foregroundDecoration: widget.outline == null
            ? null
            : BoxDecoration(
                // خطٌّ داخل الحافّة لا يأكل من المحتوى.
                border: Border.all(color: widget.outline!, width: 0.5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(widget.radius.r),
                  topRight: Radius.circular(widget.radius.r),
                ),
              ),
        decoration: BoxDecoration(
          color: XdColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(widget.radius.r),
            topRight: Radius.circular(widget.radius.r),
          ),
          boxShadow: widget.shadow,
        ),
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // المقبض: الملفُّ يرسمه خطّاً 40 × 2 بطرفين مستديرين، فصندوقُه
                // 42 × 2 على 11 من الأعلى — فينتهي 13 تحت الحافّة، وعليه
                // تُحسب هوامشُ أوّل كتلةٍ في كلّ لوح.
                Padding(
                  padding: EdgeInsets.only(top: XdSheet.handleBoxTop.h),
                  child: Center(
                    child: Container(
                      width: XdSheet.handleBoxWidth.w,
                      height: XdSheet.handleHeight.h,
                      decoration: BoxDecoration(
                        color: XdSheet.handleColor,
                        borderRadius: BorderRadius.circular(
                          XdSheet.handleHeight.r / 2,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(child: widget.child),
              ],
            ),
            // شريطُ السحب في أعلى النافذة، يُغلقها سحبُه إلى أسفل — `grip`
            // في `Sheet`. و`translucent` تُمرّر اللمساتَ والسحبَ الأفقيَّ إلى
            // ما تحته، فلا يحجب عنواناً ولا زرّاً.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: XdSheet.gripHeight.h,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onVerticalDragUpdate: _dragUpdate,
                onVerticalDragEnd: _dragEnd,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// بطاقة «لماذا تُضيف عنواناً؟» — `WhyCard`.
///
/// تُرسم في شاشة العناوين الفارغة وفي شاشة الصورة. والملفّ يُمرّر لهما
/// العنوان والفقرة نفسيهما، فهما الافتراض هنا.
///
/// 124 طولاً على 20 من الحافّتين، بزاوية 15 ولون `#FCFCFC`: العنوان 11
/// Medium على (24، 12)، وإكسٌ صغيرة في هدفٍ 30 أعلى اليمين، والفقرة 11
/// بارتفاع سطرٍ 16، وزرُّ «اعرف المزيد» 38 طولاً أسفلها.
class XdWhyCard extends StatelessWidget {
  const XdWhyCard({super.key, required this.onClose, this.title, this.body});

  final VoidCallback onClose;

  /// أوّل سطرٍ في البطاقة. غيابُه يعني عنوان الملفّ: «لماذا تُضيف عنواناً؟».
  final String? title;

  /// الفقرة. غيابُها يعني فقرة الملفّ.
  final String? body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        height: 124.h,
        decoration: BoxDecoration(
          color: XdColors.card,
          borderRadius: BorderRadius.circular(XdRow.radius.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // صفُّ العنوان: ارتفاعه ارتفاعُ العنوان (12 + صندوق سطره) لا
            // ارتفاعُ زرّ الإغلاق.
            //
            // الويب يسحب الزرّ بهامشٍ سفليٍّ سالب (`marginBottom: -8`) كي لا
            // يُطيل الصفّ: صندوقه 4 .. 34 وصفُّ العنوان 12 .. 26. و`Stack`
            // بـ`Clip.none` يفعل ذلك: الصفّ 26، والزرُّ يفيض عنه ثمانيةً
            // ولا يُحسب.
            SizedBox(
              height: (12 + Xd.lineBox(11)).h,
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  PositionedDirectional(
                    top: 12.h,
                    start: 24.w,
                    child: XdText(
                      title ?? LocaleKeys.why_add_a_address.tr(),
                      size: 11,
                      weight: XdWeight.medium,
                    ),
                  ),
                  PositionedDirectional(
                    top: 4.h,
                    end: 4.w,
                    child: Semantics(
                      button: true,
                      label: LocaleKeys.close.tr(),
                      child: XdTap(
                        scale: 0.9,
                        onTap: onClose,
                        child: Padding(
                          padding: EdgeInsets.all(8.w),
                          child: const XdSvg(
                            'closeSmall',
                            folder: kXdSharedSvg,
                            w: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // الفقرة تأخذ ما بقي: ترجمةٌ أطول من الإنجليزيّة لا تُفيض
            // البطاقة بل تُقَصّ بـ«…».
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.only(
                  // الفقرة على y 43 من البطاقة، وصفُّ العنوان ينتهي على 26.
                  top: (Xd.paraTop(43, 11, 16) - 26).h,
                  start: 24.w,
                  end: 12.w,
                ),
                child: XdText(
                  body ?? LocaleKeys.accurate_address_details.tr(),
                  size: 11,
                  height: 16,
                  maxLines: null,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.only(
                bottom: 12.h,
                start: 12.w,
                end: 12.w,
              ),
              child: XdTap(
                scale: 0.98,
                child: Container(
                  height: 38.h,
                  decoration: BoxDecoration(
                    color: XdColors.field,
                    borderRadius: BorderRadius.circular(XdRow.radius.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // صندوق `help.svg` يبدأ نصفَ بكسلٍ يسارَ الأيقونة
                      // وأعلاها، فيحلّ على (166، 785.5).
                      Transform.translate(
                        offset: Offset(0, -0.5.h),
                        child: const XdSvg(
                          'help',
                          folder: kXdSharedSvg,
                          w: 14.99,
                          h: 15,
                        ),
                      ),
                      SizedBox(width: 5.w),
                      XdText(
                        LocaleKeys.learn_more.tr(),
                        size: 11,
                        weight: XdWeight.medium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
