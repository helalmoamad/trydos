import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import '../../../../base_page.dart';
import '../../../../common/test_utils/widgets_keys.dart';
import '../../../../core/utils/responsive_padding.dart';
import '../../../../core/utils/theme_state.dart';
import '../../../../routes/router.dart';
import '../../../app/my_text_widget.dart';

class RegisterCompleted extends StatefulWidget {
  const RegisterCompleted({Key? key, required this.userName}) : super(key: key);
  final String userName;

  @override
  State<RegisterCompleted> createState() => _RegisterCompletedState();
}

class _RegisterCompletedState extends ThemeState<RegisterCompleted> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xffBCFFDF),
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ));
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffBCFFDF),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(top: 50, left: 40, right: 40, child: logo),
          Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: HWEdgeInsets.only(left: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: HWEdgeInsets.only(left: 4.0),
                        child: MyTextWidget(LocaleKeys.hello.tr(),
                            textAlign: TextAlign.start,
                            style: textTheme.headlineMedium?.ba.copyWith(
                                color: Color(0xff5D5C5D), height: 1.25)),
                      ),
                      SizedBox(
                        height: 17,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          MyTextWidget(',' + widget.userName,
                              textAlign: TextAlign.start,
                              style: textTheme.headlineMedium?.la.copyWith(
                                color: Color(0xff5D5C5D),
                                letterSpacing: 0.3,
                                height: 0.67,
                              )),
                          SizedBox(
                            height: 18,
                          ),
                          MyTextWidget(LocaleKeys.enjoy_with_our_services.tr(),
                              textAlign: TextAlign.center,
                              style: textTheme.bodyMedium?.la.copyWith(
                                  color: Color(0xff5D5C5D), height: 1.25)),
                        ],
                      ),
                    ],
                  ),
                ),
                Spacer(),
                MyTextWidget(LocaleKeys.we_recommend.tr(),
                    textAlign: TextAlign.center,
                    style: textTheme.titleLarge?.la.copyWith(
                      color: Color(0xff5D5C5D),
                      letterSpacing: 0.14,
                      height: 1.43,
                    )),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: 1.sw,
                  height: 60,
                  margin: HWEdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xffF4FFF4),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyTextWidget(
                        LocaleKeys.complete_my_profile.tr(),
                        style: textTheme.displayMedium?.ra.copyWith(
                          color: Color(0xff5D5C5D),
                          letterSpacing: 0.16,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                InkWell(
                  key: TestVariables.kTestMode
                      ? Key(WidgetsKey.skipForNowKey)
                      : null,
                  focusColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onTap: () {
                    context.go(GRouter.config.applicationRoutes.kBasePage);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: MyTextWidget(
                      LocaleKeys.skip_for_now.tr(),
                      style: textTheme.titleLarge?.ra.copyWith(
                        color: Color(0xff4d84ff),
                        letterSpacing: 0.14,
                        height: 1.43,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(
                  height: 44,
                ),
              ]),
        ],
      ),
    );
  }
}
