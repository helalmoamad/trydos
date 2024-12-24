import 'dart:math';

import 'package:dotted_border/dotted_border.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/helper/helper_functions.dart';

import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';

import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_event.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/app/svg_network_widget.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/features/home/presentation/pages/order_page.dart';

import 'package:trydos/features/home/presentation/widgets/cart_section/product_collection_in_cart_page1.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/product_details_image_widget.dart';
import 'package:trydos/features/story/presentation/widget/try_again.dart';
import 'package:trydos/main.dart';
import 'package:trydos/routes/router.dart';

import '../../../../service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import '../../../../service/firebase_analytics_service/firebase_analytics_service.dart';

class CartPage extends StatefulWidget {
  final bool? fromeFilters;
  final bool? fromeNotification;

  const CartPage({Key? key, this.fromeFilters, this.fromeNotification});
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late HomeBloc homeBloc;
  late AppBloc appBloc;
  PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();

  final ValueNotifier<bool> isExpanded = ValueNotifier(false);
  bool? fromForGroundNotification;
  @override
  void initState() {
    if ((prefsRepository.marketToken?.length ?? 0) < 5 ||
        prefsRepository.myMarketId == "" ||
        prefsRepository.myMarketId == null) {
      print("NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNIIIIIIIIIIIIIIIIII");
      context.go(GRouter.config.applicationRoutes.kRegistrationPagePath);
    }
    isExpanded.value = false;
    appBloc = BlocProvider.of<AppBloc>(context);

    homeBloc = BlocProvider.of<HomeBloc>(context);
    homeBloc.add(GetCartItemEvent());
    fromForGroundNotification =
        appBloc.state.isFromForGroundNotification ?? false;
    print("${widget.fromeNotification}" + "${fromForGroundNotification}");

    super.initState();
  }

