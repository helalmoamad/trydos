import 'package:flutter/foundation.dart' hide Category;
import 'dart:async';
import 'dart:developer' as dev;

import 'dart:math';

import 'dart:ui' as ui;

import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';

import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/home/data/models/get_home_boutiqes_model.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/orderBloc/order_bloc.dart';
import 'package:trydos/features/home/presentation/manager/orderBloc/order_event.dart'
    show GetOrdersByOrderGroupIDEvent;
import 'package:trydos/features/home/presentation/widgets/cart_section/payment_method.dart';

import '../../../../base_page.dart';

import '../../../../features/chat/presentation/manager/chat_bloc.dart';
import '../../../../features/chat/presentation/manager/chat_event.dart';
import '../../../../features/chat/data/models/my_chats_response_model.dart'
    as chat;
import 'dart:convert' as convert;

import 'handling_market_notifications.dart';

@pragma('vm:entry-point')
class LocalNotificationService {
  static final _localNotificationPlugin = FlutterLocalNotificationsPlugin();
  final String _androidChannelId = 'trydos_notifications';
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
    await _localNotificationPlugin.initialize(
      settings,
      onDidReceiveBackgroundNotificationResponse: _onSelectNotification,
      onDidReceiveNotificationResponse: _onSelectNotification,
    );

