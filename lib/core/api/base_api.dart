import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
      headers = client.options.headers
        ..[HttpHeaders.authorizationHeader] = 'Bearer $token';
    }
    if (serverName != ServerName.cloudinary) {
      headers = client.options.headers
        ..['country'] = GetIt.I<PrefsRepository>().userCountryIsAvailable == 1
            ? GetIt.I<PrefsRepository>().userChoosedCountryIso
            : GetIt.I<PrefsRepository>().countryIso;
      headers = client.options.headers
        ..['lang'] = LanguageService.languageCode == 'ar'
            ? 'ae'
            : LanguageService.languageCode;
      headers = client.options.headers
        ..['original_user_id'] = GetIt.I<PrefsRepository>().myMarketId;
      headers.addAll({
        'User-Agent': 'device OS:' +
            (Platform.isAndroid ? 'Android' : 'IOS') +
            ' '
                ', application version: 1.0.0',
      });
    }
    options = Options(headers: headers);
  }

  final ServerName serverName;

  final client = GetIt.I<Dio>();

  late Options options;

  Future<T> call();
}
