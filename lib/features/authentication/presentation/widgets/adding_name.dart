import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/form_utils.dart';
import 'package:trydos/features/authentication/presentation/widgets/name_from_field.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_executed_event_name.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../../../../common/test_utils/widgets_keys.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../core/utils/form_state_mixin.dart';
import '../../../../core/utils/responsive_padding.dart';
import '../../../../routes/router.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../../app/my_text_widget.dart';
import '../manager/auth_bloc.dart';

class AddingName extends StatefulWidget {
  const AddingName({required this.fromLogin, Key? key}) : super(key: key);
  final bool fromLogin;

  @override
  State<AddingName> createState() => _AddingNameState();
}

class _AddingNameState extends State<AddingName> with FormStateMinxin {
  final ValueNotifier<bool> displaySubmit = ValueNotifier(false);
  PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();

  @override
  void didChangeDependencies() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xffF4FFF4),
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ));

    FirebaseAnalyticsService.logScreen(
      screen: AnalyticsScreensConst.addNameScreen,
    );
    super.didChangeDependencies();
  }

  GlobalKey<FormState> _formkey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (p, c) => p.verifyOtpSignUpStatus != c.verifyOtpSignUpStatus,
      listener: (context, state) {
        if (state.verifyOtpSignUpStatus == VerifyOtpSignUpStatus.failure) {
          showMessage(
            state.signUpErrorMessage ?? LocaleKeys.no_error_message.tr(),
            showInRelease: true,
          );
          return;
        }
        if (state.verifyOtpSignUpStatus == VerifyOtpSignUpStatus.success) {
          context.go(
              GRouter.config.applicationRoutes.kRegistrationCompletedPage +
                  '?userName=${form.controllers[0].text}');
        }
      },
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (p, c) => p.updateNameStatus != c.updateNameStatus,
        listener: (context, state) {
          if (state.updateNameStatus == UpdateNameStatus.failure) {
            showMessage(
              LocaleKeys.failed_to_save_name.tr(),
              showInRelease: true,
            );
            return;
          }
          if (state.updateNameStatus == UpdateNameStatus.success) {
            context.go(
                GRouter.config.applicationRoutes.kRegistrationCompletedPage +
                    '?userName=${form.controllers[0].text}');
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: HWEdgeInsets.symmetric(horizontal: 40.0),
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(AppAssets.verifiedNumberSvg,
                        width: 15, height: 15),
                    10.horizontalSpace,
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyTextWidget(
                          LocaleKeys.the_number_verifieds_successfully.tr(),
                          style: context.textTheme.titleMedium?.ra
                              .copyWith(color: Color(0xff5D5C5D), height: 1.42),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: HWEdgeInsets.only(top: 3.0),
                              child: SvgPicture.asset(AppAssets.registerInfoSvg,
                                  width: 10, height: 10),
                            ),
                            5.horizontalSpace,
                            MyTextWidget(
                              LocaleKeys.last_step.tr(),
                              textAlign: TextAlign.start,
                              style: context.textTheme.titleMedium?.ra.copyWith(
                                  color: Color(0xffC4C2C2), height: 1.25),
                            ),
                          ],
                        ),
                        5.verticalSpace,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SvgPicture.asset(AppAssets.privacySvg,
                                width: 10, height: 10),
                            5.horizontalSpace,
                            MyTextWidget(
                              LocaleKeys.your_Privacy.tr(),
                              style: context.textTheme.titleMedium?.ra.copyWith(
                                  color: Color(0xffC4C2C2), height: 1.25),
                            )
                          ],
                        ),
                        3.verticalSpace,
                      ],
                    )
                  ],
                ),
              ]),
            ),
            28.verticalSpace,
            Form(
              key: _formkey,
              child: Padding(
                  padding: HWEdgeInsets.symmetric(horizontal: 20.0),
                  child: ValueListenableBuilder<bool>(
                      valueListenable: displaySubmit,
                      builder: (context, display, _) {
                        return NameFormField(
                          key: TestVariables.kTestMode
                              ? Key(WidgetsKey.nameFormFieldKey)
                              : null,
                          validator: ((value) {
                            if (value!.length < 8) {
                              return LocaleKeys.must_be_at_least_8_characters
                                  .tr();
                            }
                            return null;
                          }),
                          autoFocus: true,
                          ready: display,
                          onChange: (String? text) {
                            _formkey.currentState!.validate();

                            displaySubmit.value = text!.length >= 8;
                          },
                          controller: form.controllers[0],
                          suffixIcon: Padding(
                            padding: HWEdgeInsets.only(right: 20.0, top: 22),
                            child: !display
                                ? SizedBox(
                                    width: 22,
                                    height: 15,
                                  )
                                : InkWell(
                                    key: TestVariables.kTestMode
                                        ? Key(WidgetsKey.confirmNameButtonKey)
                                        : null,
                                    onTap: () {
                                      if (!widget.fromLogin) {
                                        BlocProvider.of<AuthBloc>(context)
                                            .add(UpdateNameEvent(
                                          name: form.controllers[0].text,
                                        ));
                                        // BlocProvider.of<AuthBloc>(context)
                                        //     .add(VerifyOtpSignUpEvent(
                                        //   name: form.controllers[0].text,
                                        //   otp: prefsRepository.otpCode!,
                                        //   verificationId:
                                        //       prefsRepository.verificationId!,
                                        // ));
                                      } else {
                                        BlocProvider.of<AuthBloc>(context)
                                            .add(UpdateNameEvent(
                                          name: form.controllers[0].text,
                                        ));
                                      }
                                      ////////////////
                                      FirebaseAnalyticsService
                                          .logEventForSession(
                                        eventName:
                                            AnalyticsEventsConst.buttonClicked,
                                        executedEventName:
                                            AnalyticsExecutedEventNameConst
                                                .confirmNameButton,
                                      );
                                    },
                                    child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SvgPicture.asset(
                                            AppAssets.submitArrowSvg,
                                            width: 10,
                                            height: 20,
                                          ),
                                        ]),
                                  ),
                          ),
                        );
                      })),
            ),
            10.verticalSpace,
          ],
        ),
      ),
    );
  }

  @override
  // TODO: implement numberOfFields
  int get numberOfFields => 1;
}
