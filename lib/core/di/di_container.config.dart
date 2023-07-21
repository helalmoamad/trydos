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
import 'package:logger/logger.dart' as _i14;
import 'package:shared_preferences/shared_preferences.dart' as _i22;

import '../../features/app/blocs/sensitive_connectivity/sensitive_connectivity_bloc.dart'
    as _i21;
import '../../features/authentication/data/data_sources/auth_remote_datasource.dart'
    as _i3;
import '../../features/authentication/data/repositories/auth_repository_impl.dart'
    as _i5;
import '../../features/authentication/domain/repositories/auth_repository.dart'
    as _i4;
import '../../features/authentication/domain/use_cases/create_user_usecase.dart'
    as _i10;
import '../../features/authentication/domain/use_cases/delete_fcm_usecase.dart'
    as _i11;
import '../../features/authentication/domain/use_cases/login_usecase.dart'
    as _i15;
import '../../features/authentication/domain/use_cases/store_fcm_usecase.dart'
    as _i23;
import '../../features/authentication/presentation/manager/auth_bloc.dart'
    as _i25;
import '../../features/chat/data/data_sources/chat_remote_datasource.dart'
    as _i7;
import '../../features/chat/data/repositories/chat_repository_impl.dart' as _i9;
import '../../features/chat/domain/repositories/chat_repository.dart' as _i8;
import '../../features/chat/domain/use_cases/get_contacts_usecase.dart' as _i12;
import '../../features/chat/domain/use_cases/get_my_chats_usecase.dart' as _i13;
import '../../features/chat/domain/use_cases/read_all_messages_usecase.dart'
    as _i17;
import '../../features/chat/domain/use_cases/receive_message_usecase.dart'
    as _i18;
import '../../features/chat/domain/use_cases/save_contacts_usecase.dart'
    as _i19;
import '../../features/chat/domain/use_cases/send_message_usecase.dart' as _i20;
import '../../features/chat/domain/use_cases/upload_file_usecase.dart' as _i24;
import '../../features/chat/presentation/manager/chat_bloc.dart' as _i26;
import '../domin/repositories/prefs_repository.dart' as _i16;
import 'di_container.dart' as _i27;

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
  gh.factory<_i11.DeleteFcmUseCase>(
      () => _i11.DeleteFcmUseCase(gh<_i4.AuthRepository>()));
  gh.factory<_i12.GetContactsUseCase>(
      () => _i12.GetContactsUseCase(gh<_i8.ChatRepository>()));
  gh.factory<_i13.GetMyChatsUseCase>(
      () => _i13.GetMyChatsUseCase(gh<_i8.ChatRepository>()));
  gh.singleton<_i14.Logger>(appModule.logger);
  gh.factory<_i15.LoginUseCase>(
      () => _i15.LoginUseCase(gh<_i4.AuthRepository>()));
  await gh.singletonAsync<_i16.PrefsRepository>(
    () => appModule.prefsRepository,
    preResolve: true,
  );
  gh.factory<_i17.ReadAllMessagesUseCase>(
      () => _i17.ReadAllMessagesUseCase(gh<_i8.ChatRepository>()));
  gh.factory<_i18.ReceiveMessageUseCase>(
      () => _i18.ReceiveMessageUseCase(gh<_i8.ChatRepository>()));
  gh.factory<_i19.SaveContactsUseCase>(
      () => _i19.SaveContactsUseCase(gh<_i8.ChatRepository>()));
  gh.factory<_i20.SendMessageUseCase>(
      () => _i20.SendMessageUseCase(gh<_i8.ChatRepository>()));
  gh.factory<_i21.SensitiveConnectivityBloc>(
      () => _i21.SensitiveConnectivityBloc());
  await gh.singletonAsync<_i22.SharedPreferences>(
    () => appModule.sharedPreferences,
    preResolve: true,
  );
  gh.factory<_i23.StoreFcmUseCase>(
      () => _i23.StoreFcmUseCase(gh<_i4.AuthRepository>()));
  gh.factory<_i24.UploadFileUseCase>(
      () => _i24.UploadFileUseCase(gh<_i8.ChatRepository>()));
  gh.factory<_i25.AuthBloc>(() => _i25.AuthBloc(
        gh<_i10.CreateUserUseCase>(),
        gh<_i15.LoginUseCase>(),
        gh<_i23.StoreFcmUseCase>(),
      ));
  gh.factory<_i26.ChatBloc>(() => _i26.ChatBloc(
        gh<_i12.GetContactsUseCase>(),
        gh<_i13.GetMyChatsUseCase>(),
        gh<_i19.SaveContactsUseCase>(),
        gh<_i20.SendMessageUseCase>(),
        gh<_i24.UploadFileUseCase>(),
        gh<_i17.ReadAllMessagesUseCase>(),
        gh<_i18.ReceiveMessageUseCase>(),
      ));
  gh.singleton<_i6.Dio>(appModule.dio(
    gh<_i6.BaseOptions>(),
    gh<_i14.Logger>(),
  ));
  return getIt;
}

class _$AppModule extends _i27.AppModule {}
