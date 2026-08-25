import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_event.dart';
import 'package:trydos/features/home/data/models/get_list_of_customer_addresses_model.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/widgets/cart_section/cart_delivary_adress.dart';
import 'package:trydos/features/home/presentation/widgets/cart_section/payment_method.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/product_details_image_widget.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/routes/router.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_events.dart';
import 'package:trydos/service/language_service.dart';
import '../../../../../service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import '../../../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import 'package:trydos/common/helper/dev_log.dart';

class SuccessfullOrder extends StatefulWidget {
  final List<Map<String, String>> cartImages;
  final double totalPrice;
  final double orderAmount;
  final double partialPaymentByWallet;
  final ValueNotifier<List<String>> paymentMethods;
  final List<String> availablePaymentMethod;
  final String currencySympole;
  final CustomerAddressesInfo customerAddressesInfo;
  final double decimalPointSetting;
  final String orderGroupId;
  final String currencySymbol;
  const SuccessfullOrder({
    super.key,
    required this.totalPrice,
    required this.customerAddressesInfo,
    required this.cartImages,
    required this.paymentMethods,
    required this.currencySympole,
    required this.availablePaymentMethod,
    required this.decimalPointSetting,
    required this.orderAmount,
    required this.orderGroupId,
    required this.currencySymbol,
    required this.partialPaymentByWallet,
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
    LastPagesTracker.push("SuccessfullOrder Page");
    appBloc = BlocProvider.of<AppBloc>(context);
    devLog("GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG${widget.cartImages}");
    homeBloc = BlocProvider.of<HomeBloc>(context);
    homeBloc.add(const RemoveItemsFromCartAfterOrderSuccessEvent());
    homeBloc.add(const GetCartItemEvent());
    super.initState();
  }

  bool _eventLogged = false;
  @override
  void didChangeDependencies() {
    if (!_eventLogged) {
      FirebaseAnalyticsService.logEventForSession(
        executedEventName: GlobalScreenConst.ORDER_SUCCESS_SCREEN,
        eventName: GlobalScreenConst.ORDER_SUCCESS_SCREEN,
        extraParams: {
          'screen_name': GlobalScreenConst.ORDER_SUCCESS_SCREEN,
          'screen_path': '',
          'platform': GlobalPlatform.MOBILE,
        },
      );

      _eventLogged = true;
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return
    // ignore: deprecated_member_use
    WillPopScope(
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
                  margin: EdgeInsets.symmetric(horizontal: 10.w),
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      buildPurchaseWasCompletedWidget(context),
                      //////////////////////
                      buildBagWidget(context),
                      //////////////////////////////
                      SizedBox(height: 10.h),
                      //////////////////////////////
                      buildAddressSuccessWidget(context),
                      //////////////////////////////
                      SizedBox(height: 10.h),
                      //////////////////////////////
                      PaymentMethod(
                        paymentMethods: widget.paymentMethods,
                        fromPalceOrder: true,
                        fromSuccessOrder: true,
                        availablePaymentMethod: widget.availablePaymentMethod,
                        totalPrice: widget.totalPrice,
                        amount: widget.orderAmount,
                        partialPaymentByWallet: widget.partialPaymentByWallet,
                        decimalPointSetting: widget.decimalPointSetting,
                        currencySymbol: widget.currencySymbol,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ////////////////////////////////
            Container(
              height: 80.h,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color.fromRGBO(255, 255, 255, 1),
                ),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 10,
                    blurStyle: BlurStyle.solid,
                    color: Color(0xffF1F1F1),
                  ),
                ],
                color: const Color.fromRGBO(255, 255, 255, 1),
              ),
              width: 1.sw,
              child: InkWell(
                onTap: () {
                  appBloc.add(ChangeBasePage(0));
                  context.go(GRouter.config.kRootRoute);
                },
                child: Container(
                  height: 70.h,
                  margin: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    color: const Color(0xff1D1D1D),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          LocaleKeys.done.tr(),
                          style: context.textTheme.bodyMedium?.mq.copyWith(
                            color: const Color(0xffFEFEFE),
                            letterSpacing: 0.18,
                            fontSize: 18.sp,
                            height: 0.8,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          LocaleKeys.back_to_home_page.tr(),
                          style: context.textTheme.bodyMedium?.rq.copyWith(
                            color: const Color(0xffFEFEFE),
                            letterSpacing: 0.18,
                            fontSize: 14.sp,
                            height: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAddressSuccessWidget(BuildContext context) {
    return Container(
      height: 180.h,
      width: 1.sw,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(left: 10.w, right: 10.w),
            child: Row(
              children: [
                SvgPicture.asset(AppAssets.deliveryAddressSvg, height: 15.h),
                SizedBox(width: 7.w),
                Text(
                  "${LocaleKeys.shipping_delivery_address.tr()} ",
                  style: context.textTheme.bodyMedium?.rq.copyWith(
                    color: const Color(0xff1D1D1D),
                    letterSpacing: 0.18,
                    fontSize: 14.sp,
                    height: 0.8,
                  ),
                ),
                SizedBox(width: 5.w),
                SvgPicture.asset(AppAssets.freeShippingSvg),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 35.w),
            child: Text(
              "${LocaleKeys.shipment_will_be_sent_to_the_address_below.tr()} ",
              style: context.textTheme.bodyMedium?.rq.copyWith(
                color: const Color(0xff8D8D8D),
                letterSpacing: 0.18,
                fontSize: 12.sp,
                height: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
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
      height: 170.h,
      width: 1.sw,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 22.h,
            child: Row(
              children: [
                SvgPicture.asset(AppAssets.bagsSvg, height: 20.h),
                SizedBox(width: 7.w),
                Text(
                  "${LocaleKeys.your_shopping_bag.tr()} ",
                  style: context.textTheme.bodyMedium?.rq.copyWith(
                    color: const Color(0xff1D1D1D),
                    letterSpacing: 0.18,
                    fontSize: 14.sp,
                    height: 1.33,
                  ),
                ),
                Text(
                  "${widget.cartImages.length} item",
                  style: context.textTheme.bodyMedium?.bq.copyWith(
                    color: const Color(0xff1D1D1D),
                    letterSpacing: 0.18,
                    fontSize: 13.sp,
                    height: 1.33,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Container(
            margin: EdgeInsets.only(
              top: 5.h,
              left: (LanguageService.languageCode == "ar") ? 0 : 10.w,
              right: (LanguageService.languageCode == "ar") ? 10.w : 0,
            ),
            height: 135.h,
            child: ListView.separated(
              separatorBuilder: (context, index) => const SizedBox(width: 5),
              scrollDirection: Axis.horizontal,
              itemCount: widget.cartImages.length,
              itemBuilder: (context, index) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: const Color(0x707070),
                ),
                width: 91.w,
                child: Column(
                  children: [
                    Container(
                      height: 100.h,
                      child: ProductDetailsImageWidget(
                        withInnerShadow: false,
                        imageFit: BoxFit.cover,
                        blurRadius: 0,
                        imageUrl: widget.cartImages[index]["image"],
                        width: 91.w,
                        radius: 15.r,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.cartImages[index]["size"]}',
                      style: context.textTheme.bodyMedium?.rq.copyWith(
                        color: const Color(0xff1D1D1D),
                        letterSpacing: 0.18,
                        fontSize: 10.sp,
                        height: 1.33,
                      ),
                    ),
                    Text(
                      '${widget.cartImages[index]["color"]}',
                      style: context.textTheme.bodyMedium?.rq.copyWith(
                        color: const Color(0xff1D1D1D),
                        letterSpacing: 0.18,
                        fontSize: 10.sp,
                        height: 1.33,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container buildPurchaseWasCompletedWidget(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      margin: EdgeInsets.only(top: 40.h),
      width: 1.sw,
      height: 350.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(AppAssets.success1Svg, height: 64.h),
              SvgPicture.asset(AppAssets.success2Svg, height: 20.h),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            "${LocaleKeys.the_purchase_was_completed_successfully.tr()} ",
            style: context.textTheme.bodyMedium?.rq.copyWith(
              color: const Color(0xff1D1D1D),
              letterSpacing: 0.18,
              fontSize: 14.sp,
              height: 1.33,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            "${LocaleKeys.your_order_number.tr()} ",
            style: context.textTheme.bodyMedium?.rq.copyWith(
              color: const Color(0xff1D1D1D),
              letterSpacing: 0.18,
              fontSize: 12.sp,
              height: 1.33,
            ),
          ),
          Text(
            widget.orderGroupId,
            style: context.textTheme.bodyMedium?.bq.copyWith(
              color: const Color(0xff404040),
              letterSpacing: 0.18,
              fontSize: 20.sp,
              height: 1.33,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(AppAssets.orderInvoiceSvg),
              SizedBox(width: 10.w),
              Text(
                "${LocaleKeys.order_invoice.tr()} ",
                style: context.textTheme.bodyMedium?.rq.copyWith(
                  color: const Color(0xff1D1D1D),
                  letterSpacing: 0.18,
                  fontSize: 12.sp,
                  height: 1.33,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          SvgPicture.asset(AppAssets.infoSvg),
          SizedBox(height: 10.h),
          Text(
            "${LocaleKeys.you_can_track_the_status_of_your_order_through.tr()} ",
            style: context.textTheme.bodyMedium?.rq.copyWith(
              color: const Color(0xff388CFF),
              letterSpacing: 0.18,
              fontSize: 12.sp,
              height: 1.33,
            ),
          ),
          SizedBox(height: 15.h),
          Text(
            "${LocaleKeys.my_account_my_orders.tr()} ",
            style: context.textTheme.bodyMedium?.rq.copyWith(
              color: const Color.fromARGB(255, 3, 3, 3),
              letterSpacing: 0.18,
              fontSize: 12.sp,
              height: 1.33,
            ),
          ),
        ],
      ),
    );
  }
}
