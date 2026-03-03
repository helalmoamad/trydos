import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/constant/design/assets_provider.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/orderBloc/order_bloc.dart';
import 'package:trydos/features/home/presentation/manager/orderBloc/order_state.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_events.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_buttons_event_name.dart';
import 'package:trydos/service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../../../../common/constant/payment_methods.dart';
import '../../../../../common/helper/show_message.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';

class PaymentMethod extends StatefulWidget {
  final ValueNotifier<List<String>> paymentMethods;
  final List<String> availablePaymentMethod;
  final double amount;
  final double totalPrice;
  final bool fromPalceOrder;
  final bool fromSuccessOrder;
  final double decimalPointSetting;
  final String currencySymbol;
  final double partialPaymentByWallet;
  const PaymentMethod({
    super.key,
    required this.paymentMethods,
    required this.fromPalceOrder,
    required this.fromSuccessOrder,
    required this.availablePaymentMethod,
    required this.totalPrice,
    required this.amount,
    required this.decimalPointSetting,
    required this.currencySymbol,
    this.partialPaymentByWallet = 0,
  });

  @override
  State<PaymentMethod> createState() => _PaymentMethodState();
}

PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();

class _PaymentMethodState extends State<PaymentMethod> {
  @override
  void initState() {
    if ((widget.amount > 0 &&
            !widget.fromSuccessOrder &&
            (widget.amount >= widget.totalPrice)) &&
        !widget.paymentMethods.value.contains(PaymentMethods.trydosWallet)) {
      _addItemToPaymentMethods(
        widget.paymentMethods,
        PaymentMethods.trydosWallet,
      );
    }

    super.initState();
  }

  void _addItemToPaymentMethods(
    ValueNotifier<List<String>> paymentMethods,
    String item,
  ) {
    Future.delayed(const Duration(milliseconds: 300), () {
      paymentMethods.value = List.from([item]);
      // List.from(paymentMethods.value)..add(item);
    });
  }

