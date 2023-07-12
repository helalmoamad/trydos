import 'dart:io';
import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/core/utils/responsive_padding.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_state.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_input_field.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/image_message.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/reply_messge.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/reply_on_me_message.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../app/app_widgets/trydos_app_bar/app_bar_params.dart';
import '../../../app/app_widgets/trydos_app_bar/trydos_appbar.dart';
import '../../../app/blocs/app_bloc/app_bloc.dart';
import '../../../app/blocs/app_bloc/app_event.dart';
import '../../data/models/my_chats_response_model.dart';
import '../manager/chat_bloc.dart';
import '../widgets/chat_widgets/text_message.dart';
import '../widgets/chat_widgets/voice_message.dart';

class SinglePageChat extends StatefulWidget {
  const SinglePageChat(
      {Key? key, required this.messages, required this.receiverName})
      : super(key: key);

  final List<Message> messages;
  final String receiverName;

  @override
  State<SinglePageChat> createState() => _SinglePageChatState();
}

class _SinglePageChatState extends State<SinglePageChat> {
  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();
  late ChatBloc chatBloc;

  final ValueNotifier<int> rebuildMessage = ValueNotifier(-1);
  final ValueNotifier<int> currentFocusedIcon = ValueNotifier(-1);
  double currentHoverPosition = -1;
  double x = -1;
  final ScrollController scrollController = ScrollController();
  final key = GlobalKey();
  bool isISentLastMessage = false;
  List<Widget> data = [];
  bool rebuild = true;
  DateTime lastDate = DateTime.now();

