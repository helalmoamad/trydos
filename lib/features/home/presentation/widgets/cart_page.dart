import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/helper/helper_functions.dart';

import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_event.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/features/home/presentation/pages/home_page.dart';
import 'package:trydos/features/home/presentation/pages/product_details_page.dart';
import 'package:trydos/features/home/presentation/widgets/cart_page2.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/product_details_image_widget.dart';
import 'package:trydos/features/story/presentation/widget/try_again.dart';
import 'package:trydos/routes/router.dart';

class CartPage extends StatefulWidget {
  State<CartPage> createState() => _CartPageState();

  const CartPage();
}

class _CartPageState extends State<CartPage> {
  late HomeBloc homeBloc;
  late AppBloc appBloc;
  @override
  void initState() {
    appBloc = BlocProvider.of<AppBloc>(context);

    homeBloc = BlocProvider.of<HomeBloc>(context);
    homeBloc.add(GetCartItemEvent());
    homeBloc.add(GetProductFiltersEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
          body: BlocBuilder<HomeBloc, HomeState>(
        buildWhen: (previous, current) =>
            previous.getCartItemsStatus != current.getCartItemsStatus,
        builder: (context, state) {
          if (state.getCartItemsStatus == GetCartItemsStatus.failure) {
            return Center(child: TryAgainWidget(tryAgain: () {
              BlocProvider.of<HomeBloc>(context).add(GetCartItemEvent());
            }));
          }
          if (state.getCartShippingItemsModel == null &&
              state.getCartItemsStatus != GetCartItemsStatus.success) {
            return Center(
              child: TrydosLoader(),
            );
          }
          int length = state.getCartShippingItemsModel!.data!.cart!.length - 1;
          return Column(
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
                                appBloc.add(ChangeBasePage(0));
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
                          InkWell(
                              onTap: () {
                                HelperFunctions.slidingNavigation(
                                    context,
                                    CartPage2(
                                      getCartShippingItemsModel:
                                          state.getCartShippingItemsModel!,
                                    ));
                              },
                              child: SvgPicture.asset(AppAssets.countItemSvg)),
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
                            "${state.getCartShippingItemsModel!.data!.totalCashFormated!.split(" ")[0]} ",
                            style: context.textTheme.subtitle1?.mr.copyWith(
                                fontSize: 13,
                                color: const Color(0xff5D5C5D),
                                letterSpacing: 0.18,
                                height: 1.33),
                          ),
                          Text(
                            "${state.getCartShippingItemsModel!.data!.totalCashFormated!.split(" ")[1]} ",
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
                color: Color.fromARGB(255, 255, 255, 255),
                width: 1.sw - 20,
                child: Column(
                  children: [
                    Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        margin: EdgeInsets.only(top: 10, bottom: 0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Color(0xffF8F8F8)),
                        height: 48.h,
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
                                  style: context.textTheme.subtitle1?.la
                                      .copyWith(
                                          fontSize: 13,
                                          color: const Color(0xff8D8D8D),
                                          letterSpacing: 0.18,
                                          height: 1.33),
                                ),
                                Text(
                                  "${state.getCartShippingItemsModel!.data!.totalCashFormated!.split(" ")[0]} ",
                                  style: context.textTheme.subtitle1?.mr
                                      .copyWith(
                                          fontSize: 13,
                                          color: const Color(0xff5D5C5D),
                                          letterSpacing: 0.18,
                                          height: 1.33),
                                ),
                                Text(
                                  "${state.getCartShippingItemsModel!.data!.totalCashFormated!.split(" ")[1]}",
                                  style: context.textTheme.subtitle1?.la
                                      .copyWith(
                                          fontSize: 13,
                                          color: const Color(0xff8D8D8D),
                                          letterSpacing: 0.18,
                                          height: 1.33),
                                ),
                              ],
                            ),
                          ],
                        )),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Color(0xffFFF4B5),
                      ),
                      margin: EdgeInsets.only(top: 10),
                      width: 420.w,
                      height: 580.h,
                      child: ListView.builder(
                        padding: EdgeInsets.only(top: 0),
                        itemCount:
                            state.getCartShippingItemsModel!.data!.cart!.length,
                        itemBuilder: (context, index) {
                          int quantity = state.getCartShippingItemsModel!.data!
                              .cart![index].quantity!;

                          return InkWell(
                            onTap: () {
                              HelperFunctions.slidingNavigation(
                                  context,
                                  ProductDetailsPage(
                                    productItem: state.productITemForCart[state
                                        .getCartShippingItemsModel!
                                        .data!
                                        .cart![index]
                                        .productId
                                        .toString()]!,
                                  ));
                            },
                            child: Container(
                              margin: EdgeInsets.only(
                                  bottom: index == length //length
                                      ? 30
                                      : 0),
                              width: 1.sw,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(index ==
                                        state.getCartShippingItemsModel!.data!
                                            .cart!.length //length
                                    ? 15
                                    : 0),
                                boxShadow: [
                                  BoxShadow(
                                      offset:
                                          Offset(0, index == length ? -10 : 10),
                                      blurRadius: index == length ? 0 : 5,
                                      color: Color(0xffF3F3F3),
                                      spreadRadius: index == length ? 0 : 10),
                                ],
                              ),
                              child: Container(
                                margin: EdgeInsets.only(
                                  bottom: 10.h,
                                ),
                                width: 400.w,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                height: 161.h,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          color: Color(0x707070),
                                        ),
                                        width: 110.w,
                                        height: 161.h,
                                        child: ProductDetailsImageWidget(
                                          withBackGroundShadow: false,
                                          withInnerShadow: false,
                                          imageFit: BoxFit.cover,
                                          imageUrl: state
                                              .getCartShippingItemsModel!
                                              .data!
                                              .cart![index]
                                              .thumbnail,
                                          width: 110.w,
                                          height: 161.h,
                                          radius: 15,
                                        ),
                                      ),
                                      left: 0,
                                    ),
                                    Positioned(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(top: 10),
                                            alignment: Alignment.centerLeft,
                                            width: 50,
                                            height: 10,
                                            child: state
                                                        .getCartShippingItemsModel!
                                                        .data!
                                                        .cart![index]
                                                        .brand !=
                                                    null
                                                ? SvgPicture.network(
                                                    state
                                                        .getCartShippingItemsModel!
                                                        .data!
                                                        .cart![index]
                                                        .brand!
                                                        .image!,
                                                    fit: BoxFit.contain,
                                                    color: Color(
                                                      0xff1A171B,
                                                    ),
                                                  )
                                                : SizedBox.shrink(),
                                          ),
                                          SizedBox(
                                            height: 2,
                                          ),
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            width: 200.w,
                                            height: 16,
                                            child: Text(
                                                state
                                                        .getCartShippingItemsModel!
                                                        .data!
                                                        .cart![index]
                                                        .name ??
                                                    "",
                                                style: context
                                                    .textTheme.subtitle1?.ra
                                                    .copyWith(
                                                        fontSize: 12,
                                                        color: const Color(
                                                            0xff505050),
                                                        letterSpacing: 0.18,
                                                        height: 1.33)),
                                          ),
                                          SizedBox(
                                            height: 2,
                                          ),
                                          Container(
                                              alignment: Alignment.centerLeft,
                                              width: 200,
                                              height: 16,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  SvgPicture.asset(
                                                    color: Color(0xff8D8D8D),
                                                    AppAssets.dressSvg,
                                                    height: 12,
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    " Composed Of ${state.getCartShippingItemsModel!.data!.cart![index].quantity} Piece",
                                                    style: context
                                                        .textTheme.subtitle1?.la
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight.w100,
                                                            fontSize: 12,
                                                            color: const Color(
                                                                0xff707070),
                                                            letterSpacing: 0.18,
                                                            height: 1.33),
                                                  ),
                                                ],
                                              )),
                                          Container(
                                            margin: EdgeInsets.only(top: 5),
                                            alignment: Alignment.centerLeft,
                                            width: 200,
                                            height: 15,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                SvgPicture.asset(
                                                  AppAssets.colorPickerSvg,
                                                  height: 12,
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  "Color, ",
                                                  style: context
                                                      .textTheme.subtitle1?.la
                                                      .copyWith(
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontSize: 12,
                                                          color: const Color(
                                                              0xff505050),
                                                          letterSpacing: 0.18,
                                                          height: 1.33),
                                                ),
                                                Text(
                                                  !state
                                                          .getCartShippingItemsModel!
                                                          .data!
                                                          .cart![index]
                                                          .variations
                                                          .isNullOrEmpty
                                                      ? state
                                                              .getCartShippingItemsModel!
                                                              .data!
                                                              .cart![index]
                                                              .variations![0]
                                                              .color ??
                                                          ""
                                                      : "",
                                                  style: context
                                                      .textTheme.subtitle1?.ra
                                                      .copyWith(
                                                    fontSize: 13,
                                                    color: const Color(
                                                        (0xff505050)),
                                                    letterSpacing: 0.18,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(top: 5),
                                            alignment: Alignment.centerLeft,
                                            width: 200,
                                            height: 15,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                SvgPicture.asset(
                                                  AppAssets.sizeIconSvg,
                                                  height: 12,
                                                  color: Color(0xff48C8A8),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  "Size, ",
                                                  style: context
                                                      .textTheme.subtitle1?.la
                                                      .copyWith(
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontSize: 12,
                                                          color: const Color(
                                                              0xff505050),
                                                          letterSpacing: 0.18,
                                                          height: 1.33),
                                                ),
                                                Text(
                                                  !state
                                                          .getCartShippingItemsModel!
                                                          .data!
                                                          .cart![index]
                                                          .variations
                                                          .isNullOrEmpty
                                                      ? state
                                                              .getCartShippingItemsModel!
                                                              .data!
                                                              .cart![index]
                                                              .variations![0]
                                                              .size ??
                                                          ""
                                                      : "",
                                                  style: context
                                                      .textTheme.subtitle1?.ra
                                                      .copyWith(
                                                    fontSize: 13,
                                                    color: const Color(
                                                        (0xff505050)),
                                                    letterSpacing: 0.18,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      left: 130,
                                    ),
                                    Positioned(
                                      child: Row(
                                        children: [
                                          Text(
                                            (state
                                                        .getCartShippingItemsModel!
                                                        .data!
                                                        .cart![index]
                                                        .priceNum! *
                                                    quantity)
                                                .toString(),
                                            style: context
                                                .textTheme.subtitle1?.ra
                                                .copyWith(
                                                    decorationColor:
                                                        Color(0xffC4C2C2),
                                                    fontSize: 18,
                                                    color: Color(0xffC4C2C2),
                                                    decoration: TextDecoration
                                                        .lineThrough),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                              "${state.getCartShippingItemsModel!.data!.cart![index].offerPrice! * quantity}",
                                              style: context
                                                  .textTheme.subtitle1?.br
                                                  .copyWith(
                                                decorationColor:
                                                    Color(0xff505050),
                                                fontSize: 18,
                                                color: Color(0xff505050),
                                              )),
                                        ],
                                      ),
                                      bottom: 25,
                                      right: 30,
                                    ),
                                    Positioned(
                                      child: Text(
                                        state.getCartShippingItemsModel!.data!
                                            .cart![index].offerPriceFormatted!
                                            .split(" ")[1],
                                        style: context.textTheme.subtitle1?.ra
                                            .copyWith(
                                          decorationColor: Color(0xffc4c2c2),
                                          fontSize: 9,
                                          color: Color(0xffc4c2c2),
                                        ),
                                      ),
                                      bottom: 28,
                                      right: 20,
                                    ),
                                    Positioned(
                                      child: Container(
                                        alignment: Alignment.center,
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 0.5,
                                                color: Color(0xff8D8D8D)),
                                            borderRadius:
                                                BorderRadiusDirectional
                                                    .circular(20)),
                                        child: Text(
                                          "${index + 1}",
                                          style: context.textTheme.subtitle1?.ra
                                              .copyWith(
                                            decorationColor: Color(0xff8D8D8D),
                                            fontSize: 14,
                                            color: Color(0xff8D8D8D),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      top: 5,
                                      right: 5,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        },
      )),
    );
  }
}
