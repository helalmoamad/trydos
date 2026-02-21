import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart' as trans;
import 'package:flutter/material.dart' hide BoxShadow;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/svg_network_widget.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as productListingModel;
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:tuple/tuple.dart';

import '../../../../app/my_text_widget.dart';
import '../../../../../core/utils/theme_state.dart';
import '../../../../../service/language_service.dart';
import 'product_listing_image_widget.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';

/// ---------------------------------------------------------------------------
/// ProductListingLightSlider
/// ---------------------------------------------------------------------------
/// • يحافظ على نفس الـ API والأبعاد وخطوط النص كما في `ProductListing3DSlider`.
/// • يستخدم عناصر Flutter القياسية (PageView, ListView, CarouselSlider) بدل
///   flutter_gallery_3d للحصول على أداء أخف وأكثر موثوقيّة.
/// ---------------------------------------------------------------------------
class ProductListingLightSlider extends StatefulWidget {
  const ProductListingLightSlider({
    super.key,
    required this.setThisEnabled,
    required this.slidingModeItem,
    required this.itemIndex,
    this.fromHomePage = false,
    required this.tapIndexToAddProductToCart,
    required this.productItem,
    this.productIsFlashDeal,
    this.fromFlashDeal,
    required this.displayImageColors,
    required this.currentChosenColor,
  });

  final Tuple2<int, int> slidingModeItem;
  final void Function(int, int) setThisEnabled;
  final ValueNotifier<int> tapIndexToAddProductToCart;
  final int itemIndex;
  final bool fromHomePage;
  final bool displayImageColors;
  final bool? fromFlashDeal;
  final productListingModel.Products productItem;
  final ValueNotifier<bool>? productIsFlashDeal;
  final ValueNotifier<int> currentChosenColor;

  @override
  State<ProductListingLightSlider> createState() =>
      _ProductListingLightSliderState();
}

