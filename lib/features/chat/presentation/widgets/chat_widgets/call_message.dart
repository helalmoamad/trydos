import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/responsive_padding.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import '../../../../../common/helper/helper_functions.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../../../app/app_widgets/loading_indicator/trydos_loader.dart';
import '../../../../app/my_cached_network_image.dart';
import '../../../../app/my_text_widget.dart';
import '../../../../calls/presentation/widgets/no_image_widget.dart';

class CallMessage extends StatelessWidget {
  const CallMessage({
    Key? key,
    this.userMessagePhoto,
    required this.message,
    required this.userMessageName,
    required this.isVideo,
    required this.time,
    required this.isSent,
    required this.durationInSeconds,
    required this.isMessageForMe,
  }) : super(key: key);
  final String message;
  final bool isVideo;
  final bool isSent;
  final int durationInSeconds;
  final bool isMessageForMe;
  final DateTime time;
  final String? userMessagePhoto;
  final String userMessageName;

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Padding(
        padding: HWEdgeInsets.only(
          right: isSent ? 25.w : 0,
          left: isSent ? 0 : 25.w,
        ),
        child: Row(
          mainAxisAlignment: isSent
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Stack(
              alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
              children: [
                Container(
                  constraints: const BoxConstraints(minHeight: 50),
                  decoration: BoxDecoration(
                    color: const Color(0xffFFDEDE),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: context.colorScheme.black.withOpacity(0.05),
                        offset: const Offset(0, 3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: HWEdgeInsets.only(
                      left: isSent ? 20.w : 40.w,
                      right: isSent ? 40.w : 20.w,
                    ),
                    child: Center(
                      child: Directionality(
                        textDirection: ui.TextDirection.ltr,
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              isVideo
                                  ? AppAssets.missedVideoCallInChatSvg
                                  : AppAssets.missedCallInChatSvg,
                              width: 20.w,
                              height: 20,
                            ),
                            10.horizontalSpace,
                            MyTextWidget(
                              '${durationInSeconds == 0 ? LocaleKeys.missed_call.tr() : (isMessageForMe == false ? LocaleKeys.income.tr() : LocaleKeys.Outcome.tr())}${durationInSeconds > 0 ? ' ${HelperFunctions.getTimeInFormat(Duration(seconds: durationInSeconds))}' : ''} , $message  ${!time.isUtc ? HelperFunctions.getDateInFormat(time) : HelperFunctions.getZonedDateInFormat(time)}',
                              style: context.textTheme.titleMedium?.rq.copyWith(
                                color: const Color(0xff404040),
                                height: 1.66,
                              ),
                              textDirection: ui.TextDirection.ltr,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(!isSent ? -10.w : 10.w, 0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 40.w,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xffEBFFF8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      userMessagePhoto != null
                          ? MyCachedNetworkImage(
                              imageUrl: userMessagePhoto!,
                              progressIndicatorBuilderWidget: TrydosLoader(),
                              imageFit: BoxFit.cover,
                              radius: 8,
                              width: 30.w,
                              height: 30,
                            )
                          : NoImageWidget(
                              width: 30.w,
                              height: 30,
                              textStyle: context.textTheme.titleMedium?.bq
                                  .copyWith(
                                    color: const Color(0xff6638FF),
                                    letterSpacing: 0.18,
                                    height: 1.33,
                                  ),
                              radius: 8,
                              name: userMessageName,
                            ),
                    ],
                  ),
                ),
                // Transform.translate(
                //   offset: Offset(-12.w, 0),
                //   child: Stack(
                //     alignment: Alignment.center,
                //     children: [
                //       Container(
                //         width: 40.w,
                //         height: 40,
                //         decoration: BoxDecoration(
                //           color: const Color(0xffEBFFF8),
                //           borderRadius: BorderRadius.circular(8),
                //         ),
                //       ),
                //       Container(
                //         width: 30.w,
                //         height: 30,
                //         decoration: BoxDecoration(
                //           image: DecorationImage(
                //             image: AssetImage(AppAssets.chatProfile2Jpg),
                //             fit: BoxFit.cover,
                //           ),
                //           borderRadius: BorderRadius.circular(8.0),
                //           boxShadow: [
                //             BoxShadow(
                //               color: context.colorScheme.black.withOpacity(0.16),
                //               offset: const Offset(0, 3),
                //               blurRadius: 6,
                //             ),
                //           ],
                //         ),
                //       )
                //     ],
                //   ),
                // )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
