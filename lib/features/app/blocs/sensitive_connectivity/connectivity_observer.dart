import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'sensitive_connectivity_bloc.dart';

class ConnectivityObserver {
  ConnectivityObserver(BuildContext context) {
    Connectivity().onConnectivityChanged.listen((event) {
      BlocProvider.of<SensitiveConnectivityBloc>(context).add(
        ChangeConnectivityEvent(connectivityResult: event),
      );
    });
  }
}
