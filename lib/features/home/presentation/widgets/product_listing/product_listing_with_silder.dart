import 'package:flutter/foundation.dart' hide Category;
import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart' as trans;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:sliding_up_panel/sliding_up_panel.dart';
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
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_image_widget.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/static_circle_carousel.dart';
import 'package:trydos/features/home/presentation/widgets/rotating_text_widget.dart';
import 'package:trydos/features/home/presentation/widgets/second_counter_for_redeem.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/main.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as productListingModel;
import 'package:video_player/video_player.dart';
import '../../../../../service/language_service.dart';
import '../../../../app/my_text_widget.dart';

/// 🚀 نسخة مبسطة جداً من ProductListing3DSlider - أداء فائق ⚡
class ProductListingWithSlider extends StatefulWidget {
  const ProductListingWithSlider({
    super.key,
    // required this.setThisEnabled,
    // required this.slidingModeItem,
    required this.itemIndex,
    this.imageSource,
    required this.tapIndexToAddProductToCart,
    required this.visibleRedeem,
    required this.productItem,
    required this.visibleFlashDeal,
    this.fromFlashDeal,
    this.videoSource,
    this.fromHomePage = false,
    required this.finishRedeem,
    this.tapIndexToShowColorImages,
    this.showShadowForColorImages,
    this.colorImagesPanelController,
    // جديد: افتراضي false
    //required this.displayImageColors,
    //  required this.currentChosenColor,
  });

  // final Tuple2<int, int> slidingModeItem;
  // final void Function(int, int) setThisEnabled;
  final ValueNotifier<int> tapIndexToAddProductToCart;
  final ValueNotifier<bool> finishRedeem;
  final ValueNotifier<bool> visibleFlashDeal;
  final int itemIndex;
  final ValueNotifier<bool>? showShadowForColorImages;
  final ValueNotifier<int>? tapIndexToShowColorImages;
  final PanelController? colorImagesPanelController;
  //final bool displayImageColors;
  final ValueNotifier<bool> visibleRedeem;
  final bool fromHomePage;
  final String? imageSource;
  final bool? fromFlashDeal;
  final String? videoSource;
  final productListingModel.Products productItem;

  @override
  State<ProductListingWithSlider> createState() =>
      _ProductListingWithSliderState();
}

class _ProductListingWithSliderState extends State<ProductListingWithSlider> {
  late HomeBloc _homeBloc;
  Timer? disDebounce;

  Future<void>? _initializeVideoFuture;

