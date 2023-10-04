import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/helper/file_saving.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/core/utils/responsive_padding.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_state.dart';
import 'package:trydos/features/chat/presentation/pages/create_call_page.dart';
import 'package:trydos/features/chat/presentation/pages/profile_page.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_input_field.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/document_message.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/image_message.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/reply_messge.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/reply_on_me_message.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/video_message.dart';
import 'package:uuid/uuid.dart';
import 'dart:ui' as ui;
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../routes/router.dart';
import '../../../../service/language_service.dart';
import '../../../app/app_widgets/trydos_app_bar/app_bar_params.dart';
import '../../../app/app_widgets/trydos_app_bar/trydos_appbar.dart';
import '../../../app/blocs/app_bloc/app_bloc.dart';
import '../../../app/blocs/app_bloc/app_event.dart';
import '../../../app/my_cached_network_image.dart';
import '../../data/models/my_chats_response_model.dart';
import '../manager/chat_bloc.dart';
import '../manager/chat_event.dart';
import '../widgets/chat_widgets/no_image_widget.dart';
import '../widgets/chat_widgets/text_message.dart';
import '../widgets/chat_widgets/voice_message.dart';

class SinglePageChat extends StatefulWidget {
  const SinglePageChat(
      {Key? key,
      this.dataLength,
      required this.chatId,
      required this.receiverName,
      required this.receiverPhone,
      required this.fullReceiverName,
      required this.senderName,
      this.senderPhoto,
      this.receiverPhoto})
      : super(key: key);
  final int? dataLength;
  final String chatId;
  final String receiverName;
  final String fullReceiverName;
  final String receiverPhone;
  final String senderName;
  final String? receiverPhoto;
  final String? senderPhoto;

  @override
  State<SinglePageChat> createState() => _SinglePageChatState();
}

class _SinglePageChatState extends State<SinglePageChat> {
  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();
  late ChatBloc chatBloc;

  final ValueNotifier<int> rebuildMessage = ValueNotifier(-1);
  final ValueNotifier<int> currentFocusedIcon = ValueNotifier(-2);
  final ValueNotifier<bool> clickBackButton = ValueNotifier(false);
  double currentHoverPosition = -1;
  double x = -1, xActionSubtitle = -1, yActionSubtitle = -1;
  late AutoScrollController autoScrollController;

  void _scrollToBottom() {
    if (autoScrollController.hasClients) {
      autoScrollController
          .jumpTo(autoScrollController.position.maxScrollExtent);
    } else {
      Timer(Duration(milliseconds: 400), () => _scrollToBottom());
    }
  }

  final key = GlobalKey();
  int? previousMessageSenderId, currentMessageSenderId;
  List<Widget> data = [];
  Map<String, List<Message>> messagesByDate = {};
  bool rebuild = true;
  DateTime lastDate = DateTime.now();
  int countMessagesReceivedToMeNow = 0;
  late Chat chat;
  AudioPlayer _audioPlayer = AudioPlayer();

  void playSound() async {
    await _audioPlayer.play(
        AssetSource(Platform.isIOS
            ? 'audio/Whatsapp_Tone.m4r'
            : 'audio/Whatsapp_Tone.mp3'),
        volume: 1);
  }

  @override
  void initState() {
    chatBloc = BlocProvider.of<ChatBloc>(context);
    autoScrollController = AutoScrollController();
    chatBloc.add(ReadAllMessagesEvent(widget.chatId.toString()));
    autoScrollController.addListener(() {
      if (rebuild) {
        rebuildMessage.value = -1;
      }
      print('rebuild............');
      if ((autoScrollController.offset <=
              autoScrollController.position.minScrollExtent + 400 ) &&
          autoScrollController.position.userScrollDirection ==
              ScrollDirection.forward) {
        _loadMoreMessages();
      }
    });
    super.initState();
  }

  void scrollToTheEnd() {
//todo i change the duration to 1 from 50
    scrollToIndex(3 * data.length, duration: const Duration(milliseconds: 50));
  }

  int currentScrolledIndex = -1;
  bool isPaginationEvent = false;
  bool rebuildScreen = true,
      fromPagination = false,
      getChats = false,
      getMessagesBetween = false,
      sendOrReceiveMessage = false;

