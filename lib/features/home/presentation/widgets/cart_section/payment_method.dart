import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/constant/design/assets_provider.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/language_service.dart';

class PaymentMethod extends StatefulWidget {
  final ValueNotifier<String> paymentMethod;
  final bool fromPalceOrder;
  final bool fromSuccessOrder;
  const PaymentMethod(
      {required this.paymentMethod,
      required this.fromPalceOrder,
      required this.fromSuccessOrder});

  @override
  State<PaymentMethod> createState() => _PaymentMethodState();
}

class _PaymentMethodState extends State<PaymentMethod> {
  final ValueNotifier<bool> isExpandedCoupon = ValueNotifier(false);
  final ValueNotifier<bool> isApplayCoupon = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
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
    return Column(children: [
      ValueListenableBuilder<String>(
          valueListenable: widget.paymentMethod,
          builder: (context, _paymentMethod, _) {
            return Container(
              height: (widget.fromPalceOrder) ? 120 : 203,
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
                        "${LocaleKeys.please_choose_your_payment_method_about_your_bag.tr()} ",
                        style: context.textTheme.bodyMedium?.rr.copyWith(
                            color: const Color(0xff8D8D8D),
                            letterSpacing: 0.18,
                            fontSize: 12.sp,
                            height: 1.33),
                      )),
                  SizedBox(
                    height: 8,
                  ),
                  !(_paymentMethod == "trydos_wallet") && widget.fromPalceOrder
                      ? SizedBox.shrink()
                      : InkWell(
                          onTap: () {
                            if (widget.fromPalceOrder ||
                                widget.fromSuccessOrder) {
                              return;
                            }
                            if (_paymentMethod == "trydos_wallet") {
                              widget.paymentMethod.value = "";
                            } else {
                              widget.paymentMethod.value = "trydos_wallet";
                            }
                          },
                          child: Container(
                              height: 38,
                              width: 1.sw,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: widget.fromPalceOrder
                                        ? Color(0xffC4C2C2)
                                        : _paymentMethod == "trydos_wallet"
                                            ? Color(0xff388CFF)
                                            : Color(0xffF8F8F8)),
                                color: Color(0xffF8F8F8),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(width: 29.w),
                                  SvgPicture.asset(AppAssets.trydosWalletSvg,
                                      color:
                                          _paymentMethod == "trydos_wallet" &&
                                                  !widget.fromSuccessOrder
                                              ? Color(0xff1D1D1D)
                                              : null),
                                  SizedBox(width: 10.w),
                                  Text(
                                    LanguageService.languageCode == "ar"
                                        ? "${LocaleKeys.wallet.tr()} ${LocaleKeys.trydos.tr()}"
                                        : "${LocaleKeys.trydos.tr()} ${LocaleKeys.wallet.tr()}",
                                    style: context.textTheme.bodyMedium?.rr
                                        .copyWith(
                                            color: _paymentMethod ==
                                                    "trydos_wallet"
                                                ? Color(0xff1D1D1D)
                                                : Color(0xffC4C2C2),
                                            letterSpacing: 0.18,
                                            fontSize: 12.sp,
                                            height: 1.33),
                                  ),
                                  Spacer(),
                                  Text(
                                    widget.fromSuccessOrder
                                        ? "${LocaleKeys.total.tr()}  "
                                        : "${LocaleKeys.your_balance.tr()}  ",
                                    style: context.textTheme.bodyMedium?.rr
                                        .copyWith(
                                            color: const Color(0xffD3D3D3),
                                            letterSpacing: 0.18,
                                            fontSize: 12,
                                            height: 1.33),
                                  ),
                                  Text(
                                    "788 USD",
                                    style: context.textTheme.bodyMedium?.sbt
                                        .copyWith(
                                            color: const Color(0xff1D1D1D),
                                            letterSpacing: 0.18,
                                            fontSize: 12,
                                            height: 1.33),
                                  ),
                                  SizedBox(width: 30.w)
                                ],
                              )),
                        ),
                  (widget.fromPalceOrder)
                      ? SizedBox.shrink()
                      : SizedBox(
                          height: 8,
                        ),
                  !(_paymentMethod == "credit_cards") && widget.fromPalceOrder
                      ? SizedBox.shrink()
                      : InkWell(
                          onTap: () {
                            if (widget.fromPalceOrder ||
                                widget.fromSuccessOrder) {
                              return;
                            }
                            if (_paymentMethod == "credit_cards") {
                              widget.paymentMethod.value = "";
                            } else {
                              widget.paymentMethod.value = "credit_cards";
                            }
                          },
                          child: Center(
                            child: Container(
                                height: 38,
                                width: 1.sw,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: widget.fromPalceOrder
                                          ? Color(0xffC4C2C2)
                                          : _paymentMethod == "credit_cards"
                                              ? Color(0xff388CFF)
                                              : Color(0xffF8F8F8)),
                                  color: Color(0xffF8F8F8),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(width: 29.w),
                                    SvgPicture.asset(AppAssets.creditCards,
                                        color:
                                            _paymentMethod == "credit_cards" &&
                                                    !widget.fromSuccessOrder
                                                ? Color(0xff1D1D1D)
                                                : null),
                                    SizedBox(width: 10.w),
                                    Text(
                                      "${LocaleKeys.credit_cards.tr()}",
                                      style: context.textTheme.bodyMedium?.rr
                                          .copyWith(
                                              color: _paymentMethod ==
                                                      "credit_cards"
                                                  ? Color(0xff1D1D1D)
                                                  : Color(0xffC4C2C2),
                                              letterSpacing: 0.18,
                                              fontSize: 12.sp,
                                              height: 1.33),
                                    ),
                                    Spacer(),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(AppAssets.visaSvg),
                                        SizedBox(width: 5.w),
                                        SvgPicture.asset(
                                            AppAssets.masterCardSvg),
                                        SizedBox(width: 5.w),
                                        SvgPicture.asset(AppAssets.maestroSvg),
                                        SizedBox(width: 5.w),
                                        SvgPicture.asset(
                                            AppAssets.americanExpressSvg),
                                        SizedBox(width: 5.w),
                                        SvgPicture.asset(AppAssets.applePaySvg),
                                        SizedBox(width: 5.w),
                                        SvgPicture.asset(
                                            AppAssets.googlePaySvg),
                                      ],
                                    ),
                                    SizedBox(width: 30.w)
                                  ],
                                )),
                          ),
                        ),
                  (widget.fromPalceOrder)
                      ? SizedBox.shrink()
                      : SizedBox(
                          height: 12,
                        ),
                  !(_paymentMethod == "Crypto") && widget.fromPalceOrder
                      ? SizedBox.shrink()
                      : InkWell(
                          onTap: () {
                            if (widget.fromPalceOrder ||
                                widget.fromSuccessOrder) {
                              return;
                            }
                            if (_paymentMethod == "Crypto") {
                              widget.paymentMethod.value = "";
                            } else {
                              widget.paymentMethod.value = "Crypto";
                            }
                          },
                          child: Container(
                              height: 38,
                              width: 1.sw,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: widget.fromPalceOrder
                                        ? Color(0xffC4C2C2)
                                        : _paymentMethod == "Crypto"
                                            ? Color(0xff388CFF)
                                            : Color(0xffF8F8F8)),
                                color: Color(0xffF8F8F8),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(width: 29.w),
                                  SvgPicture.asset(AppAssets.cryptoSvg,
                                      color: _paymentMethod == "Crypto" &&
                                              !widget.fromSuccessOrder
                                          ? Color(0xff1D1D1D)
                                          : null),
                                  SizedBox(width: 10.w),
                                  Text(
                                    "${LocaleKeys.Crypto.tr()}",
                                    style: context.textTheme.bodyMedium?.rr
                                        .copyWith(
                                            color: _paymentMethod == "Crypto"
                                                ? Color(0xff1D1D1D)
                                                : Color(0xffC4C2C2),
                                            letterSpacing: 0.18,
                                            fontSize: 12,
                                            height: 1.33),
                                  ),
                                  Spacer(),
                                  Row(
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
                                  ),
                                  SizedBox(width: 30.w)
                                ],
                              )),
                        ),
                ],
              ),
            );
          }),
      (widget.fromPalceOrder)
          ? SizedBox.shrink()
          : SizedBox(
              height: 25,
            ),
      (widget.fromPalceOrder)
          ? SizedBox.shrink()
          : ValueListenableBuilder<bool>(
              valueListenable: isExpandedCoupon,
              builder: (context, expandedCoupon, _) {
                return ValueListenableBuilder<bool>(
                    valueListenable: isApplayCoupon,
                    builder: (context, applayCoupon, _) {
                      return AnimatedContainer(
                        duration: Duration(seconds: 2),
                        curve: Curves.easeInOut,
                        child: InkWell(
                          onTap: () => isExpandedCoupon.value = !expandedCoupon,
                          child: Container(
                              height: expandedCoupon ? 117 : 50,
                              width: 1.sw,
                              padding: EdgeInsets.all(10.h),
                              decoration: BoxDecoration(
                                  color: expandedCoupon
                                      ? Color(0xffFFFFFF)
                                      : Color(0xffF8F8F8),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                      color: !expandedCoupon
                                          ? Color(0xffFFFFFF)
                                          : Color(0xff388CFF))),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SvgPicture.asset(
                                            AppAssets.paymentMethodSvg),
                                        SizedBox(width: 10.w),
                                        Text(
                                          "${LocaleKeys.i_have_discount_coupon.tr()} ",
                                          style: context
                                              .textTheme.bodyMedium?.rr
                                              .copyWith(
                                                  color:
                                                      const Color(0xff1D1D1D),
                                                  letterSpacing: 0.18,
                                                  fontSize: 14,
                                                  height: 1.33),
                                        ),
                                      ],
                                    ),
                                    !expandedCoupon
                                        ? SizedBox.shrink()
                                        : SizedBox(
                                            height: 5,
                                          ),
                                    !expandedCoupon
                                        ? SizedBox.shrink()
                                        : Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 27),
                                            child: Text(
                                              applayCoupon
                                                  ? "${LocaleKeys.applied_your_coupon.tr()} XXXSSSA "
                                                  : "${LocaleKeys.please_enter_coupon_information.tr()} ",
                                              style: context
                                                  .textTheme.bodyMedium?.rr
                                                  .copyWith(
                                                      color: const Color(
                                                          0xff8D8D8D),
                                                      letterSpacing: 0.18,
                                                      fontSize: 12,
                                                      height: LanguageService
                                                                  .languageCode ==
                                                              "ar"
                                                          ? 0.8
                                                          : 1.33),
                                            ),
                                          ),
                                    !expandedCoupon
                                        ? SizedBox.shrink()
                                        : SizedBox(
                                            height: 10,
                                          ),
                                    !expandedCoupon
                                        ? SizedBox.shrink()
                                        : applayCoupon
                                            ? Container(
                                                alignment: Alignment.center,
                                                height: 40,
                                                width: 1.sw,
                                                padding: EdgeInsets.all(10.h),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    border: Border.all(
                                                        color:
                                                            Color(0xff388CFF))),
                                                child: Text(
                                                  "- 100 USD ",
                                                  textAlign: TextAlign.center,
                                                  style: context
                                                      .textTheme.bodyMedium?.br
                                                      .copyWith(
                                                          color: const Color(
                                                              0xff1D1D1D),
                                                          letterSpacing: 0.18,
                                                          fontSize: 14,
                                                          height: 1.33),
                                                ))
                                            : Container(
                                                height: 40,
                                                width: 1.sw,
                                                decoration: BoxDecoration(
                                                  color: Color(0xffF8F8F8),
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    SizedBox(width: 29.w),
                                                    SvgPicture.asset(AppAssets
                                                        .trydosWalletSvg),
                                                    SizedBox(width: 10.w),
                                                    Text(
                                                      "${LocaleKeys.coupon_no.tr()}",
                                                      style: context.textTheme
                                                          .bodyMedium?.rr
                                                          .copyWith(
                                                              color: const Color(
                                                                  0xffC4C2C2),
                                                              letterSpacing:
                                                                  0.18,
                                                              fontSize: 12,
                                                              height: 1.33),
                                                    ),
                                                    Spacer(),
                                                    InkWell(
                                                      onTap: () =>
                                                          isApplayCoupon.value =
                                                              !applayCoupon,
                                                      child: Container(
                                                          width: 100.w,
                                                          padding:
                                                              EdgeInsets.all(
                                                                  10),
                                                          alignment:
                                                              Alignment.center,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15),
                                                              border: Border.all(
                                                                  color: Color(
                                                                      0xff388CFF))),
                                                          child: Text(
                                                            "${LocaleKeys.apply.tr()} ",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: context
                                                                .textTheme
                                                                .bodyMedium
                                                                ?.rr
                                                                .copyWith(
                                                                    color: const Color(
                                                                        0xff1D1D1D),
                                                                    letterSpacing:
                                                                        0.18,
                                                                    fontSize:
                                                                        14,
                                                                    height: 1),
                                                          )),
                                                    )
                                                  ],
                                                ))
                                  ])),
                        ),
                      );
                    });
              },
            ),
    ]);
  }
}
