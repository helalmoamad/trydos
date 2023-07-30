import 'dart:io';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/core/utils/responsive_padding.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_state.dart';
import 'package:trydos/features/chat/presentation/pages/chat_pages.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_input_field.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/image_message.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/reply_messge.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/reply_on_me_message.dart';
import 'package:uuid/uuid.dart';
import 'dart:ui' as ui;
import '../../../../core/domin/repositories/prefs_repository.dart';
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
      required this.chatId,
      required this.receiverName,
      required this.senderName,
      this.senderPhoto,
      this.receiverPhoto})
      : super(key: key);

  final int chatId;
  final String receiverName;
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
  double currentHoverPosition = -1;
  double x = -1, xActionSubtitle = -1, yActionSubtitle = -1;
  late final AutoScrollController autoScrollController ;
  final key = GlobalKey();
  bool isISentLastMessage = false;
  List<Widget> data = [];
  bool rebuild = true;
  DateTime lastDate = DateTime.now();
  int countMessagesReceivedToMeNow = 0;
  late Chat chat;

  @override
  void initState() {
    chatBloc = BlocProvider.of<ChatBloc>(context);
    autoScrollController=AutoScrollController(
      // viewportBoundaryGetter: ()=> Rect.fromLTRB(0,0,0,MediaQuery.of(context).padding.bottom),
      // axis: Axis.vertical
    );
    autoScrollController.addListener(() {
      if (rebuild) {
        rebuildMessage.value = -1;
      }
      if (autoScrollController.offset <=
          autoScrollController.position.minScrollExtent + 400 &&
          autoScrollController.position.userScrollDirection ==
              ScrollDirection.forward) {
        _loadMoreMessages();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final RenderBox renderBox =
          key.currentContext?.findRenderObject() as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero);
      x = position.dx;
      xActionSubtitle=x;
      yActionSubtitle=position.dy;
    });
    super.initState();
  }

  void scrollToTheEnd() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      autoScrollController.jumpTo(
        autoScrollController.position.maxScrollExtent,
      );
    });
  }

  bool isPaginationEvent = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state.receiveMessageStatus == ReceiveMessageStatus.loading &&
            widget.chatId == state.currentChannelReceivedMessage) {
          chatBloc.add(ReadAllMessagesEvent(widget.chatId));
        }
      },
      builder: (context, chatState) {
        chat = chatState.chats.firstWhere(
            (element) => element.id == widget.chatId,
            orElse: () => chatState.pinnedChats
                .firstWhere((element) => element.id == widget.chatId));
        if (chat.paginationStatus == PaginationStatus.loading) {
          isPaginationEvent = true;
        }
        preProcessingOfMessaging(
          chat.messages ?? [],
          !isPaginationEvent,
          widget.senderName,
          widget.receiverName,
          widget.senderPhoto,
          widget.receiverPhoto,
        );
        if (chat.paginationStatus == PaginationStatus.success) {
          isPaginationEvent = false;
        } else if (chat.paginationStatus != PaginationStatus.initial) {
          isPaginationEvent = true;
        }
        if (chatState.currentChannelReceivedMessage == chat.id) {
          countMessagesReceivedToMeNow++;
        }
        String receiverFullName;
        if (widget.receiverName == 'UK') {
          receiverFullName = 'Un Known user';
        } else {
          receiverFullName = chat.channelMembers!
              .firstWhere((element) => element.userId != _prefsRepository.myId)
              .user!
              .name
              .toString();
        }
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
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: HWEdgeInsetsDirectional.fromSTEB(
                                20.w, 15, 0, 15),
                            child: Transform(
                              alignment: Alignment.center,
                              transform: (Matrix4.identity()
                                ..scale(
                                    LanguageService.languageCode == 'ar'
                                        ? -1.0
                                        : 1.0,
                                    1.0,
                                    1.0)),
                              child: SvgPicture.asset(
                                AppAssets.backFromCallSvg,
                                width: 8.w,
                                color: const Color(0xff388CFF),
                              ),
                            ),
                          ),
                        ),
                        if ((chatState.unReadMessagesFromAllChats -
                                countMessagesReceivedToMeNow) >
                            0) ...{
                          10.horizontalSpace,
                          Text(
                            (chatState.unReadMessagesFromAllChats -
                                    countMessagesReceivedToMeNow)
                                .toString(),
                            style: textTheme.subtitle1?.rr
                                .copyWith(color: const Color(0xff388CFF)),
                          ),
                        },
                        20.horizontalSpace,
                        widget.receiverPhoto != null
                            ? Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1.0,
                                      color: const Color(0xff388cff)),
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
                                      Urls.baseUrl + widget.receiverPhoto!,
                                  imageFit: BoxFit.cover,
                                  height: 40,
                                  width: 40.w,
                                ),
                              )
                            : NoImageWidget(
                                height: 40,
                                width: 40.w,
                                textStyle: context.textTheme.subtitle1?.br
                                    .copyWith(
                                        color: const Color(0xff6638FF),
                                        letterSpacing: 0.18,
                                        height: 1.33),
                                name: widget.receiverName),
                        20.horizontalSpace,
                        Column(
                          children: [
                            Text(
                              receiverFullName,
                              style: textTheme.subtitle1?.mr
                                  .copyWith(color: const Color(0xff5D5C5D)),
                            ),
                            BlocBuilder<AppBloc, AppState>(
                              builder: (context, state) {
                                if(state.typingIds[widget.chatId]?.contains(_prefsRepository.myId) ?? false) {
                                  return Text(
                                    'Typing...',
                                    style: textTheme.subtitle1?.mr
                                        .copyWith(
                                        color: const Color(0xff5D5C5D)),
                                  );
                                }else{
                                  return const SizedBox.shrink();
                                }
                              },
                            ),
                          ],
                        ),
                        const Spacer(),
                        SvgPicture.asset(
                          AppAssets.makeVideoCallSvg,
                          width: 34.w,
                          height: 25,
                        ),
                        30.horizontalSpace,
                        SvgPicture.asset(
                          AppAssets.makeCallSvg,
                          width: 25.w,
                          height: 25,
                        ),
                        20.horizontalSpace
                      ],
                    ),
                  )),
            ),
            body: GestureDetector(onTap: () {
              rebuildMessage.value = -1;
            }, child: LayoutBuilder(builder: (context, constraints) {
              return SafeArea(
                  child: ValueListenableBuilder<int>(
                      valueListenable: rebuildMessage,
                      builder: (context, currentIndex, _) {
                        currentFocusedIcon.value = -2;
                        print('data length: ${data.length}');
                        return Column(
                          children: [
                            Expanded(
                              child: ScrollConfiguration(
                                behavior: const CupertinoScrollBehavior(),
                                child: ListView.builder(
                                  controller: autoScrollController,

                                  physics: const ClampingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return ValueListenableBuilder<int>(
                                        valueListenable: currentFocusedIcon,
                                        builder: (context, focusedIndex, _) {
                                          bool isSent =
                                              (data[index] is TextMessage &&
                                                  (data[index] as TextMessage)
                                                      .isSent);
                                          String? messageId = (data[index]
                                                  is TextMessage)
                                              ? (data[index] as TextMessage)
                                                  .messageId
                                              : (data[index] is ImageMessage)
                                                  ? (data[index]
                                                          as ImageMessage)
                                                      .messageId
                                                  : (data[index]
                                                          is VoiceMessage)
                                                      ? (data[index]
                                                              as VoiceMessage)
                                                          .messageId
                                                      : (data[index]
                                                              is ReplayMessage)
                                                          ? (data[index]
                                                                  as ReplayMessage)
                                                              .messageId
                                                          : (data[index]
                                                                  is ReplayOnMeMessage)
                                                              ? (data[index]
                                                                      as ReplayOnMeMessage)
                                                                  .messageId
                                                              : null;
                                          return AutoScrollTag(
                                            key: ValueKey(index),
                                            index: index,
                                            controller: autoScrollController,
                                            child: Column(
                                              children: [
                                                GestureDetector(
                                                    onLongPress: () {
                                                      if (index != 0) {
                                                        rebuild = false;
                                                        rebuildMessage.value =
                                                            index;
                                                        if (rebuildMessage
                                                                .value ==
                                                            (data.length - 2)) {
                                                          autoScrollController
                                                              .animateTo(
                                                            autoScrollController
                                                                    .position
                                                                    .maxScrollExtent +
                                                                100,
                                                            duration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        100),
                                                            curve: Curves.easeOut,
                                                          );
                                                        }
                                                        Future.delayed(
                                                          const Duration(
                                                              milliseconds: 150),
                                                          () => rebuild = true,
                                                        );
                                                      }
                                                    },
                                                    onTap: () {
                                                      rebuildMessage.value = -1;
                                                    },
                                                    child: data[index]),
                                                currentIndex == index
                                                    ? 5.verticalSpace
                                                    : const SizedBox.shrink(),
                                                currentIndex == index
                                                    ? Padding(
                                                        padding:
                                                            HWEdgeInsets.only(
                                                                left: isSent
                                                                    ? 40.w
                                                                    : 20.w,
                                                                top: 10,
                                                                right: isSent
                                                                    ? 20.w
                                                                    : 40.w),
                                                        child: GestureDetector(
                                                          key: key,
                                                          onPanDown: (details) {
                                                            currentHoverPosition =
                                                                details
                                                                    .localPosition
                                                                    .dx;
                                                            currentFocusedIcon
                                                                    .value =
                                                                (currentHoverPosition -
                                                                        x) ~/
                                                                    20;
                                                          },
                                                          onPanEnd: (details) {
                                                            rebuildMessage.value =
                                                                -1;
                                                          },
                                                          onPanUpdate: (details) {
                                                            print('hi');
                                                            if (details.localPosition
                                                                            .dx <
                                                                        x &&
                                                                    currentFocusedIcon
                                                                            .value ==
                                                                        -1){
                                                              currentFocusedIcon.value=-1;
                                                            return;
                                                            }
                                                                if(details.localPosition
                                                                            .dx >
                                                                        x +
                                                                            225
                                                                                .w &&
                                                                    currentFocusedIcon
                                                                            .value ==
                                                                        5) {
                                                                  currentFocusedIcon
                                                                      .value = 5;
                                                              return;
                                                            }
                                                            final dragDifference =
                                                                details.localPosition
                                                                        .dx -
                                                                    currentHoverPosition;
                                                            print(dragDifference);
                                                            if (dragDifference
                                                                    .abs() >
                                                                20) {
                                                              currentHoverPosition =
                                                                  details
                                                                      .localPosition
                                                                      .dx;
                                                              if (dragDifference >
                                                                  0) {
                                                                currentFocusedIcon
                                                                        .value =
                                                                    min(
                                                                        5,
                                                                        currentFocusedIcon
                                                                                .value +
                                                                            1);
                                                              } else {
                                                                currentFocusedIcon
                                                                        .value =
                                                                    max(
                                                                        -1,
                                                                        currentFocusedIcon
                                                                                .value -
                                                                            1);
                                                              }
                                                            }
                                                          },
                                                          child: Directionality(
                                                            textDirection: ui
                                                                .TextDirection
                                                                .ltr,
                                                            child: Container(
                                                              child: Row(
                                                                mainAxisAlignment: isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  InkWell(
                                                                    onTap: () => replayMessage(
                                                                        chat.messages!.firstWhere((element) =>
                                                                            element
                                                                                .id ==
                                                                            messageId),
                                                                        _prefsRepository
                                                                            .myId),
                                                                    child: Column(
                                                                      children: [
                                                                        Container(
                                                                          height:
                                                                              40,
                                                                          width:
                                                                              35.w,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color: const Color(
                                                                                0xfffafafa),
                                                                            borderRadius:
                                                                                BorderRadius.circular(12.0),
                                                                            boxShadow: const [
                                                                              BoxShadow(
                                                                                color:
                                                                                    Color(0x29000000),
                                                                                offset:
                                                                                    Offset(0, 2),
                                                                                blurRadius:
                                                                                    10,
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          child: Center(
                                                                              child: SvgPicture.asset(
                                                                            AppAssets
                                                                                .replyButtonLogoSvg,
                                                                          )),
                                                                        ),
                                                                        7.verticalSpace,
                                                                        focusedIndex ==
                                                                                -1
                                                                            ? Container(
                                                                                width:
                                                                                    50.w,
                                                                                height:
                                                                                    22,
                                                                                decoration:
                                                                                    BoxDecoration(
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
                                                                                child:
                                                                                    Center(
                                                                                  child: Text(
                                                                                    'Replay',
                                                                                    style: textTheme.overline?.rr.copyWith(color: colorScheme.white, height: 1.4),
                                                                                  ),
                                                                                ),
                                                                              )
                                                                            : const SizedBox
                                                                                .shrink()
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  5.horizontalSpace,
                                                                  Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Row(
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        children: [
                                                                          Container(
                                                                            width:
                                                                                185.w,
                                                                            height:
                                                                                40,
                                                                            padding: HWEdgeInsets.symmetric(
                                                                                vertical:
                                                                                    12,
                                                                                horizontal:
                                                                                    10),
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: const Color(
                                                                                  0xfffafafa),
                                                                              borderRadius:
                                                                                  BorderRadius.circular(12.0),
                                                                              boxShadow: const [
                                                                                BoxShadow(
                                                                                  color:
                                                                                      Color(0x29000000),
                                                                                  offset:
                                                                                      Offset(0, 2),
                                                                                  blurRadius:
                                                                                      10,
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            child:
                                                                                Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                MessageActionWidget(
                                                                                  onTap: () => forwardMessageMethod(chat.messages!.firstWhere((element) =>
                                                                                      element.id ==
                                                                                      messageId)),
                                                                                  iconUrl:
                                                                                      AppAssets.goBackIconSvg,
                                                                                  myIndex:
                                                                                      0,
                                                                                  focusedIndex:
                                                                                      focusedIndex,
                                                                                ),
                                                                                MessageActionWidget(
                                                                                  onTap:
                                                                                      () {},
                                                                                  iconUrl:
                                                                                      AppAssets.copyIconSvg,
                                                                                  myIndex:
                                                                                      1,
                                                                                  focusedIndex:
                                                                                      focusedIndex,
                                                                                ),
                                                                                MessageActionWidget(
                                                                                  onTap:
                                                                                      () {},
                                                                                  iconUrl:
                                                                                      AppAssets.addToGroupSvg,
                                                                                  myIndex:
                                                                                      2,
                                                                                  focusedIndex:
                                                                                      focusedIndex,
                                                                                ),
                                                                                MessageActionWidget(
                                                                                  onTap:
                                                                                      () {},
                                                                                  iconUrl:
                                                                                      AppAssets.removeIconSvg,
                                                                                  myIndex:
                                                                                      3,
                                                                                  focusedIndex:
                                                                                      focusedIndex,
                                                                                ),
                                                                                MessageActionWidget(
                                                                                  onTap:
                                                                                      () {},
                                                                                  iconUrl:
                                                                                      AppAssets.editIconSvg,
                                                                                  myIndex:
                                                                                      4,
                                                                                  focusedIndex:
                                                                                      focusedIndex,
                                                                                ),
                                                                                MessageActionWidget(
                                                                                  onTap:
                                                                                      () {},
                                                                                  iconUrl:
                                                                                      AppAssets.notificationIconSvg,
                                                                                  myIndex:
                                                                                      5,
                                                                                  focusedIndex:
                                                                                      focusedIndex,
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      10.verticalSpace,
                                                                      focusedIndex >=
                                                                              0
                                                                          ? Align(
                                                                          alignment: Alignment(xActionSubtitle , yActionSubtitle +50 ),
                                                                          child: Transform.translate(
                                                                              offset: Offset((focusedIndex+1)*22 , 0),
                                                                              child: MessageSubtitleWidget(focusedIndex: focusedIndex)))
                                                                          : const SizedBox
                                                                              .shrink()
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : const SizedBox.shrink(),
                                              ],
                                            ),
                                          );
                                        });
                                  },
                                  itemCount: data.length,
                                ),
                              ),
                            ),
                            BlocBuilder<AppBloc, AppState>(
                              builder: (context, state) {
                                return ChatInputField(
                                  channelId: chat.id!,
                                  senderName: widget.senderName,
                                  senderUserImage: widget.senderPhoto,
                                  onSendFile: (File file, String type) {
                                    String id = const Uuid().v4();
                                    ChannelMember member = chat.channelMembers!
                                        .firstWhere((element) =>
                                            element.userId !=
                                            _prefsRepository.myId);
                                    chatBloc.add(UploadFileEvent(
                                        file: file,
                                        channelId: member.channelId!,
                                        filePath: type == 'image'
                                            ? 'images/test'
                                            : type == 'file'
                                                ? 'files/test'
                                                : 'voices/test',
                                        messageType: type == 'image'
                                            ? 'ImageMessage'
                                            : type == 'file'
                                                ? 'FileMessage'
                                                : 'VoiceMessage',
                                        isForward: false,
                                        senderParentMessageId:
                                            state.senderParentMessageId,
                                        parentMessageId: state.thereIsReply
                                            ? state.messageId
                                            : null,
                                        messageId: id,
                                        parentMessageContent: type == 'image'
                                            ? 'Photo'
                                            : type == 'file'
                                                ? 'File'
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
                                    print('state: ${state.thereIsReply}');
                                    print('messageId: ${state.messageId}');
                                    String id = const Uuid().v4();
                                    ChannelMember member = chat.channelMembers!
                                        .firstWhere((element) =>
                                            element.userId !=
                                            _prefsRepository.myId);
                                    chatBloc.add(SendMessageEvent(
                                        messageType: 'TextMessage',
                                        channelId: member.channelId!,
                                        isForward: false,
                                        parentMessageId: state.thereIsReply
                                            ? state.messageId
                                            : null,
                                        content: message,
                                        messageId: id,
                                        senderParentMessageId:
                                            state.senderParentMessageId,
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
                        );
                      }));
            })));
      },
    );
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

  void preProcessingOfMessaging(
      List<Message> messages,
      bool scrollToLastMessage,
      String senderName,
      String receiverName,
      String? senderPhoto,
      String? receiverPhoto) {
    if (messages.isEmpty) {
      return;
    }
    data = [10.verticalSpace];
    Map<String, List<Message>> messagesByDate = {};

    isISentLastMessage = messages[0].senderUserId == _prefsRepository.myId;
    for (int i = messages.length - 1; i >= 0; i--) {
      Message element = messages[i];
      final zonedDate = HelperFunctions.replaceArabicNumber(
          DateFormat("yyyy-MM-dd")
              .format(HelperFunctions.getZonedDate(element.createdAt!)));
      if (!messagesByDate.containsKey(zonedDate)) {
        messagesByDate[zonedDate] = [];
      }
      messagesByDate[zonedDate]!.add(element);
    }

    for (String sendDate in messagesByDate.keys) {
      data.add(10.verticalSpace);
      bool thereIsDate = true;
      data.add(MessagesDate(date: formatDate(sendDate)));
      for (int i = messagesByDate[sendDate]!.length - 1; i >= 0; i--) {
        Message element = messages[i];
        MessageStatus? messageStatus = element.messageStatus
            ?.firstWhere((element) => element.userId != _prefsRepository.myId);
        bool isFirstMessage = element.senderUserId !=
            messages[min(messages.length - 1, i + 1)].senderUserId;
        if (i == messages.length - 1) {
          isFirstMessage = true;
        }
        data.add(thereIsDate
            ? 10.verticalSpace
            : isFirstMessage
                ? 30.verticalSpace
                : 10.verticalSpace);
        thereIsDate = false;
        if (element.parentMessageId != null) {
          Message parentMessage = element.parentMessage!;
          MessageStatus? parentMessageStatus = parentMessage.messageStatus
              ?.firstWhere(
                  (element) => element.userId != _prefsRepository.myId);
          int index = data.indexWhere((e) {
            if(e is TextMessage){
              return e.messageId==element.parentMessageId;
            }else if(e is ImageMessage){

              return e.messageId==element.parentMessageId;
            }else if(e is VoiceMessage){
              return e.messageId==element.parentMessageId;
            }else {
              return false;
            }
          });
          if (parentMessage.senderUserId != element.senderUserId) {
            print('parent message');
            print( _prefsRepository.myId.toString());
          print(parentMessage.senderUserId);
          print(parentMessage.receiverUserId);
            data.add(ReplayMessage(
                messageDate: element.createdAt!,
                scrollToMessage: () =>scrollToIndex(index),
                messageId: element.parentMessageId!,
                answeredFilePath: element.mediaMessageContent?[0].filePath,
                messageAnswer: element.messageContent?.content,
                isFirstMessage: !isISentLastMessage,
                replayedPhoto:
                    parentMessage.id == _prefsRepository.myId.toString()
                        ? senderPhoto
                        : receiverPhoto,
                replayedName:
                    parentMessage.id == _prefsRepository.myId.toString()
                        ? senderName
                        : receiverName,
                senderAnswerName: senderName,
                senderAnswerPhoto: senderPhoto,
                isSent: element.senderUserId == _prefsRepository.myId,
                parentSenderId: parentMessage.senderUserId!,
                isReplayedMessageRead: parentMessageStatus?.isWatched ?? false,
                isReplayedMessageReceived:
                    (parentMessageStatus?.isReceived ?? 0) == 1,
                isAnswerMessageRead: messageStatus?.isWatched ?? false,
                isAnswerMessageReceived: (messageStatus?.isReceived ?? 0) == 1,
                answeredFile: element.file,
                message: parentMessage.messageContent?.content == null
                    ? parentMessage.messageType!.name == 'ImageMessage'
                        ? 'Photo'
                        : parentMessage.messageType!.name == 'FileMessage'
                            ? 'File'
                            : 'Voice'
                    : parentMessage.messageContent!.content.toString(),
                messageAnswerId: element.id!));
          } else {
            data.add(ReplayOnMeMessage(
                messageDate: element.createdAt!,
                messageId: element.parentMessageId!,
                answeredFilePath: element.mediaMessageContent?[0].filePath,
                messageAnswer: element.messageContent?.content,
                answeredFile: element.file,
                scrollToMessage: () =>scrollToIndex(index),
                isFirstMessage: !isISentLastMessage,
                parentSenderId: parentMessage.senderUserId!,
                replayedPhoto:
                    parentMessage.id == _prefsRepository.myId.toString()
                        ? senderPhoto
                        : receiverPhoto,
                replayedName:
                    parentMessage.id == _prefsRepository.myId.toString()
                        ? senderName
                        : receiverName,
                senderAnswerName: senderName,
                senderAnswerPhoto: senderPhoto,
                isReplayedMessageRead: parentMessageStatus?.isWatched ?? false,
                isReplayedMessageReceived:
                    (parentMessageStatus?.isReceived ?? 0) == 1,
                isAnswerMessageRead: messageStatus?.isWatched ?? false,
                isAnswerMessageReceived: (messageStatus?.isReceived ?? 0) == 1,
                isSent: element.senderUserId == _prefsRepository.myId,
                message: parentMessage.messageContent?.content == null
                    ? parentMessage.messageType!.name == 'ImageMessage'
                        ? 'Photo'
                        : parentMessage.messageType!.name == 'FileMessage'
                            ? 'File'
                            : 'Voice'
                    : parentMessage.messageContent!.content.toString(),
                messageAnswerId: element.id!));
          }
        } else if (element.messageType!.name == 'TextMessage') {
          data.add(TextMessage(
            message: element.messageContent!.content.toString(),
            messageId: element.messageContent!.messageId.toString(),
            senderId: element.senderUserId!,
            isSent: element.receiverUserId != _prefsRepository.myId,
            isRead: messageStatus?.isWatched ?? false,
            userMessageName: element.receiverUserId != _prefsRepository.myId
                ? senderName
                : receiverName,
            userMessagePhoto: element.receiverUserId != _prefsRepository.myId
                ? senderPhoto
                : receiverPhoto,
            isReceived: (messageStatus?.isReceived ?? 0) == 1,
            isFirstMessage: isFirstMessage,
            time: element.createdAt!,
            isForwarded: element.isForward == 1,
          ));
        } else if (element.messageType!.name == 'FileMessage') {
        } else if (element.messageType!.name == 'VoiceMessage') {
          if (element.file != null) {
            data.add(
              VoiceMessage(
                isSent: element.receiverUserId != _prefsRepository.myId,
                file: element.file,
                messageId: element.id.toString(),
                senderId: element.senderUserId!,
                userMessageName: element.receiverUserId != _prefsRepository.myId
                    ? senderName
                    : receiverName,
                userMessagePhoto:
                    element.receiverUserId != _prefsRepository.myId
                        ? senderPhoto
                        : receiverPhoto,
                time: element.createdAt!,
                isRead: messageStatus?.isWatched ?? false,
                isReceived: (messageStatus?.isReceived ?? 0) == 1,
                isFirstMessage: isFirstMessage,
                isForwarded: element.isForward == 1,
              ),
            );
          } else {
            for (int i = 0;
                i < (element.mediaMessageContent?.length ?? 0);
                i++) {
              data.add(
                VoiceMessage(
                  isSent: element.receiverUserId != _prefsRepository.myId,
                  fileUrl: element.mediaMessageContent![i].filePath,
                  messageId:
                      element.mediaMessageContent![i].messageId.toString(),
                  time: element.createdAt!,
                  senderId: element.senderUserId!,
                  userMessageName:
                      element.receiverUserId != _prefsRepository.myId
                          ? senderName
                          : receiverName,
                  userMessagePhoto:
                      element.receiverUserId != _prefsRepository.myId
                          ? senderPhoto
                          : receiverPhoto,
                  file: element.file,
                  isFirstMessage: isFirstMessage,
                  isRead: messageStatus?.isWatched ?? false,
                  isReceived: (messageStatus?.isReceived ?? 0) == 1,
                  isForwarded: element.isForward == 1,
                ),
              );
              if (i != element.mediaMessageContent!.length - 1) {
                data.add(10.verticalSpace);
              }
            }
          }
        } else {
          if (element.file != null) {
            data.add(
              ImageMessage(
                isSent: element.receiverUserId != _prefsRepository.myId,
                imageFile: element.file,
                messageId: element.id.toString(),
                senderId: element.senderUserId!,
                time: element.createdAt!,
                userMessageName: element.receiverUserId != _prefsRepository.myId
                    ? senderName
                    : receiverName,
                userMessagePhoto:
                    element.receiverUserId != _prefsRepository.myId
                        ? senderPhoto
                        : receiverPhoto,
                isFirstMessage: isFirstMessage,
                isRead: messageStatus?.isWatched ?? false,
                isReceived: (messageStatus?.isReceived ?? 0) == 1,
                isLocalMessage: true,
                isForwarded: element.isForward == 1,
              ),
            );
          } else {
            for (int i = 0;
                i < (element.mediaMessageContent?.length ?? 0);
                i++) {
              data.add(
                ImageMessage(
                  isSent: element.receiverUserId != _prefsRepository.myId,
                  imageUrl: element.mediaMessageContent![i].filePath,
                  messageId:
                      element.mediaMessageContent![i].messageId.toString(),
                  time: element.createdAt!,
                  senderId: element.senderUserId!,
                  userMessageName:
                      element.receiverUserId != _prefsRepository.myId
                          ? senderName
                          : receiverName,
                  userMessagePhoto:
                      element.receiverUserId != _prefsRepository.myId
                          ? senderPhoto
                          : receiverPhoto,
                  isRead: messageStatus?.isWatched ?? false,
                  isReceived: (messageStatus?.isReceived ?? 0) == 1,
                  isFirstMessage: isFirstMessage,
                  isLocalMessage: false,
                  isForwarded: element.isForward == 1,
                ),
              );
              if (i != element.mediaMessageContent!.length - 1) {
                data.add(10.verticalSpace);
              }
            }
          }
        }
      }
    }
    data.add(30.verticalSpace);
    rebuildMessage.value = data.length;
    if (scrollToLastMessage) {
      print('scrolling');
      scrollToTheEnd();
    }
  }

  void forwardMessageMethod(Message message) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ChatPages(
                  navigateForForwardMessage: true,
                  onSendForwardMessage: (int receiverId) {
                    if (message.messageType!.name == 'TextMessage') {
                      chatBloc.add(SendMessageEvent(
                          messageType: message.messageType!.name,
                          channelId: message.channelId!,
                          isForward: false,
                          parentMessageId: null,
                          content: message.messageContent!.content,
                          messageId: message.id!,
                          senderParentMessageId: null,
                          parentMessageContent: null,
                          receiverUserId: receiverId));
                    } else {
                      chatBloc.add(SendMessageEvent(
                          channelId: message.channelId!,
                          mediaContent: [
                            {
                              'file_path':
                                  message.mediaMessageContent?[0].filePath,
                              'caption': 'test image'
                            }
                          ],
                          messageType: message.messageType!.name,
                          isForward: false,
                          senderParentMessageId: null,
                          parentMessageId: null,
                          messageId: message.id!,
                          parentMessageContent: null,
                          receiverUserId: receiverId));
                    }
                    BlocProvider.of<AppBloc>(context).add(RefreshChatInputField(
                        false, '', false,
                        messageId: null,
                        message: null,
                        senderParentMessageId: null,
                        imageUrl: null,
                        time: null));
                  },
                )));
  }

  void replayMessage(Message message, int? myId) {
    BlocProvider.of<AppBloc>(context).add(RefreshChatInputField(
        true,
        message.messageType!.name == 'TextMessage'
            ? 'text'
            : message.messageType!.name == 'TextMessage'
                ? 'image'
                : 'voice',
        message.senderUserId == myId,
        messageId: message.id,
        senderParentMessageId: message.senderUserId,
        message: message.messageContent?.content ??
            (message.messageType!.name == 'TextMessage' ? 'Photo' : 'Voice'),
        imageUrl:
            message.mediaMessageContent?.first.filePath ?? message.file?.path,
        time: message.createdAt));
  }
  void scrollToIndex(int index) async{
    print(index);
    await autoScrollController.scrollToIndex(index , preferPosition: AutoScrollPosition.middle);
  }
  void _loadMoreMessages() {
    print('reach');
    chatBloc.add(GetMessagesForChatEvent(channelId: widget.chatId));
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