  @override
  void initState() {
    chatBloc = BlocProvider.of<ChatBloc>(context);
    scrollController.addListener(() {
      if (rebuild) {
        rebuildMessage.value = -1;
      }
    });
    isISentLastMessage =
        widget.messages[0].senderUserId == _prefsRepository.myId;
    for (int i = widget.messages.length - 1; i >= 0; i--) {
      Message element = widget.messages[i];
      bool previousIsDate = false;
      bool isFirstMessage = element.senderUserId !=
          widget.messages[min(widget.messages.length - 1, i + 1)].senderUserId;
      if (i == widget.messages.length - 1) {
        isFirstMessage = true;
      }
      final zonedDate = HelperFunctions.getZonedDate(element.createdAt!);
      if ((zonedDate.day != lastDate.day) ||
          ((zonedDate.month != lastDate.month) ||
          (zonedDate.day != lastDate.day)) ) {
        data.add(10.verticalSpace);
        previousIsDate = true;
        data.add(MessagesDate(
            date: getMessageDate(lastDate , zonedDate)));
        lastDate = zonedDate;
      }else if(i==widget.messages.length - 1){
        data.add(10.verticalSpace);
        data.add(MessagesDate(
            date: getMessageDate(lastDate , zonedDate)));
      }
      print(isFirstMessage);
      data.add(previousIsDate
          ? 10.verticalSpace
          : isFirstMessage
              ? 10.verticalSpace
              : 10.verticalSpace);
      previousIsDate = false;
      if (element.messageType!.name == 'TextMessage') {
        data.add(TextMessage(
          message: element.messageContent!.content.toString(),
          messageId: element.messageContent!.messageId.toString(),
          isSent: element.receiverUserId != _prefsRepository.myId,
          isFirstMessage: isFirstMessage,
          time: element.createdAt!,
          isForwarded: element.isForward == 1,
        ));
      } else if(element.messageType!.name == 'VoiceMessage'){
        for (int i = 0; i < (element.mediaMessageContent?.length ?? 0); i++) {
          data.add(
            VoiceMessage(
              isSent: element.receiverUserId != _prefsRepository.myId,
              fileUrl: element.mediaMessageContent![i].filePath,
              messageId: element.mediaMessageContent![i].messageId.toString(),
              time: element.createdAt!,
              isFirstMessage: isFirstMessage,
              isForwarded: element.isForward == 1,
            ),
          );
          if (i != element.mediaMessageContent!.length - 1) {
            data.add(10.verticalSpace);
          }
        }
      }
        else {
          for (int i = 0; i < (element.mediaMessageContent?.length ?? 0); i++) {
          data.add(
            ImageMessage(
              isSent: element.receiverUserId != _prefsRepository.myId,
              imageUrl: element.mediaMessageContent![i].filePath,
              messageId: element.mediaMessageContent![i].messageId.toString(),
              time: element.createdAt!,
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
    data.add(30.verticalSpace);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
      final RenderBox renderBox =
          key.currentContext!.findRenderObject() as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero);
      x = position.dx;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                        padding:
                            HWEdgeInsetsDirectional.fromSTEB(20.w, 15, 0, 15),
                        child: SvgPicture.asset(
                          AppAssets.backFromCallSvg,
                          width: 8.w,
                          color: const Color(0xff388CFF),
                        ),
                      ),
                    ),
                    10.horizontalSpace,
                    Text(
                      '2',
                      style: textTheme.subtitle1?.rr
                          .copyWith(color: const Color(0xff388CFF)),
                    ),
                    20.horizontalSpace,
                    Container(
                      height: 40,
                      width: 40.w,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(AppAssets.chatProfile2Jpg),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
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
                    ),
                    20.horizontalSpace,
                    Text(
                      widget.receiverName,
                      style: textTheme.subtitle1?.mr
                          .copyWith(color: const Color(0xff5D5C5D)),
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
                    currentFocusedIcon.value = -1;
                    return Column(
                      children: [
                        Expanded(
                          child: ScrollConfiguration(
                            behavior: const CupertinoScrollBehavior(),
                            child: ListView.builder(
                              controller: scrollController,
                              physics: const ClampingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return ValueListenableBuilder<int>(
                                    valueListenable: currentFocusedIcon,
                                    builder: (context, focusedIndex, _) {
                                      bool isSent = (data[index]
                                              is TextMessage &&
                                          (data[index] as TextMessage).isSent);
                                      return Column(
                                        children: [
                                          GestureDetector(
                                              onLongPress: () {
                                                if (index != 0) {
                                                  rebuild = false;
                                                  rebuildMessage.value = index;
                                                  if (rebuildMessage.value ==
                                                      (data.length - 2)) {
                                                    scrollController.animateTo(
                                                      scrollController.position
                                                              .maxScrollExtent +
                                                          100,
                                                      duration: const Duration(
                                                          milliseconds: 100),
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
                                                  padding: HWEdgeInsets.only(
                                                      left:
                                                          isSent ? 40.w : 20.w,
                                                      top: 10,
                                                      right:
                                                          isSent ? 20.w : 40.w),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Column(
                                                        children: [
                                                          Container(
                                                            height: 40,
                                                            width: 35.w,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: const Color(
                                                                  0xfffafafa),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12.0),
                                                              boxShadow: const [
                                                                BoxShadow(
                                                                  color: Color(
                                                                      0x29000000),
                                                                  offset:
                                                                      Offset(
                                                                          0, 2),
                                                                  blurRadius:
                                                                      10,
                                                                ),
                                                              ],
                                                            ),
                                                            child: Center(
                                                                child:
                                                                    SvgPicture
                                                                        .asset(
                                                              AppAssets
                                                                  .replyButtonLogoSvg,
                                                            )),
                                                          ),
                                                          7.verticalSpace,
                                                          Container(
                                                            width: 50.w,
                                                            height: 22,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: const Color(
                                                                  0xff404040),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                              boxShadow: const [
                                                                BoxShadow(
                                                                  color: Color(
                                                                      0x34000000),
                                                                  offset:
                                                                      Offset(
                                                                          0, 3),
                                                                  blurRadius: 6,
                                                                ),
                                                              ],
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                'Replay',
                                                                style: textTheme
                                                                    .overline
                                                                    ?.rr
                                                                    .copyWith(
                                                                        color: colorScheme
                                                                            .white,
                                                                        height:
                                                                            1.4),
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      5.horizontalSpace,
                                                      GestureDetector(
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
                                                                  25;
                                                        },
                                                        onPanEnd: (details) {
                                                          rebuildMessage.value =
                                                              -1;
                                                        },
                                                        onPanUpdate: (details) {
                                                          print('hi');
                                                          if ((details.localPosition
                                                                          .dx <
                                                                      x &&
                                                                  currentFocusedIcon
                                                                          .value ==
                                                                      0) ||
                                                              (details.localPosition
                                                                          .dx >
                                                                      x +
                                                                          185
                                                                              .w &&
                                                                  currentFocusedIcon
                                                                          .value ==
                                                                      5)) {
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
                                                                      0,
                                                                      currentFocusedIcon
                                                                              .value -
                                                                          1);
                                                            }
                                                          }
                                                        },
                                                        child: Container(
                                                          width: 185.w,
                                                          height: 40,
                                                          padding: HWEdgeInsets
                                                              .symmetric(
                                                                  vertical: 12,
                                                                  horizontal:
                                                                      10),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: const Color(
                                                                0xfffafafa),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12.0),
                                                            boxShadow: const [
                                                              BoxShadow(
                                                                color: Color(
                                                                    0x29000000),
                                                                offset: Offset(
                                                                    0, 2),
                                                                blurRadius: 10,
                                                              ),
                                                            ],
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              SvgPicture.asset(
                                                                AppAssets
                                                                    .goBackIconSvg,
                                                                width:
                                                                    focusedIndex ==
                                                                            0
                                                                        ? 20.sp
                                                                        : 15.sp,
                                                                height:
                                                                    focusedIndex ==
                                                                            0
                                                                        ? 20
                                                                        : 15,
                                                              ),
                                                              SvgPicture.asset(
                                                                AppAssets
                                                                    .copyIconSvg,
                                                                width:
                                                                    focusedIndex ==
                                                                            1
                                                                        ? 20.sp
                                                                        : 15.sp,
                                                                height:
                                                                    focusedIndex ==
                                                                            1
                                                                        ? 20
                                                                        : 15,
                                                              ),
                                                              SvgPicture.asset(
                                                                AppAssets
                                                                    .addToGroupSvg,
                                                                width:
                                                                    focusedIndex ==
                                                                            2
                                                                        ? 20.sp
                                                                        : 15.sp,
                                                                height:
                                                                    focusedIndex ==
                                                                            2
                                                                        ? 20
                                                                        : 15,
                                                              ),
                                                              SvgPicture.asset(
                                                                AppAssets
                                                                    .removeIconSvg,
                                                                width:
                                                                    focusedIndex ==
                                                                            3
                                                                        ? 20.sp
                                                                        : 15.sp,
                                                                height:
                                                                    focusedIndex ==
                                                                            3
                                                                        ? 20
                                                                        : 15,
                                                              ),
                                                              SvgPicture.asset(
                                                                AppAssets
                                                                    .editIconSvg,
                                                                width:
                                                                    focusedIndex ==
                                                                            4
                                                                        ? 20.sp
                                                                        : 15.sp,
                                                                height:
                                                                    focusedIndex ==
                                                                            4
                                                                        ? 20
                                                                        : 15,
                                                              ),
                                                              SvgPicture.asset(
                                                                AppAssets
                                                                    .notificationIconSvg,
                                                                width:
                                                                    focusedIndex ==
                                                                            5
                                                                        ? 20.sp
                                                                        : 15.sp,
                                                                height:
                                                                    focusedIndex ==
                                                                            5
                                                                        ? 20
                                                                        : 15,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : const SizedBox.shrink(),
                                        ],
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
                              onSendFile: (File file, String type) {
                                data.removeLast();
                                if (state.thereIsReply) {
                                  data.add(10.verticalSpace);
                                  if (state.replyOnMe) {
                                    data.add(ReplayOnMeMessage(
                                      messageDate: state.time!,
                                      messageId: state.messageId!,
                                      isFirstMessage: !isISentLastMessage,
                                      isSent: true,
                                      message: state.message!,
                                      answeredFile: file,
                                      messageAnswerId: data.length.toString(),
                                    ));
                                  } else {
                                    data.add(10.verticalSpace);
                                    data.add(ReplayMessage(
                                      messageDate: state.time!,
                                      messageId: state.messageId!,
                                      isFirstMessage: !isISentLastMessage,
                                      isSent: true,
                                      message: state.message!,
                                      answeredFile: file,
                                      messageAnswerId: data.length.toString(),
                                    ));
                                  }
                                } else {
                                  data.add(10.verticalSpace);
                                  if(type=='image') {
                                    data.add(
                                      ImageMessage(
                                          isSent: true,
                                          imageFile: file,
                                          time: DateTime.now(),
                                          messageId: data.length.toString(),
                                          isFirstMessage: !isISentLastMessage),
                                    );
                                  }else{
                                    data.add(
                                      VoiceMessage(
                                          isSent: true,
                                          file: file,
                                          time: DateTime.now(),
                                          messageId: data.length.toString(),
                                          isFirstMessage: !isISentLastMessage),
                                    );
                                  }
                                }
                                isISentLastMessage = true;
                                data.add(30.verticalSpace);
                                scrollController.animateTo(
                                  scrollController.position.maxScrollExtent +
                                      50,
                                  duration: const Duration(milliseconds: 100),
                                  curve: Curves.easeOut,
                                );
                                Message m = widget.messages.first;
                                chatBloc.add(UploadFileEvent(
                                    file: file,
                                    channelId: widget.messages[0].channelId!,
                                    filePath: type == 'image' ? 'images/test' : 'voices/test',
                                    messageType: type == 'image' ?'ImageMessage':'VoiceMessage',
                                    isForward: state.thereIsReply,
                                    parentMessageId: state.messageId != null
                                        ? int.parse(state.messageId!)
                                        : null,
                                    messageId: const Uuid().v4(),
                                    receiverUserId:
                                        m.senderUserId == _prefsRepository.myId
                                            ? m.receiverUserId
                                            : m.senderUserId));
                                BlocProvider.of<AppBloc>(context).add(
                                    RefreshChatInputField(false, '', false,
                                        messageId: null,
                                        message: null,
                                        imageUrl: null,
                                        time: null));
                                rebuildMessage.value = data.length;
                              },
                              onSendMessage: (String message) {
                                data.removeLast();
                                if (state.thereIsReply) {
                                  data.add(10.verticalSpace);
                                  if (state.replyOnMe) {
                                    print(state.time!);
                                    data.add(ReplayOnMeMessage(
                                      messageDate: state.time!,
                                      messageId: state.messageId!,
                                      messageAnswer: message,
                                      isFirstMessage: !isISentLastMessage,
                                      isSent: true,
                                      message: 'Photo',
                                      messageAnswerId: data.length.toString(),
                                    ));
                                  } else {
                                    data.add(10.verticalSpace);
                                    data.add(ReplayMessage(
                                      messageDate: state.time!,
                                      messageId: state.messageId!,
                                      messageAnswer: message,
                                      isFirstMessage: !isISentLastMessage,
                                      isSent: true,
                                      message: 'Photo',
                                      messageAnswerId: data.length.toString(),
                                    ));
                                  }
                                } else {
                                  data.add(10.verticalSpace);
                                  data.add(
                                    TextMessage(
                                        message: message,
                                        isSent: true,
                                        time: DateTime.now(),
                                        messageId: data.length.toString(),
                                        isFirstMessage: !isISentLastMessage),
                                  );
                                }
                                isISentLastMessage = true;
                                data.add(30.verticalSpace);
                                scrollController.animateTo(
                                  scrollController.position.maxScrollExtent +
                                      50,
                                  duration: const Duration(milliseconds: 100),
                                  curve: Curves.easeOut,
                                );
                                print(state.messageId);
                                Message m = widget.messages.first;
                                chatBloc.add(SendMessageEvent(
                                    messageType: 'TextMessage',
                                    channelId: widget.messages[0].channelId!,
                                    isForward: state.thereIsReply,
                                    parentMessageId: state.messageId != null
                                        ? int.parse(state.messageId!)
                                        : null,
                                    content: message,
                                    messageId: const Uuid().v4(),
                                    receiverUserId:
                                        m.senderUserId == _prefsRepository.myId
                                            ? m.receiverUserId
                                            : m.senderUserId));
                                BlocProvider.of<AppBloc>(context).add(
                                    RefreshChatInputField(false, '', false,
                                        messageId: null,
                                        message: null,
                                        imageUrl: null,
                                        time: null));
                                rebuildMessage.value = data.length;
                              },
                            );
                          },
                        ),
                        0.2.verticalSpace
                      ],
                    );
                  }));
        })));
  }

  getMessageDate(DateTime lastDate, DateTime zonedDate) {

    return ((DateTime.now().difference(zonedDate).inDays).abs() == 0)
        ? 'TODAY'
        : (lastDate.difference(zonedDate).inDays.abs() == 1)
        ? 'YESTERDAY'
        : DateFormat("yyyy-MM-dd").format(zonedDate);
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
