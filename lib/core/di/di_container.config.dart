// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i7;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:logger/logger.dart' as _i26;
import 'package:shared_preferences/shared_preferences.dart' as _i40;

import '../../features/app/blocs/app_bloc/app_bloc.dart' as _i3;
import '../../features/app/blocs/sensitive_connectivity/sensitive_connectivity_bloc.dart'
    as _i39;
import '../../features/authentication/data/data_sources/auth_remote_datasource.dart'
    as _i4;
import '../../features/authentication/data/repositories/auth_repository_impl.dart'
    as _i6;
import '../../features/authentication/domain/repositories/auth_repository.dart'
    as _i5;
import '../../features/authentication/domain/use_cases/create_user_usecase.dart'
    as _i14;
import '../../features/authentication/domain/use_cases/delete_fcm_usecase.dart'
    as _i16;
import '../../features/authentication/domain/use_cases/get_customer_info_usecase.dart'
    as _i18;
import '../../features/authentication/domain/use_cases/get_user_country_usecase.dart'
    as _i22;
import '../../features/authentication/domain/use_cases/login_to_chat_usecase.dart'
    as _i27;
import '../../features/authentication/domain/use_cases/login_to_market_usecase.dart'
    as _i28;
import '../../features/authentication/domain/use_cases/login_to_stories_usecase.dart'
    as _i29;
import '../../features/authentication/domain/use_cases/register_guest_usecase.dart'
    as _i35;
import '../../features/authentication/domain/use_cases/send_otp_usecase.dart'
    as _i38;
import '../../features/authentication/domain/use_cases/store_fcm_usecase.dart'
    as _i41;
import '../../features/authentication/domain/use_cases/update_name_usecase.dart'
    as _i45;
import '../../features/authentication/domain/use_cases/verify_guest_phone_usecase.dart'
    as _i49;
import '../../features/authentication/domain/use_cases/verify_otp_signin_usecase.dart'
    as _i50;
import '../../features/authentication/domain/use_cases/verify_otp_signup_usecase.dart'
    as _i51;
import '../../features/authentication/presentation/manager/auth_bloc.dart'
    as _i52;
import '../../features/chat/data/data_sources/chat_remote_datasource.dart'
    as _i8;
import '../../features/chat/data/repositories/chat_repository_impl.dart'
    as _i10;
import '../../features/chat/domain/repositories/chat_repository.dart' as _i9;
import '../../features/chat/domain/use_cases/change_chat_property_usecase.dart'
    as _i53;
import '../../features/chat/domain/use_cases/delete_chat_usecase.dart' as _i15;
import '../../features/chat/domain/use_cases/get_contacts_usecase.dart' as _i17;
import '../../features/chat/domain/use_cases/get_messages_between_usecase.dart'
    as _i19;
import '../../features/chat/domain/use_cases/get_messages_for_chat_usecase.dart'
    as _i20;
import '../../features/chat/domain/use_cases/get_my_chats_usecase.dart' as _i21;
import '../../features/chat/domain/use_cases/read_all_messages_usecase.dart'
    as _i33;
import '../../features/chat/domain/use_cases/receive_message_usecase.dart'
    as _i34;
import '../../features/chat/domain/use_cases/save_contacts_usecase.dart'
    as _i36;
import '../../features/chat/domain/use_cases/send_message_usecase.dart' as _i37;
import '../../features/chat/domain/use_cases/upload_file_usecase.dart' as _i47;
import '../../features/chat/presentation/manager/chat_bloc.dart' as _i54;
import '../../features/chat/presentation/manager/preload_bloc/preloading_videos_bloc.dart'
    as _i31;
import '../../features/chat/presentation/utils/pusher_chat.dart' as _i32;
import '../../features/home/data/data_sources/home_remote_data_source.dart'
    as _i23;
import '../../features/home/data/repositories/home_repository_implementation.dart'
    as _i25;
import '../../features/home/domain/repositories/home_repository.dart' as _i24;
import '../../features/home/domain/use_cases/get_home_sections_usecase.dart'
    as _i55;
import '../../features/home/domain/use_cases/get_main_categories_usecase.dart'
    as _i56;
import '../../features/home/domain/use_cases/get_starting_settings_usecase.dart'
    as _i57;
import '../../features/home/presentation/manager/home_bloc.dart' as _i60;
import '../../features/story/data/data_source/story_data_source.dart' as _i42;
import '../../features/story/data/repository/story_repository_impl.dart'
    as _i44;
import '../../features/story/domain/repository/story_repository.dart' as _i43;
import '../../features/story/domain/useCases/get_stories_usecase.dart' as _i58;
import '../../features/story/domain/useCases/get_width_and_height_usecase.dart'
    as _i59;
