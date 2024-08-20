import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/config/theme/typography.dart';

import '../../../../core/utils/theme_state.dart';
import '../../../app/my_text_widget.dart';

class OfferTimeWidget extends StatefulWidget {
  const OfferTimeWidget({super.key});

  @override
  State<OfferTimeWidget> createState() => _OfferTimeWidgetState();
}

class _OfferTimeWidgetState extends ThemeState<OfferTimeWidget> {
  late CountdownTimerController controller;
  late int endTime;
  int secondsDuration = 5237;

  void onEnd() {
    controller.disposeTimer();
  }

  @override
  void initState() {
    endTime = DateTime.now().millisecondsSinceEpoch + 1000 * secondsDuration;
    controller = CountdownTimerController(endTime: endTime, onEnd: onEnd);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MyTextWidget('-',
            style: textTheme.displayMedium?.mr.copyWith(
              letterSpacing: 0.4,
              height: 1.31,
              color: const Color(0xff3c3c3c),
            )),
        SizedBox(
          width: 5,
        ),
        Row(
          children: [
            Container(
              width: 28.w,
              height: 26,
              decoration: BoxDecoration(
                color: const Color(0xff3c3c3c),
                borderRadius: BorderRadius.circular(7.0),
              ),
              child: Center(
                  child: CountdownTimer(
                widgetBuilder: (_, remainingTime) {
                  return MyTextWidget(
                      '${remainingTime?.hours == null ? '00' : remainingTime!.hours! < 10 ? '0${remainingTime.hours}' : remainingTime.hours}',
                      style: textTheme.titleLarge?.mr.copyWith(
                        letterSpacing: 0.35,
                        height: 1.35,
                        color: const Color(0xffffffcc),
                      ));
                },
                controller: controller,
                onEnd: onEnd,
                endTime: endTime,
                endWidget: const SizedBox(),
              )),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: MyTextWidget(
                ':',
                style: textTheme.displayMedium?.mr.copyWith(
                  letterSpacing: 0.4,
                  height: 1.31,
                  color: const Color(0xff3c3c3c),
                ),
              ),
            ),
            Container(
              width: 28.w,
              height: 26,
              decoration: BoxDecoration(
                color: const Color(0xff3c3c3c),
                borderRadius: BorderRadius.circular(7.0),
              ),
              child: Center(
                child: CountdownTimer(
                  widgetBuilder: (_, remainingTime) {
                    return MyTextWidget(
                        '${remainingTime?.min == null ? '00' : remainingTime!.min! < 10 ? '0${remainingTime.min}' : remainingTime.min}',
                        style: textTheme.titleLarge?.mr.copyWith(
                          letterSpacing: 0.35,
                          height: 1.35,
                          color: const Color(0xffffffcc),
                        ));
                  },
                  controller: controller,
                  onEnd: onEnd,
                  endTime: endTime,
                  endWidget: const SizedBox(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: MyTextWidget(
                ':',
                style: textTheme.displayMedium?.mr.copyWith(
                  letterSpacing: 0.4,
                  height: 1.31,
                  color: const Color(0xff3c3c3c),
                ),
              ),
            ),
            Container(
              width: 28.w,
              height: 26,
              decoration: BoxDecoration(
                color: const Color(0xff3c3c3c),
                borderRadius: BorderRadius.circular(7.0),
              ),
              child: Center(
                child: CountdownTimer(
                  widgetBuilder: (_, remainingTime) {
                    return MyTextWidget(
                        '${remainingTime?.sec == null ? '00' : remainingTime!.sec! < 10 ? '0${remainingTime.sec}' : remainingTime.sec}',
                        style: textTheme.titleLarge?.mr.copyWith(
                          letterSpacing: 0.35,
                          height: 1.35,
                          color: const Color(0xffffffcc),
                        ));
                  },
                  controller: controller,
                  onEnd: onEnd,
                  endTime: endTime,
                  endWidget: const SizedBox(),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          width: 10,
        )
      ],
    );
  }
}
