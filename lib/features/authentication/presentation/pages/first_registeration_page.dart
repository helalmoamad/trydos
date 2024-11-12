import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:trydos/base_page.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_event.dart';
import 'package:trydos/features/authentication/presentation/widgets/create_account_section.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_executed_event_name.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../../common/test_utils/widgets_keys.dart';
import '../../../../common/helper/show_message.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../core/utils/responsive_padding.dart';
import '../../../../routes/router.dart';
import '../../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../manager/auth_bloc.dart';
import '../widgets/welcome_section.dart';
import 'package:trydos/features/authentication/presentation/widgets/insert_phone_tab.dart';
import 'package:trydos/features/authentication/presentation/widgets/verify_otp.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../widgets/adding_name.dart';
import '../widgets/verification_methods.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage>
    with SingleTickerProviderStateMixin {
  PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  final ValueNotifier<int> pageContent = ValueNotifier(0);
  final ValueNotifier<bool> animate = ValueNotifier(false);
  final PageController pageController = PageController();
  bool fromLogin = false;
  String phoneNumber = '';
  String verificationId = '';
  String otp = '';
  Duration animationDuration = Duration(milliseconds: 500);
  final FocusNode focusNode = FocusNode();
  late AuthBloc authBloc;
  int isVisWhatsApp = 0;
  int PopScopeValue = 0;

  @override
  void initState() {
    authBloc = BlocProvider.of<AuthBloc>(context);
    super.initState();
  }

  @override
  void dispose() {
    prefsRepository.setTimerForOtpRunning(false);
    super.dispose();
  }

  @override
  void didChangeDependencies() async {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xffFFFFFF),
      statusBarBrightness: Brightness.light,
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
    return ValueListenableBuilder<int>(
        child: ValueListenableBuilder<bool>(
            child: logo,
            valueListenable: animate,
            builder: (context, yes, child) {
              return Directionality(
                textDirection: TextDirection.ltr,
                child: AnimatedPositioned(
                    left: yes ? 40 : null,
                    right: yes ? 40 : null,
                    top: yes ? 50 : null,
                    bottom: yes ? null : 456,
                    duration: animationDuration,
                    child: child!),
              );
            }),
        valueListenable: pageContent,
        builder: (ctx, index, child) {
          if (index < 2) {
            FocusScope.of(context).unfocus();
          } else if (index != 6) {
            focusNode.requestFocus();
          }
          return Scaffold(
            backgroundColor:
                index != 6 ? context.colorScheme.surface : Color(0xffF4FFF4),
            body: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                child!,
                Positioned(
                  top: 0,
                  right: 0,
                  child: ValueListenableBuilder<int>(
                      valueListenable: pageContent,
                      builder: (context, index, _) {
                        if (index > 1)
                          return InkWell(
                            key: TestVariables.kTestMode
                                ? Key(WidgetsKey.registerCancelKey)
                                : null,
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            onTap: () {
                              Future.delayed(
                                Duration(milliseconds: 100),
                                () {
                                  if (index == 2) {
                                    pageContent.value = 0;
                                    pageController.animateToPage(0,
                                        duration: Duration(milliseconds: 500),
                                        curve: Curves.easeInOut);
                                    return;
                                  }
                                  if (index >= 3 && index <= 5) {
                                    pageContent.value = 2;
                                    pageController.animateToPage(2,
                                        duration: Duration(milliseconds: 500),
                                        curve: Curves.easeInOut);
                                    return;
                                  }
                                  context.go(GRouter
                                      .config.applicationRoutes.kBasePage);
                                },
                              );

                              //////////////////////////
                              FirebaseAnalyticsService.logEventForSession(
                                eventName: AnalyticsEventsConst.buttonClicked,
                                executedEventName:
                                    AnalyticsExecutedEventNameConst
                                        .registerCancelButton,
                              );
                            },
                            child: Padding(
                              padding: HWEdgeInsets.only(
                                  top: 60.0, right: 30, left: 30, bottom: 60),
                              child: SvgPicture.asset(AppAssets.cancelSvg),
                            ),
                          );
                        return const SizedBox.shrink();
                      }),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 96,
                    ),
                    SizedBox(
                      height: 360,
                      width: 1.sw,
                      child: WillPopScope(
                          child: PageView(
                              physics: NeverScrollableScrollPhysics(),
                              onPageChanged: (value) => setState(() {
                                    PopScopeValue = value;
                                  }),
                              controller: pageController,
                              children: [
                                WelcomeSection(
                                  goToLoginSection: () {
                                    fromLogin = true;
                                    animationDuration = Duration(seconds: 1);
                                    animate.value = true;
                                    pageContent.value = 2;
                                    pageController.animateToPage(2,
                                        duration: Duration(milliseconds: 500),
                                        curve: Curves.easeInOut);
                                  },
                                  goToCreateAccount: () {
                                    fromLogin = false;
                                    animate.value = true;
                                    pageContent.value = 1;
                                    pageController.animateToPage(1,
                                        duration: Duration(milliseconds: 500),
                                        curve: Curves.easeInOut);
                                    //_animationController.forward();
                                  },
                                ),
                                CreateAccountSection(
                                  moveToNextStep: () {
                                    pageContent.value = 2;
                                    pageController.animateToPage(2,
                                        duration: Duration(milliseconds: 500),
                                        curve: Curves.easeInOut);
                                  },
                                ),
                                InsertPhoneTab(
                                  fromLogin: fromLogin,
                                  focusNode: focusNode,
                                  moveToNextStep: (String phoneNumber) {
                                    this.phoneNumber =
                                        phoneNumber.replaceAll(' ', '');
                                    pageContent.value = 3;
                                    pageController.animateToPage(3,
                                        duration: Duration(milliseconds: 500),
                                        curve: Curves.easeInOut);
                                  },
                                ),
                                VerificationMethods(
                                  phoneNumber: phoneNumber,
                                  onChooseWhatsapp: () {
                                    isVisWhatsApp = 1;
                                    pageContent.value = 4;
                                    pageController.animateToPage(4,
                                        duration: Duration(milliseconds: 500),
                                        curve: Curves.easeInOut);

                                    if (prefsRepository.isTimerForOtpRunning ??
                                        false) {
                                      showMessage(
                                          'you must wait for some seconds before try again');
                                      return;
                                    }
                                    authBloc.add(SendOtpEvent(
                                        phone: phoneNumber, isViaWhatsApp: 1));
                                  },
                                  goBackToPhone: () {
                                    pageController.animateToPage(2,
                                        duration: Duration(milliseconds: 500),
                                        curve: Curves.easeInOut);
                                    pageContent.value = 2;
                                  },
                                  onChooseSms: () {
                                    isVisWhatsApp = 0;
                                    pageController.animateToPage(4,
                                        duration: Duration(milliseconds: 500),
                                        curve: Curves.easeInOut);
                                    pageContent.value = 5;
                                    authBloc.add(SendOtpEvent(
                                        phone: phoneNumber, isViaWhatsApp: 0));
                                  },
                                ),
                                VerifyOtp(
                                    isVisWhatsApp: isVisWhatsApp,
                                    navigateToAddName: () {
                                      debugPrint('fromLogin:  $fromLogin');
                                      if (fromLogin) {
                                        context.go(GRouter
                                                .config
                                                .applicationRoutes
                                                .kLoginSuccessfullyPage +
                                            '?phoneNumber=$phoneNumber');
                                        return;
                                      }
                                      fromLogin = false;
                                      pageController.animateToPage(5,
                                          duration: Duration(milliseconds: 500),
                                          curve: Curves.easeInOut);
                                      pageContent.value = 6;
                                    },
                                    fromLogin: fromLogin,
                                    onLoginFailed: () {
                                      fromLogin = true;
                                      pageController.animateToPage(5,
                                          duration: Duration(milliseconds: 500),
                                          curve: Curves.easeInOut);
                                      pageContent.value = 6;
                                    },
                                    goBack: () {
                                      pageController.animateToPage(3,
                                          duration: Duration(milliseconds: 500),
                                          curve: Curves.easeInOut);
                                      pageContent.value = 3;
                                    },
                                    methodIcon: index == 4
                                        ? AppAssets.whatsappSvg
                                        : AppAssets.smsSvg,
                                    phoneNumber: phoneNumber),
                                AddingName(
                                  fromLogin: fromLogin,
                                )
                              ]),
                          onWillPop: () async {
                            if (PopScopeValue > 0) {
                              if (PopScopeValue == 2 && fromLogin) {
                                await pageController.animateToPage(
                                    PopScopeValue - 2,
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.easeInOut);
                                return false;
                              }
                              await pageController.animateToPage(
                                  PopScopeValue - 1,
                                  duration: Duration(milliseconds: 500),
                                  curve: Curves.easeInOut);
                              return false;
                            }
                            if(BlocProvider.of<AppBloc>(context).state.currentIndex != 0){
                              BlocProvider.of<AppBloc>(context).add(ChangeBasePage(0));
                              return  false;
                            }
                            return true;
                          }),
                    )
                  ],
                )
              ],
            ),
          );
        });
  }
}
