import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/main.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../chat/presentation/manager/chat_event.dart';
import '../../../story/presentation/bloc/story_bloc.dart';
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
