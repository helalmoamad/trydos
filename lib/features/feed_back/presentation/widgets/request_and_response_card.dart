import 'dart:developer';

import 'package:easy_localization/easy_localization.dart' as localization;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';

import '../../../app/app_elvated_button.dart';
import '../../../app/titled_text_widget.dart';
import '../pages/requestAndResponseDetailsLayout.dart';

class RequestAndResponseCard extends StatelessWidget {
  const RequestAndResponseCard({Key? key, required this.data})
      : super(key: key);
  final Map<String, dynamic> data;
  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        margin: EdgeInsets.all(12.sp),
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          color: context.colorScheme.background,
          border: Border.all(color: context.colorScheme.tertiary),
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              10.verticalSpace,
              if(data.containsKey('flutter_error'))...{
                Expanded(
                    child: TitledTextWidget(
                      title: 'Flutter Error: ',
                      body: data['flutter_error'].toString(),
                    )),
              }
              else ...{
                Expanded(
                    child: TitledTextWidget(
                      title: 'URL: ',
                      body: data['url'].toString(),
                      maxLines: 2,
                    )),
                4.verticalSpace,
                Expanded(
                    child: TitledTextWidget(
                      title: 'Request: ',
                      body: data['request'].toString(),
                    )),
                if (data['response_time'] != null) ...{
                  4.verticalSpace,
                  Expanded(
                      child: TitledTextWidget(
                        title: 'Response Time: ',
                        body: data['response_time'].toString(),
                      )),
                },
                4.verticalSpace,
                Expanded(
                    child: TitledTextWidget(
                      title: 'Header: ',
                      body: data['headers'].toString(),
                      maxLines: 2,
                    )),
                if (data['query'] != null) ...{
                  4.verticalSpace,
                  Expanded(
                      child: TitledTextWidget(
                        title: 'query: ',
                        body: data['query'].toString(),
                      )),
                },
                if (data['body'] != null) ...{
                  4.verticalSpace,
                  Expanded(
                      child: TitledTextWidget(
                        title: 'body: ',
                        body: data['body'].toString(),
                      )),
                },
                4.verticalSpace,
                Expanded(
                  child: TitledTextWidget(
                    title: 'Response: ',
                    body: data['response'].toString(),
                    maxLines: 2,
                  ),
                ),
              },
                8.verticalSpace,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: 0.4.sw,
                        child: AppElevatedButton(
                            text: 'share',
                            onPressed: () async {
                              String text = "";
                              data.forEach((key, value) {
                                if (value != null) {
                                  text += ('${key.toUpperCase().toString()}: $value');
                                  text += '\n';
                                }
                              });
                              log(text);
                              await Share.share(text);
                            })),
                    15.horizontalSpace,
                    SizedBox(
                        width: 0.4.sw,
                        child: AppElevatedButton(
                          text: 'show details',
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        RequestAndResponseDetailsLayout(
                                          data: data,
                                        )));
                          },
                        )),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}