  //todo i made this parameter here to reassign its value to the variable chat in the if (rebuildScreen) cause it has the sam value
  late Chat currentChat;

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (error) {
      print(error.stack);
    };
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (autoScrollController.hasClients) {
        autoScrollController
            .jumpTo(autoScrollController.position.maxScrollExtent);
      } else {
        Timer(Duration(milliseconds: 400), () => _scrollToBottom());
      }
    });
    // scrollToTheEnd();
    return Scaffold(
        backgroundColor: const Color(0xffEBFFF8),
        appBar: TrydosAppBar(
          appBarParams: AppBarParams(
              dividerBottom: false,
              hasLeading: false,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              child: SafeArea(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ValueListenableBuilder<bool>(
                        valueListenable: clickBackButton,
                        builder: (context, clicked, _) {
                          return InkWell(
                            onTap: () {
                              clickBackButton.value = true;
                              Future.delayed(
                                Duration(milliseconds: 100),
                                () {
                                  clickBackButton.value = false;
                                  GoRouter.of(context).pop();
                                },
                              );
                            },
                            child: Container(
                              color: clicked
                                  ? Colors.grey.shade100
                                  : Colors.transparent,
                              padding: HWEdgeInsetsDirectional.fromSTEB(
                                  20.w, 15, 0, 15),
                              child:
                                  //todo comment while i don't have another svg for direction
//                          Transform(
//                          alignment: Alignment.center,
//                          transform: (Matrix4.identity()
//                          ..scale(
//                          LanguageService.languageCode == 'ar'
//                          ? -1.0
//                              : 1.0,
//                          1.0,
//                          1.0)),
//                          child:
                                  SvgPicture.asset(
                                AppAssets.backFromCallSvg,
                                width: 8.w,
                                color: const Color(0xff388CFF),
                              ),
//                              )
//                              ,
                            ),
                          );
                        }),
                    BlocBuilder<ChatBloc, ChatState>(builder: (context, state) {
                      if ((state.unReadMessagesFromAllChats -
                              countMessagesReceivedToMeNow) >
                          0) {
                        return Column(
                          children: [
                            10.horizontalSpace,
                            Text(
                              (state.unReadMessagesFromAllChats -
                                      countMessagesReceivedToMeNow)
                                  .toString(),
                              style: textTheme.subtitle1?.rr
                                  .copyWith(color: const Color(0xff388CFF)),
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    20.horizontalSpace,
                    widget.receiverPhoto != null
                        ? Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  width: 1.0, color: const Color(0xff388cff)),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x29388cff),
                                  offset: Offset(0, 3),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: MyCachedNetworkImage(
                              imageUrl:
                                  ChatUrls.baseUrl + widget.receiverPhoto!,
                              imageFit: BoxFit.cover,
                              height: 40,
                              width: 40.w,
                            ),
                          )
                        : NoImageWidget(
                            height: 40,
                            width: 40.w,
                            textStyle: context.textTheme.subtitle1?.br.copyWith(
                                color: const Color(0xff6638FF),
                                letterSpacing: 0.18,
                                height: 1.33),
                            name: widget.receiverName),
                    20.horizontalSpace,
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => ProfilePage(
                                      receiverName: widget.receiverName,
                                      receiverPhoto: widget.receiverPhoto,
                                      fullReceiverName: widget.fullReceiverName,
                                      receiverPhone: widget.receiverPhone)));
                            },
                            child: Text(
                              widget.fullReceiverName,
                              style: textTheme.subtitle1?.mr
                                  .copyWith(color: const Color(0xff5D5C5D)),
                            ),
                          ),
                          if (int.tryParse(widget.chatId) != null)
                            BlocBuilder<AppBloc, AppState>(
                              builder: (context, state) {
                                if (state.pusherActivityIds[
                                        int.parse(widget.chatId)] !=
                                    null) {
                                  return Text(
                                    state.pusherActivityDescription[
                                            int.parse(widget.chatId)]
                                        .toString(),
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.caption?.mr.copyWith(
                                        color: const Color(0xff007CFF)),
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                            ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => CreateCallPage(
                                fullReceiverName: widget.fullReceiverName,
                                receiverName: widget.receiverName,
                                receiverPhoto: widget.receiverPhone,
                              ))),
                      child: SvgPicture.asset(
                        AppAssets.makeVideoCallSvg,
                        width: 34.w,
                        height: 25,
                      ),
                    ),
                    30.horizontalSpace,
                    InkWell(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => CreateCallPage(
                                fullReceiverName: widget.fullReceiverName,
                                receiverName: widget.receiverName,
                                receiverPhoto: widget.receiverPhone,
                              ))),
                      child: SvgPicture.asset(
                        AppAssets.makeCallSvg,
                        width: 25.w,
                        height: 25,
                      ),
                    ),
                    20.horizontalSpace
                  ],
                ),
              )),
        ),
        body: Column(
          children: [
            Flexible(
              child: BlocConsumer<ChatBloc, ChatState>(
                listener: (context, state) {
                  if (state.sendMessageStatus == SendMessageStatus.loading ||
                      state.receiveMessageStatus ==
                          ReceiveMessageStatus.success) {
                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                      _scrollToBottom();
                    });
                  }
                },
                // buildWhen: (p, c) {
                //   Chat previousChat = p.chats.firstWhere(
                //           (element) =>
                //       element.id.toString() == widget.chatId ||
                //           element.localId.toString() == widget.chatId,
                //       orElse: () =>
                //           p.pinnedChats.firstWhere((element) =>
                //           element.id.toString() == widget.chatId ||
                //               element.localId.toString() == widget.chatId));
                //   currentChat = c.chats.firstWhere(
                //           (element) =>
                //       element.id.toString() == widget.chatId ||
                //           element.localId.toString() == widget.chatId,
                //       orElse: () =>
                //           c.pinnedChats.firstWhere((element) =>
                //           element.id.toString() == widget.chatId ||
                //               element.localId.toString() == widget.chatId));
                //   getMessagesBetween =
                //       p.getMessagesBetweenStatus != c.getMessagesBetweenStatus;
                //
                //   rebuildScreen = (previousChat.messages?.length !=
                //       currentChat.messages?.length) ||
                //       getMessagesBetween;
                //   fromPagination = previousChat.paginationStatus !=
                //       currentChat.paginationStatus &&
                //       currentChat.paginationStatus == PaginationStatus.success;
                //   sendOrReceiveMessage = c.sendMessageStatus ==
                //       SendMessageStatus.loading ||
                //       (c.receiveMessageStatus == ReceiveMessageStatus.success &&
                //           widget.chatId ==
                //               c.currentChannelReceivedMessage.toString());
                //   getChats = p.getChatsStatus != c.getChatsStatus &&
                //       c.getChatsStatus == GetChatsStatus.success;
                //
                //   if (getChats) {
                //     fromPagination = false;
                //     sendOrReceiveMessage = false;
                //     getMessagesBetween = false;
                //   }
                //   return rebuildScreen ||
                //       p.unReadMessagesFromAllChats !=
                //           c.unReadMessagesFromAllChats ||
                //       getMessagesBetween;
                // },
                builder: (context, chatState) {
                   chat = chatState.chats.firstWhere(
                      (element) => element.id.toString() == widget.chatId,
                      orElse: () => chatState.pinnedChats.firstWhere(
                          (element) => element.id.toString() == widget.chatId));
                  print('data: ${widget.chatId}');
                  print('data: ${chatState.newSortedChatsByDate}');
                  print(
                      'data: ${chatState.newSortedChatsByDate!.containsKey(widget.chatId)}');
//                   if (rebuildScreen) {
//                     chat = chat = chatState.chats.firstWhere(
//                             (element) => element.id.toString() == widget.chatId,
//                         orElse: () =>
//                             chatState.pinnedChats.firstWhere(
//                                     (element) =>
//                                 element.id.toString() == widget.chatId));
//                     if (getMessagesBetween) {
// //                      print('messages between');
//                       bool enableTake = false;
//                       List<Message> messages = [];
//                       for (int i = chat.messages!.length - 1; i >= 0; i--) {
//                         if (chatState.scrollToParentMessage) {
//                           if (getMessageIndex(chat.messages![i].id, null) !=
//                               -1) {
//                             break;
//                           }
//                           messages.insert(0, chat.messages![i]);
//                         } else {
//                           if (chat.messages![i].id == chatState.firstMessageId)
//                             enableTake = true;
//                           if (chat.messages![i].id == chatState.secondMessageId)
//                             break;
//                           if (enableTake) messages.insert(0, chat.messages![i]);
//                         }
//                       }
//                       preProcessingOfMessaging(
//                           messages,
//                           chatState.scrollToParentMessage
//                               ? 0
//                               : getMessageIndex(
//                               chatState.secondMessageId, null),
//                           false,
//                           widget.senderName,
//                           widget.receiverName,
//                           widget.senderPhoto,
//                           widget.receiverPhoto,
//                           fromGetMessagesBetween: true,
//                           replacedReplyMessage: chatState.scrollToParentMessage
//                               ? chat.messages!.firstWhere((element) =>
//                           element.id == chatState.secondMessageId)
//                               : null);
//                     }
//                     if (data.isEmpty) {
// //                      print('data empty');
//                       preProcessingOfMessaging(
//                         chat.messages ?? [],
//                         0,
//                         true,
//                         widget.senderName,
//                         widget.receiverName,
//                         widget.senderPhoto,
//                         widget.receiverPhoto,
//                       );
//                     }
//                     if (getChats) {
// //                      print('get chats');
//                       data = [];
//                       previousMessageSenderId = null;
//                       currentMessageSenderId = null;
//                       messagesByDate = {};
//                       preProcessingOfMessaging(
//                         chat.messages ?? [],
//                         0,
//                         true,
//                         widget.senderName,
//                         widget.receiverName,
//                         widget.senderPhoto,
//                         widget.receiverPhoto,
//                       );
//                     }
//                     if (sendOrReceiveMessage) {
// //                      print('sending or receive');
//                       preProcessingOfMessaging(
//                         [chat.messages![0]],
//                         -1,
//                         true,
//                         widget.senderName,
//                         widget.receiverName,
//                         widget.senderPhoto,
//                         widget.receiverPhoto,
//                       );
//                       rebuildMessage.value = -1;
//                       if ((chatState.receiveMessageStatus ==
//                           ReceiveMessageStatus.success &&
//                           widget.chatId ==
//                               chatState.currentChannelReceivedMessage
//                                   .toString())) {
//                         playSound();
//                       }
//                       if (chat.messages![0].senderUserId !=
//                           _prefsRepository.myChatId) {
//                         chatBloc.add(ReadAllMessagesEvent(widget.chatId));
//                       }
//                     }
//                     if (fromPagination) {
// //                      print('pagination');
//                       List<Message> messages = [];
//                       for (int i = chat.messages!.length - 10;
//                       i < chat.messages!.length;
//                       i++) {
//                         messages.add(chat.messages![i]);
//                       }
//                       preProcessingOfMessaging(
//                         messages,
//                         0,
//                         false,
//                         widget.senderName,
//                         widget.receiverName,
//                         widget.senderPhoto,
//                         widget.receiverPhoto,
//                       );
//                     }
//                     if (chatState.currentChannelReceivedMessage == chat.id) {
//                       countMessagesReceivedToMeNow++;
//                     }
//                     rebuildScreen = false;
//                   }
                  print(chatState.newSortedChatsByDate);
                  return GestureDetector(
                      onTap: () {
                        rebuildMessage.value = -1;
                      },
                      child: SafeArea(
                          child: ValueListenableBuilder<int>(
                              valueListenable: rebuildMessage,
                              builder: (context, currentIndex, _) {
                                currentFocusedIcon.value = -2;
                                return Column(
                                  children: [
                                    chat.paginationStatus == PaginationStatus.loading ? TrydosLoader() : SizedBox.shrink(),
                                    chat.paginationStatus == PaginationStatus.loading ? 8.verticalSpace : SizedBox.shrink(),
                                    Expanded(
                                      child: ListView.builder(
                                        controller: autoScrollController,
                                        physics: const ClampingScrollPhysics(),
                                        itemBuilder: (context, outerIndex) {
                                          String date = chatState
                                              .newSortedChatsByDate![
                                                  widget.chatId]!
                                              .keys
                                              .toList()
                                              .reversed
                                              .toList()[outerIndex];
                                          List<Message> messages = chatState
                                              .newSortedChatsByDate![
                                                  widget.chatId]![date]!
                                              .reversed
                                              .toList();
                                          return Column(
                                            children: [
                                              //todo display the date with it's messages for a single day
                                              MessagesDate(date: date),
                                              10.verticalSpace,
                                              ListView.builder(
                                                  itemBuilder:
                                                      (context, innerIndex) {
                                                    // ,
                                                    //  widget.receiverName,
                                                    //  widget.senderPhoto,
                                                    //  widget.receiverPhoto,
                                                    return Column(
                                                      children: [
                                                        getTheMessageWidget(
                                                          message: messages[
                                                              innerIndex],
                                                          senderName:
                                                              widget.senderName,
                                                          receiverName: widget
                                                              .receiverName,
                                                          receiverPhoto: widget
                                                              .receiverPhoto,
                                                          senderPhoto: widget
                                                              .senderPhoto,
                                                        ),
                                                        messages[min(
                                                                    innerIndex +
                                                                        1,
                                                                    messages.length -
                                                                        1)]
                                                                .isFirstMessage
                                                            ? 30.verticalSpace
                                                            : 10.verticalSpace,
                                                      ],
                                                    );
                                                  },
                                                  shrinkWrap: true,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  itemCount: messages.length)
                                            ],
                                          );
                                        },
                                        itemCount: chatState
                                            .newSortedChatsByDate![
                                                widget.chatId]!
                                            .length,
                                      ),
                                    ),
                                  ],
                                );
                              })));
                },
              ),
            ),
            BlocBuilder<AppBloc, AppState>(
              buildWhen: (p, c) => p.thereIsReply != c.thereIsReply,
              builder: (context, state) {
//                flutterToast.s
                return ChatInputField(
                  channelId: chat.id!,
                  senderName: widget.senderName,
                  channelPusherName: chat.pusherChannelName ?? '',
                  senderUserImage: widget.senderPhoto,
                  onSendFile: (File file, String type) {
                    String id = const Uuid().v4();
                    FileSaving().saveFileToSpecificDirectory(file);
                    ChannelMember member = chat.channelMembers!.firstWhere(
                        (element) =>
                            element.userId != _prefsRepository.myChatId);
                    String fileName = 'Trydos-${DateTime.now()}';
                    chatBloc.add(UploadFileEvent(
                        file: file,
                        channelId: widget.chatId,
                        fileName: fileName,
                        filePath: type == 'image'
                            ? 'images/test'
                            : type == 'file'
                                ? 'files/test'
                                : type == 'video'
                                    ? 'videos/test'
                                    : 'voices/test',
                        messageType: type == 'image'
                            ? 'ImageMessage'
                            : type == 'file'
                                ? 'FileMessage'
                                : type == 'video'
                                    ? 'VideoMessage'
                                    : 'VoiceMessage',
                        isForward: false,
                        senderParentMessageId: state.senderParentMessageId,
                        parentMessageId:
                            state.thereIsReply ? state.messageId : null,
                        messageId: id,
                        parentMessageContent: type == 'image'
                            ? 'Photo'
                            : type == 'file'
                                ? 'File'
                                : type == 'video'
                                    ? 'Video'
                                    : 'Voice',
                        receiverUserId: member.userId));
                    BlocProvider.of<AppBloc>(context).add(RefreshChatInputField(
                        false, '', false,
                        messageId: null,
                        message: null,
                        senderParentMessageId: null,
                        imageUrl: null,
                        time: null));
                  },
                  onSendMessage: (String message) {
                    String id = const Uuid().v4();
                    ChannelMember member = chat.channelMembers!.firstWhere(
                        (element) =>
                            element.userId != _prefsRepository.myChatId);
//                    print('there : ${state.thereIsReply}');
                    chatBloc.add(SendMessageEvent(
                        messageType: 'TextMessage',
                        channelId: widget.chatId,
                        isForward: false,
                        parentMessageId:
                            state.thereIsReply ? state.messageId : null,
                        content: message,
                        messageId: id,
                        senderParentMessageId: state.senderParentMessageId,
                        parentMessageContent: state.message,
                        receiverUserId: member.userId));
                    BlocProvider.of<AppBloc>(context).add(RefreshChatInputField(
                        false, '', false,
                        messageId: null,
                        message: null,
                        senderParentMessageId: null,
                        imageUrl: null,
                        time: null));
                    // rebuildMessage.value = data.length;
                  },
                );
              },
            ),
            0.2.verticalSpace
          ],
        ));
  }

  String formatDate(String dateStr) {
    DateTime date = DateTime.parse(dateStr);
    DateTime now = DateTime.now();
    Duration difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'TODAY';
    } else if (difference.inDays == 1) {
      return 'YESTERDAY';
    } else {
      return dateStr;
    }
  }

  // void dealWithExistMessage(
  //   String senderName,
  //   String receiverName,
  //   String? senderPhoto,
  //   String? receiverPhoto, {
  //   required Message element,
  // }) async {
  //   int index = getMessageIndex(element.id, null);
  //   data.removeAt(index);
  //   data.removeAt(index - 1);
  //   bool thereIsDate = (data[index - 2] is MessagesDate);
  //   await addTheMessageWidget(index - 1, element, senderName, receiverName,
  //       senderPhoto, receiverPhoto, getIsFirstMessage(element.id), thereIsDate);
  //   index =
  //       getMessageIndex(element.parentMessageId, element.localParentMessageId);
  //   rebuildMessage.value = data.length;
  //   scrollToIndex(index);
  // }

