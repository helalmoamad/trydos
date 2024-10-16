import 'package:bot_toast/bot_toast.dart';
import 'package:cupertino_back_gesture/cupertino_back_gesture.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/constant/design/constant_design.dart';
import 'package:trydos/config/theme/app_theme.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/features/app/blocs/sensitive_connectivity/connectivity_observer.dart';
import 'package:trydos/features/chat/presentation/manager/chat_event.dart';
import 'package:trydos/routes/router.dart';
import 'package:trydos/service/language_service.dart';
import 'package:trydos/service/localization_service.dart';
import 'package:trydos/service/screen_service.dart';
import 'package:trydos/service/service_provider.dart';
import 'core/domin/repositories/prefs_repository.dart';
import 'features/chat/presentation/manager/chat_bloc.dart';
import 'service/firebase_analytics_service/firebase_analytics_service.dart';

class TrydosApplication extends StatefulWidget {
  const TrydosApplication({Key? key, required this.navKey}) : super(key: key);
  final GlobalKey<NavigatorState> navKey;

  @override
  State<TrydosApplication> createState() => _TrydosApplicationState();
}

final ValueNotifier<bool> denySlidingBackForSlidingUpPanels =
    ValueNotifier(false);

class _TrydosApplicationState extends State<TrydosApplication>
    with WidgetsBindingObserver {
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
    GetIt.I<ChatBloc>().add(GetDateTimeEvent());
    WidgetsBinding.instance.addObserver(this);
    /////////////////////
    FirebaseAnalyticsService.startAnalyticsSession();
    /////////////////////
    super.initState();
    // FirebasePresence.sendUserStatus("online");
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };
    return ScreenUtilInit(
      designSize: kDesignSize,
      minTextAdapt: true,
      builder: (context, child) {
        return LocalizationService(
          child: ServiceProvider(
            child: Builder(
              builder: (context) {
                return ValueListenableBuilder<bool>(
                    valueListenable: denySlidingBackForSlidingUpPanels,
                    child: MaterialApp.router(
                      debugShowCheckedModeBanner: false,
                      locale: context.locale,
                      theme: AppTheme.light,
                      supportedLocales: context.supportedLocales,
                      localizationsDelegates: context.localizationDelegates,
                      routerConfig: GRouter.router,
                      builder: (context, child) {
                        LanguageService(context);
                        ConnectivityObserver.createInstance(context);
                        ScreenService(context);

                        return botToastBuilder(context, child);
                      },
                    ),
                    builder: (context, deny, child) {
                      return BackGestureWidthTheme(
                        backGestureWidth:
                            BackGestureWidth.fraction(deny ? 0 : 1),
                        child: child!,
                      );
                    });
              },
            ),
          ),
        );
      },
    );
  }
}
