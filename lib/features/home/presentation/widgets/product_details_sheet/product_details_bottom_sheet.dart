import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
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
  final PanelController panelController = PanelController();

  @override
  void initState() {
    _focusNode.addListener(_onFocusChange);

    super.initState();
  }

  @override
  void dispose() {
    _focusNode.addListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {});
  }

  final _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ValueListenableBuilder<int>(
            valueListenable: currentActiveTab,
            builder: (context, currentTab, _) {
              return SlidingUpPanel(
                maxHeight: 0.54.sh,
                minHeight: 0.098.sh,
                onPanelClosed: (){
                  currentActiveTab.value = -1;
                },
                controller: panelController,
                panelBuilder: (controller) => Column(
                  children: [
                    ProductDetailsSheetHeader(
                        addToBagButtonShapeNotifier:
                            addToBagButtonShapeNotifier),
                    currentTab >= 0
                        ? SizedBox(
                            height: 350,
                            child: PageView(
                              physics: const cupertino.ClampingScrollPhysics(),
                              scrollBehavior:
                                  const cupertino.CupertinoScrollBehavior(),
                              controller: pageController,
                              onPageChanged: (index) {
                                currentActiveTab.value = index;
                                if (indicesOfChatCardsToShare
                                    .value.isNotEmpty) {
                                  indicesOfChatCardsToShare.value = [];
                                }
                              },
                              children: [
                                ProductDetailsSheetCommentsContent(
                                    scrollController: currentTab == 0 ? controller : null),
                                ProductDetailsSheetShareContent(
                                    focusNode: _focusNode,
                                    scrollController: currentTab == 1 ? controller : null,
                                    indicesOfChatCardsToShare:
                                        indicesOfChatCardsToShare),
                                ProductDetailsSheetMoreOptionsContent(
                                    scrollController: currentTab == 2 ? controller : null)
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0)),
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
                        panelController.open();
                        currentActiveTab.value = 0;
                            pageController.jumpToPage(0);
                      },
                      clickOnFavorite: () {
                        currentActiveTab.value = -1;
                      },
                      clickOnMoreOptions: () {
                        panelController.open();
                        currentActiveTab.value = 2;
                            pageController.jumpToPage(2);
                      },
                      clickOnShare: () {
                        panelController.open();
                        currentActiveTab.value = 1;
                            pageController.jumpToPage(1);
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

class Delegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ProductDetailsSheetHeader(
        addToBagButtonShapeNotifier: ValueNotifier(0));
  }

  @override
  double get maxExtent => 76;

  @override
  double get minExtent => 76;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
