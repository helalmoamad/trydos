import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'dart:ui' as ui;
import '../../../../common/constant/widgets_key.dart';
import '../../../../common/helper/helper_functions.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../core/utils/responsive_padding.dart';
import '../../../../routes/router.dart';
import '../../../app/my_text_widget.dart';
import '../manager/auth_bloc.dart';

class WelcomeSection extends StatelessWidget {
  WelcomeSection(
      {required this.goToCreateAccount,
      required this.goToLoginSection,
      Key? key})
      : super(key: key);
  final void Function() goToCreateAccount;
  final void Function() goToLoginSection;

  final ValueNotifier<int> clickButton = ValueNotifier(-1);
  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: HWEdgeInsets.symmetric(horizontal: 30.0),
            child: MyTextWidget(
              LocaleKeys.welcome_page_description.tr(),
              textAlign: TextAlign.center,
              style: context.textTheme.bodyText2?.la.copyWith(
                color: Color(0xff5D5C5D),
                letterSpacing: 0.14,
                height: 1.43,
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          MyTextWidget(
            LocaleKeys.why_we_know_you_label.tr(),
            textAlign: TextAlign.center,
            style: context.textTheme.bodyText2?.la.copyWith(
              color: Color(0xffF85555),
              letterSpacing: 0.14,
              height: 1.43,
            ),
          ),
          SizedBox(
            height: 30,
          ),
          InkWell(
            key: Key(WidgetsKey.haveAccountButtonKey),
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: () async {
              clickButton.value = 0;
              Future.delayed(Duration(milliseconds: 100), () {
                print("${prefsRepository.myMarketId.toString()}" +
                    "55555555555555555555555555555555555555555");
                print("${prefsRepository.myMarketId.toString()}" +
                    "5555555444444444444444444444444444444444444444444444444444444445555555555555555555555");

                clickButton.value = -1;
                goToLoginSection.call();
              });
              await FirebaseAnalytics.instance
                  .logEvent(name: 'button_clicked', parameters: {
                'userID': prefsRepository.myMarketId.toString(),
                'user_name': prefsRepository.myMarketName.toString(),
                'clicked_button_name': 'i have already account',
              });
            },
            child: ValueListenableBuilder<int>(
                valueListenable: clickButton,
                builder: (context, index, _) {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                    child: DottedBorder(
                      borderPadding: EdgeInsets.zero,
                      padding: EdgeInsets.zero,
                      strokeCap: StrokeCap.round,
                      strokeWidth: 0.5,
                      borderType: BorderType.RRect,
                      dashPattern: [3, 3],
                      radius: Radius.circular(20.0),
                      color: index == 0
                          ? const Color(0xff707070)
                          : const Color(0xfffafafa),
                      child: Container(
                        width: 1.sw,
                        height: 60,
                        decoration: BoxDecoration(
                          color: index == 0
                              ? Colors.white
                              : const Color(0xfffafafa),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Center(
                          child: MyTextWidget(
                            LocaleKeys.i_have_account.tr(),
                            style: context.textTheme.bodyText1?.ra.copyWith(
                              color: Color(0xff5D5C5D),
                              letterSpacing: 0.16,
                              height: 1.25,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
          ),
          SizedBox(
            height: 10,
          ),
          InkWell(
            key: Key(WidgetsKey.createNewAccountButtonKey),
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: () async {
              clickButton.value = 1;
              Future.delayed(Duration(milliseconds: 100), () {
                clickButton.value = -1;
                goToCreateAccount.call();
              });
              await FirebaseAnalytics.instance
                  .logEvent(name: 'button_clicked', parameters: {
                'userID': prefsRepository.myMarketId.toString(),
                'user_name': prefsRepository.myMarketName.toString(),
                'clicked_button_name': 'create new account',
              });
            },
            child: ValueListenableBuilder<int>(
                valueListenable: clickButton,
                builder: (context, index, _) {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                    child: DottedBorder(
                      borderPadding: EdgeInsets.zero,
                      padding: EdgeInsets.zero,
                      strokeCap: StrokeCap.round,
                      strokeWidth: 0.5,
                      borderType: BorderType.RRect,
                      dashPattern: [3, 3],
                      radius: Radius.circular(20.0),
                      color: index == 1
                          ? const Color(0xff707070)
                          : const Color(0xfffafafa),
                      child: Container(
                        width: 1.sw,
                        height: 60,
                        decoration: BoxDecoration(
                          color: index == 1
                              ? Colors.white
                              : const Color(0xfffafafa),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Center(
                          child: MyTextWidget(
                            LocaleKeys.create_new_account.tr(),
                            style: context.textTheme.bodyText1?.ra.copyWith(
                              color: Color(0xff5D5C5D),
                              letterSpacing: 0.16,
                              height: 1.25,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
          ),
          SizedBox(
            height: 20,
          ),
          InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            key: Key(WidgetsKey.laterTakeLookKey),
            onTap: () async {
              if (prefsRepository.isVerifiedPhone != false) {
                String? deviceId = await HelperFunctions.getDeviceId();
                BlocProvider.of<AuthBloc>(context)
                    .add(RegisterGuestEvent(deviceId: deviceId!));
              }
              await FirebaseAnalytics.instance
                  .logEvent(name: 'button_clicked', parameters: {
                'userID': prefsRepository.myMarketId.toString(),
                'user_name': prefsRepository.myMarketName.toString(),
                'clicked_button_name': 'Later, Take Look',
              });
              context.go(GRouter.config.applicationRoutes.kBasePage);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: MyTextWidget(
                LocaleKeys.later_take_look.tr(),
                textAlign: TextAlign.center,
                style: context.textTheme.bodyText2?.ra.copyWith(
                  color: Color(0xff4d84ff),
                  letterSpacing: 0.14,
                  height: 1.43,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 46,
          ),
        ],
      ),
    );
  }
}
