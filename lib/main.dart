import 'dart:isolate';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:trydos/core/di/di_container.dart';
import 'package:trydos/trydos_application.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();
  FlutterError.onError = (FlutterErrorDetails error) {};
  PlatformDispatcher.instance.onError = (error, stack) {
    return true;
  };
  Isolate.current.addErrorListener(RawReceivePort((pair) async {
    final List<dynamic> errorAndStacktrace = pair;
  }).sendPort);
  runApp(const TrydosApplication());
}

