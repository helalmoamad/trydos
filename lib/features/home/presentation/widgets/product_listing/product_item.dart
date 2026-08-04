import 'package:flutter/foundation.dart' hide Category;
import 'package:easy_localization/easy_localization.dart' as tran;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trydos/common/constant/design/assets_provider.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';

import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as productListingModel;
import 'package:trydos/features/home/presentation/widgets/product_listing/falsh_deal_counter.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_3d_slider_optimized.dart';

import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_with_silder.dart';
import 'package:trydos/features/home/presentation/widgets/second_counter_for_redeem.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/language_service.dart';

class ProductItem extends StatefulWidget {
  const ProductItem({
    super.key,
    required this.itemIndex,
    this.productIsFlashDeal,
    this.fromRecommend,
    this.productIsRecommend,
    this.fromHomePage = false,
    this.refreshFlashDeal,
    this.fromFlashDeal,
    this.imageSource,
    required this.finishRedeem,
    this.showShadowForColorImages,
    this.colorImagesPanelController,
    this.tapIndexToShowColorImages,
    this.displayImageColors,
    required this.tapIndexToAddProductToCart,
    required this.productItem,
  });

  final ValueNotifier<int> tapIndexToAddProductToCart;
  final ValueNotifier<bool> finishRedeem;
  final bool? displayImageColors;
  final bool? fromFlashDeal;
  final ValueNotifier<int>? tapIndexToShowColorImages;
  final bool fromHomePage;
  final String? imageSource;
  final bool? fromRecommend;
  final ValueNotifier<bool>? productIsRecommend;
  final ValueNotifier<bool>? showShadowForColorImages;
  final PanelController? colorImagesPanelController;
  final ValueNotifier<bool>? productIsFlashDeal;
  final ValueNotifier<bool>? refreshFlashDeal;

