/// قواعدُ الأمان — لوح XD `Home Page – 39`، ونافذةُ سياسات الدفع `– 102`.
///
/// > نافذةٌ ثانية من y 265 وفي حافّتها خطٌّ 0.5 بلون `#707070`. ونموذجُ العملة
/// > الرقميّة يقع تحتها معتماً.
/// >   - الدرعُ 34 × 40 على (197.98، 288.91)، و«حركاتُك آمنة» (14 Medium) على
/// >     خطّ الأساس 354؛
/// >   - أربعُ قواعدَ من خطّ الأساس 389، كلُّ سطرٍ 18 طولاً وبينه وبين الذي
/// >     فوقه 4: قاعدةٌ (SF Pro Rounded 12، `#1D1D1D`، نقطةٌ 14) وملاحظاتُها
/// >     (SF Pro Rounded Light 12، `#8E8E8E`، 351 عرضاً، نقطةٌ 10). والقاعدةُ
/// >     الأولى وملاحظاتُها 2 يسارَ البواقي؛
/// >   - «أوافق» 370 × 60 على (30، 803)، و«لا أوافق وألغي» (16) على خطّ
/// >     الأساس 891.
/// >
/// > و«سياسات وشروط» في الدفع (`– 102`) هي النافذةُ نفسها بالقواعد نفسها، مع
/// > هذه الفروق ([policies]): الدرعُ والقواعدُ أخفضُ بـ0.33 و1، والعنوانُ
/// > «سياسات وشروط»، و«أوافق» 188 × 45 موسَّطاً على y 811 بلون `#388CFF`
/// > وزاويةٍ 30 أعلى و14 أسفل، وكلماتُه 13 Medium على خطّ الأساس +28. و«لا
/// > أوافق وألغي» يحفظ موضعَه فوق نهاية النافذة.
library;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:trydos/common/constant/design/xd_design.dart';
import 'package:trydos/common/constant/design/xd_svg.dart';
import 'package:trydos/common/constant/design/xd_ui.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import '../../wallet_config.dart';
import 'wallet_cash_in_design.dart';
import 'wallet_sheet_parts.dart';

/// خطُّ قائمة الأمان: SF Pro Rounded 12 بارتفاع سطرٍ 18.
const String kSafeFamily = 'SF-Pro-Rounded-Regular';
const String kSafeFamilyLight = 'SF-Pro-Rounded-Light';

/// ما يبدّله اللوحان: أعلى الدرع، وكم تهبط القواعدُ عن قواعد المحفظة
/// ([drop])، والعنوان وكم يُزيحه الملفُّ عن المركز — `SAFE_LOOK`.
class SafeLook {
  const SafeLook({
    required this.shieldY,
    required this.drop,
    required this.title,
    required this.nudge,
  });

  final double shieldY;
  final double drop;
  final String title;
  final double nudge;

  /// قواعدُ المحفظة: العنوانُ يبدأ على x 126.
  static const SafeLook wallet = SafeLook(
    shieldY: 288.91,
    drop: 0,
    title: LocaleKeys.your_transactions_are_safe,
    nudge: 1.5,
  );

  /// سياساتُ الدفع: العنوانُ يبدأ على x 154.
  static const SafeLook policies = SafeLook(
    shieldY: 289.24,
    drop: 1,
    title: LocaleKeys.policies_and_terms,
    nudge: 0,
  );
}

/// جسمُ نافذة القواعد. يُوضع في [XdSheetLayer] على [CashInDesign.rulesTop].
class WalletSafeRules extends StatelessWidget {
  const WalletSafeRules({
    super.key,
    required this.onAgree,
    required this.onCancel,
    this.policies = false,
  });

  final VoidCallback onAgree;
  final VoidCallback onCancel;

  /// سياساتُ الدفع وشروطُه (`– 102`)، لا قواعدُ أمان المحفظة (`– 39`).
  final bool policies;

