import 'dart:async';
import 'package:flutter/material.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';

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
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    if (widget.texts.isEmpty) {
      return const SizedBox.shrink();
    }

    final currentText = widget.texts[_currentIndex];

    if (widget.textBuilder != null) {
      return widget.textBuilder!(currentText);
    }

    return Text(currentText, style: widget.textStyle);
  }
}
