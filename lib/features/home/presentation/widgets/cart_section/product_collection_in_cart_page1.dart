// import 'package:dotted_border/dotted_border.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get_it/get_it.dart';
// import 'package:trydos/common/constant/constant.dart';
// import 'package:trydos/common/helper/helper_functions.dart';
// import 'package:trydos/config/theme/typography.dart';
// import 'package:trydos/core/utils/extensions/build_context.dart';
// import 'package:trydos/core/utils/extensions/list.dart';
// import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
// import 'package:trydos/features/home/data/models/get_cart_item_model.dart';
// import 'package:trydos/features/home/data/models/get_old_cart_model.dart';
// import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
// import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
// import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
// import 'package:trydos/features/home/presentation/pages/product_details_page_new.dart';
// import 'package:trydos/features/home/presentation/widgets/cart_section/countdown_timer_widget.dart';
// import 'package:trydos/features/home/presentation/widgets/product_details_body/product_details_image_widget.dart';
// import 'package:trydos/generated/locale_keys.g.dart';
// import 'package:trydos/service/language_service.dart';

// class ProductCollectionInCartPage1 extends StatefulWidget {
//   ProductCollectionInCartPage1({
//     super.key,
//     required this.priceSymbol,
//     required this.oldCartCollection,
//     required this.isOldCart,
//     required this.cartCollection,
//   });

//   final List<Cart>? cartCollection;
//   final List<OldCart>? oldCartCollection;

//   final bool isOldCart;
//   final String? priceSymbol;
//   @override
//   State<ProductCollectionInCartPage1> createState() =>
//       _ProductCollectionInCartPage1State();
// }

// class _ProductCollectionInCartPage1State
//     extends State<ProductCollectionInCartPage1> {
//   late HomeBloc homeBloc;
//   @override
//   void initState() {
//     homeBloc = BlocProvider.of<HomeBloc>(context);
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final List<Cart>? cartCollection;
//     final List<OldCart>? oldCartCollection;
//     final bool isOldCart;

//     isOldCart = widget.isOldCart;
//     oldCartCollection = widget.oldCartCollection;
//     cartCollection = widget.cartCollection;
//     return BlocBuilder<HomeBloc, HomeState>(
//       buildWhen: (previous, current) =>
//           previous.getCartItemsStatus != current.getCartItemsStatus ||
//           previous.getCurrencyForCountryModel !=
//               current.getCurrencyForCountryModel ||
//           previous.hideItemInOldCartStatus != current.hideItemInOldCartStatus ||
//           previous.getOldCartItemsStatus != current.getOldCartItemsStatus ||
//           previous.deleteItemInCartStatus != current.deleteItemInCartStatus ||
//           previous.addItemInCartStatus != current.addItemInCartStatus ||
//           previous.updateItemInCartStatus != current.updateItemInCartStatus ||
//           previous.checkAvailabilityProductCartStatus !=
//               current.checkAvailabilityProductCartStatus ||
//           previous.convertItemFromcartToOldCartStatus !=
//               current.convertItemFromcartToOldCartStatus,
//       builder: (context, state) {
//         return Container(
//           padding: const EdgeInsets.all(1),
//           child: ListView.builder(
//             padding: const EdgeInsets.symmetric(),
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: isOldCart
//                 ? oldCartCollection?.length
//                 : cartCollection?.length,
//             itemBuilder: (context, index) {
//               // double price = 0;

//               /*  if (isOldCart) {
//                 oldCartCollection!.values.toList()[index].forEach((element) {
//                   price = (price + (element.priceOfVariant!)) *
//                       (element.quantity ?? 0);
//                 });
//               } else {
//                 cartCollection!.values.toList()[index].forEach((element) {
//                   price = price + element.offerPrice! * element.quantity!;
//                 });
//               }
//               price = price *
//                   state.getCurrencyForCountryModel!.data!.currency!.exchangeRate!;
//           */
//               return Container(
//                 padding: EdgeInsetsDirectional.only(
//                   start: 12.w,
//                   end: 12.w,
//                   bottom: (cartCollection?.length == 0)
//                       ? (index == (oldCartCollection?.length ?? 0) - 1) &&
//                                 isOldCart
//                             ? 270.h
//                             : 0
//                       : (oldCartCollection?.length == 0)
//                       ? (index == (cartCollection?.length ?? 0) - 1) &&
//                                 !isOldCart
//                             ? 270.h
//                             : 0
//                       : (index == (oldCartCollection?.length ?? 0) - 1) &&
//                             isOldCart
//                       ? 270.h
//                       : 0,
//                 ),
//                 child: Container(
//                   margin: EdgeInsets.only(bottom: 7.h, right: 5.w, left: 5.w),
//                   width: 1.sw,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(15.r),
//                     boxShadow: const [
//                       BoxShadow(
//                         offset: Offset(0, 5),
//                         blurRadius: 5,
//                         color: Color(0xffF2F2F2),
//                         spreadRadius: 2,
//                       ),
//                     ],
//                   ),
//                   child: Container(
//                     margin: EdgeInsets.only(bottom: 5.h),
//                     width: 400.w,
//                     decoration: BoxDecoration(
//                       border: Border.all(
//                         color: isOldCart
//                             ? const Color(0xffFF5F61)
//                             : Colors.white,
//                       ),
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(15.r),
//                     ),
//                     height: isOldCart
//                         ? 212.h
//                         : (state
//                                       .cartCollection?[index]
//                                       .haveHurryUpNotifyTimeLeft ??
//                                   false) ||
//                               (state
//                                       .cartCollection?[index]
//                                       .haveHurryUpNotifyQty ??
//                                   false)
//                         ? 235.h
//                         : 190.h,
//                     child: Stack(
//                       children: [
//                         Positioned(
//                           child: InkWell(
//                             onTap: () {
//                               /*  int indexess = isOldCart
//                                   ? state
//                                           .productITemForCart[
//                                               oldCartCollection![index]
//                                                   .productId
//                                                   .toString()]!
//                                           .syncColorImages
//                                           .isNullOrEmpty
//                                       ? -1
//                                       : state.productITemForCart[oldCartCollection[index].productId.toString()]!.syncColorImages!.indexOf(
//                                           state.productITemForCart[oldCartCollection[index].productId.toString()]!.syncColorImages!.firstWhere(
//                                               (element) =>
//                                                   element.colorOption ==
//                                                   (!oldCartCollection![index]
//                                                           .variations
//                                                           .isNullOrEmpty
//                                                       ? oldCartCollection[index]
//                                                               .variations![0]
//                                                               .colorOption ??
//                                                           ""
//                                                       : ""),
//                                               orElse: () =>
//                                                   color.SyncColorImage(
//                                                       colorName: "null",
//                                                       images: [],
//                                                       colorTrend: false)))
//                                   : state.productITemForCart[cartCollection![index].productId.toString()] == null
//                                       ? -1
//                                       : state.productITemForCart[cartCollection[index].productId.toString()]!.syncColorImages.isNullOrEmpty
//                                           ? -1
//                                           : state.productITemForCart[cartCollection[index].productId.toString()]!.syncColorImages!.indexOf(state.productITemForCart[cartCollection[index].productId.toString()]!.syncColorImages!.firstWhere(
//                                               (element) =>
//                                                   element.colorOption ==
//                                                   (!cartCollection![index]
//                                                           .variations
//                                                           .isNullOrEmpty
//                                                       ? cartCollection[index]
//                                                               .variations![0]
//                                                               .colorOption ??
//                                                           ""
//                                                       : ""),
//                                               orElse: () =>
//                                                   color.SyncColorImage(
//                                                       colorName: "null",
//                                                       images: [],
//                                                       colorTrend: false),
//                                             ));*/

