/// رمزُ QR بشكل رموز المحفظة.
///
/// > شكلُه المعتمَد — كما في رمز الإيداع النقديّ:
/// >   - **العيونُ الثلاث** حلقاتٌ شبهُ دائريّة: مربّعٌ 7 وحداتٍ بزاويةٍ
/// >     واسعة، مثقوبٌ بمربّعٍ 5 بالزاوية نفسِها، وفي قلبه مربّعٌ 3 مصمَت؛
/// >   - **وحداتُ البيانات** مربّعاتٌ صغيرةٌ **متباعدة**: كلُّ وحدةٍ أصغرُ
/// >     من خانتها فيبقى بينها فراغٌ أبيض، وزواياها مخفَّفة — فلا هي دوائرُ
/// >     ولا مربّعاتٌ حادّة.
///
/// وهو شكلُ **كلّ** رمزٍ في صفحات المحفظة: ما يُقصّ من الملفّ وما يُولَّد هنا
/// (معلوماتُ المحفظة من معرّف العميل، والإيصالُ من رقمه).
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:trydos/common/constant/design/xd_design.dart';

class WalletQr extends StatelessWidget {
  const WalletQr({
    super.key,
    required this.data,
    required this.size,
    this.color = XdColors.ink,
  });

  /// ما يحمله الرمز.
  final String data;

  /// ضلعُه ببكسل التصميم.
  final double size;

  final Color color;

  /// كم تملأ وحدةُ البيانات خانتَها — والباقي فراغٌ بينها وبين جاراتها.
  static const double moduleFill = 0.82;

  /// تخفيفُ الزوايا، نسبةً من ضلع ما تُرسم عليه: الوحدةُ وصناديقُ العين.
  static const double round = 0.28;

  /// العينُ 7 وحدات، وثقبُها 5، وقلبُها 3.
  static const int eye = 7;
  static const int eyeHole = 5;
  static const int eyeCore = 3;

  @override
  Widget build(BuildContext context) {
    final QrCode code = QrCode.fromData(
      data: data,
      errorCorrectLevel: QrErrorCorrectLevel.L,
    );
    return SizedBox(
      width: size.w,
      height: size.w,
      child: CustomPaint(
        painter: _WalletQrPainter(image: QrImage(code), color: color),
      ),
    );
  }
}

class _WalletQrPainter extends CustomPainter {
  const _WalletQrPainter({required this.image, required this.color});

  final QrImage image;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final int count = image.moduleCount;
    if (count == 0) return;
    final double cell = size.width / count;
    final Paint paint = Paint()
      ..color = color
      ..isAntiAlias = true;

    // العيونُ الثلاث: أعلى اليسار، وأعلى اليمين، وأسفل اليسار.
    for (final (int row, int col) corner in <(int, int)>[
      (0, 0),
      (0, count - WalletQr.eye),
      (count - WalletQr.eye, 0),
    ]) {
      _paintEye(canvas, paint, cell, corner.$1, corner.$2);
    }

    // وحداتُ البيانات، وما وقع في مربّع عينٍ تَرَكه الرسمُ للعين.
    final double module = cell * WalletQr.moduleFill;
    final double inset = (cell - module) / 2;
    final Radius radius = Radius.circular(module * WalletQr.round);
    for (int row = 0; row < count; row++) {
      for (int col = 0; col < count; col++) {
        if (!image.isDark(row, col)) continue;
        if (_inEye(row, col, count)) continue;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              col * cell + inset,
              row * cell + inset,
              module,
              module,
            ),
            radius,
          ),
          paint,
        );
      }
    }
  }

  /// مربّعُ عينٍ 7 × 7 في أحد الأركان الثلاثة.
  bool _inEye(int row, int col, int count) {
    const int n = WalletQr.eye;
    final bool top = row < n;
    final bool bottom = row >= count - n;
    final bool left = col < n;
    final bool right = col >= count - n;
    return (top && left) || (top && right) || (bottom && left);
  }

  /// حلقةٌ شبهُ دائريّة وقلبٌ مصمَت.
  void _paintEye(Canvas canvas, Paint paint, double cell, int row, int col) {
    Rect box(int units) {
      final double gap = (WalletQr.eye - units) / 2 * cell;
      return Rect.fromLTWH(
        col * cell + gap,
        row * cell + gap,
        units * cell,
        units * cell,
      );
    }

    RRect soft(int units) => RRect.fromRectAndRadius(
      box(units),
      Radius.circular(units * cell * WalletQr.round),
    );

    // الحلقةُ مسارٌ واحدٌ بثقبٍ، فلا تحتاج لوناً خلفها.
    canvas.drawPath(
      Path()
        ..addRRect(soft(WalletQr.eye))
        ..addRRect(soft(WalletQr.eyeHole))
        ..fillType = PathFillType.evenOdd,
      paint,
    );
    canvas.drawRRect(soft(WalletQr.eyeCore), paint);
  }

  @override
  bool shouldRepaint(_WalletQrPainter old) =>
      old.image != image || old.color != color;
}
