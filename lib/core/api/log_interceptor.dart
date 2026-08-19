import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/core/api/token_refresh_coordinator.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/story/presentation/bloc/story_bloc.dart';
import '../../enums/status_code_type.dart';
import '../domin/repositories/prefs_repository.dart';
import 'api.dart';

enum _StatusType { succeed, failed }

/// Marks a request that was already replayed after a token refresh. A second
/// 401 on the same request must report the error instead of refreshing again.
const String _retriedKey = 'wf_retried_after_refresh';

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
      //  log("${response.data}");
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
    String? freshToken;
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

      freshToken = await _handleUnauthorizedError(err);
    } catch (e) {}

    // The token was renewed, so replay the request that triggered the refresh —
    // the caller gets the real answer and never sees the 401.
    if (freshToken != null && freshToken.isNotEmpty) {
      final Response<dynamic>? retried = await _retryWithFreshToken(
        err.requestOptions,
        freshToken,
      );
      if (retried != null) {
        handler.resolve(retried);
        return;
      }
    }
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
  /// The HTTP status code is the authoritative signal; the body is only a
  /// fallback for servers that answer `200` with an error envelope.
  ///
  /// Returns the **new** bearer token when a refresh succeeded, so [onError] can
  /// send the failed request again. Returns `null` when there is nothing to
  /// retry with: the error was not a 401, the server has no refresh path, the
  /// refresh failed, or this request was already retried once.
  Future<String?> _handleUnauthorizedError(DioException err) async {
    // رمز الحالة أولاً: خادم الميديا المُقيَّد يردّ بـ 401 وجسمه
    // `{"error": "Unauthorized"}` — بلا أيٍّ من الحقول الثلاثة أدناه، فكان
    // الفحص القديم يخرج مبكراً ولا يُطلَق تحديث الرمز إطلاقاً.
    bool isUnauthorized = err.response?.statusCode == 401;

    if (!isUnauthorized) {
      // احتياط: خوادم تردّ 200 ومعها غلاف خطأ. وفكّ الجسم قد يفشل إن لم يكن
      // JSON (صفحة HTML مثلاً) — لا يجوز أن يُسقط ذلك المعالجة كلها.
      try {
        final Map<String, dynamic> body = jsonDecode(err.response.toString());
        isUnauthorized =
            body["message"].toString().contains("Unauth") ||
            body["error"].toString().contains("Unauth") ||
            body["code"].toString() == "401" ||
            body["statusCode"].toString() == "401";
      } catch (_) {
        // جسم غير قابل للتحليل: نكتفي برمز الحالة
      }
    }
    if (!isUnauthorized) return null;

    // A request that already came back through here once must not start another
    // refresh: the server keeps answering 401, so it would loop forever.
    if (err.requestOptions.extra[_retriedKey] == true) return null;

    final String path = err.requestOptions.path;
    bool isFrom(String envKey) => path.contains(dotenv.env[envKey]!);

    // Clear the token of whichever server rejected the request.
    if (isFrom('STORY_URL')) {
      // لا نمحو رمز الدخول هنا: المحو يجعل كل طلب stories آخر قيد التنفيذ
      // يُبنى بلا bearer. التحديث يستبدله، ومسار الفشل هو الذي يمحوه.
      final bool refreshed = await TokenRefreshCoordinator.instance.refresh(
        RefreshScope.stories,
        () => GetIt.I<AuthBloc>().add(const RefreshStoriesTokenEvent()),
      );
      return refreshed ? _prefsRepository.storiesToken : null;
    }
    if (isFrom('WALLET_URL')) {
      _prefsRepository.setWalletToken("");
    }
    if (isFrom('CHAT_NEST_URL')) {
      // Wait for the refresh instead of firing and forgetting, so the caller
      // can send the request again with the token it produces.
      final bool refreshed = await TokenRefreshCoordinator.instance.refresh(
        RefreshScope.chat,
        () => GetIt.I<AuthBloc>().add(const RefreshChatTokenEvent()),
      );
      return refreshed ? _prefsRepository.chatToken : null;
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
    // خادم الميديا يستعمل رمز دخول السوق نفسه في استخراج تذكرة الرفع
    // (`POST /gated/ticket`)، فرفضه بـ 401 يعني انتهاء رمز السوق — ويُعالَج
    // بنفس مسار التحديث. بدون هذا السطر كان الرفع يفشل بلا أن يُحدَّث الرمز.
    if ((isFrom("MARKETGo_URL") ||
        isFrom('MARKET_URL') ||
        isFrom('MEDIA_SERVER_URL'))) {
      if (kDebugMode) {
        print("Access token rejected — requesting a token refresh...");
      }
      // All three carry the market access token, so one refresh covers them.
      final bool refreshed = await TokenRefreshCoordinator.instance.refresh(
        RefreshScope.market,
        () => GetIt.I<AuthBloc>().add(const RefreshTokenEvent()),
      );
      return refreshed ? _prefsRepository.marketToken : null;
    }
    return null;
  }

  /// Sends [options] again with [freshToken], after a refresh replaced the
  /// expired one.
  ///
  /// Returns `null` when the request cannot be replayed, and the caller then
  /// reports the original error.
  Future<Response<dynamic>?> _retryWithFreshToken(
    RequestOptions options,
    String freshToken,
  ) async {
    try {
      final dynamic body = options.data;
      if (body is FormData) {
        // A multipart body is a single-use stream: the first attempt read it to
        // the end, so replaying it as it is would send empty file parts — and
        // the server would answer 200, hiding the loss. `clone()` rebuilds the
        // parts from their sources, so the replay carries the real bytes again.
        //
        // Safe here because every upload in this app builds its parts with
        // `MultipartFile.fromFile`, which keeps the path and can reopen it. A
        // part built from a raw stream cannot be cloned; that throws, and the
        // catch below then reports the original 401 instead.
        options.data = body.clone();
      }

      // The stored headers still carry the OLD bearer token — `BaseApi` injects
      // it when the request is built, so replaying them as they are would fail
      // with the very same 401.
      options.headers[HttpHeaders.authorizationHeader] = 'Bearer $freshToken';
      options.extra = <String, dynamic>{...options.extra, _retriedKey: true};

      if (kDebugMode) {
        print("Token refreshed — replaying ${options.method} ${options.path}");
      }
      return await GetIt.I<Dio>().fetch(options);
    } catch (_) {
      // Anything at all: fall back to reporting the original 401.
      return null;
    }
  }
}
