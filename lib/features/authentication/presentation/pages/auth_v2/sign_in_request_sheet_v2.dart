/// نافذةُ طلب الدخول — نقلٌ لـ`SignInRequestSheet.tsx` و`SignInSlides.tsx`
/// في `web_design/components/DemoApp1/screens/`؛ لوح `Sign In request`.
///
/// > «تُفتح بعد أربع ثوانٍ من فتح التطبيق من منتقي الدولة. فتعتم الصفحةُ إلى
/// > `#1D1D1D` بتسعين في المئة، وتصعد نافذةٌ بيضاءُ من 285 بنصف قطر 50 على
/// > زاويتيها العلويّتين وظلٍّ `0 -3 10` بعشرة في المئة. ومن أعلى:
/// >   - المقبضُ 40×2 على 297 (مقبضُ كلّ نافذة)؛
/// >   - الشعارُ كلُّه داكنٌ، 150×150 على (140، 327)؛
/// >   - سطران في المنتصف 14، قاعدتاهما 521 و541: «ابدأ من هنا» Medium،
/// >     و«مزيدُ المعلومات» `#388CFF`؛
/// >   - بطاقةٌ بيضاءُ 390×186 على (20، 565) بنصف قطر 20 وخطٍّ 0.5 بنفسجيّ،
/// >     ونقاطُ الصفحات على 761. والملفُّ يترك البطاقةَ فارغةً؛ وهي تحمل
/// >     شرائحَ المعاينة سلايدراً؛
/// >   - «ابدأ» 390×60 على (20، 789)؛
/// >   - «لاحقاً، ألقِ نظرةً على التطبيق» 14 `#4D84FF` على 893، وتحتها
/// >     أبيضُ إلى طرف اللوح.»
///
/// والويبُ يُعطي البطاقةَ `flexShrink` ويحدُّها بـ[SignInXd.cardMin]، لأنّ
/// بكسلَه ثابتٌ فتضيق النافذةُ على شاشةٍ قصيرة. وهنا كلُّ رقمٍ `.h` من
/// 932 — فالعمودُ يساوي النافذةَ على كلّ شاشةٍ بحكم القياس، ولا كتلةَ
/// تحتاج أن تتنازل. فالأرقامُ كما هي، والحدُّ محفوظٌ في الملفّ لا يُستعمل.
library;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:trydos/common/constant/design/xd_design.dart';
import 'package:trydos/common/constant/design/xd_svg.dart';
import 'package:trydos/common/constant/design/xd_ui.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import 'auth_parts.dart';
import 'demo_design.dart';
import 'preview_slides.dart';

class SignInRequestSheetV2 extends StatelessWidget {
  const SignInRequestSheetV2({
    super.key,
    required this.open,
    required this.onClose,
    required this.onStart,
  });

  final bool open;

  /// «لاحقاً» — وكذلك اللمسُ على العتمة والسحبُ إلى أسفل.
  final VoidCallback onClose;

  /// «ابدأ» — تفتح تصميمَ الدخول الجديد.
  final VoidCallback onStart;

  /// طرفُ مقبض النافذة على اللوح: 285 + 12 + 1 — وعليه تُقاس أوّلُ كتلة.
  static double get _handleEnd =>
      SignInXd.top + XdSheet.handleTop + XdSheet.handleHeight / 2;

  /// أعلى صندوق الفقرة ذات السطرين.
  static double get _paraTop =>
      Xd.paraTop(SignInXd.line1, 14, SignInXd.lineHeight);

