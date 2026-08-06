import 'dart:async';
import 'package:easy_localization/easy_localization.dart' as trans;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_image_widget.dart';
import 'package:trydos/features/home/presentation/widgets/rotating_text_widget.dart';
import 'package:trydos/features/home/presentation/widgets/second_counter_for_redeem.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as productListingModel;
import 'package:trydos/main.dart';
import 'package:video_player/video_player.dart';
import '../../../../../service/language_service.dart';
import '../../../../app/my_text_widget.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';

/// 🚀 نسخة مبسطة جداً من ProductListing3DSlider - أداء فائق ⚡
class ProductListing3DSliderOptimized extends StatefulWidget {
  const ProductListing3DSliderOptimized({
    super.key,
    // required this.setThisEnabled,
    // required this.slidingModeItem,
    required this.itemIndex,
    required this.tapIndexToAddProductToCart,
    required this.visibleRedeem,
    required this.productItem,
    required this.visibleFlashDeal,
    this.productIsFlashDeal,
    this.productIsRecommend,
    this.fromRecommend,
    this.fromFlashDeal,
    this.fromHomePage = false,
    required this.finishRedeem,
    this.videoSource,
    // جديد: افتراضي false
    //required this.displayImageColors,
    //  required this.currentChosenColor,
  });

  // final Tuple2<int, int> slidingModeItem;
  // final void Function(int, int) setThisEnabled;
  final ValueNotifier<int> tapIndexToAddProductToCart;
  final ValueNotifier<bool> finishRedeem;
  final ValueNotifier<bool>? productIsRecommend;
  final ValueNotifier<bool> visibleFlashDeal;
  final int itemIndex;
  //final bool displayImageColors;
  final ValueNotifier<bool> visibleRedeem;
  final bool fromHomePage;

  final String? videoSource;
  final bool? fromFlashDeal;
  final bool? fromRecommend;
  final productListingModel.Products productItem;
  //final ValueNotifier<int> currentChosenColor;
  final ValueNotifier<bool>? productIsFlashDeal;

  @override
  State<ProductListing3DSliderOptimized> createState() =>
      _ProductListing3DSliderOptimizedState();
}

