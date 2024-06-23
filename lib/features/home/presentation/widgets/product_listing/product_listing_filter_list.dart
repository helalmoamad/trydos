import 'package:flutter/cupertino.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter/rendering.dart' as rendring;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:tuple/tuple.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../../app/my_cached_network_image.dart';
import '../../../../app/my_text_widget.dart';

class StackedFiltersList extends StatefulWidget {
  const StackedFiltersList(
      {super.key, required this.onMoveToAnotherFiltersSection});

  final void Function(String message) onMoveToAnotherFiltersSection;

  @override
  _StackedFiltersListState createState() => _StackedFiltersListState();
}

class _StackedFiltersListState extends State<StackedFiltersList> {
  final ValueNotifier<bool> scaleTheTopItemInFiltersStack =
      ValueNotifier(false);
  final ValueNotifier<int> expandingFiltersStack = ValueNotifier(-1);
  final ValueNotifier<int> currentActiveSection = ValueNotifier(0);
  final ValueNotifier<List<Tuple3<int, int, double>>> selectedFiltersNotifier =
      ValueNotifier([]);
  late AutoScrollController autoScrollController;

  int lastSectionDisplayed = 0;

  @override
  void initState() {
    autoScrollController = AutoScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Tuple3<int, int, double>>>(
        valueListenable: selectedFiltersNotifier,
        builder: (context, selectedFilters, child) {
          return Column(
            children: [
              SizedBox(
                height: 115,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 15,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 35.0),
                        child: ValueListenableBuilder<int>(
                            valueListenable: currentActiveSection,
                            builder: (context, currentActive, _) {
                              return SizedBox(
                                height: 8,
                                child: ListView.builder(
                                    itemCount: 3,
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (ctx, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          if(currentActiveSection.value == index) return;
                                          currentActiveSection.value = index;
                                          autoScrollController.scrollToIndex(
                                              2 * index,
                                              duration: Duration(milliseconds: 200),
                                              preferPosition:
                                                  AutoScrollPosition.begin);
                                          widget.onMoveToAnotherFiltersSection
                                              .call('Section ${index + 1}');
                                        },
                                        child: Container(
                                          height: 8,
                                          width: 8,
                                          margin: EdgeInsets.only(right: 1.5),
                                          decoration: BoxDecoration(
                                              color: currentActive == index
                                                  ? Color(0xff505050)
                                                  : null,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Color(0xff505050))),
                                        ),
                                      );
                                    }),
                              );
                            }),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      ValueListenableBuilder<List<Tuple3<int, int, double>>>(
                          valueListenable: selectedFiltersNotifier,
                          builder: (context, selectedFilters, child) {
                            return ScrollConfiguration(
                              behavior: CupertinoScrollBehavior(),
                              child: Expanded(
                                child: ListView.builder(
                                  controller: autoScrollController,
                                    itemCount: 3 + (3 - 1),
                                    physics: ClampingScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    itemBuilder: (ctx, index) {
                                      if (index & 1 == 0)
                                        return AutoScrollTag(
                                          key: ValueKey(index),
                                          controller: autoScrollController,
                                          index: index,
                                          child: VisibilityDetector(
                                              key: Key('$index-section'),
                                              onVisibilityChanged:
                                                  (visibilityInfo) {
                                                    if(autoScrollController.hasClients && autoScrollController.position.userScrollDirection == rendring.ScrollDirection.idle){
                                                      return ;
                                                    }
                                                double visiblePercentage =
                                                    visibilityInfo.visibleFraction *
                                                        100;
                                                if (visiblePercentage == 0 ) {
                                                  int sectionIndex = -1;
                                                  // scroll to the right
                                                  if(autoScrollController.hasClients && autoScrollController.position.userScrollDirection == rendring.ScrollDirection.reverse){
                                                    sectionIndex = int.parse(visibilityInfo.key.toString()[3]) ~/ 2 + 2;
                                                  }else{
                                                    sectionIndex = int.parse(visibilityInfo.key.toString()[3]) ~/ 2;
                                                  }
                                                  currentActiveSection.value = sectionIndex - 1 ;
                                                      widget
                                                      .onMoveToAnotherFiltersSection
                                                      .call(
                                                          'Section $sectionIndex');
                                                }
                                              },
                                              child: ListView(
                                                scrollDirection: Axis.horizontal,
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                children: [
                                                  ValueListenableBuilder<int>(
                                                      valueListenable:
                                                          expandingFiltersStack,
                                                      builder: (context,
                                                          currentExpandedIndex, child) {
                                                        return AnimatedContainer(
                                                          curve: Curves.fastEaseInToSlowEaseOut,
                                                          duration: Duration(
                                                              milliseconds: 300),
                                                          margin: EdgeInsets.only(
                                                              right: 5),
                                                          width: currentExpandedIndex == index
                                                              ? (75 + 4 * 55)
                                                              : 80.0,
                                                          height: 70.0,
                                                          child: Stack(
                                                            alignment:
                                                                Alignment.topLeft,
                                                            children: [
                                                              ...List.generate(
                                                                4,
                                                                (innerIndex) =>
                                                                    AnimatedPositioned(
                                                                        curve: Curves
                                                                            .fastEaseInToSlowEaseOut,
                                                                        duration: Duration(
                                                                            milliseconds:
                                                                                300),
                                                                        top: currentExpandedIndex == index
                                                                            ? (70 -
                                                                                50)
                                                                            : (70 - 50) /
                                                                                2,
                                                                        right: currentExpandedIndex == index
                                                                            ? innerIndex * 55
                                                                            : innerIndex >= (4 - 2)
                                                                                ? (innerIndex - 1) * 3
                                                                                : 0,
                                                                        child: FilterCircleWidget(
                                                                          width: 50,
                                                                          height:
                                                                              50,
                                                                          addOrRemoveSpecificFilter:
                                                                              (bool
                                                                                  add) {
                                                                            if (add) {
                                                                              selectedFiltersNotifier.value.add(Tuple3(
                                                                                  index,
                                                                                  innerIndex,
                                                                                  10));
                                                                              selectedFiltersNotifier
                                                                                  .notifyListeners();
                                                                            } else {
                                                                              selectedFiltersNotifier.value.remove(Tuple3(
                                                                                  index,
                                                                                  innerIndex,
                                                                                  10));
                                                                              selectedFiltersNotifier
                                                                                  .notifyListeners();
                                                                            }
                                                                          },
                                                                          displayFilterMark: selectedFilters.contains(Tuple3(
                                                                              index,
                                                                              innerIndex,
                                                                              10)),
                                                                          paddingValue:
                                                                          currentExpandedIndex == index
                                                                                  ? 5
                                                                                  : 0,
                                                                          borderColor:
                                                                              colorScheme
                                                                                  .white,
                                                                          isExpanded:
                                                                          currentExpandedIndex == index,
                                                                        )),
                                                              ),
                                                              ValueListenableBuilder<
                                                                      bool>(
                                                                  valueListenable:
                                                                      scaleTheTopItemInFiltersStack,
                                                                  builder: (context,
                                                                      scale, _) {
                                                                    return FilterCircleWidget(
                                                                        width: 70,
                                                                        height: 70,
                                                                        scale:
                                                                            scale,
                                                                        paddingValue:
                                                                            0,
                                                                        isExpanded:
                                                                        currentExpandedIndex == index,
                                                                        expandStackedItemsFunction:
                                                                            () {
                                                                          scaleTheTopItemInFiltersStack
                                                                                  .value =
                                                                              true;
                                                                          expandingFiltersStack
                                                                                  .value = index;
                                                                          Future.delayed(
                                                                              Duration(
                                                                                  milliseconds: 100),
                                                                              () {
                                                                            scaleTheTopItemInFiltersStack.value =
                                                                                false;
                                                                          });
                                                                        },
                                                                        displayFilterMark:
                                                                            selectedFilters.contains(Tuple3(
                                                                                index,
                                                                                -1,
                                                                                15)),
                                                                        addOrRemoveSpecificFilter:
                                                                            (bool
                                                                                add) {
                                                                          if (add) {
                                                                            selectedFiltersNotifier.value.add(Tuple3(
                                                                                index,
                                                                                -1,
                                                                                15));
                                                                            selectedFiltersNotifier
                                                                                .notifyListeners();
                                                                          } else {
                                                                            selectedFiltersNotifier.value.remove(Tuple3(
                                                                                index,
                                                                                -1,
                                                                                15));
                                                                            selectedFiltersNotifier
                                                                                .notifyListeners();
                                                                          }
                                                                        });
                                                                  }),
                                                            ],
                                                          ),
                                                        );
                                                      }),
                                                  ...List.generate(
                                                      10,
                                                      (innerIndex) =>
                                                          FilterCircleWidget(
                                                            width: 70,
                                                            height: 70,
                                                            displayFilterMark:
                                                                selectedFilters
                                                                    .contains(Tuple3(
                                                                        index,
                                                                        innerIndex,
                                                                        15)),
                                                            withBackGroundShadow:
                                                                true,
                                                            addOrRemoveSpecificFilter:
                                                                (bool add) {
                                                              if (add) {
                                                                selectedFiltersNotifier
                                                                    .value
                                                                    .add(Tuple3(
                                                                        index,
                                                                        innerIndex,
                                                                        15));
                                                                selectedFiltersNotifier
                                                                    .notifyListeners();
                                                              } else {
                                                                selectedFiltersNotifier
                                                                    .value
                                                                    .remove(Tuple3(
                                                                        index,
                                                                        innerIndex,
                                                                        15));
                                                                selectedFiltersNotifier
                                                                    .notifyListeners();
                                                              }
                                                            },
                                                          ))
                                                ],
                                              )),
                                        );
                                      return Container(
                                        margin: EdgeInsets.only(top: 10 , right: 10 , bottom: 45),
                                        width: 0.5,
                                        color: Color(0xff707070),
                                      );
                                    }),
                              ),
                            );
                          }),
                    ],
                  ),
                ),
              ),
              if (selectedFilters.isNotEmpty) ...{
                SizedBox(
                  height: 5,
                ),
                Container(
                  width: 1.sw,
                  height: 30,
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  padding: EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                      color: Color(0xffEFEFEF),
                      borderRadius: BorderRadius.circular(10)),
                  child: SizedBox(
                    height: 15,
                    child: ListView(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        children: [
                          Center(
                              child: FilterSelectedMark(width: 15, height: 15)),
                          SizedBox(
                            width: 10,
                          ),
                          ...List.generate(
                              selectedFilters.length,
                              (index) => GestureDetector(
                                    onTap: () {
                                      selectedFiltersNotifier.value
                                          .remove(selectedFilters[index]);
                                      selectedFiltersNotifier.notifyListeners();
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        FilterImage(
                                            width: selectedFilters[index].item3,
                                            height:
                                                selectedFilters[index].item3,
                                            withInnerShadow: true,
                                            withBackGroundShadow: true,
                                            borderColor: Color(0xffFF5F61),
                                            imageUrl:
                                                'assets/images/details_circle.jpg'),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        MyTextWidget(
                                          'T-shirt',
                                          maxLines: 1,
                                          textAlign: TextAlign.center,
                                          style: context.textTheme.caption?.rq
                                              .copyWith(
                                                  color: Color(0xff8E8E8E),
                                                  letterSpacing: 0,
                                                  height: 1.25),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                      ],
                                    ),
                                  )),
                        ]),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
              }
            ],
          );
        });
  }
}

