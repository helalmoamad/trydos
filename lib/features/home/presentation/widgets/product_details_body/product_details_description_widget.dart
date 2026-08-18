import 'package:easy_localization/easy_localization.dart' as tran;
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as productListingModel;

import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_buttons_event_name.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_events.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import 'package:trydos/service/firebase_analytics_service/firebase_analytics_service.dart';

class ProductDetailsDescriptionWidget extends StatefulWidget {
  final String description;
  final productListingModel.Products productItem;
  const ProductDetailsDescriptionWidget({
    super.key,
    required this.productItem,
    required this.description,
  });

  @override
  State<ProductDetailsDescriptionWidget> createState() =>
      _ProductDetailsDescriptionWidgetState();
}

class _ProductDetailsDescriptionWidgetState
    extends State<ProductDetailsDescriptionWidget> {
  final ValueNotifier<bool> isExpandedNotifier = ValueNotifier(false);
  bool needsExpansion = false;
  late String plainText;

  @override
  void initState() {
    plainText = html_parser.parse(widget.description).body?.text ?? '';
    super.initState();
  }

  bool _checkTextOverflow(double maxWidth) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: plainText,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 11.sp,
          height: 1.5,
          color: const Color(0xff1D1D1D),
        ),
      ),
      maxLines: 2,
      textDirection: TextDirection.rtl,
    );

    textPainter.layout(maxWidth: maxWidth);
    return textPainter.didExceedMaxLines;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: LayoutBuilder(
        builder: (context, constraints) {
          needsExpansion = _checkTextOverflow(constraints.maxWidth);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Html(
                data: widget.description,
                style: {
                  "*": Style(
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                    fontSize: FontSize(11.sp),
                    color: const Color(0xff1D1D1D),
                    lineHeight: const LineHeight(1.5),
                    maxLines: isExpandedNotifier.value ? null : 2,
                    textOverflow: isExpandedNotifier.value
                        ? null
                        : TextOverflow.ellipsis,
                  ),
                },
              ),
              if (needsExpansion)
                GestureDetector(
                  onTap: () {
                    FirebaseAnalyticsService.logEventForSession(
                      executedEventName: AnalyticsButtonsEventNameConst
                          .READ_MORE_ABOUT_PRODUCT_BUTTON,
                      eventName: AnalyticsEventsConst.READ_MORE,
                      extraParams: {
                        'item_id': widget.productItem.productId.toString(),
                        'item_name': widget.productItem.name.toString(),
                        'price': widget.productItem.price.toString(),
                        'brand': widget.productItem.brand == null
                            ? ""
                            : widget.productItem.brand!.name.toString(),
                        'category': widget.productItem.categories!
                            .map((e) => e.id.toString())
                            .toList()
                            .toString(),
                        'count_likes': widget.productItem.countOfLikes
                            .toString(),
                        'review_count': widget.productItem.reviewsCount
                            .toString(),
                        'screen_name': GlobalScreenConst.PRODUCT_SCREEN,
                      },
                    );
                    isExpandedNotifier.value = !isExpandedNotifier.value;
                    setState(() {});
                  },
                  child: Text(
                    isExpandedNotifier.value
                        ? "${LocaleKeys.read_less.tr()}"
                        : "${LocaleKeys.read_more.tr()}",
                    style: TextStyle(
                      color: const Color(0xff388CFF),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
