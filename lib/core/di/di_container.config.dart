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
import 'package:logger/logger.dart' as _i35;
import 'package:shared_preferences/shared_preferences.dart' as _i50;

import '../../features/app/blocs/app_bloc/app_bloc.dart' as _i3;
import '../../features/app/blocs/sensitive_connectivity/sensitive_connectivity_bloc.dart'
    as _i49;
import '../../features/authentication/data/data_sources/auth_remote_datasource.dart'
    as _i4;
import '../../features/authentication/data/repositories/auth_repository_impl.dart'
    as _i6;
import '../../features/authentication/domain/repositories/auth_repository.dart'
    as _i5;
import '../../features/authentication/domain/use_cases/create_user_usecase.dart'
    as _i17;
import '../../features/authentication/domain/use_cases/delete_fcm_usecase.dart'
    as _i19;
import '../../features/authentication/domain/use_cases/get_customer_info_usecase.dart'
    as _i23;
import '../../features/authentication/domain/use_cases/get_user_country_usecase.dart'
    as _i30;
import '../../features/authentication/domain/use_cases/login_to_chat_usecase.dart'
    as _i36;
import '../../features/authentication/domain/use_cases/login_to_market_usecase.dart'
    as _i37;
import '../../features/authentication/domain/use_cases/login_to_stories_usecase.dart'
    as _i38;
import '../../features/authentication/domain/use_cases/register_guest_usecase.dart'
    as _i44;
import '../../features/authentication/domain/use_cases/send_otp_usecase.dart'
    as _i48;
import '../../features/authentication/domain/use_cases/store_fcm_usecase.dart'
    as _i51;
import '../../features/authentication/domain/use_cases/update_name_usecase.dart'
    as _i55;
import '../../features/authentication/domain/use_cases/verify_guest_phone_usecase.dart'
    as _i59;
import '../../features/authentication/domain/use_cases/verify_otp_signin_usecase.dart'
    as _i60;
import '../../features/authentication/domain/use_cases/verify_otp_signup_usecase.dart'
    as _i61;
import '../../features/authentication/presentation/manager/auth_bloc.dart'
    as _i65;
import '../../features/calls/data/data_source/calls_remote_data_source_model.dart'
    as _i8;
import '../../features/calls/data/repositories/calls_repository_impl.dart'
    as _i10;
import '../../features/calls/domain/repositories/calls_repository.dart' as _i9;
import '../../features/calls/domain/useCase/answer_call_usecase.dart' as _i64;
import '../../features/calls/domain/useCase/delete_Message.dart' as _i20;
import '../../features/calls/domain/useCase/get_agora_token_use_case.dart'
    as _i21;
import '../../features/calls/domain/useCase/get_missed_call_count.dart' as _i27;
import '../../features/calls/domain/useCase/get_my_calls.dart' as _i28;
import '../../features/calls/domain/useCase/make_call_usecase.dart' as _i39;
import '../../features/calls/domain/useCase/reject_call_usecase.dart' as _i45;
import '../../features/calls/domain/useCase/watch_missed_call.dart' as _i62;
import '../../features/calls/presentation/bloc/calls_bloc.dart' as _i66;
import '../../features/chat/data/data_sources/chat_remote_datasource.dart'
    as _i11;
import '../../features/chat/data/repositories/chat_repository_impl.dart'
    as _i13;
import '../../features/chat/domain/repositories/chat_repository.dart' as _i12;
import '../../features/chat/domain/use_cases/change_chat_property_usecase.dart'
    as _i67;
import '../../features/chat/domain/use_cases/delete_chat_usecase.dart' as _i18;
import '../../features/chat/domain/use_cases/get_contacts_usecase.dart' as _i22;
import '../../features/chat/domain/use_cases/get_image_width_and_height_usecase.dart'
    as _i31;
import '../../features/chat/domain/use_cases/get_media_count_usecase.dart'
    as _i24;
import '../../features/chat/domain/use_cases/get_messages_between_usecase.dart'
    as _i25;
import '../../features/chat/domain/use_cases/get_messages_for_chat_usecase.dart'
    as _i26;
import '../../features/chat/domain/use_cases/get_my_chats_usecase.dart' as _i29;
import '../../features/chat/domain/use_cases/read_all_messages_usecase.dart'
    as _i42;
import '../../features/chat/domain/use_cases/receive_message_usecase.dart'
    as _i43;
import '../../features/chat/domain/use_cases/save_contacts_usecase.dart'
    as _i46;
import '../../features/chat/domain/use_cases/send_message_usecase.dart' as _i47;
import '../../features/chat/domain/use_cases/upload_file_usecase.dart' as _i57;
import '../../features/chat/presentation/manager/chat_bloc.dart' as _i68;
import '../../features/chat/presentation/manager/preload_bloc/preloading_videos_bloc.dart'
    as _i41;