    try {
      final value = await _localNotificationPlugin
          .getNotificationAppLaunchDetails();
      if (value != null) {
        if (kDebugMode) print("chatNotification//////////////////////////**-----1");
        dev.log(
          "chatNotification//////////////////////////${value.notificationResponse?.payload ?? ""}",
        );
        if (value.notificationResponse?.payload?.contains("###") ?? false) {
          if (kDebugMode) print("chatNotification//////////////////////////**-----2");
          await GetIt.I<PrefsRepository>().setNotificationTypesFromTerminated(
            value.notificationResponse?.payload?.split('###')[0] ?? "",
          );
        } else if (value.notificationResponse?.payload?.contains(
              "#prevMessageId#",
            ) ??
            false) {
          if (kDebugMode) print("chatNotification//////////////////////////**-----3");
          final payload = value.notificationResponse!.payload!;
          final parts = payload.split('#prevMessageId#');
          final resultValue =
              (parts.isNotEmpty ? parts[0] : "") +
              "chatNotification" +
              (parts.length > 1 ? parts[1] : "");

          await GetIt.I<PrefsRepository>().setNotificationTypesFromTerminated(
            resultValue,
          );
          final storedVal = await GetIt.I<PrefsRepository>()
              .getNotificationTypeFromTerminated();
          if (kDebugMode) print(
            "chatNotification//////////////////////////**-----3$resultValue",
          );
          if (kDebugMode) print(
            "chatNotification//////////////////////////**-----3--$storedVal",
          );
        }
      }
    } catch (e, st) {
      if (kDebugMode) print("chatNotification Error in LocalNotificationService: $e");
      if (kDebugMode) print(st);
      dev.log("chatNotification Error: $e");
    }
    await _localNotificationPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          LocalNotificationService().getAndroidChannel,
        );
  }

  /// Returns a stable notification ID for a channel so that notifications from
  /// the same chat/channel update one notification (like WhatsApp) instead of
  /// creating a new one per message.
  static int _notificationIdForChannel(String? channelId) {
    if (channelId == null || channelId.isEmpty) {
      return Random().nextInt(1000000);
    }
    return channelId.hashCode.abs() % 1000000;
  }

  /// Max lines shown when notification is expanded (Android InboxStyle supports 5).
  static const int _maxChatNotificationLines = 5;
  static final Map<String, List<String>> _channelMessageLines = {};

  /// Appends a message line for the channel and returns the list (oldest first) for InboxStyle.
  static List<String> _appendMessageLineForChannel(
    String? channelId,
    String line,
  ) {
    if (channelId == null || channelId.isEmpty) return [line];
    final list = _channelMessageLines.putIfAbsent(channelId, () => <String>[]);
    list.add(line);
    while (list.length > _maxChatNotificationLines) list.removeAt(0);
    return List<String>.from(list);
  }

  @pragma('vm:entry-point')
  Future<void> showNotificationWithPayload({
    required RemoteMessage message,
    required int fromBackGround,
  }) async {
    if (HandlingMarketNotifications.checkIfTheNotificationIsNotRelatedToChat(
      message,
    )) {
      final int notificationId = Random().nextInt(1000000);
      Map? data = convert.jsonDecode(message.data["body"] ?? "") ?? {};
      if (kDebugMode) print(
        "DDDDDDDDDDDDDDDDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFQQQQQQQQQQQQQQQQQQQQQQQQ${data?["type"]}",
      );
      if (data?["type"] ==
          typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
              .order_status_changed]) {
        GetIt.I<OrderBloc>().add(
          GetOrdersByOrderGroupIDEvent(
            fromNotification: true,
            status: GetIt.I<OrderBloc>().state.currentOrederStatus ?? "",
            orderGroupId: data?["order_group_id"].toString() ?? "",
          ),
        );
        return;
      }
      if (data?["type"] ==
          typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
              .greeting]) {
        if ((GetIt.I<PrefsRepository>().fcmMarketTokenId ?? "") == "") {
          return;
        }
        GetIt.I<HomeBloc>().add(
          SendAcceptOfNotificationMarketEvent(
            firebaseTokenId: GetIt.I<PrefsRepository>().fcmMarketTokenId ?? "",
          ),
        );
        return;
      }
      String imageUrl = "";

      if (data?["type"] ==
              typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                  .product_cart_expiration] ||
          data?["type"] ==
              typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                  .product_hurry_up_quantity] ||
          data?["type"] ==
              typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                  .product_hurry_up_time_left]) {
        prefsRepository.setNotificationIdsToRemoveAfterplaceOrder(
          notificationId.toString(),
        );
      }

      if (data?["type"] ==
              typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                  .product_availability] ||
          data?["type"] ==
              typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                  .product_comment] ||
          data?["type"] ==
              typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                  .category_created] ||
          data?["type"] ==
              typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                  .product_discount] ||
          data?["type"] ==
              typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                  .product_cart_expiration] ||
          data?["type"] ==
              typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                  .remember_abandon_cart] ||
          data?["type"] ==
              typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                  .product_hurry_up_quantity] ||
          data?["type"] ==
              typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                  .product_hurry_up_time_left] ||
          data?["type"] ==
              typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                  .product_when_change_in_price] ||
          data?["type"] ==
              typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                  .seller_comment_added] ||
          data?["type"] ==
              typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                  .seller_product_stock_out] ||
          data?["type"] ==
              typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
                  .product_before_stock_out]) {
        imageUrl = data?["image"] ?? "";
      }
      if (data?["type"] ==
          typeOfNotificationForMarket[TypeOfNotificationForMarketEnum
              .boutique_created]) {
        List<BunnerBoutique>? boutiqueBannerList = List<BunnerBoutique>.from(
          data?["banner"]!.map((x) => BunnerBoutique.fromJson(x)),
        );
        imageUrl = boutiqueBannerList[0].filePath ?? "";
      }

      Uint8List? pngImage;

      try {
        if (imageUrl != "" && imageUrl.split(".").length > 0) {
          final ByteData bytes = await NetworkAssetBundle(
            Uri.parse(imageUrl),
          ).load("").onError((error, stackTrace) => ByteData(0));

          final Uint8List buffer = bytes.buffer.asUint8List();
          final ui.Codec codec = await ui.instantiateImageCodec(buffer);
          final ui.FrameInfo fi = await codec.getNextFrame();
          final ui.Image image = fi.image;

          final ByteData? byteData = await image.toByteData(
            format: ui.ImageByteFormat.png,
          );
          pngImage = byteData!.buffer.asUint8List();
        }
      } catch (e) {}
      String title = "${data?["showed_type"]}";
      String body = "${data?["description"]}";
      await _localNotificationPlugin.show(
        notificationId,
        title,
        body,
        _notificationDetails(pngImage, null, body),
        payload: '${message.data["body"] ?? ""}###${fromBackGround}',
      );

      return;
    }
    Map RemoteMessage = convert.jsonDecode(message.data['data']);
    dev.log("GGGGGGGGGGGGGGGGGF ${convert.jsonEncode(RemoteMessage)} llll");
    chat.Message myMessage = chat.Message.fromJson(RemoteMessage["message"]);
    String prevMessageId = (RemoteMessage['prev_message_id'] ?? "").toString();

    String orderId = (RemoteMessage['order_id'] ?? "").toString();
    String parentOrderId =
        RemoteMessage["parent_order_id"] == null ||
            RemoteMessage["parent_order_id"] == ""
        ? "-1"
        : RemoteMessage["parent_order_id"].toString();
    String orderGroupId = (RemoteMessage['order_group_id'] ?? "").toString();

    String? type = myMessage.messageType?.name?.toString();
    String notificationTitle = (parentOrderId != "-1" || orderId != "")
        ? (GetIt.I<PrefsRepository>().language == "ar"
              ? "عامل التوصيل"
              : GetIt.I<PrefsRepository>().language == "en"
              ? "Delivery Worker"
              : GetIt.I<PrefsRepository>().language == "tr"
              ? "Teslimat Çalışanı"
              : GetIt.I<PrefsRepository>().language == "ku"
              ? "کارمەندی گەیاندن"
              : "Delivery Worker")
        : myMessage.senderUser?.name ?? 'Trydos User';

    String notificationBody = "";
    if (type == 'TextMessage') {
      notificationBody = myMessage.messageContent?.content?.toString() ?? "";
    } else if (type == 'ImageMessage') {
      notificationBody = 'Photo 📷';
    } else if (type == 'VoiceMessage') {
      notificationBody = 'Voice message 🎤';
    } else if (type == 'VideoMessage') {
      notificationBody = 'Video 🎥';
    } else {
      notificationBody = 'New message';
    }

    // Build one line for this message (e.g. "Sender: body") and accumulate for InboxStyle.
    final String senderLabel = myMessage.senderUser?.name ?? 'Trydos User';
    final String oneLine = '$senderLabel: $notificationBody';
    final List<String> inboxLines = _appendMessageLineForChannel(
      myMessage.channel?.id,
      oneLine,
    );

    // Use stable notification ID per channel so messages from same chat
    // update one notification (like WhatsApp) instead of creating many.
    final int chatNotificationId = _notificationIdForChannel(
      myMessage.channel?.id,
    );

    await _localNotificationPlugin.show(
      chatNotificationId,
      notificationTitle,
      notificationBody,
      _notificationDetails(
        null,
        myMessage.channel?.id,
        notificationBody,
        inboxLines: inboxLines,
        inboxContentTitle: notificationTitle,
        // النافذة المنبثقة تختفي تلقائياً ويبقى الإشعار في البردايه
      ),
      payload:
          '${convert.jsonEncode(RemoteMessage['message'])}#prevMessageId#${prevMessageId}#orderId#${orderId}#groupeOrderId#${orderGroupId}#parentOrderId#${parentOrderId}',
    );
  }

  static void sendIReceivedTheMessage(String channelId) async {
    GetIt.I<ChatBloc>().add(
      NotifyThatIReceivedMessageEvent(channelId: channelId),
    );
  }

  @pragma('vm:entry-point')
  Future<void> uploadingNotification(
    maxProgress,
    progress,
    isUploading,
    bool isUploadingSuccess,
  ) async {
    if (isUploading) {
      final AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            "uploading files",
            "Uploading Files Notifications",
            channelDescription: "show to user progress for uploading files",
            channelShowBadge: false,
            importance: Importance.max,
            priority: Priority.max,
            onlyAlertOnce: true,
            showProgress: true,
            maxProgress: maxProgress,
            progress: progress,
          );

      NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );
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
        iOS: IosNotificationDetails,
      );
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
        notificationResponse.payload!.split('###')[1] == "1",
      );
      return;
    }
    chat.Message myMessage = chat.Message.fromJson(
      convert.jsonDecode(
        notificationResponse.payload!.split('#prevMessageId#')[0],
      ),
    );
    String info = notificationResponse.payload!.split('#prevMessageId#')[1];
    String prevMessageId = info.split('#orderId#')[0];
    String orderInfo = info.split('#orderId#')[1];
    String orderId = orderInfo.split('#groupeOrderId#')[0];
    String orderGroupIdWithReturnRequestId = orderInfo.split(
      '#groupeOrderId#',
    )[1];
    String orderGroupId = orderGroupIdWithReturnRequestId.split(
      '#parentOrderId#',
    )[0];
    String parentOrderId = orderGroupIdWithReturnRequestId.split(
      '#parentOrderId#',
    )[1];

    handleOpenChatPageFromNotificationInBackground(
      prevMessageId,
      orderId,
      orderGroupId,
      ((parentOrderId == "-1") ? null : parentOrderId),
      message: myMessage,
    );
  }

  _notificationDetails(
    Uint8List? pngImage,
    String? tag,
    String body, {
    List<String>? inboxLines,
    String? inboxContentTitle,

    /// إشعارات الدردشة: false حتى تختفي النافذة المنبثقة تلقائياً ويبقى الإشعار في البردايه فقط.
  }) {
    final channel = LocalNotificationService().getAndroidChannel;

    StyleInformation styleInfo;
    if (pngImage != null) {
      styleInfo = BigPictureStyleInformation(ByteArrayAndroidBitmap(pngImage));
    } else if (inboxLines != null && inboxLines.isNotEmpty) {
      // When expanded, show previous messages like WhatsApp (Android InboxStyle).
      styleInfo = InboxStyleInformation(
        inboxLines,
        contentTitle: inboxContentTitle,
      );
    } else {
      styleInfo = BigTextStyleInformation(body);
    }

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          ticker: body,
          importance: Importance.max,
          tag: tag,
          priority: Priority.max,
          category: AndroidNotificationCategory.message,
          visibility: NotificationVisibility.public,
          playSound: channel.playSound,

          enableVibration: channel.enableVibration,
          largeIcon: (pngImage == null)
              ? null
              : ByteArrayAndroidBitmap(pngImage),
          styleInformation: styleInfo,
        );
    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails();

    return NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );
  }

  AndroidNotificationChannel get getAndroidChannel =>
      AndroidNotificationChannel(
        _androidChannelId,
        _androidChannelName, // title
        importance: Importance.max,
      );
}
