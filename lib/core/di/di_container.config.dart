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
import 'package:logger/logger.dart' as _i19;
import 'package:shared_preferences/shared_preferences.dart' as _i33;

import '../../features/app/blocs/app_bloc/app_bloc.dart' as _i3;
import '../../features/app/blocs/sensitive_connectivity/sensitive_connectivity_bloc.dart'
    as _i32;
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
import '../../features/authentication/domain/use_cases/get_customer_info_usecase.dart'
    as _i15;
import '../../features/authentication/domain/use_cases/login_to_chat_usecase.dart'
    as _i20;
import '../../features/authentication/domain/use_cases/login_to_market_usecase.dart'
    as _i21;
import '../../features/authentication/domain/use_cases/login_to_stories_usecase.dart'
    as _i22;
import '../../features/authentication/domain/use_cases/register_guest_usecase.dart'
    as _i28;
import '../../features/authentication/domain/use_cases/send_otp_usecase.dart'
    as _i31;
import '../../features/authentication/domain/use_cases/store_fcm_usecase.dart'
    as _i34;
import '../../features/authentication/domain/use_cases/update_name_usecase.dart'
    as _i38;
import '../../features/authentication/domain/use_cases/verify_guest_phone_usecase.dart'
    as _i40;
import '../../features/authentication/domain/use_cases/verify_otp_signin_usecase.dart'
    as _i41;
import '../../features/authentication/domain/use_cases/verify_otp_signup_usecase.dart'
    as _i42;
import '../../features/authentication/presentation/manager/auth_bloc.dart'
    as _i43;
import '../../features/chat/data/data_sources/chat_remote_datasource.dart'
    as _i8;
import '../../features/chat/data/repositories/chat_repository_impl.dart'
    as _i10;
import '../../features/chat/domain/repositories/chat_repository.dart' as _i9;
import '../../features/chat/domain/use_cases/change_chat_property_usecase.dart'
    as _i44;
import '../../features/chat/domain/use_cases/delete_chat_usecase.dart' as _i12;
import '../../features/chat/domain/use_cases/get_contacts_usecase.dart' as _i14;
import '../../features/chat/domain/use_cases/get_messages_between_usecase.dart'
    as _i16;
import '../../features/chat/domain/use_cases/get_messages_for_chat_usecase.dart'
    as _i17;
import '../../features/chat/domain/use_cases/get_my_chats_usecase.dart' as _i18;
import '../../features/chat/domain/use_cases/read_all_messages_usecase.dart'
    as _i26;
import '../../features/chat/domain/use_cases/receive_message_usecase.dart'
    as _i27;
import '../../features/chat/domain/use_cases/save_contacts_usecase.dart'
    as _i29;
import '../../features/chat/domain/use_cases/send_message_usecase.dart' as _i30;
import '../../features/chat/domain/use_cases/upload_file_usecase.dart' as _i39;
import '../../features/chat/presentation/manager/chat_bloc.dart' as _i45;
import '../../features/chat/presentation/manager/preload_bloc/preloading_videos_bloc.dart'
    as _i24;
import '../../features/chat/presentation/utils/pusher_chat.dart' as _i25;
import '../../features/story/data/data_source/story_data_source.dart' as _i35;
import '../../features/story/data/repository/story_repository_impl.dart'
    as _i37;
import '../../features/story/domain/repository/story_repository.dart' as _i36;
import '../../features/story/domain/useCases/get_stories_usecase.dart' as _i46;
import '../../features/story/domain/useCases/get_width_and_height_usecase.dart'
    as _i47;
