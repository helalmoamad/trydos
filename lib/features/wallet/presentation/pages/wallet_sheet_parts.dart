/// القطعُ المشتركةُ بين نوافذ المحفظة — نقلٌ للمُصدَّرات التي يتقاسمها
/// `WalletCashOutSheet.tsx` و`WalletCashInSheet.tsx` و`WalletInfoSheet.tsx`:
/// `WithBank` و`Brand` و`BrandCard` و`InfoButton` و`SheetButton` و`Tab`
/// و`Recipient` و`InfoField` و`Under` و`FileLines`.
///
/// وكلُّ رقمٍ هنا بكسلُ تصميمٍ على لوح 430 × 932، يُحوَّل بـ`.w` و`.h`.
library;

import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:trydos/common/constant/design/xd_design.dart';
import 'package:trydos/common/constant/design/xd_svg.dart';
import 'package:trydos/common/constant/design/xd_ui.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import '../../wallet_config.dart';
import 'wallet_cash_in_design.dart';

/// حشوةُ التوسيط بإزاحة: جانبٌ واحدٌ ضعفَ الإزاحة — `offCentre`.
///
/// الملفُّ يُوسّط بالعين، فيبدأ نصّاً نصفَ بكسلٍ يمينَ المركز أو يسارَه.
EdgeInsetsGeometry walletOffCentre(double nudge) => EdgeInsets.only(
  left: nudge > 0 ? (nudge * 2).w : 0,
  right: nudge < 0 ? (-nudge * 2).w : 0,
);

/// كتلةٌ موسَّطةٌ على الشاشة بإزاحة الملفّ — `<Txt center nudge>`.
///
/// والطفلُ نصٌّ موسَّطُ المحاذاة (`align: TextAlign.center`).
class WalletCentred extends StatelessWidget {
  const WalletCentred({
    super.key,
    required this.child,
    this.mt = 0,
    this.nudge = 0,
  });

  final Widget child;
  final double mt;
  final double nudge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: mt.h).add(walletOffCentre(nudge)),
      child: SizedBox(width: double.infinity, child: child),
    );
  }
}

/// جملةٌ فيها `{slots}`: كلُّ خانةٍ تُبدَّل بقطعتها، فتحفظ الكلماتُ حول القيمة
/// وزنَها وتبقى الجملةُ مفتاحاً واحداً — `Slots`.
List<InlineSpan> walletSlots(
  String text,
  Map<String, InlineSpan> slots, {
  required TextStyle base,
}) {
  final List<InlineSpan> out = <InlineSpan>[];
  final RegExp pattern = RegExp(r'\{(\w+)\}');
  int at = 0;
  for (final RegExpMatch m in pattern.allMatches(text)) {
    if (m.start > at) {
      out.add(TextSpan(text: text.substring(at, m.start), style: base));
    }
    final InlineSpan? slot = slots[m.group(1)];
    out.add(slot ?? TextSpan(text: m.group(0), style: base));
    at = m.end;
  }
  if (at < text.length) {
    out.add(TextSpan(text: text.substring(at), style: base));
  }
  return out;
}

/// جملةٌ فيها اسمُ المصرف، والملفُّ يرسمه عريضاً — `WithBank`.
List<InlineSpan> walletWithBank(
  String text, {
  required double size,
  XdWeight weight = XdWeight.regular,
  Color color = XdColors.ink,
}) {
  final TextStyle base = xdTextStyle(size: size, weight: weight, color: color);
  return walletSlots(text, <String, InlineSpan>{
    'bank': TextSpan(
      text: WalletBrandData.bank,
      style: xdTextStyle(size: size, weight: XdWeight.bold, color: color),
    ),
  }, base: base);
}

/// العلامةُ كما يكتبها الملفّ: «try» و«rdb» عريضتان والباقي عاديّ — `Brand`.
class WalletBrand extends StatelessWidget {
  const WalletBrand({
    super.key,
    required this.size,
    this.mt = 0,
    this.nudge = 0,
  });

  final double size;
  final double mt;
  final double nudge;

