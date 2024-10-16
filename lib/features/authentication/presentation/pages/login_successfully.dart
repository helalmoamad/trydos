import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import '../../../../base_page.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../core/utils/responsive_padding.dart';
import '../../../../core/utils/theme_state.dart';
import '../../../../routes/router.dart';
import '../../../app/my_text_widget.dart';
import '../manager/auth_bloc.dart';

class LoginSuccessfully extends StatefulWidget {
  const LoginSuccessfully({required this.phoneNumber, Key? key})
      : super(key: key);
  final String phoneNumber;

  @override
  State<LoginSuccessfully> createState() => _LoginSuccessfullyState();
}

class _LoginSuccessfullyState extends ThemeState<LoginSuccessfully> {
  @override
  void didChangeDependencies() async {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xffE0FFEE),
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));

    Future.delayed(
      Duration(seconds: 1),
      () {
        if (mounted) context.go(GRouter.config.applicationRoutes.kBasePage);
      },
    );
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
      debugPrint('error $error');
    };
    return Scaffold(
      backgroundColor: const Color(0xffE0FFEE),
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
                Padding(
                  padding: HWEdgeInsets.symmetric(horizontal: 40.0),
                  child: Column(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          AppAssets.enterSvg,
                          width: 15,
                          height: 15,
                          color: Color(0xff388CFF),
                        ),
                        10.horizontalSpace,
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyTextWidget(
                              LocaleKeys.logged_in_successfully.tr(),
                              style: context.textTheme.titleLarge?.ra.copyWith(
                                  color: Color(0xff5D5C5D), height: 1.42),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: HWEdgeInsets.only(top: 3.0),
                                  child: SvgPicture.asset(
                                      AppAssets.phoneCallSvg,
                                      width: 10,
                                      height: 10),
                                ),
                                5.horizontalSpace,
                                MyTextWidget(
                                  widget.phoneNumber,
                                  textAlign: TextAlign.start,
                                  style: context.textTheme.titleMedium?.ra
                                      .copyWith(
                                          color: Color(0xff8D8D8D),
                                          height: 1.25),
                                ),
                              ],
                            ),
                            10.verticalSpace,
                            Padding(
                              padding: HWEdgeInsets.only(left: 30.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: HWEdgeInsets.only(left: 4.0),
                                    child: MyTextWidget(LocaleKeys.hello.tr(),
                                        textAlign: TextAlign.start,
                                        style: textTheme.headlineMedium?.ba
                                            .copyWith(
                                                color: Color(0xff5D5C5D),
                                                height: 1.25)),
                                  ),
                                  17.verticalSpace,
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      BlocBuilder<AuthBloc, AuthState>(
                                        builder: (context, state) {
                                          if (state.marketUser!.name == null ||
                                              state.marketUser!.name == '') {
                                            return const SizedBox.shrink();
                                          }
                                          return MyTextWidget(
                                              ',' +
                                                  state.marketUser!.name
                                                      .toString(),
                                              textAlign: TextAlign.start,
                                              style: textTheme
                                                  .headlineMedium?.la
                                                  .copyWith(
                                                color: Color(0xff5D5C5D),
                                                letterSpacing: 0.3,
                                                height: 0.67,
                                              ));
                                        },
                                      ),
                                      18.verticalSpace,
                                      MyTextWidget(
                                          LocaleKeys.enjoy_with_our_services
                                              .tr(),
                                          textAlign: TextAlign.center,
                                          style: textTheme.bodyMedium?.la
                                              .copyWith(
                                                  color: Color(0xff5D5C5D),
                                                  height: 1.25)),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ]),
                ),
                Spacer(),
              ]),
        ],
      ),
    );
  }
}
