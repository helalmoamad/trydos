import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/common/constant/design/assets_provider.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/falsh_deal_counter.dart';
import 'package:trydos/features/home/presentation/widgets/second_counter_for_redeem.dart';
import 'package:trydos/generated/locale_keys.g.dart' show LocaleKeys;
import 'package:trydos/service/language_service.dart';

class ProductDetailsImageWidget extends StatelessWidget {
  const ProductDetailsImageWidget(
      {super.key,
      this.width,
      this.imageUrl,
      this.withBackGroundShadow = true,
      this.withInnerShadow = true,
      this.borderRadius,
      this.borderColor,
      this.imageFit,
      this.imageHeight,
      this.isRedeem = false,
      this.productId,
      this.visibleRedeem,
      this.flashDealEndDate,
      this.lableNames,
      this.orginalHeight,
      this.index = 0,
      this.blurRadius = 10,
      this.imageWidth,
      this.orginalWidth,
      this.height,
      this.productNotAvailableNotifier,
      this.radius});

  final double? width;

  final List<String>? lableNames;
  final ValueNotifier<bool>? visibleRedeem;
  final ValueNotifier<String?>? productNotAvailableNotifier;
  final String? flashDealEndDate;
  final bool? isRedeem;
  final int? productId;
  final int index;
  final double? height;
  final double? imageWidth;
  final double? imageHeight;
  final double? blurRadius;
  final double? orginalWidth;
  final double? orginalHeight;
  final double? radius;
  final String? imageUrl;
  final BoxFit? imageFit;
  final Color? borderColor;
  final BorderRadiusGeometry? borderRadius;
  final bool withBackGroundShadow;

