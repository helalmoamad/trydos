import 'package:country_flags/country_flags.dart';
import 'package:easy_localization/easy_localization.dart' as transform;
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:trydos/common/constant/design/assets_provider.dart';

import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';

import 'package:trydos/features/app/app_widgets/trydos_app_bar/app_bar_params.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/trydos_appbar.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_event.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';

import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';

import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/language_service.dart';

class ProfileCountryPage extends StatefulWidget {
  const ProfileCountryPage({super.key});

  @override
  State<ProfileCountryPage> createState() => _ProfileCountryPageState();
}

class _ProfileCountryPageState extends State<ProfileCountryPage>
    with SingleTickerProviderStateMixin {
  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();

  final ValueNotifier<bool> visibleSave = ValueNotifier(false);
  final ValueNotifier<int> changeCountry = ValueNotifier(0);
  String choosedCountryIso = "";
  late HomeBloc homeBloc;
  late AppBloc appBloc;
  @override
  void initState() {
    LastPagesTracker.push('ProfileCountryPage');
    appBloc = BlocProvider.of<AppBloc>(context);
    choosedCountryIso = (GetIt.I<PrefsRepository>().userCountryIsAvailable == 1
            ? GetIt.I<PrefsRepository>().userChoosedCountryIso
            : GetIt.I<PrefsRepository>().countryIso) ??
        "";

    homeBloc = BlocProvider.of<HomeBloc>(context);
    if ((homeBloc.state.getAllowedCountriesModel?.data?.countries?.length ??
            0) !=
        0) {
      changeCountry.value = homeBloc
          .state.getAllowedCountriesModel!.data!.countries!
          .indexWhere((element) =>
              element.iso!.toLowerCase() == choosedCountryIso.toLowerCase());
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return ValueListenableBuilder<bool>(
        valueListenable: visibleSave,
        builder: (context, _visibleSave, _) {
          return Scaffold(
              appBar: TrydosAppBar(
                appBarParams: AppBarParams(
                    backgroundColor: const Color(0x000000),
                    action: [
                      const Spacer(),
                      !_visibleSave
                          ? const SizedBox.shrink()
                          : SizedBox(
                              width: 55.w,
                            ),
                      Text(
                        LocaleKeys.profile_country.tr(),
                        style: context.textTheme.bodyMedium?.mr.copyWith(
                            color: const Color(0xff1D1D1D),
                            letterSpacing: 0.18,
                            fontSize: 14,
                            height: 1.3),
                      ),
                      const Spacer(),
                      !_visibleSave
                          ? const SizedBox.shrink()
                          : InkWell(
                              onTap: () {
                                showDialog(
                                  barrierColor:
                                      const Color.fromRGBO(0, 0, 0, 0.3),
                                  context: context,
                                  builder: (context) => AlertDialog(
                                      backgroundColor: const Color(0xffCEFFE6),
                                      title: Text(
                                        LocaleKeys
                                            .are_you_sure_you_want_to_change_your_country
                                            .tr(),
                                        style:
                                            textTheme.titleMedium?.rr.copyWith(
                                          fontSize: 12.sp,
                                          color: const Color(0xff1D1D1D),
                                          height: 0,
                                        ),
                                      ),
                                      actions: [
                                        MaterialButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            GetIt.I<PrefsRepository>()
                                                .setUserChoosedCountryIso(homeBloc
                                                        .state
                                                        .getAllowedCountriesModel
                                                        ?.data
                                                        ?.countries?[
                                                            changeCountry.value]
                                                        .iso ??
                                                    "".toLowerCase());
                                            GetIt.I<PrefsRepository>()
                                                .setUserCountryIsAvailable(1);
                                            BlocProvider.of<HomeBloc>(context)
                                                .add(
                                                    const ClearAllAppCashEvent());
                                            clearCustomCashe();
                                            prefsRepository
                                                .setIsFoundDataCashed(false);
                                            BlocProvider.of<HomeBloc>(context).add(
                                                ChangeCountryLanguageForNotificationEvent(
                                                    country: homeBloc
                                                            .state
                                                            .getAllowedCountriesModel
                                                            ?.data
                                                            ?.countries?[
                                                                changeCountry
                                                                    .value]
                                                            .iso ??
                                                        "".toLowerCase(),
                                                    languageCode:
                                                        LanguageService
                                                            .languageCode));

                                            Future.delayed(
                                              const Duration(microseconds: 500),
                                              () {
                                                appBloc.add(ChangeBasePage(0));
                                                context.go("/");
                                              },
                                            );
                                          },
                                          child: Text(
                                            LocaleKeys.yes.tr(),
                                            style: textTheme.titleMedium?.rr
                                                .copyWith(
                                              fontSize: 16.sp,
                                              color: const Color(0xff1D1D1D),
                                              height: 0,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 40.w,
                                        ),
                                        MaterialButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          elevation: 2,
                                          child: Text(
                                            LocaleKeys.cansel.tr(),
                                            style: textTheme.titleMedium?.rr
                                                .copyWith(
                                              fontSize: 16.sp,
                                              color: const Color(0xff1D1D1D),
                                              height: 0,
                                            ),
                                          ),
                                        )
                                      ]),
                                );
                              },
                              child: Container(
                                alignment: Alignment.center,
                                width: 40,
                                height: 20,
                                child: Text(
                                  LocaleKeys.save.tr(),
                                  style: context.textTheme.bodyMedium?.mr
                                      .copyWith(
                                          color: const Color(0xff402CDD),
                                          letterSpacing: 0.18,
                                          fontSize: 14,
                                          height: 1.3),
                                ),
                              ),
                            ),
                      !_visibleSave
                          ? SizedBox(
                              width: LanguageService.languageCode == "ar"
                                  ? 40.w
                                  : 0,
                            )
                          : SizedBox(
                              width: 15.w,
                            )
                    ],
                    scrolledUnderElevation: 0,
                    backIconColor: Colors.black,
                    withShadow: false),
              ),
              body: SafeArea(
                  child: SingleChildScrollView(
                child: ValueListenableBuilder<int>(
                    valueListenable: changeCountry,
                    builder: (context, selectCountry, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              height: 50,
                              width: 1.sw,
                              decoration: BoxDecoration(
                                  color: const Color(0xffF8F8F8),
                                  border: Border.all(
                                      color: const Color(0xffD3D3D3))),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  SvgPicture.asset(
                                    AppAssets.infoSvg,
                                    color: const Color(0xff402CDD),
                                    width: 25.w,
                                  ),
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  Text(
                                    LocaleKeys.we_operate_in_the_countries.tr(),
                                    style: context.textTheme.bodyMedium?.rr
                                        .copyWith(
                                            color: const Color(0xff8D8D8D),
                                            letterSpacing: 0.18,
                                            fontSize: 10.sp,
                                            height: 1.3),
                                  ),
                                ],
                              )),
                          const SizedBox(
                            height: 20,
                          ),
                          _availableCountry(),
                          const SizedBox(
                            height: 20,
                          ),
                          _commingSoonCountry(),
                        ],
                      );
                    }),
              )));
        });
  }

  Widget _availableCountry() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 15,
          width: 170,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SvgPicture.asset(
                AppAssets.availableCountrySvg,
                height: 15,
                color: const Color(0xff707070),
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                LocaleKeys.available_country.tr(),
                style: context.textTheme.bodyMedium?.mr.copyWith(
                    color: const Color(0xff404040),
                    letterSpacing: 0.18,
                    fontSize: 12,
                    height: 1.2),
              ),
              const SizedBox(
                width: 12,
              ),
              SvgPicture.asset(
                AppAssets.chatWithQuestionSvg,
                color: const Color(0xffD3D3D3),
                height: 15,
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: 1.sw,
          height: 245,
          child: ListView.separated(
            itemBuilder: (context, index) => _countryWidget(
                homeBloc.state.getAllowedCountriesModel!.data!.countries?[index]
                        .iso ??
                    "",
                homeBloc.state.getAllowedCountriesModel?.data?.countries?[index]
                        .name ??
                    "",
                index,
                true),
            separatorBuilder: (context, index) => const SizedBox(
              height: 5,
            ),
            itemCount: (homeBloc.state.getAllowedCountriesModel?.data?.countries
                            ?.length ??
                        0) !=
                    0
                ? homeBloc
                    .state.getAllowedCountriesModel!.data!.countries!.length
                : 0,
          ),
        )
      ],
    );
  }

  Widget _commingSoonCountry() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 15,
          width: 170,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SvgPicture.asset(
                AppAssets.availableCountrySvg,
                height: 15,
                color: const Color(0xff707070),
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                LocaleKeys.coming_soon_country.tr(),
                style: context.textTheme.bodyMedium?.mr.copyWith(
                    color: const Color(0xff404040),
                    letterSpacing: 0.18,
                    fontSize: 12,
                    height: 1.2),
              ),
              const SizedBox(
                width: 12,
              ),
              SvgPicture.asset(
                AppAssets.chatWithQuestionSvg,
                color: const Color(0xffD3D3D3),
                height: 15,
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: 1.sw,
          height: 400.h,
          child: ListView.separated(
              itemBuilder: (context, index) =>
                  _countryWidget("TR", "Turkiy", index, false),
              separatorBuilder: (context, index) => const SizedBox(
                    height: 5,
                  ),
              itemCount: 5),
        )
      ],
    );
  }

  Widget _countryWidget(
      String code, String country, int index, bool isAvailable) {
    return InkWell(
      onTap: () {},
      child: InkWell(
        onTap: () {
          if (isAvailable) {
            changeCountry.value = index;
            visibleSave.value = true;
          }
        },
        child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
                color: isAvailable && index == changeCountry.value
                    ? const Color(0xffF8F8F8)
                    : Colors.white,
                borderRadius: BorderRadius.circular(15.r),
                border: Border.all(
                    color: isAvailable && index == changeCountry.value
                        ? const Color(0xff402CDD)
                        : const Color(0xffD3D3D3))),
            width: 1.sw,
            height: 53,
            child: Row(
              children: [
                const SizedBox(
                  width: 10,
                ),
                Container(
                    width: 25,
                    height: 25,
                    child: code.toUpperCase() == "SY"
                        ? SvgPicture.asset(
                            AppAssets.syriaFlagSvg,
                            width: 18.w,
                          )
                        : CountryFlag.fromCountryCode(
                            code,
                            height: 25,
                            width: 25,
                            borderRadius: 4.r,
                          )),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  country,
                  style: context.textTheme.bodyMedium?.rr.copyWith(
                      color: const Color(0xff1D1D1D),
                      letterSpacing: 0.18,
                      fontSize: 14,
                      height: 1.3),
                ),
              ],
            )),
      ),
    );
  }
}
