import 'package:easy_localization/easy_localization.dart' as tran;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
import 'package:trydos/main.dart';
import 'package:trydos/service/language_service.dart';

class ProductItem extends StatefulWidget {
  const ProductItem(
      {super.key,
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
      required this.productItem});

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
  @override
  void initState() {
    super.initState();
    if (!widget.fromHomePage) {
      if (productSlugToSaveVideoTimer.length > 8) {
        productSlugToSaveVideoTimer.removeLast();
      }
      if (!productSlugToSaveVideoTimer
          .contains(widget.productItem.slug.toString())) {
        productSlugToSaveVideoTimer.insert(
            0, widget.productItem.slug.toString());
      }
    }

//    productIdToSaveRedeemTimer.add(widget.productItem.productId.toString());

    currentChosenColor =
        ValueNotifier((widget.productItem.syncColorImages?.length ?? 0) ~/ 2);
    if (widget.productItem.hasRedeemDiscount == true) {
      GetIt.I<PrefsRepository>().setRedeemDateForProduct(
          widget.productItem.productId.toString(), "50");
    }
  }

/*  @override
  void dispose() {
    print(
        "WSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSsssssssssww${widget.productItem.slug}");
//    productIdToSaveRedeemTimer.remove(widget.productItem.productId.toString());
    super.dispose();
  }
*/
  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    /*  FlutterError.onError = (FlutterErrorDetails error) {
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
    };*/
    return Stack(
        key: ValueKey(widget.productItem.slug),
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          /*  !widget.fromHomePage
              ? SizedBox.fromSize()
              : Container(
                  height: widget.fromHomePage ? 250 : 350,
                  width: widget.fromHomePage ? 120 : 200.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff000000).withOpacity(0.1),
                        offset: const Offset(0, 3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: ValueListenableBuilder<int>(
                          valueListenable: currentChosenColor,
                          builder: (context, index, _) {
                            if (widget
                                .productItem.syncColorImages.isNullOrEmpty) {
                              return Image.asset(
                                  'assets/product_listing_background_blur_image.png',
                                  fit: BoxFit.cover);
                            }
                            if (index >
                                (widget.productItem.syncColorImages?.length ??
                                        0) -
                                    1) {
                              currentChosenColor.value =
                                  (widget.productItem.syncColorImages?.length ??
                                          0) ~/
                                      2;
                              return MyCachedNetworkImage(
                                ordinalHeight: double.parse(widget
                                    .productItem
                                    .syncColorImages![(widget.productItem
                                                .syncColorImages?.length ??
                                            0) ~/
                                        2]
                                    .images![0]
                                    .originalHeight!),
                                ordinalwidth: double.parse(widget
                                    .productItem
                                    .syncColorImages![(widget.productItem
                                                .syncColorImages?.length ??
                                            0) ~/
                                        2]
                                    .images![0]
                                    .originalWidth!),
                                imageUrl: widget
                                    .productItem
                                    .syncColorImages![(widget.productItem
                                                .syncColorImages?.length ??
                                            0) ~/
                                        2]
                                    .images![0]
                                    .filePath!,
                                height: widget.fromHomePage ? 250 : 350,
                                width: 200.w,
                                imageFit: BoxFit.cover,
                              );
                            }
                            return widget.productItem.syncColorImages!
                                        .isNullOrEmpty ||
                                    widget.productItem.syncColorImages![index]
                                        .images.isNullOrEmpty
                                ? Image.asset(
                                    'assets/product_listing_background_blur_image.png',
                                    fit: BoxFit.cover)
                                : MyCachedNetworkImage(
                                    ordinalHeight: double.parse(widget
                                        .productItem
                                        .syncColorImages![index]
                                        .images![0]
                                        .originalHeight!),
                                    ordinalwidth: double.parse(widget
                                        .productItem
                                        .syncColorImages![index]
                                        .images![0]
                                        .originalWidth!),
                                    imageUrl: widget
                                        .productItem
                                        .syncColorImages![index]
                                        .images![0]
                                        .filePath!,
                                    height: widget.fromHomePage ? 250 : 350,
                                    width: 200.w,
                                    imageFit: BoxFit.cover,
                                  );
                          })),
                ),*/

          widget.fromHomePage
              ? ProductListing3DSliderOptimized(
                  visibleFlashDeal: visibleFlashDeal,
                  finishRedeem: widget.finishRedeem,
                  videoSource: widget.productItem.videos.isNullOrEmpty
                      ? null
                      : widget.productItem.videos!.first.contains("cloudinary")
                          ? widget.productItem.videos!.first
                          : ("${dotenv.env['Video_url']}" +
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
                          : ("${dotenv.env['Video_url']}" +
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
          /*  Positioned(
              left: LanguageService.languageCode != "ar" ? null : 5,
              right: LanguageService.languageCode == "ar" ? null : 5,
              top: (widget.productItem.flashDealEndDate == null ||
                      widget.productItem.flashDealEndDate != "")
                  ? 10
                  : 55,
              child: Column(
                children: [
                  ...List.generate(
                      (widget.productItem.labelNames?.length ?? 0) > 3
                          ? 3
                          : (widget.productItem.labelNames?.length ?? 0),
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
                                  widget.productItem.labelNames?[index] ?? "",
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
          (widget.productItem.flashDealEndDate == null ||
                  widget.productItem.flashDealEndDate == "")
              ? const SizedBox.shrink()
              :

              /* Positioned(
                  left: LanguageService.languageCode == "ar" ? null : 5,
                  right: LanguageService.languageCode != "ar" ? null : 0,
                  top: (widget.productItem.flashDealEndDate != null) ? 10 : 0,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 2),
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    height: 50,
                    width: 110,
                    constraints: BoxConstraints(maxWidth: 150),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color.fromARGB(234, 255, 65, 40),
                            Color.fromARGB(255, 255, 119, 40)
                          ]),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                              LanguageService.languageCode == "ar"
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                          children: [
                            Text(
                              "${LocaleKeys.flash_deal.tr()}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.bodyMedium?.rr.copyWith(
                                color: Colors.white,
                                letterSpacing: 0.18,
                                fontSize: 14,
                                height: 1.3,
                              ),
                            ),
                            SvgPicture.asset(
                              AppAssets.flashDealSvg,
                              height: 16,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        SizedBox(height: 2),
                        FlashDealCountdownTimerWidget(
                          endDateString:
                              widget.productItem.flashDealEndDate ?? "",
                        )
                      ],
                    ),
                  ))*/
              (widget.productItem.flashDealEndDate ?? "") == ""
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
                            final now = DateTime.now();
                            try {
                              endDate = tran.DateFormat('MM/dd/yyyy', 'en_US')
                                  .parse(widget.productItem.flashDealEndDate ??
                                      "");
                              endDate = endDate.add(const Duration(days: 1));
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
                                    left: LanguageService.languageCode != "ar"
                                        ? 1
                                        : null,
                                    right: LanguageService.languageCode == "ar"
                                        ? 1
                                        : null,
                                    top: 0,
                                    child: Transform(
                                      transform: Matrix4.skewX(
                                          -0.4), // انحراف بسيط للشكل
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            left:
                                                LanguageService.languageCode !=
                                                        "ar"
                                                    ? 1
                                                    : 10,
                                            right:
                                                LanguageService.languageCode ==
                                                        "ar"
                                                    ? 1
                                                    : 10),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: const Color(0xffFF6200)),
                                          color: const Color(0xffFFF3E8),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        height: 20,
                                        child: Transform(
                                            transform: Matrix4.skewX(
                                                0.4), // انحراف بسيط للشكل
                                            child: Row(
                                              children: [
                                                const SizedBox(
                                                  width: 3,
                                                ),
                                                SvgPicture.asset(
                                                  AppAssets.flashDealSvg,
                                                  height: 12,
                                                  color:
                                                      const Color(0xffFF6200),
                                                ),
                                                const SizedBox(
                                                  width: 2,
                                                ),
                                                Text(
                                                  "${LocaleKeys.flash_deal.tr()}",
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: context
                                                      .textTheme.bodyMedium?.br
                                                      .copyWith(
                                                    color:
                                                        const Color(0xffFF6200),
                                                    letterSpacing: 0.18,
                                                    fontSize: 9,
                                                    height: 1.3,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                FlashDealCountdownTimerWidget(
                                                  visibleFlashDeal:
                                                      visibleFlashDeal,
                                                  refreshFlashDeal:
                                                      widget.refreshFlashDeal,
                                                  endDateString: widget
                                                          .productItem
                                                          .flashDealEndDate ??
                                                      "",
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                              ],
                                            )),
                                      ),
                                    ))
                                : const SizedBox.shrink();
                          })),
          Directionality(
              textDirection: LanguageService.languageCode == "ar"
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: ValueListenableBuilder<bool>(
                  valueListenable: visibleRedeem,
                  builder: (context, _visibleRedeem, _) {
                    return (GetIt.I<PrefsRepository>()
                                        .getRedeemDateForProduct(widget
                                            .productItem.productId
                                            .toString())
                                        ?.isAfter(DateTime.now()
                                            .add(const Duration(seconds: 1))) ==
                                    true &&
                                widget.productItem.hasRedeemDiscount == true) ||
                            (GetIt.I<PrefsRepository>()
                                        .getRedeemSecondRemainingForProduct(
                                            widget.productItem.productId
                                                .toString()) ??
                                    0) >
                                0
                        ? Positioned(
                            left:
                                LanguageService.languageCode == "ar" ? null : 1,
                            right:
                                LanguageService.languageCode != "ar" ? null : 1,
                            top: 0,
                            child: Transform(
                              transform:
                                  Matrix4.skewX(-0.4), // انحراف بسيط للشكل
                              child: Container(
                                margin: EdgeInsets.only(
                                    left: LanguageService.languageCode != "ar"
                                        ? 1
                                        : 10,
                                    right: LanguageService.languageCode == "ar"
                                        ? 1
                                        : 10),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0xffFF6200)),
                                  color: const Color(0xffFFF3E8),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                height: 20,
                                child: Transform(
                                    transform:
                                        Matrix4.skewX(0.4), // انحراف بسيط للشكل
                                    child: Row(
                                      children: [
                                        const SizedBox(
                                          width: 3,
                                        ),
                                        SvgPicture.asset(
                                            AppAssets.redeemClockSvg),
                                        const SizedBox(
                                          width: 3,
                                        ),
                                        Text(LocaleKeys.luck.tr(),
                                            style: context
                                                .textTheme.bodyMedium?.br
                                                .copyWith(
                                              fontSize: 9,
                                              color: const Color(0xffFF6200),
                                            )),
                                        const SizedBox(
                                          width: 1,
                                        ),
                                        Text(
                                            " ${LocaleKeys.add_to_bag_within.tr()} ",
                                            style: context
                                                .textTheme.bodyMedium?.mr
                                                .copyWith(
                                              fontSize: 9,
                                              color: const Color(0xffFF6200),
                                            )),
                                        SecondsCountdown(
                                          productId: widget
                                              .productItem.productId
                                              .toString(),
                                          finishRedeem: widget.finishRedeem,
                                          visibleRedeem: visibleRedeem,
                                          endTime: GetIt.I<PrefsRepository>()
                                                  .getRedeemDateForProduct(
                                                      widget
                                                          .productItem.productId
                                                          .toString()) ??
                                              DateTime.now(),
                                        ),
                                        Text(" ${LocaleKeys.seconds.tr()} ",
                                            style: context
                                                .textTheme.bodyMedium?.br
                                                .copyWith(
                                              fontSize: 9,
                                              color: const Color(0xffFF6200),
                                            )),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                      ],
                                    )),
                              ),
                            ))
                        : const SizedBox.shrink();
                  }))
        ]);
  }
}
