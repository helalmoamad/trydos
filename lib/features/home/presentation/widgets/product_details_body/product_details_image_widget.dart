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
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/falsh_deal_counter.dart';
import 'package:trydos/features/home/presentation/widgets/second_counter_for_redeem.dart';
import 'package:trydos/generated/locale_keys.g.dart' show LocaleKeys;
import 'package:trydos/service/language_service.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';

class ProductDetailsImageWidget extends StatelessWidget {
  const ProductDetailsImageWidget({
    super.key,
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
    this.flashDealEndDate,
    this.lableNames,
    this.orginalHeight,
    this.index = -1,
    this.blurRadius = 10,
    this.imageWidth,
    this.visibleRedeemNotifier,
    this.orginalWidth,
    this.isFlashDealEnded,
    this.visibleFlashDeal,
    this.height,
    this.visibleRedeem,
    this.radius,
  });

  final double? width;

  final List<String>? lableNames;

  final String? flashDealEndDate;
  final bool? isRedeem;

  final bool? isFlashDealEnded;
  final bool? visibleRedeem;
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
  final ValueNotifier<bool>? visibleRedeemNotifier;
  final Color? borderColor;
  final BorderRadiusGeometry? borderRadius;
  final bool withBackGroundShadow;
  final ValueNotifier<bool>? visibleFlashDeal;
  final bool withInnerShadow;

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return InteractiveViewer(
      minScale: 0.1,
      maxScale: 4.0,
      child: Stack(
        children: [
          Container(
            height: (height ?? 464),
            width: (width ?? 320),
            decoration: BoxDecoration(
              borderRadius: index == 0
                  ? BorderRadius.only(
                      bottomRight: LanguageService.languageCode != "ar"
                          ? const Radius.circular(0)
                          : const Radius.circular(15),
                      topRight: LanguageService.languageCode != "ar"
                          ? const Radius.circular(0)
                          : const Radius.circular(15),
                      topLeft: LanguageService.languageCode == "ar"
                          ? const Radius.circular(0)
                          : const Radius.circular(15),
                      bottomLeft: LanguageService.languageCode == "ar"
                          ? const Radius.circular(0)
                          : const Radius.circular(15),
                    )
                  : borderRadius ?? BorderRadius.circular((radius ?? 30.0)),
              border: Border.all(
                width: 0.5,
                color: borderColor ?? context.colorScheme.white,
              ),
              boxShadow: withBackGroundShadow
                  ? [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: context.colorScheme.black.withOpacity(0.01),
                        blurRadius: blurRadius ?? 10,
                      ),
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: index == 0
                  ? BorderRadius.only(
                      bottomRight: LanguageService.languageCode != "ar"
                          ? const Radius.circular(0)
                          : const Radius.circular(15),
                      topRight: LanguageService.languageCode != "ar"
                          ? const Radius.circular(0)
                          : const Radius.circular(15),
                      topLeft: LanguageService.languageCode == "ar"
                          ? const Radius.circular(0)
                          : const Radius.circular(15),
                      bottomLeft: LanguageService.languageCode == "ar"
                          ? const Radius.circular(0)
                          : const Radius.circular(15),
                    )
                  : borderRadius ?? BorderRadius.circular((radius ?? 30.0)),
              child: (imageUrl?.contains('assets') ?? true)
                  ? Image.asset(
                      'assets/images/address2.png',
                      fit: imageFit ?? BoxFit.cover,
                    )
                  : MyCachedNetworkImage(
                      ordinalHeight: orginalHeight,
                      ordinalwidth: orginalWidth,
                      imageUrl: imageUrl!,
                      radius: index != -1 ? 0 : 12,
                      imageWidth: imageWidth,
                      imageHeight: imageHeight,
                      height: height ?? 464,
                      width: width ?? 320,
                      imageFit: BoxFit.fitWidth,
                    ),
            ),
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
                        offset: const Offset(0, 3),
                        blurRadius: 6,
                        inset: true,
                      ),
                    ]
                  : null,
            ),
          ),
          index != 0
              ? const SizedBox.shrink()
              : Positioned(
                  bottom: 0,
                  right: LanguageService.languageCode != "ar" ? null : 0,
                  left: LanguageService.languageCode == "ar" ? null : 0,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 25,
                        height: 25,
                        decoration: BoxDecoration(
                          color: const Color(0xff513AAF),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(6),
                            bottomRight: Radius.circular(
                              LanguageService.languageCode == "ar" ? 15 : 6,
                            ),
                            bottomLeft: Radius.circular(
                              LanguageService.languageCode != "ar" ? 15 : 6,
                            ),
                            topRight: const Radius.circular(6),
                          ),
                        ),
                      ),
                      SvgPicture.asset(AppAssets.malekanSvg),
                    ],
                  ),
                ),
          (flashDealEndDate ?? "") == "" || index != 0
              ? const SizedBox.shrink()
              : !(isFlashDealEnded ?? true)
              ? Positioned(
                  left: 4,
                  right: 4,
                  top: 0,
                  child: Transform(
                    transform: Matrix4.skewX(-0.4), // انحراف بسيط للشكل
                    child: Container(
                      margin: EdgeInsets.only(
                        left: LanguageService.languageCode != "ar" ? 1 : 170.w,
                        right: LanguageService.languageCode == "ar" ? 1 : 170.w,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xffFF6200)),
                        color: const Color(0xffFFF3E8),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      height: 20,
                      child: Transform(
                        transform: Matrix4.skewX(0.4), // انحراف بسيط للشكل
                        child: Row(
                          children: [
                            const SizedBox(width: 5),
                            SvgPicture.asset(
                              AppAssets.flashDealSvg,
                              height: 12,
                              // ignore: deprecated_member_use
                              color: const Color(0xffFF6200),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              "${LocaleKeys.flash_deal.tr()}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.bodyMedium?.br.copyWith(
                                color: const Color(0xffFF6200),
                                letterSpacing: 0.18,
                                fontSize: 9,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(width: 2),
                            FlashDealCountdownTimerWidget(
                              visibleFlashDeal: visibleFlashDeal,
                              endDateString: flashDealEndDate ?? "",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
          visibleRedeem == true && index == 0
              ? Positioned(
                  left: 4,
                  right: 4,
                  top: 0,
                  child: Transform(
                    transform: Matrix4.skewX(-0.4), // انحراف بسيط للشكل
                    child: Container(
                      width: 150,
                      margin: EdgeInsets.only(
                        left: LanguageService.languageCode != "ar" ? 1 : 130.w,
                        right: LanguageService.languageCode == "ar" ? 1 : 130.w,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xffFF6200)),
                        color: const Color(0xffFFF3E8),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      height: 20,
                      child: Transform(
                        transform: Matrix4.skewX(0.4), // انحراف بسيط للشكل
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            SvgPicture.asset(AppAssets.redeemClockSvg),
                            const SizedBox(width: 3),
                            Text(
                              LocaleKeys.luck.tr(),
                              style: context.textTheme.bodyMedium?.br.copyWith(
                                fontSize: 9,
                                color: const Color(0xffFF6200),
                              ),
                            ),
                            const SizedBox(width: 1),
                            Text(
                              " ${LocaleKeys.add_to_bag_within.tr()} ",
                              style: context.textTheme.bodyMedium?.mq.copyWith(
                                fontSize: 9,
                                color: const Color(0xffFF6200),
                              ),
                            ),
                            SecondsCountdown(
                              denyStopTimer: true,
                              productId: productId.toString(),
                              //   finishRedeem: widget.finishRedeem,
                              visibleRedeem: visibleRedeemNotifier!,
                              endTime:
                                  GetIt.I<PrefsRepository>()
                                      .getRedeemDateForProduct(
                                        productId.toString(),
                                      ) ??
                                  DateTime.now(),
                            ),
                            Text(
                              " ${LocaleKeys.seconds.tr()} ",
                              style: context.textTheme.bodyMedium?.br.copyWith(
                                fontSize: 9,
                                color: const Color(0xffFF6200),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
          ((visibleRedeem == true || !(isFlashDealEnded ?? true)) && index == 0)
              ? Positioned(
                  left: LanguageService.languageCode == "ar" ? null : 35.w,
                  right: LanguageService.languageCode != "ar" ? null : 35.w,
                  top: 80.h,
                  child: Container(
                    width: 97,
                    height: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          width: 76,
                          height: 20,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            color: Color(0xff1D1D1D),
                          ),
                          child: Text(
                            "${LocaleKeys.only_this_piece.tr()}",
                            textAlign: TextAlign.center,
                            style: context.textTheme.bodyMedium?.mq.copyWith(
                              fontSize: 9,
                              color: const Color(0xffFFFFFF),
                            ),
                          ),
                        ),
                        Container(
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xffFFFFFF)),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(15),
                            ),
                            color: const Color(0xff1D1D1D),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
