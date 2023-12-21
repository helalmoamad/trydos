import 'dart:async';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import '../../../common/constant/configuration/chat_url_routes.dart';
import '../../../enums/status_code_type.dart';
import '../../domin/repositories/prefs_repository.dart';
import '../base_api.dart';
import '../client_config.dart';
import 'detect_server.dart';

class DeleteClient<T> extends BaseApi<T> {
  DeleteClient({
    required this.requestPrams,
    required this.serverName,
  })  : _fromJson = requestPrams.response.fromJson,
        _valueOnSuccess = requestPrams.response.returnValueOnSuccess,
        _queryParameters = requestPrams.queryParameters,
        _endpoint = requestPrams.endpoint,
        _receiveTimeout = requestPrams.receiveTimeout,
        _sendTimeout = requestPrams.sendTimeout, super(serverName);

  final RequestConfig<T> requestPrams;
  final FromJson<T>? _fromJson;
  final T? _valueOnSuccess;
  final Map<String, dynamic>? _queryParameters;
  final String _endpoint;
  final Stopwatch stopWatch = Stopwatch();
  final Duration? _receiveTimeout;
  final Duration? _sendTimeout;
  final ServerName serverName ;

  @override
  Future<T> call() async {
    try {
      final baseUri = getBaseUriForSpecificServer(serverName);

      final Uri uri = Uri(
        host: baseUri.host,
        scheme: baseUri.scheme,
        path: _endpoint,
        queryParameters: _queryParameters,
      );
      stopWatch.start();
      final Response response = await client.deleteUri(uri,
          options: options.copyWith(
              receiveTimeout: _receiveTimeout ?? options.receiveTimeout, sendTimeout: _sendTimeout ?? options.sendTimeout));
      stopWatch.stop();
      GetIt.I<PrefsRepository>().saveRequestsData(
          response.requestOptions.path,
          response.data is! FormData ? response.data : {'data': 'formData'},
          response.requestOptions.headers,
          response.statusCode,
          response.requestOptions.method,
          response.requestOptions.queryParameters,
          response.data is! FormData ? response.data : {'data': 'formData'},
          responseTime: stopWatch.elapsed.toString()
      );
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
