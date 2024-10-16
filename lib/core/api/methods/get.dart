import 'dart:async';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import '../../../common/constant/configuration/chat_url_routes.dart';
import '../../../enums/status_code_type.dart';
import '../../domin/repositories/prefs_repository.dart';
import '../api.dart';
import '../client_config.dart';
import 'detect_server.dart';
import 'dart:developer';

class GetClient<T> extends BaseApi<T> {
  GetClient({
    required this.requestPrams,
    required this.serverName,
    this.onReceiveProgress,
  })  : _fromJson = requestPrams.response.fromJson,
        _valueOnSuccess = requestPrams.response.returnValueOnSuccess,
        _endpoint = requestPrams.endpoint,
        _queryParameters = requestPrams.queryParameters,
        _receiveTimeout = requestPrams.receiveTimeout,
        _sendTimeout = requestPrams.sendTimeout,
        super(serverName);
  final Duration? _receiveTimeout;
  final Duration? _sendTimeout;
  final Stopwatch stopWatch = Stopwatch();
  RequestConfig<T> requestPrams;
  final ProgressCallback? onReceiveProgress;

  final FromJson<T>? _fromJson;
  final T? _valueOnSuccess;
  final String _endpoint;
  final Map<String, dynamic>? _queryParameters;
  final ServerName serverName;
  @override
  Future<T> call() async {
    try {
      print(
          "***********************************############################${_receiveTimeout}+++++++++++++++++++++++++++++++++++++++++++++++++++++++14[${options.receiveTimeout}]");
      stopWatch.start();
      final baseUri = getBaseUriForSpecificServer(serverName);

      final Response response = await client.getUri(
        Uri(
          host: baseUri.host,
          scheme: baseUri.scheme,
          path: _endpoint,
          queryParameters: _queryParameters,
        ),
        options: options.copyWith(
            receiveTimeout: _receiveTimeout ?? options.receiveTimeout,
            sendTimeout: _sendTimeout ?? options.sendTimeout),
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
        final exception = getException(
            statusCode: response.statusCode!,
            message: response.data['message']);
        throw exception;
      }
    } catch (exception) {
      rethrow;
    }
  }
}
