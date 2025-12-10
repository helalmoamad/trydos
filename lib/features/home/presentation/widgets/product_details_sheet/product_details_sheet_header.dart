import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/features/home/data/models/get_cart_item_model.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import '../../../../../common/constant/design/assets_provider.dart';
import '../../../../app/my_text_widget.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';

class ProductDetailsSheetHeader extends StatefulWidget {
  final String price;
  final String offerPrice;
  final String priceSymbol;
  final int? productId;
  final String? currentVariant;
  final double decimalPoint;
  final ValueNotifier<int> currentActiveTab;
  final bool isRedeem;
  final double redeemPrice;
  final String initPrice;
  final double redeemVariantPrice;
  final String initOfferPrice;
  final double shippingCost;
  const ProductDetailsSheetHeader({
    super.key,
    required this.shippingCost,
    this.productId,
    this.currentVariant,
    required this.addToBagButtonShapeNotifier,
    required this.offerPrice,
    required this.currentActiveTab,
    required this.price,
    required this.initOfferPrice,
    required this.initPrice,
    required this.redeemVariantPrice,
    required this.isRedeem,
    required this.redeemPrice,
    required this.decimalPoint,
    required this.priceSymbol,
  });

  final ValueNotifier<int> addToBagButtonShapeNotifier;

  @override
  State<ProductDetailsSheetHeader> createState() =>
      _ProductDetailsSheetHeaderState();
}

