import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';

enum LangCode { ar, en, tr }

List<Locale> supportedLocal = [
  localMap[LangCode.ar]!,
  localMap[LangCode.en]!,
  localMap[LangCode.tr]!,
];

final Locale defaultLocal = localMap[LangCode.en]!;

final localMap = {
  LangCode.en: const Locale('en', 'US'),
  LangCode.tr: const Locale('tr', 'TR'),
  LangCode.ar: const Locale('ar', 'SY'),
};

final mpaLanguageCodeToLocale = {
  LangCode.en.name: const Locale('en', 'US'),
  LangCode.ar.name: const Locale('ar', 'SY'),
  LangCode.tr.name: const Locale('tr', 'TR'),
};

final languageNameAndLanguageCode = <String, LangCode>{
  'English': LangCode.en,
  'Arabic': LangCode.ar,
  'Turkish': LangCode.tr,
};

class LanguageService {
  static late Locale currentLanguage;
  static String languageCode = 'en';
  static late bool rtl;

  final BuildContext context;
  static LanguageService? _instance;

  LanguageService._singleton(this.context) {
    currentLanguage = _currentLanguage;
    languageCode = _languageCode;
    rtl = _rtl;
  }

  factory LanguageService(BuildContext context) {
    if (_instance != null) {
      if (context.locale.languageCode != languageCode) {
        return LanguageService._singleton(context);
      }
      return _instance!;
    }
    return LanguageService._singleton(context);
  }

  Locale get _currentLanguage => context.locale;

  String get _languageCode => _currentLanguage.languageCode;

  bool get _rtl => context.locale == localMap[LangCode.ar]!;
}
