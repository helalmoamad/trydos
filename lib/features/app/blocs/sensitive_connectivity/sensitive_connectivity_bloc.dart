import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:injectable/injectable.dart';

import '../../../../common/helper/show_message.dart';
import '../../../../core/api/handling_exception.dart';

part 'sensitive_connectivity_event.dart';
part 'sensitive_connectivity_state.dart';

@injectable
class SensitiveConnectivityBloc extends Bloc<SensitiveConnectivityEvent, SensitiveConnectivityState>
    with HandlingExceptionRequest {
  SensitiveConnectivityBloc() : super(ConnectivityOfflineState()) {
    on<ChangeConnectivityEvent>(_onCheckConnectivity);
  }

  void _onCheckConnectivity(
    ChangeConnectivityEvent event,
    Emitter<SensitiveConnectivityState> emit,
  ) async {

    prettyPrinterI("***|| 🌐 ${event.connectivityResult.name.toUpperCase()} 🌐 ||***");

    if (event.connectivityResult == ConnectivityResult.mobile) {
      emit(ConnectivityCellularState());
    } else if (event.connectivityResult == ConnectivityResult.wifi) {
      emit(ConnectivityWifiState());
    } else {
      showMessage('No Internet connection.',timeShowing: Toast.LENGTH_SHORT);
      emit(ConnectivityOfflineState());
    }
  }
}
