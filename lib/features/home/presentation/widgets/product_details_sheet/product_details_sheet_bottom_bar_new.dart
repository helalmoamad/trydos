import 'dart:math';

import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';

import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trydos/common/helper/helper_functions.dart';

import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';

import 'package:trydos/core/utils/extensions/build_context.dart';

import 'package:trydos/core/utils/extensions/state_ext.dart';

import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/app/my_text_widget.dart';

import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/chat/presentation/manager/chat_state.dart';

import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as product;
import 'package:trydos/features/home/data/models/starting_settings_response_model.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/notify_for_available_in_country.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/notify_for_quantity_available_button.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_sheet_bottom_bar.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/falsh_deal_counter.dart';
import 'package:trydos/features/home/presentation/widgets/second_counter_for_redeem.dart';
import 'package:trydos/features/story/presentation/widget/try_again.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_buttons_event_name.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_events.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import 'package:trydos/service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../../../../common/constant/design/assets_provider.dart';
import '../../../../../core/utils/responsive_padding.dart';

class ProductDetailsSheetBottomBarNew extends StatefulWidget {
  const ProductDetailsSheetBottomBarNew({
    super.key,
    required this.addToBagButtonShapeNotifier,
    required this.clickOnFavorite,
    required this.clickOnComments,
    required this.clickOnShare,
    required this.clickOnMoreOptions,
    required this.panelController,
    required this.productIdForCashProducts,
    required this.productIdForRequestApi,
    required this.colorName,
    required this.colorNum,
    required this.size,
    required this.colorOption,
    required this.productSlug,
    required this.visibleRedeemNotifier,
    required this.countOfPieces,
    required this.colorIsNotAvailableNotifier,
    required this.currentActiveTab,
    required this.collectedAfterOrder,
    required this.products,
    required this.flashDealEndDate,
    required this.isFlashDealEnded,
    required this.visibleFlashDeal,
    required this.isRedeem,
    required this.redeemVariantPrice,
    required this.variationId,
    required this.choiceOption,
    required this.isGetFullProductDetails,
    required this.sizeIsNotAvailableNotifier,
    required this.productNotAvailableNotifier,
    required this.imageUrl,
  });

  final ValueNotifier<int> addToBagButtonShapeNotifier;

  final ValueNotifier<String?> sizeIsNotAvailableNotifier;
  final ValueNotifier<String?> productNotAvailableNotifier;
  final ValueNotifier<String?> colorIsNotAvailableNotifier;
  final PanelController panelController;
  final String imageUrl;
  final int countOfPieces;
  final ValueNotifier<bool> visibleRedeemNotifier;
  final String? flashDealEndDate;
  final bool? isFlashDealEnded;
  final ValueNotifier<bool>? visibleFlashDeal;
  final bool collectedAfterOrder;
  final bool isGetFullProductDetails;
  final product.Products products;

  final String productIdForCashProducts;
  final String productIdForRequestApi;
  final String productSlug;
  final String colorOption;
  final String colorName;
  final String variationId;
  final String choiceOption;
  final bool isRedeem;
  final String colorNum;
  final double redeemVariantPrice;
  final String size;
  final ValueNotifier<int> currentActiveTab;

  final void Function() clickOnFavorite;
  final void Function() clickOnComments;
  final void Function() clickOnShare;
  final void Function() clickOnMoreOptions;

  @override
  State<ProductDetailsSheetBottomBarNew> createState() =>
      _ProductDetailsSheetBottomBarNewState();
}

