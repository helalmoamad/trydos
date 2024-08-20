import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import '../../../app/app_elvated_button.dart';
import '../../../app/app_widgets/trydos_app_bar/app_bar_params.dart';
import '../../../app/feed_back_app_bar/humy_appbar.dart';

class RequestAndResponseDetailsLayout extends StatelessWidget {
  const RequestAndResponseDetailsLayout({Key? key, required this.data})
      : super(key: key);
  final Map<String, dynamic> data;
  static String routeName = 'RequestAndResponseDetailsLayout';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(65.0.h),
          child: FeedBackAppBar(
            appBarParams: AppBarParams(
              centerTitle: true,
              title: 'request details',
              hasLeading: true,
            ),
          )),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(8.0.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SelectableText.rich(
                    data.containsKey('flutter_error')
                        ? TextSpan(children: <TextSpan>[
                            TextSpan(
                                text: 'Error Details: ',
                                style: titleStyle(context)),
                            TextSpan(
                                text: data['flutter_error'] + '\n',
                                style: bodyStyle(context)),
                          ])
                        : TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                  text: 'URL: ', style: titleStyle(context)),
                              TextSpan(
                                  text: data['url'] + '\n',
                                  style: bodyStyle(context)),
                              TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                      text: 'Request: ',
                                      style: titleStyle(context)),
                                  TextSpan(
                                      text: data['request'].toString() + '\n',
                                      style: bodyStyle(context)),
                                ],
                              ),
                              if(data['response_time']!=null)
                              TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                      text: 'Response Time: ',
                                      style: titleStyle(context)),
                                  TextSpan(
                                      text: data['response_time'].toString() + '\n',
                                      style: bodyStyle(context)),
                                ],
                              ),
                              TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                      text: 'Header: ',
                                      style: titleStyle(context)),
                                  TextSpan(
                                      text: '${data['headers'].toString()}\n',
                                      style: bodyStyle(context)),
                                ],
                              ),
                              if (data['query'] != null) ...{
                                TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: 'query: ',
                                        style: titleStyle(context)),
                                    TextSpan(
                                        text: '${data['query'].toString()}\n',
                                        style: bodyStyle(context)),
                                  ],
                                ),
                              },
                              if (data['body'] != null) ...{
                                TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: 'body: ',
                                        style: titleStyle(context)),
                                    TextSpan(
                                        text: '${data['body']}\n',
                                        style: bodyStyle(context)),
                                  ],
                                ),
                              },
                              TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                      text: 'Response: ',
                                      style: titleStyle(context)),
                                  TextSpan(
                                      text: '${data['response'].toString()}\n',
                                      style: bodyStyle(context)),
                                ],
                              ),
                            ],
                          ),
                    toolbarOptions: const ToolbarOptions(
                      copy: true,
                      selectAll: false,
                    ),
                  ),
                  40.verticalSpace
                ],
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(0, -20.h),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.0.w),
                child: AppElevatedButton(
                    text: 'Share',
                    onPressed: () async {
                      String text = "";
                      data.forEach((key, value) {
                        if (value != null) {
                          text += ('${key.toUpperCase()}: $value');
                          text += '\n';
                        }
                      });
                      log(text);
                      await Share.share(text);
                    }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle titleStyle(BuildContext context) =>
      context.textTheme.bodyMedium!.copyWith(
          fontWeight: FontWeight.w700, color: context.colorScheme.tertiary);

  TextStyle bodyStyle(BuildContext context) =>
      context.textTheme.bodyMedium!.copyWith(
        fontWeight: FontWeight.w400,
      );
}
