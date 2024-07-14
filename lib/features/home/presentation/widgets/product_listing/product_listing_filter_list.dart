import 'package:flutter/cupertino.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter/rendering.dart' as rendring;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/data/model/pagination_model.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/features/app/svg_network_widget.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/price_filter.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/sizes_filters_list.dart';
import 'package:tuple/tuple.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../../app/app_widgets/loading_indicator/trydos_loader.dart';
import '../../../../app/my_cached_network_image.dart';
import '../../../../app/my_text_widget.dart';
import '../../../data/models/get_product_filters_model.dart' as filter_model;
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
      this.controller,
      required this.boutiqueSlug,
      this.category,
      required this.closeFilterPage});

  final void Function() closeFilterPage;
  final void Function(String message) onMoveToAnotherFiltersSection;
  final ValueNotifier<List<Tuple3<int, int?, double>>> selectedFiltersNotifier;
  final GlobalKey<AnimatedListState> listKey;
  final ScrollController? controller;
  final bool isExpanded;

  final String boutiqueSlug;
  final String? category;

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
  ValueNotifier<Tuple2<int, int>>? lowerAndUpperBound;

  final GlobalKey<AnimatedListState> listForBrandsKey =
      GlobalKey<AnimatedListState>();
  final GlobalKey<AnimatedListState> listForOffersKey =
      GlobalKey<AnimatedListState>();
  final GlobalKey<AnimatedListState> listForSizesKey =
      GlobalKey<AnimatedListState>();

  int lastSectionDisplayed = 0;
  int? minPrice;
  int? maxPrice;
  late HomeBloc homeBloc;

  @override
  void initState() {
    homeBloc = BlocProvider.of<HomeBloc>(context);
    widget.selectedFiltersNotifier.addListener(() {
      if (widget.selectedFiltersNotifier.value.isEmpty) {
        expandingFiltersStack.value = -1;
      }
      if (selectedFiltersBySize.value.length > 0 ||
          selectedFiltersByBrand.value.length > 0 ||
          widget.selectedFiltersNotifier.value.length > 0 ||
          (minPrice != null &&
              (lowerAndUpperBound?.value.item1 != minPrice ||
                  lowerAndUpperBound?.value.item2 != maxPrice))) {
        displayChosenFilters.value = true;
      } else {
        displayChosenFilters.value = false;
      }
    });
    selectedFiltersByBrand.addListener(() {
      if (selectedFiltersBySize.value.length > 0 ||
          selectedFiltersByBrand.value.length > 0 ||
          widget.selectedFiltersNotifier.value.length > 0 ||
          (minPrice != null &&
              (lowerAndUpperBound?.value.item1 != minPrice ||
                  lowerAndUpperBound?.value.item2 != maxPrice))) {
        displayChosenFilters.value = true;
      } else {
        displayChosenFilters.value = false;
      }
    });
    selectedFiltersBySize.addListener(() {
      if (selectedFiltersBySize.value.length > 0 ||
          selectedFiltersByBrand.value.length > 0 ||
          widget.selectedFiltersNotifier.value.length > 0 ||
          (minPrice != null &&
              (lowerAndUpperBound?.value.item1 != minPrice ||
                  lowerAndUpperBound?.value.item2 != maxPrice))) {
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
    String key = widget.boutiqueSlug + (widget.category ?? '');
    return BlocBuilder<HomeBloc, HomeState>(builder: (context, state) {
      if (state.getProductFiltersInEachBoutiqueStatus[key] ==
              GetProductFiltersStatus.loading ||
          state.getProductListingWithFiltersPaginationModels[key]
                  ?.paginationStatus ==
              PaginationStatus.loading) {
        return Center(child: TrydosLoader());
      }
      // if (state.getProductFiltersStatus == GetProductFiltersStatus.failure) {
      //   return Center(child: TryAgainWidget(tryAgain: () {
      //     BlocProvider.of<HomeBloc>(context).add(GetProductFiltersEvent());
      //   }));
      // }
      if (state.getProductFiltersInEachBoutiqueModel[key]?.filters == null) {
        return SizedBox.shrink();
      }
      filter_model.Filter filters =
          state.getProductFiltersInEachBoutiqueModel[key]!.filters!;
      if (lowerAndUpperBound == null && filters.prices != null) {
        minPrice = filters.prices!.minPrice!;
        maxPrice = filters.prices!.maxPrice!;
        lowerAndUpperBound = ValueNotifier(
            Tuple2(filters.prices!.minPrice!, filters.prices!.maxPrice!));
        lowerAndUpperBound!.addListener(() {
          if (selectedFiltersBySize.value.length > 0 ||
              selectedFiltersByBrand.value.length > 0 ||
              widget.selectedFiltersNotifier.value.length > 0 ||
              (minPrice != null &&
                  (lowerAndUpperBound?.value.item1 != minPrice ||
                      lowerAndUpperBound?.value.item2 != maxPrice))) {
            displayChosenFilters.value = true;
          } else {
            displayChosenFilters.value = false;
          }
        });
      }
      int countOfFilters = 0;
      List<String> titleOfFilterSection = [];
      if (!filters.categories.isNullOrEmpty) {
        countOfFilters++;
        titleOfFilterSection.add('View By Categories');
      }
      if (!filters.brands.isNullOrEmpty) {
        countOfFilters++;
        titleOfFilterSection.add('View By Brands');
      }
      if (!filters.attributes.isNullOrEmpty) {
        if (!filters.attributes![0].options.isNullOrEmpty) {
          countOfFilters++;
          titleOfFilterSection.add('View By Sizes');
        }
      }
      if (filters.prices != null) {
        countOfFilters++;
        titleOfFilterSection.add('View By Price');
      }
      return Column(
        children: [
          if (widget.isExpanded) ...{
            Padding(
                padding: EdgeInsetsDirectional.only(start: 25),
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
                                itemCount: countOfFilters,
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
                                          .call(titleOfFilterSection[index]);
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
                              itemCount: widget.isExpanded
                                  ? 1
                                  : 2 * countOfFilters - 1,
                              physics: ClampingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              padding: EdgeInsetsDirectional.only(start: 5),
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
                                        if (sectionIndex > 0) {
                                          widget.onMoveToAnotherFiltersSection
                                              .call(titleOfFilterSection[
                                                  sectionIndex - 1]);
                                        }
                                      }
                                    },
                                    child:
                                        index == 0 &&
                                                titleOfFilterSection[
                                                        index ~/ 2] ==
                                                    'View By Categories'
                                            ? AutoScrollTag(
                                                key: ValueKey(index),
                                                controller:
                                                    autoScrollController,
                                                index: index,
                                                child: ListView.builder(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  physics:
                                                      NeverScrollableScrollPhysics(),
                                                  shrinkWrap: true,
                                                  itemCount: filters
                                                          .categories?.length ??
                                                      0,
                                                  itemBuilder: (ctx, index) {
                                                    if (!filters
                                                        .categories![index]
                                                        .subCategories
                                                        .isNullOrEmpty)
                                                      return ValueListenableBuilder<
                                                              int>(
                                                          valueListenable:
                                                              expandingFiltersStack,
                                                          builder: (context,
                                                              currentExpandedIndex,
                                                              child) {
                                                            return AnimatedContainer(
                                                              curve: Curves
                                                                  .fastEaseInToSlowEaseOut,
                                                              duration: Duration(
                                                                  milliseconds:
                                                                      300),
                                                              margin:
                                                                  EdgeInsetsDirectional
                                                                      .only(
                                                                          end:
                                                                              5),
                                                              width: currentExpandedIndex ==
                                                                      index
                                                                  ? (75 +
                                                                      filters
                                                                              .categories![index]
                                                                              .subCategories!
                                                                              .length *
                                                                          55)
                                                                  : 80.0,
                                                              height: 70.0,
                                                              child: Stack(
                                                                alignment:
                                                                    AlignmentDirectional
                                                                        .topStart,
                                                                children: [
                                                                  ...List
                                                                      .generate(
                                                                    filters
                                                                        .categories![
                                                                            index]
                                                                        .subCategories!
                                                                        .length,
                                                                    (innerIndex) => AnimatedPositionedDirectional(
                                                                        curve: Curves.fastEaseInToSlowEaseOut,
                                                                        duration: Duration(milliseconds: 300),
                                                                        top: currentExpandedIndex == index ? (70 - 50) : (70 - 50) / 2,
                                                                        end: currentExpandedIndex == index
                                                                            ? innerIndex * 55
                                                                            : innerIndex >= (filters.categories![index].subCategories!.length - 2)
                                                                                ? (innerIndex - 1) * 3
                                                                                : 0,
                                                                        child: FilterCircleWidget(
                                                                          width:
                                                                              50,
                                                                          height:
                                                                              50,
                                                                          categoryName: filters
                                                                              .categories![index]
                                                                              .subCategories![innerIndex]
                                                                              .name
                                                                              .toString(),
                                                                          imageUrl: filters
                                                                              .categories![index]
                                                                              .subCategories![innerIndex]
                                                                              .icon
                                                                              .toString(),
                                                                          withBackGroundShadow:
                                                                              innerIndex != 0,
                                                                          addOrRemoveSpecificFilter:
                                                                              (bool add) {
                                                                            if (add) {
                                                                              widget.selectedFiltersNotifier.value.add(Tuple3(filters.categories![index].subCategories![innerIndex].id!, filters.categories![index].id!, 10));
                                                                              widget.listKey.currentState!.insertItem(selectedFilters.length - 1);
                                                                              widget.selectedFiltersNotifier.notifyListeners();
                                                                            } else {
                                                                              final Tuple3<int, int?, double> item = Tuple3(filters.categories![index].subCategories![innerIndex].id!, filters.categories![index].id!, 10);
                                                                              int removedIndex = widget.selectedFiltersNotifier.value.indexWhere((element) => element == item);
                                                                              widget.selectedFiltersNotifier.value.removeAt(removedIndex);
                                                                              widget.listKey.currentState!.removeItem(
                                                                                removedIndex,
                                                                                (context, animation) => buildItem(removedIndex, item, filters.categories![index].subCategories![innerIndex].icon.toString(), filters.categories![index].subCategories![innerIndex].name.toString(), animation),
                                                                              );
                                                                              widget.selectedFiltersNotifier.notifyListeners();
                                                                            }
                                                                          },
                                                                          displayFilterMark: selectedFilters.contains(Tuple3(
                                                                              filters.categories![index].subCategories![innerIndex].id!,
                                                                              filters.categories![index].id!,
                                                                              10)),
                                                                          paddingValue: currentExpandedIndex == index
                                                                              ? 5
                                                                              : 0,
                                                                          borderColor:
                                                                              colorScheme.white,
                                                                          isExpanded:
                                                                              currentExpandedIndex == index,
                                                                        )),
                                                                  ),
                                                                  ValueListenableBuilder<
                                                                          bool>(
                                                                      valueListenable:
                                                                          scaleTheTopItemInFiltersStack,
                                                                      builder: (context,
                                                                          scale,
                                                                          _) {
                                                                        return FilterCircleWidget(
                                                                            width:
                                                                                70,
                                                                            height:
                                                                                70,
                                                                            categoryName: filters.categories![index].name
                                                                                .toString(),
                                                                            imageUrl: filters.categories![index].icon
                                                                                .toString(),
                                                                            scale:
                                                                                scale,
                                                                            paddingValue:
                                                                                0,
                                                                            isExpanded: currentExpandedIndex ==
                                                                                index,
                                                                            displayFilterMark: selectedFilters.contains(Tuple3(
                                                                                filters.categories![index].id!,
                                                                                filters.categories![index].id!,
                                                                                15)),
                                                                            addOrRemoveSpecificFilter: (bool add) {
                                                                              if (add) {
                                                                                widget.selectedFiltersNotifier.value.add(Tuple3(filters.categories![index].id!, filters.categories![index].id!, 15));
                                                                                scaleTheTopItemInFiltersStack.value = true;
                                                                                expandingFiltersStack.value = index;
                                                                                Future.delayed(Duration(milliseconds: 100), () {
                                                                                  scaleTheTopItemInFiltersStack.value = false;
                                                                                });
                                                                                widget.listKey.currentState!.insertItem(selectedFilters.length - 1);
                                                                                widget.selectedFiltersNotifier.notifyListeners();
                                                                              } else {
                                                                                expandingFiltersStack.value = -1;
                                                                                final List<Tuple3<int, int?, double>> itemToRemove = [];
                                                                                final indicesToRemove = [];
                                                                                for (int i = 0; i < selectedFilters.length; i++) {
                                                                                  if (selectedFilters[i].item2 == filters.categories![index].id!) {
                                                                                    itemToRemove.add(widget.selectedFiltersNotifier.value[i]);
                                                                                    indicesToRemove.add(i);
                                                                                  }
                                                                                }
                                                                                for (int i = 0; i < itemToRemove.length; i++) {
                                                                                  widget.selectedFiltersNotifier.value.remove(itemToRemove[i]);
                                                                                  widget.listKey.currentState!.removeItem(
                                                                                    indicesToRemove[i] - i,
                                                                                    (context, animation) => buildItem(indicesToRemove[i] - i, itemToRemove[i], filters.categories![index].icon.toString(), filters.categories![index].name.toString(), animation),
                                                                                  );
                                                                                }
                                                                              }
                                                                              widget.selectedFiltersNotifier.notifyListeners();
                                                                            });
                                                                      }),
                                                                ],
                                                              ),
                                                            );
                                                          });
                                                    else {
                                                      return FilterCircleWidget(
                                                        width: 70,
                                                        height: 70,
                                                        imageUrl: filters
                                                            .categories![index]
                                                            .icon
                                                            .toString(),
                                                        categoryName: filters
                                                            .categories![index]
                                                            .name
                                                            .toString(),
                                                        displayFilterMark:
                                                            selectedFilters
                                                                .contains(Tuple3(
                                                                    filters
                                                                        .categories![
                                                                            index]
                                                                        .id!,
                                                                    null,
                                                                    15)),
                                                        withBackGroundShadow:
                                                            true,
                                                        addOrRemoveSpecificFilter:
                                                            (bool add) {
                                                          if (add) {
                                                            widget
                                                                .selectedFiltersNotifier
                                                                .value
                                                                .add(Tuple3(
                                                                    filters
                                                                        .categories![
                                                                            index]
                                                                        .id!,
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
                                                            final Tuple3<
                                                                    int,
                                                                    int?,
                                                                    double>
                                                                item = Tuple3(
                                                                    filters
                                                                        .categories![
                                                                            index]
                                                                        .id!,
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
                                                              (context, animation) => buildItem(
                                                                  removedIndex,
                                                                  item,
                                                                  filters
                                                                      .categories![
                                                                          index]
                                                                      .icon
                                                                      .toString(),
                                                                  filters
                                                                      .categories![
                                                                          index]
                                                                      .name
                                                                      .toString(),
                                                                  animation),
                                                            );
                                                            widget
                                                                .selectedFiltersNotifier
                                                                .notifyListeners();
                                                          }
                                                        },
                                                      );
                                                    }
                                                  },
                                                ),
                                              )
                                            : index <= 2 &&
                                                    titleOfFilterSection[
                                                            index ~/ 2] ==
                                                        'View By Brands'
                                                ? FiltersNormalList(
                                                    hideTitle: true,
                                                    selectedFilters:
                                                        selectedFiltersByBrand,
                                                    filterListTitle:
                                                        'Filter By Brand',
                                                    isBrandFilter: true,
                                                    filters:
                                                        filters.brands ?? [],
                                                    addItemToAnimatedList:
                                                        (int index) {
                                                      listForBrandsKey
                                                          .currentState!
                                                          .insertItem(index);
                                                    },
                                                    removeItemToAnimatedList:
                                                        (int removedIndex,
                                                            filter_model.Brand
                                                                removedItem) {
                                                      listForBrandsKey
                                                          .currentState!
                                                          .removeItem(
                                                              removedIndex,
                                                              (context,
                                                                      animation) =>
                                                                  buildBrandItem(
                                                                      removedIndex,
                                                                      removedIndex,
                                                                      removedItem,
                                                                      animation));
                                                    },
                                                  )
                                                : index <= 4 &&
                                                        titleOfFilterSection[
                                                                index ~/ 2] ==
                                                            'View By Sizes'
                                                    ? SizesFiltersList(
                                                        hideTitle: true,
                                                        selectedFilters:
                                                            selectedFiltersBySize,
                                                        addItemToAnimatedList:
                                                            (int index) {
                                                          listForSizesKey
                                                              .currentState!
                                                              .insertItem(
                                                                  index);
                                                        },
                                                        removeItemToAnimatedList:
                                                            (int removedIndex,
                                                                String
                                                                    removedItem) {
                                                          listForSizesKey.currentState!.removeItem(
                                                              removedIndex,
                                                              (context,
                                                                      animation) =>
                                                                  buildSizeItem(
                                                                      removedIndex,
                                                                      removedIndex,
                                                                      removedItem,
                                                                      animation));
                                                        },
                                                        sizes: filters
                                                                .attributes![0]
                                                                .options ??
                                                            [],
                                                      )
                                                    : PriceFilter(
                                                        lowerAndUpperBound:
                                                            lowerAndUpperBound!,
                                                        pricesFiltersRanges:
                                                            filters.prices!,
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
              removeItemToAnimatedList:
                  (int removedIndex, filter_model.Brand removedItem) {
                listForBrandsKey.currentState!.removeItem(
                    removedIndex,
                    (context, animation) => buildBrandItem(
                        removedIndex, removedIndex, removedItem, animation));
              },
            ),
            FiltersNormalList(
              selectedFilters: selectedFiltersByOffer,
              filterListTitle: 'Filter By Offer',
              isBrandFilter: false,
              filters: [],
            ),
            if (filters.prices != null)
              PriceFilter(
                lowerAndUpperBound: lowerAndUpperBound!,
                pricesFiltersRanges: filters.prices!,
              ),
            if (!filters.attributes.isNullOrEmpty)
              SizesFiltersList(
                selectedFilters: selectedFiltersBySize,
                addItemToAnimatedList: (int index) {
                  listForSizesKey.currentState!.insertItem(index);
                },
                removeItemToAnimatedList:
                    (int removedIndex, String removedItem) {
                  listForSizesKey.currentState!.removeItem(
                      removedIndex,
                      (context, animation) => buildSizeItem(
                          removedIndex, removedIndex, removedItem, animation));
                },
                sizes: filters.attributes![0].options ?? [],
              ),
          },
          if (!widget.isExpanded) ...{
            BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                filter_model.Filter? filters =
                    state.choosedFiltersInEachBoutiqueModel[key]?.filters;
                if (filters == null) {
                  return SizedBox.shrink();
                }
                if (filters.brands.isNullOrEmpty &&
                    filters.categories.isNullOrEmpty &&
                    filters.prices == null &&
                    filters.attributes.isNullOrEmpty) {
                  return SizedBox.shrink();
                }
                return Container(
                  padding: EdgeInsets.only(top: 5),
                  color: Color(0xffF8F8F8),
                  child: Container(
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
                                child:
                                    FilterSelectedMark(width: 15, height: 15)),
                            SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                                height: 28,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: filters.categories?.length ?? 0,
                                  itemBuilder: (ctx, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        List<String> categories = filters
                                            .categories!
                                            .map((e) => e.id.toString())
                                            .toList();
                                        List<filter_model.Category>
                                            newCategories =
                                            filters.categories ?? [];
                                        newCategories.removeAt(index);
                                        categories.removeAt(index);
                                        BlocProvider.of<HomeBloc>(context).add(
                                            GetProductsWithFiltersEvent(
                                                boutiqueSlug:
                                                    widget.boutiqueSlug,
                                                category: widget.category,
                                                offset: 1,
                                                filtersChoosedByUser: filter_model
                                                    .GetProductFiltersModel(
                                                        filters: filters
                                                            .copyWithSaveOtherField(
                                                                categories:
                                                                    newCategories)),
                                                categories: categories.isEmpty
                                                    ? null
                                                    : categories));
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          FilterImage(
                                            width: filters.categories![index]
                                                    .isSubCategory
                                                ? 15
                                                : 20,
                                            height: filters.categories![index]
                                                    .isSubCategory
                                                ? 15
                                                : 20,
                                            imageUrl: filters
                                                .categories![index].icon
                                                .toString(),
                                            withInnerShadow: true,
                                            withBackGroundShadow: false,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          MyTextWidget(
                                            filters.brands![index].name
                                                .toString(),
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
                                    );
                                  },
                                )),
                            SizedBox(
                                height: 28,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: filters.brands?.length ?? 0,
                                  itemBuilder: (ctx, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        List<String> brands = filters.brands!
                                            .map((e) => e.id.toString())
                                            .toList();
                                        List<filter_model.Brand> newBrands =
                                            filters.brands ?? [];
                                        newBrands.removeAt(index);
                                        brands.removeAt(index);
                                        BlocProvider.of<HomeBloc>(context).add(
                                            GetProductsWithFiltersEvent(
                                                boutiqueSlug:
                                                    widget.boutiqueSlug,
                                                category: widget.category,
                                                offset: 1,
                                                filtersChoosedByUser: filter_model
                                                    .GetProductFiltersModel(
                                                        filters: filters
                                                            .copyWithSaveOtherField(
                                                                brands:
                                                                    newBrands)),
                                                brands: brands.isEmpty
                                                    ? null
                                                    : brands));
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          FilterImage(
                                            width: 20,
                                            height: 20,
                                            imageUrl: filters
                                                .brands![index].image
                                                .toString(),
                                            withInnerShadow: true,
                                            withBackGroundShadow: false,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          MyTextWidget(
                                            filters.brands![index].name
                                                .toString(),
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
                                    );
                                  },
                                )),
                            SizedBox(
                                height: 28,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: filters.attributes.isNullOrEmpty
                                      ? 0
                                      : filters
                                              .attributes![0].options?.length ??
                                          0,
                                  itemBuilder: (ctx, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        int? id = filters.attributes![0].id;
                                        String? name =
                                            filters.attributes![0].name;
                                        List<String>? options =
                                            filters.attributes![0].options;
                                        options?.removeAt(index);
                                        BlocProvider.of<HomeBloc>(context).add(
                                            GetProductsWithFiltersEvent(
                                                boutiqueSlug:
                                                    widget.boutiqueSlug,
                                                category: widget.category,
                                                offset: 1,
                                                filtersChoosedByUser: filter_model
                                                    .GetProductFiltersModel(
                                                        filters: filters
                                                            .copyWithSaveOtherField(
                                                                attributes:
                                                                    options.isNullOrEmpty
                                                                        ? []
                                                                        : [
                                                                            filters.attributes![0].copyWith(options: options)
                                                                          ])),
                                                attributes: options
                                                        .isNullOrEmpty
                                                    ? null
                                                    : [
                                                        {
                                                          "id": id,
                                                          "name": name,
                                                          "options": options,
                                                        }
                                                      ]));
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 5,
                                          ),
                                          MyTextWidget(
                                            filters
                                                .attributes![0].options![index]
                                                .toString(),
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
                                    );
                                  },
                                )),
                            if (filters.prices != null) ...{
                              GestureDetector(
                                onTap: () {
                                  BlocProvider.of<HomeBloc>(context).add(
                                      GetProductsWithFiltersEvent(
                                          boutiqueSlug: widget.boutiqueSlug,
                                          category: widget.category,
                                          offset: 1,
                                          filtersChoosedByUser: filter_model
                                              .GetProductFiltersModel(
                                            filters:
                                                filters.copyWithSaveOtherField(
                                                    prices: null),
                                          ),
                                          prices: null));
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 5,
                                    ),
                                    MyTextWidget(
                                      filters.prices!.minPrice.toString() + '/',
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      style: context.textTheme.caption?.rq
                                          .copyWith(
                                              color: Color(0xff8E8E8E),
                                              letterSpacing: 0,
                                              height: 1.25),
                                    ),
                                    MyTextWidget(
                                      filters.prices!.maxPrice.toString(),
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
                              )
                            }
                          ]),
                    ),
                  ),
                );
              },
            ),
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
                                                  List<
                                                      Tuple3<int, int?,
                                                          double>>>(
                                              valueListenable: widget
                                                  .selectedFiltersNotifier,
                                              builder: (context,
                                                  selectedFilters, child) {
                                                return SizedBox(
                                                    height: 28,
                                                    child: AnimatedList(
                                                      shrinkWrap: true,
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      key: widget.listKey,
                                                      initialItemCount:
                                                          selectedFilters
                                                              .length,
                                                      itemBuilder: (ctx, index,
                                                          animation) {
                                                        filter_model.Category
                                                            category;
                                                        if (selectedFilters[
                                                                    index]
                                                                .item2 ==
                                                            null) {
                                                          category = filters
                                                              .categories!
                                                              .firstWhere((element) =>
                                                                  element.id ==
                                                                  selectedFilters[
                                                                          index]
                                                                      .item1);
                                                        } else {
                                                          filter_model.SubCategory sub = filters
                                                              .categories!
                                                              .firstWhere((element) =>
                                                                  element.id ==
                                                                  selectedFilters[
                                                                          index]
                                                                      .item2)
                                                              .subCategories!
                                                              .firstWhere((element) =>
                                                                  element.id ==
                                                                  selectedFilters[
                                                                          index]
                                                                      .item1);
                                                          category =
                                                              filter_model
                                                                  .Category(
                                                            id: sub.id,
                                                            name: sub.name,
                                                            icon: sub.icon,
                                                          );
                                                        }
                                                        return buildItem(
                                                            index,
                                                            selectedFilters[
                                                                index],
                                                            category.icon
                                                                .toString(),
                                                            category.name
                                                                .toString(),
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
                                                      itemBuilder: (ctx, index,
                                                          animation) {
                                                        return buildBrandItem(
                                                            selected[index],
                                                            index,
                                                            filters.brands![
                                                                selected[
                                                                    index]],
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
                                                      itemBuilder: (ctx, index,
                                                          animation) {
                                                        return buildSizeItem(
                                                            selected[index],
                                                            index,
                                                            filters
                                                                    .attributes![0]
                                                                    .options![
                                                                selected[
                                                                    index]],
                                                            animation);
                                                      },
                                                    ));
                                              }),
                                        ]),
                                  )),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            if (display) ...{
                              Expanded(
                                flex: 5,
                                child: GestureDetector(
                                  onTap: () {
                                    List<String>? brandsIds;
                                    List<String>? categoriesIds;
                                    List<filter_model.Brand>? brands;
                                    List<filter_model.Category>? categories;
                                    List<Map<String, dynamic>>? attributes;
                                    if (filters.brands != null) {
                                      brandsIds = [];
                                      brands = [];
                                      selectedFiltersByBrand.value
                                          .forEach((index) {
                                        brandsIds!.add(filters.brands![index].id
                                            .toString());
                                        brands!.add(filters.brands![index]);
                                      });
                                    }
                                    if (!filters.categories.isNullOrEmpty) {
                                      widget.selectedFiltersNotifier.value
                                          .forEach((element) {
                                        categoriesIds = [];
                                        categories = [];
                                        categoriesIds!
                                            .add(element.item1.toString());
                                        categoriesIds!
                                            .add(element.item1.toString());
                                        if (element.item2 == null) {
                                          categories!.add(filters.categories!
                                              .firstWhere((category) =>
                                                  category.id ==
                                                  element.item1));
                                        } else {
                                          filter_model.Category category;
                                          filter_model.SubCategory sub = filters
                                              .categories!
                                              .firstWhere((category) =>
                                                  category.id == element.item2)
                                              .subCategories!
                                              .firstWhere((subcategory) =>
                                                  subcategory.id ==
                                                  element.item1);
                                          category = filter_model.Category(
                                              id: sub.id,
                                              name: sub.name,
                                              icon: sub.icon,
                                              isSubCategory: true);
                                          categories!.add(category);
                                        }
                                      });
                                    }
                                    List<String> options = [];
                                    if (!filters.attributes.isNullOrEmpty) {
                                      attributes = [];
                                      selectedFiltersBySize.value
                                          .forEach((index) {
                                        options.add(filters
                                            .attributes![0].options![index]);
                                      });
                                      attributes.add({
                                        "id": filters.attributes![0].id,
                                        "name": filters.attributes![0].name,
                                        "options": options
                                      });
                                    }
                                    List<String>? prices;
                                    if (lowerAndUpperBound != null) {
                                      if (lowerAndUpperBound!.value.item1 !=
                                              minPrice &&
                                          lowerAndUpperBound!.value.item2 !=
                                              maxPrice) {
                                        prices = [];
                                        prices.add(
                                            '${lowerAndUpperBound!.value.item1}-${lowerAndUpperBound!.value.item2}');
                                      }
                                    }
                                    widget.closeFilterPage.call();
                                    homeBloc.add(GetProductsWithFiltersEvent(
                                      boutiqueSlug: widget.boutiqueSlug,
                                      category: widget.category,
                                      brands: brandsIds,
                                      categories: categoriesIds,
                                      prices: prices,
                                      attributes: attributes,
                                      filtersChoosedByUser:
                                          filter_model.GetProductFiltersModel(
                                              filters: filter_model.Filter(
                                                  brands: brands.isNullOrEmpty
                                                      ? null
                                                      : brands,
                                                  categories:
                                                      categories.isNullOrEmpty
                                                          ? null
                                                          : categories,
                                                  attributes: options.isEmpty
                                                      ? null
                                                      : [
                                                          filter_model
                                                              .Attribute(
                                                            id: filters
                                                                .attributes![0]
                                                                .id,
                                                            name: filters
                                                                .attributes![0]
                                                                .name,
                                                            options: options,
                                                          ),
                                                        ],
                                                  prices: prices.isNullOrEmpty
                                                      ? null
                                                      : filter_model.Prices(
                                                          minPrice: int.parse(
                                                              prices![0].split(
                                                                  '-')[0]),
                                                          maxPrice: int.parse(
                                                              prices[0].split(
                                                                  '-')[1]),
                                                        ))),
                                      offset: 1,
                                    ));
                                    clearAllFiltersBeforeRequest();
                                  },
                                  child: Container(
                                    height: 65,
                                    decoration: BoxDecoration(
                                        color: Color(0xffFF5F61),
                                        boxShadow: [
                                          BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              blurRadius: 6,
                                              offset: Offset(0, 3)),
                                          BoxShadow(
                                              color:
                                                  Colors.white.withOpacity(0.4),
                                              blurRadius: 6,
                                              offset: Offset(0, 3),
                                              inset: true)
                                        ],
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Center(
                                      child: MyTextWidget(
                                        'Apply',
                                        style: textTheme.headline6?.rq.copyWith(
                                            color: Color(0xffFEFEFE),
                                            height: 23 / 18),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                            },
                            Expanded(
                              flex: 2,
                              child: GestureDetector(
                                onTap: () {
                                  clearAllFiltersBeforeRequest();
                                  homeBloc.add(GetProductFiltersEvent(
                                      boutiqueSlug: widget.boutiqueSlug,
                                      category: widget.category,
                                      forceUpdate: true));
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
                    ],
                  );
                })
          }
        ],
      );
    });
  }

  void _clearAllItemsFromAnimatedList(
      int length, GlobalKey<AnimatedListState> listKey) {
    for (var i = 0; i < length; i++) {
      listKey.currentState!.removeItem(0,
          (BuildContext context, Animation<double> animation) {
        return Container();
      });
    }
  }

  Widget buildBrandItem(int indexInBrandList, int index,
      filter_model.Brand item, Animation<double> animation) {
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

  Widget buildItem(int index, Tuple3<int, int?, double> item, String imageUrl,
      String name, Animation<double> animation) {
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
              (context, animation) =>
                  buildItem(index, item, imageUrl, name, animation),
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
                  imageUrl: imageUrl),
              SizedBox(
                width: 5,
              ),
              MyTextWidget(
                name,
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

  void clearAllFiltersBeforeRequest() {
    lowerAndUpperBound?.value = Tuple2(minPrice!, maxPrice!);
    int length = widget.selectedFiltersNotifier.value.length;
    widget.selectedFiltersNotifier.value = [];
    _clearAllItemsFromAnimatedList(length, widget.listKey);
    length = selectedFiltersByBrand.value.length;
    selectedFiltersByBrand.value = [];
    _clearAllItemsFromAnimatedList(length, listForBrandsKey);
    length = selectedFiltersByOffer.value.length;
    selectedFiltersByOffer.value = [];
    _clearAllItemsFromAnimatedList(length, listForOffersKey);
    length = selectedFiltersBySize.value.length;
    selectedFiltersBySize.value = [];
    _clearAllItemsFromAnimatedList(length, listForSizesKey);
  }
}

class FilterCircleWidget extends StatefulWidget {
  const FilterCircleWidget(
      {super.key,
      this.isExpanded = true,
      required this.imageUrl,
      required this.width,
      required this.height,
      required this.categoryName,
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
  final String imageUrl;
  final String categoryName;

  @override
  State<FilterCircleWidget> createState() => _FilterCircleWidgetState();
}

class _FilterCircleWidgetState extends State<FilterCircleWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(end: widget.paddingValue),
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
                        imageUrl: widget.imageUrl,
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
                  widget.categoryName,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: context.textTheme.caption?.rq.copyWith(
                      color: Color(0xff8E8E8E), letterSpacing: 0, height: 1.25),
                ),
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
      this.isSvg = false,
      required this.imageUrl});

  final double width;
  final double height;
  final bool isSvg;
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
              isSvg
                  ? SvgNetworkWidget(svgUrl: imageUrl)
                  : imageUrl.contains('assets')
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
