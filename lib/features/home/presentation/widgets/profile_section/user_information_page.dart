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
import 'package:trydos/features/app/app_widgets/trydos_app_bar/app_bar_params.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/trydos_appbar.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';

import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/profile_section/add_photo_to_profile_page.dart';
import 'package:trydos/features/home/presentation/widgets/profile_section/profile_address_info_page.dart';
import 'package:trydos/features/home/presentation/widgets/profile_section/profile_bank_card_page.dart';
import 'package:trydos/features/home/presentation/widgets/profile_section/profile_personal_info_page.dart';
import 'package:trydos/features/home/presentation/widgets/profile_section/profile_size_info_page.dart';
import 'package:trydos/generated/locale_keys.g.dart';

class UserInformationPage extends StatefulWidget {
  const UserInformationPage({super.key});

  @override
  State<UserInformationPage> createState() => _UserInformationPageState();
}

class _UserInformationPageState extends State<UserInformationPage> {
  late HomeBloc homeBloc;
  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  @override
  void initState() {
    homeBloc = BlocProvider.of<HomeBloc>(context);
    homeBloc.add(UpdateProfileEvent(changeStatusToInit: true));
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
        appBar: TrydosAppBar(
          appBarParams: AppBarParams(
              backgroundColor: Color(0x000000),
              action: [
                Spacer(),
                Text(
                  LocaleKeys.profile.tr(),
                  style: context.textTheme.bodyMedium?.mr.copyWith(
                      color: const Color(0xff1D1D1D),
                      letterSpacing: 0.18,
                      fontSize: 14,
                      height: 1.3),
                ),
                Spacer()
              ],
              scrolledUnderElevation: 0,
              backIconColor: Colors.black,
              withShadow: false),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _addPhotoWidget(),
                  SizedBox(
                    height: 30,
                    width: 1.sw,
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ProfilePersonalInfoPage())),
                    child: _actionWidget(AppAssets.personalInfoSvg,
                        LocaleKeys.personal_info.tr()),
                  ),
                  SizedBox(
                    height: 5,
                    width: 1.sw,
                  ),
                  InkWell(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ProfileSizeInfoPage())),
                      child: _actionWidget(
                          AppAssets.sizeLineSvg, LocaleKeys.size.tr())),
                  SizedBox(
                    height: 5,
                    width: 1.sw,
                  ),
                  InkWell(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ProfileAddressInfoPage())),
                      child: _actionWidget(
                          AppAssets.addressSvg, LocaleKeys.address.tr())),
                  SizedBox(
                    height: 5,
                    width: 1.sw,
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ProfileBankCartPage())),
                    child: _actionWidget(
                        AppAssets.bankCardSvg, LocaleKeys.bank_cards.tr()),
                  ),
                  SizedBox(
                    height: 12.h,
                    width: 1.sw,
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _addPhotoWidget() {
    return InkWell(
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => AddPhotoProfilePage())),
      child: BlocBuilder<HomeBloc, HomeState>(
        buildWhen: (previous, current) =>
            previous.updateProfileStatus != current.updateProfileStatus,
        builder: (context, state) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                    color: Color(0xffF8F8F8),
                    borderRadius: BorderRadius.circular(22.r)),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  width: 128,
                  height: 40,
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(0, 0, 0, 0.6),
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(22.r),
                          bottomLeft: Radius.circular(22.r))),
                  child: Center(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        AppAssets.addPhotoSvg,
                        color: Color(0xffFFFFFF),
                      ),
                      SizedBox(width: 10),
                      Text(
                        LocaleKeys.add.tr() + " " + LocaleKeys.photo.tr(),
                        style: context.textTheme.bodyMedium?.rr.copyWith(
                            color: const Color(0xffFFFFFF),
                            letterSpacing: 0.18,
                            fontSize: 12,
                            height: 1.3),
                      ),
                      SizedBox(width: 20),
                    ],
                  )),
                ),
              ),
              state.userInfo?.image != null
                  ? MyCachedNetworkImage(
                      imageUrl: homeBloc.state.userInfo?.image ?? "",
                      width: 128,
                      imageFit: BoxFit.cover,
                      height: 128)
                  : Positioned(
                      top: 35,
                      left: 40,
                      child: SvgPicture.asset(
                        width: 50,
                        AppAssets.trySvg,
                        color: Color(0xffD3D3D3),
                      ),
                    )
            ],
          );
        },
      ),
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
}
