import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_event.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import '../../../../base_page.dart';
import '../../../../common/test_utils/widgets_keys.dart';
import '../../../../core/utils/responsive_padding.dart';
import '../../../../core/utils/theme_state.dart';
import '../../../../routes/router.dart';
import '../../../app/my_text_widget.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';

class RegisterCompleted extends StatefulWidget {
  const RegisterCompleted({Key? key, required this.userName}) : super(key: key);
  final String userName;

  @override
  State<RegisterCompleted> createState() => _RegisterCompletedState();
}

class _RegisterCompletedState extends ThemeState<RegisterCompleted> {
  late AppBloc appBloc;

  @override
  void initState() {
    LastPagesTracker.push('RegisterCompleted');
    appBloc = BlocProvider.of<AppBloc>(context);
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xffBCFFDF),
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffBCFFDF),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(top: 50.h, left: 40.w, right: 40.w, child: logo),
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              SizedBox(height: 1.sh / 8),
              Padding(
                padding: HWEdgeInsets.only(left: 30.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: HWEdgeInsets.only(left: 4.w),
                      child: MyTextWidget(
                        LocaleKeys.hello.tr(),
                        textAlign: TextAlign.start,
                        style: textTheme.headlineMedium?.bq.copyWith(
                          color: const Color(0xff5D5C5D),
                          height: 1.25,
                        ),
                      ),
                    ),
                    SizedBox(height: 17.h),
                    Column(
                      children: [
                        MyTextWidget(
                          ',' + widget.userName,
                          textAlign: TextAlign.start,
                          style: textTheme.headlineMedium?.lq.copyWith(
                            color: const Color(0xff5D5C5D),
                            letterSpacing: 0.3,
                            height: 0.67,
                          ),
                        ),
                        SizedBox(height: 18.h),
                        MyTextWidget(
                          LocaleKeys.enjoy_with_our_services.tr(),
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.lq.copyWith(
                            color: const Color(0xff5D5C5D),
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              MyTextWidget(
                LocaleKeys.we_recommend.tr(),
                textAlign: TextAlign.center,
                style: textTheme.titleLarge?.lq.copyWith(
                  color: const Color(0xff5D5C5D),
                  letterSpacing: 0.14,
                  height: 1.43,
                ),
              ),
              SizedBox(height: 10.h),
              InkWell(
                onTap: () {
                  context.go(GRouter.config.applicationRoutes.kBasePage);
                  Future.delayed(
                    const Duration(milliseconds: 300),
                    () => appBloc.add(ChangeBasePage(3)),
                  );
                },
                child: Container(
                  width: 1.sw,
                  height: 60.h,
                  margin: HWEdgeInsets.symmetric(horizontal: 20.w),
                  decoration: BoxDecoration(
                    color: const Color(0xffF4FFF4),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyTextWidget(
                        LocaleKeys.complete_my_profile.tr(),
                        style: textTheme.displayMedium?.rq.copyWith(
                          color: const Color(0xff5D5C5D),
                          letterSpacing: 0.16,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              InkWell(
                key: TestVariables.kTestMode
                    ? const Key(WidgetsKeys.skipForNowKey)
                    : null,
                focusColor: Colors.transparent,
                splashColor: Colors.transparent,
                onTap: () {
                  context.go(GRouter.config.applicationRoutes.kBasePage);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  child: MyTextWidget(
                    LocaleKeys.skip_for_now.tr(),
                    style: textTheme.titleLarge?.rq.copyWith(
                      color: const Color(0xff4d84ff),
                      letterSpacing: 0.14,
                      height: 1.43,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(height: 44.h),
            ],
          ),
        ],
      ),
    );
  }
}
