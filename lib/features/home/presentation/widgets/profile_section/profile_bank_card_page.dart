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

import 'package:trydos/features/app/app_widgets/trydos_app_bar/app_bar_params.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/trydos_appbar.dart';

import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';

import 'package:trydos/generated/locale_keys.g.dart';

class ProfileBankCartPage extends StatefulWidget {
  const ProfileBankCartPage({super.key});

  @override
  State<ProfileBankCartPage> createState() => _ProfileBankCartPageState();
}

class _ProfileBankCartPageState extends State<ProfileBankCartPage>
    with SingleTickerProviderStateMixin {
  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();

  @override
  void initState() {
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

    return Scaffold(
        appBar: TrydosAppBar(
          appBarParams: AppBarParams(
              backgroundColor: Color(0x000000),
              action: [
                Spacer(),
                Text(
                  LocaleKeys.profile_bank_cards.tr(),
                  style: context.textTheme.bodyMedium?.mr.copyWith(
                      color: const Color(0xff1D1D1D),
                      letterSpacing: 0.18,
                      fontSize: 14,
                      height: 1.3),
                ),
                Spacer(),
              ],
              scrolledUnderElevation: 0,
              backIconColor: Colors.black,
              withShadow: false),
        ),
        body: SafeArea(
            child: SingleChildScrollView(
          child: Column(
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
                        LocaleKeys.entering_your_information_correctly.tr(),
                        style: context.textTheme.bodyMedium?.rr.copyWith(
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
              Container(
                height: 15,
                width: 170,
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SvgPicture.asset(
                      AppAssets.bankCardSvg,
                      height: 15,
                      color: Color(0xff707070),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      LocaleKeys.your_bank_cards_info.tr(),
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
            ],
          ),
        )));
  }
}
