import 'dart:math';

import 'package:easy_localization/easy_localization.dart' as transform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get_it/get_it.dart';
import 'package:trydos/common/constant/design/assets_provider.dart';
import 'package:trydos/config/theme/typography.dart';

import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';

import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/generated/locale_keys.g.dart';

class ProfileHomePage extends StatefulWidget {
  const ProfileHomePage({super.key});

  @override
  State<ProfileHomePage> createState() => _ProfileHomePageState();
}

class _ProfileHomePageState extends State<ProfileHomePage> {
  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
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

    return Scaffold(
        body: SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              SizedBox(
                height: 25.h,
                width: 1.sw,
              ),
              _personInfoWidget(),
              SizedBox(
                height: 20.h,
                width: 1.sw,
              ),
              Container(
                width: 1.sw,
                height: 94,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [_ordersWidget(), _trydosWalletWidget()],
                ),
              ),
              SizedBox(
                height: 12.h,
                width: 1.sw,
              ),
              _actionWidget(AppAssets.settingSvg, LocaleKeys.settings.tr()),
              SizedBox(
                height: 12.h,
                width: 1.sw,
              ),
              _actionWidget(
                  AppAssets.termSvg, LocaleKeys.terms_conditions.tr()),
              SizedBox(
                height: 12.h,
                width: 1.sw,
              ),
              _actionWidget(
                  AppAssets.legalInfoSvg, LocaleKeys.legal_information.tr()),
              SizedBox(
                height: 12.h,
                width: 1.sw,
              ),
              _actionWidget(AppAssets.aboutUsSvg, LocaleKeys.about_us.tr()),
              SizedBox(
                height: 12.h,
                width: 1.sw,
              ),
              _actionWidget(AppAssets.shareAppSvg, LocaleKeys.share_app.tr()),
              SizedBox(
                height: 12.h,
                width: 1.sw,
              ),
              Container(
                  padding: const EdgeInsets.all(12),
                  height: 90,
                  width: 1.sw,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                          decoration: BoxDecoration(
                              color: Color(0xffF8F8F8),
                              borderRadius: BorderRadius.circular(15.r)),
                          width: 195.w,
                          height: 53,
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                AppAssets.languageSvg,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                "   actionName",
                                style: context.textTheme.bodyMedium?.rr
                                    .copyWith(
                                        color: const Color(0xff1D1D1D),
                                        letterSpacing: 0.18,
                                        fontSize: 14,
                                        height: 1.3),
                              ),
                            ],
                          )),
                      Container(
                          decoration: BoxDecoration(
                              color: Color(0xffF8F8F8),
                              borderRadius: BorderRadius.circular(15.r)),
                          width: 195.w,
                          height: 53,
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                AppAssets.languageSvg,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                "   actionName",
                                style: context.textTheme.bodyMedium?.rr
                                    .copyWith(
                                        color: const Color(0xff1D1D1D),
                                        letterSpacing: 0.18,
                                        fontSize: 14,
                                        height: 1.3),
                              ),
                            ],
                          ))
                    ],
                  ))
            ],
          ),
        ),
      ),
    ));
  }

  double _calculateTextWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: 130);
    return textPainter.size.width;
  }

  Widget _actionWidget(String svgUrl, String actionName) {
    return Container(
        padding: const EdgeInsets.all(12),
        height: 53,
        width: 1.sw,
        decoration: BoxDecoration(
            color: Color(0xffF8F8F8),
            borderRadius: BorderRadius.circular(15.r)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SvgPicture.asset(
              svgUrl,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              actionName,
              style: context.textTheme.bodyMedium?.rr.copyWith(
                  color: const Color(0xff1D1D1D),
                  letterSpacing: 0.18,
                  fontSize: 14,
                  height: 1.3),
            ),
          ],
        ));
  }

  Widget _ordersWidget() {
    return Container(
      padding: EdgeInsets.all(10),
      width: 195.w,
      decoration: BoxDecoration(
          color: Color(0xffF8F8F8), borderRadius: BorderRadius.circular(15.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SvgPicture.asset(
            AppAssets.bagsSvg,
            width: 25,
          ),
          Text(
            LocaleKeys.order_invoice.tr(),
            style: context.textTheme.bodyMedium?.mr.copyWith(
                color: const Color(0xff1D1D1D),
                letterSpacing: 0.18,
                fontSize: 14,
                height: 1.3),
          ),
          Text(
            '1 ${LocaleKeys.action.tr()}',
            style: context.textTheme.bodyMedium?.rr.copyWith(
                color: const Color(0xff8D8D8D),
                letterSpacing: 0.18,
                fontSize: 12,
                height: 1.3),
          ),
        ],
      ),
    );
  }

  Widget _trydosWalletWidget() {
    return Container(
      padding: EdgeInsets.all(10),
      width: 195.w,
      decoration: BoxDecoration(
          color: Color(0xffF8F8F8), borderRadius: BorderRadius.circular(15.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SvgPicture.asset(
            AppAssets.trydosWalletSvg,
            color: const Color(0xff3C3C3C),
            width: 25,
          ),
          Text(
            LocaleKeys.trydos.tr() + " " + LocaleKeys.wallet.tr(),
            style: context.textTheme.bodyMedium?.mr.copyWith(
                color: const Color(0xff1D1D1D),
                letterSpacing: 0.18,
                fontSize: 14,
                height: 1.3),
          ),
          Text(
            '300 USD ${LocaleKeys.your_balance.tr()}',
            style: context.textTheme.bodyMedium?.rr.copyWith(
                color: const Color(0xff8D8D8D),
                letterSpacing: 0.18,
                fontSize: 12,
                height: 1.3),
          ),
        ],
      ),
    );
  }

  Widget _personInfoWidget() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Color(0xffF8F8F8), borderRadius: BorderRadius.circular(15.r)),
      width: 1.sw,
      height: 138,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                AppAssets.parcodeSvg,
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 20,
                child: Text(
                  prefsRepository.myMarketName ?? '',
                  style: context.textTheme.bodyMedium?.mr.copyWith(
                      color: const Color(0xff1D1D1D),
                      letterSpacing: 0.18,
                      fontSize: 14,
                      height: 1.3),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                height: 16,
                width: 130,
                child: Text(
                  "+" + "${prefsRepository.myPhoneNumber ?? ''}",
                  style: context.textTheme.bodyMedium?.rr.copyWith(
                      color: const Color(0xff8D8D8D),
                      letterSpacing: 0.18,
                      fontSize: 12,
                      height: 1.3),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                height: 16,
                width: 130,
                child: Text(
                  '${LocaleKeys.add.tr()} ' + "${LocaleKeys.size.tr()}",
                  style: context.textTheme.bodyMedium?.rr.copyWith(
                      color: const Color(0xff8D8D8D),
                      letterSpacing: 0.18,
                      fontSize: 12,
                      height: 1.3),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Color(0xff1D1D1D))),
              child: Center(
                child: SvgPicture.asset(
                  AppAssets.trySvg,
                ),
              ),
            ),
          ),
          Positioned(
            top: 38,
            left: max(
                _calculateTextWidth(prefsRepository.myMarketName ?? '',
                    TextStyle(fontSize: 15)),
                _calculateTextWidth(prefsRepository.myPhoneNumber ?? '',
                    TextStyle(fontSize: 15))),
            child: Container(
              height: 35,
              width: 60,
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SvgPicture.asset(
                        AppAssets.succuessProfileSvg,
                        color: Color(0xff707070),
                        height: 16,
                        width: 16,
                      ),
                      SvgPicture.asset(AppAssets.success2Svg,
                          color: Color(0xff707070), height: 5, width: 5),
                    ],
                  ),
                  Spacer(),
                  Text(
                    '${LocaleKeys.verified_now.tr()}',
                    style: context.textTheme.bodyMedium?.rr.copyWith(
                        color: const Color(0xffFF5F61),
                        letterSpacing: 0.18,
                        fontSize: 10,
                        height: 1.3),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
