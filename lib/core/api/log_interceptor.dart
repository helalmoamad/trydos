import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/story/presentation/bloc/story_bloc.dart';
import '../../enums/status_code_type.dart';
import '../domin/repositories/prefs_repository.dart';
import 'api.dart';

enum _StatusType { succeed, failed }

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
        "\n token : ${options.headers[HttpHeaders.authorizationHeader]}"
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
      options.data is! FormData ? options.data : {'data': 'formData'},
    );

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      log(response.data.toString());
      _StatusType statusType;
      if (response.statusCode == StatusCode.operationSucceeded.code ||
          response.statusCode == StatusCode.createdSucceeded.code ||
          response.statusCode == 204) {
        statusType = _StatusType.succeed;
      } else {
        statusType = _StatusType.failed;
      }
      final requestRoute = response.requestOptions.path;

      if (statusType == _StatusType.failed) {
        prettyPrinterError(
          '***|| ${statusType.name.toUpperCase()} Response into -> $requestRoute ||***',
        );
      } else {
        prettyPrinterV(
          '***|| ${statusType.name.toUpperCase()} Response into -> $requestRoute ||***',
        );
      }
      prettyPrinterWtf(
        "***|| INFO Response Request $requestRoute ${statusType == _StatusType.succeed ? '✊' : ''} ||***"
        "\n Status code: ${response.statusCode}"
        "\n Status message: ${response.statusMessage}"
        "\n Data: ${response.data}",
      );
    }
    //////////////////// For analytics /////////////////////////////

    // FirebaseAnalyticsService.logEventForSession(
    //   eventName: AnalyticsEventsConst.programmingEvent,
    //   executedEventName: AnalyticsButtonsEventNameConst.apiResponseEvent,
    //   isForApi: true,
    //   extraParams: {
    //     'api_url':
    //         apiPath.length > 100 ? '${apiPath.substring(0, 96)}...' : apiPath,
    //     'api_status': apiStatus,
    //   },
    // );
    /////////////////////////////////////////////////////
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    try {
      // إضافة كود الخطأ للـresponse حتى يصل للـBloc

      // if (err.response?.statusCode == 400) {
      //   showMessage(jsonDecode(err.response.toString())["message"].toString(),
      //       foreGroundColor: Colors.white,
      //       backGroundColor: Colors.black,
      //       showInRelease: true,
      //       timeShowing: Toast.LENGTH_LONG);
      // }
      if (err.response?.statusCode == 400 || err.response?.statusCode == 422) {
        print(
          "error message: ${jsonDecode(err.response.toString())["message"].toString()}",
        );
        showMessage(
          jsonDecode(err.response.toString())["message"].toString(),
          foreGroundColor: Colors.white,
          backGroundColor: Colors.black,
          hasError: true,
          showInRelease: true,
        );
      }
      if (err.requestOptions.path.contains("stories/upload_story") ||
          err.requestOptions.path.contains("/djooohujg/upload")) {
        GetIt.I<StoryBloc>().add(const ChangeStatusUploadToFailureEvent());
      }
      if (err.requestOptions.path.contains("storage/storage-upload")) {
        GetIt.I<HomeBloc>().add(
          UploadUserPhotoCloudinaryEvent(File("path"), true),
        );
      }
      if (err.requestOptions.path.contains("customer/update-profile")) {
        try {
          String massageJson = jsonDecode(err.response.toString())["message"];
          Map<String, dynamic> messageDecode = jsonDecode(massageJson);
          showMessage(
            messageDecode["phone"][0],
            foreGroundColor: Colors.white,
            backGroundColor: Colors.black,
            hasError: true,
            showInRelease: true,
          );
        } catch (e) {}
      }
      if (err.requestOptions.path.contains("order/checkout")) {
        try {
          String massageJson = jsonDecode(err.response.toString())["message"];
          // Map<String, dynamic> messageDecode = jsonDecode(massageJson);
          showMessage(
            massageJson,
            foreGroundColor: Colors.white,
            backGroundColor: Colors.black,
            hasError: true,
            showInRelease: true,
          );
        } catch (e) {}
      }

      if ((err.requestOptions.path.toString().contains("register-guest")) &&
          jsonDecode(err.response.toString())["message"] ==
              "The user does not exist.") {
        String? deviceId = await HelperFunctions.getDeviceId();
        Future.delayed(
          const Duration(seconds: 5),
          () => GetIt.I<AuthBloc>().add(
            RegisterGuestEvent(deviceId: deviceId ?? ""),
          ),
        );
      }

      if ((jsonDecode(
                err.response.toString(),
              )["message"].toString().contains("Unauth") ||
              jsonDecode(err.response.toString())["code"].toString() ==
                  "401") &&
          (err.requestOptions.path.contains(dotenv.env['STORY_URL']!))) {
        _prefsRepository.setStoriesToken("");
      }
      if ((jsonDecode(
                err.response.toString(),
              )["message"].toString().contains("Unauth") ||
              jsonDecode(err.response.toString())["code"].toString() ==
                  "401") &&
          (err.requestOptions.path.contains(dotenv.env['WALLET_URL']!))) {
        _prefsRepository.setWalletToken("");
      }
      if ((jsonDecode(
                err.response.toString(),
              )["message"].toString().contains("Unauth") ||
              jsonDecode(err.response.toString())["code"].toString() ==
                  "401") &&
          (err.requestOptions.path.contains(dotenv.env['CHAT_URL']!))) {
        _prefsRepository.setChatToken("");
      }
      if ((jsonDecode(
                err.response.toString(),
              )["message"].toString().contains("Unauth") ||
              jsonDecode(err.response.toString())["code"].toString() ==
                  "401") &&
          (err.requestOptions.path.contains(dotenv.env['COMMENT_TOKEN_URL']!) ||
              err.requestOptions.path.contains(dotenv.env['MARKET_URL']!) ||
              err.requestOptions.path.contains(dotenv.env['WALLET_URL']!)) &&
          !(_prefsRepository.isTokenExpired ?? false)) {
        _prefsRepository.setVerifiedPhonePeforeExpiredToken(
          _prefsRepository.isVerifiedPhone ?? false,
        );
        String? deviceId = await HelperFunctions.getDeviceId();
        _prefsRepository.setTokenExpired(true);
        GetIt.I<AuthBloc>().add(
          RegisterGuestEvent(
            oldGuestUserId: _prefsRepository.myMarketId.toString(),
            deviceId: deviceId!,
          ),
        );

        _prefsRepository.setVerifiedPhone(false);
      }
    } catch (e) {}
    try {
      GetIt.I<HomeBloc>().add(
        SendErrorToMobileErrorLogEvent(
          errorExption: jsonDecode(
            err.response.toString(),
          )["message"].toString(),
          errorPath: "Back End Error",
          urlBackend: err.stackTrace.toString(),
          messageFromeBackend: jsonDecode(
            err.response.toString(),
          )["message"].toString(),
          lastForPageHasBeenVisited: LastPagesTracker.lastPages.join(' > '),
        ),
      );
    } catch (e) {}

    if (kDebugMode) {
      prettyPrinterError(
        "***|| SOMETHING ERROR 💔 ||***"
        "\n url: ${err.requestOptions.path}"
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
        err.requestOptions.data is FormData
            ? {'data': 'FormData'}
            : err.requestOptions.data,
      );
    }
    // GetIt.I<Dio>().post('${ChatUrls.baseUrl}/${ChatEndPoints.createBugEP}', data: {
    //   "user_id": _prefsRepository.myChatId,
    //   "title": "request error",
    //   "description": err.toString()
    // });

    //String apiPath = err.requestOptions.path;
    // FirebaseAnalyticsService.logEventForSession(
    //   eventName: AnalyticsEventsConst.programmingEvent,
    //   executedEventName: AnalyticsButtonsEventNameConst.apiResponseEvent,
    //   isForApi: true,
    //   extraParams: {
    //     'api_url':
    //         apiPath.length > 100 ? '${apiPath.substring(0, 96)}...' : apiPath,
    //     'api_status': 'Failed',
    //   },
    // );

    //  handler.next(err);

    // إضافة كود الخطأ للـdata
    Map<String, dynamic> errorData = {
      'error_code': err.response?.statusCode ?? 0,
      'error_message': err.message ?? "",
      'error_type': err.type.toString(),
      'original_data': err.response?.data is FormData
          ? {'data': 'FormData'}
          : err.response?.data ?? {},
    };

    // إنشاء response جديد مع معلومات الخطأ
    Response errorResponse = Response(
      requestOptions: err.requestOptions,
      statusCode: err.response?.statusCode ?? 0,
      statusMessage: err.response?.statusMessage ?? "",
      data: errorData,
      headers: err.response?.headers,
    );

    // إرسال الـresponse بدلاً من الـerror
    handler.resolve(errorResponse);
  }
}
