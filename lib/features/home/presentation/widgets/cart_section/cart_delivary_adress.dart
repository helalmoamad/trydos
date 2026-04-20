import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/core/utils/extensions/string.dart';
import 'package:trydos/features/app/app_widgets/app_text_field.dart';
import 'package:trydos/features/app/trydos_shimmer_loading.dart';

import 'package:trydos/features/home/data/models/get_list_of_customer_addresses_model.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/cart_section/add_shipping_address.dart';
import 'package:trydos/features/home/presentation/widgets/cart_section/payment_method.dart';
import 'package:trydos/features/home/presentation/widgets/cart_section/place_order.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/product_details_image_widget.dart';
import 'package:trydos/features/story/presentation/widget/try_again.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_events.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_buttons_event_name.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import 'package:trydos/service/firebase_analytics_service/firebase_analytics_service.dart';
import 'package:trydos/service/language_service.dart';
import '../../../../../common/constant/payment_methods.dart';
import '../../manager/orderBloc/order_bloc.dart';
import '../../manager/orderBloc/order_event.dart';
import '../../manager/orderBloc/order_state.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';

class CartDelivaryAddress extends StatefulWidget {
  final List<Map<String, String>> cartItems;
  final String currencySympole;
  final String maxShippingDay;
  final List<String> listCartGroupIds;
  final String cartGroupId;
  const CartDelivaryAddress({
    super.key,
    required this.cartItems,
    required this.maxShippingDay,
    required this.currencySympole,
    required this.listCartGroupIds,
    required this.cartGroupId,
  });
  @override
  State<CartDelivaryAddress> createState() => _CartDelivaryAddressState();
}

