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
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
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
    if (prefsRepository.chatToken != null) {
      BlocProvider.of<ChatBloc>(context).add(GetChatsEvent());
    }
    if (prefsRepository.storiesToken != null) {
      BlocProvider.of<StoryBloc>(context).add(GetStoryEvent());
    }
    if (prefsRepository.marketToken != null) {
      BlocProvider.of<AuthBloc>(context).add(GetCustomerInfoEvent());
      return;
    } else if (prefsRepository.marketToken == null) {
      registerGuest();
    }
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: context.colorScheme.background,
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.getCustomerInfoStatus == GetCustomerInfoStatus.success) {
              context.go(GRouter.config.applicationRoutes.kBasePage);
            }
          },
          child: BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state.registerGuestStatus == RegisterGuestStatus.success) {
                context.go(GRouter.config.applicationRoutes.kRegistrationPage);
              }
            },
            child: Center(child: logo),
          ),
        ));
  }

  void registerGuest() async {
    String? deviceId = await HelperFunctions.getDeviceId();
    BlocProvider.of<AuthBloc>(context).add(
        RegisterGuestEvent(deviceId: deviceId!));
  }
}
