import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/responsive_padding.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/voice_waves.dart';

import '../../../../../app_bloc/app_bloc.dart';
import '../../../../../app_bloc/app_event.dart';

class VoiceMessage extends StatelessWidget {
  const VoiceMessage(
      {Key? key,
      required this.isSent,
      required this.messageId,
        this.isForwarded=false,
      required this.isFirstMessage})
      : super(key: key);
  final bool isSent;
  final bool isFirstMessage;
  final bool isForwarded;
  final String messageId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          HWEdgeInsets.only(right: isSent ? 25.w : 0, left: isSent ? 0 : 25.w),
      child: SwipeTo(
        iconSize: 0,
        animationDuration: const Duration(milliseconds: 100),
        offsetDx: 0.15,
        onRightSwipe: () {
          BlocProvider.of<AppBloc>(context).add(RefreshChatInputField(true, 'voice',isSent));
        },
        child: Row(
          mainAxisAlignment:
              isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: isSent ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Stack(
                  alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
                  children: [
                    Container(
                      height: 70,
                      width: 365.w,
                      decoration: BoxDecoration(
                          color: isSent
                              ? const Color(0xffFFF9B4)
                              : const Color(0xffB4FED9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                                color: context.colorScheme.black.withOpacity(0.05),
                                offset: const Offset(0, 3),
                                blurRadius: 6)
                          ]),
                      child: Padding(
                        padding: HWEdgeInsets.only(
                            left: isSent ? 20.w : 27.w,
                            top: 4,
                            right: isSent ? 27.w : 20.w),
                        child: Column(
                          crossAxisAlignment: isSent
                              ? CrossAxisAlignment.start
                              : CrossAxisAlignment.end,
                          children: [
                            SizedBox(
                                height: 41,
                                width: 318.w,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (isSent) ...{
                                      SvgPicture.asset(
                                        AppAssets.pauseSvg,
                                        width: 20.sp,
                                        height: 20.sp,
                                      ),
                                      26.horizontalSpace,
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                              width: 47.w,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                                border: Border.all(
                                                    width: 0.4,
                                                    color: const Color(0xff388cff)),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '01:20',
                                                  style: context.textTheme.overline?.rt
                                                      .copyWith(
                                                          color:
                                                              const Color(0xff404040),
                                                          height: 1.4),
                                                  textAlign: TextAlign.center,
                                                ),
                                              )),
                                          1.verticalSpace,
                                          SizedBox(
                                            height: 20,
                                            width: 220.w,
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                SvgPicture.string(
                                                  '<svg viewBox="117.0 1976.5 220.0 1.0" ><path transform="translate(117.0, 1976.5)" d="M 0 0 L 220 0" fill="none" stroke="#707070" stroke-width="1" stroke-miterlimit="4" stroke-linecap="round" /></svg>',
                                                  allowDrawingOutsideViewBox: true,
                                                  fit: BoxFit.fill,
                                                ),
                                                const VoiceWaves()
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                      16.horizontalSpace,
                                      SvgPicture.asset(
                                        AppAssets.voicePlayedSvg,
                                        width: 25.w,
                                        height: 28,
                                      )
                                    } else ...{
                                      Transform(
                                          alignment: Alignment.center,
                                          transform:
                                              Matrix4.diagonal3Values(1.0, -1.0, 1.0),
                                          child: SvgPicture.asset(
                                            AppAssets.voicePlayedSvg,
                                            width: 25.w,
                                            height: 28,
                                          )),
                                      15.horizontalSpace,
                                      SvgPicture.asset(
                                        AppAssets.playSvg,
                                        width: 20.sp,
                                        height: 20.sp,
                                      ),
                                      26.horizontalSpace,
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                              width: 47.w,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.circular(15.0),
                                                border: Border.all(
                                                    width: 0.4,
                                                    color: const Color(0xff388cff)),
                                              ),
                                              child: Text(
                                                '01:20',
                                                style: context.textTheme.overline?.rt
                                                    .copyWith(
                                                    color:
                                                    const Color(0xff404040),
                                                    height: 1.4),
                                                textAlign: TextAlign.center,
                                              )),
                                          1.verticalSpace,
                                          SizedBox(
                                            height: 20,
                                            width: 220,
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                SvgPicture.string(
                                                  '<svg viewBox="117.0 1976.5 220.0 1.0" ><path transform="translate(117.0, 1976.5)" d="M 0 0 L 220 0" fill="none" stroke="#707070" stroke-width="1" stroke-miterlimit="4" stroke-linecap="round" /></svg>',
                                                  allowDrawingOutsideViewBox: true,
                                                  fit: BoxFit.fill,
                                                ),
                                                const VoiceWaves()
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    }
                                  ],
                                )),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                children: [
                                  Text(
                                    '20:14',
                                    style: context.textTheme.overline?.rr
                                        .copyWith(color: const Color(0xff505050)),
                                  ),
                                  if (isSent) ...{
                                    10.horizontalSpace,
                                    SvgPicture.asset(
                                      AppAssets.messageReadArrowSvg,
                                      width: 10.sp,
                                      height: 10.sp,
                                    )
                                  },
                                  if(isForwarded)...{
                                    10.horizontalSpace,
                                    SvgPicture.asset(
                                      AppAssets.forwardedSvg, width: 10.sp,
                                      height: 10.sp,)
                                  }
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    isFirstMessage
                        ? Transform.translate(
                            offset: Offset(isSent ? 20.w : -20.w, 0),
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
                                Container(
                                  width: 30.w,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(isSent
                                          ? AppAssets.chatProfileJpg
                                          : AppAssets.chatProfile2Jpg),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: context.colorScheme.black
                                            .withOpacity(0.16),
                                        offset: const Offset(0, 3),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        : const SizedBox.shrink()
                  ],
                ),
                7.verticalSpace,
                Container(
                  decoration: BoxDecoration(
                    color: isSent ? const Color(0xffFFF9B4):const Color(0xffcefde6),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: HWEdgeInsets.symmetric(horizontal: 16 , vertical: 5),
                  child: Center(
                    child: Text('Forwarded Message' , style: context.textTheme.overline?.rr.copyWith(
                      color: const Color(0xff505050),
                      height: 1.4
                    )),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