class _ProductDetailsSheetHeaderState extends State<ProductDetailsSheetHeader> {
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  Timer? _recallForAutoScroll;
  double _scrollOffset = 0.0;
  final double _scrollSpeed = 0.25;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _startAutoScroll();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _stopAutoScroll();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection ==
            ScrollDirection.reverse ||
        _scrollController.position.userScrollDirection ==
            ScrollDirection.forward) {
      _stopAutoScroll();
      _recallForAutoScroll?.cancel();
      _recallForAutoScroll = Timer(const Duration(seconds: 2), () {
        _startAutoScroll();
      });
    }
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      setState(() {
        _scrollOffset += _scrollSpeed;
        if (_scrollOffset >= _scrollController.position.maxScrollExtent) {
          _scrollOffset = 0.0;
        }
        _scrollController.jumpTo(_scrollOffset);
      });
    });
  }

  void _stopAutoScroll() {
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    List<String> svg = [
      AppAssets.freeShippingSvg,
      AppAssets.freeReturnSvg,
      AppAssets.arrivalOfShippingSvg,
    ];

    List<String> texts = [
      LocaleKeys.all_inclusive_without_additions.tr(),
      LocaleKeys.free_shipping.tr(),
      LocaleKeys.free_return.tr(),
      '${LocaleKeys.ship_to_you_accepted.tr()} 2 June',
    ];

    return ValueListenableBuilder<int>(
      valueListenable: widget.currentActiveTab,
      builder: (context, currentTab, _) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: BlocBuilder<HomeBloc, HomeState>(
            buildWhen: (previous, current) =>
                previous.updateItemInCartStatus !=
                    current.updateItemInCartStatus ||
                previous.addItemInCartStatus != current.addItemInCartStatus ||
                previous.deleteItemInCartStatus !=
                    current.deleteItemInCartStatus ||
                previous.getCartItemsStatus != current.getCartItemsStatus,
            builder: (context, state) {
              if (widget.shippingCost == 0) {
                texts.remove('${LocaleKeys.free_shipping.tr()}');
                svg.remove(AppAssets.freeShippingSvg);
              }

              double offPriceInCart =
                  state.cartCollection?.firstWhere((element) {
                    if (element.variations?.isNullOrEmpty ?? true) {
                      return (element.productId == widget.productId);
                    }
                    return (element.productId == widget.productId &&
                        ('${element.variations![0].colorOption ?? ""}${(((element.variations![0].colorOption ?? "") != "") && ((element.variations![0].sizeOption ?? "") != "")) ? "-" : ""}${element.variations![0].sizeOption ?? ""}') ==
                            widget.currentVariant);
                  }, orElse: () => Cart(id: 0, offerPrice: 0)).offerPrice ??
                  0;

              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  width: 1.sw,
                  height: 40.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 20.w),
                      (currentTab == 3
                                  ? ((offPriceInCart > 0 &&
                                            (!(widget.isRedeem)))
                                        ? (HelperFunctions.truncateToDecimalPlaces(
                                                    offPriceInCart,
                                                    state
                                                        .getCurrencyForCountryModel!
                                                        .data!
                                                        .currency!
                                                        .decimalDigits!,
                                                  ) *
                                                  state
                                                      .getCurrencyForCountryModel!
                                                      .data!
                                                      .currency!
                                                      .exchangeRate!)
                                              .toString()
                                        : widget.offerPrice)
                                  : widget.initOfferPrice) ==
                              (currentTab == 3
                                  ? widget.price
                                  : widget.initPrice)
                          ? const SizedBox.shrink()
                          : MyTextWidget(
                              HelperFunctions.formatNumber(
                                number: double.parse(
                                  currentTab == 3
                                      ? widget.price
                                      : widget.initPrice,
                                ),
                              ),
                              //  .toStringAsFixed(widget.decimalPoint),
                              style: textTheme.headlineMedium?.rq.copyWith(
                                color: const Color(0xffC4C2C2),
                                fontSize: 16.sp,
                                decoration: TextDecoration.lineThrough,
                                height: 0,
                              ),
                            ),
                      const SizedBox(width: 5),
                      MyTextWidget(
                        HelperFunctions.formatNumber(
                          number: double.parse(
                            currentTab == 3
                                ? ((offPriceInCart > 0 && (!(widget.isRedeem)))
                                      ? (HelperFunctions.truncateToDecimalPlaces(
                                                  offPriceInCart,
                                                  state
                                                      .getCurrencyForCountryModel!
                                                      .data!
                                                      .currency!
                                                      .decimalDigits!,
                                                ) *
                                                state
                                                    .getCurrencyForCountryModel!
                                                    .data!
                                                    .currency!
                                                    .exchangeRate!)
                                            .toString()
                                      : widget.offerPrice)
                                : widget.initOfferPrice,
                          ),
                        ),
                        //      .toStringAsFixed(widget.decimalPoint),
                        style: textTheme.headlineMedium?.bq.copyWith(
                          fontSize: 16.sp,
                          decoration: widget.isRedeem
                              ? TextDecoration.lineThrough
                              : null,
                          color: const Color(0xff505050),
                          height: 0,
                        ),
                      ),
                      const SizedBox(width: 4),
                      widget.isRedeem
                          ? const SizedBox.shrink()
                          : MyTextWidget(
                              widget.priceSymbol,
                              style: textTheme.titleMedium?.rq.copyWith(
                                fontSize: 9.sp,
                                color: const Color(0xffC4C2C2),
                                height: 0,
                              ),
                            ),
                      const SizedBox(width: 5),
                      widget.isRedeem
                          ? MyTextWidget(
                              HelperFunctions.formatNumber(
                                number: currentTab == 3
                                    ? widget.redeemVariantPrice
                                    : widget.redeemPrice,
                              ),
                              //      .toStringAsFixed(widget.decimalPoint),
                              style: textTheme.headlineMedium?.bq.copyWith(
                                fontSize: 16.sp,
                                color: Colors.deepOrangeAccent,
                                height: 0,
                              ),
                            )
                          : const SizedBox.shrink(),
                      widget.isRedeem
                          ? MyTextWidget(
                              widget.priceSymbol,
                              style: textTheme.titleMedium?.rq.copyWith(
                                fontSize: 9.sp,
                                color: Colors.deepOrangeAccent,
                                height: 0,
                              ),
                            )
                          : const SizedBox.shrink(),
                      Column(
                        children: [
                          const SizedBox(height: 5),
                          SvgPicture.asset(
                            AppAssets.chatWithQuestionSvg,
                            height: 11,
                            // ignore: deprecated_member_use
                            color: const Color(0xff5D5C5D),
                          ),
                        ],
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: SizedBox(
                          height: 30,
                          child: ListView.builder(
                            controller: _scrollController,
                            itemBuilder: (BuildContext context, int index) {
                              return Row(
                                children: [
                                  index == 0
                                      ? const SizedBox.shrink()
                                      : SvgPicture.asset(
                                          svg[index - 1],
                                          height: 15,
                                        ),
                                  const SizedBox(width: 5),
                                  MyTextWidget(
                                    texts[index],
                                    style: textTheme.titleMedium?.rq.copyWith(
                                      color: const Color(0xff8D8D8D),
                                      height: 0,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                ],
                              );
                            },
                            scrollDirection: Axis.horizontal,
                            itemCount: texts.length,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
