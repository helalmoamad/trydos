// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: unnecessary_lambdas
// ignore_for_file: lines_longer_than_80_chars
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i6;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:logger/logger.dart' as _i13;
import 'package:shared_preferences/shared_preferences.dart' as _i19;

import '../../features/app/blocs/sensitive_connectivity/sensitive_connectivity_bloc.dart'
    as _i18;
import '../../features/authentication/data/data_sources/auth_remote_datasource.dart'
    as _i3;
import '../../features/authentication/data/repositories/auth_repository_impl.dart'
    as _i5;
import '../../features/authentication/domain/repositories/auth_repository.dart'
    as _i4;
import '../../features/authentication/domain/use_cases/create_user_usecase.dart'
    as _i10;
import '../../features/authentication/domain/use_cases/login_usecase.dart'
    as _i14;
import '../../features/authentication/presentation/manager/auth_bloc.dart'
    as _i21;
import '../../features/chat/data/data_sources/chat_remote_datasource.dart'
    as _i7;
import '../../features/chat/data/repositories/chat_repository_impl.dart' as _i9;
import '../../features/chat/domain/repositories/chat_repository.dart' as _i8;
import '../../features/chat/domain/use_cases/get_contacts_usecase.dart' as _i11;
import '../../features/chat/domain/use_cases/get_my_chats_usecase.dart' as _i12;
import '../../features/chat/domain/use_cases/save_contacts_usecase.dart'
    as _i16;
import '../../features/chat/domain/use_cases/send_message_usecase.dart' as _i17;
import '../../features/chat/domain/use_cases/upload_file_usecase.dart' as _i20;
import '../../features/chat/presentation/manager/chat_bloc.dart' as _i22;
import '../domin/repositories/prefs_repository.dart' as _i15;
import 'di_container.dart' as _i23;

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
  gh.factory<_i3.AuthRemoteDatasource>(() => _i3.AuthRemoteDatasource());
  gh.lazySingleton<_i4.AuthRepository>(
      () => _i5.AuthRepositoryImpl(gh<_i3.AuthRemoteDatasource>()));
  gh.factory<_i6.BaseOptions>(() => appModule.dioOption);
  gh.factory<_i7.ChatRemoteDataSource>(() => _i7.ChatRemoteDataSource());
  gh.lazySingleton<_i8.ChatRepository>(
      () => _i9.ChatRepositoryImpl(gh<_i7.ChatRemoteDataSource>()));
  gh.factory<_i10.CreateUserUseCase>(
      () => _i10.CreateUserUseCase(gh<_i8.ChatRepository>()));
  gh.factory<_i11.GetContactsUseCase>(
      () => _i11.GetContactsUseCase(gh<_i8.ChatRepository>()));
  gh.factory<_i12.GetMyChatsUseCase>(
      () => _i12.GetMyChatsUseCase(gh<_i8.ChatRepository>()));
  gh.singleton<_i13.Logger>(appModule.logger);
  gh.factory<_i14.LoginUseCase>(
      () => _i14.LoginUseCase(gh<_i4.AuthRepository>()));
  await gh.singletonAsync<_i15.PrefsRepository>(
    () => appModule.prefsRepository,
    preResolve: true,
  );
  gh.factory<_i16.SaveContactsUseCase>(
      () => _i16.SaveContactsUseCase(gh<_i8.ChatRepository>()));
  gh.factory<_i17.SendMessageUseCase>(
      () => _i17.SendMessageUseCase(gh<_i8.ChatRepository>()));
  gh.factory<_i18.SensitiveConnectivityBloc>(
      () => _i18.SensitiveConnectivityBloc());
  await gh.singletonAsync<_i19.SharedPreferences>(
    () => appModule.sharedPreferences,
    preResolve: true,
  );
  gh.factory<_i20.UploadFileUseCase>(
      () => _i20.UploadFileUseCase(gh<_i8.ChatRepository>()));
  gh.factory<_i21.AuthBloc>(() => _i21.AuthBloc(
        gh<_i10.CreateUserUseCase>(),
        gh<_i14.LoginUseCase>(),
      ));
  gh.factory<_i22.ChatBloc>(() => _i22.ChatBloc(
        gh<_i11.GetContactsUseCase>(),
        gh<_i12.GetMyChatsUseCase>(),
        gh<_i16.SaveContactsUseCase>(),
        gh<_i17.SendMessageUseCase>(),
        gh<_i20.UploadFileUseCase>(),
      ));
  gh.singleton<_i6.Dio>(appModule.dio(
    gh<_i6.BaseOptions>(),
    gh<_i13.Logger>(),
  ));
  return getIt;
}

class _$AppModule extends _i23.AppModule {}
