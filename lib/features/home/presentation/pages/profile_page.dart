import 'dart:math';

import 'package:country_flags/country_flags.dart';
import 'package:easy_localization/easy_localization.dart' as transform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get_it/get_it.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:trydos/common/constant/design/assets_provider.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/data/model/pagination_model.dart';

import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/core/utils/responsive_padding.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/authentication/presentation/widgets/insert_phone_tab.dart';
import 'package:trydos/features/authentication/presentation/widgets/verification_methods.dart';
import 'package:trydos/features/authentication/presentation/widgets/verify_otp.dart';
import 'package:trydos/features/home/data/models/get_allowed_country_model.dart';
import 'package:trydos/features/home/data/models/starting_settings_response_model.dart';

import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/features/home/presentation/manager/orderBloc/order_event.dart';
import 'package:trydos/features/home/presentation/manager/orderBloc/order_state.dart';
import 'package:trydos/features/home/presentation/widgets/profile_section/language_profile.dart';
import 'package:trydos/features/home/presentation/widgets/profile_section/profile_country_page.dart';
import 'package:trydos/features/home/presentation/widgets/profile_section/user_information_page.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_events.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import 'package:trydos/service/firebase_analytics_service/firebase_analytics_service.dart';
import 'package:trydos/service/language_service.dart';

import '../../../../common/helper/helper_functions.dart';
import '../manager/orderBloc/order_bloc.dart';
import 'Order/orders_page.dart';

class ProfileHomePage extends StatefulWidget {
  const ProfileHomePage({super.key});

  @override
  State<ProfileHomePage> createState() => _ProfileHomePageState();
}

