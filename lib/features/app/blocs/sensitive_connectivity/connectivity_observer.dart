
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import 'sensitive_connectivity_bloc.dart';

class ConnectivityObserver {
  static ConnectivityResult previousEvent = ConnectivityResult.other;
  static ConnectivityResult? currentEvent ;
  static ConnectivityObserver? instance;
  static  PrefsRepository prefs = GetIt.I<PrefsRepository>();
  static createInstance(BuildContext context) {
    instance ??= ConnectivityObserver();
    Connectivity().onConnectivityChanged.listen((event) {
      currentEvent=event;
      if (Enum.compareByName(previousEvent, event) == 0 ||
          ((event == ConnectivityResult.mobile ||
              event == ConnectivityResult.wifi) &&
              previousEvent == ConnectivityResult.other)) {
        return;
      }
      previousEvent=event;
      BlocProvider.of<SensitiveConnectivityBloc>(context).add(
        ChangeConnectivityEvent(connectivityResult: event),
      );
    });
  }
}
