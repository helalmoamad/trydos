import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/home/data/models/get_allowed_country_model.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import 'package:trydos/service/notification_service/notification_service/handle_notification/handling_market_notifications.dart';

import '../../service/firebase_analytics_service/firebase_analytics_service.dart';

class CountryDropdown extends StatefulWidget {
  final List<Country> countries;
  final bool fromHomepage;
  const CountryDropdown(
      {super.key, required this.countries, required this.fromHomepage});
  @override
  _CountryDropdownState createState() => _CountryDropdownState();
}

class _CountryDropdownState extends State<CountryDropdown> {
  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();
  String? selectedCountry;
  late HomeBloc homeBloc;
  @override
  void initState() {
    homeBloc = BlocProvider.of<HomeBloc>(context);
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    FirebaseAnalyticsService.logScreen(
      screen: AnalyticsScreensConst.chooseCountryScreen,
    );

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: DropdownButtonHideUnderline(
        child: DropdownButton2(
          hint: Text('Country'),
          items: widget.countries.map((country) {
            return DropdownMenuItem<String>(
              value: country.iso,
              child: Text(country.nicename!),
            );
          }).toList(),
          value: selectedCountry,
          onChanged: (String? newValue) {
            selectedCountry = newValue;
            _prefsRepository.setUserChoosedCountryIso(newValue);
            if (widget.fromHomepage) {
              _prefsRepository.setUserCountryIsAvailable(1);
              print(
                  "@@@@@@@@@!!!!!!!!!!!!!!!!!!!!!!!!!!${newValue}!!!!!!111111111111111");
              BlocProvider.of<HomeBloc>(context).add(ClearAllAppCashEvent());
              List<String> topicTOUnSubsecribe =
                  _prefsRepository.topicThatAlreadySubsecribed();
              topicTOUnSubsecribe.forEach(
                (element) {
                  SubsecribeOrUnSubsecribeToTopic()
                      .UnSubsecribeToOtherTopic(element);
                  print(
                      "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${element}");
                },
              );
              Future.delayed(
                Duration(microseconds: 500),
                () {
                  context.go("/");
                },
              );
            } else {
              setState(() {});
            }
          },
          // buttonHeight: 40,
          // buttonWidth: 1.sw / 2,
          // itemHeight: 40,
        ),
      ),
    );
  }
}
