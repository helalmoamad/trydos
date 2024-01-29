import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/responsive_padding.dart';

import '../../../../../common/helper/helper_functions.dart';

class CallMessage extends StatelessWidget {
  const CallMessage({Key? key , required this.message, required this.isVideo, required this.time}) : super(key: key);
  final String message;
  final bool isVideo;
  final DateTime time;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: HWEdgeInsets.only(left:  25.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Stack(
            alignment:  Alignment.centerLeft,
            children: [
              Container(
                constraints: const BoxConstraints(
                    minHeight: 50
                ),
                decoration: BoxDecoration(
                    color:  const Color(0xffFFDEDE),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: context.colorScheme.black.withOpacity(0.05),
                          offset: const Offset(0, 3),
                          blurRadius: 6
                      )
                    ]
                ),
                child: Padding(
                  padding: HWEdgeInsets.only(left: 40.w , right: 20.w),
                  child: Center(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(AppAssets.missedCallInChatSvg , width: 20.w , height: 20,),
                        20.horizontalSpace,
                        Text(
                          '$message ${!time.isUtc
                              ? HelperFunctions.getDateInFormat(
                               time)
                              : HelperFunctions
                              .getZonedDateInFormat(
                             time)}',
                          style: context.textTheme.caption?.rr.copyWith(
                              color: const Color(0xff404040),
                              height: 1.66
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
               Transform.translate(
                offset: Offset( -12.w,0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 40.w,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xffEBFFF8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    Container(
                      width: 30.w,
                      height: 30,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image:  AssetImage( AppAssets.chatProfile2Jpg),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow:  [
                          BoxShadow(
                            color:  context.colorScheme.black.withOpacity(0.16),
                            offset: const Offset(0, 3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