  void _removeItemFromPaymentMethods(
    ValueNotifier<List<String>> paymentMethods,
    String item,
  ) {
    paymentMethods.value = List.from(paymentMethods.value)
      ..removeWhere((element) => element == item);
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return Column(
      children: [
        ValueListenableBuilder<List<String>>(
          valueListenable: widget.paymentMethods,
          builder: (context, _paymentMethods, _) {
            return Container(
              width: 1.sw,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: (widget.fromPalceOrder)
                    ? null
                    : Border.all(color: const Color(0xff388CFF)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(AppAssets.paymentMethodSvg),
                      SizedBox(width: 10.w),
                      InkWell(
                        onTap: () {
                          print(widget.availablePaymentMethod);
                          print(_paymentMethods);
                        },
                        child: Text(
                          "${LocaleKeys.payment_method.tr()} ",
                          style: context.textTheme.bodyMedium?.rq.copyWith(
                            color: const Color(0xff1D1D1D),
                            letterSpacing: 0.18,
                            fontSize: 14.sp,
                            height: 1.33,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 29.w),
                    child: Text(
                      widget.fromSuccessOrder || widget.fromPalceOrder
                          ? "${LocaleKeys.your_payment_method_about_your_bag.tr()} "
                          : "${LocaleKeys.please_choose_your_payment_method_about_your_bag.tr()} ",
                      style: context.textTheme.bodyMedium?.rq.copyWith(
                        color: const Color(0xff8D8D8D),
                        letterSpacing: 0.18,
                        fontSize: 12,
                        height: 1.33,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  (!(_paymentMethods.contains(PaymentMethods.cod)) &&
                              (widget.fromPalceOrder)) ||
                          !widget.availablePaymentMethod.contains(
                            PaymentMethods.cod,
                          )
                      ? const SizedBox.shrink()
                      : InkWell(
                          onTap: () {
                            if (widget.fromPalceOrder ||
                                widget.fromSuccessOrder) {
                              return;
                            }
                            if (widget.amount >= widget.totalPrice) {
                              showWarningMessage(
                                context,
                                "${LocaleKeys.the_payment_is_allowed_throw_trydos_wallet_only.tr()}",
                              );
                              return;
                            }
                            if (widget.amount < widget.totalPrice) {
                              if (_paymentMethods.contains(
                                PaymentMethods.cod,
                              )) {
                                _removeItemFromPaymentMethods(
                                  widget.paymentMethods,
                                  PaymentMethods.cod,
                                );
                              } else {
                                widget.paymentMethods.value =
                                    List.from(widget.paymentMethods.value)
                                      ..removeWhere(
                                        (element) =>
                                            element !=
                                            PaymentMethods.trydosWallet,
                                      );
                                ///////////////
                                _addItemToPaymentMethods(
                                  widget.paymentMethods,
                                  PaymentMethods.cod,
                                );
                              }
                            }
                          },
                          child: PaymentMethodCard(
                            fromPalceOrder: widget.fromPalceOrder,
                            paymentMethod: _paymentMethods,
                            fromSuccessOrder: widget.fromSuccessOrder,
                            currentPaymentMethod: PaymentMethods.cod,
                            svg: AppAssets.earnMoneySvg,
                            title: "${LocaleKeys.cod.tr()}",
                            cardWidgets: buildCodWidget(
                              fromSuccessOrder: widget.fromSuccessOrder,
                            ),
                          ),
                        ),
                  /////////////////////
                  (!(_paymentMethods.contains(PaymentMethods.cod)) &&
                              (widget.fromPalceOrder)) ||
                          !widget.availablePaymentMethod.contains(
                            PaymentMethods.cod,
                          )
                      ? const SizedBox.shrink()
                      : const SizedBox(height: 8),
                  /////////////////////
                  (!(_paymentMethods.contains(PaymentMethods.trydosWallet)) &&
                              widget.fromPalceOrder) ||
                          !widget.availablePaymentMethod.contains(
                            PaymentMethods.trydosWallet,
                          )
                      ? const SizedBox.shrink()
                      : InkWell(
                          onTap: () {
                            if (widget.fromPalceOrder ||
                                widget.fromSuccessOrder) {
                              return;
                            }
                            if ((widget.amount == 0) ||
                                (widget.amount < widget.totalPrice)) {
                              showWarningMessage(
                                context,
                                "${LocaleKeys.you_dont_have_enough_credit_in_the_wallet.tr()}",
                              );
                              return;
                            }
                          },
                          child: PaymentMethodCard(
                            paymentMethod: _paymentMethods,
                            fromPalceOrder: widget.fromPalceOrder,
                            fromSuccessOrder: widget.fromSuccessOrder,
                            currentPaymentMethod: PaymentMethods.trydosWallet,
                            svg: AppAssets.trydosWalletSvg,
                            title: LocaleKeys.wallet.tr(),
                            cardWidgets: buildTrydosWalletWidget(
                              context: context,
                              fromSuccessOrder: widget.fromSuccessOrder,
                            ),
                          ),
                        ),
                  /////////////////////
                  (!(_paymentMethods.contains(PaymentMethods.trydosWallet)) &&
                              widget.fromPalceOrder) ||
                          !widget.availablePaymentMethod.contains(
                            PaymentMethods.trydosWallet,
                          )
                      ? const SizedBox.shrink()
                      : const SizedBox(height: 8),
                  ////////////////////
                  (!(_paymentMethods.contains(PaymentMethods.card)) &&
                              widget.fromPalceOrder) ||
                          !widget.availablePaymentMethod.contains(
                            PaymentMethods.card,
                          )
                      ? const SizedBox.shrink()
                      : InkWell(
                          onTap: () {
                            if (widget.fromPalceOrder ||
                                widget.fromSuccessOrder) {
                              return;
                            }
                            if (widget.amount >= widget.totalPrice) {
                              showWarningMessage(
                                context,
                                "${LocaleKeys.the_payment_is_allowed_throw_trydos_wallet_only.tr()}",
                              );
                              return;
                            }
                            if (widget.amount < widget.totalPrice) {
                              if (_paymentMethods.contains(
                                PaymentMethods.card,
                              )) {
                                _removeItemFromPaymentMethods(
                                  widget.paymentMethods,
                                  PaymentMethods.card,
                                );
                              } else {
                                widget.paymentMethods.value =
                                    List.from(widget.paymentMethods.value)
                                      ..removeWhere(
                                        (element) =>
                                            element !=
                                            PaymentMethods.trydosWallet,
                                      );
                                ///////////////
                                _addItemToPaymentMethods(
                                  widget.paymentMethods,
                                  PaymentMethods.card,
                                );

                                // Log add payment event
                                try {
                                  FirebaseAnalyticsService.logEventForSession(
                                    eventName: AnalyticsEventsConst.ADD_PAYMENT,
                                    executedEventName:
                                        AnalyticsButtonsEventNameConst
                                            .CONFIRM_SHIPPING_AND_PAYMENT_BUTTON,
                                    extraParams: {
                                      'payment_type': PaymentMethods.card,
                                    },
                                  );
                                } catch (e) {}
                              }
                            }
                          },
                          child: PaymentMethodCard(
                            fromPalceOrder: widget.fromPalceOrder,
                            paymentMethod: _paymentMethods,
                            fromSuccessOrder: widget.fromSuccessOrder,
                            currentPaymentMethod: PaymentMethods.card,
                            svg: AppAssets.creditCards,
                            title: "${LocaleKeys.credit_cards.tr()}",
                            cardWidgets: buildCardPaymentWidget(
                              fromSuccessOrder: widget.fromSuccessOrder,
                            ),
                          ),
                        ),
                  ////////////////////////
                  (!(_paymentMethods.contains(PaymentMethods.card)) &&
                              widget.fromPalceOrder) ||
                          !widget.availablePaymentMethod.contains(
                            PaymentMethods.card,
                          )
                      ? const SizedBox.shrink()
                      : SizedBox(height: 12.h),
                  //////////////////////
                  (!(_paymentMethods.contains(PaymentMethods.crypto)) &&
                              widget.fromPalceOrder) ||
                          !widget.availablePaymentMethod.contains(
                            PaymentMethods.crypto,
                          )
                      ? const SizedBox.shrink()
                      : InkWell(
                          onTap: () {
                            if (widget.fromPalceOrder ||
                                widget.fromSuccessOrder) {
                              return;
                            }
                            if (widget.amount >= widget.totalPrice) {
                              showWarningMessage(
                                context,
                                "${LocaleKeys.the_payment_is_allowed_throw_trydos_wallet_only.tr()}",
                              );
                              return;
                            }
                            if (widget.amount < widget.totalPrice) {
                              if (_paymentMethods.contains(
                                PaymentMethods.crypto,
                              )) {
                                _removeItemFromPaymentMethods(
                                  widget.paymentMethods,
                                  PaymentMethods.crypto,
                                );
                              } else {
                                widget.paymentMethods.value =
                                    List.from(widget.paymentMethods.value)
                                      ..removeWhere(
                                        (element) =>
                                            element !=
                                            PaymentMethods.trydosWallet,
                                      );
                                ///////////////
                                _addItemToPaymentMethods(
                                  widget.paymentMethods,
                                  PaymentMethods.crypto,
                                );
                              }
                            }
                          },
                          child: PaymentMethodCard(
                            fromPalceOrder: widget.fromPalceOrder,
                            paymentMethod: _paymentMethods,
                            fromSuccessOrder: widget.fromSuccessOrder,
                            currentPaymentMethod: PaymentMethods.crypto,
                            svg: AppAssets.cryptoSvg,
                            title: "${LocaleKeys.Crypto.tr()}",
                            cardWidgets: buildCryptoWidget(
                              fromSuccessOrder: widget.fromSuccessOrder,
                            ),
                          ),
                        ),
                  ////////////////////////
                  /* (!(_paymentMethods.contains(PaymentMethods.crypto)) &&
                              widget.fromPalceOrder) ||
                          !widget.availablePaymentMethod
                              .contains(PaymentMethods.crypto)
                      ? SizedBox.shrink()
                      : SizedBox(
                          height: 12,
                        ),*/
                  //////////////////////
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget buildOrderTotal() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "${LocaleKeys.total.tr()}  ",
          style: context.textTheme.bodyMedium?.rq.copyWith(
            color: const Color(0xffD3D3D3),
            letterSpacing: 0.18,
            fontSize: 12,
            height: 1.33,
          ),
        ),
        Text(
          widget.partialPaymentByWallet > 0
              ? '${HelperFunctions.formatNumber(numberToFormate: (widget.amount - widget.partialPaymentByWallet), isNeedRounding: false)} ${widget.currencySymbol}'
              : '${HelperFunctions.formatNumber(numberToFormate: widget.amount, isNeedRounding: false)} ${widget.currencySymbol}',
          style: context.textTheme.bodyMedium?.sbt.copyWith(
            color: const Color(0xff1D1D1D),
            letterSpacing: 0.18,
            fontSize: 12,
            height: 1.33,
          ),
        ),
      ],
    );
  }

  Widget buildCodWidget({required bool fromSuccessOrder}) {
    return fromSuccessOrder
        ? buildOrderTotal()
        : Row(
            children: [
              Text(
                "${LocaleKeys.shipping_cost.tr()}  ",
                style: context.textTheme.bodyMedium?.rq.copyWith(
                  color: const Color(0xffD3D3D3),
                  letterSpacing: 0.18,
                  fontSize: 12,
                  height: 1.33,
                ),
              ),
              Text(
                '${HelperFunctions.formatNumber(numberToFormate: ((HelperFunctions.truncateToDecimalPlaces((GetIt.I<HomeBloc>().state.getCartShippingItemsModel?.data?.codCost ?? 0).toDouble(), GetIt.I<HomeBloc>().state.getCurrencyForCountryModel!.data!.currency!.decimalDigits!)) * (GetIt.I<HomeBloc>().state.getCurrencyForCountryModel?.data?.currency?.exchangeRate ?? 1)), isNeedRounding: false)} ${widget.currencySymbol}',
                style: context.textTheme.bodyMedium?.sbt.copyWith(
                  color: const Color(0xff1D1D1D),
                  letterSpacing: 0.18,
                  fontSize: 12,
                  height: 1.33,
                ),
              ),
            ],
          );
  }

  Widget buildCryptoWidget({required bool fromSuccessOrder}) {
    return fromSuccessOrder
        ? buildOrderTotal()
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(AppAssets.crypto1Svg),
              SizedBox(width: 5.w),
              SvgPicture.asset(AppAssets.crypto2Svg),
              SizedBox(width: 5.w),
              SvgPicture.asset(AppAssets.crypto3Svg),
              SizedBox(width: 5.w),
              SvgPicture.asset(AppAssets.crypto4Svg),
            ],
          );
  }

  Widget buildCardPaymentWidget({required bool fromSuccessOrder}) {
    return fromSuccessOrder
        ? buildOrderTotal()
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(AppAssets.visaSvg),
              SizedBox(width: 5.w),
              SvgPicture.asset(AppAssets.masterCardSvg),
              SizedBox(width: 5.w),
              SvgPicture.asset(AppAssets.maestroSvg),
              SizedBox(width: 5.w),
              SvgPicture.asset(AppAssets.americanExpressSvg),
              SizedBox(width: 5.w),
              SvgPicture.asset(AppAssets.applePaySvg),
              SizedBox(width: 5.w),
              SvgPicture.asset(AppAssets.googlePaySvg),
            ],
          );
  }

  Widget buildTrydosWalletWidget({
    required bool fromSuccessOrder,
    required BuildContext context,
  }) {
    return Row(
      children: [
        Text(
          fromSuccessOrder
              ? "${LocaleKeys.total.tr()}  "
              : "${LocaleKeys.your_balance.tr()}  ",
          style: context.textTheme.bodyMedium?.rq.copyWith(
            color: const Color(0xffD3D3D3),
            letterSpacing: 0.18,
            fontSize: 12,
            height: 1.33,
          ),
        ),
        Text(
          widget.partialPaymentByWallet > 0
              ? '${HelperFunctions.formatNumber(numberToFormate: widget.partialPaymentByWallet, isNeedRounding: false)} ${widget.currencySymbol}'
              : '${HelperFunctions.formatNumber(numberToFormate: widget.amount, isNeedRounding: false)} ${widget.currencySymbol}',
          style: context.textTheme.bodyMedium?.sbt.copyWith(
            color: const Color(0xff1D1D1D),
            letterSpacing: 0.18,
            fontSize: 12,
            height: 1.33,
          ),
        ),
        (fromSuccessOrder)
            ? const SizedBox.shrink()
            : BlocBuilder<OrderBloc, OrderState>(
                buildWhen: (previous, current) =>
                    previous.getCustomerWalletStatus !=
                    current.getCustomerWalletStatus,
                builder: (context, state) =>
                    state.getCustomerWalletStatus ==
                        GetCustomerWalletStatus.init
                    ? SizedBox(
                        width: 30,
                        height: 40,
                        child: TrydosLoader(size: 17),
                      )
                    : InkWell(
                        onTap: () {
                          BlocProvider.of<HomeBloc>(context).add(
                            GetCurrenciesForWalletEvent(
                              currencySymbol:
                                  GetIt.I<HomeBloc>()
                                      .state
                                      .getCurrencyForCountryModel!
                                      .data!
                                      .currency!
                                      .code ??
                                  "",
                            ),
                          );
                        },
                        child: const SizedBox(
                          width: 30,
                          height: 40,
                          child: Icon(Icons.refresh_sharp, size: 17),
                        ),
                      ),
              ),
      ],
    );
  }
}

class PaymentMethodCard extends StatelessWidget {
  const PaymentMethodCard({
    super.key,
    required this.fromPalceOrder,
    required this.paymentMethod,
    required this.fromSuccessOrder,
    required this.currentPaymentMethod,
    required this.title,
    required this.svg,
    required this.cardWidgets,
  });

  final bool fromPalceOrder;
  final bool fromSuccessOrder;
  final String currentPaymentMethod;
  final String title;
  final String svg;
  final List<String> paymentMethod;
  final Widget cardWidgets;

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return Container(
      height: 40.h,
      width: 1.sw,
      decoration: BoxDecoration(
        border: Border.all(
          color: fromSuccessOrder
              ? const Color.fromARGB(255, 255, 255, 255)
              : fromPalceOrder
              ? const Color(0xffC4C2C2)
              : paymentMethod.contains(currentPaymentMethod)
              ? const Color(0xff388CFF)
              : const Color(0xffF8F8F8),
        ),
        color: fromSuccessOrder || fromPalceOrder
            ? const Color.fromARGB(255, 255, 255, 255)
            : const Color(0xffF8F8F8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 26.w),
        child: Row(
          children: [
            SvgPicture.asset(
              svg,
              // ignore: deprecated_member_use
              color:
                  paymentMethod.contains(currentPaymentMethod) &&
                      !fromSuccessOrder
                  ? const Color(0xff1D1D1D)
                  : null,
            ),
            SizedBox(width: 10.w),
            Text(
              title,
              style: context.textTheme.bodyMedium?.rq.copyWith(
                color: paymentMethod.contains(currentPaymentMethod)
                    ? const Color(0xff1D1D1D)
                    : const Color(0xffC4C2C2),
                letterSpacing: 0.18,
                fontSize: 10.sp,
                height: 1.33,
              ),
            ),
            //////////////////
            const Spacer(),
            ///////////////////
            cardWidgets,
          ],
        ),
      ),
    );
  }
}
