import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:trydos/base_page.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/chat/presentation/manager/chat_state.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/routes/router.dart';
import 'package:trydos/service/firebase_analytics_service/firebase_analytics_service.dart';
import 'core/domin/repositories/prefs_repository.dart';
import 'features/app/blocs/app_bloc/app_event.dart';
import 'features/calls/presentation/utils/bg_terminated_call_utils.dart';
import 'features/home/presentation/manager/home_bloc.dart';
import 'features/story/presentation/bloc/story_bloc.dart';
import 'service/firebase_analytics_service/analytics_const/analytics_screens.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  late HomeBloc homeBloc;
  late AuthBloc authBloc;
  late AppBloc appBloc;
  @override
  void initState() {
    appBloc = BlocProvider.of<AppBloc>(context);
    homeBloc = BlocProvider.of<HomeBloc>(context);
    authBloc = BlocProvider.of<AuthBloc>(context);

    appBloc.add(ChangeTab(-1));
    GetIt.I<HomeBloc>().add(GetAllowedCountriesEvent());
    BlocProvider.of<StoryBloc>(context).add(GetStoryEvent());

    checkAndNavigationCallingPage(context, fromTerminated: true,
        whereToNavigationAfterCheck: () {
      context.go(prefsRepository.marketToken == null
          ? GRouter.config.applicationRoutes.kRegistrationPage
          : GRouter.config.applicationRoutes.kBasePage);
    });
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    FirebaseAnalyticsService.logScreen(
        screen: AnalyticsScreensConst.splashScreen);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatBloc, ChatState>(
      listener: (context, state) {
        navigationToSinglePageChat(state.chatToNavigateFromTerminated!);
      },
      listenWhen: (p, c) =>
          p.chatToNavigateFromTerminated != c.chatToNavigateFromTerminated,
      child: Scaffold(
          backgroundColor: context.colorScheme.surface,
          body: Center(child: logo)),
    );
  }
}
