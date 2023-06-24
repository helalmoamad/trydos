import 'dart:async';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:shipping/common/enums/status_code_type.dart';
import '../../../common/constant/configuration/url_routes.dart';
import '../base_api.dart';
import '../client_config.dart';

class DeleteClient<T> extends BaseApi<T> {
  DeleteClient({
    required this.requestPrams,
  })  : _fromJson = requestPrams.response.fromJson,
        _valueOnSuccess = requestPrams.response.returnValueOnSuccess,
        _queryParameters = requestPrams.queryParameters,
        _endpoint = requestPrams.endpoint;

  final RequestConfig<T> requestPrams;
  final FromJson<T>? _fromJson;
  final T? _valueOnSuccess;
  final Map<String, dynamic>? _queryParameters;
  final String _endpoint;
  final Stopwatch stopWatch = Stopwatch();
  @override
  Future<T> call() async {
    try {
      final Uri uri = Uri(
        host: Urls.baseUri.host,
        scheme: Urls.baseUri.scheme,
        path: _endpoint,
        queryParameters: _queryParameters,
      );
      stopWatch.start();
      final Response response = await client.deleteUri(uri, options: options);
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
