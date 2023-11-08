import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:pusher_client/pusher_client.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/service/language_service.dart';
import 'dart:convert' as convert;
import '../../../../main.dart';
import '../../../app/blocs/app_bloc/app_bloc.dart';
import '../../../app/blocs/app_bloc/app_event.dart';
import '../manager/chat_event.dart';

@LazySingleton()
class PusherChatService {
  Map<String, Channel> presenceChannels = {};
  Map<String, bool> publicChannels = {};
  late PusherClient pusher;
  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();
  ChatBloc chatBloc = GetIt.I<ChatBloc>();

  initialization() async {
    PusherOptions options = PusherOptions(
      // pongTimeout: ,
      // activityTimeout: ,
      // maxReconnectGapInSeconds: ,
      // maxReconnectionAttempts: ,
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

  subscribe(String channelName) async {
    //
    if(publicChannels.containsKey(channelName))return ;
    Channel channel = pusher.subscribe(channelName);
    channel.bind('ChannelReceivedEvent', (event) {
      //todo test comment
      // dealWithTimer();
      print(event?.data ?? 'ChannelReceivedEvent');
      Map<String, dynamic> data = convert.jsonDecode(event!.data.toString());
      chatBloc.add(ReceiveMessageFromPusherEvent(
          data['channel_id'].toString(), data['auth_user_id'], data['last_message_id']));
    });

    channel.bind('ChannelWatchedEvent', (event) {
      dealWithTimer();
      print(event?.data ?? 'ChannelWatchedEvent');
      Map<String, dynamic> data = convert.jsonDecode(event!.data.toString());
      chatBloc.add(WatchedMessageFromPusherEvent(
          data['channel_id'].toString(), data['auth_user_id'], data['last_message_id']));
    });
    publicChannels[channelName]=true;
  }
Map<String,String> descTranslation={
    "Typing...": "يكتب...",
    "Recording...": "يسجل مقطع صوتي...",
    "Sending file...": "يرسل ملف...",
};
  createPresenceChannel(String channelName) async {
    if(presenceChannels.containsKey(channelName)) return;
    Channel channel = pusher.subscribe("presence-typing-$channelName");
    presenceChannels["presence-typing-$channelName"] = channel;
    channel.bind('client-TypingEvent', (event) {
      dealWithTimer();
      Map<String, dynamic> data = convert.jsonDecode(event!.data.toString());
      if (data['desc']== 'null' || data['desc']==null) {
        print('yes it is');
        GetIt.I<AppBloc>().add(RemoveUserFromTypingList(int.parse(data['id'].toString())));
        return;
      }
      if(LanguageService.languageCode=='ar'){
        data['desc']=descTranslation[data['desc']] ?? data['desc'];
      }
      GetIt.I<AppBloc>().add(AddUserToTypingList(int.parse(data['uid'].toString()), int.parse(data['id'].toString()),data['desc']));
    });
  }

  void sendActivityEvent(String channelId ,String channelName, String? description) async {
    if(int.tryParse(channelId)==null){
      return;
    }
    var y = await presenceChannels["presence-typing-$channelName"]!.trigger(
        'client-TypingEvent',
        convert.jsonEncode({
          "uid": _prefsRepository.myChatId.toString(),
          "id": channelId.toString(),
          "desc": description.toString()
        }));
  }
}
