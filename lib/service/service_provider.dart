import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trydos/app_bloc/app_bloc.dart';

class ServiceProvider extends StatelessWidget {
  final Widget child;
  const ServiceProvider({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (BuildContext context) => AppBloc()),
      ],
      child: child,
    );
  }
}
