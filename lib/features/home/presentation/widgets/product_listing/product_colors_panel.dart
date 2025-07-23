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

import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/features/app/svg_network_widget.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_image_widget.dart';

import 'package:trydos/features/home/presentation/widgets/rotating_text_widget.dart';

import 'package:trydos/generated/locale_keys.g.dart';

import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as productListingModel;
import '../../../../../service/language_service.dart';
import '../../../../app/my_text_widget.dart';

/// 🚀 نسخة مبسطة جداً من ProductListing3DSlider - أداء فائق ⚡
class ProductColorPanal extends StatefulWidget {
  const ProductColorPanal({
    super.key,
    // required this.setThisEnabled,
    // required this.slidingModeItem,
    required this.itemIndex,
    required this.tapIndexToAddProductToCart,
    required this.visibleRedeem,
    required this.productItem,
    required this.colorImages,
    required this.finishRedeem,

    // جديد: افتراضي false
    //required this.displayImageColors,
    //  required this.currentChosenColor,
  });

  // final Tuple2<int, int> slidingModeItem;
  // final void Function(int, int) setThisEnabled;
  final ValueNotifier<int> tapIndexToAddProductToCart;
  final ValueNotifier<bool> finishRedeem;
  final int itemIndex;

  final ValueNotifier<bool> visibleRedeem;
  final List<String> colorImages;
  final productListingModel.Products productItem;

  @override
  State<ProductColorPanal> createState() => _ProductColorPanalState();
}

class _ProductColorPanalState extends State<ProductColorPanal> {
  late HomeBloc _homeBloc;

