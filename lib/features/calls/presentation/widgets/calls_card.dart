import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:trydos/common/constant/configuration/chat_url_routes.dart';
import 'package:trydos/common/constant/design/assets_provider.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/responsive_padding.dart';
import 'package:trydos/core/utils/theme_state.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/calls/presentation/bloc/calls_bloc.dart';

import 'package:trydos/features/calls/presentation/widgets/no_image_widget.dart';
import 'package:trydos/features/chat/presentation/pages/calls_page_content.dart';

import '../pages/create_call_page.dart';

class CallsCard extends StatefulWidget {
  const CallsCard({
    Key? key,
    this.index = 0,
    this.isMissing = false,
    this.isIncome = false,
    required this.createAt,
    required this.fullname,
    required this.photopath,
    required this.chatId,
    required this.duration,
    required this.messageType,
    required this.callRegId,
  }) : super(key: key);
  final String photopath;
  final String fullname;
  final int duration;
  final String chatId;
  final String callRegId;

  final bool isMissing;
  final String messageType;
  final bool isIncome;

  final int index;
  final DateTime? createAt;

  @override
  State<CallsCard> createState() => _CallsCardState();
}

class _CallsCardState extends ThemeState<CallsCard> {
  late CallsBloc callsBloc;
  ValueNotifier<int> typingIndicator = ValueNotifier(0);

  @override
  void initState() {
    callsBloc = BlocProvider.of<CallsBloc>(context);

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
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        height: widget.index == 0 ? 0 : 0.4,
        color: const Color(0xffC8C7CC),
        margin: HWEdgeInsetsDirectional.only(start: 94),
      ),
      InkWell(
        onLongPress: () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
              actions: [
                ElevatedButton(
                    onPressed: () {
                      callsBloc
                          .add(DeleteCallRegEvent(callId: widget.callRegId));
                      Navigator.pop(context);
                    },
                    child: Text("نعم")),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("إغلاق"))
              ],
              title: Column(
                children: [
                  Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  Text("هل أنت متأكد من الحذف ؟")
                ],
              )),
        ),
        onTap: () {},
        child: Container(
            height: 75,
            width: 1.sw,
            padding: HWEdgeInsets.only(left: 15.w, right: 30.w, top: 8),
            color:
                widget.isMissing ? const Color(0xFFFFFCFC) : colorScheme.white,
            child: Row(children: [
              Container(
                height: 55,
                width: 55.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                      width: 1.0,
                      color: widget.isMissing
                          ? const Color(0xffff5f61)
                          : widget.isIncome
                              ? const Color(0xff388CFF)
                              : const Color(0xffFFC05C)),
                ),
                child: widget.photopath != ""
                    ? Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              width: 1.0, color: const Color(0xff388cff)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x29388cff),
                              offset: Offset(0, 3),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: MyCachedNetworkImage(
                          imageUrl: ChatUrls.baseUrl + widget.photopath,
                          imageFit: BoxFit.cover,
                          progressIndicatorBuilderWidget: TrydosLoader(),
                          height: 40,
                          width: 40.w,
                        ),
                      )
                    : NoImageWidget(
                        height: 40,
                        width: 40.w,
                        textStyle: context.textTheme.subtitle1?.br.copyWith(
                            color: const Color(0xff6638FF),
                            letterSpacing: 0.18,
                            height: 1.33),
                        name: HelperFunctions.getTheFirstTwoLettersOfName(
                            widget.fullname)),
              ),
              24.horizontalSpace,
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.fullname,
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
                              Text(
                                widget.isMissing
                                    ? 'Missed Call'
                                    : widget.isIncome
                                        ? 'Income'
                                        : 'Outgoing',
                                maxLines: 1,
                                style: textTheme.bodyText2?.lr.copyWith(
                                    color: Color(widget.isMissing
                                        ? 0xffFF5F61
                                        : 0xff8E8D92)),
                              ),
                            ],
                          ),
                        ]),
                    const Spacer(),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              HelperFunctions.replaceArabicNumber(
                                  HelperFunctions.getDatesInFormat(
                                          widget.createAt!)
                                      .toString()),
                              maxLines: 1,
                              style: textTheme.bodySmall?.rr
                                  .copyWith(color: const Color(0xff8E8D92)),
                            ),
                            Text(
                              " ، ",
                              maxLines: 1,
                              style: textTheme.bodySmall?.rr.copyWith(
                                  color: const Color(0xff8E8D92), fontSize: 20),
                            ),
                            Text(
                              HelperFunctions.replaceArabicNumber(
                                !widget.createAt!.isUtc
                                    ? HelperFunctions.gettimesInFormat(
                                            widget.createAt!)
                                        .toString()
                                    : HelperFunctions.gettimesInFormat(
                                            widget.createAt!)
                                        .toString(),
                              ),
                              maxLines: 2,
                              style: textTheme.bodySmall?.rr
                                  .copyWith(color: const Color(0xff8E8D92)),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              widget.duration != 0 ? "المدة : " : "",
                              style: TextStyle(color: Color(0xff8E8D92)),
                            ),
                            Text(
                              fromSecond(widget.duration),
                              maxLines: 1,
                              style: textTheme.bodySmall?.rr
                                  .copyWith(color: const Color(0xff8E8D92)),
                            ),
                          ],
                        ),
                      ],
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
            Text(
              text,
              style: context.textTheme.caption?.rr
                  .copyWith(color: foregroundColor),
            ),
          ],
        ),
      ),
    );
  }
}

String formatDate(DateTime dateStr) {
  DateTime now = DateTime.now();
  Duration difference = now.difference(dateStr);

  if (difference.inDays == 0) {
    return 'اليوم';
  } else if (difference.inDays == 1) {
    return 'أمس';
  } else {
    return HelperFunctions.getDatesInFormat(dateStr);
  }
}

/*class Counter {
  int callDuration = 0;
  bool isRunning = false;
  Timer? timer;
  void startCounter() {
    if (!isRunning) {
      isRunning = true;
      callDuration = 0;
      timer = Timer.periodic(Duration(seconds: 1), (timer) {
        callDuration++;
      });
    }
  }

  void stopCounter() {
    if (!isRunning) {
      isRunning = false;
      callDuration = 0;

      timer?.cancel();
    }
  }
}*/
String fromSecond(int second) {
  if (second == 0) {
    return "";
  }
  int hours = (second ~/ 3600);
  String minutes = ((second % 3600) ~/ 60) < 10
      ? ((second % 3600) ~/ 60).toString().padLeft(2, "0")
      : ((second % 3600) ~/ 60).toString();
  String seconds = (second % 60) < 10
      ? (second % 60).toString().padLeft(2, "0")
      : (second % 60).toString();
  if (hours == 0) {
    return "${minutes}:${seconds}";
  }
  return "${hours}:${minutes}:${seconds}";
}
