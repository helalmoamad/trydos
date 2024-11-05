import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gallery_3d/gallery3d.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui' as ui;
import 'package:local_hero/local_hero.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';

import '../../../../../core/utils/theme_state.dart';
import '../../../../../service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../../../service/firebase_analytics_service/analytics_const/analytics_executed_event_name.dart';
import '../../../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../../data/models/get_product_listing_without_filters_model.dart'
    as productListingModel;
import '../../manager/home_bloc.dart';
import '../product_listing/product_listing_image_widget.dart';

class DisplayColorsCard extends StatefulWidget {
  const DisplayColorsCard(
      {super.key,
      required this.productItem,
      required this.scrollController,
      required this.currentColorForProduct});

  final productListingModel.Products productItem;
  final ScrollController scrollController;
  final int currentColorForProduct;
  @override
  State<DisplayColorsCard> createState() => _DisplayColorsCardState();
}

class _DisplayColorsCardState extends ThemeState<DisplayColorsCard> {
  Timer? _timer;
  Timer? _recallForAutoScroll;
  double scrollSpeed = 0.25;

  List<productListingModel.SyncColorImage>? syncColorImageList;

  List<String> images = [];

  late final Gallery3DController? gallery3dControllerForCircles;

  final ValueNotifier<int> displayMode = ValueNotifier(0);

  int? currentIndexInSlider;

  late final List<ScrollController> controllers;
  late final List<double> scrollOffsets;
  List<int> controllersToStopScroll = [];
  int? prevMode;
  final GlobalKey selectColorCardKey = GlobalKey();