  @override
  Widget build(BuildContext context) {
    final SafeLook look = policies ? SafeLook.policies : SafeLook.wallet;
    final double first = Xd.sfTop(
      CashInDesign.rulesFirstBaseline + look.drop,
      CashInDesign.ruleSize,
      CashInDesign.ruleLine,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // الدرعُ يحفظ حجمَه، موسَّطاً كما في الملفّ.
        Padding(
          padding: EdgeInsetsDirectional.only(
            top: (look.shieldY - (CashInDesign.rulesTop + 13)).h,
            start: Xd.fromCentre(CashInDesign.shieldX),
          ),
          child: const XdSvg(
            'shieldSafe',
            folder: kWalletSvg,
            w: CashInDesign.shieldW,
            h: CashInDesign.shieldH,
          ),
        ),
        // موسَّطٌ، بقدر ما يُزيحه الملفُّ عن المركز.
        WalletCentred(
          mt: Xd.gapTo(
            look.shieldY + CashInDesign.shieldH,
            CashInDesign.safeTitleBaseline,
            14,
          ),
          nudge: look.nudge,
          child: XdText(
            look.title.tr(),
            size: 14,
            weight: XdWeight.medium,
            align: TextAlign.center,
          ),
        ),
        WalletUnder(
          children: <Widget>[
            for (int i = 0; i < kWalletSafeRules.length; i++)
              ..._rule(i, first: first),
            _buttons(context, look),
          ],
        ),
      ],
    );
  }

  /// قاعدةٌ وملاحظاتُها. وكلماتُ الملاحظات تبدأ على x 56 أو 58، وعرضُها 351
  /// في الملفّ، فتحفظ مسافتَها إلى حافّة الشاشة اليمنى.
  List<Widget> _rule(int i, {required double first}) {
    final SafeRuleData item = kWalletSafeRules[i];
    final double x = i == 0 ? 56 : 58;
    final double right = Xd.designW - x - 351;
    final double wordsX = i == 0 ? 40 : 42;
    return <Widget>[
      Padding(
        padding: EdgeInsetsDirectional.only(
          top:
              (i == 0
                      ? first -
                            Xd.textBottom(CashInDesign.safeTitleBaseline, 14)
                      : CashInDesign.ruleGap)
                  .h,
          start: 20.w,
          end: right.w,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // أعلى النقطة 2 تحت أعلى السطر (378 مقابل 376).
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: _SafeBullet(big: true, ok: item.ok),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.only(
                  start: (wordsX - (20 + 14)).w,
                ),
                child: Text(
                  item.rule.tr(),
                  style: xdTextStyle(
                    size: CashInDesign.ruleSize,
                    height: CashInDesign.ruleLine,
                  ).copyWith(fontFamily: kSafeFamily),
                ),
              ),
            ),
          ],
        ),
      ),
      for (final SafeNoteData note in item.notes)
        Padding(
          padding: EdgeInsetsDirectional.only(
            top: CashInDesign.ruleGap.h,
            start: wordsX.w,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // أعلى النقطة 4 تحت أعلى السطر (402 مقابل 398).
              Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: _SafeBullet(big: false, ok: note.ok),
              ),
              WalletPara(
                text: note.text.tr(),
                mt: 0,
                ml: 16 - 10,
                // 351 في الملفّ: الصفُّ يبدأ 16 قبل الكلمات.
                width: Xd.fill(x, right),
                size: CashInDesign.ruleSize,
                lineHeight: CashInDesign.ruleLine,
                weight: XdWeight.light,
                color: XdColors.ring,
                family: kSafeFamilyLight,
                align: TextAlign.left,
              ),
            ],
          ),
        ),
    ];
  }

  /// الزرّان. و«أوافق» هو الذي يستقرّ على موضع الملفّ، و«لا أوافق» بعده.
  /// ونافذةُ السياسات تنتهي 1 أخفضَ (931)، وزرّاها معها.
  Widget _buttons(BuildContext context, SafeLook look) {
    // الملفُّ يُسنِد هذه الكتلةَ إلى أسفل اللوح (`mt-auto`)، فتحلّ على موضعها
    // فيه: «أوافق» على y 803 و«لا أوافق» على خطّ الأساس 891. وهي هنا كتلةٌ
    // بعد الأسطر بحشوةٍ عليا 8 وسفلى تُنهيها على 895، فإن طالت الترجماتُ
    // دُفِعت إلى أسفلَ كما يدفعها الويب.
    return Padding(
      padding: EdgeInsets.only(
        top: 8.h,
        bottom:
            (CashInDesign.boardEnd - 895 - look.drop).h +
            MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (policies)
            // 188 × 45 موسَّطاً، بزاويةٍ 30 أعلى و14 أسفل.
            Align(
              child: XdTap(
                scale: 0.98,
                onTap: onAgree,
                child: Container(
                  width: CashInDesign.policiesAgreeW.w,
                  height: CashInDesign.policiesAgreeH.h,
                  decoration: BoxDecoration(
                    color: XdColors.blue,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30.r),
                      bottom: Radius.circular(14.r),
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      // خطُّ الأساس 28 في الزرّ (839 − 811).
                      Padding(
                        padding: EdgeInsets.only(top: Xd.gapTo(0, 28, 13).h),
                        child: XdText(
                          LocaleKeys.i_agree_only.tr(),
                          size: 13,
                          weight: XdWeight.medium,
                          color: XdColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            WalletSheetButton(
              label: XdText(
                LocaleKeys.i_agree_only.tr(),
                size: 16,
                color: XdColors.white,
                align: TextAlign.center,
              ),
              fill: XdColors.cryptoBlue,
              stroke: XdColors.agreeLine,
              left: CashInDesign.agreeX,
              onTap: onAgree,
            ),
          WalletCentred(
            mt: policies
                ? Xd.gapTo(
                    CashInDesign.policiesAgreeY + CashInDesign.policiesAgreeH,
                    CashInDesign.policiesDisagreeBaseline,
                    16,
                  )
                : Xd.gapTo(
                    CashInDesign.agreeY + CashInDesign.agreeH,
                    CashInDesign.disagreeBaseline,
                    16,
                  ),
            child: XdTap(
              scale: 0.98,
              onTap: onCancel,
              child: Text(
                LocaleKeys.i_disagree_and_cancel.tr(),
                textAlign: TextAlign.center,
                maxLines: 1,
                // تباعدُ XD 25 يساوي 25 من ألفٍ من الـem.
                style: xdTextStyle(
                  size: 16,
                ).copyWith(letterSpacing: 0.025 * 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// نقطةُ قائمةٍ: حلقةٌ رماديّة (0.5، داخليّة) حول نقطةٍ ملوَّنة — `Bullet`.
class _SafeBullet extends StatelessWidget {
  const _SafeBullet({required this.big, required this.ok});

  final bool big;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    final double size = big ? 14 : 10;
    final double dot = big ? 6 : 4;
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: XdColors.ring, width: 0.5),
      ),
      child: Center(
        child: Container(
          width: dot.w,
          height: dot.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ok ? XdColors.safeGreen : XdColors.safeAmber,
          ),
        ),
      ),
    );
  }
}
