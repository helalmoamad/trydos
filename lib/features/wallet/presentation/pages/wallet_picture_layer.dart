/// الصفحةُ البيضاء التي تُرسم عليها صورةُ رمزٍ — `PictureLayer` في
/// `web_design/components/DemoApp1/screens/WalletWithdrawalRequest.tsx`.
///
/// > ألواحُ `Home Page – 24` و`– 31` و`– 38`: الملفُّ لا يرسم شريطَ حالةٍ
/// > هناك، وصفُّ عنوان النافذة على y 66. وتقع فوق النافذة؛ واللمسةُ تُزيلها.
/// >
/// > والصفحةُ تُمرَّر داخل الطبقة إن كانت أطولَ من الشاشة.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:trydos/common/constant/design/xd_design.dart';

/// طبقةُ الصورة. تُوضع في `Stack` الصفحة فوق طبقة النافذة.
class WalletPictureLayer extends StatelessWidget {
  const WalletPictureLayer({
    super.key,
    required this.open,
    required this.onClose,
    required this.head,
    required this.children,
  });

  final bool open;
  final VoidCallback onClose;

  /// صفُّ عنوان النافذة والسطرُ تحته.
  final Widget head;

  final List<Widget> children;

  /// y صفّ العنوان على اللوح، وهو يبدأ 11 تحت كتلته.
  static const double headY = 66;

  @override
  Widget build(BuildContext context) {
    if (!open) return const SizedBox.shrink();
    return Positioned.fill(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 250),
        builder: (BuildContext context, double t, Widget? page) =>
            Opacity(opacity: t, child: page),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onClose,
          child: ColoredBox(
            color: XdColors.white,
            // داخلَ `Material` شفّافة: النصُّ خارجَها يُرسم بخطٍّ أصفرَ مزدوجٍ
            // تحته، وهذه طبقةٌ فوق `Scaffold` لا تحته.
            child: Material(
              type: MaterialType.transparency,
              child: SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          top: (headY - Xd.statusBar - 11).h,
                        ),
                        child: head,
                      ),
                      ...children,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
