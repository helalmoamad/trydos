import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FlashDealCountdownTimerWidget extends StatefulWidget {
  final String endDateString; // صيغة MM/dd/yyyy

  const FlashDealCountdownTimerWidget({Key? key, required this.endDateString})
      : super(key: key);

  @override
  _FlashDealCountdownTimerWidgetState createState() =>
      _FlashDealCountdownTimerWidgetState();
}

class _FlashDealCountdownTimerWidgetState
    extends State<FlashDealCountdownTimerWidget> {
  late DateTime endDate;
  Timer? _timer; // يجب أن يكون nullable بدون late
  Duration _duration = Duration();

  @override
  void initState() {
    super.initState();

    try {
      endDate = DateFormat('MM/dd/yyyy', 'en_US').parse(widget.endDateString);
    } catch (e) {
      endDate = DateTime.now();
      print('Error parsing date: $e');
    }

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final now = DateTime.now();
      setState(() {
        _duration = endDate.difference(now);
        if (_duration.isNegative) {
          _duration = Duration.zero;
          _timer?.cancel();
          _timer = null;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    return '${days}d ${hours}h ${minutes}m ${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: 100,
      height: 20,
      child: Text(
        _duration > Duration.zero ? _formatDuration(_duration) : "",
        style: TextStyle(
          color: Colors.white,
          letterSpacing: 0.18,
          fontSize: 10,
          height: 1.3,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
