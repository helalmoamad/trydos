import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:country_flags/country_flags.dart';
import 'package:easy_localization/easy_localization.dart' as transform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get_it/get_it.dart';
import 'package:mime_type/mime_type.dart';
import 'package:trydos/common/constant/countries.dart';
import 'package:trydos/common/constant/design/assets_provider.dart';
import 'package:trydos/common/helper/camera_screen.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/config/theme/typography.dart';

import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/string.dart';
import 'package:trydos/core/utils/responsive_padding.dart';
import 'package:trydos/features/app/app_widgets/app_text_field.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/app_bar_params.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/trydos_appbar.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';

import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/profile_section/camera_profile.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/language_service.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class ProfileSizeInfoPage extends StatefulWidget {
  const ProfileSizeInfoPage({super.key});

  @override
  State<ProfileSizeInfoPage> createState() => _ProfileSizeInfoPageState();
}

class _ProfileSizeInfoPageState extends State<ProfileSizeInfoPage>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<bool> visibleSave = ValueNotifier(false);
  final ValueNotifier<bool> validateBox = ValueNotifier(false);

  final TextEditingController weightController = TextEditingController();
  final TextEditingController tallController = TextEditingController();

  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  late AnimationController animationController;
  late HomeBloc homeBloc;
  @override
  void initState() {
    homeBloc = BlocProvider.of<HomeBloc>(context);
    homeBloc.add(UpdateProfileEvent(changeStatusToInit: true));
    weightController.text = (homeBloc.state.userInfo?.weight ?? "").toString();
    tallController.text = (homeBloc.state.userInfo?.tall ?? "").toString();
    animationController =
        AnimationController(duration: Duration(seconds: 1), vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    animationController.dispose();
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
                        LocaleKeys.profile_size_info.tr(),
                        style: context.textTheme.bodyMedium?.mr.copyWith(
                            color: const Color(0xff1D1D1D),
                            letterSpacing: 0.18,
                            fontSize: 14,
                            height: 1.3),
                      ),
                      Spacer(),
                      !_visibleSave
                          ? SizedBox.shrink()
                          : BlocBuilder<HomeBloc, HomeState>(
                              buildWhen: (previous, current) =>
                                  previous.updateProfileStatus !=
                                  current.updateProfileStatus,
                              builder: (context, state) {
                                if (state.updateProfileStatus ==
                                    UpdateProfileStatus.success) {
                                  Future.delayed(Duration(milliseconds: 300),
                                      () => visibleSave.value = false);
                                  homeBloc.add(UpdateProfileEvent(
                                      changeStatusToInit: true));
                                }
                                return InkWell(
                                  onTap: () {
                                    homeBloc.add(UpdateProfileEvent(
                                        tall: tallController.text,
                                        weight: weightController.text));
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: 40,
                                    height: 20,
                                    child: state.updateProfileStatus ==
                                            UpdateProfileStatus.loading
                                        ? TrydosLoader(
                                            size: 18,
                                          )
                                        : Text(
                                            LocaleKeys.save.tr(),
                                            style: context
                                                .textTheme.bodyMedium?.mr
                                                .copyWith(
                                                    color:
                                                        const Color(0xff402CDD),
                                                    letterSpacing: 0.18,
                                                    fontSize: 14,
                                                    height: 1.3),
                                          ),
                                  ),
                                );
                              }),
                      !_visibleSave
                          ? SizedBox.shrink()
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
                                LocaleKeys.entering_your_information_correctly
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
                      Container(
                        height: 15,
                        width: 160,
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SvgPicture.asset(
                              AppAssets.sizeLineSvg,
                              height: 15,
                              color: Color(0xff707070),
                            ),
                            Text(
                              LocaleKeys.your_size_info.tr(),
                              style: context.textTheme.bodyMedium?.mr.copyWith(
                                  color: const Color(0xff404040),
                                  letterSpacing: 0.18,
                                  fontSize: 12,
                                  height: 1.2),
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
                        height: 15,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: _sizeAndWeightInfoWidget(
                            controller: tallController,
                            context: context,
                            isComplate: false,
                            height: 50,
                            title: LocaleKeys.how_tall_are_you.tr(),
                            hint: "000 ${LocaleKeys.cm.tr()}"),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: _sizeAndWeightInfoWidget(
                          height: 50,
                          context: context,
                          isComplate: false,
                          controller: weightController,
                          hint: "000 ${LocaleKeys.kg.tr()}",
                          title: LocaleKeys.what_is_your_weight.tr(),
                        ),
                      ),
                    ],
                  ),
                ),
              ));
        });
  }

  Widget _sizeAndWeightInfoWidget(
      {required String title,
      required String hint,
      required TextEditingController controller,
      required bool isComplate,
      required int height,
      required BuildContext context}) {
    return ValueListenableBuilder<bool>(
        valueListenable: validateBox,
        builder: (context, isValidateBox, _) {
          if (isValidateBox && controller.text.isNullOrEmpty) {
            animationController.forward();
            Future.delayed(
              Duration(seconds: 2),
              () => animationController.reset(),
            );
          }
          return AnimatedBuilder(
            animation: animationController,
            builder: (context, child) => Transform.translate(
              offset: Offset(
                  !controller.text.isNullOrEmpty
                      ? 0
                      : sin(3 * 2 * pi * animationController.value) * 5,
                  0),
              child: Container(
                height: height.toDouble(),
                width: 1.sw,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.r),
                    border: Border.all(
                        color: (isValidateBox && controller.text.isNullOrEmpty)
                            ? Colors.red
                            : Color(0xffD3D3D3))),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 5, left: 8, right: 8),
                        height: 18,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: context.textTheme.bodyMedium?.rr.copyWith(
                                  color: const Color(0xff505050),
                                  letterSpacing: 0.18,
                                  fontSize: 12,
                                  height: LanguageService.languageCode == "ar"
                                      ? 0.5
                                      : 0.8),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                          child: Directionality(
                              textDirection: TextDirection.ltr,
                              child: AppTextField(
                                controller: controller,
                                textInputType: TextInputType.phone,
                                bordersColor: Colors.white,
                                isErrorBorder: false,
                                maxLength: 3,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9\s]'))
                                ],
                                textInputAction: TextInputAction.done,
                                onChange: (val) {
                                  visibleSave.value = true;
                                },
                                validator: (value) {
                                  if (value.isNullOrEmpty) {
                                    return LocaleKeys
                                        .the_field_must_not_be_empty
                                        .tr();
                                  }
                                  return null;
                                },
                                onFieldSubmitted: (val) {
                                  FocusScope.of(context).unfocus();
                                },
                                textAlignVertical: TextAlignVertical.center,
                                hintText: '${hint}',
                                contentPadding: HWEdgeInsetsDirectional.only(
                                    start:
                                        (LanguageService.languageCode != "ar")
                                            ? 8
                                            : 8,
                                    end: 1,
                                    bottom: 1,
                                    top: 1),
                                textAlign: TextAlign.start,
                                maxLines: 1,
                                minLines: 1,
                                textStyle: context.textTheme.bodyMedium?.mr
                                    .copyWith(
                                        color: const Color(0xff1D1D1D),
                                        letterSpacing: 0.18,
                                        fontSize: 14,
                                        height: 1.1),
                                hintTextStyle: context.textTheme.bodyMedium?.rr
                                    .copyWith(
                                        color: const Color(0xffD3D3D3),
                                        letterSpacing: 0.18,
                                        fontSize: 14,
                                        height: 1),
                              ))),
                    ]),
              ),
            ),
          );
        });
  }
}
