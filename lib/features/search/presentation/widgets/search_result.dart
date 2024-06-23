import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/my_text_widget.dart';

import '../../../../core/utils/theme_state.dart';

class SearchResult extends StatefulWidget {
  const SearchResult({super.key});

  @override
  State<SearchResult> createState() => _SearchResultState();
}

class _SearchResultState extends ThemeState<SearchResult> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 20.0),
            child: MyTextWidget(
              'find Product',
              style: textTheme.caption?.rq
                  .copyWith(height: 15 / 12, color: Color(0xff505050)),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          ScrollConfiguration(
            behavior: CupertinoScrollBehavior(),
            child: ListView.separated(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 10),
              itemBuilder: (ctx, index) => Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                      height: 50,
                      width: 1.sw,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          color: Color(0xffF8F8F8),
                          borderRadius: BorderRadius.circular(15)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 35,
                          ),
                          Flexible(
                            child: MyTextWidget(
                              'Deort Fitted Dress In Knit Fabric With A High Neck And Shortslev Deort Fitted Dress In Knit Fabric With A High Neck And Shortslev',
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: context.textTheme.bodyText2?.lq.copyWith(
                                  height: 15 / 12, color: Color(0xffC4C2C2)),
                            ),
                          ),
                          SizedBox(width: 8),
                        ],
                      )),
                  Container(
                    height: 50,
                    width: 35,
                    decoration: BoxDecoration(
                        border:
                            Border.all(color: Color(0xff388CFF), width: 0.3),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(5),
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(5),
                        ),
                        image: DecorationImage(
                            image: AssetImage('assets/images/details.jpg'))),
                  )
                ],
              ),
              itemCount: 7,
              separatorBuilder: (ctx, index) => SizedBox(
                height: 5,
              ),
            ),
          )
        ],
      ),
    );
  }
}
