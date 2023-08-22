// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: unnecessary_lambdas
// ignore_for_file: lines_longer_than_80_chars
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i7;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:logger/logger.dart' as _i18;
import 'package:shared_preferences/shared_preferences.dart' as _i28;

import '../../features/app/blocs/app_bloc/app_bloc.dart' as _i3;
import '../../features/app/blocs/sensitive_connectivity/sensitive_connectivity_bloc.dart'
    as _i27;
import '../../features/authentication/data/data_sources/auth_remote_datasource.dart'
    as _i4;
import '../../features/authentication/data/repositories/auth_repository_impl.dart'
    as _i6;
import '../../features/authentication/domain/repositories/auth_repository.dart'
    as _i5;
import '../../features/authentication/domain/use_cases/create_user_usecase.dart'
    as _i11;
import '../../features/authentication/domain/use_cases/delete_fcm_usecase.dart'
    as _i13;
import '../../features/authentication/domain/use_cases/login_usecase.dart'
    as _i19;
import '../../features/authentication/domain/use_cases/store_fcm_usecase.dart'
    as _i29;
import '../../features/authentication/presentation/manager/auth_bloc.dart'
    as _i31;
import '../../features/chat/data/data_sources/chat_remote_datasource.dart'
    as _i8;
import '../../features/chat/data/repositories/chat_repository_impl.dart'
    as _i10;
import '../../features/chat/domain/repositories/chat_repository.dart' as _i9;
import '../../features/chat/domain/use_cases/change_chat_property_usecase.dart'
    as _i32;
import '../../features/chat/domain/use_cases/delete_chat_usecase.dart' as _i12;
import '../../features/chat/domain/use_cases/get_contacts_usecase.dart' as _i14;
import '../../features/chat/domain/use_cases/get_messages_between_usecase.dart'
    as _i15;
import '../../features/chat/domain/use_cases/get_messages_for_chat_usecase.dart'
    as _i16;
import '../../features/chat/domain/use_cases/get_my_chats_usecase.dart' as _i17;
import '../../features/chat/domain/use_cases/read_all_messages_usecase.dart'
    as _i23;
import '../../features/chat/domain/use_cases/receive_message_usecase.dart'
    as _i24;
import '../../features/chat/domain/use_cases/save_contacts_usecase.dart'
    as _i25;
import '../../features/chat/domain/use_cases/send_message_usecase.dart' as _i26;
import '../../features/chat/domain/use_cases/upload_file_usecase.dart' as _i30;
import '../../features/chat/presentation/manager/chat_bloc.dart' as _i33;
import '../../features/chat/presentation/manager/preload_bloc/preloading_videos_bloc.dart'
    as _i21;
