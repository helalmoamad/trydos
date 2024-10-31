import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/responsive_padding.dart';
import 'package:trydos/core/utils/theme_state.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/chat/presentation/manager/chat_event.dart';
import '../../../../../common/test_utils/widgets_keys.dart';
import '../../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../app/app_widgets/loading_indicator/trydos_loader.dart';
import '../../../../app/blocs/app_bloc/app_bloc.dart';
import '../../../../app/blocs/app_bloc/app_event.dart';
import '../../../../app/my_cached_network_image.dart';
import '../../../../app/my_text_widget.dart';
import '../../manager/chat_state.dart';
import 'no_image_widget.dart';

class TextMessage extends StatefulWidget {
  TextMessage({
    Key? key,
    this.withShadow = true,
    this.withImageShadow = true,
    this.isForwarded = false,
    this.sendColor,
    this.receivedColor,
    this.userMessagePhoto,
    required this.userMessageName,
    this.disableMessageAlignment = false,
    required this.message,
    required this.isRead,
    required this.messageId,
    required this.isSent,
    required this.senderId,
    required this.isReceived,
    required this.isFirstMessage,
    this.isreplay = false,
    this.receivedAt,
    this.createAt,
    this.watchedAt,
    required this.channalId,
    this.index = 0,
  }) : super(key: key);
  final String message;
  final int index;
  final String messageId;
  final bool isSent;
  final bool isFirstMessage;
  final bool isForwarded;
  final String channalId;
  bool isreplay;
  final Color? sendColor;
  final Color? receivedColor;
  final bool withShadow;
  final bool withImageShadow;
  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();

  bool isRead;
  final bool disableMessageAlignment;
  final DateTime? receivedAt;
  final DateTime? createAt;
  final DateTime? watchedAt;
  final int senderId;
  bool isReceived;
  final String? userMessagePhoto;
  final String userMessageName;
  @override
  State<TextMessage> createState() => _TextMessageState();
}

