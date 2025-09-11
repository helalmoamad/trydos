import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gallery_3d/gallery3d.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import '../../../../../common/constant/design/assets_provider.dart';
import '../../../../../common/helper/helper_functions.dart';
import '../../../../../service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../../../service/firebase_analytics_service/analytics_const/analytics_buttons_event_name.dart';
import '../../../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../../../app/my_text_widget.dart';
import '../../../data/models/get_product_listing_without_filters_model.dart'
    as productListingModel;
import '../product_listing/product_listing_image_widget.dart';

class BuyersCameraShots extends StatefulWidget {
  const BuyersCameraShots(
      {super.key,
      required this.productItem,
      required this.panelControllerForBuyersCameraShots});

  final productListingModel.Products productItem;
  final PanelController panelControllerForBuyersCameraShots;

  @override
  State<BuyersCameraShots> createState() => _BuyersCameraShotsState();
}

class _BuyersCameraShotsState extends State<BuyersCameraShots> {
  List<productListingModel.SyncColorImage>? syncColorImageList;

  List<String> images = [];

  late final Gallery3DController? gallery3dControllerForCircles;

  late final int currentIndexInSlider;

  final ValueNotifier<bool> scaleAnimationOnImages = ValueNotifier(true);

  @override
  void initState() {
    syncColorImageList = widget.productItem.syncColorImages ?? [];
    syncColorImageList?.removeWhere((element) => element.images.isNullOrEmpty);
    syncColorImageList = [
      ...syncColorImageList ?? [],
      ...syncColorImageList ?? [],
      ...syncColorImageList ?? [],
      ...syncColorImageList ?? [],
      ...syncColorImageList ?? [],
      ...syncColorImageList ?? [],
    ];
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
                        : 0.25,
                initialIndex: syncColorImageList!.length ~/ 4,
                primaryshiftingOffsetDivision: (syncColorImageList!.length) == 4
                    ? 4.5
                    : (syncColorImageList!.length) <= 8
                        ? 2.5
                        : 1.25,
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
    FlutterError.onError = (FlutterErrorDetails error) {
      try {
        BlocProvider.of<HomeBloc>(context).add((SendErrorToMobileErrorLogEvent(
            errorExption: error.exceptionAsString().toString(),
            errorPath: error.stack.toString().split("#")[1],
            urlBackend: "Front Error",
            messageFromeBackend: "Front Error")));
      } catch (e) {}
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };
    return Container(
      height: 50,
      margin: const EdgeInsets.only(left: 20, right: 10),
      decoration: BoxDecoration(
          color: const Color(0xffF8F8F8),
          borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 10,
            ),
            child: GestureDetector(
              onTap: () {
                HelperFunctions.showDescriptionForProductDetails(
                    context: context);
                //////////////////////////////
                // FirebaseAnalyticsService.logEventForSession(
                //   eventName: AnalyticsEventsConst.buttonClicked,
                //   executedEventName:
                //       AnalyticsButtonsEventNameConst.showBuyersCameraButton,
                // );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    AppAssets.chromeIconSvg,
                    height: 20,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  MyTextWidget(
                    '${LocaleKeys.buyers_camera.tr()} 12 ${LocaleKeys.shot.tr()}',
                    style: context.textTheme.titleLarge?.rq
                        .copyWith(color: const Color(0xff8D8D8D)),
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
          const Spacer(),
          Container(
            width: 100,
            child: GestureDetector(
              onTap: () {
                scaleAnimationOnImages.value = false;
                Future.delayed(const Duration(milliseconds: 150), () {
                  scaleAnimationOnImages.value = true;
                });
                Future.delayed(const Duration(milliseconds: 300), () {
                  widget.panelControllerForBuyersCameraShots.open();
                });
              },
              child: ValueListenableBuilder<bool>(
                  valueListenable: scaleAnimationOnImages,
                  builder: (context, oneValue, _) {
                    return AnimatedScale(
                      scale: oneValue ? 1 : 0.9,
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.fastLinearToSlowEaseIn,
                      child: (syncColorImageList?.length ?? 0) <= 8
                          ? SizedBox(
                              height: 40,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(
                                    3,
                                    (index) => GestureDetector(
                                          child: ProductListingImageWidget(
                                            width: 40 - index * 5,
                                            height: 40 - index * 5,
                                            withBackGroundShadow: true,
                                            imageUrl:
                                                'assets/images/details_circle.jpg',
                                            // images[index],
                                            innerShadowYOffset: 4,
                                            borderColor: // index == currentIndexInSlider
                                                // ? Color(int.parse(
                                                // '0xff${widget.productItem.colors![currentIndexInSlider % widget.productItem.colors!.length].color!.substring(1)}')) :
                                                Colors.white,
                                            circleShape: true,
                                          ),
                                        )),
                              ))
                          : Gallery3D(
                              // key: ValueKey('gallery3dControllerForCircles${widget.itemIndex}'),
                              controller: gallery3dControllerForCircles!,
                              denyScrolling: true,
                              width: 172,
                              padding: EdgeInsets.zero,
                              stopScrollingOnEdges: (double primaryDelta) {
                                return (primaryDelta <= 0 &&
                                        gallery3dControllerForCircles!
                                                .currentIndex ==
                                            (syncColorImageList!.length ~/ 2 -
                                                1)) ||
                                    (primaryDelta >= 0 &&
                                        gallery3dControllerForCircles!
                                                .currentIndex ==
                                            0);
                              },
                              changingPagesScrollOffset: 0.1,
                              isClip: false,
                              onItemChanged: (index) {
                                currentIndexInSlider = index;
                              },
                              onClickItem: (index) {
                                scaleAnimationOnImages.value = false;
                                Future.delayed(
                                    const Duration(milliseconds: 150), () {
                                  scaleAnimationOnImages.value = true;
                                });
                                Future.delayed(
                                    const Duration(milliseconds: 300), () {
                                  widget.panelControllerForBuyersCameraShots
                                      .open();
                                });
                              },
                              itemConfig: const GalleryItemConfig(
                                  width: 40,
                                  height: 40,
                                  radius: 180,
                                  isShowTransformMask: false,
                                  shadows: [
                                    BoxShadow(
                                      color: Color(0x19000000),
                                      offset: Offset(0, 3),
                                      blurRadius: 6,
                                    ),
                                  ]),
                              itemBuilder: (context, index) {
                                return Visibility(
                                  visible:
                                      index < (syncColorImageList!.length ~/ 2),
                                  child: const ProductListingImageWidget(
                                    width: 40,
                                    height: 40,
                                    imageUrl:
                                        'assets/images/details_circle.jpg',
                                    // images[index],
                                    innerShadowYOffset: 4,
                                    borderColor: // index == currentIndexInSlider
                                        // ? Color(int.parse(
                                        // '0xff${widget.productItem.colors![currentIndexInSlider % widget.productItem.colors!.length].color!.substring(1)}')) :
                                        Colors.white,
                                    circleShape: true,
                                  ),
                                );
                              }),
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