class _ProductDetailsSheetBottomBarNewState
    extends State<ProductDetailsSheetBottomBarNew>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  late HomeBloc homeBloc;
  int? qtyForProductWithoutVariant;
  @override
  void initState() {
    widget.addToBagButtonShapeNotifier.value = 0;
    homeBloc = BlocProvider.of<HomeBloc>(context);
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    animationController.addStatusListener(_updateStatus);
    super.initState();
  }

  void _updateStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      animationController.reset();
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    /*  bool isCloseToWhite(Color color, {int threshold = 50}) {
      return (color.red > 255 - threshold &&
          color.green > 255 - threshold &&
          color.blue > 255 - threshold);
    }*/

    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) =>
          previous
                  .addImagesToProductIdForCart[widget.productIdForRequestApi]
                  ?.length !=
              current
                  .addImagesToProductIdForCart[widget.productIdForRequestApi]
                  ?.length ||
          previous.currentSelectedColorForEveryProduct[widget.productSlug] !=
              current.currentSelectedColorForEveryProduct[widget.productSlug] ||
          previous.productStatus != current.productStatus ||
          previous.updateItemInCartStatus != current.updateItemInCartStatus ||
          previous.addItemInCartStatus != current.addItemInCartStatus ||
          previous.deleteItemInCartStatus != current.deleteItemInCartStatus ||
          previous.listitemForAddToCart?.length !=
              current.listitemForAddToCart?.length ||
          previous.addOrRemoveLikeOfProductStatus !=
              current.addOrRemoveLikeOfProductStatus ||
          previous.enableAddToCardAfterChangeVariantZero !=
              current.enableAddToCardAfterChangeVariantZero ||
          previous.changeSizesForEveryProduct !=
              current.changeSizesForEveryProduct ||
          previous
                  .cachedProductWithoutRelatedProductsModel[widget
                      .productIdForCashProducts]
                  ?.product
                  ?.sharedCount !=
              current
                  .cachedProductWithoutRelatedProductsModel[widget
                      .productIdForCashProducts]
                  ?.product
                  ?.sharedCount ||
          previous.createCommentRatingStatus !=
              current.createCommentRatingStatus ||
          previous.deleteOrderCommentRatingStatus !=
              current.deleteOrderCommentRatingStatus ||
          previous.updateOrderCommentRatingStatus !=
              current.updateOrderCommentRatingStatus ||
          previous.translateCommentStatus != current.translateCommentStatus,
      builder: (context, state) {
        qtyForProductWithoutVariant =
            state.authProductDetailsModel?.data?.availableQuantity;
        double totalPrice = 0;
        state.cartCollection?.forEach((element) {
          if (element.productId.toString() == widget.productIdForRequestApi) {
            totalPrice = totalPrice + (element.offerPrice! * element.quantity!);
          }
        });
        totalPrice =
            HelperFunctions.truncateToDecimalPlaces(
              totalPrice,
              state.getCurrencyForCountryModel!.data!.currency!.decimalDigits!,
            ) *
            state.getCurrencyForCountryModel!.data!.currency!.exchangeRate!;
        List<Map<String, List<List<String>>>> allCart = [];

        // حلقات متداخلة للوصول إلى جميع القيم
        state.addImagesToProductIdForCart[widget.productIdForRequestApi] != null
            ? state.addImagesToProductIdForCart[widget.productIdForRequestApi]!
                  .forEach((key, value) {
                    if (value.length > 0) {
                      if (value[0].length > 0) {
                        allCart.add({key.toString(): value});
                      }
                    }
                  })
            : [];

        return ValueListenableBuilder<int>(
          valueListenable: widget.currentActiveTab,
          builder: (context, currentTab, _) {
            return ValueListenableBuilder<String?>(
              valueListenable: widget.colorIsNotAvailableNotifier,
              builder: (context, selectedcolorByUser, child) {
                return ValueListenableBuilder<String?>(
                  valueListenable: widget.sizeIsNotAvailableNotifier,
                  builder: (context, selectedSizeByUser, child) {
                    return ValueListenableBuilder<String?>(
                      valueListenable: widget.productNotAvailableNotifier,
                      builder: (context, _productNotAvailableNotifier, child) {
                        homeBloc.add(
                          AddCurrentHeightWhenAddToBagEvent(
                            currentHeightWhenAddToBag: currentTab == 3
                                ? (widget.isRedeem ||
                                          selectedSizeByUser != null ||
                                          selectedcolorByUser != null ||
                                          _productNotAvailableNotifier != null)
                                      ? 130
                                      : allCart.length == 1
                                      ? 160
                                      : allCart.length >= 1
                                      ? 170
                                      : 130
                                : 68,
                          ),
                        );
                        return Container(
                          width: 1.sw,
                          height: currentTab == 3
                              ? (widget.isRedeem ||
                                        selectedSizeByUser != null ||
                                        selectedcolorByUser != null ||
                                        _productNotAvailableNotifier != null)
                                    ? 130.h
                                    : allCart.length == 1
                                    ? 160.h
                                    : allCart.length >= 1
                                    ? 170.h
                                    : 130.h
                              : 68.h,
                          decoration: const BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromARGB(255, 248, 240, 240),
                                blurRadius: 2,
                              ),
                            ],
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: HWEdgeInsets.symmetric(horizontal: 20.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (currentTab == 3) ...{
                                  ValueListenableBuilder<int>(
                                    valueListenable:
                                        widget.addToBagButtonShapeNotifier,
                                    builder: (context, itemCount, _) {
                                      ImageForAddToCart imageForAddToCart =
                                          ImageForAddToCart(
                                            countOfPieces: widget.countOfPieces,
                                            variationId: widget.variationId,
                                            colorNum: widget.colorNum,
                                            choiceOption: widget.choiceOption,
                                            quantity: 1,
                                            images: widget.imageUrl,
                                            colorOption: widget.colorOption,
                                            colorName: widget.colorName,
                                          );
                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            alignment: Alignment.center,
                                            width: 1.sw - 40.w,
                                            height:
                                                (widget.isRedeem ||
                                                    _productNotAvailableNotifier !=
                                                        null ||
                                                    selectedcolorByUser !=
                                                        null ||
                                                    selectedSizeByUser != null)
                                                ? 25.h
                                                : (allCart.length == 1)
                                                ? 62.h
                                                : (allCart.length > 1)
                                                ? 74.h
                                                : 25.h,
                                            margin: EdgeInsets.only(
                                              bottom: 8.h,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10.r),
                                              border: Border.all(
                                                color:
                                                    (_productNotAvailableNotifier !=
                                                            null ||
                                                        selectedcolorByUser !=
                                                            null ||
                                                        selectedSizeByUser !=
                                                            null)
                                                    ? Colors.white
                                                    : widget.isRedeem
                                                    ? const Color(0xffFF6200)
                                                    : (allCart.length > 0)
                                                    ? const Color(0xff513AAF)
                                                    : Colors.white,
                                              ),
                                              color: Colors.white,
                                            ),
                                            child:
                                                _productNotAvailableNotifier !=
                                                    null
                                                ? const SizedBox.shrink()
                                                : selectedcolorByUser != null ||
                                                      selectedSizeByUser != null
                                                ? MyTextWidget(
                                                    LocaleKeys
                                                        .take_a_look_at_other_colors
                                                        .tr(),
                                                    style: textTheme
                                                        .titleMedium
                                                        ?.mq
                                                        .copyWith(
                                                          fontSize: 11.sp,
                                                          height: 15 / 12,
                                                          color: const Color(
                                                            0xff1D1D1D,
                                                          ),
                                                        ),
                                                  )
                                                : widget.isRedeem
                                                ? Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      SizedBox(width: 8.w),
                                                      SvgPicture.asset(
                                                        AppAssets
                                                            .redeemClockSvg,
                                                      ),
                                                      SizedBox(width: 3.w),
                                                      Text(
                                                        LocaleKeys.luck.tr(),
                                                        style: context
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.bq
                                                            .copyWith(
                                                              fontSize: 9.sp,
                                                              color:
                                                                  const Color(
                                                                    0xffFF6200,
                                                                  ),
                                                            ),
                                                      ),
                                                      const SizedBox(width: 1),
                                                      Text(
                                                        " ${LocaleKeys.add_to_bag_within.tr()} ",
                                                        style: context
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.mq
                                                            .copyWith(
                                                              fontSize: 9.sp,
                                                              color:
                                                                  const Color(
                                                                    0xffFF6200,
                                                                  ),
                                                            ),
                                                      ),
                                                      SecondsCountdown(
                                                        denyStopTimer: true,
                                                        productId: widget
                                                            .productIdForRequestApi,
                                                        //   finishRedeem: widget.finishRedeem,
                                                        visibleRedeem: widget
                                                            .visibleRedeemNotifier,
                                                        endTime:
                                                            GetIt.I<
                                                                  PrefsRepository
                                                                >()
                                                                .getRedeemDateForProduct(
                                                                  widget
                                                                      .productIdForRequestApi
                                                                      .toString(),
                                                                ) ??
                                                            DateTime.now(),
                                                      ),
                                                      Text(
                                                        " ${LocaleKeys.seconds.tr()} |",
                                                        style: context
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.bq
                                                            .copyWith(
                                                              fontSize: 9.sp,
                                                              color:
                                                                  const Color(
                                                                    0xffFF6200,
                                                                  ),
                                                            ),
                                                      ),
                                                      Text(
                                                        " ${LocaleKeys.only.tr()} ",
                                                        style: context
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.rq
                                                            .copyWith(
                                                              fontSize: 9.sp,
                                                              height: 1.1,
                                                              color:
                                                                  const Color(
                                                                    0xffFF6200,
                                                                  ),
                                                            ),
                                                      ),
                                                      Text(
                                                        "${HelperFunctions.formatNumber(numberToFormate: (HelperFunctions.truncateToDecimalPlaces(widget.redeemVariantPrice, homeBloc.state.getCurrencyForCountryModel!.data!.currency!.decimalDigits!) * homeBloc.state.getCurrencyForCountryModel!.data!.currency!.exchangeRate!))} ",
                                                        style: context
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.bq
                                                            .copyWith(
                                                              fontSize: 9.sp,
                                                              height: 1.4,
                                                              color:
                                                                  const Color(
                                                                    0xffFF6200,
                                                                  ),
                                                            ),
                                                      ),
                                                      Text(
                                                        homeBloc
                                                            .state
                                                            .getCurrencyForCountryModel!
                                                            .data!
                                                            .currency!
                                                            .symbol!,
                                                        style: context
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.rq
                                                            .copyWith(
                                                              fontSize: 9.sp,
                                                              height: 1.1,
                                                              color:
                                                                  const Color(
                                                                    0xffFF6200,
                                                                  ),
                                                            ),
                                                      ),
                                                    ],
                                                  )
                                                : (allCart.length > 0)
                                                ? Column(
                                                    children: [
                                                      Container(
                                                        height: 25.h,
                                                        width: 1.sw - 40.w,
                                                        decoration: BoxDecoration(
                                                          color: const Color(
                                                            0xff513AAF,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10.r,
                                                              ),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              LocaleKeys.added
                                                                  .tr(),
                                                              style: context
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.rq
                                                                  .copyWith(
                                                                    color: const Color(
                                                                      0xffFCFCFC,
                                                                    ),
                                                                    letterSpacing:
                                                                        0.18,
                                                                    fontSize:
                                                                        10.sp,
                                                                    height: 1.3,
                                                                  ),
                                                            ),
                                                            Text(
                                                              " ${allCart.length} ",
                                                              style: context
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.bq
                                                                  .copyWith(
                                                                    color: const Color(
                                                                      0xffFCFCFC,
                                                                    ),
                                                                    letterSpacing:
                                                                        0.18,
                                                                    fontSize:
                                                                        10.sp,
                                                                    height: 1.3,
                                                                  ),
                                                            ),
                                                            Text(
                                                              "${LocaleKeys.item.tr()} ",
                                                              style: context
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.rq
                                                                  .copyWith(
                                                                    color: const Color(
                                                                      0xffFCFCFC,
                                                                    ),
                                                                    letterSpacing:
                                                                        0.18,
                                                                    fontSize:
                                                                        10.sp,
                                                                    height: 1.3,
                                                                  ),
                                                            ),
                                                            Text(
                                                              "${HelperFunctions.formatNumber(numberToFormate: totalPrice)} ",
                                                              style: context
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.bq
                                                                  .copyWith(
                                                                    color: const Color(
                                                                      0xffFCFCFC,
                                                                    ),
                                                                    letterSpacing:
                                                                        0.18,
                                                                    fontSize:
                                                                        10.sp,
                                                                    height: 1.3,
                                                                  ),
                                                            ),
                                                            Text(
                                                              "${homeBloc.state.getCurrencyForCountryModel!.data!.currency?.symbol ?? ""} ${LocaleKeys.to_your_bag.tr()}",
                                                              style: context
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.rq
                                                                  .copyWith(
                                                                    color: const Color(
                                                                      0xffFCFCFC,
                                                                    ),
                                                                    letterSpacing:
                                                                        0.18,
                                                                    fontSize:
                                                                        10.sp,
                                                                    height: 1.3,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(height: 5.h),
                                                      SizedBox(
                                                        height:
                                                            allCart.length > 1
                                                            ? 40.h
                                                            : 28.h,
                                                        width:
                                                            1.sw -
                                                            40.w, // أو 10.h إذا كنت تستخدم screenutil
                                                        child: ListView.builder(
                                                          padding: EdgeInsets.only(
                                                            top:
                                                                (allCart.length >
                                                                    1)
                                                                ? 0
                                                                : 5.h,
                                                          ),
                                                          itemBuilder: (context, index) {
                                                            String
                                                            imagePath = addSuitableWidthAndHeightToImage(
                                                              imageUrl:
                                                                  allCart[index]
                                                                      .values
                                                                      .first[0][0],
                                                              width: 10.w,
                                                              height: 10.h,
                                                            );
                                                            return SizedBox(
                                                              width:
                                                                  1.sw - 40.w,
                                                              height: 15.h,
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  SizedBox(
                                                                    width:
                                                                        (allCart[index].values.first.length *
                                                                                5.0)
                                                                            .w +
                                                                        5.0.w, // (عدد الصور * مقدار التراكب) + نصف صورة أخيرة
                                                                    height:
                                                                        12.h,
                                                                    child: Stack(
                                                                      children: List.generate(
                                                                        allCart[index]
                                                                            .values
                                                                            .first
                                                                            .length,
                                                                        (
                                                                          i,
                                                                        ) => Positioned(
                                                                          left:
                                                                              i *
                                                                              5.0, // كل صورة تتحرك 5 بكسل فقط (نصف حجمها)
                                                                          child: CircleAvatar(
                                                                            radius:
                                                                                5.r, // نصف القطر = 5 (لأن القطر 10)
                                                                            backgroundColor:
                                                                                Colors.deepPurple, // لون الإطار الخارجي
                                                                            child: CircleAvatar(
                                                                              radius: 4.5.r, // أصغر قليلاً ليظهر الإطار
                                                                              backgroundImage: NetworkImage(
                                                                                imagePath,
                                                                              ),
                                                                              backgroundColor: Colors.white,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 5.w,
                                                                  ),
                                                                  Text(
                                                                    "${allCart[index].values.first.length} ${LocaleKeys.item.tr()} ",
                                                                    style: context
                                                                        .textTheme
                                                                        .bodyMedium
                                                                        ?.rq
                                                                        .copyWith(
                                                                          color: const Color(
                                                                            0xff1D1D1D,
                                                                          ),
                                                                          letterSpacing:
                                                                              0.18,
                                                                          fontSize:
                                                                              10.sp,
                                                                          height:
                                                                              1.3,
                                                                        ),
                                                                  ),
                                                                  Text(
                                                                    allCart[index].values.first[0][1] ==
                                                                            "null"
                                                                        ? ""
                                                                        : "${LocaleKeys.color.tr()} ",
                                                                    style: context
                                                                        .textTheme
                                                                        .bodyMedium
                                                                        ?.rq
                                                                        .copyWith(
                                                                          color: const Color(
                                                                            0xff1D1D1D,
                                                                          ),
                                                                          letterSpacing:
                                                                              0.18,
                                                                          fontSize:
                                                                              10.sp,
                                                                          height:
                                                                              1.3,
                                                                        ),
                                                                  ),
                                                                  Text(
                                                                    allCart[index].values.first[0][1] ==
                                                                            "null"
                                                                        ? ""
                                                                        : allCart[index]
                                                                              .values
                                                                              .first[0][1],
                                                                    style: context
                                                                        .textTheme
                                                                        .bodyMedium
                                                                        ?.bq
                                                                        .copyWith(
                                                                          color: const Color(
                                                                            0xff1D1D1D,
                                                                          ),
                                                                          letterSpacing:
                                                                              0.18,
                                                                          fontSize:
                                                                              10.sp,
                                                                          height:
                                                                              1.6,
                                                                        ),
                                                                  ),
                                                                  Text(
                                                                    (allCart[index].values.first[0][2] ==
                                                                                "null" ||
                                                                            allCart[index].values.first[0][1] ==
                                                                                "null")
                                                                        ? ""
                                                                        : " | ",
                                                                    style: context
                                                                        .textTheme
                                                                        .bodyMedium
                                                                        ?.rq
                                                                        .copyWith(
                                                                          color: const Color(
                                                                            0xff1D1D1D,
                                                                          ),
                                                                          letterSpacing:
                                                                              0.18,
                                                                          fontSize:
                                                                              10.sp,
                                                                          height:
                                                                              1.3,
                                                                        ),
                                                                  ),
                                                                  Text(
                                                                    allCart[index].values.first[0][2] ==
                                                                            "null"
                                                                        ? ""
                                                                        : "${LocaleKeys.size.tr()} ",
                                                                    style: context
                                                                        .textTheme
                                                                        .bodyMedium
                                                                        ?.rq
                                                                        .copyWith(
                                                                          color: const Color(
                                                                            0xff1D1D1D,
                                                                          ),
                                                                          letterSpacing:
                                                                              0.18,
                                                                          fontSize:
                                                                              10.sp,
                                                                          height:
                                                                              1.3,
                                                                        ),
                                                                  ),
                                                                  Text(
                                                                    allCart[index].values.first[0][2] ==
                                                                            "null"
                                                                        ? ""
                                                                        : allCart[index]
                                                                              .values
                                                                              .first[0][2],
                                                                    style: context
                                                                        .textTheme
                                                                        .bodyMedium
                                                                        ?.bq
                                                                        .copyWith(
                                                                          color: const Color(
                                                                            0xff1D1D1D,
                                                                          ),
                                                                          letterSpacing:
                                                                              0.18,
                                                                          fontSize:
                                                                              10.sp,
                                                                          height:
                                                                              1.3,
                                                                        ),
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                          itemCount:
                                                              allCart.length,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : !((widget.flashDealEndDate ??
                                                              "") ==
                                                          "" ||
                                                      (widget.isFlashDealEnded ??
                                                          true))
                                                ? SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                          decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  10.r,
                                                                ),
                                                            border: Border.all(
                                                              color:
                                                                  const Color(
                                                                    0xffFF6200,
                                                                  ),
                                                            ),
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              const SizedBox(
                                                                width: 2,
                                                              ),
                                                              SvgPicture.asset(
                                                                AppAssets
                                                                    .flashDealSvg,
                                                                height: 9.sp,
                                                                // ignore: deprecated_member_use
                                                                color:
                                                                    const Color(
                                                                      0xffFF6200,
                                                                    ),
                                                              ),
                                                              const SizedBox(
                                                                width: 2,
                                                              ),
                                                              Text(
                                                                "${LocaleKeys.flash_deal.tr()}",
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: context
                                                                    .textTheme
                                                                    .bodyMedium
                                                                    ?.bq
                                                                    .copyWith(
                                                                      color: const Color(
                                                                        0xffFF6200,
                                                                      ),
                                                                      letterSpacing:
                                                                          0.18,
                                                                      fontSize:
                                                                          9.sp,
                                                                      height:
                                                                          1.3,
                                                                    ),
                                                              ),
                                                              const SizedBox(
                                                                width: 2,
                                                              ),
                                                              FlashDealCountdownTimerWidget(
                                                                visibleFlashDeal:
                                                                    widget
                                                                        .visibleFlashDeal,
                                                                endDateString:
                                                                    widget
                                                                        .flashDealEndDate ??
                                                                    "",
                                                              ),
                                                              const SizedBox(
                                                                width: 2,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 2,
                                                        ),
                                                        Row(
                                                          children: [
                                                            // ignore: deprecated_member_use
                                                            SvgPicture.asset(
                                                              AppAssets
                                                                  .fastPackingManIconSvg,
                                                              // ignore: deprecated_member_use
                                                              color:
                                                                  const Color(
                                                                    0xff388CFF,
                                                                  ),
                                                              height: 12.h,
                                                            ),
                                                            Text(
                                                              " ${LocaleKeys.fast_packing.tr()} ",
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: context
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.bq
                                                                  .copyWith(
                                                                    color: const Color(
                                                                      0xff388CFF,
                                                                    ),
                                                                    letterSpacing:
                                                                        0.18,
                                                                    fontSize:
                                                                        9.sp,
                                                                    height: 1.3,
                                                                  ),
                                                            ),
                                                            Text(
                                                              LocaleKeys
                                                                  .today_shipping_if_buy_before
                                                                  .tr(),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: context
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.rq
                                                                  .copyWith(
                                                                    color: const Color(
                                                                      0xff388CFF,
                                                                    ),
                                                                    letterSpacing:
                                                                        0.18,
                                                                    fontSize:
                                                                        9.sp,
                                                                    height: 1.3,
                                                                  ),
                                                            ),
                                                            Text(
                                                              " 13:00",
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: context
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.bq
                                                                  .copyWith(
                                                                    color: const Color(
                                                                      0xff388CFF,
                                                                    ),
                                                                    letterSpacing:
                                                                        0.18,
                                                                    fontSize:
                                                                        9.sp,
                                                                    height: 1.3,
                                                                  ),
                                                            ),
                                                            Text(
                                                              " ${LocaleKeys.today.tr()} ",
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: context
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.rq
                                                                  .copyWith(
                                                                    color: const Color(
                                                                      0xff388CFF,
                                                                    ),
                                                                    letterSpacing:
                                                                        0.18,
                                                                    fontSize:
                                                                        9.sp,
                                                                    height: 1.3,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      widget.colorNum == ""
                                                          ? const SizedBox.shrink()
                                                          : MyTextWidget(
                                                              '${LocaleKeys.color.tr()} ',
                                                              style: textTheme
                                                                  .titleMedium
                                                                  ?.rq
                                                                  .copyWith(
                                                                    fontSize:
                                                                        10.sp,
                                                                    height:
                                                                        15 / 12,
                                                                    color: const Color(
                                                                      0xff1D1D1D,
                                                                    ),
                                                                  ),
                                                            ),
                                                      widget.colorNum == ""
                                                          ? const SizedBox.shrink()
                                                          : MyTextWidget(
                                                              '${widget.colorName}',
                                                              style: textTheme
                                                                  .titleMedium
                                                                  ?.bq
                                                                  .copyWith(
                                                                    fontSize:
                                                                        10.sp,
                                                                    height:
                                                                        15 / 12,
                                                                    color: const Color(
                                                                      0xff1D1D1D,
                                                                    ),
                                                                  ),
                                                            ),
                                                      widget.size == "" &&
                                                              widget.colorNum !=
                                                                  ""
                                                          ? const SizedBox.shrink()
                                                          : MyTextWidget(
                                                              ' | ',
                                                              style: textTheme
                                                                  .titleMedium
                                                                  ?.rq
                                                                  .copyWith(
                                                                    fontSize:
                                                                        10.sp,
                                                                    height:
                                                                        15 / 12,
                                                                    color: const Color(
                                                                      0xff1D1D1D,
                                                                    ),
                                                                  ),
                                                            ),
                                                      widget.size == ""
                                                          ? const SizedBox.shrink()
                                                          : MyTextWidget(
                                                              '${LocaleKeys.size.tr()} ',
                                                              style: textTheme
                                                                  .titleMedium
                                                                  ?.rq
                                                                  .copyWith(
                                                                    fontSize:
                                                                        10.sp,
                                                                    height:
                                                                        15 / 12,
                                                                    color: const Color(
                                                                      0xff1D1D1D,
                                                                    ),
                                                                  ),
                                                            ),
                                                      widget.size == ""
                                                          ? const SizedBox.shrink()
                                                          : MyTextWidget(
                                                              '${widget.size} ',
                                                              style: textTheme
                                                                  .titleMedium
                                                                  ?.bq
                                                                  .copyWith(
                                                                    fontSize:
                                                                        10.sp,
                                                                    height:
                                                                        15 / 12,
                                                                    color: const Color(
                                                                      0xff1D1D1D,
                                                                    ),
                                                                  ),
                                                            ),
                                                    ],
                                                  ),
                                          ),
                                          AnimatedSwitcher(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            reverseDuration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            transitionBuilder:
                                                (child, animation) {
                                                  return SlideTransition(
                                                    position: Tween(
                                                      begin: const Offset(
                                                        -1.0,
                                                        0.0,
                                                      ),
                                                      end: const Offset(
                                                        0.0,
                                                        0.0,
                                                      ),
                                                    ).animate(animation),
                                                    child: child,
                                                  );
                                                },
                                            child:
                                                !(_productNotAvailableNotifier !=
                                                    null)
                                                ? (qtyForProductWithoutVariant !=
                                                                  0 &&
                                                              (selectedSizeByUser ==
                                                                  null) &&
                                                              (selectedcolorByUser ==
                                                                  null)) ||
                                                          widget
                                                              .collectedAfterOrder
                                                      ? (state.getProductDetailWithoutSimilarRelatedProductsStatus ==
                                                                    GetProductDetailWithoutSimilarRelatedProductsStatus
                                                                        .failure ||
                                                                state.authProductDetailsStatus ==
                                                                    AuthProductDetailsStatus
                                                                        .failure)
                                                            ? Container(
                                                                width: 120.w,
                                                                height: 60.h,
                                                                decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        15.r,
                                                                      ),
                                                                ),
                                                                child: TryAgainWidget(
                                                                  tryAgain: () {
                                                                    if (!(widget
                                                                        .isGetFullProductDetails)) {
                                                                      homeBloc.add(
                                                                        GetProductDatailsWithoutRelatedProductsEvent(
                                                                          productSlug:
                                                                              widget.productSlug,
                                                                          productId: widget
                                                                              .products
                                                                              .productId
                                                                              .toString()
                                                                              .toString(),
                                                                        ),
                                                                      );
                                                                    } else {
                                                                      BlocProvider.of<
                                                                            HomeBloc
                                                                          >(context)
                                                                          .add(
                                                                            GetFullProductDetailsEvent(
                                                                              productSlug: widget.productSlug,
                                                                            ),
                                                                          );
                                                                    }
                                                                  },
                                                                ),
                                                              )
                                                            : (state.getProductDetailWithoutSimilarRelatedProductsStatus !=
                                                                      GetProductDetailWithoutSimilarRelatedProductsStatus
                                                                          .success ||
                                                                  state.changeSizesForEveryProduct !=
                                                                      ChangeSizesForEveryProduct
                                                                          .success ||
                                                                  state.enableAddToCardAfterChangeVariantZero !=
                                                                      EnableAddToCardAfterChangeVariantZero
                                                                          .success)
                                                            ? Stack(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                children: [
                                                                  Shimmer.fromColors(
                                                                    baseColor: Colors
                                                                        .grey
                                                                        .shade300,
                                                                    highlightColor:
                                                                        Colors
                                                                            .grey
                                                                            .shade100,
                                                                    child: Container(
                                                                      width:
                                                                          97.w,
                                                                      height:
                                                                          60.h,
                                                                      decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              20.r,
                                                                            ),
                                                                        color: Colors
                                                                            .grey
                                                                            .shade300,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Shimmer.fromColors(
                                                                    baseColor: Colors
                                                                        .grey
                                                                        .shade400,
                                                                    highlightColor:
                                                                        Colors
                                                                            .grey
                                                                            .shade100,
                                                                    child: SvgPicture.asset(
                                                                      AppAssets
                                                                          .addBagNewSvg,
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                            : GestureDetector(
                                                                onTapDown: (details) {
                                                                  HapticFeedback.lightImpact();
                                                                  if (itemCount >
                                                                      0) {
                                                                    if (state.updateItemInCartStatus ==
                                                                            UpdateItemInCartStatus.loading ||
                                                                        state.addItemInCartStatus ==
                                                                            AddItemInCartStatus.loading ||
                                                                        state.deleteItemInCartStatus ==
                                                                            DeleteItemInCartStatus.loading) {
                                                                      return;
                                                                    }
                                                                    if (details
                                                                            .localPosition
                                                                            .dx <=
                                                                        92.w) {
                                                                      homeBloc.add(
                                                                        UpdateItemInCartEvent(
                                                                          fromCartPage:
                                                                              false,
                                                                          newQuantity:
                                                                              -1,
                                                                          maxAllowed:
                                                                              0,
                                                                          currentSize:
                                                                              state.addVariationToCartId?[allCart.last.keys.last]?["size"] ??
                                                                              "",
                                                                          colorOption:
                                                                              state.addVariationToCartId?[allCart.last.keys.last]?["color"] ??
                                                                              "",
                                                                          productId:
                                                                              widget.productIdForRequestApi,
                                                                          totalQuantity:
                                                                              (state
                                                                                      .addImagesToProductIdForCart[widget.productIdForRequestApi]?[int.tryParse(
                                                                                        allCart.last.keys.last,
                                                                                      )]
                                                                                      ?.length ??
                                                                                  0) -
                                                                              1,
                                                                          image: (state
                                                                              .addImagesToProductIdForCart[widget.productIdForRequestApi]?[int.tryParse(
                                                                                allCart.last.keys.last,
                                                                              )]
                                                                              ?.last)![0],
                                                                          cartId: allCart
                                                                              .last
                                                                              .keys
                                                                              .last,
                                                                          boutiqueId:
                                                                              "",
                                                                        ),
                                                                      );
                                                                      return;
                                                                    }
                                                                    animationController
                                                                        .forward();

                                                                    widget
                                                                        .addToBagButtonShapeNotifier
                                                                        .value++;
                                                                    homeBloc.add(
                                                                      UpdateListOfItemForAddToCartEvent(
                                                                        productId:
                                                                            widget.productIdForRequestApi,
                                                                        imageForAddToCart:
                                                                            imageForAddToCart,
                                                                        operation:
                                                                            "+",
                                                                      ),
                                                                    );
                                                                    homeBloc.add(
                                                                      AddMultiItemsToCartEvent(
                                                                        isRedeem:
                                                                            widget.isRedeem,
                                                                        fromCartPage:
                                                                            false,
                                                                        redeemVariantPrice:
                                                                            widget.redeemVariantPrice,
                                                                        maxAllowed:
                                                                            state.cachedProductWithoutRelatedProductsModel[widget.productIdForRequestApi]?.product?.maxAllowedQty ??
                                                                            "0",
                                                                        boutiqueIcon:
                                                                            state.cachedProductWithoutRelatedProductsModel[widget.productIdForRequestApi] !=
                                                                                null
                                                                            ? state.cachedProductWithoutRelatedProductsModel[widget.productIdForRequestApi]!.product !=
                                                                                      null
                                                                                  ? state.cachedProductWithoutRelatedProductsModel[widget.productIdForRequestApi]!.product!.boutique !=
                                                                                            null
                                                                                        ? state.cachedProductWithoutRelatedProductsModel[widget.productIdForRequestApi]!.product!.boutique!.icon !=
                                                                                                  null
                                                                                              ? state.cachedProductWithoutRelatedProductsModel[widget.productIdForRequestApi]!.product!.boutique!.icon!.filePath ??
                                                                                                    ""
                                                                                              : ""
                                                                                        : ""
                                                                                  : ""
                                                                            : "",
                                                                        productSlugForTopic:
                                                                            state.cachedProductWithoutRelatedProductsModel[widget.productIdForRequestApi]?.product?.slug ??
                                                                            "",
                                                                        boutiqueId:
                                                                            state.cachedProductWithoutRelatedProductsModel[widget.productIdForRequestApi] !=
                                                                                null
                                                                            ? state.cachedProductWithoutRelatedProductsModel[widget.productIdForRequestApi]!.product!.boutique !=
                                                                                      null
                                                                                  ? state.cachedProductWithoutRelatedProductsModel[widget.productIdForRequestApi]!.product!.boutique!.id!
                                                                                  : 0
                                                                            : 0,
                                                                        products:
                                                                            widget.products,
                                                                        id:
                                                                            state.cachedProductWithoutRelatedProductsModel[widget.productIdForRequestApi] !=
                                                                                null
                                                                            ? state.cachedProductWithoutRelatedProductsModel[widget.productIdForRequestApi]!.product !=
                                                                                      null
                                                                                  ? state.cachedProductWithoutRelatedProductsModel[widget.productIdForRequestApi]!.product!.id.toString()
                                                                                  : ""
                                                                            : "",
                                                                      ),
                                                                    );
                                                                  } else {
                                                                    if (state.updateItemInCartStatus ==
                                                                            UpdateItemInCartStatus.loading ||
                                                                        state.addItemInCartStatus ==
                                                                            AddItemInCartStatus.loading ||
                                                                        state.deleteItemInCartStatus ==
                                                                            DeleteItemInCartStatus.loading) {
                                                                      return;
                                                                    }
                                                                    animationController
                                                                        .forward();

                                                                    widget
                                                                        .addToBagButtonShapeNotifier
                                                                        .value++;
                                                                    homeBloc.add(
                                                                      UpdateListOfItemForAddToCartEvent(
                                                                        productId:
                                                                            widget.productIdForRequestApi,
                                                                        imageForAddToCart:
                                                                            imageForAddToCart,
                                                                        operation:
                                                                            "+",
                                                                      ),
                                                                    );
                                                                    homeBloc.add(
                                                                      AddMultiItemsToCartEvent(
                                                                        fromCartPage:
                                                                            false,
                                                                        isRedeem:
                                                                            widget.isRedeem,
                                                                        redeemVariantPrice:
                                                                            widget.redeemVariantPrice,
                                                                        maxAllowed:
                                                                            state.cachedProductWithoutRelatedProductsModel[widget.productIdForRequestApi]?.product?.maxAllowedQty ??
                                                                            "0",
                                                                        boutiqueIcon:
                                                                            state.cachedProductWithoutRelatedProductsModel[widget.productIdForRequestApi] !=
                                                                                null
                                                                            ? state.cachedProductWithoutRelatedProductsModel[widget.productIdForRequestApi]!.product !=
                                                                                      null
                                                                                  ? state.cachedProductWithoutRelatedProductsModel[widget.productIdForRequestApi]!.product!.boutique !=
                                                                                            null
                                                                                        ? state.cachedProductWithoutRelatedProductsModel[widget.productIdForRequestApi]!.product!.boutique!.icon !=
                                                                                                  null
                                                                                              ? state.cachedProductWithoutRelatedProductsModel[widget.productIdForRequestApi]!.product!.boutique!.icon!.filePath ??
                                                                                                    ""
                                                                                              : ""
                                                                                        : ""
                                                                                  : ""
                                                                            : "",
                                                                        productSlugForTopic:
                                                                            state.cachedProductWithoutRelatedProductsModel[widget.productIdForRequestApi]?.product?.slug ??
                                                                            "",
                                                                        boutiqueId:
                                                                            state.cachedProductWithoutRelatedProductsModel[widget.productIdForRequestApi] !=
                                                                                null
                                                                            ? state.cachedProductWithoutRelatedProductsModel[widget.productIdForRequestApi]!.product!.boutique !=
                                                                                      null
                                                                                  ? state.cachedProductWithoutRelatedProductsModel[widget.productIdForRequestApi]!.product!.boutique!.id!
                                                                                  : 0
                                                                            : 0,
                                                                        products:
                                                                            widget.products,
                                                                        id:
                                                                            state.cachedProductWithoutRelatedProductsModel[widget.productIdForRequestApi] !=
                                                                                null
                                                                            ? state.cachedProductWithoutRelatedProductsModel[widget.productIdForRequestApi]!.product !=
                                                                                      null
                                                                                  ? state.cachedProductWithoutRelatedProductsModel[widget.productIdForRequestApi]!.product!.id.toString()
                                                                                  : ""
                                                                            : "",
                                                                      ),
                                                                    );
                                                                    //////////////////////////////
                                                                    // FirebaseAnalyticsService.logEventForSession(
                                                                    //   eventName: AnalyticsEventsConst.buttonClicked,
                                                                    //   executedEventName: AnalyticsButtonsEventNameConst.increaseQtyButton,
                                                                    // );
                                                                  }
                                                                },
                                                                child: AnimatedBuilder(
                                                                  animation:
                                                                      animationController,
                                                                  builder:
                                                                      (
                                                                        context,
                                                                        child,
                                                                      ) {
                                                                        final sineValue = sin(
                                                                          3 *
                                                                              2 *
                                                                              pi *
                                                                              animationController.value,
                                                                        );
                                                                        return Transform.translate(
                                                                          offset: Offset(
                                                                            sineValue *
                                                                                3,
                                                                            0,
                                                                          ),
                                                                          child: SizedBox(
                                                                            width:
                                                                                1.sw -
                                                                                60.w,
                                                                            height:
                                                                                68.h,
                                                                            child: Stack(
                                                                              alignment: Alignment.topRight,
                                                                              children: [
                                                                                AnimatedContainer(
                                                                                  duration: const Duration(
                                                                                    milliseconds: 300,
                                                                                  ),
                                                                                  curve: Curves.fastLinearToSlowEaseIn,
                                                                                  decoration: BoxDecoration(
                                                                                    border: Border.all(
                                                                                      color: const Color(
                                                                                        0xff513AAF,
                                                                                      ),
                                                                                    ),
                                                                                    borderRadius: BorderRadius.circular(
                                                                                      20.r,
                                                                                    ),
                                                                                    color: const Color(
                                                                                      0xff513AAF,
                                                                                    ),
                                                                                  ),
                                                                                  child: Center(
                                                                                    child: Padding(
                                                                                      padding: EdgeInsets.symmetric(
                                                                                        vertical: 5.h,
                                                                                      ),
                                                                                      child: Column(
                                                                                        children: [
                                                                                          state.updateItemInCartStatus ==
                                                                                                      UpdateItemInCartStatus.loading ||
                                                                                                  state.addItemInCartStatus ==
                                                                                                      AddItemInCartStatus.loading ||
                                                                                                  state.deleteItemInCartStatus ==
                                                                                                      DeleteItemInCartStatus.loading
                                                                                              ? TrydosLoader(
                                                                                                  size: 20.r,
                                                                                                  color: Colors.white,
                                                                                                )
                                                                                              : allCart.length ==
                                                                                                    0
                                                                                              ? SvgPicture.asset(
                                                                                                  AppAssets.addBagNewSvg,
                                                                                                )
                                                                                              : Row(
                                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                                                                  children: [
                                                                                                    SvgPicture.asset(
                                                                                                      AppAssets.addBagNewSvg,
                                                                                                    ),
                                                                                                    SizedBox(
                                                                                                      width: 5.w,
                                                                                                    ),
                                                                                                    Text(
                                                                                                      "X",
                                                                                                      style: context.textTheme.bodyMedium?.rq.copyWith(
                                                                                                        color: const Color(
                                                                                                          0xffFFFFFF,
                                                                                                        ),
                                                                                                        letterSpacing: 0.18,
                                                                                                        fontSize: 15.sp,
                                                                                                        height: 1.3,
                                                                                                      ),
                                                                                                    ),
                                                                                                    SizedBox(
                                                                                                      width: 5.w,
                                                                                                    ),
                                                                                                    Text(
                                                                                                      "${allCart.length}",
                                                                                                      style: context.textTheme.bodyMedium?.mq.copyWith(
                                                                                                        color: const Color(
                                                                                                          0xffFFFFFF,
                                                                                                        ),
                                                                                                        letterSpacing: 0.18,
                                                                                                        fontSize: 15.sp,
                                                                                                        height: 1.3,
                                                                                                      ),
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
                                                                                          SizedBox(
                                                                                            height: 5.h,
                                                                                          ),
                                                                                          Row(
                                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                                            children: [
                                                                                              allCart.length >
                                                                                                      0
                                                                                                  ? MyTextWidget(
                                                                                                      '${LocaleKeys.add_more_to_bag.tr()}',
                                                                                                      style: textTheme.titleMedium?.mq.copyWith(
                                                                                                        height:
                                                                                                            15 /
                                                                                                            12,
                                                                                                        fontSize: 15.sp,
                                                                                                        color: const Color(
                                                                                                          0xffFFFFFF,
                                                                                                        ),
                                                                                                      ),
                                                                                                    )
                                                                                                  : MyTextWidget(
                                                                                                      '${LocaleKeys.add.tr()} ${LocaleKeys.tto.tr()} ${LocaleKeys.bag.tr()}',
                                                                                                      style: textTheme.titleMedium?.mq.copyWith(
                                                                                                        height:
                                                                                                            15 /
                                                                                                            12,
                                                                                                        fontSize: 15.sp,
                                                                                                        color: const Color(
                                                                                                          0xffFFFFFF,
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                            ],
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                if (allCart.length >
                                                                                    0) ...{
                                                                                  Positioned(
                                                                                    top: -35.h,
                                                                                    left: -35.w,
                                                                                    child: Container(
                                                                                      width: 55.w,
                                                                                      height: 55.h,
                                                                                      decoration: BoxDecoration(
                                                                                        border: Border.all(
                                                                                          color: widget.isRedeem
                                                                                              ? Colors.deepOrangeAccent
                                                                                              : Colors.blue,
                                                                                        ),
                                                                                        borderRadius: BorderRadius.circular(
                                                                                          20.r,
                                                                                        ),
                                                                                        color: colorScheme.white,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  Positioned(
                                                                                    left: 0,
                                                                                    child: Padding(
                                                                                      padding: EdgeInsets.only(
                                                                                        top:
                                                                                            (allCart.length ==
                                                                                                    1 &&
                                                                                                allCart[0].values.first.length ==
                                                                                                    1)
                                                                                            ? 0.h
                                                                                            : 7.h,
                                                                                      ),
                                                                                      child: Center(
                                                                                        child: SvgPicture.asset(
                                                                                          (allCart.length ==
                                                                                                      1 &&
                                                                                                  allCart[0].values.first.length ==
                                                                                                      1)
                                                                                              ? AppAssets.binSvg
                                                                                              : AppAssets.minusMarkSvg,

                                                                                          height:
                                                                                              (allCart.length ==
                                                                                                      1 &&
                                                                                                  allCart[0].values.first.length ==
                                                                                                      1)
                                                                                              ? 15.h
                                                                                              : 3.h,
                                                                                          // ignore: deprecated_member_use
                                                                                          color:
                                                                                              (allCart.length ==
                                                                                                      1 &&
                                                                                                  allCart[0].values.first.length ==
                                                                                                      1)
                                                                                              ? const Color(
                                                                                                  0xffFF5F61,
                                                                                                )
                                                                                              : const Color(
                                                                                                  0xff513AAF,
                                                                                                ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                },
                                                                                Positioned(
                                                                                  top: -35.h,
                                                                                  right: -35.w,
                                                                                  child: Container(
                                                                                    width: 55.w,
                                                                                    height: 55.h,
                                                                                    decoration: BoxDecoration(
                                                                                      borderRadius: BorderRadius.circular(
                                                                                        20.r,
                                                                                      ),
                                                                                      border: Border.all(
                                                                                        color: widget.isRedeem
                                                                                            ? Colors.deepOrangeAccent
                                                                                            : Colors.blue,
                                                                                      ),
                                                                                      color: colorScheme.white,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                SvgPicture.asset(
                                                                                  AppAssets.plusMarkSvg,
                                                                                  // ignore: deprecated_member_use
                                                                                  color: const Color(
                                                                                    0xff513AAF,
                                                                                  ),
                                                                                  height: 15.h,
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        );
                                                                      },
                                                                ),
                                                              )
                                                      : BlocBuilder<
                                                          HomeBloc,
                                                          HomeState
                                                        >(
                                                          buildWhen: (p, c) =>
                                                              p.getStartingSettingsStatus !=
                                                              c.getStartingSettingsStatus,
                                                          builder: (context, state) {
                                                            int
                                                            notificationTypeId =
                                                                state
                                                                    .startingSetting
                                                                    ?.notificationTypes
                                                                    ?.firstWhere(
                                                                      (type) =>
                                                                          type.name ==
                                                                          'product availability',
                                                                      orElse: () =>
                                                                          NotificationType(
                                                                            id: -1,
                                                                          ),
                                                                    )
                                                                    .id ??
                                                                -1;

                                                            return notificationTypeId ==
                                                                    -1
                                                                ? const SizedBox.shrink()
                                                                : NotifyWhenQuantityAvailableButton(
                                                                    currentTap:
                                                                        currentTab,
                                                                    productItem:
                                                                        widget
                                                                            .products,
                                                                    unAvailableSize:
                                                                        selectedSizeByUser ??
                                                                        "",
                                                                    notificationTypeId:
                                                                        notificationTypeId,
                                                                    productId:
                                                                        widget
                                                                            .productIdForRequestApi,
                                                                    selectedColorName:
                                                                        selectedcolorByUser ??
                                                                        "",
                                                                  );
                                                          },
                                                        )
                                                : NotifyWhenAvailableInCountryButton(
                                                    currentTap: currentTab,
                                                    productItem:
                                                        widget.products,
                                                    productId: widget
                                                        .productIdForRequestApi,
                                                    unAvailableType:
                                                        _productNotAvailableNotifier,
                                                  ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                },
                                if (currentTab != 3) ...{
                                  BlocBuilder<HomeBloc, HomeState>(
                                    buildWhen: (previous, current) =>
                                        previous.addOrRemoveLikeOfProductStatus !=
                                            current
                                                .addOrRemoveLikeOfProductStatus ||
                                        previous.productStatus !=
                                            current.productStatus ||
                                        previous.getProductDetailWithoutSimilarRelatedProductsStatus !=
                                            current
                                                .getProductDetailWithoutSimilarRelatedProductsStatus ||
                                        previous.authProductDetailsStatus !=
                                            current.authProductDetailsStatus,
                                    builder: (context, state) {
                                      return state.getProductDetailWithoutSimilarRelatedProductsStatus ==
                                                  GetProductDetailWithoutSimilarRelatedProductsStatus
                                                      .loading ||
                                              state.authProductDetailsStatus ==
                                                  AuthProductDetailsStatus
                                                      .loading
                                          ? Shimmer.fromColors(
                                              baseColor: Colors.grey.shade400,
                                              highlightColor:
                                                  Colors.grey.shade100,
                                              child: SvgPicture.asset(
                                                (state
                                                            .cachedProductWithoutRelatedProductsModel[widget
                                                                .productIdForCashProducts]
                                                            ?.product
                                                            ?.isLiked ??
                                                        false)
                                                    ? AppAssets
                                                          .favoriteActiveSvg
                                                    : AppAssets.addLikevg,
                                              ),
                                            )
                                          : BarWidget(
                                              text:
                                                  "${state.cachedProductWithoutRelatedProductsModel[widget.productIdForCashProducts]?.product?.countOfLikes ?? 0}",
                                              svgPath:
                                                  (state
                                                          .cachedProductWithoutRelatedProductsModel[widget
                                                              .productIdForCashProducts]
                                                          ?.product
                                                          ?.isLiked ??
                                                      false)
                                                  ? AppAssets.favoriteActiveSvg
                                                  : AppAssets.addLikevg,
                                              onTap: () {
                                                FirebaseAnalyticsService.logEventForSession(
                                                  eventName:
                                                      AnalyticsEventsConst
                                                          .LIKE_ITEM,
                                                  executedEventName:
                                                      AnalyticsButtonsEventNameConst
                                                          .LIKE_ITEM_BUTTON,
                                                  extraParams: {
                                                    'item_id': widget
                                                        .productIdForRequestApi,
                                                    'item_name':
                                                        widget.products.name ??
                                                        '',
                                                    'brand':
                                                        widget
                                                            .products
                                                            .brand!
                                                            .name ??
                                                        '',
                                                    'action':
                                                        !(state
                                                                .cachedProductWithoutRelatedProductsModel[widget
                                                                    .productIdForCashProducts]
                                                                ?.product
                                                                ?.isLiked ??
                                                            false)
                                                        ? 'like'
                                                        : 'dislike',
                                                    'category': widget
                                                        .products
                                                        .categories!
                                                        .map((e) => e.name)
                                                        .toList()
                                                        .toString(),
                                                    'count_likes': widget
                                                        .products
                                                        .countOfLikes
                                                        .toString(),
                                                    'review_count': widget
                                                        .products
                                                        .reviewsCount
                                                        .toString(),
                                                    'screen_name':
                                                        GlobalScreenConst
                                                            .PRODUCT_SCREEN,
                                                    'price': widget
                                                        .products
                                                        .price
                                                        .toString(),
                                                  },
                                                );
                                                homeBloc.add(
                                                  AddOrRemoveLikeForProductEvent(
                                                    productSlugForTopic:
                                                        state
                                                            .cachedProductWithoutRelatedProductsModel[widget
                                                                .productIdForCashProducts]
                                                            ?.product
                                                            ?.slug ??
                                                        "",
                                                    productSlug:
                                                        widget.productSlug,
                                                    isFavourite:
                                                        !(state
                                                                .cachedProductWithoutRelatedProductsModel[widget
                                                                    .productIdForCashProducts]
                                                                ?.product
                                                                ?.isLiked ??
                                                            false),
                                                    productId: widget
                                                        .productIdForRequestApi,
                                                  ),
                                                );
                                                widget.clickOnFavorite;
                                              },
                                            );
                                    },
                                  ),
                                  BarWidget(
                                    text:
                                        '${state.getFqaCommentsPaginationModel?['all']?.total ?? 0}',
                                    svgPath: currentTab == 0
                                        ? AppAssets.addCommentSvg
                                        : AppAssets.addCommentSvg,
                                    onTap: widget.clickOnComments,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      widget.panelController.open();
                                      widget.currentActiveTab.value = 3;
                                    },
                                    child: Container(
                                      alignment: Alignment.topCenter,

                                      height: 68.h,
                                      padding: EdgeInsets.only(
                                        top: 10.h,
                                        left: 15.w,
                                        right: 15.w,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xff513AAF),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(15.r),
                                          topRight: Radius.circular(15.r),
                                        ),
                                      ),
                                      child: SizedBox(
                                        height: 20.h,
                                        child: Row(
                                          children: [
                                            SvgPicture.asset(
                                              AppAssets.buyNewSvg,
                                            ),
                                            SizedBox(width: 2.w),
                                            MyTextWidget(
                                              LocaleKeys.buy.tr(),
                                              style: context
                                                  .textTheme
                                                  .titleMedium
                                                  ?.mq
                                                  .copyWith(
                                                    fontSize: 13.sp,
                                                    color: Colors.white,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  BlocBuilder<ChatBloc, ChatState>(
                                    buildWhen: (previous, current) =>
                                        previous.getSharedProductCountStatus !=
                                        current.getSharedProductCountStatus,
                                    builder: (context, chatState) {
                                      return chatState
                                                  .getSharedProductCountStatus ==
                                              GetSharedProductCountStatus
                                                  .loading
                                          ? Shimmer.fromColors(
                                              baseColor: Colors.grey.shade400,
                                              highlightColor:
                                                  Colors.grey.shade100,
                                              child: SvgPicture.asset(
                                                AppAssets.shareSvg,
                                              ),
                                            )
                                          : BarWidget(
                                              text:
                                                  '${state.cachedProductWithoutRelatedProductsModel[widget.productIdForCashProducts]?.product?.sharedCount ?? "0"}',
                                              svgPath: AppAssets.shareSvg,
                                              color: const Color(0xff1D1D1D),
                                              onTap: widget.clickOnShare,
                                            );
                                    },
                                  ),
                                  BarWidget(
                                    svgPath: AppAssets.moreOptionSvg,
                                    color: currentTab == 2
                                        ? const Color(0xff505050)
                                        : null,
                                    onTap: widget.clickOnMoreOptions,
                                  ),
                                },
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class BarWidget extends StatelessWidget {
  const BarWidget({
    super.key,
    this.text,
    required this.svgPath,
    required this.onTap,
    this.color,
  });

  final String svgPath;
  final String? text;
  final Color? color;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return Material(
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: Colors.white,
          height: 30.h,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SvgPicture.asset(
                svgPath,
                // ignore: deprecated_member_use
                color: color,
                height: 25.h,
              ),
              if (text != null && text != "0") ...{
                5.horizontalSpace,
                MyTextWidget(
                  text!,
                  style: context.textTheme.titleMedium?.rq.copyWith(
                    color: const Color(0xff8D8D8D),
                  ),
                ),
              },
            ],
          ),
        ),
      ),
    );
  }
}/*

class ImageForAddToCart {
  final String? colorName;
  final String? images;
  int? quantity;
  final String? choiceName;
  final int? countOfPieces;
  final String? colorNum;
  final String? choiceOption;
  final String? colorOption;
  bool isDuplicate;

  ImageForAddToCart({
    this.colorName,
    this.colorNum,
    this.countOfPieces,
    this.images,
    this.colorOption,
    this.choiceOption,
    this.quantity,
    this.isDuplicate = false,
    this.choiceName,
  });

  ImageForAddToCart copyWith(
          {final String? colorName,
          final String? images,
          int? quantity,
          final String? size,
          final int? countOfPieces,
          final String? choiceOption,
          final String? colorOption,
          final String? colorNum,
          bool? isDuplicate}) =>
      ImageForAddToCart(
          colorName: colorName ?? this.colorName,
          images: images ?? this.images,
          choiceOption: choiceOption ?? this.choiceOption,
          colorOption: colorOption ?? this.colorOption,
          quantity: quantity ?? this.quantity,
          countOfPieces: countOfPieces ?? this.countOfPieces,
          choiceName: size ?? this.choiceName,
          colorNum: colorNum ?? this.colorNum);

  factory ImageForAddToCart.fromJson(Map<String, dynamic> json) =>
      ImageForAddToCart(
        colorName: json["colorName"],
        images: json["images"],
        choiceName: json["size"],
        colorOption: json["colorOption"],
        quantity: json["quantity"],
        choiceOption: json["choiceOption"],
        countOfPieces: json["count_of_pieces"],
        colorNum: json["colorNum"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "colorName": colorName,
        "images": images,
        "size": choiceName,
        "colorOption": colorOption,
        "choiceOption": choiceOption,
        "quantity": quantity,
        "count_of_pieces": countOfPieces,
        "colorNum": colorNum,
      };
}
*/