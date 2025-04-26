import 'package:country_flags/country_flags.dart';
import 'package:easy_localization/easy_localization.dart' as transform;
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:trydos/common/constant/design/assets_provider.dart';
import 'package:trydos/common/helper/helper_functions.dart';

import 'package:trydos/config/theme/typography.dart';

import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';

import 'package:trydos/features/app/app_widgets/trydos_app_bar/app_bar_params.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/trydos_appbar.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_event.dart';
import 'package:trydos/features/home/data/models/starting_settings_response_model.dart';

import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';

import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/language_service.dart';

class ProfileLanguagePage extends StatefulWidget {
  const ProfileLanguagePage({super.key});

  @override
  State<ProfileLanguagePage> createState() => _ProfileLanguagePageState();
}

class _ProfileLanguagePageState extends State<ProfileLanguagePage>
    with SingleTickerProviderStateMixin {
  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();

  final ValueNotifier<bool> visibleSave = ValueNotifier(false);
  final ValueNotifier<int> changeLanguage = ValueNotifier(0);
  List<Language> language = [];
  late HomeBloc homeBloc;
  late AppBloc appBloc;
  @override
  void initState() {
    homeBloc = BlocProvider.of<HomeBloc>(context);
    appBloc = BlocProvider.of<AppBloc>(context);
    language = homeBloc.state.startingSetting?.languages ?? [];

    changeLanguage.value = language
        .indexWhere((element) => element.code == LanguageService.languageCode);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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

    return ValueListenableBuilder<bool>(
        valueListenable: visibleSave,
        builder: (context, _visibleSave, _) {
          return Scaffold(
              appBar: TrydosAppBar(
                appBarParams: AppBarParams(
                    backgroundColor: Color(0x000000),
                    action: [
                      Spacer(),
                      !_visibleSave
                          ? SizedBox.shrink()
                          : SizedBox(
                              width: 55.w,
                            ),
                      Text(
                        LocaleKeys.profile_language.tr(),
                        style: context.textTheme.bodyMedium?.mr.copyWith(
                            color: const Color(0xff1D1D1D),
                            letterSpacing: 0.18,
                            fontSize: 14,
                            height: 1.3),
                      ),
                      Spacer(),
                      !_visibleSave
                          ? SizedBox.shrink()
                          : InkWell(
                              onTap: () {
                                BlocProvider.of<HomeBloc>(context)
                                    .add(ClearAllAppCashEvent());

                                BlocProvider.of<HomeBloc>(context).add(
                                    ChangeCountryLanguageForNotificationEvent(
                                        country: GetIt.I<PrefsRepository>()
                                            .countryIso!
                                            .toLowerCase(),
                                        languageCode:
                                            language[changeLanguage.value]
                                                    .code ??
                                                ""));
                                Future.delayed(
                                  Duration(microseconds: 500),
                                  () {
                                    appBloc.add(ChangeBasePage(0));
                                    context.go("/");
                                  },
                                );
                                GetIt.I<PrefsRepository>().setLanguage(
                                    language[changeLanguage.value].code ?? "");
                                context
                                    .setLocale(HelperFunctions.getInitLocale());
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
                    valueListenable: changeLanguage,
                    builder: (context, selectLanguage, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              height: 50,
                              width: 1.sw,
                              decoration: BoxDecoration(
                                  color: Color(0xffF8F8F8),
                                  border: Border.all(color: Color(0xffD3D3D3))),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  SvgPicture.asset(
                                    AppAssets.infoSvg,
                                    color: Color(0xff402CDD),
                                    width: 25.w,
                                  ),
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  Text(
                                    LocaleKeys
                                        .we_work_in_the_languages_listed_below
                                        .tr(),
                                    style: context.textTheme.bodyMedium?.rr
                                        .copyWith(
                                            color: const Color(0xff8D8D8D),
                                            letterSpacing: 0.18,
                                            fontSize: 10.sp,
                                            height: 1.3),
                                  ),
                                ],
                              )),
                          SizedBox(
                            height: 20,
                          ),
                          _availableLanguage(),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      );
                    }),
              )));
        });
  }

  Widget _availableLanguage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 15,
          width: 170,
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SvgPicture.asset(
                AppAssets.languageSvg,
                height: 25,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                LocaleKeys.available_language.tr(),
                style: context.textTheme.bodyMedium?.mr.copyWith(
                    color: const Color(0xff404040),
                    letterSpacing: 0.18,
                    fontSize: 12,
                    height: 1.2),
              ),
              SizedBox(
                width: 12,
              ),
              SvgPicture.asset(
                AppAssets.chatWithQuestionSvg,
                color: Color(0xffD3D3D3),
                height: 15,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 5),
          width: 1.sw,
          height: 245,
          child: ListView.separated(
            itemBuilder: (context, index) {
              return _LanguageWidget(
                  language[index].code == "ar"
                      ? "SA"
                      : language[index].code == "tr"
                          ? "TR"
                          : "US",
                  language[index].name ?? "",
                  index);
            },
            separatorBuilder: (context, index) => SizedBox(
              height: 5,
            ),
            itemCount: language.length,
          ),
        )
      ],
    );
  }

  Widget _LanguageWidget(String code, String country, int index) {
    return InkWell(
      onTap: () {},
      child: InkWell(
        onTap: () {
          changeLanguage.value = index;
          visibleSave.value = true;
        },
        child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
                color: index == changeLanguage.value
                    ? Color(0xffF8F8F8)
                    : Colors.white,
                borderRadius: BorderRadius.circular(15.r),
                border: Border.all(
                    color: index == changeLanguage.value
                        ? Color(0xff402CDD)
                        : Color(0xffD3D3D3))),
            width: 1.sw,
            height: 53,
            child: Row(
              children: [
                SizedBox(
                  width: 10,
                ),
                code.toUpperCase() == "SY"
                    ? SvgPicture.asset(
                        AppAssets.syriaFlagSvg,
                      )
                    : Container(
                        width: 25,
                        height: 25,
                        child: CountryFlag.fromCountryCode(
                          code,
                          height: 25,
                          width: 25,
                          borderRadius: 4.r,
                        )),
                SizedBox(
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