class _CartDelivaryAddressState extends State<CartDelivaryAddress>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<bool> isExpanded = ValueNotifier(true);
  final ValueNotifier<int> indexTap = ValueNotifier(0);
  final ValueNotifier<bool> showDeleteAddress = ValueNotifier(false);
  final ValueNotifier<bool> showPanel = ValueNotifier(false);
  final ValueNotifier<List<String>> paymentMethods = ValueNotifier([]);
  final PanelController panelController = PanelController();
  late HomeBloc homeBloc;
  late OrderBloc orderBloc;
  final ValueNotifier<bool> validateBox = ValueNotifier(false);
  bool showDialogToResetSession = true;
  PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  int indexToDelete = 0;

  final ValueNotifier<bool> isExpandedCoupon = ValueNotifier(false);
  late AnimationController animationController;
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController couponKey = TextEditingController();
  List<Map<String, String>> cartImages = [];
  @override
  void initState() {
    LastPagesTracker.push("CartDelivaryAddress Page");
    animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    cartImages = widget.cartItems;
    print(
      "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG----------------${cartImages}",
    );
    // homeBloc = BlocProvider.of<HomeBloc>(context);
    orderBloc = BlocProvider.of<OrderBloc>(context);
    homeBloc = BlocProvider.of<HomeBloc>(context);

    ////////////////////

    orderBloc.add(GetCustomerAddressesEvent(setDefault: true));
    orderBloc.add(const GetProvincesByIsoEvent());

    homeBloc.add(const GetCoutryBoundaryByIsoEvent());
    couponKey.text = prefsRepository.getOrderCoupon();

    if (prefsRepository.getOrderCoupon().isNotEmpty) {
      BlocProvider.of<OrderBloc>(
        context,
      ).add(ApplyCouponEvent(code: prefsRepository.getOrderCoupon()));
    }

    ////////////////////
    super.initState();
  }

  @override
  void didChangeDependencies() {
    /*  if (!_eventLogged) {
      FirebaseAnalyticsService.logEventForSession(
        executedEventName: AnalyticsButtonsEventNameConst.CHECKOUT_BUTTON
        ,
        eventName: AnalyticsEventsConst.SCREEN_VIEW,
        extraParams: {
          'screen_name': GlobalScreenConst.CHECKOUT_SCREEN,
          'screen_path': '',
          'platform': GlobalPlatform.MOBILE,
        },
      );
      _eventLogged = true;
    }*/

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    animationController.dispose();
    super.dispose();
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
        // didCallOnWillPop = true;
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
        body: BlocListener<OrderBloc, OrderState>(
          listenWhen: (previous, current) =>
              previous.applyCouponStatus != current.applyCouponStatus &&
              (current.applyCouponStatus == ApplyCouponStatus.success),
          listener: (context, state) {
            if (state.applyCouponStatus == ApplyCouponStatus.success) {
              var data = state.applyCouponModel!.data!;
              if (data.status == 1) {
                // TestCoupon10
                /////////////////////////////////////////
                if (prefsRepository.getOrderCoupon().isNotEmpty) {
                  prefsRepository.removeOrderCoupon();
                }

                BlocProvider.of<HomeBloc>(context).add(GetCartOverviewEvent());
              }
            }
          },
          child: BlocBuilder<OrderBloc, OrderState>(
            buildWhen: (previous, current) =>
                previous.getCustomerAddressStatus !=
                    current.getCustomerAddressStatus ||
                previous.editAddressToOrderStatus !=
                    current.editAddressToOrderStatus ||
                previous.setCustomerAddressDefaultStatus !=
                    current.setCustomerAddressDefaultStatus ||
                previous.addAddressToOrderStatus !=
                    current.addAddressToOrderStatus ||
                previous.removeAddressToOrderStatus !=
                    current.removeAddressToOrderStatus ||
                previous.getCustomerWalletStatus !=
                    current.getCustomerWalletStatus ||
                previous.applyCouponStatus != current.applyCouponStatus,
            builder: (context, orderState) {
              if ((orderState.listOfAddressInfoClassToSave?.length ?? 0) <
                  indexTap.value + 1) {
                indexTap.value = 0;
              }

              Future.delayed(const Duration(milliseconds: 200), () {
                if (orderState.setCustomerAddressDefaultStatus ==
                        SetCustomerAddressDefaultStatus.success &&
                    orderState.getCustomerAddressStatus ==
                        GetCustomerAddressesStatus.success) {
                  indexTap.value = orderState.currentAddressChoosed ?? 0;
                }
              });

              return BlocBuilder<HomeBloc, HomeState>(
                buildWhen: (previous, current) =>
                    previous.getCartOverviewStatus !=
                        current.getCartOverviewStatus ||
                    previous.getCartItemsStatus != current.getCartItemsStatus,
                builder: (context, homeState) {
                  cartImages = [];
                  homeState.cartCollection?.forEach((element) {
                    cartImages.add({
                      "image": element.image ?? "",
                      "size": element.variations == null
                          ? ""
                          : element.variations?.size ?? "",
                      "color": element.variations == null
                          ? ""
                          : element.variations?.color ?? "",
                    });
                  });
                  List<String> availablePaymentMethod =
                      homeState
                          .getCartShippingItemsModel!
                          .data!
                          .availablePaymentMethod ??
                      [];

                  double totalCashed =
                      HelperFunctions.truncateToDecimalPlaces(
                        (homeState.getCartShippingItemsModel?.data?.totalCash ??
                            0),
                        homeState
                            .getCurrencyForCountryModel!
                            .data!
                            .currency!
                            .decimalDigits!,
                      ) *
                      homeState
                          .getCurrencyForCountryModel!
                          .data!
                          .currency!
                          .exchangeRate!;

                  double totalPrice =
                      HelperFunctions.truncateToDecimalPlaces(
                        (homeState.getCartShippingItemsModel?.data?.total ?? 0),
                        homeState
                            .getCurrencyForCountryModel!
                            .data!
                            .currency!
                            .decimalDigits!,
                      ) *
                      homeState
                          .getCurrencyForCountryModel!
                          .data!
                          .currency!
                          .exchangeRate!;
                  if (!(totalPrice > 0)) {
                    totalCashed = 0;
                  }

                  double couponDiscount =
                      HelperFunctions.truncateToDecimalPlaces(
                        (homeState
                                .getCartShippingItemsModel
                                ?.data
                                ?.couponDiscount ??
                            0),
                        homeState
                            .getCurrencyForCountryModel!
                            .data!
                            .currency!
                            .decimalDigits!,
                      );

                  String couponCode =
                      homeState.getCartShippingItemsModel?.data?.couponCode ??
                      '';
                  return ValueListenableBuilder<bool>(
                    valueListenable: showDeleteAddress,
                    builder: (context, _showDeleteAddress, _) {
                      double walletBalance =
                          orderState.customerWalletModel?.available ?? 0;
                      // *
                      //     state.getCurrencyForCountryModel!.data!.currency!
                      //         .exchangeRate!;
                      return ValueListenableBuilder<int>(
                        valueListenable: indexTap,
                        builder: (context, _indexTap, _) {
                          return Stack(
                            children: [
                              Column(
                                children: [
                                  buildPageHeader(context, orderState),
                                  ///////////////////////
                                  Expanded(
                                    child: RefreshIndicator(
                                      onRefresh: () async {
                                        homeBloc.add(const GetCartItemEvent());
                                        await Future.delayed(
                                          const Duration(seconds: 4),
                                        );
                                      },
                                      child: SingleChildScrollView(
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                            horizontal: 10.w,
                                          ),
                                          color: const Color.fromARGB(
                                            255,
                                            255,
                                            255,
                                            255,
                                          ),
                                          child: Column(
                                            children: [
                                              SizedBox(height: 10.h),
                                              ////////////////////
                                              ValueListenableBuilder<bool>(
                                                valueListenable: isExpanded,
                                                builder: (context, expanded, _) {
                                                  return buildBagItemsWidget(
                                                    expanded,
                                                    context,
                                                  );
                                                },
                                              ),
                                              //////////////////////////////////
                                              SizedBox(height: 12.h),
                                              //////////////////////////////////
                                              buildAddressWidget(
                                                orderState,
                                                context,
                                                _indexTap,
                                              ),
                                              ////////////////////
                                              SizedBox(height: 12.h),
                                              ////////////////////
                                              /*   (orderState
                                                        .listOfAddressInfoClassToSave
                                                        .isNullOrEmpty)
                                                    ? SizedBox.shrink()
                                                    :*/
                                              orderState.getCustomerWalletStatus ==
                                                      GetCustomerWalletStatus
                                                          .failure
                                                  ? TryAgainWidget(
                                                      tryAgain: () {
                                                        homeBloc.add(
                                                          GetCurrenciesForWalletEvent(
                                                            currencySymbol:
                                                                homeBloc
                                                                    .state
                                                                    .getCurrencyForCountryModel
                                                                    ?.data
                                                                    ?.currency
                                                                    ?.code ??
                                                                "",
                                                          ),
                                                        );
                                                      },
                                                    )
                                                  : orderState
                                                            .getCustomerWalletStatus ==
                                                        GetCustomerWalletStatus
                                                            .loading
                                                  ? TrydosShimmerLoading(
                                                      width: 1.sw,
                                                      logoTextWidth: 15.w,
                                                      height: 70.h,
                                                      logoTextHeight: 15.h,
                                                    )
                                                  : PaymentMethod(
                                                      fromSuccessOrder: false,
                                                      amount: walletBalance,
                                                      fromPalceOrder: false,
                                                      availablePaymentMethod:
                                                          availablePaymentMethod,
                                                      currencySymbol: widget
                                                          .currencySympole,
                                                      paymentMethods:
                                                          paymentMethods,
                                                      totalPrice: totalPrice,
                                                      decimalPointSetting:
                                                          homeState
                                                              .startingSetting
                                                              ?.decimalPointSettings ??
                                                          2,
                                                    ),
                                              ////////////
                                              SizedBox(height: 25.h),
                                              ////////////
                                              ValueListenableBuilder<bool>(
                                                valueListenable:
                                                    isExpandedCoupon,
                                                builder:
                                                    (
                                                      context,
                                                      expandedCoupon,
                                                      _,
                                                    ) {
                                                      return buildCouponWidget(
                                                        expandedCoupon,
                                                        context,
                                                        orderState,
                                                        couponDiscount,
                                                        couponCode,
                                                      );
                                                    },
                                              ),
                                              ////////////////
                                              (orderState
                                                      .listOfAddressInfoClassToSave
                                                      .isNullOrEmpty)
                                                  ? const SizedBox.shrink()
                                                  : ValueListenableBuilder<
                                                      bool
                                                    >(
                                                      valueListenable:
                                                          isExpanded,
                                                      builder: (context, _isExpanded, _) {
                                                        return ValueListenableBuilder<
                                                          bool
                                                        >(
                                                          valueListenable:
                                                              isExpandedCoupon,
                                                          builder:
                                                              (
                                                                context,
                                                                _isExpandedCoupon,
                                                                child,
                                                              ) {
                                                                return SizedBox(
                                                                  height:
                                                                      _isExpanded
                                                                      ? 120.h
                                                                      : (_isExpandedCoupon &&
                                                                            !_isExpanded)
                                                                      ? 120.h
                                                                      : 0,
                                                                );
                                                              },
                                                        );
                                                      },
                                                    ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  ////////////////////////////
                                  buildShippingButton(
                                    orderState,
                                    homeState,
                                    _indexTap,
                                    walletBalance,
                                    totalPrice,
                                    totalCashed,
                                    availablePaymentMethod,
                                  ),
                                ],
                              ),
                              //////////////////////////////
                              ValueListenableBuilder<bool>(
                                valueListenable: showPanel,
                                builder: (context, _showPanel, _) {
                                  return !_showPanel
                                      ? const SizedBox.shrink()
                                      : InkWell(
                                          onTap: () {
                                            panelController.close();
                                            showPanel.value = false;
                                          },
                                          child: Container(
                                            width: 1.sh,
                                            color: const Color.fromRGBO(
                                              0,
                                              0,
                                              0,
                                              0.65,
                                            ),
                                          ),
                                        );
                                },
                              ),
                              ///////////////
                              Positioned(
                                bottom: 0,
                                child: Container(
                                  height: 700.h,
                                  width: 1.sw,
                                  child: SlidingUpPanel(
                                    controller: panelController,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(30.r),
                                      topRight: Radius.circular(30.r),
                                    ),
                                    onPanelClosed: () {
                                      showPanel.value = false;
                                      orderBloc.add(
                                        SetCustomerAddressDefaultEvent(
                                          adressId: orderState
                                              .listOfAddressInfoClassToSave![_indexTap]
                                              .id,
                                          index: _indexTap,
                                        ),
                                      );
                                    },
                                    onPanelOpened: () {
                                      showPanel.value = true;
                                    },
                                    minHeight: 0,
                                    maxHeight: 700.h,
                                    panelBuilder: (sc) =>
                                        buildSlidingUpPanelWidgets(
                                          context,
                                          orderState,
                                          _indexTap,
                                          sc,
                                        ),
                                  ),
                                ),
                              ),
                              /////////////////////////////////////
                              _showDeleteAddress
                                  ? buildDeleteAddressWidget(
                                      context,
                                      orderState,
                                    )
                                  : const SizedBox.shrink(),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildShippingButton(
    OrderState orderState,
    HomeState homeState,
    int _indexTap,
    double walletBalance,
    double totalPrice,
    double totalCashed,
    List<String> availablePaymentMethods,
  ) {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 1)),
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
      child: ValueListenableBuilder<List<String>>(
        valueListenable: paymentMethods,
        builder: (context, _paymentMethod, _) {
          bool check = false;
          if (_paymentMethod.isNotEmpty) {
            if (totalPrice > walletBalance) {
              if (_paymentMethod.length == 1 &&
                  _paymentMethod.contains(PaymentMethods.trydosWallet)) {
                check = false;
              } else {
                check = true;
              }
            } else {
              check = true;
            }
          } else {
            check = false;
          }
          if ((orderState.listOfAddressInfoClassToSave.isNullOrEmpty)) {
            check = false;
          }
          return (orderState.applyCouponStatus == ApplyCouponStatus.loading ||
                  orderState.setCustomerAddressDefaultStatus !=
                      SetCustomerAddressDefaultStatus.success ||
                  orderState.getCustomerAddressStatus !=
                      GetCustomerAddressesStatus.success ||
                  orderState.addAddressToOrderStatus ==
                      AddAddressToOrderStatus.loading ||
                  orderState.editAddressToOrderStatus ==
                      EditAddressToOrderStatus.loading ||
                  orderState.removeAddressToOrderStatus ==
                      RemoveAddressToOrderStatus.loading ||
                  homeState.getCartOverviewStatus ==
                      GetCartOverviewStatus.loading)
              ? Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 60.h,
                    margin: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      // ignore: deprecated_member_use
                      color: const Color(0xffC4C2C2).withOpacity(0.5),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            LocaleKeys.confirm_shipping_payment.tr(),
                            style: context.textTheme.bodyMedium?.mq.copyWith(
                              color: const Color(0xffFEFEFE),
                              letterSpacing: 0.18,
                              fontSize: 18.sp,
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
                                      fontSize: 13.sp,
                                      height: 0.8,
                                    ),
                              ),
                              Text(
                                LocaleKeys.item.tr(),
                                style: context.textTheme.bodyMedium?.rq
                                    .copyWith(
                                      color: const Color(0xffFEFEFE),
                                      letterSpacing: 0.18,
                                      fontSize: 13.sp,
                                      height: 0.8,
                                    ),
                              ),
                              Text(
                                paymentMethods.value.contains(
                                      PaymentMethods.cod,
                                    )
                                    ? HelperFunctions.formatNumber(
                                        numberToFormate: totalCashed,
                                        isNeedRounding: false,
                                      )
                                    : HelperFunctions.formatNumber(
                                        numberToFormate: totalPrice,
                                        isNeedRounding: false,
                                      ),
                                style: context.textTheme.bodyMedium?.bq
                                    .copyWith(
                                      color: const Color(0xffFEFEFE),
                                      letterSpacing: 0.18,
                                      fontSize: 13.sp,
                                      height: 0.8,
                                    ),
                              ),
                              Text(
                                "${widget.currencySympole}",
                                style: context.textTheme.bodyMedium?.rq
                                    .copyWith(
                                      color: const Color(0xffFEFEFE),
                                      letterSpacing: 0.18,
                                      fontSize: 13.sp,
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
              : InkWell(
                  onTap: () {
                    if (homeState.getCartOverviewStatus ==
                        GetCartOverviewStatus.failure) {
                      homeBloc.add(GetCartOverviewEvent());
                      return;
                    }
                    if ((orderState
                        .listOfAddressInfoClassToSave
                        .isNullOrEmpty)) {
                      validateBox.value = true;
                      animationController.forward();
                      Future.delayed(
                        const Duration(seconds: 2),
                        () => animationController.reset(),
                      );
                      return;
                    }
                    if (check) {
                      /////////////////////////////////

                      ////////////////////////////////////////////
                      List<Map<String, String>> analyticsCartList = [];
                      if (homeBloc.state.cartCollection != null) {
                        homeBloc.state.cartCollection!.forEach((element) {
                          Map<String, String> item = {
                            'item_id': element.productId.toString(),
                            'item_name': element.name.toString(),
                            'quantity': element.quantity.toString(),
                          };

                          analyticsCartList.add(item);
                        });
                      }
                      ////////////////////////////////////////////
                      /* Future.delayed(
                        Duration(milliseconds: 300),
                        () {
                          FirebaseAnalyticsService.logEventForSession(
                            executedEventName: AnalyticsButtonsEventNameConst.Orde,
                            eventName: AnalyticsEventsConst.viewCart,
                            extraParams: {
                              'payment_type': analyticsPayMethods,
                              'items': analyticsCartList.toString(),
                            },
                          );
                        },
                      );*/
                      //////////////////////////////////
                      HelperFunctions.slidingNavigation(
                        context,
                        PlaceOrder(
                          customerAddressesInfo: orderState
                              .listOfAddressInfoClassToSave![_indexTap],
                          walletBalance: walletBalance,
                          cartGroupId: widget.cartGroupId,
                          listCartGroupIds: widget.listCartGroupIds,
                          paymentMethods: paymentMethods,
                          availablePaymentMethod: availablePaymentMethods,
                          cartImages: cartImages,
                          currencySympole: widget.currencySympole,
                          totalPrice: totalPrice,
                          exchangeRate:
                              homeState
                                  .getCurrencyForCountryModel!
                                  .data!
                                  .currency!
                                  .exchangeRate ??
                              0,
                          totalCashed: totalCashed,

                          decimalPointSetting:
                              homeState.startingSetting?.decimalPointSettings ??
                              2,
                        ),
                      );
                    }
                  },
                  child: Container(
                    height: 70.h,
                    margin: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      color: check
                          ? const Color(0xff346BFF)
                          : const Color(0xffC4C2C2),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            LocaleKeys.confirm_shipping_payment.tr(),
                            style: context.textTheme.bodyMedium?.mq.copyWith(
                              color: const Color(0xffFEFEFE),
                              letterSpacing: 0.18,
                              fontSize: 18.sp,
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
                                      fontSize: 13.sp,
                                      height: 0.8,
                                    ),
                              ),
                              Text(
                                LocaleKeys.item.tr(),
                                style: context.textTheme.bodyMedium?.rq
                                    .copyWith(
                                      color: const Color(0xffFEFEFE),
                                      letterSpacing: 0.18,
                                      fontSize: 13.sp,
                                      height: 0.8,
                                    ),
                              ),
                              Text(
                                paymentMethods.value.contains(
                                      PaymentMethods.cod,
                                    )
                                    ? HelperFunctions.formatNumber(
                                        numberToFormate: totalCashed,
                                        isNeedRounding: false,
                                      )
                                    : HelperFunctions.formatNumber(
                                        numberToFormate: totalPrice,
                                        isNeedRounding: false,
                                      ),
                                style: context.textTheme.bodyMedium?.bq
                                    .copyWith(
                                      color: const Color(0xffFEFEFE),
                                      letterSpacing: 0.18,
                                      fontSize: 13.sp,
                                      height: 0.8,
                                    ),
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                "${widget.currencySympole}",
                                style: context.textTheme.bodyMedium?.rq
                                    .copyWith(
                                      color: const Color(0xffFEFEFE),
                                      letterSpacing: 0.18,
                                      fontSize: 13.sp,
                                      height: 0.8,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
        },
      ),
    );
  }

  Widget buildCouponWidget(
    bool expandedCoupon,
    BuildContext context,
    OrderState state,
    double couponDiscount,
    String couponCode,
  ) {
    return AnimatedContainer(
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
      child: InkWell(
        onTap: () => isExpandedCoupon.value = !expandedCoupon,
        child: Container(
          width: 1.sw,
          padding: EdgeInsets.all(10.h),
          decoration: BoxDecoration(
            color: expandedCoupon
                ? const Color(0xffFFFFFF)
                : const Color(0xffF8F8F8),
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(
              color: !expandedCoupon
                  ? const Color(0xffFFFFFF)
                  : const Color(0xff388CFF),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  SvgPicture.asset(AppAssets.paymentMethodSvg, height: 20.h),
                  SizedBox(width: 10.w),
                  Text(
                    "${LocaleKeys.i_have_discount_coupon.tr()} ",
                    style: context.textTheme.bodyMedium?.rq.copyWith(
                      color: const Color(0xff1D1D1D),
                      letterSpacing: 0.18,
                      fontSize: 13.sp,
                      height: 1.33,
                    ),
                  ),
                ],
              ),
              !expandedCoupon ? const SizedBox.shrink() : SizedBox(height: 5.h),
              !expandedCoupon
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 27.w),
                      child: Text(
                        couponDiscount > 0
                            ? "${LocaleKeys.applied_your_coupon.tr()} $couponCode"
                            : "${LocaleKeys.please_enter_coupon_information.tr()} ",
                        style: context.textTheme.bodyMedium?.rq.copyWith(
                          color: const Color(0xff8D8D8D),
                          letterSpacing: 0.18,
                          fontSize: 12.sp,
                          height: LanguageService.languageCode == "ar"
                              ? 0.8
                              : 1.33,
                        ),
                      ),
                    ),
              !expandedCoupon
                  ? const SizedBox.shrink()
                  : SizedBox(height: 10.h),
              !expandedCoupon
                  ? const SizedBox.shrink()
                  : couponDiscount > 0
                  ? Container(
                      alignment: Alignment.center,
                      width: 1.sw,
                      padding: EdgeInsets.all(10.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.r),
                        border: Border.all(color: const Color(0xff388CFF)),
                      ),
                      child: Text(
                        "- ${couponDiscount} ${widget.currencySympole}",
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyMedium?.bq.copyWith(
                          color: const Color(0xff1D1D1D),
                          letterSpacing: 0.18,
                          fontSize: 13.sp,
                          height: 1.33,
                        ),
                      ),
                    )
                  : Form(
                      key: _formKey,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Container(
                              height: 60.h,
                              margin: EdgeInsets.symmetric(vertical: 5.w),
                              color: colorScheme.white,
                              padding: EdgeInsets.symmetric(vertical: 5.w),
                              child: AppTextField(
                                controller: couponKey,
                                textInputType: TextInputType.text,
                                filledColor: colorScheme.grey50,
                                bordersColor: colorScheme.grey50,
                                hintText: LocaleKeys.coupon_no.tr(),
                                validator: (value) {
                                  if (value.isNullOrEmpty) {
                                    return LocaleKeys
                                        .the_field_must_not_be_empty
                                        .tr();
                                  }
                                  return null;
                                },
                                hintTextStyle: textTheme.bodySmall?.lq.copyWith(
                                  color: const Color(0xffD3D3D3),
                                ),
                                contentPadding:
                                    const EdgeInsetsDirectional.fromSTEB(
                                      20,
                                      10,
                                      20,
                                      10,
                                    ),
                                isPrefixIconConstraints: false,
                                prefixIcon: Container(
                                  width: 20.w,
                                  height: 20.h,
                                  child: Row(
                                    children: [
                                      const Spacer(),
                                      Padding(
                                        padding: EdgeInsets.all(9.h),
                                        child: SvgPicture.asset(
                                          AppAssets.trydosWalletSvg,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          //////////////////////
                          const SizedBox(width: 2),
                          //////////////////////
                          Expanded(
                            child:
                                (state.applyCouponStatus ==
                                    ApplyCouponStatus.loading)
                                ? Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      padding: EdgeInsets.all(16.h),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          15.r,
                                        ),
                                        border: Border.all(
                                          color: const Color(0xff388CFF),
                                        ),
                                      ),
                                      child: Text(
                                        "${LocaleKeys.apply.tr()} ",
                                        textAlign: TextAlign.center,
                                        style: context.textTheme.bodyMedium?.rq
                                            .copyWith(
                                              color: const Color(0xff1D1D1D),
                                              letterSpacing: 0.18,
                                              fontSize: 13.sp,
                                              height: 1,
                                            ),
                                      ),
                                    ),
                                  )
                                : InkWell(
                                    onTap: () {
                                      if (_formKey.currentState!.validate()) {
                                        BlocProvider.of<OrderBloc>(context).add(
                                          ApplyCouponEvent(
                                            code: couponKey.text,
                                          ),
                                        );
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(16.h),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          15.r,
                                        ),
                                        border: Border.all(
                                          color: const Color(0xff388CFF),
                                        ),
                                      ),
                                      child: Text(
                                        "${LocaleKeys.apply.tr()} ",
                                        textAlign: TextAlign.center,
                                        style: context.textTheme.bodyMedium?.rq
                                            .copyWith(
                                              color: const Color(0xff1D1D1D),
                                              letterSpacing: 0.18,
                                              fontSize: 13.sp,
                                              height: 1,
                                            ),
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSlidingUpPanelWidgets(
    BuildContext context,
    OrderState state,
    int _indexTap,
    ScrollController sc,
  ) {
    return Container(
      width: 1.sw,
      child: Column(
        children: [
          SizedBox(height: 10.h),
          Container(
            height: 25.h,
            width: 145.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: SvgPicture.asset(
                    AppAssets.deliveryAddressSvg,
                    width: 18.w,
                    height: 18.h,
                    // ignore: deprecated_member_use
                    color: const Color(0xff1D1D1D),
                  ),
                ),
                const SizedBox(width: 3),
                Text(
                  "${LocaleKeys.your_address_list.tr()} ",
                  style: context.textTheme.bodyMedium?.rq.copyWith(
                    color: const Color(0xff1D1D1D),
                    letterSpacing: 0.18,
                    fontSize: 13.sp,
                    height: 1.33,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          Container(
            height: 570.h,
            width: 1.sw,
            margin: EdgeInsets.symmetric(horizontal: 24.w),
            child: ListView.separated(
              padding: const EdgeInsets.all(0),
              itemBuilder: (context, index) => InkWell(
                onTap: () {
                  indexTap.value = index;
                },
                child: addressInfoWithContactInfoCart(
                  cartChoosed: false,
                  shippingDays: widget.maxShippingDay,
                  isDelete: false,
                  customerAddressesInfo:
                      state.listOfAddressInfoClassToSave![index],
                  context: context,
                  index: index,
                  indexTap: _indexTap,
                  onTapDelete: () {
                    if (index == _indexTap) {
                      indexTap.value = 0;
                    }
                    indexToDelete = index;
                    showDeleteAddress.value = true;
                  },
                  onTapEdit: () {
                    panelController.close();
                    HelperFunctions.slidingNavigation(
                      context,
                      AddShippingAdress(
                        addressInfoClassToEdid:
                            state.listOfAddressInfoClassToSave![index],
                        fromEdid: true,
                      ),
                    );
                  },
                ),
              ),
              separatorBuilder: (context, index) => SizedBox(height: 10.h),
              itemCount: state.listOfAddressInfoClassToSave!.length,
              controller: sc,
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () {
              // Log add address event
              try {
                FirebaseAnalyticsService.logEventForSession(
                  eventName: AnalyticsEventsConst.ADD_ADDRESS,
                  executedEventName:
                      AnalyticsButtonsEventNameConst.AT_YOUR_ADDRESS_BUTTON,
                  extraParams: {'screen_name': GlobalScreenConst.CART_SCREEN},
                );
              } catch (e) {}

              panelController.close();
              HelperFunctions.slidingNavigation(
                context,
                const AddShippingAdress(),
              );
            },
            child: Container(
              height: 40.h,
              width: 1.sw,
              margin: EdgeInsets.symmetric(horizontal: 24.w),
              decoration: BoxDecoration(
                color: const Color(0xffE8FFED),
                borderRadius: BorderRadius.circular(15.r),
                border: Border.all(color: const Color(0xffC4C2C2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SvgPicture.asset(AppAssets.addShippingAddressSvg),
                        Positioned(
                          top: 2,
                          child: SvgPicture.asset(
                            AppAssets.addShippingAddressWhiteSvg,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    "${LocaleKeys.add_new_shipping_address.tr()} ",
                    style: context.textTheme.bodyMedium?.mq.copyWith(
                      color: const Color(0xff1D1D1D),
                      letterSpacing: 0.18,
                      fontSize: 12.sp,
                      height: 1.33,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget buildAddressWidget(
    OrderState state,
    BuildContext context,
    int _indexTap,
  ) {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) =>
          previous.getCountryBoundaryByIsoStatus !=
          current.getCountryBoundaryByIsoStatus,
      builder: (context, boundaryState) {
        return ValueListenableBuilder<bool>(
          valueListenable: validateBox,
          builder: (context, isValidateBox, _) {
            return AnimatedBuilder(
              animation: animationController,
              builder: (context, child) => Transform.translate(
                offset: Offset(
                  !(state.listOfAddressInfoClassToSave?.length == 0)
                      ? 0
                      : sin(3 * 2 * pi * animationController.value) * 5,
                  0,
                ),
                child: Container(
                  // height: !(state.listOfAddressInfoClassToSave.isNullOrEmpty) ? 225 : 203,
                  width: 1.sw,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.r),
                    border: Border.all(
                      color:
                          (state.listOfAddressInfoClassToSave?.length == 0) &&
                              isValidateBox
                          ? Colors.red
                          : const Color(0xffC4C2C2),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                            top: 10.h,
                            left: 10.w,
                            right: 10.w,
                          ),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                AppAssets.deliveryAddressSvg,
                                height: 24.h,
                              ),
                              SizedBox(width: 7.w),
                              Text(
                                "${LocaleKeys.shipping_delivery_address.tr()} ",
                                style: context.textTheme.bodyMedium?.rq
                                    .copyWith(
                                      color: const Color(0xff1D1D1D),
                                      letterSpacing: 0.18,
                                      fontSize: 13.sp,
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
                            !(state.listOfAddressInfoClassToSave.isNullOrEmpty)
                                ? "${LocaleKeys.shipment_will_be_sent_to_the_address_below.tr()} "
                                : "${LocaleKeys.please_enter_shipping_address_to_receive_your_bag.tr()} ",
                            style: context.textTheme.bodyMedium?.rq.copyWith(
                              color: const Color(0xff8D8D8D),
                              letterSpacing: 0.18,
                              fontSize: 12.sp,
                              height: 0.8,
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        !state.listOfAddressInfoClassToSave.isNullOrEmpty
                            ? Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.w),
                                child: addressInfoWithContactInfoCart(
                                  cartChoosed: true,
                                  shippingDays: widget.maxShippingDay,
                                  isDelete: false,
                                  customerAddressesInfo:
                                      (state
                                                  .listOfAddressInfoClassToSave
                                                  ?.length ??
                                              0) <
                                          _indexTap + 1
                                      ? state.listOfAddressInfoClassToSave![0]
                                      : state
                                            .listOfAddressInfoClassToSave![_indexTap],
                                  context: context,
                                  index: -1,
                                  indexTap: _indexTap,
                                  onTapDelete: () {},
                                  onTapEdit: () {
                                    ;
                                  },
                                ),
                              )
                            : Container(
                                height: 85.h,
                                width: 1.sw,
                                padding: const EdgeInsets.symmetric(),
                                margin: EdgeInsets.symmetric(horizontal: 10.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xffF8F8F8),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color:
                                        !state
                                            .listOfAddressInfoClassToSave
                                            .isNullOrEmpty
                                        ? const Color(0xff388CFF)
                                        : const Color(0xffF8F8F8),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    SizedBox(height: 8.h),
                                    SvgPicture.asset(
                                      AppAssets.chatWithQuestionSvg,
                                    ),
                                    SizedBox(height: 18.h),
                                    Text(
                                      "${LocaleKeys.your_address_list_is_empty.tr()} ",
                                      style: context.textTheme.bodyMedium?.rq
                                          .copyWith(
                                            color: const Color(0xffC4C2C2),
                                            letterSpacing: 0.18,
                                            fontSize: 12.sp,
                                            height: 0.8,
                                          ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      "${LocaleKeys.you_can_also_create_multiple_addresses_to_use.tr()} ",
                                      style: context.textTheme.bodyMedium?.rq
                                          .copyWith(
                                            color: const Color(0xffC4C2C2),
                                            letterSpacing: 0.18,
                                            fontSize: 12.sp,
                                            height: 0.8,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                        SizedBox(
                          height:
                              !(state
                                  .listOfAddressInfoClassToSave
                                  .isNullOrEmpty)
                              ? 10.h
                              : 20.h,
                        ),
                        !state.listOfAddressInfoClassToSave.isNullOrEmpty
                            ? InkWell(
                                onTap: () {
                                  if (boundaryState
                                          .getCountryBoundaryByIsoStatus !=
                                      GetCountryBoundaryByIsoStatus.success) {
                                    return;
                                  }
                                  panelController.open();
                                },
                                child:
                                    (boundaryState
                                            .getCountryBoundaryByIsoStatus ==
                                        GetCountryBoundaryByIsoStatus.failure)
                                    ? TryAgainWidget(
                                        tryAgain: () => homeBloc.add(
                                          const GetCoutryBoundaryByIsoEvent(),
                                        ),
                                      )
                                    : (boundaryState
                                              .getCountryBoundaryByIsoStatus ==
                                          GetCountryBoundaryByIsoStatus.loading)
                                    ? TrydosShimmerLoading(
                                        width: 1.sw,
                                        logoTextWidth: 15.w,
                                        height: 16.w,
                                        logoTextHeight: 15.h,
                                      )
                                    : Container(
                                        height: 16.h,
                                        width: 1.sw,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Center(
                                              child: SvgPicture.asset(
                                                AppAssets.deliveryAddressSvg,
                                                width: 15.w,
                                                height: 15.h,
                                                // ignore: deprecated_member_use
                                                color: const Color(0xff8D8D8D),
                                              ),
                                            ),
                                            SizedBox(width: 3.w),
                                            Text(
                                              "${LocaleKeys.show_address_list.tr()} ",
                                              style: context
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.mq
                                                  .copyWith(
                                                    color: const Color(
                                                      0xff8D8D8D,
                                                    ),
                                                    letterSpacing: 0.18,
                                                    fontSize: 12.sp,
                                                    height: 1,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                              )
                            : InkWell(
                                onTap: () {
                                  if (boundaryState
                                          .getCountryBoundaryByIsoStatus !=
                                      GetCountryBoundaryByIsoStatus.success) {
                                    return;
                                  }
                                  HelperFunctions.slidingNavigation(
                                    context,
                                    const AddShippingAdress(),
                                  );
                                },
                                child:
                                    (boundaryState
                                            .getCountryBoundaryByIsoStatus ==
                                        GetCountryBoundaryByIsoStatus.failure)
                                    ? TryAgainWidget(
                                        tryAgain: () => homeBloc.add(
                                          const GetCoutryBoundaryByIsoEvent(),
                                        ),
                                      )
                                    : (boundaryState
                                              .getCountryBoundaryByIsoStatus ==
                                          GetCountryBoundaryByIsoStatus.loading)
                                    ? TrydosShimmerLoading(
                                        width: 1.sw,
                                        logoTextWidth: 15.w,
                                        height: 40,
                                        logoTextHeight: 15.h,
                                      )
                                    : Container(
                                        height: 40.h,
                                        width: 1.sw,
                                        margin: EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xffE8FFED),
                                          borderRadius: BorderRadius.circular(
                                            15.r,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xffC4C2C2),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Center(
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  SvgPicture.asset(
                                                    AppAssets
                                                        .addShippingAddressSvg,
                                                  ),
                                                  Positioned(
                                                    top: 2.h,
                                                    child: SvgPicture.asset(
                                                      AppAssets
                                                          .addShippingAddressWhiteSvg,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 3),
                                            Text(
                                              "${LocaleKeys.add_shipping_address.tr()} ",
                                              style: context
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.mq
                                                  .copyWith(
                                                    color: const Color(
                                                      0xff1D1D1D,
                                                    ),
                                                    letterSpacing: 0.18,
                                                    fontSize: 12.sp,
                                                    height: 1.33,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget buildBagItemsWidget(bool expanded, BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
      child: Container(
        height: expanded ? 210.h : 45.h,
        width: 1.sw,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(color: const Color(0xffC4C2C2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () => isExpanded.value = !expanded,
              child: Container(
                margin: EdgeInsets.all(10.w),
                height: 20.h,
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
                      "${cartImages.length} ${LocaleKeys.item.tr()}",
                      style: context.textTheme.bodyMedium?.bq.copyWith(
                        color: const Color(0xff1D1D1D),
                        letterSpacing: 0.18,
                        fontSize: 13.sp,
                        height: 1.33,
                      ),
                    ),
                    const Spacer(),
                    Transform.rotate(
                      angle: expanded ? pi : 0,
                      child: SvgPicture.asset(
                        AppAssets.expandDetaileSvg,
                        height: 8.h,
                        width: 12,
                        // ignore: deprecated_member_use
                        color: const Color(0xff8D8D8D),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            !expanded ? const SizedBox.shrink() : SizedBox(height: 5.h),
            !expanded
                ? const SizedBox.shrink()
                : Container(
                    margin: EdgeInsets.only(
                      left: (LanguageService.languageCode == "ar") ? 0 : 10.w,
                      right: (LanguageService.languageCode == "ar") ? 10.w : 0,
                    ),
                    height: 160.h,
                    child: ListView.separated(
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 5),
                      scrollDirection: Axis.horizontal,
                      itemCount: cartImages.length,
                      itemBuilder: (context, index) => Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.r),
                          color: const Color(0x707070),
                        ),
                        width: 91.w,
                        child: Column(
                          children: [
                            Container(
                              height: 120.h,
                              child: ProductDetailsImageWidget(
                                withInnerShadow: false,
                                imageFit: BoxFit.cover,
                                blurRadius: 0,
                                imageUrl: cartImages[index]["image"],
                                width: 91.w,
                                radius: 15.r,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${cartImages[index]["size"]}',
                              style: context.textTheme.bodyMedium?.rq.copyWith(
                                color: const Color(0xff1D1D1D),
                                letterSpacing: 0.18,
                                fontSize: 10.sp,
                                height: 1.33,
                              ),
                            ),
                            Text(
                              '${cartImages[index]["color"]}',
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
      ),
    );
  }

  Widget buildDeleteAddressWidget(BuildContext context, OrderState state) {
    return Container(
      width: 1.sw,
      height: 1.sh,
      color: const Color.fromRGBO(0, 0, 0, 0.90),
      child: Column(
        children: [
          SizedBox(height: 1.sh / 3.5),
          SvgPicture.asset(
            AppAssets.deletecartSvg,
            // ignore: deprecated_member_use
            color: const Color(0xffFFFFFF),
            width: 50.w,
            height: 50.h,
          ),
          SizedBox(height: 10.h),
          Text(
            "${LocaleKeys.delete_below_address.tr()} ",
            style: context.textTheme.bodyMedium?.mq.copyWith(
              color: const Color(0xffFFFFFF),
              letterSpacing: 0.18,
              fontSize: 16.sp,
              height: 1.33,
            ),
          ),
          SizedBox(height: 15.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: addressInfoWithContactInfoCart(
              cartChoosed: false,
              context: context,
              isDelete: true,
              shippingDays: widget.maxShippingDay,
              indexTap: 0,
              index: 1,
              customerAddressesInfo:
                  state.listOfAddressInfoClassToSave![indexToDelete],
              onTapDelete: () {},
              onTapEdit: () {},
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () {
              showDeleteAddress.value = false;
              orderBloc.add(
                DeleteAdressInfoClassEvent(
                  adressInfoClassId:
                      state.listOfAddressInfoClassToSave?[indexToDelete].id,
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 24.w),
              height: 50.h,
              width: 1.sw,
              decoration: BoxDecoration(
                color: const Color(0xffF8F8F8),
                borderRadius: BorderRadius.circular(15.r),
                border: Border.all(color: const Color(0xffFF5F61)),
              ),
              child: Center(
                child: Text(
                  LocaleKeys.yes_delete.tr(),
                  style: context.textTheme.bodyMedium?.bq.copyWith(
                    color: const Color(0xffFF5F61),
                    letterSpacing: 0.18,
                    fontSize: 16.sp,
                    height: 1.3,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          InkWell(
            onTap: () {
              showDeleteAddress.value = false;
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 24.w),
              height: 50.h,
              width: 1.sw,
              child: Center(
                child: Text(
                  LocaleKeys.cansel.tr(),
                  style: context.textTheme.bodyMedium?.rq.copyWith(
                    color: const Color(0xffFFFFFF),
                    letterSpacing: 0.18,
                    fontSize: 16.sp,
                    height: 1.3,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget buildPageHeader(BuildContext context, OrderState state) {
    return Container(
      margin: EdgeInsets.only(top: 50.h),
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
                    width: 40.w,
                    child: Transform.rotate(
                      angle: LanguageService.languageCode == "ar" ? pi : 0,
                      child: SvgPicture.asset(
                        AppAssets.backIconArrowSvg,
                        height: 20.h,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                SvgPicture.asset(AppAssets.deliveryAddressSvg, height: 20.h),
                SizedBox(width: 5.w),
                Text(
                  !(state.listOfAddressInfoClassToSave.isNullOrEmpty)
                      ? "${LocaleKeys.shipping_payment.tr()} "
                      : "${LocaleKeys.bag_shipping_delivery_address.tr()} ",
                  style: context.textTheme.bodyMedium?.mq.copyWith(
                    color: const Color(0xff1D1D1D),
                    letterSpacing: 0.2,
                    fontSize: 14.sp,
                    height: 1.33,
                  ),
                ),
                SizedBox(
                  width: LanguageService.languageCode == "ar"
                      ? !(state.listOfAddressInfoClassToSave.isNullOrEmpty)
                            ? 180.w
                            : 120.w
                      : !(state.listOfAddressInfoClassToSave.isNullOrEmpty)
                      ? 140.w
                      : 80.w,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget addressInfoWithContactInfoCart({
  required CustomerAddressesInfo customerAddressesInfo,
  required int index,
  required int indexTap,
  required bool isDelete,
  bool? placeOrder,
  bool? successfulOrder,
  required bool cartChoosed,
  String? shippingDays,
  required BuildContext context,
  required void Function()? onTapEdit,
  required void Function()? onTapDelete,
}) {
  return Container(
    // height: (placeOrder ?? false)
    //     ? 120
    //     : (!isDelete && cartChoosed)
    //         ? 125
    //         : 90,
    width: 1.sw,

    padding: EdgeInsets.only(
      right: LanguageService.languageCode == "ar" ? 20.w : 10.w,
      left: LanguageService.languageCode != "ar" ? 20.w : 10.w,
      bottom: 5.h,
    ),
    decoration: BoxDecoration(
      color: (placeOrder ?? false) || (successfulOrder ?? false)
          ? const Color(0xffFFFFFF)
          : isDelete
          ? const Color.fromRGBO(0, 0, 0, 0)
          : const Color(0xffF8F8F8),
      borderRadius: BorderRadius.circular(15.r),
      border: (placeOrder ?? false)
          ? Border.all(color: const Color(0xffC4C2C2))
          : isDelete || (successfulOrder ?? false)
          ? Border.all(color: const Color(0xffFFFFFF))
          : cartChoosed
          ? Border.all(color: const Color(0xff388CFF))
          : index != indexTap
          ? null
          : Border.all(color: const Color(0xff388CFF)),
    ),
    child: Column(
      children: [
        SizedBox(height: 5.h),
        Container(
          width: 360.w,
          height: 16.h,
          child: Row(
            children: [
              SvgPicture.asset(
                AppAssets.homeInactiveSvg,
                // ignore: deprecated_member_use
                color: isDelete
                    ? const Color(0xffFFFFFF)
                    : index != indexTap
                    ? const Color(0xff8D8D8D)
                    : const Color(0xff1D1D1D),
                height: 12.h,
                width: 12.w,
              ),
              const SizedBox(width: 5),
              Text(
                customerAddressesInfo.address ?? "",
                style: context.textTheme.bodyMedium?.mq.copyWith(
                  color: isDelete
                      ? const Color(0xffFFFFFF)
                      : index != indexTap
                      ? const Color(0xff8D8D8D)
                      : const Color(0xff1D1D1D),
                  letterSpacing: 0.18,
                  fontSize: 12.sp,
                  height: 1.3,
                ),
              ),
              isDelete || cartChoosed
                  ? const SizedBox.shrink()
                  : const Spacer(),
              isDelete || cartChoosed
                  ? const SizedBox.shrink()
                  : InkWell(
                      onTap: onTapEdit,
                      child: Container(
                        margin: const EdgeInsets.only(top: 5),
                        width: 20.w,
                        height: 30.h,
                        child: SvgPicture.asset(
                          AppAssets.editSvg,
                          height: 30.h,
                          width: 20.w,
                        ),
                      ),
                    ),
              isDelete || cartChoosed
                  ? const SizedBox.shrink()
                  : SizedBox(width: 10.w),
              isDelete || cartChoosed
                  ? const SizedBox.shrink()
                  : InkWell(
                      onTap: onTapDelete,
                      child: Container(
                        margin: EdgeInsets.only(top: 5.h),
                        width: 20.w,
                        height: 30.h,
                        child: SvgPicture.asset(
                          AppAssets.deletecartSvg,
                          height: 14.h,
                          width: 14.w,
                        ),
                      ),
                    ),
            ],
          ),
        ),
        Container(
          width: 350.w,
          height: 16.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Text(
                "${(customerAddressesInfo.regionDetails?.building.toString() == "null" || customerAddressesInfo.regionDetails?.building == "") ? "" : customerAddressesInfo.regionDetails?.building}${(customerAddressesInfo.regionDetails?.building.toString() != "null" && customerAddressesInfo.regionDetails?.building != "") ? " | " : ""}${customerAddressesInfo.regionDetails?.street.toString() == "null" || customerAddressesInfo.regionDetails?.street == "" ? "" : customerAddressesInfo.regionDetails?.street}${(customerAddressesInfo.regionDetails?.street.toString() != "null" && customerAddressesInfo.regionDetails?.street != "") ? " | " : ""}${customerAddressesInfo.regionDetails?.town.toString() == "null" || customerAddressesInfo.regionDetails?.town == "" ? "" : customerAddressesInfo.regionDetails?.town}${(customerAddressesInfo.regionDetails?.town.toString() != "null" && customerAddressesInfo.regionDetails?.town != "") ? " | " : ""}${customerAddressesInfo.regionDetails?.city.toString() == "null" || customerAddressesInfo.regionDetails?.city == "" ? "" : customerAddressesInfo.regionDetails?.city}${(customerAddressesInfo.regionDetails?.city.toString() != "null" && customerAddressesInfo.regionDetails?.city != "") ? " | " : ""}${customerAddressesInfo.regionDetails?.province.toString() == "null" || customerAddressesInfo.regionDetails?.province == "" ? "" : customerAddressesInfo.regionDetails?.province} | ${customerAddressesInfo.regionDetails?.country ?? ''}",
                style: context.textTheme.bodyMedium?.mq.copyWith(
                  color: isDelete
                      ? const Color(0xffFFFFFF)
                      : index != indexTap
                      ? const Color(0xff8D8D8D)
                      : const Color(0xff1D1D1D),
                  letterSpacing: 0.18,
                  fontSize: 12.sp,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 350.w,
          height: 16.h,
          child: Row(
            children: [
              Text(
                "${customerAddressesInfo.addressDetail}",
                style: context.textTheme.bodyMedium?.mq.copyWith(
                  color: isDelete
                      ? const Color(0xffFFFFFF)
                      : index != indexTap
                      ? const Color(0xff8D8D8D)
                      : const Color(0xff1D1D1D),
                  letterSpacing: 0.18,
                  fontSize: 12.sp,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 350.w,
          height: 16.sp,
          child: Row(
            children: [
              SvgPicture.asset(
                AppAssets.phoneCallSvg,
                // ignore: deprecated_member_use
                color: isDelete
                    ? const Color(0xffFFFFFF)
                    : index != indexTap
                    ? const Color(0xff8D8D8D)
                    : const Color(0xff1D1D1D),
                height: 12.h,
                width: 12.w,
              ),
              const SizedBox(width: 5),
              Text(
                '+${(customerAddressesInfo.contactInfo?.phone ?? "").replaceAll("+", "")}',
                style: context.textTheme.bodyMedium?.mq.copyWith(
                  color: isDelete
                      ? const Color(0xffFFFFFF)
                      : index != indexTap
                      ? const Color(0xff8D8D8D)
                      : const Color(0xff1D1D1D),
                  letterSpacing: 0.18,
                  fontSize: 12.sp,
                  height: 1.3,
                ),
              ),
              SizedBox(width: 40.w),
              Container(
                height: 16.h,
                child: Row(
                  children: [
                    SvgPicture.asset(
                      AppAssets.personSvg,
                      // ignore: deprecated_member_use
                      color: isDelete
                          ? const Color(0xffFFFFFF)
                          : index != indexTap
                          ? const Color(0xff8D8D8D)
                          : const Color(0xff1D1D1D),
                      height: 12.h,
                      width: 12.w,
                    ),
                    const SizedBox(width: 5),
                    SizedBox(
                      width: 130.w,
                      child: Text(
                        '${customerAddressesInfo.contactInfo?.name ?? ""}',
                        style: context.textTheme.bodyMedium?.mq.copyWith(
                          color: isDelete
                              ? const Color(0xffFFFFFF)
                              : index != indexTap
                              ? const Color(0xff8D8D8D)
                              : const Color(0xff1D1D1D),
                          letterSpacing: 0.18,
                          fontSize: 12.sp,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              index != indexTap || isDelete
                  ? const SizedBox.shrink()
                  : SvgPicture.asset(
                      AppAssets.shareSvg,
                      // ignore: deprecated_member_use
                      color: isDelete || cartChoosed
                          ? const Color(0xffFFFFFF)
                          : const Color(0xff388CFF),
                      allowDrawingOutsideViewBox: true,
                      height: 12.h,
                      width: 12.w,
                    ),
            ],
          ),
        ),
        !(!isDelete && cartChoosed)
            ? const SizedBox.shrink()
            : const SizedBox(height: 15),
        !(placeOrder ?? false)
            ? const SizedBox.shrink()
            : const SizedBox(height: 5),
        !(!isDelete && cartChoosed)
            ? const SizedBox.shrink()
            : Container(
                height: 30.h,
                width: 1.sw,
                decoration: BoxDecoration(
                  color: (placeOrder ?? false) || (successfulOrder ?? false)
                      ? const Color(0xffF8F8F8)
                      : const Color(0xffFFFFFF),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${LocaleKeys.expected_delivery.tr()}',
                      style: context.textTheme.bodyMedium?.rq.copyWith(
                        color: const Color(0xff8D8D8D),
                        letterSpacing: 0.18,
                        fontSize: 10.sp,
                        height: 1.3,
                      ),
                    ),
                    Text(
                      ' ${HelperFunctions.getDateInFormatForShippingDays(int.tryParse(shippingDays ?? "0") ?? 0)}. ',
                      style: context.textTheme.bodyMedium?.rq.copyWith(
                        color: const Color(0xff1D1D1D),
                        letterSpacing: 0.18,
                        fontSize: 10.sp,
                        height: 1.3,
                      ),
                    ),
                    Text(
                      '${LocaleKeys.delivery_not.tr()}',
                      style: context.textTheme.bodyMedium?.rq.copyWith(
                        decoration: TextDecoration.underline,
                        decorationColor: const Color(0xff388CFF),
                        color: const Color(0xff388CFF),
                        letterSpacing: 0.18,
                        fontSize: 10.sp,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: (!isDelete && cartChoosed)
          ? MainAxisAlignment.start
          : MainAxisAlignment.spaceBetween,
    ),
  );
}
