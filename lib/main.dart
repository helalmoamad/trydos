import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/core/di/di_container.dart';
import 'package:trydos/trydos_application.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import 'core/domin/repositories/prefs_repository.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await configureDependencies();
  await Firebase.initializeApp(
    //options: DefaultFirebaseOptions.currentPlatform,
  );
  AssetPicker.registerObserve();
  PhotoManager.setLog(true);
  log( GetIt.I<PrefsRepository>().token.toString());
  // FlutterError.onError = (FlutterErrorDetails error) {};
  // PlatformDispatcher.instance.onError = (error, stack) {
  //   return true;
  // };
  // Isolate.current.addErrorListener(RawReceivePort((pair) async {
  //   final List<dynamic> errorAndStacktrace = pair;
  // }).sendPort);
  HttpOverrides.global =  MyHttpOverrides();
  runApp(const TrydosApplication());
}

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

