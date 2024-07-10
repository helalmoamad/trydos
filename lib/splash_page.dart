import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
import 'common/helper/helper_functions.dart';
import 'core/domin/repositories/prefs_repository.dart';
import 'features/app/blocs/app_bloc/app_event.dart';
import 'features/calls/presentation/utils/bg_terminated_call_utils.dart';
import 'features/chat/data/models/my_chats_response_model.dart';
import 'features/home/presentation/manager/home_bloc.dart';
import 'features/story/presentation/bloc/story_bloc.dart';
import 'dart:convert' as convert;

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
    homeBloc.add(GetMainCategoriesEvent());
    appBloc.add(ChangeTab(-1));

    BlocProvider.of<StoryBloc>(context).add(GetStoryEvent());
    homeBloc.add(GetCartItemEvent());
    checkAndNavigationCallingPage(context, fromTerminated: true,
        whereToNavigationAfterCheck: () {
      context.go(prefsRepository.marketToken == null
          ? GRouter.config.applicationRoutes.kRegistrationPage
          : GRouter.config.applicationRoutes.kBasePage);
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    FirebaseAnalytics.instance.logScreenView(screenName: "Splash Page");
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
          backgroundColor: context.colorScheme.background,
          body: Center(child: logo)),
    );
  }
}
