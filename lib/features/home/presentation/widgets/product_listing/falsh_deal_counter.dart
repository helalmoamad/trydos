import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/language_service.dart';
import 'dart:ui' as ui;
import 'package:trydos/core/utils/last_pages_tracker.dart';

class FlashDealCountdownTimerWidget extends StatefulWidget {
  final String endDateString;
  // صيغة MM/dd/yyyy
  final ValueNotifier<bool>? visibleFlashDeal;
  final ValueNotifier<bool>? refreshFlashDeal;

  const FlashDealCountdownTimerWidget(
      {Key? key,
      required this.endDateString,
      required this.visibleFlashDeal,
      this.refreshFlashDeal})
      : super(key: key);

  @override
  _FlashDealCountdownTimerWidgetState createState() =>
      _FlashDealCountdownTimerWidgetState();
}

class _FlashDealCountdownTimerWidgetState
    extends State<FlashDealCountdownTimerWidget> {
  late DateTime endDate;
  Timer? _timer; // يجب أن يكون nullable بدون late
  Duration _duration = const Duration();

  @override
  void initState() {
    super.initState();
    _parseEndDate();
    _startTimer();
  }

  @override
  void didUpdateWidget(FlashDealCountdownTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // إذا تغيرت endDateString، أعد تحليل التاريخ وابدأ التايمر من جديد
    if (oldWidget.endDateString != widget.endDateString) {
      _timer?.cancel();
      _parseEndDate();
      _startTimer();
    }
  }

  void _parseEndDate() {
    try {
      endDate = DateFormat('MM/dd/yyyy', 'en_US').parse(widget.endDateString);
      endDate = endDate.add(const Duration(days: 1));
    } catch (e) {
      endDate = DateTime.now();
      print('Error parsing date: $e');
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final now = DateTime.now();
      setState(() {
        _duration = endDate.difference(now);
        if (_duration.isNegative) {
          widget.refreshFlashDeal?.value = !widget.refreshFlashDeal!.value;
          widget.visibleFlashDeal?.value = !widget.visibleFlashDeal!.value;
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

    return '|${days} ${LocaleKeys.day.tr()}|${hours}:${minutes}:${seconds}';
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return Directionality(
        textDirection: LanguageService.languageCode == "ar"
            ? ui.TextDirection.rtl
            : ui.TextDirection.ltr,
        child: Container(
          alignment: LanguageService.languageCode == "ar"
              ? Alignment.centerRight
              : Alignment.centerLeft,
          height: 20,
          child: Text(
            _duration > Duration.zero ? _formatDuration(_duration) : "",
            style: context.textTheme.bodyMedium?.mr.copyWith(
              color: const Color(0xffFF6200),
              letterSpacing: 0.18,
              fontSize: 9.sp,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ));
  }
}
