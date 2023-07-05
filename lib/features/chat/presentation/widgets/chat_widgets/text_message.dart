import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/responsive_padding.dart';
import 'package:trydos/core/utils/theme_state.dart';

import '../../../../app/blocs/app_bloc/app_bloc.dart';
import '../../../../app/blocs/app_bloc/app_event.dart';

class TextMessage extends StatefulWidget {
  const TextMessage({ Key? key ,this.withShadow=true,this.withImageShadow=true ,this.isForwarded=false ,this.sendColor,this.receivedColor, required this.message, required this.messageId, required this.isSent, required this.isFirstMessage}) : super(key: key);
  final String message;
  final String messageId;
  final bool isSent;
  final bool isFirstMessage;
  final bool isForwarded;
  final Color? sendColor;
  final Color? receivedColor;
  final bool withShadow;
  final bool withImageShadow;

  @override
  State<TextMessage> createState() => _TextMessageState();
}

class _TextMessageState extends ThemeState<TextMessage> {

  double height=-1;
  final key = GlobalKey();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final RenderBox renderBox =
      key.currentContext!.findRenderObject() as RenderBox;
      height = renderBox.size.height;
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      key: key,
      children: [
        Padding(
          padding: HWEdgeInsets.only(right: widget.isSent ? 25.w : 0 , left: widget.isSent ? 0 : 25.w),
          child: SwipeTo(
            iconSize: 0,
            animationDuration: const Duration(milliseconds: 100),
            offsetDx: 0.15,
            onRightSwipe: () {
              BlocProvider.of<AppBloc>(context).add(RefreshChatInputField(true, 'text',widget.isSent));
            },
            child: Row(
              mainAxisAlignment: widget.isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                Stack(
                  alignment: widget.isSent ?  Alignment.centerRight : Alignment.centerLeft,
                  children: [
                    Container(
                      constraints: const BoxConstraints(
                        minHeight: 48
                      ),
                      decoration: BoxDecoration(
                          color: widget.isSent ? (widget.sendColor ?? const Color(0xffFFF9B4) ): (widget.receivedColor ?? const Color(0xffB4FED9)),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: widget.withShadow ? [
                            BoxShadow(
                                color: colorScheme.black.withOpacity(0.05),
                                offset: const Offset(0, 3),
                                blurRadius: 6
                            )
                          ]:null
                      ),
                      child: Padding(
                        padding: HWEdgeInsets.only(left: widget.isSent ? 20.w : height<60 ? 50.w : 40.w,top: 10,right: widget.isSent ? height<60 ? 50.w : 40.w : 20.w),
                        child: Column(
                          crossAxisAlignment: widget.isSent ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                          children: [
                            Container(
                              constraints: BoxConstraints(maxWidth: 310.w),
                              child: Text(
                                widget.message,
                                style: textTheme.bodyText2?.rr.copyWith(
                                    color:widget.withImageShadow ?  const Color(0xff505050) :  const Color(0xffC4C2C2),
                                  height: 1.43
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                children: [
                                  Text('20:14',
                                    style: textTheme.overline?.rr.copyWith(
                                        color: widget.withImageShadow ? const Color(0xff505050) : const Color(0xffC4C2C2)
                                    ),
                                  ),
                                  if(widget.isSent)...{
                                    10.horizontalSpace,
                                    SvgPicture.asset(
                                      widget.withImageShadow ? AppAssets.messageReadArrowSvg : AppAssets.messageReadArrowWithOpacitySvg, width: 10.sp,
                                      height: 10.sp,)
                                  },
                                  if(widget.isForwarded)...{
                                    10.horizontalSpace,
                                    SvgPicture.asset(
                                      AppAssets.forwardedSvg, width: 10.sp,
                                      height: 10.sp,)
                                  }
                                ],
                              ),
                            ),
                            widget.withImageShadow ? const SizedBox.shrink() : 20.verticalSpace,
                          ],
                        ),
                      ),
                    ),
                    widget.isFirstMessage ? Transform.translate(
                      offset: Offset(widget.isSent ? ( widget.withImageShadow ? height< 60 ?  10 :20 : 15) : ( widget.withImageShadow ? height< 60 ? -10 : -20 : -15),widget.withImageShadow ? 0: -10),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: widget.withImageShadow ? 40 : 30,
                            height: widget.withImageShadow ? 40 : 30,
                            decoration: BoxDecoration(
                              color: const Color(0xffEBFFF8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          Container(
                            width: widget.withImageShadow ? 30 : 20,
                            height: widget.withImageShadow ? 30 : 20,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image:  AssetImage(widget.isSent ? AppAssets.chatProfileJpg : AppAssets.chatProfile2Jpg),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                              boxShadow: widget.withImageShadow ? [
                                BoxShadow(
                                  color:  colorScheme.black.withOpacity(0.16),
                                  offset: const Offset(0, 3),
                                  blurRadius: 6,
                                ),
                              ]: null,
                            ),
                          )
                        ],
                      ),
                    ):const SizedBox.shrink()
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );

  }
}
