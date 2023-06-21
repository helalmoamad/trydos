
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';

import '../../../../../app_bloc/app_bloc.dart';
import '../../../../../app_bloc/app_event.dart';
import '../../../../../core/utils/responsive_padding.dart';

class ImageMessage extends StatelessWidget {
  const ImageMessage({Key? key ,this.isForwarded=false, required this.isSent,required this.messageId,required this.isFirstMessage}) : super(key: key);
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
          BlocProvider.of<AppBloc>(context).add(RefreshChatInputField(true, 'image',isSent));
        },
        child: Row(
          mainAxisAlignment:
          isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Stack(
              alignment:isSent ?  Alignment.centerRight : Alignment.centerLeft,
              children: [
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      width: 300.w,
                      height: 600,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image:  AssetImage(AppAssets.chatImageJpg),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(width: 3.0, color: isSent ? const Color(0xffEBFFF8) : const Color(0xffB4FFD9),),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0,-3),
                      child: Container(
                        height: 50,
                        width: 300.w-6,
                        decoration: BoxDecoration(
                          gradient: const  LinearGradient(
                            begin:  Alignment(0.0, 0),
                            end:  Alignment(0.0, 1.0),
                            colors:  [ Color(0x00000000),  Color(0xb2000000)],
                            stops:  [0.0, 1.0],
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child:  Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            children: [
                              Text('20:14',
                                style: context.textTheme.overline?.rr.copyWith(
                                    color: const Color(0xff505050)
                                ),
                              ),
                              if(isSent)...{
                                10.horizontalSpace,
                                SvgPicture.asset(
                                  AppAssets.messageReadArrowSvg, width: 10.sp,
                                  height: 10.sp,)
                              },
                              if(isForwarded)...{
                                10.horizontalSpace,
                                SvgPicture.asset(
                                  AppAssets.forwardedSvg, width: 10.sp,
                                  height: 10.sp,)
                              }
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                isFirstMessage
                    ? Transform.translate(
                  offset: Offset(isSent ? 15.w : -15.w, 0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Stack(
                        alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
                        children: [
                          Container(
                            width: 40.w,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xffEBFFF8),
                              border: Border.all(width: 3.0, color: isSent ? const Color(0xffEBFFF8) : const Color(0xffB4FFD9),),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          Container(
                            width: 20.w,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xffEBFFF8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ],
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
          ],
        ),
      ),
    );
  }
}
