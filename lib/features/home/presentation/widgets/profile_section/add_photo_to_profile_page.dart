import 'package:flutter/foundation.dart' hide Category;
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart' as transform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/constant/design/assets_provider.dart';
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
import 'package:trydos/core/utils/last_pages_tracker.dart';

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
    LastPagesTracker.push('AddPhotoProfilePage');
    homeBloc = BlocProvider.of<HomeBloc>(context);
    homeBloc.add(UpdateProfileEvent(changeStatusToInit: true));
    if (!(prefsRepository.myProfilePhoto == null ||
        prefsRepository.myProfilePhoto == "")) {
      if (kDebugMode) print(
        "22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222",
      );
      visiblePersonPhoto.value = File("initImage");
    }

    super.initState();
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
                !_visibleSave ? const SizedBox.shrink() : SizedBox(width: 55.w),
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
                !_visibleSave
                    ? const SizedBox.shrink()
                    : BlocBuilder<HomeBloc, HomeState>(
                        buildWhen: (previous, current) =>
                            previous.updateProfileStatus !=
                                current.updateProfileStatus ||
                            previous.uploadUserPhotoCloudinaryStatus !=
                                current.uploadUserPhotoCloudinaryStatus,
                        builder: (context, state) {
                          if (state.updateProfileStatus ==
                              UpdateProfileStatus.success) {
                            Future.delayed(
                              const Duration(milliseconds: 300),
                              () => visibleSave.value = false,
                            );
                          }
                          return InkWell(
                            onTap: () async {
                              if (visiblePersonPhoto.value == null) {
                                homeBloc.add(
                                  UpdateProfileEvent(image: "def.png"),
                                );
                              } else {
                                homeBloc.add(
                                  UploadUserPhotoCloudinaryEvent(
                                    visiblePersonPhoto.value!,
                                    false,
                                  ),
                                );
                              }
                            },
                            child: Container(
                              alignment: Alignment.center,
                              width: 40.w,
                              height: 20.h,
                              child:
                                  state.updateProfileStatus ==
                                          UpdateProfileStatus.loading ||
                                      state.uploadUserPhotoCloudinaryStatus ==
                                          UploadUserPhotoCloudinaryStatus
                                              .loading
                                  ? TrydosLoader(size: 18)
                                  : Text(
                                      LocaleKeys.save.tr(),
                                      style: context.textTheme.bodyMedium?.mq
                                          .copyWith(
                                            color: const Color(0xff402CDD),
                                            letterSpacing: 0.18,
                                            fontSize: 14.sp,
                                            height: 1.3,
                                          ),
                                    ),
                            ),
                          );
                        },
                      ),
                !_visibleSave ? const SizedBox.shrink() : SizedBox(width: 15.w),
              ],
              scrolledUnderElevation: 0,
              backIconColor: Colors.black,
              withShadow: false,
            ),
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
                              builder: (context, _visibleNewImage, _) {
                                return Column(
                                  children: [
                                    _PhotoWidget(),
                                    SizedBox(
                                      height: _visiblePersonPhoto != null
                                          ? 10
                                          : 145.h,
                                      width: 1.sw,
                                    ),
                                    _visiblePersonPhoto != null
                                        ? _removePhoto()
                                        : const SizedBox.shrink(),
                                    !_visibleAddPhoto ||
                                            _visiblePersonPhoto != null
                                        ? const SizedBox.shrink()
                                        : _takePhoto(),
                                    const SizedBox(height: 10),
                                    !_visibleAddPhoto ||
                                            _visiblePersonPhoto != null
                                        ? const SizedBox.shrink()
                                        : _chooseFromLibrary(),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
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
        height: 20.h,
        width: 150.w,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              AppAssets.deletecartSvg,
              width: 18.w,
              height: 18.h,
            ),
            SizedBox(width: 10.w),
            Text(
              LocaleKeys.remove_photo.tr(),
              style: context.textTheme.bodyMedium?.rq.copyWith(
                color: const Color(0xff5D5C5D),
                letterSpacing: 0.18,
                fontSize: 14.sp,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
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
        width: 160.w,
        height: 20.h,
        child: Row(
          children: [
            SvgPicture.asset(AppAssets.takphotoSvg),
            SizedBox(width: 10.w),
            Text(
              LocaleKeys.take_photo.tr(),
              style: context.textTheme.bodyMedium?.rq.copyWith(
                color: const Color(0xff5D5C5D),
                letterSpacing: 0.18,
                fontSize: 14.sp,
                height: 1.3,
              ),
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
            showWarningMessage(context, 'only photo');
          } else {
            File? file = await assetEntity.originFile;
            if (file != null) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CopperImage(
                    visibleNewImage: visibleAddPhoto,
                    image: file,
                    visiblePersonPhoto: visiblePersonPhoto,
                    visibleSave: visibleSave,
                    visiblecamera: visiblecamera,
                  ),
                ),
              );
            }
          }
        }
      },
      child: Container(
        alignment: Alignment.center,
        width: 160.w,
        height: 20.h,
        child: Row(
          children: [
            SvgPicture.asset(AppAssets.galarySvg),
            SizedBox(width: 10.w),
            Text(
              LocaleKeys.choose_from_library.tr(),
              style: context.textTheme.bodyMedium?.rq.copyWith(
                color: const Color(0xff5D5C5D),
                letterSpacing: 0.18,
                fontSize: 14.sp,
                height: 1.3,
              ),
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
              decoration: const BoxDecoration(color: Color(0xffF8F8F8)),
              child: CameraProfile(
                cameras,
                visiblePersonPhoto,
                visiblecamera,
                visibleNewImage,
                visibleSave,
              ),
            ),
          )
        : visiblePersonPhoto.value != null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(22.r),
            child: Container(
              width: 1.sw,
              height: 406.h,
              decoration: const BoxDecoration(color: Color(0xffF8F8F8)),
              child:
                  !(prefsRepository.myProfilePhoto == null ||
                          prefsRepository.myProfilePhoto == "") &&
                      !(visibleNewImage.value)
                  ? MyCachedNetworkImage(
                      imageUrl: prefsRepository.myProfilePhoto!,
                      width: 1.sw,
                      imageFit: BoxFit.cover,
                      height: 406.h,
                    )
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
                    color: const Color(0xffF8F8F8),
                    borderRadius: BorderRadius.circular(22.r),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 1.sw / 2 - 95,
                  child: Container(
                    alignment: Alignment.center,
                    width: 165.w,
                    height: 20.h,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 10.w),
                          SvgPicture.asset(
                            AppAssets.addPhotoSvg,
                            // ignore: deprecated_member_use
                            color: const Color(0xff5D5C5D),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            LocaleKeys.add_profile_photo.tr(),
                            style: context.textTheme.bodyMedium?.rq.copyWith(
                              color: const Color(0xff5D5C5D),
                              letterSpacing: 0.18,
                              fontSize: 12.sp,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Center(
                  child: SvgPicture.asset(
                    width: 50.w,
                    AppAssets.trySvg,
                    // ignore: deprecated_member_use
                    color: const Color(0xffD3D3D3),
                  ),
                ),
              ],
            ),
          );
  }
}
