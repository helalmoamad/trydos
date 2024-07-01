import 'package:flutter/cupertino.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter/rendering.dart' as rendring;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/price_filter.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/sizes_filters_list.dart';
import 'package:tuple/tuple.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../../app/app_widgets/loading_indicator/trydos_loader.dart';
import '../../../../app/my_cached_network_image.dart';
import '../../../../app/my_text_widget.dart';
import '../../../../story/presentation/widget/try_again.dart';
import '../../../data/models/get_product_filters_model.dart';
import '../../manager/home_bloc.dart';
import '../../manager/home_event.dart';
import '../../manager/home_state.dart';
import 'filters_normal_list.dart';

class StackedFiltersList extends StatefulWidget {
  const StackedFiltersList(
      {super.key,
      required this.onMoveToAnotherFiltersSection,
      required this.selectedFiltersNotifier,
      required this.listKey,
      required this.isExpanded,
      this.controller});

  final void Function(String message) onMoveToAnotherFiltersSection;
  final ValueNotifier<List<Tuple3<int, int?, double>>> selectedFiltersNotifier;
  final GlobalKey<AnimatedListState> listKey;
  final ScrollController? controller;
  final bool isExpanded;

  @override
  _StackedFiltersListState createState() => _StackedFiltersListState();
}

class _StackedFiltersListState extends State<StackedFiltersList> {
  final ValueNotifier<bool> scaleTheTopItemInFiltersStack =
      ValueNotifier(false);
  final ValueNotifier<bool> displayChosenFilters = ValueNotifier(false);
  final ValueNotifier<int> expandingFiltersStack = ValueNotifier(-1);
  final ValueNotifier<int> currentActiveSection = ValueNotifier(0);
  late AutoScrollController autoScrollController;
  final ValueNotifier<List<int>> selectedFiltersByBrand = ValueNotifier([]);
  final ValueNotifier<List<int>> selectedFiltersByOffer = ValueNotifier([]);
  final ValueNotifier<List<int>> selectedFiltersBySize = ValueNotifier([]);
  final GlobalKey<AnimatedListState> listForBrandsKey =
      GlobalKey<AnimatedListState>();
  final GlobalKey<AnimatedListState> listForOffersKey =
      GlobalKey<AnimatedListState>();
  final GlobalKey<AnimatedListState> listForSizesKey =
      GlobalKey<AnimatedListState>();
  int lastSectionDisplayed = 0;

