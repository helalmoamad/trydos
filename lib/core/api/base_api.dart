import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/core/api/methods/detect_server.dart';
import '../../service/language_service.dart';
import '../domin/repositories/prefs_repository.dart';
import 'handling_exception.dart';

abstract class BaseApi<T> with HandlingExceptionRequest {
  BaseApi(this.serverName) {
    Map<String, dynamic> headers = client.options.headers;
    final String? token = getServerToken(serverName);
    if (token != null) {
      headers = client.options.headers..[HttpHeaders.authorizationHeader] = 'Bearer ${token}';
    }

    headers = client.options.headers..[HttpHeaders.acceptLanguageHeader] = LanguageService.languageCode;

    options = Options(headers: headers);
  }
  final ServerName serverName ;
  @protected
  final client = GetIt.I<Dio>();


  late Options options;


  Future<T> call();
}
