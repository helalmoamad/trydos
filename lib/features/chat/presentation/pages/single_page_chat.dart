import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/app_bloc/app_bloc.dart';
import 'package:trydos/app_bloc/app_event.dart';
import 'package:trydos/app_bloc/app_state.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/core/utils/responsive_padding.dart';
import 'package:trydos/features/app/trydos_app_bar/app_bar_params.dart';
import 'package:trydos/features/app/trydos_app_bar/trydos_appbar.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_input_field.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/image_message.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/missed_call.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/reply_messge.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/reply_on_me_message.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/voice_message.dart';

import '../widgets/chat_widgets/text_message.dart';

class SinglePageChat extends StatefulWidget {
  const SinglePageChat({Key? key}) : super(key: key);

  @override
  State<SinglePageChat> createState() => _SinglePageChatState();
}

class _SinglePageChatState extends State<SinglePageChat> {
  final ValueNotifier<int> rebuildMessage = ValueNotifier(-1);
  final ValueNotifier<int> currentFocusedIcon = ValueNotifier(-1);
  double currentHoverPosition = -1;
  double x = -1;
  final ScrollController scrollController = ScrollController();
  List<bool> isSent = [
    false,
    false,
    false,
    true,
    false,
    true,
    false,
    false,
    false,
    false,
    false,
    true,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
  ];
  final key = GlobalKey();

  List<Widget> data = [
    10.verticalSpace,
    const MessagesDate(date: 'YESTERDAY'),
    10.verticalSpace,
    const TextMessage(
        message: 'How are you?',
        isSent: true,
        isFirstMessage: true,
        messageId: '1'),
    10.verticalSpace,
    const TextMessage(
        message:
            'The person who says it cannot be only onc done should not interrupt the person who is doing it.',
        isSent: true,
        messageId: '2',
        isFirstMessage: false),
    30.verticalSpace,
    const TextMessage(
        message: 'i am fine',
        isSent: false,
        messageId: '3',
        isFirstMessage: true),
    10.verticalSpace,
    const TextMessage(
        message:
            'The person who says it cannot be done should not interrupt the person who isdoing it.The person who says it cannot be done should not interrupt the person whois doing it.The person who says it cannotbe done should not interrupt the personwho is doing it.The person who says itcannot bedone should not interrupt the person whois doing it.The person who says it cannotbedone should not interrupt the personwho is doing it.',
        isSent: false,
        messageId: '4',
        isFirstMessage: false),
    30.verticalSpace,
    const VoiceMessage(isSent: true, isFirstMessage: true, messageId: '5'),
    30.verticalSpace,
    const ImageMessage(isSent: false, isFirstMessage: true, messageId: '6'),
    10.verticalSpace,
    const MissedCall(
      message: 'Missed Call At 20:16  "Two Hours Ago"',
      isFirstMessage: true,
    ),
    30.verticalSpace,
    const ReplayMessage(
        message:
            'The person who says it cannot be only onc done should not interrupt the person who is doing it.'),
    10.verticalSpace,
    const ReplayOnMeMessage(
        message:
            'The person who says it cannot be only onc done should not interrupt the person who is doing it.'),
    30.verticalSpace
  ];
  bool rebuild = true;

  @override
  void initState() {
    scrollController.addListener(() {
      if (rebuild) {
        rebuildMessage.value = -1;
      }
    });
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
        resizeToAvoidBottomInset: true,
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
                      'Marie Winter',
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
                                      return Column(
                                        children: [
                                          GestureDetector(
                                              onLongPress: () {
                                                if (index != 0) {
                                                  rebuild = false;
                                                  rebuildMessage.value = index;
                                                  scrollController.animateTo(
                                                    scrollController.position.maxScrollExtent+55,
                                                    duration: const Duration(
                                                        milliseconds: 100),
                                                    curve: Curves.easeOut,
                                                  );
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
                                          5.verticalSpace,
                                          currentIndex == index
                                              ? Padding(
                                                  padding: HWEdgeInsets.only(
                                                      left: isSent[index]
                                                          ? 40.w
                                                          : 20.w,
                                                      top: 10,
                                                      right: isSent[index]
                                                          ? 20.w
                                                          : 40.w),
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
                                          (index == data.length - 2 &&
                                                  currentIndex != -1)
                                              ? 40.verticalSpace
                                              : const SizedBox.shrink()
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
                              onSendMessage: (String message) {
                                data.removeLast();
                                isSent.removeLast();
                                if (state.thereIsReply) {
                                  data.add(10.verticalSpace);
                                  isSent.add(false);
                                  if (state.replyOnMe) {
                                    data.add(
                                        ReplayOnMeMessage(message: message));
                                    isSent.add(true);
                                  } else {
                                    data.add(10.verticalSpace);
                                    isSent.add(false);
                                      data.add(ReplayMessage(message: message));
                                      isSent.add(true);
                                    }
                                  BlocProvider.of<AppBloc>(context).add(
                                      RefreshChatInputField(false, '', false));
                                } else {
                                  data.add(10.verticalSpace);
                                  isSent.add(false);
                                  data.add(
                                    TextMessage(
                                        message: message,
                                        isSent: true,
                                        messageId: data.length.toString(),
                                        isFirstMessage:
                                            isSent[isSent.length - 1]
                                                ? false
                                                : true),
                                  );
                                  isSent.add(
                                      isSent[isSent.length - 1] ? false : true);
                                }
                                scrollController.animateTo(
                                  scrollController.position.maxScrollExtent +
                                      40,
                                  duration: const Duration(milliseconds: 100),
                                  curve: Curves.easeOut,
                                );
                                data.add(30.verticalSpace);
                                isSent.add(false);
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