//                               /*  if (indexess != -1) {
//                                 GetIt.I<HomeBloc>().add(
//                                     ChangeStatusOFGetProductsDetailsToSuccessEvent(
//                                         isStatusInitaial: true));
//                                 BlocProvider.of<HomeBloc>(context).add(
//                                     AddCurrentSelectedColorEvent(
//                                         currentSelectedColor: indexess,
//                                         productSlug: isOldCart
//                                             ? oldCartCollection![index]
//                                                 .slug
//                                                 .toString()
//                                             : cartCollection![index]
//                                                 .slug
//                                                 .toString()));
//                               }*/
//                               BlocProvider.of<HomeBloc>(context).add(
//                                 GetFullProductDetailsEvent(
//                                   currentColorName: isOldCart
//                                       ? (!(oldCartCollection![index]
//                                                     .variations ==
//                                                 null)
//                                             ? oldCartCollection[index]
//                                                       .variations!
//                                                       .colorOption ??
//                                                   ""
//                                             : "")
//                                       : (!(cartCollection![index].variations ==
//                                                 null)
//                                             ? cartCollection[index]
//                                                       .variations!
//                                                       .colorOption ??
//                                                   ""
//                                             : ""),
//                                   productSlug: isOldCart
//                                       ? oldCartCollection![index].slug
//                                             .toString()
//                                       : cartCollection![index].slug.toString(),
//                                 ),
//                               );
//                               Future.delayed(
//                                 const Duration(milliseconds: 300),
//                                 () => Navigator.of(context).push(
//                                   PageRouteBuilder(
//                                     pageBuilder:
//                                         (
//                                           context,
//                                           animation,
//                                           secondaryAnimation,
//                                         ) => ProductDetailsPageNew(
//                                           productSlugForOpeningChatDirectly:
//                                               isOldCart
//                                               ? oldCartCollection![index].slug
//                                                     .toString()
//                                               : cartCollection![index].slug
//                                                     .toString(),
//                                           productIdForOpeningChatDirectly:
//                                               isOldCart
//                                               ? oldCartCollection![index]
//                                                     .productId
//                                                     .toString()
//                                               : cartCollection![index].productId
//                                                     .toString(),
//                                         ),
//                                   ),
//                                 ),
//                               );
//                             },
//                             child: Container(
//                               margin: EdgeInsets.only(top: 10.h),
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(15.r),
//                                 color: const Color(0x707070),
//                               ),
//                               width: 110.w,
//                               height: 130.h,
//                               child: ProductDetailsImageWidget(
//                                 withInnerShadow: false,
//                                 imageFit: BoxFit.cover,
//                                 blurRadius: 0,
//                                 imageUrl: isOldCart
//                                     ? oldCartCollection![index].image
//                                     : cartCollection![index].image,
//                                 width: 116.w,
//                                 height: 150.h,
//                                 radius: 15.r,
//                               ),
//                             ),
//                           ),
//                           left: LanguageService.languageCode != "ar" ? 0 : null,
//                           right: LanguageService.languageCode != "ar"
//                               ? null
//                               : 0,
//                         ),
//                         Positioned(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Container(
//                                 margin: EdgeInsets.only(top: 10.h),
//                                 alignment: LanguageService.languageCode != "ar"
//                                     ? Alignment.topLeft
//                                     : Alignment.topRight,
//                                 height: 10.h,
//                                 width: 30.w,
//                                 child: (isOldCart
//                                     ? oldCartCollection![index].brand != null
//                                           ? SvgPicture.network(
//                                               oldCartCollection[index]
//                                                       .brand!
//                                                       .icon
//                                                       ?.filePath ??
//                                                   "",
//                                             )
//                                           : const SizedBox.shrink()
//                                     : cartCollection![index].brand != null
//                                     ? SvgPicture.network(
//                                         cartCollection[index]
//                                                 .brand!
//                                                 .icon
//                                                 ?.filePath ??
//                                             "",
//                                       )
//                                     : const SizedBox.shrink()),
//                               ),
//                               SizedBox(height: 2.h),
//                               Container(
//                                 alignment: LanguageService.languageCode != "ar"
//                                     ? Alignment.centerLeft
//                                     : Alignment.centerRight,
//                                 width: 200.w,
//                                 height: 16.h,
//                                 child: Text(
//                                   isOldCart
//                                       ? oldCartCollection![index].name ?? ""
//                                       : cartCollection![index].name ?? "",
//                                   style: context.textTheme.bodyMedium?.rq
//                                       .copyWith(
//                                         fontSize: 13.sp,
//                                         color: const Color(0xff505050),
//                                         letterSpacing: 0.18,
//                                         height: 1.1,
//                                       ),
//                                 ),
//                               ),
//                               SizedBox(height: 2.h),
//                               Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   isOldCart &&
//                                               oldCartCollection![index]
//                                                       .variations ==
//                                                   null ||
//                                           (!isOldCart &&
//                                               cartCollection![index]
//                                                       .variations ==
//                                                   null)
//                                       ? const SizedBox.shrink()
//                                       : !isOldCart &&
//                                                 (cartCollection![index]
//                                                             .variations!
//                                                             .colorOption ==
//                                                         "" ||
//                                                     cartCollection[index]
//                                                             .variations!
//                                                             .colorOption ==
//                                                         null) ||
//                                             isOldCart &&
//                                                 (oldCartCollection![index]
//                                                             .variations!
//                                                             .colorOption ==
//                                                         "" ||
//                                                     oldCartCollection[index]
//                                                             .variations!
//                                                             .colorOption ==
//                                                         null)
//                                       ? const SizedBox.shrink()
//                                       : Container(
//                                           margin: EdgeInsets.only(top: 5.h),
//                                           alignment:
//                                               LanguageService.languageCode !=
//                                                   "ar"
//                                               ? Alignment.centerLeft
//                                               : Alignment.centerRight,
//                                           height: 17.h,
//                                           child: Row(
//                                             children: [
//                                               SvgPicture.asset(
//                                                 AppAssets.colorPickerSvg,
//                                                 height: 12.h,
//                                               ),
//                                               const SizedBox(width: 5),
//                                               Text(
//                                                 "${LocaleKeys.color.tr()}: ",
//                                                 style: context
//                                                     .textTheme
//                                                     .bodyMedium
//                                                     ?.rq
//                                                     .copyWith(
//                                                       fontWeight:
//                                                           FontWeight.normal,
//                                                       fontSize: 12.sp,
//                                                       color: const Color(
//                                                         0xff8D8D8D,
//                                                       ),
//                                                       letterSpacing: 0.18,
//                                                       height: 1.1,
//                                                     ),
//                                               ),
//                                               Text(
//                                                 isOldCart
//                                                     ? oldCartCollection![index]
//                                                                   .variations !=
//                                                               null
//                                                           ? oldCartCollection[index]
//                                                                     .variations!
//                                                                     .color ??
//                                                                 ""
//                                                           : ""
//                                                     : cartCollection![index]
//                                                               .variations !=
//                                                           null
//                                                     ? cartCollection[index]
//                                                               .variations!
//                                                               .color ??
//                                                           ""
//                                                     : "",
//                                                 maxLines: 1,
//                                                 overflow: TextOverflow.ellipsis,
//                                                 style: context
//                                                     .textTheme
//                                                     .bodyMedium
//                                                     ?.mq
//                                                     .copyWith(
//                                                       fontSize: 13.sp,
//                                                       height: 1.1,
//                                                       color: const Color(
//                                                         (0xff505050),
//                                                       ),
//                                                       letterSpacing: 0.18,
//                                                     ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                   SizedBox(
//                                     width:
//                                         isOldCart &&
//                                                 oldCartCollection![index]
//                                                         .variations ==
//                                                     null ||
//                                             (!isOldCart &&
//                                                 cartCollection![index]
//                                                         .variations ==
//                                                     null)
//                                         ? 0
//                                         : !isOldCart &&
//                                                   (cartCollection![index]
//                                                               .variations!
//                                                               .colorOption ==
//                                                           "" ||
//                                                       cartCollection[index]
//                                                               .variations!
//                                                               .colorOption ==
//                                                           null) ||
//                                               isOldCart &&
//                                                   (oldCartCollection![index]
//                                                               .variations!
//                                                               .colorOption ==
//                                                           "" ||
//                                                       oldCartCollection[index]
//                                                               .variations!
//                                                               .colorOption ==
//                                                           null)
//                                         ? 0
//                                         : 10,
//                                   ),
//                                   !isOldCart &&
//                                               cartCollection![index]
//                                                       .variations ==
//                                                   null ||
//                                           isOldCart &&
//                                               oldCartCollection![index]
//                                                       .variations ==
//                                                   null
//                                       ? const SizedBox.shrink()
//                                       : (!isOldCart &&
//                                                 (cartCollection![index]
//                                                             .variations!
//                                                             .sizeOption ==
//                                                         "" ||
//                                                     cartCollection[index]
//                                                             .variations!
//                                                             .sizeOption ==
//                                                         null)) ||
//                                             (isOldCart &&
//                                                 (oldCartCollection![index]
//                                                             .variations!
//                                                             .sizeOption ==
//                                                         "" ||
//                                                     oldCartCollection[index]
//                                                             .variations!
//                                                             .sizeOption ==
//                                                         null))
//                                       ? const SizedBox.shrink()
//                                       : Container(
//                                           margin: EdgeInsets.only(top: 5.h),
//                                           alignment:
//                                               LanguageService.languageCode !=
//                                                   "ar"
//                                               ? Alignment.centerLeft
//                                               : Alignment.centerRight,

