/// المعاينةُ السريعة — نقلٌ لـ`web_design/NewLoginDesign/QuickPreviewScreen.tsx`
/// (لوحا `Ramaaz pay signin - 14` و`- 13`).
///
/// > «ثماني ثوانٍ تُعرض فيها الكلمةُ في منتصف الشاشة والعمودُ ينتظر تحتها،
/// > لا تُختصر بلمسة. ثمّ يصعد العمودُ إلى أعلى الشاشة وتخبو الكلمة.
/// >
/// > والعمودُ — لافتةٌ متقلّبةٌ وشعارٌ وعنوانٌ وبطاقةُ شرائحَ ونقاطٌ وزرّ —
/// > يبدأ تحت الحافّة فتُطلّ منه حلقةُ الشعار وحدَها، ثمّ يرتفع.»
///
/// والشعارُ هنا **في العمود** لا في طبقة الشعار المشتركة: فهو يصعد معه.
/// ولذلك تقول [authLogoFor] في المسرح إنّ هذه الخطوة لا تُظهر الطبقة.
///
/// ومنتقي الدولة يُعرض في هذا العمود نفسِه ([picker]): تحت الشعار، في موضع
/// العنوان والبطاقة والزرّ. فحين يذهب المنتقي ينزلق جزؤه يساراً وينزلق جزءُ
/// المعاينة من اليمين — واللافتةُ والشعارُ ليسا في الجزأين، فلا يتحرّكان:
/// اللافتةُ نفسُها تُكمل تقلّبها، والعلامةُ المشتركةُ لا تجد موضعاً جديداً
/// تذهب إليه.
library;

import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dotted_border/dotted_border.dart';

import 'package:trydos/common/constant/design/xd_design.dart';
import 'package:trydos/common/constant/design/xd_svg.dart';
import 'package:trydos/common/constant/design/xd_ui.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import 'auth_design.dart';
import 'auth_logo.dart';
import 'auth_logo_motion.dart';
import 'auth_parts.dart';
import 'demo_design.dart';
import 'preview_slides.dart';

class QuickPreviewV2 extends StatefulWidget {
  const QuickPreviewV2({
    super.key,
    required this.onComplete,
    this.onExpand,
    this.picker,
    this.hold = PreviewXd.wordmarkHold,
  });

  /// «ابدأ» في آخر شريحة.
  final VoidCallback onComplete;

  /// تُنادى حين يصعد العمود — به يُعطي المسرحُ العلامةَ عملَها الثاني، فلا
  /// تحتاج هذه الشاشةُ أن تعرف شيئاً عن إعداد الشعار.
  final VoidCallback? onExpand;

  /// منتقي الدولة. ما دام موضوعاً فهو ما يُعرض تحت الشعار.
  final Widget? picker;

  final Duration hold;

  @override
  State<QuickPreviewV2> createState() => _QuickPreviewV2State();
}

class _QuickPreviewV2State extends State<QuickPreviewV2> {
  bool _expanded = false;
  Timer? _timer;

  final PageController _pages = PageController();
  int _slide = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.hold, () {
      if (!mounted) return;
      setState(() => _expanded = true);
      widget.onExpand?.call();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pages.dispose();
    super.dispose();
  }

  bool get _showPicker => widget.picker != null;
  bool get _last => _slide == kPreviewSlides.length - 1;