class FilterCircleWidget extends StatefulWidget {
  const FilterCircleWidget(
      {super.key,
      this.isExpanded = true,
      required this.width,
      required this.height,
      required this.addOrRemoveSpecificFilter,
      this.withBackGroundShadow = true,
      this.paddingValue = 10,
      this.scale = false,
      this.markWidth = 20,
      this.markHeight = 20,
      this.borderColor,
      this.expandStackedItemsFunction,
      required this.displayFilterMark});

  final Color? borderColor;
  final bool isExpanded;
  final double width;
  final double markWidth;
  final double paddingValue;
  final double height;
  final double markHeight;
  final bool withBackGroundShadow;
  final bool scale;
  final bool displayFilterMark;
  final void Function(bool add) addOrRemoveSpecificFilter;
  final void Function()? expandStackedItemsFunction;

  @override
  State<FilterCircleWidget> createState() => _FilterCircleWidgetState();
}

class _FilterCircleWidgetState extends State<FilterCircleWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: widget.paddingValue),
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  if (!widget.isExpanded) {
                    widget.expandStackedItemsFunction?.call();
                    return;
                  }
                  widget.addOrRemoveSpecificFilter
                      .call(!widget.displayFilterMark);
                },
                child: Stack(
                  children: [
                    AnimatedScale(
                      curve: Curves.fastEaseInToSlowEaseOut,
                      scale: widget.scale ? 0.92 : 1,
                      duration: Duration(milliseconds: 100),
                      child: FilterImage(
                        imageUrl: 'assets/images/details_circle.jpg',
                        width: widget.width,
                        height: widget.height,
                        borderColor: widget.displayFilterMark
                            ? Color(0xffFF5F61)
                            : widget.borderColor,
                        withBackGroundShadow: !widget.displayFilterMark,
                        withInnerShadow: !widget.scale,
                      ),
                    ),
                    Visibility(
                        visible: widget.displayFilterMark,
                        child: FilterSelectedMark(
                            width: widget.markWidth, height: widget.markHeight))
                  ],
                ),
              ),
              if (widget.isExpanded) ...{
                SizedBox(height: 5),
                MyTextWidget(
                  'T-shirt',
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: context.textTheme.caption?.rq.copyWith(
                      color: Color(0xff8E8E8E), letterSpacing: 0, height: 1.25),
                ),
                MyTextWidget(
                  '1100',
                  textAlign: TextAlign.center,
                  style: context.textTheme.caption?.rq.copyWith(
                      color: Color(0xffC4C2C2),
                      fontSize: 10.sp,
                      letterSpacing: 0,
                      height: 1.3),
                )
              }
            ],
          ),
        ],
      ),
    );
  }
}

