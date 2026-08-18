import 'package:flutter/foundation.dart' hide Category;
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_buttons_event_name.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../../../../common/test_utils/widgets_keys.dart';
import '../../../../common/helper/helper_functions.dart';
import '../../../../routes/router.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../../app/my_text_widget.dart';
import '../manager/auth_bloc.dart';

class CreateAccountSection extends StatefulWidget {
  CreateAccountSection({Key? key, required this.moveToNextStep})
    : super(key: key);
  final void Function() moveToNextStep;

  @override
  State<CreateAccountSection> createState() => _CreateAccountSectionState();
}

class _CreateAccountSectionState extends State<CreateAccountSection> {
  final ValueNotifier<int> clickButton = ValueNotifier(-1);

  bool _eventLogged = false;
  @override
  void didChangeDependencies() {
    if (!_eventLogged) {
      FirebaseAnalyticsService.logEventForSession(
        executedEventName: AuthScreenConst.AGREE_TERMS_SCREEN,
        eventName: AnalyticsEventsConst.SCREEN_VIEW,
        extraParams: {
          'screen_name': AuthScreenConst.AGREE_TERMS_SCREEN,
          'screen_path': '',
          'platform': GlobalPlatform.MOBILE,
        },
      );

      _eventLogged = true;
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: LocaleKeys.to.tr(),
                style: context.textTheme.titleLarge?.lq.copyWith(
                  color: const Color(0xff5d5c5d),
                  letterSpacing: 0.14,
                  height: 1.43,
                ),
              ),
              TextSpan(
                text: LocaleKeys.create_new_account.tr(),
                style: context.textTheme.titleLarge?.lq.copyWith(
                  color: const Color(0xff5d5c5d),
                  letterSpacing: 0.14,
                  height: 1.43,
                ),
              ),
              TextSpan(
                text:
                    " " +
                    LocaleKeys.tap.tr() +
                    " "
                        "“" +
                    LocaleKeys.agree_continue.tr() +
                    "”" +
                    " " +
                    LocaleKeys.to_accept_trydos.tr(),
                style: context.textTheme.titleLarge?.lq.copyWith(
                  color: const Color(0xff5d5c5d),
                  letterSpacing: 0.14,
                  height: 1.43,
                ),
              ),
              TextSpan(
                text: "\n" + LocaleKeys.trydos.tr(),
                style: context.textTheme.titleLarge?.lq.copyWith(
                  color: const Color(0xff5d5c5d),
                  letterSpacing: 0.14,
                  height: 1.2,
                ),
              ),
            ],
          ),
          textHeightBehavior: const TextHeightBehavior(
            applyHeightToFirstAscent: false,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20.h),
        SvgPicture.asset(AppAssets.termsSvg),
        SizedBox(height: 10.h),
        MyTextWidget(
          LocaleKeys.trems_of_services.tr(),
          style: context.textTheme.titleLarge?.rq.copyWith(
            color: const Color(0xff388CFF),
            height: 1.42,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 60.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: InkWell(
            key: TestVariables.kTestMode
                ? const Key(WidgetsKeys.agreeContinueButtonKey)
                : null,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: () {
              clickButton.value = 0;
              Future.delayed(const Duration(milliseconds: 100), () {
                clickButton.value = -1;
                widget.moveToNextStep.call();
              });
              /////////////////////////////////////

              FirebaseAnalyticsService.logEventForSession(
                executedEventName: AuthScreenConst.AGREE_TERMS_SCREEN,
                eventName: AnalyticsEventsConst.CLICK,
                extraParams: {
                  'button_name':
                      AnalyticsButtonsEventNameConst.AGREE_CONTINUE_BUTTON,
                },
              );
            },
            child: ValueListenableBuilder<int>(
              valueListenable: clickButton,
              builder: (context, index, _) {
                return DottedBorder(
                  padding: EdgeInsets.zero,
                  borderType: BorderType.RRect,
                  strokeCap: StrokeCap.round,
                  strokeWidth: 0.5,
                  dashPattern: const [3, 3],
                  radius: Radius.circular(20.r),
                  color: index == 0
                      ? const Color(0xff388cff)
                      : const Color(0xfffafafa),
                  child: Container(
                    width: 1.sw,
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: index == 0
                          ? Colors.white
                          : const Color(0xfffafafa),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Center(
                      child: MyTextWidget(
                        LocaleKeys.agree_continue.tr(),
                        style: context.textTheme.displayMedium?.rq.copyWith(
                          color: const Color(0xff3c3c3c),
                          letterSpacing: 0.16,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(height: 20.h),
        InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: () async {
            if (kDebugMode) print(
              "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%",
            );
            Future.delayed(const Duration(milliseconds: 100), () async {
              /*     if (GetIt.I<PrefsRepository>().isVerifiedPhone != false ||
                    ((GetIt.I<PrefsRepository>().marketToken?.length ?? 0) <
                            5 ||
                        GetIt.I<PrefsRepository>().marketToken == "" ||
                        GetIt.I<PrefsRepository>().marketToken == null)) {*/
              String? deviceId = await HelperFunctions.getDeviceId();
              BlocProvider.of<AuthBloc>(
                context,
              ).add(RegisterGuestEvent(deviceId: deviceId!));
              //}
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context.go(GRouter.config.applicationRoutes.kBasePage);
              }
            });

            /////////////////////////////////////

            FirebaseAnalyticsService.logEventForSession(
              executedEventName: AuthScreenConst.AGREE_TERMS_SCREEN,
              eventName: AnalyticsEventsConst.CANCEL_SIGNUP,
              extraParams: {
                'button_name':
                    AnalyticsButtonsEventNameConst.LATER_TAKE_LOOK_BUTTON,
              },
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: MyTextWidget(
              LocaleKeys.later_take_look.tr(),
              style: context.textTheme.titleLarge?.rq.copyWith(
                color: const Color(0xff4D84FF),
                letterSpacing: 0.14,
                height: 1.43,
              ),
            ),
          ),
        ),
        SizedBox(height: 45.h),
      ],
    );
  }
}
