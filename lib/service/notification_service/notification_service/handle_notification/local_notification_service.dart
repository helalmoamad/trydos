import 'dart:async';

import 'dart:io';
import 'dart:math';

import 'dart:ui' as ui;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/home/data/models/get_home_boutiqes_model.dart';
import 'package:trydos/main.dart';
import 'package:trydos/routes/router.dart';
import '../../../../base_page.dart';
import '../../../../core/di/di_container.dart';

import '../../../../features/chat/presentation/manager/chat_bloc.dart';
import '../../../../features/chat/presentation/manager/chat_event.dart';
import '../../../../features/chat/data/models/my_chats_response_model.dart'
    as chat;
import 'dart:convert' as convert;

import 'handling_market_notifications.dart';

@pragma('vm:entry-point')
class LocalNotificationService {
  static final _localNotificationPlugin = FlutterLocalNotificationsPlugin();
  final String _androidChannelId = r'$_$_1_$_$';
  final String _androidChannelName = "Notification";

  static FlutterLocalNotificationsPlugin get localNotificationPlugin =>
      _localNotificationPlugin;

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('app_icon');

    DarwinInitializationSettings iosInitializationSettings =
        const DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings settings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );
    await _localNotificationPlugin
        .getNotificationAppLaunchDetails()
        .then((value) {
      if ((value?.notificationResponse?.payload?.split(",,,").length ?? 0) >
          0) {
        GetIt.I<PrefsRepository>().setNotificationTypesOfMarketFromTerminated(
            value?.notificationResponse?.payload?.split(',,,')[0] ?? "");
      }
    });
    await _localNotificationPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
            LocalNotificationService().getAndroidChannel);

    await _localNotificationPlugin.initialize(
      settings,
      onDidReceiveBackgroundNotificationResponse: _onSelectNotification,
      onDidReceiveNotificationResponse: _onSelectNotification,
    );
  }

  @pragma('vm:entry-point')
  Future<void> showNotificationWithPayload(
      {required RemoteMessage message, required int fromBackGround}) async {
    final Random random = Random();
    final int notificationId = random.nextInt(1000000);
    if (HandlingMarketNotifications.checkIfTheNotificationIsNotRelatedToChat(
        message)) {
      String imageUrl = "";
      Map? data = convert.jsonDecode(message.data["body"] ?? "") ?? {};

      if (data?["type"] ==
              TypeOfNotificationForMarket[
                  TypeOfNotificationForMarketEnum.product_availability] ||
          data?["type"] ==
              TypeOfNotificationForMarket[
                  TypeOfNotificationForMarketEnum.product_comment] ||
          data?["type"] ==
              TypeOfNotificationForMarket[
                  TypeOfNotificationForMarketEnum.category_created] ||
          data?["type"] ==
              TypeOfNotificationForMarket[
                  TypeOfNotificationForMarketEnum.product_discount] ||
          data?["type"] ==
              TypeOfNotificationForMarket[
                  TypeOfNotificationForMarketEnum.product_cart_expiration]) {
        imageUrl = data?["image"] ?? "";
      }
      if (data?["type"] ==
          TypeOfNotificationForMarket[
              TypeOfNotificationForMarketEnum.boutique_created]) {
        List<BunnerBoutique>? boutiqueBannerList = List<BunnerBoutique>.from(
            data?["banner"]!.map((x) => BunnerBoutique.fromJson(x)));
        imageUrl = boutiqueBannerList[0].filePath ?? "";
      }

      Uint8List? pngImage;

      try {
        if (imageUrl != "" && imageUrl.split(".").length > 0) {
          final ByteData bytes = await NetworkAssetBundle(Uri.parse(imageUrl))
              .load("")
              .onError((error, stackTrace) => ByteData(0));

          final Uint8List buffer = bytes.buffer.asUint8List();
          final ui.Codec codec = await ui.instantiateImageCodec(buffer);
          final ui.FrameInfo fi = await codec.getNextFrame();
          final ui.Image image = fi.image;

          final ByteData? byteData =
              await image.toByteData(format: ui.ImageByteFormat.png);
          pngImage = byteData!.buffer.asUint8List();
        }
      } catch (e) {}
      String title = "${data?["type"]}";
      String body = "${data?["description"]}";
      print("##################################${notificationId}");
      await _localNotificationPlugin.show(
          notificationId, title, body, _notificationDetails(pngImage),
          payload: '${message.data["body"] ?? ""},,,${fromBackGround}');

      return;
    }
    Map RemoteMessage = convert.jsonDecode(message.data['data']);
    chat.Message myMessage = chat.Message.fromJson(RemoteMessage["message"]);
    String prevMessageId = RemoteMessage['prev_message_id'].toString();
    String type = myMessage.messageType!.name.toString();
    await _localNotificationPlugin.show(
        notificationId,
        myMessage.channel?.channelName ?? 'No Channel Name',
        type == 'TextMessage'
            ? myMessage.messageContent!.content.toString()
            : type == 'ImageMessage'
                ? 'Photo'
                : type == 'VoiceMessage'
                    ? 'Voice'
                    : type == 'VideoMessage'
                        ? 'Video'
                        : 'File',
        _notificationDetails(null),
        payload:
            '${convert.jsonEncode(RemoteMessage['message'])},,${prevMessageId}');
  }

  static void sendIReceivedTheMessage(String channelId) async {
    HttpOverrides.global = MyHttpOverrides();
    GetIt.I<ChatBloc>()
        .add(NotifyThatIReceivedMessageEvent(channelId: channelId));
  }

  @pragma('vm:entry-point')
  Future<void> uploadingNotification(
      maxProgress, progress, isUploading, bool isUploadingSuccess) async {
    if (isUploading) {
      final AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
              "uploading files", "Uploading Files Notifications",
              channelDescription: "show to user progress for uploading files",
              channelShowBadge: false,
              importance: Importance.max,
              priority: Priority.max,
              onlyAlertOnce: true,
              showProgress: true,
              maxProgress: maxProgress,
              progress: progress,
              autoCancel: false);

      NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      await _localNotificationPlugin.show(
        5,
        'Uploading story',
        '',
        platformChannelSpecifics,
      );
    } else {
      final IosNotificationDetails = DarwinNotificationDetails();
      _localNotificationPlugin.cancel(5);
      AndroidNotificationDetails androidPlatformChannelSpecifics =
          const AndroidNotificationDetails(
        "files",
        "Files Notifications",
        channelDescription: "Inform user files uploaded",
        channelShowBadge: false,
        importance: Importance.max,
        priority: Priority.high,
        onlyAlertOnce: true,
      );

      NotificationDetails platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: IosNotificationDetails);
      await _localNotificationPlugin.show(
        5,
        isUploadingSuccess ? 'upload story success' : 'upload story failed',
        '',
        platformChannelSpecifics,
      );
    }
  }

  @pragma('vm:entry-point')
  static void _onSelectNotification(NotificationResponse notificationResponse) {
    if (notificationResponse.payload!.split(",,,").length > 0) {
      HandlingMarketNotifications.dealWithNotificationFromMarket(
          convert.jsonDecode(notificationResponse.payload!.split(',,,')[0]),
          notificationResponse.payload!.split(',,,')[1] == "1");
      return;
    }
    chat.Message myMessage = chat.Message.fromJson(
        convert.jsonDecode(notificationResponse.payload!.split(',,')[0]));
    String prevMessageId = notificationResponse.payload!.split(',,')[1];

    handleOpenChatPageFromNotificationInBackground(prevMessageId,
        message: myMessage);
  }

  _notificationDetails(Uint8List? pngImage) {
    final channel = LocalNotificationService().getAndroidChannel;

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(channel.id, channel.name,
            channelDescription: channel.description,
            ticker: 'ticker',
            importance: Importance.high,
            priority: Priority.high,
            playSound: channel.playSound,
            enableVibration: channel.enableVibration,
            autoCancel: false,
            largeIcon:
                (pngImage == null) ? null : ByteArrayAndroidBitmap(pngImage),
            styleInformation: (pngImage == null)
                ? null
                : BigPictureStyleInformation(ByteArrayAndroidBitmap(pngImage)));
    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails();

    return NotificationDetails(
        android: androidNotificationDetails, iOS: iosNotificationDetails);
  }

  AndroidNotificationChannel get getAndroidChannel =>
      AndroidNotificationChannel(
        _androidChannelId,
        _androidChannelName, // title
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );
}
