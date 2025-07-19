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
import 'package:trydos/features/app/svg_network_widget.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_image_widget.dart';
import 'package:trydos/features/home/presentation/widgets/second_counter_for_redeem.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:tuple/tuple.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as productListingModel;
import '../../../../../service/language_service.dart';
import '../../../../app/my_text_widget.dart';

/// 🚀 نسخة مبسطة جداً من ProductListing3DSlider - أداء فائق ⚡
class ProductListing3DSliderOptimized extends StatefulWidget {
  const ProductListing3DSliderOptimized({
    super.key,
    // required this.setThisEnabled,
    // required this.slidingModeItem,
    required this.itemIndex,
    this.imageSource,
    required this.tapIndexToAddProductToCart,
    required this.visibleRedeem,
    required this.productItem,
    this.productIsFlashDeal,
    this.fromFlashDeal,
    this.fromHomePage = false,
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
  //final bool displayImageColors;
  final ValueNotifier<bool> visibleRedeem;
  final bool fromHomePage;
  final String? imageSource;
  final bool? fromFlashDeal;
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
      height: 350,
      width: 200,
      child: Column(
        children: [
          // 🖼️ صورة المنتج
          Container(
            height: 230,
            width: 200,
            child: _buildSingleImage(),
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
  Widget _buildSingleImage() {
    // الحصول على أول صورة متاحة
    String? imageUrl;
    double imageHeight = 200;
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

    return Container(
      width: 200,
      height: 200,
      child: (imageUrl != null
          ? ProductListingImageWidget(
              orginalHeight: imageHeight,
              orginalWidth: imageWidth,
              width: 200,
              imageUrl: imageUrl,
              height: 200,
              circleShape: false,
              innerShadowYOffset: 3,
            )
          : Container(
              color: Colors.grey[200],
              child: Icon(Icons.image, size: 50, color: Colors.grey[400]),
            )),
    );
  }

  /// 💰 معلومات المنتج المبسطة
  Widget _buildProductInfo() {
    return Column(
      mainAxisSize: MainAxisSize.min, // تقليل المساحة المستخدمة
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
                const SizedBox(height: 3),
                // Product Name and Category
                _buildProductNameRow(),
              ],
            ),
          ),
        ),
        _buildRedeemSection(),
        const SizedBox(height: 5),
        // Price Section
        _buildPriceSection(),
      ],
    );
  }

  Widget _buildRedeemSection() {
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
  }

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
  Widget _buildProductNameRow() {
    return Row(
      mainAxisAlignment: LanguageService.languageCode == "ar"
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 2),
        // Category Icon
        _buildCategoryIcon(),
        const SizedBox(width: 3),
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
  Widget _buildCategoryIcon() {
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
  }

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
            final currencySymbol =
                state.getCurrencyForCountryModel?.data?.currency?.symbol ?? '';

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
                        bool isRedeem = GetIt.I<PrefsRepository>()
                                    .getRedeemDateForProduct(
                                        widget.productItem.productId.toString())
                                    ?.isAfter(DateTime.now()
                                        .add(Duration(seconds: 1))) ==
                                true &&
                            widget.productItem.hasRedeemDiscount == true;
                        double redeemPrice =
                            widget.productItem.redeemPrice ?? 0;
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
                                fontSize: 11.sp,
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
                              style: textTheme.titleMedium?.bq.copyWith(
                                fontSize: 11.sp,
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
                            isRedeem
                                ? SizedBox.shrink()
                                : MyTextWidget(
                                    state.getCurrencyForCountryModel == null
                                        ? ""
                                        : state.getCurrencyForCountryModel!
                                                .data!.currency!.symbol ??
                                            "",
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                    ),
                                  ),
                            SizedBox(
                              width: 3,
                            ),
                            isRedeem
                                ? MyTextWidget(
                                    HelperFunctions.formatNumber(
                                        number: redeemPrice * exchangeRate),
                                    //      .toStringAsFixed(widget.decimalPoint),
                                    style:
                                        textTheme.headlineMedium?.bq.copyWith(
                                      fontSize: 11.sp,
                                      color: Colors.deepOrangeAccent,
                                      height: 0,
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
                                        : state.getCurrencyForCountryModel!
                                                .data!.currency!.symbol ??
                                            "",
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: Colors.deepOrangeAccent,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ]),
                        );
                      }),
                  // Buy Button
                  _buildCompactBuyButton(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// 🛒 Compact Buy Button - FIXED: أبعاد أصلية
  Widget _buildCompactBuyButton() {
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
        widget.productIsFlashDeal?.value = widget.fromFlashDeal ?? false;

        Future.delayed(
          const Duration(milliseconds: 600),
          () => widget.tapIndexToAddProductToCart.value = widget.itemIndex,
        );
      },
      child: ValueListenableBuilder<bool>(
          valueListenable: widget.visibleRedeem,
          builder: (context, _visibleRedeem, _) {
            bool isRedeem = GetIt.I<PrefsRepository>()
                        .getRedeemDateForProduct(
                            widget.productItem.productId.toString())
                        ?.isAfter(DateTime.now().add(Duration(seconds: 1))) ==
                    true &&
                widget.productItem.hasRedeemDiscount == true;

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
                    LocaleKeys.buy.tr(),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: isRedeem
                              ? Colors.deepOrangeAccent
                              : const Color(0xff414141),
                          height: 1.2,
                        ),
                  ),
                  const SizedBox(width: 3),
                  SvgPicture.asset(
                    AppAssets.bagSvg,
                    height: 12,
                    width: 12,
                    color: isRedeem
                        ? Colors.deepOrangeAccent
                        : const Color(0xff414141),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
