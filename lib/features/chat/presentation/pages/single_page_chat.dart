import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:eraser/eraser.dart';
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
import 'package:trydos/common/test_utils/test_var.dart';
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
import 'package:trydos/features/chat/presentation/utils/firebase_presence.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_input_field.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/document_message.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/image_message.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/reply_messge.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/reply_on_me_message.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/shared_product_message.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/video_message.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:uuid/uuid.dart';
import '../../../../common/test_utils/widgets_keys.dart';
import '../../../../common/helper/helper_functions.dart';
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
import '../../../calls/presentation/utils/caller_info.dart';
import '../../../home/presentation/pages/product_details_page.dart';
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
  late CallsBloc callsBloc;
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
    rebuildMessage.value = -2;
    Eraser.clearAllAppNotifications();
    callsBloc = BlocProvider.of<CallsBloc>(context);
    chatBloc = BlocProvider.of<ChatBloc>(context);
    autoScrollController = AutoScrollController();
    callsBloc.add(GetMissedCallCountEvent());
    chatBloc.add(ReadAllMessagesEvent(widget.chatId.toString()));
    chatBloc.add(AddUserConntctSatuseEvent(
        userConnectedStatuse: " ", chatId: widget.chatId));
    //  FirebasePresence.listeningToConnectStatus(friendId:);
    //  if (int.tryParse(widget.chatId) != null) {
    //  chatBloc.add(GetMediaCountEvent(channelId: widget.chatId.toString()));
    // }

    autoScrollController.addListener(() {
      if (rebuild) {
        rebuildMessage.value = -1;
      }
      if ((autoScrollController.offset >=
          autoScrollController.position.maxScrollExtent - 400)) {
        debugPrint('///////////// _loadMoreMessages ///////////////////');
        _loadMoreMessages();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    callsBloc.add(GetMissedCallCountEvent());
    chatBloc
        .add(AddUserConntctSatuseEvent(userConnectedStatuse: " ", chatId: " "));
    autoScrollController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  int currentScrolledIndex = -1;

  @override
  Widget build(BuildContext context) {
    int duration = GetIt.I<PrefsRepository>().getdurtion ?? 0;

    ChannelMember? member;
    Locale locale = Localizations.localeOf(context);
    bool lan = locale.languageCode.contains("en");
    FlutterError.onError = (details) {
      chatBloc.add(SendErrorChatToServerEvent(
          error: details.toString(), lastPage: "Single_Page_Chat"));
      print("asfsd${details.toString()}");
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: details.toString());
    };
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _scrollToBottom();
    });
    return WillPopScope(
      onWillPop: () {
        BlocProvider.of<AppBloc>(context)
            .add(RefreshChatInputField(false, 'null', false));
        chatBloc
            .add(ChangeGlobalUsedVariablesInBloc(currentOpenedChatId: null));
        return Future.value(true);
      },
      child: Scaffold(
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
                              key: TestVariables.kTestMode
                                  ? Key(WidgetsKey.backFromChatKey)
                                  : null,
                              onTap: () {
                                BlocProvider.of<AppBloc>(context).add(
                                    RefreshChatInputField(
                                        false, 'null', false));
                                chatBloc.add(ChangeGlobalUsedVariablesInBloc(
                                    currentOpenedChatId: null));
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
                      BlocListener<ChatBloc, ChatState>(
                          listenWhen: (p, c) =>
                              p.currentOpenedChatId != c.currentOpenedChatId,
                          listener: (context, state) {
                            chat = state.chats.firstWhere(
                                (element) =>
                                    element.id.toString() == widget.chatId ||
                                    element.localId.toString() == widget.chatId,
                                orElse: () => state.pinnedChats.firstWhere(
                                    (element) =>
                                        element.id.toString() ==
                                            widget.chatId ||
                                        element.localId.toString() ==
                                            widget.chatId));

                            member = !chat.channelMembers.isNullOrEmpty
                                ? chat.channelMembers!.firstWhere((element) =>
                                    element.userId != _prefsRepository.myChatId)
                                : null;
                            FirebasePresence.listeningToConnectStatus(
                                chatId: widget.chatId,
                                friendId: member!.userId!);
                          },
                          child: BlocBuilder<ChatBloc, ChatState>(
                              builder: (context, state) {
                            if ((state.unReadMessagesFromAllChats -
                                    countMessagesReceivedToMeNow) >
                                0) {
                              return Row(
                                children: [
                                  MyTextWidget(
                                    (state.unReadMessagesFromAllChats -
                                            countMessagesReceivedToMeNow)
                                        .toString(),
                                    style: textTheme.bodyMedium?.rr.copyWith(
                                        color: const Color(0xff388CFF)),
                                  ),
                                ],
                              );
                            }
                            return const SizedBox.shrink();
                          })),

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
                              textStyle: context.textTheme.bodyMedium?.br
                                  .copyWith(
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
                              key: TestVariables.kTestMode
                                  ? Key(WidgetsKey.goToProfileButtonKey)
                                  : null,
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => ProfilePage(
                                          receiverName: widget.receiverName,
                                          receiverPhoto: widget.receiverPhoto,
                                          fullReceiverName:
                                              widget.fullReceiverName,
                                          receiverPhone: widget.receiverPhone,
                                          chatId: widget.chatId,
                                        )));
                              },
                              child: MyTextWidget(
                                widget.fullReceiverName,
                                style: textTheme.bodyMedium?.mr
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
                                      style: textTheme.titleMedium?.mr.copyWith(
                                          color: const Color(0xff007CFF)),
                                    );
                                  } else {
                                    return BlocBuilder<ChatBloc, ChatState>(
                                      builder: (context, state) {
                                        return state.userConnectedStatuse !=
                                                    ' ' &&
                                                DateTime.tryParse(state
                                                        .userConnectedStatuse) !=
                                                    null
                                            ? DateTime.parse(state.userConnectedStatuse)
                                                        .subtract(Duration(
                                                            minutes: duration))
                                                        .difference(
                                                            DateTime.now()
                                                                .toUtc())
                                                        .inMinutes
                                                        .abs() <=
                                                    5
                                                ? MyTextWidget("Online",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: textTheme
                                                        .titleMedium?.mr
                                                        .copyWith(
                                                            color: const Color(
                                                                0xff007CFF)))
                                                : Row(
                                                    children: [
                                                      MyTextWidget("أخر ظهور ",
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: textTheme
                                                              .titleMedium?.mr
                                                              .copyWith(
                                                                  color: const Color(
                                                                      0xff007CFF))),
                                                      MyTextWidget(
                                                          formatDate(DateTime
                                                                  .tryParse(state
                                                                      .userConnectedStatuse)!
                                                              .subtract(
                                                                  Duration(
                                                                      minutes:
                                                                          duration))),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: textTheme
                                                              .titleMedium?.mr
                                                              .copyWith(
                                                                  color: const Color(
                                                                      0xff007CFF))),
                                                      MyTextWidget(" الساعة ",
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: textTheme
                                                              .titleMedium?.mr
                                                              .copyWith(
                                                                  color: const Color(
                                                                      0xff007CFF))),
                                                      MyTextWidget(
                                                          HelperFunctions.gettimesInFormat(DateTime
                                                                  .tryParse(state
                                                                      .userConnectedStatuse)!
                                                              .subtract(Duration(
                                                                  minutes:
                                                                      duration))),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: textTheme
                                                              .titleMedium?.mr
                                                              .copyWith(
                                                                  color: const Color(
                                                                      0xff007CFF))),
                                                    ],
                                                  )
                                            : SizedBox.shrink();
                                      },
                                    );
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
                            var status2 =
                                await Permission.mediaLibrary.request();
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
                                    chatId: info[1]['channelId'],
                                    isVideo: true,
                                    payload: info[1]));
                              } else {
                                GetIt.I<CallsBloc>().add(MakeCallEvent(
                                    isVideo: true,
                                    receiverCallName: widget.fullReceiverName,
                                    chatId: info[0]['channelId'],
                                    payload: info[0]));
                                //todo we have the id of the chat so we can move to the call immediately
                              }
                            } else if (microphone.isDenied ||
                                status2.isDenied ||
                                camera.isDenied) {
                              showMessage(LocaleKeys.permission_denied.tr());
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
                          try {
                            List<Map<String, dynamic>> info =
                                callerInfo(channelId: widget.chatId);
                            PermissionStatus microphone =
                                await Permission.microphone.request();
                            var status2 =
                                await Permission.mediaLibrary.request();
                            if (microphone.isGranted && status2.isGranted) {
                              //todo we have the receiver id so the chat dose not exist
                              if (info[0].containsKey('currentReceiver')) {
                                debugPrint(
                                    'currentReceiver${info[0]['currentReceiver']}');

                                GetIt.I<CallsBloc>().add(MakeCallEvent(
                                    receiverUserId:
                                        info[0]['currentReceiver'].toString(),
                                    receiverCallName: widget.fullReceiverName,
                                    chatId: info[1]['channelId'],
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
                                    chatId: info[0]['channelId'],
                                    payload: info[0]));
                                //todo we have the id of the chat so we can move to the call immediately
                              }
                            } else if (microphone.isDenied ||
                                status2.isDenied) {
                              showMessage(LocaleKeys.permission_denied.tr());
                              openAppSettings();
                            }
                          } catch (e, st) {
                            print(e);
                            print(st);
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
            listenWhen: (p, c) =>
                (p.getMessagesBetweenStatus != c.getMessagesBetweenStatus &&
                    c.getMessagesBetweenStatus ==
                        GetMessagesBetweenStatus.success &&
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
                        p.resendMessageStatus != c.resendMessageStatus ||
                        (p.receiveMessageStatus != c.receiveMessageStatus &&
                            c.receiveMessageStatus ==
                                ReceiveMessageStatus.success),
                    listener: (context, state) {
                      if (state.sendMessageStatus ==
                              SendMessageStatus.loading ||
                          state.receiveMessageStatus ==
                              ReceiveMessageStatus.success) {
                        WidgetsBinding.instance
                            .addPostFrameCallback((timeStamp) {
                          _scrollToBottom();
                        });
                      }
                      print(widget.chatId);
                      print(state.currentChannelReceivedMessage);
                      if (state.receiveMessageStatus ==
                              ReceiveMessageStatus.success &&
                          (widget.chatId ==
                                  state.currentChannelReceivedMessage ||
                              chat.localId ==
                                  state.currentChannelReceivedMessage)) {
                        chatBloc.add(ReadAllMessagesEvent(chat.id.toString()));
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
                                                      key: TestVariables
                                                              .kTestMode
                                                          ? Key(
                                                              WidgetsKey
                                                                  .messagesListKey,
                                                            )
                                                          : null,
                                                      physics:
                                                          const ClampingScrollPhysics(),
                                                      shrinkWrap: true,
                                                      reverse: true,
                                                      controller:
                                                          autoScrollController,
                                                      itemBuilder:
                                                          (context, index) {
                                                        List<Message> messages =
                                                            chatState
                                                                .newSortedChatsByDate![chat
                                                                    .id
                                                                    .toString()]!
                                                                .reversed
                                                                .toList();
                                                        if (messages[index]
                                                            .isDateMessage!) {
                                                          return AutoScrollTag(
                                                              key: ValueKey(
                                                                  index),
                                                              index: index,
                                                              controller:
                                                                  autoScrollController,
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  10.verticalSpace,
                                                                  MessagesDate(
                                                                      date: messages[
                                                                              index]
                                                                          .dateValue!),
                                                                ],
                                                              ));
                                                        }
                                                        debugPrint(
                                                            'isForward : ${messages[index].isForward}');
                                                        debugPrint(
                                                            'senderUserId : ${messages[index].senderUserId}');
                                                        debugPrint(
                                                            'myChatId : ${_prefsRepository.myChatId}');
                                                        bool isSent = messages[
                                                                    index]
                                                                .senderUserId ==
                                                            _prefsRepository
                                                                .myChatId;
                                                        String? messageId =
                                                            messages[index].id;
                                                        messagesIndexes[messages[
                                                                    index]
                                                                .id
                                                                .toString()] =
                                                            index;
                                                        return AutoScrollTag(
                                                            key: ValueKey(
                                                                messageId),
                                                            index: index,
                                                            controller:
                                                                autoScrollController,
                                                            child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  messages[index]
                                                                          .isFirstMessage!
                                                                      ? 30.verticalSpace
                                                                      : 10.verticalSpace,
                                                                  ////////////////
                                                                  GestureDetector(
                                                                    key: TestVariables
                                                                            .kTestMode
                                                                        ? Key(
                                                                            '${WidgetsKey.messagesListCardKey}$index')
                                                                        : null,
                                                                    onLongPress:
                                                                        () {
                                                                      if (messages[index]
                                                                              .authMessageStatus!
                                                                              .isDeleted ==
                                                                          1) {
                                                                        /*    showDialog(
                                                                  context:
                                                                      context,
                                                                  builder: (context) => AlertDialog(
                                                                      title:
                                                                          Text(" حذف هذه الرسالة  "),
                                                                      actions: [
                                                                        MaterialButton(
                                                                          onPressed: () {
                                                                            callsBloc.add(DeleteMessageEvent(type: "message", deleteFromBoth: 0, messageId: messages[index].id!, channelId: widget.chatId, deleteFromId: _prefsRepository.myChatId!));
                                                                            Navigator.of(context).pop();
                                                                            rebuildMessage.value = -1;
                                                                          },
                                                                          child: Text("نعم"),
                                                                        ),
                                                                        SizedBox(
                                                                          width: 20.w,
                                                                        ),
                                                                        MaterialButton(
                                                                            child: Text("إغلاق"),
                                                                            onPressed: () {
                                                                              Navigator.of(context).pop();
                                                                              rebuildMessage.value = -1;
                                                                            })
                                                                      ]),
                                                                                                                                        );
                                                                                                                                        */
                                                                        return;
                                                                      }

                                                                      if ((chatState.sendMessageStatus ==
                                                                              SendMessageStatus
                                                                                  .loading &&
                                                                          chatState
                                                                              .currentMessage
                                                                              .contains(messageId))) {
                                                                        return;
                                                                      }
                                                                      if (messages[index]
                                                                              .messageType
                                                                              ?.name
                                                                              ?.contains('Call') ??
                                                                          false) {
                                                                        return;
                                                                      }
                                                                      rebuildMessage
                                                                              .value =
                                                                          index;
                                                                    },
                                                                    onTap: () {
                                                                      if (messages[index]
                                                                              .messageType
                                                                              ?.name ==
                                                                          'ShareProduct') {
                                                                        BlocProvider.of<HomeBloc>(context).add(GetFullProductDetailsEvent(
                                                                            productId:
                                                                                messages[index].shareProductContent?.productId.toString()));
                                                                        Navigator.of(context).push(MaterialPageRoute(
                                                                            builder: (ctx) => ProductDetailsPage(
                                                                                  productIdForOpeningChatDirectly: messages[index].shareProductContent?.productId.toString(),
                                                                                )));
                                                                      }
                                                                      rebuildMessage
                                                                          .value = -1;
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      color: currentScrolledIndex ==
                                                                              index
                                                                          ? Colors
                                                                              .black12
                                                                              .withOpacity(0.05)
                                                                          : null,
                                                                      child:
                                                                          getTheMessageWidget(
                                                                        listIndex:
                                                                            index,
                                                                        message:
                                                                            messages[index],
                                                                        senderName:
                                                                            widget.senderName,
                                                                        receiverName:
                                                                            widget.receiverName,
                                                                        receiverPhoto:
                                                                            widget.receiverPhoto,
                                                                        senderPhoto:
                                                                            widget.senderPhoto,
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
                                                                              left: isSent ? 40.w : 20.w,
                                                                              top: 10,
                                                                              right: isSent ? 20.w : 40.w),
                                                                          child: GestureDetector(
                                                                              onPanDown: (details) {
                                                                                if ((details.localPosition.dx + (isSent ? 140 : 0)) < (lan ? 210.w : 40)) {
                                                                                  currentFocusedIcon.value = -1;
                                                                                } else if ((details.localPosition.dx + (isSent ? 140 : 0)) > (lan ? 40 : 210.w)) {
                                                                                  currentFocusedIcon.value = lan ? 5 : 0;
                                                                                } else {
                                                                                  currentFocusedIcon.value = (lan ? (details.localPosition.dx + 40 + (isSent ? 140 : 0)) : (details.localPosition.dx - 40 - (isSent ? 140 : 0))) ~/ (30.w);
                                                                                }
                                                                              },
                                                                              onPanEnd: (details) {
                                                                                debugPrint('end');
                                                                                rebuildMessage.value = -1;
                                                                                dealWithMessageOptions(currentFocusedIcon.value, messageId);
                                                                              },
                                                                              onPanUpdate: (details) {
                                                                                if ((details.localPosition.dx - (isSent ? 140 : 0)) < 40) {
                                                                                  currentFocusedIcon.value = -1;
                                                                                } else if ((details.localPosition.dx - (isSent ? 140 : 0)) > 210.w) {
                                                                                  currentFocusedIcon.value = 5;
                                                                                } else {
                                                                                  currentFocusedIcon.value = (details.localPosition.dx - 40 - (isSent ? 140 : 0)) ~/ 30.w;
                                                                                }
                                                                              },
                                                                              child: Container(
                                                                                  //color: Colors.red,
                                                                                  child: Row(
                                                                                      mainAxisAlignment: isSent
                                                                                          ? lan
                                                                                              ? MainAxisAlignment.end
                                                                                              : MainAxisAlignment.start
                                                                                          : lan
                                                                                              ? MainAxisAlignment.start
                                                                                              : MainAxisAlignment.end,
                                                                                      children: !lan
                                                                                          ? [
                                                                                              Column(
                                                                                                mainAxisSize: MainAxisSize.min,
                                                                                                crossAxisAlignment: !lan ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                                                                                children: [
                                                                                                  Row(
                                                                                                    mainAxisAlignment: !lan ? MainAxisAlignment.end : MainAxisAlignment.start,
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
                                                                                                              key: TestVariables.kTestMode ? Key('${WidgetsKey.forWardMessageKey}$index') : null,
                                                                                                              onTap: () => forwardMessageMethod(messages.firstWhere((element) => element.id == messageId)),
                                                                                                              iconUrl: AppAssets.goBackIconSvg,
                                                                                                              myIndex: lan ? 0 : 5,
                                                                                                              focusedIndex: focusedIndex,
                                                                                                            ),
                                                                                                            MessageActionWidget(
                                                                                                              onTap: () {},
                                                                                                              iconUrl: AppAssets.copyIconSvg,
                                                                                                              myIndex: lan ? 1 : 4,
                                                                                                              focusedIndex: focusedIndex,
                                                                                                            ),
                                                                                                            MessageActionWidget(
                                                                                                              onTap: () {},
                                                                                                              iconUrl: AppAssets.addToGroupSvg,
                                                                                                              myIndex: lan ? 2 : 3,
                                                                                                              focusedIndex: focusedIndex,
                                                                                                            ),
                                                                                                            MessageActionWidget(
                                                                                                              key: TestVariables.kTestMode ? Key('${WidgetsKey.deleteMessageKey}$index') : null,
                                                                                                              onTap: () {
                                                                                                                showDialog(
                                                                                                                  context: context,
                                                                                                                  builder: (context) => AlertDialog(title: Text(LocaleKeys.delete_message.tr()), actions: [
                                                                                                                    MaterialButton(
                                                                                                                      key: TestVariables.kTestMode ? Key('${WidgetsKey.deleteOnlyMeButtonKey}$index') : null,
                                                                                                                      onPressed: () {
                                                                                                                        callsBloc.add(DeleteMessageEvent(type: "message", deleteFromBoth: 0, messageId: messages[index].id!, channelId: widget.chatId, deleteFromId: _prefsRepository.myChatId!));
                                                                                                                        Navigator.of(context).pop();
                                                                                                                        rebuildMessage.value = -1;
                                                                                                                      },
                                                                                                                      child: Text(chatState.currentFailedMessage.contains(messages[index].id!) ? LocaleKeys.yes.tr() : LocaleKeys.only_me.tr()),
                                                                                                                    ),
                                                                                                                    SizedBox(
                                                                                                                      width: 20.w,
                                                                                                                    ),
                                                                                                                    chatState.currentFailedMessage.contains(messages[index].id!)
                                                                                                                        ? MaterialButton(
                                                                                                                            child: Text(LocaleKeys.cancel.tr()),
                                                                                                                            onPressed: () {
                                                                                                                              Navigator.of(context).pop();
                                                                                                                              rebuildMessage.value = -1;
                                                                                                                            })
                                                                                                                        : MaterialButton(
                                                                                                                            onPressed: () {
                                                                                                                              callsBloc.add(DeleteMessageEvent(deleteFromId: _prefsRepository.myChatId!, type: "message", deleteFromBoth: 1, messageId: messages[index].id!, channelId: widget.chatId));
                                                                                                                              Navigator.of(context).pop();
                                                                                                                              rebuildMessage.value = -1;
                                                                                                                            },
                                                                                                                            child: Text(LocaleKeys.everyone.tr()),
                                                                                                                          )
                                                                                                                  ]),
                                                                                                                );
                                                                                                              },
                                                                                                              iconUrl: AppAssets.removeIconSvg,
                                                                                                              myIndex: lan ? 3 : 2,
                                                                                                              focusedIndex: focusedIndex,
                                                                                                            ),
                                                                                                            MessageActionWidget(
                                                                                                              onTap: () {},
                                                                                                              iconUrl: AppAssets.editIconSvg,
                                                                                                              myIndex: lan ? 4 : 1,
                                                                                                              focusedIndex: focusedIndex,
                                                                                                            ),
                                                                                                            MessageActionWidget(
                                                                                                              onTap: () {},
                                                                                                              iconUrl: AppAssets.notificationIconSvg,
                                                                                                              myIndex: lan ? 5 : 0,
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
                                                                                              ),
                                                                                              5.horizontalSpace,
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
                                                                                                              LocaleKeys.replay.tr(),
                                                                                                              style: textTheme.titleSmall?.rr.copyWith(color: colorScheme.white, height: 1.4),
                                                                                                            ),
                                                                                                          ),
                                                                                                        )
                                                                                                      : const SizedBox.shrink()
                                                                                                ],
                                                                                              ),
                                                                                            ]
                                                                                          : [
                                                                                              Column(
                                                                                                mainAxisSize: MainAxisSize.min,
                                                                                                crossAxisAlignment: !lan ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                                                                                children: [
                                                                                                  Row(
                                                                                                    mainAxisAlignment: !lan ? MainAxisAlignment.end : MainAxisAlignment.start,
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
                                                                                                              myIndex: lan ? 0 : 5,
                                                                                                              focusedIndex: focusedIndex,
                                                                                                            ),
                                                                                                            MessageActionWidget(
                                                                                                              onTap: () {},
                                                                                                              iconUrl: AppAssets.copyIconSvg,
                                                                                                              myIndex: lan ? 1 : 4,
                                                                                                              focusedIndex: focusedIndex,
                                                                                                            ),
                                                                                                            MessageActionWidget(
                                                                                                              onTap: () {},
                                                                                                              iconUrl: AppAssets.addToGroupSvg,
                                                                                                              myIndex: lan ? 2 : 3,
                                                                                                              focusedIndex: focusedIndex,
                                                                                                            ),
                                                                                                            MessageActionWidget(
                                                                                                              onTap: () {
                                                                                                                showDialog(
                                                                                                                  context: context,
                                                                                                                  builder: (context) => AlertDialog(title: Text(LocaleKeys.delete_message.tr()), actions: [
                                                                                                                    MaterialButton(
                                                                                                                      onPressed: () {
                                                                                                                        callsBloc.add(DeleteMessageEvent(type: "message", deleteFromBoth: 0, messageId: messages[index].id!, channelId: widget.chatId, deleteFromId: _prefsRepository.myChatId!));
                                                                                                                        Navigator.of(context).pop();
                                                                                                                        rebuildMessage.value = -1;
                                                                                                                      },
                                                                                                                      child: Text(chatState.currentFailedMessage.contains(messages[index].id!) ? LocaleKeys.yes.tr() : LocaleKeys.only_me.tr()),
                                                                                                                    ),
                                                                                                                    SizedBox(
                                                                                                                      width: 20.w,
                                                                                                                    ),
                                                                                                                    chatState.currentFailedMessage.contains(messages[index].id!)
                                                                                                                        ? MaterialButton(
                                                                                                                            child: Text(LocaleKeys.cancel.tr()),
                                                                                                                            onPressed: () {
                                                                                                                              Navigator.of(context).pop();
                                                                                                                              rebuildMessage.value = -1;
                                                                                                                            })
                                                                                                                        : MaterialButton(
                                                                                                                            onPressed: () {
                                                                                                                              callsBloc.add(DeleteMessageEvent(deleteFromId: _prefsRepository.myChatId!, type: "message", deleteFromBoth: 1, messageId: messages[index].id!, channelId: widget.chatId));
                                                                                                                              Navigator.of(context).pop();
                                                                                                                              rebuildMessage.value = -1;
                                                                                                                            },
                                                                                                                            child: Text(LocaleKeys.everyone.tr()),
                                                                                                                          )
                                                                                                                  ]),
                                                                                                                );
                                                                                                              },
                                                                                                              iconUrl: AppAssets.removeIconSvg,
                                                                                                              myIndex: lan ? 3 : 2,
                                                                                                              focusedIndex: focusedIndex,
                                                                                                            ),
                                                                                                            MessageActionWidget(
                                                                                                              onTap: () {},
                                                                                                              iconUrl: AppAssets.editIconSvg,
                                                                                                              myIndex: lan ? 4 : 1,
                                                                                                              focusedIndex: focusedIndex,
                                                                                                            ),
                                                                                                            MessageActionWidget(
                                                                                                              onTap: () {},
                                                                                                              iconUrl: AppAssets.notificationIconSvg,
                                                                                                              myIndex: lan ? 5 : 0,
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
                                                                                              ),
                                                                                              5.horizontalSpace,
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
                                                                                                              LocaleKeys.replay.tr(),
                                                                                                              style: textTheme.titleSmall?.rr.copyWith(color: colorScheme.white, height: 1.4),
                                                                                                            ),
                                                                                                          ),
                                                                                                        )
                                                                                                      : const SizedBox.shrink()
                                                                                                ],
                                                                                              ),
                                                                                            ].reversed.toList()))))
                                                                      : SizedBox.shrink()
                                                                ]));
                                                      },
                                                      itemCount: chatState
                                                                      .newSortedChatsByDate![
                                                                  chat.id] !=
                                                              null
                                                          ? chatState
                                                              .newSortedChatsByDate![
                                                                  chat.id]!
                                                              .length
                                                          : 0)),
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
                        ChannelMember? member =
                            !chat.channelMembers.isNullOrEmpty
                                ? chat.channelMembers!.firstWhere((element) =>
                                    element.userId != _prefsRepository.myChatId)
                                : null;
                        String mimeStr =
                            lookupMimeType(file.absolute.path) ?? '';
                        bool isMediaFile =
                            mimeStr.split('/')[0] != 'application';

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
                                ? LocaleKeys.photo.tr()
                                : customPathType == 'file'
                                    ? LocaleKeys.file.tr()
                                    : customPathType == 'video'
                                        ? LocaleKeys.vvideo.tr()
                                        : LocaleKeys.voice.tr(),
                            receiverUserId: member?.userId));
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
                        ChannelMember? member =
                            !chat.channelMembers.isNullOrEmpty
                                ? chat.channelMembers!.firstWhere((element) =>
                                    element.userId != _prefsRepository.myChatId)
                                : null;

                        debugPrint('there : ${state.thereIsReply}');
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
                            receiverUserId: member?.userId));
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
          )),
    );
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
    String id = const Uuid().v4();
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
              messageId: id,
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
              messageId: id,
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
            ? "Text"
            : message.messageType!.name == 'ImageMessage'
                ? "Photo"
                : message.messageType!.name == 'VoiceMessage'
                    ? "Voice"
                    : "video",
        message.senderUserId == myChatId,
        messageId: message.id,
        senderParentMessageId: message.senderUserId,
        message: message.messageContent?.content ??
            (message.messageType!.name == 'TextMessage'
                ? LocaleKeys.photo.tr()
                : LocaleKeys.voice.tr()),
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
    required int listIndex,
    required Message message,
    required String senderName,
    required String receiverName,
    String? senderPhoto,
    String? receiverPhoto,
  }) {
    bool isSentMessage = (message.senderUserId == _prefsRepository.myChatId &&
            message.senderUserId != null) ||
        (message.receiverUserId != _prefsRepository.myChatId &&
            message.receiverUserId != null);
    if (message.authMessageStatus?.isDeleted == 1 &&
        message.authMessageStatus?.deleteForAll == true) {
      Locale lan = Localizations.localeOf(context);
      return Row(
        mainAxisAlignment: !isSentMessage
            ? (lan.languageCode == "en"
                ? MainAxisAlignment.start
                : MainAxisAlignment.end)
            : (lan.languageCode == "en"
                ? MainAxisAlignment.end
                : MainAxisAlignment.start),
        children: [
          Container(
            margin: EdgeInsets.only(left: 10.w, right: 10.w),
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 252, 243, 243),
                border: Border(),
                borderRadius: BorderRadius.circular(20.w)),
            width: 250.w,
            height: 32.h,
            child: Row(
              children: [
                Spacer(),
                MyTextWidget(
                  message.deletedByUserId == _prefsRepository.myChatId
                      ? LocaleKeys.you_have_deleted_this_message.tr()
                      : LocaleKeys.this_message_has_been_deleted.tr(),
                  textAlign: TextAlign.center,
                  style: textTheme.titleSmall?.lr.copyWith(
                      fontSize: 12, height: 1.1, color: colorScheme.grey200),
                ),
                Spacer(),
                MyTextWidget(
                  !message.createdAt!.isUtc
                      ? HelperFunctions.getDateInFormat(message.createdAt!)
                      : HelperFunctions.getZonedDateInFormat(
                          message.createdAt!),
                  textAlign: TextAlign.center,
                  style: textTheme.titleSmall?.lr.copyWith(
                      fontSize: 12, height: 1.1, color: colorScheme.grey200),
                ),
                Spacer()
              ],
            ),
          ),
        ],
      );
    }
    int index;
    String? filePath = message.mediaMessageContent.isNullOrEmpty
        ? message.messageType?.name == 'ShareProduct'
            ? message.shareProductContent!.productImageUrl
            : null
        : message.mediaMessageContent?[0].filePath;
    if (message.file == null &&
        filePath != null &&
        _prefsRepository.isAFilePathExist(filePath, widget.chatId)) {
      String? path =
          _prefsRepository.getTheLocalPathForFile(filePath, widget.chatId);
      if (path != null) {
        File? file = File(path);
        message = message.copyWith(file: file);
      }
    }

    index = message.messageStatus
            ?.indexWhere((e) => e.userId != _prefsRepository.myChatId) ??
        -1;
    MessageStatus? messageStatus =
        index == -1 ? null : message.messageStatus![index];

    if (message.parentMessageId != null && message.parentMessage != null) {
      Message parentMessage = message.parentMessage!;

      index = parentMessage.messageStatus
              ?.indexWhere((e) => e.userId != _prefsRepository.myChatId) ??
          -1;
      MessageStatus? parentMessageStatus =
          index == -1 ? null : parentMessage.messageStatus![index];

      if (parentMessage.senderUserId != message.senderUserId) {
        return ReplayMessage(
          index: listIndex,
          messageType: message.messageType?.name ?? "",
          watchedAt: messageStatus?.watchedAt,
          messageDate: parentMessage.createdAt ?? DateTime.now(),
          createAt: message.createdAt,
          scrollToMessage: () => scrollToIndex(
              messagesIndexes[parentMessage.id.toString()] ?? -1,
              currentId: message.id!,
              parentMessageId: message.parentMessageId!),
          messageId: message.parentMessageId!,
          answeredFilePath: message.mediaMessageContent?[0].filePath,
          messageAnswer: message.messageContent?.content,
          isFirstMessage: message.isFirstMessage!,
          replayedPhoto:
              parentMessage.senderUserId == _prefsRepository.myChatId.toString()
                  ? senderPhoto
                  : receiverPhoto,
          replayedName:
              parentMessage.senderUserId == _prefsRepository.myChatId.toString()
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
                  ? LocaleKeys.photo.tr()
                  : parentMessage.messageType!.name == 'FileMessage'
                      ? LocaleKeys.file.tr()
                      : parentMessage.messageType!.name == 'VideoMessage'
                          ? LocaleKeys.vvideo.tr()
                          : LocaleKeys.voice.tr()
              : parentMessage.messageContent!.content.toString(),
          receivedAt: messageStatus?.receivedAt,
          messageAnswerId: message.id!,
          channalId: message.channelId!,
        );
      } else {
        return ReplayOnMeMessage(
            messageType: message.messageType?.name ?? "",
            key: TestVariables.kTestMode
                ? Key('${WidgetsKey.replayOnMeMessageKey}$listIndex')
                : null,
            index: listIndex,
            messageId: message.parentMessageId!,
            receivedAt: messageStatus?.receivedAt,
            messageDate: parentMessage.createdAt ?? DateTime.now(),
            createAt: message.createdAt,
            watchedaAt: messageStatus?.watchedAt,
            answeredFilePath: message.mediaMessageContent.isNullOrEmpty
                ? null
                : message.mediaMessageContent![0].filePath,
            messageAnswer: message.messageContent?.content,
            answeredFile: message.file,
            scrollToMessage: () => scrollToIndex(
                messagesIndexes[parentMessage.id.toString()] ?? -1,
                currentId: message.id!,
                parentMessageId: message.parentMessageId!),
            isISentFirstMessage:
                parentMessage.senderUserId == _prefsRepository.myChatId,
            isSent: isSentMessage,
            isFirstMessage: message.isFirstMessage!,
            senderAnswerName: senderName,
            senderAnswerPhoto: senderPhoto,
            isReplayedMessageRead: parentMessageStatus?.isWatched ?? false,
            isReplayedMessageReceived:
                (parentMessageStatus?.isReceived ?? 0) == 1,
            isAnswerMessageRead: messageStatus?.isWatched ?? false,
            isAnswerMessageReceived: (messageStatus?.isReceived ?? 0) == 1,
            message: parentMessage.messageContent?.content == null
                ? parentMessage.messageType?.name == 'ImageMessage'
                    ? LocaleKeys.photo.tr()
                    : parentMessage.messageType?.name == 'FileMessage'
                        ? LocaleKeys.file.tr()
                        : parentMessage.messageType?.name == 'VideoMessage'
                            ? LocaleKeys.vvideo.tr()
                            : LocaleKeys.voice.tr()
                : parentMessage.messageContent!.content.toString(),
            messageAnswerId: message.id!,
            channalId: message.channelId!);
      }
    } else {
      switch (message.messageType?.name) {
        case 'TextMessage':
          return TextMessage(
              key: TestVariables.kTestMode
                  ? Key('${WidgetsKey.textMessageCardKey}$listIndex')
                  : null,
              index: listIndex,
              receivedAt: messageStatus?.receivedAt,
              createAt: message.createdAt,
              message: message.messageContent!.content.toString(),
              messageId: message.id!,
              senderId: message.senderUserId!,
              isSent: isSentMessage,
              isRead: messageStatus?.isWatched ?? false,
              userMessageName: isSentMessage ? senderName : receiverName,
              userMessagePhoto: isSentMessage ? senderPhoto : receiverPhoto,
              isReceived: (messageStatus?.isReceived ?? 0) == 1,
              isFirstMessage:
                  message.isFirstMessage! || message.isFirstMessageForThisDay!,
              watchedAt: messageStatus?.watchedAt,
              isForwarded: message.isForward == 1,
              channalId: message.channelId!);
        case 'ImageMessage':
          return ImageMessage(
            channelId: message.channelId!,
            receivedAt: messageStatus?.receivedAt,
            createAt: message.createdAt,
            isSent: isSentMessage,
            imageFile: message.file,
            messageId: message.id.toString(),
            senderId: message.senderUserId!,
            imageUrl: message.mediaMessageContent?[0].filePath == null ? null : addSuitableWidthAndHeightToImage(
                imageUrl: message.mediaMessageContent![0].filePath!,
                width: 200.w,
                // the width of the image in the ui
                height: 400,
                // the height of the image in the ui
                ordinalWidth: 200.w, //double.tryParse(message.mediaMessageContent![0].originalWidth.toString()),
                ordinalHeight: 400,
                //double.tryParse(image.originalHeight.toString())
            )
            ,
            userMessageName: message.receiverUserId != _prefsRepository.myChatId
                ? senderName
                : receiverName,
            watchedAt: messageStatus?.watchedAt,
            userMessagePhoto: isSentMessage ? senderPhoto : receiverPhoto,
            isFirstMessage:
                message.isFirstMessage! || message.isFirstMessageForThisDay!,
            isRead: messageStatus?.isWatched ?? false,
            isReceived: (messageStatus?.isReceived ?? 0) == 1,
            isLocalMessage: true,
            isForwarded: message.isForward == 1,
          );
        case 'ShareProduct':
          return SharedProductMessage(
            channelId: message.channelId!,
            imageUrl: addSuitableWidthAndHeightToImage(
      imageUrl: message.shareProductContent!.productImageUrl!,
      width: message.shareProductContent!.imageWidth ?? 1.sw - 100,
      // the width of the image in the ui
      height: message.shareProductContent!.imageHeight ?? 464,
      // the height of the image in the ui
      ordinalWidth: message.shareProductContent!.imageWidth ?? 1.sw - 100, //double.tryParse(message.mediaMessageContent![0].originalWidth.toString()),
      ordinalHeight: message.shareProductContent!.imageHeight ?? 464,
      //double.tryParse(image.originalHeight.toString())
      ),
            productName: message.shareProductContent!.productName ?? "",
            productDescription:
                message.shareProductContent!.productDescription ?? "",
            imageFile: message.file,
            receivedAt: messageStatus?.receivedAt,
            createAt: message.createdAt,
            key: ValueKey(message.id),
            isSent: isSentMessage,
            messageId: message.id.toString(),
            senderId: message.senderUserId!,
            userMessageName: message.receiverUserId != _prefsRepository.myChatId
                ? senderName
                : receiverName,
            userMessagePhoto: isSentMessage ? senderPhoto : receiverPhoto,
            isFirstMessage:
                message.isFirstMessage! || message.isFirstMessageForThisDay!,
            isRead: messageStatus?.isWatched ?? false,
            isReceived: (messageStatus?.isReceived ?? 0) == 1,
            isForwarded: message.isForward == 1,
            watchedAt: messageStatus?.watchedAt,
          );

        case 'VideoMessage':
          return VideoMessage(
            channelId: message.channelId!,
            receivedAt: messageStatus?.receivedAt,
            createAt: message.createdAt,
            key: ValueKey(message.id),
            isSent: isSentMessage,
            videoFile: message.file,
            videoUrl: message.mediaMessageContent?[0].filePath,
            messageId: message.id.toString(),
            senderId: message.senderUserId!,
            userMessageName: message.receiverUserId != _prefsRepository.myChatId
                ? senderName
                : receiverName,
            userMessagePhoto: isSentMessage ? senderPhoto : receiverPhoto,
            isFirstMessage:
                message.isFirstMessage! || message.isFirstMessageForThisDay!,
            isRead: messageStatus?.isWatched ?? false,
            isReceived: (messageStatus?.isReceived ?? 0) == 1,
            isLocalMessage: true,
            isForwarded: message.isForward == 1,
            watchedAt: messageStatus?.watchedAt,
          );
        case 'VoiceMessage':
          return VoiceMessage(
            receivedAt: messageStatus?.receivedAt,
            createAt: message.createdAt,
            isSent: isSentMessage,
            file: message.file,
            fileUrl: !message.mediaMessageContent.isNullOrEmpty
                ? message.mediaMessageContent![0].filePath
                : null,
            messageId: message.id.toString(),
            senderId: message.senderUserId!,
            userMessageName: isSentMessage ? senderName : receiverName,
            userMessagePhoto: isSentMessage ? senderPhoto : receiverPhoto,
            watchedAt: messageStatus?.watchedAt,
            isRead: messageStatus?.isWatched ?? false,
            isReceived: (messageStatus?.isReceived ?? 0) == 1,
            isFirstMessage:
                message.isFirstMessage! || message.isFirstMessageForThisDay!,
            isForwarded: message.isForward == 1,
            channelId: message.channelId!,
          );
        case 'FileMessage':
          String fileName = message.file?.path.split('/').last ??
              message.mediaMessageContent![0].filePath!.split('/').last;
          return DocumentMessage(
            channelId: message.channelId!,
            receivedAt: messageStatus?.receivedAt,
            createAt: message.createdAt,
            isSent: isSentMessage,
            documentFile: message.file,
            fileName: fileName,
            watchedAt: messageStatus?.watchedAt,
            documentFileUrl: message.mediaMessageContent?[0].filePath,
            messageId: message.id.toString(),
            senderId: message.senderUserId!,
            userMessageName: isSentMessage ? senderName : receiverName,
            userMessagePhoto: isSentMessage ? senderPhoto : receiverPhoto,
            isRead: messageStatus?.isWatched ?? false,
            isReceived: (messageStatus?.isReceived ?? 0) == 1,
            isFirstMessage:
                message.isFirstMessage! || message.isFirstMessageForThisDay!,
            isForwarded: message.isForward == 1,
          );
        case 'VideoCall':
          return CallMessage(
            isVideo: true,
            message: LocaleKeys.video_call_at.tr(),
            time: message.createdAt!,
            isSent: isSentMessage,
            userMessageName: isSentMessage ? senderName : receiverName,
            userMessagePhoto: isSentMessage ? senderPhoto : receiverPhoto,
          );
        case 'VoiceCall':
          return CallMessage(
            isVideo: false,
            message: LocaleKeys.voice_call_at.tr(),
            isSent: isSentMessage,
            time: message.createdAt!,
            userMessageName: isSentMessage ? senderName : receiverName,
            userMessagePhoto: isSentMessage ? senderPhoto : receiverPhoto,
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
      return LocaleKeys.today.tr();
    } else if (difference.inDays == 1) {
      return LocaleKeys.yesterday.tr();
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
                style: context.textTheme.titleMedium?.rr
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
    Locale locale = Localizations.localeOf(context);
    bool lan = locale.languageCode == "en";

    String hoverText = '';
    switch (focusedIndex) {
      case 5:
        hoverText = lan ? LocaleKeys.re_mind.tr() : LocaleKeys.forward.tr();
        break;
      case 4:
        hoverText = lan ? LocaleKeys.edit.tr() : LocaleKeys.copy.tr();
        break;
      case 3:
        hoverText = lan ? LocaleKeys.delete.tr() : LocaleKeys.category.tr();
        break;
      case 2:
        hoverText = lan ? LocaleKeys.category.tr() : LocaleKeys.delete.tr();
        break;
      case 1:
        hoverText = lan ? LocaleKeys.copy.tr() : LocaleKeys.edit.tr();
        break;
      case 0:
        lan ? hoverText = LocaleKeys.forward.tr() : LocaleKeys.re_mind.tr();
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
          style: context.textTheme.titleSmall?.rr
              .copyWith(color: context.colorScheme.white, height: 1.4),
        ),
      ),
    );
  }
}

String formatDate(DateTime dateStr) {
  DateTime now = DateTime.now();
  Duration difference = now.difference(dateStr);

  if (difference.inDays == 0) {
    return LocaleKeys.today.tr();
  } else if (difference.inDays == 1) {
    return LocaleKeys.yesterday.tr();
  } else {
    return DateFormat.yMd().format(dateStr);
  }
}
