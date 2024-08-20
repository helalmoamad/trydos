import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trydos/common/constant/configuration/chat_url_routes.dart';
import 'package:trydos/common/constant/design/assets_provider.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/responsive_padding.dart';
import 'package:trydos/core/utils/theme_state.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/calls/presentation/bloc/calls_bloc.dart';
import 'package:trydos/features/calls/presentation/pages/in_app_view.dart';
import 'package:trydos/features/calls/presentation/utils/caller_info.dart';
import 'package:trydos/features/calls/presentation/widgets/no_image_widget.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_card.dart';
import 'package:trydos/generated/locale_keys.g.dart';

class CallsCard extends StatefulWidget {
  const CallsCard({
    Key? key,
    this.index = 0,
    this.isMissing = false,
    this.isIncome = false,
    required this.createAt,
    required this.photoPath,
    required this.chatId,
    required this.duration,
    required this.fullReceiverName,
    required this.messageType,
    required this.callRegId,
    required this.isVoice,
  }) : super(key: key);
  final String photoPath;
  final int duration;
  final String chatId;
  final bool isVoice;
  final String callRegId;
  final String fullReceiverName;
  final bool isMissing;
  final String messageType;
  final bool isIncome;

  final int index;
  final DateTime? createAt;

  @override
  State<CallsCard> createState() => _CallsCardState();
}

class _CallsCardState extends ThemeState<CallsCard> {
  late CallsBloc callsBloc;
  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();
  ValueNotifier<int> typingIndicator = ValueNotifier(0);

