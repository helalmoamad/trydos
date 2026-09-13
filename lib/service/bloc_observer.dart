import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trydos/common/helper/dev_log.dart';

class AppBlocObserver extends BlocObserver {

  // @override
  // void onCreate(BlocBase bloc) {
  //   super.onCreate(bloc);
  //   if (bloc is Cubit) {
  //     print("This is a Cubit");
  //   } else {
  //     print("This is a Bloc");
  //   }
  // }

  ///We can react to events
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    devLog("an event Happened in $bloc the event is $event");
  }

  ///We can even react to transitions
  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    /// With this we can specifically know, when and what changed in our Bloc
    devLog("There was a transition from ${transition.currentState} to ${transition.nextState}");
  }

  ///We can react to errors, and we will know the error and the StackTrace
  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    devLog("Error happened in $bloc with error $error and the stacktrace is $stackTrace");
  }

  ///We can even run something, when we close our Bloc
  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    devLog("BLOC is closed");
  }
}