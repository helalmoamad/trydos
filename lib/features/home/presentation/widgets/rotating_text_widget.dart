import 'dart:async';
import 'package:flutter/material.dart';

class RotatingTextWidget extends StatefulWidget {
  final List<String> texts;
  final TextStyle? textStyle;
  final Duration rotationDuration;
  final Widget Function(String text)? textBuilder;

  const RotatingTextWidget({
    Key? key,
    required this.texts,
    this.textStyle,
    this.rotationDuration = const Duration(seconds: 5),
    this.textBuilder,
  }) : super(key: key);

  @override
  State<RotatingTextWidget> createState() => _RotatingTextWidgetState();
}

class _RotatingTextWidgetState extends State<RotatingTextWidget> {
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startRotation();
  }

  void _startRotation() {
    // إذا كان هناك نص واحد فقط، لا نحتاج للتايمر
    if (widget.texts.length <= 1) return;

    _timer = Timer.periodic(widget.rotationDuration, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _currentIndex = (_currentIndex + 1) % widget.texts.length;
      });
    });
  }

  @override
  void didUpdateWidget(RotatingTextWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // إذا تغيرت القائمة، أعد تشغيل التايمر
    if (oldWidget.texts != widget.texts) {
      _timer?.cancel();
      _currentIndex = 0;
      _startRotation();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.texts.isEmpty) {
      return const SizedBox.shrink();
    }

    final currentText = widget.texts[_currentIndex];

    // عزل الرسم: تبديل النص كل خمس ثوانٍ كان يعيد رسم طبقة البطاقة كاملة
    return RepaintBoundary(
      child: widget.textBuilder != null
          ? widget.textBuilder!(currentText)
          : Text(currentText, style: widget.textStyle),
    );
  }
}
