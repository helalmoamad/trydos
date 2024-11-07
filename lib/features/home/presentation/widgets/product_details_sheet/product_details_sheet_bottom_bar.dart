import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/app/trydos_shimmer_loading.dart';
import 'package:trydos/features/chat/data/models/my_chats_response_model.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/chat/presentation/manager/chat_state.dart';
import 'package:trydos/features/home/data/models/get_home_boutiqes_model.dart';
import 'package:trydos/features/home/data/models/starting_settings_response_model.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/notify_for_quantity_available_button.dart';

import '../../../../../common/constant/design/assets_provider.dart';
import '../../../../../core/utils/responsive_padding.dart';
import '../../../../../service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../../../service/firebase_analytics_service/analytics_const/analytics_executed_event_name.dart';
import '../../../../../service/firebase_analytics_service/firebase_analytics_service.dart';

class ProductDetailsSheetBottomBar extends StatefulWidget {
  const ProductDetailsSheetBottomBar(
      {super.key,
      required this.addToBagButtonShapeNotifier,
      required this.clickOnFavorite,
      required this.clickOnComments,
      required this.clickOnShare,
      required this.onFinishBuying,
      required this.clickOnMoreOptions,
      required this.panelController,
      required this.productId,
      required this.colorName,
      required this.colorNum,
      required this.size,
      required this.countOfPieces,
      required this.currentActiveTab,
      required this.sizeIsNotAvailableNotifier,
      required this.imageUrl});

  final ValueNotifier<int> addToBagButtonShapeNotifier;

  final ValueNotifier<String?> sizeIsNotAvailableNotifier;

  final PanelController panelController;
  final String imageUrl;
  final int countOfPieces;
  final String productId;
  final String colorName;
  final String colorNum;
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
  late HomeBloc homeBloc;