  @override
  Widget build(BuildContext context) {
    return XdSheetLayer(
      open: open,
      y: SignInXd.top,
      radius: XdSheet.radiusWallet,
      shadow: SignInXd.shadow,
      onClose: onClose,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: (SignInXd.logoTop - _handleEnd).h),
          Center(
            child: SvgPicture.asset(
              'assets/svg/$kDemoSvg/signInLogo.svg',
              width: SignInXd.logoSize.w,
              height: SignInXd.logoSize.w,
            ),
          ),
          SizedBox(
            height: (_paraTop - (SignInXd.logoTop + SignInXd.logoSize)).h,
          ),
          _words(),
          // البطاقةُ: من أسفل الفقرة (سطران × 20) إلى 565.
          SizedBox(
            height: (SignInXd.cardTop - (_paraTop + 2 * SignInXd.lineHeight)).h,
          ),
          _SignInSlides(onStart: onStart),
          SizedBox(height: (SignInXd.ctaTop - (SignInXd.dotsTop + 8)).h),
          _cta(),
          SizedBox(
            height: Xd.gapTo(
              SignInXd.ctaTop + SignInXd.ctaHeight,
              SignInXd.laterBaseline,
              14,
            ).h,
          ),
          _later(),
          // والأبيضُ تحتها إلى طرف اللوح، تُزاد عليه الحافّةُ الآمنة.
          SizedBox(
            height:
                (SignInXd.endGap - Xd.textBottom(SignInXd.laterBaseline, 14))
                    .h +
                MediaQuery.paddingOf(context).bottom,
          ),
        ],
      ),
    );
  }

  /// سطران في المنتصف. والويبُ يقطع الجملةَ المترجَمةَ عند موضعي الملفّ
  /// (x 20.45 و65.54) ويرسم كلَّ سطرٍ وحدَه؛ وهنا فقرةٌ واحدةٌ مُوسّطةٌ من
  /// ثلاث قطعٍ — فالقطعُ تُترجم ولا يُقطَع سطرٌ على طولٍ إنجليزيّ.
  Widget _words() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: SizedBox(
        width: Xd.fill(18),
        child: Text.rich(
          TextSpan(
            children: <TextSpan>[
              TextSpan(text: '${LocaleKeys.to_access_all_features.tr()} '),
              TextSpan(
                text: LocaleKeys.please_get_started.tr(),
                style: xdTextStyle(
                  size: 14,
                  weight: XdWeight.medium,
                  height: SignInXd.lineHeight,
                ),
              ),
              TextSpan(
                text: '${LocaleKeys.where_youll_find_great_features.tr()} ',
              ),
              TextSpan(
                text: LocaleKeys.more_info.tr(),
                style: xdTextStyle(
                  size: 14,
                  color: XdColors.blue,
                  height: SignInXd.lineHeight,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
          style: xdTextStyle(size: 14, height: SignInXd.lineHeight),
        ),
      ),
    );
  }

  /// «ابدأ»: 390×60 بنصف قطر 20، `#FAFAFA` بخطٍّ 0.5 متقطّعٍ `#5D5C5D`،
  /// وكلماتُه 16 `#3C3C3C`.
  Widget _cta() {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: 20.w),
      // وأرقامُه أرقامُ الزرّ العريض نفسُها في لوح الدخول: 390×60 على 20
      // بنصف قطر 20 — فجسمُه هو هو.
      child: AuthWideBody(
        label: LocaleKeys.get_started_plain.tr(),
        onTap: onStart,
        fill: SignInXd.ctaFill,
        ink: SignInXd.ctaInk,
        // وخطُّه `#5D5C5D` — خطُّ الزرّ الافتراضيُّ نفسُه.
      ),
    );
  }

  /// والملفُّ يُوسّط «لاحقاً» على x 216 — بكسلاً واحداً يمينَ المنتصف،
  /// فالهامشُ 2 على يسارها.
  Widget _later() {
    return Padding(
      padding: EdgeInsets.only(left: SignInXd.laterOffset.w),
      child: Center(
        child: XdTap(
          scale: 1,
          onTap: onClose,
          child: XdText(
            LocaleKeys.later_take_look.tr(),
            size: 14,
            color: AuthColors.link,
          ),
        ),
      ),
    );
  }
}

/// بطاقةُ الشرائح ونقاطُها — `SignInSlides.tsx`.
///
/// > «كلُّ شريحةٍ بطاقةٌ بخطّها، فالسحبُ يُخرج بطاقةً ويُدخل أخرى.
/// > و[SignInXd.slideGap] فراغُ ما بينهما، لا يُرى إلّا في السحب: فالنافذةُ
/// > أوسعُ من البطاقة بنصفه على كلّ جانبٍ، وأطولُ بمثله، فلا يُقصّ خطٌّ.»
class _SignInSlides extends StatefulWidget {
  const _SignInSlides({required this.onStart});

  final VoidCallback onStart;

  @override
  State<_SignInSlides> createState() => _SignInSlidesState();
}

