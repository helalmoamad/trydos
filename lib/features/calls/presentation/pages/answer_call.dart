import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/features/calls/presentation/bloc/calls_bloc.dart';
import 'package:trydos/features/calls/presentation/pages/room_call_page.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/routes/router.dart';
import 'package:vibration/vibration.dart';
import '../../../../common/constant/configuration/chat_url_routes.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../../../../config/theme/typography.dart';
import '../../../app/app_widgets/loading_indicator/trydos_loader.dart';
import '../../../app/my_cached_network_image.dart';
import '../../../app/my_text_widget.dart';
import '../../../chat/presentation/manager/chat_event.dart';
import '../widgets/call_status_widget.dart';
import '../../../chat/presentation/widgets/chat_widgets/no_image_widget.dart';
import 'agora_webview.dart';

class AnswerCall extends StatefulWidget {
  String channelName;
  String messageId;
  String callerName;
  String? callerPhoto;

  AnswerCall(
      {required this.callerPhoto,
      required this.callerName,
      required this.channelName,
      required this.messageId,
      super.key});

  @override
  State<AnswerCall> createState() => _AnswerCallState();
}

class _AnswerCallState extends State<AnswerCall> {
  var player = AudioPlayer();

  @override
  void dispose() {
    GetIt.I<CallsBloc>().add(InitResponseRejectVideoCallEvent());

    Vibration.cancel();
    player.stop();
    // TODO: implement dispose
    super.dispose();
  }

  late ChatBloc chatBloc;

  @override
  void initState() {
    chatBloc = BlocProvider.of<ChatBloc>(context);
    if (GetIt.I<CallsBloc>().state.makeCallStatus == MakeCallStatus.endCall) {
      Navigator.of(context).pop();
      debugPrint('poppp');
    } else {
      Vibration.vibrate(repeat: 0, pattern: [1000, 1000, 1000, 1000]);
      player.setReleaseMode(ReleaseMode.loop);
      player.play(AssetSource(
        'audio/Whatsapp_Tone.mp3',
      ));
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      chatBloc.add(SendErrorChatToServerEvent(
          error: error.toString(), lastPage: "Answer_Call"));
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };

    // er.oGoRoutf(context).p
    return Scaffold(
      backgroundColor: colorScheme.black,
      body: BlocConsumer<CallsBloc, CallsState>(
        builder: (context, state) {
          return Column(
            children: [
              Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  140.verticalSpace,
                  Center(
                      child: widget.callerPhoto != null
                          ? Container(
                              height: 200,
                              width: 200.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                    width: 1.0, color: const Color(0xff388cff)),
                                boxShadow: [
                                  BoxShadow(
                                      color:
                                          colorScheme.white.withOpacity(0.35),
                                      offset: const Offset(0, 10),
                                      blurRadius: 30,
                                      spreadRadius: 10),
                                ],
                              ),
                              child: MyCachedNetworkImage(
                                  imageUrl:
                                      ChatUrls.baseUrl + widget.callerPhoto!,
                                  imageFit: BoxFit.cover,
                                  progressIndicatorBuilderWidget:
                                      TrydosLoader(),
                                  height: 80.h,
                                  width: 60.w),
                            )
                          : NoImageWidget(
                              width: 120.w,
                              height: 180.h,
                              textStyle: context.textTheme.bodyMedium?.br
                                  .copyWith(
                                      color: const Color(0xff6638FF),
                                      letterSpacing: 0.18,
                                      height: 1.33),
                              name: widget.callerName)),
                  15.verticalSpace,
                  MyTextWidget(
                    widget.callerName,
                    style: textTheme.headlineSmall?.rr
                        .copyWith(color: const Color(0xffD3D3D3)),
                  ),
                  80.verticalSpace,
                  CallStatusWidget(
                    text: LocaleKeys.calling.tr(),
                    iconUrl: AppAssets.callingSvg,
                    textColor: colorScheme.grey200,
                  ),
                ],
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                      width: 100.w,
                      height: 100.h,
                      child: TextButton(
                        onPressed: () async {
                          await Vibration.cancel();
                          await player.stop();
                          await [Permission.camera, Permission.microphone]
                              .request()
                              .then((value) {
                            GetIt.I<CallsBloc>().add(AnswerVideoCallEvent(
                                chatId: widget.channelName,
                                messageId: widget.messageId));
                          });
                        },
                        child: MyTextWidget(
                          LocaleKeys.answer.tr(),
                          style: TextStyle(color: Colors.green),
                        ),
                      )),
                  TextButton(
                      onPressed: () async {
                        GetIt.I<CallsBloc>().add(RejectVideoCallEvent(
                          messageId: widget.messageId,
                          duration: 0,
                        ));
                        Navigator.of(context).pop();
                      },
                      child: Container(
                          width: 100.w,
                          height: 100.h,
                          child: Center(
                              child: MyTextWidget(
                            LocaleKeys.reject.tr(),
                            style: TextStyle(color: Colors.red),
                          ))))
                ],
              )
            ],
          );
        },
        // listenWhen: (previous, current) =>
        //     previous.createVideoCallStatus != current.createVideoCallStatus,
        listener: (context, state) {
          debugPrint("zczczxc");
          if (state.makeCallStatus == MakeCallStatus.endCall) {
            debugPrint("adasd");
            Navigator.of(context).pop();
          }

          // else  if (state.rejectVideoCallStatus == RejectVideoCallStatus.success)
          //    Navigator.pop(context);
          //  else if (state.createVideoCallStatus == CreateVideoCallStatus.success) {
          //    debugPrint("anmzxch");
          //    Navigator.of(context).push(MaterialPageRoute(
          //      builder: (context) =>
          //          AgoraWebView(type: "video", channelId: widget.channelName, auth_token: state.agoraToken!, uId: GetIt.I<PrefsRepository>().myChatId!.toString(),),
          //
          //    ));
          //  }
        },
      ),
    );
  }
}