  @override
  Widget build(BuildContext context) {
    return WalletCentred(
      mt: mt,
      nudge: nudge,
      child: Text.rich(
        TextSpan(
          children: <InlineSpan>[
            TextSpan(
              text: WalletBrandData.start,
              style: xdTextStyle(size: size, weight: XdWeight.bold),
            ),
            TextSpan(
              text: WalletBrandData.rest,
              style: xdTextStyle(size: size),
            ),
            TextSpan(
              text: WalletBrandData.bank,
              style: xdTextStyle(size: size, weight: XdWeight.bold),
            ),
          ],
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
      ),
    );
  }
}

/// الجزءُ الذي يُمرَّر من نافذة: كلُّ ما تحت الرأس — `Under`.
///
/// والرأسُ يثبت فوقه، فلا يَخرج العنوانُ مع التمرير.
class WalletUnder extends StatelessWidget {
  const WalletUnder({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

/// فقرةٌ بارتفاع سطر الملفّ، تُبقي مسافتَه إلى الحافّتين — `FileLines`.
///
/// والملفُّ يرسم على الشاشة العريضة فواصلَ أسطره الإنجليزيّة، وعلى الضيّقة
/// يترك النصَّ يلتفّ. وترجماتُنا تختلف أطوالها، فاللفُّ هو الصحيح دائماً.
class WalletPara extends StatelessWidget {
  const WalletPara({
    super.key,
    this.text,
    this.spans,
    required this.mt,
    required this.ml,
    required this.width,
    required this.size,
    required this.lineHeight,
    this.weight = XdWeight.regular,
    this.color = XdColors.ink,
    this.family,
    this.align,
  });

  /// نصُّ الفقرة، أو [spans] إن كانت كلماتُها مختلفةَ الأوزان.
  final String? text;
  final List<InlineSpan>? spans;

  final double mt;

  /// الحشوةُ قبل الفقرة داخل كتلتها، ببكسل التصميم.
  final double ml;

  /// عرضُ الفقرة محسوباً بـ[Xd.fill]: مسافةُ الملفّ إلى حافّتي **الشاشة**.
  final double width;

  final double size;
  final double lineHeight;
  final XdWeight weight;
  final Color color;

  /// خطٌّ غيرُ Quicksand — قوائمُ الأمان بخطّ SF Pro Rounded.
  final String? family;

  final TextAlign? align;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = xdTextStyle(
      size: size,
      weight: weight,
      color: color,
      height: lineHeight,
    );
    return Padding(
      padding: EdgeInsetsDirectional.only(top: mt.h, start: ml.w),
      child: SizedBox(
        width: width,
        child: spans == null
            ? Text(
                text!,
                textAlign: align,
                style: family == null
                    ? style
                    : style.copyWith(fontFamily: family),
              )
            : Text.rich(TextSpan(children: spans), textAlign: align),
      ),
    );
  }
}

/// بطاقةُ trydos | rdb في طرق الإيداع (`– 22` على y 338) وطرق السحب
/// (`– 21` على y 366) — `BrandCard`.
///
/// 390 × 188 على x 20 وخطٌّ بنفسجيٌّ **على** حافّتها. ومن أعلاها: وسمُ
/// «موصى به» 94 × 22 على (310، +6)، والعلامةُ 30 على خطّ الأساس +106، ووسمُ
/// «سهل . سريع . بلا عمولة» 158 × 22 على (136، +122).
class WalletBrandCard extends StatelessWidget {
  const WalletBrandCard({
    super.key,
    required this.y,
    required this.mt,
    required this.onTap,
  });

  /// y حافّة البطاقة العليا على اللوح.
  final double y;
  final double mt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(top: mt.h, start: 20.w),
      child: XdTap(
        scale: 0.985,
        onTap: onTap,
        child: Container(
          width: Xd.fill(20),
          height: CashInDesign.brandCardH.h,
          decoration: BoxDecoration(
            color: XdColors.card,
            borderRadius: BorderRadius.circular(15.r),
          ),
          // الخطُّ على الحافّة لا يأكل من المحتوى.
          foregroundDecoration: BoxDecoration(
            border: Border.all(color: XdColors.purple),
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // وسمُ «موصى به» يحفظ 6 إلى حافّة البطاقة اليمنى.
              Padding(
                padding: EdgeInsetsDirectional.only(
                  top: 6.h,
                  end: (410 - (310 + 94)).w,
                ),
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: _tag(
                    LocaleKeys.recommended.tr(),
                    minWidth: 94,
                    stroke: false,
                  ),
                ),
              ),
              // الملفُّ يُوسّط العلامة على x 216: بكسلاً يمينَ مركز البطاقة.
              WalletBrand(
                size: 30,
                mt: Xd.gapTo(y + 6 + 22, y + 106, 30),
                nudge: 1,
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: (y + 122 - Xd.textBottom(y + 106, 30)).h,
                ),
                child: Align(
                  child: _tag(
                    LocaleKeys.easy_fast_no_commission.tr(),
                    minWidth: 158,
                    stroke: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// وسمٌ 22 طولاً بزاوية 8، كلمتُه 11 بنفسجيّةٌ على خطّ الأساس 15.
  Widget _tag(String label, {required double minWidth, required bool stroke}) {
    return Container(
      height: 22.h,
      constraints: BoxConstraints(minWidth: minWidth.w),
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        color: XdColors.purpleTint,
        borderRadius: BorderRadius.circular(8.r),
      ),
      foregroundDecoration: stroke
          ? BoxDecoration(
              border: Border.all(color: XdColors.purple),
              borderRadius: BorderRadius.circular(8.r),
            )
          : null,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: Xd.gapTo(0, 15, 11).h),
            child: XdText(
              label,
              size: 11,
              color: XdColors.purple,
              align: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// زرُّ البطاقة الرماديّة: 366 × 38، `#F8F8F8` بزاوية 15، وكلمتُه 11 Medium
/// رماديّةٌ على خطّ الأساس 23، و12 من حافّتي البطاقة — `InfoButton`.
class WalletInfoButton extends StatelessWidget {
  const WalletInfoButton({
    super.key,
    required this.mt,
    required this.label,
    this.nudge = 0,
    this.onTap,
  });

  final double mt;
  final String label;
  final double nudge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(top: mt.h, start: (32 - 20).w),
      child: XdTap(
        scale: 0.98,
        onTap: onTap,
        child: Container(
          width: Xd.fill(12),
          height: CashInDesign.greyButtonH.h,
          decoration: BoxDecoration(
            color: XdColors.field,
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Column(
            children: <Widget>[
              WalletCentred(
                mt: Xd.gapTo(0, 23, 11),
                nudge: nudge,
                child: XdText(
                  label,
                  size: 11,
                  weight: XdWeight.medium,
                  color: XdColors.grey,
                  align: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// الزرُّ العريض: 390 × 60 على x 20 بزاوية 20 وكلماتُه 16 على خطّ الأساس 36،
/// ويحفظ 20 إلى حافّتي النافذة — `SheetButton`.
class WalletSheetButton extends StatelessWidget {
  const WalletSheetButton({
    super.key,
    required this.label,
    required this.fill,
    this.mt = 0,
    this.nudge = 0,
    this.color = XdColors.white,
    this.stroke,
    this.dash = false,
    this.left = 20,
    this.onTap,
  });

  /// نصٌّ موسَّطُ المحاذاة.
  final Widget label;

  final Color fill;
  final double mt;
  final double nudge;
  final Color color;
  final Color? stroke;

  /// خطٌّ متقطّعٌ «3 3» — زرُّ «رجوع» في قارئ الرمز (`Home Page – 30`).
  final bool dash;

  /// 20 في كلّ نافذة، و30 في «أوافق» بقواعد الأمان.
  final double left;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget body = Column(
      children: <Widget>[
        WalletCentred(mt: Xd.gapTo(0, 36, 16), nudge: nudge, child: label),
      ],
    );
    return Padding(
      padding: EdgeInsetsDirectional.only(top: mt.h, start: left.w),
      child: XdTap(
        scale: 0.98,
        onTap: onTap,
        child: dash && stroke != null
            ? DottedBorder(
                padding: EdgeInsets.zero,
                borderType: BorderType.RRect,
                strokeCap: StrokeCap.round,
                dashPattern: const <double>[3, 3],
                radius: Radius.circular(20.r),
                color: stroke!,
                child: Container(
                  width: Xd.fill(left),
                  height: CashInDesign.wideButtonH.h,
                  decoration: BoxDecoration(
                    color: fill,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: body,
                ),
              )
            : Container(
                width: Xd.fill(left),
                height: CashInDesign.wideButtonH.h,
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                foregroundDecoration: stroke == null
                    ? null
                    : BoxDecoration(
                        border: Border.all(color: stroke!),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                child: body,
              ),
      ),
    );
  }
}

/// تبويبُ نموذجٍ: 193 × 28 بزاوية 8، كلمتُه 13 على خطّ الأساس 19. والمختارُ
/// ملوَّنٌ بكلماتٍ Medium، والآخرُ له خطٌّ وكلماتٌ عاديّة — `Tab`.
///
/// والتبويبان يتقاسمان عرضَ صفّهما، فلا بدَّ للصفّ من عرض: 20 من الحافّتين.
class WalletTab extends StatelessWidget {
  const WalletTab({
    super.key,
    required this.chosen,
    required this.spans,
    required this.onTap,
    this.fill = XdColors.card,
    this.chosenFill = XdColors.green,
    this.nudge = 0.5,
    this.ml,
  });

  final bool chosen;

  /// كلماتُ التبويب بوزنِه الأساس — المختارُ Medium وغيرُه عاديّ.
  final List<InlineSpan> Function(XdWeight weight) spans;

  final VoidCallback onTap;

  /// اللونُ ما لم يكن مختاراً.
  final Color fill;

  /// أخضرُ نموذج السحب، وأصفرُ `#FAE26B` في نماذج الإيداع.
  final Color chosenFill;

  /// كم يُزيح الملفُّ الكلماتَ عن مركز التبويب.
  final double nudge;

  final double? ml;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsetsDirectional.only(start: (ml ?? 0).w),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: CashInDesign.tabH.h,
            decoration: BoxDecoration(
              color: chosen ? chosenFill : fill,
              borderRadius: BorderRadius.circular(8.r),
            ),
            foregroundDecoration: chosen
                ? null
                : BoxDecoration(
                    border: Border.all(color: XdColors.line),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
            child: Column(
              children: <Widget>[
                WalletCentred(
                  mt: Xd.gapTo(CashInDesign.tabsY, 232, 13),
                  nudge: nudge,
                  child: Text.rich(
                    TextSpan(
                      children: spans(
                        chosen ? XdWeight.medium : XdWeight.regular,
                      ),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// حقلٌ للقراءة: 390 × 55 لونُه `#FCFCFC`، عنوانٌ رماديٌّ 12 على خطّ الأساس
/// 20 وقيمةٌ 14 على 43، و12 من الداخل. و[mark] تُضيف العينَ الرماديّة أعلى
/// اليمين — `Recipient` و`InfoField`.
class WalletField extends StatelessWidget {
  const WalletField({
    super.key,
    required this.mt,
    required this.label,
    required this.value,
    this.mark = false,
    this.markIcon = 'eyeGrey',
    this.markW = 16,
    this.markTop = 20 - 8,
  });

  final double mt;

  /// عنوانٌ قد يكون غنيّاً (اسمُ المصرف عريضٌ فيه).
  final Widget label;
  final Widget value;

  final bool mark;
  final String markIcon;
  final double markW;
  final double markTop;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(top: mt.h, start: 20.w),
      child: Container(
        width: Xd.fill(20),
        height: CashInDesign.fieldH.h,
        decoration: BoxDecoration(
          color: XdColors.card,
          borderRadius: BorderRadius.circular(15.r),
        ),
        padding: EdgeInsetsDirectional.only(start: 12.w, end: 12.w, top: 8.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  label,
                  Padding(
                    padding: EdgeInsets.only(
                      top: Xd.gapTo(8 + Xd.lineBox(12), 43, 14).h,
                    ),
                    child: value,
                  ),
                ],
              ),
            ),
            if (mark)
              Padding(
                padding: EdgeInsets.only(top: markTop.h),
                child: XdSvg(markIcon, folder: kWalletSvg, w: markW),
              ),
          ],
        ),
      ),
    );
  }
}

/// إجراءٌ تحت رمزٍ، وx الذي يبدأ عنده الملفُّ كلمتَه، وكم تزيح صورتُه عن
/// مركز الكلمة — `Action` في ملفّي الإيداع والسحب.
typedef WalletAction = ({
  String id,
  String icon,
  String label,
  double x,
  double off,
});

/// صفُّ إجراءاتٍ على y 855: صورةٌ 20 فوق نصٍّ 11 على خطّ الأساس 892. والنصوصُ
/// تنتهي على y 895: 35 فوق أسفل اللوح — `Actions`.
///
/// والملفُّ يُوسّط الصفَّ على الشاشة: الخاناتُ تحفظ عروضَها، والصفُّ يحفظ
/// مسافةَ الملفّ من مركز الشاشة.
class WalletActionsRow extends StatelessWidget {
  const WalletActionsRow({
    super.key,
    required this.mt,
    required this.actions,
    required this.onAct,
  });

  final double mt;
  final List<WalletAction> actions;
  final ValueChanged<String> onAct;

  /// y الصفّ وخطُّ أساس كلماته، وما تحتها إلى نهاية اللوح.
  static const double y = 855;
  static const double labelBaseline = 892;
  static const double icon = 20;
  static const double tail = 930 - 895;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: mt.h,
        start: Xd.fromCentre(actions.first.x),
        bottom: tail.h + MediaQuery.paddingOf(context).bottom,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (int i = 0; i < actions.length; i++)
            // الخانةُ تمتدّ من بداية نصٍّ إلى بداية التالي، والإجراءُ في
            // أوّلها بعرض أوسعِ ما فيه — فيحلّ نصُّه على x الملفّ.
            if (i < actions.length - 1)
              SizedBox(
                width: (actions[i + 1].x - actions[i].x).w,
                child: Align(
                  alignment: AlignmentDirectional.topStart,
                  child: _action(actions[i]),
                ),
              )
            else
              _action(actions[i]),
        ],
      ),
    );
  }

  Widget _action(WalletAction a) {
    return XdTap(
      scale: 0.96,
      onTap: () => onAct(a.id),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // الصورةُ موسَّطةٌ فوق نصّها ثمّ تزيح عنه بالقدر الذي في الملفّ.
          Padding(
            padding: walletOffCentre(a.off),
            child: XdSvg(a.icon, folder: kWalletSvg, w: icon),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: Xd.gapTo(y + icon, labelBaseline, 11).h,
            ),
            child: XdText(a.label.tr(), size: 11),
          ),
        ],
      ),
    );
  }
}

/// الملاحظةُ أسفل صورةِ رمزٍ (`Home Page – 24`، `– 31`، `– 38`): 390 × 90 على
/// (20، 805)، لونُها `#FCFCFC` وخطٌّ **على** حافّتها. عنوانُها (11 Medium) على
/// خطّ الأساس 828، ثمّ نصٌّ 11 بارتفاع سطرٍ 16 من 848. وتنتهي على y 895: 35
/// فوق أسفل اللوح — `Note`.
///
/// ونصُّها ينتهي بـ«شكراً لك | يسعدنا أن نخدمك.»، والجزآن Medium — `ThankYou`.
class WalletNote extends StatelessWidget {
  const WalletNote({
    super.key,
    required this.mt,
    required this.title,
    required this.body,
  });

  final double mt;
  final String title;
  final String body;

  static const double y = 805;
  static const double height = 90;
  static const double titleBaseline = 828;
  static const double paraBaseline = 848;
  static const double paraLine = 16;

  @override
  Widget build(BuildContext context) {
    final double para = Xd.paraTop(paraBaseline, 11, paraLine);
    final TextStyle base = xdTextStyle(size: 11, height: paraLine);
    final TextStyle medium = xdTextStyle(
      size: 11,
      weight: XdWeight.medium,
      height: paraLine,
    );
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: mt.h,
        start: 20.w,
        bottom: WalletActionsRow.tail.h + MediaQuery.paddingOf(context).bottom,
      ),
      child: Container(
        width: Xd.fill(20),
        constraints: BoxConstraints(minHeight: height.h),
        padding: EdgeInsetsDirectional.only(
          start: 12.w,
          bottom: (895 - (para + 3 * paraLine)).h,
        ),
        decoration: BoxDecoration(
          color: XdColors.card,
          borderRadius: BorderRadius.circular(15.r),
        ),
        foregroundDecoration: BoxDecoration(
          border: Border.all(color: XdColors.line),
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            WalletPara(
              text: title,
              mt: Xd.gapTo(y, titleBaseline, 11),
              ml: 0,
              // 12 من حافّة الملاحظة اليمنى أيضاً: الملفّ 366.
              width: Xd.fill(32, 32),
              size: 11,
              lineHeight: Xd.lineBox(11),
              weight: XdWeight.medium,
            ),
            WalletPara(
              spans: <InlineSpan>[
                TextSpan(text: '$body ', style: base),
                TextSpan(text: LocaleKeys.thank_you.tr(), style: medium),
                TextSpan(text: ' | ', style: base),
                TextSpan(
                  text: LocaleKeys.we_are_pleased_to_serve_you.tr(),
                  style: medium,
                ),
                TextSpan(text: '.', style: base),
              ],
              mt: para - Xd.textBottom(titleBaseline, 11),
              ml: 0,
              width: Xd.fill(32, 32),
              size: 11,
              lineHeight: paraLine,
            ),
          ],
        ),
      ),
    );
  }
}

/// صورةٌ من `assets/images/wallet_v2/` بحجم الملفّ.
class WalletImage extends StatelessWidget {
  const WalletImage({
    super.key,
    required this.name,
    required this.size,
    this.radius = 0,
  });

  final String name;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final Widget image = Image.asset(
      'assets/images/wallet_v2/$name',
      width: size.w,
      height: size.w,
      fit: BoxFit.cover,
    );
    if (radius == 0) return image;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius.r),
      child: image,
    );
  }
}
