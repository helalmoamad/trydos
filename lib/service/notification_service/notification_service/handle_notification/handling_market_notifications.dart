

import 'package:firebase_messaging/firebase_messaging.dart';

class HandlingMarketNotifications{
  // في هذا التابع نفحص أنواع الإشعارات المتعلقة بالمتجر فإذا كانت للمتجر نعيد true والا نعيد false
  static bool checkIfTheNotificationIsNotRelatedToChat(RemoteMessage message){
    print(message.data.toString());
    return true;
  }

  // هنا حسب نوع الاشعار نحدد إلى أي صفحة سننتقل او ماذا سنفعل
  static dealWithNotificationFromMarket(Map data){

  }

}