import '../../features/story/presentation/bloc/story_bloc.dart' as _i48;
import '../domin/repositories/prefs_repository.dart' as _i23;
import 'di_container.dart' as _i49;

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
  gh.factory<_i15.GetCustomerInfoUseCase>(
      () => _i15.GetCustomerInfoUseCase(gh<_i5.AuthRepository>()));
  gh.factory<_i16.GetMessagesBetweenUseCase>(
      () => _i16.GetMessagesBetweenUseCase(gh<_i9.ChatRepository>()));
  gh.factory<_i17.GetMessagesForChatUseCase>(
      () => _i17.GetMessagesForChatUseCase(gh<_i9.ChatRepository>()));
  gh.factory<_i18.GetMyChatsUseCase>(
      () => _i18.GetMyChatsUseCase(gh<_i9.ChatRepository>()));
  gh.singleton<_i19.Logger>(appModule.logger);
  gh.factory<_i20.LoginToChatUseCase>(
      () => _i20.LoginToChatUseCase(gh<_i5.AuthRepository>()));
  gh.factory<_i21.LoginToMarketUseCase>(
      () => _i21.LoginToMarketUseCase(gh<_i5.AuthRepository>()));
  gh.factory<_i22.LoginToStoriesUseCase>(
      () => _i22.LoginToStoriesUseCase(gh<_i5.AuthRepository>()));
  await gh.singletonAsync<_i23.PrefsRepository>(
    () => appModule.prefsRepository,
    preResolve: true,
  );
  gh.factory<_i24.PreloadingVideosBloc>(() => _i24.PreloadingVideosBloc());
  gh.lazySingleton<_i25.PusherChatService>(() => _i25.PusherChatService());
  gh.factory<_i26.ReadAllMessagesUseCase>(
      () => _i26.ReadAllMessagesUseCase(gh<_i9.ChatRepository>()));
  gh.factory<_i27.ReceiveMessageUseCase>(
      () => _i27.ReceiveMessageUseCase(gh<_i9.ChatRepository>()));
  gh.factory<_i28.RegisterGuestUseCase>(
      () => _i28.RegisterGuestUseCase(gh<_i5.AuthRepository>()));
  gh.factory<_i29.SaveContactsUseCase>(
      () => _i29.SaveContactsUseCase(gh<_i9.ChatRepository>()));
  gh.factory<_i30.SendMessageUseCase>(
      () => _i30.SendMessageUseCase(gh<_i9.ChatRepository>()));
  gh.factory<_i31.SendOtpUseCase>(
      () => _i31.SendOtpUseCase(gh<_i5.AuthRepository>()));
  gh.factory<_i32.SensitiveConnectivityBloc>(
      () => _i32.SensitiveConnectivityBloc());
  await gh.singletonAsync<_i33.SharedPreferences>(
    () => appModule.sharedPreferences,
    preResolve: true,
  );
  gh.factory<_i34.StoreFcmUseCase>(
      () => _i34.StoreFcmUseCase(gh<_i5.AuthRepository>()));
  gh.factory<_i35.StoriesDataSource>(() => _i35.StoriesDataSource());
  gh.lazySingleton<_i36.StoryRepository>(
      () => _i37.StoryRepositoryImpl(gh<_i35.StoriesDataSource>()));
  gh.factory<_i38.UpdateNameUseCase>(
      () => _i38.UpdateNameUseCase(gh<_i5.AuthRepository>()));
  gh.factory<_i39.UploadFileUseCase>(
      () => _i39.UploadFileUseCase(gh<_i9.ChatRepository>()));
  gh.factory<_i40.VerifyGuestPhoneUseCase>(
      () => _i40.VerifyGuestPhoneUseCase(gh<_i5.AuthRepository>()));
  gh.factory<_i41.VerifyOtpSignInUseCase>(
      () => _i41.VerifyOtpSignInUseCase(gh<_i5.AuthRepository>()));
  gh.factory<_i42.VerifyOtpSignUpUseCase>(
      () => _i42.VerifyOtpSignUpUseCase(gh<_i5.AuthRepository>()));
  gh.factory<_i43.AuthBloc>(() => _i43.AuthBloc(
        gh<_i11.CreateUserUseCase>(),
        gh<_i20.LoginToChatUseCase>(),
        gh<_i21.LoginToMarketUseCase>(),
        gh<_i22.LoginToStoriesUseCase>(),
        gh<_i34.StoreFcmUseCase>(),
        gh<_i38.UpdateNameUseCase>(),
        gh<_i28.RegisterGuestUseCase>(),
        gh<_i31.SendOtpUseCase>(),
        gh<_i15.GetCustomerInfoUseCase>(),
        gh<_i40.VerifyGuestPhoneUseCase>(),
        gh<_i41.VerifyOtpSignInUseCase>(),
        gh<_i42.VerifyOtpSignUpUseCase>(),
      ));
  gh.factory<_i44.ChangeChatPropertyUseCase>(
      () => _i44.ChangeChatPropertyUseCase(gh<_i9.ChatRepository>()));
  gh.lazySingleton<_i45.ChatBloc>(() => _i45.ChatBloc(
        gh<_i14.GetContactsUseCase>(),
        gh<_i18.GetMyChatsUseCase>(),
        gh<_i29.SaveContactsUseCase>(),
        gh<_i30.SendMessageUseCase>(),
        gh<_i16.GetMessagesBetweenUseCase>(),
        gh<_i39.UploadFileUseCase>(),
        gh<_i17.GetMessagesForChatUseCase>(),
        gh<_i12.DeleteChatUseCase>(),
        gh<_i44.ChangeChatPropertyUseCase>(),
        gh<_i26.ReadAllMessagesUseCase>(),
        gh<_i27.ReceiveMessageUseCase>(),
      ));
  gh.singleton<_i7.Dio>(appModule.dio(
    gh<_i7.BaseOptions>(),
    gh<_i19.Logger>(),
  ));
  gh.factory<_i46.GetStoryUseCase>(
      () => _i46.GetStoryUseCase(gh<_i36.StoryRepository>()));
  gh.factory<_i47.GetWidthAndHeightUseCase>(
      () => _i47.GetWidthAndHeightUseCase(gh<_i36.StoryRepository>()));
  gh.lazySingleton<_i48.StoryBloc>(() => _i48.StoryBloc(
        gh<_i46.GetStoryUseCase>(),
        gh<_i47.GetWidthAndHeightUseCase>(),
      ));
  return getIt;
}

class _$AppModule extends _i49.AppModule {}
