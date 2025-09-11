import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import '../../../../../common/constant/design/assets_provider.dart';
import '../../../../../core/utils/responsive_padding.dart';
import '../../../../app/my_text_widget.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class ProductDetailsSheetHeader extends StatefulWidget {
  final String price;
  final String offerPrice;
  final String priceSymbol;
  final int decimalPoint;
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
    List<String> svg = [
      AppAssets.freeShippingSvg,
      AppAssets.freeReturnSvg,
      AppAssets.arrivalOfShippingSvg,
    ];

    List<String> texts = [
      '${LocaleKeys.free_shipping.tr()}',
      '${LocaleKeys.free_return.tr()}',
      '${LocaleKeys.ship_to_you_accepted.tr()} 2 June',
    ];
    if (widget.shippingCost == 0) {
      texts.remove('${LocaleKeys.free_shipping.tr()}');
      svg.remove(AppAssets.freeShippingSvg);
    }
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
    return ValueListenableBuilder<int>(
        valueListenable: widget.currentActiveTab,
        builder: (context, currentTab, _) {
          return Container(
            decoration: BoxDecoration(
                color: colorScheme.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(30))),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            MyTextWidget(
                              HelperFunctions.formatNumber(
                                  number: double.parse(currentTab == 3
                                      ? widget.price
                                      : widget.initPrice)),
                              //  .toStringAsFixed(widget.decimalPoint),
                              style: textTheme.headlineMedium?.rq.copyWith(
                                color: const Color(0xffC4C2C2),
                                fontSize: 20.sp,
                                decoration: TextDecoration.lineThrough,
                                height: 0,
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            MyTextWidget(
                              HelperFunctions.formatNumber(
                                  number: double.parse(currentTab == 3
                                      ? widget.offerPrice
                                      : widget.initOfferPrice)),
                              //      .toStringAsFixed(widget.decimalPoint),
                              style: textTheme.headlineMedium?.bq.copyWith(
                                fontSize: 20.sp,
                                decoration: widget.isRedeem
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: const Color(0xff505050),
                                height: 0,
                              ),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            widget.isRedeem
                                ? const SizedBox.shrink()
                                : MyTextWidget(
                                    widget.priceSymbol,
                                    style: textTheme.titleMedium?.rq.copyWith(
                                      fontSize: 16.sp,
                                      color: const Color(0xffC4C2C2),
                                      height: 0,
                                    ),
                                  ),
                            const SizedBox(
                              width: 5,
                            ),
                            widget.isRedeem
                                ? MyTextWidget(
                                    HelperFunctions.formatNumber(
                                        number: currentTab == 3
                                            ? widget.redeemVariantPrice
                                            : widget.redeemPrice),
                                    //      .toStringAsFixed(widget.decimalPoint),
                                    style:
                                        textTheme.headlineMedium?.bq.copyWith(
                                      fontSize: 20.sp,
                                      color: Colors.deepOrangeAccent,
                                      height: 0,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                            const SizedBox(
                              width: 5,
                            ),
                            widget.isRedeem
                                ? MyTextWidget(
                                    widget.priceSymbol,
                                    style: textTheme.titleMedium?.rq.copyWith(
                                      fontSize: 16.sp,
                                      color: Colors.deepOrangeAccent,
                                      height: 0,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                            /*    ValueListenableBuilder<int>(
                              valueListenable: widget.addToBagButtonShapeNotifier,
                              builder: (context, itemCount, _) {
                                return itemCount > 1
                                    ? Row(
                                        children: [
                                          MyTextWidget(
                                            'x$itemCount = ${itemCount * 70} ',
                                            style:
                                                textTheme.titleMedium?.bq.copyWith(
                                              color: Color(0xff505050),
                                              height: 0,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          // MyTextWidget(
                                          //   widget.price.split(" ").toList()[1],
                                          //   style: textTheme.titleMedium?.rq.copyWith(
                                          //     color: Color(0xffC4C2C2),
                                          //     height: 0,
                                          //   ),
                                          // ),
                                        ],
                                      )
                                    : const SizedBox.shrink();
                              }),
                          SvgPicture.asset(
                            AppAssets.registerInfoSvg,
                            height: 12,
                            color: Color(0xff8E8E8E),
                          )*/
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Padding(
                              padding: HWEdgeInsets.only(bottom: 8),
                              child: MyTextWidget(
                                '${LocaleKeys.all_inclusive_without_additions.tr()}',
                                style: textTheme.titleMedium?.rq.copyWith(
                                  color: const Color(0xff8D8D8D),
                                  height: 0,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 11,
                            ),
                            Flexible(
                              child: SizedBox(
                                height: 15 + 12.h,
                                child: ListView.builder(
                                  controller: _scrollController,
                                  padding: HWEdgeInsets.only(bottom: 12),
                                  itemBuilder: (
                                    BuildContext context,
                                    int index,
                                  ) {
                                    return Row(
                                      children: [
                                        SvgPicture.asset(
                                          svg[index],
                                          height: 15,
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        MyTextWidget(
                                          texts[index],
                                          style: textTheme.titleMedium?.rq
                                              .copyWith(
                                            color: const Color(0xff8D8D8D),
                                            height: 0,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        )
                                      ],
                                    );
                                  },
                                  scrollDirection: Axis.horizontal,
                                  itemCount: svg.length,
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
}
