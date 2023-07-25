   import 'package:pusher_client/pusher_client.dart';

class PusherChatService {
  late final PusherClient pusherClient;

  void initialization() async {
    PusherOptions options = PusherOptions(
      encrypted: false,
      cluster: 'ap2',
    );
    pusherClient = PusherClient(
        'cd403c68a9fbb7ce7da6',
        options,
        autoConnect: false
    );
  }
  void connectPusher(){
    try {
      pusherClient.connect();
      print('pusher connected');
      pusherClient.onConnectionStateChange((state) {
        print("previousState: ${state?.previousState}, currentState: ${state
            ?.currentState}");
      });

      pusherClient.onConnectionError((error) {
        print("error: ${error?.message}");
      });
    }catch(e) {
      print('pusher connection failed');
      print("ERROR: $e");
    }
  }

//
  void subscribe(String channelName) {
    Channel channel = pusherClient.subscribe(channelName);

    channel.bind("ChannelReceivedEvent", (PusherEvent? event) {
      print(event?.data);
    });
    channel.bind("ChannelWatchedEvent", (PusherEvent? event) {
      print(event?.data);
    });
  }

  void unSubscribe(String channelName) {
    pusherClient.unsubscribe(channelName);
  }

  void disconnectPusher() {
    pusherClient.disconnect();
  }

  void createPresenceChannel(String channelName) {
    Channel presenceChannel = pusherClient.subscribe("presence-$channelName");
    presenceChannel.bind("TypingEvent", (PusherEvent? event) {
      print(event?.data);
    });
  }
}