  @override
  void initState() {
    super.initState();
    _homeBloc = BlocProvider.of<HomeBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: _buildSimpleProductCard(),
    );
  }

  /// 🎯 بطاقة منتج بسيطة - أداء ممتاز
  Widget _buildSimpleProductCard() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          color: Color(0xffF8F8F8),
          border: Border.all(color: Colors.white)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🖼️ صورة المنتج - بدون مسافات إضافية
          Container(
            height: 300,
            width: 200,
            child: buildSingleImage(widget.colorImages),
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
    double imageHeight = 290;
    double imageWidth = 200;

    // محاولة الحصول على الصورة من syncColorImages أولاً
    if (widget.productItem.syncColorImages?.isNotEmpty == true) {
      final firstColorImage = widget.productItem.syncColorImages!.first;
      if (firstColorImage.images?.isNotEmpty == true) {
        imageUrl = firstColorImage.images!.first.filePath;
        imageHeight = double.tryParse(
                firstColorImage.images!.first.originalHeight ?? '290') ??
            290;
        imageWidth = double.tryParse(
                firstColorImage.images!.first.originalWidth ?? '200') ??
            200;
      }
    }

    // إذا لم توجد، استخدم أول صورة من images العادية
    if (imageUrl == null && widget.productItem.images?.isNotEmpty == true) {
      final firstImage = widget.productItem.images!.first;
      imageUrl = firstImage.filePath;
      imageHeight = double.tryParse(firstImage.originalHeight ?? '290') ?? 290;
      imageWidth = double.tryParse(firstImage.originalWidth ?? '200') ?? 200;
    }

    return ValueListenableBuilder<bool>(
        valueListenable: widget.visibleRedeem,
        builder: (context, _visibleRedeem, _) {
          bool isRedeem = (GetIt.I<PrefsRepository>()
                          .getRedeemDateForProduct(
                              widget.productItem.productId.toString())
                          ?.isAfter(DateTime.now().add(Duration(seconds: 1))) ==
                      true &&
                  widget.productItem.hasRedeemDiscount == true) ||
              (GetIt.I<PrefsRepository>().getRedeemSecondRemainingForProduct(
                          widget.productItem.productId.toString()) ??
                      0) >
                  0;
          return Container(
            width: 200,
            height: 290,
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            child: (imageUrl != null
                ? ProductListingImageWidget(
                    borderColor: isRedeem ? Color(0xffFF6200) : null,
                    orginalHeight: imageHeight,
                    orginalWidth: imageWidth,
                    width: 200,
                    imageUrl: imageUrl,
                    height: 290,
                    circleShape: false,
                    innerShadowYOffset: 3,
                  )
                : Container(
                    color: Colors.grey[200],
                    child: Icon(Icons.image, size: 50, color: Colors.grey[400]),
                  )),
          );
        });
  }

  /// 💰 معلومات المنتج المبسطة
  Widget _buildProductInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // معلومات المنتج
        SizedBox(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: LanguageService.languageCode == "ar"
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // Brand Icon
                _buildBrandIcon(),

                // Product Name and Category
                _buildProductNameRow(),

                (widget.productItem.labelNames?.length ?? 0) == 0
                    ? SizedBox(
                        height: 10,
                      )
                    : RotatingTextWidget(
                        texts: widget.productItem.labelNames ?? [],
                        rotationDuration: Duration(seconds: 5),
                        textStyle: textTheme.titleMedium?.br.copyWith(
                          fontSize: 9.sp,
                          color: Color(0xff388CFF),
                          height: 0,
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
  Widget _buildProductNameRow() {
    return Row(
      mainAxisAlignment: LanguageService.languageCode == "ar"
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Category Icon
        //  _buildCategoryIcon(),

        // Product Name
        Flexible(
          child: MyTextWidget(
            widget.productItem.name.toString(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: const Color(0xff3c3c3c),
                ),
          ),
        ),
      ],
    );
  }

  /// 🏷️ Category Icon
/*  Widget _buildCategoryIcon() {
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
      width: 200,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
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
                      valueListenable: widget.visibleRedeem,
                      builder: (context, _visibleRedeem, _) {
                        bool isRedeem = (GetIt.I<PrefsRepository>()
                                        .getRedeemDateForProduct(widget
                                            .productItem.productId
                                            .toString())
                                        ?.isAfter(DateTime.now()
                                            .add(Duration(seconds: 1))) ==
                                    true &&
                                widget.productItem.hasRedeemDiscount == true) ||
                            (GetIt.I<PrefsRepository>()
                                        .getRedeemSecondRemainingForProduct(
                                            widget.productItem.productId
                                                .toString()) ??
                                    0) >
                                0;

                        return Flexible(
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            MyTextWidget(
                              HelperFunctions.formatNumber(
                                  number: (price * exchangeRate))
                              /* .toStringAsFixed(state.startingSetting
                                                    ?.decimalPointSetting ??
                                                2)
                                            .toString()*/
                              ,
                              style: textTheme.titleMedium?.lq.copyWith(
                                fontSize: 9.sp,
                                color: Color(0xff3c3c3c),
                                decoration: TextDecoration.lineThrough,
                                height: 0,
                              ),
                            ),
                            SizedBox(
                              width: 2,
                            ),
                            MyTextWidget(
                              HelperFunctions.formatNumber(
                                  number: (offerPrice * exchangeRate))
                              /*.toStringAsFixed(state.startingSetting
                                                    ?.decimalPointSetting ??
                                                2)
                                            .toString()*/
                              ,
                              style: textTheme.titleMedium?.mr.copyWith(
                                fontSize: 9.sp,
                                decorationColor: Color(0xffFF6200),
                                decoration: isRedeem
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: Color(0xff3c3c3c),
                                height: 0,
                              ),
                            ),
                            SizedBox(
                              width: 2,
                            ),
                            MyTextWidget(
                              state.getCurrencyForCountryModel == null
                                  ? ""
                                  : state.getCurrencyForCountryModel!.data!
                                          .currency!.symbol ??
                                      "",
                              style: TextStyle(fontSize: 8.sp, height: 0),
                            ),
                          ]),
                        );
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
            Duration(milliseconds: 50),
            () => _homeBloc.add(AddCurrentSelectedColorEvent(
                currentSelectedColor: 0,
                productSlug: widget.productItem.slug.toString())));
        _homeBloc.add(ChangeStatusOFGetProductsDetailsToSuccessEvent(
          isStatusInitaial: true,
        ));
        // widget.productIsFlashDeal?.value = widget.fromFlashDeal ?? false;

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
                            ?.isAfter(
                                DateTime.now().add(Duration(seconds: 1))) ==
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
                  MyTextWidget(
                    " ${LocaleKeys.buy.tr()} ",
                    style: textTheme.titleSmall?.rr.copyWith(
                      fontSize: 9.sp,
                      color: isRedeem
                          ? Color(0xffFF6200)
                          : const Color(0xff414141),
                      height: 0,
                    ),
                  ),
                  isRedeem
                      ? MyTextWidget(
                          HelperFunctions.formatNumber(
                              number: redeemPrice * exchangeRate),
                          //      .toStringAsFixed(widget.decimalPoint),
                          style: textTheme.headlineMedium?.br.copyWith(
                            fontSize: 9.sp,
                            color: Color(0xffFF6200),
                            height: 1.2,
                          ),
                        )
                      : const SizedBox.shrink(),
                  SizedBox(
                    width: 2,
                  ),
                  isRedeem
                      ? MyTextWidget(
                          state.getCurrencyForCountryModel == null
                              ? ""
                              : state.getCurrencyForCountryModel!.data!
                                      .currency!.symbol ??
                                  "",
                          style: TextStyle(
                            fontSize: 8.sp,
                            color: Color(0xffFF6200),
                            height: 1.2,
                          ),
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(width: 3),
                  SvgPicture.asset(
                    AppAssets.bagSvg,
                    height: 12,
                    width: 12,
                  ),
                ],
              ),
            );
          }),
    );
  }
}

Widget buildSingleImage(List<String> colorImages) {
  return SizedBox(
    width: 200,
    height: 300,
    child: colorImages.isNotEmpty
        ? _ImagePageViewWithDots(images: colorImages)
        : Container(
            color: Colors.grey[200],
            child: Icon(Icons.image, size: 50, color: Colors.grey[400]),
          ),
  );
}

class _ImagePageViewWithDots extends StatefulWidget {
  final List<String> images;
  const _ImagePageViewWithDots({Key? key, required this.images})
      : super(key: key);

  @override
  State<_ImagePageViewWithDots> createState() => _ImagePageViewWithDotsState();
}

class _ImagePageViewWithDotsState extends State<_ImagePageViewWithDots> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 200,
          height: 290,
          child: PageView.builder(
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, i) => ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: ProductListingImageWidget(
                imageUrl: widget.images[i],
                width: 200,
                height: 290,
                orginalWidth: 200,
                orginalHeight: 290,
                circleShape: false,
                innerShadowYOffset: 3,
              ),
            ),
          ),
        ),
        if (widget.images.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.images.length,
              (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: _page == i ? Color(0xff8D8D8D) : Color(0xffD3D3D3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          )
      ],
    );
  }
}