import '../../features/home/data/data_sources/home_remote_data_source.dart'
    as _i32;
import '../../features/home/data/repositories/home_repository_implementation.dart'
    as _i34;
import '../../features/home/domain/repositories/home_repository.dart' as _i33;
import '../../features/home/domain/use_cases/get_home_sections_usecase.dart'
    as _i69;
import '../../features/home/domain/use_cases/get_main_categories_usecase.dart'
    as _i70;
import '../../features/home/domain/use_cases/get_products_usecase.dart' as _i71;
import '../../features/home/domain/use_cases/get_starting_settings_usecase.dart'
    as _i72;
import '../../features/home/presentation/manager/home_bloc.dart' as _i75;
import '../../features/story/data/data_source/story_data_source.dart' as _i52;
import '../../features/story/data/repository/story_repository_impl.dart'
    as _i54;
import '../../features/story/domain/repository/story_repository.dart' as _i53;
import '../../features/story/domain/useCases/add_story_to_our_server_usecase.dart'
    as _i63;
import '../../features/story/domain/useCases/get_stories_usecase.dart' as _i73;
import '../../features/story/domain/useCases/get_width_and_height_usecase.dart'
    as _i74;
import '../../features/story/domain/useCases/increase_viewers_usecase.dart'
    as _i76;
