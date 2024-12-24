import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/helper/helper_functions.dart';

import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';

import 'package:trydos/features/home/data/models/get_cart_item_model.dart';
import 'package:trydos/features/home/data/models/get_old_cart_model.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';

import 'package:trydos/features/home/presentation/pages/product_details_page.dart';
import 'package:trydos/features/home/presentation/widgets/cart_section/count_down_timer.dart';

import 'package:trydos/features/home/presentation/widgets/product_details_body/product_details_image_widget.dart';

class productCollectionInCartPage1 extends StatefulWidget {
  const productCollectionInCartPage1({
    super.key,
    required this.priceSymbol,
    required this.oldCartCollection,
    required this.isOldCart,
    required this.cartCollection,
  });

  final List<Cart>? cartCollection;
  final List<OldCart>? oldCartCollection;

  final bool isOldCart;

  final String? priceSymbol;
  @override
  State<productCollectionInCartPage1> createState() =>
      _productCollectionInCartPage1State();
}

class _productCollectionInCartPage1State
    extends State<productCollectionInCartPage1> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<Cart>? cartCollection;
    final List<OldCart>? oldCartCollection;
    final bool isOldCart;
    isOldCart = widget.isOldCart;
    oldCartCollection = widget.oldCartCollection;
    cartCollection = widget.cartCollection;
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) =>
          previous.getCartItemsStatus != current.getCartItemsStatus ||
          previous.getCurrencyForCountryModel !=
              current.getCurrencyForCountryModel ||
          previous.hideItemInOldCartStatus != current.hideItemInOldCartStatus ||
          previous.getOldCartItemsStatus != current.getOldCartItemsStatus ||
          previous.deleteItemInCartStatus != current.deleteItemInCartStatus ||
          previous.addItemInCartStatus != current.addItemInCartStatus ||
          previous.updateItemInCartStatus != current.updateItemInCartStatus,
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.all(1),
          child: ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 0),
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemCount:
                isOldCart ? oldCartCollection?.length : cartCollection?.length,
            itemBuilder: (context, index) {
              // double price = 0;

              /*  if (isOldCart) {
                oldCartCollection!.values.toList()[index].forEach((element) {
                  price = (price + (element.priceOfVariant!)) *
                      (element.quantity ?? 0);
                });
              } else {
                cartCollection!.values.toList()[index].forEach((element) {
                  price = price + element.offerPrice! * element.quantity!;
                });
              }
              price = price *
                  state.getCurrencyForCountryModel!.data!.currency!.exchangeRate!;
          */
              return Container(
                padding: EdgeInsetsDirectional.only(
                    start: 12,
                    end: 12,
                    bottom: (cartCollection?.length == 0)
                        ? (index == (oldCartCollection?.length ?? 0) - 1) &&
                                isOldCart
                            ? 170
                            : 0
                        : (oldCartCollection?.length == 0)
                            ? (index == (cartCollection?.length ?? 0) - 1) &&
                                    !isOldCart
                                ? 170
                                : 0
                            : (index == (oldCartCollection?.length ?? 0) - 1) &&
                                    isOldCart
                                ? 170
                                : 0),
                child: Container(
                  margin: EdgeInsets.only(bottom: 7, right: 5, left: 5),
                  width: 1.sw,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                          offset: Offset(0, 5),
                          blurRadius: 5,
                          color: Color(0xffF2F2F2),
                          spreadRadius: 2),
                    ],
                  ),
                  child: Container(
                    margin: EdgeInsets.only(
                      bottom: 5.h,
                    ),
                    width: 400.w,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: isOldCart ? Color(0xffFF5F61) : Colors.white),
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    height: isOldCart
                        ? 208.h
                        : (state.cartCollection?[index].haveHurryUpNotify ??
                                false)
                            ? 208.h
                            : 161.h,
                    child: Stack(
                      children: [
                        Positioned(
                          child: InkWell(
                            onTap: () {
                              int indexess = isOldCart
                                  ? state
                                          .productITemForCart[
                                              oldCartCollection![index]
                                                  .productId
                                                  .toString()]!
                                          .syncColorImages
                                          .isNullOrEmpty
                                      ? -1
                                      : state.productITemForCart[oldCartCollection[index].productId.toString()]!.syncColorImages!
                                          .indexOf(state
                                              .productITemForCart[
                                                  oldCartCollection[index]
                                                      .productId
                                                      .toString()]!
                                              .syncColorImages!
                                              .firstWhere((element) =>
                                                  element.colorName ==
                                                  (!oldCartCollection![index]
                                                          .variations
                                                          .isNullOrEmpty
                                                      ? oldCartCollection[index]
                                                              .variations![0]
                                                              .color ??
                                                          ""
                                                      : "")))
                                  : state.productITemForCart[cartCollection![index].productId.toString()] == null
                                      ? -1
                                      : state.productITemForCart[cartCollection[index].productId.toString()]!.syncColorImages.isNullOrEmpty
                                          ? -1
                                          : state.productITemForCart[cartCollection[index].productId.toString()]!.syncColorImages!.indexOf(state.productITemForCart[cartCollection[index].productId.toString()]!.syncColorImages!.firstWhere((element) => element.colorName == (!cartCollection![index].variations.isNullOrEmpty ? cartCollection[index].variations![0].color ?? "" : "")));
                              if (indexess != -1) {
                                BlocProvider.of<HomeBloc>(context).add(
                                    AddCurrentSelectedColorEvent(
                                        currentSelectedColor: indexess,
                                        productId: isOldCart
                                            ? oldCartCollection![index]
                                                .productId
                                                .toString()
                                            : cartCollection![index]
                                                .productId
                                                .toString()));
                              }
                              HelperFunctions.slidingNavigation(
                                  context,
                                  ProductDetailsPage(
                                    productItem: isOldCart
                                        ? state.productITemForCart[
                                            oldCartCollection![index]
                                                .productId
                                                .toString()]!
                                        : state.productITemForCart[
                                            cartCollection![index]
                                                .productId
                                                .toString()]!,
                                  ));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Color(0x707070),
                              ),
                              width: 110.w,
                              height: 161.h,
                              child: ProductDetailsImageWidget(
                                withBackGroundShadow: true,
                                withInnerShadow: false,
                                imageFit: BoxFit.cover,
                                blurRadius: 0,
                                imageUrl: isOldCart
                                    ? oldCartCollection![index].image
                                    : cartCollection![index].image,
                                width: 116.w,
                                height: 160.h,
                                radius: 15,
                              ),
                            ),
                          ),
                          left: 0,
                        ),
                        Positioned(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: 10),
                                alignment: Alignment.topLeft,
                                height: 10,
                                width: 30,
                                child: (isOldCart
                                    ? oldCartCollection![index].brand != null
                                        ? SvgPicture.network(
                                            oldCartCollection[index]
                                                .brand!
                                                .image!,
                                            fit: BoxFit.contain,
                                          )
                                        : SizedBox.shrink()
                                    : cartCollection![index].brand != null
                                        ? SvgPicture.network(
                                            cartCollection[index].brand!.image!,
                                            fit: BoxFit.fill,
                                            color: Color(
                                              0xff1A171B,
                                            ),
                                          )
                                        : SizedBox.shrink()),
                              ),
                              SizedBox(
                                height: 2,
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                width: 200.w,
                                height: 16,
                                child: Text(
                                    isOldCart
                                        ? oldCartCollection![index].name ?? ""
                                        : cartCollection![index].name ?? "",
                                    style: context.textTheme.bodyMedium?.ra
                                        .copyWith(
                                            fontSize: 12,
                                            color: const Color(0xff505050),
                                            letterSpacing: 0.18,
                                            height: 1.33)),
                              ),
                              SizedBox(
                                height: 2,
                              ),
                              Container(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    isOldCart &&
                                                oldCartCollection![index]
                                                    .variations
                                                    .isNullOrEmpty ||
                                            (!isOldCart &&
                                                cartCollection![index]
                                                    .variations
                                                    .isNullOrEmpty)
                                        ? SizedBox.shrink()
                                        : !isOldCart &&
                                                    (cartCollection![index]
                                                                .variations![0]
                                                                .color ==
                                                            "" ||
                                                        cartCollection[index]
                                                                .variations![0]
                                                                .color ==
                                                            null) ||
                                                isOldCart &&
                                                    (oldCartCollection![index]
                                                                .variations![0]
                                                                .color ==
                                                            "" ||
                                                        oldCartCollection[index]
                                                                .variations![0]
                                                                .color ==
                                                            null)
                                            ? SizedBox.shrink()
                                            : Container(
                                                margin: EdgeInsets.only(top: 5),
                                                alignment: Alignment.centerLeft,
                                                height: 17,
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
                                                      "Color: ",
                                                      style: context.textTheme
                                                          .bodyMedium?.ra
                                                          .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 12,
                                                              color: const Color(
                                                                  0xff8D8D8D),
                                                              letterSpacing:
                                                                  0.18,
                                                              height: 1.33),
                                                    ),
                                                    Text(
                                                      isOldCart
                                                          ? !oldCartCollection![
                                                                      index]
                                                                  .variations
                                                                  .isNullOrEmpty
                                                              ? oldCartCollection[
                                                                          index]
                                                                      .variations![
                                                                          0]
                                                                      .color ??
                                                                  ""
                                                              : ""
                                                          : !cartCollection![
                                                                      index]
                                                                  .variations
                                                                  .isNullOrEmpty
                                                              ? cartCollection[
                                                                          index]
                                                                      .variations![
                                                                          0]
                                                                      .color ??
                                                                  ""
                                                              : "",
                                                      style: context.textTheme
                                                          .bodyMedium?.mr
                                                          .copyWith(
                                                        fontSize: 13,
                                                        height: 1.33,
                                                        color: const Color(
                                                            (0xff505050)),
                                                        letterSpacing: 0.18,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                    SizedBox(
                                      width: isOldCart &&
                                                  oldCartCollection![index]
                                                      .variations
                                                      .isNullOrEmpty ||
                                              (!isOldCart &&
                                                  cartCollection![index]
                                                      .variations
                                                      .isNullOrEmpty)
                                          ? 0
                                          : !isOldCart &&
                                                      (cartCollection![index]
                                                                  .variations![
                                                                      0]
                                                                  .color ==
                                                              "" ||
                                                          cartCollection[index]
                                                                  .variations![
                                                                      0]
                                                                  .color ==
                                                              null) ||
                                                  isOldCart &&
                                                      (oldCartCollection![index]
                                                                  .variations![
                                                                      0]
                                                                  .color ==
                                                              "" ||
                                                          oldCartCollection[
                                                                      index]
                                                                  .variations![
                                                                      0]
                                                                  .color ==
                                                              null)
                                              ? 0
                                              : 10,
                                    ),
                                    !isOldCart &&
                                                cartCollection![index]
                                                    .variations
                                                    .isNullOrEmpty ||
                                            isOldCart &&
                                                oldCartCollection![index]
                                                    .variations
                                                    .isNullOrEmpty
                                        ? SizedBox.shrink()
                                        : (!isOldCart &&
                                                    (cartCollection![index]
                                                                .variations![0]
                                                                .size ==
                                                            "" ||
                                                        cartCollection[index]
                                                                .variations![0]
                                                                .size ==
                                                            null)) ||
                                                (isOldCart &&
                                                    (oldCartCollection![index]
                                                                .variations![0]
                                                                .size ==
                                                            "" ||
                                                        oldCartCollection[index]
                                                                .variations![0]
                                                                .size ==
                                                            null))
                                            ? SizedBox.shrink()
                                            : Container(
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
                                                      "Size: ",
                                                      style: context.textTheme
                                                          .bodyMedium?.ra
                                                          .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 12,
                                                              color: const Color(
                                                                  0xff8D8D8D),
                                                              letterSpacing:
                                                                  0.18,
                                                              height: 1.33),
                                                    ),
                                                    Text(
                                                      isOldCart
                                                          ? !oldCartCollection![
                                                                      index]
                                                                  .variations
                                                                  .isNullOrEmpty
                                                              ? oldCartCollection[
                                                                          index]
                                                                      .variations![
                                                                          0]
                                                                      .size ??
                                                                  ""
                                                              : ""
                                                          : !cartCollection![
                                                                      index]
                                                                  .variations
                                                                  .isNullOrEmpty
                                                              ? cartCollection[
                                                                          index]
                                                                      .variations![
                                                                          0]
                                                                      .size ??
                                                                  ""
                                                              : "",
                                                      style: context.textTheme
                                                          .bodyMedium?.mr
                                                          .copyWith(
                                                        fontSize: 13,
                                                        height: 1.33,
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
                              ),
                              SizedBox(
                                height: 2.h,
                              ),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  width: 200,
                                  height: 17,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
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
                                        isOldCart
                                            ? " Composed Of: "
                                            : " Composed Of: ",
                                        style: context.textTheme.bodyMedium?.ra
                                            .copyWith(
                                                fontWeight: FontWeight.normal,
                                                fontSize: 12,
                                                color: const Color(0xff8D8D8D),
                                                letterSpacing: 0.18,
                                                height: 1.33),
                                      ),
                                      Text(
                                        isOldCart
                                            ? "${oldCartCollection![index].countOfPieces ?? 1} Piece"
                                            : "${cartCollection![index].countOfPieces ?? 1} Piece",
                                        style: context.textTheme.bodyMedium?.mr
                                            .copyWith(
                                                fontWeight: FontWeight.w100,
                                                fontSize: 12,
                                                color: const Color(0xff505050),
                                                letterSpacing: 0.18,
                                                height: 1.33),
                                      ),
                                    ],
                                  )),
                              SizedBox(
                                height: 2.h,
                              ),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  width: 200,
                                  height: 17,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SvgPicture.asset(
                                        color: Color(0xff8D8D8D),
                                        AppAssets.shappingCartNew,
                                        height: 12,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        isOldCart ? "Shipping: " : "Shipping: ",
                                        style: context.textTheme.bodyMedium?.ra
                                            .copyWith(
                                                fontWeight: FontWeight.normal,
                                                fontSize: 12,
                                                color: const Color(0xff8D8D8D),
                                                letterSpacing: 0.18,
                                                height: 1.33),
                                      ),
                                      Text(
                                        isOldCart
                                            ? "${state.oldcartCollection?[index].shippingDays ?? 0} Day "
                                            : "${state.cartCollection?[index].shippingDays ?? 0} Day ",
                                        style: context.textTheme.bodyMedium?.mr
                                            .copyWith(
                                                fontWeight: FontWeight.w100,
                                                fontSize: 12,
                                                color: const Color(0xff505050),
                                                letterSpacing: 0.18,
                                                height: 1.33),
                                      ),
                                      Text(
                                        isOldCart ? "Details" : "Details",
                                        style: context.textTheme.bodyMedium?.mr
                                            .copyWith(
                                                decoration:
                                                    TextDecoration.underline,
                                                fontWeight: FontWeight.w100,
                                                fontSize: 12,
                                                color: const Color(0xff505050),
                                                letterSpacing: 0.18,
                                                height: 1.33),
                                      ),
                                    ],
                                  )),
                              SizedBox(
                                height: 14.h,
                              ),
                              Container(
                                height: 31.h,
                                width: 265.w,
                                padding: EdgeInsets.only(right: 40.w),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.w),
                                      width: 85.w,
                                      height: 24.h,
                                      child: isOldCart
                                          ? Row(
                                              children: [
                                                InkWell(
                                                    onTap: () {
                                                      GetIt.I<HomeBloc>().add(
                                                          HideItemInOldCartEvent(
                                                              oldCartId:
                                                                  oldCartCollection?[
                                                                          index]
                                                                      .id));
                                                    },
                                                    child: Container(
                                                      height: 60,
                                                      width: 25,
                                                      child: Container(
                                                        alignment:
                                                            Alignment.center,
                                                        width: 12,
                                                        child: SvgPicture.asset(
                                                          AppAssets
                                                              .deletecartSvg,
                                                          width: 12,
                                                        ),
                                                      ),
                                                    )),
                                                Text(
                                                    "${oldCartCollection![index].quantity ?? 0}",
                                                    style: context.textTheme
                                                        .bodyMedium?.mr
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight.w100,
                                                            fontSize: 14,
                                                            color: const Color(
                                                                0xff1D1D1D),
                                                            letterSpacing: 0.18,
                                                            height: 1.33)),
                                                InkWell(
                                                  onTap: () {
                                                    print(
                                                        "2222222222222222222222222222222222222222222222222222");
                                                    int indexess = isOldCart
                                                        ? state
                                                                .productITemForCart[oldCartCollection![index]
                                                                    .productId
                                                                    .toString()]!
                                                                .syncColorImages
                                                                .isNullOrEmpty
                                                            ? -1
                                                            : state.productITemForCart[oldCartCollection[index].productId.toString()]!.syncColorImages!.indexOf(state
                                                                .productITemForCart[
                                                                    oldCartCollection[index]
                                                                        .productId
                                                                        .toString()]!
                                                                .syncColorImages!
                                                                .firstWhere((element) =>
                                                                    element.colorName ==
                                                                    (!oldCartCollection![index].variations.isNullOrEmpty
                                                                        ? oldCartCollection[index].variations![0].color ??
                                                                            ""
                                                                        : "")))
                                                        : state
                                                                .productITemForCart[
                                                                    cartCollection![index]
                                                                        .productId
                                                                        .toString()]!
                                                                .syncColorImages
                                                                .isNullOrEmpty
                                                            ? -1
                                                            : state.productITemForCart[cartCollection[index].productId.toString()]!.syncColorImages!.indexOf(state.productITemForCart[cartCollection[index].productId.toString()]!.syncColorImages!.firstWhere((element) => element.colorName == (!cartCollection![index].variations.isNullOrEmpty ? cartCollection[index].variations![0].color ?? "" : "")));
                                                    if (indexess != -1) {
                                                      BlocProvider.of<HomeBloc>(
                                                              context)
                                                          .add(AddCurrentSelectedColorEvent(
                                                              currentSelectedColor:
                                                                  indexess,
                                                              productId: isOldCart
                                                                  ? oldCartCollection![
                                                                          index]
                                                                      .productId
                                                                      .toString()
                                                                  : cartCollection![
                                                                          index]
                                                                      .productId
                                                                      .toString()));
                                                    }
                                                    HelperFunctions
                                                        .slidingNavigation(
                                                            context,
                                                            ProductDetailsPage(
                                                              productItem: isOldCart
                                                                  ? state
                                                                      .productITemForCart[oldCartCollection![
                                                                          index]
                                                                      .productId
                                                                      .toString()]!
                                                                  : state
                                                                      .productITemForCart[cartCollection![
                                                                          index]
                                                                      .productId
                                                                      .toString()]!,
                                                            ));
                                                  },
                                                  child: Container(
                                                    height: 60,
                                                    width: 25,
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      width: 12,
                                                      child: SvgPicture.asset(
                                                        AppAssets.addCartSvg,
                                                        width: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                            )
                                          : Row(
                                              children: [
                                                InkWell(
                                                    onTap: () {
                                                      print(
                                                          "---------------------------------------------------------------------------------------------------------------");
                                                      (cartCollection![index].quantity ?? 0) > 1
                                                          ? GetIt.I<HomeBloc>().add(UpdateItemInCartEvent(
                                                              maxAllowed: double.tryParse(
                                                                  cartCollection[index].maxAllowedQty ??
                                                                      "0"),
                                                              countOfPieces: cartCollection[index]
                                                                  .countOfPieces,
                                                              currentSize: !cartCollection[index]
                                                                      .variations
                                                                      .isNullOrEmpty
                                                                  ? cartCollection[index].variations![0].size ??
                                                                      ""
                                                                  : "",
                                                              colorName: !cartCollection[index]
                                                                      .variations
                                                                      .isNullOrEmpty
                                                                  ? cartCollection[index]
                                                                          .variations![0]
                                                                          .color ??
                                                                      ""
                                                                  : "",
                                                              productId: cartCollection[index].productId.toString(),
                                                              quantity: (cartCollection[index].quantity ?? 0) - 1,
                                                              image: cartCollection[index].image ?? "",
                                                              cartId: cartCollection[index].id.toString(),
                                                              boutiqueId: cartCollection[index].boutique!.id.toString()))
                                                          : GetIt.I<HomeBloc>().add(RemoveItemFormCartEvent(countOfPieces: cartCollection[index].countOfPieces, image: cartCollection[index].image ?? '', currentSize: !cartCollection[index].variations.isNullOrEmpty ? cartCollection[index].variations![0].size ?? "" : "", ColoName: !cartCollection[index].variations.isNullOrEmpty ? cartCollection[index].variations![0].color ?? "" : "", productId: cartCollection[index].productId.toString(), itemId: cartCollection[index].id.toString(), boutiqueId: cartCollection[index].boutique!.id.toString()));
                                                    },
                                                    child: (cartCollection![
                                                                        index]
                                                                    .quantity ??
                                                                0) >
                                                            1
                                                        ? Container(
                                                            height: 60,
                                                            width: 25,
                                                            child: Container(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              width: 12,
                                                              child: SvgPicture
                                                                  .asset(
                                                                AppAssets
                                                                    .removeCartSvg,
                                                                width: 12,
                                                              ),
                                                            ),
                                                          )
                                                        : Container(
                                                            height: 60,
                                                            width: 25,
                                                            child: Container(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              width: 12,
                                                              child: SvgPicture
                                                                  .asset(
                                                                AppAssets
                                                                    .deletecartSvg,
                                                                width: 12,
                                                              ),
                                                            ),
                                                          )),
                                                Text(
                                                    "${cartCollection[index].quantity ?? 0}",
                                                    style: context.textTheme
                                                        .bodyMedium?.mr
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight.w100,
                                                            fontSize: 14,
                                                            color: const Color(
                                                                0xff1D1D1D),
                                                            letterSpacing: 0.18,
                                                            height: 1.33)),
                                                InkWell(
                                                  onTap: () {
                                                    GetIt.I<HomeBloc>().add(UpdateItemInCartEvent(
                                                        maxAllowed: double.tryParse(
                                                            cartCollection![index].maxAllowedQty ??
                                                                "0"),
                                                        countOfPieces:
                                                            cartCollection[index]
                                                                .countOfPieces,
                                                        currentSize:
                                                            !cartCollection[index]
                                                                    .variations
                                                                    .isNullOrEmpty
                                                                ? cartCollection[index].variations![0].size ??
                                                                    ""
                                                                : "",
                                                        colorName: !cartCollection[index]
                                                                .variations
                                                                .isNullOrEmpty
                                                            ? cartCollection[index]
                                                                    .variations![0]
                                                                    .color ??
                                                                ""
                                                            : "",
                                                        productId: cartCollection[index].productId.toString(),
                                                        quantity: (cartCollection[index].quantity ?? 0) + 1,
                                                        image: cartCollection[index].image ?? "",
                                                        cartId: cartCollection[index].id.toString(),
                                                        boutiqueId: cartCollection[index].boutique!.id.toString()));
                                                  },
                                                  child: Container(
                                                    height: 60,
                                                    width: 25,
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      width: 12,
                                                      child: SvgPicture.asset(
                                                        AppAssets.addCartSvg,
                                                        width: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                            ),
                                    ),
                                    Spacer(),
                                    Container(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            height: 17.h,
                                            child: Row(
                                              children: [
                                                Text(
                                                  isOldCart
                                                      ? (oldCartCollection![
                                                                      index]
                                                                  .priceOfVariant! *
                                                              state
                                                                  .getCurrencyForCountryModel!
                                                                  .data!
                                                                  .currency!
                                                                  .exchangeRate! *
                                                              oldCartCollection[
                                                                      index]
                                                                  .quantity!)
                                                          .toStringAsFixed(state
                                                                  .startingSetting
                                                                  ?.decimalPointSetting ??
                                                              2)
                                                      : (cartCollection![index]
                                                                  .price! *
                                                              state
                                                                  .getCurrencyForCountryModel!
                                                                  .data!
                                                                  .currency!
                                                                  .exchangeRate! *
                                                              cartCollection[
                                                                      index]
                                                                  .quantity!)
                                                          .toStringAsFixed(state
                                                                  .startingSetting
                                                                  ?.decimalPointSetting ??
                                                              2),
                                                  style: context
                                                      .textTheme.bodyMedium?.ra
                                                      .copyWith(
                                                          decorationColor:
                                                              Color(0xffC4C2C2),
                                                          fontSize: 14,
                                                          color: isOldCart ||
                                                                  cartCollection![
                                                                              index]
                                                                          .offerPrice ==
                                                                      cartCollection[
                                                                              index]
                                                                          .price
                                                              ? Color(
                                                                  0xff505050)
                                                              : Color(
                                                                  0xffC4C2C2),
                                                          decoration: isOldCart
                                                              ? null
                                                              : cartCollection![
                                                                              index]
                                                                          .offerPrice ==
                                                                      cartCollection[
                                                                              index]
                                                                          .price
                                                                  ? null
                                                                  : TextDecoration
                                                                      .lineThrough),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                    isOldCart
                                                        ? ""
                                                        : cartCollection![index]
                                                                    .offerPrice ==
                                                                cartCollection[
                                                                        index]
                                                                    .price
                                                            ? ""
                                                            : "${(cartCollection[index].offerPrice! * cartCollection[index].quantity! * state.getCurrencyForCountryModel!.data!.currency!.exchangeRate!).toStringAsFixed(state.startingSetting?.decimalPointSetting ?? 2)} ",
                                                    style: context.textTheme
                                                        .bodyMedium?.br
                                                        .copyWith(
                                                      decorationColor:
                                                          Color(0xff505050),
                                                      fontSize: 14,
                                                      color: Color(0xff505050),
                                                    )),
                                                Text(
                                                  widget.priceSymbol ?? '\$',
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
                                          ),
                                          isOldCart
                                              ? SizedBox.shrink()
                                              : Row(
                                                  children: [
                                                    Container(
                                                      width: 10,
                                                      height: 10.h,
                                                      child: SvgPicture.asset(
                                                          AppAssets
                                                              .countItemSvg),
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                        "Saved ${(((cartCollection![index].price! - cartCollection[index].offerPrice!) / cartCollection[index].price!) * 100).toStringAsFixed(1)}%",
                                                        style: context.textTheme
                                                            .bodyMedium?.ra
                                                            .copyWith(
                                                          fontSize: 8,
                                                          color:
                                                              Color(0xff388CFF),
                                                        ))
                                                  ],
                                                )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          left: 130,
                        ),
                        Positioned(
                          child: Container(
                            alignment: Alignment.center,
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 0.5, color: Color(0xff8D8D8D)),
                                borderRadius:
                                    BorderRadiusDirectional.circular(20)),
                            child: Text(
                              isOldCart ? "${index + 1}" : "${index + 1}",
                              style: context.textTheme.bodyMedium?.ra.copyWith(
                                decorationColor: Color(0xff8D8D8D),
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
                              borderRadius: BorderRadius.circular(15),
                              color: Color(0x707070),
                            ),
                            width: 100.w,
                            height: 40.h,
                            child: !isOldCart &&
                                    cartCollection![index].availableQuantity !=
                                        null &&
                                    ((cartCollection[index].availableQuantity ??
                                            0) <
                                        (cartCollection[index].quantity ?? 0))
                                /*||
                                            isOldCart &&
                                                ((oldCartCollection![groupCartkeys[
                                                                    index]]![
                                                                indexes]
                                                            .availableQuantity ??
                                                        0) <
                                                    (oldCartCollection![groupCartkeys[index]]![
                                                                    indexes]
                                                                .quantity ??
                                                          
                                                        0))*/
                                ? Text(
                                    " Out OF Stock",
                                    style: context.textTheme.bodyMedium?.la
                                        .copyWith(
                                            fontWeight: FontWeight.w100,
                                            fontSize: 12,
                                            color: const Color.fromARGB(
                                                255, 206, 9, 9),
                                            letterSpacing: 0.18,
                                            height: 1.33),
                                  )
                                : SizedBox.shrink(),
                          ),
                          top: 5,
                          right: 20,
                        ),
                        Positioned(
                            bottom: -15,
                            child: isOldCart
                                ? Container(
                                    width: 350.w,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Color(0xffF8F8F8),
                                    ),
                                    margin: EdgeInsets.only(
                                        bottom: 20, left: 20, right: 20),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Color(0xffF8F8F8),
                                      ),
                                      height: 32,
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 10.w,
                                          ),
                                          SvgPicture.asset(
                                              AppAssets.towCartSvg),
                                          Text(" Out Of Bag! ",
                                              style: context
                                                  .textTheme.bodyMedium?.ba
                                                  .copyWith(
                                                fontSize: 12,
                                                color: Color(0xff8D8D8D),
                                              )),
                                          Text("Time Running Out. ",
                                              style: context
                                                  .textTheme.bodyMedium?.ra
                                                  .copyWith(
                                                fontSize: 12,
                                                color: Color(0xff8D8D8D),
                                              )),
                                          Text(" -30:00",
                                              style: context
                                                  .textTheme.bodyMedium?.ba
                                                  .copyWith(
                                                fontSize: 12,
                                                color: Color(0xff8D8D8D),
                                              )),
                                          InkWell(
                                            onTap: () {
                                              print(state
                                                  .productITemForCart.keys
                                                  .toList());
                                              int indexess = isOldCart
                                                  ? state
                                                          .productITemForCart[
                                                              oldCartCollection![index]
                                                                  .productId
                                                                  .toString()]!
                                                          .syncColorImages
                                                          .isNullOrEmpty
                                                      ? -1
                                                      : state.productITemForCart[oldCartCollection[index].productId.toString()]!.syncColorImages!.indexOf(state.productITemForCart[oldCartCollection[index].productId.toString()]!.syncColorImages!
                                                          .firstWhere((element) =>
                                                              element.colorName ==
                                                              (!oldCartCollection![index]
                                                                      .variations
                                                                      .isNullOrEmpty
                                                                  ? oldCartCollection[index].variations![0].color ??
                                                                      ""
                                                                  : "")))
                                                  : state
                                                          .productITemForCart[
                                                              cartCollection![index]
                                                                  .productId
                                                                  .toString()]!
                                                          .syncColorImages
                                                          .isNullOrEmpty
                                                      ? -1
                                                      : state
                                                          .productITemForCart[cartCollection[index].productId.toString()]!
                                                          .syncColorImages!
                                                          .indexOf(state.productITemForCart[cartCollection[index].productId.toString()]!.syncColorImages!.firstWhere((element) => element.colorName == (!cartCollection![index].variations.isNullOrEmpty ? cartCollection[index].variations![0].color ?? "" : "")));
                                              if (indexess != -1) {
                                                BlocProvider.of<HomeBloc>(
                                                        context)
                                                    .add(AddCurrentSelectedColorEvent(
                                                        currentSelectedColor:
                                                            indexess,
                                                        productId: isOldCart
                                                            ? oldCartCollection![
                                                                    index]
                                                                .productId
                                                                .toString()
                                                            : cartCollection![
                                                                    index]
                                                                .productId
                                                                .toString()));
                                              }
                                              HelperFunctions.slidingNavigation(
                                                  context,
                                                  ProductDetailsPage(
                                                    productItem: isOldCart
                                                        ? state.productITemForCart[
                                                            oldCartCollection![
                                                                    index]
                                                                .productId
                                                                .toString()]!
                                                        : state.productITemForCart[
                                                            cartCollection![
                                                                    index]
                                                                .productId
                                                                .toString()]!,
                                                  ));
                                            },
                                            child: Text(" | Add Agin?",
                                                style: context
                                                    .textTheme.bodyMedium?.ra
                                                    .copyWith(
                                                  fontSize: 12,
                                                  color: Color(0xff8D8D8D),
                                                )),
                                          ),
                                          Spacer(),
                                          SvgPicture.asset(
                                              AppAssets.chatWithQuestionSvg),
                                          SizedBox(
                                            width: 10.w,
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                : !(state.cartCollection?[index]
                                            .haveHurryUpNotify ??
                                        false)
                                    ? SizedBox.shrink()
                                    : Container(
                                        width: 350.w,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Color(0xffFDFDEF),
                                        ),
                                        margin: EdgeInsets.only(
                                            bottom: 20, left: 20, right: 20),
                                        child: DottedBorder(
                                            borderPadding: EdgeInsets.zero,
                                            padding: EdgeInsets.zero,
                                            borderType: BorderType.RRect,
                                            strokeCap: StrokeCap.round,
                                            strokeWidth: 0.5,
                                            dashPattern: [3, 3],
                                            radius: Radius.circular(20.0),
                                            color: const Color(0xffD3D3D3),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                color: Color(0xffFDFDEF),
                                              ),
                                              height: 32,
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    width: 10.w,
                                                  ),
                                                  SvgPicture.asset(
                                                      AppAssets.alarmClockSvg),
                                                  Text(" Hurry Up! ",
                                                      style: context.textTheme
                                                          .bodyMedium?.ba
                                                          .copyWith(
                                                        fontSize: 12,
                                                        color:
                                                            Color(0xffA28E5B),
                                                      )),
                                                  Text("Quantity Running Out. ",
                                                      style: context.textTheme
                                                          .bodyMedium?.ra
                                                          .copyWith(
                                                        fontSize: 12,
                                                        color:
                                                            Color(0xffA28E5B),
                                                      )),
                                                  /*         Text(
                                                      " ${state.cartCollection?[index].timeLeftInMinutes}:00",
                                                      style: context.textTheme
                                                          .bodyMedium?.ba
                                                          .copyWith(
                                                        fontSize: 12,
                                                        color:
                                                            Color(0xffA28E5B),
                                                      )),*/
                                                  countDownTimer(
                                                    cartId: state
                                                        .cartCollection?[index]
                                                        .id
                                                        .toString(),
                                                  )
                                                ],
                                              ),
                                            )),
                                      ))
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