  @override
  void initState() {
    super.initState();
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
    _homeBloc = BlocProvider.of<HomeBloc>(context);
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

  /* @override
  void dispose() {
    if (disDebounce?.isActive ?? false) {
      disDebounce!.cancel();
    }
    disDebounce = Timer(const Duration(milliseconds: 2000), () {
      for (var i = 0;
          i < videoProductInListingController.keys.toList().length;
          i++) {
        if (!productSlugToSaveVideoTimer
            .contains(videoProductInListingController.keys.toList()[i])) {
          videoProductInListingController[i]?.pause();
          videoProductInListingController[i]?.dispose();
          videoProductInListingController
              .remove(videoProductInListingController.keys.toList()[i]);
        }
      }
    });

    super.dispose();
  }*/

  /// 🎯 بطاقة منتج بسيطة - أداء ممتاز
  Widget _buildSimpleProductCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        color: const Color(0xffF8F8F8),
        border: Border.all(color: Colors.white),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🖼️ صورة المنتج - بدون مسافات إضافية
          SizedBox(
            height: 290.h,
            width: 200.w,
            child: _buildSingleImage(
              (GetIt.I<PrefsRepository>()
                              .getRedeemDateForProduct(
                                widget.productItem.productId.toString(),
                              )
                              ?.isAfter(
                                DateTime.now().add(const Duration(seconds: 1)),
                              ) ==
                          true &&
                      widget.productItem.hasRedeemDiscount == true) ||
                  (GetIt.I<PrefsRepository>()
                              .getRedeemSecondRemainingForProduct(
                                widget.productItem.productId.toString(),
                              ) ??
                          0) >
                      0,
            ),
          ),

          // 💰 معلومات المنتج
          Expanded(child: _buildProductInfo()),
        ],
      ),
    );
  }

  /// 🎯 بناء مبسط للصورة والمعلومات
  /*Widget _buildSimpleProductCardOld() {
    return Container(
      height: widget.fromHomePage ? 350 : 400, // الأبعاد الأصلية
      width: 200,
      child: Column(
        children: [
          // 🖼️ صورة واحدة بسيطة
          Expanded(
            flex: 3,
            child: _buildSingleImage(),
          ),

          // 💰 معلومات المنتج
          Expanded(
            flex: 1,
            child: _buildProductInfo(),
          ),
        ],
      ),
    );
  }*/

  /// 🖼️ عرض صورة واحدة فقط (أول صورة) - مع الـ loading الأصلي
  Widget _buildSingleImage(bool isRedeem) {
    // الحصول على أول صورة متاحة
    String? imageUrl;
    double imageHeight = 290.h;
    double imageWidth = 200.w;

    // محاولة الحصول على الصورة من syncColorImages أولاً
    if (widget.productItem.syncColorImages?.isNotEmpty == true) {
      final firstColorImage = widget.productItem.syncColorImages!.first;
      if (firstColorImage.images?.isNotEmpty == true) {
        imageUrl = firstColorImage.images!.first.filePath;
        imageHeight =
            double.tryParse(
              firstColorImage.images!.first.originalHeight ?? '290',
            )?.h ??
            290.h;
        imageWidth =
            double.tryParse(
              firstColorImage.images!.first.originalWidth ?? '200',
            )?.w ??
            200.w;
      }
    }

    // إذا لم توجد، استخدم أول صورة من images العادية
    if (imageUrl == null && widget.productItem.images?.isNotEmpty == true) {
      final firstImage = widget.productItem.images!.first;
      imageUrl = firstImage.filePath;
      imageHeight =
          double.tryParse(firstImage.originalHeight ?? '290')?.h ?? 290.h;
      imageWidth =
          double.tryParse(firstImage.originalWidth ?? '200')?.w ?? 200.w;
    }

    return ValueListenableBuilder<bool>(
      valueListenable: widget.visibleRedeem,
      builder: (context, _visibleRedeem, _) {
        bool isRedeem =
            (GetIt.I<PrefsRepository>()
                        .getRedeemDateForProduct(
                          widget.productItem.productId.toString(),
                        )
                        ?.isAfter(
                          DateTime.now().add(const Duration(seconds: 1)),
                        ) ==
                    true &&
                widget.productItem.hasRedeemDiscount == true) ||
            (GetIt.I<PrefsRepository>().getRedeemSecondRemainingForProduct(
                      widget.productItem.productId.toString(),
                    ) ??
                    0) >
                0;
        final bool hasVideo =
            (widget.videoSource != null && widget.videoSource!.isNotEmpty);

        return SizedBox(
          height: 290.h,
          child: (imageUrl != null
              ? Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    hasVideo
                        ? _buildVideoBox(isRedeem, imageUrl)
                        : ProductListingImageWidget(
                            borderColor: isRedeem
                                ? const Color(0xffFF6200)
                                : null,
                            orginalHeight: imageHeight,
                            orginalWidth: imageWidth,
                            width: 200.w,
                            imageUrl: imageUrl,
                            height: 290.h,
                            circleShape: false,
                            innerShadowYOffset: 3,
                          ),
                    Positioned(
                      bottom: 0,
                      child: StaticCircleCarousel(
                        itemIndex: widget.itemIndex,
                        tapIndexToShowColorImages:
                            widget.tapIndexToShowColorImages,
                        colorImagesPanelController:
                            widget.colorImagesPanelController,
                        showShadowForColorImages:
                            widget.showShadowForColorImages,
                        imageUrls:
                            widget.productItem.syncColorImages
                                ?.map((e) => e.images?.first.filePath ?? "")
                                .toList() ??
                            [],
                        colors:
                            widget.productItem.colors
                                ?.map((e) => e.color ?? "")
                                .toList() ??
                            [],
                      ),
                    ),
                  ],
                )
              : Container(
                  color: Colors.grey[200],
                  child: Icon(Icons.image, size: 50.h, color: Colors.grey[400]),
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
      height: 290.h,
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.r),
                child: SizedBox(
                  width: 190.w,
                  height: 290.h,
                  child: VideoPlayer(
                    videoProductInListingController[widget.productItem.slug ??
                        ""]!,
                  ),
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(15.r),
                  child: ProductListingImageWidget(
                    borderColor: isRedeem ? const Color(0xffFF6200) : null,
                    orginalHeight: 200.h,
                    orginalWidth: 200.w,
                    width: 200.w,
                    imageUrl: imageUrl,
                    height: 290.h,
                    circleShape: false,
                    innerShadowYOffset: 3.h,
                  ),
                ),
              buffering
                  ? TrydosLoader(size: 20.h)
                  : /* videoProductInListingController[
                                widget.productItem.slug ?? ""]!
                            .value
                            .isPlaying
                        ? InkWell(
                            onTap: () {
                              videoProductInListingController[
                                      widget.productItem.slug ?? ""]!
                                  .pause();
                            },
                            child: SizedBox(
                              width: 60,
                              height: 60,
                            ),
                          )
                        : Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(1, 1, 0, 0.2),
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(color: Colors.white)),
                            child: InkWell(
                              onTap: () {
                                videoProductInListingController
                                    .forEach((key, value) => value.pause());
                                videoProductInListingController[
                                        widget.productItem.slug ?? ""]!
                                    .play();
                              },
                              child: Icon(Icons.play_arrow,
                                  size: 30, color: Colors.white),
                            ))*/ const SizedBox.shrink(),
            ],
          );
        },
      ),
    );
  }

  /// 💰 معلومات المنتج المبسطة
  Widget _buildProductInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // معلومات المنتج
        SizedBox(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Column(
              crossAxisAlignment: LanguageService.languageCode == "ar"
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // Brand Icon
                SizedBox(height: 5.h),
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
                      const Spacer(),

                      SizedBox(
                        child: ValueListenableBuilder<bool>(
                          valueListenable: widget.visibleRedeem,
                          builder: (context, _visibleRedeem, _) {
                            return (GetIt.I<PrefsRepository>()
                                                .getRedeemDateForProduct(
                                                  widget.productItem.productId
                                                      .toString(),
                                                )
                                                ?.isAfter(
                                                  DateTime.now().add(
                                                    const Duration(seconds: 1),
                                                  ),
                                                ) ==
                                            true &&
                                        widget.productItem.hasRedeemDiscount ==
                                            true) ||
                                    (GetIt.I<PrefsRepository>()
                                                .getRedeemSecondRemainingForProduct(
                                                  widget.productItem.productId
                                                      .toString(),
                                                ) ??
                                            0) >
                                        0
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SvgPicture.asset(
                                        AppAssets.redeemClockSvg,
                                        // ignore: deprecated_member_use
                                        color: const Color(0xffFF6200),
                                      ),
                                      SizedBox(width: 2.w),
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
                                                GetIt.I<PrefsRepository>()
                                                    .getRedeemDateForProduct(
                                                      widget
                                                          .productItem
                                                          .productId
                                                          .toString(),
                                                    ) ??
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
        /*    _buildRedeemSection(),
        const SizedBox(height: 2),
        _buildLabelSection(),*/
        //    const SizedBox(height: 5),
        // Price Section
        _buildPriceSection(),
      ],
    );
  }

  /*Widget _buildRedeemSection() {
    return ValueListenableBuilder<bool>(
        valueListenable: widget.visibleRedeem,
        builder: (context, _visibleRedeem, _) {
          return GetIt.I<PrefsRepository>()
                          .getRedeemDateForProduct(
                              widget.productItem.productId.toString())
                          ?.isAfter(DateTime.now().add(Duration(seconds: 1))) ==
                      true &&
                  widget.productItem.hasRedeemDiscount == true
              ? Container(
                  margin: EdgeInsets.only(left: 1, right: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.deepOrangeAccent),
                    color: Color(0xffFDFDEF),
                  ),
                  height: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 3,
                      ),
                      SvgPicture.asset(AppAssets.alarmClockSvg),
                      Text(LocaleKeys.luck.tr(),
                          style: context.textTheme.bodyMedium?.ba.copyWith(
                            fontSize: 11,
                            color: const Color.fromARGB(255, 250, 71, 16),
                          )),
                      Text(" ${LocaleKeys.add_to_bag_within.tr()} ",
                          style: context.textTheme.bodyMedium?.ra.copyWith(
                            fontSize: 10,
                            color: const Color.fromARGB(255, 250, 71, 16),
                          )),
                      SecondsCountdown(
                        finishRedeem: widget.finishRedeem,
                        visibleRedeem: widget.visibleRedeem,
                        endTime: GetIt.I<PrefsRepository>()
                                .getRedeemDateForProduct(
                                    widget.productItem.productId.toString()) ??
                            DateTime.now(),
                      ),
                      Text(" ${LocaleKeys.seconds.tr()} ",
                          style: context.textTheme.bodyMedium?.ra.copyWith(
                            fontSize: 10,
                            color: const Color.fromARGB(255, 230, 67, 18),
                          )),
                    ].reversed.toList(),
                  ),
                )
              : SizedBox.shrink();
        });
  }*/

  /*Widget _buildLabelSection() {
    return ValueListenableBuilder<bool>(
        valueListenable: widget.visibleRedeem,
        builder: (context, _visibleRedeem, _) {
          return GetIt.I<PrefsRepository>()
                          .getRedeemDateForProduct(
                              widget.productItem.productId.toString())
                          ?.isAfter(DateTime.now().add(Duration(seconds: 1))) !=
                      true &&
                  widget.productItem.hasRedeemDiscount != true
              ? Container(
                  margin: EdgeInsets.only(left: 1, right: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.deepOrangeAccent),
                    color: Color(0xffFDFDEF),
                  ),
                  height: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 3,
                      ),
                      SvgPicture.asset(AppAssets.alarmClockSvg),
                      Text(LocaleKeys.luck.tr(),
                          style: context.textTheme.bodyMedium?.ba.copyWith(
                            fontSize: 11,
                            color: const Color.fromARGB(255, 250, 71, 16),
                          )),
                      Text(" ${LocaleKeys.add_to_bag_within.tr()} ",
                          style: context.textTheme.bodyMedium?.ra.copyWith(
                            fontSize: 10,
                            color: const Color.fromARGB(255, 250, 71, 16),
                          )),
                      SecondsCountdown(
                        finishRedeem: widget.finishRedeem,
                        visibleRedeem: widget.visibleRedeem,
                        endTime: GetIt.I<PrefsRepository>()
                                .getRedeemDateForProduct(
                                    widget.productItem.productId.toString()) ??
                            DateTime.now(),
                      ),
                      Text(" ${LocaleKeys.seconds.tr()} ",
                          style: context.textTheme.bodyMedium?.ra.copyWith(
                            fontSize: 10,
                            color: const Color.fromARGB(255, 230, 67, 18),
                          )),
                    ].reversed.toList(),
                  ),
                )
              : SizedBox.shrink();
        });
  }*/

  /// 🏷️ Brand Icon
  Widget _buildBrandIcon() {
    final brandIcon = widget.productItem.brand?.icon?.filePath;
    bool isVerified = (widget.productItem.brand?.isVerified ?? 0) > 0;
    if (brandIcon == null) return const SizedBox.shrink();

    return SizedBox(
      width: isVerified ? 56.w : 31.w,
      height: 16.h,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: LanguageService.languageCode == "ar"
            ? [
                isVerified
                    ? SvgPicture.asset(AppAssets.productVerifySvg, height: 8.h)
                    : const SizedBox.shrink(),
                SizedBox(width: isVerified ? 5.w : 0),
                MyCachedNetworkImage(
                  imageUrl: brandIcon,
                  height: 15.h,
                  imageFit: BoxFit.contain,
                  width: 30.w,
                ),
              ]
            : [
                MyCachedNetworkImage(
                  imageUrl: brandIcon,
                  height: 15.h,
                  imageFit: BoxFit.contain,
                  width: 30.w,
                ),
                SizedBox(width: isVerified ? 5.w : 0),
                isVerified
                    ? SvgPicture.asset(AppAssets.productVerifySvg, height: 8.h)
                    : const SizedBox.shrink(),
              ],
      ),
    );
  }

  /// 📝 Product Name Row
  Widget _buildProductCategoryRow() {
    List<String> productCategory = [];
    productCategory.add(widget.productItem.name ?? '');
    productCategory.add(widget.productItem.categoriesTree ?? '');
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
            productCategory.join(' | '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: const Color(0xff3c3c3c)),
          ),
        ),
      ],
    );
  }

  /// 🏷️ Category Icon
  /* Widget _buildCategoryIcon() {
    final categoryIcon = widget.productItem.category?.flatPhotoPath?.filePath;
    if (categoryIcon == null) return const SizedBox.shrink();

    return SizedBox(
      height: 10,
      child: Transform.translate(
        offset: const Offset(0, 1),
        child: SvgNetworkWidget(
          svgUrl: categoryIcon,
          height: 10,
        ),
      ),
    );
  }*/

  /// 💰 Price Section - FIXED: أبعاد أصلية
  Widget _buildPriceSection() {
    return SizedBox(
      width: 200.w,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (previous, current) =>
              previous.getCurrencyForCountryModel !=
              current.getCurrencyForCountryModel,
          builder: (context, state) {
            final price = HelperFunctions.truncateToDecimalPlaces(
              widget.productItem.price ?? 0,
              state.getCurrencyForCountryModel!.data!.currency!.decimalDigits!,
            );
            final offerPrice = HelperFunctions.truncateToDecimalPlaces(
              widget.productItem.offerPrice ?? 0,
              state.getCurrencyForCountryModel!.data!.currency!.decimalDigits!,
            );
            final exchangeRate =
                state
                    .getCurrencyForCountryModel
                    ?.data
                    ?.currency
                    ?.exchangeRate ??
                1;

            return Directionality(
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
                      bool isFlashDealEnded = false;
                      DateTime endDate;
                      Duration _duration = const Duration();
                      final now = DateTime.now();
                      try {
                        endDate = DateFormat(
                          'MM/dd/yyyy',
                          'en_US',
                        ).parse(widget.productItem.flashDealEndDate ?? "");
                        endDate = endDate.add(const Duration(days: 1));
                      } catch (e) {
                        endDate = DateTime.now();
                        if (kDebugMode) print('Error parsing date: $e');
                      }
                      _duration = endDate.difference(now);
                      if (_duration.isNegative || _duration.inSeconds < 1) {
                        isFlashDealEnded = true;
                      }

                      return ValueListenableBuilder<bool>(
                        valueListenable: widget.visibleRedeem,
                        builder: (context, _visibleRedeem, _) {
                          bool isRedeem =
                              (GetIt.I<PrefsRepository>()
                                          .getRedeemDateForProduct(
                                            widget.productItem.productId
                                                .toString(),
                                          )
                                          ?.isAfter(
                                            DateTime.now().add(
                                              const Duration(seconds: 1),
                                            ),
                                          ) ==
                                      true &&
                                  widget.productItem.hasRedeemDiscount ==
                                      true) ||
                              (GetIt.I<PrefsRepository>()
                                          .getRedeemSecondRemainingForProduct(
                                            widget.productItem.productId
                                                .toString(),
                                          ) ??
                                      0) >
                                  0;

                          return Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                price == offerPrice
                                    ? const SizedBox.shrink()
                                    : Container(
                                        constraints: BoxConstraints(
                                          maxWidth: 45.w,
                                        ),
                                        child: AutoSizeText(
                                          HelperFunctions.formatNumber(
                                            numberToFormate:
                                                (price * exchangeRate),
                                          ),
                                          /* .toStringAsFixed(state.startingSetting
                                                    ?.decimalPointSetting ??
                                                2)
                                            .toString()*/
                                          minFontSize: 4,
                                          style: textTheme.titleMedium?.lq
                                              .copyWith(
                                                fontSize: 12.sp,
                                                color: const Color(0xff3c3c3c),
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                height: 0,
                                              ),
                                        ),
                                      ),
                                const SizedBox(width: 2),
                                Container(
                                  constraints: BoxConstraints(maxWidth: 45.w),
                                  child: AutoSizeText(
                                    HelperFunctions.formatNumber(
                                      numberToFormate:
                                          (((isFlashDealEnded ||
                                                  (widget
                                                              .productItem
                                                              .flashDealPrice ??
                                                          0) ==
                                                      0)
                                              ? offerPrice
                                              : widget
                                                        .productItem
                                                        .flashDealPrice ??
                                                    0) *
                                          exchangeRate),
                                    ),
                                    /*.toStringAsFixed(state.startingSetting
                                                    ?.decimalPointSetting ??
                                                2)
                                            .toString()*/
                                    minFontSize: 4,
                                    style: textTheme.titleMedium?.mq.copyWith(
                                      fontSize: 12.sp,
                                      decorationColor: const Color(0xffFF6200),
                                      decoration: isRedeem
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: const Color(0xff3c3c3c),
                                      height: 0,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 2),
                                MyTextWidget(
                                  state.getCurrencyForCountryModel == null
                                      ? ""
                                      : state
                                                .getCurrencyForCountryModel!
                                                .data!
                                                .currency!
                                                .symbol ??
                                            "",
                                  style: textTheme.titleMedium?.lq.copyWith(
                                    fontSize: 10.sp,
                                    color: const Color(0xff1D1D1D),
                                    height: 0,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                  // Buy Button
                  _buildCompactBuyButton(state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// 🛒 Compact Buy Button - FIXED: أبعاد أصلية
  Widget _buildCompactBuyButton(HomeState state) {
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

        Future.delayed(
          const Duration(milliseconds: 600),
          () => widget.tapIndexToAddProductToCart.value = widget.itemIndex,
        );
      },
      child: ValueListenableBuilder<bool>(
        valueListenable: widget.visibleRedeem,
        builder: (context, _visibleRedeem, _) {
          final exchangeRate =
              state.getCurrencyForCountryModel?.data?.currency?.exchangeRate ??
              1;
          double redeemPrice = HelperFunctions.truncateToDecimalPlaces(
            widget.productItem.redeemPrice ?? 0,
            state.getCurrencyForCountryModel!.data!.currency!.decimalDigits!,
          );
          bool isRedeem =
              (GetIt.I<PrefsRepository>()
                          .getRedeemDateForProduct(
                            widget.productItem.productId.toString(),
                          )
                          ?.isAfter(
                            DateTime.now().add(const Duration(seconds: 1)),
                          ) ==
                      true &&
                  widget.productItem.hasRedeemDiscount == true) ||
              (GetIt.I<PrefsRepository>().getRedeemSecondRemainingForProduct(
                        widget.productItem.productId.toString(),
                      ) ??
                      0) >
                  0;

          return Container(
            height: 25.h, // الارتفاع الأصلي
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: const Color(0x1D1D1D),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                MyTextWidget(
                  " ${LocaleKeys.buy.tr()} ",
                  style: textTheme.titleSmall?.lq.copyWith(
                    fontSize: 12.sp,
                    color: isRedeem
                        ? const Color(0xffFF6200)
                        : const Color(0xff414141),
                    height: 0,
                  ),
                ),
                isRedeem
                    ? Container(
                        constraints: BoxConstraints(maxWidth: 25.w),
                        child: AutoSizeText(
                          HelperFunctions.formatNumber(
                            numberToFormate: redeemPrice * exchangeRate,
                          ),
                          maxLines: 1,
                          minFontSize: 2,
                          //      .toStringAsFixed(widget.decimalPoint),
                          style: textTheme.headlineMedium?.bq.copyWith(
                            fontSize: 10.sp,
                            color: const Color(0xffFF6200),
                            height: 1.2,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                const SizedBox(width: 2),
                isRedeem
                    ? MyTextWidget(
                        state.getCurrencyForCountryModel == null
                            ? ""
                            : state
                                      .getCurrencyForCountryModel!
                                      .data!
                                      .currency!
                                      .symbol ??
                                  "",
                        style: TextStyle(
                          fontSize: 8.sp,
                          color: const Color(0xffFF6200),
                          height: 1.2,
                        ),
                      )
                    : const SizedBox.shrink(),
                SizedBox(width: 3.w),
                SvgPicture.asset(AppAssets.bagSvg, height: 15.h),
              ],
            ),
          );
        },
      ),
    );
  }
}
