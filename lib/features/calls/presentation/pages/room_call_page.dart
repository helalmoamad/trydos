
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get_it/get_it.dart';
// import 'package:trydos/config/theme/my_color_scheme.dart';
// import 'package:trydos/core/domin/repositories/prefs_repository.dart';
// import 'package:trydos/features/calls/presentation/bloc/calls_bloc.dart';
//
// import '../../../../common/constant/configuration/global.dart';
//
// class RoomCallPage extends StatefulWidget {
//   RoomCallPage({super.key});
//
//   @override
//   State<RoomCallPage> createState() => _RoomCallPageState();
// }
//
// class _RoomCallPageState extends State<RoomCallPage> {
//   late RtcEngine _engine;
//   bool loading = true;
//   List remoteIds = [];
//   double xPosition = 0.0;
//   double yPosition = 0.0;
//   bool muteAudio = false;
//
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     super.dispose();
//     _dispose();
//     // _engine.de
//     // _engine.leaveChannel();
//     // _engine.destroy();
//   }
//   Future<void> _dispose() async {
//     await _engine.leaveChannel();
//     await _engine.release();
//   }
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//   }
//
//   Future<void> initializeAgora(String token, String channelName) async {
//
//
//     _engine = createAgoraRtcEngine();
//     await _engine.initialize(const RtcEngineContext(
//       appId: Constants.agoraAppId,
//       channelProfile: ChannelProfileType.channelProfileCommunication,
//     ));
//     await _engine.enableVideo();
//     _engine.registerEventHandler(RtcEngineEventHandler(
//
//       onUserJoined: (rtcConnection , uid, elapsed) {
//         debugPrint("userJoinde $uid");
//         setState(() {
//           remoteIds.add(uid);
//         });
//       },
//       onUserOffline: (rtcConnection ,uid, reason) async {
//         await _engine.leaveChannel();
//
//         GetIt.I<CallsBloc>().add(EndVideoCallEvent());
//         Navigator.of(context).pop();
//         debugPrint("userOffLine");
//         // setState(() {
//         //   remoteIds.remove(uid);
//         // });
//       },
//     ));
//     await _engine
//         .joinChannel(
//       token: token,
//         uid:  GetIt.I<PrefsRepository>().myChatId!
//         , channelId: channelName, options: const ChannelMediaOptions())
//         .then((value) {
//       setState(() {
//         loading = false;
//       });
//     });
//
//     // await _engine.leaveChannel();
//     // _engine = await RtcEngine.createWithContext(
//     //     RtcEngineContext(Constants.agoraAppId));
//     // await _engine.enableVideo();
//     // await _engine.setChannelProfile(ChannelProfile.Communication);
//     // _engine.setEventHandler(RtcEngineEventHandler(
//     //   error: (err) {
//     //     debugPrint("errorAgora${err}");
//     //   },
//     //   joinChannelSuccess: (channel, uid, elapsed) =>
//     //       debugPrint("Channel joinde"),
//     //   userJoined: (uid, elapsed) {
//     //     debugPrint("userJoinde $uid");
//     //     setState(() {
//     //       remoteIds.add(uid);
//     //     });
//     //   },
//     //   userOffline: (uid, reason) async {
//     //     await _engine.leaveChannel();
//     //
//     //     GetIt.I<CallsBloc>().add(EndVideoCallEvent());
//     //     Navigator.of(context).pop();
//     //     debugPrint("userOffLine");
//     //     // setState(() {
//     //     //   remoteIds.remove(uid);
//     //     // });
//     //   },
//     // ));
//     //
//     // await _engine
//     //     .joinChannel(
//     //         token, channelName, null, GetIt.I<PrefsRepository>().myChatId!)
//     //     .then((value) {
//     //   setState(() {
//     //     loading = false;
//     //   });
//     // });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: BlocConsumer<CallsBloc, CallsState>(
//         builder: (context, state) {
//           if (state.createVideoCallStatus == CreateVideoCallStatus.loading)
//             return Center(
//               child: CircularProgressIndicator(),
//             );
//           else {
//             debugPrint('initializeAgoradsz');
//             initializeAgora(state.agoraToken!, state.channelName!);
//             return loading
//                 ? Center(
//                     child: CircularProgressIndicator(),
//                   )
//                 : Stack(
//                     children: [
//                       Center(
//                         child: renderRemoteView(state.channelName!),
//                       ),
//                       Positioned(
//                           top: yPosition,
//                           left: xPosition,
//                           child: GestureDetector(
//                             // onPanUpdate: (details) {
//                             //   setState(() {
//                             //     xPosition += details.delta.dx;
//                             //     yPosition += details.delta.dy;
//                             //   });
//                             // },
//                             child: Container(
//                                 width: 100.w,
//                                 height: 130.h,
//                                 child:  AgoraVideoView(
//                                   controller: VideoViewController(
//                                     rtcEngine: _engine,
//                                     canvas: VideoCanvas(uid: GetIt.I<PrefsRepository>().myChatId!),
//                                   ),
//                                 )// rtc_local_view.SurfaceView()
//                             ),
//                           )),
//                       Align(
//                         alignment: Alignment.bottomCenter,
//                         child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceAround,
//                             children: [
//                               CircleAvatar(
//                                 backgroundColor: Colors.white,
//                                 child: IconButton(
//                                     onPressed: () {
//                                       muteAudio = !muteAudio;
//                                       _engine.muteLocalAudioStream(muteAudio);
//                                     },
//                                     icon: Icon(
//                                       Icons.volume_mute,
//                                       size: 18,
//                                       color: Colors.black,
//                                     )),
//                               ),
//                               CircleAvatar(
//                                 child: IconButton(
//                                     onPressed: () async {
//                                       GetIt.I<CallsBloc>()
//                                           .add(EndVideoCallEvent());
//                                       await _engine.leaveChannel();
//                                       Navigator.of(context).pop();
//                                     },
//                                     icon: Icon(
//                                       color: Colors.black,
//                                       Icons.call_end,
//                                       size: 18,
//                                     )),
//                                 radius: 20,
//                                 backgroundColor: Colors.white,
//                               ),
//                               CircleAvatar(
//                                 backgroundColor: Colors.white,
//                                 child: IconButton(
//                                     onPressed: () {
//                                       _engine.switchCamera();
//                                     },
//                                     icon: Icon(
//                                       Icons.switch_camera,
//                                       size: 18,
//                                       color: Colors.black,
//                                     )),
//                               )
//                             ]),
//                       )
//                     ],
//                   );
//           }
//         },
//         listener: (context, state) {},
//       ),
//     );
//   }
//
//   Widget renderRemoteView(String channelName) {
//     if (remoteIds.isNotEmpty) {
//       if (remoteIds.length == 1) {
//         return AgoraVideoView(
//           controller: VideoViewController.remote(
//             rtcEngine: _engine,
//             canvas: VideoCanvas(uid: remoteIds[0]),
//             connection:  RtcConnection(channelId: channelName),
//           ),
//         );
//         // return rtc_remote_view.SurfaceView(
//         //   uid: remoteIds[0],
//         //   channelId: channelName,
//         // );
//       } else if (remoteIds.length == 2) {
//         return Column(
//           children: [
//             // rtc_remote_view.SurfaceView(
//             //   uid: remoteIds[0],
//             //   channelId: channelName,
//             // ),
//             // rtc_remote_view.SurfaceView(
//             //   uid: remoteIds[1],
//             //   channelId: channelName,
//             // ),
//             AgoraVideoView(
//               controller: VideoViewController.remote(
//                 rtcEngine: _engine,
//                 canvas: VideoCanvas(uid: remoteIds[0]),
//                 connection:  RtcConnection(channelId: channelName),
//               ),
//             ),
//             AgoraVideoView(
//               controller: VideoViewController.remote(
//                 rtcEngine: _engine,
//                 canvas: VideoCanvas(uid: remoteIds[1]),
//                 connection:  RtcConnection(channelId: channelName),
//               ),
//             )
//           ],
//         );
//       } else {
//         return SizedBox();
//       }
//     } else {
//       return MyTextWidget("no user joindex");
//     }
//   }
// }
