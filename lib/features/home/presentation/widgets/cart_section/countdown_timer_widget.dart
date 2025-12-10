import 'dart:async';
import 'package:flutter/material.dart';

class CountdownTimerWidget extends StatefulWidget {
  final int initialMinutes;
  final TextStyle? textStyle;

  const CountdownTimerWidget({
    Key? key,
    required this.initialMinutes,
    this.textStyle,
  }) : super(key: key);

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // تحويل الدقائق إلى ثواني
    _remainingSeconds = widget.initialMinutes * 60;
    _startTimer();
  }

  @override
  void didUpdateWidget(CountdownTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // إذا تغيرت القيمة الأولية، نعيد تشغيل المؤقت
    if (oldWidget.initialMinutes != widget.initialMinutes) {
      _remainingSeconds = widget.initialMinutes * 60;
      _timer?.cancel();
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        if (mounted) {
          setState(() {
            _remainingSeconds--;
          });
        }
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime() {
    final hours = _remainingSeconds ~/ 3600;
    final minutes = (_remainingSeconds % 3600) ~/ 60;
    final seconds = _remainingSeconds % 60;

    // إذا كانت الساعات = 0، نعرض فقط الدقائق والثواني
    if (hours == 0) {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }

    // إذا كانت الساعات أكبر من 0، نعرض الساعات والدقائق والثواني
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Text(_formatTime(), style: widget.textStyle);
  }
}
