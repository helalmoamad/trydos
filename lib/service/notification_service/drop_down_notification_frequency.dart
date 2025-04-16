import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/service/notification_service/notification_service/handle_notification/handling_market_notifications.dart';

class NotificationFrequencyDropdown extends StatefulWidget {
  final List<String> notificationFrequency;
  String selectedNotificationFrequency;
  NotificationFrequencyDropdown(
      {super.key,
      required this.notificationFrequency,
      required this.selectedNotificationFrequency});
  @override
  _CountryDropdownState createState() => _CountryDropdownState();
}

class _CountryDropdownState extends State<NotificationFrequencyDropdown> {
  late HomeBloc homeBloc;
  @override
  void initState() {
    homeBloc = BlocProvider.of<HomeBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: DropdownButtonHideUnderline(
        child: DropdownButton2(
          hint: Text(
            widget.selectedNotificationFrequency,
            style: TextStyle(fontSize: 16),
          ),
          items: widget.notificationFrequency.map((e) {
            return DropdownMenuItem<String>(
              value: e,
              child: Text(e, style: TextStyle(fontSize: 16)),
            );
          }).toList(),
          value: widget.selectedNotificationFrequency,
          onChanged: (String? newValue) {
            widget.selectedNotificationFrequency = newValue ?? "";

            setState(() {});
            homeBloc.add(UpdateNotificationFrequencyEvent(
                notificationFrequency: newValue ?? ''));
          },
          // buttonHeight: 40,
          // buttonWidth: 1.sw / 2,
          // itemHeight: 40,
        ),
      ),
    );
  }
}