class _ProductListing3DSliderOptimizedState
    extends State<ProductListing3DSliderOptimized> {
  late HomeBloc _homeBloc;
  final prefs = GetIt.I<PrefsRepository>();

  Future<void>? _initializeVideoFuture;
  String? imageUrl;
  List<String> productCategoryList = [];
  String productCategory = "";
  String? brandIcon;
  DateTime? getRedeemDateForProduct;
  bool isVerified = true;
  int? getRedeemSecondRemainingForProduct;
  bool isFlashDealEnded = false;
  DateTime? endDate;
  Duration _duration = const Duration();
  double price = 0;
  double offerPrice = 0;
  int decimalDigits = 1;
  double exchangeRate = 1;
  String symbol = "";
  String redeemPriceWithExchangeRate = "";
  String offerPriceWithExchangeRate = "";
  String priceWithExchangeRate = "";
  String flashDealPriceWithExchangeRate = "";

  @override
  void initState() {
    super.initState();
    getRedeemSecondRemainingForProduct = prefs
        .getRedeemSecondRemainingForProduct(
          widget.productItem.productId.toString(),
        );
    brandIcon = widget.productItem.brand?.icon?.filePath;
    getRedeemDateForProduct = prefs.getRedeemDateForProduct(
      widget.productItem.productId.toString(),
    );
    isVerified = (widget.productItem.brand?.isVerified ?? 0) > 0;
    productCategoryList.add(widget.productItem.name ?? '');
    productCategoryList.add(widget.productItem.categoriesTree ?? '');
    productCategory = productCategoryList.join(' | ');
    price = widget.productItem.price ?? 0;
    offerPrice = widget.productItem.offerPrice ?? 0;
    decimalDigits =
        GetIt.I<HomeBloc>()
            .state
            .getCurrencyForCountryModel
            ?.data
            ?.currency
            ?.decimalDigits ??
        1;
    symbol =
        GetIt.I<HomeBloc>()
            .state
            .getCurrencyForCountryModel
            ?.data
            ?.currency
            ?.symbol ??
        "";
    exchangeRate =
        GetIt.I<HomeBloc>()
            .state
            .getCurrencyForCountryModel
            ?.data
            ?.currency
            ?.exchangeRate ??
        1;
    priceWithExchangeRate = HelperFunctions.formatNumber(
      numberToFormate:
          ((HelperFunctions.truncateToDecimalPlaces(price, decimalDigits)) *
          exchangeRate),
    );
    offerPriceWithExchangeRate = HelperFunctions.formatNumber(
      numberToFormate:
          ((HelperFunctions.truncateToDecimalPlaces(
            offerPrice,
            decimalDigits,
          )) *
          exchangeRate),
    );
    flashDealPriceWithExchangeRate = HelperFunctions.formatNumber(
      numberToFormate:
          ((HelperFunctions.truncateToDecimalPlaces(
            widget.productItem.flashDealPrice ?? 0,
            decimalDigits,
          )) *
          exchangeRate),
    );
    redeemPriceWithExchangeRate = HelperFunctions.formatNumber(
      numberToFormate:
          ((HelperFunctions.truncateToDecimalPlaces(
            widget.productItem.redeemPrice ?? 0,
            decimalDigits,
          )) *
          exchangeRate),
    );
    endDate = widget.productItem.flashDealEndDateTime;
    // محاولة الحصول على الصورة من syncColorImages أولاً
    if (widget.productItem.syncColorImages?.isNotEmpty == true) {
      final firstColorImage = widget.productItem.syncColorImages!.first;
      if (firstColorImage.images?.isNotEmpty == true) {
        imageUrl = firstColorImage.images!.first.filePath;
      }
    }
    if (imageUrl == null && widget.productItem.images?.isNotEmpty == true) {
      final firstImage = widget.productItem.images!.first;
      imageUrl = firstImage.filePath;
    }
    _homeBloc = BlocProvider.of<HomeBloc>(context);
    if (widget.videoSource != null && widget.videoSource!.isNotEmpty) {
      videoProductInListingController[widget.productItem.slug ?? ""]?.dispose();
      videoProductInListingController.remove(widget.productItem.slug ?? "");
      videoProductInListingController.addAll({
        widget.productItem.slug ?? "": VideoPlayerController.networkUrl(
          Uri.parse(widget.videoSource!),
          videoPlayerOptions: VideoPlayerOptions(),
        )..setLooping(true),
      });
      _initializeVideoFuture =
          videoProductInListingController[widget.productItem.slug ?? ""]!
              .initialize()
              .then((_) {
                if (!mounted) return;
                setState(() {});
                videoProductInListingController[widget.productItem.slug ?? ""]!
                    .setVolume(0);
                videoProductInListingController[widget.productItem.slug ?? ""]!
                    .play();
              });

      videoProductInListingController[widget.productItem.slug ?? ""]!
          .addListener(() {
            if (!mounted) return;
            setState(() {});
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return Directionality(
      textDirection: TextDirection.ltr,
      child: _buildSimpleProductCard(),
    );
  }

  /// 🎯 بطاقة منتج بسيطة - أداء ممتاز
  Widget _buildSimpleProductCard() {
    return Container(
      height: 375.h,
      width: 200.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(15.r)),
        color: const Color(0xffF8F8F8),
        border: Border.all(color: Colors.white),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🖼️ صورة المنتج - بدون مسافات إضافية
          SizedBox(height: 250.h, width: 200.w, child: _buildSingleImage()),

          // 💰 معلومات المنتج
          Expanded(child: _buildProductInfo()),
        ],
      ),
    );
  }

  /// 🖼️ عرض صورة واحدة فقط (أول صورة) - مع الـ loading الأصلي
  Widget _buildSingleImage() {
    // الحصول على أول صورة متاحة

    return ValueListenableBuilder<bool>(
      valueListenable: widget.visibleRedeem,
      builder: (context, _visibleRedeem, _) {
        getRedeemDateForProduct = prefs.getRedeemDateForProduct(
          widget.productItem.productId.toString(),
        );
        getRedeemSecondRemainingForProduct = prefs
            .getRedeemSecondRemainingForProduct(
              widget.productItem.productId.toString(),
            );
        bool isRedeem =
            (getRedeemDateForProduct?.isAfter(
                      DateTime.now().add(const Duration(seconds: 1)),
                    ) ==
                    true &&
                widget.productItem.hasRedeemDiscount == true) ||
            (getRedeemSecondRemainingForProduct ?? 0) > 0;
        final bool hasVideo =
            (widget.videoSource != null && widget.videoSource!.isNotEmpty);

        return Container(
          width: 200.w,
          height: 250.h,
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15.r)),
            border: isRedeem
                ? Border.all(color: const Color(0xffFF6200))
                : null,
          ),
          child: hasVideo
              ? _buildVideoBox(isRedeem, imageUrl ?? "")
              : (imageUrl != null
                    ? ProductListingImageWidget(
                        width: 200.w,
                        imageUrl: imageUrl ?? "",
                        height: 250.h,
                        circleShape: false,
                        innerShadowYOffset: 3,
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.image,
                          size: 50.h,
                          color: Colors.grey[400],
                        ),
                      )),
        );
      },
    );
  }

  Widget _buildVideoBox(bool isRedeem, String imageUrl) {
    if (videoProductInListingController[widget.productItem.slug ?? ""] ==
        null) {
      return Container(color: Colors.black12);
    }

    return SizedBox(
      height: 250.h,
      child: FutureBuilder<void>(
        future: _initializeVideoFuture,
        builder: (context, snapshot) {
          final bool initialized =
              videoProductInListingController[widget.productItem.slug ?? ""]!
                  .value
                  .isInitialized;
          final bool buffering =
              videoProductInListingController[widget.productItem.slug ?? ""]!
                  .value
                  .isBuffering;
          final bool showLoading = !initialized;

          Widget videoChild;
          if (initialized) {
            videoChild = FittedBox(
              fit: BoxFit.cover,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.r),
                ),
                width: 200.w,
                height: 250.h,
                child: VideoPlayer(
                  videoProductInListingController[widget.productItem.slug ??
                      ""]!,
                ),
              ),
            );
          } else {
            videoChild = const SizedBox.shrink();
          }

          return Stack(
            alignment: Alignment.center,
            children: [
              videoChild,
              if (showLoading)
                ProductListingImageWidget(
                  radius: 15.r,
                  borderColor: isRedeem ? const Color(0xffFF6200) : null,
                  orginalHeight: 250.h,
                  orginalWidth: 200.w,
                  width: 200.w,
                  imageUrl: imageUrl,
                  height: 250.h,
                  circleShape: false,
                  innerShadowYOffset: 3,
                ),
              buffering ? TrydosLoader(size: 20.h) : const SizedBox.shrink(),
            ],
          );
        },
      ),
    );
  }

  /// 💰 معلومات المنتج المبسطة
  Widget _buildProductInfo() {
    return Column(
      children: [
        // معلومات المنتج
        SizedBox(
          width: 200.w,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0.r),
            child: Column(
              crossAxisAlignment: LanguageService.languageCode == "ar"
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                SizedBox(height: 5.h),
                // Brand Icon
                _buildBrandIcon(),
                SizedBox(height: 5.h),

                // Product Name and Category
                _buildProductCategoryRow(),
                SizedBox(height: 5.h),

                Directionality(
                  textDirection: LanguageService.languageCode == "ar"
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RotatingTextWidget(
                        texts: widget.productItem.labelNames ?? [],
                        textStyle: textTheme.titleMedium?.bq.copyWith(
                          fontSize: 9.sp,
                          color: const Color(0xff388CFF),
                          height: 0,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      const Spacer(),
                      SizedBox(
                        child: ValueListenableBuilder<bool>(
                          valueListenable: widget.visibleRedeem,
                          builder: (context, _visibleRedeem, _) {
                            getRedeemDateForProduct = prefs
                                .getRedeemDateForProduct(
                                  widget.productItem.productId.toString(),
                                );
                            getRedeemSecondRemainingForProduct = prefs
                                .getRedeemSecondRemainingForProduct(
                                  widget.productItem.productId.toString(),
                                );
                            return (getRedeemDateForProduct?.isAfter(
                                              DateTime.now().add(
                                                const Duration(seconds: 1),
                                              ),
                                            ) ==
                                            true &&
                                        widget.productItem.hasRedeemDiscount ==
                                            true) ||
                                    (getRedeemSecondRemainingForProduct ?? 0) >
                                        0
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SvgPicture.asset(
                                        AppAssets.redeemClockSvg,
                                        // ignore: deprecated_member_use
                                        color: const Color(0xffFF6200),
                                      ),
                                      const SizedBox(width: 2),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SecondsCountdown(
                                            productId: widget
                                                .productItem
                                                .productId
                                                .toString(),
                                            finishRedeem: widget.finishRedeem,
                                            visibleRedeem: widget.visibleRedeem,
                                            endTime:
                                                getRedeemDateForProduct ??
                                                DateTime.now(),
                                          ),
                                          Text(
                                            " ${LocaleKeys.seconds.tr()} ",
                                            style: context
                                                .textTheme
                                                .bodyMedium
                                                ?.rq
                                                .copyWith(
                                                  fontSize: 9.sp,
                                                  color: const Color(
                                                    0xffFF6200,
                                                  ),
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                : const SizedBox.shrink();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        _buildPriceSection(),
      ],
    );
  }

  /// 🏷️ Brand Icon
  Widget _buildBrandIcon() {
    if (brandIcon == null) return const SizedBox.shrink();

    return SizedBox(
      width: isVerified ? 55.w : 35.w,
      height: 15.h,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: LanguageService.languageCode == "ar"
            ? [
                isVerified
                    ? SvgPicture.asset(AppAssets.productVerifySvg, height: 10.h)
                    : const SizedBox.shrink(),
                SizedBox(width: isVerified ? 5.w : 0),
                MyCachedNetworkImage(
                  imageUrl: brandIcon ?? "",
                  height: 15.h,
                  imageFit: BoxFit.fill,
                  width: 30.w,
                ),
              ]
            : [
                MyCachedNetworkImage(
                  imageUrl: brandIcon ?? "",
                  height: 15.h,
                  imageFit: BoxFit.fill,
                  width: 30.w,
                ),
                SizedBox(width: isVerified ? 5.w : 0),
                isVerified
                    ? SvgPicture.asset(AppAssets.productVerifySvg, height: 10.h)
                    : const SizedBox.shrink(),
              ],
      ),
    );
  }

  /// 📝 Product Name Row
  Widget _buildProductCategoryRow() {
    return Row(
      mainAxisAlignment: LanguageService.languageCode == "ar"
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        // Category Icon
        //  _buildCategoryIcon(),

        // Product Name
        Flexible(
          child: MyTextWidget(
            productCategory,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleMedium?.rq.copyWith(
              color: const Color(0xff505050),
              fontSize: 10.sp,
            ),
          ),
        ),
      ],
    );
  }

  // _buildCategoryIcon() was removed because it's unused to avoid linter warnings.

  /// 💰 Price Section - FIXED: أبعاد أصلية
  Widget _buildPriceSection() {
    return SizedBox(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: Directionality(
          textDirection: LanguageService.languageCode == "ar"
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Price Row
              ValueListenableBuilder<bool>(
                valueListenable: widget.visibleFlashDeal,
                builder: (context, _visibleFlashDeal, _) {
                  if (endDate == null) {
                    isFlashDealEnded = true;
                  } else {
                    _duration = endDate!.difference(DateTime.now());
                    if (_duration.isNegative || _duration.inSeconds < 1) {
                      isFlashDealEnded = true;
                    }
                  }

                  return ValueListenableBuilder<bool>(
                    valueListenable: widget.visibleRedeem,
                    builder: (context, _visibleRedeem, _) {
                      getRedeemDateForProduct = prefs.getRedeemDateForProduct(
                        widget.productItem.productId.toString(),
                      );

                      getRedeemSecondRemainingForProduct = prefs
                          .getRedeemSecondRemainingForProduct(
                            widget.productItem.productId.toString(),
                          );
                      bool isRedeem =
                          (getRedeemDateForProduct?.isAfter(
                                    DateTime.now().add(
                                      const Duration(seconds: 1),
                                    ),
                                  ) ==
                                  true &&
                              widget.productItem.hasRedeemDiscount == true) ||
                          (getRedeemSecondRemainingForProduct ?? 0) > 0;

                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          price == offerPrice
                              ? const SizedBox.shrink()
                              : Container(
                                  constraints: const BoxConstraints(
                                    maxWidth: 50,
                                  ),
                                  child: Text(
                                    priceWithExchangeRate,

                                    maxLines: 1,

                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.titleMedium?.lq.copyWith(
                                      fontSize: 12.sp,
                                      color: const Color(0xff3c3c3c),
                                      decoration: TextDecoration.lineThrough,
                                      height: 0,
                                    ),
                                  ),
                                ),
                          const SizedBox(width: 2),

                          Text(
                            (isFlashDealEnded ||
                                    (widget.productItem.flashDealPrice ?? 0) ==
                                        0)
                                ? offerPriceWithExchangeRate
                                : flashDealPriceWithExchangeRate,

                            maxLines: 1,

                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleMedium?.mq.copyWith(
                              fontSize: 11.sp,
                              decorationColor: const Color(0xffFF6200),
                              decoration: isRedeem
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: const Color(0xff3c3c3c),
                              height: 0,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            symbol,
                            maxLines: 1,

                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleMedium?.lq.copyWith(
                              fontSize: 10.sp,
                              decorationColor: const Color(0xff1D1D1D),
                              decoration: isRedeem
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: const Color(0xff3c3c3c),
                              height: 1.3,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              // Buy Button
              _buildCompactBuyButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// 🛒 Compact Buy Button - FIXED: أبعاد أصلية
  Widget _buildCompactBuyButton() {
    return InkWell(
      onTap: () {
        Future.delayed(
          const Duration(milliseconds: 50),
          () => _homeBloc.add(
            AddCurrentSelectedColorEvent(
              currentSelectedColor: 0,
              productSlug: widget.productItem.slug.toString(),
            ),
          ),
        );
        _homeBloc.add(
          const ChangeStatusOFGetProductsDetailsToSuccessEvent(
            isStatusInitaial: true,
          ),
        );
        widget.productIsFlashDeal?.value = widget.fromFlashDeal ?? false;
        widget.productIsRecommend?.value = widget.fromRecommend ?? false;

        Future.delayed(
          const Duration(milliseconds: 600),
          () => widget.tapIndexToAddProductToCart.value = widget.itemIndex,
        );
      },
      child: ValueListenableBuilder<bool>(
        valueListenable: widget.visibleRedeem,
        builder: (context, _visibleRedeem, _) {
          getRedeemDateForProduct = prefs.getRedeemDateForProduct(
            widget.productItem.productId.toString(),
          );
          getRedeemSecondRemainingForProduct = prefs
              .getRedeemSecondRemainingForProduct(
                widget.productItem.productId.toString(),
              );
          bool isRedeem =
              (getRedeemDateForProduct?.isAfter(
                        DateTime.now().add(const Duration(seconds: 1)),
                      ) ==
                      true &&
                  widget.productItem.hasRedeemDiscount == true) ||
              (getRedeemSecondRemainingForProduct ?? 0) > 0;

          return Container(
            height: 20.h, // الارتفاع الأصلي
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: const Color(0x1D1D1D),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  " ${LocaleKeys.buy.tr()} ",
                  style: textTheme.titleSmall?.rq.copyWith(
                    fontSize: 9.sp,
                    color: isRedeem
                        ? const Color(0xffFF6200)
                        : const Color(0xff414141),
                    height: 0,
                  ),
                ),
                isRedeem
                    ? Container(
                        constraints: const BoxConstraints(maxWidth: 25),
                        child: Text(
                          redeemPriceWithExchangeRate,

                          //      .toStringAsFixed(widget.decimalPoint),
                          style: textTheme.headlineMedium?.bq.copyWith(
                            fontSize: 9.sp,
                            color: const Color(0xffFF6200),
                            height: 1.2,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                const SizedBox(width: 2),
                isRedeem
                    ? Text(
                        symbol,
                        style: TextStyle(
                          fontSize: 9.sp,
                          color: const Color(0xffFF6200),
                          height: 1.2,
                        ),
                      )
                    : const SizedBox.shrink(),
                const SizedBox(width: 3),
                SvgPicture.asset(AppAssets.bagSvg, height: 15.h),
              ],
            ),
          );
        },
      ),
    );
  }
}