  @override
  void initState() {
    widget.selectedFiltersNotifier.addListener(() {
      if (widget.selectedFiltersNotifier.value.isEmpty) {
        expandingFiltersStack.value = -1;
      }
      if (selectedFiltersBySize.value.length > 0 ||
          selectedFiltersByBrand.value.length > 0 ||
          widget.selectedFiltersNotifier.value.length > 0) {
        displayChosenFilters.value = true;
      } else {
        displayChosenFilters.value = false;
      }
    });
    selectedFiltersByBrand.addListener(() {
      if (selectedFiltersBySize.value.length > 0 ||
          selectedFiltersByBrand.value.length > 0 ||
          widget.selectedFiltersNotifier.value.length > 0) {
        displayChosenFilters.value = true;
      } else {
        displayChosenFilters.value = false;
      }
    });
    selectedFiltersBySize.addListener(() {
      if (selectedFiltersBySize.value.length > 0 ||
          selectedFiltersByBrand.value.length > 0 ||
          widget.selectedFiltersNotifier.value.length > 0) {
        displayChosenFilters.value = true;
      } else {
        displayChosenFilters.value = false;
      }
    });
    autoScrollController = AutoScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(builder: (context, state) {
      if (state.getProductFiltersStatus == GetProductFiltersStatus.loading) {
        return Center(child: TrydosLoader());
      }
      if (state.getProductFiltersStatus == GetProductFiltersStatus.failure) {
        return Center(child: TryAgainWidget(tryAgain: () {
          BlocProvider.of<HomeBloc>(context).add(GetProductFiltersEvent());
        }));
      }
      Filter filters = state.getProductFiltersModel!.filters!;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.isExpanded) ...{
            Padding(
                padding: EdgeInsets.only(left: 25),
                child: Row(
                  children: [
                    FilterSelectedMark(width: 20, height: 20),
                    SizedBox(
                      width: 10,
                    ),
                    MyTextWidget(
                      'Filter By Category',
                      style: context.textTheme.caption?.rq
                          .copyWith(color: Color(0xff505050), height: 15 / 12),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    SvgPicture.asset(
                      AppAssets.registerInfoSvg,
                      color: Color(0xffD3D3D3),
                    )
                  ],
                )),
            SizedBox(
              height: 10,
            )
          },
          SizedBox(
            height: 110,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: widget.isExpanded ? 20 : 15,
                ),
                Visibility(
                  visible: !widget.isExpanded,
                  child: Padding(
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
                                      if (currentActiveSection.value == index)
                                        return;
                                      currentActiveSection.value = index;
                                      autoScrollController.scrollToIndex(
                                          2 * index,
                                          duration: Duration(milliseconds: 200),
                                          preferPosition:
                                              AutoScrollPosition.begin);
                                      widget.onMoveToAnotherFiltersSection
                                          .call('Section ${index + 1}');
                                    },
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 8,
                                          width: 8,
                                          decoration: BoxDecoration(
                                              color: currentActive == index
                                                  ? Color(0xff505050)
                                                  : null,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Color(0xff505050))),
                                        ),
                                        Container(
                                          width: index != 2 ? 2 : 0,
                                          color: Colors.transparent,
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                          );
                        }),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                ValueListenableBuilder<List<Tuple3<int, int?, double>>>(
                    valueListenable: widget.selectedFiltersNotifier,
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
                              padding: EdgeInsets.only(left: 5),
                              itemBuilder: (ctx, index) {
                                if (index & 1 == 0)
                                  return VisibilityDetector(
                                    key: Key('$index-section'),
                                    onVisibilityChanged: (visibilityInfo) {
                                      if (autoScrollController.hasClients &&
                                          autoScrollController.position
                                                  .userScrollDirection ==
                                              rendring.ScrollDirection.idle) {
                                        return;
                                      }
                                      double visiblePercentage =
                                          visibilityInfo.visibleFraction * 100;
                                      if (visiblePercentage == 0) {
                                        int sectionIndex = -1;
                                        // scroll to the right
                                        if (autoScrollController.hasClients &&
                                            autoScrollController.position
                                                    .userScrollDirection ==
                                                rendring
                                                    .ScrollDirection.reverse) {
                                          sectionIndex = int.parse(
                                                      visibilityInfo.key
                                                          .toString()[3]) ~/
                                                  2 +
                                              2;
                                        } else {
                                          sectionIndex = int.parse(
                                                  visibilityInfo.key
                                                      .toString()[3]) ~/
                                              2;
                                        }
                                        currentActiveSection.value =
                                            sectionIndex - 1;
                                        widget.onMoveToAnotherFiltersSection
                                            .call('Section $sectionIndex');
                                      }
                                    },
                                    child: AutoScrollTag(
                                      key: ValueKey(index),
                                      controller: autoScrollController,
                                      index: index,
                                      child: ListView(
                                        scrollDirection: Axis.horizontal,
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        children: [
                                          ValueListenableBuilder<int>(
                                              valueListenable:
                                                  expandingFiltersStack,
                                              builder: (context,
                                                  currentExpandedIndex, child) {
                                                return AnimatedContainer(
                                                  curve: Curves
                                                      .fastEaseInToSlowEaseOut,
                                                  duration: Duration(
                                                      milliseconds: 300),
                                                  margin:
                                                      EdgeInsets.only(right: 5),
                                                  width: currentExpandedIndex ==
                                                          index
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
                                                                top: currentExpandedIndex ==
                                                                        15 *
                                                                            index
                                                                    ? (70 - 50)
                                                                    : (70 - 50) /
                                                                        2,
                                                                right: currentExpandedIndex ==
                                                                        15 *
                                                                            index
                                                                    ? innerIndex *
                                                                        55
                                                                    : innerIndex >=
                                                                            (4 -
                                                                                2)
                                                                        ? (innerIndex -
                                                                                1) *
                                                                            3
                                                                        : 0,
                                                                child:
                                                                    FilterCircleWidget(
                                                                  width: 50,
                                                                  height: 50,
                                                                  withBackGroundShadow:
                                                                      innerIndex !=
                                                                          0,
                                                                  addOrRemoveSpecificFilter:
                                                                      (bool
                                                                          add) {
                                                                    if (add) {
                                                                      widget.selectedFiltersNotifier.value.add(Tuple3(
                                                                          15 * index +
                                                                              innerIndex +
                                                                              1,
                                                                          15 *
                                                                              index,
                                                                          10));
                                                                      widget
                                                                          .listKey
                                                                          .currentState!
                                                                          .insertItem(selectedFilters.length -
                                                                              1);
                                                                      widget
                                                                          .selectedFiltersNotifier
                                                                          .notifyListeners();
                                                                    } else {
                                                                      final Tuple3<
                                                                              int,
                                                                              int?,
                                                                              double>
                                                                          item =
                                                                          Tuple3(
                                                                              15 * index + innerIndex + 1,
                                                                              15 * index,
                                                                              10);
                                                                      int removedIndex = widget
                                                                          .selectedFiltersNotifier
                                                                          .value
                                                                          .indexWhere((element) =>
                                                                              element ==
                                                                              item);
                                                                      widget
                                                                          .selectedFiltersNotifier
                                                                          .value
                                                                          .removeAt(
                                                                              removedIndex);
                                                                      widget
                                                                          .listKey
                                                                          .currentState!
                                                                          .removeItem(
                                                                        removedIndex,
                                                                        (context, animation) => buildItem(
                                                                            removedIndex,
                                                                            item,
                                                                            animation),
                                                                      );
                                                                      widget
                                                                          .selectedFiltersNotifier
                                                                          .notifyListeners();
                                                                    }
                                                                  },
                                                                  displayFilterMark: selectedFilters.contains(Tuple3(
                                                                      15 * index +
                                                                          innerIndex +
                                                                          1,
                                                                      15 *
                                                                          index,
                                                                      10)),
                                                                  paddingValue:
                                                                      currentExpandedIndex ==
                                                                              15 * index
                                                                          ? 5
                                                                          : 0,
                                                                  borderColor:
                                                                      colorScheme
                                                                          .white,
                                                                  isExpanded:
                                                                      currentExpandedIndex ==
                                                                          15 *
                                                                              index,
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
                                                                scale: scale,
                                                                paddingValue: 0,
                                                                isExpanded:
                                                                    currentExpandedIndex ==
                                                                        15 *
                                                                            index,
                                                                displayFilterMark:
                                                                    selectedFilters.contains(Tuple3(
                                                                        15 *
                                                                            index,
                                                                        15 *
                                                                            index,
                                                                        15)),
                                                                addOrRemoveSpecificFilter:
                                                                    (bool add) {
                                                                  if (add) {
                                                                    widget
                                                                        .selectedFiltersNotifier
                                                                        .value
                                                                        .add(Tuple3(
                                                                            15 *
                                                                                index,
                                                                            15 *
                                                                                index,
                                                                            15));
                                                                    scaleTheTopItemInFiltersStack
                                                                            .value =
                                                                        true;
                                                                    expandingFiltersStack
                                                                            .value =
                                                                        15 *
                                                                            index;
                                                                    Future.delayed(
                                                                        Duration(
                                                                            milliseconds:
                                                                                100),
                                                                        () {
                                                                      scaleTheTopItemInFiltersStack
                                                                              .value =
                                                                          false;
                                                                    });
                                                                    widget
                                                                        .listKey
                                                                        .currentState!
                                                                        .insertItem(
                                                                            selectedFilters.length -
                                                                                1);
                                                                    widget
                                                                        .selectedFiltersNotifier
                                                                        .notifyListeners();
                                                                  } else {
                                                                    expandingFiltersStack
                                                                        .value = -1;
                                                                    final List<
                                                                        Tuple3<
                                                                            int,
                                                                            int?,
                                                                            double>> itemToRemove = [];
                                                                    final indicesToRemove =
                                                                        [];
                                                                    for (int i =
                                                                            0;
                                                                        i < selectedFilters.length;
                                                                        i++) {
                                                                      if (selectedFilters[i]
                                                                              .item2 ==
                                                                          15 *
                                                                              index) {
                                                                        itemToRemove.add(widget
                                                                            .selectedFiltersNotifier
                                                                            .value[i]);
                                                                        indicesToRemove
                                                                            .add(i);
                                                                      }
                                                                    }
                                                                    for (int i =
                                                                            0;
                                                                        i < itemToRemove.length;
                                                                        i++) {
                                                                      widget
                                                                          .selectedFiltersNotifier
                                                                          .value
                                                                          .remove(
                                                                              itemToRemove[i]);
                                                                      widget
                                                                          .listKey
                                                                          .currentState!
                                                                          .removeItem(
                                                                        indicesToRemove[i] -
                                                                            i,
                                                                        (context, animation) => buildItem(
                                                                            indicesToRemove[i] -
                                                                                i,
                                                                            itemToRemove[i],
                                                                            animation),
                                                                      );
                                                                    }
                                                                  }
                                                                  widget
                                                                      .selectedFiltersNotifier
                                                                      .notifyListeners();
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
                                                                15 * index +
                                                                    innerIndex +
                                                                    4,
                                                                null,
                                                                15)),
                                                    withBackGroundShadow: true,
                                                    addOrRemoveSpecificFilter:
                                                        (bool add) {
                                                      if (add) {
                                                        widget
                                                            .selectedFiltersNotifier
                                                            .value
                                                            .add(Tuple3(
                                                                15 * index +
                                                                    innerIndex +
                                                                    4,
                                                                null,
                                                                15));
                                                        widget.listKey
                                                            .currentState!
                                                            .insertItem(
                                                                selectedFilters
                                                                        .length -
                                                                    1);
                                                        widget
                                                            .selectedFiltersNotifier
                                                            .notifyListeners();
                                                      } else {
                                                        final Tuple3<int, int?,
                                                                double> item =
                                                            Tuple3(
                                                                15 * index +
                                                                    innerIndex +
                                                                    4,
                                                                null,
                                                                15);
                                                        int removedIndex = widget
                                                            .selectedFiltersNotifier
                                                            .value
                                                            .indexWhere(
                                                                (element) =>
                                                                    element ==
                                                                    item);
                                                        widget
                                                            .selectedFiltersNotifier
                                                            .value
                                                            .removeAt(
                                                                removedIndex);
                                                        widget.listKey
                                                            .currentState!
                                                            .removeItem(
                                                          removedIndex,
                                                          (context,
                                                                  animation) =>
                                                              buildItem(
                                                                  removedIndex,
                                                                  item,
                                                                  animation),
                                                        );
                                                        widget
                                                            .selectedFiltersNotifier
                                                            .notifyListeners();
                                                      }
                                                    },
                                                  ))
                                        ],
                                      ),
                                    ),
                                  );
                                return Container(
                                  margin: EdgeInsets.only(
                                      top: 10, right: 10, bottom: 45),
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
          if (widget.isExpanded) ...{
            SizedBox(
              height: 10,
            ),
            FiltersNormalList(
              selectedFilters: selectedFiltersByBrand,
              filterListTitle: 'Filter By Brand',
              isBrandFilter: true,
              filters: filters.brands ?? [],
              addItemToAnimatedList: (int index) {
                listForBrandsKey.currentState!.insertItem(index);
              },
              removeItemToAnimatedList: (int removedIndex, Brand removedItem) {
                listForBrandsKey.currentState!.removeItem(
                    removedIndex,
                    (context, animation) => buildBrandItem(
                        removedIndex,
                        removedIndex,
                        removedItem,
                        animation));
              },
            ),
            FiltersNormalList(
              selectedFilters: selectedFiltersByOffer,
              filterListTitle: 'Filter By Offer',
              isBrandFilter: false,
              filters: [],
            ),
            PriceFilter(
              pricesFiltersRanges: filters.prices!,
            ),
            SizesFiltersList(
              selectedFilters: selectedFiltersBySize,
              addItemToAnimatedList: (int index) {
                listForSizesKey.currentState!.insertItem(index);
              },
              removeItemToAnimatedList: (int removedIndex, String removedItem) {
                listForSizesKey.currentState!.removeItem(
                    removedIndex,
                        (context, animation) => buildSizeItem(
                            removedIndex,
                        removedIndex,
                        removedItem,
                        animation));
              },
              sizes: filters.attributes?[0].options ?? [],
            ),
          },
          if (!widget.isExpanded) ...{
            ValueListenableBuilder<List<Tuple3<int, int?, double>>>(
                valueListenable: widget.selectedFiltersNotifier,
                builder: (context, selectedFilters, child) {
                  return Container(
                    padding: EdgeInsets.only(
                        top: selectedFilters.isNotEmpty ? 5 : 0),
                    color: Color(0xffF8F8F8),
                    child: Container(
                      width: 1.sw,
                      height: selectedFilters.isNotEmpty ? 30 : 0,
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
                                  child: FilterSelectedMark(
                                      width: 15, height: 15)),
                              SizedBox(
                                width: 10,
                              ),
                              SizedBox(
                                  height: 28,
                                  child: AnimatedList(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    key: widget.listKey,
                                    initialItemCount: selectedFilters.length,
                                    itemBuilder: (ctx, index, animation) {
                                      return buildItem(index,
                                          selectedFilters[index], animation);
                                    },
                                  )),
                            ]),
                      ),
                    ),
                  );
                }),
          },
          if (widget.isExpanded) ...{
            SizedBox(
              height: 20,
            ),
            ValueListenableBuilder<bool>(
                valueListenable: displayChosenFilters,
                builder: (context, display, child) {
                  return Column(
                    children: [
                      Container(
                        width: 1.sw,
                        height: display ? 55 : 0,
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            color: colorScheme.white,
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 6,
                                  offset: Offset(0, 0),
                                  color: Colors.black.withOpacity(0.1))
                            ],
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 5)
                                  .copyWith(left: 10),
                              child: MyTextWidget(
                                'The Products Will Be Shown As Below',
                                style: context.textTheme.caption?.rq.copyWith(
                                    color: Color(0xff505050), height: 15 / 12),
                              ),
                            ),
                            Container(
                              width: 1.sw,
                              height: display ? 30 : 0,
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
                                          child: FilterSelectedMark(
                                              width: 15, height: 15)),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      ValueListenableBuilder<
                                              List<Tuple3<int, int?, double>>>(
                                          valueListenable:
                                              widget.selectedFiltersNotifier,
                                          builder: (context, selectedFilters,
                                              child) {
                                            return SizedBox(
                                                height: 28,
                                                child: AnimatedList(
                                                  shrinkWrap: true,
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  key: widget.listKey,
                                                  initialItemCount:
                                                      selectedFilters.length,
                                                  itemBuilder:
                                                      (ctx, index, animation) {
                                                    return buildItem(
                                                        index,
                                                        selectedFilters[index],
                                                        animation);
                                                  },
                                                ));
                                          }),
                                      ValueListenableBuilder<List<int>>(
                                          valueListenable:
                                              selectedFiltersByBrand,
                                          builder: (context, selected, _) {
                                            return SizedBox(
                                                height: 28,
                                                child: AnimatedList(
                                                  shrinkWrap: true,
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  key: listForBrandsKey,
                                                  initialItemCount:
                                                      selected.length,
                                                  itemBuilder:
                                                      (ctx, index, animation) {
                                                    return buildBrandItem(
                                                        selected[index],
                                                        index,
                                                        filters.brands![
                                                            selected[index]],
                                                        animation);
                                                  },
                                                ));
                                          }),
                                      ValueListenableBuilder<List<int>>(
                                          valueListenable:
                                              selectedFiltersBySize,
                                          builder: (context, selected, _) {
                                            return SizedBox(
                                                height: 28,
                                                child: AnimatedList(
                                                  shrinkWrap: true,
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  key: listForSizesKey,
                                                  initialItemCount:
                                                      selected.length,
                                                  itemBuilder:
                                                      (ctx, index, animation) {
                                                    return buildSizeItem(
                                                        selected[index],
                                                        index,
                                                        filters.attributes![0]
                                                                .options![
                                                            selected[index]],
                                                        animation);
                                                  },
                                                ));
                                          }),
                                    ]),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (display) ...{
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 65,
                                      decoration: BoxDecoration(
                                          color: Color(0xffFF5F61),
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.1),
                                                blurRadius: 6,
                                                offset: Offset(0, 3)),
                                            BoxShadow(
                                                color: Colors.white
                                                    .withOpacity(0.4),
                                                blurRadius: 6,
                                                offset: Offset(0, 3),
                                                inset: true)
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Center(
                                        child: MyTextWidget(
                                          'Apply',
                                          style: textTheme.headline6?.rq
                                              .copyWith(
                                                  color: Color(0xffFEFEFE),
                                                  height: 23 / 18),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                flex: 2,
                                child: GestureDetector(
                                  onTap: () {
                                    widget.selectedFiltersNotifier.value = [];
                                    selectedFiltersByBrand.value = [];
                                    selectedFiltersByOffer.value = [];
                                    selectedFiltersBySize.value = [];
                                  },
                                  child: Stack(
                                    children: [
                                      Container(
                                        height: 65,
                                        decoration: BoxDecoration(
                                            color: colorScheme.white,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                  blurRadius: 6,
                                                  offset: Offset(0, 3)),
                                              BoxShadow(
                                                  color: Colors.white
                                                      .withOpacity(0.4),
                                                  blurRadius: 6,
                                                  offset: Offset(0, 3),
                                                  inset: true)
                                            ],
                                            border: Border.all(
                                                color: Color(0xff388CFF))),
                                        child: Center(
                                          child: MyTextWidget(
                                            'Reset',
                                            style: textTheme.headline6?.rq
                                                .copyWith(
                                                    color: Color(0xff388CFF),
                                                    height: 23 / 18),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        )
                      } else ...{
                        SizedBox(height: 95)
                      }
                    ],
                  );
                })
          }
        ],
      );
    });
  }

  Widget buildBrandItem(int indexInBrandList, int index, Brand item,
      Animation<double> animation) {
    return AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Transform(
            transform: Matrix4.identity()
              ..translate(0.0, 0.0, (1.0 - animation.value)),
            child: Opacity(
              opacity: animation.value,
              child: child,
            ),
          );
        },
        child: GestureDetector(
          onTap: () {
            selectedFiltersByBrand.value.remove(indexInBrandList);
            selectedFiltersByBrand.notifyListeners();
            listForBrandsKey.currentState!.removeItem(
              index,
              (context, animation) =>
                  buildBrandItem(indexInBrandList, index, item, animation),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // FilterImage(
              //     width: 20,
              //     height: 20,
              //     withInnerShadow: true,
              //     withBackGroundShadow: true,
              //     borderColor: Color(0xffFF5F61),
              //     imageUrl: item.image.toString()),
              SizedBox(
                width: 5,
              ),
              MyTextWidget(
                item.name.toString(),
                maxLines: 1,
                textAlign: TextAlign.center,
                style: context.textTheme.caption?.rq.copyWith(
                    color: Color(0xff8E8E8E), letterSpacing: 0, height: 1.25),
              ),
              SizedBox(
                width: 5,
              ),
            ],
          ),
        ));
  }

  Widget buildOfferItem(int indexInBrandList, int index, String offer,
      Animation<double> animation) {
    return AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Transform(
            transform: Matrix4.identity()
              ..translate(0.0, 0.0, (1.0 - animation.value)),
            child: Opacity(
              opacity: animation.value,
              child: child,
            ),
          );
        },
        child: GestureDetector(
          onTap: () {
            selectedFiltersByOffer.value.remove(indexInBrandList);
            selectedFiltersByOffer.notifyListeners();
            listForOffersKey.currentState!.removeItem(
              index,
              (context, animation) =>
                  buildOfferItem(indexInBrandList, index, offer, animation),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // FilterImage(
              //     width: 20,
              //     height: 20,
              //     withInnerShadow: true,
              //     withBackGroundShadow: true,
              //     borderColor: Color(0xffFF5F61),
              //     imageUrl: item.image.toString()),
              SizedBox(
                width: 5,
              ),
              MyTextWidget(
                offer,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: context.textTheme.caption?.rq.copyWith(
                    color: Color(0xff8E8E8E), letterSpacing: 0, height: 1.25),
              ),
              SizedBox(
                width: 5,
              ),
            ],
          ),
        ));
  }

  Widget buildSizeItem(int indexInSizeList, int index, String size,
      Animation<double> animation) {
    return AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Transform(
            transform: Matrix4.identity()
              ..translate(0.0, 0.0, (1.0 - animation.value)),
            child: Opacity(
              opacity: animation.value,
              child: child,
            ),
          );
        },
        child: GestureDetector(
          onTap: () {
            selectedFiltersBySize.value.remove(indexInSizeList);
            selectedFiltersBySize.notifyListeners();
            listForSizesKey.currentState!.removeItem(
              index,
              (context, animation) =>
                  buildSizeItem(indexInSizeList, index, size, animation),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // FilterImage(
              //     width: 20,
              //     height: 20,
              //     withInnerShadow: true,
              //     withBackGroundShadow: true,
              //     borderColor: Color(0xffFF5F61),
              //     imageUrl: item.image.toString()),
              SizedBox(
                width: 5,
              ),
              MyTextWidget(
                size,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: context.textTheme.caption?.rq.copyWith(
                    color: Color(0xff8E8E8E), letterSpacing: 0, height: 1.25),
              ),
              SizedBox(
                width: 5,
              ),
            ],
          ),
        ));
  }

  Widget buildItem(
      int index, Tuple3<int, int?, double> item, Animation<double> animation) {
    return AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Transform(
            transform: Matrix4.identity()
              ..translate(0.0, 0.0, (1.0 - animation.value)),
            child: Opacity(
              opacity: animation.value,
              child: child,
            ),
          );
        },
        child: GestureDetector(
          onTap: () {
            widget.selectedFiltersNotifier.value.remove(item);
            widget.selectedFiltersNotifier.notifyListeners();
            widget.listKey.currentState!.removeItem(
              index,
              (context, animation) => buildItem(index, item, animation),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilterImage(
                  width: item.item3,
                  height: item.item3,
                  withInnerShadow: true,
                  withBackGroundShadow: true,
                  borderColor: Color(0xffFF5F61),
                  imageUrl: 'assets/images/details_circle.jpg'),
              SizedBox(
                width: 5,
              ),
              MyTextWidget(
                'T-shirt',
                maxLines: 1,
                textAlign: TextAlign.center,
                style: context.textTheme.caption?.rq.copyWith(
                    color: Color(0xff8E8E8E), letterSpacing: 0, height: 1.25),
              ),
              SizedBox(
                width: 5,
              ),
            ],
          ),
        ));
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
                        withBackGroundShadow: !widget.displayFilterMark &&
                            widget.withBackGroundShadow,
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
            height: height / 2,
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