  final productListingModel.Products productItem;
  final int itemIndex;

  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  final PageController pageController = PageController();
  late final ValueNotifier<int> currentChosenColor;
  final ValueNotifier<bool> visibleRedeem = ValueNotifier(false);
  final ValueNotifier<bool> visibleFlashDeal = ValueNotifier(false);
  final dateNow = DateTime.now();
  final pref = GetIt.I<PrefsRepository>();
  @override
  void initState() {
    super.initState();
    currentChosenColor = ValueNotifier(
      (widget.productItem.syncColorImages?.length ?? 0) ~/ 2,
    );
    if (widget.productItem.hasRedeemDiscount == true) {
      pref.setRedeemDateForProduct(
        widget.productItem.productId.toString(),
        "50",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };

    return Stack(
      key: ValueKey(widget.productItem.slug),
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        widget.fromHomePage
            ? ProductListing3DSliderOptimized(
                visibleFlashDeal: visibleFlashDeal,
                finishRedeem: widget.finishRedeem,
                videoSource: widget.productItem.videos.isNullOrEmpty
                    ? null
                    : widget.productItem.videos!.first.contains("cloudinary")
                    ? widget.productItem.videos!.first
                    : ("${dotenv.env['Vedio_S3_Server']}" +
                          (widget.productItem.videos!.first)),
                productIsFlashDeal: widget.productIsFlashDeal,
                productIsRecommend: widget.productIsRecommend,
                fromRecommend: widget.fromRecommend,
                fromFlashDeal: widget.fromFlashDeal,
                fromHomePage: widget.fromHomePage,
                visibleRedeem: visibleRedeem,
                productItem: widget.productItem,
                tapIndexToAddProductToCart: widget.tapIndexToAddProductToCart,
                itemIndex: widget.itemIndex,
              )
            : ProductListingWithSlider(
                visibleFlashDeal: visibleFlashDeal,
                tapIndexToShowColorImages: widget.tapIndexToShowColorImages,
                finishRedeem: widget.finishRedeem,
                videoSource: widget.productItem.videos.isNullOrEmpty
                    ? null
                    : widget.productItem.videos!.first.contains("cloudinary")
                    ? widget.productItem.videos!.first
                    : ("${dotenv.env['Vedio_S3_Server']}" +
                          (widget.productItem.videos!.first)),
                showShadowForColorImages: widget.showShadowForColorImages,
                colorImagesPanelController: widget.colorImagesPanelController,
                visibleRedeem: visibleRedeem,
                fromFlashDeal: widget.fromFlashDeal,
                fromHomePage: widget.fromHomePage,
                productItem: widget.productItem,
                tapIndexToAddProductToCart: widget.tapIndexToAddProductToCart,
                itemIndex: widget.itemIndex,
              ),

        (widget.productItem.flashDealEndDate == null ||
                widget.productItem.flashDealEndDate == "")
            ? const SizedBox.shrink()
            : (widget.productItem.flashDealEndDate ?? "") == ""
            ? const SizedBox.shrink()
            : Directionality(
                textDirection: LanguageService.languageCode == "ar"
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: ValueListenableBuilder<bool>(
                  valueListenable: visibleFlashDeal,
                  builder: (context, _visibleFlashDeal, _) {
                    bool isFlashDealEnded = false;
                    DateTime endDate;
                    Duration _duration = const Duration();

                    try {
                      endDate = tran.DateFormat(
                        'MM/dd/yyyy',
                        'en_US',
                      ).parse(widget.productItem.flashDealEndDate ?? "");
                      endDate = endDate.add(const Duration(days: 1));
                    } catch (e) {
                      endDate = dateNow;
                      if (kDebugMode) print('Error parsing date: $e');
                    }
                    _duration = endDate.difference(dateNow);
                    if (_duration.isNegative || _duration.inSeconds < 1) {
                      isFlashDealEnded = true;
                    }

                    return !isFlashDealEnded
                        ? Positioned(
                            left: LanguageService.languageCode != "ar"
                                ? 5.w
                                : null,
                            right: LanguageService.languageCode == "ar"
                                ? 5.w
                                : null,
                            top: -5.h,
                            child: Transform(
                              transform: Matrix4.skewX(-0.4),
                              child: Container(
                                margin: EdgeInsets.only(
                                  left: LanguageService.languageCode != "ar"
                                      ? 1
                                      : 10.w,
                                  right: LanguageService.languageCode == "ar"
                                      ? 1
                                      : 10.w,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xffFF6200),
                                  ),
                                  color: const Color(0xffFFF3E8),
                                  borderRadius: BorderRadius.circular(15.r),
                                ),
                                height: 25.h,
                                child: Transform(
                                  transform: Matrix4.skewX(0.4),
                                  child: Row(
                                    children: [
                                      SizedBox(width: 3.w),
                                      SvgPicture.asset(
                                        AppAssets.flashDealSvg,
                                        height: 9.h,
                                        colorFilter: const ColorFilter.mode(
                                          Color(0xffFF6200),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      SizedBox(width: 2.w),
                                      Text(
                                        "${LocaleKeys.flash_deal.tr()}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: context.textTheme.bodyMedium?.bq
                                            .copyWith(
                                              color: const Color(0xffFF6200),
                                              letterSpacing: 0.18,
                                              fontSize: 9.sp,
                                              height: 1.3,
                                            ),
                                      ),
                                      SizedBox(width: 5.w),
                                      // 💡 عزل عداد الفلاش ديل لمنع إعادة رسم الكارت عند تغيير الثواني
                                      FlashDealCountdownTimerWidget(
                                        visibleFlashDeal: visibleFlashDeal,
                                        refreshFlashDeal:
                                            widget.refreshFlashDeal,
                                        endDateString:
                                            widget
                                                .productItem
                                                .flashDealEndDate ??
                                            "",
                                      ),
                                      SizedBox(width: 10.w),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink();
                  },
                ),
              ),

        Directionality(
          textDirection: LanguageService.languageCode == "ar"
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: ValueListenableBuilder<bool>(
            valueListenable: visibleRedeem,
            builder: (context, _visibleRedeem, _) {
              return (pref
                                  .getRedeemDateForProduct(
                                    widget.productItem.productId.toString(),
                                  )
                                  ?.isAfter(
                                    DateTime.now().add(
                                      const Duration(seconds: 1),
                                    ),
                                  ) ==
                              true &&
                          widget.productItem.hasRedeemDiscount == true) ||
                      (pref.getRedeemSecondRemainingForProduct(
                                widget.productItem.productId.toString(),
                              ) ??
                              0) >
                          0
                  ? Positioned(
                      left: LanguageService.languageCode != "ar" ? 5.w : null,
                      right: LanguageService.languageCode == "ar" ? 5.w : null,
                      top: -5.h,
                      child: Transform(
                        transform: Matrix4.skewX(-0.4),
                        child: Container(
                          margin: EdgeInsets.only(
                            left: LanguageService.languageCode != "ar"
                                ? 0
                                : 10.w,
                            right: LanguageService.languageCode == "ar"
                                ? 0
                                : 10.w,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xffFF6200)),
                            color: const Color(0xffFFF3E8),
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                          height: 25.h,
                          child: Transform(
                            transform: Matrix4.skewX(0.4),
                            child: Row(
                              children: [
                                SizedBox(width: 3.w),
                                SvgPicture.asset(
                                  AppAssets.redeemClockSvg,
                                  height: 9.h,
                                ),
                                SizedBox(width: 3.w),
                                Text(
                                  LocaleKeys.luck.tr(),
                                  style: context.textTheme.bodyMedium?.bq
                                      .copyWith(
                                        fontSize: 9.sp,
                                        color: const Color(0xffFF6200),
                                      ),
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  " ${LocaleKeys.add_to_bag_within.tr()} ",
                                  style: context.textTheme.bodyMedium?.mq
                                      .copyWith(
                                        fontSize: 9.sp,
                                        color: const Color(0xffFF6200),
                                      ),
                                ),
                                // 💡 عزل عداد الثواني الخاص بـ Redeem لمنع الـ Jank
                                SecondsCountdown(
                                  productId: widget.productItem.productId
                                      .toString(),
                                  finishRedeem: widget.finishRedeem,
                                  visibleRedeem: visibleRedeem,
                                  endTime:
                                      pref.getRedeemDateForProduct(
                                        widget.productItem.productId.toString(),
                                      ) ??
                                      dateNow,
                                ),
                                Text(
                                  " ${LocaleKeys.seconds.tr()} ",
                                  style: context.textTheme.bodyMedium?.bq
                                      .copyWith(
                                        fontSize: 9.sp,
                                        color: const Color(0xffFF6200),
                                      ),
                                ),
                                SizedBox(width: 10.w),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}
