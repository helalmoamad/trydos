// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i4;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:logger/logger.dart' as _i12;
import 'package:shared_preferences/shared_preferences.dart' as _i13;

import '../../features/app/blocs/app_bloc/app_bloc.dart' as _i15;
import '../../features/app/blocs/sensitive_connectivity/sensitive_connectivity_bloc.dart'
    as _i5;
import '../../features/authentication/data/data_sources/auth_remote_datasource.dart'
    as _i6;
import '../../features/authentication/data/repositories/auth_repository_impl.dart'
    as _i21;
import '../../features/authentication/domain/repositories/auth_repository.dart'
    as _i20;
import '../../features/authentication/domain/use_cases/create_user_usecase.dart'
    as _i56;
import '../../features/authentication/domain/use_cases/delete_fcm_usecase.dart'
    as _i27;
import '../../features/authentication/domain/use_cases/get_customer_info_usecase.dart'
    as _i28;
import '../../features/authentication/domain/use_cases/get_user_country_usecase.dart'
    as _i29;
import '../../features/authentication/domain/use_cases/login_to_chat_usecase.dart'
    as _i30;
import '../../features/authentication/domain/use_cases/login_to_market_usecase.dart'
    as _i31;
import '../../features/authentication/domain/use_cases/login_to_stories_usecase.dart'
    as _i32;
import '../../features/authentication/domain/use_cases/register_guest_usecase.dart'
    as _i33;
import '../../features/authentication/domain/use_cases/send_otp_usecase.dart'
    as _i34;
import '../../features/authentication/domain/use_cases/store_fcm_usecase.dart'
    as _i35;
import '../../features/authentication/domain/use_cases/update_chat_user_name_usecase.dart'
    as _i36;
import '../../features/authentication/domain/use_cases/update_name_usecase.dart'
    as _i37;
import '../../features/authentication/domain/use_cases/update_stories_user_usecase.dart'
    as _i38;
import '../../features/authentication/domain/use_cases/verify_guest_phone_usecase.dart'
    as _i39;
import '../../features/authentication/domain/use_cases/verify_otp_signin_usecase.dart'
    as _i40;
import '../../features/authentication/domain/use_cases/verify_otp_signup_usecase.dart'
    as _i41;
import '../../features/authentication/presentation/manager/auth_bloc.dart'
    as _i83;
import '../../features/calls/data/data_source/calls_remote_data_source_model.dart'
    as _i7;
import '../../features/calls/data/repositories/calls_repository_impl.dart'
    as _i51;
import '../../features/calls/domain/repositories/calls_repository.dart' as _i50;
import '../../features/calls/domain/useCase/answer_call_usecase.dart' as _i72;
import '../../features/calls/domain/useCase/delete_Message.dart' as _i73;
import '../../features/calls/domain/useCase/get_agora_token_use_case.dart'
    as _i74;
import '../../features/calls/domain/useCase/get_missed_call_count.dart' as _i75;
import '../../features/calls/domain/useCase/get_my_calls.dart' as _i76;
import '../../features/calls/domain/useCase/make_call_usecase.dart' as _i77;
import '../../features/calls/domain/useCase/reject_call_usecase.dart' as _i78;
import '../../features/calls/domain/useCase/watch_missed_call.dart' as _i79;
import '../../features/calls/presentation/bloc/calls_bloc.dart' as _i82;
import '../../features/chat/data/data_sources/chat_remote_datasource.dart'
    as _i8;
import '../../features/chat/data/repositories/chat_repository_impl.dart'
    as _i54;
import '../../features/chat/domain/repositories/chat_repository.dart' as _i53;
import '../../features/chat/domain/use_cases/change_chat_property_usecase.dart'
    as _i57;
import '../../features/chat/domain/use_cases/delete_chat_usecase.dart' as _i58;
import '../../features/chat/domain/use_cases/get_contacts_usecase.dart' as _i59;
import '../../features/chat/domain/use_cases/get_date_time.dart' as _i60;
import '../../features/chat/domain/use_cases/get_image_width_and_height_usecase.dart'
    as _i61;
import '../../features/chat/domain/use_cases/get_media_count_usecase.dart'
    as _i62;
import '../../features/chat/domain/use_cases/get_messages_between_usecase.dart'
    as _i63;
import '../../features/chat/domain/use_cases/get_messages_for_chat_usecase.dart'
    as _i64;
