/// صفُّ طرق الدفع — نقلٌ لـ`web_design/components/DemoApp1/screens/PayWays.tsx`.
///
/// > صفُّ خمسِ خاناتٍ 125 بينها 8، ينزلق جانبياً كما تفعل مجموعةُ تمرير
/// > الملفّ: البطاقاتُ («متاح قريباً»، ووسمُه 76 × 19 يتدلّى 9 فوق حافّة
/// > الخانة السفلى)، والعملاتُ الرقميّة، وصورُ شام كاش وسيريتل كاش وإرسال.
/// > وطرقُ الإيداع في المحفظة (`– 22`، الخاناتُ على y 534) ونافذةُ الدفع في
/// > السلّة (`– 73`، على y 604) ترسمان الصفَّ نفسه.
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

class PayWays extends StatelessWidget {
  const PayWays({super.key, required this.mt, this.onCrypto});

  /// من الكتلة التي فوقه إلى حافّة الخانات العليا.
  final double mt;

  /// لمسةُ خانة العملات الرقميّة. والبواقي لا تأخذ لمسةً بعد.
  final VoidCallback? onCrypto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: mt.h),
      child: SizedBox(
        height: PayWaysDesign.rowHeight.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: kWalletCashInWays.length,
          padding: EdgeInsets.zero,
          itemBuilder: (BuildContext context, int i) => _tile(i),
        ),
      ),
    );
  }

  Widget _tile(int i) {
    final WalletWayData way = kWalletCashInWays[i];
    final bool last = i == kWalletCashInWays.length - 1;
    return Padding(
      // الصفُّ ينتهي 20 بعد آخر خانة، كما يبدأ.
      padding: EdgeInsetsDirectional.only(
        start: i == 0 ? PayWaysDesign.edge.w : PayWaysDesign.gap.w,
        end: last ? PayWaysDesign.edge.w : 0,
      ),
      child: SizedBox(
        width: PayWaysDesign.tile.w,
        // الخانةُ 125 والوسمُ يتدلّى، فالصفُّ ينتهي أسفلَ الوسم. والوسمُ
        // موضوعٌ بـ`Stack` لا بهامشٍ سالب.
        child: Stack(
          children: <Widget>[
            Semantics(
              button: !way.soon,
              label: way.translate ? way.name.tr() : way.name,
              child: XdTap(
                scale: way.soon ? 1 : 0.97,
                onTap: way.id == 'crypto' ? onCrypto : null,
                child: Container(
                  width: PayWaysDesign.tile.w,
                  height: PayWaysDesign.tile.w,
                  padding: EdgeInsets.all(PayWaysDesign.pad.w),
                  decoration: BoxDecoration(
                    color: XdColors.card,
                    borderRadius: BorderRadius.circular(PayWaysDesign.radius.r),
                  ),
                  foregroundDecoration: BoxDecoration(
                    border: Border.all(color: XdColors.line),
                    borderRadius: BorderRadius.circular(PayWaysDesign.radius.r),
                  ),
                  child: way.icon != null
                      ? Container(
                          width: PayWaysDesign.inner.w,
                          height: PayWaysDesign.inner.w,
                          decoration: BoxDecoration(
                            color: XdColors.white,
                            borderRadius: BorderRadius.circular(
                              PayWaysDesign.radius.r,
                            ),
                          ),
                          foregroundDecoration: BoxDecoration(
                            border: Border.all(color: XdColors.line),
                            borderRadius: BorderRadius.circular(
                              PayWaysDesign.radius.r,
                            ),
                          ),
                          child: XdSvg(
                            way.icon!,
                            folder: kWalletSvg,
                            w: PayWaysDesign.inner,
                          ),
                        )
                      : WalletImage(
                          name: way.picture!,
                          size: PayWaysDesign.inner,
                          radius: PayWaysDesign.radius,
                        ),
                ),
              ),
            ),
            if (way.soon)
              PositionedDirectional(
                top: PayWaysDesign.tagY.h,
                start: PayWaysDesign.tagX.w,
                child: _soon(),
              ),
          ],
        ),
      ),
    );
  }

  /// وسمُ «متاح قريباً»: 76 × 19 بزاوية 6.8 وخطٍّ باهتٍ، وكلمتُه 9 موسَّطة.
  Widget _soon() {
    return Container(
      width: PayWaysDesign.tagW.w,
      height: PayWaysDesign.tagH.h,
      decoration: BoxDecoration(
        color: XdColors.card,
        borderRadius: BorderRadius.circular(PayWaysDesign.tagRadius.r),
      ),
      foregroundDecoration: BoxDecoration(
        border: Border.all(color: XdColors.hint),
        borderRadius: BorderRadius.circular(PayWaysDesign.tagRadius.r),
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              top: Xd.gapTo(0, PayWaysDesign.tagBaseline, 9).h,
            ),
            child: XdText(
              LocaleKeys.soon_available.tr(),
              size: 9,
              align: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
