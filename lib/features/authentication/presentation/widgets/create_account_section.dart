import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_executed_event_name.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../../../../common/test_utils/widgets_keys.dart';
import '../../../../common/helper/helper_functions.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../routes/router.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../../app/my_text_widget.dart';
import '../manager/auth_bloc.dart';

class CreateAccountSection extends StatelessWidget {
  CreateAccountSection({Key? key, required this.moveToNextStep})
      : super(key: key);
  final ValueNotifier<int> clickButton = ValueNotifier(-1);
  final void Function() moveToNextStep;

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: LocaleKeys.to.tr(),
                style: context.textTheme.titleLarge?.la.copyWith(
                  color: const Color(0xff5d5c5d),
                  letterSpacing: 0.14,
                  height: 1.43,
                ),
              ),
              TextSpan(
                text: LocaleKeys.create_new_account.tr(),
                style: context.textTheme.titleLarge?.lr.copyWith(
                  color: const Color(0xff5d5c5d),
                  letterSpacing: 0.14,
                  height: 1.43,
                ),
              ),
              TextSpan(
                text: " " +
                    LocaleKeys.tap.tr() +
                    " "
                        "“" +
                    LocaleKeys.agree_continue.tr() +
                    "”" +
                    " " +
                    LocaleKeys.to_accept_trydos.tr(),
                style: context.textTheme.titleLarge?.la.copyWith(
                  color: const Color(0xff5d5c5d),
                  letterSpacing: 0.14,
                  height: 1.43,
                ),
              ),
              TextSpan(
                text: "\n" + LocaleKeys.trydos.tr(),
                style: context.textTheme.titleLarge?.la.copyWith(
                  color: const Color(0xff5d5c5d),
                  letterSpacing: 0.14,
                  height: 1.2,
                ),
              ),
            ],
          ),
          textHeightBehavior:
              TextHeightBehavior(applyHeightToFirstAscent: false),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 23,
        ),
        SvgPicture.asset(AppAssets.termsSvg),
        SizedBox(
          height: 10,
        ),
        MyTextWidget(
          LocaleKeys.trems_of_services.tr(),
          style: context.textTheme.titleLarge?.ra.copyWith(
            color: const Color(0xff388CFF),
            height: 1.42,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 78,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: InkWell(
            key: TestVariables.kTestMode
                ? Key(WidgetsKey.agreeContinueButtonKey)
                : null,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: () {
              clickButton.value = 0;
              Future.delayed(
                Duration(milliseconds: 100),
                () {
                  clickButton.value = -1;
                  moveToNextStep.call();
                },
              );
              /////////////////////////////////////
              FirebaseAnalyticsService.logEventForSession(
                eventName: AnalyticsEventsConst.buttonClicked,
                executedEventName:
                    AnalyticsExecutedEventNameConst.agreeContinueButton,
              );
            },
            child: ValueListenableBuilder<int>(
                valueListenable: clickButton,
                builder: (context, index, _) {
                  return DottedBorder(
                    borderPadding: EdgeInsets.zero,
                    padding: EdgeInsets.zero,
                    borderType: BorderType.RRect,
                    strokeCap: StrokeCap.round,
                    strokeWidth: 0.5,
                    dashPattern: [3, 3],
                    radius: Radius.circular(20.0),
                    color: index == 0
                        ? const Color(0xff388cff)
                        : const Color(0xfffafafa),
                    child: Container(
                      width: 1.sw,
                      height: 60,
                      decoration: BoxDecoration(
                        color:
                            index == 0 ? Colors.white : const Color(0xfffafafa),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Center(
                        child: MyTextWidget(
                          LocaleKeys.agree_continue.tr(),
                          style: context.textTheme.displayMedium?.ra.copyWith(
                            color: const Color(0xff3c3c3c),
                            letterSpacing: 0.16,
                            height: 1.25,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
          ),
        ),
        SizedBox(
          height: 19,
        ),
        InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: () async {
            Future.delayed(
              Duration(milliseconds: 100),
              () async {
                if (GetIt.I<PrefsRepository>().isVerifiedPhone != false) {
                  String? deviceId = await HelperFunctions.getDeviceId();
                  BlocProvider.of<AuthBloc>(context)
                      .add(RegisterGuestEvent(deviceId: deviceId!));
                }
                context.go(GRouter.config.applicationRoutes.kBasePage);
              },
            );

            /////////////////////////////////////
            FirebaseAnalyticsService.logEventForSession(
              eventName: AnalyticsEventsConst.buttonClicked,
              executedEventName:
                  AnalyticsExecutedEventNameConst.laterTakeLookButton,
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: MyTextWidget(
              LocaleKeys.later_take_look.tr(),
              style: context.textTheme.titleLarge?.ra.copyWith(
                color: const Color(0xff4D84FF),
                letterSpacing: 0.14,
                height: 1.43,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 45,
        ),
      ],
    );
  }
}
