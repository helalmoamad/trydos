// import 'dart:developer';
//
// import 'package:dartz/dartz_unsafe.dart';
// import 'package:dio/dio.dart';
// import 'package:get_it/get_it.dart';
// import 'package:injectable/injectable.dart';
// import 'package:trydos/core/domin/repositories/prefs_repository.dart';
// import 'package:trydos/features/calls/presentation/bloc/calls_bloc.dart';
// import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
// import 'package:trydos/service/language_service.dart';
// import 'dart:convert' as convert;
// import '../../../app/blocs/app_bloc/app_bloc.dart';
// import '../../../app/blocs/app_bloc/app_event.dart';
// import '../../data/models/my_chats_response_model.dart';
// import '../manager/chat_event.dart';
// import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
// @LazySingleton()
// class PusherChatService {
//    PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();
//   final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();
//   ChatBloc chatBloc = GetIt.I<ChatBloc>();
//   CallsBloc callBloc = GetIt.I<CallsBloc>();
//   Future initialization() async {
//     // try {
//     //   await pusher.init(
//     //     apiKey: 'a6740907447a19f198f9' , // 'cd403c68a9fbb7ce7da6',
//     //     cluster: 'us2' , // 'ap2',
//     //     onConnectionStateChange: onConnectionStateChange,
//     //     onError: onError,
//     //     pongTimeout: 120,
//     //     useTLS: true,
//     //     onSubscriptionSucceeded: onSubscriptionSucceeded,
//     //     onEvent: onEvent,
//     //     onSubscriptionError: onSubscriptionError,
//     //     onDecryptionFailure: onDecryptionFailure,
//     //     onMemberAdded: onMemberAdded,
//     //     onMemberRemoved: onMemberRemoved,
//     //     onSubscriptionCount: onSubscriptionCount,
//     //     //onAuthorizer: onAuthorizer,
//     //     authEndpoint: "http://chating_staging_trydos.trydos.tech/broadcasting/auth",
//     //   );
//     //   await pusher.connect();
//     // } catch (e) {
//     //   log("ERROR PUSHER CHANNELS: $e");
//     // }
//   }
//
//    void onConnectionStateChange(dynamic currentState, dynamic previousState) {
//      log("Connection: $currentState");
//    }
//
//    void onError(String message, int? code, dynamic e) {
//      log("onError: $message code: $code exception: $e");
//    }
//
//    void onEvent(PusherEvent event) {
//      log("onEvent: $event");
//    }
//
//    void onSubscriptionSucceeded(String channelName, dynamic data) {
//      log("onSubscriptionSucceeded: $channelName data: $data");
//      final me = pusher.getChannel(channelName)?.me;
//      log("Me: $me");
//    }
//
//    void onSubscriptionError(String message, dynamic e) {
//      log("onSubscriptionError: $message Exception: $e");
//    }
//
//    void onDecryptionFailure(String event, String reason) {
//      log("onDecryptionFailure: $event reason: $reason");
//    }
//
//    void onMemberAdded(String channelName, PusherMember member) {
//      log("onMemberAdded: $channelName user: $member");
//    }
//
//    void onMemberRemoved(String channelName, PusherMember member) {
//      log("onMemberRemoved: $channelName user: $member");
//    }
//
//    void onSubscriptionCount(String channelName, int subscriptionCount) {
//      log("onSubscriptionCount: $channelName subscriptionCount: $subscriptionCount");
//    }
//
//   //@pragma('vm:entry-point')
//   subscribe(String channelName) async {
//     // if (pusher.getChannel(channelName) != null ) return;
//     // try {
//     //   await pusher.subscribe(channelName: channelName, onEvent: (event) {
//     //     debugPrint('eventPusher $event');
//     //     // debugPrint('ChannelReceivedEventData ${event?.data ?? 'Empty'}');
//     //     Map<String, dynamic> data = convert.jsonDecode(event!.data.toString());
//     //     chatBloc.add(
//     //         ReceiveMessageFromPusherEvent(data['channel_id'].toString(),
//     //             data['auth_user_id'], data['last_message_id']));
//     //   },
//     //       onSubscriptionError: onSubscriptionError
//     //   );
//     // }catch(error){
//     //   debugPrint('ERRORRRRR $error');
//     // }
//     // channel.bind('ChannelWatchedEvent', (event) {
//     //   debugPrint('ChannelWatchedEventData ${event?.data ?? 'Empty'}');
//     //   Map<String, dynamic> data = convert.jsonDecode(event!.data.toString());
//     //   chatBloc.add(WatchedMessageFromPusherEvent(data['channel_id'].toString(),
//     //       data['auth_user_id'], data['last_message_id']));
//     // });
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
//   }
//
//   Map<String, String> descTranslation = {
//     "Typing...": "يكتب...",
//     "Recording...": "يسجل مقطع صوتي...",
//     "Sending file...": "يرسل ملف...",
//   };
//   deleteAllPresenceChannels(List<Chat> chats){
//     // for(int i=0; i< chats.length ; i++) {
//     //   if (pusher.getChannel("presence-typing-${chats[i].id}") != null)
//     //     continue;
//     //   pusher.unsubscribe(channelName: "presence-typing-${chats[i].id}");
//     // }
//   }
//   subscribeToAllPresenceChannels(List<Chat> chats){
//     // if((pusher.channels.length - 1) == chats.length)return;
//     // for(int i=0; i< chats.length ; i++) {
//     //   createPresenceChannel(chats[i].id.toString());
//     // }
//   }
//   createPresenceChannel(String channelName) async {
//    //  if (pusher.getChannel("presence-typing-$channelName") != null) return;
//    // await  pusher.subscribe(channelName: "presence-typing-$channelName" , onEvent: (event){
//    //    debugPrint('Presence Event $event');
//    //  });
//     // channel.bind('client-TypingEvent', (event) {
//     //   Map<String, dynamic> data = convert.jsonDecode(event!.data.toString());
//     //   if (data['desc'] == 'null' || data['desc'] == null) {
//     //     debugPrint('yes it is');
//     //     GetIt.I<AppBloc>()
//     //         .add(RemoveUserFromTypingList(int.parse(data['id'].toString())));
//     //     return;
//     //   }
//     //   if (LanguageService.languageCode == 'ar') {
//     //     data['desc'] = descTranslation[data['desc']] ?? data['desc'];
//     //   }
//     //   GetIt.I<AppBloc>().add(AddUserToTypingList(
//     //       int.parse(data['uid'].toString()),
//     //       int.parse(data['id'].toString()),
//     //       data['desc']));
//     // });
//   }
//
//   void sendActivityEvent(
//       String channelId, String? description) async {
//     // if (int.tryParse(channelId) == null) {
//     //   return;
//     // }
//     // debugPrint('presenceChannels["presence-typing-$channelId"] ${pusher.getChannel("presence-typing-$channelId")}');
//     // pusher.trigger(
//     //   PusherEvent(channelName: "presence-typing-$channelId", eventName: 'client-TypingEvent',data: convert.jsonEncode({
//     //     "uid": _prefsRepository.myChatId.toString(),
//     //     "id": channelId.toString(),
//     //     "desc": description.toString()
//     //   })));
//   }
// }
