import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' hide Category;
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

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    try {
      if (err.response?.statusCode == 400 || err.response?.statusCode == 422) {
        if (kDebugMode)
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

      await _handleUnauthorizedError(err);
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

  /// Handles backend "unauthorized" (401) errors: clears the token of the
  /// server the failing request belongs to and, for market-scoped servers,
  /// silently re-registers the user as a guest to refresh the token.
  ///
  /// Any decode/lookup failure is intentionally allowed to throw — the caller
  /// wraps this in a try/catch, matching the original behaviour.
  Future<void> _handleUnauthorizedError(DioException err) async {
    final Map<String, dynamic> body = jsonDecode(err.response.toString());

    final bool isUnauthorized =
        body["message"].toString().contains("Unauth") ||
        body["code"].toString() == "401" ||
        body["statusCode"].toString() == "401";
    if (!isUnauthorized) return;

    final String path = err.requestOptions.path;
    bool isFrom(String envKey) => path.contains(dotenv.env[envKey]!);

    // Clear the token of whichever server rejected the request.
    if (isFrom('STORY_URL')) {
      _prefsRepository.setStoriesToken("");
    }
    if (isFrom('WALLET_URL')) {
      _prefsRepository.setWalletToken("");
    }
    if (isFrom('CHAT_URL')) {
      GetIt.I<AuthBloc>().add(const RefreshChatTokenEvent());
    }

    if (isFrom('COMMENT_TOKEN_URL')) {
      _prefsRepository.setTokenForComment("");
    }
    if (kDebugMode) {
      print("Access token rejected — requesting a token refresh...");
    }
    // Market 401: the access token expired or was rejected -> exchange the
    // stored refresh token for a new access + refresh pair (once per expiry —
    // guarded by isTokenExpired, which the refresh resets on success). If the
    // refresh itself is rejected, AuthBloc falls back to a brand-new guest
    // session (register-guest) per the auth contract.
    if ((isFrom("MARKETGo_URL") || isFrom('MARKET_URL'))) {
      if (kDebugMode) {
        print("Access token rejected — requesting a token refresh...");
      }
      GetIt.I<AuthBloc>().add(const RefreshTokenEvent());
    }
  }
}