  final bool withInnerShadow;

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> visibleFlashDeal = ValueNotifier(false);
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
    print(imageUrl);
    return InteractiveViewer(
      panEnabled: true,
      minScale: 0.1,
      maxScale: 4.0,
      child: Stack(
        children: [
          Container(
            height: (height ?? 464),
            width: (width ?? 320),
            decoration: BoxDecoration(
              borderRadius:
                  borderRadius ?? BorderRadius.circular((radius ?? 30.0)),
              border: Border.all(
                  width: 0.5, color: borderColor ?? context.colorScheme.white),
              boxShadow: withBackGroundShadow
                  ? [
                      BoxShadow(
                        color: context.colorScheme.black.withOpacity(0.01),
                        offset: Offset(0, 0),
                        blurRadius: blurRadius ?? 10,
                      ),
                    ]
                  : null,
            ),
            child: ClipRRect(
                borderRadius:
                    borderRadius ?? BorderRadius.circular((radius ?? 30.0)),
                child: (imageUrl?.contains('assets') ?? true)
                    ? Image.asset('assets/images/address2.png',
                        fit: imageFit ?? BoxFit.cover)
                    : MyCachedNetworkImage(
                        ordinalHeight: orginalHeight,
                        ordinalwidth: orginalWidth,
                        imageUrl: imageUrl!,
                        imageWidth: imageWidth,
                        imageHeight: imageHeight,
                        height: height ?? 464,
                        width: width ?? 320,
                        imageFit: BoxFit.fitWidth,
                      )),
          ),
          Container(
            height: (height ?? 464),
            width: (width ?? 320),
            decoration: BoxDecoration(
              borderRadius:
                  borderRadius ?? BorderRadius.circular((radius ?? 30.0)),
              boxShadow: withInnerShadow
                  ? [
                      BoxShadow(
                          color: context.colorScheme.white,
                          offset: Offset(0, 3),
                          blurRadius: 6,
                          inset: true),
                    ]
                  : null,
            ),
          ),
          (flashDealEndDate ?? "") == ""
              ? SizedBox.shrink()
              : ValueListenableBuilder<String?>(
                  valueListenable:
                      productNotAvailableNotifier ?? ValueNotifier(null),
                  builder: (context, _productNotAvailableNotifier, _) {
                    return _productNotAvailableNotifier != null
                        ? SizedBox.shrink()
                        : ValueListenableBuilder<bool>(
                            valueListenable: visibleFlashDeal,
                            builder: (context, _visibleFlashDeal, _) {
                              bool isFlashDealEnded = false;
                              DateTime endDate;
                              Duration _duration = Duration();
                              final now = DateTime.now();
                              try {
                                endDate = DateFormat('MM/dd/yyyy', 'en_US')
                                    .parse(flashDealEndDate ?? "");
                                endDate = endDate.add(Duration(days: 1));
                              } catch (e) {
                                endDate = DateTime.now();
                                print('Error parsing date: $e');
                              }
                              _duration = endDate.difference(now);
                              if (_duration.isNegative ||
                                  _duration.inSeconds < 1) {
                                isFlashDealEnded = true;
                              }

                              return !isFlashDealEnded
                                  ? Positioned(
                                      left: 7,
                                      right: 7,
                                      top: 0,
                                      child: Transform(
                                        transform: Matrix4.skewX(
                                            -0.4), // انحراف بسيط للشكل
                                        child: Container(
                                          width: 150,
                                          margin: EdgeInsets.only(
                                              left: LanguageService
                                                          .languageCode !=
                                                      "ar"
                                                  ? 1
                                                  : 120.w,
                                              right: LanguageService
                                                          .languageCode ==
                                                      "ar"
                                                  ? 1
                                                  : 120.w),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Color(0xffFF6200)),
                                            color: Color(0xffFFF3E8),
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          height: 20,
                                          child: Transform(
                                              transform: Matrix4.skewX(
                                                  0.4), // انحراف بسيط للشكل
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  SvgPicture.asset(
                                                    AppAssets.flashDealSvg,
                                                    height: 12,
                                                    color: Color(0xffFF6200),
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    "${LocaleKeys.flash_deal.tr()}",
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: context.textTheme
                                                        .bodyMedium?.br
                                                        .copyWith(
                                                      color: Color(0xffFF6200),
                                                      letterSpacing: 0.18,
                                                      fontSize: 9,
                                                      height: 1.3,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  FlashDealCountdownTimerWidget(
                                                    visibleFlashDeal:
                                                        visibleFlashDeal,
                                                    endDateString:
                                                        flashDealEndDate ?? "",
                                                  )
                                                ],
                                              )),
                                        ),
                                      ))
                                  : SizedBox.shrink();
                            });
                  }),
          visibleRedeem != null && index == 0
              ? ValueListenableBuilder<String?>(
                  valueListenable:
                      productNotAvailableNotifier ?? ValueNotifier(null),
                  builder: (context, _productNotAvailableNotifier, _) {
                    return _productNotAvailableNotifier != null
                        ? SizedBox.shrink()
                        : ValueListenableBuilder<bool>(
                            valueListenable: visibleRedeem!,
                            builder: (context, _visibleRedeem, _) {
                              return (GetIt.I<PrefsRepository>()
                                                  .getRedeemDateForProduct(
                                                      productId.toString())
                                                  ?.isAfter(DateTime.now().add(
                                                      Duration(seconds: 1))) ==
                                              true &&
                                          isRedeem == true) ||
                                      (GetIt.I<PrefsRepository>()
                                                  .getRedeemSecondRemainingForProduct(
                                                      productId.toString()) ??
                                              0) >
                                          0
                                  ? Positioned(
                                      left: 7,
                                      right: 7,
                                      top: 0,
                                      child: Transform(
                                        transform: Matrix4.skewX(
                                            -0.4), // انحراف بسيط للشكل
                                        child: Container(
                                          width: 150,
                                          margin: EdgeInsets.only(
                                              left: LanguageService
                                                          .languageCode !=
                                                      "ar"
                                                  ? 1
                                                  : 120.w,
                                              right: LanguageService
                                                          .languageCode ==
                                                      "ar"
                                                  ? 1
                                                  : 120.w),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Color(0xffFF6200)),
                                            color: Color(0xffFFF3E8),
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          height: 20,
                                          child: Transform(
                                              transform: Matrix4.skewX(
                                                  0.4), // انحراف بسيط للشكل
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width: 8,
                                                  ),
                                                  SvgPicture.asset(
                                                      AppAssets.redeemClockSvg),
                                                  SizedBox(
                                                    width: 3,
                                                  ),
                                                  Text(LocaleKeys.luck.tr(),
                                                      style: context.textTheme
                                                          .bodyMedium?.br
                                                          .copyWith(
                                                        fontSize: 9,
                                                        color: const Color(
                                                            0xffFF6200),
                                                      )),
                                                  SizedBox(
                                                    width: 1,
                                                  ),
                                                  Text(
                                                      " ${LocaleKeys.add_to_bag_within.tr()} ",
                                                      style: context.textTheme
                                                          .bodyMedium?.mr
                                                          .copyWith(
                                                        fontSize: 9,
                                                        color: const Color(
                                                            0xffFF6200),
                                                      )),
                                                  SecondsCountdown(
                                                    denyStopTimer: true,
                                                    productId:
                                                        productId.toString(),
                                                    //   finishRedeem: widget.finishRedeem,
                                                    visibleRedeem:
                                                        visibleRedeem!,
                                                    endTime: GetIt.I<
                                                                PrefsRepository>()
                                                            .getRedeemDateForProduct(
                                                                productId
                                                                    .toString()) ??
                                                        DateTime.now(),
                                                  ),
                                                  Text(
                                                      " ${LocaleKeys.seconds.tr()} ",
                                                      style: context.textTheme
                                                          .bodyMedium?.br
                                                          .copyWith(
                                                        fontSize: 9,
                                                        color: const Color(
                                                            0xffFF6200),
                                                      )),
                                                ],
                                              )),
                                        ),
                                      ))
                                  : SizedBox.shrink();
                            });
                  })
              : SizedBox.shrink()
          /*  Positioned(
              left: LanguageService.languageCode != "ar" ? null : 5,
              right: LanguageService.languageCode == "ar" ? null : 5,
              top: (flashDealTime == null || flashDealTime == "") ? 10 : 55,
              child: Column(
                children: [
                  ...List.generate(
                      (lableNames?.length ?? 0) > 3
                          ? 3
                          : (lableNames?.length ?? 0),
                      (index) => Container(
                            margin: EdgeInsets.symmetric(vertical: 2),
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            height: 30,
                            constraints: BoxConstraints(maxWidth: 160),
                            decoration: BoxDecoration(
                              gradient: ((index % 2) == 0)
                                  ? LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                          Color.fromARGB(255, 255, 119, 40),
                                          Color.fromARGB(162, 255, 119, 40)
                                        ])
                                  : LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                          Color.fromARGB(255, 79, 40, 255),
                                          Color.fromARGB(106, 79, 40, 255)
                                        ]),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  AppAssets.lableSvg,
                                  height: 16,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                                Text(
                                  lableNames?[index] ?? "",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      context.textTheme.bodyMedium?.rr.copyWith(
                                    color: Colors.white,
                                    letterSpacing: 0.18,
                                    fontSize: 14,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ))
                ],
              )),*/
        ],
      ),
    );
  }
}
