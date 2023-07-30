import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import '../../../../../core/utils/responsive_padding.dart';
import '../../../../app/blocs/app_bloc/app_bloc.dart';
import '../../../../app/blocs/app_bloc/app_event.dart';
import '../../../../app/my_cached_network_image.dart';
import 'no_image_widget.dart';

class DocumentMessage extends StatelessWidget {
  const DocumentMessage(
      {Key? key,
        this.isForwarded = false,
        this.isLocalMessage = true,
        required this.isSent,
        required this.time,
        required this.isRead,
        required this.senderId,
        this.userMessagePhoto,
        this.imageFile,
        this.imageUrl,
        required this.userMessageName,
        required this.fileName,
        required this.messageId,
        required this.isReceived,
        required this.isFirstMessage})
      : super(key: key);
  final bool isSent;
  final bool isFirstMessage;
  final bool isForwarded;
  final String messageId;
  final File? imageFile;
  final bool isLocalMessage;
  final String? imageUrl;
  final DateTime time;
  final bool isRead;
  final bool isReceived;
  final int senderId;
  final String? userMessagePhoto;
  final String userMessageName;
  final String fileName;
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          // TODO: implement listener
        },
        builder: (context, state) {
          return Padding(
            padding: HWEdgeInsets.only(
                right: isSent ? 25.w : 0, left: isSent ? 0 : 25.w),
            child: SwipeTo(
              iconSize: 0,
              animationDuration: const Duration(milliseconds: 100),
              offsetDx: 0.15,
              onRightSwipe: () {
                print(time);
                BlocProvider.of<AppBloc>(context).add(RefreshChatInputField(true, 'image', isSent,senderParentMessageId:senderId , imageUrl: imageUrl ?? imageFile!.path,messageId: messageId,time: time,message: 'Photo'));
              },
              child: Row(
                mainAxisAlignment:
                isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  Stack(
                    alignment:
                    isSent ? Alignment.centerRight : Alignment.centerLeft,
                    children: [
                      Container(
                        constraints:  const BoxConstraints(minHeight:  48 ),
                        decoration: BoxDecoration(
                            color: isSent
                                ?
                                const Color(0xffFFF9B4)
                                :
                                const Color(0xffB4FED9),
                            borderRadius: BorderRadius.circular(20),
                           ),
                        child: Padding(
                          padding: HWEdgeInsets.only(
                              left: isSent
                                  ? 20.w
                                  : 40.w,
                              top: 10,
                              right: isSent ? 40.w
                                  : 20.w),
                          child: IntrinsicWidth(
                            child: Column(
                              crossAxisAlignment: isSent
                                  ? CrossAxisAlignment.start
                                  : CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    SvgPicture.asset(AppAssets.documentSvg , width: 25 , height: 25,),
                                    10.horizontalSpace,
                                    Container(
                                      constraints: BoxConstraints(maxWidth: 310.w),
                                      child: Text(
                                        fileName,
                                        style: context.textTheme.bodyText2?.rr.copyWith(
                                            color: const Color(0xffC4C2C2),
                                            height: 1.43),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5),
                                  child: Row(
                                    children: [
                                      Text(
                                        !time.isUtc
                                            ? HelperFunctions.getDateInFormat(
                                            time)
                                            : HelperFunctions
                                            .getZonedDateInFormat(
                                           time),
                                        style: context.textTheme.overline?.rr
                                            .copyWith(
                                            color: const Color(0xffC4C2C2)),
                                      ),
                                      if (isSent) ...{
                                        10.horizontalSpace,
                                        SvgPicture.asset(
                                          (state.sendMessageStatus ==
                                              SendMessageStatus
                                                  .loading &&
                                              state.currentMessage
                                                  .contains(
                                                  messageId))
                                              ? AppAssets.sandClockSvg :
                                               isRead
                                              ? AppAssets
                                              .messageReadArrowSvg
                                              : isReceived ? AppAssets.messageDeliveredArrowSvg :AppAssets
                                              .messageSentArrowSvg,
                                          width: 10.sp,
                                          height: 10.sp,
                                        )
                                      },
                                      if (isForwarded) ...{
                                        10.horizontalSpace,
                                        SvgPicture.asset(
                                          AppAssets.forwardedSvg,
                                          width: 10.sp,
                                          height: 10.sp,
                                        )
                                      }
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      isFirstMessage
                          ? Transform.translate(
                        offset: Offset(isSent ? 15.w : -15.w, 0),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Stack(
                              alignment: isSent
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              children: [
                                Container(
                                  width: 40.w,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xffEBFFF8),
                                    border: Border.all(
                                      width: 3.0,
                                      color: isSent
                                          ? const Color(0xffFFF9B4)
                                          : const Color(0xffB4FFD9),
                                    ),
                                    borderRadius:
                                    BorderRadius.circular(12),
                                  ),
                                ),
                                Container(
                                  width: 20.w,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xffEBFFF8),
                                    borderRadius:
                                    BorderRadius.circular(8),
                                  ),
                                ),
                              ],
                            ),
                            userMessagePhoto != null
                                ? MyCachedNetworkImage(
                              imageUrl: Urls.baseUrl + userMessagePhoto!,
                              imageFit: BoxFit.cover,
                              radius: 8,
                              width: 30.w,
                              height: 30,
                            )
                                : NoImageWidget(
                                width: 30.w,
                                height: 30,
                                textStyle:context.textTheme.caption?.br.copyWith(
                                    color: const Color(0xff6638FF),
                                    letterSpacing: 0.18,
                                    height: 1.33),
                                radius: 8,
                                name:userMessageName
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
        },
      ),
    );
  }
}