  void _next() {
    if (_last) {
      widget.onComplete();
      return;
    }
    _pages.nextPage(
      duration: XdTransition.duration,
      curve: XdTransition.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: XdColors.white,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints box) {
          // مطويّاً: حافّةُ اللافتة العليا تعلو حافّةَ الشاشة السفلى بالذيل
          // نفسِه على كلّ شاشة. وتُقاس **من الأسفل** عن قصد: إزاحةٌ ثابتةٌ من
          // الأعلى لا تصحّ إلّا على شاشةٍ طولُها 932 بالضبط.
          final double collapsedY =
              box.maxHeight -
              PreviewXd.collapsedTail.h -
              PreviewXd.abovePill.h;

          return ClipRect(
            child: Stack(
              children: <Widget>[
                // الكلمةُ في منتصف الشاشة، ما لم يصعد العمود.
                Positioned.fill(child: _wordmark()),
                AnimatedPositioned(
                  duration: _expanded
                      ? PreviewXd.riseToTop
                      : PreviewXd.riseToPeek,
                  curve: PreviewXd.riseEase,
                  top: _expanded ? 0 : collapsedY,
                  left: 0,
                  right: 0,
                  child: _column(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// الكلمةُ وسطَ الشاشة: تبقى ثماني ثوانٍ، ثمّ تخبو وتصغر إلى 0.9.
  Widget _wordmark() {
    return IgnorePointer(
      child: AnimatedScale(
        scale: _expanded ? PreviewXd.wordmarkExitScale : 1,
        duration: PreviewXd.wordmarkFade,
        curve: Curves.easeInOut,
        child: AnimatedOpacity(
          opacity: _expanded ? 0 : 1,
          duration: PreviewXd.wordmarkFade,
          curve: Curves.easeInOut,
          // لوحةُ الرأس: بناءٌ سينمائيٌّ مرّةً، **والحروفُ تقف ساكنةً**
          // والعيونُ تهبط حولها — `animateWord: false` في إعداد هذا المكان.
          child: Center(
            child: AuthLogoMark(
              variant: LogoVariant.header,
              slot: LogoSlots.quickPreviewWordmark,
              size: PreviewXd.wordmarkWidth.w,
            ),
          ),
        ),
      ),
    );
  }

  Widget _column() {
    return Column(
      children: <Widget>[
        SizedBox(height: PreviewXd.abovePill.h),
        const _SloganPill(),
        SizedBox(height: PreviewXd.pillToLogo.h),
        // ولافتةُ العمود تُناوب، مُطلّةً من الحافّة وبعد أن ترتفع —
        // و`quick-preview-badge` في الويب هو «المناوبة» نفسُها، وهي افتراضُ
        // [AuthBadge]، فلا يُمرَّر.
        const AuthBadge(),
        // تحت الشعار: المنتقي، أو جزءُ المعاينة. والانزلاقُ انزلاقُ الدخول
        // نفسُه: الخارجُ يساراً والداخلُ من اليمين.
        AnimatedSwitcher(
          duration: AuthSlide.duration,
          switchInCurve: AuthSlide.ease,
          switchOutCurve: AuthSlide.ease,
          layoutBuilder: (Widget? current, List<Widget> previous) => Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[...previous, if (current != null) current],
          ),
          transitionBuilder: (Widget part, Animation<double> t) =>
              FadeTransition(
                opacity: t,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(t),
                  child: part,
                ),
              ),
          child: _showPicker
              ? KeyedSubtree(
                  key: const ValueKey<String>('picker'),
                  child: widget.picker!,
                )
              : KeyedSubtree(
                  key: const ValueKey<String>('preview'),
                  child: _body(),
                ),
        ),
      ],
    );
  }

  /// جزءُ المعاينة: العنوانُ والبطاقةُ والنقاطُ والزرّ.
  Widget _body() {
    return Column(
      children: <Widget>[
        SizedBox(height: PreviewXd.logoToTitle.h),
        XdText(
          LocaleKeys.quick_preview_dotted.tr(),
          size: 30,
          weight: XdWeight.bold,
        ),
        SizedBox(height: PreviewXd.titleToCard.h),
        _card(),
        SizedBox(height: PreviewXd.cardToDots.h),
        _dots(),
        SizedBox(height: PreviewXd.dotsToButton.h),
        _button(),
        SizedBox(height: PreviewXd.belowButton.h),
      ],
    );
  }

  /// البطاقة: صندوقٌ 390×473 لا خطَّ له ولا حشوة — **فالخطُّ للشريحة** لا
  /// له، كي يحمل كلُّ سحبٍ بطاقةً بحدِّها وتأتي التاليةُ بحدِّها.
  ///
  /// والنافذةُ أوسعُ من الصندوق بنصف [PreviewXd.slideGap] على كلّ جانبٍ
  /// وأطولُ بمثله، لسببين كلاهما مقصود: تبقى البطاقةُ 390 فلا يتحرّك شيءٌ
  /// في السكون، وتبقى حدودُها داخلَ القصّ فلا يُقصّ خطُّ 0.5 على جانبٍ.
  Widget _card() {
    final double width = Xd.fill(AuthXd.boxLeft);
    final double height = PreviewXd.cardHeight.h;
    final double half = PreviewXd.slideGap.w / 2;
    return SizedBox(
      width: width,
      height: height,
      child: OverflowBox(
        maxWidth: width + PreviewXd.slideGap.w,
        maxHeight: height + PreviewXd.slideGap.h,
        child: SizedBox(
          width: width + PreviewXd.slideGap.w,
          height: height + PreviewXd.slideGap.h,
          child: PageView.builder(
            controller: _pages,
            onPageChanged: (int i) => setState(() => _slide = i),
            itemCount: kPreviewSlides.length,
            itemBuilder: (BuildContext context, int i) => Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: half),
                child: _slideCard(kPreviewSlides[i], width, height),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _slideCard(PreviewSlide slide, double width, double height) {
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.symmetric(horizontal: AuthXd.boxLeft.w),
      decoration: BoxDecoration(
        color: XdColors.white,
        borderRadius: BorderRadius.circular(AuthXd.boxRadius.r),
        border: Border.all(color: XdColors.purple, width: 0.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: PreviewXd.iconCircle.w,
            height: PreviewXd.iconCircle.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: SignInXd.iconBg,
              shape: BoxShape.circle,
              border: Border.all(color: SignInXd.iconRing),
              boxShadow: const <BoxShadow>[
                // `shadow-inner`: ظلٌّ داخليٌّ خفيف.
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
              width: PreviewXd.iconSize.w,
              height: PreviewXd.iconSize.w,
            ),
          ),
          SizedBox(height: PreviewXd.iconToTitle.h),
          XdText(
            slide.titleKey.tr(),
            size: 20,
            weight: XdWeight.bold,
            align: TextAlign.center,
            maxLines: 2,
          ),
          SizedBox(height: PreviewXd.titleToLine.h),
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
  }

  /// النقاط: المعروضةُ حبّةٌ 16×8 داكنة، وسواها حلقاتٌ 8 بخطٍّ 1 `#404040`.
  Widget _dots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 0; i < kPreviewSlides.length; i += 1) ...<Widget>[
          if (i > 0) SizedBox(width: AuthXd.previewDotGap.w),
          GestureDetector(
            onTap: () => _pages.animateToPage(
              i,
              duration: SignInXd.dotMove,
              curve: XdTransition.ease,
            ),
            child: AnimatedContainer(
              duration: SignInXd.dotMove,
              width:
                  (i == _slide
                          ? AuthXd.previewDotActiveWidth
                          : AuthXd.previewDotSize)
                      .w,
              height: AuthXd.previewDotSize.w,
              decoration: BoxDecoration(
                color: i == _slide ? XdColors.ink : Colors.transparent,
                borderRadius: BorderRadius.circular(
                  AuthXd.previewDotSize.r / 2,
                ),
                border: i == _slide
                    ? null
                    : Border.all(color: XdColors.inkSoft),
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// «التالي» حتّى آخر شريحة، ثمّ «ابدأ» بنفسجيّاً مُصمتاً.
  Widget _button() {
    final Widget face = Container(
      width: Xd.fill(AuthXd.boxLeft),
      height: AuthXd.boxHeight.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _last ? XdColors.purple : PreviewXd.nextFill,
        borderRadius: BorderRadius.circular(AuthXd.boxRadius.r),
      ),
      child: XdText(
        _last
            ? LocaleKeys.get_started_plain.tr()
            : LocaleKeys.next.tr(),
        size: 16,
        color: _last ? XdColors.white : AuthColors.dash,
      ),
    );

    return XdTap(
      scale: 0.98,
      onTap: _next,
      child: _last
          ? face
          : DottedBorder(
              padding: EdgeInsets.zero,
              borderType: BorderType.RRect,
              strokeCap: StrokeCap.round,
              strokeWidth: 0.5,
              dashPattern: const <double>[3, 3],
              radius: Radius.circular(AuthXd.boxRadius.r),
              color: XdColors.purple,
              child: face,
            ),
    );
  }
}

/// لافتةُ الشعار المتقلّبة.
///
/// > «الشعاراتُ ليست نصوصاً: النقطتان حولَها بنفسجيّتان والكلماتُ داكنة،
/// > و«تسوّق . تواصل . استثمر . استمتع» فيها ثلاثُ نقاطٍ أُخرى في وسطها.
/// > فكلُّ شعارٍ يرسم نفسَه، ويحمل تشديدَه هو.»
///
/// واللافتةُ كلُّها تتقلّب والكلماتُ معها — لا تثبت اللافتةُ وتخبو كلماتُها،
/// فذلك مزجٌ لا تقليب. وعرضُها عرضُ سطرها: الملفُّ يرسمها نصّاً موضوعاً
/// بـ12 من اللافتة على كلّ جانب، فلكلّ شعارٍ عرضُه.
class _SloganPill extends StatefulWidget {
  const _SloganPill();

  @override
  State<_SloganPill> createState() => _SloganPillState();
}

class _SloganPillState extends State<_SloganPill> {
  int _at = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(PreviewXd.flipEvery, (Timer _) {
      if (mounted) setState(() => _at = (_at + 1) % _slogans.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// النقطةُ البنفسجيّةُ التي يضعها التصميمُ حول كلّ شعار.
  static TextSpan _stop() =>
      TextSpan(text: '.', style: xdTextStyle(size: 14, color: XdColors.purple));

  /// شعارٌ بين نقطتين، كلماتُه كلُّها بوزنٍ واحد.
  static List<TextSpan> _plain(String key) => <TextSpan>[
    _stop(),
    TextSpan(text: ' ${key.tr()} '),
    _stop(),
  ];

  /// والشكلُ نفسُه، وآخرُ [count] كلماتٍ أثقلُ درجةً — والتصميمُ لا يضع
  /// وزناً واحداً لشعارٍ كلِّه: «رفيقُك الجديد في التسوّق» فيه «في التسوّق»
  /// وحدَها Medium. ويُقرأ التشديدُ من آخر الجملة المترجَمة، فتبقى الجملةُ
  /// مفتاحاً واحداً.
  static List<TextSpan> _tailMedium(String key, int count) {
    final List<String> words = key.tr().trim().split(' ');
    if (words.length <= count) return _plain(key);
    final String head = words.sublist(0, words.length - count).join(' ');
    final String tail = words.sublist(words.length - count).join(' ');
    return <TextSpan>[
      _stop(),
      TextSpan(text: ' $head '),
      TextSpan(
        text: tail,
        style: xdTextStyle(size: 14, weight: XdWeight.medium),
      ),
      const TextSpan(text: ' '),
      _stop(),
    ];
  }

  /// والشكلُ نفسُه، وأوّلُ كلمةٍ عريضة — «جرّب تسوّقاً مختلفاً» تفتح على
  /// كلمة العلامة، والعلامةُ بجانبها هي كلمةُ «جرّب» وحدَها، فالشعارُ يستند
  /// إليها.
  static List<TextSpan> _leadBold(String key) {
    final List<String> words = key.tr().trim().split(' ');
    return <TextSpan>[
      _stop(),
      const TextSpan(text: ' '),
      TextSpan(
        text: words.first,
        style: xdTextStyle(size: 14, weight: XdWeight.bold),
      ),
      TextSpan(text: ' ${words.skip(1).join(' ')} '),
      _stop(),
    ];
  }

  static final List<List<TextSpan> Function()> _slogans =
      <List<TextSpan> Function()>[
        () => _tailMedium(LocaleKeys.slogan_shopping_buddy, 2),
        () => _leadBold(LocaleKeys.slogan_try_different),
        () => _plain(LocaleKeys.slogan_shop_connect),
        () => _plain(LocaleKeys.slogan_social_commerce),
        () => _plain(LocaleKeys.slogan_shopping_redefined),
        () => _plain(LocaleKeys.slogan_revolutionary),
      ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AuthXd.pillHeight.h,
      child: AnimatedSwitcher(
        duration: PreviewXd.flipTurn,
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeOut,
        // الداخلةُ تحلّ محلَّ الخارجة، لا تجاورها.
        layoutBuilder: (Widget? current, List<Widget> previous) => Stack(
          alignment: Alignment.center,
          children: <Widget>[...previous, if (current != null) current],
        ),
        transitionBuilder: (Widget pill, Animation<double> t) {
          // تدور على محور x: الداخلةُ من −90 إلى 0، والخارجةُ من 0 إلى +90.
          // و`t` يرجع من 1 إلى 0 للخارجة، فدورانٌ واحدٌ يخدم الحالين لو
          // أخذنا الزاويةَ من الجهة التي يمضي إليها.
          return AnimatedBuilder(
            animation: t,
            builder: (BuildContext context, Widget? child) => Opacity(
              opacity: t.value,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 1 / 600)
                  ..rotateX(-(1 - t.value) * 1.5707963267948966),
                child: child,
              ),
            ),
            child: pill,
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_at),
          child: Container(
            height: AuthXd.pillHeight.h,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: AuthXd.pillPaddingX.w),
            decoration: BoxDecoration(
              color: PreviewXd.pillFill,
              borderRadius: BorderRadius.circular(AuthXd.pillRadius.r),
            ),
            child: Text.rich(
              TextSpan(children: _slogans[_at]()),
              maxLines: 1,
              textAlign: TextAlign.center,
              style: xdTextStyle(size: 14),
            ),
          ),
        ),
      ),
    );
  }
}
