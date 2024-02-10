import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/common/constant/design/assets_provider.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/responsive_padding.dart';
import 'package:trydos/core/utils/theme_state.dart';

import '../../../app/my_text_widget.dart';
import '../pages/create_call_page.dart';

class CallsCard extends StatefulWidget {
  const CallsCard(
      {Key? key, this.index = 0, this.isMissing = false, this.isIncome = false})
      : super(key: key);
  final bool isMissing;
  final bool isIncome;
  final int index;

  @override
  State<CallsCard> createState() => _CallsCardState();
}

class _CallsCardState extends ThemeState<CallsCard> {
  ValueNotifier<int> typingIndicator = ValueNotifier(0);

  @override
  void initState() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (typingIndicator.value == 5) {
        typingIndicator.value = 0;
      } else {
        typingIndicator.value++;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    typingIndicator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min, children: [
      Container(
        height: widget.index == 0 ? 0 : 0.4,
        color: const Color(0xffC8C7CC),
        margin: HWEdgeInsetsDirectional.only(start: 94),
      ),
      InkWell(
        onTap: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>  const CreateCallPage(fullReceiverName: 'Mahmoud',receiverName: 'MA', chatId: '',)));
        },
        child: Container(
            height: 75,
            width: 1.sw,
            padding: HWEdgeInsets.only(left: 15.w, right: 30.w, top: 8),
            color: widget.isMissing ? const Color(0xFFFFFCFC) : colorScheme.white,
            child: Row(children: [
              Container(
                height: 55,
                width: 55.w,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppAssets.profileJpg),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                      width: 1.0,
                      color: widget.isMissing
                          ? const Color(0xffff5f61)
                          : widget.isIncome
                              ? const Color(0xff388CFF)
                              : const Color(0xffFFC05C)),
                ),
              ),
              24.horizontalSpace,
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center, children: [
                      Row(
                        children: [
                          MyTextWidget(
                            'Grant Marshall',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.subtitle1?.rr
                                .copyWith(color: const Color(0xff505050)),
                          ),
                          30.horizontalSpace
                        ],
                      ),
                      10.verticalSpace,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            widget.isMissing
                                ? AppAssets.callMissingSvg
                                : widget.isIncome
                                    ? AppAssets.callIncomeSvg
                                    : AppAssets.callOutgoingSvg,
                            height: 15.sp,
                            width: 15.sp,
                          ),
                          10.horizontalSpace,
                          MyTextWidget(
                            widget.isMissing
                                ? 'Missed Call'
                                : widget.isIncome
                                    ? 'Income'
                                    : 'Outgoing',
                            maxLines: 1,
                            style: textTheme.bodyText2?.lr.copyWith(
                                color: Color(
                                    widget.isMissing ? 0xffFF5F61 : 0xff8E8D92)),
                          ),
                        ],
                      ),
                    ]),
                    const Spacer(),
                    MyTextWidget(
                      '01:58',
                      maxLines: 1,
                      style: textTheme.caption?.rr
                          .copyWith(color: const Color(0xff8E8D92)),
                    ),
                  ],
                ),
              )
            ])),
      )
    ]);
  }
}

class SlidableActionWidget extends StatelessWidget {
  const SlidableActionWidget(
      {Key? key,
      required this.backgroundColor,
      required this.foregroundColor,
      required this.iconUrl,
      required this.text})
      : super(key: key);
  final Color backgroundColor;
  final Color foregroundColor;
  final String iconUrl;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 85.w,
      height: 92,
      margin: HWEdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(width: 0.5, color: const Color(0xffd3d3d3)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              iconUrl,
              width: 25.h,
              height: 25.h,
            ),
            8.verticalSpace,
            MyTextWidget(
              text,
              style: context.textTheme.caption?.rr
                  .copyWith(color: foregroundColor),
            )
          ],
        ),
      ),
    );
  }
}
