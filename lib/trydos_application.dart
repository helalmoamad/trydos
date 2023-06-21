import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/common/constant/design/constant_design.dart';
import 'package:trydos/config/theme/app_theme.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/service/language_service.dart';
import 'package:trydos/service/localization_service.dart';
import 'package:trydos/service/screen_service.dart';
import 'package:trydos/service/service_provider.dart';
import 'package:trydos/splash_page.dart';


class TrydosApplication extends StatefulWidget {
  const TrydosApplication({Key? key}) : super(key: key);

  static final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

  @override
  State<TrydosApplication> createState() => _TrydosApplicationState();
}

class _TrydosApplicationState extends State<TrydosApplication> {


  @override
  void didChangeDependencies() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: colorScheme.white,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ));
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: kDesignSize,
      minTextAdapt: true,
      builder: (context, child) {
        return LocalizationService(
          child: ServiceProvider(
            child: MaterialApp(
                navigatorKey: TrydosApplication.navKey,
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light,
                builder: (context, child) {
                  LanguageService(context);
                  ScreenService(context);
                  return child!;
                },
                home:  const SplashPage()),
          ),
        );
      },
    );
  }
}
