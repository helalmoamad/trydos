import 'dart:async';

import 'dart:io';
import 'dart:math';

import 'dart:ui' as ui;

import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';

import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/home/data/models/get_home_boutiqes_model.dart';
import 'package:trydos/features/home/presentation/widgets/cart_section/payment_method.dart';

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
        const DarwinInitializationSettings();

    final InitializationSettings settings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );
    try {
      await _localNotificationPlugin
          .getNotificationAppLaunchDetails()
          .then((value) {
        if (value?.notificationResponse?.payload?.contains("###") ?? false) {
          GetIt.I<PrefsRepository>().setNotificationTypesFromTerminated(
              value?.notificationResponse?.payload?.split('###')[0] ?? "");
        } else if (value?.notificationResponse?.payload
                ?.contains("#prevMessageId#") ??
            false) {
          GetIt.I<PrefsRepository>().setNotificationTypesFromTerminated(((value
                      ?.notificationResponse?.payload
                      ?.split('#prevMessageId#')[0] ??
                  "") +
              ("chatNotification") +
              (value?.notificationResponse?.payload
                      ?.split('#prevMessageId#')[1] ??
                  "")));
        }
      });
    } catch (e) {}
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
              typeOfNotificationForMarket[
                  TypeOfNotificationForMarketEnum.product_cart_expiration] ||
          data?["type"] ==
              typeOfNotificationForMarket[
                  TypeOfNotificationForMarketEnum.product_hurry_up_quantity] ||
          data?["type"] ==
              typeOfNotificationForMarket[
                  TypeOfNotificationForMarketEnum.product_hurry_up_time_left]) {
        prefsRepository.setNotificationIdsToRemoveAfterplaceOrder(
            notificationId.toString());
      }

      if (data?["type"] ==
              typeOfNotificationForMarket[
                  TypeOfNotificationForMarketEnum.product_availability] ||
          data?["type"] ==
              typeOfNotificationForMarket[
                  TypeOfNotificationForMarketEnum.product_comment] ||
          data?["type"] ==
              typeOfNotificationForMarket[
                  TypeOfNotificationForMarketEnum.category_created] ||
          data?["type"] ==
              typeOfNotificationForMarket[
                  TypeOfNotificationForMarketEnum.product_discount] ||
          data?["type"] ==
              typeOfNotificationForMarket[
                  TypeOfNotificationForMarketEnum.product_cart_expiration] ||
          data?["type"] ==
              typeOfNotificationForMarket[
                  TypeOfNotificationForMarketEnum.remember_abandon_cart] ||
          data?["type"] ==
              typeOfNotificationForMarket[
                  TypeOfNotificationForMarketEnum.product_hurry_up_quantity] ||
          data?["type"] ==
              typeOfNotificationForMarket[
                  TypeOfNotificationForMarketEnum.product_hurry_up_time_left] ||
          data?["type"] ==
              typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                  .product_when_change_in_price] ||
          data?["type"] ==
              typeOfNotificationForMarket[
                  TypeOfNotificationForMarketEnum.seller_comment_added] ||
          data?["type"] ==
              typeOfNotificationForMarket[
                  TypeOfNotificationForMarketEnum.seller_product_stock_out] ||
          data?["type"] ==
              typeOfNotificationForMarket[
                  TypeOfNotificationForMarketEnum.product_before_stock_out]) {
        imageUrl = data?["image"] ?? "";
      }
      if (data?["type"] ==
          typeOfNotificationForMarket[
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
      String title = "${data?["showed_type"]}";
      String body = "${data?["description"]}";
      await _localNotificationPlugin.show(
          notificationId, title, body, _notificationDetails(pngImage, null),
          payload: '${message.data["body"] ?? ""}###${fromBackGround}');

      return;
    }
    Map RemoteMessage = convert.jsonDecode(message.data['data']);
    chat.Message myMessage = chat.Message.fromJson(RemoteMessage["message"]);
    String prevMessageId = (RemoteMessage['prev_message_id'] ?? "").toString();

    String orderId = (RemoteMessage['order_id'] ?? "").toString();
    String parentOrderId = RemoteMessage["parent_order_id"] == null ||
            RemoteMessage["parent_order_id"] == ""
        ? "-1"
        : RemoteMessage["parent_order_id"].toString();
    String orderGroupId = (RemoteMessage['order_group_id'] ?? "").toString();
    String type = myMessage.messageType!.name.toString();
    await _localNotificationPlugin.show(
        notificationId,
        (parentOrderId != "-1" || orderId != "")
            ? (GetIt.I<PrefsRepository>().language == "ar"
                ? "عامل التوصيل"
                : GetIt.I<PrefsRepository>().language == "en"
                    ? "Delivery Worker"
                    : GetIt.I<PrefsRepository>().language == "tr"
                        ? "Teslimat Çalışanı"
                        : GetIt.I<PrefsRepository>().language == "ku"
                            ? "کارمەندی گەیاندن"
                            : "Delivery Worker")
            : myMessage.channel?.channelName ?? 'No Channel Name',
        type == 'TextMessage'
            ? myMessage.messageContent!.content.toString()
            : type == 'ImageMessage'
                ? 'Photo'
                : type == 'VoiceMessage'
                    ? 'Voice'
                    : type == 'VideoMessage'
                        ? 'Video'
                        : 'File',
        _notificationDetails(null, myMessage.channel?.id),
        payload:
            '${convert.jsonEncode(RemoteMessage['message'])}#prevMessageId#${prevMessageId}#orderId#${orderId}#groupeOrderId#${orderGroupId}#parentOrderId#${parentOrderId}');
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
              progress: progress);

      NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      await _localNotificationPlugin.show(
        5,
        'Uploading story',
        '',
        platformChannelSpecifics,
      );
    } else {
      const IosNotificationDetails = DarwinNotificationDetails();
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
    if (notificationResponse.payload!.split("###").toList().length > 1) {
      HandlingMarketNotifications.dealWithNotificationFromMarket(
          convert.jsonDecode(notificationResponse.payload!.split('###')[0]),
          notificationResponse.payload!.split('###')[1] == "1");
      return;
    }
    chat.Message myMessage = chat.Message.fromJson(convert
        .jsonDecode(notificationResponse.payload!.split('#prevMessageId#')[0]));
    String info = notificationResponse.payload!.split('#prevMessageId#')[1];
    String prevMessageId = info.split('#orderId#')[0];
    String orderInfo = info.split('#orderId#')[1];
    String orderId = orderInfo.split('#groupeOrderId#')[0];
    String orderGroupIdWithReturnRequestId =
        orderInfo.split('#groupeOrderId#')[1];
    String orderGroupId =
        orderGroupIdWithReturnRequestId.split('#parentOrderId#')[0];
    String parentOrderId =
        orderGroupIdWithReturnRequestId.split('#parentOrderId#')[1];

    handleOpenChatPageFromNotificationInBackground(prevMessageId, orderId,
        orderGroupId, ((parentOrderId == "-1") ? null : parentOrderId),
        message: myMessage);
  }

  _notificationDetails(Uint8List? pngImage, String? tag) {
    final channel = LocalNotificationService().getAndroidChannel;

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(channel.id, channel.name,
            channelDescription: channel.description,
            ticker: 'ticker',
            importance: Importance.max,
            tag: tag,
            priority: Priority.max,
            playSound: channel.playSound,
            enableVibration: channel.enableVibration,
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
        importance: Importance.max,
      );
}
