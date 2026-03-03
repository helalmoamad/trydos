import 'dart:math';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/authentication/presentation/widgets/insert_phone_tab.dart';
import 'package:trydos/features/authentication/presentation/widgets/verification_methods.dart';
import 'package:trydos/features/authentication/presentation/widgets/verify_otp.dart';
import 'package:trydos/features/home/domain/use_cases/wallet_checkout_usecase.dart';
import 'package:uuid/uuid.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/home/data/models/get_list_of_customer_addresses_model.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/orderBloc/order_event.dart';
import 'package:trydos/features/home/presentation/widgets/cart_section/cart_delivary_adress.dart';
import 'package:trydos/features/home/presentation/widgets/cart_section/payment_method.dart';
import 'package:trydos/features/home/presentation/widgets/cart_section/successful_order.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/product_details_image_widget.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_buttons_event_name.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_events.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import 'package:trydos/service/language_service.dart';
import '../../../../../common/constant/payment_methods.dart';
import '../../../../../common/helper/show_message.dart';
import '../../../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../../data/models/place_order_model.dart';
import '../../../domain/use_cases/place_order_usecase.dart';
import '../../manager/homeBloc/home_state.dart';
import '../../manager/orderBloc/order_bloc.dart';
import '../../manager/orderBloc/order_state.dart';
import 'payment_webview.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';

class PlaceOrder extends StatefulWidget {
  final List<Map<String, String>> cartImages;
  final List<String> availablePaymentMethod;
  final double totalPrice;
  final double totalCashed;
  final double walletBalance;
  final String cartGroupId;
  final List<String> listCartGroupIds;
  final ValueNotifier<List<String>> paymentMethods;
  final String currencySympole;
  final CustomerAddressesInfo customerAddressesInfo;
  final double decimalPointSetting;

  final double exchangeRate;
  const PlaceOrder({
    super.key,
    required this.totalPrice,
    required this.customerAddressesInfo,
    required this.cartImages,
    required this.paymentMethods,
    required this.listCartGroupIds,
    required this.currencySympole,
    required this.exchangeRate,
    required this.availablePaymentMethod,
    required this.decimalPointSetting,
    required this.cartGroupId,

    required this.totalCashed,
    required this.walletBalance,
  });
  @override
  State<PlaceOrder> createState() => _PlaceOrderState();
}