//                                           height: 17.h,
//                                           child: Row(
//                                             children: [
//                                               SvgPicture.asset(
//                                                 AppAssets.sizeIconSvg,
//                                                 height: 12.h,
//                                                 // ignore: deprecated_member_use
//                                                 color: const Color(0xff48C8A8),
//                                               ),
//                                               SizedBox(width: 5.w),
//                                               Text(
//                                                 "${LocaleKeys.size.tr()}: ",
//                                                 style: context
//                                                     .textTheme
//                                                     .bodyMedium
//                                                     ?.rq
//                                                     .copyWith(
//                                                       fontWeight:
//                                                           FontWeight.normal,
//                                                       fontSize: 13.sp,
//                                                       color: const Color(
//                                                         0xff8D8D8D,
//                                                       ),
//                                                       letterSpacing: 0.18,
//                                                       height: 1.1,
//                                                     ),
//                                               ),
//                                               Text(
//                                                 isOldCart
//                                                     ? oldCartCollection![index]
//                                                                   .variations !=
//                                                               null
//                                                           ? oldCartCollection[index]
//                                                                     .variations!
//                                                                     .size ??
//                                                                 ""
//                                                           : ""
//                                                     : cartCollection![index]
//                                                               .variations !=
//                                                           null
//                                                     ? cartCollection[index]
//                                                               .variations!
//                                                               .size ??
//                                                           ""
//                                                     : "",
//                                                 maxLines: 1,
//                                                 overflow: TextOverflow.ellipsis,
//                                                 style: context
//                                                     .textTheme
//                                                     .bodyMedium
//                                                     ?.mq
//                                                     .copyWith(
//                                                       fontSize: 13.sp,
//                                                       height: 1.1,
//                                                       color: const Color(
//                                                         (0xff505050),
//                                                       ),
//                                                       letterSpacing: 0.18,
//                                                     ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                 ],
//                               ),
//                               const SizedBox(height: 2),
//                               Container(
//                                 alignment: LanguageService.languageCode != "ar"
//                                     ? Alignment.centerLeft
//                                     : Alignment.centerRight,
//                                 width: 200.w,
//                                 height: 17.h,
//                                 child: Row(
//                                   children: [
//                                     SvgPicture.asset(
//                                       // ignore: deprecated_member_use
//                                       color: const Color(0xff8D8D8D),
//                                       AppAssets.dressSvg,
//                                       height: 12.h,
//                                     ),
//                                     const SizedBox(width: 5),
//                                     Text(
//                                       isOldCart
//                                           ? " ${LocaleKeys.composed_of.tr()}: "
//                                           : " ${LocaleKeys.composed_of.tr()}: ",
//                                       style: context.textTheme.bodyMedium?.rq
//                                           .copyWith(
//                                             fontWeight: FontWeight.normal,
//                                             fontSize: 13.sp,
//                                             color: const Color(0xff8D8D8D),
//                                             letterSpacing: 0.18,
//                                             height: 1.1,
//                                           ),
//                                     ),
//                                     Text(
//                                       isOldCart
//                                           ? "${oldCartCollection![index].countOfPieces ?? 1} ${LocaleKeys.piece.tr()}"
//                                           : "${cartCollection![index].countOfPieces ?? 1} ${LocaleKeys.piece.tr()}",
//                                       style: context.textTheme.bodyMedium?.mq
//                                           .copyWith(
//                                             fontWeight: FontWeight.w100,
//                                             fontSize: 13.sp,
//                                             color: const Color(0xff505050),
//                                             letterSpacing: 0.18,
//                                             height: 1.1,
//                                           ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               SizedBox(height: 2.h),
//                               (isOldCart &&
//                                           state
//                                               .oldcartCollection
//                                               .isNullOrEmpty) ||
//                                       (!isOldCart &&
//                                           state.cartCollection.isNullOrEmpty)
//                                   ? const SizedBox()
//                                   : isOldCart &&
//                                         (state
//                                                     .oldcartCollection?[index]
//                                                     .shippingDays ??
//                                                 0) ==
//                                             0
//                                   ? const SizedBox()
//                                   : !isOldCart &&
//                                         ((state
//                                                         .cartCollection?[index]
//                                                         .shippingDays ??
//                                                     0) +
//                                                 (state
//                                                         .startingSetting
//                                                         ?.shippingDay ??
//                                                     0)) ==
//                                             0
//                                   ? const SizedBox()
//                                   : Container(
//                                       alignment:
//                                           LanguageService.languageCode != "ar"
//                                           ? Alignment.centerLeft
//                                           : Alignment.centerRight,
//                                       width: 200.w,
//                                       height: 17.h,
//                                       child: Row(
//                                         children: [
//                                           SvgPicture.asset(
//                                             // ignore: deprecated_member_use
//                                             color: const Color(0xff8D8D8D),
//                                             AppAssets.shappingCartNew,
//                                             height: 12.h,
//                                           ),
//                                           const SizedBox(width: 5),
//                                           Text(
//                                             isOldCart
//                                                 ? "${LocaleKeys.shipping.tr()}: "
//                                                 : "${LocaleKeys.shipping.tr()}: ",
//                                             style: context
//                                                 .textTheme
//                                                 .bodyMedium
//                                                 ?.rq
//                                                 .copyWith(
//                                                   fontWeight: FontWeight.normal,
//                                                   fontSize: 13.sp,
//                                                   color: const Color(
//                                                     0xff8D8D8D,
//                                                   ),
//                                                   letterSpacing: 0.18,
//                                                   height: 1.1,
//                                                 ),
//                                           ),
//                                           Text(
//                                             isOldCart
//                                                 ? "${((state.oldcartCollection?[index].shippingDays ?? 0) + (state.startingSetting?.shippingDay ?? 0))} ${LocaleKeys.day.tr()} "
//                                                 : "${((state.cartCollection?[index].shippingDays ?? 0) + (state.startingSetting?.shippingDay ?? 0))} ${LocaleKeys.day.tr()} ",
//                                             style: context
//                                                 .textTheme
//                                                 .bodyMedium
//                                                 ?.mq
//                                                 .copyWith(
//                                                   fontWeight: FontWeight.w100,
//                                                   fontSize: 13.sp,
//                                                   color: const Color(
//                                                     0xff505050,
//                                                   ),
//                                                   letterSpacing: 0.18,
//                                                   height: 1.1,
//                                                 ),
//                                           ),
//                                           Text(
//                                             "${LocaleKeys.details.tr()}",
//                                             strutStyle:
//                                                 LanguageService.languageCode !=
//                                                     "ar"
//                                                 ? null
//                                                 : const StrutStyle(
//                                                     height: 0.8,
//                                                     leading: 0.6,
//                                                   ),
//                                             style: context
//                                                 .textTheme
//                                                 .bodyMedium
//                                                 ?.mq
//                                                 .copyWith(
//                                                   decoration:
//                                                       TextDecoration.underline,
//                                                   fontWeight: FontWeight.w100,
//                                                   fontSize: 13.sp,
//                                                   color: const Color(
//                                                     0xff505050,
//                                                   ),
//                                                   letterSpacing: 0.18,
//                                                   height: 1.33,
//                                                 ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                               const SizedBox(height: 14),
//                               Container(
//                                 margin: EdgeInsets.only(
//                                   left: LanguageService.languageCode == "ar"
//                                       ? 10.w
//                                       : 0,
//                                   right: LanguageService.languageCode == "ar"
//                                       ? 0
//                                       : 10.w,
//                                 ),
//                                 height: 32.h,
//                                 child: Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Container(
//                                       width: 70.w,
//                                       height: 24.h,
//                                       child: isOldCart
//                                           ? Row(
//                                               children: [
//                                                 InkWell(
//                                                   onTap: () {
//                                                     GetIt.I<HomeBloc>().add(
//                                                       HideItemInOldCartEvent(
//                                                         oldCartId:
//                                                             oldCartCollection?[index]
//                                                                 .id,
//                                                       ),
//                                                     );
//                                                   },
//                                                   child: Container(
//                                                     height: 60.h,
//                                                     width: 25.w,
//                                                     child: Container(
//                                                       alignment:
//                                                           Alignment.center,
//                                                       width: 12.w,
//                                                       child: SvgPicture.asset(
//                                                         AppAssets.deletecartSvg,
//                                                         width: 12.w,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 Text(
//                                                   "${oldCartCollection![index].quantity ?? 0}",
//                                                   style: context
//                                                       .textTheme
//                                                       .bodyMedium
//                                                       ?.mq
//                                                       .copyWith(
//                                                         fontSize: 13.sp,
//                                                         color: const Color(
//                                                           0xff1D1D1D,
//                                                         ),
//                                                         letterSpacing: 0.18,
//                                                         height: 1.1,
//                                                       ),
//                                                 ),
//                                                 InkWell(
//                                                   onTap: () {
//                                                     BlocProvider.of<HomeBloc>(
//                                                       context,
//                                                     ).add(
//                                                       GetFullProductDetailsEvent(
//                                                         currentColorName:
//                                                             isOldCart
//                                                             ? (oldCartCollection![index]
//                                                                           .variations !=
//                                                                       null
//                                                                   ? oldCartCollection[index]
//                                                                             .variations!
//                                                                             .colorOption ??
//                                                                         ""
//                                                                   : "")
//                                                             : (cartCollection![index]
//                                                                           .variations !=
//                                                                       null
//                                                                   ? cartCollection[index]
//                                                                             .variations!
//                                                                             .colorOption ??
//                                                                         ""
//                                                                   : ""),
//                                                         productSlug: isOldCart
//                                                             ? oldCartCollection![index]
//                                                                   .slug
//                                                                   .toString()
//                                                             : cartCollection![index]
//                                                                   .slug
//                                                                   .toString(),
//                                                       ),
//                                                     );
//                                                     Future.delayed(
//                                                       const Duration(
//                                                         milliseconds: 300,
//                                                       ),
//                                                       () => Navigator.of(context).push(
//                                                         PageRouteBuilder(
//                                                           pageBuilder:
//                                                               (
//                                                                 context,
//                                                                 animation,
//                                                                 secondaryAnimation,
//                                                               ) => ProductDetailsPageNew(
//                                                                 productSlugForOpeningChatDirectly:
//                                                                     isOldCart
//                                                                     ? oldCartCollection![index]
//                                                                           .slug
//                                                                           .toString()
//                                                                     : cartCollection![index]
//                                                                           .slug
//                                                                           .toString(),
//                                                                 productIdForOpeningChatDirectly:
//                                                                     isOldCart
//                                                                     ? oldCartCollection![index]
//                                                                           .productId
//                                                                           .toString()
//                                                                     : cartCollection![index]
//                                                                           .productId
//                                                                           .toString(),
//                                                               ),
//                                                         ),
//                                                       ),
//                                                     );
//                                                     /* devLog(
//                                                         "2222222222222222222222222222222222222222222222222222");
//                                                     int indexess = isOldCart
//                                                         ? state
//                                                                 .productITemForCart[oldCartCollection![index]
//                                                                     .productId
//                                                                     .toString()]!
//                                                                 .syncColorImages
//                                                                 .isNullOrEmpty
//                                                             ? -1
//                                                             : state.productITemForCart[oldCartCollection[index].productId.toString()]!.syncColorImages!.indexOf(state
//                                                                 .productITemForCart[
//                                                                     oldCartCollection[index]
//                                                                         .productId
//                                                                         .toString()]!
//                                                                 .syncColorImages!
//                                                                 .firstWhere((element) =>
//                                                                     element.colorOption ==
//                                                                     (!oldCartCollection![index].variations.isNullOrEmpty
//                                                                         ? oldCartCollection[index].variations![0].colorOption ??
//                                                                             ""
//                                                                         : "")))
//                                                         : state
//                                                                 .productITemForCart[
//                                                                     cartCollection![index]
//                                                                         .productId
//                                                                         .toString()]!
//                                                                 .syncColorImages
//                                                                 .isNullOrEmpty
//                                                             ? -1
//                                                             : state.productITemForCart[cartCollection[index].productId.toString()]!.syncColorImages!.indexOf(state.productITemForCart[cartCollection[index].productId.toString()]!.syncColorImages!.firstWhere((element) => element.colorOption == (!cartCollection![index].variations.isNullOrEmpty ? cartCollection[index].variations![0].colorOption ?? "" : ""), orElse: () => color.SyncColorImage(colorName: "null", images: [], colorTrend: false)));
//                                                     if (indexess != -1) {
//                                                       GetIt.I<HomeBloc>().add(
//                                                           ChangeStatusOFGetProductsDetailsToSuccessEvent(
//                                                               isStatusInitaial:
//                                                                   true));
//                                                       BlocProvider.of<HomeBloc>(
//                                                               context)
//                                                           .add(AddCurrentSelectedColorEvent(
//                                                               currentSelectedColor:
//                                                                   indexess,
//                                                               productSlug: isOldCart
//                                                                   ? oldCartCollection![
//                                                                           index]
//                                                                       .slug
//                                                                       .toString()
//                                                                   : cartCollection![
//                                                                           index]
//                                                                       .slug
//                                                                       .toString()));
//                                                     }
//                                                     Future.delayed(
//                                                         Duration(
//                                                             milliseconds: 300),
//                                                         () => HelperFunctions
//                                                             .slidingNavigation(
//                                                                 context,
//                                                                 ProductDetailsPage(
//                                                                   fromCart:
//                                                                       true,
//                                                                   productItem: isOldCart
//                                                                       ? state
//                                                                           .productITemForCart[oldCartCollection![
//                                                                               index]
//                                                                           .productId
//                                                                           .toString()]!
//                                                                       : state
//                                                                           .productITemForCart[cartCollection![
//                                                                               index]
//                                                                           .productId
//                                                                           .toString()]!,
//                                                                 )));*/
//                                                   },
//                                                   child: Container(
//                                                     height: 60.h,
//                                                     width: 25.w,
//                                                     child: Container(
//                                                       alignment:
//                                                           Alignment.center,
//                                                       width: 12.w,
//                                                       child: SvgPicture.asset(
//                                                         AppAssets.addCartSvg,
//                                                         width: 12.w,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ],
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment
//                                                       .spaceBetween,
//                                             )
//                                           : Row(
//                                               children: [
//                                                 InkWell(
//                                                   onTap: () {
//                                                     homeBloc.add(
//                                                       ChangeCurrentIndexForUpdatCartEvent(
//                                                         index: index,
//                                                       ),
//                                                     );
//                                                     if (index ==
//                                                             (state.currentIndexForUpdateCart ??
//                                                                 0) &&
//                                                         (state.updateItemInCartStatus ==
//                                                             UpdateItemInCartStatus
//                                                                 .loading)) {
//                                                       return;
//                                                     }
//                                                     (cartCollection![index]
//                                                                     .quantity ??
//                                                                 0) >
//                                                             1
//                                                         ? GetIt.I<HomeBloc>().add(
//                                                             UpdateItemInCartEvent(
//                                                               fromCartPage:
//                                                                   true,
//                                                               newQuantity: -1,
//                                                               maxAllowed: double.tryParse(
//                                                                 cartCollection[index]
//                                                                         .maxAllowedQty ??
//                                                                     "0",
//                                                               ),
//                                                               currentSize:
//                                                                   cartCollection[index]
//                                                                           .variations !=
//                                                                       null
//                                                                   ? cartCollection[index]
//                                                                             .variations!
//                                                                             .sizeOption ??
//                                                                         ""
//                                                                   : "",
//                                                               colorOption:
//                                                                   cartCollection[index]
//                                                                           .variations !=
//                                                                       null
//                                                                   ? cartCollection[index]
//                                                                             .variations!
//                                                                             .colorOption ??
//                                                                         ""
//                                                                   : "",
//                                                               productId:
//                                                                   cartCollection[index]
//                                                                       .productId
//                                                                       .toString(),
//                                                               productName:
//                                                                   cartCollection[index]
//                                                                       .name
//                                                                       .toString(),
//                                                               productPrice:
//                                                                   cartCollection[index]
//                                                                       .price
//                                                                       .toString(),
//                                                               totalQuantity:
//                                                                   (cartCollection[index]
//                                                                           .quantity ??
//                                                                       0) -
//                                                                   1,
//                                                               image:
//                                                                   cartCollection[index]
//                                                                       .image ??
//                                                                   "",
//                                                               cartId:
//                                                                   cartCollection[index]
//                                                                       .id
//                                                                       .toString(),
//                                                               boutiqueId:
//                                                                   cartCollection[index]
//                                                                       .boutique!
//                                                                       .id
//                                                                       .toString(),
//                                                             ),
//                                                           )
//                                                         : GetIt.I<HomeBloc>().add(
//                                                             RemoveItemFormCartEvent(
//                                                               fromCartPage:
//                                                                   true,
//                                                               image:
//                                                                   cartCollection[index]
//                                                                       .image ??
//                                                                   '',
//                                                               currentSize:
//                                                                   cartCollection[index]
//                                                                           .variations !=
//                                                                       null
//                                                                   ? cartCollection[index]
//                                                                             .variations!
//                                                                             .sizeOption ??
//                                                                         ""
//                                                                   : "",
//                                                               colorName:
//                                                                   cartCollection[index]
//                                                                           .variations !=
//                                                                       null
//                                                                   ? cartCollection[index]
//                                                                             .variations!
//                                                                             .colorOption ??
//                                                                         ""
//                                                                   : "",
//                                                               productId:
//                                                                   cartCollection[index]
//                                                                       .productId
//                                                                       .toString(),
//                                                               itemId:
//                                                                   cartCollection[index]
//                                                                       .id
//                                                                       .toString(),
//                                                               boutiqueId:
//                                                                   cartCollection[index]
//                                                                       .boutique!
//                                                                       .id
//                                                                       .toString(),
//                                                             ),
//                                                           );
//                                                   },
//                                                   child:
//                                                       (cartCollection![index]
//                                                                   .quantity ??
//                                                               0) >
//                                                           1
//                                                       ? Container(
//                                                           height: 60.h,
//                                                           width: 25.w,
//                                                           child: Container(
//                                                             alignment: Alignment
//                                                                 .center,
//                                                             width: 12,
//                                                             child: SvgPicture.asset(
//                                                               AppAssets
//                                                                   .removeCartSvg,
//                                                               width: 12,
//                                                             ),
//                                                           ),
//                                                         )
//                                                       : Container(
//                                                           height: 60.h,
//                                                           width: 25.w,
//                                                           child: Container(
//                                                             alignment: Alignment
//                                                                 .center,
//                                                             width: 12.w,
//                                                             child: SvgPicture.asset(
//                                                               AppAssets
//                                                                   .deletecartSvg,
//                                                               width: 12.w,
//                                                             ),
//                                                           ),
//                                                         ),
//                                                 ),
//                                                 ((state.currentIndexForUpdateCart ??
//                                                                 0) ==
//                                                             index) &&
//                                                         state.updateItemInCartStatus ==
//                                                             UpdateItemInCartStatus
//                                                                 .loading
//                                                     ? TrydosLoader(size: 13.sp)
//                                                     : Text(
//                                                         "${cartCollection[index].quantity ?? 0}",
//                                                         style: context
//                                                             .textTheme
//                                                             .bodyMedium
//                                                             ?.mq
//                                                             .copyWith(
//                                                               fontSize: 16.sp,
//                                                               color:
//                                                                   const Color(
//                                                                     0xff1D1D1D,
//                                                                   ),
//                                                               letterSpacing:
//                                                                   0.18,
//                                                               height: 1.1,
//                                                             ),
//                                                       ),
//                                                 InkWell(
//                                                   onTap: () {
//                                                     homeBloc.add(
//                                                       ChangeCurrentIndexForUpdatCartEvent(
//                                                         index: index,
//                                                       ),
//                                                     );

