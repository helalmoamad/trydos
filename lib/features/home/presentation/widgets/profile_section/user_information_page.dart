import 'package:easy_localization/easy_localization.dart' as transform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get_it/get_it.dart';
import 'package:trydos/common/constant/countries.dart';
import 'package:trydos/common/constant/design/assets_provider.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/app_bar_params.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/trydos_appbar.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
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

  bool fromLogin = false;
  final ValueNotifier<bool> animate = ValueNotifier(false);
  Duration animationDuration = const Duration(milliseconds: 500);
  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  final ValueNotifier<String?> changeGender = ValueNotifier("null");
  final ValueNotifier<bool> visibleSave = ValueNotifier(false);
  final TextEditingController emailController = TextEditingController();
  final ValueNotifier<bool> visiblePrefix = ValueNotifier(false);
  final ValueNotifier<bool> visiblePrefixOptional = ValueNotifier(false);
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController alternativePhoneController =
      TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  late AuthBloc authBloc;

  @override
  void initState() {
    LastPagesTracker.push('UserInformationPage');
    homeBloc = BlocProvider.of<HomeBloc>(context);
    homeBloc.add(UpdateProfileEvent(changeStatusToInit: true));

    authBloc = BlocProvider.of<AuthBloc>(context);
    fullNameController.text = homeBloc.state.userInfo?.name == "guest"
        ? ""
        : homeBloc.state.userInfo?.name ?? "";

    homeBloc.state.userInfo?.alternativePhone ?? "";
    if ((homeBloc.state.userInfo?.phone?.length ?? 0) > 4) {
      if (homeBloc.state.userInfo!.phone!.startsWith("+")) {
        phoneController.text = homeBloc.state.userInfo!.phone!
            .split("+")
            .toList()[1];
      } else {
        phoneController.text = homeBloc.state.userInfo?.phone ?? "";
      }
    }
    String _getCountryCodeFromNumber(String num) {
      Country newCountry = countries.firstWhere(
        (element) =>
            '+${num.toLowerCase()}'.startsWith(element.dialCode.toLowerCase()),
        orElse: () => const Country(
          name: '',
          flag: '',
          code: '',
          dialCode: '',
          minLength: 0,
          maxLength: 0,
        ),
      );
      if (newCountry.code != "") {
        return newCountry.dialCode.split("+").toList()[1];
      }
      return "";
    }

    String formattedPhone = _formatNumber(
      phoneController.text,
      _getCountryCodeFromNumber(phoneController.text),
    );
    phoneController.text = formattedPhone;

    if ((homeBloc.state.userInfo?.alternativePhone?.length ?? 0) > 4) {
      if (homeBloc.state.userInfo!.alternativePhone!.startsWith("+")) {
        alternativePhoneController.text = homeBloc
            .state
            .userInfo!
            .alternativePhone!
            .split("+")
            .toList()[1];
      } else {
        alternativePhoneController.text =
            homeBloc.state.userInfo?.alternativePhone ?? "";
      }
    }

    String formattedAlternativePhone = _formatNumber(
      alternativePhoneController.text,
      _getCountryCodeFromNumber(alternativePhoneController.text),
    );
    alternativePhoneController.text = formattedAlternativePhone;

    emailController.text =
        (homeBloc.state.userInfo?.email?.contains("@guest.com") ?? false)
        ? ""
        : homeBloc.state.userInfo?.email ?? "";
    changeGender.value =
        (homeBloc.state.userInfo?.gender?.name.toString()) ?? "null";

    if (phoneController.text.length > 0) {
      visiblePrefix.value = true;
    }
    if (alternativePhoneController.text.length > 0) {
      visiblePrefixOptional.value = true;
    }
    super.initState();
  }

  String _formatNumber(String input, String countryCode) {
    if (countryCode == "") {
      return input;
    }
    // إزالة الفراغات

    String inputWithoutCode = input.split("${countryCode}").toList()[1];
    String digitsOnly = inputWithoutCode
        .replaceAll(' ', '')
        .replaceAll(RegExp(r'[^0-9]'), '');

    // إضافة فراغات بين كل 3 أرقام
    StringBuffer formatted = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i > 0 && i % 3 == 0) {
        formatted.write(' '); // إضافة فراغ
      }
      formatted.write(digitsOnly[i]);
    }

    return "${countryCode}${(digitsOnly.length == 0) ? formatted.toString() : (" " + formatted.toString())}";
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return Scaffold(
      appBar: TrydosAppBar(
        appBarParams: AppBarParams(
          backgroundColor: const Color(0x000000),
          action: [
            const Spacer(),
            Text(
              LocaleKeys.profile.tr(),
              style: context.textTheme.bodyMedium?.mq.copyWith(
                color: const Color(0xff1D1D1D),
                letterSpacing: 0.18,
                fontSize: 14.sp,
                height: 1.3,
              ),
            ),
            const Spacer(),
          ],
          scrolledUnderElevation: 0,
          backIconColor: Colors.black,
          withShadow: false,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(12.h),
            child: Column(
              children: [
                _addPhotoWidget(),
                SizedBox(height: 30.h, width: 1.sw),
                InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProfilePersonalInfoPage(
                        changeGender: changeGender,
                        visibleSave: visibleSave,
                        emailController: emailController,
                        visiblePrefix: visiblePrefix,
                        visiblePrefixOptional: visiblePrefixOptional,
                        phoneController: phoneController,
                        alternativePhoneController: alternativePhoneController,
                        fullNameController: fullNameController,
                      ),
                    ),
                  ),
                  child: _actionWidget(
                    AppAssets.personalInfoSvg,
                    LocaleKeys.personal_info.tr(),
                  ),
                ),
                SizedBox(height: 5.h, width: 1.sw),
                InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ProfileSizeInfoPage(),
                    ),
                  ),
                  child: _actionWidget(
                    AppAssets.sizeLineSvg,
                    LocaleKeys.size.tr(),
                  ),
                ),
                SizedBox(height: 5.h, width: 1.sw),
                InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ProfileAddressInfoPage(),
                    ),
                  ),
                  child: _actionWidget(
                    AppAssets.addressSvg,
                    LocaleKeys.address.tr(),
                  ),
                ),
                SizedBox(height: 5.h, width: 1.sw),
                InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ProfileBankCartPage(),
                    ),
                  ),
                  child: _actionWidget(
                    AppAssets.bankCardSvg,
                    LocaleKeys.bank_cards.tr(),
                  ),
                ),
                SizedBox(height: 12.h, width: 1.sw),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _addPhotoWidget() {
    return InkWell(
      onTap: () {
        if ((prefsRepository.isVerifiedPhonePeforeExpiredToken ?? false)) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddPhotoProfilePage(),
            ),
          );
          return;
        }
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        buildWhen: (previous, current) =>
            previous.updateProfileStatus != current.updateProfileStatus,
        builder: (context, state) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 128.w,
                height: 128.h,
                decoration: BoxDecoration(
                  color: const Color(0xffF8F8F8),
                  borderRadius: BorderRadius.circular(22.r),
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  width: 128.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(0, 0, 0, 0.6),
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(22.r),
                      bottomLeft: Radius.circular(22.r),
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          AppAssets.addPhotoSvg,
                          // ignore: deprecated_member_use
                          color: const Color(0xffFFFFFF),
                          height: 15.h,
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          LocaleKeys.add.tr() + " " + LocaleKeys.photo.tr(),
                          style: context.textTheme.bodyMedium?.rq.copyWith(
                            color: const Color(0xffFFFFFF),
                            letterSpacing: 0.18,
                            fontSize: 12.sp,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(width: 20.w),
                      ],
                    ),
                  ),
                ),
              ),
              !(prefsRepository.myProfilePhoto == null ||
                      prefsRepository.myProfilePhoto == "")
                  ? MyCachedNetworkImage(
                      imageUrl: prefsRepository.myProfilePhoto!,
                      width: 128.w,
                      imageFit: BoxFit.cover,
                      height: 128.h,
                    )
                  : Positioned(
                      top: 35.h,
                      left: 40.w,
                      child: SvgPicture.asset(
                        width: 50.w,
                        AppAssets.trySvg,
                        // ignore: deprecated_member_use
                        color: const Color(0xffD3D3D3),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }

  Widget _actionWidget(String svgUrl, String actionName) {
    return Container(
      padding: EdgeInsets.all(12.h),
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
}
