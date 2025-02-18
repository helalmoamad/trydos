import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_event.dart';
import 'package:trydos/features/home/data/models/get_list_of_customer_addresses_model.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/widgets/cart_section/cart_delivary_adress.dart';
import 'package:trydos/features/home/presentation/widgets/cart_section/payment_method.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/product_details_image_widget.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/routes/router.dart';
import 'package:trydos/service/language_service.dart';
import '../../../../../service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import '../../../../../service/firebase_analytics_service/firebase_analytics_service.dart';

class SuccessfullOrder extends StatefulWidget {
  final List<Map<String, String>> cartImages;
  final double totalPrice;
  final double orderAmount;
  final ValueNotifier<List<String>> paymentMethods;
  final List<String> availablePaymentMethod;
  final String currencySympole;
  final CustomerAddressesInfo customerAddressesInfo;
  final int decimalPointSetting;
  final String orderGroupId;
  const SuccessfullOrder({
    required this.totalPrice,
    required this.customerAddressesInfo,
    required this.cartImages,
    required this.paymentMethods,
    required this.currencySympole,
    Key? key,
    required this.availablePaymentMethod,
    required this.decimalPointSetting,
    required this.orderAmount,
    required this.orderGroupId,
  });
  @override
  State<SuccessfullOrder> createState() => _SuccessfullOrderState();
}

class _SuccessfullOrderState extends State<SuccessfullOrder> {
  late HomeBloc homeBloc;
  late AppBloc appBloc;
  final ValueNotifier<bool> agreeToPolicies = ValueNotifier(false);