//                                                     if (index ==
//                                                             (state.currentIndexForUpdateCart ??
//                                                                 0) &&
//                                                         (state.updateItemInCartStatus ==
//                                                             UpdateItemInCartStatus
//                                                                 .loading)) {
//                                                       return;
//                                                     }
//                                                     GetIt.I<HomeBloc>().add(
//                                                       UpdateItemInCartEvent(
//                                                         fromCartPage: true,
//                                                         newQuantity: 1,
//                                                         maxAllowed: double.tryParse(
//                                                           cartCollection![index]
//                                                                   .maxAllowedQty ??
//                                                               "0",
//                                                         ),
//                                                         currentSize:
//                                                             cartCollection[index]
//                                                                     .variations !=
//                                                                 null
//                                                             ? cartCollection[index]
//                                                                       .variations!
//                                                                       .sizeOption ??
//                                                                   ""
//                                                             : "",
//                                                         // الشرط كان مقلوباً:
//                                                         // يقرأ `variations!`
//                                                         // حين تكون null، فيرمي
//                                                         // خطأ عند كل ضغطة على +
//                                                         colorOption:
//                                                             cartCollection[index]
//                                                                     .variations !=
//                                                                 null
//                                                             ? cartCollection[index]
//                                                                       .variations!
//                                                                       .colorOption ??
//                                                                   ""
//                                                             : "",
//                                                         productId:
//                                                             cartCollection[index]
//                                                                 .productId
//                                                                 .toString(),
//                                                         productName:
//                                                             cartCollection[index]
//                                                                 .name
//                                                                 .toString(),
//                                                         productPrice:
//                                                             cartCollection[index]
//                                                                 .price
//                                                                 .toString(),
//                                                         totalQuantity:
//                                                             (cartCollection[index]
//                                                                     .quantity ??
//                                                                 0) +
//                                                             1,
//                                                         image:
//                                                             cartCollection[index]
//                                                                 .image ??
//                                                             "",
//                                                         cartId:
//                                                             cartCollection[index]
//                                                                 .id
//                                                                 .toString(),
//                                                         boutiqueId:
//                                                             cartCollection[index]
//                                                                 .boutique!
//                                                                 .id
//                                                                 .toString(),
//                                                       ),
//                                                     );
//                                                   },
//                                                   child: Container(
//                                                     height: 60.h,
//                                                     width: 25.w,
//                                                     child: Container(
//                                                       alignment:
//                                                           Alignment.center,
//                                                       width: 12.w,
//                                                       child: SvgPicture.asset(
//                                                         AppAssets.addCartSvg,
//                                                         width: 12.w,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ],
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment
//                                                       .spaceBetween,
//                                             ),
//                                     ),
//                                     SizedBox(width: 15.w),
//                                     Container(
//                                       margin: EdgeInsets.symmetric(
//                                         horizontal: 5.w,
//                                       ),
//                                       child: Column(
//                                         mainAxisSize: MainAxisSize.min,
//                                         children: [
//                                           Container(
//                                             height: 16.h,
//                                             child: Row(
//                                               children: [
//                                                 Text(
//                                                   isOldCart
//                                                       ? HelperFunctions.formatNumber(
//                                                           numberToFormate:
//                                                               (HelperFunctions.truncateToDecimalPlaces(
//                                                                 oldCartCollection![index]
//                                                                     .offerPrice!,
//                                                                 state
//                                                                     .getCurrencyForCountryModel!
//                                                                     .data!
//                                                                     .currency!
//                                                                     .decimalDigits!,
//                                                               ) *
//                                                               state
//                                                                   .getCurrencyForCountryModel!
//                                                                   .data!
//                                                                   .currency!
//                                                                   .exchangeRate! *
//                                                               oldCartCollection[index]
//                                                                   .quantity!),
//                                                         )
//                                                       /*  .toStringAsFixed(state
//                                                                   .startingSetting
//                                                                   ?.decimalPointSetting ??
//                                                               2)*/
//                                                       : HelperFunctions.formatNumber(
//                                                           numberToFormate:
//                                                               (HelperFunctions.truncateToDecimalPlaces(
//                                                                 cartCollection![index]
//                                                                     .price!,
//                                                                 state
//                                                                     .getCurrencyForCountryModel!
//                                                                     .data!
//                                                                     .currency!
//                                                                     .decimalDigits!,
//                                                               ) *
//                                                               state
//                                                                   .getCurrencyForCountryModel!
//                                                                   .data!
//                                                                   .currency!
//                                                                   .exchangeRate! *
//                                                               cartCollection[index]
//                                                                   .quantity!),
//                                                         ),
//                                                   /* .toStringAsFixed(state
//                                                                   .startingSetting
//                                                                   ?.decimalPointSetting ??
//                                                               2)*/
//                                                   style: context.textTheme.bodyMedium?.ra.copyWith(
//                                                     decorationColor:
//                                                         const Color(0xffC4C2C2),
//                                                     fontSize: 13.sp,
//                                                     color:
//                                                         isOldCart ||
//                                                             cartCollection![index]
//                                                                     .offerPrice ==
//                                                                 cartCollection[index]
//                                                                     .price
//                                                         ? const Color(
//                                                             0xff505050,
//                                                           )
//                                                         : const Color(
//                                                             0xffC4C2C2,
//                                                           ),
//                                                     decoration: isOldCart
//                                                         ? null
//                                                         : cartCollection![index]
//                                                                   .offerPrice ==
//                                                               cartCollection[index]
//                                                                   .price
//                                                         ? null
//                                                         : TextDecoration
//                                                               .lineThrough,
//                                                   ),
//                                                 ),
//                                                 const SizedBox(width: 5),
//                                                 Text(
//                                                   isOldCart
//                                                       ? ""
//                                                       : cartCollection![index]
//                                                                 .offerPrice ==
//                                                             cartCollection[index]
//                                                                 .price
//                                                       ? ""
//                                                       : "${HelperFunctions.formatNumber(numberToFormate: (HelperFunctions.truncateToDecimalPlaces(cartCollection[index].offerPrice!, state.getCurrencyForCountryModel!.data!.currency!.decimalDigits!) * cartCollection[index].quantity! * state.getCurrencyForCountryModel!.data!.currency!.exchangeRate!))
//                                                         //.toStringAsFixed(state.startingSetting?.decimalPointSetting ?? 2)
//                                                         } ",
//                                                   style: context
//                                                       .textTheme
//                                                       .bodyMedium
//                                                       ?.br
//                                                       .copyWith(
//                                                         decorationColor:
//                                                             const Color(
//                                                               0xff505050,
//                                                             ),
//                                                         fontSize: 13.sp,
//                                                         color: isOldCart
//                                                             ? const Color(
//                                                                 0xff505050,
//                                                               )
//                                                             : cartCollection![index]
//                                                                       .isRedeem ==
//                                                                   true
//                                                             ? Colors
//                                                                   .deepOrangeAccent
//                                                             : const Color(
//                                                                 0xff505050,
//                                                               ),
//                                                       ),
//                                                 ),
//                                                 Text(
//                                                   widget.priceSymbol ?? '\$',
//                                                   style: context
//                                                       .textTheme
//                                                       .bodyMedium
//                                                       ?.rq
//                                                       .copyWith(
//                                                         decorationColor:
//                                                             const Color(
//                                                               0xffc4c2c2,
//                                                             ),
//                                                         fontSize: 9.sp,
//                                                         color: isOldCart
//                                                             ? const Color(
//                                                                 0xff505050,
//                                                               )
//                                                             : cartCollection![index]
//                                                                       .isRedeem ==
//                                                                   true
//                                                             ? Colors
//                                                                   .deepOrangeAccent
//                                                             : const Color(
//                                                                 0xffc4c2c2,
//                                                               ),
//                                                       ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                           isOldCart
//                                               ? const SizedBox.shrink()
//                                               : Row(
//                                                   children: [
//                                                     Container(
//                                                       width: 10.w,
//                                                       height: 10.h,
//                                                       child: SvgPicture.asset(
//                                                         AppAssets.countItemSvg,
//                                                       ),
//                                                     ),
//                                                     const SizedBox(width: 5),
//                                                     Text(
//                                                       "${LocaleKeys.saved.tr()} ${(((cartCollection![index].price! - cartCollection[index].offerPrice!) / cartCollection[index].price!) * 100).toStringAsFixed(0)} %",
//                                                       style: context
//                                                           .textTheme
//                                                           .bodyMedium
//                                                           ?.rq
//                                                           .copyWith(
//                                                             fontSize: 9.sp,
//                                                             color: const Color(
//                                                               0xff388CFF,
//                                                             ),
//                                                           ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               isOldCart
//                                   ? const SizedBox.shrink()
//                                   : InkWell(
//                                       onTap: () {
//                                         homeBloc.add(
//                                           ChangeCurrentIndexForUpdatCartEvent(
//                                             index: index,
//                                           ),
//                                         );
//                                         if (index ==
//                                                     (state.currentIndexForUpdateCart ??
//                                                         0) &&
//                                                 (state.convertItemFromcartToOldCartStatus ==
//                                                     ConvertItemFromcartToOldCartStatus
//                                                         .loading) ||
//                                             isOldCart) {
//                                           return;
//                                         }

