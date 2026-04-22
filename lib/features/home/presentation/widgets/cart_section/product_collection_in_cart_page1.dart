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
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/home/data/models/get_cart_item_model.dart';
import 'package:trydos/features/home/data/models/get_old_cart_model.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/features/home/presentation/pages/product_details_page_new.dart';
import 'package:trydos/features/home/presentation/widgets/cart_section/countdown_timer_widget.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/product_details_image_widget.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/language_service.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';

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
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
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
              current.checkAvailabilityProductCartStatus ||
          previous.convertItemFromcartToOldCartStatus !=
              current.convertItemFromcartToOldCartStatus,
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(1),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: isOldCart
                ? oldCartCollection?.length
                : cartCollection?.length,
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
                  start: 12.w,
                  end: 12.w,
                  bottom: (cartCollection?.length == 0)
                      ? (index == (oldCartCollection?.length ?? 0) - 1) &&
                                isOldCart
                            ? 270.h
                            : 0
                      : (oldCartCollection?.length == 0)
                      ? (index == (cartCollection?.length ?? 0) - 1) &&
                                !isOldCart
                            ? 270.h
                            : 0
                      : (index == (oldCartCollection?.length ?? 0) - 1) &&
                            isOldCart
                      ? 270.h
                      : 0,
                ),
                child: Container(
                  margin: EdgeInsets.only(bottom: 7.h, right: 5.w, left: 5.w),
                  width: 1.sw,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.r),
                    boxShadow: const [
                      BoxShadow(
                        offset: Offset(0, 5),
                        blurRadius: 5,
                        color: Color(0xffF2F2F2),
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 5.h),
                    width: 400.w,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isOldCart
                            ? const Color(0xffFF5F61)
                            : Colors.white,
                      ),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                    height: isOldCart
                        ? 212.h
                        : (state
                                      .cartCollection?[index]
                                      .haveHurryUpNotifyTimeLeft ??
                                  false) ||
                              (state
                                      .cartCollection?[index]
                                      .haveHurryUpNotifyQty ??
                                  false)
                        ? 235.h
                        : 190.h,
                    child: Stack(
                      children: [
                        Positioned(
                          child: InkWell(
                            onTap: () {
                              /*  int indexess = isOldCart
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
                                                  element.colorOption ==
                                                  (!oldCartCollection![index]
                                                          .variations
                                                          .isNullOrEmpty
                                                      ? oldCartCollection[index]
                                                              .variations![0]
                                                              .colorOption ??
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
                                                  element.colorOption ==
                                                  (!cartCollection![index]
                                                          .variations
                                                          .isNullOrEmpty
                                                      ? cartCollection[index]
                                                              .variations![0]
                                                              .colorOption ??
                                                          ""
                                                      : ""),
                                              orElse: () =>
                                                  color.SyncColorImage(
                                                      colorName: "null",
                                                      images: [],
                                                      colorTrend: false),
                                            ));*/

                              /*  if (indexess != -1) {
                                GetIt.I<HomeBloc>().add(
                                    ChangeStatusOFGetProductsDetailsToSuccessEvent(
                                        isStatusInitaial: true));
                                BlocProvider.of<HomeBloc>(context).add(
                                    AddCurrentSelectedColorEvent(
                                        currentSelectedColor: indexess,
                                        productSlug: isOldCart
                                            ? oldCartCollection![index]
                                                .slug
                                                .toString()
                                            : cartCollection![index]
                                                .slug
                                                .toString()));
                              }*/
                              BlocProvider.of<HomeBloc>(context).add(
                                GetFullProductDetailsEvent(
                                  currentColorName: isOldCart
                                      ? (!(oldCartCollection![index]
                                                    .variations ==
                                                null)
                                            ? oldCartCollection[index]
                                                      .variations!
                                                      .colorOption ??
                                                  ""
                                            : "")
                                      : (!(cartCollection![index].variations ==
                                                null)
                                            ? cartCollection[index]
                                                      .variations!
                                                      .colorOption ??
                                                  ""
                                            : ""),
                                  productSlug: isOldCart
                                      ? oldCartCollection![index].slug
                                            .toString()
                                      : cartCollection![index].slug.toString(),
                                ),
                              );
                              Future.delayed(
                                const Duration(milliseconds: 300),
                                () => Navigator.of(context).push(
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                        ) => ProductDetailsPageNew(
                                          productSlugForOpeningChatDirectly:
                                              isOldCart
                                              ? oldCartCollection![index].slug
                                                    .toString()
                                              : cartCollection![index].slug
                                                    .toString(),
                                          productIdForOpeningChatDirectly:
                                              isOldCart
                                              ? oldCartCollection![index]
                                                    .productId
                                                    .toString()
                                              : cartCollection![index].productId
                                                    .toString(),
                                        ),
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.only(top: 10.h),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.r),
                                color: const Color(0x707070),
                              ),
                              width: 110.w,
                              height: 130.h,
                              child: ProductDetailsImageWidget(
                                withInnerShadow: false,
                                imageFit: BoxFit.cover,
                                blurRadius: 0,
                                imageUrl: isOldCart
                                    ? oldCartCollection![index].image
                                    : cartCollection![index].image,
                                width: 116.w,
                                height: 150.h,
                                radius: 15.r,
                              ),
                            ),
                          ),
                          left: LanguageService.languageCode != "ar" ? 0 : null,
                          right: LanguageService.languageCode != "ar"
                              ? null
                              : 0,
                        ),
                        Positioned(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: 10.h),
                                alignment: LanguageService.languageCode != "ar"
                                    ? Alignment.topLeft
                                    : Alignment.topRight,
                                height: 10.h,
                                width: 30.w,
                                child: (isOldCart
                                    ? oldCartCollection![index].brand != null
                                          ? SvgPicture.network(
                                              oldCartCollection[index]
                                                      .brand!
                                                      .icon
                                                      ?.filePath ??
                                                  "",
                                            )
                                          : const SizedBox.shrink()
                                    : cartCollection![index].brand != null
                                    ? SvgPicture.network(
                                        cartCollection[index]
                                                .brand!
                                                .icon
                                                ?.filePath ??
                                            "",
                                      )
                                    : const SizedBox.shrink()),
                              ),
                              SizedBox(height: 2.h),
                              Container(
                                alignment: LanguageService.languageCode != "ar"
                                    ? Alignment.centerLeft
                                    : Alignment.centerRight,
                                width: 200.w,
                                height: 16.h,
                                child: Text(
                                  isOldCart
                                      ? oldCartCollection![index].name ?? ""
                                      : cartCollection![index].name ?? "",
                                  style: context.textTheme.bodyMedium?.rq
                                      .copyWith(
                                        fontSize: 13.sp,
                                        color: const Color(0xff505050),
                                        letterSpacing: 0.18,
                                        height: 1.33,
                                      ),
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  isOldCart &&
                                              oldCartCollection![index]
                                                      .variations ==
                                                  null ||
                                          (!isOldCart &&
                                              cartCollection![index]
                                                      .variations ==
                                                  null)
                                      ? const SizedBox.shrink()
                                      : !isOldCart &&
                                                (cartCollection![index]
                                                            .variations!
                                                            .colorOption ==
                                                        "" ||
                                                    cartCollection[index]
                                                            .variations!
                                                            .colorOption ==
                                                        null) ||
                                            isOldCart &&
                                                (oldCartCollection![index]
                                                            .variations!
                                                            .colorOption ==
                                                        "" ||
                                                    oldCartCollection[index]
                                                            .variations!
                                                            .colorOption ==
                                                        null)
                                      ? const SizedBox.shrink()
                                      : Container(
                                          margin: EdgeInsets.only(top: 5.h),
                                          alignment:
                                              LanguageService.languageCode !=
                                                  "ar"
                                              ? Alignment.centerLeft
                                              : Alignment.centerRight,
                                          height: 17.h,
                                          child: Row(
                                            children: [
                                              SvgPicture.asset(
                                                AppAssets.colorPickerSvg,
                                                height: 12.h,
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                "${LocaleKeys.color.tr()}: ",
                                                style: context
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.rq
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 12.sp,
                                                      color: const Color(
                                                        0xff8D8D8D,
                                                      ),
                                                      letterSpacing: 0.18,
                                                      height: 1.33,
                                                    ),
                                              ),
                                              Text(
                                                isOldCart
                                                    ? oldCartCollection![index]
                                                                  .variations !=
                                                              null
                                                          ? oldCartCollection[index]
                                                                    .variations!
                                                                    .color ??
                                                                ""
                                                          : ""
                                                    : cartCollection![index]
                                                              .variations !=
                                                          null
                                                    ? cartCollection[index]
                                                              .variations!
                                                              .color ??
                                                          ""
                                                    : "",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: context
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.mq
                                                    .copyWith(
                                                      fontSize: 13.sp,
                                                      height: 1.33,
                                                      color: const Color(
                                                        (0xff505050),
                                                      ),
                                                      letterSpacing: 0.18,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                  SizedBox(
                                    width:
                                        isOldCart &&
                                                oldCartCollection![index]
                                                        .variations ==
                                                    null ||
                                            (!isOldCart &&
                                                cartCollection![index]
                                                        .variations ==
                                                    null)
                                        ? 0
                                        : !isOldCart &&
                                                  (cartCollection![index]
                                                              .variations!
                                                              .colorOption ==
                                                          "" ||
                                                      cartCollection[index]
                                                              .variations!
                                                              .colorOption ==
                                                          null) ||
                                              isOldCart &&
                                                  (oldCartCollection![index]
                                                              .variations!
                                                              .colorOption ==
                                                          "" ||
                                                      oldCartCollection[index]
                                                              .variations!
                                                              .colorOption ==
                                                          null)
                                        ? 0
                                        : 10,
                                  ),
                                  !isOldCart &&
                                              cartCollection![index]
                                                      .variations ==
                                                  null ||
                                          isOldCart &&
                                              oldCartCollection![index]
                                                      .variations ==
                                                  null
                                      ? const SizedBox.shrink()
                                      : (!isOldCart &&
                                                (cartCollection![index]
                                                            .variations!
                                                            .sizeOption ==
                                                        "" ||
                                                    cartCollection[index]
                                                            .variations!
                                                            .sizeOption ==
                                                        null)) ||
                                            (isOldCart &&
                                                (oldCartCollection![index]
                                                            .variations!
                                                            .sizeOption ==
                                                        "" ||
                                                    oldCartCollection[index]
                                                            .variations!
                                                            .sizeOption ==
                                                        null))
                                      ? const SizedBox.shrink()
                                      : Container(
                                          margin: EdgeInsets.only(top: 5.h),
                                          alignment:
                                              LanguageService.languageCode !=
                                                  "ar"
                                              ? Alignment.centerLeft
                                              : Alignment.centerRight,
                                          width: 125.w,
                                          height: 15.h,
                                          child: Row(
                                            children: [
                                              SvgPicture.asset(
                                                AppAssets.sizeIconSvg,
                                                height: 12.h,
                                                // ignore: deprecated_member_use
                                                color: const Color(0xff48C8A8),
                                              ),
                                              SizedBox(width: 5.w),
                                              Text(
                                                "${LocaleKeys.size.tr()}: ",
                                                style: context
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.rq
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 13.sp,
                                                      color: const Color(
                                                        0xff8D8D8D,
                                                      ),
                                                      letterSpacing: 0.18,
                                                      height: 1.2,
                                                    ),
                                              ),
                                              Text(
                                                isOldCart
                                                    ? oldCartCollection![index]
                                                                  .variations !=
                                                              null
                                                          ? oldCartCollection[index]
                                                                    .variations!
                                                                    .size ??
                                                                ""
                                                          : ""
                                                    : cartCollection![index]
                                                              .variations !=
                                                          null
                                                    ? cartCollection[index]
                                                              .variations!
                                                              .size ??
                                                          ""
                                                    : "",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: context
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.mq
                                                    .copyWith(
                                                      fontSize: 13.sp,
                                                      height: 1.2,
                                                      color: const Color(
                                                        (0xff505050),
                                                      ),
                                                      letterSpacing: 0.18,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Container(
                                alignment: LanguageService.languageCode != "ar"
                                    ? Alignment.centerLeft
                                    : Alignment.centerRight,
                                width: 200.w,
                                height: 17.h,
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      // ignore: deprecated_member_use
                                      color: const Color(0xff8D8D8D),
                                      AppAssets.dressSvg,
                                      height: 12.h,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      isOldCart
                                          ? " ${LocaleKeys.composed_of.tr()}: "
                                          : " ${LocaleKeys.composed_of.tr()}: ",
                                      style: context.textTheme.bodyMedium?.rq
                                          .copyWith(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 13.sp,
                                            color: const Color(0xff8D8D8D),
                                            letterSpacing: 0.18,
                                            height: 1.33,
                                          ),
                                    ),
                                    Text(
                                      isOldCart
                                          ? "${oldCartCollection![index].countOfPieces ?? 1} ${LocaleKeys.piece.tr()}"
                                          : "${cartCollection![index].countOfPieces ?? 1} ${LocaleKeys.piece.tr()}",
                                      style: context.textTheme.bodyMedium?.mq
                                          .copyWith(
                                            fontWeight: FontWeight.w100,
                                            fontSize: 13.sp,
                                            color: const Color(0xff505050),
                                            letterSpacing: 0.18,
                                            height: 1.33,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 2.h),
                              (isOldCart &&
                                          state
                                              .oldcartCollection
                                              .isNullOrEmpty) ||
                                      (!isOldCart &&
                                          state.cartCollection.isNullOrEmpty)
                                  ? const SizedBox()
                                  : isOldCart &&
                                        (state
                                                    .oldcartCollection?[index]
                                                    .shippingDays ??
                                                0) ==
                                            0
                                  ? const SizedBox()
                                  : !isOldCart &&
                                        ((state
                                                        .cartCollection?[index]
                                                        .shippingDays ??
                                                    0) +
                                                (state
                                                        .startingSetting
                                                        ?.shippingDay ??
                                                    0)) ==
                                            0
                                  ? const SizedBox()
                                  : Container(
                                      alignment:
                                          LanguageService.languageCode != "ar"
                                          ? Alignment.centerLeft
                                          : Alignment.centerRight,
                                      width: 200.w,
                                      height: 17.h,
                                      child: Row(
                                        children: [
                                          SvgPicture.asset(
                                            // ignore: deprecated_member_use
                                            color: const Color(0xff8D8D8D),
                                            AppAssets.shappingCartNew,
                                            height: 12.h,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            isOldCart
                                                ? "${LocaleKeys.shipping.tr()}: "
                                                : "${LocaleKeys.shipping.tr()}: ",
                                            style: context
                                                .textTheme
                                                .bodyMedium
                                                ?.rq
                                                .copyWith(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 13.sp,
                                                  color: const Color(
                                                    0xff8D8D8D,
                                                  ),
                                                  letterSpacing: 0.18,
                                                  height: 1.33,
                                                ),
                                          ),
                                          Text(
                                            isOldCart
                                                ? "${((state.oldcartCollection?[index].shippingDays ?? 0) + (state.startingSetting?.shippingDay ?? 0))} ${LocaleKeys.day.tr()} "
                                                : "${((state.cartCollection?[index].shippingDays ?? 0) + (state.startingSetting?.shippingDay ?? 0))} ${LocaleKeys.day.tr()} ",
                                            style: context
                                                .textTheme
                                                .bodyMedium
                                                ?.mq
                                                .copyWith(
                                                  fontWeight: FontWeight.w100,
                                                  fontSize: 13.sp,
                                                  color: const Color(
                                                    0xff505050,
                                                  ),
                                                  letterSpacing: 0.18,
                                                  height: 1.33,
                                                ),
                                          ),
                                          Text(
                                            isOldCart
                                                ? "${LocaleKeys.details.tr()}"
                                                : "${LocaleKeys.details.tr()}",
                                            strutStyle:
                                                LanguageService.languageCode !=
                                                    "ar"
                                                ? null
                                                : const StrutStyle(
                                                    height: 0.8,
                                                    leading: 0.6,
                                                  ),
                                            style: context
                                                .textTheme
                                                .bodyMedium
                                                ?.mq
                                                .copyWith(
                                                  decoration:
                                                      TextDecoration.underline,
                                                  fontWeight: FontWeight.w100,
                                                  fontSize: 13.sp,
                                                  color: const Color(
                                                    0xff505050,
                                                  ),
                                                  letterSpacing: 0.18,
                                                  height: 1.33,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                              const SizedBox(height: 14),
                              Container(
                                margin: EdgeInsets.only(
                                  left: LanguageService.languageCode == "ar"
                                      ? 10.w
                                      : 0,
                                  right: LanguageService.languageCode == "ar"
                                      ? 0
                                      : 10.w,
                                ),
                                height: 32.h,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 70.w,
                                      height: 24.h,
                                      child: isOldCart
                                          ? Row(
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    GetIt.I<HomeBloc>().add(
                                                      HideItemInOldCartEvent(
                                                        oldCartId:
                                                            oldCartCollection?[index]
                                                                .id,
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    height: 60.h,
                                                    width: 25.w,
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      width: 12.w,
                                                      child: SvgPicture.asset(
                                                        AppAssets.deletecartSvg,
                                                        width: 12.w,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  "${oldCartCollection![index].quantity ?? 0}",
                                                  style: context
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.mq
                                                      .copyWith(
                                                        fontSize: 13.sp,
                                                        color: const Color(
                                                          0xff1D1D1D,
                                                        ),
                                                        letterSpacing: 0.18,
                                                        height: 1.33,
                                                      ),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    BlocProvider.of<HomeBloc>(
                                                      context,
                                                    ).add(
                                                      GetFullProductDetailsEvent(
                                                        currentColorName:
                                                            isOldCart
                                                            ? (oldCartCollection![index]
                                                                          .variations !=
                                                                      null
                                                                  ? oldCartCollection[index]
                                                                            .variations!
                                                                            .colorOption ??
                                                                        ""
                                                                  : "")
                                                            : (cartCollection![index]
                                                                          .variations !=
                                                                      null
                                                                  ? cartCollection[index]
                                                                            .variations!
                                                                            .colorOption ??
                                                                        ""
                                                                  : ""),
                                                        productSlug: isOldCart
                                                            ? oldCartCollection![index]
                                                                  .slug
                                                                  .toString()
                                                            : cartCollection![index]
                                                                  .slug
                                                                  .toString(),
                                                      ),
                                                    );
                                                    Future.delayed(
                                                      const Duration(
                                                        milliseconds: 300,
                                                      ),
                                                      () => Navigator.of(context).push(
                                                        PageRouteBuilder(
                                                          pageBuilder:
                                                              (
                                                                context,
                                                                animation,
                                                                secondaryAnimation,
                                                              ) => ProductDetailsPageNew(
                                                                productSlugForOpeningChatDirectly:
                                                                    isOldCart
                                                                    ? oldCartCollection![index]
                                                                          .slug
                                                                          .toString()
                                                                    : cartCollection![index]
                                                                          .slug
                                                                          .toString(),
                                                                productIdForOpeningChatDirectly:
                                                                    isOldCart
                                                                    ? oldCartCollection![index]
                                                                          .productId
                                                                          .toString()
                                                                    : cartCollection![index]
                                                                          .productId
                                                                          .toString(),
                                                              ),
                                                        ),
                                                      ),
                                                    );
                                                    /* print(
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
                                                                    element.colorOption ==
                                                                    (!oldCartCollection![index].variations.isNullOrEmpty
                                                                        ? oldCartCollection[index].variations![0].colorOption ??
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
                                                            : state.productITemForCart[cartCollection[index].productId.toString()]!.syncColorImages!.indexOf(state.productITemForCart[cartCollection[index].productId.toString()]!.syncColorImages!.firstWhere((element) => element.colorOption == (!cartCollection![index].variations.isNullOrEmpty ? cartCollection[index].variations![0].colorOption ?? "" : ""), orElse: () => color.SyncColorImage(colorName: "null", images: [], colorTrend: false)));
                                                    if (indexess != -1) {
                                                      GetIt.I<HomeBloc>().add(
                                                          ChangeStatusOFGetProductsDetailsToSuccessEvent(
                                                              isStatusInitaial:
                                                                  true));
                                                      BlocProvider.of<HomeBloc>(
                                                              context)
                                                          .add(AddCurrentSelectedColorEvent(
                                                              currentSelectedColor:
                                                                  indexess,
                                                              productSlug: isOldCart
                                                                  ? oldCartCollection![
                                                                          index]
                                                                      .slug
                                                                      .toString()
                                                                  : cartCollection![
                                                                          index]
                                                                      .slug
                                                                      .toString()));
                                                    }
                                                    Future.delayed(
                                                        Duration(
                                                            milliseconds: 300),
                                                        () => HelperFunctions
                                                            .slidingNavigation(
                                                                context,
                                                                ProductDetailsPage(
                                                                  fromCart:
                                                                      true,
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
                                                                )));*/
                                                  },
                                                  child: Container(
                                                    height: 60.h,
                                                    width: 25.w,
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      width: 12.w,
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
                                                        index: index,
                                                      ),
                                                    );
                                                    if (index ==
                                                            (state.currentIndexForUpdateCart ??
                                                                0) &&
                                                        (state.updateItemInCartStatus ==
                                                            UpdateItemInCartStatus
                                                                .loading)) {
                                                      return;
                                                    }
                                                    (cartCollection![index]
                                                                    .quantity ??
                                                                0) >
                                                            1
                                                        ? GetIt.I<HomeBloc>().add(
                                                            UpdateItemInCartEvent(
                                                              fromCartPage:
                                                                  true,
                                                              newQuantity: -1,
                                                              maxAllowed: double.tryParse(
                                                                cartCollection[index]
                                                                        .maxAllowedQty ??
                                                                    "0",
                                                              ),
                                                              currentSize:
                                                                  cartCollection[index]
                                                                          .variations !=
                                                                      null
                                                                  ? cartCollection[index]
                                                                            .variations!
                                                                            .sizeOption ??
                                                                        ""
                                                                  : "",
                                                              colorOption:
                                                                  cartCollection[index]
                                                                          .variations !=
                                                                      null
                                                                  ? cartCollection[index]
                                                                            .variations!
                                                                            .colorOption ??
                                                                        ""
                                                                  : "",
                                                              productId:
                                                                  cartCollection[index]
                                                                      .productId
                                                                      .toString(),
                                                              productName:
                                                                  cartCollection[index]
                                                                      .name
                                                                      .toString(),
                                                              productPrice:
                                                                  cartCollection[index]
                                                                      .price
                                                                      .toString(),
                                                              totalQuantity:
                                                                  (cartCollection[index]
                                                                          .quantity ??
                                                                      0) -
                                                                  1,
                                                              image:
                                                                  cartCollection[index]
                                                                      .image ??
                                                                  "",
                                                              cartId:
                                                                  cartCollection[index]
                                                                      .id
                                                                      .toString(),
                                                              boutiqueId:
                                                                  cartCollection[index]
                                                                      .boutique!
                                                                      .id
                                                                      .toString(),
                                                            ),
                                                          )
                                                        : GetIt.I<HomeBloc>().add(
                                                            RemoveItemFormCartEvent(
                                                              fromCartPage:
                                                                  true,
                                                              image:
                                                                  cartCollection[index]
                                                                      .image ??
                                                                  '',
                                                              currentSize:
                                                                  cartCollection[index]
                                                                          .variations !=
                                                                      null
                                                                  ? cartCollection[index]
                                                                            .variations!
                                                                            .sizeOption ??
                                                                        ""
                                                                  : "",
                                                              colorName:
                                                                  cartCollection[index]
                                                                          .variations !=
                                                                      null
                                                                  ? cartCollection[index]
                                                                            .variations!
                                                                            .colorOption ??
                                                                        ""
                                                                  : "",
                                                              productId:
                                                                  cartCollection[index]
                                                                      .productId
                                                                      .toString(),
                                                              itemId:
                                                                  cartCollection[index]
                                                                      .id
                                                                      .toString(),
                                                              boutiqueId:
                                                                  cartCollection[index]
                                                                      .boutique!
                                                                      .id
                                                                      .toString(),
                                                            ),
                                                          );
                                                  },
                                                  child:
                                                      (cartCollection![index]
                                                                  .quantity ??
                                                              0) >
                                                          1
                                                      ? Container(
                                                          height: 60.h,
                                                          width: 25.w,
                                                          child: Container(
                                                            alignment: Alignment
                                                                .center,
                                                            width: 12,
                                                            child: SvgPicture.asset(
                                                              AppAssets
                                                                  .removeCartSvg,
                                                              width: 12,
                                                            ),
                                                          ),
                                                        )
                                                      : Container(
                                                          height: 60.h,
                                                          width: 25.w,
                                                          child: Container(
                                                            alignment: Alignment
                                                                .center,
                                                            width: 12.w,
                                                            child: SvgPicture.asset(
                                                              AppAssets
                                                                  .deletecartSvg,
                                                              width: 12.w,
                                                            ),
                                                          ),
                                                        ),
                                                ),
                                                ((state.currentIndexForUpdateCart ??
                                                                0) ==
                                                            index) &&
                                                        state.updateItemInCartStatus ==
                                                            UpdateItemInCartStatus
                                                                .loading
                                                    ? TrydosLoader(size: 13.sp)
                                                    : Text(
                                                        "${cartCollection[index].quantity ?? 0}",
                                                        style: context
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.mq
                                                            .copyWith(
                                                              fontSize: 16.sp,
                                                              color:
                                                                  const Color(
                                                                    0xff1D1D1D,
                                                                  ),
                                                              letterSpacing:
                                                                  0.18,
                                                              height: 1.33,
                                                            ),
                                                      ),
                                                InkWell(
                                                  onTap: () {
                                                    homeBloc.add(
                                                      ChangeCurrentIndexForUpdatCartEvent(
                                                        index: index,
                                                      ),
                                                    );

                                                    if (index ==
                                                            (state.currentIndexForUpdateCart ??
                                                                0) &&
                                                        (state.updateItemInCartStatus ==
                                                            UpdateItemInCartStatus
                                                                .loading)) {
                                                      return;
                                                    }
                                                    GetIt.I<HomeBloc>().add(
                                                      UpdateItemInCartEvent(
                                                        fromCartPage: true,
                                                        newQuantity: 1,
                                                        maxAllowed: double.tryParse(
                                                          cartCollection![index]
                                                                  .maxAllowedQty ??
                                                              "0",
                                                        ),
                                                        currentSize:
                                                            cartCollection[index]
                                                                    .variations !=
                                                                null
                                                            ? cartCollection[index]
                                                                      .variations!
                                                                      .sizeOption ??
                                                                  ""
                                                            : "",
                                                        colorOption:
                                                            cartCollection[index]
                                                                    .variations ==
                                                                null
                                                            ? cartCollection[index]
                                                                      .variations!
                                                                      .colorOption ??
                                                                  ""
                                                            : "",
                                                        productId:
                                                            cartCollection[index]
                                                                .productId
                                                                .toString(),
                                                        productName:
                                                            cartCollection[index]
                                                                .name
                                                                .toString(),
                                                        productPrice:
                                                            cartCollection[index]
                                                                .price
                                                                .toString(),
                                                        totalQuantity:
                                                            (cartCollection[index]
                                                                    .quantity ??
                                                                0) +
                                                            1,
                                                        image:
                                                            cartCollection[index]
                                                                .image ??
                                                            "",
                                                        cartId:
                                                            cartCollection[index]
                                                                .id
                                                                .toString(),
                                                        boutiqueId:
                                                            cartCollection[index]
                                                                .boutique!
                                                                .id
                                                                .toString(),
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    height: 60.h,
                                                    width: 25.w,
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      width: 12.w,
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
                                    SizedBox(width: 15.w),
                                    Container(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 5.w,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            height: 16.h,
                                            child: Row(
                                              children: [
                                                Text(
                                                  isOldCart
                                                      ? HelperFunctions.formatNumber(
                                                          numberToFormate:
                                                              (HelperFunctions.truncateToDecimalPlaces(
                                                                oldCartCollection![index]
                                                                    .offerPrice!,
                                                                state
                                                                    .getCurrencyForCountryModel!
                                                                    .data!
                                                                    .currency!
                                                                    .decimalDigits!,
                                                              ) *
                                                              state
                                                                  .getCurrencyForCountryModel!
                                                                  .data!
                                                                  .currency!
                                                                  .exchangeRate! *
                                                              oldCartCollection[index]
                                                                  .quantity!),
                                                        )
                                                      /*  .toStringAsFixed(state
                                                                  .startingSetting
                                                                  ?.decimalPointSetting ??
                                                              2)*/
                                                      : HelperFunctions.formatNumber(
                                                          numberToFormate:
                                                              (HelperFunctions.truncateToDecimalPlaces(
                                                                cartCollection![index]
                                                                    .price!,
                                                                state
                                                                    .getCurrencyForCountryModel!
                                                                    .data!
                                                                    .currency!
                                                                    .decimalDigits!,
                                                              ) *
                                                              state
                                                                  .getCurrencyForCountryModel!
                                                                  .data!
                                                                  .currency!
                                                                  .exchangeRate! *
                                                              cartCollection[index]
                                                                  .quantity!),
                                                        ),
                                                  /* .toStringAsFixed(state
                                                                  .startingSetting
                                                                  ?.decimalPointSetting ??
                                                              2)*/
                                                  style: context.textTheme.bodyMedium?.ra.copyWith(
                                                    decorationColor:
                                                        const Color(0xffC4C2C2),
                                                    fontSize: 13.sp,
                                                    color:
                                                        isOldCart ||
                                                            cartCollection![index]
                                                                    .offerPrice ==
                                                                cartCollection[index]
                                                                    .price
                                                        ? const Color(
                                                            0xff505050,
                                                          )
                                                        : const Color(
                                                            0xffC4C2C2,
                                                          ),
                                                    decoration: isOldCart
                                                        ? null
                                                        : cartCollection![index]
                                                                  .offerPrice ==
                                                              cartCollection[index]
                                                                  .price
                                                        ? null
                                                        : TextDecoration
                                                              .lineThrough,
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  isOldCart
                                                      ? ""
                                                      : cartCollection![index]
                                                                .offerPrice ==
                                                            cartCollection[index]
                                                                .price
                                                      ? ""
                                                      : "${HelperFunctions.formatNumber(numberToFormate: (HelperFunctions.truncateToDecimalPlaces(cartCollection[index].offerPrice!, state.getCurrencyForCountryModel!.data!.currency!.decimalDigits!) * cartCollection[index].quantity! * state.getCurrencyForCountryModel!.data!.currency!.exchangeRate!))
                                                        //.toStringAsFixed(state.startingSetting?.decimalPointSetting ?? 2)
                                                        } ",
                                                  style: context
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.br
                                                      .copyWith(
                                                        decorationColor:
                                                            const Color(
                                                              0xff505050,
                                                            ),
                                                        fontSize: 13.sp,
                                                        color: isOldCart
                                                            ? const Color(
                                                                0xff505050,
                                                              )
                                                            : cartCollection![index]
                                                                      .isRedeem ==
                                                                  true
                                                            ? Colors
                                                                  .deepOrangeAccent
                                                            : const Color(
                                                                0xff505050,
                                                              ),
                                                      ),
                                                ),
                                                Text(
                                                  widget.priceSymbol ?? '\$',
                                                  style: context
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.rq
                                                      .copyWith(
                                                        decorationColor:
                                                            const Color(
                                                              0xffc4c2c2,
                                                            ),
                                                        fontSize: 9.sp,
                                                        color: isOldCart
                                                            ? const Color(
                                                                0xff505050,
                                                              )
                                                            : cartCollection![index]
                                                                      .isRedeem ==
                                                                  true
                                                            ? Colors
                                                                  .deepOrangeAccent
                                                            : const Color(
                                                                0xffc4c2c2,
                                                              ),
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          isOldCart
                                              ? const SizedBox.shrink()
                                              : Row(
                                                  children: [
                                                    Container(
                                                      width: 10.w,
                                                      height: 10.h,
                                                      child: SvgPicture.asset(
                                                        AppAssets.countItemSvg,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                      "${LocaleKeys.saved.tr()} ${(((cartCollection![index].price! - cartCollection[index].offerPrice!) / cartCollection[index].price!) * 100).toStringAsFixed(0)} %",
                                                      style: context
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.rq
                                                          .copyWith(
                                                            fontSize: 9.sp,
                                                            color: const Color(
                                                              0xff388CFF,
                                                            ),
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              isOldCart
                                  ? const SizedBox.shrink()
                                  : InkWell(
                                      onTap: () {
                                        homeBloc.add(
                                          ChangeCurrentIndexForUpdatCartEvent(
                                            index: index,
                                          ),
                                        );
                                        if (index ==
                                                    (state.currentIndexForUpdateCart ??
                                                        0) &&
                                                (state.convertItemFromcartToOldCartStatus ==
                                                    ConvertItemFromcartToOldCartStatus
                                                        .loading) ||
                                            isOldCart) {
                                          return;
                                        }

                                        homeBloc.add(
                                          ConvertItemFromCartToOldCartEvent(
                                            cartId: cartCollection![index].id
                                                .toString(),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            10.r,
                                          ),
                                          color: const Color.fromARGB(
                                            255,
                                            48,
                                            190,
                                            255,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        width: isOldCart ? 0 : null,
                                        height: isOldCart ? 0 : 28.h,
                                        child:
                                            (index ==
                                                    (state.currentIndexForUpdateCart ??
                                                        0) &&
                                                (state.convertItemFromcartToOldCartStatus ==
                                                    ConvertItemFromcartToOldCartStatus
                                                        .loading))
                                            ? TrydosLoader(
                                                size: 20.h,
                                                color: const Color.fromARGB(
                                                  255,
                                                  255,
                                                  255,
                                                  255,
                                                ),
                                              )
                                            : Row(
                                                children: [
                                                  Text(
                                                    " ${LocaleKeys.delay.tr()}  ",
                                                    style: context
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.bq
                                                        .copyWith(
                                                          fontSize: 13.sp,
                                                          color:
                                                              const Color.fromARGB(
                                                                255,
                                                                255,
                                                                255,
                                                                255,
                                                              ),
                                                        ),
                                                  ),
                                                  SvgPicture.asset(
                                                    AppAssets.redeemClockSvg,
                                                    width: 15.w,
                                                    height: 15.h,
                                                    // ignore: deprecated_member_use
                                                    color: const Color.fromARGB(
                                                      255,
                                                      255,
                                                      255,
                                                      255,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                            ],
                          ),
                          left: LanguageService.languageCode != "ar"
                              ? 130.w
                              : null,
                          right: LanguageService.languageCode != "ar"
                              ? null
                              : 130.w,
                        ),
                        Positioned(
                          child: Container(
                            alignment: Alignment.center,
                            width: 30.w,
                            height: 30.h,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 0.5,
                                color: const Color(0xff8D8D8D),
                              ),
                              borderRadius: BorderRadiusDirectional.circular(
                                20.r,
                              ),
                            ),
                            child: Text(
                              isOldCart ? "${index + 1}" : "${index + 1}",
                              style: context.textTheme.bodyMedium?.rq.copyWith(
                                decorationColor: const Color(0xff8D8D8D),
                                fontSize: 13.sp,
                                color: const Color(0xff8D8D8D),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          top: 5.h,
                          right: LanguageService.languageCode != "ar"
                              ? 5.w
                              : null,
                          left: LanguageService.languageCode != "ar"
                              ? null
                              : 5.w,
                        ),

                        //////////////////////
                        Positioned(
                          bottom: -15.h,
                          child: isOldCart
                              ? Container(
                                  width: 375.w,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.r),
                                    color: const Color(0xffF8F8F8),
                                  ),
                                  margin: EdgeInsets.only(
                                    bottom: 20.h,
                                    left: 5.w,
                                    right: 5.w,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20.r),
                                      color: const Color(0xffF8F8F8),
                                    ),
                                    height: 35.h,
                                    child: Row(
                                      children: [
                                        SizedBox(width: 10.w),
                                        SvgPicture.asset(AppAssets.towCartSvg),
                                        Text(
                                          " ${LocaleKeys.out_of_bag.tr()} ",
                                          style: context
                                              .textTheme
                                              .bodyMedium
                                              ?.bq
                                              .copyWith(
                                                fontSize: 13.sp,
                                                color: const Color(0xff8D8D8D),
                                              ),
                                        ),
                                        Text(
                                          "${LocaleKeys.time_running_out.tr()} ",
                                          style: context
                                              .textTheme
                                              .bodyMedium
                                              ?.rq
                                              .copyWith(
                                                fontSize: 13.sp,
                                                color: const Color(0xff8D8D8D),
                                              ),
                                        ),
                                        Text(
                                          " -30:00",
                                          style: context
                                              .textTheme
                                              .bodyMedium
                                              ?.bq
                                              .copyWith(
                                                fontSize: 13.sp,
                                                color: const Color(0xff8D8D8D),
                                              ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            /*print(state.productITemForCart.keys
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
                                                    : state.productITemForCart[oldCartCollection[index].productId.toString()]!.syncColorImages!.indexOf(state
                                                        .productITemForCart[
                                                            oldCartCollection[index]
                                                                .productId
                                                                .toString()]!
                                                        .syncColorImages!
                                                        .firstWhere((element) =>
                                                            element
                                                                .colorOption ==
                                                            (!oldCartCollection![index]
                                                                    .variations
                                                                    .isNullOrEmpty
                                                                ? oldCartCollection[index].variations![0].colorOption ??
                                                                    ""
                                                                : "")))
                                                : state
                                                        .productITemForCart[cartCollection![index].productId.toString()]!
                                                        .syncColorImages
                                                        .isNullOrEmpty
                                                    ? -1
                                                    : state.productITemForCart[cartCollection[index].productId.toString()]!.syncColorImages!.indexOf(state.productITemForCart[cartCollection[index].productId.toString()]!.syncColorImages!.firstWhere((element) => element.colorOption == (!cartCollection![index].variations.isNullOrEmpty ? cartCollection[index].variations![0].colorOption ?? "" : ""), orElse: () => color.SyncColorImage(colorName: "null", images: [], colorTrend: false)));
                                            if (indexess != -1) {
                                              GetIt.I<HomeBloc>().add(
                                                  ChangeStatusOFGetProductsDetailsToSuccessEvent(
                                                      isStatusInitaial: true));
                                              BlocProvider.of<HomeBloc>(context)
                                                  .add(AddCurrentSelectedColorEvent(
                                                      currentSelectedColor:
                                                          indexess,
                                                      productSlug: isOldCart
                                                          ? oldCartCollection![
                                                                  index]
                                                              .slug
                                                              .toString()
                                                          : cartCollection![
                                                                  index]
                                                              .slug
                                                              .toString()));
                                            }
                                            Future.delayed(
                                                Duration(milliseconds: 300),
                                                () => HelperFunctions
                                                    .slidingNavigation(
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
                                                                  cartCollection![
                                                                          index]
                                                                      .productId
                                                                      .toString()]!,
                                                        )));*/
                                            BlocProvider.of<HomeBloc>(
                                              context,
                                            ).add(
                                              GetFullProductDetailsEvent(
                                                currentColorName: isOldCart
                                                    ? (oldCartCollection![index]
                                                                  .variations !=
                                                              null
                                                          ? oldCartCollection[index]
                                                                    .variations!
                                                                    .colorOption ??
                                                                ""
                                                          : "")
                                                    : (cartCollection![index]
                                                                  .variations !=
                                                              null
                                                          ? cartCollection[index]
                                                                    .variations!
                                                                    .colorOption ??
                                                                ""
                                                          : ""),
                                                productSlug: isOldCart
                                                    ? oldCartCollection![index]
                                                          .slug
                                                          .toString()
                                                    : cartCollection![index]
                                                          .slug
                                                          .toString(),
                                              ),
                                            );
                                            Future.delayed(
                                              const Duration(milliseconds: 300),
                                              () => Navigator.of(context).push(
                                                PageRouteBuilder(
                                                  pageBuilder:
                                                      (
                                                        context,
                                                        animation,
                                                        secondaryAnimation,
                                                      ) => ProductDetailsPageNew(
                                                        productSlugForOpeningChatDirectly:
                                                            isOldCart
                                                            ? oldCartCollection![index]
                                                                  .slug
                                                                  .toString()
                                                            : cartCollection![index]
                                                                  .slug
                                                                  .toString(),
                                                        productIdForOpeningChatDirectly:
                                                            isOldCart
                                                            ? oldCartCollection![index]
                                                                  .productId
                                                                  .toString()
                                                            : cartCollection![index]
                                                                  .productId
                                                                  .toString(),
                                                      ),
                                                ),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            " | ${LocaleKeys.add_again.tr()}",
                                            style: context
                                                .textTheme
                                                .bodyMedium
                                                ?.rq
                                                .copyWith(
                                                  fontSize: 13.sp,
                                                  color: const Color(
                                                    0xff8D8D8D,
                                                  ),
                                                ),
                                          ),
                                        ),
                                        const Spacer(),
                                        SvgPicture.asset(
                                          AppAssets.chatWithQuestionSvg,
                                        ),
                                        const SizedBox(width: 5),
                                      ],
                                    ),
                                  ),
                                )
                              : !(state
                                        .cartCollection?[index]
                                        .haveHurryUpNotifyTimeLeft ??
                                    false)
                              ? (state
                                            .cartCollection?[index]
                                            .haveHurryUpNotifyQty ??
                                        false)
                                    ? Container(
                                        width: 315.w,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            20.r,
                                          ),
                                          color: const Color(0xffFDFDEF),
                                        ),
                                        margin: EdgeInsets.only(
                                          bottom: 20.h,
                                          left: 20.w,
                                          right: 20.w,
                                        ),
                                        child: DottedBorder(
                                          padding: EdgeInsets.zero,
                                          borderType: BorderType.RRect,
                                          strokeCap: StrokeCap.round,
                                          strokeWidth: 0.5,
                                          dashPattern: const [3, 3],
                                          radius: Radius.circular(20.r),
                                          color: const Color(0xffD3D3D3),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20.r),
                                              color: const Color(0xffFDFDEF),
                                            ),
                                            height: 32.h,
                                            child: Row(
                                              children: [
                                                SizedBox(width: 10.w),
                                                SvgPicture.asset(
                                                  AppAssets.alarmClockSvg,
                                                ),
                                                Text(
                                                  " ${LocaleKeys.hurry_up.tr()} ",
                                                  style: context
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.bq
                                                      .copyWith(
                                                        fontSize: 13.sp,
                                                        color: const Color(
                                                          0xffA28E5B,
                                                        ),
                                                      ),
                                                ),
                                                Text(
                                                  "${LocaleKeys.quantity_running_out.tr()} ",
                                                  style: context
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.rq
                                                      .copyWith(
                                                        fontSize: 13.sp,
                                                        color: const Color(
                                                          0xffA28E5B,
                                                        ),
                                                      ),
                                                ),
                                                Text(
                                                  " ${state.cartCollection?[index].qtyLeft}",
                                                  style: context
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.bq
                                                      .copyWith(
                                                        fontSize: 13.sp,
                                                        color: const Color(
                                                          0xffA28E5B,
                                                        ),
                                                      ),
                                                ),
                                                Text(
                                                  " ${LocaleKeys.piece.tr()}",
                                                  style: context
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.bq
                                                      .copyWith(
                                                        fontSize: 13.sp,
                                                        color: const Color(
                                                          0xffA28E5B,
                                                        ),
                                                      ),
                                                ),
                                                /*    CountDownTimer(
                                                    cartId: state
                                                        .cartCollection?[index]
                                                        .id
                                                        .toString(),
                                                  )*/
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink()
                              : Container(
                                  width: 315.w,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.r),
                                    color: const Color(0xffFDFDEF),
                                  ),
                                  margin: EdgeInsets.only(
                                    bottom: 20.h,
                                    left: 20.w,
                                    right: 20.w,
                                  ),
                                  child: DottedBorder(
                                    padding: EdgeInsets.zero,
                                    borderType: BorderType.RRect,
                                    strokeCap: StrokeCap.round,
                                    strokeWidth: 0.5,
                                    dashPattern: const [3, 3],
                                    radius: Radius.circular(20.r),
                                    color: const Color(0xffD3D3D3),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          20.r,
                                        ),
                                        color: const Color(0xffFDFDEF),
                                      ),
                                      height: 32.h,
                                      child: Row(
                                        children: [
                                          SizedBox(width: 10.w),
                                          SvgPicture.asset(
                                            AppAssets.alarmClockSvg,
                                          ),
                                          Text(
                                            " ${LocaleKeys.hurry_up.tr()} ",
                                            style: context
                                                .textTheme
                                                .bodyMedium
                                                ?.bq
                                                .copyWith(
                                                  fontSize: 13.sp,
                                                  color: const Color(
                                                    0xffA28E5B,
                                                  ),
                                                ),
                                          ),
                                          Text(
                                            "${LocaleKeys.the_time_will_end.tr()} ",
                                            style: context
                                                .textTheme
                                                .bodyMedium
                                                ?.rq
                                                .copyWith(
                                                  fontSize: 13.sp,
                                                  color: const Color(
                                                    0xffA28E5B,
                                                  ),
                                                ),
                                          ),
                                          CountdownTimerWidget(
                                            initialMinutes:
                                                state
                                                    .cartCollection?[index]
                                                    .timeLeftInMinutes ??
                                                0,
                                            textStyle: context
                                                .textTheme
                                                .bodyMedium
                                                ?.bq
                                                .copyWith(
                                                  fontSize: 13.sp,
                                                  color: const Color(
                                                    0xffA28E5B,
                                                  ),
                                                ),
                                          ),

                                          /*    CountDownTimer(
                                                    cartId: state
                                                        .cartCollection?[index]
                                                        .id
                                                        .toString(),
                                                  )*/
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                        ),

                        ///////////////////////
                        !isOldCart &&
                                (cartCollection![index].isActive == false ||
                                    (cartCollection[index].checkAvailability ==
                                        false) ||
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
                                  width: 100.w,
                                  height: 30.h,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(255, 0, 0, 0),
                                    borderRadius: BorderRadius.circular(10.h),
                                  ),
                                  child: Center(
                                    child: Text(
                                      " ${LocaleKeys.unavailable.tr()}",
                                      style: context.textTheme.bodyMedium?.lq
                                          .copyWith(
                                            fontSize: 13.sp,
                                            color: const Color.fromARGB(
                                              255,
                                              255,
                                              255,
                                              255,
                                            ),
                                            letterSpacing: 0.18,
                                            height: 1.33,
                                          ),
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
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
