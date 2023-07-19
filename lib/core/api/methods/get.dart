import 'dart:async';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../../common/constant/configuration/url_routes.dart';
import '../../../enums/status_code_type.dart';
import '../api.dart';
import '../client_config.dart';

class GetClient<T> extends BaseApi<T> {
  GetClient({
    required this.requestPrams,
    this.onReceiveProgress,
  })  : _fromJson = requestPrams.response.fromJson,
        _valueOnSuccess = requestPrams.response.returnValueOnSuccess,
        _endpoint = requestPrams.endpoint,
        _queryParameters = requestPrams.queryParameters,
  _receiveTimeout = requestPrams.receiveTimeout,
  _sendTimeout = requestPrams.sendTimeout;
  final Duration? _receiveTimeout;
  final Duration? _sendTimeout;
  final Stopwatch stopWatch = Stopwatch();
  RequestConfig<T> requestPrams;
  final ProgressCallback? onReceiveProgress;

  final FromJson<T>? _fromJson;
  final T? _valueOnSuccess;
  final String _endpoint;
  final Map<String, dynamic>? _queryParameters;

  @override
  Future<T> call() async {
    try {

      stopWatch.start();

      final Response response = await client.getUri(
        Uri(
          host: Urls.baseUri.host,
          scheme: Urls.baseUri.scheme,
          path:  _endpoint,
          queryParameters: _queryParameters,
        ),
        options: options.copyWith(
            receiveTimeout: _receiveTimeout ?? options.receiveTimeout, sendTimeout: _sendTimeout ?? options.sendTimeout),
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
        final exception = getException(statusCode: response.statusCode!, message: response.data['message']);
        throw exception;
      }
    } catch (exception) {
      rethrow;
    }
  }
}
