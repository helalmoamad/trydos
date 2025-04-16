import 'dart:math';

import 'package:country_flags/country_flags.dart';
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
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/home/data/models/get_allowed_country_model.dart';

import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/profile_section/profile_country_page.dart';
import 'package:trydos/features/home/presentation/widgets/profile_section/user_information_page.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/language_service.dart';

import '../../../../common/helper/helper_functions.dart';
import 'Order/orders_page.dart';

class ProfileHomePage extends StatefulWidget {
  const ProfileHomePage({super.key});

  @override
  State<ProfileHomePage> createState() => _ProfileHomePageState();
}

class _ProfileHomePageState extends State<ProfileHomePage> {
  late HomeBloc homeBloc;
  @override
  void initState() {
    homeBloc = BlocProvider.of<HomeBloc>(context);
    homeBloc.add(UpdateProfileEvent(changeStatusToInit: true));
    // TODO: implement initState
    super.initState();
  }

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
                  children: [
                    _ordersWidget(),
                    _trydosWalletWidget(),
                  ],
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
                  height: 53,
                  width: 1.sw,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [_countryWidget(), _languageWidget()],
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

  Widget _languageWidget() {
    return Container(
        decoration: BoxDecoration(
            color: Color(0xffF8F8F8),
            borderRadius: BorderRadius.circular(15.r)),
        width: 195.w,
        height: 53,
        child: Row(
          children: [
            SizedBox(
              width: 10,
            ),
            SvgPicture.asset(
              AppAssets.languageSvg,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              "English",
              style: context.textTheme.bodyMedium?.rr.copyWith(
                  color: const Color(0xff1D1D1D),
                  letterSpacing: 0.18,
                  fontSize: 14,
                  height: 1.3),
            ),
          ],
        ));
  }

