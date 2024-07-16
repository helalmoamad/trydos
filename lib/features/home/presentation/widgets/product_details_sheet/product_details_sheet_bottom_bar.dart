import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/notify_for_quantity_available_button.dart';

import '../../../../../common/constant/design/assets_provider.dart';
import '../../../../../core/utils/responsive_padding.dart';

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
      required this.currentActiveTab,
      required this.sizeIsNotAvailableNotifier,
      required this.imageUrl});

  final ValueNotifier<int> addToBagButtonShapeNotifier;

  final ValueNotifier<String?> sizeIsNotAvailableNotifier;

  final PanelController panelController;
  final String imageUrl;
  final String productId;
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
    return Directionality(
      textDirection: TextDirection.ltr,
      child: BlocBuilder<HomeBloc, HomeState>(
        buildWhen: (previous, current) =>
            previous.addImagesToProductIdForCart !=
            current.addImagesToProductIdForCart,
        builder: (context, state) {
          print(state.addImagesToProductIdForCart[widget.productId]);
          List<String> allimages = [];

          // حلقات متداخلة للوصول إلى جميع القيم
          state.addImagesToProductIdForCart[widget.productId] != null
              ? state.addImagesToProductIdForCart[widget.productId]!
                  .forEach((key, value) {
                  allimages.addAll(value);
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
                                  builder:
                                      (context, selectedSizeByUser, child) {
                                    return ValueListenableBuilder<int>(
                                        valueListenable:
                                            widget.addToBagButtonShapeNotifier,
                                        builder: (context, itemCount, _) {
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
                                                ? GestureDetector(
                                                    onTapDown: (details) {
                                                      if (currentTab != 3) {
                                                        widget.panelController
                                                            .open();
                                                        widget.currentActiveTab
                                                            .value = 3;
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
                                                          } else if (details
                                                                  .localPosition
                                                                  .dx >=
                                                              (1.sw - 90).w) {
                                                            animationController
                                                                .forward();
                                                            widget
                                                                .addToBagButtonShapeNotifier
                                                                .value++;
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
                                                          }
                                                        } else {
                                                          animationController
                                                              .forward();
                                                          widget
                                                              .addToBagButtonShapeNotifier
                                                              .value++;
                                                        }
                                                      }
                                                    },
                                                    child: AnimatedBuilder(
                                                        animation:
                                                            animationController,
                                                        builder:
                                                            (context, child) {
                                                          final sineValue = sin(3 *
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
                                                                        : itemCount >
                                                                                0
                                                                            ? 197.w
                                                                            : 97.w,
                                                                    child:
                                                                        Stack(
                                                                      alignment:
                                                                          Alignment
                                                                              .topRight,
                                                                      children: [
                                                                        AnimatedContainer(
                                                                          duration:
                                                                              const Duration(milliseconds: 300),
                                                                          curve:
                                                                              Curves.fastLinearToSlowEaseIn,
                                                                          decoration: BoxDecoration(
                                                                              border: Border.all(color: Colors.blue),
                                                                              borderRadius: BorderRadius.circular(20),
                                                                              color: itemCount > 0 ? const Color(0xffCEFFE6) : const Color(0xffF8F8F8)),
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                                                              child: Column(
                                                                                children: [
                                                                                  Row(
                                                                                    mainAxisAlignment: currentTab == 3 ? MainAxisAlignment.center : MainAxisAlignment.center,
                                                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                                                    children: [
                                                                                      if (itemCount > 0) ...{
                                                                                        Spacer(),
                                                                                        Expanded(
                                                                                            child: SizedBox(
                                                                                          height: 20,
                                                                                          child: ListView.builder(
                                                                                            itemBuilder: (context, index) {
                                                                                              return Align(widthFactor: 1 - (itemCount / 12 * 0.3), child: MyCachedNetworkImage(circleDimensions: 15, imageUrl: widget.imageUrl, width: 15, imageFit: BoxFit.cover, height: 20)); /*Container(
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
                                                                                            itemCount: itemCount,
                                                                                          ),
                                                                                        )),
                                                                                        Spacer()
                                                                                      } else
                                                                                        Spacer(),
                                                                                      Expanded(
                                                                                          child: SizedBox(
                                                                                        height: 20,
                                                                                        child: ListView.builder(
                                                                                          itemBuilder: (context, index) {
                                                                                            return Align(widthFactor: 1 - (itemCount / 12 * 0.3), child: MyCachedNetworkImage(circleDimensions: 15, imageUrl: allimages[index], width: 15, imageFit: BoxFit.cover, height: 20)); /*Container(
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
                                                                                      )),
                                                                                      SvgPicture.asset(
                                                                                        AppAssets.bagSvg,
                                                                                        height: 30.h,
                                                                                      ),
                                                                                      SizedBox(
                                                                                        width: state.addImagesToProductIdForCart[widget.productId] != null
                                                                                            ? state.addImagesToProductIdForCart[widget.productId]!.length > 1
                                                                                                ? 10
                                                                                                : 20
                                                                                            : 20,
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                  const SizedBox(
                                                                                    height: 5,
                                                                                  ),
                                                                                  if (currentTab != 3) ...{
                                                                                    MyTextWidget(
                                                                                      itemCount > 0 ? '$itemCount' : 'Add to bag',
                                                                                      style: itemCount > 0 ? textTheme.caption?.bq.copyWith(color: const Color(0xff505050)) : textTheme.caption?.rq.copyWith(color: const Color(0xff505050)),
                                                                                    )
                                                                                  } else ...{
                                                                                    Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      children: [
                                                                                        MyTextWidget(
                                                                                          'Add ',
                                                                                          style: textTheme.caption?.mq.copyWith(height: 15 / 12, color: const Color(0xff505050)),
                                                                                        ),
                                                                                        MyTextWidget(
                                                                                          'to bag ',
                                                                                          style: textTheme.caption?.rq.copyWith(height: 15 / 12, color: const Color(0xff505050)),
                                                                                        ),
                                                                                        MyTextWidget(
                                                                                          'blue ',
                                                                                          style: textTheme.caption?.mq.copyWith(height: 15 / 12, color: Colors.blue),
                                                                                        ),
                                                                                        MyTextWidget(
                                                                                          'color ',
                                                                                          style: textTheme.caption?.rq.copyWith(height: 15 / 12, color: const Color(0xff505050)),
                                                                                        ),
                                                                                        MyTextWidget(
                                                                                          'Medium ',
                                                                                          style: textTheme.caption?.mq.copyWith(height: 15 / 12, color: const Color(0xff505050)),
                                                                                        ),
                                                                                        MyTextWidget(
                                                                                          'size',
                                                                                          style: textTheme.caption?.rq.copyWith(height: 15 / 12, color: const Color(0xff505050)),
                                                                                        ),
                                                                                      ],
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
                                                                            top:
                                                                                -35,
                                                                            left:
                                                                                -35,
                                                                            child:
                                                                                Container(
                                                                              width: 55,
                                                                              height: 55,
                                                                              decoration: BoxDecoration(border: Border.all(color: Colors.blue), borderRadius: BorderRadius.circular(20), color: colorScheme.white),
                                                                            ),
                                                                          ),
                                                                          Positioned(
                                                                            left:
                                                                                0,
                                                                            child:
                                                                                Padding(
                                                                              padding: EdgeInsets.only(top: itemCount == 1 ? 0 : 7.h),
                                                                              child: SvgPicture.asset(
                                                                                itemCount == 1 ? AppAssets.binSvg : AppAssets.minusMarkSvg,
                                                                                height: itemCount == 1 ? 15.h : 3.h,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        },
                                                                        Positioned(
                                                                          top:
                                                                              -35,
                                                                          right:
                                                                              -35,
                                                                          child:
                                                                              Container(
                                                                            width:
                                                                                55,
                                                                            height:
                                                                                55,
                                                                            decoration: BoxDecoration(
                                                                                borderRadius: BorderRadius.circular(20),
                                                                                border: Border.all(color: Colors.blue),
                                                                                color: colorScheme.white),
                                                                          ),
                                                                        ),
                                                                        SvgPicture
                                                                            .asset(
                                                                          AppAssets
                                                                              .plusMarkSvg,
                                                                          height:
                                                                              15.h,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ));
                                                        }),
                                                  )
                                                : NotifyWhenQuantityAvailableButton(
                                                    unAvailableSize:
                                                        selectedSizeByUser,
                                                  ),
                                          );
                                        });
                                  }),
                              if (currentTab != 3) ...{
                                const Spacer(),
                                Expanded(
                                  flex: 5,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      BarWidget(
                                          text: '110K',
                                          svgPath: AppAssets.favoriteSvg,
                                          onTap: widget.clickOnFavorite),
                                      BarWidget(
                                          text: '110K',
                                          svgPath: currentTab == 0
                                              ? AppAssets.chatMarkActiveSvg
                                              : AppAssets.chatMarkSvg,
                                          onTap: widget.clickOnComments),
                                      BarWidget(
                                          text: '2K',
                                          svgPath: AppAssets.shareSvg,
                                          color: currentTab == 1
                                              ? Color(0xff505050)
                                              : null,
                                          onTap: widget.clickOnShare),
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
      ),
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
                  style: context.textTheme.caption?.rq.copyWith(
                    color: Color(0xff8D8D8D),
                  ))
            }
          ],
        ),
      ),
    );
  }
}