  @override
  void initState() {
    callsBloc = BlocProvider.of<CallsBloc>(context);

    Timer.periodic(const Duration(seconds: 1), (timer) {
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
    typingIndicator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        height: widget.index == 0 ? 0 : 0.4,
        color: const Color(0xffC8C7CC),
        margin: HWEdgeInsetsDirectional.only(start: 94),
      ),
      Slidable(
        startActionPane: ActionPane(
            motion: const ScrollMotion(),
            extentRatio: 0.25,
            children: [
              SlidableActionWidget(
                text: LocaleKeys.delete.tr(),
                backgroundColor: const Color(0xffFFE8E8),
                foregroundColor: const Color(0xffFA6868),
                iconUrl: AppAssets.binSvg,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                        title: Text(LocaleKeys.delete_message.tr()),
                        actions: [
                          MaterialButton(
                            onPressed: () {
                              callsBloc.add(DeleteMessageEvent(
                                  deleteFromId: _prefsRepository.myChatId!,
                                  type: "call",
                                  deleteFromBoth: 0,
                                  messageId: widget.callRegId));
                              callsBloc.add(DeleteMessageEvent(
                                  deleteFromId: _prefsRepository.myChatId!,
                                  type: "message",
                                  deleteFromBoth: 0,
                                  channelId: widget.chatId,
                                  messageId: widget.callRegId));
                              Navigator.of(context).pop();
                            },
                            child: Text(LocaleKeys.only_me.tr()),
                          ),
                          SizedBox(
                            width: 20.w,
                          ),
                          MaterialButton(
                            onPressed: () {
                              callsBloc.add(DeleteMessageEvent(
                                  type: "call",
                                  deleteFromBoth: 1,
                                  messageId: widget.callRegId,
                                  deleteFromId: _prefsRepository.myChatId!));
                              callsBloc.add(DeleteMessageEvent(
                                  deleteFromId: _prefsRepository.myChatId!,
                                  type: "message",
                                  deleteFromBoth: 1,
                                  channelId: widget.chatId,
                                  messageId: widget.callRegId));
                              Navigator.of(context).pop();
                            },
                            child: Text(LocaleKeys.everyone.tr()),
                          )
                        ]),
                  );
                },
              )
            ]),
        child: InkWell(
          onTap: () async {
            if (widget.isVoice) {
              List<Map<String, dynamic>> info =
                  callerInfo(channelId: widget.chatId);
              PermissionStatus microphone =
                  await Permission.microphone.request();
              var status2 = await Permission.mediaLibrary.request();
              if (microphone.isGranted && status2.isGranted) {
                //todo we have the receiver id so the chat dose not exist
                if (info[0].containsKey('currentReceiver')) {
                  debugPrint('currentReceiver${info[0]['currentReceiver']}');

                  GetIt.I<CallsBloc>().add(MakeCallEvent(
                      receiverUserId: info[0]['currentReceiver'].toString(),
                      isVideo: false,
                      receiverCallName: widget.fullReceiverName,
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
                      chatId: widget.chatId,
                      receiverCallName: widget.fullReceiverName,
                      payload: info[0]));
                  //todo we have the id of the chat so we can move to the call immediately
                }
              } else if (microphone.isDenied || status2.isDenied) {
                showMessage(LocaleKeys.permission_denied.tr());
                openAppSettings();
              }
              ;
            } else {
              List<Map<String, dynamic>> info =
                  callerInfo(channelId: widget.chatId);
              PermissionStatus microphone =
                  await Permission.microphone.request();
              var status2 = await Permission.mediaLibrary.request();
              if (microphone.isGranted && status2.isGranted) {
                //todo we have the receiver id so the chat dose not exist
                if (info[0].containsKey('currentReceiver')) {
                  debugPrint('currentReceiver${info[0]['currentReceiver']}');

                  GetIt.I<CallsBloc>().add(MakeCallEvent(
                      receiverUserId: info[0]['currentReceiver'].toString(),
                      isVideo: true,
                      receiverCallName: widget.fullReceiverName,
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
                      isVideo: true,
                      chatId: widget.chatId,
                      receiverCallName: widget.fullReceiverName,
                      payload: info[0]));
                  //todo we have the id of the chat so we can move to the call immediately
                }
              } else if (microphone.isDenied || status2.isDenied) {
                showMessage(LocaleKeys.permission_denied.tr());
                openAppSettings();
              }
            }
          },
          child: Container(
              height: 75,
              width: 1.sw,
              padding: HWEdgeInsets.only(left: 15.w, right: 30.w, top: 8),
              color: widget.isMissing
                  ? const Color(0xFFFFFCFC)
                  : colorScheme.white,
              child: Row(children: [
                Container(
                  height: 55,
                  width: 55.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                        width: 1.0,
                        color: widget.isMissing
                            ? const Color(0xffff5f61)
                            : widget.isIncome
                                ? const Color(0xff388CFF)
                                : const Color(0xffFFC05C)),
                  ),
                  child: widget.photoPath != ""
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
                            imageUrl: ChatUrls.baseUrl + widget.photoPath,
                            imageFit: BoxFit.cover,
                            progressIndicatorBuilderWidget: TrydosLoader(),
                            height: 40,
                            width: 40.w,
                          ),
                        )
                      : NoImageWidget(
                          height: 40,
                          width: 40.w,
                          textStyle: context.textTheme.bodyMedium?.br.copyWith(
                              color: const Color(0xff6638FF),
                              letterSpacing: 0.18,
                              height: 1.33),
                          name: HelperFunctions.getTheFirstTwoLettersOfName(
                              widget.fullReceiverName)),
                ),
                24.horizontalSpace,
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Text(
                                  widget.fullReceiverName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodyMedium?.rr
                                      .copyWith(color: const Color(0xff505050)),
                                ),
                                30.horizontalSpace
                              ],
                            ),
                            10.verticalSpace,
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  widget.isMissing
                                      ? AppAssets.callMissingSvg
                                      : widget.isIncome
                                          ? AppAssets.callIncomeSvg
                                          : AppAssets.callOutgoingSvg,
                                  height: 15.sp,
                                  width: 15.sp,
                                ),
                                10.horizontalSpace,
                                Text(
                                  widget.isMissing
                                      ? LocaleKeys.missed_call.tr()
                                      : widget.isIncome
                                          ? LocaleKeys.income.tr()
                                          : LocaleKeys.Outcome.tr(),
                                  maxLines: 1,
                                  style: textTheme.titleLarge?.lr.copyWith(
                                      color: Color(widget.isMissing
                                          ? 0xffFF5F61
                                          : 0xff8E8D92)),
                                ),
                              ],
                            ),
                          ]),
                      const Spacer(),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Text(
                                HelperFunctions.replaceArabicNumber(
                                    HelperFunctions.getDatesInFormat(
                                            widget.createAt!)
                                        .toString()),
                                maxLines: 1,
                                style: textTheme.bodySmall?.rr
                                    .copyWith(color: const Color(0xff8E8D92)),
                              ),
                              Text(
                                " ، ",
                                maxLines: 1,
                                style: textTheme.bodySmall?.rr.copyWith(
                                    color: const Color(0xff8E8D92),
                                    fontSize: 20),
                              ),
                              Text(
                                HelperFunctions.replaceArabicNumber(
                                  !widget.createAt!.isUtc
                                      ? HelperFunctions.gettimesInFormat(
                                              widget.createAt!)
                                          .toString()
                                      : HelperFunctions.gettimesInFormat(
                                              widget.createAt!)
                                          .toString(),
                                ),
                                maxLines: 2,
                                style: textTheme.bodySmall?.rr
                                    .copyWith(color: const Color(0xff8E8D92)),
                              ),
                            ],
                          ),
                          widget.duration > 0
                              ? Row(
                                  children: [
                                    Text(
                                      "المدة : ",
                                      style:
                                          TextStyle(color: Color(0xff8E8D92)),
                                    ),
                                    Text(
                                      fromSecond(widget.duration),
                                      maxLines: 1,
                                      style: textTheme.bodySmall?.rr.copyWith(
                                          color: const Color(0xff8E8D92)),
                                    ),
                                  ],
                                )
                              : SizedBox.shrink(),
                        ],
                      ),
                    ],
                  ),
                )
              ])),
        ),
      )
    ]);
  }
}

class SlidableActionWidgete extends StatelessWidget {
  const SlidableActionWidgete(
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
      height: 92,
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
              style: context.textTheme.titleMedium?.rr
                  .copyWith(color: foregroundColor),
            ),
          ],
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
    return HelperFunctions.getDatesInFormat(dateStr);
  }
}

/*class Counter {
  int callDuration = 0;
  bool isRunning = false;
  Timer? timer;
  void startCounter() {
    if (!isRunning) {
      isRunning = true;
      callDuration = 0;
      timer = Timer.periodic(Duration(seconds: 1), (timer) {
        callDuration++;
      });
    }
  }

  void stopCounter() {
    if (!isRunning) {
      isRunning = false;
      callDuration = 0;

      timer?.cancel();
    }
  }
}*/
String fromSecond(int second) {
  if (second == 0) {
    return "";
  }
  int hours = (second ~/ 3600);
  String minutes = ((second % 3600) ~/ 60) < 10
      ? ((second % 3600) ~/ 60).toString().padLeft(2, "0")
      : ((second % 3600) ~/ 60).toString();
  String seconds = (second % 60) < 10
      ? (second % 60).toString().padLeft(2, "0")
      : (second % 60).toString();
  if (hours == 0) {
    return "${minutes}:${seconds}";
  }
  return "${hours}:${minutes}:${seconds}";
}
