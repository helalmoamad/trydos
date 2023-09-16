import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/constant/design/constant_design.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/config/theme/app_theme.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/features/app/blocs/sensitive_connectivity/connectivity_observer.dart';
import 'package:trydos/routes/router.dart';
import 'package:trydos/service/language_service.dart';
import 'package:trydos/service/localization_service.dart';
import 'package:trydos/service/screen_service.dart';
import 'package:trydos/service/service_provider.dart';
import 'package:flutter_smartlook/flutter_smartlook.dart';
class TrydosApplication extends StatefulWidget {
  const TrydosApplication({Key? key , required this.navKey }) : super(key: key);

   final GlobalKey<NavigatorState> navKey ;

  @override
  State<TrydosApplication> createState() => _TrydosApplicationState();
}

class _TrydosApplicationState extends State<TrydosApplication> {

  final Smartlook smartLook = Smartlook.instance;
  @override
  void didChangeDependencies() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: colorScheme.white,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ));
    super.didChangeDependencies();
  }

  final botToastBuilder = BotToastInit();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      initializeSmartLook();
    });

  }
  initializeSmartLook() async {
    String deviceId = await HelperFunctions.getDeviceId().toString();
    await smartLook.preferences.setProjectKey('c8c465313d257c63e0a282ba9856a427973888fe');
    await smartLook.preferences.setFrameRate(2);
    await smartLook.user.setIdentifier(deviceId);
    await smartLook.user.setName(GetIt.I<PrefsRepository>().myName ?? 'No_Name');
    await smartLook.start();
}
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: kDesignSize,
      minTextAdapt: true,
      builder: (context, child) {
        return LocalizationService(
          child: ServiceProvider(
            child: Builder(
              builder: (context) {
                return MaterialApp.router(
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.light,
                    locale: context.locale,
                    supportedLocales: context.supportedLocales,
                    localizationsDelegates: context.localizationDelegates,
                    routerConfig: GRouter.router,
                    builder: (context, child) {
                      LanguageService(context);
                      ConnectivityObserver.createInstance(context);
                      ScreenService(context);
                      return botToastBuilder(context, child);
                    },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
