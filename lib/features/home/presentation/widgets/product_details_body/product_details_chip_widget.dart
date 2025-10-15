import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:trydos/config/theme/typography.dart';

import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/app/svg_network_widget.dart';
import 'package:trydos/features/home/data/models/get_product_detail_without_related_products_model.dart';
import '../../../../../common/helper/helper_functions.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';

class ProductDetailsChipWidget extends StatelessWidget {
  const ProductDetailsChipWidget(
      {super.key, this.withIcon = false, required this.descriptor});
  final DataDescriptor? descriptor;
  final bool withIcon;

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return GestureDetector(
      onTap: () {
        HelperFunctions.showDescriptionForProductDetails(context: context);
      },
      child: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: const Color(0xffFCFCFC),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                SvgNetworkWidget(
                  svgUrl: descriptor!.descriptorGroup!.icon!,
                  color: const Color(0xff1D1D1D),
                  width: 11,
                  height: 11,
                ),
                const SizedBox(
                  width: 5,
                ),
                MyTextWidget(
                  descriptor!.descriptorGroup!.name!,
                  style: context.textTheme.titleSmall?.ra.copyWith(
                      color: const Color(0xff1D1D1D), fontSize: 9, height: 1.3),
                ),
              ]),
              SizedBox(
                height: 16,
                child: ListView.separated(
                  itemCount: descriptor!.descriptors!.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (withIcon) ...{
                            MyTextWidget(
                              descriptor!.descriptors![index].value!,
                              style: context.textTheme.titleLarge?.rq.copyWith(
                                  height: 1.23,
                                  color: const Color(0xff1D1D1D),
                                  fontSize: 11.sp),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: SvgNetworkWidget(
                                svgUrl: descriptor!
                                    .descriptors![index].descriptor!.icon!,
                                color: const Color(0xff1D1D1D),
                                width: 11,
                                height: 11,
                              ),
                            ),
                          },
                          MyTextWidget(
                            descriptor!.descriptors![index].descriptor!.name!,
                            style: context.textTheme.titleMedium?.rq.copyWith(
                                height: 1.23,
                                color: const Color(0xff1D1D1D),
                                fontSize: 11.sp),
                          )
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const SizedBox(
                      width: 5,
                    );
                  },
                ),
              )
            ],
          )),
    );
  }
}
