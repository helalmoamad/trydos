import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/calls/presentation/bloc/calls_bloc.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import '../features/app/blocs/pre_caching_image_bloc/pre_caching_image_bloc.dart';
import '../features/app/blocs/sensitive_connectivity/sensitive_connectivity_bloc.dart';
import '../features/story/presentation/bloc/story_bloc.dart';

class ServiceProvider extends StatelessWidget {
  final Widget child;
  const ServiceProvider({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (BuildContext context) => GetIt.I<CallsBloc>()),
        BlocProvider(create: (BuildContext context) => GetIt.I<StoryBloc>()),
        BlocProvider(create: (BuildContext context) => GetIt.I<AppBloc>()),
        BlocProvider(
            create: (BuildContext context) => SensitiveConnectivityBloc()),
        BlocProvider(create: (BuildContext context) => GetIt.I<AuthBloc>()),
        BlocProvider(create: (BuildContext context) => GetIt.I<ChatBloc>()),
        BlocProvider(create: (BuildContext context) => GetIt.I<HomeBloc>()),
        BlocProvider(create: (BuildContext context) => GetIt.I<PreCachingImageBloc>()),
      ],
      child: child,
    );
  }
}
