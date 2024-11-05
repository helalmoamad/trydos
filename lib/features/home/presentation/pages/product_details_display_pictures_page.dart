import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:overscroll_pop/overscroll_pop.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/app_bar_params.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/trydos_appbar.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as listing;
import 'package:trydos/features/home/presentation/pages/product_details_page.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import '../../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../../../service/language_service.dart';
import '../../data/models/get_product_listing_without_filters_model.dart'
    as images;
import '../widgets/product_details_body/product_details_image_widget.dart';

class ProductDetailsDisplayPicturesPage extends StatefulWidget {
  final List<listing.Thumbnail> images;
  const ProductDetailsDisplayPicturesPage({super.key, required this.images});

  @override
  State<ProductDetailsDisplayPicturesPage> createState() =>
      _ProductDetailsDisplayPicturesPageState();
}

class _ProductDetailsDisplayPicturesPageState
    extends State<ProductDetailsDisplayPicturesPage> {
  final ValueNotifier<int> selectedPicture = ValueNotifier(0);

  @override
  void didChangeDependencies() {
    FirebaseAnalyticsService.logScreen(
      screen: AnalyticsScreensConst.productPhotosScreen,
    );
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (error) {
      debugPrint(error.toString());
    };
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
          appBar: TrydosAppBar(
            appBarParams: AppBarParams(
                scrolledUnderElevation: 0,
                backIconColor: Colors.black,
                withShadow: false),
          ),
          backgroundColor: Color(0xffF4F4F4),
          body: SingleChildScrollView(
            child: ValueListenableBuilder<int>(
              valueListenable: selectedPicture,
              builder: (context, selectedIndex, _) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ProductDetailsImageWidget(
                        orginalHeight: double.parse(
                            widget.images[selectedIndex].originalHeight!),
                        orginalWidth: double.parse(
                            widget.images[selectedIndex].originalWidth!),
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
                            height: 160,
                            child: ScrollConfiguration(
                              behavior: const CupertinoScrollBehavior(),
                              child: ListView.separated(
                                  itemCount: widget.images.length,
                                  shrinkWrap: true,
                                  physics: const ClampingScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.only(
                                      left: 10, right: 10, top: 10, bottom: 10),
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        selectedPicture.value = index;
                                      },
                                      child: ProductDetailsImageWidget(
                                        orginalHeight: double.parse(widget
                                            .images[index].originalHeight!),
                                        orginalWidth: double.parse(widget
                                            .images[index].originalWidth!),
                                        height: 140,
                                        radius: 15,
                                        width: 100,
                                        borderColor: index == selectedIndex
                                            ? Color(0xff388CFF)
                                            : null,
                                        imageUrl: widget.images[index].filePath,
                                      ),
                                    );
                                  },
                                  separatorBuilder: (context, index) {
                                    return SizedBox(
                                      width: 5,
                                    );
                                  }),
                            )),
                        Container(
                          color: Colors.transparent,
                          width: 20,
                          height: 160,
                        )
                      ],
                    ),
                  ],
                );
              },
            ),
          )),
    );
  }
}
