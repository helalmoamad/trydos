part of 'sensitive_connectivity_bloc.dart';

@immutable
abstract class SensitiveConnectivityEvent extends Equatable{
  const SensitiveConnectivityEvent();
}

class ChangeConnectivityEvent extends SensitiveConnectivityEvent{
  final ConnectivityResult connectivityResult;

  const ChangeConnectivityEvent({required this.connectivityResult});
  @override
  List<Object> get props => [];
}