class _PlaceOrderState extends State<PlaceOrder> {
  final ValueNotifier<bool> agreeToPolicies = ValueNotifier(false);
  final PanelController panelController = PanelController();
  final PageController pageController = PageController();
  final FocusNode focusNode = FocusNode();
  final OrderBloc orderBloc = GetIt.I<OrderBloc>();
  String phoneNumber = '';
  int isVisWhatsApp = 0;
  final ValueNotifier<bool> isVerified = ValueNotifier(true);
  PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  @override
  void initState() {
    print("PlaceOrder PageRRRRRRRRRRRRRRRRRRRRRRRRRRR${widget.cartImages}");
    LastPagesTracker.push("PlaceOrder Page");
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return
    // ignore: deprecated_member_use
    WillPopScope(
      onWillPop: () async {
        if (Navigator.canPop(context)) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();

            return false;
          }
        }
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: BlocListener<HomeBloc, HomeState>(
          listenWhen: (previous, current) =>
              (previous.checkWithGetCartStatus !=
                  current.checkWithGetCartStatus &&
              current.checkWithGetCartStatus ==
                  CheckWithGetCartStatus.successForPlaceOrder),
          listener: (context, state) {
            if (state.checkWithGetCartStatus ==
                CheckWithGetCartStatus.successForPlaceOrder) {
              if (!state.cartCollection!.any(
                (element) =>
                    (element.isActive == false ||
                    element.isCountryRestricted == true ||
                    element.checkAvailability == false),
              )) {
                if (widget.paymentMethods.value.contains(
                  PaymentMethods.trydosWallet,
                )) {
                  _showWalletPaymentDialog(context);
                  return;
                }
                String paymentMethod = '';
                int payByWallet = 0;

                if (widget.paymentMethods.value.length == 1) {
                  paymentMethod = widget.paymentMethods.value[0];
                  print(
                    "paymentMethod:  -------------------------------------${paymentMethod}",
                  );
                  //////////////
                  payByWallet = 0;
                } else {
                  if (widget.paymentMethods.value.contains(
                        PaymentMethods.trydosWallet,
                      ) &&
                      widget.paymentMethods.value.length == 2) {
                    paymentMethod = widget.paymentMethods.value.firstWhere(
                      (element) => element != PaymentMethods.trydosWallet,
                    );
                    payByWallet = 1;
                  }
                }

                PlaceOrderParams placeOrderParams = PlaceOrderParams(
                  addressId: widget.customerAddressesInfo.id!,
                  orderNote: 'orderNote',
                  paymentMethod: paymentMethod,
                  payByWallet: payByWallet,
                );

                BlocProvider.of<OrderBloc>(
                  context,
                ).add(PlaceOrderEvent(placeOrderParams: placeOrderParams));
              } else {
                //////////////////////////
                showWarningMessage(
                  context,
                  "${LocaleKeys.you_have_to_delete_all_unavailable_products.tr()}",
                );
                ////////////////////////
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              }
            }
          },
          child: BlocListener<OrderBloc, OrderState>(
            listenWhen: (previous, current) =>
                previous.placeOrderStatus != current.placeOrderStatus &&
                (current.placeOrderStatus == PlaceOrderStatus.success ||
                    current.placeOrderStatus == PlaceOrderStatus.unavailable),
            listener: (context, orderState) {
              debugPrint('placeOrderStatus:  ${orderState.placeOrderStatus}');

              if (orderState.placeOrderStatus == PlaceOrderStatus.unavailable) {
                BlocProvider.of<HomeBloc>(
                  context,
                ).add(const GetCartItemEvent());

                ////////////////////////////
                showWarningMessage(
                  context,
                  "${LocaleKeys.you_have_to_delete_all_unavailable_products.tr()}",
                );
                ////////////////////////
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              }

              if (orderState.placeOrderStatus == PlaceOrderStatus.success) {
                List<OrdersGroupDataModel>? data =
                    orderState.placeOrderModel!.data!;

                debugPrint('The url is : ${data[0].url}');

                if (data[0].url != null) {
                  HelperFunctions.slidingNavigation(
                    context,
                    PaymentWebview(
                      url: data[0].url!,
                      cartGroupId: widget.cartGroupId,
                    ),
                  );
                } else {
                  List<Map<String, String>> cartImages = [];
                  List<Map<String, String>> analyticsItems = [];
                  double orderAmount = 0;
                  double partialPaymentByWallet = 0;
                  /////////////////////////////////////////////////
                  data.forEach((e) {
                    orderAmount = orderAmount + e.orderAmount!;
                    partialPaymentByWallet =
                        partialPaymentByWallet + e.partialPaymentByWallet!;
                    e.details!.forEach((element) {
                      for (var i = 0; i < (element.qty ?? 0); i++) {
                        cartImages.add({
                          "image": element.image ?? '',
                          "size": element.variation.isNullOrEmpty
                              ? ""
                              : element.variation?[0].size ?? "",
                          "color": element.variation.isNullOrEmpty
                              ? ""
                              : element.variation?[0].color?.name ?? "",
                        });
                        ////////////////////////////
                        analyticsItems.add({
                          "item_id": element.productId.toString(),
                          "item_name": element.productDetails!.name.toString(),
                          "item_variant":
                              '${element.variation.isNullOrEmpty ? "" : element.variation?[0].color ?? ""}-${element.variation.isNullOrEmpty ? "" : element.variation?[0].size ?? ""}',
                        });
                      }
                    });
                  });
                  /////////////////////////
                  orderAmount =
                      HelperFunctions.truncateToDecimalPlaces(
                        orderAmount,
                        BlocProvider.of<HomeBloc>(context)
                            .state
                            .getCurrencyForCountryModel!
                            .data!
                            .currency!
                            .decimalDigits!,
                      ) *
                      widget.exchangeRate;

                  partialPaymentByWallet =
                      HelperFunctions.truncateToDecimalPlaces(
                        partialPaymentByWallet,
                        BlocProvider.of<HomeBloc>(context)
                            .state
                            .getCurrencyForCountryModel!
                            .data!
                            .currency!
                            .decimalDigits!,
                      ) *
                      widget.exchangeRate;
                  ////////////////////////////////
                  CustomerAddressesInfo
                  customerAddressesInfo = CustomerAddressesInfo(
                    id: data[0].shippingAddress,
                    address: data[0].shippingAddressData!.address ?? '',
                    addressDetail:
                        data[0].shippingAddressData!.addressDetail ?? '',
                    contactInfo: ContactInfo(
                      name:
                          data[0].shippingAddressData!.contactPersonName ?? '',
                      alternativePhone:
                          data[0].shippingAddressData!.alternativePhone ?? '',
                      phone: data[0].shippingAddressData!.phone ?? '',
                    ),
                    location: Location(
                      latitude: data[0].shippingAddressData!.latitude ?? '',
                      longitude: data[0].shippingAddressData!.longitude ?? '',
                    ),
                    regionDetails: RegionDetails(
                      country: data[0].shippingAddressData!.country ?? '',
                      province: data[0].shippingAddressData!.province ?? '',
                      city: data[0].shippingAddressData!.city ?? '',
                      town: data[0].shippingAddressData!.town ?? '',
                      street: data[0].shippingAddressData!.street ?? '',
                      building: data[0].shippingAddressData!.building ?? '',
                    ),
                  );
                  /////////////////////////
                  widget.paymentMethods.value = List.from(
                    widget.paymentMethods.value,
                  )..clear();

                  String paymentMethod = data[0].paymentMethod?.value ?? '';

                  // if (data[0].paymentMethod == 'trydos_wallet') {
                  //   paymentMethod = PaymentMethods.trydosWallet;
                  // } else if (data[0].paymentMethod == 'cash_on_delivery') {
                  //   paymentMethod = PaymentMethods.cod;
                  // } else {
                  //   paymentMethod = data[0].paymentMethod?.value ?? '';
                  // }

                  widget.paymentMethods.value = List.from(
                    widget.paymentMethods.value,
                  )..add(paymentMethod);

                  if (partialPaymentByWallet > 0) {
                    widget.paymentMethods.value = List.from(
                      widget.paymentMethods.value,
                    )..add(PaymentMethods.trydosWallet);
                  }

                  /////////////////////////
                  Future.delayed(const Duration(milliseconds: 300), () {
                    FirebaseAnalyticsService.logEventForSession(
                      executedEventName:
                          AnalyticsButtonsEventNameConst.PLACE_ORDER_BUTTON,
                      eventName: AnalyticsEventsConst.PURCHASE,
                      extraParams: {
                        'transaction_id': data[0].transactionRef.toString(),
                        'value': orderAmount.toString(),
                        'currency': widget.currencySympole.toString(),
                        'shipping': data[0].shippingCost.toString(),
                        'coupon': data[0].couponCode.toString(),
                        'screen_name': GlobalScreenConst.PLACE_ORDER_SCREEN,
                        'items': analyticsItems.toString(),
                      },
                    );
                  });

                  /////////////////////////
                  HelperFunctions.slidingNavigation(
                    context,
                    SuccessfullOrder(
                      cartImages: cartImages,
                      currencySympole: widget.currencySympole,
                      availablePaymentMethod: widget.availablePaymentMethod,
                      customerAddressesInfo: customerAddressesInfo,
                      paymentMethods: widget.paymentMethods,
                      totalPrice: widget.totalPrice,
                      decimalPointSetting: widget.decimalPointSetting,
                      orderAmount: orderAmount,
                      partialPaymentByWallet: partialPaymentByWallet,
                      orderGroupId: data[0].orderGroupId ?? '',
                      currencySymbol: widget.currencySympole,
                    ),
                  );
                }
              }
            },
            child: BlocListener<OrderBloc, OrderState>(
              listenWhen: (previous, current) =>
                  previous.getOrdersByCartGroupIDStatus !=
                      current.getOrdersByCartGroupIDStatus &&
                  current.getOrdersByCartGroupIDStatus ==
                      GetOrdersByCartGroupIDStatus.success,
              listener: (context, state) {
                debugPrint(
                  'getOrdersByCartGroupIDStatus:  ${state.getOrdersByCartGroupIDStatus}',
                );

                if (state.getOrdersByCartGroupIDStatus ==
                    GetOrdersByCartGroupIDStatus.success) {
                  List<OrdersGroupDataModel>? data =
                      state.getOrdersByCartGroupIDModel!.data!;

                  List<Map<String, String>> cartImages = [];
                  double orderAmount = 0;
                  double partialPaymentByWallet = 0;
                  /////////////////////////////////////////////////
                  data.forEach((e) {
                    orderAmount = orderAmount + e.orderAmount!;
                    partialPaymentByWallet =
                        partialPaymentByWallet + e.partialPaymentByWallet!;
                    e.details!.forEach((element) {
                      for (var i = 0; i < (element.qty ?? 0); i++) {
                        cartImages.add({
                          "image": element.image ?? '',
                          "size": element.variation.isNullOrEmpty
                              ? ""
                              : element.variation?[0].size ?? "",
                          "color": element.variation.isNullOrEmpty
                              ? ""
                              : element.variation?[0].color?.name ?? "",
                        });
                      }
                    });
                  });
                  ////////////////////////////////
                  orderAmount =
                      HelperFunctions.truncateToDecimalPlaces(
                        orderAmount,
                        BlocProvider.of<HomeBloc>(context)
                            .state
                            .getCurrencyForCountryModel!
                            .data!
                            .currency!
                            .decimalDigits!,
                      ) *
                      widget.exchangeRate;

                  partialPaymentByWallet =
                      HelperFunctions.truncateToDecimalPlaces(
                        partialPaymentByWallet,
                        BlocProvider.of<HomeBloc>(context)
                            .state
                            .getCurrencyForCountryModel!
                            .data!
                            .currency!
                            .decimalDigits!,
                      ) *
                      widget.exchangeRate;
                  ////////////////////////////////
                  CustomerAddressesInfo
                  customerAddressesInfo = CustomerAddressesInfo(
                    id: data[0].shippingAddress,
                    address: data[0].shippingAddressData!.address ?? '',
                    addressDetail:
                        data[0].shippingAddressData!.addressDetail ?? '',
                    contactInfo: ContactInfo(
                      name:
                          data[0].shippingAddressData!.contactPersonName ?? '',
                      alternativePhone:
                          data[0].shippingAddressData!.alternativePhone ?? '',
                      phone: data[0].shippingAddressData!.phone ?? '',
                    ),
                    location: Location(
                      latitude: data[0].shippingAddressData!.latitude ?? '',
                      longitude: data[0].shippingAddressData!.longitude ?? '',
                    ),
                    regionDetails: RegionDetails(
                      country: data[0].shippingAddressData!.country ?? '',
                      province: data[0].shippingAddressData!.province ?? '',
                      city: data[0].shippingAddressData!.city ?? '',
                      town: data[0].shippingAddressData!.town ?? '',
                      street: data[0].shippingAddressData!.street ?? '',
                      building: data[0].shippingAddressData!.building ?? '',
                    ),
                  );
                  /////////////////////////
                  widget.paymentMethods.value = List.from(
                    widget.paymentMethods.value,
                  )..clear();

                  String paymentMethod = data[0].paymentMethod?.value ?? '';

                  // if (data[0].paymentMethod == 'trydos_wallet') {
                  //   paymentMethod = PaymentMethods.trydosWallet;
                  // } else if (data[0].paymentMethod == 'cash_on_delivery') {
                  //   paymentMethod = PaymentMethods.cod;
                  // } else if (data[0].paymentMethod == 'crypto') {
                  //   paymentMethod = PaymentMethods.crypto;
                  // }

                  widget.paymentMethods.value = List.from(
                    widget.paymentMethods.value,
                  )..add(paymentMethod);

                  if (partialPaymentByWallet > 0) {
                    widget.paymentMethods.value = List.from(
                      widget.paymentMethods.value,
                    )..add(PaymentMethods.trydosWallet);
                  }
                  /////////////////////////
                  HelperFunctions.slidingNavigation(
                    context,
                    SuccessfullOrder(
                      cartImages: cartImages,
                      currencySympole: widget.currencySympole,
                      availablePaymentMethod: widget.availablePaymentMethod,
                      customerAddressesInfo: customerAddressesInfo,
                      paymentMethods: widget.paymentMethods,
                      totalPrice: widget.totalPrice,
                      partialPaymentByWallet: partialPaymentByWallet,
                      decimalPointSetting: widget.decimalPointSetting,
                      orderAmount: orderAmount,
                      orderGroupId: data[0].orderGroupId ?? '',
                      currencySymbol: widget.currencySympole,
                    ),
                  );
                }
              },
              child: BlocBuilder<OrderBloc, OrderState>(
                buildWhen: (previous, current) =>
                    previous.placeOrderStatus != current.placeOrderStatus ||
                    previous.getOrdersByCartGroupIDStatus !=
                        current.getOrdersByCartGroupIDStatus,
                builder: (context, orderState) {
                  return BlocBuilder<HomeBloc, HomeState>(
                    buildWhen: (previous, current) =>
                        previous.checkWithGetCartStatus !=
                        current.checkWithGetCartStatus,
                    builder: (context, homeState) {
                      return Stack(
                        children: [
                          Column(
                            children: [
                              buildPageHeader(context),
                              /////////////////////
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    alignment: Alignment.topCenter,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        buildBagItemsWidget(context),
                                        //////////////////////////////////
                                        SizedBox(height: 12.h),
                                        //////////////////////////////////
                                        buildAddress(context),
                                        //////////////////////////////////
                                        PaymentMethod(
                                          fromSuccessOrder: false,
                                          amount: widget.walletBalance,
                                          fromPalceOrder: true,
                                          paymentMethods: widget.paymentMethods,
                                          availablePaymentMethod:
                                              widget.availablePaymentMethod,
                                          totalPrice: widget.totalPrice,
                                          decimalPointSetting:
                                              widget.decimalPointSetting,
                                          currencySymbol:
                                              widget.currencySympole,
                                        ),
                                        /////////////////////////
                                        SizedBox(height: 40.h),
                                        //////////////////////////////////
                                        buildAgreeToPoliciesWidget(),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // //////////////////////////
                              buildPlaceOrderButton(orderState, homeState),
                            ],
                          ),
                          Positioned(
                            bottom: 0,
                            child: ValueListenableBuilder<bool>(
                              valueListenable: isVerified,
                              builder: (context, _isverified, _) {
                                return _isverified
                                    ? const SizedBox.shrink()
                                    : _veryfiedOtp(context);
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPlaceOrderButton(OrderState orderState, HomeState homeState) {
    return ValueListenableBuilder<bool>(
      valueListenable: agreeToPolicies,
      builder: (context, _agreeToPolicies, _) {
        return (orderState.placeOrderStatus == PlaceOrderStatus.loading ||
                homeState.checkWithGetCartStatus ==
                    CheckWithGetCartStatus.loading ||
                orderState.getOrdersByCartGroupIDStatus ==
                    GetOrdersByCartGroupIDStatus.loading)
            ? Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 60,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    // ignore: deprecated_member_use
                    color: const Color(0xffC4C2C2).withOpacity(0.5),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          LocaleKeys.place_order.tr(),
                          style: context.textTheme.bodyMedium?.mq.copyWith(
                            color: const Color(0xffFEFEFE),
                            letterSpacing: 0.18,
                            fontSize: 18,
                            height: 0.8,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${homeState.cartCollection?.length} ',
                              style: context.textTheme.bodyMedium?.bq.copyWith(
                                color: const Color(0xffFEFEFE),
                                letterSpacing: 0.18,
                                fontSize: 14,
                                height: 0.8,
                              ),
                            ),
                            Text(
                              LocaleKeys.item.tr(),
                              style: context.textTheme.bodyMedium?.rq.copyWith(
                                color: const Color(0xffFEFEFE),
                                letterSpacing: 0.18,
                                fontSize: 14,
                                height: 0.8,
                              ),
                            ),
                            Text(
                              widget.paymentMethods.value.contains(
                                    PaymentMethods.cod,
                                  )
                                  ? HelperFunctions.formatNumber(
                                      numberToFormate: widget.totalCashed,
                                      isNeedRounding: false,
                                    )
                                  : HelperFunctions.formatNumber(
                                      numberToFormate: widget.totalPrice,
                                      isNeedRounding: false,
                                    ),
                              style: context.textTheme.bodyMedium?.bq.copyWith(
                                color: const Color(0xffFEFEFE),
                                letterSpacing: 0.18,
                                fontSize: 14,
                                height: 0.8,
                              ),
                            ),
                            Text(
                              "${widget.currencySympole}",
                              style: context.textTheme.bodyMedium?.rq.copyWith(
                                color: const Color(0xffFEFEFE),
                                letterSpacing: 0.18,
                                fontSize: 14,
                                height: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Container(
                height: 80,
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
                    if (_agreeToPolicies) {
                      if (!(prefsRepository.isVerifiedPhone ?? false)) {
                        isVerified.value = false;
                        if ((prefsRepository
                                .isVerifiedPhonePeforeExpiredToken ??
                            false)) {
                          GetIt.I<AuthBloc>().add(
                            SendOtpEvent(
                              phone: prefsRepository.myPhoneNumber!,
                              isViaWhatsApp: 1,
                            ),
                          );
                        }
                        return;
                      }
                      BlocProvider.of<HomeBloc>(
                        context,
                      ).add(const CheckWithGetCartEvent(isForPlaceOrder: true));
                    }
                  },
                  child: Container(
                    height: 70.h,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: _agreeToPolicies
                          ? const Color(0xff346BFF)
                          : const Color(0xffC4C2C2),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            LocaleKeys.place_order.tr(),
                            style: context.textTheme.bodyMedium?.mq.copyWith(
                              color: const Color(0xffFEFEFE),
                              letterSpacing: 0.18,
                              fontSize: 18,
                              height: 0.8,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${homeState.cartCollection?.length} ',
                                style: context.textTheme.bodyMedium?.bq
                                    .copyWith(
                                      color: const Color(0xffFEFEFE),
                                      letterSpacing: 0.18,
                                      fontSize: 14,
                                      height: 0.8,
                                    ),
                              ),
                              Text(
                                LocaleKeys.item.tr(),
                                style: context.textTheme.bodyMedium?.rq
                                    .copyWith(
                                      color: const Color(0xffFEFEFE),
                                      letterSpacing: 0.18,
                                      fontSize: 14,
                                      height: 0.8,
                                    ),
                              ),
                              Text(
                                widget.paymentMethods.value.contains(
                                      PaymentMethods.cod,
                                    )
                                    ? HelperFunctions.formatNumber(
                                        numberToFormate: widget.totalCashed,
                                        isNeedRounding: false,
                                      )
                                    : HelperFunctions.formatNumber(
                                        numberToFormate: widget.totalPrice,
                                        isNeedRounding: false,
                                      ),
                                style: context.textTheme.bodyMedium?.bq
                                    .copyWith(
                                      color: const Color(0xffFEFEFE),
                                      letterSpacing: 0.18,
                                      fontSize: 14,
                                      height: 0.8,
                                    ),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                "${widget.currencySympole}",
                                style: context.textTheme.bodyMedium?.rq
                                    .copyWith(
                                      color: const Color(0xffFEFEFE),
                                      letterSpacing: 0.18,
                                      fontSize: 14,
                                      height: 0.8,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
      },
    );
  }

  Widget buildAgreeToPoliciesWidget() {
    return InkWell(
      onTap: () {
        agreeToPolicies.value = !agreeToPolicies.value;
      },
      child: ValueListenableBuilder<bool>(
        valueListenable: agreeToPolicies,
        builder: (context, _agreeToPolicies, _) {
          return Container(
            margin: const EdgeInsets.all(15),
            height: 40.h,
            width: 1.sw,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xff388CFF)),
              color: _agreeToPolicies
                  ? const Color(0xffF5FFF8)
                  : const Color(0xffF8F8F8),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                SizedBox(width: 28.w),
                SvgPicture.asset(
                  AppAssets.detectedSvg,
                  // ignore: deprecated_member_use
                  color: _agreeToPolicies
                      ? const Color(0xff388CFF)
                      : const Color(0xff8E8E8E),
                ),
                const SizedBox(width: 20),

                Text(
                  "${LocaleKeys.i_read_and_agree_to_the.tr()}",
                  style: context.textTheme.bodyMedium?.rq.copyWith(
                    color: const Color(0xff1D1D1D),
                    letterSpacing: 0.18,
                    fontSize: 12.sp,
                    height: 1.33,
                  ),
                ),
                Text(
                  " ${LocaleKeys.policies.tr()}",
                  style: context.textTheme.bodyMedium?.rq.copyWith(
                    decoration: TextDecoration.underline,
                    decorationColor: const Color(0xff388CFF),
                    color: const Color(0xff388CFF),
                    letterSpacing: 0.18,
                    fontSize: 12,
                    height: 1.33,
                  ),
                ),
                Text(
                  " ${LocaleKeys.and.tr()} ",
                  style: context.textTheme.bodyMedium?.rq.copyWith(
                    color: const Color(0xff1D1D1D),
                    letterSpacing: 0.18,
                    fontSize: 12,
                    height: 1.33,
                  ),
                ),
                Text(
                  "${LocaleKeys.terms.tr()}",
                  style: context.textTheme.bodyMedium?.rq.copyWith(
                    decoration: TextDecoration.underline,
                    decorationColor: const Color(0xff388CFF),
                    color: const Color(0xff388CFF),
                    letterSpacing: 0.18,
                    fontSize: 12,
                    height: 1.33,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildAddress(BuildContext context) {
    return Container(
      width: 1.sw,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
            child: Row(
              children: [
                SvgPicture.asset(AppAssets.deliveryAddressSvg, height: 16),
                SizedBox(width: 7.w),
                Text(
                  "${LocaleKeys.shipping_delivery_address.tr()} ",
                  style: context.textTheme.bodyMedium?.rq.copyWith(
                    color: const Color(0xff1D1D1D),
                    letterSpacing: 0.18,
                    fontSize: 14,
                    height: 0.8,
                  ),
                ),
                SizedBox(width: 5.w),
                SvgPicture.asset(AppAssets.freeShippingSvg),
              ],
            ),
          ),
          SizedBox(height: 5.h),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 35.w),
            child: Text(
              "${LocaleKeys.shipment_will_be_sent_to_the_address_below.tr()} ",
              style: context.textTheme.bodyMedium?.rq.copyWith(
                color: const Color(0xff8D8D8D),
                letterSpacing: 0.18,
                fontSize: 12,
                height: 0.8,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: addressInfoWithContactInfoCart(
              cartChoosed: true,
              placeOrder: true,
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

  Widget buildBagItemsWidget(BuildContext context) {
    return Container(
      height: 190,
      width: 1.sw,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(10),
            height: 20,
            child: Row(
              children: [
                SvgPicture.asset(AppAssets.bagsSvg, height: 20),
                SizedBox(width: 7.w),
                Text(
                  "${LocaleKeys.your_shopping_bag.tr()} ",
                  style: context.textTheme.bodyMedium?.rq.copyWith(
                    color: const Color(0xff1D1D1D),
                    letterSpacing: 0.18,
                    fontSize: 14,
                    height: 1.33,
                  ),
                ),
                Text(
                  "${widget.cartImages.length} item",
                  style: context.textTheme.bodyMedium?.bq.copyWith(
                    color: const Color(0xff1D1D1D),
                    letterSpacing: 0.18,
                    fontSize: 13,
                    height: 1.33,
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              left: (LanguageService.languageCode == "ar") ? 0 : 10,
              right: (LanguageService.languageCode == "ar") ? 10 : 0,
            ),
            height: 150,
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
                      height: 125.h,
                      child: ProductDetailsImageWidget(
                        withInnerShadow: false,
                        imageFit: BoxFit.cover,
                        blurRadius: 0,
                        imageUrl: widget.cartImages[index]["image"],
                        width: 91.w,
                        radius: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.cartImages[index]["size"]}',
                      style: context.textTheme.bodyMedium?.rq.copyWith(
                        color: const Color(0xff1D1D1D),
                        letterSpacing: 0.18,
                        fontSize: 10,
                        height: 1.33,
                      ),
                    ),
                    ////////////////////
                    Text(
                      '${widget.cartImages[index]["color"]}',
                      style: context.textTheme.bodyMedium?.rq.copyWith(
                        color: const Color(0xff1D1D1D),
                        letterSpacing: 0.18,
                        fontSize: 10,
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

  Widget buildPageHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 60),
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
                      angle: LanguageService.languageCode == "ar" ? pi : 0,
                      child: SvgPicture.asset(
                        AppAssets.backIconArrowSvg,
                        height: 20,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                SvgPicture.asset(AppAssets.deliveryAddressSvg, height: 20),
                SizedBox(width: 5.w),
                Text(
                  "${LocaleKeys.shipping_payment.tr()} ",
                  style: context.textTheme.bodyMedium?.mq.copyWith(
                    color: const Color(0xff1D1D1D),
                    letterSpacing: 0.2,
                    fontSize: 14,
                    height: 1.33,
                  ),
                ),
                SizedBox(
                  width: LanguageService.languageCode == "ar" ? 180.w : 140.w,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _veryfiedOtp(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        color: Colors.white,
        height: 265,
        width: 1.sw,
        child: Stack(
          children: [
            PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: pageController,
              children:
                  (prefsRepository.isVerifiedPhonePeforeExpiredToken ?? false)
                  ? [
                      VerifyOtp(
                        fromProfile: false,
                        navigateToProfile: () {},
                        fromExpired: true,
                        isVisWhatsApp: 1,
                        navigateToAddName: () {},
                        navigateTocartOrProfile: () {
                          isVerified.value = true;
                        },
                        fromLogin: false,
                        onLoginFailed: () {
                          //   pageController.animateToPage(3, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
                        },
                        goBack: () {
                          // pageController.animateToPage(1, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
                        },
                        methodIcon: AppAssets.whatsappSvg,
                        phoneNumber: prefsRepository.myPhoneNumber!,
                      ),
                    ]
                  : [
                      InsertPhoneTab(
                        focusNode: focusNode,
                        moveToNextStep: (String phoneNumber) {
                          this.phoneNumber = phoneNumber.replaceAll(' ', '');
                          pageController.animateToPage(
                            1,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                          setState(() {});
                        },
                      ),
                      VerificationMethods(
                        isFromLogin: false,
                        phoneNumber: phoneNumber,
                        onChooseWhatsapp: () {
                          isVisWhatsApp = 1;
                          print("###################33333# isVisWhatsApp}");
                          pageController.animateToPage(
                            2,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );

                          if (prefsRepository.isTimerForOtpRunning ?? false) {
                            showWarningMessage(
                              context,
                              ' ${LocaleKeys.you_must_wait_for_some_seconds_before_try_again.tr()}',
                            );
                            return;
                          }
                          /*   authBloc.add(
                              SendOtpEvent(phone: phoneNumber, isViaWhatsApp: 1));*/
                        },
                        goBackToPhone: () {
                          pageController.animateToPage(
                            0,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        },
                        onChooseSms: () {
                          isVisWhatsApp = 0;
                          pageController.animateToPage(
                            3,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                          /* authBloc.add(
                              SendOtpEvent(phone: phoneNumber, isViaWhatsApp: 0));*/
                        },
                      ),
                      VerifyOtp(
                        fromProfile: false,
                        navigateToProfile: () {},
                        fromExpired: true,
                        isVisWhatsApp: isVisWhatsApp,
                        navigateToAddName: () {},
                        navigateTocartOrProfile: () {
                          isVerified.value = true;
                          GetIt.I<HomeBloc>().add(
                            GetCurrenciesForWalletEvent(
                              currencySymbol:
                                  GetIt.I<HomeBloc>()
                                      .state
                                      .getCurrencyForCountryModel
                                      ?.data
                                      ?.currency
                                      ?.code ??
                                  "",
                            ),
                          );

                          orderBloc.add(
                            GetOrdersEvent(
                              status: "",
                              getWithPagination: false,
                            ),
                          );
                        },
                        fromLogin: false,
                        onLoginFailed: () {
                          pageController.animateToPage(
                            3,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        },
                        goBack: () {
                          pageController.animateToPage(
                            1,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        },
                        methodIcon: isVisWhatsApp == 1
                            ? AppAssets.whatsappSvg
                            : AppAssets.smsSvg,
                        phoneNumber: phoneNumber,
                      ),
                    ],
            ),
            Positioned(
              top: 0,
              left: LanguageService.languageCode != "ar" ? null : 0,
              right: LanguageService.languageCode != "ar" ? 0 : null,
              child: Container(
                margin: const EdgeInsets.all(10),
                height: 20,
                width: 40,
                child: InkWell(
                  onTap: () => isVerified.value = true,
                  child: SvgPicture.asset(
                    AppAssets.closeSvg,
                    height: 15,
                    width: 30,
                    // ignore: deprecated_member_use
                    color: const Color(0xffFF5F61),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWalletPaymentDialog(BuildContext context) {
    const uuid = Uuid();
    String idempotencyKey = uuid.v4();
    // dialog should not be dismissible while a checkout request is in progress
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // ignore: deprecated_member_use
        return WillPopScope(
          onWillPop: () async {
            // prevent back-button pop when loading
            return orderBloc.state.walletCheckoutStatus !=
                WalletCheckoutStatus.loading;
          },
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            child: Container(
              width: 0.9.sw,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Text(
                    'Wallet Payment',
                    style: context.textTheme.headlineSmall?.copyWith(
                      color: const Color(0xff1D1D1D),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Select Currency Label
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Select Currency',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xff999999),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // Currency Button
                  Container(
                    width: double.infinity,
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: const Color(0xff346BFF),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Text(
                        widget.currencySympole,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Total Amount
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xff1D1D1D),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.totalPrice.toStringAsFixed(2)} ${widget.currencySympole}',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xff1D1D1D),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.h),

                  // Account to Pay / Wallet Balance
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Account to Pay',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xff999999),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${widget.walletBalance.toStringAsFixed(2)} ${widget.currencySympole}',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xff00C853),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 25.h),

                  // Confirm Button
                  BlocListener<OrderBloc, OrderState>(
                    listenWhen: (previous, current) =>
                        previous.walletCheckoutStatus !=
                        current.walletCheckoutStatus,
                    listener: (context, state) {
                      if (state.walletCheckoutStatus ==
                          WalletCheckoutStatus.success) {
                        Navigator.of(context).pop();
                        BlocProvider.of<OrderBloc>(context).add(
                          GetOrdersByCartGroupIDEvent(
                            cartGroupId: widget.cartGroupId,
                          ),
                        );
                      }
                      if (state.walletCheckoutStatus ==
                          WalletCheckoutStatus.unAuth) {
                        Navigator.of(context).pop();
                        Future.delayed(const Duration(seconds: 1), () {
                          if (!(prefsRepository.isVerifiedPhone ?? false)) {
                            isVerified.value = false;
                            if ((prefsRepository
                                    .isVerifiedPhonePeforeExpiredToken ??
                                false)) {
                              GetIt.I<AuthBloc>().add(
                                SendOtpEvent(
                                  phone: prefsRepository.myPhoneNumber!,
                                  isViaWhatsApp: 1,
                                ),
                              );
                            }
                            return;
                          }
                        });
                      }
                    },
                    child: BlocBuilder<OrderBloc, OrderState>(
                      buildWhen: (previous, current) =>
                          previous.walletCheckoutStatus !=
                          current.walletCheckoutStatus,
                      builder: (context, state) {
                        return state.walletCheckoutStatus ==
                                WalletCheckoutStatus.loading
                            ? Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  width: double.infinity,
                                  height: 50.h,
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xffC4C2C2,
                                      // ignore: deprecated_member_use
                                    ).withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              )
                            : GestureDetector(
                                onTap: () {
                                  _proceedWithWalletPayment(idempotencyKey);
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 50.h,
                                  decoration: BoxDecoration(
                                    color: const Color(0xff346BFF),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Confirm Wallet Payment',
                                      style: context.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                    ),
                                  ),
                                ),
                              );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _proceedWithWalletPayment(String idempotencyKey) async {
    // Generate idempotency key for request uniqueness

    // Get currency ID (assuming you have it)
    String currencyId =
        BlocProvider.of<OrderBloc>(
          context,
        ).state.customerWalletModel?.assetId ??
        ""; // You'll need to pass this or get from context

    // compute timestamp once (use seconds or ms as agreed by backend)
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    // Build request payload identical to WalletCheckoutParams.payloadMap
    final requestPayload = {
      'currencyId': currencyId,
      'store_user_id':
          int.tryParse(prefsRepository.myMarketId ?? '') ??
          prefsRepository.myMarketId,
      'amount': widget.totalPrice,
      'cart_group_ids': widget.listCartGroupIds,
      'idempotencyKey': idempotencyKey,
    };

    // encode body exactly as sent to server
    final requestBody = jsonEncode(requestPayload);

    // Generate HMAC signature with computed timestamp
    final message = '$timestamp.$requestBody';
    final digest = Hmac(
      sha256,
      utf8.encode(dotenv.env['Secret_Key'] ?? ''),
    ).convert(utf8.encode(message)).toString();
    final signature = 'sha256=$digest';

    debugPrint('Signing request body: $requestBody');
    debugPrint('Signature message: $message');
    debugPrint('Computed signature: $signature');

    BlocProvider.of<OrderBloc>(context).add(
      WalletCheckoutEvent(
        params: WalletCheckoutParams(
          amount: widget.totalPrice,
          cartGroupIds: widget.listCartGroupIds,
          myMarketId: prefsRepository.myMarketId ?? "",
          currencyId: currencyId,
          idempotencyKey: idempotencyKey,
          signature: signature,
          timestamp: timestamp,
        ),
      ),
    );
  }
}
