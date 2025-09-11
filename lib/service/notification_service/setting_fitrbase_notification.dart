import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/service/notification_service/drop_down_notification_frequency.dart';
import 'package:trydos/service/notification_service/notification_service/handle_notification/handling_market_notifications.dart';

class SwitchListForNotification extends StatefulWidget {
  const SwitchListForNotification({super.key});

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
    switchLabels.add("Firebase Notification");
    switchValues.add(homeBloc.state.firebaseSettingForNotificationModel?.data
            ?.firebaseSettings?.firebase ==
        "1");
    switchTopics.add("firebase_notification");
    switchLabels.add("Whatsapp Notification");
    switchValues.add(homeBloc.state.firebaseSettingForNotificationModel?.data
            ?.firebaseSettings?.whatsapp ==
        "1");
    switchTopics.add("whatsapp_notification");
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
        homeBloc.add(const UpdateEmailNotificationEvent(email: 1));
      } else if (switchTopics[index] == "whatsapp_notification") {
        homeBloc.add(const UpdateWhatsappNotificationEvent(whatsapp: 1));
      } else if (switchTopics[index] == "firebase_notification") {
        homeBloc.add(const UpdateFirebaseNotificationEvent(firebase: 1));
      } else {
        SubsecribeOrUnSubsecribeToTopic()
            .subsecribeToOtherTopic(switchTopics[index]);
      }
      ;
    } else {
      if (switchTopics[index] == "email_notification") {
        homeBloc.add(const UpdateEmailNotificationEvent(email: 0));
      } else if (switchTopics[index] == "whatsApp_notification") {
        homeBloc.add(const UpdateWhatsappNotificationEvent(whatsapp: 0));
      } else if (switchTopics[index] == "fireBase_notification") {
        homeBloc.add(const UpdateFirebaseNotificationEvent(firebase: 0));
      } else {
        SubsecribeOrUnSubsecribeToTopic()
            .unSubsecribeToOtherTopic(switchTopics[index]);
      }
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
        title: const Center(
            child: Text(
          ' Notification Setting                 ',
          style: TextStyle(
            fontSize: 18,
          ),
        )),
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        buildWhen: (previous, current) =>
            previous.updateEmailappNotificationStatus !=
                current.updateEmailappNotificationStatus ||
            current.updateWhatsappNotificationStatus !=
                previous.updateWhatsappNotificationStatus,
        builder: (context, state) {
          print(
              "sxxxxxxxxxxxxxxxxxxxx${state.updateEmailappNotificationStatus}xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxssssssssssssssssssssssssssssssssssssssss");

          if (state.updateWhatsappNotificationStatus ==
              UpdateWhatsappNotificationStatus.failure) {
            switchValues[1] = false;
          }
          if (state.updateEmailappNotificationStatus ==
              UpdateEmailappNotificationStatus.failure) {
            print("sssssssssssssssssssssssssssssssssssssssss");
            switchValues[2] = false;
          }
          return Container(
            height: 1.sh,
            width: 1.sw,
            color: Colors.grey[200],
            child: Column(
              children: [
                Container(
                    margin: const EdgeInsets.all(20),
                    height: 50.h,
                    width: 1.sw - 40,
                    child: Row(
                      children: [
                        const Text(
                          "Ntification Frequency :",
                          style: TextStyle(fontSize: 18),
                        ),
                        const Spacer(),
                        NotificationFrequencyDropdown(
                          notificationFrequency: const [
                            "daily",
                            "weekly",
                            "monthly"
                          ],
                          selectedNotificationFrequency: homeBloc
                                  .state
                                  .firebaseSettingForNotificationModel
                                  ?.data
                                  ?.firebaseSettings
                                  ?.notificationFrequency ??
                              "daily",
                        )
                      ],
                    )),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  height: 20,
                  child: const Row(
                    children: [
                      Text(
                        "Notification Type :",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(0),
                  height: 1.sh - 250,
                  child: ListView.builder(
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
