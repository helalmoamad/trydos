import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// الأيقونات التي لا يرسمها ملف XD: الجمع والكاميرا والميكروفون والإرسال
/// والإغلاق، ونقطة التسجيل، وشيفرون «اسحب للإلغاء».
///
/// منقولةٌ من `web_design/components/DemoApp1/chat/chatIcons.tsx` — نفس
/// مسارات الرسم ونفس سماكة الخطّ.
///
/// مرسومةٌ بـ`CustomPainter` لا بملفّات SVG: مصدرها كودٌ في الويب لا ملفّ
/// مقصوص، وهكذا يبقى اللون والمقاس حرّين كما في الأصل.
///
/// كلّها على شبكة `24×24` كما في الويب، عدا نقطة التسجيل على `10×10`.
abstract class ChatIconsV2 {
  /// سماكة الخطّ الافتراضية في الملف.
  static const double stroke = 1.7;

  static Widget plus({double size = 24, required Color color}) =>
      _LineIcon(size: size, color: color, painter: _PlusPainter());

  static Widget camera({double size = 22, required Color color}) =>
      _LineIcon(size: size, color: color, painter: _CameraPainter());

  static Widget mic({double size = 22, required Color color}) =>
      _LineIcon(size: size, color: color, painter: _MicPainter());

  /// سهم الإرسال — سماكته 1.9 لا 1.7.
  static Widget send({double size = 22, required Color color}) =>
      _LineIcon(size: size, color: color, width: 1.9, painter: _SendPainter());

  static Widget close({double size = 18, required Color color}) =>
      _LineIcon(size: size, color: color, painter: _ClosePainter());

  /// الشيفرون الصغير قبل «اسحب للإلغاء» — سماكته 2.
  static Widget chevronStart({double size = 14, required Color color}) =>
      _LineIcon(size: size, color: color, width: 2, painter: _ChevronPainter());

  /// النقطة الحمراء التي تنبض أثناء التسجيل — دائرةٌ ممتلئة 10×10.
  static Widget recordDot({required Color color}) => _RecordDot(color: color);
}

/// غلافٌ يضبط المقاس ويحوّل شبكة 24 إلى المقاس المطلوب.
class _LineIcon extends StatelessWidget {
  const _LineIcon({
    required this.size,
    required this.color,
    required this.painter,
    this.width = ChatIconsV2.stroke,
  });

  final double size;
  final Color color;
  final CustomPainter Function(Color, double) painter;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.w,
      height: size.w,
      child: CustomPaint(painter: painter(color, width)),
    );
  }
}

/// يضبط الفرشاة ويقيس من شبكة 24 إلى مقاس الرسم.
Paint _pen(Color color, double width, Size size) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = width * (size.width / 24)
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

double _s(Size size, double v) => v * (size.width / 24);

typedef _P = CustomPainter Function(Color, double);

_P _PlusPainter() =>
    (color, width) => _Plus(color, width);
_P _CameraPainter() =>
    (color, width) => _Camera(color, width);
_P _MicPainter() =>
    (color, width) => _Mic(color, width);
_P _SendPainter() =>
    (color, width) => _Send(color, width);
_P _ClosePainter() =>
    (color, width) => _Close(color, width);
_P _ChevronPainter() =>
    (color, width) => _Chevron(color, width);

/// `M12 5v14M5 12h14`
class _Plus extends CustomPainter {
  _Plus(this.color, this.width);
  final Color color;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint pen = _pen(color, width, size);
    canvas.drawLine(
      Offset(_s(size, 12), _s(size, 5)),
      Offset(_s(size, 12), _s(size, 19)),
      pen,
    );
    canvas.drawLine(
      Offset(_s(size, 5), _s(size, 12)),
      Offset(_s(size, 19), _s(size, 12)),
      pen,
    );
  }

  @override
  bool shouldRepaint(_Plus old) => old.color != color || old.width != width;
}

