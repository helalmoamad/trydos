import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/common/constant/design/assets_provider.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';

import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as productListingModel;
import 'package:trydos/features/home/presentation/widgets/product_listing/falsh_deal_counter.dart';
import 'dart:ui' as ui;

import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_3d_slider.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_3d_slider_optimized.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_simple_slider.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/language_service.dart';
import 'package:tuple/tuple.dart';

class ProductItem extends StatefulWidget {
  const ProductItem(
      {super.key,
      this.setThisEnabled,
      this.slidingModeItem,
      required this.itemIndex,
      this.productIsFlashDeal,
      this.fromHomePage = false,
      this.fromFlashDeal,
      this.imageSource,
      this.displayImageColors,
      required this.tapIndexToAddProductToCart,
      required this.productItem});

  final void Function(int, int)? setThisEnabled;
  final ValueNotifier<int> tapIndexToAddProductToCart;
  final bool? displayImageColors;
  final bool? fromFlashDeal;
  final bool fromHomePage;
  final String? imageSource;
  final ValueNotifier<bool>? productIsFlashDeal;
  final Tuple2<int, int>? slidingModeItem;
  final productListingModel.Products productItem;
  final int itemIndex;

  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  final PageController pageController = PageController();
  late final ValueNotifier<int> currentChosenColor;

  @override
  void initState() {
    super.initState();
    currentChosenColor =
        ValueNotifier((widget.productItem.syncColorImages?.length ?? 0) ~/ 2);
  }

  @override
  Widget build(BuildContext context) {
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
          /*  Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: BackdropFilter(
                blendMode: BlendMode.overlay,
                filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  decoration: const BoxDecoration(color: Color(0xfffafafa)),
                ),
              ),
            ),
          ),*/
          /* Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(
                  sigmaX: 10.0,
                  sigmaY: 10.0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                      color: const Color(0xffffffff).withOpacity(0.8)),
                ),
              ),
            ),
          ),*/
          ProductListing3DSliderOptimized(
            fromFlashDeal: widget.fromFlashDeal,
            fromHomePage: widget.fromHomePage,
            imageSource: widget.imageSource,
            productItem: widget.productItem,
            tapIndexToAddProductToCart: widget.tapIndexToAddProductToCart,
            itemIndex: widget.itemIndex,
          ),
          Positioned(
              left: LanguageService.languageCode != "ar" ? null : 5,
              right: LanguageService.languageCode == "ar" ? null : 5,
              top: (widget.productItem.flashDealEndDate != null) ? 55 : 10,
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
              )),
          (widget.productItem.flashDealEndDate == null ||
                  widget.productItem.flashDealEndDate == "")
              ? SizedBox.shrink()
              : Positioned(
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
                  ))
        ]);
  }
}
