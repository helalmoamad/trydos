import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/app_elvated_button.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/app/svg_network_widget.dart';
import 'package:trydos/features/home/data/models/get_cart_item_model.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/features/home/presentation/pages/product_details_page.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/product_details_image_widget.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/my_gallery3d_widget.dart';
import 'package:trydos/features/story/presentation/widget/try_again.dart';

import '../../../../service/language_service.dart';

class CartPage2 extends StatelessWidget {
  final GetCartShippingItemsModel getCartShippingItemsModel;

  const CartPage2({Key? key, required this.getCartShippingItemsModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> changeCartCollections = ValueNotifier(false);

    int indexes = 0;
    List<String> groupCartkeys = [];
    int? tapIndex;
    List<String> visibleCollectionGroups = [];
    TextEditingController quantityController = TextEditingController();
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        body: BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (previous, current) =>
          previous.getCartItemsStatus != current.getCartItemsStatus ||
              previous.cartCollection!.values !=
                  current.cartCollection!.values,
          builder: (context, state) {
            double totlaPrice = 0;
            String? priceSymbol;
            state.cartCollection!.values.toList().forEach((element) {
              priceSymbol =
              (element.first.priceFormatted?.split(' ') ?? ['\$', '\$'])[1];
              element.forEach((element) {
                totlaPrice =
                    totlaPrice + element.offerPrice! * element.quantity!;
              });
            });
            if (state.getCartItemsStatus == GetCartItemsStatus.failure &&
                (state.cartCollection == null ||
                    state.cartCollection!.isEmpty)) {
              return Center(child: TryAgainWidget(tryAgain: () {
                BlocProvider.of<HomeBloc>(context).add(GetCartItemEvent());
              }));
            }
            if (state.cartCollection == null || state.cartCollection!.isEmpty) {
              return Center(
                child: Container(
                  child: MyTextWidget("no item in cart"),
                ),
              );
            }
            if (state.getCartShippingItemsModel == null &&
                state.getCartItemsStatus != GetCartItemsStatus.success) {
              return Center(
                child: TrydosLoader(),
              );
            }
            groupCartkeys = state.cartCollection!.keys.toList();
            visibleCollectionGroups = state.cartCollection!.keys.toList();

            return ValueListenableBuilder<bool>(
                valueListenable: changeCartCollections,
                builder: (context, visible, _child) {
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
                                      style: context.textTheme.bodyMedium?.ra
                                          .copyWith(
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
                                  Text(" ${state.cartCollection!.length} ",
                                      style: context.textTheme.bodyMedium?.mr
                                          .copyWith(
                                          fontSize: 13,
                                          color: const Color(0xff5D5C5D),
                                          letterSpacing: 0.18,
                                          height: 1.33)),
                                  Text(
                                    "item ",
                                    style: context.textTheme.bodyMedium?.la
                                        .copyWith(
                                        fontSize: 13,
                                        color: const Color(0xff8D8D8D),
                                        letterSpacing: 0.18,
                                        height: 1.33),
                                  ),
                                  Text(
                                    "${totlaPrice.toStringAsFixed(
                                        state.startingSetting
                                            ?.decimalPointSetting ?? 2)} ",
                                    style: context.textTheme.bodyMedium?.mr
                                        .copyWith(
                                        fontSize: 13,
                                        color: const Color(0xff5D5C5D),
                                        letterSpacing: 0.18,
                                        height: 1.33),
                                  ),
                                  Text(
                                    priceSymbol ?? '\$',
                                    style: context.textTheme.bodyMedium?.la
                                        .copyWith(
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
                              height: 600,
                              child: ListView.builder(
                                padding: EdgeInsets.symmetric(vertical: 0),
                                shrinkWrap: false,
                                itemCount: state.cartCollection!.length,
                                itemBuilder: (context, index) {
                                  double price = 0;
                                  state.cartCollection!.values
                                      .toList()[index]
                                      .forEach((element) {
                                    price = price +
                                        element.offerPrice! * element.quantity!;
                                  });
                                  return Column(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          tapIndex = index;
                                          if (visibleCollectionGroups.any(
                                                  (element) =>
                                              element ==
                                                  groupCartkeys[tapIndex!])) {
                                            visibleCollectionGroups.removeWhere(
                                                    (element) =>
                                                element ==
                                                    groupCartkeys[tapIndex!]);
                                          } else {
                                            visibleCollectionGroups
                                                .add(groupCartkeys[tapIndex!]);
                                          }

                                          changeCartCollections.value =
                                          !changeCartCollections.value;
                                        },
                                        child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20),
                                            margin: EdgeInsets.only(
                                                top: 10, bottom: 0),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.circular(20),
                                                color: Color(0xffF8F8F8)),
                                            height: 48.h,
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 15,
                                                  child: SvgNetworkWidget(
                                                    svgUrl: state
                                                        .cartCollection!
                                                        .values
                                                        .toList()[index][0]
                                                        .boutique!
                                                        .icon!
                                                        .filePath ??
                                                        "",
                                                    height: 30,
                                                  ),
                                                ),
                                                Spacer(),
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                                  children: [
                                                    SvgPicture.asset(
                                                        AppAssets.countItemSvg),
                                                    Text(
                                                        "  ${state
                                                            .cartCollection!
                                                            .values
                                                            .toList()[index]
                                                            .length} ",
                                                        style: context.textTheme
                                                            .bodyMedium?.mr
                                                            .copyWith(
                                                            fontSize: 13,
                                                            color: const Color(
                                                                0xff5D5C5D),
                                                            letterSpacing:
                                                            0.18,
                                                            height: 1.33)),
                                                    Text(
                                                      "item ",
                                                      style: context.textTheme
                                                          .bodyMedium?.la
                                                          .copyWith(
                                                          fontSize: 13,
                                                          color: const Color(
                                                              0xff8D8D8D),
                                                          letterSpacing:
                                                          0.18,
                                                          height: 1.33),
                                                    ),
                                                    Text(
                                                      " ${price.toStringAsFixed(
                                                          state.startingSetting
                                                              ?.decimalPointSetting ??
                                                              2)}",
                                                      style: context.textTheme
                                                          .bodyMedium?.mr
                                                          .copyWith(
                                                          fontSize: 13,
                                                          color: const Color(
                                                              0xff5D5C5D),
                                                          letterSpacing:
                                                          0.18,
                                                          height: 1.33),
                                                    ),
                                                    Text(
                                                      priceSymbol ?? '\$',
                                                      style: context.textTheme
                                                          .bodyMedium?.la
                                                          .copyWith(
                                                          fontSize: 13,
                                                          color: const Color(
                                                              0xff8D8D8D),
                                                          letterSpacing:
                                                          0.18,
                                                          height: 1.33),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            )),
                                      ),
                                      Column(
                                        children: [
                                          visibleCollectionGroups.any(
                                                  (element) =>
                                              element ==
                                                  groupCartkeys[index])
                                              ? Container(
                                            alignment: Alignment.center,
                                            margin:
                                            EdgeInsets.only(top: 15),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    15),
                                                color: Color(0xffFEFEFE),
                                                boxShadow: [
                                                  BoxShadow(
                                                      offset:
                                                      Offset(0, 5),
                                                      spreadRadius: 15,
                                                      color: Color(
                                                          0xffF3F3F3),
                                                      blurRadius: 15)
                                                ]),
                                            width: 1.sw,
                                            height: 152,
                                            child: ListView.builder(
                                              scrollDirection:
                                              Axis.horizontal,
                                              padding:
                                              EdgeInsets.only(top: 0),
                                              itemCount: state
                                                  .cartCollection![
                                              groupCartkeys[
                                              index]]!
                                                  .length,
                                              itemBuilder:
                                                  (context, indexes) {
                                                return InkWell(
                                                  onDoubleTap: () {
                                                    showDialog(
                                                        context: context,
                                                        builder:
                                                            (BuildContext
                                                        context) {
                                                          return AlertDialog(
                                                            title: MyTextWidget(
                                                                "Change Quatity In Cart",
                                                                textDirection:
                                                                TextDirection
                                                                    .ltr),
                                                            actions: <Widget>[
                                                              SingleChildScrollView(
                                                                child:
                                                                Column(
                                                                  children: [
                                                                    TextFormField(
                                                                      inputFormatters: [
                                                                        FilteringTextInputFormatter
                                                                            .digitsOnly
                                                                      ],
                                                                      textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                      controller:
                                                                      quantityController,
                                                                      enabled:
                                                                      true,
                                                                      keyboardType:
                                                                      TextInputType
                                                                          .number,
                                                                    ),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                      children: [
                                                                        AppElevatedButton(
                                                                          onPressed: () {
                                                                            BlocProvider
                                                                                .of<
                                                                                HomeBloc>(
                                                                                context)
                                                                                .add(
                                                                                UpdateItemInCartEvent(
                                                                                    countOfPieces: state
                                                                                        .cartCollection![groupCartkeys[index]]![indexes]
                                                                                        .countOfPieces,
                                                                                    image: state
                                                                                        .cartCollection![groupCartkeys[index]]![indexes]
                                                                                        .image ??
                                                                                        "",
                                                                                    currentSize: !state
                                                                                        .cartCollection![groupCartkeys[index]]![indexes]
                                                                                        .variations
                                                                                        .isNullOrEmpty
                                                                                        ? state
                                                                                        .cartCollection![groupCartkeys[index]]![indexes]
                                                                                        .variations![0]
                                                                                        .size ??
                                                                                        ""
                                                                                        : "",
                                                                                    colorName: !state
                                                                                        .cartCollection![groupCartkeys[index]]![indexes]
                                                                                        .variations
                                                                                        .isNullOrEmpty
                                                                                        ? state
                                                                                        .cartCollection![groupCartkeys[index]]![indexes]
                                                                                        .variations![0]
                                                                                        .color ??
                                                                                        ""
                                                                                        : "",
                                                                                    productId: state
                                                                                        .cartCollection![groupCartkeys[index]]![indexes]
                                                                                        .productId
                                                                                        .toString(),
                                                                                    quantity: int
                                                                                        .tryParse(
                                                                                        quantityController
                                                                                            .text)!,
                                                                                    cartId: state
                                                                                        .cartCollection![groupCartkeys[index]]![indexes]
                                                                                        .id
                                                                                        .toString(),
                                                                                    boutiqueId: state
                                                                                        .cartCollection![groupCartkeys[index]]![indexes]
                                                                                        .boutique!
                                                                                        .id
                                                                                        .toString()));
                                                                            Navigator
                                                                                .pop(
                                                                                context);
                                                                          },
                                                                          text: "Yes",
                                                                        ),
                                                                        AppElevatedButton(
                                                                          onPressed: () {
                                                                            Navigator
                                                                                .pop(
                                                                                context);
                                                                          },
                                                                          text: 'Not Now',
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        });
                                                  },
                                                  onLongPress: () {
                                                    showDialog(
                                                        context: context,
                                                        builder:
                                                            (BuildContext
                                                        context) {
                                                          return AlertDialog(
                                                            title: MyTextWidget(
                                                                "Delete Item From Cart",
                                                                textDirection:
                                                                TextDirection
                                                                    .ltr),
                                                            actions: <Widget>[
                                                              Row(
                                                                mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                                children: [
                                                                  AppElevatedButton(
                                                                    onPressed:
                                                                        () {
                                                                      BlocProvider
                                                                          .of<
                                                                          HomeBloc>(
                                                                          context)
                                                                          .add(
                                                                          RemoveItemFormCartEvent(
                                                                              countOfPieces: state
                                                                                  .cartCollection![groupCartkeys[index]]![indexes]
                                                                                  .countOfPieces,
                                                                              image: state
                                                                                  .cartCollection![groupCartkeys[index]]![indexes]
                                                                                  .image ??
                                                                                  '',
                                                                              currentSize: !state
                                                                                  .cartCollection![groupCartkeys[index]]![indexes]
                                                                                  .variations
                                                                                  .isNullOrEmpty
                                                                                  ? state
                                                                                  .cartCollection![groupCartkeys[index]]![indexes]
                                                                                  .variations![0]
                                                                                  .size ??
                                                                                  ""
                                                                                  : "",
                                                                              ColoName: !state
                                                                                  .cartCollection![groupCartkeys[index]]![indexes]
                                                                                  .variations
                                                                                  .isNullOrEmpty
                                                                                  ? state
                                                                                  .cartCollection![groupCartkeys[index]]![indexes]
                                                                                  .variations![0]
                                                                                  .color ??
                                                                                  ""
                                                                                  : "",
                                                                              productId: state
                                                                                  .cartCollection![groupCartkeys[index]]![indexes]
                                                                                  .productId
                                                                                  .toString(),
                                                                              itemId: state
                                                                                  .cartCollection![groupCartkeys[index]]![indexes]
                                                                                  .id
                                                                                  .toString(),
                                                                              boutiqueId: state
                                                                                  .cartCollection![groupCartkeys[index]]![indexes]
                                                                                  .boutique!
                                                                                  .id
                                                                                  .toString()));
                                                                      Navigator
                                                                          .pop(
                                                                          context);
                                                                    },
                                                                    text:
                                                                    "Yes",
                                                                  ),
                                                                  AppElevatedButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator
                                                                          .pop(
                                                                          context);
                                                                    },
                                                                    text:
                                                                    'Not Now',
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          );
                                                        });
                                                  },
                                                  onTap: () {
                                                    HelperFunctions
                                                        .slidingNavigation(
                                                        context,
                                                        ProductDetailsPage(
                                                          productItem: state
                                                              .productITemForCart![state
                                                              .cartCollection![
                                                          groupCartkeys[index]]![
                                                          indexes]
                                                              .productId
                                                              .toString()]!,
                                                        ));
                                                  },
                                                  child: Stack(
                                                    children: [
                                                      Container(
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                15)),
                                                        margin: EdgeInsets
                                                            .symmetric(
                                                            horizontal:
                                                            2),
                                                        child:
                                                        ProductDetailsImageWidget(
                                                          withBackGroundShadow:
                                                          false,
                                                          withInnerShadow:
                                                          false,
                                                          width: 97.w,
                                                          height: 142,
                                                          imageUrl: state
                                                              .cartCollection![
                                                          groupCartkeys[
                                                          index]]![
                                                          indexes]
                                                              .image,
                                                          radius: 15,
                                                          imageFit: BoxFit
                                                              .cover,
                                                        ),
                                                      ),
                                                      Positioned(
                                                        child: Container(
                                                          alignment:
                                                          Alignment
                                                              .center,
                                                          width: 28,
                                                          height: 28,
                                                          decoration: BoxDecoration(
                                                              color: Color(
                                                                  0xffFEFEFE),
                                                              border: Border
                                                                  .all(
                                                                  width:
                                                                  0.5,
                                                                  color: Color(
                                                                      0xff8D8D8D)),
                                                              borderRadius:
                                                              BorderRadiusDirectional
                                                                  .circular(
                                                                  15)),
                                                          child: Text(
                                                            "${state
                                                                .cartCollection![groupCartkeys[index]]![indexes]
                                                                .quantity}",
                                                            style: context
                                                                .textTheme
                                                                .bodyMedium
                                                                ?.ra
                                                                .copyWith(
                                                              decorationColor:
                                                              Color(
                                                                  0xff8D8D8D),
                                                              fontSize:
                                                              14,
                                                              color: Color(
                                                                  0xff8D8D8D),
                                                            ),
                                                            textAlign:
                                                            TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                        top: 3,
                                                        left: 5,
                                                      ),
                                                      Positioned(
                                                        child: Container(
                                                          margin:
                                                          EdgeInsets
                                                              .all(2),
                                                          alignment:
                                                          Alignment
                                                              .center,
                                                          width: 97.w,
                                                          height: 45,
                                                          decoration: BoxDecoration(
                                                              shape: BoxShape
                                                                  .rectangle,
                                                              color: Color
                                                                  .fromRGBO(
                                                                  0,
                                                                  0,
                                                                  0,
                                                                  0.5),
                                                              borderRadius: BorderRadius
                                                                  .only(
                                                                  bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                      15),
                                                                  bottomLeft:
                                                                  Radius
                                                                      .circular(
                                                                      15))),
                                                          child: Text(
                                                            '''${!state
                                                                .cartCollection![groupCartkeys[index]]![indexes]
                                                                .variations
                                                                .isNullOrEmpty
                                                                ? state
                                                                .cartCollection![groupCartkeys[index]]![indexes]
                                                                .variations![0]
                                                                .size ?? ""
                                                                : ""} \n '''
                                                                '''${(state
                                                                .cartCollection![groupCartkeys[index]]![indexes]
                                                                .offerPrice! *
                                                                state
                                                                    .cartCollection![groupCartkeys[index]]![indexes]
                                                                    .quantity!)} '''
                                                                '''${priceSymbol ??
                                                                '\$'}''',
                                                            style: context
                                                                .textTheme
                                                                .bodyMedium
                                                                ?.ra
                                                                .copyWith(
                                                              decorationColor:
                                                              Color(
                                                                  0xffFEFEFE),
                                                              fontSize:
                                                              12,
                                                              color: Color(
                                                                  0xffFEFEFE),
                                                            ),
                                                            textAlign:
                                                            TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                        top: 95,
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          )
                                              : SizedBox.shrink(),
                                          visibleCollectionGroups.any(
                                                  (element) =>
                                              element ==
                                                  groupCartkeys[index])
                                              ? Container(
                                              margin: EdgeInsets.only(
                                                top: 10,
                                              ),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      15),
                                                  color: Color(0xffFEFEFE),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        offset:
                                                        Offset(0, 5),
                                                        spreadRadius: 15,
                                                        color: Color(
                                                            0xffF3F3F3),
                                                        blurRadius: 15)
                                                  ]),
                                              width: 410.w,
                                              height: 216,
                                              alignment: Alignment.center,
                                              child: ListView.builder(
                                                  scrollDirection:
                                                  Axis.horizontal,
                                                  padding: EdgeInsets.only(
                                                      top: 0),
                                                  itemCount: state
                                                      .cartCollection![
                                                  groupCartkeys[
                                                  index]]!
                                                      .length,
                                                  itemBuilder:
                                                      (context, indexs) {
                                                    return Column(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .center,
                                                      children: [
                                                        InkWell(
                                                          onDoubleTap: () {
                                                            showDialog(
                                                                context:
                                                                context,
                                                                builder:
                                                                    (
                                                                    BuildContext
                                                                    context) {
                                                                  return AlertDialog(
                                                                    title: MyTextWidget(
                                                                        "Change Quatity In Cart",
                                                                        textDirection:
                                                                        TextDirection
                                                                            .ltr),
                                                                    actions: <
                                                                        Widget>[
                                                                      SingleChildScrollView(
                                                                        child:
                                                                        Column(
                                                                          children: [
                                                                            TextFormField(
                                                                              inputFormatters: [
                                                                                FilteringTextInputFormatter
                                                                                    .digitsOnly
                                                                              ],
                                                                              textAlign: TextAlign
                                                                                  .center,
                                                                              controller: quantityController,
                                                                              enabled: true,
                                                                              keyboardType: TextInputType
                                                                                  .number,
                                                                            ),
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment
                                                                                  .spaceBetween,
                                                                              children: [
                                                                                AppElevatedButton(
                                                                                  onPressed: () {
                                                                                    BlocProvider
                                                                                        .of<
                                                                                        HomeBloc>(
                                                                                        context)
                                                                                        .add(
                                                                                        UpdateItemInCartEvent(
                                                                                            countOfPieces: state
                                                                                                .cartCollection![groupCartkeys[index]]![indexes]
                                                                                                .countOfPieces,
                                                                                            image: state
                                                                                                .cartCollection![groupCartkeys[index]]![indexes]
                                                                                                .image ??
                                                                                                "",
                                                                                            currentSize: !state
                                                                                                .cartCollection![groupCartkeys[index]]![indexes]
                                                                                                .variations
                                                                                                .isNullOrEmpty
                                                                                                ? state
                                                                                                .cartCollection![groupCartkeys[index]]![indexes]
                                                                                                .variations![0]
                                                                                                .size ??
                                                                                                ""
                                                                                                : "",
                                                                                            colorName: !state
                                                                                                .cartCollection![groupCartkeys[index]]![indexes]
                                                                                                .variations
                                                                                                .isNullOrEmpty
                                                                                                ? state
                                                                                                .cartCollection![groupCartkeys[index]]![indexes]
                                                                                                .variations![0]
                                                                                                .color ??
                                                                                                ""
                                                                                                : "",
                                                                                            productId: state
                                                                                                .cartCollection![groupCartkeys[index]]![indexes]
                                                                                                .productId
                                                                                                .toString(),
                                                                                            quantity: int
                                                                                                .tryParse(
                                                                                                quantityController
                                                                                                    .text)!,
                                                                                            cartId: state
                                                                                                .cartCollection![groupCartkeys[index]]![indexs]
                                                                                                .id
                                                                                                .toString(),
                                                                                            boutiqueId: state
                                                                                                .cartCollection![groupCartkeys[index]]![indexes]
                                                                                                .boutique!
                                                                                                .id
                                                                                                .toString()));
                                                                                    Navigator
                                                                                        .pop(
                                                                                        context);
                                                                                  },
                                                                                  text: "Yes",
                                                                                ),
                                                                                AppElevatedButton(
                                                                                  onPressed: () {
                                                                                    Navigator
                                                                                        .pop(
                                                                                        context);
                                                                                  },
                                                                                  text: 'Not Now',
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  );
                                                                });
                                                          },
                                                          onLongPress: () {
                                                            showDialog(
                                                                context:
                                                                context,
                                                                builder:
                                                                    (
                                                                    BuildContext
                                                                    context) {
                                                                  return AlertDialog(
                                                                    title: MyTextWidget(
                                                                        "Delete Item From Cart",
                                                                        textDirection:
                                                                        TextDirection
                                                                            .ltr),
                                                                    actions: <
                                                                        Widget>[
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                        children: [
                                                                          AppElevatedButton(
                                                                            onPressed: () {
                                                                              BlocProvider
                                                                                  .of<
                                                                                  HomeBloc>(
                                                                                  context)
                                                                                  .add(
                                                                                  RemoveItemFormCartEvent(
                                                                                      countOfPieces: state
                                                                                          .cartCollection![groupCartkeys[index]]![indexes]
                                                                                          .countOfPieces,
                                                                                      image: state
                                                                                          .cartCollection![groupCartkeys[index]]![indexes]
                                                                                          .image ??
                                                                                          '',
                                                                                      currentSize: !state
                                                                                          .cartCollection![groupCartkeys[index]]![indexes]
                                                                                          .variations
                                                                                          .isNullOrEmpty
                                                                                          ? state
                                                                                          .cartCollection![groupCartkeys[index]]![indexes]
                                                                                          .variations![0]
                                                                                          .size ??
                                                                                          ""
                                                                                          : "",
                                                                                      ColoName: !state
                                                                                          .cartCollection![groupCartkeys[index]]![indexes]
                                                                                          .variations
                                                                                          .isNullOrEmpty
                                                                                          ? state
                                                                                          .cartCollection![groupCartkeys[index]]![indexes]
                                                                                          .variations![0]
                                                                                          .color ??
                                                                                          ""
                                                                                          : "",
                                                                                      productId: state
                                                                                          .cartCollection![groupCartkeys[index]]![indexes]
                                                                                          .productId
                                                                                          .toString(),
                                                                                      itemId: state
                                                                                          .cartCollection![groupCartkeys[index]]![indexes]
                                                                                          .id
                                                                                          .toString(),
                                                                                      boutiqueId: state
                                                                                          .cartCollection![groupCartkeys[index]]![indexes]
                                                                                          .boutique!
                                                                                          .id
                                                                                          .toString()));
                                                                              Navigator
                                                                                  .pop(
                                                                                  context);
                                                                            },
                                                                            text: "Yes",
                                                                          ),
                                                                          AppElevatedButton(
                                                                            onPressed: () {
                                                                              Navigator
                                                                                  .pop(
                                                                                  context);
                                                                            },
                                                                            text: 'Not Now',
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  );
                                                                });
                                                          },
                                                          onTap: () {
                                                            HelperFunctions
                                                                .slidingNavigation(
                                                                context,
                                                                ProductDetailsPage(
                                                                  productItem: state
                                                                      .productITemForCart![state
                                                                      .cartCollection![groupCartkeys[index]]![indexes]
                                                                      .productId
                                                                      .toString()]!,
                                                                ));
                                                          },
                                                          child: Stack(
                                                              children: [
                                                                Container(
                                                                  alignment:
                                                                  Alignment
                                                                      .center,
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                      left:
                                                                      2,
                                                                      right:
                                                                      2),
                                                                  child:
                                                                  ProductDetailsImageWidget(
                                                                    withBackGroundShadow:
                                                                    false,
                                                                    withInnerShadow:
                                                                    false,
                                                                    width:
                                                                    97.w,
                                                                    height:
                                                                    142,
                                                                    imageUrl: state
                                                                        .cartCollection![groupCartkeys[index]]![indexes]
                                                                        .image,
                                                                    radius:
                                                                    15,
                                                                    imageFit:
                                                                    BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                                Positioned(
                                                                  child:
                                                                  Container(
                                                                    alignment:
                                                                    Alignment
                                                                        .center,
                                                                    width:
                                                                    28,
                                                                    height:
                                                                    28,
                                                                    decoration: BoxDecoration(
                                                                        color:
                                                                        Color(
                                                                            0xffFEFEFE),
                                                                        border: Border
                                                                            .all(
                                                                            width: 0.5,
                                                                            color: Color(
                                                                                0xff8D8D8D)),
                                                                        borderRadius: BorderRadiusDirectional
                                                                            .circular(
                                                                            20)),
                                                                    child:
                                                                    Text(
                                                                      "${state
                                                                          .cartCollection![groupCartkeys[index]]![indexes]
                                                                          .quantity}",
                                                                      style: context
                                                                          .textTheme
                                                                          .bodyMedium
                                                                          ?.ra
                                                                          .copyWith(
                                                                        decorationColor:
                                                                        Color(
                                                                            0xff8D8D8D),
                                                                        fontSize:
                                                                        14,
                                                                        color:
                                                                        Color(
                                                                            0xff8D8D8D),
                                                                      ),
                                                                      textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                    ),
                                                                  ),
                                                                  top: 3,
                                                                  left: 5,
                                                                ),
                                                              ]),
                                                        ),
                                                        Container(
                                                          alignment:
                                                          Alignment
                                                              .center,
                                                          width: 97.w,
                                                          height: 45,
                                                          child: Text(
                                                            '''${!state
                                                                .cartCollection![groupCartkeys[index]]![indexes]
                                                                .variations
                                                                .isNullOrEmpty
                                                                ? state
                                                                .cartCollection![groupCartkeys[index]]![indexes]
                                                                .variations![0]
                                                                .size ?? ""
                                                                : ""} \n '''
                                                                '''${(state
                                                                .cartCollection![groupCartkeys[index]]![indexes]
                                                                .offerPrice! *
                                                                state
                                                                    .cartCollection![groupCartkeys[index]]![indexes]
                                                                    .quantity!)} '''
                                                                '''${priceSymbol ??
                                                                '\$'}''',
                                                            style: context
                                                                .textTheme
                                                                .bodyMedium
                                                                ?.ra
                                                                .copyWith(
                                                              decorationColor:
                                                              Color(
                                                                  0xff505050),
                                                              fontSize: 12,
                                                              color: Color(
                                                                  0xff505050),
                                                            ),
                                                            textAlign:
                                                            TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  }))
                                              : SizedBox.shrink()
                                        ],
                                      )
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  );
                });
          },
        ),
      ),
    );
  }
}
