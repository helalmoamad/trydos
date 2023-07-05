// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: unnecessary_lambdas
// ignore_for_file: lines_longer_than_80_chars
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i3;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:logger/logger.dart' as _i4;
import 'package:shared_preferences/shared_preferences.dart' as _i7;

import '../../features/app/blocs/sensitive_connectivity/sensitive_connectivity_bloc.dart'
    as _i6;
import '../domin/repositories/prefs_repository.dart' as _i5;
import 'di_container.dart' as _i8;

// ignore_for_file: unnecessary_lambdas
// ignore_for_file: lines_longer_than_80_chars
// initializes the registration of main-scope dependencies inside of GetIt
Future<_i1.GetIt> $initGetIt(
  _i1.GetIt getIt, {
  String? environment,
  _i2.EnvironmentFilter? environmentFilter,
}) async {
  final gh = _i2.GetItHelper(
    getIt,
    environment,
    environmentFilter,
  );
  final appModule = _$AppModule();
  gh.factory<_i3.BaseOptions>(() => appModule.dioOption);
  gh.singleton<_i4.Logger>(appModule.logger);
  await gh.singletonAsync<_i5.PrefsRepository>(
    () => appModule.prefsRepository,
    preResolve: true,
  );
  gh.factory<_i6.SensitiveConnectivityBloc>(
      () => _i6.SensitiveConnectivityBloc());
  await gh.singletonAsync<_i7.SharedPreferences>(
    () => appModule.sharedPreferences,
    preResolve: true,
  );
  gh.singleton<_i3.Dio>(appModule.dio(
    gh<_i3.BaseOptions>(),
    gh<_i4.Logger>(),
  ));
  return getIt;
}

class _$AppModule extends _i8.AppModule {}
