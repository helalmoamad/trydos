import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../common/constant/configuration/prefs_key.dart';
import '../api/log_interceptor.dart';
import '../data/repository/prefs_repository_impl.dart';
import '../domin/repositories/prefs_repository.dart';
import 'di_container.config.dart';

final GetIt _getIt = GetIt.I;

@InjectableInit(
  initializerName: r'$initGetIt',
  preferRelativeImports: true,
  asExtension: false,
)
Future<GetIt> configureDependencies() async => $initGetIt(_getIt);

@module
abstract class AppModule {
  BaseOptions get dioOption => BaseOptions(
    connectTimeout: const Duration(minutes: 2),
    receiveTimeout: const Duration(minutes: 2),
    sendTimeout: const Duration(minutes: 2),
    contentType: 'application/json',
    headers: <String, String>{HttpHeaders.acceptHeader: 'application/json'},
  );

  @singleton
  Logger get logger => Logger();

  @preResolve
  @singleton
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();

  @preResolve
  @singleton
  Future<PrefsRepository> get prefsRepository async {
    SharedPreferences prefs = await sharedPreferences;
    const secureStorage = FlutterSecureStorage();
    // Migrate existing tokens from SharedPreferences to secure storage (one-time).
    final migratedChatToken = prefs.getString(PrefsKey.chatToken);
    if (migratedChatToken != null && migratedChatToken.isNotEmpty) {
      await secureStorage.write(
        key: PrefsKey.chatToken,
        value: migratedChatToken,
      );
      await prefs.remove(PrefsKey.chatToken);
    }

    final migratedWalletToken = prefs.getString(PrefsKey.walletToken);
    if (migratedWalletToken != null && migratedWalletToken.isNotEmpty) {
      await secureStorage.write(
        key: PrefsKey.walletToken,
        value: migratedWalletToken,
      );
      await prefs.remove(PrefsKey.walletToken);
    }

    final migratedMarketToken = prefs.getString(PrefsKey.marketToken);
    if (migratedMarketToken != null && migratedMarketToken.isNotEmpty) {
      await secureStorage.write(
        key: PrefsKey.marketToken,
        value: migratedMarketToken,
      );
      await prefs.remove(PrefsKey.marketToken);
    }

    final migratedStoriesToken = prefs.getString(PrefsKey.storiesToken);
    if (migratedStoriesToken != null && migratedStoriesToken.isNotEmpty) {
      await secureStorage.write(
        key: PrefsKey.storiesToken,
        value: migratedStoriesToken,
      );
      await prefs.remove(PrefsKey.storiesToken);
    }

    final migratedTokenForComment = prefs.getString(PrefsKey.tokenForComment);
    if (migratedTokenForComment != null && migratedTokenForComment.isNotEmpty) {
      await secureStorage.write(
        key: PrefsKey.tokenForComment,
        value: migratedTokenForComment,
      );
      await prefs.remove(PrefsKey.tokenForComment);
    }

    final initialChatToken = await secureStorage.read(key: PrefsKey.chatToken);
    final initialWalletToken = await secureStorage.read(
      key: PrefsKey.walletToken,
    );
    final initialMarketToken = await secureStorage.read(
      key: PrefsKey.marketToken,
    );
    final initialStoriesToken = await secureStorage.read(
      key: PrefsKey.storiesToken,
    );
    final initialTokenForComment = await secureStorage.read(
      key: PrefsKey.tokenForComment,
    );
    return PrefsRepositoryImpl(
      prefs,
      secureStorage,
      initialChatToken: initialChatToken,
      initialWalletToken: initialWalletToken,
      initialMarketToken: initialMarketToken,
      initialStoriesToken: initialStoriesToken,
      initialTokenForComment: initialTokenForComment,
    );
  }

  @singleton
  Dio dio(BaseOptions option, Logger logger) {
    final dio = Dio(option);
    // dio.httpClientAdapter = Http2Adapter(
    //   ConnectionManager(idleTimeout: Duration(seconds: 15),proxyConnectedPredicate: (_,__)=> true),
    // );
    dio.interceptors.add(LoggerInterceptor());
    return dio;
  }
}

// @singleton
// SessionManager get sessionManager => SessionManager();

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
