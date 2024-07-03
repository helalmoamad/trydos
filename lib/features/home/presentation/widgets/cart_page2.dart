import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/home/data/models/get_cart_item_model.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/product_details_image_widget.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/my_gallery3d_widget.dart';

import '../../../../service/language_service.dart';

class CartPage2 extends StatelessWidget {
  final GetCartShippingItemsModel getCartShippingItemsModel;
  const CartPage2({Key? key, required this.getCartShippingItemsModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    int length = getCartShippingItemsModel.data!.cart!.length - 1;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        body: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 60),
              padding: EdgeInsets.symmetric(horizontal: 10),
              width: 1.sw - 20,
              height: 85.h,
              child: Column(
                children: [
                  DottedBorder(
                    radius: Radius.circular(10),
                    borderType: BorderType.RRect,
                    strokeCap: StrokeCap.round,
                    strokeWidth: 0.5,
                    color: Color(0xff707070),
                    dashPattern: [3, 3],
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      height: 40.h,
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: SvgPicture.asset(
                              AppAssets.backIconArrowSvg,
                              height: 20,
                            ),
                          ),
                          Spacer(),
                          Text(
                            "      Your Shopping Bag",
                            style: context.textTheme.subtitle1?.ra.copyWith(
                                color: const Color(0xff505050),
                                letterSpacing: 0.18,
                                fontSize: 13,
                                height: 1.33),
                          ),
                          Spacer(),
                          SvgPicture.asset(
                            AppAssets.bagsSvg,
                            height: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color(0xffF8F8F8)),
                    margin: EdgeInsets.only(top: 5.h),
                    height: 30.h,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(AppAssets.countItemSvg),
                        Text(" ${length + 1} ",
                            style: context.textTheme.subtitle1?.mr.copyWith(
                                fontSize: 13,
                                color: const Color(0xff5D5C5D),
                                letterSpacing: 0.18,
                                height: 1.33)),
                        Text(
                          "item ",
                          style: context.textTheme.subtitle1?.la.copyWith(
                              fontSize: 13,
                              color: const Color(0xff8D8D8D),
                              letterSpacing: 0.18,
                              height: 1.33),
                        ),
                        Text(
                          "${getCartShippingItemsModel.data!.totalCashFormated!.split(" ")[0]} ",
                          style: context.textTheme.subtitle1?.mr.copyWith(
                              fontSize: 13,
                              color: const Color(0xff5D5C5D),
                              letterSpacing: 0.18,
                              height: 1.33),
                        ),
                        Text(
                          "${getCartShippingItemsModel.data!.totalCashFormated!.split(" ")[1]}",
                          style: context.textTheme.subtitle1?.la.copyWith(
                              fontSize: 13,
                              color: const Color(0xff8D8D8D),
                              letterSpacing: 0.18,
                              height: 1.33),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 50.h,
              color: Color(0xffF4F4F4),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.center,
              color: Color(0xffFEFEFE),
              width: 1.sw - 20,
              height: 700.h,
              child: Column(
                children: [
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      margin: EdgeInsets.only(top: 10, bottom: 0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Color(0xffF8F8F8)),
                      height: 50.h,
                      child: Row(
                        children: [
                          Container(
                            width: 93,
                            height: 15,
                            child: SvgPicture.asset(
                              AppAssets.mangoSvg,
                              fit: BoxFit.cover,
                              color: Color(
                                0xff1A171B,
                              ),
                            ),
                          ),
                          Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(AppAssets.countItemSvg),
                              Text("  ${length + 1} ",
                                  style: context.textTheme.subtitle1?.mr
                                      .copyWith(
                                          fontSize: 13,
                                          color: const Color(0xff5D5C5D),
                                          letterSpacing: 0.18,
                                          height: 1.33)),
                              Text(
                                "item ",
                                style: context.textTheme.subtitle1?.la.copyWith(
                                    fontSize: 13,
                                    color: const Color(0xff8D8D8D),
                                    letterSpacing: 0.18,
                                    height: 1.33),
                              ),
                              Text(
                                "${getCartShippingItemsModel.data!.totalCashFormated!.split(" ")[0]} ",
                                style: context.textTheme.subtitle1?.mr.copyWith(
                                    fontSize: 13,
                                    color: const Color(0xff5D5C5D),
                                    letterSpacing: 0.18,
                                    height: 1.33),
                              ),
                              Text(
                                "${getCartShippingItemsModel.data!.totalCashFormated!.split(" ")[1]}",
                                style: context.textTheme.subtitle1?.la.copyWith(
                                    fontSize: 13,
                                    color: const Color(0xff8D8D8D),
                                    letterSpacing: 0.18,
                                    height: 1.33),
                              ),
                            ],
                          ),
                        ],
                      )),
                  Column(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(top: 15),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Color(0xffFEFEFE),
                            boxShadow: [
                              BoxShadow(
                                  offset: Offset(0, 5),
                                  spreadRadius: 15,
                                  color: Color(0xffF3F3F3),
                                  blurRadius: 15)
                            ]),
                        width: 1.sw,
                        height: 152,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.only(top: 0),
                          itemCount: length + 1,
                          itemBuilder: (context, indexs) {
                            return Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15)),
                                  margin: EdgeInsets.symmetric(horizontal: 2),
                                  child: ProductDetailsImageWidget(
                                    withBackGroundShadow: false,
                                    withInnerShadow: false,
                                    width: 97.w,
                                    height: 142,
                                    imageUrl: getCartShippingItemsModel
                                        .data!.cart![indexs].thumbnail,
                                    radius: 15,
                                    imageFit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                        color: Color(0xffFEFEFE),
                                        border: Border.all(
                                            width: 0.5,
                                            color: Color(0xff8D8D8D)),
                                        borderRadius:
                                            BorderRadiusDirectional.circular(
                                                15)),
                                    child: Text(
                                      "${indexs + 1}",
                                      style: context.textTheme.subtitle1?.ra
                                          .copyWith(
                                        decorationColor: Color(0xff8D8D8D),
                                        fontSize: 14,
                                        color: Color(0xff8D8D8D),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  top: 3,
                                  left: 5,
                                ),
                                Positioned(
                                  child: Container(
                                    margin: EdgeInsets.all(2),
                                    alignment: Alignment.center,
                                    width: 97.w,
                                    height: 45,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        color: Color.fromRGBO(0, 0, 0, 0.5),
                                        borderRadius: BorderRadius.only(
                                            bottomRight: Radius.circular(15),
                                            bottomLeft: Radius.circular(15))),
                                    child: Text(
                                      "${!getCartShippingItemsModel.data!.cart![indexs].variations.isNullOrEmpty ? getCartShippingItemsModel.data!.cart![indexs].variations![0].size ?? "" : ""} \n ${getCartShippingItemsModel.data!.cart![indexs].offerPriceFormatted!.split(" ")[0]} ${getCartShippingItemsModel.data!.cart![indexs].offerPriceFormatted!.split(" ")[1]}",
                                      style: context.textTheme.subtitle1?.ra
                                          .copyWith(
                                        decorationColor: Color(0xffFEFEFE),
                                        fontSize: 12,
                                        color: Color(0xffFEFEFE),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  top: 95,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(
                            top: 10,
                          ),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Color(0xffFEFEFE),
                              boxShadow: [
                                BoxShadow(
                                    offset: Offset(0, 5),
                                    spreadRadius: 15,
                                    color: Color(0xffF3F3F3),
                                    blurRadius: 15)
                              ]),
                          width: 410.w,
                          height: 216,
                          alignment: Alignment.center,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.only(top: 0),
                              itemCount: length + 1,
                              itemBuilder: (context, indexs) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Stack(children: [
                                      Container(
                                        alignment: Alignment.center,
                                        padding:
                                            EdgeInsets.only(left: 2, right: 2),
                                        child: ProductDetailsImageWidget(
                                          withBackGroundShadow: false,
                                          withInnerShadow: false,
                                          width: 97.w,
                                          height: 142,
                                          imageUrl: getCartShippingItemsModel
                                              .data!.cart![indexs].thumbnail,
                                          radius: 15,
                                          imageFit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        child: Container(
                                          alignment: Alignment.center,
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                              color: Color(0xffFEFEFE),
                                              border: Border.all(
                                                  width: 0.5,
                                                  color: Color(0xff8D8D8D)),
                                              borderRadius:
                                                  BorderRadiusDirectional
                                                      .circular(20)),
                                          child: Text(
                                            "${indexs + 1}",
                                            style: context
                                                .textTheme.subtitle1?.ra
                                                .copyWith(
                                              decorationColor:
                                                  Color(0xff8D8D8D),
                                              fontSize: 14,
                                              color: Color(0xff8D8D8D),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        top: 3,
                                        left: 5,
                                      ),
                                    ]),
                                    Container(
                                      alignment: Alignment.center,
                                      width: 97.w,
                                      height: 45,
                                      child: Text(
                                        "${!getCartShippingItemsModel.data!.cart![indexs].variations.isNullOrEmpty ? getCartShippingItemsModel.data!.cart![indexs].variations![0].size ?? "" : ""} \n ${getCartShippingItemsModel.data!.cart![indexs].offerPriceFormatted!.split(" ")[0]} ${getCartShippingItemsModel.data!.cart![indexs].offerPriceFormatted!.split(" ")[1]}",
                                        style: context.textTheme.subtitle1?.ra
                                            .copyWith(
                                          decorationColor: Color(0xff505050),
                                          fontSize: 12,
                                          color: Color(0xff505050),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                );
                              }))
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