class _ProfileHomePageState extends State<ProfileHomePage> {
  late HomeBloc homeBloc;
  late AuthBloc authBloc;
  late OrderBloc orderBloc;
  final PanelController panelController = PanelController();
  final PageController pageController = PageController();
  final FocusNode focusNode = FocusNode();
  String phoneNumber = '';
  int isVisWhatsApp = 0;
  final ValueNotifier<bool> isVerified = ValueNotifier(true);
  PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  @override
  void initState() {
    authBloc = BlocProvider.of<AuthBloc>(context);
    homeBloc = BlocProvider.of<HomeBloc>(context);
    orderBloc = BlocProvider.of<OrderBloc>(context);
    orderBloc.add(
      GetCustomerWalletEvent(limit: 10, offset: 1),
    );
    orderBloc.add(
      GetOrdersEvent(
        status: "",
        getWithPagination: false,
      ),
    );
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
      child: Stack(
        children: [
          SingleChildScrollView(
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
                  _actionWidget(AppAssets.legalInfoSvg,
                      LocaleKeys.legal_information.tr()),
                  SizedBox(
                    height: 12.h,
                    width: 1.sw,
                  ),
                  _actionWidget(AppAssets.aboutUsSvg, LocaleKeys.about_us.tr()),
                  SizedBox(
                    height: 12.h,
                    width: 1.sw,
                  ),
                  _actionWidget(
                      AppAssets.shareAppSvg, LocaleKeys.share_app.tr()),
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
          ValueListenableBuilder<bool>(
              valueListenable: isVerified,
              builder: (context, _isverified, _) {
                return _isverified
                    ? SizedBox.shrink()
                    : Container(
                        width: 1.sw,
                        height: 1.sh,
                        color: Color.fromRGBO(0, 0, 0, 0.5),
                      );
              }),
          Positioned(
              bottom: 0,
              child: ValueListenableBuilder<bool>(
                  valueListenable: isVerified,
                  builder: (context, _isverified, _) {
                    return _isverified ? SizedBox.shrink() : _veryfiedOtp();
                  }))
        ],
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

  Widget _veryfiedOtp() {
    return Container(
      color: Colors.white,
      height: 265,
      width: 1.sw,
      child: Stack(children: [
        PageView(
            physics: NeverScrollableScrollPhysics(),
            controller: pageController,
            children:
                (prefsRepository.isVerifiedPhonePeforeExpiredToken ?? false)
                    ? [
                        VerifyOtp(
                            fromProfile: false,
                            navigateToProfile: () {},
                            fromExpired: true,
                            isVisWhatsApp: 1,
                            navigateToAddName: () {},
                            navigateTocartOrProfile: () {
                              isVerified.value = true;
                            },
                            fromLogin: false,
                            onLoginFailed: () {
                              //   pageController.animateToPage(3, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
                            },
                            goBack: () {
                              // pageController.animateToPage(1, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
                            },
                            methodIcon: AppAssets.whatsappSvg,
                            phoneNumber: prefsRepository.myPhoneNumber!),
                      ]
                    : [
                        InsertPhoneTab(
                          fromLogin: false,
                          focusNode: focusNode,
                          moveToNextStep: (String phoneNumber) {
                            this.phoneNumber = phoneNumber.replaceAll(' ', '');
                            pageController.animateToPage(1,
                                duration: Duration(milliseconds: 500),
                                curve: Curves.easeInOut);
                            setState(() {});
                          },
                        ),
                        VerificationMethods(
                          isFromLogin: false,
                          phoneNumber: phoneNumber,
                          onChooseWhatsapp: () {
                            isVisWhatsApp = 1;
                            print("###################33333#${isVisWhatsApp}");
                            pageController.animateToPage(2,
                                duration: Duration(milliseconds: 500),
                                curve: Curves.easeInOut);

                            if (prefsRepository.isTimerForOtpRunning ?? false) {
                              showWarningMessage(
                                context,
                                '${LocaleKeys.you_must_wait_for_some_seconds_before_try_again.tr()}',
                              );
                              return;
                            }
                            /*   authBloc.add(
                            SendOtpEvent(phone: phoneNumber, isViaWhatsApp: 1));*/
                          },
                          goBackToPhone: () {
                            pageController.animateToPage(0,
                                duration: Duration(milliseconds: 500),
                                curve: Curves.easeInOut);
                          },
                          onChooseSms: () {
                            isVisWhatsApp = 0;
                            pageController.animateToPage(3,
                                duration: Duration(milliseconds: 500),
                                curve: Curves.easeInOut);
                            /* authBloc.add(
                            SendOtpEvent(phone: phoneNumber, isViaWhatsApp: 0));*/
                          },
                        ),
                        VerifyOtp(
                            fromProfile: false,
                            navigateToProfile: () {},
                            fromExpired: true,
                            isVisWhatsApp: isVisWhatsApp,
                            navigateToAddName: () {},
                            navigateTocartOrProfile: () {
                              isVerified.value = true;
                              orderBloc.add(
                                GetCustomerWalletEvent(limit: 10, offset: 1),
                              );
                              orderBloc.add(
                                GetOrdersEvent(
                                  status: "",
                                  getWithPagination: false,
                                ),
                              );
                            },
                            fromLogin: false,
                            onLoginFailed: () {
                              pageController.animateToPage(3,
                                  duration: Duration(milliseconds: 500),
                                  curve: Curves.easeInOut);
                            },
                            goBack: () {
                              pageController.animateToPage(1,
                                  duration: Duration(milliseconds: 500),
                                  curve: Curves.easeInOut);
                            },
                            methodIcon: isVisWhatsApp == 1
                                ? AppAssets.whatsappSvg
                                : AppAssets.smsSvg,
                            phoneNumber: phoneNumber),
                      ]),
        Positioned(
          top: 0,
          left: LanguageService.languageCode != "ar" ? null : 0,
          right: LanguageService.languageCode != "ar" ? 0 : null,
          child: Container(
            margin: EdgeInsets.all(10),
            height: 20,
            width: 40,
            child: InkWell(
                onTap: () => isVerified.value = true,
                child: SvgPicture.asset(
                  AppAssets.closeSvg,
                  height: 15,
                  width: 30,
                  color: Color(0xffFF5F61),
                )),
          ),
        )
      ]),
    );
  }

  Widget _languageWidget() {
    List<Language> language = [];

    int languageIndex;

    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) =>
          previous.getStartingSettingsStatus !=
          current.getStartingSettingsStatus,
      builder: (context, state) {
        language = state.startingSetting?.languages ?? [];
        languageIndex = language.indexWhere(
            (element) => element.code == LanguageService.languageCode);
        return (state.getStartingSettingsStatus !=
                    GetStartingSettingsStatus.success &&
                languageIndex == -1)
            ? Container(
                width: 195.w,
                height: 53,
                child: Shimmer.fromColors(
                    baseColor: Colors.grey[200]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                        width: 195,
                        height: 53,
                        margin: HWEdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xffFAFAFA),
                          borderRadius: BorderRadius.circular(20.0),
                        ))))
            : InkWell(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ProfileLanguagePage())),
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
                        SvgPicture.asset(
                          AppAssets.languageSvg,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "${language[languageIndex].name}",
                          style: context.textTheme.bodyMedium?.rr.copyWith(
                              color: const Color(0xff1D1D1D),
                              letterSpacing: 0.18,
                              fontSize: 14,
                              height: 1.3),
                        ),
                      ],
                    )),
              );
      },
    );
  }

  Widget _countryWidget() {
    String choosedCountryIso =
        (GetIt.I<PrefsRepository>().userCountryIsAvailable == 1
                ? GetIt.I<PrefsRepository>().userChoosedCountryIso
                : GetIt.I<PrefsRepository>().countryIso) ??
            "";
    List<Country>? allowCountries;
    Country? country;
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) =>
          previous.getAllowedCountriesModel?.data?.countries?.length !=
          current.getAllowedCountriesModel?.data?.countries?.length,
      builder: (context, state) {
        allowCountries =
            homeBloc.state.getAllowedCountriesModel?.data?.countries ?? [];
        country = allowCountries?.firstWhere(
            (element) => '${choosedCountryIso.toLowerCase()}'
                .startsWith(element.iso!.toLowerCase()),
            orElse: () => Country(id: -1));
        return (allowCountries.isNullOrEmpty || country?.id == -1)
            ? Container(
                width: 195.w,
                height: 53,
                child: Shimmer.fromColors(
                    baseColor: Colors.grey[200]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                        width: 195,
                        height: 53,
                        margin: HWEdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xffFAFAFA),
                          borderRadius: BorderRadius.circular(20.0),
                        ))))
            : InkWell(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ProfileCountryPage())),
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
                            child: country!.iso!.toUpperCase() == "SY"
                                ? SvgPicture.asset(
                                    AppAssets.syriaFlagSvg,
                                  )
                                : CountryFlag.fromCountryCode(
                                    country!.iso!.toUpperCase(),
                                    height: 25,
                                    width: 25,
                                    borderRadius: 4.r,
                                  )),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          country?.name ?? "",
                          style: context.textTheme.bodyMedium?.rr.copyWith(
                              color: const Color(0xff1D1D1D),
                              letterSpacing: 0.18,
                              fontSize: 14,
                              height: 1.3),
                        ),
                      ],
                    )),
              );
      },
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
      child: BlocBuilder<OrderBloc, OrderState>(
        buildWhen: (previous, current) =>
            previous.getOrdersModel?[""]?.paginationStatus !=
            current.getOrdersModel?[""]?.paginationStatus,
        builder: (context, state) {
          return Container(
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
                state.getOrdersModel?[""]?.paginationStatus ==
                        PaginationStatus.loading
                    ? Container(
                        alignment: Alignment.center,
                        width: 40,
                        height: 20,
                        child: TrydosLoader(
                          size: 20,
                        ),
                      )
                    : Text(
                        '${state.orderTotalSize} ${LocaleKeys.action.tr()}',
                        style: context.textTheme.bodyMedium?.rr.copyWith(
                            color: const Color(0xff8D8D8D),
                            letterSpacing: 0.18,
                            fontSize: 12,
                            height: 1.3),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _trydosWalletWidget() {
    return BlocBuilder<OrderBloc, OrderState>(
      buildWhen: (previous, current) =>
          previous.getCustomerWalletStatus != current.getCustomerWalletStatus,
      builder: (context, state) {
        double walletBalance = state.customerWalletModel == null
            ? 0
            : state.customerWalletModel!.data.totalWalletBalance!;
        String symbole = state.customerWalletModel == null
            ? ''
            : state.customerWalletModel!.data.currencySymbol ?? '';
        return Container(
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
              state.getCustomerWalletStatus == GetCustomerWalletStatus.loading
                  ? Container(
                      alignment: Alignment.center,
                      width: 40,
                      height: 20,
                      child: TrydosLoader(
                        size: 20,
                      ),
                    )
                  : Text(
                      '${LocaleKeys.your_balance.tr()} ${(walletBalance).toStringAsFixed(GetIt.I<HomeBloc>().state.startingSetting?.decimalPointSettings ?? 2)} ${symbole}',
                      style: context.textTheme.bodyMedium?.rr.copyWith(
                          color: const Color(0xff8D8D8D),
                          letterSpacing: 0.18,
                          fontSize: 12,
                          height: 1.3),
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget _personInfoWidget() {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) =>
          previous.verifyOtpSignInStatus != current.verifyOtpSignInStatus ||
          previous.verifyOtpSignUpStatus != current.verifyOtpSignUpStatus ||
          previous.verifyOtpFromGuestStatus != current.verifyOtpFromGuestStatus,
      builder: (context, state) {
        return InkWell(
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => UserInformationPage())),
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
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Container(
                            height: 16,
                            child: Text(
                              (prefsRepository.myPhoneNumber?.length ?? 0) < 4
                                  ? ""
                                  : (prefsRepository.myPhoneNumber ?? "")
                                          .startsWith("+")
                                      ? "${prefsRepository.myPhoneNumber ?? ''}"
                                      : "+" +
                                          "${prefsRepository.myPhoneNumber ?? ''}",
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
                            '${LocaleKeys.add.tr()} ' +
                                "${LocaleKeys.size.tr()}",
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
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.r)),
                            border: Border.all(
                                color: !(prefsRepository.myProfilePhoto ==
                                            null ||
                                        prefsRepository.myProfilePhoto == "")
                                    ? Colors.white
                                    : Color(0xff1D1D1D))),
                        child: !(prefsRepository.myProfilePhoto == null ||
                                prefsRepository.myProfilePhoto == "")
                            ? ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15.r)),
                                child: MyCachedNetworkImage(
                                    imageUrl:
                                        prefsRepository.myProfilePhoto ?? "",
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
                                  prefsRepository.myMarketName ?? '',
                                  context.textTheme.bodyMedium!.mr.copyWith(
                                      color: const Color(0xff1D1D1D),
                                      letterSpacing: 0.18,
                                      fontSize: 14,
                                      height: 1.3)),
                              _calculateTextWidth(
                                  prefsRepository.myPhoneNumber ?? '',
                                  context.textTheme.bodyMedium!.rr.copyWith(
                                      color: const Color(0xff8D8D8D),
                                      letterSpacing: 0.18,
                                      fontSize: 12,
                                      height: 1.3))),
                      right: LanguageService.languageCode != "ar"
                          ? null
                          : max(
                              _calculateTextWidth(
                                  prefsRepository.myMarketName ?? '',
                                  context.textTheme.bodyMedium!.mr.copyWith(
                                      color: const Color(0xff1D1D1D),
                                      letterSpacing: 0.18,
                                      fontSize: 14,
                                      height: 1.3)),
                              _calculateTextWidth(
                                  prefsRepository.myPhoneNumber ?? '',
                                  context.textTheme.bodyMedium!.rr.copyWith(
                                      color: const Color(0xff8D8D8D),
                                      letterSpacing: 0.18,
                                      fontSize: 12,
                                      height: 1.3))),
                      child: ValueListenableBuilder<bool>(
                          valueListenable: isVerified,
                          builder: (context, _isverified, _) {
                            return InkWell(
                              onTap: () {
                                if (!(prefsRepository.isVerifiedPhone ??
                                    false)) {
                                  isVerified.value = false;
                                }
                              },
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
                                            color: Color(0xff707070),
                                            height: 5,
                                            width: 5),
                                      ],
                                    ),
                                    Spacer(),
                                    Text(
                                      (prefsRepository.isVerifiedPhone ?? false)
                                          ? '${LocaleKeys.verified.tr()}'
                                          : '${LocaleKeys.verified_now.tr()}',
                                      style: context.textTheme.bodyMedium?.rr
                                          .copyWith(
                                              color: (prefsRepository
                                                          .isVerifiedPhone ??
                                                      false)
                                                  ? Colors.green
                                                  : const Color(0xffFF5F61),
                                              letterSpacing: 0.18,
                                              fontSize: 10,
                                              height: 1.3),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