//                                         homeBloc.add(
//                                           ConvertItemFromCartToOldCartEvent(
//                                             cartId: cartCollection![index].id
//                                                 .toString(),
//                                           ),
//                                         );
//                                       },
//                                       child: Container(
//                                         padding: const EdgeInsets.symmetric(
//                                           horizontal: 3,
//                                         ),
//                                         decoration: BoxDecoration(
//                                           borderRadius: BorderRadius.circular(
//                                             10.r,
//                                           ),
//                                           color: const Color.fromARGB(
//                                             255,
//                                             48,
//                                             190,
//                                             255,
//                                           ),
//                                         ),
//                                         alignment: Alignment.center,
//                                         width: isOldCart ? 0 : null,
//                                         height: isOldCart ? 0 : 28.h,
//                                         child:
//                                             (index ==
//                                                     (state.currentIndexForUpdateCart ??
//                                                         0) &&
//                                                 (state.convertItemFromcartToOldCartStatus ==
//                                                     ConvertItemFromcartToOldCartStatus
//                                                         .loading))
//                                             ? TrydosLoader(
//                                                 size: 20.h,
//                                                 color: const Color.fromARGB(
//                                                   255,
//                                                   255,
//                                                   255,
//                                                   255,
//                                                 ),
//                                               )
//                                             : Row(
//                                                 children: [
//                                                   Text(
//                                                     " ${LocaleKeys.delay.tr()}  ",
//                                                     style: context
//                                                         .textTheme
//                                                         .bodyMedium
//                                                         ?.bq
//                                                         .copyWith(
//                                                           fontSize: 13.sp,
//                                                           color:
//                                                               const Color.fromARGB(
//                                                                 255,
//                                                                 255,
//                                                                 255,
//                                                                 255,
//                                                               ),
//                                                         ),
//                                                   ),
//                                                   SvgPicture.asset(
//                                                     AppAssets.redeemClockSvg,
//                                                     width: 15.w,
//                                                     height: 15.h,
//                                                     // ignore: deprecated_member_use
//                                                     color: const Color.fromARGB(
//                                                       255,
//                                                       255,
//                                                       255,
//                                                       255,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                       ),
//                                     ),
//                             ],
//                           ),
//                           left: LanguageService.languageCode != "ar"
//                               ? 130.w
//                               : null,
//                           right: LanguageService.languageCode != "ar"
//                               ? null
//                               : 130.w,
//                         ),
//                         Positioned(
//                           child: Container(
//                             alignment: Alignment.center,
//                             width: 30.w,
//                             height: 30.h,
//                             decoration: BoxDecoration(
//                               border: Border.all(
//                                 width: 0.5,
//                                 color: const Color(0xff8D8D8D),
//                               ),
//                               borderRadius: BorderRadiusDirectional.circular(
//                                 20.r,
//                               ),
//                             ),
//                             child: Text(
//                               isOldCart ? "${index + 1}" : "${index + 1}",
//                               style: context.textTheme.bodyMedium?.rq.copyWith(
//                                 decorationColor: const Color(0xff8D8D8D),
//                                 fontSize: 13.sp,
//                                 color: const Color(0xff8D8D8D),
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                           top: 5.h,
//                           right: LanguageService.languageCode != "ar"
//                               ? 5.w
//                               : null,
//                           left: LanguageService.languageCode != "ar"
//                               ? null
//                               : 5.w,
//                         ),