import '../../features/chat/presentation/utils/pusher_chat.dart' as _i22;
import '../domin/repositories/prefs_repository.dart' as _i20;
import 'di_container.dart' as _i34;

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
  gh.lazySingleton<_i3.AppBloc>(() => _i3.AppBloc());
  gh.factory<_i4.AuthRemoteDatasource>(() => _i4.AuthRemoteDatasource());
  gh.lazySingleton<_i5.AuthRepository>(
      () => _i6.AuthRepositoryImpl(gh<_i4.AuthRemoteDatasource>()));
  gh.factory<_i7.BaseOptions>(() => appModule.dioOption);
  gh.factory<_i8.ChatRemoteDataSource>(() => _i8.ChatRemoteDataSource());
  gh.lazySingleton<_i9.ChatRepository>(
      () => _i10.ChatRepositoryImpl(gh<_i8.ChatRemoteDataSource>()));
  gh.factory<_i11.CreateUserUseCase>(
      () => _i11.CreateUserUseCase(gh<_i9.ChatRepository>()));
  gh.factory<_i12.DeleteChatUseCase>(
      () => _i12.DeleteChatUseCase(gh<_i9.ChatRepository>()));
  gh.factory<_i13.DeleteFcmUseCase>(
      () => _i13.DeleteFcmUseCase(gh<_i5.AuthRepository>()));
  gh.factory<_i14.GetContactsUseCase>(
      () => _i14.GetContactsUseCase(gh<_i9.ChatRepository>()));
  gh.factory<_i15.GetMessagesBetweenUseCase>(
      () => _i15.GetMessagesBetweenUseCase(gh<_i9.ChatRepository>()));
  gh.factory<_i16.GetMessagesForChatUseCase>(
      () => _i16.GetMessagesForChatUseCase(gh<_i9.ChatRepository>()));
  gh.factory<_i17.GetMyChatsUseCase>(
      () => _i17.GetMyChatsUseCase(gh<_i9.ChatRepository>()));
  gh.singleton<_i18.Logger>(appModule.logger);
  gh.factory<_i19.LoginUseCase>(
      () => _i19.LoginUseCase(gh<_i5.AuthRepository>()));
  await gh.singletonAsync<_i20.PrefsRepository>(
    () => appModule.prefsRepository,
    preResolve: true,
  );
  gh.factory<_i21.PreloadingVideosBloc>(() => _i21.PreloadingVideosBloc());
  gh.lazySingleton<_i22.PusherChatService>(() => _i22.PusherChatService());
  gh.factory<_i23.ReadAllMessagesUseCase>(
      () => _i23.ReadAllMessagesUseCase(gh<_i9.ChatRepository>()));
  gh.factory<_i24.ReceiveMessageUseCase>(
      () => _i24.ReceiveMessageUseCase(gh<_i9.ChatRepository>()));
  gh.factory<_i25.SaveContactsUseCase>(
      () => _i25.SaveContactsUseCase(gh<_i9.ChatRepository>()));
  gh.factory<_i26.SendMessageUseCase>(
      () => _i26.SendMessageUseCase(gh<_i9.ChatRepository>()));
  gh.factory<_i27.SensitiveConnectivityBloc>(
      () => _i27.SensitiveConnectivityBloc());
  await gh.singletonAsync<_i28.SharedPreferences>(
    () => appModule.sharedPreferences,
    preResolve: true,
  );
  gh.factory<_i29.StoreFcmUseCase>(
      () => _i29.StoreFcmUseCase(gh<_i5.AuthRepository>()));
  gh.factory<_i30.UploadFileUseCase>(
      () => _i30.UploadFileUseCase(gh<_i9.ChatRepository>()));
  gh.factory<_i31.AuthBloc>(() => _i31.AuthBloc(
        gh<_i11.CreateUserUseCase>(),
        gh<_i19.LoginUseCase>(),
        gh<_i29.StoreFcmUseCase>(),
      ));
  gh.factory<_i32.ChangeChatPropertyUseCase>(
      () => _i32.ChangeChatPropertyUseCase(gh<_i9.ChatRepository>()));
  gh.lazySingleton<_i33.ChatBloc>(() => _i33.ChatBloc(
        gh<_i14.GetContactsUseCase>(),
        gh<_i17.GetMyChatsUseCase>(),
        gh<_i25.SaveContactsUseCase>(),
        gh<_i26.SendMessageUseCase>(),
        gh<_i15.GetMessagesBetweenUseCase>(),
        gh<_i30.UploadFileUseCase>(),
        gh<_i16.GetMessagesForChatUseCase>(),
        gh<_i12.DeleteChatUseCase>(),
        gh<_i32.ChangeChatPropertyUseCase>(),
        gh<_i23.ReadAllMessagesUseCase>(),
        gh<_i24.ReceiveMessageUseCase>(),
      ));
  gh.singleton<_i7.Dio>(appModule.dio(
    gh<_i7.BaseOptions>(),
    gh<_i18.Logger>(),
  ));
  return getIt;
}

class _$AppModule extends _i34.AppModule {}
