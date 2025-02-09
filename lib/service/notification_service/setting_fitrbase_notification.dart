import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/service/notification_service/notification_service/handle_notification/handling_market_notifications.dart';

class SwitchListForNotification extends StatefulWidget {
  @override
  _SwitchListForNotificationState createState() =>
      _SwitchListForNotificationState();
}

class _SwitchListForNotificationState extends State<SwitchListForNotification> {
  List<bool> switchValues = [];

  List<String> switchLabels = [];
  List<String> switchTopics = [];
  late HomeBloc homeBloc;
  @override
  void initState() {
    homeBloc = BlocProvider.of<HomeBloc>(context);
    switchLabels.add("FireBase Notification");
    switchValues.add(homeBloc.state.firebaseSettingForNotificationModel?.data
            ?.firebaseSettings?.firebase ==
        "1");
    switchTopics.add("fireBase_notification");
    switchLabels.add("WhatsApp Notification");
    switchValues.add(homeBloc.state.firebaseSettingForNotificationModel?.data
            ?.firebaseSettings?.whatsapp ==
        "1");
    switchTopics.add("whatsApp_notification");
    switchLabels.add("Email Notification");
    switchValues.add(homeBloc.state.firebaseSettingForNotificationModel?.data
            ?.firebaseSettings?.email ==
        "1");
    switchTopics.add("email_notification");
    homeBloc.state.firebaseSettingForNotificationModel?.data?.firebaseSettings
        ?.subscribedTopics
        ?.forEach(
      (element) {
        if (!switchLabels.contains(element.showedName)) {
          switchLabels.add(element.showedName ?? "");
          switchValues.add(true);
          switchTopics.add(element.topic ?? "");
        }
      },
    );
    homeBloc.state.firebaseSettingForNotificationModel?.data?.firebaseSettings
        ?.unsubscribedTopics
        ?.forEach(
      (element) {
        if (!switchLabels.contains(element.showedName)) {
          switchLabels.add(element.showedName ?? "");
          switchValues.add(false);
          switchTopics.add(element.topic ?? "");
        }
      },
    );

    super.initState();
  }

  void _onSwitchChanged(bool value, int index) {
    if (value) {
      if (switchTopics[index] == "email_notification") {
        homeBloc.add(UpdateEmailNotificationEvent(email: 1));
        return;
      }
      if (switchTopics[index] == "whatsApp_notification") {
        homeBloc.add(UpdateWhatsappNotificationEvent(whatsapp: 1));
        return;
      }
      if (switchTopics[index] == "fireBase_notification") {
        homeBloc.add(UpdateFirebaseNotificationEvent(firebase: 1));
        return;
      }
      SubsecribeOrUnSubsecribeToTopic()
          .SubsecribeToOtherTopic(switchTopics[index]);
    } else {
      if (switchTopics[index] == "email_notification") {
        homeBloc.add(UpdateEmailNotificationEvent(email: 0));
        return;
      }
      if (switchTopics[index] == "whatsApp_notification") {
        homeBloc.add(UpdateWhatsappNotificationEvent(whatsapp: 0));
        return;
      }
      if (switchTopics[index] == "fireBase_notification") {
        homeBloc.add(UpdateFirebaseNotificationEvent(firebase: 0));
        return;
      }
      SubsecribeOrUnSubsecribeToTopic()
          .UnSubsecribeToOtherTopic(switchTopics[index]);
    }
    setState(() {
      switchValues[index] = value;
    });
    // تنفيذ الدالة المطلوبة هنا
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          'Setting Notification                  ',
          style: TextStyle(
            fontSize: 18,
          ),
        )),
      ),
      body: ListView.builder(
        itemCount: switchLabels.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SwitchListTile(
              inactiveTrackColor: Colors.black,
              activeColor: Colors.green,
              title: Text(switchLabels[index]),
              value: switchValues[index],
              onChanged: (value) => _onSwitchChanged(value, index),
            ),
          );
        },
      ),
    );
  }
}