//                         //////////////////////
//                         Positioned(
//                           bottom: -15.h,
//                           child: isOldCart
//                               ? Container(
//                                   width: 375.w,
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(20.r),
//                                     color: const Color(0xffF8F8F8),
//                                   ),
//                                   margin: EdgeInsets.only(
//                                     bottom: 20.h,
//                                     left: 5.w,
//                                     right: 5.w,
//                                   ),
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(20.r),
//                                       color: const Color(0xffF8F8F8),
//                                     ),
//                                     height: 35.h,
//                                     child: Row(
//                                       children: [
//                                         SizedBox(width: 10.w),
//                                         SvgPicture.asset(AppAssets.towCartSvg),
//                                         Text(
//                                           " ${LocaleKeys.out_of_bag.tr()} ",
//                                           style: context
//                                               .textTheme
//                                               .bodyMedium
//                                               ?.bq
//                                               .copyWith(
//                                                 fontSize: 13.sp,
//                                                 color: const Color(0xff8D8D8D),
//                                               ),
//                                         ),
//                                         Text(
//                                           "${LocaleKeys.time_running_out.tr()} ",
//                                           style: context
//                                               .textTheme
//                                               .bodyMedium
//                                               ?.rq
//                                               .copyWith(
//                                                 fontSize: 13.sp,
//                                                 color: const Color(0xff8D8D8D),
//                                               ),
//                                         ),
//                                         Text(
//                                           " -30:00",
//                                           style: context
//                                               .textTheme
//                                               .bodyMedium
//                                               ?.bq
//                                               .copyWith(
//                                                 fontSize: 13.sp,
//                                                 color: const Color(0xff8D8D8D),
//                                               ),
//                                         ),
//                                         InkWell(
//                                           onTap: () {
//                                             /*devLog(state.productITemForCart.keys
//                                                 .toList());
//                                             int indexess = isOldCart
//                                                 ? state
//                                                         .productITemForCart[
//                                                             oldCartCollection![index]
//                                                                 .productId
//                                                                 .toString()]!
//                                                         .syncColorImages
//                                                         .isNullOrEmpty
//                                                     ? -1
//                                                     : state.productITemForCart[oldCartCollection[index].productId.toString()]!.syncColorImages!.indexOf(state
//                                                         .productITemForCart[
//                                                             oldCartCollection[index]
//                                                                 .productId
//                                                                 .toString()]!
//                                                         .syncColorImages!
//                                                         .firstWhere((element) =>
//                                                             element
//                                                                 .colorOption ==
//                                                             (!oldCartCollection![index]
//                                                                     .variations
//                                                                     .isNullOrEmpty
//                                                                 ? oldCartCollection[index].variations![0].colorOption ??
//                                                                     ""
//                                                                 : "")))
//                                                 : state
//                                                         .productITemForCart[cartCollection![index].productId.toString()]!
//                                                         .syncColorImages
//                                                         .isNullOrEmpty
//                                                     ? -1
//                                                     : state.productITemForCart[cartCollection[index].productId.toString()]!.syncColorImages!.indexOf(state.productITemForCart[cartCollection[index].productId.toString()]!.syncColorImages!.firstWhere((element) => element.colorOption == (!cartCollection![index].variations.isNullOrEmpty ? cartCollection[index].variations![0].colorOption ?? "" : ""), orElse: () => color.SyncColorImage(colorName: "null", images: [], colorTrend: false)));
//                                             if (indexess != -1) {
//                                               GetIt.I<HomeBloc>().add(
//                                                   ChangeStatusOFGetProductsDetailsToSuccessEvent(
//                                                       isStatusInitaial: true));
//                                               BlocProvider.of<HomeBloc>(context)
//                                                   .add(AddCurrentSelectedColorEvent(
//                                                       currentSelectedColor:
//                                                           indexess,
//                                                       productSlug: isOldCart
//                                                           ? oldCartCollection![
//                                                                   index]
//                                                               .slug
//                                                               .toString()
//                                                           : cartCollection![
//                                                                   index]
//                                                               .slug
//                                                               .toString()));
//                                             }
//                                             Future.delayed(
//                                                 Duration(milliseconds: 300),
//                                                 () => HelperFunctions
//                                                     .slidingNavigation(
//                                                         context,
//                                                         ProductDetailsPage(
//                                                           fromCart: true,
//                                                           productItem: isOldCart
//                                                               ? state.productITemForCart[
//                                                                   oldCartCollection![
//                                                                           index]
//                                                                       .productId
//                                                                       .toString()]!
//                                                               : state.productITemForCart[
//                                                                   cartCollection![
//                                                                           index]
//                                                                       .productId
//                                                                       .toString()]!,
//                                                         )));*/
//                                             BlocProvider.of<HomeBloc>(
//                                               context,
//                                             ).add(
//                                               GetFullProductDetailsEvent(
//                                                 currentColorName: isOldCart
//                                                     ? (oldCartCollection![index]
//                                                                   .variations !=
//                                                               null
//                                                           ? oldCartCollection[index]
//                                                                     .variations!
//                                                                     .colorOption ??
//                                                                 ""
//                                                           : "")
//                                                     : (cartCollection![index]
//                                                                   .variations !=
//                                                               null
//                                                           ? cartCollection[index]
//                                                                     .variations!
//                                                                     .colorOption ??
//                                                                 ""
//                                                           : ""),
//                                                 productSlug: isOldCart
//                                                     ? oldCartCollection![index]
//                                                           .slug
//                                                           .toString()
//                                                     : cartCollection![index]
//                                                           .slug
//                                                           .toString(),
//                                               ),
//                                             );
//                                             Future.delayed(
//                                               const Duration(milliseconds: 300),
//                                               () => Navigator.of(context).push(
//                                                 PageRouteBuilder(
//                                                   pageBuilder:
//                                                       (
//                                                         context,
//                                                         animation,
//                                                         secondaryAnimation,
//                                                       ) => ProductDetailsPageNew(
//                                                         productSlugForOpeningChatDirectly:
//                                                             isOldCart
//                                                             ? oldCartCollection![index]
//                                                                   .slug
//                                                                   .toString()
//                                                             : cartCollection![index]
//                                                                   .slug
//                                                                   .toString(),
//                                                         productIdForOpeningChatDirectly:
//                                                             isOldCart
//                                                             ? oldCartCollection![index]
//                                                                   .productId
//                                                                   .toString()
//                                                             : cartCollection![index]
//                                                                   .productId
//                                                                   .toString(),
//                                                       ),
//                                                 ),
//                                               ),
//                                             );
//                                           },
//                                           child: Text(
//                                             " | ${LocaleKeys.add_again.tr()}",
//                                             style: context
//                                                 .textTheme
//                                                 .bodyMedium
//                                                 ?.rq
//                                                 .copyWith(
//                                                   fontSize: 13.sp,
//                                                   color: const Color(
//                                                     0xff8D8D8D,
//                                                   ),
//                                                 ),
//                                           ),
//                                         ),
//                                         const Spacer(),
//                                         SvgPicture.asset(
//                                           AppAssets.chatWithQuestionSvg,
//                                         ),
//                                         const SizedBox(width: 5),
//                                       ],
//                                     ),
//                                   ),
//                                 )
//                               : !(state
//                                         .cartCollection?[index]
//                                         .haveHurryUpNotifyTimeLeft ??
//                                     false)
//                               ? (state
//                                             .cartCollection?[index]
//                                             .haveHurryUpNotifyQty ??
//                                         false)
//                                     ? Container(
//                                         width: 315.w,
//                                         decoration: BoxDecoration(
//                                           borderRadius: BorderRadius.circular(
//                                             20.r,
//                                           ),
//                                           color: const Color(0xffFDFDEF),
//                                         ),
//                                         margin: EdgeInsets.only(
//                                           bottom: 20.h,
//                                           left: 20.w,
//                                           right: 20.w,
//                                         ),
//                                         child: DottedBorder(
//                                           padding: EdgeInsets.zero,
//                                           borderType: BorderType.RRect,
//                                           strokeCap: StrokeCap.round,
//                                           strokeWidth: 0.5,
//                                           dashPattern: const [3, 3],
//                                           radius: Radius.circular(20.r),
//                                           color: const Color(0xffD3D3D3),
//                                           child: Container(
//                                             decoration: BoxDecoration(
//                                               borderRadius:
//                                                   BorderRadius.circular(20.r),
//                                               color: const Color(0xffFDFDEF),
//                                             ),
//                                             height: 32.h,
//                                             child: Row(
//                                               children: [
//                                                 SizedBox(width: 10.w),
//                                                 SvgPicture.asset(
//                                                   AppAssets.alarmClockSvg,
//                                                 ),
//                                                 Text(
//                                                   " ${LocaleKeys.hurry_up.tr()} ",
//                                                   style: context
//                                                       .textTheme
//                                                       .bodyMedium
//                                                       ?.bq
//                                                       .copyWith(
//                                                         fontSize: 13.sp,
//                                                         color: const Color(
//                                                           0xffA28E5B,
//                                                         ),
//                                                       ),
//                                                 ),
//                                                 Text(
//                                                   "${LocaleKeys.quantity_running_out.tr()} ",
//                                                   style: context
//                                                       .textTheme
//                                                       .bodyMedium
//                                                       ?.rq
//                                                       .copyWith(
//                                                         fontSize: 13.sp,
//                                                         color: const Color(
//                                                           0xffA28E5B,
//                                                         ),
//                                                       ),
//                                                 ),
//                                                 Text(
//                                                   " ${state.cartCollection?[index].qtyLeft}",
//                                                   style: context
//                                                       .textTheme
//                                                       .bodyMedium
//                                                       ?.bq
//                                                       .copyWith(
//                                                         fontSize: 13.sp,
//                                                         color: const Color(
//                                                           0xffA28E5B,
//                                                         ),
//                                                       ),
//                                                 ),
//                                                 Text(
//                                                   " ${LocaleKeys.piece.tr()}",
//                                                   style: context
//                                                       .textTheme
//                                                       .bodyMedium
//                                                       ?.bq
//                                                       .copyWith(
//                                                         fontSize: 13.sp,
//                                                         color: const Color(
//                                                           0xffA28E5B,
//                                                         ),
//                                                       ),
//                                                 ),
//                                                 /*    CountDownTimer(
//                                                     cartId: state
//                                                         .cartCollection?[index]
//                                                         .id
//                                                         .toString(),
//                                                   )*/
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                       )
//                                     : const SizedBox.shrink()
//                               : Container(
//                                   width: 315.w,
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(20.r),
//                                     color: const Color(0xffFDFDEF),
//                                   ),
//                                   margin: EdgeInsets.only(
//                                     bottom: 20.h,
//                                     left: 20.w,
//                                     right: 20.w,
//                                   ),
//                                   child: DottedBorder(
//                                     padding: EdgeInsets.zero,
//                                     borderType: BorderType.RRect,
//                                     strokeCap: StrokeCap.round,
//                                     strokeWidth: 0.5,
//                                     dashPattern: const [3, 3],
//                                     radius: Radius.circular(20.r),
//                                     color: const Color(0xffD3D3D3),
//                                     child: Container(
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(
//                                           20.r,
//                                         ),
//                                         color: const Color(0xffFDFDEF),
//                                       ),
//                                       height: 32.h,
//                                       child: Row(
//                                         children: [
//                                           SizedBox(width: 10.w),
//                                           SvgPicture.asset(
//                                             AppAssets.alarmClockSvg,
//                                           ),
//                                           Text(
//                                             " ${LocaleKeys.hurry_up.tr()} ",
//                                             style: context
//                                                 .textTheme
//                                                 .bodyMedium
//                                                 ?.bq
//                                                 .copyWith(
//                                                   fontSize: 13.sp,
//                                                   color: const Color(
//                                                     0xffA28E5B,
//                                                   ),
//                                                 ),
//                                           ),
//                                           Text(
//                                             "${LocaleKeys.the_time_will_end.tr()} ",
//                                             style: context
//                                                 .textTheme
//                                                 .bodyMedium
//                                                 ?.rq
//                                                 .copyWith(
//                                                   fontSize: 13.sp,
//                                                   color: const Color(
//                                                     0xffA28E5B,
//                                                   ),
//                                                 ),
//                                           ),
//                                           CountdownTimerWidget(
//                                             initialMinutes:
//                                                 state
//                                                     .cartCollection?[index]
//                                                     .timeLeftInMinutes ??
//                                                 0,
//                                             textStyle: context
//                                                 .textTheme
//                                                 .bodyMedium
//                                                 ?.bq
//                                                 .copyWith(
//                                                   fontSize: 13.sp,
//                                                   color: const Color(
//                                                     0xffA28E5B,
//                                                   ),
//                                                 ),
//                                           ),

//                                           /*    CountDownTimer(
//                                                     cartId: state
//                                                         .cartCollection?[index]
//                                                         .id
//                                                         .toString(),
//                                                   )*/
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                         ),

//                         ///////////////////////
//                         !isOldCart &&
//                                 (cartCollection![index].isActive == false ||
//                                     (cartCollection[index].checkAvailability ==
//                                         false) ||
//                                     cartCollection[index].isCountryRestricted ==
//                                         true)
//                             ? Positioned(
//                                 top: 0,
//                                 right: LanguageService.languageCode != "ar"
//                                     ? null
//                                     : 0,
//                                 left: LanguageService.languageCode != "ar"
//                                     ? 0
//                                     : null,
//                                 child: Container(
//                                   width: 100.w,
//                                   height: 30.h,
//                                   decoration: BoxDecoration(
//                                     color: const Color.fromARGB(255, 0, 0, 0),
//                                     borderRadius: BorderRadius.circular(10.h),
//                                   ),
//                                   child: Center(
//                                     child: Text(
//                                       " ${LocaleKeys.unavailable.tr()}",
//                                       style: context.textTheme.bodyMedium?.lq
//                                           .copyWith(
//                                             fontSize: 13.sp,
//                                             color: const Color.fromARGB(
//                                               255,
//                                               255,
//                                               255,
//                                               255,
//                                             ),
//                                             letterSpacing: 0.18,
//                                             height: 1.1,
//                                           ),
//                                     ),
//                                   ),
//                                 ),
//                               )
//                             : const SizedBox.shrink(),
//                         // Positioned(
//                         //   top: 5,
//                         //   right:
//                         //       LanguageService.languageCode != "ar" ? null : 20,
//                         //   left:
//                         //       LanguageService.languageCode != "ar" ? 20 : null,
//                         //   child: Container(
//                         //     decoration: BoxDecoration(
//                         //       borderRadius: BorderRadius.circular(15),
//                         //       color: Color.fromARGB(0, 0, 0, 0),
//                         //     ),
//                         //     width: 100,
//                         //     height: 40,
//                         //     child: !isOldCart
//                         //         // &&
//                         //         //         cartCollection![index].availableQuantity !=
//                         //         //             null &&
//                         //         //         ((cartCollection[index].availableQuantity ??
//                         //         //                 0) <
//                         //         //             (cartCollection[index].quantity ?? 0))
//                         //         ? Text(
//                         //             " ${LocaleKeys.out_of_stock.tr()}",
//                         //             style: context.textTheme.bodyMedium?.la
//                         //                 .copyWith(
//                         //                     fontWeight: FontWeight.w100,
//                         //                     fontSize: 12,
//                         //                     color: const Color.fromARGB(
//                         //                         255, 206, 9, 9),
//                         //                     letterSpacing: 0.18,
//                         //                     height: 1.33),
//                         //           )
//                         //         : SizedBox.shrink(),
//                         //   ),
//                         // ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }

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
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/home/data/models/get_cart_item_model.dart';
import 'package:trydos/features/home/data/models/get_old_cart_model.dart' hide Icon;
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/features/home/presentation/pages/product_details_page_new.dart';
import 'package:trydos/features/home/presentation/widgets/cart_section/countdown_timer_widget.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/product_details_image_widget.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/language_service.dart';

