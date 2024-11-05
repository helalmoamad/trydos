import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/my_text_widget.dart';

import '../../../../../core/utils/responsive_padding.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../../../../service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../../../service/firebase_analytics_service/analytics_const/analytics_executed_event_name.dart';
import '../../../../../service/firebase_analytics_service/firebase_analytics_service.dart';

class ProductDetailsDescriptionWidget extends StatefulWidget {
  final String description;
  ProductDetailsDescriptionWidget({
    super.key,
    required this.description,
  });

  @override
  State<ProductDetailsDescriptionWidget> createState() =>
      _ProductDetailsDescriptionWidgetState();
}

class _ProductDetailsDescriptionWidgetState
    extends State<ProductDetailsDescriptionWidget> {
  final ValueNotifier<bool> readMoreNotifier = ValueNotifier(true);

  String text = "";
  String twoLines = '';
  bool readMores = true;

  @override
  void initState() {
    text = HtmlParser.parseHTML(widget.description).text;
    int index = 4 * ((1.sw.w - 40) ~/ 13.sp) - 12;

    if (text.length - 5 < index) {
      twoLines = text;
      readMores = false;
    } else {
      while (text[index] != ' ' && index > 0) {
        index--;
      }
      twoLines = text.substring(0, index + 1);
      text = text.substring(0, text.length);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: readMoreNotifier,
        builder: (context, readMore, child) {
          return Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.0),
              child: Column(
                children: [
                  Html(
                    shrinkWrap: true,
                    data: text,
                    style: {
                      "body": Style(margin: Margins.all(0)),
                      "p": Style(
                        maxLines: readMore ? 2 : 12,
                        margin: Margins.all(0),
                      ),
                    },
                  ),
                  RichText(
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(children: [
                        readMores
                            ? TextSpan(
                                text: !readMore
                                    ? LocaleKeys.read_less.tr()
                                    : LocaleKeys.read_more.tr(),
                                style: context.textTheme.titleLarge?.rq
                                    .copyWith(
                                        height: 1.23,
                                        color: Color(0xff388CFF),
                                        fontSize: 13),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    readMoreNotifier.value =
                                        !readMoreNotifier.value;
                                    if (!readMoreNotifier.value) {
                                      FirebaseAnalyticsService
                                          .logEventForSession(
                                        eventName:
                                            AnalyticsEventsConst.buttonClicked,
                                        executedEventName:
                                            AnalyticsExecutedEventNameConst
                                                .readMoreButton,
                                      );
                                    } else {
                                      FirebaseAnalyticsService
                                          .logEventForSession(
                                        eventName:
                                            AnalyticsEventsConst.buttonClicked,
                                        executedEventName:
                                            AnalyticsExecutedEventNameConst
                                                .readLessButton,
                                      );
                                    }
                                  },
                              )
                            : TextSpan(
                                text: " ",
                              )
                      ]))
                ],
              )

              /*     RichText(
                maxLines: readMore ? 2 : 12,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(children: [
                  TextSpan(
                    text: readMore ? twoLines : text,
                    style: context.textTheme.titleLarge?.rq.copyWith(
                        height: 1.23, color: Color(0xff8D8D8D), fontSize: 13),
                  ),
                  readMores
                      ? TextSpan(
                          text: !readMore ? "Read Less..." : "Read More...",
                          style: context.textTheme.titleLarge?.rq.copyWith(
                              height: 1.23,
                              color: Color(0xff388CFF),
                              fontSize: 13),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              readMoreNotifier.value = !readMoreNotifier.value;
                            })
                      : TextSpan(
                          text: "",
                        )
                ]))*/
              );
        });
  }
}
