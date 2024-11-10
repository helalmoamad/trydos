import 'package:dotted_border/dotted_border.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/helper/helper_functions.dart';

import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/app_elvated_button.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_event.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/app/svg_network_widget.dart';
import 'package:trydos/features/home/data/models/get_cart_item_model.dart';
import 'package:trydos/features/home/data/models/get_old_cart_model.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';

import 'package:trydos/features/home/presentation/pages/product_details_page.dart';

import 'package:trydos/features/home/presentation/widgets/product_details_body/product_details_image_widget.dart';
import 'package:trydos/features/story/presentation/widget/try_again.dart';

class productCollectionInCartPage2 extends StatelessWidget {
  const productCollectionInCartPage2(
      {super.key,
      required this.changeCartCollections,
      required this.visibleCollectionGroups,
      required this.groupCartkeys,
      required this.priceSymbol,
      required this.cartCollection,
      required this.oldcartCollection,
      required this.indexes,
      required this.isOLdCart,
      required this.tapIndexs,
      required this.quantityController});

  final ValueNotifier<bool> changeCartCollections;
  final List<String> visibleCollectionGroups;
  final List<String> groupCartkeys;
  final bool isOLdCart;
  final Map<String, List<Cart>>? cartCollection;
  final Map<String, List<OldCart>>? oldcartCollection;
  final int tapIndexs;
  final int indexes;
  final TextEditingController quantityController;

