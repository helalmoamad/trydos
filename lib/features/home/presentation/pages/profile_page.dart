//import 'dart:convert';
import 'dart:async';
import 'dart:math';

import 'package:flutter/scheduler.dart';
import 'package:country_flags/country_flags.dart';
import 'package:easy_localization/easy_localization.dart' as transform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get_it/get_it.dart';
//import 'package:qr_flutter/qr_flutter.dart';
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
import 'package:trydos/features/dashBoard/presentation/bloc/dashBoard_bloc.dart'
    as dashboard;
import 'package:trydos/features/dashBoard/presentation/pages/SelectShopForOrderPage.dart';
import 'package:trydos/features/dashBoard/presentation/pages/select_shop_page.dart';
import 'package:trydos/features/home/data/models/get_allowed_country_model.dart';
import 'package:trydos/features/home/presentation/pages/become_seller/become_seller_page.dart';
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

import 'package:trydos/service/language_service.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
// import 'package:trydos_wallet/trydos_wallet.dart';
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
  late dashboard.DashboardBloc dashboardBloc;
  late AuthBloc authBloc;
  late OrderBloc orderBloc;
  final PanelController panelController = PanelController();
  final PageController pageController = PageController();
  final FocusNode focusNode = FocusNode();
  String phoneNumber = '';
  int isVisWhatsApp = 0;
  final ValueNotifier<bool> isVerified = ValueNotifier(true);
  PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  // late StreamSubscription walletEvents;

  // لإدارة الموارد بشكل آمن
  bool _isWalletInitialized = false;
  @override
  void initState() {
    LastPagesTracker.push("ProfileHome Page");
    authBloc = BlocProvider.of<AuthBloc>(context);
    homeBloc = BlocProvider.of<HomeBloc>(context);
    dashboardBloc = BlocProvider.of<dashboard.DashboardBloc>(context);
    //authBloc.add(CreateWalletEvent());
    orderBloc = BlocProvider.of<OrderBloc>(context);
    homeBloc.add(
      GetCurrenciesForWalletEvent(
        currencySymbol:
            homeBloc.state.getCurrencyForCountryModel?.data?.currency?.code ??
            "",
      ),
    );

    authBloc.add(GetCustomerInfoEvent());
    orderBloc.add(GetOrdersEvent(status: "", getWithPagination: false));
    homeBloc.add(UpdateProfileEvent(changeStatusToInit: true));
    // walletEvents = authEvents.listen((evt) async {
    //   if (evt.toString() == 'AuthEvent.unauthenticated' &&
    //       (prefsRepository.isVerifiedPhone ?? false)) {
    //     prefsRepository.setVerifiedPhone(false);
    //     prefsRepository.setVerifiedPhonePeforeExpiredToken(true);
    //     await Future.delayed(const Duration(seconds: 1));

    //     // استخدم SchedulerBinding لتأخير العملية بعد انتهاء البناء
    //     if (mounted) {
    //       SchedulerBinding.instance.addPostFrameCallback((_) {
    //         if (mounted && Navigator.of(context).canPop()) {
    //           Navigator.of(context).pop();
    //         }
    //       });
    //     }

    //     await Future.delayed(const Duration(seconds: 1));
    //     isVerified.value = false;

    //     authBloc.add(
    //       SendOtpEvent(phone: prefsRepository.myPhoneNumber!, isViaWhatsApp: 1),
    //     );
    //   }
    // });

    // لاحقًا إذا لم تعد بحاجة:

    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // walletEvents.cancel();

    // تنظيف موارد المحفظة
    _cleanupWallet();

    // تنظيف باقي الموارد
    pageController.dispose();
    focusNode.dispose();
    isVerified.dispose();

    super.dispose();
  }

  /// تنظيف موارد المحفظة بشكل آمن
  Future<void> _cleanupWallet() async {
    if (_isWalletInitialized) {
      try {
        // يمكنك إضافة طلب لإغلاق المحفظة إذا كانت المكتبة توفرها
        // await TrydosWallet.dispose();
        _isWalletInitialized = false;
      } catch (e) {
        print('Error cleaning up wallet: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Column(
                  children: [
                    SizedBox(height: 18.h, width: 1.sw),
                    _personInfoWidget(),
                    SizedBox(height: 18.h, width: 1.sw),

                    BlocBuilder<
                      dashboard.DashboardBloc,
                      dashboard.DashBoardState
                    >(
                      buildWhen: (previous, current) =>
                          previous.getUserPermissionStatus !=
                          current.getUserPermissionStatus,
                      builder: (context, state) {
                        if (state.getUserPermissionStatus ==
                            dashboard.GetUserPermissionStatus.loading) {
                          return Shimmer.fromColors(
                            baseColor: Colors.grey[200]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: 1.sw,
                              height: 54.h,
                              decoration: BoxDecoration(
                                color: const Color(0xffFAFAFA),
                                borderRadius: BorderRadius.circular(15.r),
                              ),
                            ),
                          );
                        }
                        if (state.getUserPermissionStatus ==
                                dashboard.GetUserPermissionStatus.success &&
                            (!(state.shops?.isNullOrEmpty ?? true))) {
                          return InkWell(
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) =>
                              //         const SelectShopForOrderPage(),
                              //   ),
                              // );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SelectShopPage(),
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(10.h),
                              height: 130.h,
                              width: 1.sw,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1D1D1D),
                                borderRadius: BorderRadius.circular(15.r),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SvgPicture.asset(
                                    AppAssets.BagwhiteSvg,
                                    width: 25.w,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    LocaleKeys.Sellers.tr(),
                                    style: TextStyle(
                                      color: const Color(0xFFFCFCFC),
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                  BlocBuilder<OrderBloc, OrderState>(
                                    builder: (context, state) {
                                      return Text(
                                        "${state.orderTotalSize} ${LocaleKeys.action.tr()}",
                                        style: TextStyle(
                                          color: const Color(0xFFFCFCFC),
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),

                    SizedBox(height: 18.h, width: 1.sw),
                    Container(
                      width: 1.sw,
                      height: 94.h,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [_ordersWidget(), _trydosWalletWidget()],
                      ),
                    ),
                    SizedBox(height: 10.h, width: 1.sw),
                    // BlocBuilder<
                    //   dashboard.DashboardBloc,
                    //   dashboard.DashBoardState
                    // >(
                    //   buildWhen: (previous, current) =>
                    //       previous.getUserPermissionStatus !=
                    //       current.getUserPermissionStatus,
                    //   builder: (context, state) {
                    //     return state.getUserPermissionStatus ==
                    //             dashboard.GetUserPermissionStatus.loading
                    //         ? Shimmer.fromColors(
                    //             baseColor: Colors.grey[200]!,
                    //             highlightColor: Colors.grey[100]!,
                    //             child: Container(
                    //               width: 1.sw,
                    //               height: 54.h,
                    //               decoration: BoxDecoration(
                    //                 color: const Color(0xffFAFAFA),
                    //                 borderRadius: BorderRadius.circular(15.r),
                    //               ),
                    //             ),
                    //           )
                    //         : (state.getUserPermissionStatus ==
                    //                   dashboard
                    //                       .GetUserPermissionStatus
                    //                       .success &&
                    //               (!(state.shops?.isNullOrEmpty ?? true)))
                    //         ? InkWell(
                    //             onTap: () {
                    //               Navigator.push(
                    //                 context,
                    //                 MaterialPageRoute(
                    //                   builder: (context) =>
                    //                       const SelectShopPage(),
                    //                 ),
                    //               );
                    //             },
                    //             child: _actionWidget(
                    //               AppAssets.marketSvg,
                    //               LocaleKeys.go_to_seller_dashboard.tr(),
                    //             ),
                    //           )
                    //         : const SizedBox.shrink();
                    //   },
                    // ),
                    SizedBox(height: 10.h, width: 1.sw),
                    BlocBuilder<
                      dashboard.DashboardBloc,
                      dashboard.DashBoardState
                    >(
                      buildWhen: (previous, current) =>
                          previous.getUserPermissionStatus !=
                          current.getUserPermissionStatus,
                      builder: (context, state) {
                        return state.getUserPermissionStatus ==
                                dashboard.GetUserPermissionStatus.loading
                            ? Shimmer.fromColors(
                                baseColor: Colors.grey[200]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  width: 1.sw,
                                  height: 54.h,
                                  decoration: BoxDecoration(
                                    color: const Color(0xffFAFAFA),
                                    borderRadius: BorderRadius.circular(15.r),
                                  ),
                                ),
                              )
                            : (state.getUserPermissionStatus ==
                                      dashboard
                                          .GetUserPermissionStatus
                                          .success &&
                                  (!(state.shops?.isNullOrEmpty ?? true)))
                            ? (state.shops?.first.isMaster ?? false)
                                  ? const SizedBox.shrink()
                                  : InkWell(
                                      onTap: () {
                                        if (!(prefsRepository.isVerifiedPhone ??
                                            false)) {
                                          isVerified.value = false;
                                          if ((prefsRepository
                                                  .isVerifiedPhonePeforeExpiredToken ??
                                              false)) {
                                            authBloc.add(
                                              SendOtpEvent(
                                                phone: prefsRepository
                                                    .myPhoneNumber!,
                                                isViaWhatsApp: 1,
                                              ),
                                            );
                                          }
                                          return;
                                        }
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (context) => SizedBox(
                                            height:
                                                MediaQuery.of(
                                                  context,
                                                ).size.height *
                                                0.8,
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                bottom: MediaQuery.of(
                                                  context,
                                                ).viewInsets.bottom,
                                              ),
                                              child: const BecomeSellerPage(),
                                            ),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: EdgeInsetsGeometry.only(
                                          bottom: 10.h,
                                        ),
                                        child: _actionWidget(
                                          AppAssets.sellerSvg,
                                          LocaleKeys.become_a_seller_at_trydos
                                              .tr(),
                                        ),
                                      ),
                                    )
                            : const SizedBox.shrink();
                      },
                    ),

                    _actionWidget(
                      AppAssets.settingSvg,
                      LocaleKeys.settings.tr(),
                    ),

                    SizedBox(height: 10.h, width: 1.sw),
                    _actionWidget(
                      AppAssets.termSvg,
                      LocaleKeys.terms_conditions.tr(),
                    ),
                    SizedBox(height: 10.h, width: 1.sw),
                    _actionWidget(
                      AppAssets.legalInfoSvg,
                      LocaleKeys.legal_information.tr(),
                    ),
                    SizedBox(height: 10.h, width: 1.sw),
                    _actionWidget(
                      AppAssets.aboutUsSvg,
                      LocaleKeys.about_us.tr(),
                    ),
                    SizedBox(height: 10.h, width: 1.sw),
                    _actionWidget(
                      AppAssets.shareAppSvg,
                      LocaleKeys.share_app.tr(),
                    ),
                    SizedBox(height: 10.h, width: 1.sw),
                    Container(
                      height: 54.h,
                      width: 1.sw,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [_countryWidget(), _languageWidget()],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: isVerified,
              builder: (context, _isverified, _) {
                return _isverified
                    ? const SizedBox.shrink()
                    : Container(
                        width: 1.sw,
                        height: 1.sh,
                        color: const Color.fromRGBO(0, 0, 0, 0.5),
                      );
              },
            ),
            Positioned(
              bottom: 0,
              child: ValueListenableBuilder<bool>(
                valueListenable: isVerified,
                builder: (context, _isverified, _) {
                  return _isverified ? const SizedBox.shrink() : _veryfiedOtp();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTextWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 130);
    return textPainter.size.width;
  }

  Widget _veryfiedOtp() {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        color: Colors.white,
        height: 265,
        width: 1.sw,
        child: Stack(
          children: [
            PageView(
              physics: const NeverScrollableScrollPhysics(),
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
                        phoneNumber: prefsRepository.myPhoneNumber!,
                      ),
                    ]
                  : [
                      InsertPhoneTab(
                        focusNode: focusNode,
                        moveToNextStep: (String phoneNumber) {
                          this.phoneNumber = phoneNumber.replaceAll(' ', '');
                          pageController.animateToPage(
                            1,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                          setState(() {});
                        },
                      ),
                      VerificationMethods(
                        isFromLogin: false,
                        phoneNumber: phoneNumber,
                        onChooseWhatsapp: () {
                          isVisWhatsApp = 1;
                          print("###################33333# isVisWhatsApp}");
                          pageController.animateToPage(
                            2,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );

                          if (prefsRepository.isTimerForOtpRunning ?? false) {
                            showWarningMessage(
                              context,
                              ' ${LocaleKeys.you_must_wait_for_some_seconds_before_try_again.tr()}',
                            );
                            return;
                          }
                          /*   authBloc.add(
                              SendOtpEvent(phone: phoneNumber, isViaWhatsApp: 1));*/
                        },
                        goBackToPhone: () {
                          pageController.animateToPage(
                            0,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        },
                        onChooseSms: () {
                          isVisWhatsApp = 0;
                          pageController.animateToPage(
                            3,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
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
                          homeBloc.add(
                            GetCurrenciesForWalletEvent(
                              currencySymbol:
                                  homeBloc
                                      .state
                                      .getCurrencyForCountryModel
                                      ?.data
                                      ?.currency
                                      ?.code ??
                                  "",
                            ),
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
                          pageController.animateToPage(
                            3,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        },
                        goBack: () {
                          pageController.animateToPage(
                            1,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        },
                        methodIcon: isVisWhatsApp == 1
                            ? AppAssets.whatsappSvg
                            : AppAssets.smsSvg,
                        phoneNumber: phoneNumber,
                      ),
                    ],
            ),
            Positioned(
              top: 0,
              left: LanguageService.languageCode != "ar" ? null : 0,
              right: LanguageService.languageCode != "ar" ? 0 : null,
              child: Container(
                margin: const EdgeInsets.all(10),
                height: 20,
                width: 40,
                child: InkWell(
                  onTap: () => isVerified.value = true,
                  child: SvgPicture.asset(
                    AppAssets.closeSvg,
                    height: 15,
                    width: 30,
                    // ignore: deprecated_member_use
                    color: const Color(0xffFF5F61),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
          (element) =>
              element.code ==
              (LanguageService.isKurdish ? "ku" : LanguageService.languageCode),
        );
        return (state.getStartingSettingsStatus !=
                    GetStartingSettingsStatus.success &&
                languageIndex == -1)
            ? Container(
                width: 200.w,
                height: 54.h,
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[200]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 200.w,
                    height: 54.h,
                    margin: HWEdgeInsets.symmetric(horizontal: 20.w),
                    decoration: BoxDecoration(
                      color: const Color(0xffFAFAFA),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                ),
              )
            : InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProfileLanguagePage(),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xffF8F8F8),
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  width: 200.w,
                  height: 54.h,
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      SvgPicture.asset(AppAssets.languageSvg, height: 25.h),
                      const SizedBox(width: 10),
                      Text(
                        "${language[languageIndex].name}",
                        style: context.textTheme.bodyMedium?.rq.copyWith(
                          color: const Color(0xff1D1D1D),
                          letterSpacing: 0.18,
                          fontSize: 14.sp,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
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
          (element) => '${choosedCountryIso.toLowerCase()}'.startsWith(
            element.iso!.toLowerCase(),
          ),
          orElse: () => Country(id: -1),
        );
        return (allowCountries.isNullOrEmpty || country?.id == -1)
            ? Container(
                width: 200.w,
                height: 54.h,
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[200]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 200.w,
                    height: 54.h,
                    margin: HWEdgeInsets.symmetric(horizontal: 20.r),
                    decoration: BoxDecoration(
                      color: const Color(0xffFAFAFA),
                      borderRadius: BorderRadius.circular(20.0.r),
                    ),
                  ),
                ),
              )
            : InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProfileCountryPage(),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xffF8F8F8),
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  width: 200.w,
                  height: 54.h,
                  child: Row(
                    children: [
                      SizedBox(width: 10.w),
                      Container(
                        width: 25.w,
                        height: 25.h,
                        child: country!.iso!.toUpperCase() == "SY"
                            ? SvgPicture.asset(AppAssets.syriaFlagSvg)
                            : CountryFlag.fromCountryCode(
                                country!.iso!.toUpperCase(),
                                width: 25.w,
                                height: 25.h,
                                borderRadius: 4.r,
                              ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        country?.name ?? "",
                        style: context.textTheme.bodyMedium?.rq.copyWith(
                          color: const Color(0xff1D1D1D),
                          letterSpacing: 0.18,
                          fontSize: 14.sp,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              );
      },
    );
  }

  Widget _actionWidget(String svgUrl, String actionName) {
    return Container(
      padding: EdgeInsets.all(12.r),
      height: 54.h,
      width: 1.sw,
      decoration: BoxDecoration(
        color: const Color(0xffF8F8F8),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Row(
        children: [
          SvgPicture.asset(svgUrl),
          const SizedBox(width: 10),
          Text(
            actionName,
            style: context.textTheme.bodyMedium?.rq.copyWith(
              color: const Color(0xff1D1D1D),
              letterSpacing: 0.18,
              fontSize: 14.sp,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _ordersWidget() {
    return InkWell(
      onTap: () {
        if (!(prefsRepository.isVerifiedPhone ?? false)) {
          isVerified.value = false;
          if ((prefsRepository.isVerifiedPhonePeforeExpiredToken ?? false)) {
            authBloc.add(
              SendOtpEvent(
                phone: prefsRepository.myPhoneNumber!,
                isViaWhatsApp: 1,
              ),
            );
          }
          return;
        }

        HelperFunctions.slidingNavigation(context, OrdersPage());
      },
      child: BlocBuilder<OrderBloc, OrderState>(
        buildWhen: (previous, current) =>
            previous.getOrdersModel?[""]?.paginationStatus !=
            current.getOrdersModel?[""]?.paginationStatus,
        builder: (context, state) {
          return Container(
            padding: EdgeInsets.all(10.h),
            width: 195.w,
            decoration: BoxDecoration(
              color: const Color(0xffF8F8F8),
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SvgPicture.asset(AppAssets.bagsSvg, width: 25.w),
                Text(
                  LocaleKeys.order_invoice.tr(),
                  style: context.textTheme.bodyMedium?.mq.copyWith(
                    color: const Color(0xff1D1D1D),
                    letterSpacing: 0.18,
                    fontSize: 14.sp,
                    height: 1.3,
                  ),
                ),
                state.getOrdersModel?[""]?.paginationStatus ==
                        PaginationStatus.loading
                    ? Container(
                        alignment: Alignment.center,
                        width: 40.w,
                        height: 20.h,
                        child: TrydosLoader(size: 20.h),
                      )
                    : Text(
                        '${state.orderTotalSize} ${LocaleKeys.action.tr()}',
                        style: context.textTheme.bodyMedium?.rq.copyWith(
                          color: const Color(0xff8D8D8D),
                          letterSpacing: 0.18,
                          fontSize: 12.sp,
                          height: 1.3,
                        ),
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
            : state.customerWalletModel!.available ?? 0;
        String symbole = state.customerWalletModel == null
            ? ''
            : state.customerWalletModel?.assetSymbol ?? "";
        return Container(
          padding: EdgeInsets.all(10.h),
          width: 200.w,
          decoration: BoxDecoration(
            color: const Color(0xffF8F8F8),
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: InkWell(
            onTap: () {
              // _initializeAndOpenWallet();
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SvgPicture.asset(
                  AppAssets.trydosWalletSvg,
                  // ignore: deprecated_member_use
                  color: const Color(0xff3C3C3C),
                  width: 25.w,
                ),
                Text(
                  LocaleKeys.wallet.tr(),
                  style: context.textTheme.bodyMedium?.mq.copyWith(
                    color: const Color(0xff1D1D1D),
                    letterSpacing: 0.18,
                    fontSize: 11.sp,
                    height: 1.3,
                  ),
                ),
                state.getCustomerWalletStatus == GetCustomerWalletStatus.loading
                    ? Container(
                        alignment: Alignment.center,
                        width: 40.w,
                        height: 20.h,
                        child: TrydosLoader(size: 20.h),
                      )
                    : Text(
                        '${LocaleKeys.your_balance.tr()} ${(walletBalance).toStringAsFixed((GetIt.I<HomeBloc>().state.startingSetting?.decimalPointSettings ?? 2).round())} ${symbole}',
                        style: context.textTheme.bodyMedium?.rq.copyWith(
                          color: const Color(0xff8D8D8D),
                          letterSpacing: 0.18,
                          fontSize: 12.sp,
                          height: 1.3,
                        ),
                      ),
              ],
            ),
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
          previous.verifyOtpFromGuestStatus !=
              current.verifyOtpFromGuestStatus ||
          previous.getCustomerInfoStatus != current.getCustomerInfoStatus,
      builder: (context, state) {
        return InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const UserInformationPage(),
            ),
          ),
          child: Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: const Color(0xffF8F8F8),
              borderRadius: BorderRadius.circular(15.r),
            ),
            width: 1.sw,

            child: BlocBuilder<HomeBloc, HomeState>(
              buildWhen: (previous, current) =>
                  previous.updateProfileStatus != current.updateProfileStatus,
              builder: (context, state) {
                return Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          // onTap: () => _showShareAccountViaQr(context),
                          child: SvgPicture.asset(AppAssets.parcodeSvg),
                        ),
                        SizedBox(height: 10.h),
                        Container(
                          height: 20.h,
                          child: Text(
                            prefsRepository.myMarketName ?? '',
                            style: context.textTheme.bodyMedium?.mq.copyWith(
                              color: const Color(0xff1D1D1D),
                              letterSpacing: 0.18,
                              fontSize: 14.sp,
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Container(
                            height: 16.h,
                            child: Text(
                              (prefsRepository.myPhoneNumber?.length ?? 0) < 4
                                  ? ""
                                  : (prefsRepository.myPhoneNumber ?? "")
                                        .startsWith("+")
                                  ? "${prefsRepository.myPhoneNumber ?? ''}"
                                  : "+" +
                                        "${prefsRepository.myPhoneNumber ?? ''}",
                              style: context.textTheme.bodyMedium?.rq.copyWith(
                                color: const Color(0xff8D8D8D),
                                letterSpacing: 0.18,
                                fontSize: 12.sp,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Container(
                          height: 16.h,
                          width: 130.w,
                          child: Text(
                            '${LocaleKeys.add.tr()} ' +
                                "${LocaleKeys.size.tr()}",
                            style: context.textTheme.bodyMedium?.rq.copyWith(
                              color: const Color(0xff8D8D8D),
                              letterSpacing: 0.18,
                              fontSize: 12.sp,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 0,
                      right: LanguageService.languageCode == "ar" ? null : 0,
                      left: LanguageService.languageCode != "ar" ? null : 0,
                      child: Container(
                        height: 70.h,
                        width: 70.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(15.r)),
                          border: Border.all(
                            color:
                                !(prefsRepository.myProfilePhoto == null ||
                                    prefsRepository.myProfilePhoto == "")
                                ? Colors.white
                                : const Color(0xff1D1D1D),
                          ),
                        ),
                        child:
                            !(prefsRepository.myProfilePhoto == null ||
                                prefsRepository.myProfilePhoto == "")
                            ? ClipRRect(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15.r),
                                ),
                                child: MyCachedNetworkImage(
                                  imageUrl:
                                      prefsRepository.myProfilePhoto ?? "",
                                  width: 70.w,
                                  imageFit: BoxFit.cover,
                                  height: 70.h,
                                ),
                              )
                            : Center(child: SvgPicture.asset(AppAssets.trySvg)),
                      ),
                    ),
                    Positioned(
                      top: 38.h,
                      left: LanguageService.languageCode == "ar"
                          ? null
                          : max(
                              _calculateTextWidth(
                                prefsRepository.myMarketName ?? '',
                                context.textTheme.bodyMedium!.mq.copyWith(
                                  color: const Color(0xff1D1D1D),
                                  letterSpacing: 0.18,
                                  fontSize: 14.sp,
                                  height: 1.3,
                                ),
                              ),
                              _calculateTextWidth(
                                prefsRepository.myPhoneNumber ?? '',
                                context.textTheme.bodyMedium!.rq.copyWith(
                                  color: const Color(0xff8D8D8D),
                                  letterSpacing: 0.18,
                                  fontSize: 12.sp,
                                  height: 1.3,
                                ),
                              ),
                            ),
                      right: LanguageService.languageCode != "ar"
                          ? null
                          : max(
                              _calculateTextWidth(
                                prefsRepository.myMarketName ?? '',
                                context.textTheme.bodyMedium!.mq.copyWith(
                                  color: const Color(0xff1D1D1D),
                                  letterSpacing: 0.18,
                                  fontSize: 14.sp,
                                  height: 1.3,
                                ),
                              ),
                              _calculateTextWidth(
                                prefsRepository.myPhoneNumber ?? '',
                                context.textTheme.bodyMedium!.rq.copyWith(
                                  color: const Color(0xff8D8D8D),
                                  letterSpacing: 0.18,
                                  fontSize: 12.sp,
                                  height: 1.3,
                                ),
                              ),
                            ),
                      child: ValueListenableBuilder<bool>(
                        valueListenable: isVerified,
                        builder: (context, _isverified, _) {
                          return InkWell(
                            onTap: () {
                              if (!(prefsRepository.isVerifiedPhone ?? false)) {
                                isVerified.value = false;
                                if ((prefsRepository
                                        .isVerifiedPhonePeforeExpiredToken ??
                                    false)) {
                                  authBloc.add(
                                    SendOtpEvent(
                                      phone: prefsRepository.myPhoneNumber!,
                                      isViaWhatsApp: 1,
                                    ),
                                  );
                                }
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              height: 35.h,
                              width: 72.w,
                              child: Column(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        AppAssets.succuessProfileSvg,
                                        // ignore: deprecated_member_use
                                        color: const Color(0xff707070),
                                        height: 16.h,
                                        width: 16.w,
                                      ),
                                      SvgPicture.asset(
                                        AppAssets.success2Svg,
                                        // ignore: deprecated_member_use
                                        color: const Color(0xff707070),
                                        height: 5.h,
                                        width: 5.w,
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Text(
                                    (prefsRepository.isVerifiedPhone ?? false)
                                        ? '${LocaleKeys.verified.tr()}'
                                        : '${LocaleKeys.verified_now.tr()}',
                                    style: context.textTheme.bodyMedium?.rq
                                        .copyWith(
                                          color:
                                              (prefsRepository
                                                      .isVerifiedPhone ??
                                                  false)
                                              ? Colors.green
                                              : const Color(0xffFF5F61),
                                          letterSpacing: 0.18,
                                          fontSize: 10.sp,
                                          height: 1.3,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
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

  /*  void _showShareAccountViaQr(BuildContext context) {
    if (prefsRepository.isVerifiedPhone == false) {
      showWarningMessage(context, LocaleKeys.you_must_login_first.tr());
      return;
    }
    final qrPayload = jsonEncode(_buildShareableAccountPayload());
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  LocaleKeys.share_account_via_qr_title.tr(),
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff1D1D1D),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10.h),
                Text(
                  LocaleKeys.share_account_via_qr_hint.tr(),
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    color: const Color(0xff8D8D8D),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.h),
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: const Color(0xffF0F0F0)),
                  ),
                  child: QrImageView(
                    data: qrPayload,
                    size: 220.r,
                    backgroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff1D1D1D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      LocaleKeys.cancel.tr(),
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
*/
  /*Map<String, dynamic> _buildShareableAccountPayload() {
    return {
      "idToken": prefsRepository.idToken ?? "",
      "name": prefsRepository.myMarketName ?? "",
      "userMarketPhone": prefsRepository.myPhoneNumber ?? "",
      "userMarketId": prefsRepository.myMarketId ?? "",
      "userCountryIso": prefsRepository.countryIso ?? "",
      "userMarketToken": prefsRepository.marketToken ?? "",
      "language": prefsRepository.language ?? "",
      "userVerifiedPhone": prefsRepository.isVerifiedPhone ?? "",
      "userUserChoosedCountryIso": prefsRepository.userChoosedCountryIso ?? "",
    };
  }*/

  /// فتح المحفظة بشكل آمن مع ضمان الإغلاق
  //   Future<void> _initializeAndOpenWallet() async {
  //     if (!mounted) return;

  //     try {
  //       // تهيئة المحفظة
  //       TrydosWallet.init(
  //         TrydosWalletConfig(
  //           baseUrl: dotenv.env['WALLET_URL'] ?? '', // رابط الـ API
  //           token: prefsRepository.walletToken, // استخدم القيمة الفعلية
  //           languageCode: LanguageService.languageCode, // استخدم اللغة الحالية
  //           allowBadCertificate: true, // true للتطوير فقط عند خطأ SSL
  //         ),
  //       );

  //       _isWalletInitialized = true;

  //       // فتح المحفظة
  //       if (mounted) {
  //         await Navigator.of(context).push(
  //           MaterialPageRoute(
  //             builder: (context) => BlocProvider(
  //               create: (context) => WalletBloc(),
  //               child: const TrydosWalletWelcomeScreen(),
  //             ),
  //           ),
  //         );
  //       }
  //     } catch (e) {
  //       print('Error initializing wallet: $e');
  //       if (mounted) {
  //         ScaffoldMessenger.of(
  //           context,
  //         ).showSnackBar(SnackBar(content: Text('خطأ في فتح المحفظة: $e')));
  //       }
  //     } finally {
  //       // التأكد من تنظيف الموارد حتى عند حدوث خطأ
  //       if (_isWalletInitialized && !mounted) {
  //         await _cleanupWallet();
  //       }
  //     }
  //   }
  // }
}
