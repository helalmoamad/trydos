import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import '../../../../../common/constant/design/assets_provider.dart';
import '../../../../../core/utils/responsive_padding.dart';
import '../../../../app/my_text_widget.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';

class CartDetailsSheetHeader extends StatefulWidget {
  final double shippingCost;
  const CartDetailsSheetHeader({
    required this.shippingCost,
    super.key,
  });

  @override
  State<CartDetailsSheetHeader> createState() => _CartDetailsSheetHeaderState();
}

class _CartDetailsSheetHeaderState extends State<CartDetailsSheetHeader> {
  List<String> svg = [
    AppAssets.arrivalOfShippingSvg,
    AppAssets.freeShippingSvg,
    AppAssets.freeReturnSvg,
    AppAssets.deliveryGuranteeSvg,
    AppAssets.returnGuranteeSvg,
    AppAssets.securePrivacySvg,
    AppAssets.safeEasySvg,
    AppAssets.purchaseSvg,
    AppAssets.earnMoneySvg,
  ];

  List<String> texts = [
    '${LocaleKeys.delivery.tr()}',
    '${LocaleKeys.free_shipping.tr()}',
    '${LocaleKeys.free_return.tr()}',
    '${LocaleKeys.delivery_guarantee.tr()}',
    '${LocaleKeys.return_guarantee.tr()}',
    '${LocaleKeys.secure_privacy.tr()}',
    '${LocaleKeys.safe_easy_payment.tr()}',
    '${LocaleKeys.purchase_protection.tr()}',
    '${LocaleKeys.earn_money_with_this_order.tr()}',
  ];
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
    if (widget.shippingCost == 0) {
      texts.remove('${LocaleKeys.free_shipping.tr()}');
      svg.remove(AppAssets.freeShippingSvg);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          color: colorScheme.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
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
                        index == 0
                            ? MyTextWidget(
                                '2 June',
                                style: textTheme.titleMedium?.ba.copyWith(
                                    color: const Color(0xff505050),
                                    height: 0,
                                    fontSize: 11),
                              )
                            : MyTextWidget(
                                texts[index],
                                style: textTheme.titleMedium?.rq.copyWith(
                                    color: const Color(0xff505050),
                                    height: 0,
                                    fontSize: 11),
                              ),
                        const SizedBox(
                          width: 10,
                        )
                      ],
                    );
                  },
                  scrollDirection: Axis.horizontal,
                  itemCount: texts.length,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
