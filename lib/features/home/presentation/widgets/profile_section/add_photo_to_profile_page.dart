import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:country_flags/country_flags.dart';
import 'package:easy_localization/easy_localization.dart' as transform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:mime_type/mime_type.dart';
import 'package:path_provider/path_provider.dart';
import 'package:trydos/common/constant/design/assets_provider.dart';
import 'package:trydos/common/helper/camera_screen.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/config/theme/typography.dart';

import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/app_bar_params.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/trydos_appbar.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';

import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/profile_section/camera_profile.dart';
import 'package:trydos/features/home/presentation/widgets/profile_section/crope_image.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class AddPhotoProfilePage extends StatefulWidget {
  const AddPhotoProfilePage({super.key});

  @override
  State<AddPhotoProfilePage> createState() => _AddPhotoProfilePageState();
}

class _AddPhotoProfilePageState extends State<AddPhotoProfilePage> {
  final ValueNotifier<bool> visibleAddPhoto = ValueNotifier(false);
  final ValueNotifier<bool> visibleSave = ValueNotifier(false);
  final ValueNotifier<bool> visibleNewImage = ValueNotifier(false);
  final ValueNotifier<bool> visiblecamera = ValueNotifier(false);
  final ValueNotifier<File?> visiblePersonPhoto = ValueNotifier(null);
  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  List<CameraDescription> cameras = [];
  late HomeBloc homeBloc;
  @override
  void initState() {
    homeBloc = BlocProvider.of<HomeBloc>(context);
    homeBloc.add(UpdateProfileEvent(changeStatusToInit: true));
    if (homeBloc.state.userInfo?.image != null) {
      print(
          "22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222");
      visiblePersonPhoto.value = File("initImage");
    }

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
                        LocaleKeys.profile.tr(),
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
                                      current.updateProfileStatus ||
                                  previous.uploadUserPhotoCloudinaryStatus !=
                                      current.uploadUserPhotoCloudinaryStatus,
                              builder: (context, state) {
                                if (state.updateProfileStatus ==
                                    UpdateProfileStatus.success) {
                                  Future.delayed(Duration(milliseconds: 300),
                                      () => visibleSave.value = false);
                                }
                                return InkWell(
                                  onTap: () async {
                                    if (visiblePersonPhoto.value == null) {
                                      homeBloc.add(
                                          UpdateProfileEvent(image: "def.png"));
                                    } else {
                                      homeBloc.add(
                                          UploadUserPhotoCloudinaryEvent(
                                              visiblePersonPhoto.value!,
                                              false));
                                    }
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: 40,
                                    height: 20,
                                    child: state.updateProfileStatus ==
                                                UpdateProfileStatus.loading ||
                                            state.uploadUserPhotoCloudinaryStatus ==
                                                UploadUserPhotoCloudinaryStatus
                                                    .loading
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
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: ValueListenableBuilder<bool>(
                        valueListenable: visiblecamera,
                        builder: (context, _visiblecamera, _) {
                          return ValueListenableBuilder<File?>(
                              valueListenable: visiblePersonPhoto,
                              builder: (context, _visiblePersonPhoto, _) {
                                return ValueListenableBuilder<bool>(
                                    valueListenable: visibleAddPhoto,
                                    builder: (context, _visibleAddPhoto, _) {
                                      return ValueListenableBuilder<bool>(
                                          valueListenable: visibleNewImage,
                                          builder:
                                              (context, _visibleNewImage, _) {
                                            return Column(
                                              children: [
                                                _PhotoWidget(),
                                                SizedBox(
                                                  height: _visiblePersonPhoto !=
                                                          null
                                                      ? 10
                                                      : 145.h,
                                                  width: 1.sw,
                                                ),
                                                _visiblePersonPhoto != null
                                                    ? _removePhoto()
                                                    : SizedBox.shrink(),
                                                !_visibleAddPhoto ||
                                                        _visiblePersonPhoto !=
                                                            null
                                                    ? SizedBox.shrink()
                                                    : _takePhoto(),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                !_visibleAddPhoto ||
                                                        _visiblePersonPhoto !=
                                                            null
                                                    ? SizedBox.shrink()
                                                    : _chooseFromLibrary()
                                              ],
                                            );
                                          });
                                    });
                              });
                        }),
                  ),
                ),
              ));
        });
  }

  Widget _removePhoto() {
    return InkWell(
      onTap: () {
        visiblePersonPhoto.value = null;
        visibleSave.value = true;
        homeBloc.add(UpdateProfileEvent(changeStatusToInit: true));
      },
      child: Container(
          alignment: Alignment.center,
          height: 20,
          width: 150,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                AppAssets.deletecartSvg,
                width: 18,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                LocaleKeys.remove_photo.tr(),
                style: context.textTheme.bodyMedium?.rr.copyWith(
                    color: const Color(0xff5D5C5D),
                    letterSpacing: 0.18,
                    fontSize: 14,
                    height: 1.3),
              ),
            ],
          )),
    );
  }

  Widget _takePhoto() {
    homeBloc.add(UpdateProfileEvent(changeStatusToInit: true));
    return InkWell(
      onTap: () async {
        cameras = await availableCameras();
        visiblecamera.value = true;

        /////////////////////////////////
      },
      child: Container(
        alignment: Alignment.center,
        width: 160,
        height: 20,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SvgPicture.asset(
              AppAssets.takphotoSvg,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              LocaleKeys.take_photo.tr(),
              style: context.textTheme.bodyMedium?.rr.copyWith(
                  color: const Color(0xff5D5C5D),
                  letterSpacing: 0.18,
                  fontSize: 14,
                  height: 1.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chooseFromLibrary() {
    homeBloc.add(UpdateProfileEvent(changeStatusToInit: true));
    return InkWell(
      onTap: () async {
        AssetEntity? assetEntity;
        assetEntity = await HelperFunctions.getAssetFromGallery(context);
        if (assetEntity != null) {
          if (assetEntity.type == AssetType.video) {
            showMessage('only photo', showInRelease: true);
          } else {
            File? file = await assetEntity.originFile;
            if (file != null) {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => CopperImage(
                        visibleNewImage: visibleAddPhoto,
                        image: file,
                        visiblePersonPhoto: visiblePersonPhoto,
                        visibleSave: visibleSave,
                        visiblecamera: visiblecamera,
                      )));
            }
          }
        }
      },
      child: Container(
        alignment: Alignment.center,
        width: 160,
        height: 20,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SvgPicture.asset(
              AppAssets.galarySvg,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              LocaleKeys.choose_from_library.tr(),
              style: context.textTheme.bodyMedium?.rr.copyWith(
                  color: const Color(0xff5D5C5D),
                  letterSpacing: 0.18,
                  fontSize: 14,
                  height: 1.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _PhotoWidget() {
    return visiblecamera.value
        ? ClipRRect(
            borderRadius: BorderRadius.circular(22.r),
            child: Container(
              width: 1.sw,
              height: 406.h,
              decoration: BoxDecoration(
                color: Color(0xffF8F8F8),
              ),
              child: CameraProfile(cameras, visiblePersonPhoto, visiblecamera,
                  visibleNewImage, visibleSave),
            ),
          )
        : visiblePersonPhoto.value != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(22.r),
                child: Container(
                  width: 1.sw,
                  height: 406.h,
                  decoration: BoxDecoration(
                    color: Color(0xffF8F8F8),
                  ),
                  child: homeBloc.state.userInfo?.image != null &&
                          !(visibleNewImage.value)
                      ? MyCachedNetworkImage(
                          imageUrl: homeBloc.state.userInfo!.image!,
                          width: 1.sw,
                          imageFit: BoxFit.cover,
                          height: 406.h)
                      : Image.file(
                          visiblePersonPhoto.value!,
                          height: 406.h,
                          width: 1.sw,
                          fit: BoxFit.fill,
                        ),
                ),
              )
            : InkWell(
                onTap: () => visibleAddPhoto.value = true,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 1.sw,
                      height: 406.h,
                      decoration: BoxDecoration(
                          color: Color(0xffF8F8F8),
                          borderRadius: BorderRadius.circular(22.r)),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 1.sw / 2 - 95,
                      child: Container(
                        alignment: Alignment.center,
                        width: 165,
                        height: 20,
                        child: Center(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            SvgPicture.asset(
                              AppAssets.addPhotoSvg,
                              color: Color(0xff5D5C5D),
                            ),
                            SizedBox(width: 10),
                            Text(
                              LocaleKeys.add_profile_photo.tr(),
                              style: context.textTheme.bodyMedium?.rr.copyWith(
                                  color: const Color(0xff5D5C5D),
                                  letterSpacing: 0.18,
                                  fontSize: 12,
                                  height: 1.3),
                            ),
                          ],
                        )),
                      ),
                    ),
                    Center(
                      child: SvgPicture.asset(
                        width: 50,
                        AppAssets.trySvg,
                        color: Color(0xffD3D3D3),
                      ),
                    )
                  ],
                ),
              );
  }
}