import '../../features/story/domain/useCases/upload_story_usecase.dart' as _i48;
import '../../features/story/presentation/bloc/story_bloc.dart' as _i61;
import '../data/data_source/common_use_repo_data_source.dart' as _i11;
import '../data/repository/common_use_repository_impl.dart' as _i13;
import '../domin/repositories/common_use_repository.dart' as _i12;
import '../domin/repositories/prefs_repository.dart' as _i30;
import '../domin/usecases/upload_file_cloudinary_usecase.dart' as _i46;
import 'di_container.dart' as _i62;

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
  gh.factory<_i11.CommonUseRemoteDataSource>(
      () => _i11.CommonUseRemoteDataSource());
  gh.lazySingleton<_i12.CommonUseRepository>(
      () => _i13.CommonUseRepositoryImpl(gh<_i11.CommonUseRemoteDataSource>()));
  gh.factory<_i14.CreateUserUseCase>(
      () => _i14.CreateUserUseCase(gh<_i9.ChatRepository>()));
  gh.factory<_i15.DeleteChatUseCase>(
      () => _i15.DeleteChatUseCase(gh<_i9.ChatRepository>()));
  gh.factory<_i16.DeleteFcmUseCase>(
      () => _i16.DeleteFcmUseCase(gh<_i5.AuthRepository>()));
  gh.factory<_i17.GetContactsUseCase>(
      () => _i17.GetContactsUseCase(gh<_i9.ChatRepository>()));
  gh.factory<_i18.GetCustomerInfoUseCase>(
      () => _i18.GetCustomerInfoUseCase(gh<_i5.AuthRepository>()));
  gh.factory<_i19.GetMessagesBetweenUseCase>(
      () => _i19.GetMessagesBetweenUseCase(gh<_i9.ChatRepository>()));
  gh.factory<_i20.GetMessagesForChatUseCase>(
      () => _i20.GetMessagesForChatUseCase(gh<_i9.ChatRepository>()));
  gh.factory<_i21.GetMyChatsUseCase>(
      () => _i21.GetMyChatsUseCase(gh<_i9.ChatRepository>()));
  gh.factory<_i22.GetUserCountryUseCase>(
      () => _i22.GetUserCountryUseCase(gh<_i5.AuthRepository>()));
  gh.factory<_i23.HomeRemoteDatasource>(() => _i23.HomeRemoteDatasource());
  gh.lazySingleton<_i24.HomeRepository>(
      () => _i25.HomeRepositoryImpl(gh<_i23.HomeRemoteDatasource>()));
  gh.singleton<_i26.Logger>(appModule.logger);
  gh.factory<_i27.LoginToChatUseCase>(
      () => _i27.LoginToChatUseCase(gh<_i5.AuthRepository>()));
  gh.factory<_i28.LoginToMarketUseCase>(
      () => _i28.LoginToMarketUseCase(gh<_i5.AuthRepository>()));
  gh.factory<_i29.LoginToStoriesUseCase>(
      () => _i29.LoginToStoriesUseCase(gh<_i5.AuthRepository>()));
  await gh.singletonAsync<_i30.PrefsRepository>(
    () => appModule.prefsRepository,
    preResolve: true,
  );
  gh.factory<_i31.PreloadingVideosBloc>(() => _i31.PreloadingVideosBloc());
  gh.lazySingleton<_i32.PusherChatService>(() => _i32.PusherChatService());
  gh.factory<_i33.ReadAllMessagesUseCase>(
      () => _i33.ReadAllMessagesUseCase(gh<_i9.ChatRepository>()));
  gh.factory<_i34.ReceiveMessageUseCase>(
      () => _i34.ReceiveMessageUseCase(gh<_i9.ChatRepository>()));
  gh.factory<_i35.RegisterGuestUseCase>(
      () => _i35.RegisterGuestUseCase(gh<_i5.AuthRepository>()));
  gh.factory<_i36.SaveContactsUseCase>(
      () => _i36.SaveContactsUseCase(gh<_i9.ChatRepository>()));
  gh.factory<_i37.SendMessageUseCase>(
      () => _i37.SendMessageUseCase(gh<_i9.ChatRepository>()));
  gh.factory<_i38.SendOtpUseCase>(
      () => _i38.SendOtpUseCase(gh<_i5.AuthRepository>()));
  gh.factory<_i39.SensitiveConnectivityBloc>(
      () => _i39.SensitiveConnectivityBloc());
  await gh.singletonAsync<_i40.SharedPreferences>(
    () => appModule.sharedPreferences,
    preResolve: true,
  );
  gh.factory<_i41.StoreFcmUseCase>(
      () => _i41.StoreFcmUseCase(gh<_i5.AuthRepository>()));
  gh.factory<_i42.StoriesDataSource>(() => _i42.StoriesDataSource());
  gh.lazySingleton<_i43.StoryRepository>(
      () => _i44.StoryRepositoryImpl(gh<_i42.StoriesDataSource>()));
  gh.factory<_i45.UpdateNameUseCase>(
      () => _i45.UpdateNameUseCase(gh<_i5.AuthRepository>()));
  gh.factory<_i46.UploadFileCloudinaryUseCase>(
      () => _i46.UploadFileCloudinaryUseCase(gh<_i12.CommonUseRepository>()));
  gh.factory<_i47.UploadFileUseCase>(
      () => _i47.UploadFileUseCase(gh<_i9.ChatRepository>()));
  gh.factory<_i48.UploadStoryUseCase>(
      () => _i48.UploadStoryUseCase(gh<_i43.StoryRepository>()));
  gh.factory<_i49.VerifyGuestPhoneUseCase>(
      () => _i49.VerifyGuestPhoneUseCase(gh<_i5.AuthRepository>()));
  gh.factory<_i50.VerifyOtpSignInUseCase>(
      () => _i50.VerifyOtpSignInUseCase(gh<_i5.AuthRepository>()));
  gh.factory<_i51.VerifyOtpSignUpUseCase>(
      () => _i51.VerifyOtpSignUpUseCase(gh<_i5.AuthRepository>()));
  gh.factory<_i52.AuthBloc>(() => _i52.AuthBloc(
        gh<_i14.CreateUserUseCase>(),
        gh<_i27.LoginToChatUseCase>(),
        gh<_i28.LoginToMarketUseCase>(),
        gh<_i29.LoginToStoriesUseCase>(),
        gh<_i41.StoreFcmUseCase>(),
        gh<_i45.UpdateNameUseCase>(),
        gh<_i35.RegisterGuestUseCase>(),
        gh<_i38.SendOtpUseCase>(),
        gh<_i18.GetCustomerInfoUseCase>(),
        gh<_i49.VerifyGuestPhoneUseCase>(),
        gh<_i50.VerifyOtpSignInUseCase>(),
        gh<_i22.GetUserCountryUseCase>(),
        gh<_i51.VerifyOtpSignUpUseCase>(),
      ));
  gh.factory<_i53.ChangeChatPropertyUseCase>(
      () => _i53.ChangeChatPropertyUseCase(gh<_i9.ChatRepository>()));
  gh.lazySingleton<_i54.ChatBloc>(() => _i54.ChatBloc(
        gh<_i17.GetContactsUseCase>(),
        gh<_i21.GetMyChatsUseCase>(),
        gh<_i36.SaveContactsUseCase>(),
        gh<_i37.SendMessageUseCase>(),
        gh<_i19.GetMessagesBetweenUseCase>(),
        gh<_i46.UploadFileCloudinaryUseCase>(),
        gh<_i20.GetMessagesForChatUseCase>(),
        gh<_i15.DeleteChatUseCase>(),
        gh<_i53.ChangeChatPropertyUseCase>(),
        gh<_i33.ReadAllMessagesUseCase>(),
        gh<_i34.ReceiveMessageUseCase>(),
      ));
  gh.singleton<_i7.Dio>(appModule.dio(
    gh<_i7.BaseOptions>(),
    gh<_i26.Logger>(),
  ));
  gh.factory<_i55.GetHomeSectionsUseCase>(
      () => _i55.GetHomeSectionsUseCase(gh<_i24.HomeRepository>()));
  gh.factory<_i56.GetMainCategoriesUseCase>(
      () => _i56.GetMainCategoriesUseCase(gh<_i24.HomeRepository>()));
  gh.factory<_i57.GetStartingSettingsUseCase>(
      () => _i57.GetStartingSettingsUseCase(gh<_i24.HomeRepository>()));
  gh.factory<_i58.GetStoryUseCase>(
      () => _i58.GetStoryUseCase(gh<_i43.StoryRepository>()));
  gh.factory<_i59.GetWidthAndHeightUseCase>(
      () => _i59.GetWidthAndHeightUseCase(gh<_i43.StoryRepository>()));
  gh.lazySingleton<_i60.HomeBloc>(() => _i60.HomeBloc(
        gh<_i55.GetHomeSectionsUseCase>(),
        gh<_i56.GetMainCategoriesUseCase>(),
        gh<_i57.GetStartingSettingsUseCase>(),
      ));
  gh.lazySingleton<_i61.StoryBloc>(() => _i61.StoryBloc(
        gh<_i46.UploadFileCloudinaryUseCase>(),
        gh<_i58.GetStoryUseCase>(),
        gh<_i59.GetWidthAndHeightUseCase>(),
        gh<_i48.UploadStoryUseCase>(),
      ));
  return getIt;
}

class _$AppModule extends _i62.AppModule {}
