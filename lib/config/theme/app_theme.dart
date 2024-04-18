import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trydos/config/theme/typography.dart';

part 'light_color_scheme.dart';



const defaultAppTheme = ThemeMode.light;


class AppTheme {
  static ThemeData get _builtInLightTheme => ThemeData.light();

  static ThemeData get light {
    final textTheme = appTextTheme(
        _builtInLightTheme.textTheme, _lightColorScheme.onBackground);

    return _builtInLightTheme.copyWith(
        colorScheme: _lightColorScheme,
        textTheme: textTheme,
        useMaterial3: true,
        typography: Typography.material2018(),
        scaffoldBackgroundColor: _lightColorScheme.background,
        primaryColor: _lightColorScheme.primary,
    );
  }

}
