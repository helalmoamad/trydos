import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/features/app/my_text_widget.dart';

import '../../../../../common/constant/design/assets_provider.dart';
import '../../../../../core/utils/responsive_padding.dart';

class ProductDetailsSheetBottomBar extends StatefulWidget {
  const ProductDetailsSheetBottomBar(
      {super.key,
      required this.addToBagButtonShapeNotifier,
      required this.clickOnFavorite,
      required this.clickOnComments,
      required this.clickOnShare,
      required this.clickOnMoreOptions,
      required this.currentActiveTab});

  final ValueNotifier<int> addToBagButtonShapeNotifier;

  final ValueNotifier<int> currentActiveTab;

  final void Function() clickOnFavorite;
  final void Function() clickOnComments;
  final void Function() clickOnShare;
  final void Function() clickOnMoreOptions;

  @override
  State<ProductDetailsSheetBottomBar> createState() =>
      _ProductDetailsSheetBottomBarState();
}

class _ProductDetailsSheetBottomBarState
    extends State<ProductDetailsSheetBottomBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;

  @override
  void initState() {
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
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
      child: Container(
        color: colorScheme.white,
        child: Column(
          children: [
            10.verticalSpace,
            Padding(
              padding: HWEdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ValueListenableBuilder<int>(
                      valueListenable: widget.addToBagButtonShapeNotifier,
                      builder: (context, itemCount, _) {
                        return GestureDetector(
                          onTapDown: (details) {
                            if (itemCount > 0) {
                              if (details.localPosition.dx <= 40.w) {
                                animationController.forward();
                                widget.addToBagButtonShapeNotifier.value--;
                              } else if (details.localPosition.dx >= 140.w) {
                                animationController.forward();
                                widget.addToBagButtonShapeNotifier.value++;
                              }
                            } else {
                              animationController.forward();
                              widget.addToBagButtonShapeNotifier.value++;
                            }
                          },
                          child: AnimatedBuilder(
                              animation: animationController,
                              builder: (context, child) {
                                final sineValue =
                                    sin(3 * 2 * pi * animationController.value);
                                return Transform.translate(
                                    offset: Offset(sineValue * 3, 0),
                                    child: SizedBox(
                                      width: itemCount > 0 ? 197.w : 97.w,
                                      child: Stack(
                                        alignment: Alignment.topRight,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                color: itemCount > 0
                                                    ? Color(0xffCEFFE6)
                                                    : Color(0xffF8F8F8)),
                                            child: Center(
                                              child: Padding(
                                                padding: HWEdgeInsets.symmetric(
                                                    vertical: 10),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.end,
                                                      children: [
                                                        if (itemCount > 0) ...{
                                                          Expanded(
                                                              child: SizedBox(
                                                            height: 20,
                                                            child:
                                                                ListView.builder(
                                                              itemBuilder:
                                                                  (context,
                                                                      index) {
                                                                return Align(
                                                                    widthFactor: 1 -
                                                                        (itemCount /
                                                                            4 *
                                                                            0.3),
                                                                    child:
                                                                        Container(
                                                                      width: 15,
                                                                      height: 20,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        image:
                                                                            DecorationImage(
                                                                          image: AssetImage(
                                                                              AppAssets.profileJpg),
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                5.0),
                                                                      ),
                                                                    ));
                                                              },
                                                              reverse: true,
                                                              shrinkWrap: true,
                                                              scrollDirection:
                                                                  Axis.horizontal,
                                                              itemCount:
                                                                  itemCount,
                                                            ),
                                                          ))
                                                        } else
                                                          Spacer(),
                                                        SvgPicture.asset(
                                                          AppAssets.bagSvg,
                                                          height: 30.h,
                                                        ),
                                                        Spacer()
                                                      ],
                                                    ),
                                                    5.verticalSpace,
                                                    MyTextWidget(
                                                      itemCount > 0
                                                          ? '$itemCount'
                                                          : 'Add to bag',
                                                      style: itemCount > 0
                                                          ? textTheme.caption?.bq
                                                              .copyWith(
                                                                  color: Color(
                                                                      0xff505050))
                                                          : textTheme.caption?.rq
                                                              .copyWith(
                                                                  color: Color(
                                                                      0xff505050)),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (itemCount > 0) ...{
                                            Positioned(
                                              top: -35,
                                              left: -35,
                                              child: Container(
                                                width: 55,
                                                height: 55,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(20),
                                                    color: colorScheme.white),
                                              ),
                                            ),
                                            Positioned(
                                              left: 0,
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    top: itemCount == 1
                                                        ? 0
                                                        : 7.h),
                                                child: SvgPicture.asset(
                                                  itemCount == 1
                                                      ? AppAssets.binSvg
                                                      : AppAssets
                                                          .minusMarkSvg,
                                                  height: itemCount == 1
                                                      ? 15.h
                                                      : 3.h,
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
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  color: colorScheme.white),
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
                        );
                      }),
                  Spacer(),
                  Expanded(
                    flex: 5,
                    child: ValueListenableBuilder<int>(
                        valueListenable: widget.currentActiveTab,
                        builder: (context, currentTab, _) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                  color:
                                      currentTab == 1 ? Color(0xff505050) : null,
                                  onTap: widget.clickOnShare),
                              BarWidget(
                                  svgPath: AppAssets.moreOptionSvg,
                                  color:
                                      currentTab == 2 ? Color(0xff505050) : null,
                                  onTap: widget.clickOnMoreOptions),
                            ],
                          );
                        }),
                  )
                ],
              ),
            ),
            20.verticalSpace
          ],
        ),
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