/// جسم الكاميرا ودائرة العدسة.
class _Camera extends CustomPainter {
  _Camera(this.color, this.width);
  final Color color;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint pen = _pen(color, width, size);
    final Path body = Path()
      ..moveTo(_s(size, 4), _s(size, 8.5))
      ..arcToPoint(
        Offset(_s(size, 6.5), _s(size, 6)),
        radius: Radius.circular(_s(size, 2.5)),
      )
      ..lineTo(_s(size, 8.1), _s(size, 6))
      ..lineTo(_s(size, 9.2), _s(size, 4.3))
      ..cubicTo(
        _s(size, 9.5),
        _s(size, 3.9),
        _s(size, 9.9),
        _s(size, 3.7),
        _s(size, 10.4),
        _s(size, 3.7),
      )
      ..lineTo(_s(size, 13.6), _s(size, 3.7))
      ..cubicTo(
        _s(size, 14.1),
        _s(size, 3.7),
        _s(size, 14.5),
        _s(size, 3.9),
        _s(size, 14.8),
        _s(size, 4.3),
      )
      ..lineTo(_s(size, 15.9), _s(size, 6))
      ..lineTo(_s(size, 17.5), _s(size, 6))
      ..arcToPoint(
        Offset(_s(size, 20), _s(size, 8.5)),
        radius: Radius.circular(_s(size, 2.5)),
      )
      ..lineTo(_s(size, 20), _s(size, 16.5))
      ..arcToPoint(
        Offset(_s(size, 17.5), _s(size, 19)),
        radius: Radius.circular(_s(size, 2.5)),
      )
      ..lineTo(_s(size, 6.5), _s(size, 19))
      ..arcToPoint(
        Offset(_s(size, 4), _s(size, 16.5)),
        radius: Radius.circular(_s(size, 2.5)),
      )
      ..close();
    canvas.drawPath(body, pen);
    canvas.drawCircle(Offset(_s(size, 12), _s(size, 12.5)), _s(size, 3.4), pen);
  }

  @override
  bool shouldRepaint(_Camera old) => old.color != color || old.width != width;
}

/// كبسولة الميكروفون وقوسه وساقه وقاعدته.
class _Mic extends CustomPainter {
  _Mic(this.color, this.width);
  final Color color;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint pen = _pen(color, width, size);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(_s(size, 9), _s(size, 3.5), _s(size, 6), _s(size, 11)),
        Radius.circular(_s(size, 3)),
      ),
      pen,
    );
    // قوسٌ نصف دائري من (6, 11.5) إلى (18, 11.5).
    canvas.drawArc(
      Rect.fromLTRB(_s(size, 6), _s(size, 5.5), _s(size, 18), _s(size, 17.5)),
      0,
      3.14159265,
      false,
      pen,
    );
    canvas.drawLine(
      Offset(_s(size, 12), _s(size, 17.5)),
      Offset(_s(size, 12), _s(size, 20.5)),
      pen,
    );
    canvas.drawLine(
      Offset(_s(size, 9.5), _s(size, 20.5)),
      Offset(_s(size, 14.5), _s(size, 20.5)),
      pen,
    );
  }

  @override
  bool shouldRepaint(_Mic old) => old.color != color || old.width != width;
}

/// `M12 19V5.5M6.5 11 12 5.5l5.5 5.5` — سهمٌ لأعلى.
class _Send extends CustomPainter {
  _Send(this.color, this.width);
  final Color color;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint pen = _pen(color, width, size);
    canvas.drawLine(
      Offset(_s(size, 12), _s(size, 19)),
      Offset(_s(size, 12), _s(size, 5.5)),
      pen,
    );
    final Path head = Path()
      ..moveTo(_s(size, 6.5), _s(size, 11))
      ..lineTo(_s(size, 12), _s(size, 5.5))
      ..lineTo(_s(size, 17.5), _s(size, 11));
    canvas.drawPath(head, pen);
  }

  @override
  bool shouldRepaint(_Send old) => old.color != color || old.width != width;
}

/// `m7 7 10 10M17 7 7 17`
class _Close extends CustomPainter {
  _Close(this.color, this.width);
  final Color color;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint pen = _pen(color, width, size);
    canvas.drawLine(
      Offset(_s(size, 7), _s(size, 7)),
      Offset(_s(size, 17), _s(size, 17)),
      pen,
    );
    canvas.drawLine(
      Offset(_s(size, 17), _s(size, 7)),
      Offset(_s(size, 7), _s(size, 17)),
      pen,
    );
  }

  @override
  bool shouldRepaint(_Close old) => old.color != color || old.width != width;
}

/// `m14.5 6-6 6 6 6`
class _Chevron extends CustomPainter {
  _Chevron(this.color, this.width);
  final Color color;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint pen = _pen(color, width, size);
    final Path path = Path()
      ..moveTo(_s(size, 14.5), _s(size, 6))
      ..lineTo(_s(size, 8.5), _s(size, 12))
      ..lineTo(_s(size, 14.5), _s(size, 18));
    canvas.drawPath(path, pen);
  }

  @override
  bool shouldRepaint(_Chevron old) => old.color != color || old.width != width;
}

/// النقطة الحمراء — دائرةٌ ممتلئة نصف قطرها 5 على شبكة 10.
class _RecordDot extends StatelessWidget {
  const _RecordDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10.w,
      height: 10.w,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
