import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/core/utils/responsive_padding.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_sheet_bottom_bar.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_sheet_comments_content.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_sheet_header.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_sheet_more_options_content.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_sheet_share_content.dart';

class ProductDetailsBottomSheet extends StatefulWidget {
  const ProductDetailsBottomSheet({super.key});

  @override
  State<ProductDetailsBottomSheet> createState() =>
      _ProductDetailsBottomSheetState();
}

class _ProductDetailsBottomSheetState extends State<ProductDetailsBottomSheet> {
  final ValueNotifier<int> addToBagButtonShapeNotifier = ValueNotifier(0);
  final ValueNotifier<List<int>> indicesOfChatCardsToShare = ValueNotifier([]);
  final ValueNotifier<int> currentActiveTab = ValueNotifier(-1);
  final PageController pageController = PageController();
  final DraggableScrollableController draggableScrollableController =
      DraggableScrollableController();

  @override
  void initState() {
    draggableScrollableController.addListener(listener);
    _focusNode.addListener(_onFocusChange);
    super.initState();
  }

  @override
  void dispose() {
    draggableScrollableController.removeListener(listener);
    _focusNode.addListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {});
  }

  void listener() {
    if (draggableScrollableController.size == 73.5 / (1.sh - 100.h)) {
      draggableScrollableController.reset();
      currentActiveTab.value = -1;
    }
  }

  final _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ValueListenableBuilder<int>(
            valueListenable: currentActiveTab,
            builder: (context, currentTab, _) {
              return Flexible(
                child: DraggableScrollableSheet(
                    initialChildSize: currentTab == -1
                        ? 73.5 / (1.sh - 100.h)
                        : _focusNode.hasFocus
                            ? 1.h
                            : 423.5 / (1.sh - 100.h),
                    minChildSize: 73.5 / (1.sh - 100.h),
                    snap: true,
                    snapAnimationDuration: Duration(milliseconds: 100),
                    maxChildSize: currentTab == -1
                        ? 73.5 / (1.sh - 100.h)
                        : _focusNode.hasFocus
                            ? 1.h
                            : 423.5 / (1.sh - 100.h),
                    controller: draggableScrollableController,
                    builder: (context, scrollController) {
                      if (draggableScrollableController.isAttached) {
                        draggableScrollableController.reset();
                      }
                      return ScrollConfiguration(
                        behavior: cupertino.CupertinoScrollBehavior(),
                        child: SingleChildScrollView(
                            physics: ClampingScrollPhysics(),
                            controller: scrollController,
                            child: Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                Container(
                                  width: 1.sw,
                                  decoration: BoxDecoration(
                                      color: colorScheme.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0x1a000000),
                                          offset: Offset(0, -3),
                                          blurRadius: 20,
                                        ),
                                      ],
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(30),
                                          topRight: Radius.circular(30))),
                                  child: Directionality(
                                    textDirection: TextDirection.ltr,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ProductDetailsSheetHeader(
                                            addToBagButtonShapeNotifier:
                                                addToBagButtonShapeNotifier),
                                        currentTab >= 0
                                            ? SizedBox(
                                                height: 350,
                                                child: PageView(
                                                  physics:
                                                      const ClampingScrollPhysics(),
                                                  scrollBehavior: const cupertino
                                                      .CupertinoScrollBehavior(),
                                                  controller: pageController,
                                                  onPageChanged: (index) {
                                                    currentActiveTab.value =
                                                        index;
                                                    if (indicesOfChatCardsToShare
                                                        .value.isNotEmpty) {
                                                      indicesOfChatCardsToShare
                                                          .value = [];
                                                    }
                                                  },
                                                  children: [
                                                    ProductDetailsSheetCommentsContent(),
                                                    ProductDetailsSheetShareContent(
                                                        focusNode: _focusNode,
                                                        indicesOfChatCardsToShare:
                                                            indicesOfChatCardsToShare),
                                                    ProductDetailsSheetMoreOptionsContent()
                                                  ],
                                                ),
                                              )
                                            : const SizedBox.shrink(),
                                      ],
                                    ),
                                  ),
                                ),
                                currentTab != -1
                                    ? Positioned(
                                        top: 7,
                                        child: SvgPicture.asset(
                                          AppAssets.minusMarkSvg,
                                          width: 25,
                                          color: Colors.grey.shade200,
                                        ))
                                    : const SizedBox.shrink(),
                              ],
                            )),
                      );
                    }),
              );
            }),
        Divider(
          height: 0.h,
          color: Color(0xffE6E6E6),
        ),
        ValueListenableBuilder<List<int>>(
            valueListenable: indicesOfChatCardsToShare,
            builder: (context, indices, _) {
              return indices.isEmpty
                  ? ProductDetailsSheetBottomBar(
                      clickOnComments: () {
                        currentActiveTab.value = 0;
                        Future.delayed(
                          Duration(milliseconds: 100),
                          () {
                            pageController.animateToPage(0,
                                duration: Duration(milliseconds: 200),
                                curve: Curves.easeInOut);
                          },
                        );
                      },
                      clickOnFavorite: () {
                        currentActiveTab.value = -1;
                      },
                      clickOnMoreOptions: () {
                        currentActiveTab.value = 2;
                        Future.delayed(
                          Duration(milliseconds: 100),
                          () {
                            pageController.animateToPage(2,
                                duration: Duration(milliseconds: 200),
                                curve: Curves.easeInOut);
                          },
                        );
                      },
                      clickOnShare: () {
                        currentActiveTab.value = 1;
                        Future.delayed(
                          Duration(milliseconds: 100),
                          () {
                            pageController.animateToPage(1,
                                duration: Duration(milliseconds: 200),
                                curve: Curves.easeInOut);
                          },
                        );
                      },
                      currentActiveTab: currentActiveTab,
                      addToBagButtonShapeNotifier: addToBagButtonShapeNotifier)
                  : ShareButton(
                      onTap: () {},
                    );
            }),
      ],
    );
  }
}

class ShareButton extends StatelessWidget {
  const ShareButton({super.key, this.onTap});

  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        12.verticalSpace,
        Material(
          color: Colors.transparent,
          child: InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: onTap,
            child: Container(
              padding: HWEdgeInsets.symmetric(vertical: 20),
              margin: HWEdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xff3c3c3c),
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x1a000000),
                    offset: Offset(0, 3),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      AppAssets.shareSvg,
                      color: Colors.white,
                      height: 20,
                    ),
                    10.horizontalSpace,
                    MyTextWidget(
                      'Send',
                      style: context.textTheme.headline6?.rq
                          .copyWith(color: Colors.white),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
