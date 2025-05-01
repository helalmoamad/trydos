import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/home/data/models/get_cart_item_model.dart';
import 'package:trydos/features/home/data/models/get_old_cart_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as color;
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/features/home/presentation/pages/product_details_page.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/product_details_image_widget.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/language_service.dart';

class ProductCollectionInCartPage1 extends StatefulWidget {
  ProductCollectionInCartPage1({
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
  State<ProductCollectionInCartPage1> createState() =>
      _ProductCollectionInCartPage1State();
}

class _ProductCollectionInCartPage1State
    extends State<ProductCollectionInCartPage1> {
  late HomeBloc homeBloc;
  @override
  void initState() {
    homeBloc = BlocProvider.of<HomeBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      try {
        BlocProvider.of<HomeBloc>(context).add((SendErrorToMobileErrorLogEvent(
            errorExption: error.exceptionAsString().toString(),
            errorPath: error.stack.toString().split("#")[1],
            urlBackend: "Front Error",
            messageFromeBackend: "Front Error")));
      } catch (e) {}
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };
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
          previous.updateItemInCartStatus != current.updateItemInCartStatus ||
          previous.checkAvailabilityProductCartStatus !=
              current.checkAvailabilityProductCartStatus,
      builder: (context, state) {
        print(
            "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!##########################################${(state.updateItemInCartStatus == UpdateItemInCartStatus.loading)}");
        return Container(
          padding: EdgeInsets.all(1),
          child: ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 0),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
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
                            ? 260
                            : 0
                        : (oldCartCollection?.length == 0)
                            ? (index == (cartCollection?.length ?? 0) - 1) &&
                                    !isOldCart
                                ? 260
                                : 0
                            : (index == (oldCartCollection?.length ?? 0) - 1) &&
                                    isOldCart
                                ? 260
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
                        ? 190
                        : (state.cartCollection?[index]
                                        .haveHurryUpNotifyTimeLeft ??
                                    false) ||
                                (state.cartCollection?[index]
                                        .haveHurryUpNotifyQty ??
                                    false)
                            ? 190
                            : 155,
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
                                      : state.productITemForCart[oldCartCollection[index].productId.toString()]!.syncColorImages!.indexOf(
                                          state.productITemForCart[oldCartCollection[index].productId.toString()]!.syncColorImages!.firstWhere(
                                              (element) =>
                                                  element.colorName ==
                                                  (!oldCartCollection![index]
                                                          .variations
                                                          .isNullOrEmpty
                                                      ? oldCartCollection[index]
                                                              .variations![0]
                                                              .color ??
                                                          ""
                                                      : ""),
                                              orElse: () =>
                                                  color.SyncColorImage(
                                                      colorName: "null",
                                                      images: [],
                                                      colorTrend: false)))
                                  : state.productITemForCart[cartCollection![index].productId.toString()] == null
                                      ? -1
                                      : state.productITemForCart[cartCollection[index].productId.toString()]!.syncColorImages.isNullOrEmpty
                                          ? -1
                                          : state.productITemForCart[cartCollection[index].productId.toString()]!.syncColorImages!.indexOf(state.productITemForCart[cartCollection[index].productId.toString()]!.syncColorImages!.firstWhere(
                                              (element) =>
                                                  element.colorName ==
                                                  (!cartCollection![index]
                                                          .variations
                                                          .isNullOrEmpty
                                                      ? cartCollection[index]
                                                              .variations![0]
                                                              .color ??
                                                          ""
                                                      : ""),
                                              orElse: () =>
                                                  color.SyncColorImage(
                                                      colorName: "null",
                                                      images: [],
                                                      colorTrend: false),
                                            ));

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
                                    fromCart: true,
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
                              margin: EdgeInsets.only(top: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Color(0x707070),
                              ),
                              width: 110,
                              height: 130,
                              child: ProductDetailsImageWidget(
                                withBackGroundShadow: true,
                                withInnerShadow: false,
                                imageFit: BoxFit.cover,
                                blurRadius: 0,
                                imageUrl: isOldCart
                                    ? oldCartCollection![index].image
                                    : cartCollection![index].image,
                                width: 116,
                                height: 150,
                                radius: 15,
                              ),
                            ),
                          ),
                          left: LanguageService.languageCode != "ar" ? 0 : null,
                          right:
                              LanguageService.languageCode != "ar" ? null : 0,
                        ),
                        Positioned(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: 10),
                                alignment: LanguageService.languageCode != "ar"
                                    ? Alignment.topLeft
                                    : Alignment.topRight,
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
                                            fit: BoxFit.contain,
                                          )
                                        : SizedBox.shrink()),
                              ),
                              SizedBox(
                                height: 2,
                              ),
                              Container(
                                alignment: LanguageService.languageCode != "ar"
                                    ? Alignment.centerLeft
                                    : Alignment.centerRight,
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
                                                alignment: LanguageService
                                                            .languageCode !=
                                                        "ar"
                                                    ? Alignment.centerLeft
                                                    : Alignment.centerRight,
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
                                                      "${LocaleKeys.color.tr()}: ",
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
                                                alignment: LanguageService
                                                            .languageCode !=
                                                        "ar"
                                                    ? Alignment.centerLeft
                                                    : Alignment.centerRight,
                                                width: 100,
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
                                                      "${LocaleKeys.size.tr()}: ",
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
                                                              height: 1.2),
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
                                height: 2,
                              ),
                              Container(
                                  alignment:
                                      LanguageService.languageCode != "ar"
                                          ? Alignment.centerLeft
                                          : Alignment.centerRight,
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
                                            ? " ${LocaleKeys.composed_of.tr()}: "
                                            : " ${LocaleKeys.composed_of.tr()}: ",
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
                                            ? "${oldCartCollection![index].countOfPieces ?? 1} ${LocaleKeys.piece.tr()}"
                                            : "${cartCollection![index].countOfPieces ?? 1} ${LocaleKeys.piece.tr()}",
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
                                height: 2,
                              ),
                              (isOldCart &&
                                          state.oldcartCollection
                                              .isNullOrEmpty) ||
                                      (!isOldCart &&
                                          state.cartCollection.isNullOrEmpty)
                                  ? SizedBox()
                                  : isOldCart &&
                                          (state.oldcartCollection?[index]
                                                      .shippingDays ??
                                                  0) ==
                                              0
                                      ? SizedBox()
                                      : !isOldCart &&
                                              (state.cartCollection?[index]
                                                          .shippingDays ??
                                                      0) ==
                                                  0
                                          ? SizedBox()
                                          : Container(
                                              alignment: LanguageService
                                                          .languageCode !=
                                                      "ar"
                                                  ? Alignment.centerLeft
                                                  : Alignment.centerRight,
                                              width: 200,
                                              height: 17,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
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
                                                    isOldCart
                                                        ? "${LocaleKeys.shipping.tr()}: "
                                                        : "${LocaleKeys.shipping.tr()}: ",
                                                    style: context.textTheme
                                                        .bodyMedium?.ra
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            fontSize: 12,
                                                            color: const Color(
                                                                0xff8D8D8D),
                                                            letterSpacing: 0.18,
                                                            height: 1.33),
                                                  ),
                                                  Text(
                                                    isOldCart
                                                        ? "${state.oldcartCollection?[index].shippingDays ?? 0} ${LocaleKeys.day.tr()} "
                                                        : "${state.cartCollection?[index].shippingDays ?? 0} ${LocaleKeys.day.tr()} ",
                                                    style: context.textTheme
                                                        .bodyMedium?.mr
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight.w100,
                                                            fontSize: 12,
                                                            color: const Color(
                                                                0xff505050),
                                                            letterSpacing: 0.18,
                                                            height: 1.33),
                                                  ),
                                                  Text(
                                                    isOldCart
                                                        ? "${LocaleKeys.details.tr()}"
                                                        : "${LocaleKeys.details.tr()}",
                                                    strutStyle: LanguageService
                                                                .languageCode !=
                                                            "ar"
                                                        ? null
                                                        : StrutStyle(
                                                            height: 0.8,
                                                            leading: 0.6),
                                                    style: context.textTheme
                                                        .bodyMedium?.mr
                                                        .copyWith(
                                                            decoration:
                                                                TextDecoration
                                                                    .underline,
                                                            fontWeight:
                                                                FontWeight.w100,
                                                            fontSize: 12,
                                                            color: const Color(
                                                                0xff505050),
                                                            letterSpacing: 0.18,
                                                            height: 1.33),
                                                  ),
                                                ],
                                              )),
                              SizedBox(
                                height: 14,
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                    left: LanguageService.languageCode == "ar"
                                        ? 10.w
                                        : 0,
                                    right: LanguageService.languageCode == "ar"
                                        ? 0
                                        : 10.w),
                                height: 32,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 70.w,
                                      height: 24,
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
                                                      width: 25.w,
                                                      child: Container(
                                                        alignment:
                                                            Alignment.center,
                                                        width: 12,
                                                        child: SvgPicture.asset(
                                                          AppAssets
                                                              .deletecartSvg,
                                                          width: 12.w,
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
                                                            fontSize: 14.sp,
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
                                                            : state.productITemForCart[cartCollection[index].productId.toString()]!.syncColorImages!.indexOf(state.productITemForCart[cartCollection[index].productId.toString()]!.syncColorImages!.firstWhere((element) => element.colorName == (!cartCollection![index].variations.isNullOrEmpty ? cartCollection[index].variations![0].color ?? "" : ""), orElse: () => color.SyncColorImage(colorName: "null", images: [], colorTrend: false)));
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
                                                              fromCart: true,
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
                                                    width: 25.w,
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      width: 12,
                                                      child: SvgPicture.asset(
                                                        AppAssets.addCartSvg,
                                                        width: 12.w,
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
                                                      homeBloc.add(
                                                          ChangeCurrentIndexForUpdatCartEvent(
                                                              index: index));
                                                      if (index ==
                                                              (state.currentIndexForUpdateCart ??
                                                                  0) &&
                                                          (state.updateItemInCartStatus ==
                                                              UpdateItemInCartStatus
                                                                  .loading)) {
                                                        return;
                                                      }
                                                      (cartCollection![index].quantity ?? 0) > 1
                                                          ? GetIt.I<HomeBloc>().add(UpdateItemInCartEvent(
                                                              newQuantity: -1,
                                                              maxAllowed: double.tryParse(
                                                                  cartCollection[index].maxAllowedQty ??
                                                                      "0"),
                                                              currentSize: !cartCollection[index]
                                                                      .variations
                                                                      .isNullOrEmpty
                                                                  ? cartCollection[index].variations![0].size ??
                                                                      ""
                                                                  : "",
                                                              colorName: !cartCollection[index]
                                                                      .variations
                                                                      .isNullOrEmpty
                                                                  ? cartCollection[index].variations![0].color ??
                                                                      ""
                                                                  : "",
                                                              productId:
                                                                  cartCollection[index]
                                                                      .productId
                                                                      .toString(),
                                                              totalQuantity:
                                                                  (cartCollection[index].quantity ?? 0) - 1,
                                                              image: cartCollection[index].image ?? "",
                                                              cartId: cartCollection[index].id.toString(),
                                                              boutiqueId: cartCollection[index].boutique!.id.toString()))
                                                          : GetIt.I<HomeBloc>().add(RemoveItemFormCartEvent(image: cartCollection[index].image ?? '', currentSize: !cartCollection[index].variations.isNullOrEmpty ? cartCollection[index].variations![0].size ?? "" : "", colorName: !cartCollection[index].variations.isNullOrEmpty ? cartCollection[index].variations![0].color ?? "" : "", productId: cartCollection[index].productId.toString(), itemId: cartCollection[index].id.toString(), boutiqueId: cartCollection[index].boutique!.id.toString()));
                                                    },
                                                    child: (cartCollection![
                                                                        index]
                                                                    .quantity ??
                                                                0) >
                                                            1
                                                        ? Container(
                                                            height: 60,
                                                            width: 25.w,
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
                                                            width: 25.w,
                                                            child: Container(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              width: 12,
                                                              child: SvgPicture
                                                                  .asset(
                                                                AppAssets
                                                                    .deletecartSvg,
                                                                width: 12.w,
                                                              ),
                                                            ),
                                                          )),
                                                ((state.currentIndexForUpdateCart ??
                                                                0) ==
                                                            index) &&
                                                        state.updateItemInCartStatus ==
                                                            UpdateItemInCartStatus
                                                                .loading
                                                    ? TrydosLoader(
                                                        size: 14.sp,
                                                      )
                                                    : Text(
                                                        "${cartCollection[index].quantity ?? 0}",
                                                        style: context.textTheme
                                                            .bodyMedium?.mr
                                                            .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w100,
                                                                fontSize: 16.sp,
                                                                color: const Color(
                                                                    0xff1D1D1D),
                                                                letterSpacing:
                                                                    0.18,
                                                                height: 1.33)),
                                                InkWell(
                                                  onTap: () {
                                                    homeBloc.add(
                                                        ChangeCurrentIndexForUpdatCartEvent(
                                                            index: index));

                                                    if (index ==
                                                            (state.currentIndexForUpdateCart ??
                                                                0) &&
                                                        (state.updateItemInCartStatus ==
                                                            UpdateItemInCartStatus
                                                                .loading)) {
                                                      return;
                                                    }
                                                    GetIt.I<HomeBloc>().add(UpdateItemInCartEvent(
                                                        newQuantity: 1,
                                                        maxAllowed: double.tryParse(
                                                            cartCollection![index]
                                                                    .maxAllowedQty ??
                                                                "0"),
                                                        currentSize: !cartCollection[index]
                                                                .variations
                                                                .isNullOrEmpty
                                                            ? cartCollection[index].variations![0].size ??
                                                                ""
                                                            : "",
                                                        colorName: !cartCollection[index]
                                                                .variations
                                                                .isNullOrEmpty
                                                            ? cartCollection[index].variations![0].color ??
                                                                ""
                                                            : "",
                                                        productId: cartCollection[index]
                                                            .productId
                                                            .toString(),
                                                        totalQuantity:
                                                            (cartCollection[index].quantity ?? 0) + 1,
                                                        image: cartCollection[index].image ?? "",
                                                        cartId: cartCollection[index].id.toString(),
                                                        boutiqueId: cartCollection[index].boutique!.id.toString()));
                                                  },
                                                  child: Container(
                                                    height: 60,
                                                    width: 25.w,
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      width: 12,
                                                      child: SvgPicture.asset(
                                                        AppAssets.addCartSvg,
                                                        width: 12.w,
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
                                    SizedBox(
                                      width: 30.w,
                                    ),
                                    Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 5.w),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            height: 17,
                                            child: Row(
                                              children: [
                                                Text(
                                                  isOldCart
                                                      ? HelperFunctions.formatNumber(
                                                          number: (oldCartCollection![
                                                                      index]
                                                                  .priceOfVariant! *
                                                              state
                                                                  .getCurrencyForCountryModel!
                                                                  .data!
                                                                  .currency!
                                                                  .exchangeRate! *
                                                              oldCartCollection[
                                                                      index]
                                                                  .quantity!))
                                                      /*  .toStringAsFixed(state
                                                                  .startingSetting
                                                                  ?.decimalPointSetting ??
                                                              2)*/
                                                      : HelperFunctions.formatNumber(
                                                          number:
                                                              (cartCollection![
                                                                          index]
                                                                      .price! *
                                                                  state
                                                                      .getCurrencyForCountryModel!
                                                                      .data!
                                                                      .currency!
                                                                      .exchangeRate! *
                                                                  cartCollection[
                                                                          index]
                                                                      .quantity!))
                                                  /* .toStringAsFixed(state
                                                                  .startingSetting
                                                                  ?.decimalPointSetting ??
                                                              2)*/
                                                  ,
                                                  style: context
                                                      .textTheme.bodyMedium?.ra
                                                      .copyWith(
                                                          decorationColor:
                                                              Color(0xffC4C2C2),
                                                          fontSize: 12.sp,
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
                                                            : "${HelperFunctions.formatNumber(number: (cartCollection[index].offerPrice! * cartCollection[index].quantity! * state.getCurrencyForCountryModel!.data!.currency!.exchangeRate!))
                                                            //.toStringAsFixed(state.startingSetting?.decimalPointSetting ?? 2)
                                                            } ",
                                                    style: context.textTheme
                                                        .bodyMedium?.br
                                                        .copyWith(
                                                      decorationColor:
                                                          Color(0xff505050),
                                                      fontSize: 14.sp,
                                                      color: Color(0xff505050),
                                                    )),
                                                Text(
                                                  widget.priceSymbol ?? '\$',
                                                  style: context
                                                      .textTheme.bodyMedium?.ra
                                                      .copyWith(
                                                    decorationColor:
                                                        Color(0xffc4c2c2),
                                                    fontSize: 9.sp,
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
                                                      height: 10,
                                                      child: SvgPicture.asset(
                                                          AppAssets
                                                              .countItemSvg),
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                        "${LocaleKeys.saved.tr()} ${(((cartCollection![index].price! - cartCollection[index].offerPrice!) / cartCollection[index].price!) * 100).toStringAsFixed(0)} %",
                                                        style: context.textTheme
                                                            .bodyMedium?.ra
                                                            .copyWith(
                                                          fontSize: 7,
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
                          left:
                              LanguageService.languageCode != "ar" ? 130 : null,
                          right:
                              LanguageService.languageCode != "ar" ? null : 130,
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
                          right:
                              LanguageService.languageCode != "ar" ? 5 : null,
                          left: LanguageService.languageCode != "ar" ? null : 5,
                        ),

                        //////////////////////
                        Positioned(
                          bottom: -15,
                          child: isOldCart
                              ? Container(
                                  width: 310,
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
                                          width: 10,
                                        ),
                                        SvgPicture.asset(AppAssets.towCartSvg),
                                        Text(" ${LocaleKeys.out_of_bag.tr()} ",
                                            style: context
                                                .textTheme.bodyMedium?.ba
                                                .copyWith(
                                              fontSize: 12,
                                              color: Color(0xff8D8D8D),
                                            )),
                                        Text(
                                            "${LocaleKeys.time_running_out.tr()} ",
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
                                            print(state.productITemForCart.keys
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
                                                    : state.productITemForCart[oldCartCollection[index].productId.toString()]!.syncColorImages!.indexOf(
                                                        state.productITemForCart[oldCartCollection[index].productId.toString()]!.syncColorImages!
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
                                                        .indexOf(state.productITemForCart[cartCollection[index].productId.toString()]!.syncColorImages!.firstWhere((element) => element.colorName == (!cartCollection![index].variations.isNullOrEmpty ? cartCollection[index].variations![0].color ?? "" : ""), orElse: () => color.SyncColorImage(colorName: "null", images: [], colorTrend: false)));
                                            if (indexess != -1) {
                                              BlocProvider.of<HomeBloc>(context)
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
                                                  fromCart: true,
                                                  productItem: isOldCart
                                                      ? state.productITemForCart[
                                                          oldCartCollection![
                                                                  index]
                                                              .productId
                                                              .toString()]!
                                                      : state.productITemForCart[
                                                          cartCollection![index]
                                                              .productId
                                                              .toString()]!,
                                                ));
                                          },
                                          child: Text(
                                              " | ${LocaleKeys.add_again.tr()}",
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
                                          width: 10,
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              : !(state.cartCollection?[index]
                                          .haveHurryUpNotifyTimeLeft ??
                                      false)
                                  ? (state.cartCollection?[index]
                                              .haveHurryUpNotifyQty ??
                                          false)
                                      ? Container(
                                          width: 315,
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
                                                      width: 10,
                                                    ),
                                                    SvgPicture.asset(AppAssets
                                                        .alarmClockSvg),
                                                    Text(
                                                        " ${LocaleKeys.hurry_up.tr()} ",
                                                        style: context.textTheme
                                                            .bodyMedium?.ba
                                                            .copyWith(
                                                          fontSize: 12,
                                                          color:
                                                              Color(0xffA28E5B),
                                                        )),
                                                    Text(
                                                        "${LocaleKeys.quantity_running_out.tr()} ",
                                                        style: context.textTheme
                                                            .bodyMedium?.ra
                                                            .copyWith(
                                                          fontSize: 12,
                                                          color:
                                                              Color(0xffA28E5B),
                                                        )),
                                                    Text(
                                                        " ${state.cartCollection?[index].qtyLeft}",
                                                        style: context.textTheme
                                                            .bodyMedium?.ba
                                                            .copyWith(
                                                          fontSize: 12,
                                                          color:
                                                              Color(0xffA28E5B),
                                                        )),
                                                    Text(
                                                        " ${LocaleKeys.piece.tr()}",
                                                        style: context.textTheme
                                                            .bodyMedium?.ba
                                                            .copyWith(
                                                          fontSize: 12,
                                                          color:
                                                              Color(0xffA28E5B),
                                                        )),
                                                    /*    CountDownTimer(
                                                    cartId: state
                                                        .cartCollection?[index]
                                                        .id
                                                        .toString(),
                                                  )*/
                                                  ],
                                                ),
                                              )),
                                        )
                                      : SizedBox.shrink()
                                  : Container(
                                      width: 315,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
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
                                                  width: 10,
                                                ),
                                                SvgPicture.asset(
                                                    AppAssets.alarmClockSvg),
                                                Text(
                                                    " ${LocaleKeys.hurry_up.tr()} ",
                                                    style: context.textTheme
                                                        .bodyMedium?.ba
                                                        .copyWith(
                                                      fontSize: 12,
                                                      color: Color(0xffA28E5B),
                                                    )),
                                                Text(
                                                    "${LocaleKeys.the_time_will_end.tr()} ",
                                                    style: context.textTheme
                                                        .bodyMedium?.ra
                                                        .copyWith(
                                                      fontSize: 12,
                                                      color: Color(0xffA28E5B),
                                                    )),
                                                Text(
                                                    " ${state.cartCollection?[index].timeLeftInMinutes}:00",
                                                    style: context.textTheme
                                                        .bodyMedium?.ba
                                                        .copyWith(
                                                      fontSize: 12,
                                                      color: Color(0xffA28E5B),
                                                    )),

                                                /*    CountDownTimer(
                                                    cartId: state
                                                        .cartCollection?[index]
                                                        .id
                                                        .toString(),
                                                  )*/
                                              ],
                                            ),
                                          )),
                                    ),
                        ),

                        ///////////////////////
                        !isOldCart &&
                                (cartCollection![index].isActive == false ||
                                    cartCollection[index].checkAvailability ==
                                        false ||
                                    cartCollection[index].isCountryRestricted ==
                                        true)
                            ? Positioned(
                                top: 0,
                                right: LanguageService.languageCode != "ar"
                                    ? null
                                    : 0,
                                left: LanguageService.languageCode != "ar"
                                    ? 0
                                    : null,
                                child: Container(
                                    width: 100,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(255, 0, 0, 0),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        " ${LocaleKeys.unavailable.tr()}",
                                        style: context.textTheme.bodyMedium?.la
                                            .copyWith(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                                color: const Color.fromARGB(
                                                    255, 255, 255, 255),
                                                letterSpacing: 0.18,
                                                height: 1.33),
                                      ),
                                    )),
                              )
                            : SizedBox.shrink(),
                        // Positioned(
                        //   top: 5,
                        //   right:
                        //       LanguageService.languageCode != "ar" ? null : 20,
                        //   left:
                        //       LanguageService.languageCode != "ar" ? 20 : null,
                        //   child: Container(
                        //     decoration: BoxDecoration(
                        //       borderRadius: BorderRadius.circular(15),
                        //       color: Color.fromARGB(0, 0, 0, 0),
                        //     ),
                        //     width: 100,
                        //     height: 40,
                        //     child: !isOldCart
                        //         // &&
                        //         //         cartCollection![index].availableQuantity !=
                        //         //             null &&
                        //         //         ((cartCollection[index].availableQuantity ??
                        //         //                 0) <
                        //         //             (cartCollection[index].quantity ?? 0))
                        //         ? Text(
                        //             " ${LocaleKeys.out_of_stock.tr()}",
                        //             style: context.textTheme.bodyMedium?.la
                        //                 .copyWith(
                        //                     fontWeight: FontWeight.w100,
                        //                     fontSize: 12,
                        //                     color: const Color.fromARGB(
                        //                         255, 206, 9, 9),
                        //                     letterSpacing: 0.18,
                        //                     height: 1.33),
                        //           )
                        //         : SizedBox.shrink(),
                        //   ),
                        // ),
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
