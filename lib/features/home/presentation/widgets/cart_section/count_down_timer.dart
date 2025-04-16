import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';

class CountDownTimer extends StatefulWidget {
  const CountDownTimer({super.key, required this.cartId});

  final String? cartId;
  @override
  State<CountDownTimer> createState() => _CountDownTimerState();
}

class _CountDownTimerState extends State<CountDownTimer> {
  CountdownTimerController? countdownTimerController;
  int? endTime;
  late HomeBloc homeBloc;

  @override
  void initState() {
    homeBloc = BlocProvider.of<HomeBloc>(context);

    endTime = homeBloc.state.cartIdsHurryUPTimerStarted[widget.cartId] ?? 0;

    if (countdownTimerController == null) {
      countdownTimerController = CountdownTimerController(
          endTime: endTime ?? 0,
          onEnd: () {
            homeBloc.add(GetOldCartItemEvent());
            homeBloc.add(GetCartItemEvent());
          });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      try {
        BlocProvider.of<HomeBloc>(context).add((SendErrorToMobileErrorLogEvent(
            errorExption: error.exceptionAsString().toString(),
            errorPath: error.stack.toString().split("#")[1],
            urlBackend: "Front Error",
            messageFromeBackend: "Front Error")));
      } catch (e) {}
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };
    return Directionality(
        textDirection: TextDirection.ltr,
        child: CountdownTimer(
          widgetBuilder: (_, remainingTime) {
            String seconds = (remainingTime?.sec ?? 0) < 10
                ? '0${remainingTime?.sec == null ? 0 : remainingTime?.sec}'
                : '${remainingTime?.sec == null ? 0 : remainingTime?.sec}';
            String minets = (remainingTime?.min ?? 0) < 10
                ? '0${remainingTime?.min == null ? 0 : remainingTime?.min}'
                : '${remainingTime?.min == null ? 0 : remainingTime?.min}';
            return Text('$minets : $seconds ',
                style: context.textTheme.bodyMedium?.ba.copyWith(
                  fontSize: 12,
                  color: Color(0xffA28E5B),
                ));
          },
          controller: countdownTimerController,
          endWidget: const SizedBox.shrink(),
        ));
  }
}
