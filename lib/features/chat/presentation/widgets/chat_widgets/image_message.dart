import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import '../../../../../core/utils/responsive_padding.dart';
import '../../../../app/blocs/app_bloc/app_bloc.dart';
import '../../../../app/blocs/app_bloc/app_event.dart';

class ImageMessage extends StatelessWidget {
  const ImageMessage(
      {Key? key,
      this.isForwarded = false,
      this.isLocalMessage = true,
      required this.isSent,
      required this.time,
      required this.isRead,
      required this.senderId,
       this.imageFile,
       this.imageUrl,
      required this.messageId,
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
  final int senderId;
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
                BlocProvider.of<AppBloc>(context).add(RefreshChatInputField(true, 'image', isSent,senderParentMessageId:senderId  , imageUrl: imageUrl,messageId: messageId,time: time,message: 'Photo'));
              },
              child: Row(
                mainAxisAlignment:
                    isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  Stack(
                    alignment:
                        isSent ? Alignment.centerRight : Alignment.centerLeft,
                    children: [
                      Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Container(
                            width: 300.w,
                            height: 600,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: isLocalMessage ? FileImage(imageFile!) : (NetworkImage(Urls.baseUrl+imageUrl!) as ImageProvider),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                width: 3.0,
                                color: isSent
                                    ? const Color(0xffFFF9B4)
                                    : const Color(0xffB4FFD9),
                              ),
                            ),
                          ),
                          Transform.translate(
                            offset: const Offset(0, -3),
                            child: Container(
                              height: 50,
                              width: 300.w - 6,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment(0.0, 0),
                                  end: Alignment(0.0, 1.0),
                                  colors: [
                                    Color(0x00000000),
                                    Color(0xb2000000)
                                  ],
                                  stops: [0.0, 1.0],
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5,horizontal: 20),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      !time.isUtc ? HelperFunctions.getDateInFormat(time) : HelperFunctions.getZonedDateInFormat(time),
                                      style: context.textTheme.overline?.rr
                                          .copyWith(
                                              color: context.colorScheme.white),
                                    ),
                                    if (isSent) ...{
                                      10.horizontalSpace,
                                      SvgPicture.asset(
                                        (state.sendMessageStatus ==
                                                    SendMessageStatus.loading &&
                                                state.currentMessage.contains(messageId))
                                            ? AppAssets.sandClockSvg
                                            : isRead ? AppAssets.messageReadArrowSvg
                                            :AppAssets
                                            .messageSentArrowSvg,
                                        color: context.colorScheme.white,
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
        },
      ),
    );
  }
}
