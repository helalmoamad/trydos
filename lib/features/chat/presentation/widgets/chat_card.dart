import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/constant/design/assets_provider.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/responsive_padding.dart';
import 'package:trydos/core/utils/theme_state.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/chat/presentation/pages/single_page_chat.dart';

import '../../../../common/helper/helper_functions.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../data/models/my_chats_response_model.dart';

class ChatCard extends StatefulWidget {
  const ChatCard(
      {Key? key, this.index = 0, this.isTyping = false, required this.chat})
      : super(key: key);
  final bool isTyping;
  final int index;
  final Chat chat;

  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends ThemeState<ChatCard> {
  ValueNotifier<int> typingIndicator = ValueNotifier(0);
  late Timer timer;
  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();
  late DateTime chatTime;

  @override
  void initState() {
    chatTime = widget.chat.messages!.first.createdAt!;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
    timer.cancel();
    typingIndicator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String receiverName = widget.chat.channelMembers!
        .firstWhere((element) => element.userId != _prefsRepository.myId)
        .user!
        .name
        .toString();
    return BlocConsumer<ChatBloc, ChatState>(
  listener: (context, state) {
    // TODO: implement listener
  },
  builder: (context, state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: widget.index == 0 ? 0 : 0.4,
          color: const Color(0xffC8C7CC),
          margin: HWEdgeInsetsDirectional.only(start: 94),
        ),
        SizedBox(
          height: 100.h,
          width: 1.sw,
          child: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BlocBuilder<ChatBloc, ChatState>(
                            builder: (context, state) {
                              return SinglePageChat(
                                messages: state.messages[widget.chat.id] ?? [],
                                receiverName: receiverName,
                              );
                            },
                          )));
            },
            child: Slidable(
              endActionPane: ActionPane(
                extentRatio: 0.645,
                motion: const ScrollMotion(),
                children: [
                  SlidableActionWidget(
                    text: 'Archive',
                    backgroundColor: const Color(0xffF0F0F0),
                    foregroundColor: colorScheme.grey200,
                    iconUrl: AppAssets.archiveSvg,
                  ),
                  SlidableActionWidget(
                    text: 'Delete',
                    backgroundColor: const Color(0xffFFE8E8),
                    foregroundColor: const Color(0xffFA6868),
                    iconUrl: AppAssets.binSvg,
                  ),
                  SlidableActionWidget(
                    text: 'Mute',
                    backgroundColor: const Color(0xffF6F5FD),
                    foregroundColor: const Color(0xffC4C2C2),
                    iconUrl: AppAssets.muteSvg,
                  ),
                ],
              ),

              // The end action pane is the one at the right or the bottom side.
              startActionPane: ActionPane(
                extentRatio: 0.43,
                motion: const ScrollMotion(),
                children: [
                  SlidableActionWidget(
                    text: 'Unread',
                    backgroundColor: const Color(0xffFCF6EF),
                    foregroundColor: colorScheme.grey200,
                    iconUrl: AppAssets.unreadSvg,
                  ),
                  SlidableActionWidget(
                    text: 'Pin',
                    backgroundColor: const Color(0xffEFF8FF),
                    foregroundColor: colorScheme.grey200,
                    iconUrl: AppAssets.pinSvg,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Container(
                    padding: HWEdgeInsets.only(left: 15.w, right: 10.w),
                    color: colorScheme.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 60.w,
                          height: 80.h,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(AppAssets.chatProfileJpg),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: widget.isTyping
                                ? [
                                    BoxShadow(
                                        color: const Color(0xff007CFF)
                                            .withOpacity(0.16),
                                        offset: const Offset(0, 3),
                                        blurRadius: 6)
                                  ]
                                : null,
                            border: widget.isTyping
                                ? Border.all(
                                    color: const Color(0xff007CFF), width: 1)
                                : null,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        18.horizontalSpace,
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Row(
                                  children: [
                                    Text(
                                      receiverName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.subtitle1?.rr.copyWith(
                                          height: 1.33,
                                          color: const Color(0xff505050)),
                                    ),
                                    const Spacer(),
                                    BlocConsumer<ChatBloc, ChatState>(
                                      listener: (context, state) {
                                        if (widget
                                                .chat.messages![0].channelId ==
                                            state.channelId) {
                                          chatTime = DateTime.now();
                                        }
                                      },
                                      builder: (context, state) {
                                        return Text(
                                          !chatTime.isUtc
                                              ? HelperFunctions.getDateInFormat(
                                                  chatTime)
                                              : HelperFunctions
                                                  .getZonedDateInFormat(
                                                      chatTime),
                                          maxLines: 1,
                                          style: textTheme.caption?.rr.copyWith(
                                              height: 1.33,
                                              color: const Color(0xff8E8D92)),
                                        );
                                      },
                                    ),
                                    30.horizontalSpace
                                  ],
                                ),
                              ),
                              7.verticalSpace,
                              Flexible(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (widget.isTyping) ...{
                                      Transform.translate(
                                        offset: const Offset(0, 3),
                                        child: SvgPicture.asset(
                                          AppAssets.messageReadArrowSvg,
                                          height: 12.h,
                                          width: 12.w,
                                        ),
                                      ),
                                      7.horizontalSpace,
                                    },
                                    Flexible(
                                      fit: FlexFit.tight,
                                      child: SizedBox(
                                        height: widget.isTyping ? 33 : 51,
                                        child: Text(
                                          state.messages[widget.chat.id]!.first
                                                      .mediaMessageContent !=
                                                  null
                                              ? 'Photo'
                                              :  state.messages[widget.chat.id]!.first
                                                  .messageContent!.content
                                                  .toString(),
                                          maxLines: widget.isTyping ? 1 : 3,
                                          textAlign: TextAlign.start,
                                          overflow: TextOverflow.ellipsis,
                                          style: textTheme.bodyText2?.lr
                                              .copyWith(
                                                  height: 1.22,
                                                  color: colorScheme.grey200),
                                        ),
                                      ),
                                    ),
                                    28.horizontalSpace,
                                    Row(
                                      children: [
                                        if (widget.isTyping) ...{
                                          SvgPicture.asset(
                                            AppAssets.singleChatFilledActiveSvg,
                                            height: 15.h,
                                            width: 15.w,
                                          ),
                                          10.horizontalSpace,
                                          Text(
                                            '1',
                                            maxLines: 1,
                                            style: textTheme.caption?.rr
                                                .copyWith(
                                                    color: const Color(
                                                        0xff007CFF)),
                                          ),
                                        },
                                        25.horizontalSpace,
                                        SvgPicture.asset(
                                          AppAssets.forwardArrowRight,
                                          width: 3.w,
                                          height: 12.h,
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              if (widget.isTyping) ...{
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Typing',
                                      maxLines: 1,
                                      style: textTheme.caption?.rr.copyWith(
                                          color: const Color(0xff007CFF)),
                                    ),
                                    8.horizontalSpace,
                                    Transform.translate(
                                      offset: const Offset(0, 1),
                                      child: ValueListenableBuilder<int>(
                                          valueListenable: typingIndicator,
                                          builder: (context, activeIndex, _) {
                                            return SizedBox(
                                              width: 50.w,
                                              height: 5.h,
                                              child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: List.generate(
                                                      6,
                                                      (index) => Container(
                                                            width: 5,
                                                            height: 5,
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: activeIndex ==
                                                                      index
                                                                  ? const Color(
                                                                      0xff007cff)
                                                                  : colorScheme
                                                                      .white,
                                                              border: Border.all(
                                                                  width: 1.0,
                                                                  color: const Color(
                                                                      0xff007cff)),
                                                            ),
                                                          ))),
                                            );
                                          }),
                                    )
                                  ],
                                )
                              },
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Positioned(
                    right: 10.sp,
                    bottom: 10.sp,
                    child: SvgPicture.asset(
                      AppAssets.pinSvg,
                      width: 20.w,
                      height: 20.h,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  },
);
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
      height: 92.h,
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
            )
          ],
        ),
      ),
    );
  }
}