import '../../features/chat/domain/use_cases/get_my_chats_usecase.dart' as _i65;
import '../../features/chat/domain/use_cases/read_all_messages_usecase.dart'
    as _i66;
import '../../features/chat/domain/use_cases/receive_message_usecase.dart'
    as _i67;
import '../../features/chat/domain/use_cases/save_contacts_usecase.dart'
    as _i68;
import '../../features/chat/domain/use_cases/send_error_to_server_usecase.dart'
    as _i69;
import '../../features/chat/domain/use_cases/send_message_usecase.dart' as _i70;
import '../../features/chat/domain/use_cases/upload_file_usecase.dart' as _i71;
import '../../features/chat/presentation/manager/chat_bloc.dart' as _i81;
import '../../features/chat/presentation/manager/preload_bloc/preloading_videos_bloc.dart'
    as _i9;
import '../../features/home/data/data_sources/home_remote_data_source.dart'
    as _i10;
import '../../features/home/data/repositories/home_repository_implementation.dart'
    as _i19;
import '../../features/home/domain/repositories/home_repository.dart' as _i18;
import '../../features/home/domain/use_cases/get_home_boutiqes_usecase.dart'
    as _i42;
import '../../features/home/domain/use_cases/get_main_categories_usecase.dart'
    as _i43;
import '../../features/home/domain/use_cases/get_product_detail_without_related_products_uswcase.dart'
    as _i45;
import '../../features/home/domain/use_cases/get_products_usecase.dart' as _i44;
import '../../features/home/domain/use_cases/get_starting_settings_usecase.dart'
    as _i46;
import '../../features/home/domain/use_cases/get_stories_for_product_usecase.dart'
    as _i47;
import '../../features/home/presentation/manager/home_bloc.dart' as _i52;
import '../../features/story/data/data_source/story_data_source.dart' as _i11;
import '../../features/story/data/repository/story_repository_impl.dart'
    as _i17;
import '../../features/story/domain/repository/story_repository.dart' as _i16;
import '../../features/story/domain/useCases/add_story_to_our_server_usecase.dart'
    as _i22;
import '../../features/story/domain/useCases/get_stories_usecase.dart' as _i23;
import '../../features/story/domain/useCases/get_width_and_height_usecase.dart'
    as _i24;
import '../../features/story/domain/useCases/increase_viewers_usecase.dart'
    as _i25;
