import 'package:easy_localization/easy_localization.dart' as local;
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/home/data/models/starting_settings_response_model.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/story/presentation/bloc/story_bloc.dart';
import 'package:trydos/service/notification_service/notification_service/handle_notification/handling_market_notifications.dart';
import 'package:trydos/service/service_provider.dart';
import 'package:trydos/trydos_application.dart';

class LanguageDropdown extends StatefulWidget {
  final List<Language> language;
  const LanguageDropdown({super.key, required this.language});
  @override
  _LanguageDropdownState createState() => _LanguageDropdownState();
}

class _LanguageDropdownState extends State<LanguageDropdown> {
  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();

  String? selectedlang;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: DropdownButtonHideUnderline(
        child: DropdownButton2(
          hint: Text('Language'),
          items: widget.language.map((lang) {
            return DropdownMenuItem<String>(
              value: lang.code,
              child: Text(lang.name ?? ""),
            );
          }).toList(),
          value: selectedlang,
          onChanged: (String? newValue) async {
            selectedlang = newValue;
            BlocProvider.of<HomeBloc>(context).add(ClearAllAppCashEvent());
            /*   List<String> topicTOUnSubsecribe =
                _prefsRepository.topicThatAlreadySubsecribed();
            topicTOUnSubsecribe.forEach(
              (element) {
                SubsecribeOrUnSubsecribeToTopic()
                    .UnSubsecribeToOtherTopic(element);
                print(
                    "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${element}");
              },
            );*/
            BlocProvider.of<HomeBloc>(context).add(
                ChangeCountryLanguageForNotificationEvent(
                    country: newValue!,
                    languageCode: _prefsRepository.countryIso!.toLowerCase()));
            Future.delayed(
              Duration(microseconds: 500),
              () {
                context.go("/");
              },
            );
            _prefsRepository.setLanguage(newValue);
            context.setLocale(HelperFunctions.getInitLocale());
            print(
                "############################################################################################################${HelperFunctions.getInitLocale()}");
          },
          // buttonHeight: 30,
          // buttonWidth: 95,
          // itemHeight: 30,
        ),
      ),
    );
  }
}
