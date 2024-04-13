import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:overscroll_pop/overscroll_pop.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/app_bar_params.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/trydos_appbar.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/product_details_title.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_bottom_sheet.dart';

import '../../../app/app_draggable_sheet.dart';
import '../../../story/presentation/pages/story_collection.dart';
import '../widgets/product_details_body/product_details_chip_widget.dart';
import '../widgets/product_details_body/product_details_description_widget.dart';
import '../widgets/product_details_body/product_details_image_widget.dart';

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({super.key, required this.productId});

  final String productId;

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (error) {
      debugPrint(error.toString());
    };
    return OverscrollPop(
      workNormally: true,
      withRoundedCorners: true,
      child: Hero(
        tag: widget.productId,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Scaffold(
                  appBar: TrydosAppBar(
                    appBarParams: AppBarParams(
                        scrolledUnderElevation: 0,
                        backIconColor: Colors.black,
                        withShadow: false
                    ),
                  ),
                  backgroundColor: Color(0xffF4F4F4),
                  body: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                            height: 464,
                            child: ScrollConfiguration(
                              behavior: const CupertinoScrollBehavior(),
                              child: ListView.separated(
                                itemCount: 5,
                                shrinkWrap: true,
                                physics: const ClampingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                padding: EdgeInsets.only(left: 10, right: 10 , top: 10 , bottom: 15),
                                itemBuilder: (context, index) {
                                  return ProductDetailsImageWidget();
                                },
                                separatorBuilder: (context, index) {
                                  return SizedBox(
                                    width: 9,
                                  );
                                },
                              ),
                            )),
                        ProductDetailsTitle(),
                        SizedBox(
                          height: 5,
                        ),
                        ProductDetailsDescriptionWidget(),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                            height: 52,
                            child: ScrollConfiguration(
                              behavior: const CupertinoScrollBehavior(),
                              child: ListView.separated(
                                itemCount: 5,
                                physics: const ClampingScrollPhysics(),
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                padding: EdgeInsets.only(left: 20, right: 20),
                                itemBuilder: (context, index) {
                                  return ProductDetailsChipWidget(
                                    withIcon: index % 2 != 0,
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return SizedBox(
                                    width: 8,
                                  );
                                },
                              ),
                            )),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: (2 * 73.5 / (1.sh - 100.h)).sh,
                        ),
                      ],
                    ),
                  )),
              ProductDetailsBottomSheet()
            ],
          ),
        ),
      ),
    );
  }
}
