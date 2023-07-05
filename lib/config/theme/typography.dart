import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

part 'font.dart';

TextTheme appTextTheme(TextTheme base, Color textColor) => base
    .copyWith(
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: _FontSize.huge, ///77
        fontWeight: _semiBold,
        letterSpacing:0.14,
      ),
      headline1: base.headline1?.copyWith(
        fontSize: _FontSize.heading_01, /// 46
        fontWeight: _light,
        letterSpacing:0.14,
        fontFamily: _sFDisplayLightFamily,
      ),
      headline2: base.headline2?.copyWith(
        fontSize: _FontSize.heading_02, /// 36
        fontWeight: _light,
        letterSpacing:0.14,
        fontFamily: _sFDisplayLightFamily,
      ),
      headline3: base.headline3?.copyWith(
        fontSize: _FontSize.heading_03, /// 26
        fontWeight: _bold,
        letterSpacing:0.14,

        fontFamily: _sFDisplayLightFamily,

      ),
      headline4: base.headline4?.copyWith(
        fontSize: _FontSize.heading_04, /// 24
        fontWeight: _regular,
        letterSpacing:0.14,
        fontFamily: _sFDisplayLightFamily,

      ),
      headline5: base.headline5?.copyWith(
        fontSize: _FontSize.heading_05, /// 20
        fontWeight: _bold,
        letterSpacing:0.14,
        fontFamily: _sFDisplayLightFamily,
      ),

      headline6: base.headline6?.copyWith(
        fontSize: _FontSize.heading_06, /// 22
        fontWeight: _medium,
        letterSpacing:0.14,
        fontFamily: _sFDisplayLightFamily,
      ),
      subtitle1: base.subtitle1?.copyWith(
        fontSize: _FontSize.subtitle_01, /// 18
        fontWeight: _bold,
        letterSpacing:0.14,
        fontFamily: _sFDisplayLightFamily,
      ),
      subtitle2: base.subtitle2?.copyWith(
        fontSize: _FontSize.subtitle_02,  /// 16
        fontWeight: _bold,
        letterSpacing:0.14,
        fontFamily: _sFDisplayLightFamily,
      ),
      bodyText1: base.bodyText1?.copyWith(
        fontSize: _FontSize.body_01,  /// 16
        fontWeight: _regular,
        letterSpacing:0.14,
        fontFamily: _sFDisplayLightFamily,
      ),
      bodyText2: base.bodyText2?.copyWith(
        fontSize: _FontSize.body_02,  /// 14
        fontWeight: _regular,
        letterSpacing:0.14,
        fontFamily: _sFDisplayLightFamily,
      ),
      button: base.button?.copyWith(
        fontSize: _FontSize.button, /// 18
        fontWeight: _bold,
        letterSpacing:0.14,
        fontFamily: _sFDisplayLightFamily,
      ),
      caption: base.caption?.copyWith(
        fontSize: _FontSize.caption,  /// 12
        fontWeight: _regular,
        letterSpacing:0.14,
        fontFamily: _sFDisplayLightFamily,
      ),
      overline: base.overline?.copyWith(
        fontSize: _FontSize.overline, /// 10
        fontWeight: _regular,
        letterSpacing:0.14,
        fontFamily: _sFDisplayLightFamily,
      ),
    )
    .apply(
      displayColor: textColor,
      bodyColor: textColor,
    );