import 'dart:async';
import 'dart:math';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gallery_3d/gallery3d.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:local_hero/local_hero.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/home/data/models/get_product_detail_without_related_products_model.dart';
import '../../../data/models/get_product_listing_without_filters_model.dart'
    as product;
import '../../../../../core/utils/theme_state.dart';
import '../../manager/home_bloc.dart';
import '../../manager/home_state.dart';
import 'dart:ui' as ui;
class DisplaySizesCard extends StatefulWidget {
  const DisplaySizesCard(
      {super.key,
      required this.scrollController,
      required this.variation,
      required this.productItem,
      required this.currentColorForProduct});

  final ScrollController scrollController;
  final List<Variation>? variation;
  final product.Products productItem;
  final int currentColorForProduct;

  @override
  State<DisplaySizesCard> createState() => _DisplaySizesCardState();
}

class _DisplaySizesCardState extends ThemeState<DisplaySizesCard> {
  Timer? _timer;
  Timer? _recallForAutoScroll;
  double scrollSpeed = 0.25;

  List<String>? sizes;

  late final Gallery3DController? gallery3dControllerForCircles;

  final ValueNotifier<int> displayMode = ValueNotifier(0);

  int? currentIndexInSlider;

  late final List<ScrollController> controllers;
  late final List<double> scrollOffsets;
  List<int> controllersToStopScroll = [];
  int? prevMode;
  final GlobalKey selectSizeCardKey = GlobalKey();

