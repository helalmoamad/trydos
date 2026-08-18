import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:trydos/features/app/app_widgets/trydos_app_bar/app_bar_params.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/trydos_appbar.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as listing;
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_buttons_event_name.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import '../../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../../../service/language_service.dart';

import '../widgets/product_details_body/product_details_image_widget.dart';

class ProductDetailsDisplayPicturesPage extends StatefulWidget {
  final List<listing.Thumbnail> images;
  final int currentIndex;
  final String brand;
  final String category;
  const ProductDetailsDisplayPicturesPage({
    super.key,
    required this.images,
    required this.currentIndex,
    required this.brand,
    required this.category,
  });

  @override
  State<ProductDetailsDisplayPicturesPage> createState() =>
      _ProductDetailsDisplayPicturesPageState();
}

class _ProductDetailsDisplayPicturesPageState
    extends State<ProductDetailsDisplayPicturesPage> {
  @override
  void didChangeDependencies() {
    // FirebaseAnalyticsService.logScreen(
    //   screen: AnalyticsScreensConst.productPhotosScreen,
    // );
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<int> selectedPicture = ValueNotifier(
      widget.currentIndex,
    );
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: TrydosAppBar(
          appBarParams: AppBarParams(
            scrolledUnderElevation: 0,
            backIconColor: Colors.black,
            withShadow: false,
          ),
        ),
        backgroundColor: const Color(0xffF4F4F4),
        body: SingleChildScrollView(
          child: ValueListenableBuilder<int>(
            valueListenable: selectedPicture,
            builder: (context, selectedIndex, _) {
              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(10.w),
                    child: ProductDetailsImageWidget(
                      orginalHeight: double.tryParse(
                        widget.images[selectedIndex].originalHeight!,
                      ),
                      orginalWidth: double.tryParse(
                        widget.images[selectedIndex].originalWidth!,
                      ),
                      height: 0.6.sh,
                      width: 1.sw,
                      imageUrl: widget.images[selectedIndex].filePath,
                    ),
                  ),
                  Stack(
                    alignment: LanguageService.rtl
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    children: [
                      SizedBox(
                        height: 160.h,
                        child: ScrollConfiguration(
                          behavior: const CupertinoScrollBehavior(),
                          child: ListView.separated(
                            itemCount: widget.images.length,
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.only(
                              left: 10.w,
                              right: 10.w,
                              top: 10.h,
                              bottom: 10.h,
                            ),
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  selectedPicture.value = index;
                                  FirebaseAnalyticsService.logEventForSession(
                                    eventName: AnalyticsEventsConst.VIEW_IMAGE,
                                    extraParams: {
                                      'image_index': index.toString(),
                                      'screen_name':
                                          GlobalScreenConst.PRODUCT_SCREEN,
                                      'brand': widget.brand,
                                      'category': widget.category,
                                    },
                                    executedEventName:
                                        AnalyticsButtonsEventNameConst
                                            .SHOW_PRODUCT_PHOTOS_BUTTON,
                                  );
                                },
                                child: ProductDetailsImageWidget(
                                  orginalHeight: double.tryParse(
                                    widget.images[index].originalHeight!,
                                  ),
                                  orginalWidth: double.tryParse(
                                    widget.images[index].originalWidth!,
                                  ),
                                  height: 140.h,
                                  radius: 15.r,
                                  width: 100.w,
                                  borderColor: index == selectedIndex
                                      ? const Color(0xff388CFF)
                                      : null,
                                  imageUrl: widget.images[index].filePath,
                                ),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return SizedBox(width: 5.w);
                            },
                          ),
                        ),
                      ),
                      Container(
                        color: Colors.transparent,
                        width: 20.w,
                        height: 160.h,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
