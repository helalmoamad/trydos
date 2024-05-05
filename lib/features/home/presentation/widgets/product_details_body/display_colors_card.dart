import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gallery_3d/gallery3d.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';

import '../../../../../core/utils/theme_state.dart';
import '../../../data/models/get_product_listing_without_filters_model.dart'
    as productListingModel;
import '../../manager/home_bloc.dart';
import '../product_listing/product_listing_image_widget.dart';

class DisplayColorsCard extends StatefulWidget {
  const DisplayColorsCard(
      {super.key, required this.productItem, required this.scrollController});

  final productListingModel.Product productItem;
  final ScrollController scrollController;

  @override
  State<DisplayColorsCard> createState() => _DisplayColorsCardState();
}

class _DisplayColorsCardState extends ThemeState<DisplayColorsCard> {
  List<productListingModel.SyncColorImage>? syncColorImageList;

  List<String> images = [];

  late final Gallery3DController? gallery3dControllerForCircles;

  final ValueNotifier<int> displayMode = ValueNotifier(0);

  int currentIndexInSlider = 0;

  final _myListKey = GlobalKey<AnimatedListState>();
  bool isProgrammaticScroll = false;

  void changingModeListener() {
    print(
        '${widget.scrollController.position.activity is DrivenScrollActivity}');
    if (widget.scrollController.position.activity is DrivenScrollActivity) {
      return;
    }
    if (displayMode.value != 0) {
      displayMode.value = 0;
    }
  }

