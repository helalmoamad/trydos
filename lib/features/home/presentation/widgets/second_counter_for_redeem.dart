import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';

class SecondsCountdown extends StatefulWidget {
  final DateTime endTime;
  final ValueNotifier<bool> visibleRedeem;
  final ValueNotifier<bool>? finishRedeem;
  final String productId;
  final bool denyStopTimer;

  const SecondsCountdown(
      {Key? key,
      required this.endTime,
      required this.visibleRedeem,
      required this.productId,
      this.denyStopTimer = false,
      this.finishRedeem})
      : super(key: key);

  @override
  State<SecondsCountdown> createState() => _SecondsCountdownState();
}

class _SecondsCountdownState extends State<SecondsCountdown> {
  late int secondsLeft;
  Timer? timer;
  late DateTime _endTime;
  String? _lastProductId;

  @override
  void initState() {
    super.initState();
    _initTimer();
    _lastProductId = widget.productId;
  }

  @override
  void dispose() {
    if (widget.denyStopTimer) {
      return;
    }
    // خزّن عدد الثواني المتبقية عند التخلص من الودجت
    final now = DateTime.now();
    final diff = _endTime.difference(now);
    int secondsToSave = (diff.inSeconds) > 0 ? diff.inSeconds : 0;
    final prefs = GetIt.I<PrefsRepository>();
    prefs.setRedeemSecondRemainingForProduct(
        widget.productId.toString(), secondsToSave);

    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SecondsCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.denyStopTimer) {
      return;
    }
    // إذا تغير المنتج أو وقت النهاية
    if (widget.productId != _lastProductId ||
        widget.endTime != oldWidget.endTime) {
      timer?.cancel();
      _initTimer();
      _lastProductId = widget.productId;
    }
  }

  Future<void> _initTimer() async {
    final prefs = GetIt.I<PrefsRepository>();
    int? savedSeconds =
        prefs.getRedeemSecondRemainingForProduct(widget.productId);
    if (savedSeconds != null && savedSeconds > 0) {
      _endTime = DateTime.now().add(Duration(seconds: savedSeconds));
    } else {
      _endTime = widget.endTime;
    }
    _updateSeconds();
    timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateSeconds());
  }

  void _updateSeconds() {
    final now = DateTime.now();
    final diff = _endTime.difference(now);

    if (!mounted) return;

    setState(() {
      secondsLeft = diff.inSeconds > 0 ? diff.inSeconds : 0;
    });
    if (secondsLeft == 0) {
      GetIt.I<PrefsRepository>()
          .setRedeemSecondRemainingForProduct(widget.productId.toString(), 0);
      timer?.cancel();
      widget.visibleRedeem.value = !widget.visibleRedeem.value;
      widget.finishRedeem?.value = !(widget.finishRedeem?.value ?? false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text('$secondsLeft',
        style: context.textTheme.bodyMedium?.br.copyWith(
          fontSize: 9,
          height: 1.5,
          color: Color(0xffFF6200),
        ));
  }
}