  Widget _countryWidget() {
    String choosedCountryIso =
        (GetIt.I<PrefsRepository>().userCountryIsAvailable == 1
                ? GetIt.I<PrefsRepository>().userChoosedCountryIso
                : GetIt.I<PrefsRepository>().countryIso) ??
            "";
    List<Country>? alowCountries =
        homeBloc.state.getAllowedCountriesModel?.data?.countries;
    Country? country = alowCountries?.firstWhere(
        (element) => '${choosedCountryIso.toLowerCase()}'
            .startsWith(element.iso!.toLowerCase()),
        orElse: () => alowCountries[0]);
    return InkWell(
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => ProfileCountryPage())),
      child: Container(
          decoration: BoxDecoration(
              color: Color(0xffF8F8F8),
              borderRadius: BorderRadius.circular(15.r)),
          width: 195.w,
          height: 53,
          child: Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Container(
                  width: 25,
                  height: 25,
                  child: CountryFlag.fromCountryCode(
                    country!.iso!.toUpperCase(),
                    height: 25,
                    width: 25,
                    borderRadius: 4.r,
                  )),
              SizedBox(
                width: 10,
              ),
              Text(
                country.name ?? "",
                style: context.textTheme.bodyMedium?.rr.copyWith(
                    color: const Color(0xff1D1D1D),
                    letterSpacing: 0.18,
                    fontSize: 14,
                    height: 1.3),
              ),
            ],
          )),
    );
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
    return InkWell(
      onTap: () {
        HelperFunctions.slidingNavigation(
          context,
          OrdersPage(),
        );
      },
      child: Container(
        padding: EdgeInsets.all(10),
        width: 195.w,
        decoration: BoxDecoration(
            color: Color(0xffF8F8F8),
            borderRadius: BorderRadius.circular(15.r)),
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
      ),
    );
  }

  Widget _trydosWalletWidget() {
    double walletBalance =
        BlocProvider.of<HomeBloc>(context).state.customerWalletModel == null
            ? 0
            : BlocProvider.of<HomeBloc>(context)
                    .state
                    .customerWalletModel!
                    .data
                    .totalWalletBalance! *
                BlocProvider.of<HomeBloc>(context)
                    .state
                    .getCurrencyForCountryModel!
                    .data!
                    .currency!
                    .exchangeRate!;
    String symbole = BlocProvider.of<HomeBloc>(context)
            .state
            .getCurrencyForCountryModel!
            .data!
            .currency!
            .symbol ??
        "";
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
            LanguageService.languageCode == "ar"
                ? LocaleKeys.wallet.tr() + " " + LocaleKeys.trydos.tr()
                : LocaleKeys.trydos.tr() + " " + LocaleKeys.wallet.tr(),
            style: context.textTheme.bodyMedium?.mr.copyWith(
                color: const Color(0xff1D1D1D),
                letterSpacing: 0.18,
                fontSize: 14,
                height: 1.3),
          ),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              '${walletBalance} ${symbole}',
              style: context.textTheme.bodyMedium?.rr.copyWith(
                  color: const Color(0xff8D8D8D),
                  letterSpacing: 0.18,
                  fontSize: 12,
                  height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _personInfoWidget() {
    return InkWell(
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => UserInformationPage())),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Color(0xffF8F8F8),
            borderRadius: BorderRadius.circular(15.r)),
        width: 1.sw,
        height: 138,
        child: BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (previous, current) =>
              previous.updateProfileStatus != current.updateProfileStatus,
          builder: (context, state) {
            return Stack(
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
                        state.userInfo?.name ?? '',
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
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Container(
                        height: 16,
                        child: Text(
                          "${state.userInfo?.phone ?? ''}",
                          style: context.textTheme.bodyMedium?.rr.copyWith(
                              color: const Color(0xff8D8D8D),
                              letterSpacing: 0.18,
                              fontSize: 12,
                              height: 1.3),
                        ),
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
                  right: LanguageService.languageCode == "ar" ? null : 0,
                  left: LanguageService.languageCode != "ar" ? null : 0,
                  child: Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(15.r)),
                        border: Border.all(
                            color: state.userInfo?.image != null
                                ? Colors.white
                                : Color(0xff1D1D1D))),
                    child: state.userInfo?.image != null
                        ? ClipRRect(
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.r)),
                            child: MyCachedNetworkImage(
                                imageUrl: state.userInfo?.image ?? "",
                                width: 70,
                                imageFit: BoxFit.cover,
                                height: 70),
                          )
                        : Center(
                            child: SvgPicture.asset(
                              AppAssets.trySvg,
                            ),
                          ),
                  ),
                ),
                Positioned(
                  top: 38,
                  left: LanguageService.languageCode == "ar"
                      ? null
                      : max(
                          _calculateTextWidth(
                              state.userInfo?.name ?? '',
                              context.textTheme.bodyMedium!.mr.copyWith(
                                  color: const Color(0xff1D1D1D),
                                  letterSpacing: 0.18,
                                  fontSize: 14,
                                  height: 1.3)),
                          _calculateTextWidth(
                              state.userInfo?.phone ?? '',
                              context.textTheme.bodyMedium!.rr.copyWith(
                                  color: const Color(0xff8D8D8D),
                                  letterSpacing: 0.18,
                                  fontSize: 12,
                                  height: 1.3))),
                  right: LanguageService.languageCode != "ar"
                      ? null
                      : max(
                          _calculateTextWidth(
                              state.userInfo?.name ?? '',
                              context.textTheme.bodyMedium!.mr.copyWith(
                                  color: const Color(0xff1D1D1D),
                                  letterSpacing: 0.18,
                                  fontSize: 14,
                                  height: 1.3)),
                          _calculateTextWidth(
                              state.userInfo?.phone ?? '',
                              context.textTheme.bodyMedium!.rr.copyWith(
                                  color: const Color(0xff8D8D8D),
                                  letterSpacing: 0.18,
                                  fontSize: 12,
                                  height: 1.3))),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 15),
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
            );
          },
        ),
      ),
    );
  }
}
