import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:trydos/common/helper/helper_functions.dart';

import 'language_service.dart';

class LocalizationService extends StatelessWidget {
  final Widget child;
  const LocalizationService({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EasyLocalization(
      path: "assets/languages",
      saveLocale: true,
      startLocale: HelperFunctions.getInitLocale(),
      fallbackLocale: HelperFunctions.getInitLocale(),
      supportedLocales: supportedLocal,
      child: child,
    );
  }
}