  @override
  void initState() {
    appBloc = BlocProvider.of<AppBloc>(context);

    homeBloc = BlocProvider.of<HomeBloc>(context);
    homeBloc.add(RemoveItemsFromCartAfterOrderSuccessEvent());
    homeBloc.add(GetCartItemEvent(fromTerminitedStatusl: true));
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
        appBloc.add(ChangeBasePage(0));
        // didCallOnWillPop = true;
        context.go(GRouter.config.kRootRoute);
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      buildPurchaseWasCompletedWidget(context),
                      //////////////////////
                      buildBagWidget(context),
                      //////////////////////////////
                      SizedBox(
                        height: 10.h,
                      ),
                      //////////////////////////////
                      buildAddressSuccessWidget(
                        context,
                      ),
                      //////////////////////////////
                      SizedBox(
                        height: 10.h,
                      ),
                      //////////////////////////////
                      PaymentMethod(
                        paymentMethods: widget.paymentMethods,
                        fromPalceOrder: true,
                        fromSuccessOrder: true,
                        availablePaymentMethod: widget.availablePaymentMethod,
                        totalPrice: widget.totalPrice,
                        amount: widget.orderAmount,
                        decimalPointSetting: widget.decimalPointSetting,
                      )
                    ],
                  ),
                ),
              ),
            ),
            ////////////////////////////////
            Container(
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color.fromRGBO(255, 255, 255, 1),
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    blurStyle: BlurStyle.solid,
                    color: Color(0xffF1F1F1),
                  ),
                ],
                color: Color.fromRGBO(255, 255, 255, 1),
              ),
              width: 1.sw,
              child: InkWell(
                onTap: () {
                  appBloc.add(ChangeBasePage(0));
                  context.go(GRouter.config.kRootRoute);
                },
                child: Container(
                  height: 70.h,
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color(0xff1D1D1D)),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          LocaleKeys.done.tr(),
                          style: context.textTheme.bodyMedium?.mr.copyWith(
                              color: const Color(0xffFEFEFE),
                              letterSpacing: 0.18,
                              fontSize: 18,
                              height: 0.8),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Text(
                          LocaleKeys.back_to_home_page.tr(),
                          style: context.textTheme.bodyMedium?.rr.copyWith(
                              color: const Color(0xffFEFEFE),
                              letterSpacing: 0.18,
                              fontSize: 14,
                              height: 0.8),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildAddressSuccessWidget(
    BuildContext context,
  ) {
    return Container(
      height: 160,
      width: 1.sw,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(left: 10, right: 10),
            child: Row(
              children: [
                SvgPicture.asset(
                  AppAssets.deliveryAddressSvg,
                  height: 15,
                ),
                SizedBox(
                  width: 7.w,
                ),
                Text(
                  "${LocaleKeys.shipping_delivery_address.tr()} ",
                  style: context.textTheme.bodyMedium?.ra.copyWith(
                      color: const Color(0xff1D1D1D),
                      letterSpacing: 0.18,
                      fontSize: 14,
                      height: 0.8),
                ),
                SizedBox(
                  width: 5.w,
                ),
                SvgPicture.asset(
                  AppAssets.freeShippingSvg,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 35.w),
            child: Text(
              "${LocaleKeys.shipment_will_be_sent_to_the_address_below.tr()} ",
              style: context.textTheme.bodyMedium?.ra.copyWith(
                  color: const Color(0xff8D8D8D),
                  letterSpacing: 0.18,
                  fontSize: 12,
                  height: 0.8),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: addressInfoWithContactInfoCart(
              cartChoosed: true,
              placeOrder: false,
              successfulOrder: true,
              isDelete: false,
              customerAddressesInfo: widget.customerAddressesInfo,
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
      ),
    );
  }

  Widget buildBagWidget(BuildContext context) {
    return Container(
      height: 165,
      width: 1.sw,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 22,
            child: Row(
              children: [
                SvgPicture.asset(
                  AppAssets.bagsSvg,
                  height: 20,
                ),
                SizedBox(
                  width: 7.w,
                ),
                Text(
                  "${LocaleKeys.your_shopping_bag.tr()} ",
                  style: context.textTheme.bodyMedium?.ra.copyWith(
                      color: const Color(0xff1D1D1D),
                      letterSpacing: 0.18,
                      fontSize: 14,
                      height: 1.33),
                ),
                Text(
                  "${widget.cartImages.length} item",
                  style: context.textTheme.bodyMedium?.br.copyWith(
                      color: const Color(0xff1D1D1D),
                      letterSpacing: 0.18,
                      fontSize: 13,
                      height: 1.33),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 2,
          ),
          Container(
            margin: EdgeInsets.only(
                top: 5.h,
                left: (LanguageService.languageCode == "ar") ? 0 : 10,
                right: (LanguageService.languageCode == "ar") ? 10 : 0),
            height: 135,
            child: ListView.separated(
              separatorBuilder: (context, index) => SizedBox(
                width: 5,
              ),
              scrollDirection: Axis.horizontal,
              itemCount: widget.cartImages.length,
              itemBuilder: (context, index) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Color(0x707070),
                ),
                width: 91.w,
                child: Column(
                  children: [
                    Container(
                      height: 100,
                      child: ProductDetailsImageWidget(
                        withBackGroundShadow: true,
                        withInnerShadow: false,
                        imageFit: BoxFit.cover,
                        blurRadius: 0,
                        imageUrl: widget.cartImages[index]["image"],
                        width: 91.w,
                        radius: 15,
                      ),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Text(
                      '${widget.cartImages[index]["size"]}',
                      style: context.textTheme.bodyMedium?.rr.copyWith(
                          color: const Color(0xff1D1D1D),
                          letterSpacing: 0.18,
                          fontSize: 10,
                          height: 1.33),
                    ),
                    Text(
                      '${widget.cartImages[index]["color"]}',
                      style: context.textTheme.bodyMedium?.rr.copyWith(
                          color: const Color(0xff1D1D1D),
                          letterSpacing: 0.18,
                          fontSize: 10,
                          height: 1.33),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Container buildPurchaseWasCompletedWidget(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      margin: EdgeInsets.only(top: 50),
      width: 1.sw,
      height: 255,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(
                AppAssets.success1Svg,
              ),
              SvgPicture.asset(
                AppAssets.success2Svg,
              )
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "${LocaleKeys.the_purchase_was_completed_successfully.tr()} ",
            style: context.textTheme.bodyMedium?.rr.copyWith(
                color: const Color(0xff1D1D1D),
                letterSpacing: 0.18,
                fontSize: 14,
                height: 1.33),
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            "${LocaleKeys.your_order_number.tr()} ",
            style: context.textTheme.bodyMedium?.rr.copyWith(
                color: const Color(0xff1D1D1D),
                letterSpacing: 0.18,
                fontSize: 12,
                height: 1.33),
          ),
          Text(
            widget.orderGroupId,
            style: context.textTheme.bodyMedium?.br.copyWith(
                color: const Color(0xff404040),
                letterSpacing: 0.18,
                fontSize: 20,
                height: 1.33),
          ),
          SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                AppAssets.orderInvoiceSvg,
              ),
              SizedBox(
                width: 10.w,
              ),
              Text(
                "${LocaleKeys.order_invoice.tr()} ",
                style: context.textTheme.bodyMedium?.rr.copyWith(
                    color: const Color(0xff1D1D1D),
                    letterSpacing: 0.18,
                    fontSize: 12,
                    height: 1.33),
              )
            ],
          ),
          SizedBox(
            height: 8,
          ),
          SvgPicture.asset(
            AppAssets.infoSvg,
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            "${LocaleKeys.you_can_track_the_status_of_your_order_through.tr()} ",
            style: context.textTheme.bodyMedium?.rr.copyWith(
                color: const Color(0xff388CFF),
                letterSpacing: 0.18,
                fontSize: 12,
                height: 1.33),
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            "${LocaleKeys.my_account_my_orders.tr()} ",
            style: context.textTheme.bodyMedium?.rr.copyWith(
                color: const Color(0xff388CFF),
                letterSpacing: 0.18,
                fontSize: 12,
                height: 1.33),
          )
        ],
      ),
    );
  }
}
