import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/search/presentation/widgets/search_history_chip.dart';

import '../../../../common/constant/design/assets_provider.dart';
import '../../../app/my_text_widget.dart';

class TrendingSection extends StatefulWidget {
  TrendingSection({super.key});

  @override
  State<TrendingSection> createState() => _TrendingSectionState();
}

class _TrendingSectionState extends State<TrendingSection> {
  final ValueNotifier<bool> changeViewMode = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 20.0, start: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueListenableBuilder<bool>(
              valueListenable: changeViewMode,
              builder: (context, value, _) {
                return SizedBox(
                  height: 28,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          changeViewMode.value = !changeViewMode.value;
                        },
                        child: SvgPicture.asset(
                          AppAssets.trendingSvg,
                          width: 20,
                          height: 20,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      if (value) ...{
                        MyTextWidget(
                          'Popular Search',
                          style: context.textTheme.titleLarge?.mq.copyWith(
                              height: 18 / 14, color: Color(0xff505050)),
                        ),
                      } else ...{
                        Expanded(
                            child: ListView.separated(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (ctx, index) => Container(
                                height: 28,
                                padding:
                                    EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                    color: Color(0xffF8F8F8),
                                    borderRadius:
                                        BorderRadius.circular(10)),
                                child: Center(
                                  child: Text(
                                    index % 2 == 0
                                        ? 'Birthday'
                                        : 'Man Pantalon',
                                    style: context.textTheme.titleLarge?.rq
                                        .copyWith(
                                            height: 18 / 14,
                                            color: Color(0xff8D8D8D)),
                                  ),
                                ),
                              ),
                              itemCount: 10,
                              separatorBuilder: (ctx, index) => SizedBox(
                                width: 5,
                              ),
                            ))
                      }
                    ],
                  ),
                );
              }),
          ValueListenableBuilder<bool>(
              valueListenable: changeViewMode,
              builder: (context, value, _) {
                return value
                    ? ScrollConfiguration(
                        behavior: CupertinoScrollBehavior(),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          padding: EdgeInsets.only(top: 15, right: 20),
                          itemBuilder: (ctx, index) => Container(
                            height: 40,
                            width: 1.sw,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                color: Color(0xffF8F8F8),
                                borderRadius: BorderRadius.circular(10)),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  MyTextWidget(
                                    index % 2 == 0
                                        ? 'Birthday'
                                        : 'Man Pantalon',
                                    textAlign: TextAlign.start,
                                    style: context.textTheme.titleLarge?.rq
                                        .copyWith(
                                            height: 18 / 14,
                                            color: Color(0xff8D8D8D)),
                                  ),
                                  Row(
                                    children: [
                                      MyTextWidget(
                                        '100,000',
                                        textAlign: TextAlign.start,
                                        style: context.textTheme.titleSmall?.rq
                                            .copyWith(
                                                height: 1.3,
                                                color: Color(0xff8D8D8D)),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      SvgPicture.asset(
                                        AppAssets.searchOutlinedSvg,
                                        width: 13,
                                        height: 13,
                                        color: Color(0xff388CFF),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                          itemCount: 10,
                          separatorBuilder: (ctx, index) => SizedBox(
                            height: 5,
                          ),
                        ),
                      )
                    : SizedBox.shrink();
              })
        ],
      ),
    );
  }
}
