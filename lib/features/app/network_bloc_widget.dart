import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/sensitive_connectivity/sensitive_connectivity_bloc.dart';

class NetworkBlocSensitive extends StatelessWidget {
  final Widget child;
  final double opacity;

  const NetworkBlocSensitive({
    required this.child,
    this.opacity = 0.6,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SensitiveConnectivityBloc, SensitiveConnectivityState>(
      builder: (context, state) {
        if (state is ConnectivityWifiState) {
          return child;
        } else if (state is ConnectivityCellularState) {
          return AnimatedOpacity(
            curve: Curves.ease,
            duration: const Duration(milliseconds: 300),
            opacity: opacity,
            child: child,
          );
        } else {
          return AnimatedOpacity(
            curve: Curves.ease,
            duration: const Duration(milliseconds: 300),
            opacity: 0.3,
            child: IgnorePointer(
              ignoring: true,
              child: child,
            ),
          );
        }
      },
    );
  }
}
