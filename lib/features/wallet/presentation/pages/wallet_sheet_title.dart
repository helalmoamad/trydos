import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:trydos/common/constant/design/xd_svg.dart';

import '../../wallet_config.dart';

/// صفُّ عنوانٍ في نوافذ المحفظة — `SheetTitle` في `WalletCashOutSheet.tsx`.
///
/// ثلاثة أعمدة: أيقونةٌ 30 على x 24 وعلامةُ العملة بعدها على x 58 (تنزل 5)،
/// والعنوان 24 موسَّطاً على الشاشة. والصفُّ يبدأ 11 تحت حافّة النافذة
/// (`top + 24` من `top + 13`).
class WalletSheetTitle extends StatelessWidget {
  const WalletSheetTitle({
    super.key,
    required this.top,
    required this.icon,
    required this.mark,
    required this.label,
    this.weight = XdWeight.bold,
    this.nudge = 0,
  });

  /// y حافّة النافذة العليا على اللوح.
  final double top;

  final String icon;

  /// علامةُ العملة.
  final String mark;

  final String label;

  /// Bold في كلّ نافذةٍ إلّا «طرق الإيداع» (`– 22`): Medium.
  final XdWeight weight;

  /// كم يُزيح الملفُّ العنوان عن المركز (الموجب يميناً).
  final double nudge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: (top + 24 - (top + 13)).h),
      // بعرض النافذة: الملفُّ يجعل الصفَّ شبكةً من ثلاثة أعمدة
      // (`1fr | auto | 1fr`)، فيحلّ العنوانُ في وسطها موسَّطاً على النافذة.
      // و`Stack` بلا عرضٍ يلتفّ حول العنوان فيُسنَد إلى أوّل العمود — فكان
      // العنوانُ في الطرف لا في المنتصف.
      child: SizedBox(
        width: 1.sw,
        child: Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            PositionedDirectional(
              start: 24.w,
              top: 0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  XdSvg(icon, folder: kWalletSvg, w: 30),
                  SizedBox(width: (58 - (24 + 30)).w),
                  Padding(
                    padding: EdgeInsets.only(top: 5.h),
                    child: XdSvg(mark, folder: kWalletSvg, w: 20),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: nudge > 0 ? (nudge * 2).w : 0,
                right: nudge < 0 ? (-nudge * 2).w : 0,
              ),
              child: XdText(label, size: 24, weight: weight),
            ),
          ],
        ),
      ),
    );
  }
}