//   void preProcessingOfMessaging(
//       List<Message> messages,
//       int insertPosition,
//       bool scrollToLastMessage,
//       String senderName,
//       String receiverName,
//       String? senderPhoto,
//       String? receiverPhoto,
//       {bool fromGetMessagesBetween = false,
//       Message? replacedReplyMessage}) async {
//     if (messages.isEmpty && replacedReplyMessage == null) {
//       return;
//     }
//     if (data.isNotEmpty) {
//       data.removeLast();
//     }
//
//     //todo here bring all the days that have messages send on it and put
//     Map<String, List<Message>> newMessagesByDate = {};
//
//     for (int i = 0; i < messages.length; i++) {
//       Message element = messages[i];
//       final zonedDate = HelperFunctions.replaceArabicNumber(
//           DateFormat("yyyy-MM-dd")
//               .format(HelperFunctions.getZonedDate(element.createdAt!)));
//       if (!newMessagesByDate.containsKey(zonedDate)) {
//         newMessagesByDate[zonedDate] = [];
//       }
//       newMessagesByDate[zonedDate]!.add(element);
//     }
//     for (String sendDate in newMessagesByDate.keys) {
//       bool thereIsDate = false;
//       if (!messagesByDate.containsKey(sendDate) && insertPosition == -1) {
//         thereIsDate = true;
//         data.insert(data.length, 10.verticalSpace);
//         data.insert(data.length, MessagesDate(date: formatDate(sendDate)));
//         messagesByDate[sendDate] = newMessagesByDate[sendDate] ?? [];
//       }
//       bool isFirstMessage = false;
//       for (int i = 0; i < newMessagesByDate[sendDate]!.length; i++) {
//         Message element = newMessagesByDate[sendDate]![i];
//         isFirstMessage = false;
//         if (insertPosition == 0) {
//           //todo here we check if the next message coming from the other use so its the new  first message in the chat
//           //todo cause he change the sender so change the owner of the message
//           isFirstMessage = newMessagesByDate[sendDate]![
//                       math.min(i + 1, newMessagesByDate[sendDate]!.length - 1)]
//                   .senderUserId !=
//               element.senderUserId;
//         } else {
//           isFirstMessage = !(element.senderUserId == currentMessageSenderId);
//         }
//         if (currentMessageSenderId == null && insertPosition == -1) {
//           isFirstMessage = true;
//         }
//         if (i == newMessagesByDate[sendDate]!.length - 1 &&
//             insertPosition == 0) {
//           isFirstMessage = true;
//           thereIsDate = true;
//         }
// //        print('$i : $isFirstMessage');
//         await addTheMessageWidget(
//             insertPosition,
//             element,
//             senderName,
//             receiverName,
//             senderPhoto,
//             receiverPhoto,
//             isFirstMessage,
//             thereIsDate);
//       }
//       thereIsDate = false;
//       if (!messagesByDate.containsKey(sendDate) && insertPosition == 0) {
// //        print(sendDate);
//         data.insert(0, MessagesDate(date: formatDate(sendDate)));
//         data.insert(0, 10.verticalSpace);
//         messagesByDate[sendDate] = newMessagesByDate[sendDate] ?? [];
//       }
//     }
//     if (!fromGetMessagesBetween) {
//       currentMessageSenderId = messages[0].senderUserId;
//     }
//     if (scrollToLastMessage) {}
//     data.add(30.verticalSpace);
//     if (replacedReplyMessage != null) {
//       dealWithExistMessage(widget.senderName, widget.receiverName,
//           widget.senderPhoto, widget.receiverPhoto,
//           element: replacedReplyMessage);
//       rebuildMessage.value = data.length;
//     } else {
//       rebuildMessage.value = data.length;
//     }
//   }
//
//   addTheMessageWidget(
//       int insertPosition,
//       Message element,
//       String senderName,
//       String receiverName,
//       String? senderPhoto,
//       String? receiverPhoto,
//       bool isFirstMessage,
//       bool thereIsDate) async {
//     String messageType = element.messageType!.name.toString();
//     MessageStatus? messageStatus = element.messageStatus
//         ?.firstWhere((e) => e.userId != _prefsRepository.myChatId);
// //    print('ee: ${element.parentMessageId}');
// //    print('ee: ${element.parentMessage}');
//     if (insertPosition == -1) {
//       data.insert(
//           data.length,
//           thereIsDate
//               ? 10.verticalSpace
//               : isFirstMessage
//                   ? 30.verticalSpace
//                   : 10.verticalSpace);
//     }
//     if (element.parentMessageId != null && element.parentMessage != null) {
//       Message parentMessage = element.parentMessage!;
//       MessageStatus? parentMessageStatus = parentMessage.messageStatus
//           ?.firstWhere((e) => e.userId != _prefsRepository.myChatId);
//       int index = getMessageIndex(
//           element.parentMessageId, element.localParentMessageId);
//       if (parentMessage.senderUserId != element.senderUserId) {
//         data.insert(
//             insertPosition == -1 ? data.length : insertPosition,
//             ReplayMessage(
//                 messageDate: element.createdAt!,
//                 scrollToMessage: () => scrollToIndex(index,
//                     currentId: element.id!,
//                     parentMessageId: element.parentMessageId!),
//                 messageId: element.parentMessageId!,
//                 answeredFilePath: element.mediaMessageContent?[0].filePath,
//                 messageAnswer: element.messageContent?.content,
//                 isFirstMessage: isFirstMessage,
//                 replayedPhoto:
//                     parentMessage.id == _prefsRepository.myChatId.toString()
//                         ? senderPhoto
//                         : receiverPhoto,
//                 replayedName:
//                     parentMessage.id == _prefsRepository.myChatId.toString()
//                         ? senderName
//                         : receiverName,
//                 senderAnswerName: senderName,
//                 senderAnswerPhoto: senderPhoto,
//                 isISentFirstMessage:
//                     parentMessage.senderUserId == _prefsRepository.myChatId,
//                 isSent: element.senderUserId == _prefsRepository.myChatId,
//                 parentSenderId: parentMessage.senderUserId!,
//                 isReplayedMessageRead: parentMessageStatus?.isWatched ?? false,
//                 isReplayedMessageReceived:
//                     (parentMessageStatus?.isReceived ?? 0) == 1,
//                 isAnswerMessageRead: messageStatus?.isWatched ?? false,
//                 isAnswerMessageReceived: (messageStatus?.isReceived ?? 0) == 1,
//                 answeredFile: element.file,
//                 message: parentMessage.messageContent?.content == null
//                     ? parentMessage.messageType!.name == 'ImageMessage'
//                         ? 'Photo'
//                         : parentMessage.messageType!.name == 'FileMessage'
//                             ? 'File'
//                             : parentMessage.messageType!.name == 'VideoMessage'
//                                 ? 'Video'
//                                 : 'Voice'
//                     : parentMessage.messageContent!.content.toString(),
//                 messageAnswerId: element.id!));
//       } else {
//         data.insert(
//             insertPosition == -1 ? data.length : insertPosition,
//             ReplayOnMeMessage(
//                 messageDate: element.createdAt!,
//                 messageId: element.parentMessageId!,
//                 answeredFilePath: element.mediaMessageContent?[0].filePath,
//                 messageAnswer: element.messageContent?.content,
//                 answeredFile: element.file,
//                 scrollToMessage: () => scrollToIndex(index,
//                     currentId: element.id!,
//                     parentMessageId: element.parentMessageId!),
//                 isISentFirstMessage:
//                     parentMessage.senderUserId == _prefsRepository.myChatId,
//                 isSent: element.senderUserId == _prefsRepository.myChatId,
//                 isFirstMessage: isFirstMessage,
//                 parentSenderId: parentMessage.senderUserId!,
//                 replayedPhoto:
//                     parentMessage.id == _prefsRepository.myChatId.toString()
//                         ? senderPhoto
//                         : receiverPhoto,
//                 replayedName:
//                     parentMessage.id == _prefsRepository.myChatId.toString()
//                         ? senderName
//                         : receiverName,
//                 senderAnswerName: senderName,
//                 senderAnswerPhoto: senderPhoto,
//                 isReplayedMessageRead: parentMessageStatus?.isWatched ?? false,
//                 isReplayedMessageReceived:
//                     (parentMessageStatus?.isReceived ?? 0) == 1,
//                 isAnswerMessageRead: messageStatus?.isWatched ?? false,
//                 isAnswerMessageReceived: (messageStatus?.isReceived ?? 0) == 1,
//                 message: parentMessage.messageContent?.content == null
//                     ? parentMessage.messageType!.name == 'ImageMessage'
//                         ? 'Photo'
//                         : parentMessage.messageType!.name == 'FileMessage'
//                             ? 'File'
//                             : parentMessage.messageType!.name == 'VideoMessage'
//                                 ? 'Video'
//                                 : 'Voice'
//                     : parentMessage.messageContent!.content.toString(),
//                 messageAnswerId: element.id!));
//       }
//     } else {
//       switch (messageType) {
//         case 'TextMessage':
//           data.insert(
//               insertPosition == -1 ? data.length : insertPosition,
//               TextMessage(
//                 message: element.messageContent!.content.toString(),
//                 messageId: element.messageContent!.messageId.toString(),
//                 senderId: element.senderUserId!,
//                 isSent: element.receiverUserId != _prefsRepository.myChatId,
//                 isRead: messageStatus?.isWatched ?? false,
//                 userMessageName:
//                     element.receiverUserId != _prefsRepository.myChatId
//                         ? senderName
//                         : receiverName,
//                 userMessagePhoto:
//                     element.receiverUserId != _prefsRepository.myChatId
//                         ? senderPhoto
//                         : receiverPhoto,
//                 isReceived: (messageStatus?.isReceived ?? 0) == 1,
//                 isFirstMessage: isFirstMessage,
//                 time: element.createdAt!,
//                 isForwarded: element.isForward == 1,
//               ));
//           break;
//         case 'ImageMessage':
//           if (element.file != null) {
//             data.insert(
//               insertPosition == -1 ? data.length : insertPosition,
//               ImageMessage(
//                 isSent: element.receiverUserId != _prefsRepository.myChatId,
//                 imageFile: element.file,
//                 messageId: element.id.toString(),
//                 senderId: element.senderUserId!,
//                 time: element.createdAt!,
//                 userMessageName:
//                     element.receiverUserId != _prefsRepository.myChatId
//                         ? senderName
//                         : receiverName,
//                 userMessagePhoto:
//                     element.receiverUserId != _prefsRepository.myChatId
//                         ? senderPhoto
//                         : receiverPhoto,
//                 isFirstMessage: isFirstMessage,
//                 isRead: messageStatus?.isWatched ?? false,
//                 isReceived: (messageStatus?.isReceived ?? 0) == 1,
//                 isLocalMessage: true,
//                 isForwarded: element.isForward == 1,
//               ),
//             );
//           } else {
// //            print('length : ${element.mediaMessageContent?.length}');
//             for (int i = 0;
//                 i < (element.mediaMessageContent?.length ?? 0);
//                 i++) {
//               File? file = await FileSaving().checkExistence(
//                   element.mediaMessageContent![i].filePath,
//                   element.mediaMessageContent![i].fileName!,
//                   download: false);
//               data.insert(
//                 insertPosition == -1 ? data.length : insertPosition,
//                 ImageMessage(
//                   isSent: element.receiverUserId != _prefsRepository.myChatId,
//                   imageUrl: element.mediaMessageContent![i].filePath,
//                   imageFile: file,
//                   messageId:
//                       element.mediaMessageContent![i].messageId.toString(),
//                   time: element.createdAt!,
//                   senderId: element.senderUserId!,
//                   userMessageName:
//                       element.receiverUserId != _prefsRepository.myChatId
//                           ? senderName
//                           : receiverName,
//                   userMessagePhoto:
//                       element.receiverUserId != _prefsRepository.myChatId
//                           ? senderPhoto
//                           : receiverPhoto,
//                   isRead: messageStatus?.isWatched ?? false,
//                   isReceived: (messageStatus?.isReceived ?? 0) == 1,
//                   isFirstMessage: isFirstMessage,
//                   isLocalMessage: file != null,
//                   isForwarded: element.isForward == 1,
//                 ),
//               );
//               if (i != element.mediaMessageContent!.length - 1) {
//                 data.insert(insertPosition == -1 ? data.length : insertPosition,
//                     10.verticalSpace);
//               }
//             }
//           }
//           break;
//         case 'VideoMessage':
//           if (element.file != null) {
//             data.insert(
//               insertPosition == -1 ? data.length : insertPosition,
//               VideoMessage(
//                 isSent: element.receiverUserId != _prefsRepository.myChatId,
//                 videoFile: element.file,
//                 messageId: element.id.toString(),
//                 senderId: element.senderUserId!,
//                 time: element.createdAt!,
//                 userMessageName:
//                     element.receiverUserId != _prefsRepository.myChatId
//                         ? senderName
//                         : receiverName,
//                 userMessagePhoto:
//                     element.receiverUserId != _prefsRepository.myChatId
//                         ? senderPhoto
//                         : receiverPhoto,
//                 isFirstMessage: isFirstMessage,
//                 isRead: messageStatus?.isWatched ?? false,
//                 isReceived: (messageStatus?.isReceived ?? 0) == 1,
//                 isLocalMessage: true,
//                 isForwarded: element.isForward == 1,
//               ),
//             );
//           } else {
// //            print('length : ${element.mediaMessageContent?.length}');
//             for (int i = 0;
//                 i < (element.mediaMessageContent?.length ?? 0);
//                 i++) {
//               File? file = await FileSaving().checkExistence(
//                   element.mediaMessageContent![i].filePath,
//                   element.mediaMessageContent![i].fileName!,
//                   download: false);
//               data.insert(
//                 insertPosition == -1 ? data.length : insertPosition,
//                 VideoMessage(
//                   isSent: element.receiverUserId != _prefsRepository.myChatId,
//                   videoUrl: element.mediaMessageContent![i].filePath,
//                   videoFile: file,
//                   messageId:
//                       element.mediaMessageContent![i].messageId.toString(),
//                   time: element.createdAt!,
//                   senderId: element.senderUserId!,
//                   userMessageName:
//                       element.receiverUserId != _prefsRepository.myChatId
//                           ? senderName
//                           : receiverName,
//                   userMessagePhoto:
//                       element.receiverUserId != _prefsRepository.myChatId
//                           ? senderPhoto
//                           : receiverPhoto,
//                   isRead: messageStatus?.isWatched ?? false,
//                   isReceived: (messageStatus?.isReceived ?? 0) == 1,
//                   isFirstMessage: isFirstMessage,
//                   isLocalMessage: file != null,
//                   isForwarded: element.isForward == 1,
//                 ),
//               );
//               if (i != element.mediaMessageContent!.length - 1) {
//                 data.insert(insertPosition == -1 ? data.length : insertPosition,
//                     10.verticalSpace);
//               }
//             }
//           }
//           break;
//         case 'VoiceMessage':
//           if (element.file != null) {
//             data.insert(
//               insertPosition == -1 ? data.length : insertPosition,
//               VoiceMessage(
//                 isSent: element.receiverUserId != _prefsRepository.myChatId,
//                 file: element.file,
//                 messageId: element.id.toString(),
//                 senderId: element.senderUserId!,
//                 userMessageName:
//                     element.receiverUserId != _prefsRepository.myChatId
//                         ? senderName
//                         : receiverName,
//                 userMessagePhoto:
//                     element.receiverUserId != _prefsRepository.myChatId
//                         ? senderPhoto
//                         : receiverPhoto,
//                 time: element.createdAt!,
//                 isRead: messageStatus?.isWatched ?? false,
//                 isReceived: (messageStatus?.isReceived ?? 0) == 1,
//                 isFirstMessage: isFirstMessage,
//                 isForwarded: element.isForward == 1,
//               ),
//             );
//           } else {
//             for (int i = 0;
//                 i < (element.mediaMessageContent?.length ?? 0);
//                 i++) {
//               String fileName = element.mediaMessageContent![i].fileName ??
//                   element.mediaMessageContent![i].filePath!.split('/').last;
//               File? file = await FileSaving().checkExistence(
//                   element.mediaMessageContent![i].filePath, fileName,
//                   download: false);
//               data.insert(
//                 insertPosition == -1 ? data.length : insertPosition,
//                 VoiceMessage(
//                   isSent: element.receiverUserId != _prefsRepository.myChatId,
//                   fileUrl: element.mediaMessageContent![i].filePath,
//                   messageId:
//                       element.mediaMessageContent![i].messageId.toString(),
//                   time: element.createdAt!,
//                   senderId: element.senderUserId!,
//                   userMessageName:
//                       element.receiverUserId != _prefsRepository.myChatId
//                           ? senderName
//                           : receiverName,
//                   userMessagePhoto:
//                       element.receiverUserId != _prefsRepository.myChatId
//                           ? senderPhoto
//                           : receiverPhoto,
//                   file: file,
//                   isFirstMessage: isFirstMessage,
//                   isRead: messageStatus?.isWatched ?? false,
//                   isReceived: (messageStatus?.isReceived ?? 0) == 1,
//                   isForwarded: element.isForward == 1,
//                 ),
//               );
//               if (i != element.mediaMessageContent!.length - 1) {
//                 data.insert(insertPosition == -1 ? data.length : insertPosition,
//                     10.verticalSpace);
//               }
//             }
//           }
//           break;
//         case 'FileMessage':
//           if (element.file != null) {
//             String fileName = element.file!.path.split('/').last;
//             data.insert(
//               insertPosition == -1 ? data.length : insertPosition,
//               DocumentMessage(
//                 isSent: element.receiverUserId != _prefsRepository.myChatId,
//                 documentFile: element.file,
//                 fileName: fileName,
//                 messageId: element.id.toString(),
//                 senderId: element.senderUserId!,
//                 userMessageName:
//                     element.receiverUserId != _prefsRepository.myChatId
//                         ? senderName
//                         : receiverName,
//                 userMessagePhoto:
//                     element.receiverUserId != _prefsRepository.myChatId
//                         ? senderPhoto
//                         : receiverPhoto,
//                 time: element.createdAt!,
//                 isRead: messageStatus?.isWatched ?? false,
//                 isReceived: (messageStatus?.isReceived ?? 0) == 1,
//                 isFirstMessage: isFirstMessage,
//                 isForwarded: element.isForward == 1,
//               ),
//             );
//           } else {
//             for (int i = 0;
//                 i < (element.mediaMessageContent?.length ?? 0);
//                 i++) {
//               String fileName = element.mediaMessageContent![i].fileName ??
//                   element.file!.path.split('/').last;
//               File? file = await FileSaving().checkExistence(
//                   element.mediaMessageContent![i].filePath, fileName,
//                   download: false);
//               data.insert(
//                 insertPosition == -1 ? data.length : insertPosition,
//                 DocumentMessage(
//                   isSent: element.receiverUserId != _prefsRepository.myChatId,
//                   documentFile: file,
//                   documentFileUrl: element.mediaMessageContent![i].filePath,
//                   fileName: fileName,
//                   messageId:
//                       element.mediaMessageContent![i].messageId.toString(),
//                   time: element.createdAt!,
//                   senderId: element.senderUserId!,
//                   userMessageName:
//                       element.receiverUserId != _prefsRepository.myChatId
//                           ? senderName
//                           : receiverName,
//                   userMessagePhoto:
//                       element.receiverUserId != _prefsRepository.myChatId
//                           ? senderPhoto
//                           : receiverPhoto,
//                   isFirstMessage: isFirstMessage,
//                   isRead: messageStatus?.isWatched ?? false,
//                   isReceived: (messageStatus?.isReceived ?? 0) == 1,
//                   isForwarded: element.isForward == 1,
//                 ),
//               );
//               if (i != element.mediaMessageContent!.length - 1) {
//                 data.insert(insertPosition == -1 ? data.length : insertPosition,
//                     10.verticalSpace);
//               }
//             }
//           }
//       }
//     }
// //    print('isFirst: $isFirstMessage');
//     if (insertPosition != -1) {
//       data.insert(
//           insertPosition,
//           thereIsDate
//               ? 10.verticalSpace
//               : isFirstMessage
//                   ? 30.verticalSpace
//                   : 10.verticalSpace);
//     }
//   }

  int getMessageIndex(String? messageId, String? localParentMessageId) {
    return data.indexWhere((e) {
      if (e is TextMessage) {
        return e.messageId == messageId || e.messageId == localParentMessageId;
      } else if (e is ImageMessage) {
        return e.messageId == messageId || e.messageId == localParentMessageId;
      } else if (e is VoiceMessage) {
        return e.messageId == messageId || e.messageId == localParentMessageId;
      } else if (e is VideoMessage) {
        return e.messageId == messageId || e.messageId == localParentMessageId;
      } else if (e is DocumentMessage) {
        return e.messageId == messageId || e.messageId == localParentMessageId;
      } else if (e is ReplayMessage) {
        return e.messageAnswerId == messageId ||
            e.messageAnswerId == localParentMessageId;
      } else if (e is ReplayOnMeMessage) {
        return e.messageAnswerId == messageId ||
            e.messageAnswerId == localParentMessageId;
      } else {
        return false;
      }
    });
  }

  bool getIsFirstMessage(String? messageId) {
    for (var e in data) {
      if (e is TextMessage && e.messageId == messageId) {
        return e.isFirstMessage;
      } else if (e is ImageMessage && e.messageId == messageId) {
        return e.isFirstMessage;
      } else if (e is VoiceMessage && e.messageId == messageId) {
        return e.isFirstMessage;
      } else if (e is VideoMessage && e.messageId == messageId) {
        return e.isFirstMessage;
      } else if (e is DocumentMessage && e.messageId == messageId) {
        return e.isFirstMessage;
      } else if (e is ReplayMessage && e.messageId == messageId) {
        return e.isFirstMessage;
      } else if (e is ReplayOnMeMessage && e.messageId == messageId) {
        return e.isFirstMessage;
      }
    }
    return false;
  }

  void dealWithMessageOptions(int index, String? messageId) {
    if (index == -1) {
      replayMessage(
          chat.messages!.firstWhere((element) => element.id == messageId),
          _prefsRepository.myChatId);
    } else if (index == 0) {
      forwardMessageMethod(
          chat.messages!.firstWhere((element) => element.id == messageId));
    }
  }

  void forwardMessageMethod(Message message) {
    context.push(
      GRouter.config.applicationRoutes.kChatPage +
          '?hideCallsAndStories=true&description=Forward To...',
      extra: (int receiverId, String channelId) {
        if (message.messageType!.name == 'TextMessage') {
          chatBloc.add(SendMessageEvent(
              messageType: message.messageType!.name,
              channelId: channelId,
              isForward: true,
              parentMessageId: null,
              content: message.messageContent!.content,
              messageId: message.id!,
              senderParentMessageId: null,
              parentMessageContent: null,
              receiverUserId: receiverId));
        } else {
          chatBloc.add(SendMessageEvent(
              channelId: channelId,
              mediaContent: [
                {
                  'file_path': message.mediaMessageContent?[0].filePath,
                  'file_name': message.mediaMessageContent?[0].fileName,
                }
              ],
              messageType: message.messageType!.name,
              isForward: true,
              senderParentMessageId: null,
              parentMessageId: null,
              messageId: message.id!,
              parentMessageContent: null,
              receiverUserId: receiverId));
        }
        // BlocProvider.of<AppBloc>(context).add(RefreshChatInputField(
        //     false, '', false,
        //     messageId: null,
        //     message: null,
        //     senderParentMessageId: null,
        //     imageUrl: null,
        //     time: null));
      },
    );
  }

  void replayMessage(Message message, int? myChatId) {
    BlocProvider.of<AppBloc>(context).add(RefreshChatInputField(
        true,
        message.messageType!.name == 'TextMessage'
            ? 'text'
            : message.messageType!.name == 'TextMessage'
                ? 'image'
                : 'voice',
        message.senderUserId == myChatId,
        messageId: message.id,
        senderParentMessageId: message.senderUserId,
        message: message.messageContent?.content ??
            (message.messageType!.name == 'TextMessage' ? 'Photo' : 'Voice'),
        imageUrl:
            message.mediaMessageContent?.first.filePath ?? message.file?.path,
        time: message.createdAt));
  }

  void scrollToIndex(int index,
      {String? currentId,
      String? parentMessageId,
      Duration? duration,
      AutoScrollPosition? preferPosition}) {
//    print('iii:  $index');
    if (index == -1) {
      chatBloc.add(GetAllMessagesBetweenEvent(
          firstMessageId: parentMessageId!,
          scrollToParentMessage: true,
          secondMessageId: currentId!,
          channelId: widget.chatId));
      return;
    }
    currentScrolledIndex = index;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await autoScrollController.scrollToIndex(index,
          duration: duration ?? const Duration(milliseconds: 250),
          preferPosition: preferPosition ?? AutoScrollPosition.middle);
    });
    Future.delayed(const Duration(milliseconds: 1000)).then((value) {
      currentScrolledIndex = -1;
      rebuildMessage.value = 2 * data.length;
    });
  }

  void _loadMoreMessages() {
    chatBloc.add(GetMessagesForChatEvent(channelId: widget.chatId));
  }

  getTheMessageWidget({
    required Message message,
    required String senderName,
    required String receiverName,
    String? senderPhoto,
    String? receiverPhoto,
  }) {
    String? filePath = message.mediaMessageContent?[0].filePath;
    if (filePath!=null &&  _prefsRepository.isAFilePathExist(filePath)) {
      File? file= File(FileSaving().getFilePath(filePath.split('/').last));
      message = message.copyWith(file: file , checkedExistence: true);
    }
    MessageStatus? messageStatus = message.messageStatus
        ?.firstWhere((e) => e.userId != _prefsRepository.myChatId);
    if (message.parentMessageId != null && message.parentMessage != null) {
      Message parentMessage = message.parentMessage!;
      MessageStatus? parentMessageStatus = parentMessage.messageStatus
          ?.firstWhere((e) => e.userId != _prefsRepository.myChatId);
      int index = getMessageIndex(
          message.parentMessageId, message.localParentMessageId);
      if (parentMessage.senderUserId != message.senderUserId) {
        return ReplayMessage(
            messageDate: message.createdAt!,
            scrollToMessage: () => scrollToIndex(index,
                currentId: message.id!,
                parentMessageId: message.parentMessageId!),
            messageId: message.parentMessageId!,
            answeredFilePath: message.mediaMessageContent?[0].filePath,
            messageAnswer: message.messageContent?.content,
            isFirstMessage: message.isFirstMessage,
            replayedPhoto:
                parentMessage.id == _prefsRepository.myChatId.toString()
                    ? senderPhoto
                    : receiverPhoto,
            replayedName:
                parentMessage.id == _prefsRepository.myChatId.toString()
                    ? senderName
                    : receiverName,
            senderAnswerName: senderName,
            senderAnswerPhoto: senderPhoto,
            isISentFirstMessage:
                parentMessage.senderUserId == _prefsRepository.myChatId,
            isSent: message.senderUserId == _prefsRepository.myChatId,
            parentSenderId: parentMessage.senderUserId!,
            isReplayedMessageRead: parentMessageStatus?.isWatched ?? false,
            isReplayedMessageReceived:
                (parentMessageStatus?.isReceived ?? 0) == 1,
            isAnswerMessageRead: messageStatus?.isWatched ?? false,
            isAnswerMessageReceived: (messageStatus?.isReceived ?? 0) == 1,
            answeredFile: message.file,
            message: parentMessage.messageContent?.content == null
                ? parentMessage.messageType!.name == 'ImageMessage'
                    ? 'Photo'
                    : parentMessage.messageType!.name == 'FileMessage'
                        ? 'File'
                        : parentMessage.messageType!.name == 'VideoMessage'
                            ? 'Video'
                            : 'Voice'
                : parentMessage.messageContent!.content.toString(),
            messageAnswerId: message.id!);
      } else {
        return ReplayOnMeMessage(
            messageDate: message.createdAt!,
            messageId: message.parentMessageId!,
            answeredFilePath: message.mediaMessageContent?[0].filePath,
            messageAnswer: message.messageContent?.content,
            answeredFile: message.file,
            scrollToMessage: () => scrollToIndex(index,
                currentId: message.id!,
                parentMessageId: message.parentMessageId!),
            isISentFirstMessage:
                parentMessage.senderUserId == _prefsRepository.myChatId,
            isSent: message.senderUserId == _prefsRepository.myChatId,
            isFirstMessage: message.isFirstMessage ?? false,
            parentSenderId: parentMessage.senderUserId!,
            replayedPhoto:
                parentMessage.id == _prefsRepository.myChatId.toString()
                    ? senderPhoto
                    : receiverPhoto,
            replayedName:
                parentMessage.id == _prefsRepository.myChatId.toString()
                    ? senderName
                    : receiverName,
            senderAnswerName: senderName,
            senderAnswerPhoto: senderPhoto,
            isReplayedMessageRead: parentMessageStatus?.isWatched ?? false,
            isReplayedMessageReceived:
                (parentMessageStatus?.isReceived ?? 0) == 1,
            isAnswerMessageRead: messageStatus?.isWatched ?? false,
            isAnswerMessageReceived: (messageStatus?.isReceived ?? 0) == 1,
            message: parentMessage.messageContent?.content == null
                ? parentMessage.messageType!.name == 'ImageMessage'
                    ? 'Photo'
                    : parentMessage.messageType!.name == 'FileMessage'
                        ? 'File'
                        : parentMessage.messageType!.name == 'VideoMessage'
                            ? 'Video'
                            : 'Voice'
                : parentMessage.messageContent!.content.toString(),
            messageAnswerId: message.id!);
      }
    } else {
      switch (message.messageType!.name) {
        case 'TextMessage':
          return TextMessage(
            message: message.messageContent!.content.toString(),
            messageId: message.id!,
            senderId: message.senderUserId!,
            isSent: message.receiverUserId != _prefsRepository.myChatId,
            isRead: messageStatus?.isWatched ?? false,
            userMessageName: message.receiverUserId != _prefsRepository.myChatId
                ? senderName
                : receiverName,
            userMessagePhoto:
                message.receiverUserId != _prefsRepository.myChatId
                    ? senderPhoto
                    : receiverPhoto,
            isReceived: (messageStatus?.isReceived ?? 0) == 1,
            isFirstMessage: message.isFirstMessage,
            time: message.createdAt!,
            isForwarded: message.isForward == 1,
          );
        case 'ImageMessage':
          return ImageMessage(
            isSent: message.receiverUserId != _prefsRepository.myChatId,
            imageFile: message.file,
            messageId: message.id.toString(),
            senderId: message.senderUserId!,
            imageUrl: message.mediaMessageContent?[0].filePath,
            time: message.createdAt!,
            userMessageName: message.receiverUserId != _prefsRepository.myChatId
                ? senderName
                : receiverName,
            userMessagePhoto:
                message.receiverUserId != _prefsRepository.myChatId
                    ? senderPhoto
                    : receiverPhoto,
            isFirstMessage: message.isFirstMessage,
            isRead: messageStatus?.isWatched ?? false,
            isReceived: (messageStatus?.isReceived ?? 0) == 1,
            isLocalMessage: true,
            isForwarded: message.isForward == 1,
          );
        case 'VideoMessage':
          return VideoMessage(
            isSent: message.receiverUserId != _prefsRepository.myChatId,
            videoFile: message.file,
            videoUrl: message.mediaMessageContent?[0].filePath,
            messageId: message.id.toString(),
            senderId: message.senderUserId!,
            time: message.createdAt!,
            userMessageName: message.receiverUserId != _prefsRepository.myChatId
                ? senderName
                : receiverName,
            userMessagePhoto:
                message.receiverUserId != _prefsRepository.myChatId
                    ? senderPhoto
                    : receiverPhoto,
            isFirstMessage: message.isFirstMessage,
            isRead: messageStatus?.isWatched ?? false,
            isReceived: (messageStatus?.isReceived ?? 0) == 1,
            isLocalMessage: true,
            isForwarded: message.isForward == 1,
          );
        case 'VoiceMessage':
          return VoiceMessage(
            isSent: message.receiverUserId != _prefsRepository.myChatId,
            file: message.file,
            fileUrl: message.mediaMessageContent?[0].filePath,
            messageId: message.id.toString(),
            senderId: message.senderUserId!,
            userMessageName: message.receiverUserId != _prefsRepository.myChatId
                ? senderName
                : receiverName,
            userMessagePhoto:
                message.receiverUserId != _prefsRepository.myChatId
                    ? senderPhoto
                    : receiverPhoto,
            time: message.createdAt!,
            isRead: messageStatus?.isWatched ?? false,
            isReceived: (messageStatus?.isReceived ?? 0) == 1,
            isFirstMessage: message.isFirstMessage,
            isForwarded: message.isForward == 1,
          );
        case 'FileMessage':
          String fileName = message.file?.path.split('/').last ??
              message.mediaMessageContent![0].filePath!.split('/').last;
          return DocumentMessage(
            isSent: message.receiverUserId != _prefsRepository.myChatId,
            documentFile: message.file,
            fileName: fileName,
            documentFileUrl: message.mediaMessageContent?[0].filePath,
            messageId: message.id.toString(),
            senderId: message.senderUserId!,
            userMessageName: message.receiverUserId != _prefsRepository.myChatId
                ? senderName
                : receiverName,
            userMessagePhoto:
                message.receiverUserId != _prefsRepository.myChatId
                    ? senderPhoto
                    : receiverPhoto,
            time: message.createdAt!,
            isRead: messageStatus?.isWatched ?? false,
            isReceived: (messageStatus?.isReceived ?? 0) == 1,
            isFirstMessage: message.isFirstMessage,
            isForwarded: message.isForward == 1,
          );
      }
    }
  }
}

