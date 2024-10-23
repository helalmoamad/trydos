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
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';

import 'package:trydos/features/home/presentation/pages/product_details_page.dart';

import 'package:trydos/features/home/presentation/widgets/product_details_body/product_details_image_widget.dart';
import 'package:trydos/features/story/presentation/widget/try_again.dart';

class productCollectionInCartPage1 extends StatelessWidget {
  const productCollectionInCartPage1(
      {super.key,
      required this.changeCartCollections,
      required this.visibleCollectionGroups,
      required this.groupCartkeys,
      required this.priceSymbol,
      required this.cartCollection,
      required this.getCartShippingItemsModel,
      required this.tapIndexs,
      required this.quantityController});

  final ValueNotifier<bool> changeCartCollections;
  final List<String> visibleCollectionGroups;
  final List<String> groupCartkeys;
  final Map<String, List<Cart>>? cartCollection;
  final int tapIndexs;
  final TextEditingController quantityController;
  final GetCartShippingItemsModel? getCartShippingItemsModel;
  final String? priceSymbol;
  @override
  Widget build(BuildContext context) {
    int tapIndex = tapIndexs;
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) =>
          previous.getCartItemsStatus != current.getCartItemsStatus ||
          previous.getCurrencyForCountryModel !=
              current.getCurrencyForCountryModel ||
          previous.deleteItemInCartStatus != current.deleteItemInCartStatus ||
          previous.addItemInCartStatus != current.addItemInCartStatus ||
          previous.updateItemInCartStatus != current.updateItemInCartStatus,
      builder: (context, state) {
        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 0),
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          itemCount: cartCollection!.length,
          itemBuilder: (context, index) {
            double price = 0;
            cartCollection!.values.toList()[index].forEach((element) {
              price = price + element.offerPrice! * element.quantity!;
            });
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
                      width: 1.sw - 20,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      margin: EdgeInsets.only(top: 5, bottom: 0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Color(0xffF8F8F8)),
                      height: 48.h,
                      child: Row(
                        children: [
                          Container(
                            width: 30,
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
                                        width: 15,
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
                                  "  ${cartCollection!.values.toList()[index].length} ",
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
                SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: visibleCollectionGroups
                            .any((element) => element == groupCartkeys[index])
                        ? Color(0xffFFF4B5)
                        : Colors.white,
                  ),
                  margin: EdgeInsets.only(top: 10),
                  width: visibleCollectionGroups
                          .any((element) => element == groupCartkeys[index])
                      ? 420.w
                      : 0,
                  height: visibleCollectionGroups
                          .any((element) => element == groupCartkeys[index])
                      ? cartCollection![groupCartkeys[index]]!.length * 180.h +
                          15.h
                      : 0,
                  child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: false,
                    padding: EdgeInsets.only(top: 0),
                    itemCount: cartCollection![groupCartkeys[index]]!.length,
                    itemBuilder: (context, indexes) {
                      int quantity =
                          cartCollection![groupCartkeys[index]]![indexes]
                              .quantity!;

                      return visibleCollectionGroups
                              .any((element) => element == groupCartkeys[index])
                          ? InkWell(
                              onDoubleTap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: MyTextWidget(
                                            "Change Quatity In Cart",
                                            textDirection: TextDirection.ltr),
                                        actions: <Widget>[
                                          SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                TextFormField(
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter
                                                        .digitsOnly
                                                  ],
                                                  textAlign: TextAlign.center,
                                                  controller:
                                                      quantityController,
                                                  enabled: true,
                                                  keyboardType:
                                                      TextInputType.number,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    AppElevatedButton(
                                                      onPressed: () {
                                                        GetIt.I<HomeBloc>().add(UpdateItemInCartEvent(
                                                            maxAllowed: double.tryParse(
                                                                cartCollection![groupCartkeys[index]]![indexes].maxAllowedQty ??
                                                                    "0"),
                                                            countOfPieces:
                                                                cartCollection![groupCartkeys[index]]![indexes]
                                                                    .countOfPieces,
                                                            currentSize: !cartCollection![groupCartkeys[index]]![indexes]
                                                                    .variations
                                                                    .isNullOrEmpty
                                                                ? cartCollection![groupCartkeys[index]]![indexes].variations![0].size ??
                                                                    ""
                                                                : "",
                                                            colorName: !cartCollection![groupCartkeys[index]]![indexes]
                                                                    .variations
                                                                    .isNullOrEmpty
                                                                ? cartCollection![groupCartkeys[index]]![indexes]
                                                                        .variations![0]
                                                                        .color ??
                                                                    ""
                                                                : "",
                                                            productId: cartCollection![groupCartkeys[index]]![indexes].productId.toString(),
                                                            quantity: int.tryParse(quantityController.text)!,
                                                            image: cartCollection?[groupCartkeys[index]]![indexes].image ?? "",
                                                            cartId: cartCollection![groupCartkeys[index]]![indexes].id.toString(),
                                                            boutiqueId: cartCollection![groupCartkeys[index]]![indexes].boutique!.id.toString()));
                                                        Navigator.pop(context);
                                                      },
                                                      text: "Yes",
                                                    ),
                                                    AppElevatedButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
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
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: MyTextWidget(
                                            "Delete Item From Cart",
                                            textDirection: TextDirection.ltr),
                                        actions: <Widget>[
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              AppElevatedButton(
                                                onPressed: () {
                                                  GetIt.I<HomeBloc>().add(RemoveItemFormCartEvent(
                                                      countOfPieces:
                                                          cartCollection![groupCartkeys[index]]![indexes]
                                                              .countOfPieces,
                                                      image:
                                                          cartCollection![groupCartkeys[index]]![indexes]
                                                                  .image ??
                                                              '',
                                                      currentSize:
                                                          !cartCollection![groupCartkeys[index]]![indexes]
                                                                  .variations
                                                                  .isNullOrEmpty
                                                              ? cartCollection![groupCartkeys[index]]![indexes].variations![0].size ??
                                                                  ""
                                                              : "",
                                                      ColoName: !cartCollection![groupCartkeys[index]]![indexes]
                                                              .variations
                                                              .isNullOrEmpty
                                                          ? cartCollection![groupCartkeys[index]]![indexes]
                                                                  .variations![0]
                                                                  .color ??
                                                              ""
                                                          : "",
                                                      productId: cartCollection![groupCartkeys[index]]![indexes].productId.toString(),
                                                      itemId: cartCollection![groupCartkeys[index]]![indexes].id.toString(),
                                                      boutiqueId: cartCollection![groupCartkeys[index]]![indexes].boutique!.id.toString()));
                                                  Navigator.pop(context);
                                                },
                                                text: "Yes",
                                              ),
                                              AppElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
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
                                int indexess = state.productITemForCart![cartCollection![groupCartkeys[index]]![indexes].productId.toString()]!.syncColorImages.isNullOrEmpty
                                    ? -1
                                    : state.productITemForCart![cartCollection![groupCartkeys[index]]![indexes].productId.toString()]!.syncColorImages!
                                        .indexOf(state
                                            .productITemForCart![
                                                cartCollection![groupCartkeys[index]]![indexes]
                                                    .productId
                                                    .toString()]!
                                            .syncColorImages!
                                            .firstWhere((element) =>
                                                element.colorName ==
                                                (!cartCollection![groupCartkeys[index]]![indexes]
                                                        .variations
                                                        .isNullOrEmpty
                                                    ? cartCollection![groupCartkeys[index]]![indexes]
                                                            .variations![0]
                                                            .color ??
                                                        ""
                                                    : "")));
                                if (indexess != -1) {
                                  BlocProvider.of<HomeBloc>(context).add(
                                      AddCurrentSelectedColorEvent(
                                          currentSelectedColor: indexess,
                                          productId: cartCollection![
                                                      groupCartkeys[index]]![
                                                  indexes]
                                              .productId
                                              .toString()));
                                }
                                HelperFunctions.slidingNavigation(
                                    context,
                                    ProductDetailsPage(
                                      productItem: state
                                          .productITemForCart![cartCollection![
                                              groupCartkeys[index]]![indexes]
                                          .productId
                                          .toString()]!,
                                    ));
                              },
                              child: Container(
                                margin: EdgeInsets.only(
                                    bottom: indexes ==
                                            cartCollection![
                                                        groupCartkeys[index]]!
                                                    .length -
                                                1 //length
                                        ? 30
                                        : 0),
                                width: 1.sw,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(indexes ==
                                          getCartShippingItemsModel!
                                                  .data!.cart!.length -
                                              1 //length
                                      ? 15
                                      : 15),
                                  boxShadow: [
                                    BoxShadow(
                                        offset: Offset(
                                            0,
                                            indexes == 0
                                                ? 0
                                                : indexes ==
                                                        cartCollection![
                                                                    groupCartkeys[
                                                                        index]]!
                                                                .length -
                                                            1
                                                    ? -10
                                                    : 10),
                                        blurRadius: indexes ==
                                                cartCollection![groupCartkeys[
                                                            index]]!
                                                        .length -
                                                    1
                                            ? 0
                                            : 5,
                                        color: Color(0xffF3F3F3),
                                        spreadRadius: indexes == 0
                                            ? 5
                                            : indexes ==
                                                    cartCollection![
                                                                groupCartkeys[
                                                                    index]]!
                                                            .length -
                                                        1
                                                ? 0
                                                : 10),
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
                                            imageUrl: cartCollection![
                                                        groupCartkeys[index]]![
                                                    indexes]
                                                .image,
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
                                              child:
                                                  cartCollection![groupCartkeys[
                                                                      index]]![
                                                                  indexes]
                                                              .brand !=
                                                          null
                                                      ? SvgPicture.network(
                                                          cartCollection![
                                                                  groupCartkeys[
                                                                      index]]![indexes]
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
                                                  cartCollection![groupCartkeys[
                                                              index]]![indexes]
                                                          .name ??
                                                      "",
                                                  style: context
                                                      .textTheme.bodyMedium?.ra
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
                                                      " Composed Of ${cartCollection![groupCartkeys[index]]![indexes].countOfPieces} Piece",
                                                      style: context.textTheme
                                                          .bodyMedium?.la
                                                          .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w100,
                                                              fontSize: 12,
                                                              color: const Color(
                                                                  0xff707070),
                                                              letterSpacing:
                                                                  0.18,
                                                              height: 1.33),
                                                    ),
                                                  ],
                                                )),
                                            cartCollection![groupCartkeys[
                                                        index]]![indexes]
                                                    .variations
                                                    .isNullOrEmpty
                                                ? SizedBox.shrink()
                                                : (cartCollection![groupCartkeys[
                                                                        index]]![
                                                                    indexes]
                                                                .variations![0]
                                                                .color ==
                                                            "" ||
                                                        cartCollection![groupCartkeys[
                                                                        index]]![
                                                                    indexes]
                                                                .variations![0]
                                                                .color ==
                                                            null)
                                                    ? SizedBox.shrink()
                                                    : Container(
                                                        margin: EdgeInsets.only(
                                                            top: 5),
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        width: 200,
                                                        height: 15,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            SvgPicture.asset(
                                                              AppAssets
                                                                  .colorPickerSvg,
                                                              height: 12,
                                                            ),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            Text(
                                                              "Color, ",
                                                              style: context
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.la
                                                                  .copyWith(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                      fontSize:
                                                                          12,
                                                                      color: const Color(
                                                                          0xff505050),
                                                                      letterSpacing:
                                                                          0.18,
                                                                      height:
                                                                          1.33),
                                                            ),
                                                            Text(
                                                              !cartCollection![groupCartkeys[
                                                                              index]]![
                                                                          indexes]
                                                                      .variations
                                                                      .isNullOrEmpty
                                                                  ? cartCollection![groupCartkeys[index]]![
                                                                              indexes]
                                                                          .variations![
                                                                              0]
                                                                          .color ??
                                                                      ""
                                                                  : "",
                                                              style: context
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.ra
                                                                  .copyWith(
                                                                fontSize: 13,
                                                                color: const Color(
                                                                    (0xff505050)),
                                                                letterSpacing:
                                                                    0.18,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                            cartCollection![groupCartkeys[
                                                        index]]![indexes]
                                                    .variations
                                                    .isNullOrEmpty
                                                ? SizedBox.shrink()
                                                : (cartCollection![groupCartkeys[
                                                                        index]]![
                                                                    indexes]
                                                                .variations![0]
                                                                .size ==
                                                            "" ||
                                                        cartCollection![groupCartkeys[
                                                                        index]]![
                                                                    indexes]
                                                                .variations![0]
                                                                .size ==
                                                            null)
                                                    ? SizedBox.shrink()
                                                    : Container(
                                                        margin: EdgeInsets.only(
                                                            top: 5),
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        width: 200,
                                                        height: 15,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            SvgPicture.asset(
                                                              AppAssets
                                                                  .sizeIconSvg,
                                                              height: 12,
                                                              color: Color(
                                                                  0xff48C8A8),
                                                            ),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            Text(
                                                              "Size, ",
                                                              style: context
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.la
                                                                  .copyWith(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                      fontSize:
                                                                          12,
                                                                      color: const Color(
                                                                          0xff505050),
                                                                      letterSpacing:
                                                                          0.18,
                                                                      height:
                                                                          1.33),
                                                            ),
                                                            Text(
                                                              !cartCollection![groupCartkeys[
                                                                              index]]![
                                                                          indexes]
                                                                      .variations
                                                                      .isNullOrEmpty
                                                                  ? cartCollection![groupCartkeys[index]]![
                                                                              indexes]
                                                                          .variations![
                                                                              0]
                                                                          .size ??
                                                                      ""
                                                                  : "",
                                                              style: context
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.ra
                                                                  .copyWith(
                                                                fontSize: 13,
                                                                color: const Color(
                                                                    (0xff505050)),
                                                                letterSpacing:
                                                                    0.18,
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
                                              (cartCollection![groupCartkeys[
                                                              index]]![indexes]
                                                          .price! *
                                                      state
                                                          .getCurrencyForCountryModel!
                                                          .data!
                                                          .currency!
                                                          .exchangeRate! *
                                                      quantity)
                                                  .toStringAsFixed(state
                                                          .startingSetting
                                                          ?.decimalPointSetting ??
                                                      2),
                                              style: context
                                                  .textTheme.bodyMedium?.ra
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
                                                "${(cartCollection![groupCartkeys[index]]![indexes].offerPrice! * quantity * state.getCurrencyForCountryModel!.data!.currency!.exchangeRate!).toStringAsFixed(state.startingSetting?.decimalPointSetting ?? 2)} ",
                                                style: context
                                                    .textTheme.bodyMedium?.br
                                                    .copyWith(
                                                  decorationColor:
                                                      Color(0xff505050),
                                                  fontSize: 18,
                                                  color: Color(0xff505050),
                                                )),
                                            Text(
                                              priceSymbol ?? '\$',
                                              style: context
                                                  .textTheme.bodyMedium?.ra
                                                  .copyWith(
                                                decorationColor:
                                                    Color(0xffc4c2c2),
                                                fontSize: 9,
                                                color: Color(0xffc4c2c2),
                                              ),
                                            )
                                          ],
                                        ),
                                        bottom: 15,
                                        right: 10,
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
                                            "${cartCollection![groupCartkeys[index]]![indexes].quantity}",
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
                                        top: 5,
                                        right: 5,
                                      ),
                                      Positioned(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            color: Color(0x707070),
                                          ),
                                          width: 100.w,
                                          height: 40.h,
                                          child: (cartCollection![groupCartkeys[
                                                              index]]![indexes]
                                                          .availableQuantity ??
                                                      0) <
                                                  (cartCollection![
                                                                  groupCartkeys[
                                                                      index]]![
                                                              indexes]
                                                          .quantity ??
                                                      0)
                                              ? Text(
                                                  " Out OF Stock",
                                                  style: context
                                                      .textTheme.bodyMedium?.la
                                                      .copyWith(
                                                          fontWeight:
                                                              FontWeight.w100,
                                                          fontSize: 12,
                                                          color: const Color
                                                              .fromARGB(
                                                              255, 206, 9, 9),
                                                          letterSpacing: 0.18,
                                                          height: 1.33),
                                                )
                                              : SizedBox.shrink(),
                                        ),
                                        top: 5,
                                        right: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : SizedBox.shrink();
                    },
                  ),
                )
              ],
            );
          },
        );
      },
    );
  }
}