  @override
  void didChangeDependencies() {
    FirebaseAnalyticsService.logScreen(
      screen: AnalyticsScreensConst.cartScreen,
    );
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: WillPopScope(
        onWillPop: () async {
          // didCallOnWillPop = true;
          if (Navigator.canPop(context)) {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();

              appBloc.add(ChangeBasePage(0));
              return false;
              // منع الإغلاق بعد تنفيذ pop
            }

            // يسمح بالإغلاق إذا لم تنطبق أي من الشروط

            appBloc.add(ChangeBasePage(0));
            homeBloc.add(ResetAllSelectedAppliedFilterEvent());
            return false;
          } else {
            appBloc.add(ChangeBasePage(0));
            return true;
          }
        },
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: BlocBuilder<HomeBloc, HomeState>(
              buildWhen: (previous, current) {
                return previous.getCartItemsStatus !=
                        current.getCartItemsStatus ||
                    previous.getCurrencyForCountryModel !=
                        current.getCurrencyForCountryModel ||
                    previous.deleteItemInCartStatus !=
                        current.deleteItemInCartStatus ||
                    previous.getOldCartItemsStatus !=
                        current.getOldCartItemsStatus ||
                    previous.convertItemFromOldcartToCartStatus !=
                        current.convertItemFromOldcartToCartStatus ||
                    previous.hideItemInOldCartStatus !=
                        current.hideItemInOldCartStatus ||
                    previous.addItemInCartStatus !=
                        current.addItemInCartStatus ||
                    previous.updateItemInCartStatus !=
                        current.updateItemInCartStatus ||
                    previous.cartCollection!.length !=
                        current.cartCollection?.length ||
                    previous.oldcartCollection?.length !=
                        current.oldcartCollection!.length;
              },
              builder: (context, state) {
                if (state.getCartItemsStatus == GetCartItemsStatus.failure &&
                    (state.getCartShippingItemsModel == null)) {
                  return Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: Center(child: TryAgainWidget(tryAgain: () {
                      BlocProvider.of<HomeBloc>(context)
                          .add(GetCartItemEvent());
                    })),
                  );
                }

                if (state.getCartShippingItemsModel == null &&
                        state.getCartItemsStatus !=
                            GetCartItemsStatus.success ||
                    (state.getOldCartModel == null &&
                        state.getOldCartItemsStatus !=
                            GetOLdCartItemsStatus.success)) {
                  print("-------------------------------${(state.getOldCartModel == null && state.getOldCartItemsStatus != GetOLdCartItemsStatus.success)}------------------------------------------${state.getCartShippingItemsModel == null && state.getCartItemsStatus != GetCartItemsStatus.success}" +
                      "   ////////////////${state.getCartShippingItemsModel == null && state.getCartItemsStatus != GetCartItemsStatus.success}");
                  return Center(
                    child: TrydosLoader(),
                  );
                }

                double totlalOfferPrice = 0;
                double totlalPrice = 0;
                String? priceSymbol;
                double totlalQuantity = 0;
                double totlalDiscount = 0;

                state.cartCollection!.forEach((element) {
                  totlalQuantity = totlalQuantity + (element.quantity ?? 0);
                  priceSymbol = state
                          .getCurrencyForCountryModel!.data!.currency!.symbol ??
                      "";

                  totlalOfferPrice = totlalOfferPrice +
                      element.offerPrice! * element.quantity!;
                  totlalPrice =
                      totlalPrice + element.price! * element.quantity!;
                  totlalDiscount = totlalDiscount +
                      (element.price! - element.offerPrice!) *
                          element.quantity!;
                });
                totlalOfferPrice = totlalOfferPrice *
                    state.getCurrencyForCountryModel!.data!.currency!
                        .exchangeRate!;
                totlalPrice = totlalPrice *
                    state.getCurrencyForCountryModel!.data!.currency!
                        .exchangeRate!;
                totlalDiscount = totlalDiscount *
                    state.getCurrencyForCountryModel!.data!.currency!
                        .exchangeRate!;

                return Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 60),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      width: 1.sw - 20,
                      height: 70.h,
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            height: 50.h,
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    // didCallOnWillPop = true;
                                    if (Navigator.canPop(context)) {
                                      if (Navigator.of(context).canPop()) {
                                        Navigator.of(context).pop();
                                        return;
                                        // منع الإغلاق بعد تنفيذ pop
                                      }

                                      // يسمح بالإغلاق إذا لم تنطبق أي من الشروط

                                      appBloc.add(ChangeBasePage(0));
                                      homeBloc.add(
                                          ResetAllSelectedAppliedFilterEvent());
                                      return;
                                    } else {
                                      appBloc.add(ChangeBasePage(0));
                                      return;
                                    }
                                  },
                                  child: Container(
                                    width: 40,
                                    child: SvgPicture.asset(
                                      AppAssets.backIconArrowSvg,
                                      height: 20,
                                    ),
                                  ),
                                ),
                                Spacer(),
                                SvgPicture.asset(
                                  AppAssets.bagsSvg,
                                  height: 20,
                                ),
                                SizedBox(
                                  width: 7.w,
                                ),
                                Text(
                                  "Shopping Bag ",
                                  style: context.textTheme.bodyMedium?.ra
                                      .copyWith(
                                          color: const Color(0xff505050),
                                          letterSpacing: 0.18,
                                          fontSize: 13,
                                          height: 1.33),
                                ),
                                Text(
                                  "${state.cartCollection?.length} item",
                                  style: context.textTheme.bodyMedium?.br
                                      .copyWith(
                                          color: const Color(0xff505050),
                                          letterSpacing: 0.18,
                                          fontSize: 13,
                                          height: 1.33),
                                ),
                                Spacer(),
                                SvgPicture.asset(
                                  AppAssets.shareSvg,
                                  height: 20,
                                  width: 20,
                                  color: Color(0xff3C3C3C),
                                )
                              ],
                            ),
                          ),
                          /*container(
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
                                      /* HelperFunctions.slidingNavigation(
                                                context,
                                                CartPage2(
                                                  getCartShippingItemsModel: state
                                                      .getCartShippingItemsModel!,
                                                ));*/
                                    },
                                    child: SvgPicture.asset(
                                        AppAssets.countItemSvg)),
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
                                  "${totlaPrice.toStringAsFixed(state.startingSetting?.decimalPointSetting ?? 2)}",
                                  style: context.textTheme.bodyMedium?.mr
                                      .copyWith(
                                          fontSize: 13,
                                          color: const Color(0xff5D5C5D),
                                          letterSpacing: 0.18,
                                          height: 1.33),
                                ),
                                Text(
                                  " ${priceSymbol ?? '\$'} ",
                                  style: context.textTheme.bodyMedium?.la
                                      .copyWith(
                                          fontSize: 13,
                                          color: const Color(0xff8D8D8D),
                                          letterSpacing: 0.18,
                                          height: 1.33),
                                ),
                              ],
                            ),
                          ),*/
                        ],
                      ),
                    ),
                    Container(
                      color: Color.fromARGB(255, 255, 255, 255),
                      child: Container(
                        color: ((state.cartCollection == null ||
                                    state.cartCollection!.isEmpty) &&
                                (state.oldcartCollection == null ||
                                    state.oldcartCollection!.isEmpty))
                            ? Color(0xffF8F8F8)
                            : Color(0xffFEFEFE),
                        alignment: Alignment.topCenter,
                        height: 1.sh - 190,
                        child: Stack(
                          children: [
                            ((state.cartCollection == null ||
                                        state.cartCollection!.isEmpty) &&
                                    (state.oldcartCollection == null ||
                                        state.oldcartCollection!.isEmpty))
                                ? Center(
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 170.h,
                                        ),
                                        Container(
                                          height: 40,
                                          child: Text(
                                            "Your Shopping Bag Is Empty",
                                            style: context
                                                .textTheme.bodyMedium?.ra
                                                .copyWith(
                                                    fontSize: 18,
                                                    color:
                                                        const Color(0xff505050),
                                                    letterSpacing: 0.18,
                                                    height: 1.33),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(
                                    height: 1.sh - 190,
                                    child: ListView(
                                      padding: EdgeInsets.only(top: 0),
                                      shrinkWrap: true,
                                      children: [
                                        (state.cartCollection == null ||
                                                state.cartCollection!.isEmpty)
                                            ? SizedBox.shrink()
                                            : productCollectionInCartPage1(
                                                isOldCart: false,
                                                oldCartCollection:
                                                    state.oldcartCollection ??
                                                        [],
                                                cartCollection:
                                                    state.cartCollection ?? [],
                                                priceSymbol: priceSymbol,
                                              ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        state.oldcartCollection != null
                                            ? !state.oldcartCollection!.isEmpty
                                                ? Center(
                                                    child: MyTextWidget(
                                                    "Old Cart",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 24),
                                                  ))
                                                : SizedBox.shrink()
                                            : SizedBox.shrink(),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        state.oldcartCollection != null
                                            ? !state.oldcartCollection!.isEmpty
                                                ? Container(
                                                    height: 70.h,
                                                    padding:
                                                        EdgeInsets.all(20.w),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        ElevatedButton(
                                                            onPressed: () {
                                                              GetIt.I<HomeBloc>()
                                                                  .add(
                                                                      HideItemInOldCartEvent(
                                                                hideAll: true,
                                                              ));
                                                            },
                                                            child: MyTextWidget(
                                                              "Hide All",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red,
                                                                  fontSize: 14),
                                                            ))
                                                      ],
                                                    ))
                                                : SizedBox.shrink()
                                            : SizedBox.shrink(),
                                        (state.oldcartCollection == null ||
                                                state
                                                    .oldcartCollection!.isEmpty)
                                            ? SizedBox.shrink()
                                            : productCollectionInCartPage1(
                                                isOldCart: true,
                                                oldCartCollection:
                                                    state.oldcartCollection ??
                                                        [],
                                                cartCollection:
                                                    state.cartCollection ?? [],
                                                priceSymbol: priceSymbol,
                                              ),
                                      ],
                                    ),
                                  ),
                            ValueListenableBuilder<bool>(
                                valueListenable: isExpanded,
                                builder: (context, expanded, _) {
                                  return !expanded
                                      ? SizedBox.shrink()
                                      : Container(
                                          color:
                                              Color.fromRGBO(29, 29, 29, 0.6),
                                        );
                                }),
                            ValueListenableBuilder<bool>(
                                valueListenable: isExpanded,
                                builder: (context, expanded, _) {
                                  return Positioned(
                                    bottom: 0,
                                    child: AnimatedContainer(
                                      duration: Duration(seconds: 1),
                                      curve: Curves.easeInOut,
                                      child: Container(
                                        alignment: Alignment.topLeft,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Color(0xffFFFFFF)),
                                            color: Color(0xffFFFFFF),
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(30),
                                                topRight: Radius.circular(30))),
                                        height:
                                            ((state.cartCollection == null ||
                                                        state.cartCollection!
                                                            .isEmpty) &&
                                                    (state.oldcartCollection ==
                                                            null ||
                                                        state.oldcartCollection!
                                                            .isEmpty))
                                                ? 100.h
                                                : expanded
                                                    ? 425.h
                                                    : 176.h,
                                        width: 1.sw,
                                        child: Directionality(
                                          textDirection: TextDirection.ltr,
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                !expanded
                                                    ? SizedBox.shrink()
                                                    : Container(
                                                        margin:
                                                            EdgeInsets.all(18),
                                                        width: 65,
                                                        height: 18,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            SvgPicture.asset(
                                                              AppAssets
                                                                  .countItemSvg,
                                                              color: Color(
                                                                  0xff1D1D1D),
                                                              height: 12,
                                                            ),
                                                            Text(
                                                              " Item ",
                                                              style: context
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.mr
                                                                  .copyWith(
                                                                      fontSize:
                                                                          13,
                                                                      color: const Color(
                                                                          0xff1D1D1D),
                                                                      letterSpacing:
                                                                          0.18,
                                                                      height:
                                                                          1.33),
                                                            ),
                                                            Text(
                                                              "${totlalQuantity.round()}",
                                                              style: context
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.ba
                                                                  .copyWith(
                                                                      fontSize:
                                                                          13,
                                                                      color: const Color(
                                                                          0xff1D1D1D),
                                                                      letterSpacing:
                                                                          0.18,
                                                                      height:
                                                                          1.33),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                !expanded
                                                    ? SizedBox.shrink()
                                                    : Container(
                                                        width: 400.w,
                                                        height: 50.h,
                                                        padding:
                                                            EdgeInsets.only(
                                                                right: 10),
                                                        margin: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    10.w),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Container(
                                                                  height: 17.h,
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              25,
                                                                          right:
                                                                              10.w),
                                                                  child: Text(
                                                                    "Price ",
                                                                    style: context.textTheme.bodyMedium?.mr.copyWith(
                                                                        fontSize:
                                                                            13,
                                                                        color: const Color(
                                                                            0xff1D1D1D),
                                                                        letterSpacing:
                                                                            0.18,
                                                                        height:
                                                                            1.33),
                                                                  ),
                                                                ),
                                                                Spacer(),
                                                                Text(
                                                                  " ${totlalPrice.toStringAsFixed(state.startingSetting?.decimalPointSetting ?? 2)}  ",
                                                                  style: context
                                                                      .textTheme
                                                                      .bodyMedium
                                                                      ?.br
                                                                      .copyWith(
                                                                          fontSize:
                                                                              13,
                                                                          color: const Color(
                                                                              0xff1D1D1D),
                                                                          letterSpacing:
                                                                              0.18,
                                                                          height:
                                                                              1.33),
                                                                ),
                                                                Text(
                                                                  "${priceSymbol ?? "\$"}",
                                                                  style: context
                                                                      .textTheme
                                                                      .bodyMedium
                                                                      ?.mr
                                                                      .copyWith(
                                                                          fontSize:
                                                                              13,
                                                                          color: const Color(
                                                                              0xff1D1D1D),
                                                                          letterSpacing:
                                                                              0.18,
                                                                          height:
                                                                              1.33),
                                                                ),
                                                              ],
                                                            ),
                                                            Container(
                                                              height: 17.h,
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      left: 25,
                                                                      right:
                                                                          10.w),
                                                              child: Text(
                                                                "Normal Price ",
                                                                style: context
                                                                    .textTheme
                                                                    .bodyMedium
                                                                    ?.ra
                                                                    .copyWith(
                                                                        fontSize:
                                                                            11,
                                                                        color: const Color(
                                                                            0xff1D1D1D),
                                                                        letterSpacing:
                                                                            0.18,
                                                                        height:
                                                                            1.33),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                !expanded
                                                    ? SizedBox.shrink()
                                                    : SizedBox(
                                                        height: 5.h,
                                                      ),
                                                !expanded
                                                    ? SizedBox.shrink()
                                                    : Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                right: 10),
                                                        width: 400.w,
                                                        height: 50.h,
                                                        margin: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    10.w),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Container(
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              10.w),
                                                                  child:
                                                                      SvgPicture
                                                                          .asset(
                                                                    AppAssets
                                                                        .totalDiscountCartSvg,
                                                                    color: Color(
                                                                        0xffFE0364),
                                                                    height: 12,
                                                                  ),
                                                                ),
                                                                Container(
                                                                  height: 17.h,
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              2,
                                                                          right:
                                                                              10.w),
                                                                  child: Text(
                                                                    "Total Discount ${(totlalPrice == 0 ? 0 : ((totlalDiscount) / totlalPrice) * 100).toStringAsFixed(1)}% ",
                                                                    style: context.textTheme.bodyMedium?.mr.copyWith(
                                                                        fontSize:
                                                                            13,
                                                                        color: const Color(
                                                                            0xffA28E5B),
                                                                        letterSpacing:
                                                                            0.18,
                                                                        height:
                                                                            1.33),
                                                                  ),
                                                                ),
                                                                Spacer(),
                                                                Text(
                                                                  "- ${(totlalDiscount).toStringAsFixed(state.startingSetting?.decimalPointSetting ?? 2)}  ",
                                                                  style: context
                                                                      .textTheme
                                                                      .bodyMedium
                                                                      ?.br
                                                                      .copyWith(
                                                                          fontSize:
                                                                              13,
                                                                          color: const Color(
                                                                              0xffA28E5B),
                                                                          letterSpacing:
                                                                              0.18,
                                                                          height:
                                                                              1.33),
                                                                ),
                                                                Text(
                                                                  "${priceSymbol ?? "\$"}",
                                                                  style: context
                                                                      .textTheme
                                                                      .bodyMedium
                                                                      ?.mr
                                                                      .copyWith(
                                                                          fontSize:
                                                                              13,
                                                                          color: const Color(
                                                                              0xffA28E5B),
                                                                          letterSpacing:
                                                                              0.18,
                                                                          height:
                                                                              1.33),
                                                                ),
                                                              ],
                                                            ),
                                                            Container(
                                                              height: 17.h,
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      left: 25,
                                                                      right:
                                                                          10.w),
                                                              child: Text(
                                                                "All Inclusive Without Additions ",
                                                                style: context
                                                                    .textTheme
                                                                    .bodyMedium
                                                                    ?.ra
                                                                    .copyWith(
                                                                        fontSize:
                                                                            11,
                                                                        color: const Color(
                                                                            0xffA28E5B),
                                                                        letterSpacing:
                                                                            0.18,
                                                                        height:
                                                                            1.33),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                !expanded
                                                    ? SizedBox.shrink()
                                                    : SizedBox(
                                                        height: 5.h,
                                                      ),
                                                !expanded
                                                    ? SizedBox.shrink()
                                                    : Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                right: 10),
                                                        width: 400.w,
                                                        height: 50.h,
                                                        margin: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    10.w),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Container(
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              10.w),
                                                                  child:
                                                                      SvgPicture
                                                                          .asset(
                                                                    AppAssets
                                                                        .giftCartSvg,
                                                                    color: Color(
                                                                        0xff5BA260),
                                                                    height: 12,
                                                                  ),
                                                                ),
                                                                Container(
                                                                  height: 17.h,
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              2,
                                                                          right:
                                                                              10.w),
                                                                  child: Text(
                                                                    "Gift",
                                                                    style: context.textTheme.bodyMedium?.mr.copyWith(
                                                                        fontSize:
                                                                            13,
                                                                        color: const Color(
                                                                            0xff5BA260),
                                                                        letterSpacing:
                                                                            0.18,
                                                                        height:
                                                                            1.33),
                                                                  ),
                                                                ),
                                                                Spacer(),
                                                                Text(
                                                                  "- ${0}  ",
                                                                  style: context
                                                                      .textTheme
                                                                      .bodyMedium
                                                                      ?.br
                                                                      .copyWith(
                                                                          fontSize:
                                                                              13,
                                                                          color: const Color(
                                                                              0xff5BA260),
                                                                          letterSpacing:
                                                                              0.18,
                                                                          height:
                                                                              1.33),
                                                                ),
                                                                Text(
                                                                  "${priceSymbol ?? "\$"}",
                                                                  style: context
                                                                      .textTheme
                                                                      .bodyMedium
                                                                      ?.mr
                                                                      .copyWith(
                                                                          fontSize:
                                                                              13,
                                                                          color: const Color(
                                                                              0xff5BA260),
                                                                          letterSpacing:
                                                                              0.18,
                                                                          height:
                                                                              1.33),
                                                                ),
                                                              ],
                                                            ),
                                                            Container(
                                                              height: 17.h,
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      left: 25,
                                                                      right:
                                                                          10.w),
                                                              child: Text(
                                                                "First Shopping ",
                                                                style: context
                                                                    .textTheme
                                                                    .bodyMedium
                                                                    ?.ra
                                                                    .copyWith(
                                                                        fontSize:
                                                                            11,
                                                                        color: const Color(
                                                                            0xff5BA260),
                                                                        letterSpacing:
                                                                            0.18,
                                                                        height:
                                                                            1.33),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                SizedBox(
                                                  height: 5.h,
                                                ),
                                                !expanded
                                                    ? SizedBox.shrink()
                                                    : Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                right: 10),
                                                        width: 400.w,
                                                        height: 50.h,
                                                        margin: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    10.w),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Container(
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              10.w),
                                                                  child:
                                                                      SvgPicture
                                                                          .asset(
                                                                    AppAssets
                                                                        .shappingCartSvg,
                                                                    color: Color(
                                                                        0xffBEF4CD),
                                                                    height: 12,
                                                                  ),
                                                                ),
                                                                Container(
                                                                  height: 17.h,
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              2,
                                                                          right:
                                                                              10.w),
                                                                  child: Text(
                                                                    "Shipping ",
                                                                    style: context.textTheme.bodyMedium?.mr.copyWith(
                                                                        fontSize:
                                                                            13,
                                                                        color: const Color(
                                                                            0xff2FA52F),
                                                                        letterSpacing:
                                                                            0.18,
                                                                        height:
                                                                            1.29),
                                                                  ),
                                                                ),
                                                                Spacer(),
                                                                Text(
                                                                  "0",
                                                                  style: context.textTheme.bodyMedium?.br.copyWith(
                                                                      decoration: TextDecoration
                                                                          .lineThrough,
                                                                      decorationColor:
                                                                          const Color(
                                                                              0xff2FA52F),
                                                                      color: const Color(
                                                                          0xff2FA52F),
                                                                      fontSize:
                                                                          13,
                                                                      letterSpacing:
                                                                          0.18,
                                                                      height:
                                                                          1.33),
                                                                ),
                                                                Text(
                                                                  " 0,00  ",
                                                                  style: context
                                                                      .textTheme
                                                                      .bodyMedium
                                                                      ?.br
                                                                      .copyWith(
                                                                          fontSize:
                                                                              13,
                                                                          color: const Color(
                                                                              0xff2FA52F),
                                                                          letterSpacing:
                                                                              0.18,
                                                                          height:
                                                                              1.33),
                                                                ),
                                                                Text(
                                                                  "${priceSymbol ?? "\$"}",
                                                                  style: context
                                                                      .textTheme
                                                                      .bodyMedium
                                                                      ?.mr
                                                                      .copyWith(
                                                                          fontSize:
                                                                              13,
                                                                          color: const Color(
                                                                              0xff2FA52F),
                                                                          letterSpacing:
                                                                              0.18,
                                                                          height:
                                                                              1.33),
                                                                ),
                                                              ],
                                                            ),
                                                            Container(
                                                              height: 17.h,
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      left: 25,
                                                                      right:
                                                                          10.w),
                                                              child: Text(
                                                                "Shipping Is Completely Free Without Any Extras ",
                                                                style: context
                                                                    .textTheme
                                                                    .bodyMedium
                                                                    ?.ra
                                                                    .copyWith(
                                                                        fontSize:
                                                                            11,
                                                                        color: const Color(
                                                                            0xff2FA52F),
                                                                        letterSpacing:
                                                                            0.18,
                                                                        height:
                                                                            1.33),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                SizedBox(
                                                  height: expanded ? 0 : 10.h,
                                                ),
                                                ((state.cartCollection ==
                                                                null ||
                                                            state
                                                                .cartCollection!
                                                                .isEmpty) &&
                                                        (state.oldcartCollection ==
                                                                null ||
                                                            state
                                                                .oldcartCollection!
                                                                .isEmpty))
                                                    ? SizedBox.shrink()
                                                    : Container(
                                                        width: 400.w,
                                                        height: 50.h,
                                                        decoration: BoxDecoration(
                                                            color: Color(
                                                                0xffF8F8F8),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            12))),
                                                        padding:
                                                            EdgeInsets.only(
                                                                right: 10),
                                                        margin: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    10.w),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Container(
                                                                  height: 17.h,
                                                                  margin: EdgeInsets.only(
                                                                      left:
                                                                          25.w,
                                                                      right:
                                                                          10.w),
                                                                  child: Text(
                                                                    "Total",
                                                                    style: context.textTheme.bodyMedium?.br.copyWith(
                                                                        fontSize:
                                                                            13,
                                                                        color: const Color(
                                                                            0xff1D1D1D),
                                                                        letterSpacing:
                                                                            0.18,
                                                                        height:
                                                                            1.33),
                                                                  ),
                                                                ),
                                                                Spacer(),
                                                                Text(
                                                                  "${totlalPrice.toStringAsFixed(state.startingSetting?.decimalPointSetting ?? 2)}  ",
                                                                  style: context.textTheme.bodyMedium?.ra.copyWith(
                                                                      decoration:
                                                                          TextDecoration
                                                                              .lineThrough,
                                                                      fontSize:
                                                                          16,
                                                                      color: const Color(
                                                                          0xff1D1D1D),
                                                                      letterSpacing:
                                                                          0.18,
                                                                      height:
                                                                          1.33),
                                                                ),
                                                                Text(
                                                                  "${totlalOfferPrice.toStringAsFixed(state.startingSetting?.decimalPointSetting ?? 2)}  ",
                                                                  style: context
                                                                      .textTheme
                                                                      .bodyMedium
                                                                      ?.br
                                                                      .copyWith(
                                                                          fontSize:
                                                                              16,
                                                                          color: const Color(
                                                                              0xff1D1D1D),
                                                                          letterSpacing:
                                                                              0.18,
                                                                          height:
                                                                              1.33),
                                                                ),
                                                                Text(
                                                                  "${priceSymbol ?? "\$"}",
                                                                  style: context
                                                                      .textTheme
                                                                      .bodyMedium
                                                                      ?.mr
                                                                      .copyWith(
                                                                          fontSize:
                                                                              16,
                                                                          color: const Color(
                                                                              0xff1D1D1D),
                                                                          letterSpacing:
                                                                              0.18,
                                                                          height:
                                                                              1.33),
                                                                ),
                                                                Container(
                                                                    width: 20,
                                                                    height: 20,
                                                                    child:
                                                                        InkWell(
                                                                      onTap: () =>
                                                                          isExpanded.value =
                                                                              !expanded,
                                                                      child:
                                                                          Container(
                                                                        alignment:
                                                                            Alignment.centerRight,
                                                                        height:
                                                                            8,
                                                                        child: !expanded
                                                                            ? Transform.rotate(
                                                                                angle: pi,
                                                                                alignment: Alignment.center,
                                                                                child: SvgPicture.asset(
                                                                                  AppAssets.expandDetaileSvg,
                                                                                  height: 6,
                                                                                ))
                                                                            : SvgPicture.asset(
                                                                                AppAssets.expandDetaileSvg,
                                                                                height: 6,
                                                                              ),
                                                                      ),
                                                                    )),
                                                              ],
                                                            ),
                                                            Container(
                                                              height: 17.h,
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      left: 25,
                                                                      right:
                                                                          10.w),
                                                              child: Text(
                                                                "Click To Show All Discount ",
                                                                style: context
                                                                    .textTheme
                                                                    .bodyMedium
                                                                    ?.ra
                                                                    .copyWith(
                                                                        fontSize:
                                                                            11,
                                                                        color: const Color(
                                                                            0xff8D8D8D),
                                                                        letterSpacing:
                                                                            0.18,
                                                                        height:
                                                                            1.33),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                Spacer(),
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      bottom: 10),
                                                  height: 70.h,
                                                  child: InkWell(
                                                    onTap: () {
                                                      if ((state.cartCollection ==
                                                                  null ||
                                                              state
                                                                  .cartCollection!
                                                                  .isEmpty) &&
                                                          (state.oldcartCollection ==
                                                                  null ||
                                                              state
                                                                  .oldcartCollection!
                                                                  .isEmpty)) {
                                                        // didCallOnWillPop = true;
                                                        if (Navigator.canPop(
                                                            context)) {
                                                          if (Navigator.of(
                                                                  context)
                                                              .canPop()) {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            return;
                                                            // منع الإغلاق بعد تنفيذ pop
                                                          }

                                                          // يسمح بالإغلاق إذا لم تنطبق أي من الشروط

                                                          appBloc.add(
                                                              ChangeBasePage(
                                                                  0));
                                                          homeBloc.add(
                                                              ResetAllSelectedAppliedFilterEvent());
                                                          return;
                                                        } else {
                                                          appBloc.add(
                                                              ChangeBasePage(
                                                                  0));
                                                          return;
                                                        }
                                                      } else {
                                                        if (prefsRepository
                                                                .isVerifiedPhone !=
                                                            true) {
                                                          context.go(GRouter
                                                              .config
                                                              .applicationRoutes
                                                              .kRegistrationPagePath);
                                                        } else {
                                                          Navigator.of(context)
                                                              .push(
                                                                  MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    OrderPage(),
                                                          ));
                                                        }
                                                      }
                                                      ;
                                                    },
                                                    child: Container(
                                                        alignment:
                                                            Alignment.center,
                                                        child: ((state.cartCollection ==
                                                                        null ||
                                                                    state
                                                                        .cartCollection!
                                                                        .isEmpty) &&
                                                                (state.oldcartCollection ==
                                                                        null ||
                                                                    state
                                                                        .oldcartCollection!
                                                                        .isEmpty))
                                                            ? Text(
                                                                "Back To Home",
                                                                style: context
                                                                    .textTheme
                                                                    .bodyMedium
                                                                    ?.la
                                                                    .copyWith(
                                                                  fontSize: 18,
                                                                  color: const Color(
                                                                      0xffFEFEFE),
                                                                  letterSpacing:
                                                                      0.18,
                                                                ),
                                                              )
                                                            : Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Text(
                                                                        "Confirm ",
                                                                        style: context
                                                                            .textTheme
                                                                            .bodyMedium
                                                                            ?.la
                                                                            .copyWith(
                                                                          fontSize:
                                                                              18,
                                                                          color:
                                                                              const Color(0xffFEFEFE),
                                                                          letterSpacing:
                                                                              0.18,
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        "&",
                                                                        style: context
                                                                            .textTheme
                                                                            .bodyMedium
                                                                            ?.ld
                                                                            .copyWith(
                                                                          fontSize:
                                                                              18,
                                                                          color:
                                                                              const Color(0xffFEFEFE),
                                                                          letterSpacing:
                                                                              0.18,
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        " Continue",
                                                                        style: context
                                                                            .textTheme
                                                                            .bodyMedium
                                                                            ?.la
                                                                            .copyWith(
                                                                          fontSize:
                                                                              18,
                                                                          color:
                                                                              const Color(0xffFEFEFE),
                                                                          letterSpacing:
                                                                              0.18,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Text(
                                                                        "${totlalQuantity.round()} ",
                                                                        style: context
                                                                            .textTheme
                                                                            .bodyMedium
                                                                            ?.ba
                                                                            .copyWith(
                                                                          fontSize:
                                                                              14,
                                                                          color:
                                                                              const Color(0xffFEFEFE),
                                                                          letterSpacing:
                                                                              0.18,
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        "Item",
                                                                        style: context
                                                                            .textTheme
                                                                            .bodyMedium
                                                                            ?.ra
                                                                            .copyWith(
                                                                          fontSize:
                                                                              14,
                                                                          color:
                                                                              const Color(0xffFEFEFE),
                                                                          letterSpacing:
                                                                              0.18,
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        " ${totlalOfferPrice.toStringAsFixed(state.startingSetting?.decimalPointSetting ?? 2)} ",
                                                                        style: context
                                                                            .textTheme
                                                                            .bodyMedium
                                                                            ?.ba
                                                                            .copyWith(
                                                                          fontSize:
                                                                              14,
                                                                          color:
                                                                              const Color(0xffFEFEFE),
                                                                          letterSpacing:
                                                                              0.18,
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        priceSymbol ??
                                                                            ' \$',
                                                                        style: context
                                                                            .textTheme
                                                                            .bodyMedium
                                                                            ?.ra
                                                                            .copyWith(
                                                                          decorationColor:
                                                                              Color(0xffFEFEFE),
                                                                          fontSize:
                                                                              14,
                                                                          color:
                                                                              Color(0xffFEFEFE),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                        margin: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    20.w),
                                                        width: 390.w,
                                                        height: 70.h,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                          color:
                                                              Color(0xff3C3C3C),
                                                        )),
                                                  ),
                                                ),
                                              ],
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                          ],
                        ),
                      ),
                    )
                  ],
                );
              },
            )),
      ),
    );
  }
}