class MessagesDate extends StatelessWidget {
  const MessagesDate({Key? key, required this.date}) : super(key: key);
  final String date;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 78.w,
          height: 22,
          decoration: BoxDecoration(
            color: const Color(0xff388cff),
            borderRadius: BorderRadius.circular(7.0),
          ),
          child: Center(
            child: Text(date,
                style: context.textTheme.caption?.rr
                    .copyWith(color: context.colorScheme.white)),
          ),
        ),
      ],
    );
  }
}

class MessageActionWidget extends StatelessWidget {
  const MessageActionWidget({
    Key? key,
    required this.onTap,
    required this.focusedIndex,
    required this.myIndex,
    required this.iconUrl,
  }) : super(key: key);
  final void Function() onTap;
  final int focusedIndex;
  final int myIndex;
  final String iconUrl;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => onTap,
        child: SvgPicture.asset(
          iconUrl,
          width: focusedIndex == myIndex ? 20.sp : 15.sp,
          height: focusedIndex == myIndex ? 20 : 15,
        ));
  }
}

class MessageSubtitleWidget extends StatelessWidget {
  const MessageSubtitleWidget({
    Key? key,
    required this.focusedIndex,
  }) : super(key: key);
  final int focusedIndex;

  @override
  Widget build(BuildContext context) {
    String hoverText = '';
    switch (focusedIndex) {
      case 0:
        hoverText = 'Forward';
        break;
      case 1:
        hoverText = 'Copy';
        break;
      case 2:
        hoverText = 'Category';
        break;
      case 3:
        hoverText = 'Delete';
        break;
      case 4:
        hoverText = 'Edit';
        break;
      case 5:
        hoverText = 'Re-Remind';
        break;
    }
    return Container(
      width: 50.w,
      height: 22,
      decoration: BoxDecoration(
        color: const Color(0xff404040),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x34000000),
            offset: Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Center(
        child: Text(
          hoverText,
          style: context.textTheme.overline?.rr
              .copyWith(color: context.colorScheme.white, height: 1.4),
        ),
      ),
    );
  }
}
