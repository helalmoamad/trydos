import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:get_it/get_it.dart';
import 'package:mime/mime.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/features/app/vedio_player.dart';
import 'package:trydos/features/authentication/presentation/widgets/adding_name.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/chat/presentation/manager/chat_state.dart';
import 'package:trydos/features/chat/presentation/pages/media_in_profile.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import '../../../../common/constant/configuration/chat_url_routes.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../core/utils/responsive_padding.dart';
import '../../../../service/language_service.dart';
import '../../../app/app_widgets/loading_indicator/trydos_loader.dart';
import '../../../app/my_cached_network_image.dart';
import '../../../app/my_text_widget.dart';
import '../widgets/chat_widgets/no_image_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage(
      {Key? key,
      required this.receiverName,
      required this.fullReceiverName,
      required this.receiverPhone,
      this.receiverPhoto,
      required this.chatId})
      : super(key: key);
  final String receiverName;

  final String chatId;
  final String fullReceiverName;
  final String? receiverPhoto;
  final String receiverPhone;
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();
  List<String>? images = [];
  @override
  void initState() {
    images = _prefsRepository.getTheLocalPathForChannel(widget.chatId) ?? [];
    super.initState();
  }

  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };
    return Scaffold(
      backgroundColor: const Color(0xffF8F8F8),
      body: SafeArea(
        child: Stack(
          alignment: LanguageService.languageCode == 'ar'
              ? AlignmentDirectional.topEnd
              : AlignmentDirectional.topStart,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    50.verticalSpace,
                    widget.receiverPhoto != null
                        ? Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromARGB(2, 0, 0, 0)
//                            colorScheme.black.withOpacity(0.16)
                                  ,
                                  offset: const Offset(0, 3),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: MyCachedNetworkImage(
                              imageUrl:
                                  ChatUrls.baseUrl + widget.receiverPhoto!,
                              imageFit: BoxFit.cover,
                              progressIndicatorBuilderWidget: TrydosLoader(),
                              height: 150.h,
                              width: 150.w,
                            ),
                          )
                        : NoImageWidget(
                            height: 150.h,
                            width: 150.w,
                            textStyle: context.textTheme.subtitle1?.br.copyWith(
                                color: const Color(0xff6638FF),
                                letterSpacing: 0.18,
                                height: 1.33),
                            name: widget.receiverName),
                    17.verticalSpace,
                    MyTextWidget(
                      widget.fullReceiverName,
                      style: textTheme.headline5?.rr
                          .copyWith(color: const Color(0xff5D5C5D)),
                    ),
                    8.verticalSpace,
                    MyTextWidget(
                      widget.receiverPhone,
                      style: textTheme.bodyText2?.rr
                          .copyWith(color: const Color(0xff5D5C5D)),
                    ),
                  ],
                ),
                50.verticalSpace,
                Padding(
                  padding: HWEdgeInsets.symmetric(horizontal: 70.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {},
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              AppAssets.callingSvg,
                              color: const Color(0xff388CFF),
                              width: 25.sp,
                              height: 25.sp,
                            ),
                            10.verticalSpace,
                            MyTextWidget(
                              LocaleKeys.call.tr(),
                              style: textTheme.caption?.rr
                                  .copyWith(color: const Color(0xff5D5C5D)),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {},
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              AppAssets.videoCallSvg,
                              width: 25.sp,
                              height: 25.sp,
                            ),
                            10.verticalSpace,
                            MyTextWidget(
                              LocaleKeys.video.tr(),
                              style: textTheme.caption?.rr
                                  .copyWith(color: const Color(0xff5D5C5D)),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {},
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              AppAssets.searchSvg,
                              color: const Color(0xff388CFF),
                              width: 25.sp,
                              height: 25.sp,
                            ),
                            10.verticalSpace,
                            MyTextWidget(
                              LocaleKeys.search.tr(),
                              style: textTheme.caption?.rr
                                  .copyWith(color: const Color(0xff5D5C5D)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                50.verticalSpace,
                Container(
                  height: 95.h,
                  width: 1.sw,
                  decoration: BoxDecoration(
                      color: const Color(0xffF4F4F4),
                      borderRadius: BorderRadius.circular(20)),
                  padding: HWEdgeInsets.fromLTRB(15, 15, 20, 15),
                  margin: HWEdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        AppAssets.gallerySvg,
                        width: 25.sp,
                        height: 25.sp,
                      ),
                      20.horizontalSpace,
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyTextWidget(
                              LocaleKeys.media_files.tr(),
                              style: textTheme.bodyText1?.rr
                                  .copyWith(color: const Color(0xff5D5C5D)),
                            ),
                            10.verticalSpace,
                            BlocBuilder<ChatBloc, ChatState>(
                              builder: (context, state) {
                                return Flexible(
                                  child: Row(
                                    children: [
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                            AppAssets.imageGallerySvg,
                                            width: 15.sp,
                                            height: 15.sp,
                                          ),
                                          5.horizontalSpace,
                                          MyTextWidget(
                                            state.imageCountInEachChat
                                                .toString(),
                                            style: textTheme.caption?.lr
                                                .copyWith(
                                                    color: const Color(
                                                        0xff5D5C5D)),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                            AppAssets.videoGallerySvg,
                                            width: 15.sp,
                                            height: 15.sp,
                                          ),
                                          5.horizontalSpace,
                                          MyTextWidget(
                                            state.videoCountInEachChat
                                                .toString(),
                                            style: textTheme.caption?.lr
                                                .copyWith(
                                                    color: const Color(
                                                        0xff5D5C5D)),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                            AppAssets.fileGallerySvg,
                                            width: 15.sp,
                                            height: 15.sp,
                                          ),
                                          5.horizontalSpace,
                                          MyTextWidget(
                                            state.fileCountInEachChat
                                                .toString(),
                                            style: textTheme.caption?.lr
                                                .copyWith(
                                                    color: const Color(
                                                        0xff5D5C5D)),
                                          ),
                                        ],
                                      ),
                                      const Spacer(
                                        flex: 4,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          ],
                        ),
                      ),
                      InkWell(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              LocaleKeys.see_all.tr(),
                            ),
                            SizedBox(
                              width: 2.w,
                            ),
                            SvgPicture.asset(
                              AppAssets.forwardArrowRight,
                              width: 10.w,
                              height: 20.h,
                            ),
                          ],
                        ),
                        onTap: () =>
                            Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => MediaInProfile(
                            files: images ?? [],
                          ),
                        )),
                      )
                    ],
                  ),
                ),
                10.verticalSpace,
                Container(
                  alignment: Alignment.center,
                  width: 1.sw - 20.w,
                  height: 150.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: images!.length,
                    itemBuilder: (context, index) {
                      String mimeStr = images![index].split(" ")[0];
                      if (mimeStr.split('/').contains("video")) {
                        return Container(
                          margin: EdgeInsets.all(2),
                          width: 200.w,
                          child: MYVideoPlayer(
                            videoFile: File(images![index].split(" ")[1]),
                            chatId: widget.chatId,
                          ),
                        );
                      }
                      if (mimeStr.split('/').contains("image")) {
                        return FullScreenWidget(
                          backgroundColor: const Color(0xffB4FFD9),
                          child: Hero(
                            tag: "hero${DateTime.now()}",
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 2),
                              width: 150.w,
                              height: 400.h,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: FileImage(
                                      File(images![index].split(" ")[1])),
                                  fit: BoxFit.fill,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  width: 3.0,
                                  color: const Color(0xffB4FFD9),
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      return SizedBox.shrink();
                    },
                  ),
                ),
                10.verticalSpace,
                Container(
                  decoration: BoxDecoration(
                      color: const Color(0xffF4F4F4),
                      borderRadius: BorderRadius.circular(20)),
                  padding: HWEdgeInsets.fromLTRB(15, 15, 20, 15),
                  margin: HWEdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        AppAssets.saveToGallerySvg,
                        width: 25.sp,
                        height: 25.sp,
                      ),
                      20.horizontalSpace,
                      MyTextWidget(
                        LocaleKeys.save_to_gallery.tr(),
                        style: textTheme.bodyText1?.rr
                            .copyWith(color: const Color(0xff5D5C5D)),
                      ),
                      const Spacer(),
                      MyTextWidget(
                        LocaleKeys.never.tr(),
                        style: textTheme.bodyText1?.lr
                            .copyWith(color: const Color(0xff5D5C5D)),
                      ),
                      36.horizontalSpace,
                      Transform(
                        alignment: Alignment.center,
                        transform: (Matrix4.identity()
                          ..scale(
                              LanguageService.languageCode == 'ar' ? -1.0 : 1.0,
                              1.0,
                              1.0)),
                        child: SvgPicture.asset(
                          AppAssets.forwardArrowRight,
                          width: 3.w,
                          height: 12.h,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(20.w, 15.h, 20.w, 0),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: SvgPicture.asset(
                  AppAssets.backFromCallSvg,
                  height: 20,
                  color: const Color(0xff388CFF),
                  width: 8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
