import 'package:easy_localization/easy_localization.dart' as local;
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/home/data/models/starting_settings_response_model.dart';
import 'package:trydos/service/service_provider.dart';
import 'package:trydos/trydos_application.dart';

class LanguageDropdown extends StatefulWidget {
  const LanguageDropdown({super.key});
  @override
  _LanguageDropdownState createState() => _LanguageDropdownState();
}

class _LanguageDropdownState extends State<LanguageDropdown> {
  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();

  String? selectedlang;
  List<String> language = ["Arabic", "English"];
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
          items: language.map((lang) {
            return DropdownMenuItem<String>(
              value: lang,
              child: Text(lang),
            );
          }).toList(),
          value: selectedlang,
          onChanged: (String? newValue) {
            selectedlang = newValue;
            _prefsRepository.setLanguage(newValue);
            context.setLocale(HelperFunctions.getInitLocale());
          },
          // buttonHeight: 30,
          // buttonWidth: 95,
          // itemHeight: 30,
        ),
      ),
    );
  }
}
