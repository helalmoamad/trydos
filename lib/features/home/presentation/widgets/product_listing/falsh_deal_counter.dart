import 'package:flutter/foundation.dart' hide Category;
import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/language_service.dart';
import 'dart:ui' as ui;

class FlashDealCountdownTimerWidget extends StatefulWidget {
  final DateTime endDateTime;
  // صيغة MM/dd/yyyy
  final ValueNotifier<bool>? visibleFlashDeal;
  final ValueNotifier<bool>? refreshFlashDeal;

  const FlashDealCountdownTimerWidget({
    Key? key,
    required this.endDateTime,
    required this.visibleFlashDeal,
    this.refreshFlashDeal,
  }) : super(key: key);

  @override
  _FlashDealCountdownTimerWidgetState createState() =>
      _FlashDealCountdownTimerWidgetState();
}

class _FlashDealCountdownTimerWidgetState
    extends State<FlashDealCountdownTimerWidget> {
  late DateTime endDate;
  Timer? _timer; // يجب أن يكون nullable بدون late
  // ⚡ الوقت المتبقّي في ValueNotifier: النبضة كل ثانية تعيد بناء الـ Text وحده
  final ValueNotifier<Duration> _duration = ValueNotifier<Duration>(
    Duration.zero,
  );

  @override
  void initState() {
    super.initState();
    _parseEndDate();
    _startTimer();
  }

  @override
  void didUpdateWidget(FlashDealCountdownTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // إذا تغيّر وقت النهاية، أعد تحليل التاريخ وابدأ التايمر من جديد
    if (oldWidget.endDateTime != widget.endDateTime) {
      _timer?.cancel();
      _parseEndDate();
      _startTimer();
    }
  }

  void _parseEndDate() {
    try {
      endDate = widget.endDateTime;
    } catch (e) {
      endDate = DateTime.now();
      if (kDebugMode) print('Error parsing date: $e');
    }
    final Duration remaining = endDate.difference(DateTime.now());
    _duration.value = remaining.isNegative ? Duration.zero : remaining;
  }

  void _startTimer() {
    // ضمان عدم بقاء مؤقّت سابق معلّقاً يضاعف النبضات
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final Duration remaining = endDate.difference(DateTime.now());
      if (remaining.isNegative) {
        widget.refreshFlashDeal?.value = !widget.refreshFlashDeal!.value;
        widget.visibleFlashDeal?.value = !widget.visibleFlashDeal!.value;
        _duration.value = Duration.zero;
        _timer?.cancel();
        _timer = null;
        return;
      }
      _duration.value = remaining;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _duration.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    return '|${days} ${LocaleKeys.day.tr()}|${hours}:${minutes}:${seconds}';
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = LanguageService.languageCode == "ar";
    // يُحسب مرة واحدة لكل build بدل كل نبضة ثانية
    final TextStyle? textStyle = context.textTheme.bodyMedium?.mq.copyWith(
      color: const Color(0xffFF6200),
      letterSpacing: 0.18,
      fontSize: 9.sp,
      height: 1.3,
    );

    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Container(
        alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
        height: 20.h,
        // عزل الرسم: نبضة الثانية تعيد رسم هذا النص وحده بدل طبقة البطاقة كاملة
        child: RepaintBoundary(
          child: ValueListenableBuilder<Duration>(
            valueListenable: _duration,
            builder: (context, duration, _) => Text(
              duration > Duration.zero ? _formatDuration(duration) : "",
              style: textStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
