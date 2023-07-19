import 'dart:async';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../../enums/status_code_type.dart';
import '../api.dart';
import '../client_config.dart';

class PostClient<T> extends BaseApi<T> {
  PostClient({
    required this.requestPrams,
    this.onSendProgress,
    this.onReceiveProgress,
  })  : _fromJson = requestPrams.response.fromJson,
        _valueOnSuccess = requestPrams.response.returnValueOnSuccess,
        _queryParameters = requestPrams.queryParameters,
        _data = requestPrams.data,
        _endpoint = requestPrams.endpoint,
  _receiveTimeout = requestPrams.receiveTimeout,
  _sendTimeout = requestPrams.sendTimeout;
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

  @override
  Future<T> call() async {
    try {
      final uri = Uri.parse(client.options.baseUrl);
      stopWatch.start();
      final Response response = await client.postUri(
        Uri(
          host: uri.host,
          scheme: uri.scheme,
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
      Logger(printer: PrettyPrinter(methodCount: 0)).wtf(stopWatch.elapsed.toString());
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
