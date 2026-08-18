import 'package:flutter/foundation.dart' hide Category;
import 'package:easy_localization/easy_localization.dart' as tran;
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:ui' as ui;
import 'package:trydos/common/constant/design/assets_provider.dart';
import 'package:trydos/config/theme/typography.dart';

import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_image_widget.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_buttons_event_name.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_events.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import 'package:trydos/service/firebase_analytics_service/firebase_analytics_service.dart';
import 'package:trydos/service/language_service.dart';

import '../../../../../core/utils/theme_state.dart';

import '../../../data/models/get_product_listing_without_filters_model.dart'
    as productListingModel;
import '../../manager/homeBloc/home_bloc.dart';

class DisplayColorsCardNew extends StatefulWidget {
  const DisplayColorsCardNew({
    super.key,
    required this.productItem,
    required this.currentColorForProduct,
  });

  final productListingModel.Products productItem;

  final int currentColorForProduct;
  @override
  State<DisplayColorsCardNew> createState() => _DisplayColorsCardNewState();
}

class _DisplayColorsCardNewState extends ThemeState<DisplayColorsCardNew> {
  List<productListingModel.SyncColorImageProduct>? syncColorImageList;

  List<String> images = [];

  int? currentIndexInSlider;

  @override
  void initState() {
    syncColorImageList = widget.productItem.syncColorImages ?? [];
    syncColorImageList?.removeWhere((element) => element.images.isNullOrEmpty);

    images =
        syncColorImageList?.map((e) => e.images![0].filePath!).toList() ?? [];

    currentIndexInSlider = widget.currentColorForProduct;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) =>
          previous.currentSelectedColorForEveryProduct[widget.productItem.slug
              .toString()] !=
          current.currentSelectedColorForEveryProduct[widget.productItem.slug
              .toString()],
      builder: (context, state) {
        currentIndexInSlider =
            state.currentSelectedColorForEveryProduct[widget.productItem.slug
                .toString()] ??
            (widget.productItem.syncColorImages?.length ?? 0) ~/ 2;
        if ((currentIndexInSlider ?? 0) >
            (widget.productItem.syncColorImages?.length ?? 0)) {
          currentIndexInSlider = 0;
        }
        if (kDebugMode)
          print(
            "SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS4/////////////${state.currentSelectedColorForEveryProduct[widget.productItem.slug.toString()]} ${widget.productItem.slug.toString()} ${currentIndexInSlider}",
          );
        return Container(
          margin: EdgeInsets.only(left: 10.w, right: 10.w, bottom: 10.h),
          height: 76.h,
          width: 1.sw,
          decoration: BoxDecoration(
            color: const Color(0xffFCFCFC),
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Row(
            children: [
              Container(
                width: 120.w,
                padding: EdgeInsets.all(10.w),
                height: 76.h,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(AppAssets.colorPickerSvg, height: 20.h),
                    MyTextWidget(
                      '${LocaleKeys.available.tr()} ${syncColorImageList!.length} ${LocaleKeys.n_color.tr()}',
                      style: textTheme.titleLarge?.rq.copyWith(
                        color: const Color(0xff1D1D1D),
                        fontSize: 9.sp,
                      ),
                    ),
                    Row(
                      children: [
                        MyTextWidget(
                          '${syncColorImageList!.length} ',
                          style: textTheme.titleLarge?.bq.copyWith(
                            color: const Color(0xff1D1D1D),
                            fontSize: 11.sp,
                          ),
                        ),
                        MyTextWidget(
                          '${LocaleKeys.color_available.tr()}',
                          style: textTheme.titleLarge?.rq.copyWith(
                            color: const Color(0xff1D1D1D),
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 1.sw - 160.w,
                height: 75.h,
                child: Directionality(
                  textDirection: LanguageService.languageCode == "ar"
                      ? ui.TextDirection.ltr
                      : ui.TextDirection.rtl,
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(),
                    itemBuilder: (ctx, index) {
                      return GestureDetector(
                        onTap: () {
                          currentIndexInSlider = index;

                          BlocProvider.of<HomeBloc>(context).add(
                            AddCurrentSelectedColorEvent(
                              currentSelectedColor: index,
                              productSlug: widget.productItem.slug.toString(),
                            ),
                          );

                          //////////////////////////////
                          // FirebaseAnalyticsService
                          //     .logEventForSession(
                          //   eventName:
                          //       AnalyticsEventsConst
                          //           .buttonClicked,
                          //   executedEventName:
                          //       AnalyticsButtonsEventNameConst
                          //           .chooseAvailableColorButton,
                          // );
                          FirebaseAnalyticsService.logEventForSession(
                            executedEventName: AnalyticsButtonsEventNameConst
                                .CHOOSE_AVAILABLE_COLOR_BUTTON,
                            eventName: AnalyticsEventsConst.CHANGE_COLOR,
                            extraParams: {
                              'item_id': widget.productItem.productId
                                  .toString(),
                              'item_name': widget.productItem.name.toString(),
                              'brand': widget.productItem.brand!.name
                                  .toString(),
                              'category': widget.productItem.categories!
                                  .map((e) => e.name)
                                  .toList()
                                  .toString(),
                              'selected_color':
                                  widget.productItem.colors![index].name ??
                                  ''.toString(),
                              'screen_name': GlobalScreenConst.PRODUCT_SCREEN,
                              'selected_size':
                                  BlocProvider.of<HomeBloc>(context)
                                      .state
                                      .currentColorSizeForCart?['choiceOption'] ??
                                  '',
                            },
                          );
                        },
                        child: Stack(
                          children: [
                            ProductListingImageWidget(
                              width: 55.w,
                              height: 75.h,
                              radius: 6.r,
                              // مصغّرة تملأ إطارها: contain كانت تترك أشرطة
                              // رمادية لاختلاف نسبة أبعاد الصورة عن الصندوق
                              imageFit: BoxFit.cover,
                              withBackGroundShadow: true,
                              imageUrl: images[index],
                              innerShadowYOffset: 4,
                              borderColor: index == currentIndexInSlider
                                  ? const Color(0xff513AAF)
                                  /*? isColorWhite
                                          ? Colors.black
                                          : Color(int.parse(
                                              '0xff${widget.productItem.colors![currentIndexInSlider! % widget.productItem.colors!.length].color!.substring(1)}'))*/
                                  : null,
                              circleShape: false,
                            ),
                            !(syncColorImageList?[index].colorTrend ?? false)
                                ? const SizedBox.shrink()
                                : Positioned(
                                    top: 0,
                                    left: 0,
                                    child: SvgPicture.asset(
                                      AppAssets.trendingSvg,
                                    ),
                                  ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const SizedBox(width: 2);
                    },
                    itemCount: (syncColorImageList!.length),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
