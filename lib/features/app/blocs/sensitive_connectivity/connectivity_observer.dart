import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import 'sensitive_connectivity_bloc.dart';

class ConnectivityObserver {
  static ConnectivityResult previousEvent = ConnectivityResult.other;
  static ConnectivityResult? currentEvent;
  static ConnectivityObserver? instance;
  static PrefsRepository prefs = GetIt.I<PrefsRepository>();

  static ConnectivityResult _resolveConnectivityResult(
    List<ConnectivityResult> results,
  ) {
    if (results.contains(ConnectivityResult.wifi)) {
      return ConnectivityResult.wifi;
    }
    if (results.contains(ConnectivityResult.mobile)) {
      return ConnectivityResult.mobile;
    }
    if (results.contains(ConnectivityResult.none)) {
      return ConnectivityResult.none;
    }
    return results.isEmpty ? ConnectivityResult.other : results.first;
  }

  static createInstance(BuildContext context) {
    instance ??= ConnectivityObserver();
    Connectivity().onConnectivityChanged.listen((event) {
      final resolvedEvent = _resolveConnectivityResult(event);
      currentEvent = resolvedEvent;
      if (Enum.compareByName(previousEvent, resolvedEvent) == 0 ||
          ((resolvedEvent == ConnectivityResult.mobile ||
                  resolvedEvent == ConnectivityResult.wifi) &&
              previousEvent == ConnectivityResult.other)) {
        return;
      }
      previousEvent = resolvedEvent;
      BlocProvider.of<SensitiveConnectivityBloc>(
        context,
      ).add(ChangeConnectivityEvent(connectivityResult: resolvedEvent));
    });
  }
}
