import 'dart:async';
import 'package:flutter/material.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';

class SecondsCountdown extends StatefulWidget {
  final DateTime endTime;
  final ValueNotifier<bool> visibleRedeem;
  final ValueNotifier<bool>? finishRedeem;

  const SecondsCountdown(
      {Key? key,
      required this.endTime,
      required this.visibleRedeem,
      this.finishRedeem})
      : super(key: key);

  @override
  State<SecondsCountdown> createState() => _SecondsCountdownState();
}

class _SecondsCountdownState extends State<SecondsCountdown> {
  late int secondsLeft;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _updateSeconds();
    timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateSeconds());
  }

  void _updateSeconds() {
    final now = DateTime.now();
    final diff = widget.endTime.difference(now);

    setState(() {
      secondsLeft = diff.inSeconds > 0 ? diff.inSeconds : 0;
    });
    if (secondsLeft == 0) {
      timer?.cancel();
      widget.visibleRedeem.value = !widget.visibleRedeem.value;
      widget.finishRedeem?.value = !(widget.finishRedeem?.value ?? false);
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text('$secondsLeft',
        style: context.textTheme.bodyMedium?.br.copyWith(
          fontSize: 12,
          height: 1.5,
          color: const Color.fromARGB(
              255, 250, 71, 16), // يمكنك تغيير الحجم حسب رغبتك
        ));
  }
}
