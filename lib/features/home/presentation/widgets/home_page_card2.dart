import 'dart:math';
import 'dart:ui' as ui;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/home/data/models/get_home_boutiqes_model.dart';
import 'package:trydos/features/home/presentation/pages/product_listing_page.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_executed_event_name.dart';
import '../../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../../app/my_text_widget.dart';
import '../../../app/svg_network_widget.dart';

class HomePageCard2 extends cupertino.StatefulWidget {
  HomePageCard2(
      {super.key,
      this.withSlidingImages = false,
      required this.boutique,
      required this.category_Slug});
  final String category_Slug;
  final bool withSlidingImages;
  final Boutique boutique;

  @override
  cupertino.State<HomePageCard2> createState() => _HomePageCard2State();
}

class _HomePageCard2State extends cupertino.State<HomePageCard2> {
  final ValueNotifier<int> resizeItems = ValueNotifier(-1);
  final ValueNotifier<int> changeBackgroundBlurImage = ValueNotifier(0);
  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  late AutoScrollController autoScrollController;
  late ScrollController scrollController;

  @override
  void initState() {
    autoScrollController = AutoScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            HelperFunctions.slidingNavigation(
                context,
                ProductListingPage(
                  boutique: widget.boutique,
                  withSlidingImages: widget.withSlidingImages,
                  boutiqueSlug: widget.boutique.slug!,
                  boutiqueDescription: widget.boutique.description,
                  boutiqueFirstBanner: widget.boutique.banners![0].filePath!,
                  boutiqueIcon: widget.boutique.icon?.filePath!,
                ));
            ////////////////////////////////////
            FirebaseAnalyticsService.logEventForSession(
              eventName: AnalyticsEventsConst.buttonClicked,
              executedEventName:
                  AnalyticsExecutedEventNameConst.chooseBoutiqueButton,
            );
            ////////////////////////////////////
            Future.delayed(
              Duration(milliseconds: 100),
              () {
                FirebaseAnalyticsService.logEventForViewedBoutique(
                  eventName: AnalyticsEventsConst.viewedBoutique,
                  boutiqueId: widget.boutique.id.toString(),
                  boutiqueName: widget.boutique.name.toString(),
                );
              },
            );
          },
          child: Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 235,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff000000).withOpacity(0.1),
                      offset: Offset(0, 3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: ValueListenableBuilder<int>(
                        valueListenable: changeBackgroundBlurImage,
                        builder: (context, index, _) {
                          print(index);
                          print((widget.boutique.banners?.length ?? 0) > 0);
                          return ((widget.boutique.banners?.length ?? 0) > 0)
                              ? MyCachedNetworkImage(
                                  imageFit: cupertino.BoxFit.cover,
                                  imageUrl:
                                      widget.boutique.banners![index].filePath!,
                                  width: 1.sw,
                                  radius: 15,
                                  height: 235,
                                )
                              : cupertino.SizedBox.shrink();
                        })),
              ),
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: BackdropFilter(
                    blendMode: BlendMode.overlay,
                    filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: Container(
                      decoration: BoxDecoration(color: Color(0xfffafafa)),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(
                      sigmaX: 10.0,
                      sigmaY: 10.0,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Color(0xffffffff).withOpacity(0.8)),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.only(start: 25.w, top: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        widget.boutique.icon != null
                            ? SvgNetworkWidget(
                                svgUrl: widget.boutique.icon!.filePath!,
                                height: 20,
                                width: 40,
                              )
                            : MyTextWidget(
                                widget.boutique.name!,
                                style:
                                    context.textTheme.titleMedium?.rd.copyWith(
                                  fontSize: 16,
                                  color: ui.Color.fromARGB(255, 15, 15, 15),
                                ),
                              ),
                        SizedBox(
                          height: 5,
                        ),
                        Html(
                          shrinkWrap: true,
                          data: widget.boutique.description ?? '',
                          style: {
                            "body": Style(margin: Margins.all(0)),
                            "p": Style(
                              maxLines: 1,
                              margin: Margins.all(0),
                            ),
                          },
                        ),
                        if (!widget.withSlidingImages)
                          SizedBox(
                            height: 10,
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: widget.withSlidingImages ? 0 : 10,
                        right: widget.withSlidingImages ? 0 : 10),
                    child: widget.withSlidingImages
                        ? cupertino.Container(
                            //color: Colors.red,
                            child: CarouselSlider.builder(
                                itemCount: widget.boutique.banners!.length,
                                itemBuilder: (context, index, _) {
                                  return Padding(
                                    padding: EdgeInsetsDirectional.only(
                                        start: index == 0 ? 0 : 10,
                                        top: 10,
                                        bottom: 10),
                                    child: Stack(
                                      children: [
                                        Container(
                                          height: 155,
                                          width: 1.sw,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                            border: Border.all(
                                                width: 0.5,
                                                color: const Color(0xfffafafa)),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0x33000000),
                                                offset: Offset(0, 3),
                                                blurRadius: 10,
                                              ),
                                            ],
                                          ),
                                          child: widget.boutique
                                                      .banners?[index] !=
                                                  null
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  child: MyCachedNetworkImage(
                                                    imageUrl: widget
                                                        .boutique
                                                        .banners![index]
                                                        .filePath!,
                                                    imageFit: BoxFit.cover,
                                                    width: 1.sw,
                                                    innerShadowYOffset: 3,
                                                    withInnerShadow: true,
                                                    height: 155,
                                                  ))
                                              : cupertino.SizedBox.shrink(),
                                        ),
                                        Container(
                                          height: 155,
                                          width: 1.sw,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.white
                                                      .withOpacity(0.7),
                                                  offset: Offset(0, 3),
                                                  blurRadius: 6,
                                                  inset: true),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                options: CarouselOptions(
                                  autoPlay: true,
                                  autoPlayInterval: Duration(seconds: 6),
                                  autoPlayAnimationDuration:
                                      Duration(seconds: 1),
                                  initialPage: 0,
                                  onPageChanged: (int index, _) {
                                    changeBackgroundBlurImage.value = index;
                                  },
                                  height: 155,
                                  enableInfiniteScroll: false,
                                  viewportFraction: 0.90,
                                )))
                        : Stack(
                            children: [
                              Container(
                                height: 135,
                                width: 1.sw,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  border: Border.all(
                                      width: 0.5,
                                      color: const Color(0xfffafafa)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0x33000000),
                                      offset: Offset(0, 3),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: ((widget.boutique.banners?.length ??
                                                0) ==
                                            0)
                                        ? cupertino.SizedBox.shrink()
                                        : MyCachedNetworkImage(
                                            imageUrl: widget
                                                .boutique.banners![0].filePath!,
                                            imageFit: BoxFit.cover,
                                            width: 1.sw,
                                            withInnerShadow: true,
                                            innerShadowYOffset: 3,
                                            height: 135,
                                          )),
                              ),
                              Container(
                                height: 135,
                                width: 1.sw,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.white.withOpacity(0.7),
                                        offset: Offset(0, 3),
                                        blurRadius: 6,
                                        inset: true),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  )
                ],
              )),
              PositionedDirectional(
                child: cupertino.Container(
                  height: 12,
                  child: cupertino.ListView.separated(
                    separatorBuilder: (context, index) => 13.horizontalSpace,
                    shrinkWrap: true,
                    scrollDirection: cupertino.Axis.horizontal,
                    itemBuilder: (context, index) {
                      return InkWell(
                          onTap: () {
                            HelperFunctions.slidingNavigation(
                                context,
                                ProductListingPage(
                                  boutique: widget.boutique,
                                  withSlidingImages: widget.withSlidingImages,
                                  boutiqueSlug: widget.boutique.slug!,
                                  category: widget
                                      .boutique
                                      .mainCategoriesForProductIds![index]
                                      .categorySlug,
                                  boutiqueDescription:
                                      widget.boutique.description!,
                                  boutiqueFirstBanner:
                                      widget.boutique.banners![0].filePath!,
                                  boutiqueIcon: widget.boutique.icon!.filePath!,
                                ));
                          },
                          child: SvgNetworkWidget(
                            svgUrl: widget
                                        .boutique
                                        .mainCategoriesForProductIds![index]
                                        .flatPhotoPath !=
                                    null
                                ? widget
                                    .boutique
                                    .mainCategoriesForProductIds![index]
                                    .flatPhotoPath!
                                    .filePath!
                                : "",
                            width: 12,
                            height: 12,
                          ));
                    },
                    itemCount:
                        widget.boutique.mainCategoriesForProductIds!.length,
                  ),
                ),

                /*  Row(
                  children: [
                    SvgPicture.asset(
                      AppAssets.manInactiveSvg,
                      height: 12,
                    ),
                    13.horizontalSpace,
                    SvgPicture.asset(
                      AppAssets.womenInactiveSvg,
                      height: 12,
                    ),
                    13.horizontalSpace,
                    SvgPicture.asset(
                      AppAssets.childrenInactiveSvg,
                      height: 12,
                    ),
                  ],
                ),*/
                end: 18.w,
                top: 18,
              ),
            ],
          ),
        ),
        Directionality(
          textDirection: ui.TextDirection.ltr,
          child: ValueListenableBuilder<int>(
              valueListenable: resizeItems,
              builder: (context, focused, _) {
                return GestureDetector(
                  onPanDown: (details) {
                    print(focused);
                    HapticFeedback.lightImpact();
                    resizeItems.value = (details.globalPosition.dx -
                            40 -
                            (9 -
                                    widget.boutique.mainCategoriesForProductIds!
                                        .length) /
                                //childCategoriesForProductIds!.length) /
                                2 *
                                (40.w - 5.w)) ~/
                        35.w;
                  },
                  onPanCancel: () {
                    resizeItems.value = -1;
                  },
                  onPanEnd: (details) {
                    resizeItems.value = -1;
                  },
                  onPanUpdate: (details) {
                    int prev = resizeItems.value;
                    resizeItems.value = (details.globalPosition.dx -
                            40 -
                            (9 -
                                    widget
                                        .boutique
                                        .mainCategoriesForProductIds!
                                        //.childCategoriesForProductIds!
                                        .length) /
                                2 *
                                (40.w - 5.w)) ~/
                        35.w;
                    if (prev != resizeItems.value) {
                      HapticFeedback.lightImpact();
                    }
                  },
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10.w,
                      ),
                      Transform.translate(
                        offset: Offset(10, 0),
                        child: SizedBox(
                          width: 340.w,
                          height: focused != -1 ? 100.w : 60.w,
                          child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: List.generate(
                                  min(
                                      9,
                                      widget
                                          .boutique
                                          .mainCategoriesForProductIds!
                                          //  .childCategoriesForProductIds!
                                          .length),
                                  (index) => AnimatedPositioned(
                                        left: (9 -
                                                    widget
                                                        .boutique
                                                        .mainCategoriesForProductIds!
                                                        //  .childCategoriesForProductIds!
                                                        .length) /
                                                2 *
                                                (40.w - 5.w) +
                                            (index * (40.w - 5.w) +
                                                (focused != -1
                                                    ? index == (focused + 1)
                                                        ? 20.w
                                                        : index == focused
                                                            ? 5.w
                                                            : index > focused
                                                                ? 20.w
                                                                : 0
                                                    : 0)),
                                        curve: Curves.fastEaseInToSlowEaseOut,
                                        bottom: focused == index ? 35.w : 10.w,
                                        duration: Duration(
                                            milliseconds:
                                                focused == index ? 150 : 10),
                                        child: InkWell(
                                          onTap: () {
                                            HelperFunctions.slidingNavigation(
                                                context,
                                                ProductListingPage(
                                                  boutique: widget.boutique,
                                                  withSlidingImages:
                                                      widget.withSlidingImages,
                                                  boutiqueSlug:
                                                      widget.boutique.slug!,
                                                  category: widget
                                                      .boutique
                                                      .mainCategoriesForProductIds![
                                                          index]
                                                      .categorySlug,
                                                  boutiqueDescription: widget
                                                      .boutique.description,
                                                  boutiqueFirstBanner: widget
                                                      .boutique
                                                      .banners![0]
                                                      .filePath!,
                                                  boutiqueIcon: widget.boutique
                                                          .icon?.filePath ??
                                                      "",
                                                ));
                                          },
                                          child: ProductItemCircle(
                                            index: index,
                                            isFocused: focused == index,
                                            imageUrl: widget
                                                    .boutique
                                                    .mainCategoriesForProductIds![
                                                        //  .childCategoriesForProductIds![
                                                        index]
                                                    .mostViewedProductThumbnail!
                                                    .filePath ??
                                                "",
                                            name: widget
                                                    .boutique
                                                    .mainCategoriesForProductIds![
                                                        //.childCategoriesForProductIds![
                                                        index]
                                                    .categoryName ??
                                                "",
                                            countProducts: (widget
                                                        .boutique
                                                        .mainCategoriesForProductIds![
                                                            //.childCategoriesForProductIds![
                                                            index]
                                                        .countProducts ??
                                                    "")
                                                .toString(),
                                          ),
                                        ),
                                      ))),
                        ),
                      ),
                      SizedBox(
                        height: 10.w,
                      )
                    ],
                  ),
                );
              }),
        ),
      ],
    );
  }
}