class ProductCollectionInCartPage1 extends StatefulWidget {
  const ProductCollectionInCartPage1({
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

  static const Color _textDark = Color(0xff505050);
  static const Color _textGrey = Color(0xff8D8D8D);
  static const Color _border = Color(0xffE6E6E6);
  static const Color _blue = Color.fromARGB(255, 48, 190, 255);
  static const Color _red = Color(0xffE53935);
  static const Color _hurry = Color(0xffA28E5B);

  @override
  void initState() {
    homeBloc = BlocProvider.of<HomeBloc>(context);
    super.initState();
  }

  // TODO: استبدلها بـ LocaleKeys عند إضافة المفاتيح لملفات الترجمة
  String _tr(String ar, String en) =>
      LanguageService.languageCode == 'ar' ? ar : en;

  @override
  Widget build(BuildContext context) {
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
        return ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.isOldCart
              ? widget.oldCartCollection?.length
              : widget.cartCollection?.length,
          itemBuilder: (context, index) => Padding(
            padding: EdgeInsetsDirectional.only(
              start: 12.w,
              end: 12.w,
              bottom: _bottomPadding(index),
            ),
            child: _buildItem(context, state, index),
          ),
        );
      },
    );
  }

  // نفس منطق المسافة السفلية القديم لآخر عنصر
  double _bottomPadding(int index) {
    final cartLen = widget.cartCollection?.length;
    final oldLen = widget.oldCartCollection?.length ?? 0;
    final isOld = widget.isOldCart;
    bool isLast;
    if (cartLen == 0) {
      isLast = isOld && index == oldLen - 1;
    } else if (oldLen == 0) {
      isLast = !isOld && index == (cartLen ?? 0) - 1;
    } else {
      isLast = isOld && index == oldLen - 1;
    }
    return isLast ? 270.h : 0;
  }

  // ======================================================================
  // Card
  // ======================================================================

  Widget _buildItem(BuildContext context, HomeState state, int index) {
    final isOldCart = widget.isOldCart;
    final Cart? cart = isOldCart ? null : widget.cartCollection![index];
    final OldCart? oldCart =
        isOldCart ? widget.oldCartCollection![index] : null;
    final dynamic item = isOldCart ? oldCart : cart;

    final dynamic variations = item.variations;
    final String colorOption = variations?.colorOption ?? '';
    final String slug = item.slug.toString();
    final String productId = item.productId.toString();

    void openProduct() =>
        _openProduct(context, slug: slug, productId: productId, colorOption: colorOption);

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: isOldCart ? const Color(0xffFF5F61) : const Color(0xffF0F0F0),
        ),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 5),
            blurRadius: 5,
            color: Color(0xffF2F2F2),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---------- الصورة + التفاصيل ----------
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: openProduct,
                borderRadius: BorderRadius.circular(12.r),
                child: ProductDetailsImageWidget(
                  withInnerShadow: false,
                  imageFit: BoxFit.cover,
                  blurRadius: 0,
                  imageUrl: item.image,
                  width: 95.w,
                  height: 120.h,
                  radius: 12.r,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _buildDetails(context, state, index, item, cart),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // ---------- الكمية + تأجيل + السعر ----------
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              isOldCart
                  ? _oldCartQuantityBox(context, oldCart!, openProduct)
                  : _cartQuantityBox(context, state, index, cart!),
              if (!isOldCart) ...[
                SizedBox(width: 8.w),
                _delayButton(context, state, index, cart!),
              ],
              SizedBox(width: 8.w),
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: _priceColumn(context, state, cart, oldCart),
                  ),
                ),
              ),
            ],
          ),

          // ---------- البانر السفلي ----------
          _bottomBanner(context, state, index, openProduct),
        ],
      ),
    );
  }

  // ======================================================================
  // Details
  // ======================================================================

  Widget _buildDetails(
    BuildContext context,
    HomeState state,
    int index,
    dynamic item,
    Cart? cart,
  ) {
    
    final isOldCart = widget.isOldCart;
    final dynamic variations = item.variations;
    final String colorOption = variations?.colorOption ?? '';
    final String sizeOption = variations?.sizeOption ?? '';
    final String? brandIcon = item.brand?.icon?.filePath;

    // الشحن (نفس الشروط القديمة)
    final int itemShipping = isOldCart
        ? (state.oldcartCollection != null &&
                  index < state.oldcartCollection!.length
              ? state.oldcartCollection![index].shippingDays ?? 0
              : 0)
        : (state.cartCollection != null && index < state.cartCollection!.length
              ? state.cartCollection![index].shippingDays ?? 0
              : 0);
    final int totalShipping =
        itemShipping + (state.startingSetting?.shippingDay ?? 0);
    final bool showShipping = isOldCart ? itemShipping != 0 : totalShipping != 0;

    // التوفر
    final bool isUnavailable =
        cart != null &&
        (cart.isActive == false ||
            cart.checkAvailability == false ||
            cart.isCountryRestricted == true);
    final String unavailableReason = cart?.isCountryRestricted == true
        ? _tr('غير متوفر في بلدك', 'Not available in your country')
        : LocaleKeys.unavailable.tr();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // البراند + رقم العنصر
        Row(
          children: [
            if (brandIcon != null && brandIcon.isNotEmpty)
              SizedBox(
                height: 30.h,
                width: 30.w,
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Image.network(brandIcon, height: 12.h),
                ),
              ),
            const Spacer(),
            _indexBadge(context, index),
          ],
        ),
        SizedBox(height: 4.h),

        // الاسم
        Text(
          item.name ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodyMedium?.rq.copyWith(
            fontSize: 13.sp,
            color: _textDark,
            letterSpacing: 0.18,
            height: 1.3,
          ),
        ),
        SizedBox(height: 6.h),

        // اللون والمقاس
        if (colorOption.isNotEmpty || sizeOption.isNotEmpty)
          Wrap(
            spacing: 10.w,
            children: [
              if (colorOption.isNotEmpty)
                _infoRow(
                  context,
                  svg: AppAssets.colorPickerSvg,
                  label: LocaleKeys.color.tr(),
                  value: variations?.color ?? '',
                ),
              if (sizeOption.isNotEmpty)
                _infoRow(
                  context,
                  svg: AppAssets.sizeIconSvg,
                  iconColor: const Color(0xff48C8A8),
                  label: LocaleKeys.size.tr(),
                  value: variations?.size ?? '',
                ),
            ],
          ),

        // مكون من
        _infoRow(
          context,
          svg: AppAssets.dressSvg,
          iconColor: _textGrey,
          label: LocaleKeys.composed_of.tr(),
          value: '${item.countOfPieces ?? 1} ${LocaleKeys.piece.tr()}',
        ),

        // الشحن
        if (showShipping)
          _infoRow(
            context,
            svg: AppAssets.shappingCartNew,
            iconColor: _textGrey,
            label: LocaleKeys.shipping.tr(),
            value: '$totalShipping ${LocaleKeys.day.tr()}',
            trailing: Text(
              ' ${LocaleKeys.details.tr()}',
              style: context.textTheme.bodyMedium?.mq.copyWith(
                decoration: TextDecoration.underline,
                fontSize: 12.sp,
                color: _textDark,
              ),
            ),
          ),

        // التوفر
        if (isUnavailable)
          Padding(
            padding: EdgeInsets.only(top: 2.h),
            child: Row(
              children: [
                Icon(Icons.warning_rounded, size: 14.sp, color: _red),
                SizedBox(width: 4.w),
                Flexible(
                  child: Text(
                    '${_tr('التوفر', 'Availability')}: $unavailableReason',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyMedium?.rq.copyWith(
                      fontSize: 12.sp,
                      color: _red,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _infoRow(
    BuildContext context, {
    required String svg,
    required String label,
    required String value,
    Color? iconColor,
    Widget? trailing,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            svg,
            height: 12.h,
            colorFilter: iconColor == null
                ? null
                : ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
          SizedBox(width: 5.w),
          Text(
            '$label: ',
            style: context.textTheme.bodyMedium?.rq.copyWith(
              fontSize: 12.sp,
              color: _textGrey,
              height: 1.1,
            ),
          ),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.mq.copyWith(
                fontSize: 12.sp,
                color: _textDark,
                height: 1.1,
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _indexBadge(BuildContext context, int index) {
    return Container(
      width: 24.w,
      height: 24.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(width: 0.5, color: _textGrey),
      ),
      child: Text(
        '${index + 1}',
        style: context.textTheme.bodyMedium?.rq.copyWith(
          fontSize: 11.sp,
          color: _textGrey,
        ),
      ),
    );
  }

  // ======================================================================
  // Quantity / Delay / Price
  // ======================================================================

  Widget _qtyButton({required String svg, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: SizedBox(
        width: 30.w,
        height: 32.h,
        child: Center(child: SvgPicture.asset(svg, width: 12.w)),
      ),
    );
  }

  Widget _quantityShell({required List<Widget> children}) {
    return Container(
      height: 32.h,
      decoration: BoxDecoration(
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }

  Widget _qtyText(BuildContext context, String text) {
    return Text(
      text,
      style: context.textTheme.bodyMedium?.mq.copyWith(
        fontSize: 14.sp,
        color: const Color(0xff1D1D1D),
      ),
    );
  }

  Widget _oldCartQuantityBox(
    BuildContext context,
    OldCart oldCart,
    VoidCallback openProduct,
  ) {
    return _quantityShell(
      children: [
        _qtyButton(
          svg: AppAssets.deletecartSvg,
          onTap: () => GetIt.I<HomeBloc>().add(
            HideItemInOldCartEvent(oldCartId: oldCart.id),
          ),
        ),
        SizedBox(
          width: 22.w,
          child: Center(child: _qtyText(context, '${oldCart.quantity ?? 0}')),
        ),
        _qtyButton(svg: AppAssets.addCartSvg, onTap: openProduct),
      ],
    );
  }

  bool _isUpdating(HomeState state, int index) =>
      index == (state.currentIndexForUpdateCart ?? 0) &&
      state.updateItemInCartStatus == UpdateItemInCartStatus.loading;

  Widget _cartQuantityBox(
    BuildContext context,
    HomeState state,
    int index,
    Cart cart,
  ) {
    final qty = cart.quantity ?? 0;
    return _quantityShell(
      children: [
        _qtyButton(
          svg: qty > 1 ? AppAssets.removeCartSvg : AppAssets.deletecartSvg,
          onTap: () => _onDecrease(state, index, cart),
        ),
        SizedBox(
          width: 22.w,
          child: Center(
            child: _isUpdating(state, index)
                ? TrydosLoader(size: 13.sp)
                : _qtyText(context, '$qty'),
          ),
        ),
        _qtyButton(
          svg: AppAssets.addCartSvg,
          onTap: () => _onIncrease(state, index, cart),
        ),
      ],
    );
  }

  void _onDecrease(HomeState state, int index, Cart cart) {
    homeBloc.add(ChangeCurrentIndexForUpdatCartEvent(index: index));
    if (_isUpdating(state, index)) return;

    final qty = cart.quantity ?? 0;
    final size = cart.variations?.sizeOption ?? '';
    final color = cart.variations?.colorOption ?? '';

    if (qty > 1) {
      GetIt.I<HomeBloc>().add(
        UpdateItemInCartEvent(
          fromCartPage: true,
          newQuantity: -1,
          maxAllowed: double.tryParse(cart.maxAllowedQty ?? '0'),
          currentSize: size,
          colorOption: color,
          productId: cart.productId.toString(),
          productName: cart.name.toString(),
          productPrice: cart.price.toString(),
          totalQuantity: qty - 1,
          image: cart.image ?? '',
          cartId: cart.id.toString(),
          boutiqueId: cart.boutique!.id.toString(),
        ),
      );
    } else {
      GetIt.I<HomeBloc>().add(
        RemoveItemFormCartEvent(
          fromCartPage: true,
          image: cart.image ?? '',
          currentSize: size,
          colorName: color,
          productId: cart.productId.toString(),
          itemId: cart.id.toString(),
          boutiqueId: cart.boutique!.id.toString(),
        ),
      );
    }
  }

  void _onIncrease(HomeState state, int index, Cart cart) {
    homeBloc.add(ChangeCurrentIndexForUpdatCartEvent(index: index));
    if (_isUpdating(state, index)) return;

    GetIt.I<HomeBloc>().add(
      UpdateItemInCartEvent(
        fromCartPage: true,
        newQuantity: 1,
        maxAllowed: double.tryParse(cart.maxAllowedQty ?? '0'),
        currentSize: cart.variations?.sizeOption ?? '',
        colorOption: cart.variations?.colorOption ?? '',
        productId: cart.productId.toString(),
        productName: cart.name.toString(),
        productPrice: cart.price.toString(),
        totalQuantity: (cart.quantity ?? 0) + 1,
        image: cart.image ?? '',
        cartId: cart.id.toString(),
        boutiqueId: cart.boutique!.id.toString(),
      ),
    );
  }

  Widget _delayButton(
    BuildContext context,
    HomeState state,
    int index,
    Cart cart,
  ) {
    final isConverting =
        index == (state.currentIndexForUpdateCart ?? 0) &&
        state.convertItemFromcartToOldCartStatus ==
            ConvertItemFromcartToOldCartStatus.loading;

    return InkWell(
      borderRadius: BorderRadius.circular(8.r),
      onTap: () {
        homeBloc.add(ChangeCurrentIndexForUpdatCartEvent(index: index));
        if (isConverting) return;
        homeBloc.add(
          ConvertItemFromCartToOldCartEvent(cartId: cart.id.toString()),
        );
      },
      child: Container(
        height: 32.h,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _blue,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: isConverting
            ? TrydosLoader(size: 18.h, color: Colors.white)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    AppAssets.redeemClockSvg,
                    width: 14.w,
                    height: 14.w,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    LocaleKeys.delay.tr(),
                    style: context.textTheme.bodyMedium?.bq.copyWith(
                      fontSize: 12.sp,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  String _money(HomeState state, num? value, int? qty) {
    final currency = state.getCurrencyForCountryModel?.data?.currency;
    final int digits = currency?.decimalDigits ?? 2;
    final double rate = (currency?.exchangeRate ?? 1).toDouble();
    return HelperFunctions.formatNumber(
      numberToFormate:
          HelperFunctions.truncateToDecimalPlaces(
            (value ?? 0).toDouble(),
            digits,
          ) *
          rate *
          (qty ?? 0),
    );
  }

  Widget _priceColumn(
    BuildContext context,
    HomeState state,
    Cart? cart,
    OldCart? oldCart,
  ) {
    final symbol = widget.priceSymbol ?? '\$';

    final bool hasDiscount =
        cart != null && cart.offerPrice != cart.price;
    final String mainPrice = cart == null
        ? _money(state, oldCart!.offerPrice, oldCart.quantity)
        : _money(state, cart.offerPrice, cart.quantity);
    final Color mainColor = cart?.isRedeem == true
        ? Colors.deepOrangeAccent
        : const Color(0xff1D1D1D);

    final num price = cart?.price ?? 0;
    final num offer = cart?.offerPrice ?? 0;
    final String savedPercent = price == 0
        ? '0'
        : (((price - offer) / price) * 100).toStringAsFixed(0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (hasDiscount)
          Text(
            '${_money(state, cart.price, cart.quantity)} $symbol',
            style: context.textTheme.bodyMedium?.rq.copyWith(
              fontSize: 11.sp,
              color: const Color(0xffC4C2C2),
              decoration: TextDecoration.lineThrough,
              decorationColor: const Color(0xffC4C2C2),
            ),
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              mainPrice,
              style: context.textTheme.bodyMedium?.bq.copyWith(
                fontSize: 15.sp,
                color: mainColor,
              ),
            ),
            SizedBox(width: 3.w),
            Text(
              symbol,
              style: context.textTheme.bodyMedium?.rq.copyWith(
                fontSize: 9.sp,
                color: mainColor,
              ),
            ),
          ],
        ),
        if (hasDiscount)
          Text(
            '${LocaleKeys.saved.tr()} $savedPercent %',
            style: context.textTheme.bodyMedium?.rq.copyWith(
              fontSize: 9.sp,
              color: const Color(0xff388CFF),
            ),
          ),
      ],
    );
  }

  // ======================================================================
  // Bottom banners
  // ======================================================================

  Widget _bottomBanner(
    BuildContext context,
    HomeState state,
    int index,
    VoidCallback openProduct,
  ) {
    if (widget.isOldCart) return _oldCartBanner(context, openProduct);

    final stateItem =
        (state.cartCollection != null && index < state.cartCollection!.length)
        ? state.cartCollection![index]
        : null;
    if (stateItem == null) return const SizedBox.shrink();

    final hurryTime = stateItem.haveHurryUpNotifyTimeLeft ?? false;
    final hurryQty = stateItem.haveHurryUpNotifyQty ?? false;

    final hurryStyle = context.textTheme.bodyMedium?.rq.copyWith(
      fontSize: 12.sp,
      color: _hurry,
    );
    final hurryBold = context.textTheme.bodyMedium?.bq.copyWith(
      fontSize: 12.sp,
      color: _hurry,
    );

    if (hurryTime) {
      return _hurryShell(
        children: [
          Flexible(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${LocaleKeys.hurry_up.tr()} ',
                    style: hurryBold,
                  ),
                  TextSpan(
                    text: '${LocaleKeys.the_time_will_end.tr()} ',
                    style: hurryStyle,
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          CountdownTimerWidget(
            initialMinutes: stateItem.timeLeftInMinutes ?? 0,
            textStyle: hurryBold,
          ),
        ],
      );
    }

    if (hurryQty) {
      return _hurryShell(
        children: [
          Flexible(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${LocaleKeys.hurry_up.tr()} ',
                    style: hurryBold,
                  ),
                  TextSpan(
                    text: '${LocaleKeys.quantity_running_out.tr()} ',
                    style: hurryStyle,
                  ),
                  TextSpan(
                    text:
                        '${stateItem.qtyLeft} ${LocaleKeys.piece.tr()}',
                    style: hurryBold,
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _hurryShell({required List<Widget> children}) {
    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: DottedBorder(
        padding: EdgeInsets.zero,
        borderType: BorderType.RRect,
        strokeCap: StrokeCap.round,
        strokeWidth: 0.5,
        dashPattern: const [3, 3],
        radius: Radius.circular(20.r),
        color: const Color(0xffD3D3D3),
        child: Container(
          height: 32.h,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            color: const Color(0xffFDFDEF),
          ),
          child: Row(
            children: [
              SvgPicture.asset(AppAssets.alarmClockSvg),
              SizedBox(width: 5.w),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _oldCartBanner(BuildContext context, VoidCallback openProduct) {
    final grey = context.textTheme.bodyMedium?.rq.copyWith(
      fontSize: 12.sp,
      color: _textGrey,
    );
    final greyBold = context.textTheme.bodyMedium?.bq.copyWith(
      fontSize: 12.sp,
      color: _textGrey,
    );

    return Container(
      margin: EdgeInsets.only(top: 10.h),
      height: 34.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: const Color(0xffF8F8F8),
      ),
      child: Row(
        children: [
          SvgPicture.asset(AppAssets.towCartSvg),
          SizedBox(width: 5.w),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${LocaleKeys.out_of_bag.tr()} ',
                    style: greyBold,
                  ),
                  TextSpan(
                    text: '${LocaleKeys.time_running_out.tr()} ',
                    style: grey,
                  ),
                  TextSpan(text: '-30:00', style: greyBold),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          InkWell(
            onTap: openProduct,
            child: Text(' | ${LocaleKeys.add_again.tr()}', style: grey),
          ),
          SizedBox(width: 5.w),
          SvgPicture.asset(AppAssets.chatWithQuestionSvg),
        ],
      ),
    );
  }

  // ======================================================================
  // Navigation
  // ======================================================================

  void _openProduct(
    BuildContext context, {
    required String slug,
    required String productId,
    required String colorOption,
  }) {
    BlocProvider.of<HomeBloc>(context).add(
      GetFullProductDetailsEvent(
        currentColorName: colorOption,
        productSlug: slug,
      ),
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!context.mounted) return;
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => ProductDetailsPageNew(
            productSlugForOpeningChatDirectly: slug,
            productIdForOpeningChatDirectly: productId,
          ),
        ),
      );
    });
  }
}