  @override
  void initState() {
    widget.addToBagButtonShapeNotifier.value = 0;
    homeBloc = BlocProvider.of<HomeBloc>(context);
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
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
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) =>
          previous.addImagesToProductIdForCart[widget.productId]?.length !=
              current.addImagesToProductIdForCart[widget.productId]?.length ||
          previous.currentSelectedColorForEveryProduct[widget.productId] !=
              current.currentSelectedColorForEveryProduct[widget.productId] ||
          previous.productStatus != current.productStatus ||
          previous.updateItemInCartStatus != current.updateItemInCartStatus ||
          previous.addItemInCartStatus != current.addItemInCartStatus ||
          previous.deleteItemInCartStatus != current.deleteItemInCartStatus ||
          previous.ListitemForAddToCart?.length !=
              current.ListitemForAddToCart?.length ||
          previous.getCommentForProductStatus !=
              current.getCommentForProductStatus ||
          previous.addCommentStatus != current.addCommentStatus,
      builder: (context, state) {
        print("***********");
        List<String> allimages = [];

        // حلقات متداخلة للوصول إلى جميع القيم
        state.addImagesToProductIdForCart[widget.productId] != null
            ? state.addImagesToProductIdForCart[widget.productId]!
                .forEach((key, value) {
                allimages.addAll(value);
              })
            : [];
        print(")))${state.addImagesToProductIdForCart[widget.productId]}");
        return Container(
            color: colorScheme.white,
            child: Column(
              children: [
                // ValueListenableBuilder<int>(
                // valueListenable: widget.currentActiveTab,
                // builder: (context , currentTab , _) {
                //   return currentTab == 3 ? const SizedBox.shrink() : 10.verticalSpace;
                // }),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: HWEdgeInsets.symmetric(horizontal: 20.0),
                  child: ValueListenableBuilder<int>(
                      valueListenable: widget.currentActiveTab,
                      builder: (context, currentTab, _) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ValueListenableBuilder<String?>(
                                valueListenable:
                                    widget.sizeIsNotAvailableNotifier,
                                builder: (context, selectedSizeByUser, child) {
                                  return ValueListenableBuilder<int>(
                                      valueListenable:
                                          widget.addToBagButtonShapeNotifier,
                                      builder: (context, itemCount, _) {
                                        ImageForAddToCart imageForAddToCart =
                                            ImageForAddToCart(
                                          countOfPieces: widget.countOfPieces,
                                          colorNum: widget.colorNum,
                                          quantity: 1,
                                          images: widget.imageUrl,
                                          colorName: widget.colorName,
                                        );
                                        return AnimatedSwitcher(
                                            duration:
                                                Duration(milliseconds: 300),
                                            reverseDuration:
                                                Duration(milliseconds: 300),
                                            transitionBuilder:
                                                (child, animation) {
                                              return SlideTransition(
                                                position: Tween(
                                                  begin: Offset(-1.0, 0.0),
                                                  end: Offset(0.0, 0.0),
                                                ).animate(animation),
                                                child: child,
                                              );
                                            },
                                            child: selectedSizeByUser == null
                                                ? (state.productStatus?[
                                                            widget.productId] !=
                                                        GetProductDetailWithoutSimilarRelatedProductsStatus
                                                            .success)
                                                    ? Stack(
                                                        alignment:
                                                            Alignment.center,
                                                        children: [
                                                          Shimmer.fromColors(
                                                            baseColor: Colors
                                                                .grey.shade300,
                                                            highlightColor:
                                                                Colors.grey
                                                                    .shade100,
                                                            child: Container(
                                                              width: 97.w,
                                                              height: 60,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20),
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              ),
                                                            ),
                                                          ),
                                                          Shimmer.fromColors(
                                                            baseColor: Colors
                                                                .grey.shade400,
                                                            highlightColor:
                                                                Colors.grey
                                                                    .shade100,
                                                            child: SvgPicture
                                                                .asset(
                                                              AppAssets.bagSvg,
                                                              height: 30.h,
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    : GestureDetector(
                                                        onTapDown: (details) {
                                                          if (currentTab != 3) {
                                                            print('open panel');

                                                            if (state.productStatus![
                                                                    widget
                                                                        .productId] ==
                                                                GetProductDetailWithoutSimilarRelatedProductsStatus
                                                                    .success) {
                                                              widget
                                                                  .panelController
                                                                  .open();
                                                              widget
                                                                  .currentActiveTab
                                                                  .value = 3;
                                                            }
                                                            //////////////////////////////
                                                            FirebaseAnalyticsService
                                                                .logEventForSession(
                                                              eventName:
                                                                  AnalyticsEventsConst
                                                                      .buttonClicked,
                                                              executedEventName:
                                                                  AnalyticsExecutedEventNameConst
                                                                      .addToBagButton,
                                                            );
                                                          } else {
                                                            HapticFeedback
                                                                .lightImpact();
                                                            if (itemCount > 0) {
                                                              if (details
                                                                      .localPosition
                                                                      .dx <=
                                                                  50.w) {
                                                                animationController
                                                                    .forward();
                                                                widget
                                                                    .addToBagButtonShapeNotifier
                                                                    .value--;
                                                                homeBloc.add(
                                                                  UpdateListOfItemForAddToCartEvent(
                                                                      productId:
                                                                          widget
                                                                              .productId,
                                                                      imageForAddToCart:
                                                                          imageForAddToCart,
                                                                      operation:
                                                                          "-"),
                                                                );
                                                                print(
                                                                    '111111111111111');
                                                                //////////////////////////////
                                                                FirebaseAnalyticsService
                                                                    .logEventForSession(
                                                                  eventName:
                                                                      AnalyticsEventsConst
                                                                          .buttonClicked,
                                                                  executedEventName:
                                                                      AnalyticsExecutedEventNameConst
                                                                          .decreaseQtyButton,
                                                                );
                                                              } else if (details
                                                                      .localPosition
                                                                      .dx >=
                                                                  (1.sw - 90)
                                                                      .w) {
                                                                animationController
                                                                    .forward();
                                                                widget
                                                                    .addToBagButtonShapeNotifier
                                                                    .value++;
                                                                homeBloc.add(UpdateListOfItemForAddToCartEvent(
                                                                    productId:
                                                                        widget
                                                                            .productId,
                                                                    imageForAddToCart:
                                                                        imageForAddToCart,
                                                                    operation:
                                                                        "+"));
                                                                print(
                                                                    '22222222222222');
                                                                //////////////////////////////
                                                                FirebaseAnalyticsService
                                                                    .logEventForSession(
                                                                  eventName:
                                                                      AnalyticsEventsConst
                                                                          .buttonClicked,
                                                                  executedEventName:
                                                                      AnalyticsExecutedEventNameConst
                                                                          .increaseQtyButton,
                                                                );
                                                              } else {
                                                                animationController
                                                                    .forward();
                                                                widget
                                                                    .onFinishBuying
                                                                    .call(itemCount
                                                                        .toString());
                                                                Future.delayed(
                                                                    Duration(
                                                                        milliseconds:
                                                                            400),
                                                                    () {
                                                                  widget
                                                                      .panelController
                                                                      .close();
                                                                });
                                                                widget
                                                                    .addToBagButtonShapeNotifier
                                                                    .value = 0;
                                                                homeBloc.add(UpdateListOfItemForAddToCartEvent(
                                                                    productId:
                                                                        widget
                                                                            .productId,
                                                                    resetTheList:
                                                                        true,
                                                                    imageForAddToCart:
                                                                        imageForAddToCart,
                                                                    operation:
                                                                        "remove"));
                                                                print(
                                                                    '33333333333333');
                                                                //////////////////////////////
                                                                FirebaseAnalyticsService
                                                                    .logEventForSession(
                                                                  eventName:
                                                                      AnalyticsEventsConst
                                                                          .buttonClicked,
                                                                  executedEventName:
                                                                      AnalyticsExecutedEventNameConst
                                                                          .addProductToBagButton,
                                                                );
                                                              }
                                                            } else {
                                                              animationController
                                                                  .forward();
                                                              widget
                                                                  .addToBagButtonShapeNotifier
                                                                  .value++;
                                                              homeBloc.add(UpdateListOfItemForAddToCartEvent(
                                                                  productId: widget
                                                                      .productId,
                                                                  imageForAddToCart:
                                                                      imageForAddToCart,
                                                                  operation:
                                                                      "+"));
                                                              print(
                                                                  '44444444444');
                                                              //////////////////////////////
                                                              FirebaseAnalyticsService
                                                                  .logEventForSession(
                                                                eventName:
                                                                    AnalyticsEventsConst
                                                                        .buttonClicked,
                                                                executedEventName:
                                                                    AnalyticsExecutedEventNameConst
                                                                        .increaseQtyButton,
                                                              );
                                                            }
                                                          }
                                                        },
                                                        child: AnimatedBuilder(
                                                            animation:
                                                                animationController,
                                                            builder: (context,
                                                                child) {
                                                              final sineValue =
                                                                  sin(3 *
                                                                      2 *
                                                                      pi *
                                                                      animationController
                                                                          .value);
                                                              return Transform
                                                                  .translate(
                                                                      offset: Offset(
                                                                          sineValue *
                                                                              3,
                                                                          0),
                                                                      child:
                                                                          SizedBox(
                                                                        width: currentTab ==
                                                                                3
                                                                            ? 1.sw -
                                                                                40
                                                                            : itemCount > 0
                                                                                ? 197.w
                                                                                : 97.w,
                                                                        child:
                                                                            Stack(
                                                                          alignment:
                                                                              Alignment.topRight,
                                                                          children: [
                                                                            AnimatedContainer(
                                                                              duration: const Duration(milliseconds: 300),
                                                                              curve: Curves.fastLinearToSlowEaseIn,
                                                                              decoration: BoxDecoration(border: Border.all(color: Colors.blue), borderRadius: BorderRadius.circular(20), color: itemCount > 0 ? const Color(0xffCEFFE6) : const Color(0xffF8F8F8)),
                                                                              child: Center(
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                                                                  child: Column(
                                                                                    children: [
                                                                                      Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        crossAxisAlignment: CrossAxisAlignment.end,
                                                                                        children: [
                                                                                          SvgPicture.asset(
                                                                                            AppAssets.bagSvg,
                                                                                            height: 30.h,
                                                                                          ),
                                                                                          if (itemCount > 0) ...{
                                                                                            SizedBox(
                                                                                              height: 20,
                                                                                              child: ListView.builder(
                                                                                                itemBuilder: (context, index) {
                                                                                                  return Align(widthFactor: 1 - (itemCount / 12 * 0.3), child: MyCachedNetworkImage(circleDimensions: 15, imageUrl: state.ListitemForAddToCart != null ? state.ListitemForAddToCart![index].images! : "", width: 15, imageWidth: 70, imageHeight: 70, imageFit: BoxFit.cover, height: 20)); /*Container(
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
                                                                                                itemCount: state.ListitemForAddToCart != null ? state.ListitemForAddToCart!.length : 0,
                                                                                              ),
                                                                                            ),
                                                                                          },
                                                                                          SizedBox(
                                                                                            height: 20,
                                                                                            child: ListView.builder(
                                                                                              itemBuilder: (context, index) {
                                                                                                return Align(
                                                                                                  widthFactor: 1 - (itemCount / 12 * 0.3),
                                                                                                  child: MyCachedNetworkImage(
                                                                                                    circleDimensions: 15,
                                                                                                    imageUrl: allimages[index],
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
                                                                                      if (currentTab != 3) ...{
                                                                                        MyTextWidget(
                                                                                          itemCount > 0 ? '$itemCount' : 'Add to bag',
                                                                                          style: itemCount > 0 ? textTheme.titleMedium?.bq.copyWith(color: const Color(0xff505050)) : textTheme.titleMedium?.rq.copyWith(color: const Color(0xff505050)),
                                                                                        )
                                                                                      } else ...{
                                                                                        Row(
                                                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                                                          children: [
                                                                                            MyTextWidget(
                                                                                              'Add ',
                                                                                              style: textTheme.titleMedium?.mq.copyWith(height: 15 / 12, color: const Color(0xff505050)),
                                                                                            ),
                                                                                            MyTextWidget(
                                                                                              'to bag ',
                                                                                              style: textTheme.titleMedium?.rq.copyWith(height: 15 / 12, color: const Color(0xff505050)),
                                                                                            ),
                                                                                            widget.colorNum == ""
                                                                                                ? SizedBox.shrink()
                                                                                                : MyTextWidget(
                                                                                                    'color ',
                                                                                                    style: textTheme.titleMedium?.rq.copyWith(height: 15 / 12, color: const Color(0xff505050)),
                                                                                                  ),
                                                                                            widget.colorNum == ""
                                                                                                ? SizedBox.shrink()
                                                                                                : MyTextWidget(
                                                                                                    '${widget.colorName} ',
                                                                                                    style: textTheme.titleMedium?.mq.copyWith(height: 15 / 12, color: Color(int.parse('0xff${widget.colorNum.substring(1)}'))),
                                                                                                  ),
                                                                                            widget.size == ""
                                                                                                ? SizedBox.shrink()
                                                                                                : MyTextWidget(
                                                                                                    'size ',
                                                                                                    style: textTheme.titleMedium?.rq.copyWith(height: 15 / 12, color: const Color(0xff505050)),
                                                                                                  ),
                                                                                            widget.size == ""
                                                                                                ? SizedBox.shrink()
                                                                                                : MyTextWidget(
                                                                                                    '${widget.size} ',
                                                                                                    style: textTheme.titleMedium?.mq.copyWith(height: 15 / 12, color: const Color(0xff505050)),
                                                                                                  ),
                                                                                          ].reversed.toList(),
                                                                                        )
                                                                                      }
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            if (itemCount >
                                                                                0) ...{
                                                                              Positioned(
                                                                                top: -35,
                                                                                left: -35,
                                                                                child: Container(
                                                                                  width: 55,
                                                                                  height: 55,
                                                                                  decoration: BoxDecoration(border: Border.all(color: Colors.blue), borderRadius: BorderRadius.circular(20), color: colorScheme.white),
                                                                                ),
                                                                              ),
                                                                              Positioned(
                                                                                left: 0,
                                                                                child: Padding(
                                                                                  padding: EdgeInsets.only(top: itemCount == 1 ? 0 : 7.h),
                                                                                  child: SvgPicture.asset(
                                                                                    itemCount == 1 ? AppAssets.binSvg : AppAssets.minusMarkSvg,
                                                                                    height: itemCount == 1 ? 15.h : 3.h,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            },
                                                                            Positioned(
                                                                              top: -35,
                                                                              right: -35,
                                                                              child: Container(
                                                                                width: 55,
                                                                                height: 55,
                                                                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.blue), color: colorScheme.white),
                                                                              ),
                                                                            ),
                                                                            SvgPicture.asset(
                                                                              AppAssets.plusMarkSvg,
                                                                              height: 15.h,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ));
                                                            }),
                                                      )
                                                : BlocBuilder<HomeBloc,
                                                    HomeState>(
                                                    buildWhen: (p, c) =>
                                                        p.getStartingSettingsStatus !=
                                                        c.getStartingSettingsStatus,
                                                    builder: (context, state) {
                                                      int notificationTypeId = state
                                                              .startingSetting
                                                              ?.notificationTypes
                                                              ?.firstWhere(
                                                                  (type) =>
                                                                      type.name ==
                                                                      'product availability',
                                                                  orElse: () =>
                                                                      NotificationType(
                                                                          id: -1))
                                                              .id ??
                                                          -1;

                                                      return notificationTypeId ==
                                                              -1
                                                          ? SizedBox.shrink()
                                                          : NotifyWhenQuantityAvailableButton(
                                                              unAvailableSize:
                                                                  selectedSizeByUser,
                                                              notificationTypeId:
                                                                  notificationTypeId,
                                                              productId: widget
                                                                  .productId,
                                                              selectedColorName:
                                                                  widget
                                                                      .colorName,
                                                            );
                                                    },
                                                  ));
                                      });
                                }),
                            if (currentTab != 3) ...{
                              const Spacer(),
                              Expanded(
                                flex: 5,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                                  .getProductDetailWithoutSimilarRelatedProductsStatus,
                                      builder: (context, state) {
                                        print("-------------");
                                        return state.getProductDetailWithoutSimilarRelatedProductsStatus ==
                                                GetProductDetailWithoutSimilarRelatedProductsStatus
                                                    .loading
                                            ? Shimmer.fromColors(
                                                baseColor: Colors.grey.shade400,
                                                highlightColor:
                                                    Colors.grey.shade100,
                                                child: SvgPicture.asset(
                                                  (state
                                                              .cachedProductWithoutRelatedProductsModel[
                                                                  widget
                                                                      .productId]
                                                              ?.product
                                                              ?.isLiked ??
                                                          false)
                                                      ? AppAssets
                                                          .favoriteActiveSvg
                                                      : AppAssets.favoriteSvg,
                                                ),
                                              )
                                            : BarWidget(
                                                text:
                                                    "${state.cachedProductWithoutRelatedProductsModel[widget.productId]?.product?.countOfLikes ?? 0}",
                                                svgPath: (state
                                                            .cachedProductWithoutRelatedProductsModel[
                                                                widget
                                                                    .productId]
                                                            ?.product
                                                            ?.isLiked ??
                                                        false)
                                                    ? AppAssets
                                                        .favoriteActiveSvg
                                                    : AppAssets.favoriteSvg,
                                                onTap: () {
                                                  homeBloc.add(
                                                      AddOrRemoveLikeForProductEvent(
                                                          isFavourite: !(state
                                                                  .cachedProductWithoutRelatedProductsModel[
                                                                      widget
                                                                          .productId]
                                                                  ?.product
                                                                  ?.isLiked ??
                                                              false),
                                                          productId: widget
                                                              .productId));
                                                  widget.clickOnFavorite;
                                                });
                                      },
                                    ),
                                    state
                                                .getCommentForProductModel[
                                                    widget.productId]
                                                ?.commentsForProduct
                                                ?.commentsCount ==
                                            null
                                        ? Shimmer.fromColors(
                                            baseColor: Colors.grey.shade400,
                                            highlightColor:
                                                Colors.grey.shade100,
                                            child: SvgPicture.asset(
                                              AppAssets.chatMarkSvg,
                                            ),
                                          )
                                        : BarWidget(
                                            text:
                                                '${state.getCommentForProductModel[widget.productId]?.commentsForProduct?.commentsCount ?? 0}',
                                            svgPath: currentTab == 0
                                                ? AppAssets.chatMarkActiveSvg
                                                : AppAssets.chatMarkSvg,
                                            onTap: widget.clickOnComments),
                                    BlocBuilder<ChatBloc, ChatState>(
                                      buildWhen: (previous, current) =>
                                          previous.getSharedProductCountStatus !=
                                              current
                                                  .getSharedProductCountStatus ||
                                          previous.getSharedProductCount?[
                                                  widget.productId] !=
                                              current.getSharedProductCount?[
                                                  widget.productId],
                                      builder: (context, state) {
                                        return state.getSharedProductCount?[
                                                        widget.productId] ==
                                                    null &&
                                                state.getSharedProductCountStatus ==
                                                    GetSharedProductCountStatus
                                                        .loading
                                            ? Shimmer.fromColors(
                                                baseColor: Colors.grey.shade400,
                                                highlightColor:
                                                    Colors.grey.shade100,
                                                child: SvgPicture.asset(
                                                    AppAssets.shareSvg),
                                              )
                                            : BarWidget(
                                                text:
                                                    '${state.getSharedProductCount?[widget.productId] ?? "0"}',
                                                svgPath: AppAssets.shareSvg,
                                                color: currentTab == 1
                                                    ? Color(0xff505050)
                                                    : null,
                                                onTap: widget.clickOnShare);
                                      },
                                    ),
                                    BarWidget(
                                        svgPath: AppAssets.moreOptionSvg,
                                        color: currentTab == 2
                                            ? Color(0xff505050)
                                            : null,
                                        onTap: widget.clickOnMoreOptions),
                                  ],
                                ),
                              )
                            }
                          ],
                        );
                      }),
                ),
                const SizedBox(
                  height: 20,
                )
              ],
            ));
      },
    );
  }
}

class BarWidget extends StatelessWidget {
  const BarWidget(
      {super.key,
      this.text,
      required this.svgPath,
      required this.onTap,
      this.color});

  final String svgPath;
  final String? text;
  final Color? color;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
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
              color: color,
              height: 30.h,
            ),
            if (text != null) ...{
              5.verticalSpace,
              MyTextWidget(text!,
                  style: context.textTheme.titleMedium?.rq.copyWith(
                    color: Color(0xff8D8D8D),
                  ))
            }
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
  final String? size;
  final int? countOfPieces;
  final String? colorNum;
  bool isDuplicate;

  ImageForAddToCart({
    this.colorName,
    this.colorNum,
    this.countOfPieces,
    this.images,
    this.quantity,
    this.isDuplicate = false,
    this.size,
  });

  ImageForAddToCart copyWith(
          {final String? colorName,
          final String? images,
          int? quantity,
          final String? size,
          final int? countOfPieces,
          final String? colorNum,
          bool? isDuplicate}) =>
      ImageForAddToCart(
          colorName: colorName ?? this.colorNum,
          images: images ?? this.images,
          quantity: quantity ?? this.quantity,
          countOfPieces: countOfPieces ?? this.countOfPieces,
          size: size ?? this.size,
          colorNum: colorName ?? this.colorName);

  factory ImageForAddToCart.fromJson(Map<String, dynamic> json) =>
      ImageForAddToCart(
        colorName: json["colorName"],
        images: json["images"],
        size: json["size"],
        quantity: json["quantity"],
        countOfPieces: json["count_of_pieces"],
        colorNum: json["colorNum"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "colorName": colorName,
        "images": images,
        "size": size,
        "quantity": quantity,
        "count_of_pieces": countOfPieces,
        "colorNum": colorNum,
      };
}