class ProductItemCircle extends StatelessWidget {
  const ProductItemCircle(
      {required this.index,
      required this.isFocused,
      super.key,
      required this.countProducts,
      required this.imageUrl,
      required this.name});

  final String imageUrl;
  final int index;
  final String countProducts;
  final String name;
  final bool isFocused;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFocused ? 50.w : 40.w,
      height: isFocused ? 80.w : 40.w,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          AnimatedOpacity(
            duration: Duration(milliseconds: 150),
            opacity: isFocused ? 1 : 0,
            curve: Curves.easeInOut,
            child: Transform.translate(
              offset: Offset(0, isFocused ? 35.w : 0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MyTextWidget(
                      name,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: context.textTheme.titleMedium?.rr.copyWith(
                          color: Color(0xff8E8E8E),
                          letterSpacing: 0,
                          height: 1.43),
                    ),
                    MyTextWidget(
                      countProducts,
                      textAlign: TextAlign.center,
                      style: context.textTheme.titleMedium?.rr.copyWith(
                          color: Color(0xff8E8E8E),
                          fontSize: 8.sp,
                          letterSpacing: 0,
                          height: 1.375),
                    )
                  ]),
            ),
          ),
          AnimatedScale(
            duration: Duration(milliseconds: 200),
            scale: isFocused ? 1.25 : 1,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 40.w,
                  width: 40.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff000000).withOpacity(0.16),
                        offset: Offset(0, 3),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(180),
                      child: MyCachedNetworkImage(
                          imageUrl: imageUrl,
                          width: 40.w,
                          imageFit: cupertino.BoxFit.cover,
                          height: 40.w)),
                ),
                Container(
                  height: 40.w,
                  width: 40.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.white.withOpacity(0.7),
                          offset: Offset(0, 4),
                          blurRadius: 6,
                          inset: true),
                    ],
                  ),
                ),
                index == 8
                    ? Container(
                        height: 40.w,
                        width: 40.w,
                        decoration: BoxDecoration(
                          color: const Color(0x98000000),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0x29000000),
                              offset: Offset(0, 3),
                              blurRadius: 3,
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.5),
                              inset: true,
                              offset: Offset(0, 4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
                index == 8
                    ? MyTextWidget(
                        'More',
                        style: context.textTheme.titleSmall?.rq
                            .copyWith(color: Colors.white),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
