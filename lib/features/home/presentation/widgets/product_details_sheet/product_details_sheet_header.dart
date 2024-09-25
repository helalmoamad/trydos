import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import '../../../../../common/constant/design/assets_provider.dart';
import '../../../../../core/utils/responsive_padding.dart';
import '../../../../app/my_text_widget.dart';

class ProductDetailsSheetHeader extends StatefulWidget {
  final String price;
  final String offerPrice;
  final String priceSymbol;
  final int decimalPoint;
  const ProductDetailsSheetHeader({
    super.key,
    required this.addToBagButtonShapeNotifier,
    required this.offerPrice,
    required this.decimalPoint,
    required this.priceSymbol,
    required this.price,
  });

  final ValueNotifier<int> addToBagButtonShapeNotifier;

  @override
  State<ProductDetailsSheetHeader> createState() =>
      _ProductDetailsSheetHeaderState();
}

class _ProductDetailsSheetHeaderState extends State<ProductDetailsSheetHeader> {
  List<String> svg = [
    AppAssets.freeShippingSvg,
    AppAssets.freeReturnSvg,
    AppAssets.arrivalOfShippingSvg,
  ];

  List<String> texts = [
    'Free Shipping',
    'Free Return',
    'Ship To You Accepted 2 June',
  ];
  ScrollController _scrollController = ScrollController();
  Timer? _timer;
  Timer? _recallForAutoScroll;
  double _scrollOffset = 0.0;
  double _scrollSpeed = 0.25;

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
      _recallForAutoScroll = Timer(Duration(seconds: 2), () {
        _startAutoScroll();
      });
    }
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(Duration(milliseconds: 50), (_) {
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
    return Container(
      decoration: BoxDecoration(
          color: colorScheme.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 15),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      MyTextWidget(
                        double.parse(widget.price)
                            .toStringAsFixed(widget.decimalPoint),
                        style: textTheme.headlineMedium?.rq.copyWith(
                          color: Color(0xffC4C2C2),
                          decoration: TextDecoration.lineThrough,
                          height: 0,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      MyTextWidget(
                        double.parse(widget.offerPrice)
                            .toStringAsFixed(widget.decimalPoint),
                        style: textTheme.headlineMedium?.bq.copyWith(
                          color: Color(0xff505050),
                          height: 0,
                        ),
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      MyTextWidget(
                        widget.priceSymbol,
                        style: textTheme.titleMedium?.rq.copyWith(
                          fontSize: 18,
                          color: Color(0xffC4C2C2),
                          height: 0,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      ValueListenableBuilder<int>(
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
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: HWEdgeInsets.only(bottom: 12.0),
                        child: MyTextWidget(
                          'All Inclusive Without Additions',
                          style: textTheme.titleMedium?.rq.copyWith(
                            color: Color(0xff8D8D8D),
                            height: 0,
                          ),
                        ),
                      ),
                      SizedBox(
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
                                  SizedBox(
                                    width: 5,
                                  ),
                                  MyTextWidget(
                                    texts[index],
                                    style: textTheme.titleMedium?.rq.copyWith(
                                      color: Color(0xff8D8D8D),
                                      height: 0,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  )
                                ],
                              );
                            },
                            scrollDirection: Axis.horizontal,
                            itemCount: 3,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