  void changingModeListener() {
    if (renderBox == null && selectSizeCardKey.currentContext != null) {
      renderBox =
          selectSizeCardKey.currentContext?.findRenderObject() as RenderBox;
    }
    if (renderBox != null &&
        displayMode.value == 1 &&
        (renderBox!.localToGlobal(Offset.zero).dy + 175 - 1.sh).abs() <= 10) {
      prevMode = displayMode.value;
      prevModeForRunHero = null;
      displayMode.value = 0;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        prevMode = null;
        displayMode.notifyListeners();
        renderBox = null;
      });
    }
  }

  void _scrollListener(ScrollController _scrollController, {int index = 0}) {
    if (_scrollController.position.userScrollDirection ==
            ScrollDirection.reverse ||
        _scrollController.position.userScrollDirection ==
            ScrollDirection.forward) {
      _timer?.cancel();
      controllersToStopScroll.add(index);
      _startAutoScroll();
      _recallForAutoScroll?.cancel();
      _recallForAutoScroll = Timer(const Duration(seconds: 2), () {
        _timer?.cancel();
        controllersToStopScroll.remove(index);
        _startAutoScroll();
      });
    }
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      setState(() {
        for (int i = 0; i < controllers.length; i++) {
          if (controllers[i].hasClients &&
              !controllersToStopScroll.contains(i)) {
            scrollOffsets[i] += scrollSpeed;
            if (scrollOffsets[i] >= controllers[i].position.maxScrollExtent) {
              scrollOffsets[i] = 0.0;
            }
            controllers[i].jumpTo(scrollOffsets[i]);
          }
        }
      });
    });
  }

  // @override
  // void dispose() {
  //   for (int i = 0; i < controllers.length; i++) {
  //     controllers[i].removeListener(() => _scrollListener(controllers[i] , index: i));
  //   }
  //   for (int i = 0; i < controllers.length; i++) {
  //     controllers[i].dispose();
  //   }
  //   super.dispose();
  // }
  RenderBox? renderBox;

  @override
  void initState() {
    sizes = [];
    if (widget.variation != null && !widget.productItem.colors.isNullOrEmpty) {
      widget.variation!.forEach((element) {
        if (element.type!.split("-")[0] ==
                widget
                    .productItem.colors![widget.currentColorForProduct].name &&
            element.qty != null) {
          if (element.qty! > 0) {
            sizes!.add(element.type!.split("-")[1]);
          }
        }
      });
    }

    sizes = [
      ...sizes ?? [],
      ...sizes ?? [],
    ];
    widget.scrollController.addListener(changingModeListener);
    gallery3dControllerForCircles = sizes.isNullOrEmpty || sizes!.length < 3
        ? null
        : Gallery3DController(
            itemCount: sizes!.length,
            autoLoop: false,
            minScale: (sizes!.length) == 4
                ? 0.7
                : (sizes!.length) <= 8
                    ? 0.55
                    : 0.4,
            initialIndex: sizes!.length ~/ 4,
            primaryshiftingOffsetDivision: (sizes!.length) == 4
                ? 4.5
                : (sizes!.length) <= 8
                    ? 2.5
                    : 1.6,
            scrollTime: 1);
    if (sizes!.length <= 8) {
      currentIndexInSlider = 0;
    } else {
      currentIndexInSlider = sizes!.length ~/ 4;
    }
    super.initState();
  }

  final ExpansionTileController expansionTileController =
      ExpansionTileController();

  int? prevModeForRunHero;

  bool firstTime = true;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
        buildWhen: (p, c) =>
            p.currentSelectedColorForEveryProduct !=
                c.currentSelectedColorForEveryProduct ||
            p.sizes != c.sizes,
        builder: (context, state) {
          return ValueListenableBuilder<int>(
              valueListenable: displayMode,
              builder: (context, mode, _) {
                sizes = state.sizes;
                sizes = [
                  ...sizes ?? [],
                  ...sizes ?? [],
                ];
                return renderBox != null &&
                        prevMode == 1 &&
                        (renderBox!.localToGlobal(Offset.zero).dy + 175 - 1.sh)
                                .abs() <=
                            10
                    ? SizedBox.shrink()
                    : LocalHeroScope(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.fastLinearToSlowEaseIn,
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: mode == 0 ? 15.0 : 0,
                              right: mode == 0 ? 15.0 : 0),
                          child: AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.fastLinearToSlowEaseIn,
                              alignment: Alignment.topCenter,
                              child: Container(
                                key: selectSizeCardKey,
                                height: mode == 2
                                    ? 300
                                    : mode == 1
                                        ? 205
                                        : 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: const Color(0xffF8F8F8)),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: mode != 0 ? 30 : 10,
                                                top: mode == 0 ? 5 : 15),
                                            child: GestureDetector(
                                              onTap: () {
                                                HelperFunctions
                                                    .showDescriptionForProductDetails(
                                                        context: context);
                                              },
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  SvgPicture.asset(
                                                    AppAssets
                                                        .coloredSizeIconSvg,
                                                    height: 20,
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  MyTextWidget(
                                                    'Available ${sizes!.length ~/ 2} Sizes',
                                                    style: textTheme
                                                        .titleLarge?.rq
                                                        .copyWith(
                                                            color: const Color(
                                                                0xff8D8D8D)),
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  SvgPicture.asset(
                                                    AppAssets.registerInfoSvg,
                                                    height: 12,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                              padding: EdgeInsets.only(
                                                  right: mode == 0 ? 20.0 : 10,
                                                  top: 5),
                                              child: mode == 0
                                                  ? LocalHero(
                                                      tag: 'sizes',
                                                      enabled:
                                                          prevModeForRunHero ==
                                                              null,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          WidgetsBinding
                                                              .instance
                                                              .addPostFrameCallback(
                                                                  (timeStamp) {
                                                            prevModeForRunHero =
                                                                1;
                                                          });
                                                          displayMode.value = 1;
                                                          if (widget
                                                                  .scrollController
                                                                  .position
                                                                  .pixels <
                                                              (1.sh -
                                                                  renderBox!
                                                                      .localToGlobal(
                                                                          Offset
                                                                              .zero)
                                                                      .dy +
                                                                  150 -
                                                                  renderBox!
                                                                      .size
                                                                      .height)) {
                                                            widget.scrollController.animateTo(
                                                                (1.sh -
                                                                    renderBox!
                                                                        .localToGlobal(Offset
                                                                            .zero)
                                                                        .dy +
                                                                    150 -
                                                                    renderBox!
                                                                        .size
                                                                        .height),
                                                                curve: Curves
                                                                    .fastEaseInToSlowEaseOut,
                                                                duration: Duration(
                                                                    milliseconds:
                                                                        300));
                                                          }
                                                        },
                                                        child:
                                                            (sizes?.length ??
                                                                        0) <=
                                                                    8
                                                                ? SizedBox(
                                                                    height: 40,
                                                                    child: Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      children: List.generate(
                                                                          sizes!.length ~/ 2,
                                                                          (index) => GestureDetector(
                                                                                  child: SizeItemWidget(
                                                                                sizeName: sizes![index],
                                                                                width: 40 - index * 5,
                                                                                height: 40 - index * 5,
                                                                                index: index,
                                                                                currentIndex: currentIndexInSlider!,
                                                                              ))),
                                                                    ))
                                                                : Material(
                                                                    color: Colors
                                                                        .transparent,
                                                                    child: Directionality(
                                                                      textDirection: ui.TextDirection.ltr,
                                                                      child: Gallery3D(
                                                                          // key: ValueKey('gallery3dControllerForCircles${widget.itemIndex}'),
                                                                          controller: gallery3dControllerForCircles!,
                                                                          denyScrolling: true,
                                                                          width: 200,
                                                                          stopScrollingOnEdges: (double primaryDelta) {
                                                                            return (primaryDelta <= 0 && gallery3dControllerForCircles!.currentIndex == (sizes!.length ~/ 2 - 1)) ||
                                                                                (primaryDelta >= 0 && gallery3dControllerForCircles!.currentIndex == 0);
                                                                          },
                                                                          height: null,
                                                                          changingPagesScrollOffset: 0.1,
                                                                          isClip: false,
                                                                          onItemChanged: (index) {
                                                                            currentIndexInSlider =
                                                                                index;
                                                                          },
                                                                          onClickItem: (index) {
                                                                            WidgetsBinding
                                                                                .instance
                                                                                .addPostFrameCallback((timeStamp) {
                                                                              prevModeForRunHero =
                                                                                  1;
                                                                            });
                                                                            displayMode.value =
                                                                                1;
                                                                            if (widget.scrollController.position.pixels <
                                                                                (1.sh - renderBox!.localToGlobal(Offset.zero).dy + 150 - renderBox!.size.height)) {
                                                                              widget.scrollController.animateTo((1.sh - renderBox!.localToGlobal(Offset.zero).dy + 150 - renderBox!.size.height),
                                                                                  curve: Curves.fastEaseInToSlowEaseOut,
                                                                                  duration: const Duration(milliseconds: 300));
                                                                            }
                                                                          },
                                                                          itemConfig: const GalleryItemConfig(
                                                                            width:
                                                                                40,
                                                                            height:
                                                                                40,
                                                                            radius:
                                                                                180,
                                                                            isShowTransformMask:
                                                                                false,
                                                                          ),
                                                                          itemBuilder: (context, index) {
                                                                            return Visibility(
                                                                                visible: ((gallery3dControllerForCircles?.currentIndex ?? 0) < (sizes!.length ~/ 2) && index < (sizes!.length ~/ 2)) || (gallery3dControllerForCircles?.currentIndex ?? 0) >= (sizes!.length ~/ 2),
                                                                                child: SizeItemWidget(
                                                                                  sizeName: sizes![index],
                                                                                  width: 40,
                                                                                  height: 40,
                                                                                  index: index,
                                                                                  currentIndex: currentIndexInSlider!,
                                                                                ));
                                                                          }),
                                                                    ),
                                                                  ),
                                                      ),
                                                    )
                                                  : GestureDetector(
                                                      onTap: () {},
                                                      child: Container(
                                                        width: 30,
                                                        height: 30,
                                                        color:
                                                            Colors.transparent,
                                                        child: Center(
                                                          child: Container(
                                                            width: 12,
                                                            height: 12,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Color(
                                                                  0xffD3D3D3),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          180),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    )),
                                        ],
                                      ),
                                      SizedBox(
                                        height: mode != 0 ? 10 : 0,
                                      ),
                                      mode != 0
                                          ? LocalHero(
                                              tag: 'sizes',
                                              enabled:
                                                  prevModeForRunHero == null,
                                              child: Container(
                                                  height: mode == 1 ? 70 : 240,
                                                  child: ListView.separated(
                                                      physics:
                                                          BouncingScrollPhysics(),
                                                      padding: EdgeInsets.only(
                                                          left: mode != 0
                                                              ? 20
                                                              : 0),
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemBuilder:
                                                          (ctx, index) {
                                                        return GestureDetector(
                                                          onTap: () {
                                                            currentIndexInSlider =
                                                                index;
                                                            HapticFeedback
                                                                .lightImpact();
                                                          },
                                                          child:
                                                              AnimatedContainer(
                                                                  duration: Duration(
                                                                      milliseconds:
                                                                          300),
                                                                  curve: Curves
                                                                      .fastLinearToSlowEaseIn,
                                                                  alignment:
                                                                      Alignment
                                                                          .topCenter,
                                                                  child:
                                                                      SizeItemWidget(
                                                                    sizeName:
                                                                        sizes![
                                                                            index],
                                                                    width: mode ==
                                                                            1
                                                                        ? 70
                                                                        : 135,
                                                                    height:
                                                                        mode == 1
                                                                            ? 70
                                                                            : 195,
                                                                    index:
                                                                        index,
                                                                    currentIndex:
                                                                        currentIndexInSlider!,
                                                                  )),
                                                        );
                                                      },
                                                      separatorBuilder:
                                                          (context, index) {
                                                        return SizedBox(
                                                          width: 10,
                                                        );
                                                      },
                                                      itemCount:
                                                          (sizes!.length ~/
                                                              2))),
                                            )
                                          : SizedBox.shrink(),
                                      if (mode != 0) ...{
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Container(
                                            width: 1.sw,
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 20),
                                            height: 30,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Color(0xffF4F4F4)),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SvgPicture.asset(
                                                    AppAssets.registerInfoSvg),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                MyTextWidget(
                                                  'L ',
                                                  style: textTheme.titleMedium?.bq
                                                      .copyWith(
                                                          height: 1,
                                                          color: const Color(
                                                              0xff505050)),
                                                ),
                                                MyTextWidget(
                                                  'Recommended ',
                                                  style: textTheme.titleMedium?.rq
                                                      .copyWith(
                                                          height: 1,
                                                          color: const Color(
                                                              0xff505050)),
                                                ),
                                                MyTextWidget(
                                                  'Size ',
                                                  style: textTheme.titleMedium?.bq
                                                      .copyWith(
                                                          height: 1,
                                                          color: const Color(
                                                              0xff505050)),
                                                ),
                                                MyTextWidget(
                                                  'For You ',
                                                  style: textTheme.titleMedium?.rq
                                                      .copyWith(
                                                          height: 1,
                                                          color: const Color(
                                                              0xff505050)),
                                                ),
                                                MyTextWidget(
                                                  'Last ',
                                                  style: textTheme.titleMedium?.rq
                                                      .copyWith(
                                                          height: 1,
                                                          color: const Color(
                                                              0xffFFAF5F)),
                                                ),
                                                MyTextWidget(
                                                  '2',
                                                  style: textTheme.titleMedium?.mq
                                                      .copyWith(
                                                          height: 1,
                                                          color: const Color(
                                                              0xffFFAF5F)),
                                                ),
                                              ],
                                            )),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Container(
                                          height: 30,
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: DottedBorder(
                                            radius: Radius.circular(10),
                                            borderType: BorderType.RRect,
                                            strokeCap: StrokeCap.round,
                                            strokeWidth: 0.5,
                                            color: Color(0xff707070),
                                            dashPattern: [3, 3],
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                SvgPicture.asset(
                                                  AppAssets.malokanSvg,
                                                  height: 20,
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                MyTextWidget(
                                                  'Need Help Finding Your Size?',
                                                  style: textTheme.titleMedium?.rq
                                                      .copyWith(
                                                          color: const Color(
                                                              0xff505050)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.only(
                                                right: mode == 0 ? 20.0 : 10,
                                                top: 5),
                                            child: mode == 0
                                                ? LocalHero(
                                                    tag: 'sizes',
                                                    enabled:
                                                        prevModeForRunHero ==
                                                            null,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        WidgetsBinding.instance
                                                            .addPostFrameCallback(
                                                                (timeStamp) {
                                                          prevModeForRunHero =
                                                              1;
                                                        });
                                                        displayMode.value = 1;
                                                        if ((widget
                                                                        .scrollController
                                                                        .position
                                                                        .pixels -
                                                                    widget
                                                                        .scrollController
                                                                        .position
                                                                        .maxScrollExtent)
                                                                .abs() >
                                                            120) {
                                                          widget.scrollController.animateTo(
                                                              widget
                                                                      .scrollController
                                                                      .position
                                                                      .maxScrollExtent -
                                                                  100,
                                                              curve: Curves
                                                                  .fastEaseInToSlowEaseOut,
                                                              duration: Duration(
                                                                  milliseconds:
                                                                      300));
                                                        }
                                                      },
                                                      child:
                                                          (sizes?.length ??
                                                                      0) <=
                                                                  8
                                                              ? SizedBox(
                                                                  height: 40,
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: List.generate(
                                                                        sizes!.length ~/ 2,
                                                                        (index) => GestureDetector(
                                                                                child: SizeItemWidget(
                                                                              sizeName: sizes![index],
                                                                              width: 40 - index * 5,
                                                                              height: 40 - index * 5,
                                                                              index: index,
                                                                              currentIndex: currentIndexInSlider!,
                                                                            ))),
                                                                  ))
                                                              : Material(
                                                                  color: Colors
                                                                      .transparent,
                                                                  child: Gallery3D(
                                                                      // key: ValueKey('gallery3dControllerForCircles${widget.itemIndex}'),
                                                                      controller: gallery3dControllerForCircles!,
                                                                      denyScrolling: true,
                                                                      width: 200,
                                                                      stopScrollingOnEdges: (double primaryDelta) {
                                                                        return (primaryDelta <= 0 && gallery3dControllerForCircles!.currentIndex == (sizes!.length ~/ 2 - 1)) ||
                                                                            (primaryDelta >= 0 &&
                                                                                gallery3dControllerForCircles!.currentIndex == 0);
                                                                      },
                                                                      height: null,
                                                                      changingPagesScrollOffset: 0.1,
                                                                      isClip: false,
                                                                      onItemChanged: (index) {
                                                                        currentIndexInSlider =
                                                                            index;
                                                                      },
                                                                      onClickItem: (index) {
                                                                        WidgetsBinding
                                                                            .instance
                                                                            .addPostFrameCallback((timeStamp) {
                                                                          prevModeForRunHero =
                                                                              1;
                                                                        });
                                                                        displayMode
                                                                            .value = 1;
                                                                        if ((widget.scrollController.position.pixels - widget.scrollController.position.maxScrollExtent).abs() >
                                                                            120) {
                                                                          widget.scrollController.animateTo(
                                                                              widget.scrollController.position.maxScrollExtent - 100,
                                                                              curve: Curves.fastEaseInToSlowEaseOut,
                                                                              duration: const Duration(milliseconds: 300));
                                                                        }
                                                                      },
                                                                      itemConfig: const GalleryItemConfig(
                                                                        width:
                                                                            40,
                                                                        height:
                                                                            40,
                                                                        radius:
                                                                            180,
                                                                        isShowTransformMask:
                                                                            false,
                                                                      ),
                                                                      itemBuilder: (context, index) {
                                                                        return Visibility(
                                                                            visible:
                                                                                ((gallery3dControllerForCircles?.currentIndex ?? 0) < (sizes!.length ~/ 2) && index < (sizes!.length ~/ 2)) || (gallery3dControllerForCircles?.currentIndex ?? 0) >= (sizes!.length ~/ 2),
                                                                            child: SizeItemWidget(
                                                                              sizeName: sizes![index],
                                                                              width: 40,
                                                                              height: 40,
                                                                              index: index,
                                                                              currentIndex: currentIndexInSlider!,
                                                                            ));
                                                                      }),
                                                                ),
                                                    ),
                                                  )
                                                : GestureDetector(
                                                    onTap: () {
                                                      // if (displayMode.value == 1) {
                                                      //   if ((widget
                                                      //                   .scrollController
                                                      //                   .position
                                                      //                   .pixels -
                                                      //               widget
                                                      //                   .scrollController
                                                      //                   .position
                                                      //                   .maxScrollExtent)
                                                      //           .abs() >
                                                      //       170) {
                                                      //     widget.scrollController.animateTo(
                                                      //         widget
                                                      //                 .scrollController
                                                      //                 .position
                                                      //                 .maxScrollExtent -
                                                      //             140,
                                                      //         curve: Curves
                                                      //             .fastEaseInToSlowEaseOut,
                                                      //         duration: Duration(
                                                      //             milliseconds: 300));
                                                      //   }
                                                      // }
                                                    },
                                                    child: Container(
                                                      width: 30,
                                                      height: 30,
                                                      color: Colors.transparent,
                                                      child: Center(
                                                        child: Container(
                                                          width: 12,
                                                          height: 12,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Color(
                                                                0xffD3D3D3),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        180),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )),
                                        SizedBox(
                                          height: mode != 0 ? 10 : 0,
                                        ),
                                        mode != 0
                                            ? LocalHero(
                                                tag: 'sizes',
                                                enabled:
                                                    prevModeForRunHero == null,
                                                child: Container(
                                                    height:
                                                        mode == 1 ? 70 : 240,
                                                    child: ListView.separated(
                                                        physics:
                                                            BouncingScrollPhysics(),
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: mode != 0
                                                                    ? 20
                                                                    : 0),
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        itemBuilder:
                                                            (ctx, index) {
                                                          return GestureDetector(
                                                            onTap: () {
                                                              currentIndexInSlider =
                                                                  index;
                                                              HapticFeedback
                                                                  .lightImpact();
                                                            },
                                                            child:
                                                                AnimatedContainer(
                                                                    duration: Duration(
                                                                        milliseconds:
                                                                            300),
                                                                    curve: Curves
                                                                        .fastLinearToSlowEaseIn,
                                                                    alignment:
                                                                        Alignment
                                                                            .topCenter,
                                                                    child:
                                                                        SizeItemWidget(
                                                                      sizeName:
                                                                          sizes![
                                                                              index],
                                                                      width: mode ==
                                                                              1
                                                                          ? 70
                                                                          : 135,
                                                                      height: mode ==
                                                                              1
                                                                          ? 70
                                                                          : 195,
                                                                      index:
                                                                          index,
                                                                      currentIndex:
                                                                          currentIndexInSlider!,
                                                                    )),
                                                          );
                                                        },
                                                        separatorBuilder:
                                                            (context, index) {
                                                          return SizedBox(
                                                            width: 10,
                                                          );
                                                        },
                                                        itemCount:
                                                            (sizes!.length ~/
                                                                2))),
                                              )
                                            : SizedBox.shrink()
                                      }
                                    ]),
                              )),
                        ));
              });
        });
  }
}

class SizeItemWidget extends StatelessWidget {
  const SizeItemWidget(
      {super.key,
      required this.sizeName,
      required this.currentIndex,
      required this.index,
      required this.width,
      required this.height});

  final String sizeName;
  final int currentIndex;
  final int index;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(180.0),
          color: index == currentIndex ? Color(0xffF4F4F4) : Color(0xffF8F8F8)),
      child: DottedBorder(
        radius: Radius.circular(180),
        borderType: BorderType.RRect,
        strokeCap: StrokeCap.round,
        strokeWidth: 0.5,
        color: Color(0xff707070),
        dashPattern: [3, 3],
        child: Center(
          child: Text(
            sizeName,
            style: context.textTheme.headlineLarge?.rq.copyWith(
              height: 1.3,
              fontSize: index != currentIndex
                  ? index < currentIndex
                      ? max(10.sp, (20 - (currentIndex - index) * 8).sp)
                      : max(10.sp, (20 - (index - currentIndex) * 8).sp)
                  : 14.sp,
              color: const Color(0xff505050),
            ),
          ),
        ),
      ),
    );
  }
}
