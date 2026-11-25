import 'package:trydos/features/chat/presentation/pages/chat_list_design.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_v2/call_row_v2.dart';
import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/responsive_padding.dart';
import 'package:trydos/core/utils/theme_state.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/calls/presentation/bloc/calls_bloc.dart';
import 'package:trydos/features/calls/presentation/utils/caller_info.dart';
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
  ValueNotifier<int> typingIndicator = ValueNotifier(0);
  Timer? _typingTimer;

  @override
  void initState() {
    callsBloc = BlocProvider.of<CallsBloc>(context);

    _typingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        if (typingIndicator.value == 5) {
          typingIndicator.value = 0;
        } else {
          typingIndicator.value++;
        }
      } else {
        // إيقاف الـ Timer إذا تم التخلص من الـ Widget
        timer.cancel();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    // إيقاف الـ Timer
    _typingTimer?.cancel();

    // تنظيف ValueNotifier
    typingIndicator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // صفّ المكالمة بالتصميم الجديد — [CallRowFaceV2]. والقديم تحته.
    //
    // النبرات الثلاث مشتقّةٌ من الحقلين اللذين عند الصفّ القديم، لا من حقلٍ
    // جديد: ما لم يُجَب وارداً فهو **فائتة**، وما جاوزت مدّتُه صفراً فهو
    // **واردة** بسطر الدقائق تحته، وما عداه **بلا ردّ**.
    final CallRowKindV2 kind = widget.isMissing
        ? CallRowKindV2.missed
        : (widget.isIncome && widget.duration > 0
              ? CallRowKindV2.incoming
              : CallRowKindV2.noAnswer);
    return CallRowFaceV2(
      kind: kind,
      name: widget.fullReceiverName,
      time: widget.createAt == null
          ? ''
          : (!widget.createAt!.isUtc
                ? HelperFunctions.getDateInFormat(widget.createAt!)
                : HelperFunctions.getZonedDateInFormat(widget.createAt!)),
      label: switch (kind) {
        CallRowKindV2.missed =>
          widget.isVoice
              ? LocaleKeys.missed_voice_call.tr()
              : LocaleKeys.missed_video_call.tr(),
        CallRowKindV2.incoming =>
          widget.isVoice
              ? LocaleKeys.incoming_voice_call.tr()
              : LocaleKeys.incoming_video_call.tr(),
        CallRowKindV2.noAnswer => LocaleKeys.no_answer.tr(),
      },
      minutesLabel: kind == CallRowKindV2.incoming
          ? LocaleKeys.n_min.tr(
              namedArgs: {'n': '${(widget.duration / 60).ceil()}'},
            )
          : null,
      photo: _photoV2(),
      initials: widget.photoPath.isEmpty
          ? HelperFunctions.getTheFirstTwoLettersOfName(widget.fullReceiverName)
          : null,
      onTap: _startCallV2,
    );
  }

  /// يبدأ المكالمة — جسم نقرة الصفّ القديم حرفاً بحرف، مستخرَجاً
  /// ليستعمله معه صفُّ التصميم الجديد.
  ///
  /// **وشاشةُ المكالمة نفسها لا تُنقَل عن الويب.** للملف شاشةٌ خاصّة بها
  /// (`components/DemoApp1/screens/CallScreen.tsx`)، وقرّر المالك إبقاء
  /// مكالماتنا كما هي: `MakeCallEvent` ثم `AgoraInAppWebView` — أي صفحةُ
  /// ويبٍ داخل التطبيق. فالتصميم الجديد يمسّ **صفَّ السجلّ** وحده
  /// ([CallRowFaceV2])، لا ما يحدث بعد النقر عليه.
  Future<void> _startCallV2() async {
    if (widget.isVoice) {
      List<Map<String, dynamic>> info = callerInfo(channelId: widget.chatId);
      PermissionStatus microphone = await Permission.microphone.request();
      var status2 = await Permission.mediaLibrary.request();
      if (microphone.isGranted && status2.isGranted) {
        //todo we have the receiver id so the chat dose not exist
        if (info[0].containsKey('currentReceiver')) {
          debugPrint('currentReceiver${info[0]['currentReceiver']}');

          GetIt.I<CallsBloc>().add(
            MakeCallEvent(
              receiverUserId: info[0]['currentReceiver'].toString(),
              isVideo: false,
              receiverCallName: widget.fullReceiverName,
              payload: info[1],
            ),
          );

          // GetIt.I<CallsBloc>().add(VideoCallEvent(
          //     receiverUserId: info[0]['currentReceiver'],
          //     payload: info[1]));
          //todo we need to wait the response to get the new chat id and join the video call so the navigation will be in the listener
        }
        //todo else the chat already exist so we don't have the receiver id just the chat id
        else {
          debugPrint('widget.chatId${widget.chatId}');
          debugPrint('info[0]${info[0]}');

          GetIt.I<CallsBloc>().add(
            MakeCallEvent(
              isVideo: false,
              chatId: widget.chatId,
              receiverCallName: widget.fullReceiverName,
              payload: info[0],
            ),
          );
          //todo we have the id of the chat so we can move to the call immediately
        }
      } else if (microphone.isDenied || status2.isDenied) {
        showWarningMessage(context, LocaleKeys.permission_denied.tr());
        openAppSettings();
      }
      ;
    } else {
      List<Map<String, dynamic>> info = callerInfo(channelId: widget.chatId);
      PermissionStatus microphone = await Permission.microphone.request();
      var status2 = await Permission.mediaLibrary.request();
      if (microphone.isGranted && status2.isGranted) {
        //todo we have the receiver id so the chat dose not exist
        if (info[0].containsKey('currentReceiver')) {
          debugPrint('currentReceiver${info[0]['currentReceiver']}');

          GetIt.I<CallsBloc>().add(
            MakeCallEvent(
              receiverUserId: info[0]['currentReceiver'].toString(),
              isVideo: true,
              receiverCallName: widget.fullReceiverName,
              payload: info[1],
            ),
          );

          // GetIt.I<CallsBloc>().add(VideoCallEvent(
          //     receiverUserId: info[0]['currentReceiver'],
          //     payload: info[1]));
          //todo we need to wait the response to get the new chat id and join the video call so the navigation will be in the listener
        }
        //todo else the chat already exist so we don't have the receiver id just the chat id
        else {
          debugPrint('widget.chatId${widget.chatId}');
          debugPrint('info[0]${info[0]}');

          GetIt.I<CallsBloc>().add(
            MakeCallEvent(
              isVideo: true,
              chatId: widget.chatId,
              receiverCallName: widget.fullReceiverName,
              payload: info[0],
            ),
          );
          //todo we have the id of the chat so we can move to the call immediately
        }
      } else if (microphone.isDenied || status2.isDenied) {
        showWarningMessage(context, LocaleKeys.permission_denied.tr());
        openAppSettings();
      }
    }
  }

  /// صورة المتّصل في الصفّ الجديد، أو `null` فتُرسم حرفا اسمه.
  Widget _photoV2() {
    if (widget.photoPath.isEmpty) return const SizedBox.shrink();
    return MyCachedNetworkImage(
      imageUrl: widget.photoPath.contains('media_server')
          ? widget.photoPath
          : '${dotenv.env['Media_S3_Server']}${widget.photoPath}',
      imageFit: BoxFit.cover,
      width: ChatListDesign.callPhoto.w,
      height: ChatListDesign.callPhoto.h,
      // بلا تدويرٍ داخليّ: [RowPhotoV2] يقصّ بنصف قطر 15.
      radius: 0,
    );
  }
}

class SlidableActionWidgete extends StatelessWidget {
  const SlidableActionWidgete({
    Key? key,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.iconUrl,
    required this.text,
  }) : super(key: key);
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
            SvgPicture.asset(iconUrl, width: 25.h, height: 25.h),
            8.verticalSpace,
            Text(
              text,
              style: context.textTheme.titleMedium?.rq.copyWith(
                color: foregroundColor,
              ),
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