  @override
  void initState() {
    BlocProvider.of<HomeBloc>(context)
        .add(AddCurrentIndexEvent(currentIndex: 0));
    widget.scrollController.addListener(changingModeListener);
    syncColorImageList = widget.productItem.syncColorImages ?? [];
    syncColorImageList?.removeWhere((element) => element.images.isNullOrEmpty);
    syncColorImageList = [
      ...syncColorImageList ?? [],
      ...syncColorImageList ?? []
    ];
    images = syncColorImageList?.map((e) => e.images![0]).toList() ?? [];
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
                initialIndex: syncColorImageList!.length ~/ 4,
                primaryshiftingOffsetDivision: (syncColorImageList!.length) == 4
                    ? 4.5
                    : (syncColorImageList!.length) <= 8
                        ? 2.5
                        : 1.6,
                scrollTime: 1);
    if (syncColorImageList!.length <= 8) {
      currentIndexInSlider = 0;
    } else {
      currentIndexInSlider = syncColorImageList!.length ~/ 4;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: displayMode,
        builder: (context, mode, _) {
          return Container(
            decoration: BoxDecoration(
                color: Color(0xffF8F8F8),
                borderRadius: BorderRadius.circular(15)),
            margin: mode == 0 ? EdgeInsets.only(left: 20, right: 10) : null,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      left: mode == 0 ? 10.0 : 30, top: mode == 0 ? 0 : 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          displayMode.value = 0;
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              AppAssets.colorPickerSvg,
                              height: 20,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            MyTextWidget(
                              'Available ${syncColorImageList!.length ~/ 2} Color',
                              style: textTheme.bodyText2?.rq
                                  .copyWith(color: Color(0xff8D8D8D)),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            SvgPicture.asset(
                              AppAssets.registerInfoSvg,
                              height: 12,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: mode == 0 ? 20.0 : 10),
                        child: GestureDetector(
                          onTap: () {
                            displayMode.value = 1;
                            WidgetsBinding.instance
                                .addPostFrameCallback((timeStamp) {
                              widget.scrollController.animateTo(
                                  widget.scrollController.position
                                      .maxScrollExtent,
                                  duration: Duration(milliseconds: 150),
                                  curve: Curves.easeInOut);
                            });
                          },
                          child: mode == 0
                              ? (syncColorImageList?.length ?? 0) <= 8
                                  ? SizedBox(
                                      height: 40,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: List.generate(
                                            syncColorImageList!.length ~/ 2,
                                            (index) => GestureDetector(
                                                  child:
                                                      ProductListingImageWidget(
                                                    width: 35 - index * 5,
                                                    height: 35 - index * 5,
                                                    withBackGroundShadow: true,
                                                    imageUrl: images[index],
                                                    innerShadowYOffset: 4,
                                                    borderColor: index ==
                                                            currentIndexInSlider
                                                        ? Color(int.parse(
                                                            '0xff${widget.productItem.colors![currentIndexInSlider % widget.productItem.colors!.length].color!.substring(1)}'))
                                                        : Colors.white,
                                                    circleShape: true,
                                                  ),
                                                )).reversed.toList(),
                                      ))
                                  : Gallery3D(
                                      // key: ValueKey('gallery3dControllerForCircles${widget.itemIndex}'),
                                      controller:
                                          gallery3dControllerForCircles!,
                                      width: 200,
                                      stopScrollingOnEdges:
                                          (double primaryDelta) {
                                        return (primaryDelta <= 0 &&
                                                gallery3dControllerForCircles!
                                                        .currentIndex ==
                                                    (syncColorImageList!
                                                                .length ~/
                                                            2 -
                                                        1)) ||
                                            (primaryDelta >= 0 &&
                                                gallery3dControllerForCircles!
                                                        .currentIndex ==
                                                    0);
                                      },
                                      height: null,
                                      changingPagesScrollOffset: 0.1,
                                      isClip: false,
                                      onItemChanged: (index) {
                                        currentIndexInSlider = index;
                                      },
                                      itemConfig: GalleryItemConfig(
                                          width: 35,
                                          height: 35,
                                          radius: 180,
                                          isShowTransformMask: false,
                                          shadows: [
                                            BoxShadow(
                                              color: Color(0x19000000),
                                              offset: Offset(0, 3),
                                              blurRadius: 6,
                                            ),
                                          ]),
                                      onClickItem: (index) {},
                                      itemBuilder: (context, index) {
                                        return Visibility(
                                          visible: index <
                                              (syncColorImageList!.length ~/ 2),
                                          child: ProductListingImageWidget(
                                            width: 35,
                                            height: 35,
                                            imageUrl: images[index],
                                            innerShadowYOffset: 4,
                                            borderColor: index ==
                                                    currentIndexInSlider
                                                ? Color(int.parse(
                                                    '0xff${widget.productItem.colors![currentIndexInSlider % widget.productItem.colors!.length].color!.substring(1)}'))
                                                : Colors.white,
                                            circleShape: true,
                                          ),
                                        );
                                      })
                              : GestureDetector(
                                  onTap: () {
                                    if (mode == 1) {
                                      displayMode.value = 2;
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((timeStamp) {
                                        widget.scrollController.animateTo(
                                            widget.scrollController.position
                                                    .maxScrollExtent -
                                                150,
                                            duration:
                                                Duration(milliseconds: 150),
                                            curve: Curves.easeInOut);
                                      });
                                    } else {
                                      widget.scrollController
                                          .removeListener(changingModeListener);
                                      displayMode.value = 1;
                                      Future.delayed(
                                          Duration(milliseconds: 1000), () {
                                        widget.scrollController
                                            .addListener(changingModeListener);
                                      });
                                    }
                                  },
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    color: Colors.red,
                                    child: Center(
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: Color(0xffD3D3D3),
                                          borderRadius: BorderRadius.circular(
                                              mode == 1 ? 3 : 180),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (mode != 0) ...{
                  SizedBox(
                    height: mode == 2 ? 10 : 5,
                  ),
                  // AnimatedList(
                  //   key: _myListKey,
                  //   shrinkWrap: true,
                  //   scrollDirection: Axis.horizontal,
                  //   initialItemCount: (syncColorImageList!.length ~/ 2),
                  //   itemBuilder: (ctx , index , animation){
                  //     return SlideTransition(position: animation.drive(Tween()) , child: ,);
                  //   },
                  // ),
                  SizedBox(
                      height: mode == 1 ? 112 : 240,
                      child: ListView.separated(
                          physics: BouncingScrollPhysics(),
                          padding: EdgeInsets.only(left: 20),
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (ctx, index) {
                            return Column(
                              children: [
                                if (mode == 1) ...{
                                  MyTextWidget(
                                    syncColorImageList![index].colorTrend ==
                                            true
                                        ? "Trend"
                                        : " ",
                                    style: textTheme.overline?.mq.copyWith(
                                        color: Color(0xffFF5F61), height: 1.3),
                                  ),
                                },
                                GestureDetector(
                                  onTap: () {
                                    currentIndexInSlider = index;
                                    BlocProvider.of<HomeBloc>(context).add(
                                        AddCurrentIndexEvent(
                                            currentIndex: index));
                                  },
                                  child: ProductListingImageWidget(
                                    width: mode == 1 ? 70 : 135,
                                    height: mode == 1 ? 70 : 194,
                                    withBackGroundShadow: true,
                                    imageUrl: images[index],
                                    innerShadowYOffset: 4,
                                    borderColor: index == currentIndexInSlider
                                        ? Color(int.parse(
                                            '0xff${widget.productItem.colors![currentIndexInSlider % widget.productItem.colors!.length].color!.substring(1)}'))
                                        : Colors.white,
                                    circleShape: mode == 1 ? true : false,
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                MyTextWidget(
                                  syncColorImageList![index]
                                      .colorName
                                      .toString(),
                                  style: currentIndexInSlider == index
                                      ? textTheme.bodyText2?.mq.copyWith(
                                          color: Color(0xff3C3C3C),
                                          height: 1.26,
                                          fontSize: 15.sp)
                                      : textTheme.bodyText2?.rq.copyWith(
                                          color: Color(0xff3C3C3C),
                                          height: 1.26,
                                          fontSize: 15.sp),
                                ),
                                if (mode == 2) ...{
                                  MyTextWidget(
                                    'Offer',
                                    style: textTheme.caption?.mq.copyWith(
                                        color: Color(0xff388CFF), height: 1.3),
                                  ),
                                },
                              ],
                            );
                          },
                          separatorBuilder: (context, index) {
                            return SizedBox(
                              width: mode == 1 ? 10 : 5,
                            );
                          },
                          itemCount: (syncColorImageList!.length ~/ 2)))
                },
                if (mode != 0)
                  SizedBox(
                    height: 10,
                  )
              ],
            ),
          );
        });
  }
}
