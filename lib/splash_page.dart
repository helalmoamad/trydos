import 'dart:async';
import 'package:adobe_xd/pinned.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:trydos/base_page.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/authentication/presentation/pages/login_page.dart';
import 'package:trydos/features/chat/presentation/manager/chat_event.dart';
import 'package:trydos/routes/router.dart';
import 'package:trydos/routes/router_config.dart';

import 'core/domin/repositories/prefs_repository.dart';
import 'features/chat/presentation/manager/chat_bloc.dart';
import 'features/story/presentation/bloc/story_bloc.dart';
class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();

  @override
  void initState() {
    Timer(const Duration(seconds: 4), _onSplash);
    if(prefsRepository.chatToken != null){
      BlocProvider.of<ChatBloc>(context).add(GetChatsEvent());
    }
    BlocProvider.of<StoryBloc>(context).add(GetStoryEvent());
//    if(prefsRepository.storiesToken != null){
//
//    }
    super.initState();
  }

  _onSplash() {

    if (prefsRepository.registeredUser) {
      context.go(GRouter.config.applicationRoutes.kBasePage);
    } else {
      context.go(GRouter.config.applicationRoutes.kRegistrationPage);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.background,
      body: Center(
        child: logo
      )
    );
  }
}