  final String? priceSymbol;
  @override
  Widget build(BuildContext context) {
    int tapIndex = tapIndexs;
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) =>
          previous.getCartItemsStatus != current.getCartItemsStatus ||
          previous.getOldCartItemsStatus != current.getOldCartItemsStatus ||
          previous.getCurrencyForCountryModel !=
              current.getCurrencyForCountryModel ||
          previous.hideItemInOldCartStatus != current.hideItemInOldCartStatus ||
          previous.getOldCartItemsStatus != current.getOldCartItemsStatus ||
          previous.deleteItemInCartStatus != current.deleteItemInCartStatus ||
          previous.addItemInCartStatus != current.addItemInCartStatus ||
          previous.updateItemInCartStatus != current.updateItemInCartStatus,
      builder: (context, state) {
        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 0),
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          itemCount:
              isOLdCart ? oldcartCollection!.length : cartCollection!.length,
          itemBuilder: (context, index) {
            double price = 0;
            if (isOLdCart) {
              oldcartCollection!.values.toList()[index].forEach((element) {
                price =
                    price + element.priceOfVariant! * (element.quantity ?? 0);
              });
            } else {
              cartCollection!.values.toList()[index].forEach((element) {
                price = price + element.offerPrice! * element.quantity!;
              });
            }

            price = price *
                state.getCurrencyForCountryModel!.data!.currency!.exchangeRate!;
            return Column(
              children: [
                InkWell(
                  onTap: () {
                    tapIndex = index;
                    if (visibleCollectionGroups.any(
                        (element) => element == groupCartkeys[tapIndex!])) {
                      visibleCollectionGroups.removeWhere(
                          (element) => element == groupCartkeys[tapIndex!]);
                    } else {
                      visibleCollectionGroups.add(groupCartkeys[tapIndex!]);
                    }

                    changeCartCollections.value = !changeCartCollections.value;
                  },
                  child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      margin: EdgeInsets.only(top: 10, bottom: 0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Color(0xffF8F8F8)),
                      height: 48.h,
                      child: Row(
                        children: [
                          isOLdCart
                              ? Container(
                                  height: 15,
                                  child: oldcartCollection!.values
                                              .toList()[index][0]
                                              .boutique !=
                                          null
                                      ? oldcartCollection!.values
                                                  .toList()[index][0]
                                                  .boutique!
                                                  .icon !=
                                              null
                                          ? SvgNetworkWidget(
                                              svgUrl: oldcartCollection!.values
                                                      .toList()[index][0]
                                                      .boutique!
                                                      .icon!
                                                      .filePath ??
                                                  "",
                                              width: 30,
                                            )
                                          : SizedBox.shrink()
                                      : SizedBox.shrink(),
                                )
                              : Container(
                                  height: 15,
                                  child: cartCollection!.values
                                              .toList()[index][0]
                                              .boutique !=
                                          null
                                      ? cartCollection!.values
                                                  .toList()[index][0]
                                                  .boutique!
                                                  .icon !=
                                              null
                                          ? SvgNetworkWidget(
                                              svgUrl: cartCollection!.values
                                                      .toList()[index][0]
                                                      .boutique!
                                                      .icon!
                                                      .filePath ??
                                                  "",
                                              width: 30,
                                            )
                                          : SizedBox.shrink()
                                      : SizedBox.shrink(),
                                ),
                          Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(AppAssets.countItemSvg),
                              Text(
                                  isOLdCart
                                      ? "  ${oldcartCollection!.values.toList()[index].length} "
                                      : "  ${cartCollection!.values.toList()[index].length} ",
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
                                " ${price.toStringAsFixed(state.startingSetting?.decimalPointSetting ?? 2)}",
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
                        ],
                      )),
                ),
                Column(
                  children: [
                    visibleCollectionGroups
                            .any((element) => element == groupCartkeys[index])
                        ? Container(
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
                              itemCount: isOLdCart
                                  ? oldcartCollection![groupCartkeys[index]]!
                                      .length
                                  : cartCollection![groupCartkeys[index]]!
                                      .length,
                              itemBuilder: (context, indexes) {
                                return InkWell(
                                  onDoubleTap: () {
                                    if (!isOLdCart) {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: MyTextWidget(
                                                  "Change Quatity In Cart",
                                                  textDirection:
                                                      TextDirection.ltr),
                                              actions: <Widget>[
                                                SingleChildScrollView(
                                                  child: Column(
                                                    children: [
                                                      TextFormField(
                                                        inputFormatters: [
                                                          FilteringTextInputFormatter
                                                              .digitsOnly
                                                        ],
                                                        textAlign:
                                                            TextAlign.center,
                                                        controller:
                                                            quantityController,
                                                        enabled: true,
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
                                                              BlocProvider.of<HomeBloc>(context).add(UpdateItemInCartEvent(
                                                                  maxAllowed: double.tryParse(isOLdCart
                                                                      ? oldcartCollection![groupCartkeys[index]]![indexes].maxAllowedQty ??
                                                                          "0"
                                                                      : cartCollection![groupCartkeys[index]]![indexes].maxAllowedQty ??
                                                                          "0"),
                                                                  countOfPieces:
                                                                      cartCollection![groupCartkeys[index]]![indexes]
                                                                          .countOfPieces,
                                                                  image:
                                                                      cartCollection![groupCartkeys[index]]![indexes].image ??
                                                                          "",
                                                                  currentSize: !cartCollection![groupCartkeys[index]]![indexes]
                                                                          .variations
                                                                          .isNullOrEmpty
                                                                      ? cartCollection![groupCartkeys[index]]![indexes].variations![0].size ??
                                                                          ""
                                                                      : "",
                                                                  colorName: !cartCollection![groupCartkeys[index]]![indexes]
                                                                          .variations
                                                                          .isNullOrEmpty
                                                                      ? cartCollection![groupCartkeys[index]]![indexes].variations![0].color ?? ""
                                                                      : "",
                                                                  productId: cartCollection![groupCartkeys[index]]![indexes].productId.toString(),
                                                                  quantity: int.tryParse(quantityController.text)!,
                                                                  cartId: cartCollection![groupCartkeys[index]]![indexes].id.toString(),
                                                                  boutiqueId: cartCollection![groupCartkeys[index]]![indexes].boutique!.id.toString()));
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            text: "Yes",
                                                          ),
                                                          AppElevatedButton(
                                                            onPressed: () {
                                                              Navigator.pop(
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
                                    }
                                  },
                                  onLongPress: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return isOLdCart
                                              ? AlertDialog(
                                                  title: MyTextWidget(
                                                      "What do you Want ?",
                                                      textDirection:
                                                          TextDirection.ltr),
                                                  actions: <Widget>[
                                                    /*  AppElevatedButton(
                                                      onPressed: () {
                                                        GetIt.I<HomeBloc>().add(ConvertItemFromOldcartToCartEvent(
                                                            oldCartId: oldcartCollection![
                                                                            groupCartkeys[index]]![
                                                                        indexes]
                                                                    .id ??
                                                                0,
                                                            boutiqueId: oldcartCollection![
                                                                    groupCartkeys[
                                                                        index]]![indexes]
                                                                .boutique!
                                                                .id
                                                                .toString()));
                                                        Navigator.pop(context);
                                                      },
                                                      text:
                                                          "Convert Item To Cart",
                                                    ),*/
                                                    AppElevatedButton(
                                                      onPressed: () {
                                                        GetIt.I<HomeBloc>().add(HideItemInOldCartEvent(
                                                            hideAll: false,
                                                            oldCartId: oldcartCollection![
                                                                            groupCartkeys[index]]![
                                                                        indexes]
                                                                    .id ??
                                                                0,
                                                            boutiqueId: oldcartCollection![
                                                                    groupCartkeys[
                                                                        index]]![indexes]
                                                                .boutique!
                                                                .id
                                                                .toString()));
                                                        Navigator.pop(context);
                                                      },
                                                      text: "Hide Item",
                                                    ),
                                                    AppElevatedButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      text: 'excite',
                                                    ),
                                                  ],
                                                )
                                              : AlertDialog(
                                                  title: MyTextWidget(
                                                      "Delete Item From Cart",
                                                      textDirection:
                                                          TextDirection.ltr),
                                                  actions: <Widget>[
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        AppElevatedButton(
                                                          onPressed: () {
                                                            BlocProvider.of<HomeBloc>(context).add(RemoveItemFormCartEvent(
                                                                countOfPieces: cartCollection![groupCartkeys[index]]![indexes]
                                                                    .countOfPieces,
                                                                image: cartCollection![groupCartkeys[index]]![indexes].image ??
                                                                    '',
                                                                currentSize: !cartCollection![groupCartkeys[index]]![indexes].variations.isNullOrEmpty
                                                                    ? cartCollection![groupCartkeys[index]]![indexes].variations![0].size ??
                                                                        ""
                                                                    : "",
                                                                ColoName: !cartCollection![groupCartkeys[index]]![indexes]
                                                                        .variations
                                                                        .isNullOrEmpty
                                                                    ? cartCollection![groupCartkeys[index]]![indexes].variations![0].color ??
                                                                        ""
                                                                    : "",
                                                                productId: cartCollection![groupCartkeys[index]]![indexes]
                                                                    .productId
                                                                    .toString(),
                                                                itemId: cartCollection![groupCartkeys[index]]![indexes]
                                                                    .id
                                                                    .toString(),
                                                                boutiqueId: cartCollection![groupCartkeys[index]]![indexes]
                                                                    .boutique!
                                                                    .id
                                                                    .toString()));
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          text: "Yes",
                                                        ),
                                                        AppElevatedButton(
                                                          onPressed: () {
                                                            Navigator.pop(
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
                                    int indexess = isOLdCart
                                        ? state.productITemForCart![oldcartCollection![groupCartkeys[index]]![indexes].productId.toString()]!.syncColorImages!.indexOf(state
                                            .productITemForCart![oldcartCollection![groupCartkeys[index]]![indexes]
                                                .productId
                                                .toString()]!
                                            .syncColorImages!
                                            .firstWhere((element) =>
                                                element.colorName ==
                                                (!oldcartCollection![groupCartkeys[index]]![indexes]
                                                        .variations
                                                        .isNullOrEmpty
                                                    ? oldcartCollection![groupCartkeys[index]]![indexes].variations![0].color ??
                                                        ""
                                                    : "")))
                                        : state
                                            .productITemForCart![cartCollection![groupCartkeys[index]]![indexes].productId.toString()]!
                                            .syncColorImages!
                                            .indexOf(state.productITemForCart![cartCollection![groupCartkeys[index]]![indexes].productId.toString()]!.syncColorImages!.firstWhere((element) => element.colorName == (!cartCollection![groupCartkeys[index]]![indexes].variations.isNullOrEmpty ? cartCollection![groupCartkeys[index]]![indexes].variations![0].color ?? "" : "")));
                                    if (index != -1) {
                                      BlocProvider.of<HomeBloc>(context).add(
                                          AddCurrentSelectedColorEvent(
                                              currentSelectedColor: indexess,
                                              productId: isOLdCart
                                                  ? oldcartCollection![
                                                          groupCartkeys[
                                                              index]]![indexes]
                                                      .productId
                                                      .toString()
                                                  : cartCollection![
                                                          groupCartkeys[
                                                              index]]![indexes]
                                                      .productId
                                                      .toString()));
                                    }
                                    HelperFunctions.slidingNavigation(
                                        context,
                                        ProductDetailsPage(
                                          productItem: isOLdCart
                                              ? state.productITemForCart![
                                                  oldcartCollection![
                                                          groupCartkeys[
                                                              index]]![indexes]
                                                      .productId
                                                      .toString()]!
                                              : state.productITemForCart![
                                                  cartCollection![groupCartkeys[
                                                          index]]![indexes]
                                                      .productId
                                                      .toString()]!,
                                        ));
                                  },
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        margin:
                                            EdgeInsets.symmetric(horizontal: 2),
                                        child: ProductDetailsImageWidget(
                                          withBackGroundShadow: false,
                                          withInnerShadow: false,
                                          width: 97.w,
                                          height: 142,
                                          imageUrl: isOLdCart
                                              ? oldcartCollection![
                                                      groupCartkeys[
                                                          index]]![indexes]
                                                  .image
                                              : cartCollection![groupCartkeys[
                                                      index]]![indexes]
                                                  .image,
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
                                                      .circular(15)),
                                          child: Text(
                                            isOLdCart
                                                ? "${oldcartCollection![groupCartkeys[index]]![indexes].quantity}"
                                                : "${cartCollection![groupCartkeys[index]]![indexes].quantity}",
                                            style: context
                                                .textTheme.bodyMedium?.ra
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
                                      Positioned(
                                        child: Container(
                                          margin: EdgeInsets.all(2),
                                          alignment: Alignment.center,
                                          width: 97.w,
                                          height: 45,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              color:
                                                  Color.fromRGBO(0, 0, 0, 0.5),
                                              borderRadius: BorderRadius.only(
                                                  bottomRight:
                                                      Radius.circular(15),
                                                  bottomLeft:
                                                      Radius.circular(15))),
                                          child: Text(
                                            isOLdCart
                                                ? '''${!oldcartCollection![groupCartkeys[index]]![indexes].variations.isNullOrEmpty ? oldcartCollection![groupCartkeys[index]]![indexes].variations![0].size ?? "" : ""} \n '''
                                                    '''${(oldcartCollection![groupCartkeys[index]]![indexes].priceOfVariant! * (oldcartCollection![groupCartkeys[index]]![indexes].quantity ?? 0) * state.getCurrencyForCountryModel!.data!.currency!.exchangeRate!).toStringAsFixed(state.startingSetting?.decimalPointSetting ?? 2)} '''
                                                    '''${priceSymbol ?? '\$'}'''
                                                : '''${!cartCollection![groupCartkeys[index]]![indexes].variations.isNullOrEmpty ? cartCollection![groupCartkeys[index]]![indexes].variations![0].size ?? "" : ""} \n '''
                                                    '''${(cartCollection![groupCartkeys[index]]![indexes].offerPrice! * cartCollection![groupCartkeys[index]]![indexes].quantity! * state.getCurrencyForCountryModel!.data!.currency!.exchangeRate!).toStringAsFixed(state.startingSetting?.decimalPointSetting ?? 2)} '''
                                                    '''${priceSymbol ?? '\$'}''',
                                            style: context
                                                .textTheme.bodyMedium?.ra
                                                .copyWith(
                                              decorationColor:
                                                  Color(0xffFEFEFE),
                                              fontSize: 12,
                                              color: Color(0xffFEFEFE),
                                            ),
                                            textAlign: TextAlign.center,
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
                    visibleCollectionGroups
                            .any((element) => element == groupCartkeys[index])
                        ? Container(
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
                                itemCount: isOLdCart
                                    ? oldcartCollection![groupCartkeys[index]]!
                                        .length
                                    : cartCollection![groupCartkeys[index]]!
                                        .length,
                                itemBuilder: (context, indexs) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        onDoubleTap: () {
                                          if (!isOLdCart) {
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: MyTextWidget(
                                                        "Change Quatity In Cart",
                                                        textDirection:
                                                            TextDirection.ltr),
                                                    actions: <Widget>[
                                                      SingleChildScrollView(
                                                        child: Column(
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
                                                              enabled: true,
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
                                                                  onPressed:
                                                                      () {
                                                                    BlocProvider.of<HomeBloc>(context).add(UpdateItemInCartEvent(
                                                                        maxAllowed:
                                                                            double.tryParse(cartCollection![groupCartkeys[index]]![indexes].maxAllowedQty ??
                                                                                "0"),
                                                                        countOfPieces:
                                                                            cartCollection![groupCartkeys[index]]![indexs]
                                                                                .countOfPieces,
                                                                        image: cartCollection![groupCartkeys[index]]![indexes].image ??
                                                                            "",
                                                                        currentSize: !cartCollection![groupCartkeys[index]]![indexs].variations.isNullOrEmpty
                                                                            ? cartCollection![groupCartkeys[index]]![indexs].variations![0].size ??
                                                                                ""
                                                                            : "",
                                                                        colorName: !cartCollection![groupCartkeys[index]]![indexs].variations.isNullOrEmpty
                                                                            ? cartCollection![groupCartkeys[index]]![indexs].variations![0].color ??
                                                                                ""
                                                                            : "",
                                                                        productId: cartCollection![groupCartkeys[index]]![indexs]
                                                                            .productId
                                                                            .toString(),
                                                                        quantity:
                                                                            int.tryParse(quantityController.text)!,
                                                                        cartId: cartCollection![groupCartkeys[index]]![indexs].id.toString(),
                                                                        boutiqueId: cartCollection![groupCartkeys[index]]![indexs].boutique!.id.toString()));
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  text: "Yes",
                                                                ),
                                                                AppElevatedButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  text:
                                                                      'Not Now',
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                });
                                          }
                                        },
                                        onLongPress: () {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return isOLdCart
                                                    ? AlertDialog(
                                                        title: MyTextWidget(
                                                            "What do you Want ?",
                                                            textDirection:
                                                                TextDirection
                                                                    .ltr),
                                                        actions: <Widget>[
                                                          /* AppElevatedButton(
                                                            onPressed: () {
                                                              GetIt.I<HomeBloc>().add(ConvertItemFromOldcartToCartEvent(
                                                                  oldCartId:
                                                                      oldcartCollection![groupCartkeys[index]]![indexes]
                                                                              .id ??
                                                                          0,
                                                                  boutiqueId: oldcartCollection![
                                                                              groupCartkeys[index]]![
                                                                          indexes]
                                                                      .boutique!
                                                                      .id
                                                                      .toString()));
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            text:
                                                                "Convert Item To Cart",
                                                          ),*/
                                                          AppElevatedButton(
                                                            onPressed: () {
                                                              GetIt.I<HomeBloc>().add(HideItemInOldCartEvent(
                                                                  hideAll:
                                                                      false,
                                                                  oldCartId:
                                                                      oldcartCollection![groupCartkeys[index]]![indexes]
                                                                              .id ??
                                                                          0,
                                                                  boutiqueId: oldcartCollection![
                                                                              groupCartkeys[index]]![
                                                                          indexes]
                                                                      .boutique!
                                                                      .id
                                                                      .toString()));
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            text: "Hide Item",
                                                          ),
                                                          AppElevatedButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            text: 'excite',
                                                          ),
                                                        ],
                                                      )
                                                    : AlertDialog(
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
                                                                onPressed: () {
                                                                  BlocProvider.of<HomeBloc>(context).add(RemoveItemFormCartEvent(
                                                                      countOfPieces:
                                                                          cartCollection![groupCartkeys[index]]![indexes]
                                                                              .countOfPieces,
                                                                      image:
                                                                          cartCollection![groupCartkeys[index]]![indexes].image ??
                                                                              '',
                                                                      currentSize: !cartCollection![groupCartkeys[index]]![indexes].variations.isNullOrEmpty
                                                                          ? cartCollection![groupCartkeys[index]]![indexes].variations![0].size ??
                                                                              ""
                                                                          : "",
                                                                      ColoName: !cartCollection![groupCartkeys[index]]![indexes].variations.isNullOrEmpty
                                                                          ? cartCollection![groupCartkeys[index]]![indexes].variations![0].color ??
                                                                              ""
                                                                          : "",
                                                                      productId: cartCollection![groupCartkeys[index]]![indexes]
                                                                          .productId
                                                                          .toString(),
                                                                      itemId: cartCollection![groupCartkeys[index]]![indexes]
                                                                          .id
                                                                          .toString(),
                                                                      boutiqueId: cartCollection![groupCartkeys[index]]![indexes]
                                                                          .boutique!
                                                                          .id
                                                                          .toString()));
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                text: "Yes",
                                                              ),
                                                              AppElevatedButton(
                                                                onPressed: () {
                                                                  Navigator.pop(
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
                                          int indexess = isOLdCart
                                              ? state.productITemForCart![oldcartCollection![groupCartkeys[index]]![indexs].productId.toString()]!.syncColorImages!.indexOf(state
                                                  .productITemForCart![oldcartCollection![groupCartkeys[index]]![indexs]
                                                      .productId
                                                      .toString()]!
                                                  .syncColorImages!
                                                  .firstWhere((element) =>
                                                      element.colorName ==
                                                      (!oldcartCollection![groupCartkeys[index]]![indexs]
                                                              .variations
                                                              .isNullOrEmpty
                                                          ? oldcartCollection![groupCartkeys[index]]![indexs].variations![0].color ??
                                                              ""
                                                          : "")))
                                              : state
                                                  .productITemForCart![cartCollection![groupCartkeys[index]]![indexs].productId.toString()]!
                                                  .syncColorImages!
                                                  .indexOf(state.productITemForCart![cartCollection![groupCartkeys[index]]![indexs].productId.toString()]!.syncColorImages!.firstWhere((element) => element.colorName == (!cartCollection![groupCartkeys[index]]![indexs].variations.isNullOrEmpty ? cartCollection![groupCartkeys[index]]![indexs].variations![0].color ?? "" : "")));
                                          if (index != -1) {
                                            BlocProvider.of<HomeBloc>(context)
                                                .add(AddCurrentSelectedColorEvent(
                                                    currentSelectedColor:
                                                        indexess,
                                                    productId: isOLdCart
                                                        ? oldcartCollection![
                                                                    groupCartkeys[
                                                                        index]]![
                                                                indexs]
                                                            .productId
                                                            .toString()
                                                        : cartCollection![
                                                                    groupCartkeys[
                                                                        index]]![
                                                                indexs]
                                                            .productId
                                                            .toString()));
                                          }
                                          HelperFunctions.slidingNavigation(
                                              context,
                                              ProductDetailsPage(
                                                productItem: isOLdCart
                                                    ? state.productITemForCart![
                                                        oldcartCollection![
                                                                    groupCartkeys[
                                                                        index]]![
                                                                indexs]
                                                            .productId
                                                            .toString()]!
                                                    : state.productITemForCart![
                                                        cartCollection![
                                                                    groupCartkeys[
                                                                        index]]![
                                                                indexs]
                                                            .productId
                                                            .toString()]!,
                                              ));
                                        },
                                        child: Stack(children: [
                                          Container(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.only(
                                                left: 2, right: 2),
                                            child: ProductDetailsImageWidget(
                                              withBackGroundShadow: false,
                                              withInnerShadow: false,
                                              width: 97.w,
                                              height: 142,
                                              imageUrl: isOLdCart
                                                  ? oldcartCollection![
                                                          groupCartkeys[
                                                              index]]![indexs]
                                                      .image
                                                  : cartCollection![
                                                          groupCartkeys[
                                                              index]]![indexs]
                                                      .image,
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
                                                isOLdCart
                                                    ? "${oldcartCollection![groupCartkeys[index]]![indexs].quantity}"
                                                    : "${cartCollection![groupCartkeys[index]]![indexs].quantity}",
                                                style: context
                                                    .textTheme.bodyMedium?.ra
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
                                      ),
                                      Container(
                                        alignment: Alignment.center,
                                        width: 97.w,
                                        height: 45,
                                        child: Text(
                                          isOLdCart
                                              ? '''${!oldcartCollection![groupCartkeys[index]]![indexs].variations.isNullOrEmpty ? oldcartCollection![groupCartkeys[index]]![indexs].variations![0].size ?? "" : ""} \n '''
                                                  '''${(oldcartCollection![groupCartkeys[index]]![indexs].priceOfVariant! * (oldcartCollection![groupCartkeys[index]]![indexs].quantity ?? 0) * state.getCurrencyForCountryModel!.data!.currency!.exchangeRate!).toStringAsFixed(state.startingSetting?.decimalPointSetting ?? 2)} '''
                                                  '''${priceSymbol ?? '\$'}'''
                                              : '''${!cartCollection![groupCartkeys[index]]![indexs].variations.isNullOrEmpty ? cartCollection![groupCartkeys[index]]![indexs].variations![0].size ?? "" : ""} \n '''
                                                  '''${(cartCollection![groupCartkeys[index]]![indexs].offerPrice! * cartCollection![groupCartkeys[index]]![indexs].quantity! * state.getCurrencyForCountryModel!.data!.currency!.exchangeRate!).toStringAsFixed(state.startingSetting?.decimalPointSetting ?? 2)} '''
                                                  '''${priceSymbol ?? '\$'}''',
                                          style: context
                                              .textTheme.bodyMedium?.ra
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
                        : SizedBox.shrink()
                  ],
                )
              ],
            );
          },
        );
      },
    );
  }
}