class _ProductListingLightSliderState
    extends ThemeState<ProductListingLightSlider> {
  // Controllers
  late final PageController _imagesController;
  late final ScrollController _colorsController;

  // Data
  late final List<productListingModel.SyncColorImageProduct>
  _colorImages; // may be empty
  late final List<String> _fallbackImages; // product images when no colors

  // State
  int _slideMode = 0; // 0: normal, 1: colors, 2: three-images (carousel)
  int _currentColorIdx = 0;

  @override
  void initState() {
    super.initState();

    _colorImages = (widget.productItem.syncColorImages ?? [])
      ..removeWhere((e) => e.images.isNullOrEmpty);
    _fallbackImages = (widget.productItem.images ?? [])
        .map((e) => e.filePath!)
        .toList();

    _imagesController = PageController();
    _colorsController = ScrollController()..addListener(_onColorBarScroll);

    // اختَر الفهرس الأول كلون افتراضي إن وجد
    if (_colorImages.isNotEmpty) {
      BlocProvider.of<HomeBloc>(context).add(
        AddCurrentSelectedColorEvent(
          currentSelectedColor: 0,
          productSlug: widget.productItem.slug.toString(),
        ),
      );
    }
  }

  void _onColorBarScroll() {
    if (_colorImages.isEmpty) return;
    // itemExtent = 40, we add half extent for rounding
    final newIdx = ((_colorsController.offset + 20) ~/ 40).clamp(
      0,
      _colorImages.length - 1,
    );
    if (newIdx != _currentColorIdx) {
      _onSelectColor(newIdx);
    }
  }

  @override
  void dispose() {
    _imagesController.dispose();
    _colorsController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    _slideMode = widget.itemIndex == widget.slidingModeItem.item1
        ? widget.slidingModeItem.item2
        : 0;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTopSection(),
                if (_shouldShowColorBar) ...[
                  const SizedBox(height: 8),
                  _buildColorBar(),
                  const SizedBox(height: 4),
                  _buildColorName(),
                ],
              ],
            ),
            Positioned(bottom: 10, child: _buildBottomSection()),
          ],
        ),
      ),
    );
  }

  // --------------------------- TOP SECTION ----------------------------------
  Widget _buildTopSection() {
    switch (_slideMode) {
      case 1:
        return _buildColorImages();
      case 2:
        return _buildThreeImages();
      default:
        return _buildNormalImages();
    }
  }

  // Mode 0: all images carousel (no colors) ----------------------------------
  Widget _buildNormalImages() {
    final height = widget.fromHomePage ? 220.0 : 290.0;
    final width = widget.fromHomePage ? 170.0 : 200.0;

    return SizedBox(
      height: height,
      width: width,
      child: CarouselSlider.builder(
        itemCount: _fallbackImages.length,
        itemBuilder: (_, idx, __) => ProductListingImageWidget(
          width: width,
          height: height,
          circleShape: false,
          innerShadowYOffset: 3,
          imageUrl: _fallbackImages[idx],
        ),
        options: CarouselOptions(
          viewportFraction: 1,
          enableInfiniteScroll: false,
          onPageChanged: (_, __) => widget.setThisEnabled.call(-1, -1),
        ),
      ),
    );
  }

  // Mode 1: show images of selected color ------------------------------------
  Widget _buildColorImages() {
    final images = _getCurrentColorImages();
    final height = widget.fromHomePage ? 200.0 : 240.0;
    final double width = widget.fromHomePage ? 170.0 : 200.0;

    return SizedBox(
      height: height,
      width: width,
      child: PageView.builder(
        controller: _imagesController,
        itemCount: images.length,
        itemBuilder: (_, idx) => ProductListingImageWidget(
          key: ValueKey(images[idx]),
          width: width,
          height: height,
          circleShape: false,
          innerShadowYOffset: 3,
          imageUrl: images[idx],
        ),
      ),
    );
  }

  // Mode 2: first three product images ---------------------------------------
  Widget _buildThreeImages() {
    final all = _fallbackImages;
    if (all.isEmpty) return _buildNormalImages();
    List<String> three;
    if (all.length < 3) {
      three = [...all];
      while (three.length < 3) three.add(all.first);
    } else {
      three = all.sublist(0, 3);
    }

    const height = 240.0;
    return SizedBox(
      height: height,
      width: 200,
      child: PageView(
        children: three
            .map(
              (e) => ProductListingImageWidget(
                key: ValueKey(e),
                width: 170.w,
                height: height,
                circleShape: false,
                innerShadowYOffset: 3,
                imageUrl: e,
              ),
            )
            .toList(),
      ),
    );
  }

  // --------------------------- COLORS BAR -----------------------------------
  bool get _shouldShowColorBar =>
      widget.displayImageColors && _colorImages.isNotEmpty;

  Widget _buildColorBar() {
    return SizedBox(
      height: 45,
      width: 200,
      child: ListView.builder(
        controller: _colorsController,
        scrollDirection: Axis.horizontal,
        itemExtent: 40,
        itemCount: _colorImages.length,
        itemBuilder: (_, idx) {
          final imgUrl = _colorImages[idx].images!.first.filePath!;
          final selected = idx == _currentColorIdx;
          return GestureDetector(
            onTap: () => _onSelectColor(idx),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected ? Colors.red : Colors.grey.shade400,
                  width: 0.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ProductListingImageWidget(
                  width: 30,
                  height: 40,
                  circleShape: false,
                  innerShadowYOffset: 3,
                  imageUrl: imgUrl,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onSelectColor(int idx) {
    setState(() => _currentColorIdx = idx);
    _imagesController.jumpToPage(0);

    final int realIdx = idx % (widget.productItem.syncColorImages?.length ?? 1);
    widget.currentChosenColor.value = realIdx;
    BlocProvider.of<HomeBloc>(context).add(
      AddCurrentSelectedColorEvent(
        currentSelectedColor: realIdx,
        productSlug: widget.productItem.slug.toString(),
      ),
    );
  }

  Widget _buildColorName() {
    final name = _colorImages[_currentColorIdx].colorName ?? '';
    final colorsList = widget.productItem.colors ?? [];
    final int hex = colorsList.isEmpty
        ? 0xff000000
        : int.parse(
            colorsList[_currentColorIdx % colorsList.length].color!.substring(
              1,
            ),
          );

    return MyTextWidget(
      name,
      textAlign: TextAlign.center,
      style: textTheme.titleMedium?.mq.copyWith(color: Color(0xff000000 | hex)),
    );
  }

  List<String> _getCurrentColorImages() {
    if (_colorImages.isEmpty) return _fallbackImages;
    final realIdx =
        _currentColorIdx % (widget.productItem.syncColorImages?.length ?? 1);
    return _colorImages[realIdx].images!.map((e) => e.filePath!).toList();
  }

  // --------------------------- BOTTOM SECTION -------------------------------
  Widget _buildBottomSection() {
    return Column(
      children: [
        SizedBox(height: widget.fromHomePage ? 0 : 20),
        _buildBrandAndName(),
        SizedBox(height: widget.fromHomePage ? 0 : 10),
        _buildPriceAndBuy(),
      ],
    );
  }

  Widget _buildBrandAndName() {
    return SizedBox(
      width: 200,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: LanguageService.languageCode == 'ar'
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (widget.productItem.brand?.icon?.filePath != null)
              SvgNetworkWidget(
                svgUrl: widget.productItem.brand!.icon!.filePath!,
                width: 30.w,
                height: 15,
              ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: LanguageService.languageCode == 'ar'
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                if (widget.productItem.category != null)
                  SvgNetworkWidget(
                    svgUrl: widget.productItem.category!.flatPhotoPath!.filePath
                        .toString(),
                    height: 10,
                  ),
                const SizedBox(width: 3),
                Flexible(
                  child: MyTextWidget(
                    widget.productItem.name ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall?.rq.copyWith(
                      color: const Color(0xff3c3c3c),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceAndBuy() {
    return SizedBox(
      width: 225,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 22),
        child: BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (p, c) =>
              p.getCurrencyForCountryModel != c.getCurrencyForCountryModel,
          builder: (context, state) {
            final price = HelperFunctions.truncateToDecimalPlaces(
              widget.productItem.price ?? 0,
              state.getCurrencyForCountryModel!.data!.currency!.decimalDigits!,
            );
            final offerPrice = HelperFunctions.truncateToDecimalPlaces(
              widget.productItem.offerPrice ?? 0,
              state.getCurrencyForCountryModel!.data!.currency!.decimalDigits!,
            );
            final rate =
                state
                    .getCurrencyForCountryModel
                    ?.data
                    ?.currency
                    ?.exchangeRate ??
                1;
            return Directionality(
              textDirection: LanguageService.languageCode == 'ar'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      MyTextWidget(
                        HelperFunctions.formatNumber(
                          numberToFormate: price * rate,
                        ),
                        style: textTheme.titleMedium?.lq.copyWith(
                          color: const Color(0xff3c3c3c),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 2),
                      MyTextWidget(
                        HelperFunctions.formatNumber(
                          numberToFormate: offerPrice * rate,
                        ),
                        style: textTheme.titleMedium?.bq.copyWith(
                          color: const Color(0xff3c3c3c),
                        ),
                      ),
                      const SizedBox(width: 2),
                      MyTextWidget(
                        state
                                .getCurrencyForCountryModel
                                ?.data
                                ?.currency
                                ?.symbol ??
                            '',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: _onBuyPressed,
                    child: Container(
                      height: 30.h,
                      color: const Color(0x1D1D1D),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          MyTextWidget(
                            LocaleKeys.buy.tr(),
                            style: textTheme.titleSmall?.lq.copyWith(
                              color: const Color(0xff414141),
                            ),
                          ),
                          const SizedBox(width: 2),
                          SvgPicture.asset(
                            AppAssets.bagSvg,
                            height: 15,
                            width: 15,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _onBuyPressed() {
    BlocProvider.of<HomeBloc>(context).add(
      const ChangeStatusOFGetProductsDetailsToSuccessEvent(
        isStatusInitaial: true,
      ),
    );
    widget.productIsFlashDeal?.value = widget.fromFlashDeal ?? false;
    Future.delayed(const Duration(milliseconds: 600), () {
      widget.tapIndexToAddProductToCart.value = widget.itemIndex;
    });
  }
}
