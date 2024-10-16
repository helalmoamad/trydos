import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import '../../../enums/status_code_type.dart';
import '../api.dart';
import '../client_config.dart';
import '../log_interceptor.dart';
import 'detect_server.dart';

typedef whenComplete = FutureOr<void> Function();

class PostClient<T> extends BaseApi<T> {
  final void Function(bool isUploadingSuccess)? onUploadingFinished;

  PostClient({
    required this.requestPrams,
    required this.serverName,
    this.onUploadingFinished,
    this.onSendProgress,
    this.onReceiveProgress,
  })  : _fromJson = requestPrams.response.fromJson,
        _valueOnSuccess = requestPrams.response.returnValueOnSuccess,
        _queryParameters = requestPrams.queryParameters,
        _data = requestPrams.data,
        _endpoint = requestPrams.endpoint,
        _receiveTimeout = requestPrams.receiveTimeout,
        _sendTimeout = requestPrams.sendTimeout,
        super(serverName);
  final Stopwatch stopWatch = Stopwatch();
  final RequestConfig<T> requestPrams;

  final ProgressCallback? onSendProgress;
  final ProgressCallback? onReceiveProgress;
  final Duration? _receiveTimeout;
  final Duration? _sendTimeout;
  final FromJson<T>? _fromJson;
  final T? _valueOnSuccess;
  final dynamic _queryParameters;
  final dynamic _data;
  final String _endpoint;
  final ServerName serverName;

  @override
  Future<T> call() async {
    try {
      final baseUri = getBaseUriForSpecificServer(serverName);
      //todo just in case the server is Cloudinary i want to clear the header
      if (serverName == ServerName.cloudinary) {
        options = Options();
        client.options.headers = {};
        // Fluttertoast.showToast(msg: client.options.headers.toString());
      }
      stopWatch.start();
      final Response response = await client
          .postUri(
        Uri(
          host: baseUri.host,
          scheme: baseUri.scheme,
          path: _endpoint,
          queryParameters: _queryParameters,
        ),
        options: options.copyWith(
            receiveTimeout: _receiveTimeout ?? options.receiveTimeout,
            sendTimeout: _sendTimeout ?? options.sendTimeout),
        data: _data,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      )
          .then((response) {
        stopWatch.stop();
        GetIt.I<PrefsRepository>().saveRequestsData(
            'This From Response   ${response.requestOptions.path}',
            response.data is! FormData ? response.data : {'data': 'formData'},
            response.requestOptions.headers,
            response.statusCode,
            response.requestOptions.method,
            response.requestOptions.queryParameters,
            response.data is! FormData ? response.data : {'data': 'formData'},
            responseTime: stopWatch.elapsed.toString()
        );
        log('request time: ${stopWatch.elapsed.toString()}');
        onUploadingFinished?.call(true);
        return response;
      }).catchError((error, errorStack) {
        onUploadingFinished?.call(false);
        return error;
      });

      if (response.statusCode == StatusCode.operationSucceeded.code) {
        if (_fromJson == null) {
          return Future.value(_valueOnSuccess);
        }

        return _fromJson!(response.data);
      } else {
        throw getException(
            statusCode: response.statusCode!,
            message: response.data['message']);
      }
    } catch (exception) {
      rethrow;
    }
  }
}
