import 'dart:math';

import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:local_hero/local_hero.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trydos/base_page.dart';

import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/helper/helper_functions.dart';

import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/app_elvated_button.dart';

import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_event.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/app/svg_network_widget.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/authentication/presentation/pages/first_registeration_page.dart';
import 'package:trydos/features/chat/domain/use_cases/get_image_width_and_height_usecase.dart';
import 'package:trydos/features/home/data/models/get_list_of_customer_addresses_model.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/cart_section/add_shipping_address.dart';
import 'package:trydos/features/home/presentation/widgets/cart_section/cart_delivary_adress.dart';
import 'package:trydos/features/home/presentation/widgets/cart_section/payment_method.dart';

import 'package:trydos/features/home/presentation/widgets/cart_section/product_collection_in_cart_page1.dart';
import 'package:trydos/features/home/presentation/widgets/cart_section/successful_order.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/product_details_image_widget.dart';
import 'package:trydos/features/story/presentation/widget/try_again.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/main.dart';
import 'package:trydos/routes/router.dart';
import 'package:trydos/service/language_service.dart';

import '../../../../../service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import '../../../../../service/firebase_analytics_service/firebase_analytics_service.dart';

class PlaceOrder extends StatefulWidget {
  final List<Map<String, String>> cartImages;
  final String totalPrice;
  final ValueNotifier<String> paymentMethod;
  final String currencySympole;
  final CustomerAddressesInfo customerAddressesInfo;
  const PlaceOrder({
    required this.totalPrice,
    required this.customerAddressesInfo,
    required this.cartImages,
    required this.paymentMethod,
    required this.currencySympole,
    Key? key,
  });
  @override
  State<PlaceOrder> createState() => _PlaceOrderState();
}

class _PlaceOrderState extends State<PlaceOrder> {
  late HomeBloc homeBloc;

  final ValueNotifier<bool> agreeToPolicies = ValueNotifier(false);

