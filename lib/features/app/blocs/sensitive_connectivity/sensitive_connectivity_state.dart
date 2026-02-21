part of 'sensitive_connectivity_bloc.dart';

abstract class SensitiveConnectivityState extends Equatable {
  const SensitiveConnectivityState();
}

class SensitiveConnectivityInitial extends SensitiveConnectivityState {
  @override
  List<Object> get props => [];
}

class ConnectivityWifiState extends SensitiveConnectivityState {
  @override
  List<Object> get props => [];
}

class ConnectivityCellularState extends SensitiveConnectivityState {
  @override
  List<Object> get props => [];
}

class ConnectivityOfflineState extends SensitiveConnectivityState {
  @override
  List<Object> get props => [];
}
