import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../enums/status_code_type.dart';
import '../../service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../service/firebase_analytics_service/analytics_const/analytics_executed_event_name.dart';
import '../domin/repositories/prefs_repository.dart';
import 'api.dart';

enum _StatusType {
  succeed,
  failed,
}

class LoggerInterceptor extends Interceptor with HandlingExceptionRequest {
  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      log(_prefsRepository.chatToken.toString());
      log('story ${_prefsRepository.storiesToken.toString()}');
      prettyPrinterI(
        "***|| INFO Request ${options.path} ||***"
        "\n HTTP Method: ${options.method}"
        "\n token : ${options.headers[HttpHeaders.authorizationHeader]?.substring(0, 20)}"
        "\n param : ${options.data}"
        "\n url: ${options.path}"
        "\n Header: ${options.headers}"
        "\n timeout: ${options.connectTimeout! ~/ 1000}s",
      );
    }
    _prefsRepository.saveRequestsData(
        'This From Request   ${options.path}',
        options.data is! FormData ? options.data : {'data': 'formData'},
        options.headers,
        null,
        options.method,
        options.queryParameters,
        options.data is! FormData ? options.data : {'data': 'formData'});

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      _StatusType statusType;
      if (response.statusCode == StatusCode.operationSucceeded.code) {
        statusType = _StatusType.succeed;
      } else {
        statusType = _StatusType.failed;
      }
      final requestRoute = response.requestOptions.path;

      if (statusType == _StatusType.failed) {
        prettyPrinterError(
            '***|| ${statusType.name.toUpperCase()} Response into -> $requestRoute ||***');
      } else {
        prettyPrinterV(
            '***|| ${statusType.name.toUpperCase()} Response into -> $requestRoute ||***');
      }
      prettyPrinterWtf(
        "***|| INFO Response Request $requestRoute ${statusType == _StatusType.succeed ? '✊' : ''} ||***"
        "\n Status code: ${response.statusCode}"
        "\n Status message: ${response.statusMessage}"
        "\n Data: ${response.data}",
      );
    }
    //////////////////// For analytics /////////////////////////////
    String apiStatus = '';
    if (response.statusCode == StatusCode.operationSucceeded.code) {
      apiStatus = 'Succeeded';
    } else {
      apiStatus = 'Failed';
    }
    /////////
    String apiPath = response.requestOptions.path;
    FirebaseAnalyticsService.logEventForSession(
      eventName: AnalyticsEventsConst.programmingEvent,
      executedEventName: AnalyticsExecutedEventNameConst.apiResponseEvent,
      isForApi: true,
      extraParams: {
        'api_url':
            apiPath.length > 100 ? '${apiPath.substring(0, 96)}...' : apiPath,
        'api_status': apiStatus,
      },
    );
    /////////////////////////////////////////////////////
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      prettyPrinterError(
        "***|| SOMETHING ERROR 💔 ||***"
        "\n error: ${err.error}"
        "\n response: ${err.response}"
        "\n message: ${err.message}"
        "\n type: ${err.type}"
        "\n stackTrace: ${err.stackTrace}",
      );
      _prefsRepository.saveRequestsData(
          err.requestOptions.path,
          {'error': err.error.toString()},
          err.response?.headers.map ?? {},
          err.response?.statusCode,
          err.requestOptions.method,
          err.requestOptions.queryParameters,
          err.requestOptions.data);
    }
    // GetIt.I<Dio>().post('${ChatUrls.baseUrl}/${ChatEndPoints.createBugEP}', data: {
    //   "user_id": _prefsRepository.myChatId,
    //   "title": "request error",
    //   "description": err.toString()
    // });

    String apiPath = err.requestOptions.path;
    FirebaseAnalyticsService.logEventForSession(
      eventName: AnalyticsEventsConst.programmingEvent,
      executedEventName: AnalyticsExecutedEventNameConst.apiResponseEvent,
      isForApi: true,
      extraParams: {
        'api_url':
            apiPath.length > 100 ? '${apiPath.substring(0, 96)}...' : apiPath,
        'api_status': 'Failed',
      },
    );

    handler.next(err);
  }
}
