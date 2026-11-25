/// «شروط الخدمة» — نقلٌ لـ`web_design/NewLoginDesign/NewTermsScreen.tsx`.
///
/// > من أعلى إلى أسفل:
/// >   - الشعارُ في موضعه المنخفض (390) — رقمُ «ابدأ» نفسُه، فلا ينزلق بينهما؛
/// >   - فقرةُ الشروط 14 على عرض الصندوق (390 على x 20)، موسَّطةً بارتفاع
/// >     سطرٍ 1.43 — وهي كتلةٌ تلتفّ، فتأخذ ارتفاعَ سطرها من الملفّ لا 1.25
/// >     الذي للسطر الواحد. ولونٌ واحدٌ ووزنٌ واحد: الملفُّ لا يُثخّن اسمَ
/// >     المنتَج؛
/// >   - أيقونةُ الشروط 25 على (202، 688)؛
/// >   - «شروط الخدمة» 14 `#388CFF` على 721؛
/// >   - «أوافق وأتابع» على 789، و«لاحقاً…» على 879.
library;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:trydos/common/constant/design/xd_design.dart';
import 'package:trydos/common/constant/design/xd_svg.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import 'auth_design.dart';
import 'auth_logo.dart';
import 'auth_parts.dart';

class TermsScreenV2 extends StatelessWidget {
  const TermsScreenV2({super.key, this.onAgree, this.onLater});

  final VoidCallback? onAgree;
  final VoidCallback? onLater;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        double up(double top) => box.maxHeight - authFromBottom(top).h;

        return AuthBoard(
          children: <Widget>[
            Positioned(
              top: up(AuthXd.termsBody),
              left: AuthXd.boxLeft.w,
              child: SizedBox(
                width: Xd.fill(AuthXd.boxLeft),
                child: Text(
                  '${LocaleKeys.to_create_account_tap_agree.tr()} Trydos '
                  '${LocaleKeys.terms_of_services.tr()}',
                  textAlign: TextAlign.center,
                  style: xdTextStyle(
                    size: 14,
                    // ارتفاعُ سطر الملفّ 1.43 من المقاس، لا صندوقُ السطر
                    // الواحد.
                    height: 14 * AuthXd.termsBodyLineHeight,
                  ),
                ),
              ),
            ),
            Positioned(
              top: up(AuthXd.termsIconTop),
              left: AuthXd.termsIconLeft.w,
              child: SvgPicture.asset(
                'assets/svg/$kAuthSvg/terms.svg',
                width: AuthXd.termsIconSize.w,
                height: AuthXd.termsIconSize.w,
              ),
            ),
            AuthCentredLine(
              top: up(AuthXd.termsLinkLine),
              text: LocaleKeys.terms_of_services.tr(),
              size: 14,
              color: AuthColors.termsLink,
            ),
            AuthWideButton(
              top: up(AuthXd.ctaPrimary),
              label: LocaleKeys.agree_continue.tr(),
              onTap: onAgree,
              fill: AuthColors.buttonAgree,
              ink: AuthColors.buttonAgreeInk,
            ),
            if (onLater != null)
              AuthCentredLine(
                top: up(AuthXd.ctaLink),
                text: LocaleKeys.later_take_look.tr(),
                size: 14,
                color: AuthColors.link,
                onTap: onLater,
              ),
          ],
        );
      },
    );
  }
}
