/// «ابدأ» — نقلٌ لـ`web_design/NewLoginDesign/NewGetStartedScreen.tsx`.
///
/// > من أعلى إلى أسفل:
/// >   - ماسحُ QR في الزاوية، 25 على (الحافّة − 30، 60)؛
/// >   - الشعارُ في موضعه المنخفض (390)، وهو موضعُ «الشروط» نفسُه — فلا
/// >     ينزلق حين تنزلق الشاشة؛
/// >   - «. ابدأ .» 30 Bold على 649؛
/// >   - «لديّ حسابٌ سلفاً» على 721، و«زبونٌ جديد» على 789؛
/// >   - «لاحقاً، ألقِ نظرةً على التطبيق» 14 `#4D84FF` على 879.
/// >
/// > وكلُّ ما تحت الشعار يحفظ مسافتَه من **أسفل** الشاشة ([authFromBottom])،
/// > فيصعد مع الأزرار على هاتفٍ أقصرَ من اللوح.
///
/// > والعنوانُ موسَّطٌ توسيطاً تامّاً. يبدو على اللوح أيسرَ قليلاً، وليس ذلك
/// > إلّا من النقطة والفراغ اللذين يسبقانه — وهي عينٌ لا قياس.
library;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:trydos/common/constant/design/xd_svg.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import 'auth_design.dart';
import 'auth_parts.dart';

class GetStartedScreenV2 extends StatelessWidget {
  const GetStartedScreenV2({
    super.key,
    this.onExistingAccount,
    this.onNewCustomer,
    this.onLater,
    this.onScanQr,
  });

  final VoidCallback? onExistingAccount;
  final VoidCallback? onNewCustomer;
  final VoidCallback? onLater;
  final VoidCallback? onScanQr;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        /// y على الشاشة لكتلةٍ يحفظ الملفُّ مسافتَها من أسفل اللوح.
        double up(double top) => box.maxHeight - authFromBottom(top).h;

        return AuthBoard(
          children: <Widget>[
            if (onScanQr != null)
              AuthCorner(
                icon: 'qrlogin',
                size: AuthXd.controlQrSize,
                onTap: onScanQr!,
                semantics: LocaleKeys.scan_qr_code.tr(),
              ),
            AuthCentredLine(
              top: up(AuthXd.getStartedTitle),
              text: LocaleKeys.get_started_dotted.tr(),
              size: 30,
              weight: XdWeight.bold,
            ),
            AuthWideButton(
              top: up(AuthXd.ctaSecond),
              label: LocaleKeys.i_have_account.tr(),
              onTap: onExistingAccount,
            ),
            AuthWideButton(
              top: up(AuthXd.ctaPrimary),
              label: LocaleKeys.new_customer.tr(),
              onTap: onNewCustomer,
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
