import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/constant/design/assets_provider.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/language_service.dart';

import '../../../../../common/constant/payment_methods.dart';
import '../../../../../common/helper/show_message.dart';

class PaymentMethod extends StatefulWidget {
  final ValueNotifier<List<String>> paymentMethods;
  final List<String> availablePaymentMethod;
  final double amount;
  final double totalPrice;
  final bool fromPalceOrder;
  final bool fromSuccessOrder;
  final int decimalPointSetting;
  final String currencySymbol;
  final double partialPaymentByWallet;
  const PaymentMethod({
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
    super.initState();
  }

  void _addItemToPaymentMethods(
      ValueNotifier<List<String>> paymentMethods, String item) {
    paymentMethods.value = List.from(paymentMethods.value)..add(item);
  }

  void _removeItemFromPaymentMethods(
      ValueNotifier<List<String>> paymentMethods, String item) {
    paymentMethods.value = List.from(paymentMethods.value)
      ..removeWhere(
        (element) => element == item,
      );
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
    return Column(
      children: [
        ValueListenableBuilder<List<String>>(
          valueListenable: widget.paymentMethods,
          builder: (context, _paymentMethods, _) {
            return Container(
              width: 1.sw,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: (widget.fromPalceOrder)
                      ? null
                      : Border.all(color: Color(0xff388CFF))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SvgPicture.asset(AppAssets.paymentMethodSvg),
                      SizedBox(width: 10.w),
                      Text(
                        "${LocaleKeys.payment_method.tr()} ",
                        style: context.textTheme.bodyMedium?.rr.copyWith(
                            color: const Color(0xff1D1D1D),
                            letterSpacing: 0.18,
                            fontSize: 14.sp,
                            height: 1.33),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 29.w,
                    ),
                    child: Text(
                      widget.fromSuccessOrder || widget.fromPalceOrder
                          ? "${LocaleKeys.your_payment_method_about_your_bag.tr()} "
                          : "${LocaleKeys.please_choose_your_payment_method_about_your_bag.tr()} ",
                      style: context.textTheme.bodyMedium?.rr.copyWith(
                          color: const Color(0xff8D8D8D),
                          letterSpacing: 0.18,
                          fontSize: 12,
                          height: 1.33),
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  (!(_paymentMethods.contains(PaymentMethods.trydosWallet)) &&
                              widget.fromPalceOrder) ||
                          !widget.availablePaymentMethod
                              .contains(PaymentMethods.trydosWallet)
                      ? SizedBox.shrink()
                      : InkWell(
                          onTap: () {
                            if (widget.fromPalceOrder ||
                                widget.fromSuccessOrder) {
                              return;
                            }
                            ///////////////////////////
                            if (_paymentMethods
                                .contains(PaymentMethods.trydosWallet)) {
                              _removeItemFromPaymentMethods(
                                widget.paymentMethods,
                                PaymentMethods.trydosWallet,
                              );
                            } else {
                              if (widget.amount > 0) {
                                if (widget.paymentMethods.value.isNotEmpty) {
                                  widget.paymentMethods.value =
                                      List.from(widget.paymentMethods.value)
                                        ..clear();
                                  //////////////////////
                                  _addItemToPaymentMethods(
                                    widget.paymentMethods,
                                    PaymentMethods.trydosWallet,
                                  );
                                } else {
                                  _addItemToPaymentMethods(
                                    widget.paymentMethods,
                                    PaymentMethods.trydosWallet,
                                  );
                                }
                              }
                            }
                          },
                          child: PaymentMethodCard(
                            paymentMethod: _paymentMethods,
                            fromPalceOrder: widget.fromPalceOrder,
                            fromSuccessOrder: widget.fromSuccessOrder,
                            currentPaymentMethod: PaymentMethods.trydosWallet,
                            svg: AppAssets.trydosWalletSvg,
                            title: LanguageService.languageCode == "ar"
                                ? "${LocaleKeys.wallet.tr()} ${LocaleKeys.trydos.tr()}"
                                : "${LocaleKeys.trydos.tr()} ${LocaleKeys.wallet.tr()}",
                            cardWidgets: buildTrydosWalletWidget(
                              context: context,
                              fromSuccessOrder: widget.fromSuccessOrder,
                            ),
                          ),
                        ),
                  /////////////////////
                  (!(_paymentMethods.contains(PaymentMethods.trydosWallet)) &&
                              widget.fromPalceOrder) ||
                          !widget.availablePaymentMethod
                              .contains(PaymentMethods.trydosWallet)
                      ? SizedBox.shrink()
                      : SizedBox(
                          height: 8,
                        ),
                  ////////////////////
                  (!(_paymentMethods.contains(PaymentMethods.card)) &&
                              widget.fromPalceOrder) ||
                          !widget.availablePaymentMethod
                              .contains(PaymentMethods.card)
                      ? SizedBox.shrink()
                      : InkWell(
                          onTap: () {
                            if (widget.fromPalceOrder ||
                                widget.fromSuccessOrder ||
                                widget.amount > widget.totalPrice) {
                              if (widget.amount > widget.totalPrice &&
                                  !(widget.fromPalceOrder ||
                                      widget.fromSuccessOrder)) {
                                showMessage(
                                  " ${LocaleKeys.the_payment_is_allowed_throw_trydos_wallet_only.tr()}",
                                  foreGroundColor: Colors.white,
                                  backGroundColor: Colors.black,
                                  showInRelease: true,
                                  timeShowing: Toast.LENGTH_LONG,
                                );
                              }
                              return;
                            }
                            /////////////////////
                            if (_paymentMethods.contains(PaymentMethods.card)) {
                              _removeItemFromPaymentMethods(
                                widget.paymentMethods,
                                PaymentMethods.card,
                              );
                            } else {
                              if (widget.paymentMethods.value
                                  .contains(PaymentMethods.trydosWallet)) {
                                if (widget.amount < widget.totalPrice) {
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
                                } else {
                                  widget.paymentMethods.value =
                                      List.from(widget.paymentMethods.value)
                                        ..clear();
                                  ////////////////
                                  _addItemToPaymentMethods(
                                    widget.paymentMethods,
                                    PaymentMethods.card,
                                  );
                                }
                              } else {
                                widget.paymentMethods.value =
                                    List.from(widget.paymentMethods.value)
                                      ..clear();
                                ////////////////
                                _addItemToPaymentMethods(
                                  widget.paymentMethods,
                                  PaymentMethods.card,
                                );
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
                                fromSuccessOrder: widget.fromSuccessOrder),
                          ),
                        ),
                  ////////////////////////
                  (!(_paymentMethods.contains(PaymentMethods.card)) &&
                              widget.fromPalceOrder) ||
                          !widget.availablePaymentMethod
                              .contains(PaymentMethods.card)
                      ? SizedBox.shrink()
                      : SizedBox(
                          height: 12.h,
                        ),
                  //////////////////////
                  (!(_paymentMethods.contains(PaymentMethods.crypto)) &&
                              widget.fromPalceOrder) ||
                          !widget.availablePaymentMethod
                              .contains(PaymentMethods.crypto)
                      ? SizedBox.shrink()
                      : InkWell(
                          onTap: () {
                            if (widget.fromPalceOrder ||
                                widget.fromSuccessOrder ||
                                widget.amount > widget.totalPrice) {
                              if (widget.amount > widget.totalPrice &&
                                  !(widget.fromPalceOrder ||
                                      widget.fromSuccessOrder)) {
                                showMessage(
                                  " ${LocaleKeys.the_payment_is_allowed_throw_trydos_wallet_only.tr()}",
                                  foreGroundColor: Colors.white,
                                  backGroundColor: Colors.black,
                                  showInRelease: true,
                                  timeShowing: Toast.LENGTH_LONG,
                                );
                              }
                              return;
                            }
                            //////////////////////////
                            if (_paymentMethods
                                .contains(PaymentMethods.crypto)) {
                              _removeItemFromPaymentMethods(
                                widget.paymentMethods,
                                PaymentMethods.crypto,
                              );
                              ///////////////////
                            } else {
                              if (widget.paymentMethods.value
                                  .contains(PaymentMethods.trydosWallet)) {
                                if (widget.amount < widget.totalPrice) {
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
                                } else {
                                  widget.paymentMethods.value =
                                      List.from(widget.paymentMethods.value)
                                        ..clear();
                                  ////////////////
                                  _addItemToPaymentMethods(
                                    widget.paymentMethods,
                                    PaymentMethods.crypto,
                                  );
                                }
                              } else {
                                widget.paymentMethods.value =
                                    List.from(widget.paymentMethods.value)
                                      ..clear();
                                ////////////////
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
                                fromSuccessOrder: widget.fromSuccessOrder),
                          ),
                        ),
                  ////////////////////////
                  (!(_paymentMethods.contains(PaymentMethods.crypto)) &&
                              widget.fromPalceOrder) ||
                          !widget.availablePaymentMethod
                              .contains(PaymentMethods.crypto)
                      ? SizedBox.shrink()
                      : SizedBox(
                          height: 12,
                        ),
                  //////////////////////
                  (!(_paymentMethods.contains(PaymentMethods.cod)) &&
                              widget.fromPalceOrder) ||
                          !widget.availablePaymentMethod
                              .contains(PaymentMethods.cod)
                      ? SizedBox.shrink()
                      : InkWell(
                          onTap: () {
                            if (widget.fromPalceOrder ||
                                widget.fromSuccessOrder ||
                                widget.amount > widget.totalPrice) {
                              if (widget.amount > widget.totalPrice &&
                                  !(widget.fromPalceOrder ||
                                      widget.fromSuccessOrder)) {
                                showMessage(
                                  " ${LocaleKeys.the_payment_is_allowed_throw_trydos_wallet_only.tr()}",
                                  foreGroundColor: Colors.white,
                                  backGroundColor: Colors.black,
                                  showInRelease: true,
                                  timeShowing: Toast.LENGTH_LONG,
                                );
                              }
                              return;
                            }
                            if (_paymentMethods.contains(PaymentMethods.cod)) {
                              _removeItemFromPaymentMethods(
                                widget.paymentMethods,
                                PaymentMethods.cod,
                              );
                            } else {
                              if (widget.paymentMethods.value
                                  .contains(PaymentMethods.trydosWallet)) {
                                if (widget.amount < widget.totalPrice) {
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
                                } else {
                                  widget.paymentMethods.value =
                                      List.from(widget.paymentMethods.value)
                                        ..clear();
                                  ////////////////
                                  _addItemToPaymentMethods(
                                    widget.paymentMethods,
                                    PaymentMethods.cod,
                                  );
                                }
                              } else {
                                widget.paymentMethods.value =
                                    List.from(widget.paymentMethods.value)
                                      ..clear();
                                ////////////////
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
          style: context.textTheme.bodyMedium?.rr.copyWith(
              color: const Color(0xffD3D3D3),
              letterSpacing: 0.18,
              fontSize: 12,
              height: 1.33),
        ),
        Text(
          widget.partialPaymentByWallet > 0
              ? '${(widget.amount - widget.partialPaymentByWallet).toStringAsFixed(GetIt.I<HomeBloc>().state.startingSetting?.decimalPointSettings ?? 2)} ${widget.currencySymbol}'
              : '${widget.amount.toStringAsFixed(GetIt.I<HomeBloc>().state.startingSetting?.decimalPointSettings ?? 2)} ${widget.currencySymbol}',
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
    return fromSuccessOrder ? buildOrderTotal() : SizedBox.shrink();
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
          style: context.textTheme.bodyMedium?.rr.copyWith(
              color: const Color(0xffD3D3D3),
              letterSpacing: 0.18,
              fontSize: 12,
              height: 1.33),
        ),
        Text(
          widget.partialPaymentByWallet > 0
              ? '${widget.partialPaymentByWallet.toStringAsFixed(GetIt.I<HomeBloc>().state.startingSetting?.decimalPointSettings ?? 2)} ${widget.currencySymbol}'
              : '${widget.amount.toStringAsFixed(GetIt.I<HomeBloc>().state.startingSetting?.decimalPointSettings ?? 2)} ${widget.currencySymbol}',
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
    return Container(
      height: 40.h,
      width: 1.sw,
      decoration: BoxDecoration(
        border: Border.all(
          color: fromSuccessOrder
              ? Color.fromARGB(255, 255, 255, 255)
              : fromPalceOrder
                  ? Color(0xffC4C2C2)
                  : paymentMethod.contains(currentPaymentMethod)
                      ? Color(0xff388CFF)
                      : Color(0xffF8F8F8),
        ),
        color: fromSuccessOrder || fromPalceOrder
            ? Color.fromARGB(255, 255, 255, 255)
            : Color(0xffF8F8F8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 26.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SvgPicture.asset(
              svg,
              color: paymentMethod.contains(currentPaymentMethod) &&
                      !fromSuccessOrder
                  ? Color(0xff1D1D1D)
                  : null,
            ),
            SizedBox(width: 10.w),
            Text(
              title,
              style: context.textTheme.bodyMedium?.rr.copyWith(
                  color: paymentMethod.contains(currentPaymentMethod)
                      ? Color(0xff1D1D1D)
                      : Color(0xffC4C2C2),
                  letterSpacing: 0.18,
                  fontSize: 12,
                  height: 1.33),
            ),
            //////////////////
            Spacer(),
            ///////////////////
            cardWidgets,
          ],
        ),
      ),
    );
  }
}
