import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/home/data/models/get_allowed_country_model.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';

class CountryDropdown extends StatefulWidget {
  final List<Country> countries;

  const CountryDropdown({super.key, required this.countries});
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
            setState(() {
              selectedCountry = newValue;
              _prefsRepository.setUserChoosedCountryIso(newValue);
            });
            homeBloc.add(GetHomeBoutiqesEvent(
                categorySlug: "Empty", offset: "1", getWithPagination: false));
            homeBloc.add(GetMainCategoriesEvent());
          },
          // buttonHeight: 40,
          // buttonWidth: 1.sw / 2,
          // itemHeight: 40,
        ),
      ),
    );
  }
}