class FilterImage extends StatelessWidget {
  const FilterImage(
      {super.key,
      required this.width,
      required this.height,
      required this.withInnerShadow,
      required this.withBackGroundShadow,
      this.borderColor,
      required this.imageUrl});

  final double width;
  final double height;
  final bool withInnerShadow;
  final bool withBackGroundShadow;
  final Color? borderColor;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(180.0)),
          border: borderColor != null
              ? Border.all(width: 0.5, color: borderColor!)
              : null,
          boxShadow: withBackGroundShadow
              ? [
                  BoxShadow(
                    color: Color(0x19000000),
                    offset: Offset(0, 3),
                    blurRadius: 3,
                  ),
                ]
              : null),
      child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(180.0)),
          child: Stack(
            children: [
              imageUrl.contains('assets')
                  ? Image.asset(imageUrl,
                      width: width, fit: BoxFit.cover, height: height)
                  : MyCachedNetworkImage(
                      imageUrl: imageUrl,
                      width: width,
                      imageFit: BoxFit.cover,
                      height: height),
              //Image.asset(imageUrl , fit: BoxFit.cover, width: width, height: height,),
              Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  boxShadow: withInnerShadow
                      ? [
                          BoxShadow(
                            offset: Offset(0, 4),
                            blurRadius: 6,
                            color: Colors.white.withOpacity(0.5),
                            inset: true,
                          ),
                        ]
                      : null,
                ),
              ),
            ],
          )),
    );
  }
}

class FilterSelectedMark extends StatelessWidget {
  const FilterSelectedMark(
      {super.key, required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color(0x19000000),
                  offset: Offset(0, 3),
                  blurRadius: 3,
                ),
              ],
              borderRadius: BorderRadius.circular(180),
              color: Color(0xffFF5F61)),
          child: Center(
              child: SvgPicture.asset(
            AppAssets.filtersSvg,
            color: Colors.white,
            height: height / 2 ,
          )),
        ),
        Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(180),
            border: Border.all(width: 1, color: Color(0xffFF5F61)),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 4),
                blurRadius: 6,
                color: Colors.white.withOpacity(0.7),
                inset: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
