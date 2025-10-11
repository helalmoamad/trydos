import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart' as trans;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/svg_network_widget.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
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

  Future<void>? _initializeVideoFuture;

  @override
  void initState() {
    super.initState();
    _homeBloc = BlocProvider.of<HomeBloc>(context);
    if (widget.videoSource != null && widget.videoSource!.isNotEmpty) {
      videoProductInListingController[widget.productItem.slug ?? ""]?.dispose();
      videoProductInListingController.remove(widget.productItem.slug ?? "");
      videoProductInListingController.addAll({
        widget.productItem.slug ?? "": VideoPlayerController.networkUrl(
          Uri.parse(widget.videoSource!),
          videoPlayerOptions: VideoPlayerOptions(),
        )..setLooping(true)
      });
      _initializeVideoFuture =
          videoProductInListingController[widget.productItem.slug ?? ""]!
              .initialize()
              .then((_) {
        if (!mounted) return;
        setState(() {});
        videoProductInListingController[widget.productItem.slug ?? ""]!
            .setVolume(0);
        videoProductInListingController[widget.productItem.slug ?? ""]!.play();
      });

      videoProductInListingController[widget.productItem.slug ?? ""]!
          .addListener(() {
        if (!mounted) return;
        setState(() {});
      });
    }
  }

  /* @override
  void dispose() {
    if (debounce?.isActive ?? false) {
      debounce!.cancel();
    }
    debounce = Timer(Duration(milliseconds: 2000), () {
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
    return SizedBox(
      height: 350,
      width: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🖼️ صورة المنتج - بدون مسافات إضافية
          SizedBox(
            height: 230,
            width: 200,
            child: _buildSingleImage((GetIt.I<PrefsRepository>()
                            .getRedeemDateForProduct(
                                widget.productItem.productId.toString())
                            ?.isAfter(DateTime.now()
                                .add(const Duration(seconds: 1))) ==
                        true &&
                    widget.productItem.hasRedeemDiscount == true) ||
                (GetIt.I<PrefsRepository>().getRedeemSecondRemainingForProduct(
                            widget.productItem.productId.toString()) ??
                        0) >
                    0),
          ),

          // 💰 معلومات المنتج
          Expanded(
            child: _buildProductInfo(),
          ),
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
    double imageHeight = 250;
    double imageWidth = 200;

    // محاولة الحصول على الصورة من syncColorImages أولاً
    if (widget.productItem.syncColorImages?.isNotEmpty == true) {
      final firstColorImage = widget.productItem.syncColorImages!.first;
      if (firstColorImage.images?.isNotEmpty == true) {
        imageUrl = firstColorImage.images!.first.filePath;
        imageHeight = double.tryParse(
                firstColorImage.images!.first.originalHeight ?? '250') ??
            250;
        imageWidth = double.tryParse(
                firstColorImage.images!.first.originalWidth ?? '200') ??
            200;
      }
    }

    // إذا لم توجد، استخدم أول صورة من images العادية
    if (imageUrl == null && widget.productItem.images?.isNotEmpty == true) {
      final firstImage = widget.productItem.images!.first;
      imageUrl = firstImage.filePath;
      imageHeight = double.tryParse(firstImage.originalHeight ?? '250') ?? 250;
      imageWidth = double.tryParse(firstImage.originalWidth ?? '200') ?? 200;
    }

    return ValueListenableBuilder<bool>(
        valueListenable: widget.visibleRedeem,
        builder: (context, _visibleRedeem, _) {
          bool isRedeem = (GetIt.I<PrefsRepository>()
                          .getRedeemDateForProduct(
                              widget.productItem.productId.toString())
                          ?.isAfter(
                              DateTime.now().add(const Duration(seconds: 1))) ==
                      true &&
                  widget.productItem.hasRedeemDiscount == true) ||
              (GetIt.I<PrefsRepository>().getRedeemSecondRemainingForProduct(
                          widget.productItem.productId.toString()) ??
                      0) >
                  0;
          final bool hasVideo =
              (widget.videoSource != null && widget.videoSource!.isNotEmpty);

          return Container(
            width: 200,
            height: 250,
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              border:
                  isRedeem ? Border.all(color: const Color(0xffFF6200)) : null,
            ),
            child: hasVideo
                ? _buildVideoBox(isRedeem, imageUrl ?? "")
                : (imageUrl != null
                    ? ProductListingImageWidget(
                        orginalHeight: imageHeight,
                        orginalWidth: imageWidth,
                        width: 200,
                        imageUrl: imageUrl,
                        height: 250,
                        circleShape: false,
                        innerShadowYOffset: 3,
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.image,
                            size: 50, color: Colors.grey[400]),
                      )),
          );
        });
  }

  Widget _buildVideoBox(bool isRedeem, String imageUrl) {
    if (videoProductInListingController[widget.productItem.slug ?? ""] ==
        null) {
      return Container(color: Colors.black12);
    }

    return SizedBox(
        height: 250,
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
                      borderRadius: BorderRadius.circular(15),
                      child: SizedBox(
                        width: 200,
                        height: 250,
                        child: VideoPlayer(videoProductInListingController[
                            widget.productItem.slug ?? ""]!),
                      )));
            } else {
              videoChild = const SizedBox.shrink();
            }

            return Stack(
              alignment: Alignment.center,
              children: [
                videoChild,
                if (showLoading)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: ProductListingImageWidget(
                      borderColor: isRedeem ? const Color(0xffFF6200) : null,
                      orginalHeight: 250,
                      orginalWidth: 200,
                      width: 200,
                      imageUrl: imageUrl,
                      height: 250,
                      circleShape: false,
                      innerShadowYOffset: 3,
                    ),
                  ),
                buffering
                    ? TrydosLoader(
                        size: 20,
                      )
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
                            ))*/
                    const SizedBox.shrink()
              ],
            );
          },
        ));
  }

  /// 💰 معلومات المنتج المبسطة
  Widget _buildProductInfo() {
    return Column(
      children: [
        // معلومات المنتج
        SizedBox(
          width: 200,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              crossAxisAlignment: LanguageService.languageCode == "ar"
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // Brand Icon
                _buildBrandIcon(),

                // Product Name and Category
                _buildProductCategoryRow(),

                Directionality(
                    textDirection: LanguageService.languageCode == "ar"
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RotatingTextWidget(
                            texts: widget.productItem.labelNames ?? [],
                            textStyle: textTheme.titleMedium?.br.copyWith(
                              fontSize: 9.sp,
                              color: const Color(0xff388CFF),
                              height: 0,
                            ),
                          ),
                          SizedBox(
                            width: 50,
                            height: 13,
                            child: SizedBox(
                                width: 40,
                                height: 12,
                                child: ValueListenableBuilder<bool>(
                                    valueListenable: widget.visibleRedeem,
                                    builder: (context, _visibleRedeem, _) {
                                      return (GetIt.I<PrefsRepository>()
                                                          .getRedeemDateForProduct(
                                                              widget.productItem
                                                                  .productId
                                                                  .toString())
                                                          ?.isAfter(DateTime
                                                                  .now()
                                                              .add(const Duration(
                                                                  seconds:
                                                                      1))) ==
                                                      true &&
                                                  widget.productItem
                                                          .hasRedeemDiscount ==
                                                      true) ||
                                              (GetIt.I<PrefsRepository>()
                                                          .getRedeemSecondRemainingForProduct(
                                                              widget.productItem
                                                                  .productId
                                                                  .toString()) ??
                                                      0) >
                                                  0
                                          ? Row(children: [
                                              SvgPicture.asset(
                                                AppAssets.redeemClockSvg,
                                                color: const Color(0xffFF6200),
                                              ),
                                              const SizedBox(
                                                width: 2,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SecondsCountdown(
                                                    productId: widget
                                                        .productItem.productId
                                                        .toString(),
                                                    finishRedeem:
                                                        widget.finishRedeem,
                                                    visibleRedeem:
                                                        widget.visibleRedeem,
                                                    endTime: GetIt.I<
                                                                PrefsRepository>()
                                                            .getRedeemDateForProduct(
                                                                widget
                                                                    .productItem
                                                                    .productId
                                                                    .toString()) ??
                                                        DateTime.now(),
                                                  ),
                                                  Text(
                                                      " ${LocaleKeys.seconds.tr()} ",
                                                      style: context.textTheme
                                                          .bodyMedium?.rr
                                                          .copyWith(
                                                        fontSize: 9,
                                                        color: const Color(
                                                            0xffFF6200),
                                                      )),
                                                ],
                                              ),
                                            ])
                                          : const SizedBox.shrink();
                                    })),
                          )
                        ])),
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
    if (brandIcon == null) return const SizedBox.shrink();

    return SvgNetworkWidget(
      svgUrl: brandIcon,
      width: 30.w,
      height: 15,
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
            style: textTheme.titleMedium?.rr
                .copyWith(color: const Color(0xff505050), fontSize: 10.sp),
          ),
        ),
      ],
    );
  }

  // _buildCategoryIcon() was removed because it's unused to avoid linter warnings.

  /// 💰 Price Section - FIXED: أبعاد أصلية
  Widget _buildPriceSection() {
    return SizedBox(
      width: 200,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (previous, current) =>
              previous.getCurrencyForCountryModel !=
              current.getCurrencyForCountryModel,
          builder: (context, state) {
            final price = widget.productItem.price ?? 0;
            final offerPrice = widget.productItem.offerPrice ?? 0;
            final exchangeRate = state
                    .getCurrencyForCountryModel?.data?.currency?.exchangeRate ??
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
                          endDate = DateFormat('MM/dd/yyyy', 'en_US')
                              .parse(widget.productItem.flashDealEndDate ?? "");
                          endDate = endDate.add(const Duration(days: 1));
                        } catch (e) {
                          endDate = DateTime.now();
                          print('Error parsing date: $e');
                        }
                        _duration = endDate.difference(now);
                        if (_duration.isNegative || _duration.inSeconds < 1) {
                          isFlashDealEnded = true;
                        }

                        return ValueListenableBuilder<bool>(
                            valueListenable: widget.visibleRedeem,
                            builder: (context, _visibleRedeem, _) {
                              bool isRedeem = (GetIt.I<PrefsRepository>()
                                              .getRedeemDateForProduct(widget
                                                  .productItem.productId
                                                  .toString())
                                              ?.isAfter(DateTime.now().add(
                                                  const Duration(
                                                      seconds: 1))) ==
                                          true &&
                                      widget.productItem.hasRedeemDiscount ==
                                          true) ||
                                  (GetIt.I<PrefsRepository>()
                                              .getRedeemSecondRemainingForProduct(
                                                  widget.productItem.productId
                                                      .toString()) ??
                                          0) >
                                      0;

                              return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                        constraints:
                                            const BoxConstraints(maxWidth: 42),
                                        child: AutoSizeText(
                                          HelperFunctions.formatNumber(
                                              number: (price * exchangeRate))
                                          /* .toStringAsFixed(state.startingSetting
                                                    ?.decimalPointSetting ??
                                                2)
                                            .toString()*/
                                          ,
                                          maxLines: 1,
                                          minFontSize: 4,
                                          stepGranularity: 0.1,
                                          overflow: TextOverflow.ellipsis,
                                          style: textTheme.titleMedium?.lr
                                              .copyWith(
                                            fontSize: 12,
                                            color: const Color(0xff3c3c3c),
                                            decoration:
                                                TextDecoration.lineThrough,
                                            height: 0,
                                          ),
                                        )),
                                    const SizedBox(
                                      width: 2,
                                    ),
                                    Container(
                                        constraints:
                                            const BoxConstraints(maxWidth: 42),
                                        child: AutoSizeText(
                                          HelperFunctions.formatNumber(
                                              number: (((isFlashDealEnded ||
                                                          (widget.productItem
                                                                      .flashDealPrice ??
                                                                  0) ==
                                                              0)
                                                      ? offerPrice
                                                      : widget.productItem
                                                              .flashDealPrice ??
                                                          0) *
                                                  exchangeRate))
                                          /*.toStringAsFixed(state.startingSetting
                                                    ?.decimalPointSetting ??
                                                2)
                                            .toString()*/
                                          ,
                                          maxLines: 1,
                                          minFontSize: 4,
                                          stepGranularity: 0.1,
                                          overflow: TextOverflow.ellipsis,
                                          style: textTheme.titleMedium?.mr
                                              .copyWith(
                                            fontSize: 12.sp,
                                            decorationColor:
                                                const Color(0xffFF6200),
                                            decoration: isRedeem
                                                ? TextDecoration.lineThrough
                                                : null,
                                            color: const Color(0xff3c3c3c),
                                            height: 0,
                                          ),
                                        )),
                                    const SizedBox(
                                      width: 2,
                                    ),
                                    AutoSizeText(
                                      state.getCurrencyForCountryModel == null
                                          ? ""
                                          : state.getCurrencyForCountryModel!
                                                  .data!.currency!.symbol ??
                                              "",
                                      maxLines: 1,
                                      minFontSize: 6,
                                      stepGranularity: 0.1,
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.titleMedium?.lr.copyWith(
                                        fontSize: 10.sp,
                                        decorationColor:
                                            const Color(0xff1D1D1D),
                                        decoration: isRedeem
                                            ? TextDecoration.lineThrough
                                            : null,
                                        color: const Color(0xff3c3c3c),
                                        height: 0,
                                      ),
                                    ),
                                  ]);
                            });
                      }),
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
            () => _homeBloc.add(AddCurrentSelectedColorEvent(
                currentSelectedColor: 0,
                productSlug: widget.productItem.slug.toString())));
        _homeBloc.add(const ChangeStatusOFGetProductsDetailsToSuccessEvent(
          isStatusInitaial: true,
        ));
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
            final exchangeRate = state
                    .getCurrencyForCountryModel?.data?.currency?.exchangeRate ??
                1;
            double redeemPrice = widget.productItem.redeemPrice ?? 0;
            bool isRedeem = (GetIt.I<PrefsRepository>()
                            .getRedeemDateForProduct(
                                widget.productItem.productId.toString())
                            ?.isAfter(DateTime.now()
                                .add(const Duration(seconds: 1))) ==
                        true &&
                    widget.productItem.hasRedeemDiscount == true) ||
                (GetIt.I<PrefsRepository>().getRedeemSecondRemainingForProduct(
                            widget.productItem.productId.toString()) ??
                        0) >
                    0;

            return Container(
              height: 25, // الارتفاع الأصلي
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0x1D1D1D),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AutoSizeText(
                    " ${LocaleKeys.buy.tr()} ",
                    style: textTheme.titleSmall?.rr.copyWith(
                      fontSize: 10.sp,
                      color: isRedeem
                          ? const Color(0xffFF6200)
                          : const Color(0xff414141),
                      height: 0,
                    ),
                  ),
                  isRedeem
                      ? Container(
                          constraints: const BoxConstraints(maxWidth: 25),
                          child: AutoSizeText(
                            HelperFunctions.formatNumber(
                                number: redeemPrice * exchangeRate),
                            minFontSize: 2,
                            //      .toStringAsFixed(widget.decimalPoint),
                            style: textTheme.headlineMedium?.br.copyWith(
                              fontSize: 10.sp,
                              color: const Color(0xffFF6200),
                              height: 1.2,
                            ),
                          ))
                      : const SizedBox.shrink(),
                  const SizedBox(
                    width: 2,
                  ),
                  isRedeem
                      ? AutoSizeText(
                          state.getCurrencyForCountryModel == null
                              ? ""
                              : state.getCurrencyForCountryModel!.data!
                                      .currency!.symbol ??
                                  "",
                          style: TextStyle(
                            fontSize: 8.sp,
                            color: const Color(0xffFF6200),
                            height: 1.2,
                          ),
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(width: 3),
                  SvgPicture.asset(
                    AppAssets.bagSvg,
                    height: 15,
                  ),
                ],
              ),
            );
          }),
    );
  }
}