  @override
  void initState() {
    homeBloc = BlocProvider.of<HomeBloc>(context);
    homeBloc.add(GetCustomerAddressesEvent());
//    appBloc = BlocProvider.of<AppBloc>(context);

    // homeBloc = BlocProvider.of<HomeBloc>(context);

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
    return WillPopScope(
        onWillPop: () async {
          // didCallOnWillPop = true;
          if (Navigator.canPop(context)) {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();

              return false;
              // منع الإغلاق بعد تنفيذ pop
            }

            // يسمح بالإغلاق إذا لم تنطبق أي من الشروط
          }
          return true;
        },
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            body: Stack(
              children: [
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 60),
                      width: 1.sw,
                      height: 50.h,
                      child: Column(
                        children: [
                          Container(
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

                                      return;
                                    } else {}
                                  },
                                  child: Container(
                                    width: 40,
                                    child: Transform.rotate(
                                      angle:
                                          LanguageService.languageCode == "ar"
                                              ? pi
                                              : 0,
                                      child: SvgPicture.asset(
                                        AppAssets.backIconArrowSvg,
                                        height: 20,
                                      ),
                                    ),
                                  ),
                                ),
                                Spacer(),
                                SvgPicture.asset(
                                  AppAssets.deliveryAddressSvg,
                                  height: 20,
                                ),
                                SizedBox(
                                  width: 5.w,
                                ),
                                Text("${LocaleKeys.shipping_payment.tr()} ",
                                    style: context.textTheme.bodyMedium?.mr
                                        .copyWith(
                                            color: const Color(0xff1D1D1D),
                                            letterSpacing: 0.2,
                                            fontSize: 14,
                                            height: 1.33)),
                                SizedBox(
                                    width: LanguageService.languageCode == "ar"
                                        ? 180.w
                                        : 140.w)
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 1.sh - 120.h,
                      child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          color: Color.fromARGB(255, 255, 255, 255),
                          child: Container(
                              height: 1.sh - 110.h,
                              alignment: Alignment.topCenter,
                              child: Center(
                                  child: Column(children: [
                                Container(
                                    height: 200.h,
                                    width: 1.sw,
                                    child: Column(
                                      children: [
                                        Container(
                                            margin: EdgeInsets.all(10),
                                            height: 20.h,
                                            child: Row(children: [
                                              SvgPicture.asset(
                                                AppAssets.bagsSvg,
                                                height: 20,
                                              ),
                                              SizedBox(
                                                width: 7.w,
                                              ),
                                              Text(
                                                "${LocaleKeys.your_shopping_bag.tr()} ",
                                                style: context
                                                    .textTheme.bodyMedium?.ra
                                                    .copyWith(
                                                        color: const Color(
                                                            0xff1D1D1D),
                                                        letterSpacing: 0.18,
                                                        fontSize: 14,
                                                        height: 1.33),
                                              ),
                                              Text(
                                                "${widget.cartImages.length} item",
                                                style: context
                                                    .textTheme.bodyMedium?.br
                                                    .copyWith(
                                                        color: const Color(
                                                            0xff1D1D1D),
                                                        letterSpacing: 0.18,
                                                        fontSize: 13,
                                                        height: 1.33),
                                              ),
                                            ])),
                                        Container(
                                          margin: EdgeInsets.only(
                                              left: (LanguageService
                                                          .languageCode ==
                                                      "ar")
                                                  ? 0
                                                  : 10,
                                              right: (LanguageService
                                                          .languageCode ==
                                                      "ar")
                                                  ? 10
                                                  : 0),
                                          height: 157.h,
                                          child: ListView.separated(
                                              separatorBuilder:
                                                  (context, index) => SizedBox(
                                                        width: 5,
                                                      ),
                                              scrollDirection: Axis.horizontal,
                                              itemCount:
                                                  widget.cartImages.length,
                                              itemBuilder: (context, index) =>
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      color: Color(0x707070),
                                                    ),
                                                    width: 91.w,
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          height: 125.h,
                                                          child:
                                                              ProductDetailsImageWidget(
                                                            withBackGroundShadow:
                                                                true,
                                                            withInnerShadow:
                                                                false,
                                                            imageFit:
                                                                BoxFit.cover,
                                                            blurRadius: 0,
                                                            imageUrl: widget
                                                                    .cartImages[
                                                                index]["image"],
                                                            width: 91.w,
                                                            radius: 15,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 2,
                                                        ),
                                                        Text(
                                                          '${widget.cartImages[index]["size"]}',
                                                          style: context
                                                              .textTheme
                                                              .bodyMedium
                                                              ?.rr
                                                              .copyWith(
                                                                  color: const Color(
                                                                      0xff1D1D1D),
                                                                  letterSpacing:
                                                                      0.18,
                                                                  fontSize: 10,
                                                                  height: 1.33),
                                                        ),
                                                        Text(
                                                          '${widget.cartImages[index]["color"]}',
                                                          style: context
                                                              .textTheme
                                                              .bodyMedium
                                                              ?.rr
                                                              .copyWith(
                                                                  color: const Color(
                                                                      0xff1D1D1D),
                                                                  letterSpacing:
                                                                      0.18,
                                                                  fontSize: 10,
                                                                  height: 1.33),
                                                        ),
                                                      ],
                                                    ),
                                                  )),
                                        )
                                      ],
                                    )),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                    height: 200.h,
                                    width: 1.sw,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                            margin: EdgeInsets.only(
                                                top: 10, left: 10, right: 10),
                                            child: Row(children: [
                                              SvgPicture.asset(
                                                AppAssets.deliveryAddressSvg,
                                                height: 16,
                                              ),
                                              SizedBox(
                                                width: 7.w,
                                              ),
                                              Text(
                                                "${LocaleKeys.shipping_delivery_address.tr()} ",
                                                style: context
                                                    .textTheme.bodyMedium?.ra
                                                    .copyWith(
                                                        color: const Color(
                                                            0xff1D1D1D),
                                                        letterSpacing: 0.18,
                                                        fontSize: 14,
                                                        height: 0.8),
                                              ),
                                              SizedBox(
                                                width: 5.w,
                                              ),
                                              SvgPicture.asset(
                                                AppAssets.freeShippingSvg,
                                              )
                                            ])),
                                        SizedBox(
                                          height: 5.h,
                                        ),
                                        Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 35.w),
                                            child: Text(
                                              "${LocaleKeys.shipment_will_be_sent_to_the_address_below.tr()} ",
                                              style: context
                                                  .textTheme.bodyMedium?.ra
                                                  .copyWith(
                                                      color: const Color(
                                                          0xff8D8D8D),
                                                      letterSpacing: 0.18,
                                                      fontSize: 12,
                                                      height: 0.8),
                                            )),
                                        SizedBox(
                                          height: 12.h,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: AddressInfoWithContactInfoCart(
                                            cartChoosed: true,
                                            placeOrder: true,
                                            isDelete: false,
                                            customerAddressesInfo:
                                                widget.customerAddressesInfo,
                                            context: context,
                                            index: -1,
                                            indexTap: -2,
                                            onTapDelete: () {},
                                            onTapEdit: () {
                                              ;
                                            },
                                          ),
                                        ),
                                      ],
                                    )),
                                PaymentMethod(
                                    fromSuccessOrder: false,
                                    fromPalceOrder: true,
                                    paymentMethod: widget.paymentMethod),
                                SizedBox(
                                  height: 10.h,
                                ),
                                Spacer(),
                                InkWell(
                                  onTap: () {
                                    agreeToPolicies.value =
                                        !agreeToPolicies.value;
                                  },
                                  child: ValueListenableBuilder<bool>(
                                      valueListenable: agreeToPolicies,
                                      builder: (context, _agreeToPolicies, _) {
                                        return Container(
                                            margin: EdgeInsets.all(15),
                                            height: 40.h,
                                            width: 1.sw,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: const Color(0xff388CFF),
                                              ),
                                              color: _agreeToPolicies
                                                  ? Color(0xffF5FFF8)
                                                  : Color(0xffF8F8F8),
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                SizedBox(width: 29.w),
                                                SvgPicture.asset(
                                                    AppAssets.detectedSvg,
                                                    color: _agreeToPolicies
                                                        ? Color(0xff388CFF)
                                                        : Color(0xff8E8E8E)),
                                                SizedBox(
                                                  width: 20,
                                                ),
                                                SizedBox(width: 10.w),
                                                Text(
                                                  "${LocaleKeys.i_read_and_agree_to_the.tr()}",
                                                  style: context
                                                      .textTheme.bodyMedium?.rr
                                                      .copyWith(
                                                          color:
                                                              Color(0xff1D1D1D),
                                                          letterSpacing: 0.18,
                                                          fontSize: 12,
                                                          height: 1.33),
                                                ),
                                                Text(
                                                  " ${LocaleKeys.policies.tr()}",
                                                  style: context
                                                      .textTheme.bodyMedium?.rr
                                                      .copyWith(
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          decorationColor:
                                                              const Color(
                                                                  0xff388CFF),
                                                          color:
                                                              Color(0xff388CFF),
                                                          letterSpacing: 0.18,
                                                          fontSize: 12,
                                                          height: 1.33),
                                                ),
                                                Text(
                                                  " ${LocaleKeys.and.tr()} ",
                                                  style: context
                                                      .textTheme.bodyMedium?.rr
                                                      .copyWith(
                                                          color:
                                                              Color(0xff1D1D1D),
                                                          letterSpacing: 0.18,
                                                          fontSize: 12,
                                                          height: 1.33),
                                                ),
                                                Text(
                                                  "${LocaleKeys.terms.tr()}",
                                                  style: context
                                                      .textTheme.bodyMedium?.rr
                                                      .copyWith(
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          decorationColor:
                                                              const Color(
                                                                  0xff388CFF),
                                                          color:
                                                              Color(0xff388CFF),
                                                          letterSpacing: 0.18,
                                                          fontSize: 12,
                                                          height: 1.33),
                                                )
                                              ],
                                            ));
                                      }),
                                ),
                                ValueListenableBuilder<bool>(
                                    valueListenable: agreeToPolicies,
                                    builder: (context, _agreeToPolicies, _) {
                                      return Container(
                                          height: 100.h,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Color.fromRGBO(
                                                  255, 255, 255, 1),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                blurRadius: 10,
                                                blurStyle: BlurStyle.solid,
                                                color: Color(0xffF1F1F1),
                                              )
                                            ],
                                            color: Color.fromRGBO(
                                                255, 255, 255, 1),
                                          ),
                                          width: 1.sw,
                                          child: InkWell(
                                            onTap: () {
                                              if (_agreeToPolicies) {
                                                HelperFunctions
                                                    .slidingNavigation(
                                                        context,
                                                        SuccessfulOrder(
                                                          cartImages:
                                                              widget.cartImages,
                                                          currencySympole: widget
                                                              .currencySympole,
                                                          customerAddressesInfo:
                                                              widget
                                                                  .customerAddressesInfo,
                                                          paymentMethod: widget
                                                              .paymentMethod,
                                                          totalPrice:
                                                              widget.totalPrice,
                                                        ));
                                              }
                                            },
                                            child: Container(
                                              height: 70.h,
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 10),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  color: _agreeToPolicies
                                                      ? Color(0xff346BFF)
                                                      : Color(0xffC4C2C2)),
                                              child: Center(
                                                  child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    LocaleKeys.place_order.tr(),
                                                    style: context.textTheme
                                                        .bodyMedium?.mr
                                                        .copyWith(
                                                            color: const Color(
                                                                0xffFEFEFE),
                                                            letterSpacing: 0.18,
                                                            fontSize: 18,
                                                            height: 0.8),
                                                  ),
                                                  SizedBox(
                                                    height: 10.h,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        '${widget.cartImages.length} ',
                                                        style: context.textTheme
                                                            .bodyMedium?.br
                                                            .copyWith(
                                                                color: const Color(
                                                                    0xffFEFEFE),
                                                                letterSpacing:
                                                                    0.18,
                                                                fontSize: 14,
                                                                height: 0.8),
                                                      ),
                                                      Text(
                                                        LocaleKeys.item.tr(),
                                                        style: context.textTheme
                                                            .bodyMedium?.rr
                                                            .copyWith(
                                                                color: const Color(
                                                                    0xffFEFEFE),
                                                                letterSpacing:
                                                                    0.18,
                                                                fontSize: 14,
                                                                height: 0.8),
                                                      ),
                                                      Text(
                                                        ' ${widget.totalPrice} ',
                                                        style: context.textTheme
                                                            .bodyMedium?.br
                                                            .copyWith(
                                                                color: const Color(
                                                                    0xffFEFEFE),
                                                                letterSpacing:
                                                                    0.18,
                                                                fontSize: 14,
                                                                height: 0.8),
                                                      ),
                                                      Text(
                                                        "${widget.currencySympole}",
                                                        style: context.textTheme
                                                            .bodyMedium?.rr
                                                            .copyWith(
                                                                color: const Color(
                                                                    0xffFEFEFE),
                                                                letterSpacing:
                                                                    0.18,
                                                                fontSize: 14,
                                                                height: 0.8),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              )),
                                            ),
                                          ));
                                    })
                              ])))),
                    )
                  ],
                ),
              ],
            )));
  }
}