class _SignInSlidesState extends State<_SignInSlides> {
  final PageController _pages = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsetsDirectional.only(start: 20.w),
          child: SizedBox(
            width: Xd.fill(20),
            height: SignInXd.cardHeight.h,
            child: _slider(),
          ),
        ),
        SizedBox(
          height: (SignInXd.dotsTop - (SignInXd.cardTop + SignInXd.cardHeight))
              .h,
        ),
        Center(child: _dots()),
      ],
    );
  }

  /// النافذةُ أوسعُ من البطاقة وأطولُ بـ[SignInXd.slideGap]، والبطاقةُ داخلها
  /// أصغرُ بمثله — فالفراغُ بين بطاقتين لا يُقصّ خطُّ واحدةٍ منهما.
  Widget _slider() {
    final double half = SignInXd.slideGap.w / 2;
    return OverflowBox(
      maxWidth: Xd.fill(20) + SignInXd.slideGap.w,
      maxHeight: SignInXd.cardHeight.h + SignInXd.slideGap.h,
      child: SizedBox(
        width: Xd.fill(20) + SignInXd.slideGap.w,
        height: SignInXd.cardHeight.h + SignInXd.slideGap.h,
        child: PageView.builder(
          controller: _pages,
          onPageChanged: (int i) => setState(() => _index = i),
          itemCount: kPreviewSlides.length,
          itemBuilder: (BuildContext context, int i) => Padding(
            padding: EdgeInsets.symmetric(horizontal: half, vertical: half),
            child: _slide(kPreviewSlides[i]),
          ),
        ),
      ),
    );
  }

  Widget _slide(PreviewSlide slide) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        // أتسع البطاقةُ للأيقونة، وبأيّ مقاس؟ ثلاثُ درجات: كاملةٌ، فصغيرةٌ،
        // فبلا أيقونةٍ وتبقى الكلمات.
        final double room = box.maxHeight - 2 * SignInXd.slidePad.h;
        final double words = _wordsHeight(context, slide, box.maxWidth);
        final bool full =
            (SignInXd.iconCircle + SignInXd.iconGap).h + words <= room;
        final bool small =
            (SignInXd.iconCircleSmall + SignInXd.iconGapSmall).h + words <=
            room;
        final double circle = full
            ? SignInXd.iconCircle
            : SignInXd.iconCircleSmall;
        final double icon = full ? SignInXd.iconSize : SignInXd.iconSizeSmall;
        final double gap = full ? SignInXd.iconGap : SignInXd.iconGapSmall;

        return Container(
          padding: EdgeInsets.symmetric(horizontal: SignInXd.slidePadX.w),
          decoration: BoxDecoration(
            color: XdColors.white,
            borderRadius: BorderRadius.circular(SignInXd.cardRadius.r),
            border: Border.all(
              color: XdColors.purple,
              width: SignInXd.cardLine,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (full || small) ...<Widget>[
                Container(
                  width: circle.w,
                  height: circle.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: SignInXd.iconBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: SignInXd.iconRing),
                    boxShadow: const <BoxShadow>[
                      // `inset 0 2px 4px rgb(0 0 0 / 0.05)`.
                      BoxShadow(
                        color: Color(0x0D000000),
                        offset: Offset(0, 2),
                        blurRadius: 4,
                        blurStyle: BlurStyle.inner,
                      ),
                    ],
                  ),
                  child: SvgPicture.asset(
                    'assets/svg/$kDemoSvg/${slide.icon}.svg',
                    width: icon.w,
                    height: icon.w,
                  ),
                ),
                SizedBox(height: gap.h),
              ],
              XdText(
                slide.titleKey.tr(),
                size: 20,
                weight: XdWeight.bold,
                height: 25,
                align: TextAlign.center,
                maxLines: 2,
              ),
              SizedBox(height: SignInXd.titleGap.h),
              SizedBox(
                width: SignInXd.slideTextMax.w,
                child: XdText(
                  slide.lineKey.tr(),
                  size: 14,
                  color: XdColors.lineDark,
                  height: 14 * SignInXd.slideTextLine,
                  align: TextAlign.center,
                  maxLines: 4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// طولُ كلمات الشريحة: عنوانُها وسطرُها — لا يتبدّل بمقاس الأيقونة، فلا
  /// تتردّد الدرجةُ بين حالين.
  double _wordsHeight(
    BuildContext context,
    PreviewSlide slide,
    double maxWidth,
  ) {
    final double width = maxWidth - 2 * SignInXd.slidePadX.w;
    double measure(String text, TextStyle style, double at, int lines) {
      final TextPainter painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: Directionality.of(context),
        textAlign: TextAlign.center,
        maxLines: lines,
      )..layout(maxWidth: at);
      return painter.height;
    }

    return measure(
          slide.titleKey.tr(),
          xdTextStyle(size: 20, weight: XdWeight.bold, height: 25),
          width,
          2,
        ) +
        SignInXd.titleGap.h +
        measure(
          slide.lineKey.tr(),
          xdTextStyle(size: 14, height: 14 * SignInXd.slideTextLine),
          width < SignInXd.slideTextMax.w ? width : SignInXd.slideTextMax.w,
          4,
        );
  }

  /// النقاط: المعروضةُ حبّةٌ 16×8 داكنة، وسواها حلقاتٌ 8 بخطٍّ 1 `#404040`.
  Widget _dots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 0; i < kPreviewSlides.length; i += 1) ...<Widget>[
          if (i > 0) SizedBox(width: SignInXd.dotGap.w),
          GestureDetector(
            onTap: () => _pages.animateToPage(
              i,
              duration: XdTransition.duration,
              curve: XdTransition.ease,
            ),
            child: AnimatedContainer(
              duration: SignInXd.dotMove,
              width: (i == _index ? SignInXd.dotPill : SignInXd.dotSize).w,
              height: SignInXd.dotSize.w,
              decoration: BoxDecoration(
                color: i == _index ? XdColors.ink : Colors.transparent,
                borderRadius: BorderRadius.circular(SignInXd.dotSize.r / 2),
                border: i == _index
                    ? null
                    : Border.all(color: XdColors.inkSoft),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