import '../../features/story/domain/useCases/upload_story_usecase.dart' as _i26;
import '../../features/story/presentation/bloc/story_bloc.dart' as _i80;
import '../data/data_source/common_use_repo_data_source.dart' as _i3;
import '../data/repository/common_use_repository_impl.dart' as _i49;
import '../domin/repositories/common_use_repository.dart' as _i48;
import '../domin/repositories/prefs_repository.dart' as _i14;
import '../domin/usecases/upload_file_cloudinary_usecase.dart' as _i55;
import 'di_container.dart' as _i84;

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
  gh.factory<_i3.CommonUseRemoteDataSource>(
      () => _i3.CommonUseRemoteDataSource());
  gh.factory<_i4.BaseOptions>(() => appModule.dioOption);
  gh.factory<_i5.SensitiveConnectivityBloc>(
      () => _i5.SensitiveConnectivityBloc());
  gh.factory<_i6.AuthRemoteDatasource>(() => _i6.AuthRemoteDatasource());
  gh.factory<_i7.CallsRemoteDataSource>(() => _i7.CallsRemoteDataSource());
  gh.factory<_i8.ChatRemoteDataSource>(() => _i8.ChatRemoteDataSource());
  gh.factory<_i9.PreloadingVideosBloc>(() => _i9.PreloadingVideosBloc());
  gh.factory<_i10.HomeRemoteDatasource>(() => _i10.HomeRemoteDatasource());
  gh.factory<_i11.StoriesDataSource>(() => _i11.StoriesDataSource());
  gh.singleton<_i12.Logger>(() => appModule.logger);
  await gh.singletonAsync<_i13.SharedPreferences>(
    () => appModule.sharedPreferences,
    preResolve: true,
  );
  await gh.singletonAsync<_i14.PrefsRepository>(
    () => appModule.prefsRepository,
    preResolve: true,
  );
  gh.lazySingleton<_i15.AppBloc>(() => _i15.AppBloc());
  gh.lazySingleton<_i16.StoryRepository>(
      () => _i17.StoryRepositoryImpl(gh<_i11.StoriesDataSource>()));
  gh.lazySingleton<_i18.HomeRepository>(
      () => _i19.HomeRepositoryImpl(gh<_i10.HomeRemoteDatasource>()));
  gh.singleton<_i4.Dio>(() => appModule.dio(
        gh<_i4.BaseOptions>(),
        gh<_i12.Logger>(),
      ));
  gh.lazySingleton<_i20.AuthRepository>(
      () => _i21.AuthRepositoryImpl(gh<_i6.AuthRemoteDatasource>()));
  gh.factory<_i22.AddStoryToOurServerUseCase>(
      () => _i22.AddStoryToOurServerUseCase(gh<_i16.StoryRepository>()));
  gh.factory<_i23.GetStoryUseCase>(
      () => _i23.GetStoryUseCase(gh<_i16.StoryRepository>()));
  gh.factory<_i24.GetWidthAndHeightUseCase>(
      () => _i24.GetWidthAndHeightUseCase(gh<_i16.StoryRepository>()));
  gh.factory<_i25.IncreaseViewersUseCase>(
      () => _i25.IncreaseViewersUseCase(gh<_i16.StoryRepository>()));
  gh.factory<_i26.UploadStoryUseCase>(
      () => _i26.UploadStoryUseCase(gh<_i16.StoryRepository>()));
  gh.factory<_i27.DeleteFcmUseCase>(
      () => _i27.DeleteFcmUseCase(gh<_i20.AuthRepository>()));
  gh.factory<_i28.GetCustomerInfoUseCase>(
      () => _i28.GetCustomerInfoUseCase(gh<_i20.AuthRepository>()));
  gh.factory<_i29.GetUserCountryUseCase>(
      () => _i29.GetUserCountryUseCase(gh<_i20.AuthRepository>()));
  gh.factory<_i30.LoginToChatUseCase>(
      () => _i30.LoginToChatUseCase(gh<_i20.AuthRepository>()));
  gh.factory<_i31.LoginToMarketUseCase>(
      () => _i31.LoginToMarketUseCase(gh<_i20.AuthRepository>()));
  gh.factory<_i32.LoginToStoriesUseCase>(
      () => _i32.LoginToStoriesUseCase(gh<_i20.AuthRepository>()));
  gh.factory<_i33.RegisterGuestUseCase>(
      () => _i33.RegisterGuestUseCase(gh<_i20.AuthRepository>()));
  gh.factory<_i34.SendOtpUseCase>(
      () => _i34.SendOtpUseCase(gh<_i20.AuthRepository>()));
  gh.factory<_i35.StoreFcmUseCase>(
      () => _i35.StoreFcmUseCase(gh<_i20.AuthRepository>()));
  gh.factory<_i36.UpdateChatUserNameUseCase>(
      () => _i36.UpdateChatUserNameUseCase(gh<_i20.AuthRepository>()));
  gh.factory<_i37.UpdateNameUseCase>(
      () => _i37.UpdateNameUseCase(gh<_i20.AuthRepository>()));
  gh.factory<_i38.UpdateStoriesUserUseCase>(
      () => _i38.UpdateStoriesUserUseCase(gh<_i20.AuthRepository>()));
  gh.factory<_i39.VerifyGuestPhoneUseCase>(
      () => _i39.VerifyGuestPhoneUseCase(gh<_i20.AuthRepository>()));
  gh.factory<_i40.VerifyOtpSignInUseCase>(
      () => _i40.VerifyOtpSignInUseCase(gh<_i20.AuthRepository>()));
  gh.factory<_i41.VerifyOtpSignUpUseCase>(
      () => _i41.VerifyOtpSignUpUseCase(gh<_i20.AuthRepository>()));
  gh.factory<_i42.GetHomeBoutiqesUseCase>(
      () => _i42.GetHomeBoutiqesUseCase(gh<_i18.HomeRepository>()));
  gh.factory<_i43.GetMainCategoriesUseCase>(
      () => _i43.GetMainCategoriesUseCase(gh<_i18.HomeRepository>()));
  gh.factory<_i44.GetProductsWithoutFiltersUseCase>(
      () => _i44.GetProductsWithoutFiltersUseCase(gh<_i18.HomeRepository>()));
  gh.factory<_i45.GetProductDetailWithoutRelatedProductsUseCase>(() =>
      _i45.GetProductDetailWithoutRelatedProductsUseCase(
          gh<_i18.HomeRepository>()));
  gh.factory<_i46.GetStartingSettingsUseCase>(
      () => _i46.GetStartingSettingsUseCase(gh<_i18.HomeRepository>()));
  gh.factory<_i47.GetStoryForProductUseCase>(
      () => _i47.GetStoryForProductUseCase(gh<_i18.HomeRepository>()));
  gh.lazySingleton<_i48.CommonUseRepository>(
      () => _i49.CommonUseRepositoryImpl(gh<_i3.CommonUseRemoteDataSource>()));
  gh.lazySingleton<_i50.CallsRepository>(
      () => _i51.CallsRepositoryImpl(gh<_i7.CallsRemoteDataSource>()));
  gh.lazySingleton<_i52.HomeBloc>(() => _i52.HomeBloc(
        gh<_i43.GetMainCategoriesUseCase>(),
        gh<_i47.GetStoryForProductUseCase>(),
        gh<_i42.GetHomeBoutiqesUseCase>(),
        gh<_i24.GetWidthAndHeightUseCase>(),
        gh<_i45.GetProductDetailWithoutRelatedProductsUseCase>(),
        gh<_i46.GetStartingSettingsUseCase>(),
        gh<_i44.GetProductsWithoutFiltersUseCase>(),
      ));
  gh.lazySingleton<_i53.ChatRepository>(
      () => _i54.ChatRepositoryImpl(gh<_i8.ChatRemoteDataSource>()));
  gh.factory<_i55.UploadFileCloudinaryUseCase>(
      () => _i55.UploadFileCloudinaryUseCase(gh<_i48.CommonUseRepository>()));
  gh.factory<_i56.CreateUserUseCase>(
      () => _i56.CreateUserUseCase(gh<_i53.ChatRepository>()));
  gh.factory<_i57.ChangeChatPropertyUseCase>(
      () => _i57.ChangeChatPropertyUseCase(gh<_i53.ChatRepository>()));
  gh.factory<_i58.DeleteChatUseCase>(
      () => _i58.DeleteChatUseCase(gh<_i53.ChatRepository>()));
  gh.factory<_i59.GetContactsUseCase>(
      () => _i59.GetContactsUseCase(gh<_i53.ChatRepository>()));
  gh.factory<_i60.GetDateTimeUseCase>(
      () => _i60.GetDateTimeUseCase(gh<_i53.ChatRepository>()));
  gh.factory<_i61.GetWidthAndHeightUseCase>(
      () => _i61.GetWidthAndHeightUseCase(gh<_i53.ChatRepository>()));
  gh.factory<_i62.GetMediaCountUseCase>(
      () => _i62.GetMediaCountUseCase(gh<_i53.ChatRepository>()));
  gh.factory<_i63.GetMessagesBetweenUseCase>(
      () => _i63.GetMessagesBetweenUseCase(gh<_i53.ChatRepository>()));
  gh.factory<_i64.GetMessagesForChatUseCase>(
      () => _i64.GetMessagesForChatUseCase(gh<_i53.ChatRepository>()));
  gh.factory<_i65.GetMyChatsUseCase>(
      () => _i65.GetMyChatsUseCase(gh<_i53.ChatRepository>()));
  gh.factory<_i66.ReadAllMessagesUseCase>(
      () => _i66.ReadAllMessagesUseCase(gh<_i53.ChatRepository>()));
  gh.factory<_i67.ReceiveMessageUseCase>(
      () => _i67.ReceiveMessageUseCase(gh<_i53.ChatRepository>()));
  gh.factory<_i68.SaveContactsUseCase>(
      () => _i68.SaveContactsUseCase(gh<_i53.ChatRepository>()));
  gh.factory<_i69.SendErrorToServerUseCase>(
      () => _i69.SendErrorToServerUseCase(gh<_i53.ChatRepository>()));
  gh.factory<_i70.SendMessageUseCase>(
      () => _i70.SendMessageUseCase(gh<_i53.ChatRepository>()));
  gh.factory<_i71.UploadFileUseCase>(
      () => _i71.UploadFileUseCase(gh<_i53.ChatRepository>()));
  gh.factory<_i72.AnswerCallUseCase>(
      () => _i72.AnswerCallUseCase(gh<_i50.CallsRepository>()));
  gh.factory<_i73.DeleteMessageUseCase>(
      () => _i73.DeleteMessageUseCase(gh<_i50.CallsRepository>()));
  gh.factory<_i74.GetAgoraTokenUseCase>(
      () => _i74.GetAgoraTokenUseCase(gh<_i50.CallsRepository>()));
  gh.factory<_i75.GetMissedCalCountUseCase>(
      () => _i75.GetMissedCalCountUseCase(gh<_i50.CallsRepository>()));
  gh.factory<_i76.GetMyCallsUseCase>(
      () => _i76.GetMyCallsUseCase(gh<_i50.CallsRepository>()));
  gh.factory<_i77.MakeCallUseCase>(
      () => _i77.MakeCallUseCase(gh<_i50.CallsRepository>()));
  gh.factory<_i78.RejectCallUseCase>(
      () => _i78.RejectCallUseCase(gh<_i50.CallsRepository>()));
  gh.factory<_i79.WatchMissedCallUseCase>(
      () => _i79.WatchMissedCallUseCase(gh<_i50.CallsRepository>()));
  gh.lazySingleton<_i80.StoryBloc>(() => _i80.StoryBloc(
        gh<_i55.UploadFileCloudinaryUseCase>(),
        gh<_i23.GetStoryUseCase>(),
        gh<_i24.GetWidthAndHeightUseCase>(),
        gh<_i26.UploadStoryUseCase>(),
        gh<_i25.IncreaseViewersUseCase>(),
        gh<_i22.AddStoryToOurServerUseCase>(),
      ));
  gh.lazySingleton<_i81.ChatBloc>(() => _i81.ChatBloc(
        gh<_i59.GetContactsUseCase>(),
        gh<_i65.GetMyChatsUseCase>(),
        gh<_i68.SaveContactsUseCase>(),
        gh<_i70.SendMessageUseCase>(),
        gh<_i63.GetMessagesBetweenUseCase>(),
        gh<_i55.UploadFileCloudinaryUseCase>(),
        gh<_i64.GetMessagesForChatUseCase>(),
        gh<_i58.DeleteChatUseCase>(),
        gh<_i57.ChangeChatPropertyUseCase>(),
        gh<_i71.UploadFileUseCase>(),
        gh<_i66.ReadAllMessagesUseCase>(),
        gh<_i67.ReceiveMessageUseCase>(),
        gh<_i62.GetMediaCountUseCase>(),
        gh<_i60.GetDateTimeUseCase>(),
        gh<_i69.SendErrorToServerUseCase>(),
      ));
  gh.lazySingleton<_i82.CallsBloc>(() => _i82.CallsBloc(
        gh<_i78.RejectCallUseCase>(),
        gh<_i77.MakeCallUseCase>(),
        gh<_i76.GetMyCallsUseCase>(),
        gh<_i79.WatchMissedCallUseCase>(),
        gh<_i72.AnswerCallUseCase>(),
        gh<_i75.GetMissedCalCountUseCase>(),
        gh<_i74.GetAgoraTokenUseCase>(),
        gh<_i73.DeleteMessageUseCase>(),
      ));
  gh.factory<_i83.AuthBloc>(() => _i83.AuthBloc(
        gh<_i38.UpdateStoriesUserUseCase>(),
        gh<_i36.UpdateChatUserNameUseCase>(),
        gh<_i56.CreateUserUseCase>(),
        gh<_i30.LoginToChatUseCase>(),
        gh<_i31.LoginToMarketUseCase>(),
        gh<_i32.LoginToStoriesUseCase>(),
        gh<_i35.StoreFcmUseCase>(),
        gh<_i37.UpdateNameUseCase>(),
        gh<_i33.RegisterGuestUseCase>(),
        gh<_i34.SendOtpUseCase>(),
        gh<_i28.GetCustomerInfoUseCase>(),
        gh<_i39.VerifyGuestPhoneUseCase>(),
        gh<_i40.VerifyOtpSignInUseCase>(),
        gh<_i29.GetUserCountryUseCase>(),
        gh<_i41.VerifyOtpSignUpUseCase>(),
      ));
  return getIt;
}

class _$AppModule extends _i84.AppModule {}
