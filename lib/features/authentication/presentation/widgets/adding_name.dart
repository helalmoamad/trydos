import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/form_utils.dart';
import 'package:trydos/features/authentication/presentation/widgets/name_from_field.dart';

import '../../../../common/constant/design/assets_provider.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../core/utils/form_state_mixin.dart';
import '../../../../core/utils/responsive_padding.dart';
import '../../../../routes/router.dart';
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
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
    ));
    super.didChangeDependencies();
  }

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
          showMessage(state.signUpErrorMessage ?? 'No Error Message',showInRelease: true,);
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
            showMessage('failed to save name',showInRelease: true,);
            return;
          }
          if (state.updateNameStatus == UpdateNameStatus.success) {
            context.go(
                GRouter.config.applicationRoutes.kRegistrationCompletedPage +
                    '?userName=${form.controllers[0].text}');
          }
        },
        child: Directionality(
          textDirection: TextDirection.ltr,
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
                            'The Number Verified Successfully !',
                            style: context.textTheme.caption?.ra.copyWith(
                                color: Color(0xff5D5C5D), height: 1.42),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: HWEdgeInsets.only(top: 3.0),
                                child: SvgPicture.asset(
                                    AppAssets.registerInfoSvg,
                                    width: 10,
                                    height: 10),
                              ),
                              5.horizontalSpace,
                              MyTextWidget(
                                'Last Step And Enjoy Our Services',
                                textAlign: TextAlign.start,
                                style: context.textTheme.caption?.ra.copyWith(
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
                                'Your Privacy Is Completely Safe, We Not Share Your\nInformation With Anyone',
                                style: context.textTheme.caption?.ra.copyWith(
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
              Padding(
                  padding: HWEdgeInsets.symmetric(horizontal: 20.0),
                  child: ValueListenableBuilder<bool>(
                      valueListenable: displaySubmit,
                      builder: (context, display, _) {
                        return NameFormField(
                          autoFocus: true,
                          ready: display,
                          onChange: (String? text) {
                            displaySubmit.value = text!.length > 8;
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
                                    onTap: () {
                                      if (widget.fromLogin) {
                                        BlocProvider.of<AuthBloc>(context)
                                            .add(VerifyOtpSignUpEvent(
                                          name: form.controllers[0].text,
                                          otp: prefsRepository.otpCode!,
                                          verificationId:
                                              prefsRepository.verificationId!,
                                        ));
                                      } else {
                                        BlocProvider.of<AuthBloc>(context)
                                            .add(UpdateNameEvent(
                                          name: form.controllers[0].text,
                                        ));
                                      }
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
              10.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }

  @override
  // TODO: implement numberOfFields
  int get numberOfFields => 1;
}
