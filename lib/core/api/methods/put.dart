import 'dart:async';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import '../../../enums/status_code_type.dart';
import '../../domin/repositories/prefs_repository.dart';
import '../api.dart';
import '../client_config.dart';
import 'detect_server.dart';
import 'dart:developer';

class PutClient<T> extends BaseApi<T> {
  PutClient({
    required this.requestPrams,
    required this.serverName,
    this.onSendProgress,
    this.onReceiveProgress,
  })  : _fromJson = requestPrams.response.fromJson,
        _valueOnSuccess = requestPrams.response.returnValueOnSuccess,
        _data = requestPrams.data,
        _queryParameters = requestPrams.queryParameters,
        _endpoint = requestPrams.endpoint,
  _receiveTimeout = requestPrams.receiveTimeout,
  _sendTimeout = requestPrams.sendTimeout, super(serverName);

  final RequestConfig<T> requestPrams;
  final Stopwatch stopWatch = Stopwatch();
  final ProgressCallback? onSendProgress;
  final ProgressCallback? onReceiveProgress;
  final Duration? _receiveTimeout;
  final Duration? _sendTimeout;

  final FromJson<T>? _fromJson;
  final T? _valueOnSuccess;
  final dynamic _queryParameters;
  final dynamic _data;
  final String _endpoint;
  final ServerName serverName ;

  @override
  Future<T> call() async {
    try {
      final baseUri = getBaseUriForSpecificServer(serverName);
      stopWatch.start();
      final Response response = await client.putUri(
        Uri(
          host: baseUri.host,
          scheme: baseUri.scheme,
          path: _endpoint,
          queryParameters: _queryParameters,
        ),
        options: options.copyWith(
            receiveTimeout: _receiveTimeout ?? options.receiveTimeout, sendTimeout: _sendTimeout ?? options.sendTimeout),
        data: _data,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

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
      prettyPrinterI(stopWatch.elapsed.toString());
      if (response.statusCode == StatusCode.operationSucceeded.code) {
        if (_fromJson == null) {
          return Future.value(_valueOnSuccess);
        }

        return _fromJson!(response.data);
      } else {
        throw getException(statusCode: response.statusCode!, message: response.data['message']);
      }
    } catch (exception) {
      rethrow;
    }
  }
}
