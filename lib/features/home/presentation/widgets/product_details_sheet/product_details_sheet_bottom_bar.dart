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
import 'package:trydos/core/utils/last_pages_tracker.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as product;
import 'package:trydos/features/home/data/models/starting_settings_response_model.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/notify_for_available_in_country.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/notify_for_quantity_available_button.dart';
import 'package:trydos/features/story/presentation/widget/try_again.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import '../../../../../common/constant/design/assets_provider.dart';
import '../../../../../core/utils/responsive_padding.dart';

class ProductDetailsSheetBottomBar extends StatefulWidget {
  const ProductDetailsSheetBottomBar({
    super.key,
    required this.addToBagButtonShapeNotifier,
    required this.clickOnFavorite,
    required this.clickOnComments,
    required this.clickOnShare,
    required this.onFinishBuying,
    required this.clickOnMoreOptions,
    required this.panelController,
    required this.productIdForCashproducts,
    required this.productIdForRequestApi,
    required this.colorName,
    required this.colorNum,
    required this.size,
    required this.colorOption,
    required this.productSlug,
    required this.countOfPieces,
    required this.colorIsNotAvailableNotifier,
    required this.currentActiveTab,
    required this.qtyForproductWithoutVariant,
    required this.collectedAfterOrder,
    required this.products,
    required this.isRedeem,
    required this.redeemVariantPrice,
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

  final bool collectedAfterOrder;
  final bool isGetFullProductDetails;
  final product.Products products;
  final int? qtyForproductWithoutVariant;
  final String productIdForCashproducts;
  final String productIdForRequestApi;
  final String productSlug;
  final String colorOption;
  final String colorName;
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
  final void Function(String quantity) onFinishBuying;

  @override
  State<ProductDetailsSheetBottomBar> createState() =>
      _ProductDetailsSheetBottomBarState();
}

class _ProductDetailsSheetBottomBarState
    extends State<ProductDetailsSheetBottomBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  late HomeBloc homeBloc;

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
          previous.enableAddToCardAfterChangeVariantZero !=
              current.enableAddToCardAfterChangeVariantZero ||
          previous.changeSizesForEveryProduct !=
              current.changeSizesForEveryProduct ||
          previous
                  .cachedProductWithoutRelatedProductsModel[widget
                      .productIdForCashproducts]
                  ?.product
                  ?.sharedCount !=
              current
                  .cachedProductWithoutRelatedProductsModel[widget
                      .productIdForCashproducts]
                  ?.product
                  ?.sharedCount,
      builder: (context, state) {
        List<List<String>> allimages = [];
        List<String> cartIds = [];

        // حلقات متداخلة للوصول إلى جميع القيم
        state.addImagesToProductIdForCart[widget.productIdForRequestApi] != null
            ? state.addImagesToProductIdForCart[widget.productIdForRequestApi]!
                  .forEach((key, value) {
                    allimages.addAll(value);
                    if (value.length > 0) {
                      cartIds.add(key.toString());
                    }
                  })
            : [];
        return Container(
          color: colorScheme.white,
          child: Column(
            children: [
              // ValueListenableBuilder<int>(
              // valueListenable: widget.currentActiveTab,
              // builder: (context , currentTab , _) {
              //   return currentTab == 3 ? const SizedBox.shrink() : 10.verticalSpace;
              // }),
              const SizedBox(height: 10),
              Padding(
                padding: HWEdgeInsets.symmetric(horizontal: 20.0),
                child: ValueListenableBuilder<int>(
                  valueListenable: widget.currentActiveTab,
                  builder: (context, currentTab, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ValueListenableBuilder<String?>(
                          valueListenable: widget.productNotAvailableNotifier,
                          builder: (context, _productNotAvailableNotifier, child) {
                            return ValueListenableBuilder<String?>(
                              valueListenable:
                                  widget.colorIsNotAvailableNotifier,
                              builder: (context, selectedcolorByUser, child) {
                                return ValueListenableBuilder<String?>(
                                  valueListenable:
                                      widget.sizeIsNotAvailableNotifier,
                                  builder: (context, selectedSizeByUser, child) {
                                    return ValueListenableBuilder<int>(
                                      valueListenable:
                                          widget.addToBagButtonShapeNotifier,
                                      builder: (context, itemCount, _) {
                                        ImageForAddToCart imageForAddToCart =
                                            ImageForAddToCart(
                                              countOfPieces:
                                                  widget.countOfPieces,
                                              colorNum: widget.colorNum,
                                              quantity: 1,
                                              images: widget.imageUrl,
                                              colorOption: widget.colorOption,
                                              colorName: widget.colorName,
                                            );
                                        return AnimatedSwitcher(
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
                                                    end: const Offset(0.0, 0.0),
                                                  ).animate(animation),
                                                  child: child,
                                                );
                                              },
                                          child:
                                              !(_productNotAvailableNotifier !=
                                                  null)
                                              ? (widget.qtyForproductWithoutVariant !=
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
                                                              width: 120,
                                                              height: 60,
                                                              decoration:
                                                                  BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          15,
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
                                                                    BlocProvider.of<HomeBloc>(
                                                                      context,
                                                                    ).add(
                                                                      GetFullProductDetailsEvent(
                                                                        productSlug:
                                                                            widget.productSlug,
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
                                                                    width: 97.w,
                                                                    height: 60,
                                                                    decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            20,
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
                                                                        .bagSvg,
                                                                    height:
                                                                        30.h,
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          : GestureDetector(
                                                              onTapDown: (details) {
                                                                if (currentTab !=
                                                                    3) {
                                                                  if (state
                                                                          .productStatus![widget
                                                                          .productIdForCashproducts] ==
                                                                      GetProductDetailWithoutSimilarRelatedProductsStatus
                                                                          .success) {
                                                                    widget
                                                                        .panelController
                                                                        .open();
                                                                    widget
                                                                            .currentActiveTab
                                                                            .value =
                                                                        3;
                                                                  }
                                                                  //////////////////////////////
                                                                  // FirebaseAnalyticsService.logEventForSession(
                                                                  //   eventName: AnalyticsEventsConst.buttonClicked,
                                                                  //   executedEventName: AnalyticsButtonsEventNameConst.addToBagButton,
                                                                  // );
                                                                } else {
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
                                                                      //    homeBloc.add(UpdateItemInCartEvent(fromCartPage: false, newQuantity: -1, maxAllowed: 0, currentSize: state.addVariationToCartId?[cartIds.last]?["size"] ?? "", colorOption: state.addVariationToCartId?[cartIds.last]?["color"] ?? "", productId: widget.productIdForRequestApi, totalQuantity: (state.addImagesToProductIdForCart[widget.productIdForRequestApi]?[int.tryParse(cartIds.last)]?.length ?? 0) - 1, image: state.addImagesToProductIdForCart[widget.productIdForRequestApi]?[int.tryParse(cartIds.last)]?.last ?? "", cartId: cartIds.last, boutiqueId: ""));
                                                                      return;
                                                                    }
                                                                    animationController
                                                                        .forward();
                                                                    widget
                                                                        .onFinishBuying
                                                                        .call(
                                                                          itemCount
                                                                              .toString(),
                                                                        );
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
                                                                    //////////////////////////////
                                                                    // FirebaseAnalyticsService.logEventForSession(
                                                                    //   eventName: AnalyticsEventsConst.buttonClicked,
                                                                    //   executedEventName: AnalyticsButtonsEventNameConst.increaseQtyButton,
                                                                    // );
                                                                    //  }
                                                                    /*     else {
                                                                          animationController
                                                                              .forward();
                                                                          widget
                                                                              .onFinishBuying
                                                                              .call(
                                                                                  itemCount.toString());
                                                                          Future.delayed(
                                                                              Duration(
                                                                                  milliseconds: 400),
                                                                              () {
                                                                            widget
                                                                                .panelController
                                                                                .close();
                                                                          });
                                                                          widget
                                                                              .addToBagButtonShapeNotifier
                                                                              .value = 0;
                                
                                                                          print(
                                                                              '33333333333333');
                                                                          //////////////////////////////
                                                                          FirebaseAnalyticsService
                                                                              .logEventForSession(
                                                                            eventName:
                                                                                AnalyticsEventsConst.buttonClicked,
                                                                            executedEventName:
                                                                                AnalyticsExecutedEventNameConst.addProductToBagButton,
                                                                          );
                                                                        }*/
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
                                                                        .onFinishBuying
                                                                        .call(
                                                                          itemCount
                                                                              .toString(),
                                                                        );
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
                                                                }
                                                              },
                                                              child: AnimatedBuilder(
                                                                animation:
                                                                    animationController,
                                                                builder: (context, child) {
                                                                  final sineValue = sin(
                                                                    3 *
                                                                        2 *
                                                                        pi *
                                                                        animationController
                                                                            .value,
                                                                  );
                                                                  return Transform.translate(
                                                                    offset: Offset(
                                                                      sineValue *
                                                                          3,
                                                                      0,
                                                                    ),
                                                                    child: SizedBox(
                                                                      width:
                                                                          currentTab ==
                                                                              3
                                                                          ? 1.sw -
                                                                                60
                                                                          : itemCount >
                                                                                0
                                                                          ? 197.w
                                                                          : 97.w,
                                                                      child: Stack(
                                                                        alignment:
                                                                            Alignment.topRight,
                                                                        children: [
                                                                          AnimatedContainer(
                                                                            duration: const Duration(
                                                                              milliseconds: 300,
                                                                            ),
                                                                            curve:
                                                                                Curves.fastLinearToSlowEaseIn,
                                                                            decoration: BoxDecoration(
                                                                              border: Border.all(
                                                                                color: widget.isRedeem
                                                                                    ? Colors.deepOrangeAccent
                                                                                    : Colors.blue,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(
                                                                                20,
                                                                              ),
                                                                              color:
                                                                                  state.updateItemInCartStatus ==
                                                                                          UpdateItemInCartStatus.loading ||
                                                                                      state.addItemInCartStatus ==
                                                                                          AddItemInCartStatus.loading ||
                                                                                      state.deleteItemInCartStatus ==
                                                                                          DeleteItemInCartStatus.loading
                                                                                  ? const Color(
                                                                                      0xffF8F8F8,
                                                                                    )
                                                                                  : allimages.length >
                                                                                        0
                                                                                  ? const Color(
                                                                                      0xffCEFFE6,
                                                                                    )
                                                                                  : const Color(
                                                                                      0xffF8F8F8,
                                                                                    ),
                                                                            ),
                                                                            child: Center(
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.symmetric(
                                                                                  vertical: 10,
                                                                                ),
                                                                                child: Column(
                                                                                  children: [
                                                                                    Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      crossAxisAlignment: CrossAxisAlignment.end,
                                                                                      children: [
                                                                                        state.updateItemInCartStatus ==
                                                                                                    UpdateItemInCartStatus.loading ||
                                                                                                state.addItemInCartStatus ==
                                                                                                    AddItemInCartStatus.loading ||
                                                                                                state.deleteItemInCartStatus ==
                                                                                                    DeleteItemInCartStatus.loading
                                                                                            ? TrydosLoader(
                                                                                                size: 20.h,
                                                                                              )
                                                                                            : SvgPicture.asset(
                                                                                                AppAssets.bagSvg,
                                                                                                height: 30.h,
                                                                                              ),
                                                                                        if (itemCount >
                                                                                            0) ...{
                                                                                          SizedBox(
                                                                                            height: 20,
                                                                                            child: ListView.builder(
                                                                                              itemBuilder:
                                                                                                  (
                                                                                                    context,
                                                                                                    index,
                                                                                                  ) {
                                                                                                    return Align(
                                                                                                      widthFactor:
                                                                                                          1 -
                                                                                                          (itemCount /
                                                                                                              12 *
                                                                                                              0.3),
                                                                                                      child: MyCachedNetworkImage(
                                                                                                        circleDimensions: 15,
                                                                                                        imageUrl:
                                                                                                            state.listitemForAddToCart !=
                                                                                                                null
                                                                                                            ? state.listitemForAddToCart![index].images!
                                                                                                            : "",
                                                                                                        width: 15,
                                                                                                        imageWidth: 70,
                                                                                                        imageHeight: 70,
                                                                                                        imageFit: BoxFit.cover,
                                                                                                        height: 20,
                                                                                                      ),
                                                                                                    ); /*Container(
                                                                                                  width: 15,
                                                                                                  height: 20,
                                                                                                  decoration: BoxDecoration(
                                                                                                    image: DecorationImage(
                                                                                                      image: NetworkImage(widget.imageUrl),
                                                                                                      fit: ,
                                                                                                    ),
                                                                                                    borderRadius: BorderRadius.circular(5.0),
                                                                                                  ),
                                                                                                ));*/
                                                                                                  },
                                                                                              reverse: true,
                                                                                              shrinkWrap: true,
                                                                                              scrollDirection: Axis.horizontal,
                                                                                              itemCount:
                                                                                                  state.listitemForAddToCart !=
                                                                                                      null
                                                                                                  ? state.listitemForAddToCart!.length
                                                                                                  : 0,
                                                                                            ),
                                                                                          ),
                                                                                        },
                                                                                        SizedBox(
                                                                                          height: 20,
                                                                                          child: ListView.builder(
                                                                                            itemBuilder:
                                                                                                (
                                                                                                  context,
                                                                                                  index,
                                                                                                ) {
                                                                                                  return Align(
                                                                                                    widthFactor:
                                                                                                        1 -
                                                                                                        (itemCount /
                                                                                                            12 *
                                                                                                            0.3),
                                                                                                    child: MyCachedNetworkImage(
                                                                                                      circleDimensions: 15,
                                                                                                      imageUrl: allimages[index][0],
                                                                                                      width: 15,
                                                                                                      imageWidth: 70,
                                                                                                      imageHeight: 70,
                                                                                                      imageFit: BoxFit.cover,
                                                                                                      height: 20,
                                                                                                    ),
                                                                                                  ); /*Container(
                                                                                                  width: 15,
                                                                                                  height: 20,
                                                                                                  decoration: BoxDecoration(
                                                                                                    image: DecorationImage(
                                                                                                      image: NetworkImage(widget.imageUrl),
                                                                                                      fit: ,
                                                                                                    ),
                                                                                                    borderRadius: BorderRadius.circular(5.0),
                                                                                                  ),
                                                                                                ));*/
                                                                                                },
                                                                                            reverse: true,
                                                                                            shrinkWrap: true,
                                                                                            scrollDirection: Axis.horizontal,
                                                                                            itemCount: allimages.length,
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                    const SizedBox(
                                                                                      height: 5,
                                                                                    ),
                                                                                    if (currentTab !=
                                                                                        3) ...{
                                                                                      MyTextWidget(
                                                                                        itemCount >
                                                                                                0
                                                                                            ? '$itemCount'
                                                                                            : '${LocaleKeys.add.tr()} ${LocaleKeys.tto.tr()} ${LocaleKeys.bag.tr()}',
                                                                                        style:
                                                                                            itemCount >
                                                                                                0
                                                                                            ? textTheme.titleMedium?.bq.copyWith(
                                                                                                color: const Color(
                                                                                                  0xff505050,
                                                                                                ),
                                                                                              )
                                                                                            : textTheme.titleMedium?.rq.copyWith(
                                                                                                color: const Color(
                                                                                                  0xff505050,
                                                                                                ),
                                                                                              ),
                                                                                      ),
                                                                                    } else ...{
                                                                                      Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        children: [
                                                                                          MyTextWidget(
                                                                                            '${LocaleKeys.add.tr()} ',
                                                                                            style: textTheme.titleMedium?.mq.copyWith(
                                                                                              height:
                                                                                                  15 /
                                                                                                  12,
                                                                                              color: const Color(
                                                                                                0xff505050,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          MyTextWidget(
                                                                                            '${LocaleKeys.tto.tr()} ${LocaleKeys.bag.tr()} ',
                                                                                            style: textTheme.titleMedium?.rq.copyWith(
                                                                                              height:
                                                                                                  15 /
                                                                                                  12,
                                                                                              color: const Color(
                                                                                                0xff505050,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          widget.colorNum ==
                                                                                                  ""
                                                                                              ? const SizedBox.shrink()
                                                                                              : MyTextWidget(
                                                                                                  '${LocaleKeys.color.tr()} ',
                                                                                                  style: textTheme.titleMedium?.rq.copyWith(
                                                                                                    height:
                                                                                                        15 /
                                                                                                        12,
                                                                                                    color: const Color(
                                                                                                      0xff505050,
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                          widget.colorNum ==
                                                                                                  ""
                                                                                              ? const SizedBox.shrink()
                                                                                              : MyTextWidget(
                                                                                                  '${widget.colorName} ',
                                                                                                  style: textTheme.titleMedium?.mq.copyWith(
                                                                                                    height:
                                                                                                        15 /
                                                                                                        12,
                                                                                                    color: const Color(
                                                                                                      0xff1D1D1D,
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                          widget.size ==
                                                                                                  ""
                                                                                              ? const SizedBox.shrink()
                                                                                              : MyTextWidget(
                                                                                                  '${LocaleKeys.size.tr()} ',
                                                                                                  style: textTheme.titleMedium?.rq.copyWith(
                                                                                                    height:
                                                                                                        15 /
                                                                                                        12,
                                                                                                    color: const Color(
                                                                                                      0xff505050,
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                          widget.size ==
                                                                                                  ""
                                                                                              ? const SizedBox.shrink()
                                                                                              : MyTextWidget(
                                                                                                  '${widget.size} ',
                                                                                                  style: textTheme.titleMedium?.mq.copyWith(
                                                                                                    height:
                                                                                                        15 /
                                                                                                        12,
                                                                                                    color: const Color(
                                                                                                      0xff505050,
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                        ],
                                                                                      ),
                                                                                    },
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          if (allimages.length >
                                                                                  0 &&
                                                                              currentTab ==
                                                                                  3) ...{
                                                                            Positioned(
                                                                              top: -35,
                                                                              left: -35,
                                                                              child: Container(
                                                                                width: 55,
                                                                                height: 55,
                                                                                decoration: BoxDecoration(
                                                                                  border: Border.all(
                                                                                    color: widget.isRedeem
                                                                                        ? Colors.deepOrangeAccent
                                                                                        : Colors.blue,
                                                                                  ),
                                                                                  borderRadius: BorderRadius.circular(
                                                                                    20,
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
                                                                                      allimages.length ==
                                                                                          1
                                                                                      ? 0
                                                                                      : 7.h,
                                                                                ),
                                                                                child: Center(
                                                                                  child: SvgPicture.asset(
                                                                                    allimages.length ==
                                                                                            1
                                                                                        ? AppAssets.binSvg
                                                                                        : AppAssets.minusMarkSvg,
                                                                                    height:
                                                                                        allimages.length ==
                                                                                            1
                                                                                        ? 15.h
                                                                                        : 3.h,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          },
                                                                          Positioned(
                                                                            top:
                                                                                -35,
                                                                            right:
                                                                                -35,
                                                                            child: Container(
                                                                              width: 55,
                                                                              height: 55,
                                                                              decoration: BoxDecoration(
                                                                                borderRadius: BorderRadius.circular(
                                                                                  20,
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
                                                                            height:
                                                                                15.h,
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
                                                                  productItem:
                                                                      widget
                                                                          .products,
                                                                  currentTap:
                                                                      currentTab,
                                                                  unAvailableSize:
                                                                      selectedSizeByUser ??
                                                                      "",
                                                                  notificationTypeId:
                                                                      notificationTypeId,
                                                                  productId: widget
                                                                      .productIdForRequestApi,
                                                                  selectedColorName:
                                                                      selectedcolorByUser ??
                                                                      "",
                                                                );
                                                        },
                                                      )
                                              : NotifyWhenAvailableInCountryButton(
                                                  currentTap: currentTab,
                                                  productItem: widget.products,
                                                  productId: widget
                                                      .productIdForRequestApi,
                                                  unAvailableType:
                                                      _productNotAvailableNotifier,
                                                ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                        if (currentTab != 3) ...{
                          const Spacer(),
                          Expanded(
                            flex: 5,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                                AuthProductDetailsStatus.loading
                                        ? Shimmer.fromColors(
                                            baseColor: Colors.grey.shade400,
                                            highlightColor:
                                                Colors.grey.shade100,
                                            child: SvgPicture.asset(
                                              (state
                                                          .cachedProductWithoutRelatedProductsModel[widget
                                                              .productIdForCashproducts]
                                                          ?.product
                                                          ?.isLiked ??
                                                      false)
                                                  ? AppAssets.favoriteActiveSvg
                                                  : AppAssets.favoriteSvg,
                                            ),
                                          )
                                        : BarWidget(
                                            text:
                                                "${state.cachedProductWithoutRelatedProductsModel[widget.productIdForCashproducts]?.product?.countOfLikes ?? 0}",
                                            svgPath:
                                                (state
                                                        .cachedProductWithoutRelatedProductsModel[widget
                                                            .productIdForCashproducts]
                                                        ?.product
                                                        ?.isLiked ??
                                                    false)
                                                ? AppAssets.favoriteActiveSvg
                                                : AppAssets.favoriteSvg,
                                            onTap: () {
                                              homeBloc.add(
                                                AddOrRemoveLikeForProductEvent(
                                                  productSlugForTopic:
                                                      state
                                                          .cachedProductWithoutRelatedProductsModel[widget
                                                              .productIdForCashproducts]
                                                          ?.product
                                                          ?.slug ??
                                                      "",
                                                  productSlug:
                                                      widget.productSlug,
                                                  isFavourite:
                                                      !(state
                                                              .cachedProductWithoutRelatedProductsModel[widget
                                                                  .productIdForCashproducts]
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
                                      '${state.cachedProductWithoutRelatedProductsModel[widget.productIdForCashproducts]?.product?.commentsCount ?? 0}',
                                  svgPath: currentTab == 0
                                      ? AppAssets.chatMarkActiveSvg
                                      : AppAssets.chatMarkSvg,
                                  onTap: widget.clickOnComments,
                                ),
                                BlocBuilder<ChatBloc, ChatState>(
                                  buildWhen: (previous, current) =>
                                      previous.getSharedProductCountStatus !=
                                      current.getSharedProductCountStatus,
                                  builder: (context, chatState) {
                                    return chatState
                                                .getSharedProductCountStatus ==
                                            GetSharedProductCountStatus.loading
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
                                                '${state.cachedProductWithoutRelatedProductsModel[widget.productIdForCashproducts]?.product?.sharedCount ?? "0"}',
                                            svgPath: AppAssets.shareSvg,
                                            color: currentTab == 1
                                                ? const Color(0xff505050)
                                                : null,
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
                              ],
                            ),
                          ),
                        },
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
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
      color: Colors.transparent,
      child: InkWell(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: onTap,
        child: Column(
          children: [
            SvgPicture.asset(
              svgPath,
              // ignore: deprecated_member_use
              color: color,
              height: 30.h,
            ),
            if (text != null && text != "0") ...{
              5.verticalSpace,
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
    );
  }
}

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

  ImageForAddToCart copyWith({
    final String? colorName,
    final String? images,
    int? quantity,
    final String? size,
    final int? countOfPieces,
    final String? choiceOption,
    final String? colorOption,
    final String? colorNum,
    bool? isDuplicate,
  }) => ImageForAddToCart(
    colorName: colorName ?? this.colorName,
    images: images ?? this.images,
    choiceOption: choiceOption ?? this.choiceOption,
    colorOption: colorOption ?? this.colorOption,
    quantity: quantity ?? this.quantity,
    countOfPieces: countOfPieces ?? this.countOfPieces,
    choiceName: size ?? this.choiceName,
    colorNum: colorNum ?? this.colorNum,
  );

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
