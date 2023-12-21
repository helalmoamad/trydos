
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';

import '../../../../common/constant/configuration/chat_url_routes.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../core/utils/responsive_padding.dart';
import '../../../../service/language_service.dart';
import '../../../app/app_widgets/loading_indicator/trydos_loader.dart';
import '../../../app/my_cached_network_image.dart';
import '../widgets/chat_widgets/no_image_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key , required this.receiverName, required this.fullReceiverName, required this.receiverPhone,this.receiverPhoto}) : super(key: key);
  final String receiverName;
  final String fullReceiverName;
  final String? receiverPhoto;
  final String receiverPhone;
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
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
          alignment: LanguageService
              .languageCode ==
              'ar' ? AlignmentDirectional.topEnd : AlignmentDirectional.topStart,
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

                        boxShadow:  [
                          BoxShadow(
                            color:
                            Color.fromARGB(2, 0, 0, 0)
//                            colorScheme.black.withOpacity(0.16)
                            ,
                            offset: const Offset(0, 3),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: MyCachedNetworkImage(
                        imageUrl: ChatUrls.baseUrl + widget.receiverPhoto!,
                        imageFit: BoxFit.cover,
                        progressIndicatorBuilderWidget: TrydosLoader(),
                        height: 150.h,
                        width: 150.w,
                      ),
                    )
                        : NoImageWidget(
                        height: 150.h,
                        width: 150.w,
                        textStyle: context.textTheme.subtitle1?.br
                            .copyWith(
                            color: const Color(0xff6638FF),
                            letterSpacing: 0.18,
                            height: 1.33),
                        name: widget.receiverName),
                    17.verticalSpace,
                      Text(
                        widget.fullReceiverName,
                        style: textTheme.headline5?.rr
                            .copyWith(color: const Color(0xff5D5C5D)),
                      ),
                    8.verticalSpace,
                    Text(
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
                        onTap: (){},
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
                            Text(
                              'Call',
                              style: textTheme.caption?.rr
                                  .copyWith(color: const Color(0xff5D5C5D)),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: (){},
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              AppAssets.videoCallSvg,
                              width: 25.sp,
                              height: 25.sp,
                            ),
                            10.verticalSpace,
                            Text(
                              'Video',
                              style: textTheme.caption?.rr
                                  .copyWith(color: const Color(0xff5D5C5D)),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: (){},
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
                            Text(
                              'Search',
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
                  height: 75.h,
                  width: 1.sw,
                  decoration: BoxDecoration(
                    color: const Color(0xffF4F4F4),
                    borderRadius: BorderRadius.circular(20)
                  ),
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
                            Text(
                              'Media & Files',
                              style: textTheme.bodyText1?.rr
                                  .copyWith(color: const Color(0xff5D5C5D)),
                            ),
                            10.verticalSpace,
                            Flexible(
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
                                      Text(
                                        '3122',
                                        style: textTheme.caption?.lr
                                            .copyWith(color: const Color(0xff5D5C5D)),
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
                                      Text(
                                        '18',
                                        style: textTheme.caption?.lr
                                            .copyWith(color: const Color(0xff5D5C5D)),
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
                                      Text(
                                        '2',
                                        style: textTheme.caption?.lr
                                            .copyWith(color: const Color(0xff5D5C5D)),
                                      ),
                                    ],
                                  ),
                                  const Spacer(flex: 4,),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Transform(
                        alignment: Alignment.center,
                        transform: (Matrix4.identity()
                          ..scale(
                              LanguageService
                                  .languageCode ==
                                  'ar'
                                  ? -1.0
                                  : 1.0,
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
                ),
                10.verticalSpace,
                Container(
                  decoration: BoxDecoration(
                      color: const Color(0xffF4F4F4),
                      borderRadius: BorderRadius.circular(20)
                  ),
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
                      Text('Save To Gallery',
                        style: textTheme.bodyText1?.rr
                            .copyWith(color: const Color(0xff5D5C5D)),),
                      const Spacer(),
                      Text('Never',
                        style: textTheme.bodyText1?.lr
                            .copyWith(color: const Color(0xff5D5C5D)),),
                      36.horizontalSpace,
                      Transform(
                        alignment: Alignment.center,
                        transform: (Matrix4.identity()
                          ..scale(
                              LanguageService
                                  .languageCode ==
                                  'ar'
                                  ? -1.0
                                  : 1.0,
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
                onTap: (){
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
