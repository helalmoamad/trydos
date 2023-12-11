import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:pusher_client/pusher_client.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/calls/presentation/bloc/calls_bloc.dart';
import 'package:trydos/features/calls/presentation/pages/answer_call.dart';
import 'package:trydos/features/calls/presentation/pages/room_call_page.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/service/language_service.dart';
import 'dart:convert' as convert;
import '../../../../main.dart';
import '../../../../routes/router.dart';
import '../../../app/blocs/app_bloc/app_bloc.dart';
import '../../../app/blocs/app_bloc/app_event.dart';
import '../../data/models/my_chats_response_model.dart';
import '../manager/chat_event.dart';

@LazySingleton()
class PusherChatService {
  Map<String, Channel> presenceChannels = {};
  Map<String, bool> publicChannels = {};
  late PusherClient pusher;
  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();
  ChatBloc chatBloc = GetIt.I<ChatBloc>();
  CallsBloc callBloc = GetIt.I<CallsBloc>();

  Future initialization() async {
    PusherOptions options = PusherOptions(
      encrypted: true,
      cluster: 'ap2',
      auth: PusherAuth(
        'http://chating_staging_trydos.trydos.tech/broadcasting/auth',
        headers: {
          'Authorization': 'Bearer ${_prefsRepository.chatToken}',
        },
      ),
    );
    pusher = PusherClient("cd403c68a9fbb7ce7da6", options,
        autoConnect: false, enableLogging: false);
    await pusher.connect();
    pusher.onConnectionStateChange((state) {
      print(state?.currentState ?? 'null state');
    });
    pusher.onConnectionError((state) {
      print(state?.message ?? 'null message');
      print(state?.code ?? 'null code');
      print(state?.exception ?? 'null exception');
    });
  }

  @pragma('vm:entry-point')
  subscribe(String channelName) async {
    if (publicChannels.containsKey(channelName)) return;
    Channel channel = pusher.subscribe(channelName);
    channel.bind('ChannelReceivedEvent', (event) {
      // print('ChannelReceivedEventData ${event?.data ?? 'Empty'}');
      Map<String, dynamic> data = convert.jsonDecode(event!.data.toString());
      chatBloc.add(ReceiveMessageFromPusherEvent(data['channel_id'].toString(),
          data['auth_user_id'], data['last_message_id']));
    });

    channel.bind('ChannelWatchedEvent', (event) {
      print('ChannelWatchedEventData ${event?.data ?? 'Empty'}');
      Map<String, dynamic> data = convert.jsonDecode(event!.data.toString());
      chatBloc.add(WatchedMessageFromPusherEvent(data['channel_id'].toString(),
          data['auth_user_id'], data['last_message_id']));
    });

    //todo later....
    channel.bind('VideoCallEvent', (event) {
      debugPrint("asdadasbcnghn${event!.data!.toString()}");
      Map<String, dynamic> data = convert.jsonDecode(event!.data.toString());
      debugPrint(
          'VideoCallEvent ${data['channel_id'].toString() ?? 'EmptyVideoCallEvent'}');
      debugPrint(' ${data ?? 'EmptyVideoCallEvent'}');

      Chat currentChat = chatBloc.state.chats
          .firstWhere((element) => element.id == data['channel_id'].toString());

      debugPrint("myChatId${GetIt.I<PrefsRepository>().myChatId}");
      for (var i = 0; i < currentChat.channelMembers!.length; i++) {
        debugPrint("channel${currentChat.channelMembers![i].user!.id}");
        debugPrint("channel${currentChat.channelMembers![i].user!.name}");
      }

      debugPrint("chatVideoEvent${currentChat.id}");

      ChannelMember currentCaller = chatBloc.state.chats
          .firstWhere((element) => element.id == data['channel_id'].toString())
          .channelMembers!
          .firstWhere((element) =>
              element.user!.id != GetIt.I<PrefsRepository>().myChatId);
      debugPrint('currentCaller${currentCaller.user!.name!}');
      debugPrint(
          'currentCallercontactUser${currentCaller.user!.contactUser == null ? 'nullContact' : currentCaller.user!.contactUser!.name!}');
      debugPrint('currentCallerphotoPath${currentCaller.user!.photoPath}');

      String callerName = currentCaller.user!.contactUser == null
          ? currentCaller.user!.name!
          : currentCaller.user!.contactUser!.name!;

      Navigator.of(navigatorKey.currentState!.context).push(MaterialPageRoute(
        builder: (context) => AnswerCall(
          channelName: data['channel_id'].toString(),
          callerName: callerName,
          callerPhoto: currentCaller.user!.photoPath,
        ),
      ));
    });

    channel.bind('AnswerCallEvent', (event) {
      Navigator.of(navigatorKey.currentState!.context).push(MaterialPageRoute(
        builder: (context) => RoomCallPage(),
      ));
    });

    publicChannels[channelName] = true;
  }

  Map<String, String> descTranslation = {
    "Typing...": "يكتب...",
    "Recording...": "يسجل مقطع صوتي...",
    "Sending file...": "يرسل ملف...",
  };

  createPresenceChannel(String channelName) async {
    if (presenceChannels.containsKey(channelName)) return;
    Channel channel = pusher.subscribe("presence-typing-$channelName");
    presenceChannels["presence-typing-$channelName"] = channel;
    channel.bind('client-TypingEvent', (event) {
      Map<String, dynamic> data = convert.jsonDecode(event!.data.toString());
      if (data['desc'] == 'null' || data['desc'] == null) {
        print('yes it is');
        GetIt.I<AppBloc>()
            .add(RemoveUserFromTypingList(int.parse(data['id'].toString())));
        return;
      }
      if (LanguageService.languageCode == 'ar') {
        data['desc'] = descTranslation[data['desc']] ?? data['desc'];
      }
      GetIt.I<AppBloc>().add(AddUserToTypingList(
          int.parse(data['uid'].toString()),
          int.parse(data['id'].toString()),
          data['desc']));
    });
  }

  void sendActivityEvent(
      String channelId, String channelName, String? description) async {
    if (int.tryParse(channelId) == null) {
      return;
    }
    var y = await presenceChannels["presence-typing-$channelId"]!.trigger(
        'client-TypingEvent',
        convert.jsonEncode({
          "uid": _prefsRepository.myChatId.toString(),
          "id": channelId.toString(),
          "desc": description.toString()
        }));
  }
}
