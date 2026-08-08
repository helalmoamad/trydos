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

  const SecondsCountdown({
    Key? key,
    required this.endTime,
    required this.visibleRedeem,
    required this.productId,
    this.denyStopTimer = false,
    this.finishRedeem,
  }) : super(key: key);

  @override
  State<SecondsCountdown> createState() => _SecondsCountdownState();
}

class _SecondsCountdownState extends State<SecondsCountdown> {
  // ⚡ الثواني المتبقّية في ValueNotifier: النبضة تعيد بناء الـ Text وحده
  final ValueNotifier<int> _secondsLeft = ValueNotifier<int>(0);
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
    timer?.cancel(); // أوقف المؤقت دائمًا
    _secondsLeft.dispose();
    if (widget.denyStopTimer) {
      super.dispose();
      return;
    }
    // خزّن عدد الثواني المتبقية عند التخلص من الودجت
    final now = DateTime.now();
    final diff = _endTime.difference(now);
    int secondsToSave = (diff.inSeconds) > 0 ? diff.inSeconds : 0;
    final prefs = GetIt.I<PrefsRepository>();
    prefs.setRedeemSecondRemainingForProduct(
      widget.productId.toString(),
      secondsToSave,
    );
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

  void _initTimer() {
    final prefs = GetIt.I<PrefsRepository>();
    int? savedSeconds = prefs.getRedeemSecondRemainingForProduct(
      widget.productId,
    );
    if (savedSeconds != null && savedSeconds > 0) {
      _endTime = DateTime.now().add(Duration(seconds: savedSeconds));
    } else {
      _endTime = widget.endTime;
    }
    _updateSeconds();
    // ضمان عدم بقاء مؤقّت سابق معلّقاً يضاعف النبضات
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateSeconds());
  }

  void _updateSeconds() {
    final now = DateTime.now();
    final diff = _endTime.difference(now);

    if (!mounted) return;

    final int secondsLeft = diff.inSeconds > 0 ? diff.inSeconds : 0;
    _secondsLeft.value = secondsLeft;
    if (secondsLeft == 0) {
      timer?.cancel();
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          widget.visibleRedeem.value = !widget.visibleRedeem.value;
          if (widget.finishRedeem != null) {
            widget.finishRedeem!.value = !(widget.finishRedeem!.value);
          }
        });
      }
      GetIt.I<PrefsRepository>().setRedeemSecondRemainingForProduct(
        widget.productId.toString(),
        0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // يُحسب مرة واحدة لكل build بدل كل نبضة ثانية
    final TextStyle? textStyle = context.textTheme.bodyMedium?.bq.copyWith(
      fontSize: 9,
      height: 1.5,
      color: const Color(0xffFF6200),
    );

    // عزل الرسم: نبضة الثانية تعيد رسم هذا النص وحده بدل طبقة البطاقة كاملة
    return RepaintBoundary(
      child: ValueListenableBuilder<int>(
        valueListenable: _secondsLeft,
        builder: (context, secondsLeft, _) =>
            Text('$secondsLeft', style: textStyle),
      ),
    );
  }
}