import '../../features/story/domain/useCases/upload_story_usecase.dart' as _i58;
import '../../features/story/presentation/bloc/story_bloc.dart' as _i77;
import '../data/data_source/common_use_repo_data_source.dart' as _i14;
import '../data/repository/common_use_repository_impl.dart' as _i16;
import '../domin/repositories/common_use_repository.dart' as _i15;
import '../domin/repositories/prefs_repository.dart' as _i40;
import '../domin/usecases/upload_file_cloudinary_usecase.dart' as _i56;
import 'di_container.dart' as _i78;

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
  gh.factory<_i8.CallsRemoteDataSource>(() => _i8.CallsRemoteDataSource());
  gh.lazySingleton<_i9.CallsRepository>(
      () => _i10.CallsRepositoryImpl(gh<_i8.CallsRemoteDataSource>()));
  gh.factory<_i11.ChatRemoteDataSource>(() => _i11.ChatRemoteDataSource());
  gh.lazySingleton<_i12.ChatRepository>(
      () => _i13.ChatRepositoryImpl(gh<_i11.ChatRemoteDataSource>()));
  gh.factory<_i14.CommonUseRemoteDataSource>(
      () => _i14.CommonUseRemoteDataSource());
  gh.lazySingleton<_i15.CommonUseRepository>(
      () => _i16.CommonUseRepositoryImpl(gh<_i14.CommonUseRemoteDataSource>()));
  gh.factory<_i17.CreateUserUseCase>(
      () => _i17.CreateUserUseCase(gh<_i12.ChatRepository>()));
  gh.factory<_i18.DeleteChatUseCase>(
      () => _i18.DeleteChatUseCase(gh<_i12.ChatRepository>()));
  gh.factory<_i19.DeleteFcmUseCase>(
      () => _i19.DeleteFcmUseCase(gh<_i5.AuthRepository>()));
  gh.factory<_i20.DeleteMessageUseCase>(
      () => _i20.DeleteMessageUseCase(gh<_i9.CallsRepository>()));
  gh.factory<_i21.GetAgoraTokenUseCase>(
      () => _i21.GetAgoraTokenUseCase(gh<_i9.CallsRepository>()));
  gh.factory<_i22.GetContactsUseCase>(
      () => _i22.GetContactsUseCase(gh<_i12.ChatRepository>()));
  gh.factory<_i23.GetCustomerInfoUseCase>(
      () => _i23.GetCustomerInfoUseCase(gh<_i5.AuthRepository>()));
  gh.factory<_i24.GetMediaCountUseCase>(
      () => _i24.GetMediaCountUseCase(gh<_i12.ChatRepository>()));
  gh.factory<_i25.GetMessagesBetweenUseCase>(
      () => _i25.GetMessagesBetweenUseCase(gh<_i12.ChatRepository>()));
  gh.factory<_i26.GetMessagesForChatUseCase>(
      () => _i26.GetMessagesForChatUseCase(gh<_i12.ChatRepository>()));
  gh.factory<_i27.GetMissedCalCountUseCase>(
      () => _i27.GetMissedCalCountUseCase(gh<_i9.CallsRepository>()));
  gh.factory<_i28.GetMyCallsUseCase>(
      () => _i28.GetMyCallsUseCase(gh<_i9.CallsRepository>()));
  gh.factory<_i29.GetMyChatsUseCase>(
      () => _i29.GetMyChatsUseCase(gh<_i12.ChatRepository>()));
  gh.factory<_i30.GetUserCountryUseCase>(
      () => _i30.GetUserCountryUseCase(gh<_i5.AuthRepository>()));
  gh.factory<_i31.GetWidthAndHeightUseCase>(
      () => _i31.GetWidthAndHeightUseCase(gh<_i12.ChatRepository>()));
  gh.factory<_i32.HomeRemoteDatasource>(() => _i32.HomeRemoteDatasource());
  gh.lazySingleton<_i33.HomeRepository>(
      () => _i34.HomeRepositoryImpl(gh<_i32.HomeRemoteDatasource>()));
  gh.singleton<_i35.Logger>(appModule.logger);
  gh.factory<_i36.LoginToChatUseCase>(
      () => _i36.LoginToChatUseCase(gh<_i5.AuthRepository>()));
  gh.factory<_i37.LoginToMarketUseCase>(
      () => _i37.LoginToMarketUseCase(gh<_i5.AuthRepository>()));
  gh.factory<_i38.LoginToStoriesUseCase>(
      () => _i38.LoginToStoriesUseCase(gh<_i5.AuthRepository>()));
  gh.factory<_i39.MakeCallUseCase>(
      () => _i39.MakeCallUseCase(gh<_i9.CallsRepository>()));
  await gh.singletonAsync<_i40.PrefsRepository>(
    () => appModule.prefsRepository,
    preResolve: true,
  );
  gh.factory<_i41.PreloadingVideosBloc>(() => _i41.PreloadingVideosBloc());
  gh.factory<_i42.ReadAllMessagesUseCase>(
      () => _i42.ReadAllMessagesUseCase(gh<_i12.ChatRepository>()));
  gh.factory<_i43.ReceiveMessageUseCase>(
      () => _i43.ReceiveMessageUseCase(gh<_i12.ChatRepository>()));
  gh.factory<_i44.RegisterGuestUseCase>(
      () => _i44.RegisterGuestUseCase(gh<_i5.AuthRepository>()));
  gh.factory<_i45.RejectCallUseCase>(
      () => _i45.RejectCallUseCase(gh<_i9.CallsRepository>()));
  gh.factory<_i46.SaveContactsUseCase>(
      () => _i46.SaveContactsUseCase(gh<_i12.ChatRepository>()));
  gh.factory<_i47.SendMessageUseCase>(
      () => _i47.SendMessageUseCase(gh<_i12.ChatRepository>()));
  gh.factory<_i48.SendOtpUseCase>(
      () => _i48.SendOtpUseCase(gh<_i5.AuthRepository>()));
  gh.factory<_i49.SensitiveConnectivityBloc>(
      () => _i49.SensitiveConnectivityBloc());
  await gh.singletonAsync<_i50.SharedPreferences>(
    () => appModule.sharedPreferences,
    preResolve: true,
  );
  gh.factory<_i51.StoreFcmUseCase>(
      () => _i51.StoreFcmUseCase(gh<_i5.AuthRepository>()));
  gh.factory<_i52.StoriesDataSource>(() => _i52.StoriesDataSource());
  gh.lazySingleton<_i53.StoryRepository>(
      () => _i54.StoryRepositoryImpl(gh<_i52.StoriesDataSource>()));
  gh.factory<_i55.UpdateNameUseCase>(
      () => _i55.UpdateNameUseCase(gh<_i5.AuthRepository>()));
  gh.factory<_i56.UploadFileCloudinaryUseCase>(
      () => _i56.UploadFileCloudinaryUseCase(gh<_i15.CommonUseRepository>()));
  gh.factory<_i57.UploadFileUseCase>(
      () => _i57.UploadFileUseCase(gh<_i12.ChatRepository>()));
  gh.factory<_i58.UploadStoryUseCase>(
      () => _i58.UploadStoryUseCase(gh<_i53.StoryRepository>()));
  gh.factory<_i59.VerifyGuestPhoneUseCase>(
      () => _i59.VerifyGuestPhoneUseCase(gh<_i5.AuthRepository>()));
  gh.factory<_i60.VerifyOtpSignInUseCase>(
      () => _i60.VerifyOtpSignInUseCase(gh<_i5.AuthRepository>()));
  gh.factory<_i61.VerifyOtpSignUpUseCase>(
      () => _i61.VerifyOtpSignUpUseCase(gh<_i5.AuthRepository>()));
  gh.factory<_i62.WatchMissedCallUseCase>(
      () => _i62.WatchMissedCallUseCase(gh<_i9.CallsRepository>()));
  gh.factory<_i63.AddStoryToOurServerUseCase>(
      () => _i63.AddStoryToOurServerUseCase(gh<_i53.StoryRepository>()));
  gh.factory<_i64.AnswerCallUseCase>(
      () => _i64.AnswerCallUseCase(gh<_i9.CallsRepository>()));
  gh.factory<_i65.AuthBloc>(() => _i65.AuthBloc(
        gh<_i17.CreateUserUseCase>(),
        gh<_i36.LoginToChatUseCase>(),
        gh<_i37.LoginToMarketUseCase>(),
        gh<_i38.LoginToStoriesUseCase>(),
        gh<_i51.StoreFcmUseCase>(),
        gh<_i55.UpdateNameUseCase>(),
        gh<_i44.RegisterGuestUseCase>(),
        gh<_i48.SendOtpUseCase>(),
        gh<_i23.GetCustomerInfoUseCase>(),
        gh<_i59.VerifyGuestPhoneUseCase>(),
        gh<_i60.VerifyOtpSignInUseCase>(),
        gh<_i30.GetUserCountryUseCase>(),
        gh<_i61.VerifyOtpSignUpUseCase>(),
      ));
  gh.lazySingleton<_i66.CallsBloc>(() => _i66.CallsBloc(
        gh<_i45.RejectCallUseCase>(),
        gh<_i39.MakeCallUseCase>(),
        gh<_i28.GetMyCallsUseCase>(),
        gh<_i62.WatchMissedCallUseCase>(),
        gh<_i64.AnswerCallUseCase>(),
        gh<_i27.GetMissedCalCountUseCase>(),
        gh<_i21.GetAgoraTokenUseCase>(),
        gh<_i20.DeleteMessageUseCase>(),
      ));
  gh.factory<_i67.ChangeChatPropertyUseCase>(
      () => _i67.ChangeChatPropertyUseCase(gh<_i12.ChatRepository>()));
  gh.lazySingleton<_i68.ChatBloc>(() => _i68.ChatBloc(
        gh<_i22.GetContactsUseCase>(),
        gh<_i29.GetMyChatsUseCase>(),
        gh<_i46.SaveContactsUseCase>(),
        gh<_i47.SendMessageUseCase>(),
        gh<_i25.GetMessagesBetweenUseCase>(),
        gh<_i56.UploadFileCloudinaryUseCase>(),
        gh<_i26.GetMessagesForChatUseCase>(),
        gh<_i18.DeleteChatUseCase>(),
        gh<_i67.ChangeChatPropertyUseCase>(),
        gh<_i57.UploadFileUseCase>(),
        gh<_i42.ReadAllMessagesUseCase>(),
        gh<_i43.ReceiveMessageUseCase>(),
        gh<_i24.GetMediaCountUseCase>(),
      ));
  gh.singleton<_i7.Dio>(appModule.dio(
    gh<_i7.BaseOptions>(),
    gh<_i35.Logger>(),
  ));
  gh.factory<_i69.GetHomeSectionsUseCase>(
      () => _i69.GetHomeSectionsUseCase(gh<_i33.HomeRepository>()));
  gh.factory<_i70.GetMainCategoriesUseCase>(
      () => _i70.GetMainCategoriesUseCase(gh<_i33.HomeRepository>()));
  gh.factory<_i71.GetProductsWithoutFiltersUseCase>(
      () => _i71.GetProductsWithoutFiltersUseCase(gh<_i33.HomeRepository>()));
  gh.factory<_i72.GetStartingSettingsUseCase>(
      () => _i72.GetStartingSettingsUseCase(gh<_i33.HomeRepository>()));
  gh.factory<_i73.GetStoryUseCase>(
      () => _i73.GetStoryUseCase(gh<_i53.StoryRepository>()));
  gh.factory<_i74.GetWidthAndHeightUseCase>(
      () => _i74.GetWidthAndHeightUseCase(gh<_i53.StoryRepository>()));
  gh.lazySingleton<_i75.HomeBloc>(() => _i75.HomeBloc(
        gh<_i69.GetHomeSectionsUseCase>(),
        gh<_i70.GetMainCategoriesUseCase>(),
        gh<_i72.GetStartingSettingsUseCase>(),
        gh<_i71.GetProductsWithoutFiltersUseCase>(),
      ));
  gh.factory<_i76.IncreaseViewersUseCase>(
      () => _i76.IncreaseViewersUseCase(gh<_i53.StoryRepository>()));
  gh.lazySingleton<_i77.StoryBloc>(() => _i77.StoryBloc(
        gh<_i56.UploadFileCloudinaryUseCase>(),
        gh<_i73.GetStoryUseCase>(),
        gh<_i74.GetWidthAndHeightUseCase>(),
        gh<_i58.UploadStoryUseCase>(),
        gh<_i76.IncreaseViewersUseCase>(),
        gh<_i63.AddStoryToOurServerUseCase>(),
      ));
  return getIt;
}

class _$AppModule extends _i78.AppModule {}
