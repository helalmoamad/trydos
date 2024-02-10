// import 'package:dartz/dartz_unsafe.dart';
// import 'package:get_it/get_it.dart';
// import 'package:injectable/injectable.dart';
// import 'package:pusher_client_fixed/pusher_client_fixed.dart';
// import 'package:trydos/core/domin/repositories/prefs_repository.dart';
// import 'package:trydos/features/calls/presentation/bloc/calls_bloc.dart';
// import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
// import 'package:trydos/service/language_service.dart';
// import 'dart:convert' as convert;
// import '../../../app/blocs/app_bloc/app_bloc.dart';
// import '../../../app/blocs/app_bloc/app_event.dart';
// import '../../data/models/my_chats_response_model.dart';
// import '../manager/chat_event.dart';
// @LazySingleton()
// class PusherChatService {
//   Map<String, Channel> presenceChannels = {};
//   Map<String, bool> publicChannels = {};
//   late PusherClient pusher;
//   final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();
//   ChatBloc chatBloc = GetIt.I<ChatBloc>();
//   CallsBloc callBloc = GetIt.I<CallsBloc>();
//   Future initialization() async {
//     PusherOptions options = PusherOptions(
//       encrypted: true,
//       cluster: 'ap2',
//       auth: PusherAuth(
//         'http://chating_staging_trydos.trydos.tech/broadcasting/auth',
//         headers: {
//           'Authorization': 'Bearer ${_prefsRepository.chatToken}',
//         },
//       ),
//     );
//     pusher = PusherClient("cd403c68a9fbb7ce7da6", options,
//         autoConnect: false, enableLogging: false);
//     await pusher.connect();
//     pusher.onConnectionStateChange((state) {
//       debugPrint(state?.currentState ?? 'null state');
//     });
//     pusher.onConnectionError((state) {
//       debugPrint(state?.message ?? 'null message');
//       debugPrint(state?.code ?? 'null code');
//       debugPrint(state?.exception ?? 'null exception');
//     });
//   }
//
//   //@pragma('vm:entry-point')
//   subscribe(String channelName) async {
//     if (publicChannels.containsKey(channelName)) return;
//     Channel channel = pusher.subscribe(channelName);
//     channel.bind('ChannelReceivedEvent', (event) {
//       // debugPrint('ChannelReceivedEventData ${event?.data ?? 'Empty'}');
//       Map<String, dynamic> data = convert.jsonDecode(event!.data.toString());
//       chatBloc.add(ReceiveMessageFromPusherEvent(data['channel_id'].toString(),
//           data['auth_user_id'], data['last_message_id']));
//     });
//
//     channel.bind('ChannelWatchedEvent', (event) {
//       debugPrint('ChannelWatchedEventData ${event?.data ?? 'Empty'}');
//       Map<String, dynamic> data = convert.jsonDecode(event!.data.toString());
//       chatBloc.add(WatchedMessageFromPusherEvent(data['channel_id'].toString(),
//           data['auth_user_id'], data['last_message_id']));
//     });
//
//     //todo later....
//     // channel.bind('VideoCallEvent', (event) {
//     //
//     //
//     //
//     //
//     // });
//
//     // channel.bind('AnswerCallEvent', (event) {
//     //   Navigator.of(navigatorKey.currentState!.context).push(MaterialPageRoute(
//     //     builder: (context) =>
//     //
//     //         // AgoraWebView(type: "video", channelId: widget.channelName, token: state.agoraToken!, uId: GetIt.I<PrefsRepository>().myChatId!.toString(),),
//     //
//     //     AgoraWebView()
//     //         ,
//     //   ));
//     // });
//
//     //channel.bind('InAnotherCallEvent', (event) {});
//
//     publicChannels[channelName] = true;
//   }
//
//   Map<String, String> descTranslation = {
//     "Typing...": "يكتب...",
//     "Recording...": "يسجل مقطع صوتي...",
//     "Sending file...": "يرسل ملف...",
//   };
//   deleteAllPresenceChannels(List<Chat> chats){
//     for(int i=0; i< chats.length ; i++) {
//       if (!presenceChannels.containsKey("presence-typing-${chats[i].id}"))
//         continue;
//       pusher.unsubscribe("presence-typing-${chats[i].id}");
//       presenceChannels.remove("presence-typing-${chats[i].id}");
//     }
//   }
//   subscribeToAllPresenceChannels(List<Chat> chats){
//     if(presenceChannels.length == chats.length)return;
//     for(int i=0; i< chats.length ; i++) {
//       if (presenceChannels.containsKey("presence-typing-${chats[i].id}"))
//         continue;
//       createPresenceChannel(chats[i].id.toString());
//     }
//   }
//   createPresenceChannel(String channelName) async {
//     if (presenceChannels.containsKey("presence-typing-$channelName")) return;
//     Channel channel = pusher.subscribe("presence-typing-$channelName");
//     presenceChannels["presence-typing-$channelName"] = channel;
//     channel.bind('client-TypingEvent', (event) {
//       Map<String, dynamic> data = convert.jsonDecode(event!.data.toString());
//       if (data['desc'] == 'null' || data['desc'] == null) {
//         debugPrint('yes it is');
//         GetIt.I<AppBloc>()
//             .add(RemoveUserFromTypingList(int.parse(data['id'].toString())));
//         return;
//       }
//       if (LanguageService.languageCode == 'ar') {
//         data['desc'] = descTranslation[data['desc']] ?? data['desc'];
//       }
//       GetIt.I<AppBloc>().add(AddUserToTypingList(
//           int.parse(data['uid'].toString()),
//           int.parse(data['id'].toString()),
//           data['desc']));
//     });
//   }
//
//   void sendActivityEvent(
//       String channelId, String? description) async {
//     if (int.tryParse(channelId) == null) {
//       return;
//     }
//    await presenceChannels["presence-typing-$channelId"]!.trigger(
//         'client-TypingEvent',
//         convert.jsonEncode({
//           "uid": _prefsRepository.myChatId.toString(),
//           "id": channelId.toString(),
//           "desc": description.toString()
//         }));
//   }
// }
