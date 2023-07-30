import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:pusher_client/pusher_client.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'dart:convert' as convert;
import '../../../app/blocs/app_bloc/app_bloc.dart';
import '../../../app/blocs/app_bloc/app_event.dart';
import '../manager/chat_event.dart';

@LazySingleton()
class PusherChatService {
  Map<String, Channel> presenceChannels = {};
  late PusherClient pusher;
  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();
  ChatBloc chatBloc = GetIt.I<ChatBloc>();

  initialization() async {
    PusherOptions options = PusherOptions(
      encrypted: true,
      cluster: 'ap2',
      auth: PusherAuth(
        'http://chating_staging_trydos.trydos.tech/broadcasting/auth',
        headers: {
          'Authorization': 'Bearer ${_prefsRepository.token}',
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
    Channel channel = pusher.subscribe(channelName);
    channel.bind('ChannelReceivedEvent', (event) {
      print(event?.data ?? 'ChannelReceivedEvent');
      Map<String, dynamic> data = convert.jsonDecode(event!.data.toString());
      chatBloc.add(ReceiveMessageFromPusherEvent(
          data['channel_id'], data['auth_user_id'], data['last_message_id']));
    });

    channel.bind('ChannelWatchedEvent', (event) {
      print(event?.data ?? 'ChannelWatchedEvent');
      Map<String, dynamic> data = convert.jsonDecode(event!.data.toString());
      chatBloc.add(WatchedMessageFromPusherEvent(
          data['channel_id'], data['auth_user_id'], data['last_message_id']));
    });
  }

  createPresenceChannel(int channelId) async {
    Channel channel = pusher.subscribe("presence-typing-$channelId");
    presenceChannels["presence-typing-$channelId"] = channel;
    channel.bind('client-TypingEvent', (event) {
      print(event?.data ?? 'No Data');
      Map<String, dynamic> data = convert.jsonDecode(event!.data.toString());
      if (data['desc'] == null) {
        print('yes it is');
        GetIt.I<AppBloc>().add(RemoveUserFromTypingList(int.parse(data['id'].toString())));
        return;
      }
      GetIt.I<AppBloc>().add(AddUserToTypingList(int.parse(data['uid'].toString()), int.parse(data['id'].toString())));
    });
  }

  void sendTypingEvent(int channelId, String? description) async {
    print('send typing');
    var y = await presenceChannels["presence-typing-$channelId"]!.trigger(
        'client-TypingEvent',
        convert.jsonEncode({
          "uid": _prefsRepository.myId.toString(),
          "id": channelId.toString(),
          "desc": "$description"
        }));
  }
}
