import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/helper/file_saving.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/core/utils/responsive_padding.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_state.dart';
import 'package:trydos/features/calls/presentation/bloc/calls_bloc.dart';
import 'package:trydos/features/chat/presentation/pages/profile_page.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_input_field.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/document_message.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/image_message.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/reply_messge.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/reply_on_me_message.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/video_message.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/data/model/pagination_model.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../routes/router.dart';
import '../../../../service/language_service.dart';
import '../../../app/app_widgets/trydos_app_bar/app_bar_params.dart';
import '../../../app/app_widgets/trydos_app_bar/trydos_appbar.dart';
import '../../../app/blocs/app_bloc/app_bloc.dart';
import '../../../app/blocs/app_bloc/app_event.dart';
import '../../../app/my_cached_network_image.dart';
import '../../../app/my_text_widget.dart';
import '../../../calls/presentation/pages/in_app_view.dart';
import '../../../calls/presentation/utils/caller_info.dart';
import '../../data/models/my_chats_response_model.dart';
import '../manager/chat_bloc.dart';
import '../manager/chat_event.dart';
import '../manager/chat_state.dart';
import '../widgets/chat_widgets/call_message.dart';
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
  late AutoScrollController autoScrollController;

  void _scrollToBottom() {
    autoScrollController.jumpTo(0);
  }

  int? previousMessageSenderId, currentMessageSenderId;
  List<Widget> data = [];
  Map<String, List<Message>> messagesByDate = {};
  bool rebuild = true;
  DateTime lastDate = DateTime.now();
  DateTime? time;
  int countMessagesReceivedToMeNow = 0;
  late Chat chat;
  AudioPlayer _audioPlayer = AudioPlayer();
  Map<String, int> messagesIndexes = {};

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
    chatBloc.add(GetMediaCountEvent(channelId: widget.chatId));
    autoScrollController.addListener(() {
      if (rebuild) {
        rebuildMessage.value = -1;
      }
      if ((autoScrollController.offset >=
          autoScrollController.position.maxScrollExtent - 400)) {
        _loadMoreMessages();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    autoScrollController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  int currentScrolledIndex = -1;

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (details) {
      debugPrint("asfsd${details.toString()}");
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: details.toString());
    };
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _scrollToBottom();
    });
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
                                  20.w, 15, 10, 15),
                              child: SvgPicture.asset(
                                !LanguageService.rtl
                                    ? AppAssets.backFromCallSvg
                                    : AppAssets.backArrowArabic,
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
                        return Row(
                          children: [
                            MyTextWidget(
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
                              progressIndicatorBuilderWidget: TrydosLoader(),
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
                            child: MyTextWidget(
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
                                  return MyTextWidget(
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
                    BlocBuilder<CallsBloc, CallsState>(
                      builder: (context, state) => InkWell(
                        onTap: () async {
                          List<Map<String, dynamic>> info =
                              callerInfo(channelId: widget.chatId);
                          PermissionStatus microphone =
                              await Permission.microphone.request();
                          var status2 = await Permission.mediaLibrary.request();
                          PermissionStatus camera =
                              await Permission.camera.request();
                          if (microphone.isGranted &&
                              status2.isGranted &&
                              camera.isGranted) {
                            if (info[0].containsKey('currentReceiver')) {
                              GetIt.I<CallsBloc>().add(MakeCallEvent(
                                  receiverUserId:
                                      info[0]['currentReceiver'].toString(),
                                  receiverCallName: widget.fullReceiverName,
                                  chatId: widget.chatId,
                                  isVideo: true,
                                  payload: info[1]));
                            } else {
                              GetIt.I<CallsBloc>().add(MakeCallEvent(
                                  isVideo: true,
                                  receiverCallName: widget.fullReceiverName,
                                  chatId: widget.chatId,
                                  payload: info[0]));
                              //todo we have the id of the chat so we can move to the call immediately
                            }
                          } else if (microphone.isDenied ||
                              status2.isDenied ||
                              camera.isDenied) {
                            showMessage('permission denied');
                            openAppSettings();
                          }
                        },
                        child: SvgPicture.asset(
                          AppAssets.makeVideoCallSvg,
                          width: 34.w,
                          height: 25,
                        ),
                      ),
                    ),
                    30.horizontalSpace,
                    // todo CreateCallPage
                    InkWell(
                      onTap: () async {
                        List<Map<String, dynamic>> info =
                            callerInfo(channelId: widget.chatId);
                        PermissionStatus microphone =
                            await Permission.microphone.request();
                        var status2 = await Permission.mediaLibrary.request();
                        if (microphone.isGranted && status2.isGranted) {
                          //todo we have the receiver id so the chat dose not exist
                          if (info[0].containsKey('currentReceiver')) {
                            debugPrint(
                                'currentReceiver${info[0]['currentReceiver']}');

                            GetIt.I<CallsBloc>().add(MakeCallEvent(
                                receiverUserId:
                                    info[0]['currentReceiver'].toString(),
                                receiverCallName: widget.fullReceiverName,
                                chatId: widget.chatId,
                                isVideo: false,
                                payload: info[1]));

                            // GetIt.I<CallsBloc>().add(VideoCallEvent(
                            //     receiverUserId: info[0]['currentReceiver'],
                            //     payload: info[1]));
//todo we need to wait the response to get the new chat id and join the video call so the navigation will be in the listener
                          }
                          //todo else the chat already exist so we don't have the receiver id just the chat id
                          else {
                            debugPrint('widget.chatId${widget.chatId}');
                            debugPrint('info[0]${info[0]}');

                            GetIt.I<CallsBloc>().add(MakeCallEvent(
                                isVideo: false,
                                receiverCallName: widget.fullReceiverName,
                                chatId: widget.chatId,
                                payload: info[0]));
                            //todo we have the id of the chat so we can move to the call immediately
                          }
                        } else if (microphone.isDenied || status2.isDenied) {
                          showMessage('permission denied');
                          openAppSettings();
                        }
                      },
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
        body: BlocListener<ChatBloc, ChatState>(
          listenWhen: (p, c) => (p.getMessagesBetweenStatus !=
                  c.getMessagesBetweenStatus &&
              c.getMessagesBetweenStatus == GetMessagesBetweenStatus.success &&
              c.scrollToParentMessage),
          listener: (context, state) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              scrollToIndex(1);
            });
          },
          child: Column(
            children: [
              Flexible(
                child: BlocConsumer<ChatBloc, ChatState>(
                  listenWhen: (p, c) =>
                      p.sendMessageStatus != c.sendMessageStatus ||
                      (p.receiveMessageStatus != c.receiveMessageStatus &&
                          c.receiveMessageStatus ==
                              ReceiveMessageStatus.success),
                  listener: (context, state) {
                    if (state.sendMessageStatus == SendMessageStatus.loading ||
                        state.receiveMessageStatus ==
                            ReceiveMessageStatus.success) {
                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                        _scrollToBottom();
                      });
                    }
                    if (state.receiveMessageStatus ==
                            ReceiveMessageStatus.success &&
                        chat.id == state.currentChannelReceivedMessage) {
                      chatBloc.add(ReadAllMessagesEvent(widget.chatId));
                    }
                  },
                  builder: (context, chatState) {
                    chat = chatState.chats.firstWhere(
                        (element) =>
                            element.id.toString() == widget.chatId ||
                            element.localId.toString() == widget.chatId,
                        orElse: () => chatState.pinnedChats.firstWhere(
                            (element) =>
                                element.id.toString() == widget.chatId ||
                                element.localId.toString() == widget.chatId));
                    return GestureDetector(
                        onTap: () {
                          rebuildMessage.value = -1;
                        },
                        child: SafeArea(
                            child: ValueListenableBuilder<int>(
                                valueListenable: rebuildMessage,
                                builder: (context, currentIndex, _) {
                                  currentFocusedIcon.value = -2;
                                  return ValueListenableBuilder<int>(
                                      valueListenable: currentFocusedIcon,
                                      builder: (context, focusedIndex, _) {
                                        return Column(
                                          children: [
                                            chat.paginationStatus ==
                                                    PaginationStatus.loading
                                                ? TrydosLoader()
                                                : SizedBox.shrink(),
                                            chat.paginationStatus ==
                                                    PaginationStatus.loading
                                                ? 8.verticalSpace
                                                : SizedBox.shrink(),
                                            Flexible(
                                              child: ListView.builder(
                                                physics:
                                                    const ClampingScrollPhysics(),
                                                shrinkWrap: true,
                                                reverse: true,
                                                controller:
                                                    autoScrollController,
                                                itemBuilder: (context, index) {
                                                  List<Message> messages =
                                                      chatState
                                                          .newSortedChatsByDate![
                                                              chat.id
                                                                  .toString()]!
                                                          .reversed
                                                          .toList();
                                                  if (messages[index]
                                                      .isDateMessage) {
                                                    return AutoScrollTag(
                                                        key: ValueKey(index),
                                                        index: index,
                                                        controller:
                                                            autoScrollController,
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            10.verticalSpace,
                                                            MessagesDate(
                                                                date: messages[
                                                                        index]
                                                                    .dateValue),
                                                          ],
                                                        ));
                                                  }

                                                  debugPrint(
                                                      'isForward : ${messages[index].isForward}');
                                                  debugPrint(
                                                      'senderUserId : ${messages[index].senderUserId}');
                                                  debugPrint(
                                                      'myChatId : ${_prefsRepository.myChatId}');
                                                  bool isSent = messages[index]
                                                          .senderUserId ==
                                                      _prefsRepository.myChatId;
                                                  String? messageId =
                                                      messages[index].id;
                                                  messagesIndexes[
                                                      messages[index]
                                                          .id
                                                          .toString()] = index;
                                                  return AutoScrollTag(
                                                      key: ValueKey(messageId),
                                                      index: index,
                                                      controller:
                                                          autoScrollController,
                                                      child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            messages[index]
                                                                    .isFirstMessage
                                                                ? 30.verticalSpace
                                                                : 10.verticalSpace,
                                                            GestureDetector(
                                                              onLongPress: () {
                                                                if ((chatState
                                                                            .sendMessageStatus ==
                                                                        SendMessageStatus
                                                                            .loading &&
                                                                    chatState
                                                                        .currentMessage
                                                                        .contains(
                                                                            messageId))) {
                                                                  return;
                                                                }
                                                                if (messages[
                                                                            index]
                                                                        .messageType
                                                                        ?.name
                                                                        ?.contains(
                                                                            'Call') ??
                                                                    false) {
                                                                  return;
                                                                }
                                                                rebuildMessage
                                                                        .value =
                                                                    index;
                                                              },
                                                              onTap: () {
                                                                rebuildMessage
                                                                    .value = -1;
                                                              },
                                                              child: Container(
                                                                color: currentScrolledIndex ==
                                                                        index
                                                                    ? Colors
                                                                        .black12
                                                                        .withOpacity(
                                                                            0.05)
                                                                    : null,
                                                                child:
                                                                    getTheMessageWidget(
                                                                  message:
                                                                      messages[
                                                                          index],
                                                                  senderName: widget
                                                                      .senderName,
                                                                  receiverName:
                                                                      widget
                                                                          .receiverName,
                                                                  receiverPhoto:
                                                                      widget
                                                                          .receiverPhoto,
                                                                  senderPhoto:
                                                                      widget
                                                                          .senderPhoto,
                                                                ),
                                                              ),
                                                            ),
                                                            index == 0
                                                                ? 10
                                                                    .verticalSpace
                                                                : const SizedBox
                                                                    .shrink(),
                                                            currentIndex ==
                                                                    index
                                                                ? 5
                                                                    .verticalSpace
                                                                : const SizedBox
                                                                    .shrink(),
                                                            currentIndex ==
                                                                    index
                                                                ? Padding(
                                                                    padding: HWEdgeInsets.only(
                                                                        left: isSent
                                                                            ? 40
                                                                                .w
                                                                            : 20
                                                                                .w,
                                                                        top: 10,
                                                                        right: isSent
                                                                            ? 20.w
                                                                            : 40.w),
                                                                    child: GestureDetector(
                                                                        onPanDown: (details) {
                                                                          if ((details.localPosition.dx - (isSent ? 140 : 0)) <
                                                                              40) {
                                                                            currentFocusedIcon.value =
                                                                                -1;
                                                                          } else if ((details.localPosition.dx - (isSent ? 140 : 0)) >
                                                                              210.w) {
                                                                            currentFocusedIcon.value =
                                                                                5;
                                                                          } else {
                                                                            currentFocusedIcon.value =
                                                                                (details.localPosition.dx - 40 - (isSent ? 140 : 0)) ~/ 30.w;
                                                                          }
                                                                        },
                                                                        onPanEnd: (details) {
                                                                          debugPrint(
                                                                              'end');
                                                                          rebuildMessage.value =
                                                                              -1;
                                                                          dealWithMessageOptions(
                                                                              currentFocusedIcon.value,
                                                                              messageId);
                                                                        },
                                                                        onPanUpdate: (details) {
                                                                          if ((details.localPosition.dx - (isSent ? 140 : 0)) <
                                                                              40) {
                                                                            currentFocusedIcon.value =
                                                                                -1;
                                                                          } else if ((details.localPosition.dx - (isSent ? 140 : 0)) >
                                                                              210.w) {
                                                                            currentFocusedIcon.value =
                                                                                5;
                                                                          } else {
                                                                            currentFocusedIcon.value =
                                                                                (details.localPosition.dx - 40 - (isSent ? 140 : 0)) ~/ 30.w;
                                                                          }
                                                                        },
                                                                        child: Directionality(
                                                                            textDirection: TextDirection.ltr,
                                                                            child: Container(
                                                                                //color: Colors.red,
                                                                                child: Row(mainAxisAlignment: isSent ? MainAxisAlignment.end : MainAxisAlignment.start, children: [
                                                                              Column(
                                                                                children: [
                                                                                  InkWell(
                                                                                    highlightColor: const Color(0xfffafafa),
                                                                                    splashColor: const Color(0xfffafafa),
                                                                                    onTap: () {
                                                                                      currentFocusedIcon.value = -1;
                                                                                    },
                                                                                    child: InkWell(
                                                                                      onTap: () {
                                                                                        dealWithMessageOptions(-1, messageId);
                                                                                      },
                                                                                      child: Container(
                                                                                        height: 40,
                                                                                        width: 35.w,
                                                                                        decoration: BoxDecoration(
                                                                                          color: const Color(0xfffafafa),
                                                                                          borderRadius: BorderRadius.circular(12.0),
                                                                                          boxShadow: const [
                                                                                            BoxShadow(
                                                                                              color: Color(0x29000000),
                                                                                              offset: Offset(0, 2),
                                                                                              blurRadius: 10,
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                        child: Center(
                                                                                            child: SvgPicture.asset(
                                                                                          AppAssets.replyButtonLogoSvg,
                                                                                        )),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  10.verticalSpace,
                                                                                  focusedIndex == -1
                                                                                      ? Container(
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
                                                                                            child: MyTextWidget(
                                                                                              'Replay',
                                                                                              style: textTheme.overline?.rr.copyWith(color: colorScheme.white, height: 1.4),
                                                                                            ),
                                                                                          ),
                                                                                        )
                                                                                      : const SizedBox.shrink()
                                                                                ],
                                                                              ),
                                                                              5.horizontalSpace,
                                                                              Column(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                                    children: [
                                                                                      Container(
                                                                                        width: 185.w,
                                                                                        height: 40,
                                                                                        padding: HWEdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                                                                        decoration: BoxDecoration(
                                                                                          color: const Color(0xfffafafa),
                                                                                          borderRadius: BorderRadius.circular(12.0),
                                                                                          boxShadow: const [
                                                                                            BoxShadow(
                                                                                              color: Color(0x29000000),
                                                                                              offset: Offset(0, 2),
                                                                                              blurRadius: 10,
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                        child: Row(
                                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                          children: [
                                                                                            MessageActionWidget(
                                                                                              onTap: () => forwardMessageMethod(messages.firstWhere((element) => element.id == messageId)),
                                                                                              iconUrl: AppAssets.goBackIconSvg,
                                                                                              myIndex: 0,
                                                                                              focusedIndex: focusedIndex,
                                                                                            ),
                                                                                            MessageActionWidget(
                                                                                              onTap: () {},
                                                                                              iconUrl: AppAssets.copyIconSvg,
                                                                                              myIndex: 1,
                                                                                              focusedIndex: focusedIndex,
                                                                                            ),
                                                                                            MessageActionWidget(
                                                                                              onTap: () {},
                                                                                              iconUrl: AppAssets.addToGroupSvg,
                                                                                              myIndex: 2,
                                                                                              focusedIndex: focusedIndex,
                                                                                            ),
                                                                                            MessageActionWidget(
                                                                                              onTap: () {},
                                                                                              iconUrl: AppAssets.removeIconSvg,
                                                                                              myIndex: 3,
                                                                                              focusedIndex: focusedIndex,
                                                                                            ),
                                                                                            MessageActionWidget(
                                                                                              onTap: () {},
                                                                                              iconUrl: AppAssets.editIconSvg,
                                                                                              myIndex: 4,
                                                                                              focusedIndex: focusedIndex,
                                                                                            ),
                                                                                            MessageActionWidget(
                                                                                              onTap: () {},
                                                                                              iconUrl: AppAssets.notificationIconSvg,
                                                                                              myIndex: 5,
                                                                                              focusedIndex: focusedIndex,
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                  10.verticalSpace,
                                                                                  focusedIndex >= 0 ? Transform.translate(offset: Offset(focusedIndex * 30.w, 0), child: MessageSubtitleWidget(focusedIndex: focusedIndex)) : const SizedBox.shrink()
                                                                                ],
                                                                              )
                                                                            ])))))
                                                                : SizedBox.shrink()
                                                          ]));
                                                },
                                                itemCount: chatState
                                                    .newSortedChatsByDate![
                                                        chat.id]!
                                                    .length,
                                              ),
                                            ),
                                          ],
                                        );
                                      });
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
                    senderUserImage: widget.senderPhoto,
                    onSendFile: (File file, String customPathType) {
                      String id = const Uuid().v4();
                      FileSaving().saveFileToSpecificDirectory(file);
                      ChannelMember member = chat.channelMembers!.firstWhere(
                          (element) =>
                              element.userId != _prefsRepository.myChatId);
                      String mimeStr = lookupMimeType(file.absolute.path) ?? '';
                      bool isMediaFile = mimeStr.split('/')[0] != 'application';

                      chatBloc.add(UploadFileEvent(
                          file: file,
                          channelId: chat.id.toString(),
                          filePath: customPathType == 'image'
                              ? 'images/test'
                              : customPathType == 'file'
                                  ? 'files/test'
                                  : customPathType == 'video'
                                      ? 'videos/test'
                                      : 'voices/test',
                          useCloudinaryToUpload: isMediaFile,
                          fileName: file.path,
                          messageType: customPathType == 'image'
                              ? 'ImageMessage'
                              : customPathType == 'file'
                                  ? 'FileMessage'
                                  : customPathType == 'video'
                                      ? 'VideoMessage'
                                      : 'VoiceMessage',
                          isForward: false,
                          senderParentMessageId: state.senderParentMessageId,
                          parentMessageId:
                              state.thereIsReply ? state.messageId : null,
                          messageId: id,
                          parentMessageContent: customPathType == 'image'
                              ? 'Photo'
                              : customPathType == 'file'
                                  ? 'File'
                                  : customPathType == 'video'
                                      ? 'Video'
                                      : 'Voice',
                          receiverUserId: member.userId));
                      BlocProvider.of<AppBloc>(context).add(
                          RefreshChatInputField(false, '', false,
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
//                    debugPrint('there : ${state.thereIsReply}');
                      chatBloc.add(SendMessageEvent(
                          messageType: 'TextMessage',
                          channelId: chat.id.toString(),
                          isForward: false,
                          parentMessageId:
                              state.thereIsReply ? state.messageId : null,
                          content: message,
                          messageId: id,
                          senderParentMessageId: state.senderParentMessageId,
                          parentMessageContent: state.message,
                          receiverUserId: member.userId));
                      BlocProvider.of<AppBloc>(context).add(
                          RefreshChatInputField(false, '', false,
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
          ),
        ));
  }

  void dealWithMessageOptions(int index, String? messageId) {
    debugPrint('indexxxx:  $index');
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
    if (index == -1) {
      chatBloc.add(GetAllMessagesBetweenEvent(
          firstMessageId: parentMessageId!,
          scrollToParentMessage: true,
          secondMessageId: currentId!,
          channelId: widget.chatId));
      return;
    }
    autoScrollController
        .scrollToIndex(index,
            duration: duration ?? const Duration(milliseconds: 50),
            preferPosition: preferPosition ?? AutoScrollPosition.middle)
        .then((value) {
      currentScrolledIndex = index;
      rebuildMessage.value = index;
      Future.delayed(
        Duration(milliseconds: 800),
        () {
          currentScrolledIndex = -1;
          rebuildMessage.value = -1;
        },
      );
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
    debugPrint("id${message.id.toString()}");
    debugPrint("localId${message.localId.toString()}");
    FlutterError.onError = (details) {
      debugPrint("asfsd${details.toString()}");
    };
    String? filePath = message.mediaMessageContent.isNullOrEmpty
        ? null
        : message.mediaMessageContent?[0].filePath;
    if (message.file == null &&
        filePath != null &&
        _prefsRepository.isAFilePathExist(filePath)) {
      String? path = _prefsRepository.getTheLocalPathForFile(filePath);
      if (path != null) {
        File? file = File(path);
        message = message.copyWith(file: file);
      }
    }
    bool isSentMessage = (message.senderUserId == _prefsRepository.myChatId &&
            message.senderUserId != null) ||
        (message.receiverUserId != _prefsRepository.myChatId &&
            message.receiverUserId != null);
    MessageStatus? messageStatus = message.messageStatus
        ?.firstWhere((e) => e.userId != _prefsRepository.myChatId);
    time = messageStatus?.isWatched ?? false
        ? messageStatus?.watchedAt
        : messageStatus?.isReceived == 1
            ? messageStatus?.receivedAt
            : message.createdAt;

    if (message.parentMessageId != null && message.parentMessage != null) {
      Message parentMessage = message.parentMessage!;
      MessageStatus? parentMessageStatus = parentMessage.messageStatus
          ?.firstWhere((e) => e.userId != _prefsRepository.myChatId);

      if (parentMessage.senderUserId != message.senderUserId) {
        return ReplayMessage(
          messageDate: message.createdAt!,
          time: message.senderUserId != _prefsRepository.myChatId
              ? message.createdAt!
              : time!,
          scrollToMessage: () => scrollToIndex(
              messagesIndexes[parentMessage.id.toString()] ?? -1,
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
          replayedName: parentMessage.id == _prefsRepository.myChatId.toString()
              ? senderName
              : receiverName,
          senderAnswerName: senderName,
          senderAnswerPhoto: senderPhoto,
          isISentFirstMessage:
              parentMessage.senderUserId == _prefsRepository.myChatId,
          isSent: isSentMessage,
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
          messageAnswerId: message.id!,
          receivedAt: messageStatus?.receivedAt,
          createAt: message.createdAt,
        );
      } else {
        return ReplayOnMeMessage(
            time: message.senderUserId != _prefsRepository.myChatId
                ? message.createdAt!
                : time!,
            messageId: message.parentMessageId!,
            receivedAt: messageStatus?.receivedAt,
            createAt: message.createdAt,
            answeredFilePath: message.mediaMessageContent?[0].filePath,
            messageAnswer: message.messageContent?.content,
            answeredFile: message.file,
            scrollToMessage: () => scrollToIndex(
                messagesIndexes[parentMessage.id.toString()] ?? -1,
                currentId: message.id!,
                parentMessageId: message.parentMessageId!),
            isISentFirstMessage:
                parentMessage.senderUserId == _prefsRepository.myChatId,
            isSent: isSentMessage,
            isFirstMessage: message.isFirstMessage,
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
            receivedAt: messageStatus?.receivedAt,
            createAt: message.createdAt,
            message: message.messageContent!.content.toString(),
            messageId: message.id!,
            senderId: message.senderUserId!,
            isSent: isSentMessage,
            isRead: messageStatus?.isWatched ?? false,
            userMessageName: message.receiverUserId != _prefsRepository.myChatId
                ? senderName
                : receiverName,
            userMessagePhoto:
                message.receiverUserId != _prefsRepository.myChatId
                    ? senderPhoto
                    : receiverPhoto,
            isReceived: (messageStatus?.isReceived ?? 0) == 1,
            isFirstMessage:
                message.isFirstMessage || message.isFirstMessageForThisDay,
            time: message.senderUserId != _prefsRepository.myChatId
                ? message.createdAt!
                : time!,
            isForwarded: message.isForward == 1,
          );
        case 'ImageMessage':
          return ImageMessage(
            receivedAt: messageStatus?.receivedAt,
            createAt: message.createdAt,
            isSent: isSentMessage,
            imageFile: message.file,
            messageId: message.id.toString(),
            senderId: message.senderUserId!,
            imageUrl: message.mediaMessageContent?[0].filePath,
            time: message.senderUserId != _prefsRepository.myChatId
                ? message.createdAt!
                : time!,
            userMessageName: message.receiverUserId != _prefsRepository.myChatId
                ? senderName
                : receiverName,
            userMessagePhoto:
                message.receiverUserId != _prefsRepository.myChatId
                    ? senderPhoto
                    : receiverPhoto,
            isFirstMessage:
                message.isFirstMessage || message.isFirstMessageForThisDay,
            isRead: messageStatus?.isWatched ?? false,
            isReceived: (messageStatus?.isReceived ?? 0) == 1,
            isLocalMessage: true,
            isForwarded: message.isForward == 1,
          );
        case 'VideoMessage':
          return VideoMessage(
            receivedAt: messageStatus?.receivedAt,
            createAt: message.createdAt,
            key: ValueKey(message.id),
            isSent: isSentMessage,
            videoFile: message.file,
            videoUrl: message.mediaMessageContent?[0].filePath,
            messageId: message.id.toString(),
            senderId: message.senderUserId!,
            time: message.senderUserId != _prefsRepository.myChatId
                ? message.createdAt!
                : time!,
            userMessageName: message.receiverUserId != _prefsRepository.myChatId
                ? senderName
                : receiverName,
            userMessagePhoto:
                message.receiverUserId != _prefsRepository.myChatId
                    ? senderPhoto
                    : receiverPhoto,
            isFirstMessage:
                message.isFirstMessage || message.isFirstMessageForThisDay,
            isRead: messageStatus?.isWatched ?? false,
            isReceived: (messageStatus?.isReceived ?? 0) == 1,
            isLocalMessage: true,
            isForwarded: message.isForward == 1,
          );
        case 'VoiceMessage':
          return VoiceMessage(
            time: message.senderUserId != _prefsRepository.myChatId
                ? message.createdAt!
                : time!,
            receivedAt: messageStatus?.receivedAt,
            createAt: message.createdAt,
            isSent: isSentMessage,
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
            watchedAt: messageStatus?.watchedAt ?? DateTime.now(),
            isRead: messageStatus?.isWatched ?? false,
            isReceived: (messageStatus?.isReceived ?? 0) == 1,
            isFirstMessage:
                message.isFirstMessage || message.isFirstMessageForThisDay,
            isForwarded: message.isForward == 1,
          );
        case 'FileMessage':
          String fileName = message.file?.path.split('/').last ??
              message.mediaMessageContent![0].filePath!.split('/').last;
          return DocumentMessage(
            receivedAt: messageStatus?.receivedAt,
            createAt: message.createdAt,
            isSent: isSentMessage,
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
            time: message.senderUserId != _prefsRepository.myChatId
                ? message.createdAt!
                : time!,
            isRead: messageStatus?.isWatched ?? false,
            isReceived: (messageStatus?.isReceived ?? 0) == 1,
            isFirstMessage:
                message.isFirstMessage || message.isFirstMessageForThisDay,
            isForwarded: message.isForward == 1,
          );
        case 'VideoCall':
          return CallMessage(
            isVideo: true,
            message: 'Video Call At',
            time: message.createdAt!,
            isSent: isSentMessage,
            userMessageName: message.receiverUserId != _prefsRepository.myChatId
                ? senderName
                : receiverName,
            userMessagePhoto:
                message.receiverUserId != _prefsRepository.myChatId
                    ? senderPhoto
                    : receiverPhoto,
          );
        case 'VoiceCall':
          return CallMessage(
            isVideo: false,
            message: 'Voice Call At',
            isSent: isSentMessage,
            time: message.createdAt!,
            userMessageName: message.receiverUserId != _prefsRepository.myChatId
                ? senderName
                : receiverName,
            userMessagePhoto:
                message.receiverUserId != _prefsRepository.myChatId
                    ? senderPhoto
                    : receiverPhoto,
          );
      }
    }
  }
}

class MessagesDate extends StatelessWidget {
  const MessagesDate({Key? key, required this.date}) : super(key: key);
  final String date;

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
            child: MyTextWidget(formatDate(date),
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
        onTap: onTap,
        child: SvgPicture.asset(
          iconUrl,
          width: focusedIndex == myIndex ? 20.w : 15.w,
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
        child: MyTextWidget(
          hoverText,
          style: context.textTheme.overline?.rr
              .copyWith(color: context.colorScheme.white, height: 1.4),
        ),
      ),
    );
  }
}
