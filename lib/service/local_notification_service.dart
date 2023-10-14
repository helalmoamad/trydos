import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  //todo initialize the notification
  Future<void> initNotification() async {
    AndroidInitializationSettings initializationSettingsAndroid =
    const AndroidInitializationSettings('flutter_logo');
    var initializationSettingIos = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {},
    );
    var initializeSettings = InitializationSettings(
        iOS: initializationSettingIos, android: initializationSettingsAndroid);

    notificationsPlugin.initialize(initializeSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {});
  }

  NotificationDetails? notificationDetails() {
    return const NotificationDetails(
        iOS: DarwinNotificationDetails(),
        android: AndroidNotificationDetails('channelId', 'channelName',
            importance: Importance.max));
  }

  Future showNotification(
      {int id = 0, String? title, String? body, String? payload}) async {
    return notificationsPlugin.show(
        id, title, body, await notificationDetails());
  }
}