  void changingModeListener() {
    if (renderBox == null && selectColorCardKey.currentContext != null) {
      renderBox =
          selectColorCardKey.currentContext?.findRenderObject() as RenderBox;
    }

    if (renderBox != null &&
        (displayMode.value == 1 || displayMode.value == 2) &&
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

    // if ((widget.scrollController.position.pixels <= (widget.scrollController.position.maxScrollExtent - 650) &&
    //     displayMode.value == 1) ||
    //     (widget.scrollController.position.pixels <= (widget.scrollController.position.maxScrollExtent - 775) &&
    //         displayMode.value == 2)) {
    //   prevMode = displayMode.value;
    //   prevModeForRunHero = null;
    //   displayMode.value = 0;
    //   WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //     prevMode = null;
    //     displayMode.notifyListeners();
    //   });
    // }

    // if (widget.scrollController.position.activity is DrivenScrollActivity) {
    //   return;
    // }
    // if(expandedOrNot.value){
    //   expansionTileController.collapse();
    //   expandedOrNot.value = false;
    //   if(displayMode.value == 2) {
    //     displayMode.value--;
    //   }
    // }
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

  @override
  void initState() {
    syncColorImageList = widget.productItem.syncColorImages ?? [];
    syncColorImageList?.removeWhere((element) => element.images.isNullOrEmpty);
    syncColorImageList = [
      ...syncColorImageList ?? [],
      ...syncColorImageList ?? [],
    ];
    // controllers = List.generate(syncColorImageList?.length ?? 0, (index) => ScrollController());
    // scrollOffsets = List.generate(syncColorImageList?.length ?? 0, (index) => 0);
    // _startAutoScroll();
    // int i = 0;
    // controllers.forEach((element) {
    //   element.addListener(() {
    //     _scrollListener(element , index : i++);
    //   });
    // });
    widget.scrollController.addListener(changingModeListener);
    images =
        syncColorImageList?.map((e) => e.images![0].filePath!).toList() ?? [];
    gallery3dControllerForCircles =
        syncColorImageList.isNullOrEmpty || syncColorImageList!.length < 3
            ? null
            : Gallery3DController(
                itemCount: syncColorImageList!.length,
                autoLoop: false,
                minScale: (syncColorImageList!.length) == 4
                    ? 0.7
                    : (syncColorImageList!.length) <= 8
                        ? 0.55
                        : 0.4,
                initialIndex: widget.currentColorForProduct,
                primaryshiftingOffsetDivision: (syncColorImageList!.length) == 4
                    ? 4.5
                    : (syncColorImageList!.length) <= 8
                        ? 2.5
                        : 1.6,
                scrollTime: 1);
    currentIndexInSlider = widget.currentColorForProduct;
    super.initState();
  }

  final ExpansionTileController expansionTileController =
      ExpansionTileController();

  int? prevModeForRunHero;
  RenderBox? renderBox;
  bool firstTime = true;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: displayMode,
        builder: (context, mode, _) {
          return (renderBox != null &&
                  (prevMode == 1 || prevMode == 2) &&
                  (renderBox!.localToGlobal(Offset.zero).dy + 175 - 1.sh)
                          .abs() <=
                      10)
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
                          key: selectColorCardKey,
                          height: mode == 2
                              ? 300
                              : mode == 1
                                  ? 175
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
                                            AppAssets.colorPickerSvg,
                                            height: 20,
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          MyTextWidget(
                                            'Available ${syncColorImageList!.length ~/ 2} Color',
                                            style: textTheme.titleLarge?.rq
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
                                          right: mode == 0 ? 20.0 : 10, top: 5),
                                      child: mode == 0
                                          ? LocalHero(
                                              tag: 'colors',
                                              enabled:
                                                  prevModeForRunHero == null,
                                              child: GestureDetector(
                                                onTap: () {
                                                  WidgetsBinding.instance
                                                      .addPostFrameCallback(
                                                          (timeStamp) {
                                                    prevModeForRunHero = 1;
                                                  });
                                                  if (widget.scrollController
                                                          .position.pixels <
                                                      (1.sh -
                                                          renderBox!
                                                              .localToGlobal(
                                                                  Offset.zero)
                                                              .dy +
                                                          150 -
                                                          renderBox!
                                                              .size.height)) {
                                                    widget.scrollController.animateTo(
                                                        (1.sh -
                                                            renderBox!
                                                                .localToGlobal(
                                                                    Offset.zero)
                                                                .dy +
                                                            150 -
                                                            renderBox!
                                                                .size.height),
                                                        curve: Curves
                                                            .fastEaseInToSlowEaseOut,
                                                        duration: Duration(
                                                            milliseconds: 300));
                                                  }
                                                  displayMode.value = 1;
                                                },
                                                child:
                                                    (syncColorImageList
                                                                    ?.length ??
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
                                                              children:
                                                                  List.generate(
                                                                      syncColorImageList!
                                                                              .length ~/
                                                                          2,
                                                                      (index) =>
                                                                          GestureDetector(
                                                                            child:
                                                                                ProductListingImageWidget(
                                                                              width: 40 - index * 5,
                                                                              height: 40 - index * 5,
                                                                              imageWidth: 70,
                                                                              imageHeight: 70,
                                                                              withBackGroundShadow: true,
                                                                              imageUrl: images[index],
                                                                              innerShadowYOffset: 4,
                                                                              borderColor: index == currentIndexInSlider ? Color(int.parse('0xff${widget.productItem.colors![currentIndexInSlider! % widget.productItem.colors!.length].color!.substring(1)}')) : Colors.white,
                                                                              circleShape: true,
                                                                            ),
                                                                          )),
                                                            ))
                                                        : Material(
                                                            color: Colors
                                                                .transparent,
                                                            child:
                                                                Directionality(
                                                              textDirection: ui
                                                                  .TextDirection
                                                                  .ltr,
                                                              child: Gallery3D(
                                                                  // key: ValueKey('gallery3dControllerForCircles${widget.itemIndex}'),
                                                                  controller:
                                                                      gallery3dControllerForCircles!,
                                                                  denyScrolling:
                                                                      true,
                                                                  width: 200,
                                                                  stopScrollingOnEdges:
                                                                      (double
                                                                          primaryDelta) {
                                                                    return (primaryDelta <=
                                                                                0 &&
                                                                            gallery3dControllerForCircles!.currentIndex ==
                                                                                (syncColorImageList!.length ~/ 2 -
                                                                                    1)) ||
                                                                        (primaryDelta >=
                                                                                0 &&
                                                                            gallery3dControllerForCircles!.currentIndex ==
                                                                                0);
                                                                  },
                                                                  height: null,
                                                                  changingPagesScrollOffset:
                                                                      0.1,
                                                                  isClip: false,
                                                                  onItemChanged:
                                                                      (index) {
                                                                    currentIndexInSlider =
                                                                        index;
                                                                  },
                                                                  onClickItem:
                                                                      (index) {
                                                                    WidgetsBinding
                                                                        .instance
                                                                        .addPostFrameCallback(
                                                                            (timeStamp) {
                                                                      prevModeForRunHero =
                                                                          1;
                                                                    });
                                                                    displayMode
                                                                        .value = 1;
                                                                    if (widget
                                                                            .scrollController
                                                                            .position
                                                                            .pixels <
                                                                        (1.sh -
                                                                            renderBox!.localToGlobal(Offset.zero).dy +
                                                                            150 -
                                                                            renderBox!.size.height)) {
                                                                      widget.scrollController.animateTo(
                                                                          (1.sh -
                                                                              renderBox!.localToGlobal(Offset.zero).dy +
                                                                              150 -
                                                                              renderBox!.size.height),
                                                                          curve: Curves.fastEaseInToSlowEaseOut,
                                                                          duration: const Duration(milliseconds: 300));
                                                                    }
                                                                  },
                                                                  itemConfig: const GalleryItemConfig(
                                                                      width: 40,
                                                                      height:
                                                                          40,
                                                                      radius:
                                                                          180,
                                                                      isShowTransformMask:
                                                                          false,
                                                                      shadows: [
                                                                        BoxShadow(
                                                                          color:
                                                                              Color(0x19000000),
                                                                          offset: Offset(
                                                                              0,
                                                                              3),
                                                                          blurRadius:
                                                                              6,
                                                                        ),
                                                                      ]),
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) {
                                                                    return Visibility(
                                                                      visible: ((gallery3dControllerForCircles?.currentIndex ?? 0) < (syncColorImageList!.length ~/ 2) && index < (syncColorImageList!.length ~/ 2)) ||
                                                                          (gallery3dControllerForCircles?.currentIndex ?? 0) >=
                                                                              (syncColorImageList!.length ~/ 2),
                                                                      child:
                                                                          ProductListingImageWidget(
                                                                        width:
                                                                            40,
                                                                        height:
                                                                            40,
                                                                        imageWidth:
                                                                            70,
                                                                        imageHeight:
                                                                            70,
                                                                        imageUrl:
                                                                            images[index],
                                                                        innerShadowYOffset:
                                                                            4,
                                                                        borderColor: index ==
                                                                                currentIndexInSlider
                                                                            ? Color(int.parse('0xff${widget.productItem.colors![currentIndexInSlider! % widget.productItem.colors!.length].color!.substring(1)}'))
                                                                            : Colors.white,
                                                                        circleShape:
                                                                            true,
                                                                      ),
                                                                    );
                                                                  }),
                                                            ),
                                                          ),
                                              ),
                                            )
                                          : GestureDetector(
                                              onTap: () {
                                                if (displayMode.value == 1) {
                                                  displayMode.value = 2;
                                                  if (widget.scrollController
                                                          .position.pixels <
                                                      (1.sh -
                                                          renderBox!
                                                              .localToGlobal(
                                                                  Offset.zero)
                                                              .dy +
                                                          renderBox!
                                                                  .size.height /
                                                              2)) {
                                                    widget.scrollController.animateTo(
                                                        (1.sh -
                                                            renderBox!
                                                                .localToGlobal(
                                                                    Offset.zero)
                                                                .dy +
                                                            renderBox!.size
                                                                    .height /
                                                                2),
                                                        curve: Curves
                                                            .fastEaseInToSlowEaseOut,
                                                        duration: Duration(
                                                            milliseconds: 300));
                                                  }
                                                } else {
                                                  displayMode.value = 1;
                                                }
                                              },
                                              child: Container(
                                                width: 30,
                                                height: 30,
                                                color: Colors.transparent,
                                                child: Center(
                                                  child: Container(
                                                    width: 12,
                                                    height: 12,
                                                    decoration: BoxDecoration(
                                                      color: Color(0xffD3D3D3),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              180),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )),
                                ],
                              ),
                              SizedBox(
                                height: mode != 0 ? 20 : 0,
                              ),
                              mode != 0
                                  ? LocalHero(
                                      tag: 'colors',
                                      enabled: prevModeForRunHero == null,
                                      child: Container(
                                          height: mode == 1 ? 112 : 240,
                                          child: ListView.separated(
                                              physics: BouncingScrollPhysics(),
                                              padding: EdgeInsets.only(
                                                  left: mode != 0 ? 20 : 0),
                                              scrollDirection: Axis.horizontal,
                                              itemBuilder: (ctx, index) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    currentIndexInSlider =
                                                        index;
                                                    HapticFeedback
                                                        .lightImpact();

                                                    BlocProvider.of<HomeBloc>(
                                                            context)
                                                        .add(AddCurrentSelectedColorEvent(
                                                            currentSelectedColor:
                                                                index,
                                                            productId: widget
                                                                .productItem.id
                                                                .toString()));
                                                    //////////////////////////////
                                                    FirebaseAnalyticsService
                                                        .logEventForSession(
                                                      eventName:
                                                          AnalyticsEventsConst
                                                              .buttonClicked,
                                                      executedEventName:
                                                          AnalyticsExecutedEventNameConst
                                                              .chooseAvailableColorButton,
                                                    );
                                                  },
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      AnimatedContainer(
                                                        duration: Duration(
                                                            milliseconds: 300),
                                                        curve: Curves
                                                            .fastLinearToSlowEaseIn,
                                                        alignment:
                                                            Alignment.topCenter,
                                                        child:
                                                            ProductListingImageWidget(
                                                          width: mode == 1
                                                              ? 70
                                                              : 135,
                                                          height: mode == 1
                                                              ? 70
                                                              : 195,
                                                          withBackGroundShadow:
                                                              true,
                                                          imageUrl:
                                                              images[index],
                                                          innerShadowYOffset: 4,
                                                          borderColor: index ==
                                                                  currentIndexInSlider
                                                              ? Color(int.parse(
                                                                  '0xff${widget.productItem.colors![currentIndexInSlider! % widget.productItem.colors!.length].color!.substring(1)}'))
                                                              : Colors.white,
                                                          circleShape:
                                                              mode == 1,
                                                        ),
                                                      ),
                                                      SizedBox(height: 5),
                                                      SizedBox(
                                                        width: 70,
                                                        child: Center(
                                                          child: MyTextWidget(
                                                            syncColorImageList![
                                                                    index]
                                                                .colorName
                                                                .toString(),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: currentIndexInSlider ==
                                                                    index
                                                                ? textTheme
                                                                    .titleLarge
                                                                    ?.mq
                                                                    .copyWith(
                                                                    color: Color(
                                                                        0xff3C3C3C),
                                                                    height:
                                                                        1.35,
                                                                  )
                                                                : textTheme
                                                                    .titleLarge
                                                                    ?.rq
                                                                    .copyWith(
                                                                        color: Color(
                                                                            0xff3C3C3C),
                                                                        height:
                                                                            1.35),
                                                          ),
                                                        ),
                                                      ),
                                                      MyTextWidget(
                                                        'Offer',
                                                        style: textTheme
                                                            .titleMedium?.mq
                                                            .copyWith(
                                                          color:
                                                              Color(0xff388CFF),
                                                          height: 1.3,
                                                        ),
                                                      ),
                                                      // if (mode == 1) ...{
                                                      //   MyTextWidget(
                                                      //     'Trend',
                                                      //     style: textTheme.titleSmall?.mq.copyWith(
                                                      //       color: Color(0xffFF5F61),
                                                      //       height: 1.3,
                                                      //     ),
                                                      //   ),
                                                      // },
                                                    ],
                                                  ),
                                                );
                                              },
                                              separatorBuilder:
                                                  (context, index) {
                                                return SizedBox(
                                                  width: 10,
                                                );
                                              },
                                              itemCount:
                                                  (syncColorImageList!.length ~/
                                                      2))),
                                    )
                                  : SizedBox.shrink(),
                            ],
                          ),
                        ),
                      )),
                );
        });
  }
}