class _TextMessageState extends ThemeState<TextMessage> {
  double height = -1;
  final key = GlobalKey();
  bool timer = false;
  late ChatBloc chatBloc;
  @override
  void initState() {
    chatBloc = BlocProvider.of<ChatBloc>(context);
    Timer(Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          timer = true;
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) {
        final RenderBox renderBox =
            key.currentContext?.findRenderObject() as RenderBox;
        height = renderBox.size.height;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };
    return BlocConsumer<ChatBloc, ChatState>(
      listenWhen: (p, c) =>
          p.changeMessageStateFromPusherStatus !=
              c.changeMessageStateFromPusherStatus &&
          c.changeMessageStateFromPusherStatus !=
              ChangeMessageStateFromPusherStatus.init,
      listener: (context, state) {
        if (state.changeMessageStateFromPusherStatus ==
            ChangeMessageStateFromPusherStatus.watched) {
          if (widget.isRead) {
            return;
          }
          setState(() {
            widget.isRead = true;
          });
        } else if (!widget.isReceived) {
          setState(() {
            widget.isReceived = true;
          });
        }
      },
      builder: (context, state) {
        return Column(
          key: key,
          children: [
            Padding(
              padding: HWEdgeInsets.only(
                  right: (widget.isSent || widget.disableMessageAlignment)
                      ? 25.w
                      : 0,
                  left: (widget.isSent || widget.disableMessageAlignment)
                      ? 0
                      : 25.w),
              child: SwipeTo(
                onLeftSwipe: () {
                  if (widget.senderId == widget._prefsRepository.myChatId) {
                    if ((state.sendMessageStatus == SendMessageStatus.loading &&
                        state.currentMessage.contains(widget.messageId))) {
                      return;
                    }
                    BlocProvider.of<AppBloc>(context).add(RefreshChatInputField(
                        true, 'text', widget.isSent,
                        messageId: widget.messageId,
                        senderParentMessageId: widget.senderId,
                        message: widget.message,
                        time: widget.createAt));
                  } else {}
                },
                iconSize: 0,
                animationDuration: const Duration(milliseconds: 100),
                offsetDx: 0.15,
                onRightSwipe: () {
                  if (widget.senderId == widget._prefsRepository.myChatId) {
                    !widget.isreplay
                        ? BlocProvider.of<ChatBloc>(context)
                            .add(ChangeSlop(messageId: widget.messageId))
                        : {};
                  } else {
                    if ((state.sendMessageStatus == SendMessageStatus.loading &&
                        state.currentMessage.contains(widget.messageId))) {
                      return;
                    }
                    BlocProvider.of<AppBloc>(context).add(RefreshChatInputField(
                        true, 'text', widget.isSent,
                        messageId: widget.messageId,
                        senderParentMessageId: widget.senderId,
                        message: widget.message,
                        time: widget.createAt));
                  }
                },
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    mainAxisAlignment: widget.disableMessageAlignment
                        ? widget.isSent
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.end
                        : widget.isSent
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                    children: [
                      Transform.translate(
                        offset: !(state.isSlpoing &&
                                state.slopMessageId!
                                    .contains(widget.messageId) &&
                                (widget.isReceived || widget.isRead) &&
                                !widget.isreplay)
                            ? Offset(0, 0)
                            : widget.senderId ==
                                    widget._prefsRepository.myChatId
                                ? Offset(50.w, 0)
                                : Offset(0.w, 0),
                        child: Stack(
                          alignment: widget.isSent
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          children: [
                            Container(
                              key: TestVariables.kTestMode
                                  ? Key(
                                      '${WidgetsKey.messageCardKey}${widget.index}')
                                  : null,
                              constraints: BoxConstraints(
                                  minHeight: !widget.withShadow ? 71 : 48),
                              decoration: BoxDecoration(
                                  color: widget.isSent
                                      ? (widget.sendColor ??
                                          const Color(0xffFFF9B4))
                                      : (widget.receivedColor ??
                                          const Color(0xffB4FED9)),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: widget.withShadow
                                      ? [
                                          BoxShadow(
                                              color: colorScheme.black
                                                  .withOpacity(0.05),
                                              offset: const Offset(0, 3),
                                              blurRadius: 6)
                                        ]
                                      : null),
                              child: Padding(
                                padding: HWEdgeInsets.only(
                                    left: (widget.isSent ||
                                            widget.disableMessageAlignment)
                                        ? 20.w
                                        : height < 60
                                            ? 50.w
                                            : 40.w,
                                    top: 10,
                                    right: (widget.isSent ||
                                            widget.disableMessageAlignment)
                                        ? height < 60
                                            ? 50.w
                                            : 40.w
                                        : 20.w),
                                child: IntrinsicWidth(
                                  child: Column(
                                    crossAxisAlignment: widget.isSent
                                        ? CrossAxisAlignment.start
                                        : CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        constraints:
                                            BoxConstraints(maxWidth: 310.w),
                                        child: MyTextWidget(
                                          widget.message,
                                          style: textTheme.titleLarge?.rr
                                              .copyWith(
                                                  color: widget.withImageShadow
                                                      ? const Color(0xff505050)
                                                      : const Color(0xffC4C2C2),
                                                  height: 1.43),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5),
                                        child: Row(
                                          children: [
                                            MyTextWidget(
                                              !widget.createAt!.isUtc
                                                  ? HelperFunctions
                                                      .getDateInFormat(
                                                          widget.createAt!)
                                                  : HelperFunctions
                                                      .getZonedDateInFormat(
                                                          widget.createAt!),
                                              style: textTheme.titleSmall?.rr
                                                  .copyWith(
                                                      color:
                                                          widget.withImageShadow
                                                              ? const Color(
                                                                  0xff505050)
                                                              : const Color(
                                                                  0xffC4C2C2)),
                                            ),
                                            if (widget.isSent) ...{
                                              10.horizontalSpace,
                                              (state.currentFailedMessage
                                                      .contains(
                                                          widget.messageId))
                                                  ? Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        InkWell(
                                                            onTap: () {
                                                              chatBloc.add(ResendMessageEvent(
                                                                  channelId: widget
                                                                      .channalId,
                                                                  messageId: widget
                                                                      .messageId));
                                                            },
                                                            child: Icon(
                                                              Icons.refresh,
                                                              size: 27.w,
                                                            )),
                                                        Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  left: 5.w),
                                                          child:
                                                              SvgPicture.asset(
                                                            AppAssets
                                                                .messageFailedSvg,
                                                            width: 10.sp,
                                                            height: 10.sp,
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  : Opacity(
                                                      opacity: !widget
                                                              .withImageShadow
                                                          ? 0.4
                                                          : 1,
                                                      child: widget.isRead
                                                          ? SvgPicture.asset(
                                                              AppAssets
                                                                  .messageReadArrowSvg,
                                                              width: 10.sp,
                                                              height: 10.sp,
                                                            )
                                                          : widget.isReceived
                                                              ? SvgPicture
                                                                  .asset(
                                                                  AppAssets
                                                                      .messageDeliveredArrowSvg,
                                                                  width: 10.sp,
                                                                  height: 10.sp,
                                                                )
                                                              : (state.currentMessage
                                                                      .contains(
                                                                          widget
                                                                              .messageId))
                                                                  ? timer
                                                                      ?
                                                                      // (state.currentMessage.contains(widget
                                                                      //         .messageId))
                                                                      //     ?
                                                                      SvgPicture
                                                                          .asset(
                                                                          AppAssets
                                                                              .sandClockSvg,
                                                                          width:
                                                                              10.sp,
                                                                          height:
                                                                              10.sp,
                                                                        )
                                                                      // :
                                                                      // SvgPicture
                                                                      //     .asset(
                                                                      //     AppAssets.messageSentArrowSvg,
                                                                      //     width: 10.sp,
                                                                      //     height: 10.sp,
                                                                      //   )
                                                                      : SvgPicture
                                                                          .asset(
                                                                          "",
                                                                          width:
                                                                              10.sp,
                                                                          height:
                                                                              10.sp,
                                                                        )
                                                                  : SvgPicture
                                                                      .asset(
                                                                      key: TestVariables
                                                                              .kTestMode
                                                                          ? Key(
                                                                              '${WidgetsKey.messageSentArrowKey}${widget.index}',
                                                                            )
                                                                          : null,
                                                                      AppAssets
                                                                          .messageSentArrowSvg,
                                                                      width:
                                                                          10.sp,
                                                                      height:
                                                                          10.sp,
                                                                    ),
                                                    )
                                            },
                                            if (widget.isForwarded) ...{
                                              10.horizontalSpace,
                                              SvgPicture.asset(
                                                key: TestVariables.kTestMode
                                                    ? Key(
                                                        '${WidgetsKey.forwardedArrowKey}${widget.index}',
                                                      )
                                                    : null,
                                                AppAssets.forwardedSvg,
                                                width: 10.sp,
                                                height: 10.sp,
                                              )
                                            }
                                          ],
                                        ),
                                      ),
                                      widget.withImageShadow
                                          ? const SizedBox.shrink()
                                          : 20.verticalSpace,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            widget.isFirstMessage
                                ? Transform.translate(
                                    offset: Offset(
                                        widget.isSent
                                            ? (widget.withImageShadow
                                                ? height < 60
                                                    ? 10
                                                    : 20
                                                : 15)
                                            : (widget.withImageShadow
                                                ? height < 60
                                                    ? -10
                                                    : -20
                                                : -15),
                                        widget.withImageShadow ? 0 : -10),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width:
                                              widget.withImageShadow ? 40 : 30,
                                          height:
                                              widget.withImageShadow ? 40 : 30,
                                          decoration: BoxDecoration(
                                            color: const Color(0xffEBFFF8),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        widget.userMessagePhoto != null
                                            ? MyCachedNetworkImage(
                                                imageUrl: ChatUrls.baseUrl +
                                                    widget.userMessagePhoto!,
                                                imageFit: BoxFit.cover,
                                                radius: 8,
                                                progressIndicatorBuilderWidget:
                                                    TrydosLoader(),
                                                width: widget.withImageShadow
                                                    ? 30
                                                    : 20,
                                                withImageShadow:
                                                    widget.withImageShadow,
                                                height: widget.withImageShadow
                                                    ? 30
                                                    : 20,
                                              )
                                            : NoImageWidget(
                                                width: widget.withImageShadow
                                                    ? 30
                                                    : 20,
                                                height: widget.withImageShadow
                                                    ? 30
                                                    : 20,
                                                textStyle: context
                                                    .textTheme.titleMedium?.br
                                                    .copyWith(
                                                        color: const Color(
                                                            0xff6638FF),
                                                        letterSpacing: 0.18,
                                                        height: 1.33),
                                                radius: 8,
                                                withImageShadow:
                                                    widget.withImageShadow,
                                                name: widget.userMessageName),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                            state.isSlpoing &&
                                    state.slopMessageId!
                                        .contains(widget.messageId) &&
                                    !widget.isreplay
                                ? Transform.translate(
                                    offset: widget.senderId ==
                                            widget._prefsRepository.myChatId
                                        ? Offset(-120.w, 0)
                                        : Offset(0, 0),
                                    child: SendRecieveWatchTime(
                                      isRead: widget.isRead,
                                      isReceived: widget.isReceived,
                                      receivedAt: widget.receivedAt,
                                      watchedAt: widget.watchedAt,
                                    ),
                                  )
                                : SizedBox.shrink(),
                          ],
                        ),
                      ),
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

class SendRecieveWatchTime extends StatelessWidget {
  final bool isRead;
  final bool isReceived;
  final DateTime? receivedAt;
  final DateTime? watchedAt;

  const SendRecieveWatchTime(
      {super.key,
      required this.isRead,
      required this.isReceived,
      this.receivedAt,
      required this.watchedAt});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 45.w,
      height: 31.w,
      child: Row(
        children: [
          Column(
            children: [
              isReceived
                  ? Row(
                      children: [
                        Container(
                            width: 24,
                            height: 14,
                            child: Text(
                              !receivedAt!.isUtc
                                  ? HelperFunctions.getDateInFormat(receivedAt!)
                                  : HelperFunctions.getZonedDateInFormat(
                                      receivedAt!),
                              style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.normal,
                                  color: const Color(0xffC4C2C2)),
                            )),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 3.5)),
                        Container(
                            width: 10,
                            height: 10,
                            child: SvgPicture.asset(
                                AppAssets.messageDeliveredArrowSvg))
                      ],
                    )
                  : SizedBox.shrink(),
              Padding(padding: EdgeInsets.symmetric(vertical: 0.17)),
              isRead
                  ? Row(
                      children: [
                        Container(
                            width: 24,
                            height: 14,
                            child: Text(
                                !watchedAt!.isUtc
                                    ? HelperFunctions.getDateInFormat(
                                        watchedAt!)
                                    : HelperFunctions.getZonedDateInFormat(
                                        watchedAt!),
                                style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.normal,
                                    color: const Color(0xff505050)))),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 3.5)),
                        Container(
                            width: 10,
                            height: 10,
                            child:
                                SvgPicture.asset(AppAssets.messageReadArrowSvg))
                      ],
                    )
                  : SizedBox.shrink()
            ],
          ),
        ],
      ),
    );
  }
}
