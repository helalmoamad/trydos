import 'dart:async';
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:trydos/common/constant/design/assets_provider.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/core/utils/responsive_padding.dart';
import 'package:trydos/core/utils/theme_state.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_state.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/no_image_widget.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import '../../../../common/constant/configuration/chat_url_routes.dart';
import '../../../../common/test_utils/widgets_keys.dart';
import '../../../../common/helper/helper_functions.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../routes/router.dart';
import '../../../../service/language_service.dart';
import '../../../app/my_cached_network_image.dart';
import '../../../app/my_text_widget.dart';
import '../../data/models/my_chats_response_model.dart';
import '../manager/chat_event.dart';
import '../manager/chat_state.dart';

class ChatCard extends StatefulWidget {
  const ChatCard(
      {Key? key,
      this.index = 0,
      this.activityDescription,
      required this.chat,
      required this.thereActivity,
      this.onSendForwardMessage,
      required this.messageId})
      : super(key: key);
  final int index;
  final Chat chat;
  final String messageId;
  final bool thereActivity;
  final String? activityDescription;
  final Function(int receiverId, String channelId)? onSendForwardMessage;

  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends ThemeState<ChatCard> {
  ValueNotifier<int> typingIndicator = ValueNotifier(0);
  Timer? timer;
  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();
  DateTime? chatTime;
  late ChatBloc chatBloc;

  @override
  void initState() {
    chatBloc = BlocProvider.of<ChatBloc>(context);
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    typingIndicator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
      print(error);
    };
    chatTime = null;
    print('dwwdw ${widget.chat.messages}');
    if (!(widget.chat.messages.isNullOrEmpty)) {
      chatTime = widget.chat.messages!
          .firstWhere((element) =>
              element.authMessageStatus!.isDeleted == 0 ||
              element.authMessageStatus!.deleteForAll!)
          .createdAt!;
    }

    User? receiver = !widget.chat.channelMembers.isNullOrEmpty
        ? widget.chat.channelMembers!
            .firstWhere(
                (element) => element.userId != _prefsRepository.myChatId)
            .user
        : null;
    String receiverName = HelperFunctions.getTheFirstTwoLettersOfName(
            widget.chat.channelName ?? LocaleKeys.no_channal_name.tr()),
        fullReceiverName =
            widget.chat.channelName ?? LocaleKeys.no_channal_name.tr();
    // if (receiver == null) {
    //   receiverName = 'UK';
    //   fullReceiverName = 'Unknown User';
    // } else {
    //   receiverName = receiver.contactUser == null
    //       ? receiver.name == null
    //           ? 'UK'
    //           : HelperFunctions.getTheFirstTwoLettersOfName(receiver.name!)
    //       : receiver.contactUser!.name == null
    //           ? 'UK'
    //           : HelperFunctions.getTheFirstTwoLettersOfName(
    //               receiver.contactUser!.name!);
    //   fullReceiverName = receiver.contactUser?.name ??
    //       receiver.name ??
    //       receiver.mobilePhone ??
    //       'Unknown User';
    // }
    String senderName = HelperFunctions.getTheFirstTwoLettersOfName(
        _prefsRepository.myChatName ?? LocaleKeys.no_channal_name.tr());
    print('meesges ${widget.chat.messages?.length}');
    print('meesges ${widget.chat.channelMembers?.length}');
    print('meesges ${widget.chat.channelName}');
    print('_prefsRepository.myChatId ${_prefsRepository.myChatId}');

    ChannelMember? me = !widget.chat.channelMembers.isNullOrEmpty
        ? widget.chat.channelMembers!.firstWhere(
            (element) => element.userId == _prefsRepository.myChatId)
        : null;
    // User? sender = me.user;
    // String senderName;
    // if (sender == null) {
    //   senderName = 'UK';
    // } else {
    //   senderName = sender.name == null
    //       ? 'UK'
    //       : HelperFunctions.getTheFirstTwoLettersOfName(sender.name!);
    // }
    if (widget.thereActivity && timer == null) {
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (typingIndicator.value == 5) {
          typingIndicator.value = 0;
        } else {
          typingIndicator.value++;
        }
      });
    }
    String messageType = '';
    bool isDeleteForAll = false;
    bool deleteFromMyId = false;
    if (!widget.chat.messages.isNullOrEmpty) {
      messageType = (widget.chat.messages!
              .firstWhere((element) =>
                  element.authMessageStatus!.isDeleted == 0 ||
                  element.authMessageStatus!.deleteForAll!)
              .messageType
              ?.name)
          .toString();
      deleteFromMyId = (widget.chat.messages!
              .firstWhere((element) =>
                  element.authMessageStatus!.isDeleted == 0 ||
                  element.authMessageStatus!.deleteForAll!)
              .deletedByUserId ==
          _prefsRepository.myChatId!);
      isDeleteForAll = (widget.chat.messages!
              .firstWhere((element) =>
                  element.authMessageStatus!.isDeleted == 0 ||
                  element.authMessageStatus!.deleteForAll!)
              .authMessageStatus!
              .deleteForAll ??
          false);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: widget.index == 0 ? 0 : 0.4,
          color: const Color(0xffC8C7CC),
          margin: HWEdgeInsetsDirectional.only(start: 94),
        ),
        //todo
        SizedBox(
          height: 100.h,
          width: 1.sw,
          child: Container(
            child: InkWell(
              onTap: () {
//                if(state.)
                //todo (future update) call just when The totalUnreadMessage one or more
                // if (widget.onSendForwardMessage != null) {
                //   Navigator.of(context)
                //     ..pop()
                //     ..pop();
                // }
                chatBloc.add(ChangeGlobalUsedVariablesInBloc(
                    currentOpenedChatId: widget.chat.id));
                widget.onSendForwardMessage?.call(
                    widget.chat.channelMembers!
                        .firstWhere((element) =>
                            element.userId !=
                            GetIt.I<PrefsRepository>().myChatId)
                        .userId!,
                    widget.chat.id.toString());
                context.go(GRouter
                        .config.applicationRoutes.kSinglePageChatPagePath +
                    '?chatId=${widget.chat.id!.toString()}&data_length=${widget.chat.messages!.length}&receiverName=$receiverName&fullReceiverName=${fullReceiverName}&receiverPhone=${receiver?.mobilePhone ?? 'Uo Number'}&senderName=${senderName}&receiverPhoto=${receiver?.photoPath}&senderPhoto=${_prefsRepository.myChatPhoto}');
              },
              child: Slidable(
                endActionPane: ActionPane(
                  extentRatio: 0.645,
                  motion: const ScrollMotion(),
                  children: [
                    SlidableActionWidget(
                      text: me?.archived == 0
                          ? LocaleKeys.archive.tr()
                          : LocaleKeys.un_archive.tr(),
                      onTap: () {
                        chatBloc.add(ChangeChatPropertyEvent(
                            channelId: widget.chat.id!,
                            archive: 1 - (me?.archived ?? 0)));
                      },
                      backgroundColor: const Color(0xffF0F0F0),
                      foregroundColor: colorScheme.grey200,
                      iconUrl: AppAssets.archiveSvg,
                    ),
                    SlidableActionWidget(
                      key: TestVariables.kTestMode
                          ? Key(
                              '${WidgetsKey.deleteChatConversationIconKey}${widget.index}')
                          : null,
                      text: LocaleKeys.delete.tr(),
                      onTap: () {
                        if (double.tryParse(widget.chat.id!) == null) {
                          showMessage(
                              'You Can\'t remove this Chat at This Time');
                          return;
                        }
                        chatBloc
                            .add(DeleteChatEvent(channelId: widget.chat.id!));
                      },
                      backgroundColor: const Color(0xffFFE8E8),
                      foregroundColor: const Color(0xffFA6868),
                      iconUrl: AppAssets.binSvg,
                    ),
                    SlidableActionWidget(
                      text: me?.mute == 0
                          ? LocaleKeys.mute.tr()
                          : LocaleKeys.un_mute.tr(),
                      onTap: () {
                        chatBloc.add(ChangeChatPropertyEvent(
                            channelId: widget.chat.id!,
                            mute: 1 - (me?.mute ?? 0)));
                      },
                      backgroundColor: const Color(0xffF6F5FD),
                      foregroundColor: const Color(0xffC4C2C2),
                      iconUrl: me?.mute == 1
                          ? AppAssets.unMuteSvg
                          : AppAssets.muteSvg,
                    ),
                  ],
                ),

                // The end action pane is the one at the right or the bottom side.
                startActionPane: ActionPane(
                  extentRatio: 0.43,
                  motion: const ScrollMotion(),
                  children: [
                    SlidableActionWidget(
                      text: LocaleKeys.read.tr(),
                      onTap: () {
                        chatBloc.add(
                            ReadAllMessagesEvent(widget.chat.id!.toString()));
                      },
                      backgroundColor: const Color(0xffFCF6EF),
                      foregroundColor: colorScheme.grey200,
                      iconUrl: AppAssets.unreadSvg,
                    ),
                    SlidableActionWidget(
                      text: me?.pin == 0
                          ? LocaleKeys.pin.tr()
                          : LocaleKeys.un_pin.tr(),
                      onTap: () {
                        if (chatBloc.state.pinnedChats.length == 3 &&
                            me?.pin == 0) {
                          showMessage(
                              LocaleKeys.you_can_have_at_most_3_pinned.tr(),
                              showInRelease: true);
                          return;
                        }
                        chatBloc.add(ChangeChatPropertyEvent(
                            channelId: widget.chat.id!,
                            pin: 1 - (me?.pin ?? 0)));
                      },
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
                          receiver?.photoPath != null
                              ? BlocBuilder<AppBloc, AppState>(
                                  builder: (context, state) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        boxShadow: widget.thereActivity
                                            ? [
                                                BoxShadow(
                                                    color:
                                                        const Color(0xff007CFF)
                                                            .withOpacity(0.16),
                                                    offset: const Offset(0, 3),
                                                    blurRadius: 6)
                                              ]
                                            : null,
                                        border: widget.thereActivity
                                            ? Border.all(
                                                color: const Color(0xff007CFF),
                                                width: 1)
                                            : null,
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      child: MyCachedNetworkImage(
                                          imageUrl: ChatUrls.baseUrl +
                                              receiver?.photoPath,
                                          imageFit: BoxFit.cover,
                                          height: 80.h,
                                          width: 60.w),
                                    );
                                  },
                                )
                              : NoImageWidget(
                                  width: 60.w,
                                  height: 80.h,
                                  textStyle: context.textTheme.bodyMedium?.br
                                      .copyWith(
                                          color: const Color(0xff6638FF),
                                          letterSpacing: 0.18,
                                          height: 1.33),
                                  thereActivity: widget.thereActivity,
                                  name: receiverName),
                          18.horizontalSpace,
                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Row(
                                    children: [
                                      MyTextWidget(
                                        fullReceiverName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: textTheme.bodyMedium?.rr
                                            .copyWith(
                                                height: 1.33,
                                                color: const Color(0xff505050)),
                                      ),
                                      const Spacer(),
                                      if (chatTime == null)
                                        const SizedBox.shrink()
                                      else
                                        BlocConsumer<ChatBloc, ChatState>(
                                          listener: (context, state) {},
                                          builder: (context, state) {
                                            return MyTextWidget(
                                              !chatTime!.isUtc
                                                  ? HelperFunctions
                                                      .getDateInFormat(
                                                          chatTime!)
                                                  : HelperFunctions
                                                      .getZonedDateInFormat(
                                                          chatTime!),
                                              maxLines: 1,
                                              style: textTheme.titleSmall?.lr
                                                  .copyWith(
                                                      fontSize: 12,
                                                      height: 1.1,
                                                      color:
                                                          colorScheme.grey200),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (widget.thereActivity) ...{
//                                        Transform.translate(
//                                          offset: const Offset(0, 3),
//                                          child: Transform(
//                                            alignment: Alignment.center,
//                                            transform: (Matrix4.identity()
//                                              ..scale(
//                                                  LanguageService.languageCode ==
//                                                          'ar'
//                                                      ? -1.0
//                                                      : 1.0,
//                                                  1.0,
//                                                  1.0)),
//                                            child:
                                        SvgPicture.asset(
                                          AppAssets.messageReadArrowSvg,
                                          height: 12.h,
                                          width: 12.w,
                                        )
//                                            ,
//                                          ),
//                                        )
                                        ,
                                        7.horizontalSpace,
                                      },
                                      Flexible(
                                        fit: FlexFit.loose,
                                        child: SizedBox(
                                          height:
                                              widget.thereActivity ? 33 : 51,
                                          child: (widget
                                                      .chat.messages?.isEmpty ??
                                                  true &&
                                                      widget.chat.messages !=
                                                          null)
                                              ? const SizedBox.shrink()
                                              : Row(
                                                  children: [
                                                    if (widget
                                                                .chat
                                                                .messages!
                                                                .first
                                                                .messageType
                                                                ?.name !=
                                                            'VoiceCall' &&
                                                        widget
                                                                .chat
                                                                .messages!
                                                                .first
                                                                .messageType
                                                                ?.name !=
                                                            'VideoCall')
                                                      BlocBuilder<ChatBloc,
                                                          ChatState>(
                                                        builder:
                                                            (context, state) {
                                                          if (widget
                                                                  .chat
                                                                  .messages!
                                                                  .first
                                                                  .senderUserId ==
                                                              _prefsRepository
                                                                  .myChatId) {
                                                            Message lastMessage = [
                                                              ...state.chats,
                                                              ...state
                                                                  .pinnedChats
                                                            ]
                                                                .firstWhere(
                                                                    (element) =>
                                                                        element
                                                                            .id ==
                                                                        widget
                                                                            .chat
                                                                            .id,
                                                                    orElse: () => Chat(
                                                                        messages: []))
                                                                .messages!
                                                                .firstWhere(
                                                                    (element) =>
                                                                        element.authMessageStatus!.isDeleted ==
                                                                            0 ||
                                                                        element
                                                                            .authMessageStatus!
                                                                            .deleteForAll!,
                                                                    orElse: () =>
                                                                        Message(id: '-1'));
                                                            if (lastMessage
                                                                    .id ==
                                                                '-1') {
                                                              return SizedBox
                                                                  .shrink();
                                                            }
                                                            MessageStatus?
                                                                status;
                                                            if (int.tryParse(
                                                                    lastMessage
                                                                        .id
                                                                        .toString()) !=
                                                                null) {
                                                              status = lastMessage
                                                                  .messageStatus!
                                                                  .firstWhere((element) =>
                                                                      element
                                                                          .userId !=
                                                                      _prefsRepository
                                                                          .myChatId);
                                                            }
                                                            return lastMessage
                                                                    .authMessageStatus!
                                                                    .deleteForAll!
                                                                ? SizedBox
                                                                    .shrink()
                                                                : SvgPicture
                                                                    .asset(
                                                                    (state.currentMessage.contains(lastMessage
                                                                            .id))
                                                                        ? AppAssets
                                                                            .sandClockSvg
                                                                        : (state.currentFailedMessage.contains(lastMessage.id))
                                                                            ? AppAssets.messageFailedSvg
                                                                            : status?.isWatched ?? false
                                                                                ? AppAssets.messageReadArrowSvg
                                                                                : status?.isReceived == 1
                                                                                    ? AppAssets.messageDeliveredArrowSvg
                                                                                    : AppAssets.messageSentArrowSvg,
                                                                    width:
                                                                        10.sp,
                                                                    height:
                                                                        10.sp,
                                                                  );
                                                          } else
                                                            return SizedBox
                                                                .shrink();
                                                        },
                                                      ),
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 5)),
                                                    if ((widget.chat.messages
                                                                ?.firstWhere((element) =>
                                                                    element.authMessageStatus!
                                                                            .isDeleted ==
                                                                        0 ||
                                                                    element
                                                                        .authMessageStatus!
                                                                        .deleteForAll!)
                                                                .mediaMessageContent
                                                                ?.isNotEmpty ??
                                                            false) ||
                                                        (widget.chat.messages
                                                                ?.firstWhere((element) =>
                                                                    element.authMessageStatus!
                                                                            .isDeleted ==
                                                                        0 ||
                                                                    element
                                                                        .authMessageStatus!
                                                                        .deleteForAll!)
                                                                .file !=
                                                            null) ||
                                                        messageType.contains(
                                                            'Call')) ...{
                                                      isDeleteForAll
                                                          ? SizedBox.shrink()
                                                          : SvgPicture.asset(
                                                              messageType ==
                                                                      'ImageMessage'
                                                                  ? AppAssets
                                                                      .lastMessageImageSvg
                                                                  : messageType ==
                                                                          'VideoMessage'
                                                                      ? AppAssets
                                                                          .lastMessageVideoSvg
                                                                      : messageType ==
                                                                              'FileMessage'
                                                                          ? AppAssets
                                                                              .documentSvg
                                                                          : messageType == 'VoiceCall'
                                                                              ? AppAssets.missedCallInChatSvg
                                                                              : messageType == 'VideoCall'
                                                                                  ? AppAssets.missedVideoCallInChatSvg
                                                                                  : AppAssets.lastMessageAudioSvg,
                                                              width: 20.w,
                                                              height: 20.h,
                                                              color: messageType
                                                                      .contains(
                                                                          'Call')
                                                                  ? colorScheme
                                                                      .grey200
                                                                      .withOpacity(
                                                                          0.6)
                                                                  : null,
                                                            ),
                                                      !isDeleteForAll
                                                          ? 10.horizontalSpace
                                                          : SizedBox.shrink(),
                                                    },
                                                    Flexible(
                                                      flex: 2,
                                                      child: deleteFromMyId &&
                                                              !isDeleteForAll
                                                          ? SizedBox.shrink()
                                                          : MyTextWidget(
                                                              isDeleteForAll
                                                                  ? deleteFromMyId
                                                                      ? LocaleKeys
                                                                          .you_have_deleted_this_message
                                                                          .tr()
                                                                      : LocaleKeys
                                                                          .this_message_has_been_deleted
                                                                          .tr()
                                                                  : messageType !=
                                                                          'TextMessage'
                                                                      ? messageType !=
                                                                              'ShareProduct'
                                                                          ? (messageType == 'ImageMessage'
                                                                              ? LocaleKeys.photo.tr()
                                                                              : messageType == 'VideoMessage'
                                                                                  ? LocaleKeys.vvideo.tr()
                                                                                  : messageType == 'FileMessage'
                                                                                      ? LocaleKeys.file.tr()
                                                                                      : messageType == 'VoiceCall'
                                                                                          ? LocaleKeys.voice_call.tr()
                                                                                          : messageType == 'VideoCall'
                                                                                              ? LocaleKeys.video_call.tr()
                                                                                              : LocaleKeys.voice.tr())
                                                                          : widget.chat.messages!.firstWhere((element) => element.authMessageStatus!.isDeleted == 0).shareProductContent!.productName ?? ""
                                                                      : widget.chat.messages!.firstWhere((element) => element.authMessageStatus!.isDeleted == 0).messageContent!.content.toString(),
                                                              maxLines: widget
                                                                      .thereActivity
                                                                  ? 1
                                                                  : 3,
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: textTheme
                                                                  .titleSmall
                                                                  ?.lr
                                                                  .copyWith(
                                                                      fontSize:
                                                                          12,
                                                                      height:
                                                                          1.1,
                                                                      color: colorScheme
                                                                          .grey200),
                                                            ),
                                                    ),
                                                    Spacer()
                                                  ],
                                                ),
                                        ),
                                      ),
                                      28.horizontalSpace,
                                      Row(
                                        children: [
                                          if (((widget.chat
                                                          .totalUnreadMessageCount ??
                                                      0)) >
                                                  0 &&
                                              widget.chat
                                                      .totalUnreadMessageCount !=
                                                  null) ...{
                                            SvgPicture.asset(
                                              AppAssets
                                                  .singleChatFilledActiveSvg,
                                              height: 15.h,
                                              width: 15.w,
                                            ),
                                            10.horizontalSpace,
                                            MyTextWidget(
                                              (widget.chat
                                                      .totalUnreadMessageCount!)
                                                  .toString(),
                                              maxLines: 1,
                                              style: textTheme.titleMedium?.rr
                                                  .copyWith(
                                                      color: const Color(
                                                          0xff007CFF)),
                                            ),
                                          },
                                          25.horizontalSpace,
                                          Transform(
                                            alignment: Alignment.center,
                                            transform: (Matrix4.identity()
                                              ..scale(
                                                  LanguageService
                                                              .languageCode ==
                                                          'ar'
                                                      ? -1.0
                                                      : 1.0,
                                                  1.0,
                                                  1.0)),
                                            child: SvgPicture.asset(
                                              AppAssets.forwardArrowRight,
                                              width: 3.w,
                                              height: 12.h,
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                if (widget.thereActivity) ...{
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      MyTextWidget(
                                        widget.activityDescription!.substring(
                                            0,
                                            widget.activityDescription!.length -
                                                3),
                                        maxLines: 1,
                                        style: textTheme.titleMedium?.rr
                                            .copyWith(
                                                color: const Color(0xff007CFF)),
                                      ),
                                      8.horizontalSpace,
//                                      Transform.translate(
//                                        offset: const Offset(0, 1),
//                                        child:
//                                        ,
//                                      )
                                      ValueListenableBuilder<int>(
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
                                          })
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
                      right:
                          LanguageService.languageCode != 'ar' ? 10.sp : null,
                      left: LanguageService.languageCode == 'ar' ? 10.sp : null,
                      bottom: 10.sp,
                      child: Row(
                        children: [
                          if (me?.pin == 1) ...{
                            SvgPicture.asset(
                              AppAssets.pinSvg,
                              width: 20.w,
                              height: 20.h,
                            ),
                          },
                          if (me?.mute == 1) ...{
                            10.horizontalSpace,
                            SvgPicture.asset(
                              AppAssets.muteSvg,
                              width: 20.w,
                              height: 20.h,
                            ),
                          },
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SlidableActionWidget extends StatelessWidget {
  const SlidableActionWidget(
      {Key? key,
      required this.backgroundColor,
      required this.foregroundColor,
      required this.iconUrl,
      required this.onTap,
      required this.text})
      : super(key: key);
  final Color backgroundColor;
  final Color foregroundColor;
  final String iconUrl;
  final String text;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap.call();
        Slidable.of(context)?.close();
      },
      child: Container(
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
              MyTextWidget(
                text,
                style: context.textTheme.titleMedium?.rr
                    .copyWith(color: foregroundColor),
              )
            ],
          ),
        ),
      ),
    );
  }
}
