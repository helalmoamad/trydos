import 'dart:async';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../../enums/status_code_type.dart';
import '../api.dart';
import '../client_config.dart';
import 'detect_server.dart';

typedef whenComplete = FutureOr<void> Function();

class PostClient<T> extends BaseApi<T> {
  whenComplete? whenComplete1;

  PostClient({
    required this.requestPrams,
    required this.serverName,
    this.whenComplete1,
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
          .whenComplete(whenComplete1 ?? () => null);
      stopWatch.stop();
      prettyPrinterI(stopWatch.elapsed.toString());
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
