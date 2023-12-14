// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as rtc_local_view;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtc_remote_view;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/calls/presentation/bloc/calls_bloc.dart';

import '../../../../common/constant/configuration/global.dart';

class RoomCallPage extends StatefulWidget {
  RoomCallPage({super.key});

  @override
  State<RoomCallPage> createState() => _RoomCallPageState();
}

class _RoomCallPageState extends State<RoomCallPage> {
  late RtcEngine _engine;
  bool loading = true;
  List remoteIds = [];
  double xPosition = 0.0;
  double yPosition = 0.0;
  bool muteAudio = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    // _engine.de
    _engine.leaveChannel();
    _engine.destroy();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<void> initializeAgora(String token, String channelName) async {
    // await _engine.leaveChannel();
    _engine = await RtcEngine.createWithContext(
        RtcEngineContext(Constants.agoraAppId));
    await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfile.Communication);
    _engine.setEventHandler(RtcEngineEventHandler(
      error: (err) {
        debugPrint("errorAgora${err}");
      },
      joinChannelSuccess: (channel, uid, elapsed) =>
          debugPrint("Channel joinde"),
      userJoined: (uid, elapsed) {
        debugPrint("userJoinde $uid");
        setState(() {
          remoteIds.add(uid);
        });
      },
      userOffline: (uid, reason) {
        debugPrint("userOffLine");
        setState(() {
          remoteIds.remove(uid);
        });
      },
    ));

    await _engine
        .joinChannel(
            token, channelName, null, GetIt.I<PrefsRepository>().myChatId!)
        .then((value) {
      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<CallsBloc, CallsState>(
        builder: (context, state) {
          initializeAgora(state.agoraToken!, state.channelName!);
          return loading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Stack(
                  children: [
                    Center(
                      child: renderRemoteView(state.channelName!),
                    ),
                    Positioned(
                        top: yPosition,
                        left: xPosition,
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            setState(() {
                              xPosition += details.delta.dx;
                              yPosition += details.delta.dy;
                            });
                          },
                          child: Container(
                              width: 100.w,
                              height: 130.h,
                              child: rtc_local_view.SurfaceView()),
                        )),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                                onPressed: () {
                                  muteAudio = !muteAudio;
                                  _engine.muteLocalAudioStream(muteAudio);
                                },
                                icon: Icon(
                                  Icons.volume_mute,
                                  size: 18,
                                )),
                            IconButton(
                                onPressed: () {
                                  _engine.leaveChannel();
                                },
                                icon: Icon(
                                  Icons.call_end,
                                  size: 18,
                                )),
                            IconButton(
                                onPressed: () {
                                  _engine.switchCamera();
                                },
                                icon: Icon(Icons.switch_camera, size: 18))
                          ]),
                    )
                  ],
                );
        },
        listener: (context, state) {},
      ),
    );
  }

  Widget renderRemoteView(String channelName) {
    if (remoteIds.isNotEmpty) {
      if (remoteIds.length == 1) {
        return rtc_remote_view.SurfaceView(
          uid: remoteIds[0],
          channelId: channelName,
        );
      } else if (remoteIds.length == 2) {
        return Column(
          children: [
            rtc_remote_view.SurfaceView(
              uid: remoteIds[0],
              channelId: channelName,
            ),
            rtc_remote_view.SurfaceView(
              uid: remoteIds[1],
              channelId: channelName,
            ),
          ],
        );
      } else {
        return SizedBox();
      }
    } else {
      return Text("no user joindex");
    }
  }
}
