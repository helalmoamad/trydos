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

import '../../common/helper/firebase_analytics_sessions.dart' as _i15;
import '../../features/app/blocs/app_bloc/app_bloc.dart' as _i16;
import '../../features/app/blocs/sensitive_connectivity/sensitive_connectivity_bloc.dart'
    as _i5;
import '../../features/authentication/data/data_sources/auth_remote_datasource.dart'
    as _i6;
import '../../features/authentication/data/repositories/auth_repository_impl.dart'
    as _i22;
import '../../features/authentication/domain/repositories/auth_repository.dart'
    as _i21;
import '../../features/authentication/domain/use_cases/create_user_usecase.dart'
    as _i59;
import '../../features/authentication/domain/use_cases/delete_fcm_usecase.dart'
    as _i28;
import '../../features/authentication/domain/use_cases/get_customer_info_usecase.dart'
    as _i29;
import '../../features/authentication/domain/use_cases/get_user_country_usecase.dart'
    as _i30;
import '../../features/authentication/domain/use_cases/login_to_chat_usecase.dart'
    as _i31;
import '../../features/authentication/domain/use_cases/login_to_market_usecase.dart'
    as _i32;
import '../../features/authentication/domain/use_cases/login_to_stories_usecase.dart'
    as _i33;
import '../../features/authentication/domain/use_cases/register_guest_usecase.dart'
    as _i34;
import '../../features/authentication/domain/use_cases/send_otp_usecase.dart'
    as _i35;
import '../../features/authentication/domain/use_cases/store_fcm_usecase.dart'
    as _i36;
import '../../features/authentication/domain/use_cases/update_chat_user_name_usecase.dart'
    as _i37;
import '../../features/authentication/domain/use_cases/update_name_usecase.dart'
    as _i38;
import '../../features/authentication/domain/use_cases/update_stories_user_usecase.dart'
    as _i39;
import '../../features/authentication/domain/use_cases/verify_guest_phone_usecase.dart'
    as _i40;
import '../../features/authentication/domain/use_cases/verify_otp_signin_usecase.dart'
    as _i41;
import '../../features/authentication/domain/use_cases/verify_otp_signup_usecase.dart'
    as _i42;
import '../../features/authentication/presentation/manager/auth_bloc.dart'
    as _i87;
import '../../features/calls/data/data_source/calls_remote_data_source_model.dart'
    as _i7;
import '../../features/calls/data/repositories/calls_repository_impl.dart'
    as _i55;
import '../../features/calls/domain/repositories/calls_repository.dart' as _i54;
import '../../features/calls/domain/useCase/answer_call_usecase.dart' as _i75;
import '../../features/calls/domain/useCase/delete_Message.dart' as _i76;
import '../../features/calls/domain/useCase/get_agora_token_use_case.dart'
    as _i77;
import '../../features/calls/domain/useCase/get_missed_call_count.dart' as _i78;
import '../../features/calls/domain/useCase/get_my_calls.dart' as _i79;
import '../../features/calls/domain/useCase/make_call_usecase.dart' as _i80;
import '../../features/calls/domain/useCase/reject_call_usecase.dart' as _i81;
import '../../features/calls/domain/useCase/watch_missed_call.dart' as _i82;
import '../../features/calls/presentation/bloc/calls_bloc.dart' as _i86;
import '../../features/chat/data/data_sources/chat_remote_datasource.dart'
    as _i8;
import '../../features/chat/data/repositories/chat_repository_impl.dart'
    as _i57;
import '../../features/chat/domain/repositories/chat_repository.dart' as _i56;
import '../../features/chat/domain/use_cases/change_chat_property_usecase.dart'
    as _i60;
import '../../features/chat/domain/use_cases/delete_chat_usecase.dart' as _i61;
import '../../features/chat/domain/use_cases/get_contacts_usecase.dart' as _i62;
import '../../features/chat/domain/use_cases/get_date_time.dart' as _i63;
import '../../features/chat/domain/use_cases/get_image_width_and_height_usecase.dart'
    as _i64;
import '../../features/chat/domain/use_cases/get_media_count_usecase.dart'
    as _i65;
import '../../features/chat/domain/use_cases/get_messages_between_usecase.dart'
    as _i66;
import '../../features/chat/domain/use_cases/get_messages_for_chat_usecase.dart'
    as _i67;
import '../../features/chat/domain/use_cases/get_my_chats_usecase.dart' as _i68;
import '../../features/chat/domain/use_cases/read_all_messages_usecase.dart'
    as _i69;
import '../../features/chat/domain/use_cases/receive_message_usecase.dart'
    as _i70;
import '../../features/chat/domain/use_cases/save_contacts_usecase.dart'
    as _i71;
import '../../features/chat/domain/use_cases/send_error_to_server_usecase.dart'
    as _i72;
import '../../features/chat/domain/use_cases/send_message_usecase.dart' as _i73;
import '../../features/chat/domain/use_cases/upload_file_usecase.dart' as _i74;
import '../../features/chat/presentation/manager/chat_bloc.dart' as _i85;
import '../../features/chat/presentation/manager/preload_bloc/preloading_videos_bloc.dart'
    as _i9;
import '../../features/home/data/data_sources/home_remote_data_source.dart'
    as _i10;
import '../../features/home/data/repositories/home_repository_implementation.dart'
    as _i20;
import '../../features/home/domain/repositories/home_repository.dart' as _i19;
import '../../features/home/domain/use_cases/get_cart_item_usecase.dart'
    as _i51;
import '../../features/home/domain/use_cases/get_home_boutiqes_usecase.dart'
    as _i43;
import '../../features/home/domain/use_cases/get_main_categories_usecase.dart'
    as _i44;
import '../../features/home/domain/use_cases/get_product_detail_without_related_products_uswcase.dart'
    as _i46;
import '../../features/home/domain/use_cases/get_product_filters_usecase.dart'
    as _i47;
import '../../features/home/domain/use_cases/get_products_usecase.dart' as _i45;
import '../../features/home/domain/use_cases/get_starting_settings_usecase.dart'
    as _i48;
import '../../features/home/domain/use_cases/get_stories_for_product_usecase.dart'
    as _i49;
import '../../features/home/domain/use_cases/GetCommentForProductUseCase.dart'
    as _i50;
import '../../features/home/presentation/manager/home_bloc.dart' as _i83;
import '../../features/story/data/data_source/story_data_source.dart' as _i11;
import '../../features/story/data/repository/story_repository_impl.dart'
    as _i18;
import '../../features/story/domain/repository/story_repository.dart' as _i17;
import '../../features/story/domain/useCases/add_story_to_our_server_usecase.dart'
    as _i23;
import '../../features/story/domain/useCases/get_stories_usecase.dart' as _i24;
import '../../features/story/domain/useCases/get_width_and_height_usecase.dart'
    as _i25;
import '../../features/story/domain/useCases/increase_viewers_usecase.dart'
    as _i26;
import '../../features/story/domain/useCases/upload_story_usecase.dart' as _i27;
import '../../features/story/presentation/bloc/story_bloc.dart' as _i84;
import '../data/data_source/common_use_repo_data_source.dart' as _i3;
import '../data/repository/common_use_repository_impl.dart' as _i53;
import '../domin/repositories/common_use_repository.dart' as _i52;
import '../domin/repositories/prefs_repository.dart' as _i14;
import '../domin/usecases/upload_file_cloudinary_usecase.dart' as _i58;
import 'di_container.dart' as _i88;

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
  gh.lazySingleton<_i15.SessionManager>(() => _i15.SessionManager());
  gh.lazySingleton<_i16.AppBloc>(() => _i16.AppBloc());
  gh.lazySingleton<_i17.StoryRepository>(
      () => _i18.StoryRepositoryImpl(gh<_i11.StoriesDataSource>()));
  gh.lazySingleton<_i19.HomeRepository>(
      () => _i20.HomeRepositoryImpl(gh<_i10.HomeRemoteDatasource>()));
  gh.singleton<_i4.Dio>(() => appModule.dio(
        gh<_i4.BaseOptions>(),
        gh<_i12.Logger>(),
      ));
  gh.lazySingleton<_i21.AuthRepository>(
      () => _i22.AuthRepositoryImpl(gh<_i6.AuthRemoteDatasource>()));
  gh.factory<_i23.AddStoryToOurServerUseCase>(
      () => _i23.AddStoryToOurServerUseCase(gh<_i17.StoryRepository>()));
  gh.factory<_i24.GetStoryUseCase>(
      () => _i24.GetStoryUseCase(gh<_i17.StoryRepository>()));
  gh.factory<_i25.GetWidthAndHeightUseCase>(
      () => _i25.GetWidthAndHeightUseCase(gh<_i17.StoryRepository>()));
  gh.factory<_i26.IncreaseViewersUseCase>(
      () => _i26.IncreaseViewersUseCase(gh<_i17.StoryRepository>()));
  gh.factory<_i27.UploadStoryUseCase>(
      () => _i27.UploadStoryUseCase(gh<_i17.StoryRepository>()));
  gh.factory<_i28.DeleteFcmUseCase>(
      () => _i28.DeleteFcmUseCase(gh<_i21.AuthRepository>()));
  gh.factory<_i29.GetCustomerInfoUseCase>(
      () => _i29.GetCustomerInfoUseCase(gh<_i21.AuthRepository>()));
  gh.factory<_i30.GetUserCountryUseCase>(
      () => _i30.GetUserCountryUseCase(gh<_i21.AuthRepository>()));
  gh.factory<_i31.LoginToChatUseCase>(
      () => _i31.LoginToChatUseCase(gh<_i21.AuthRepository>()));
  gh.factory<_i32.LoginToMarketUseCase>(
      () => _i32.LoginToMarketUseCase(gh<_i21.AuthRepository>()));
  gh.factory<_i33.LoginToStoriesUseCase>(
      () => _i33.LoginToStoriesUseCase(gh<_i21.AuthRepository>()));
  gh.factory<_i34.RegisterGuestUseCase>(
      () => _i34.RegisterGuestUseCase(gh<_i21.AuthRepository>()));
  gh.factory<_i35.SendOtpUseCase>(
      () => _i35.SendOtpUseCase(gh<_i21.AuthRepository>()));
  gh.factory<_i36.StoreFcmUseCase>(
      () => _i36.StoreFcmUseCase(gh<_i21.AuthRepository>()));
  gh.factory<_i37.UpdateChatUserNameUseCase>(
      () => _i37.UpdateChatUserNameUseCase(gh<_i21.AuthRepository>()));
  gh.factory<_i38.UpdateNameUseCase>(
      () => _i38.UpdateNameUseCase(gh<_i21.AuthRepository>()));
  gh.factory<_i39.UpdateStoriesUserUseCase>(
      () => _i39.UpdateStoriesUserUseCase(gh<_i21.AuthRepository>()));
  gh.factory<_i40.VerifyGuestPhoneUseCase>(
      () => _i40.VerifyGuestPhoneUseCase(gh<_i21.AuthRepository>()));
  gh.factory<_i41.VerifyOtpSignInUseCase>(
      () => _i41.VerifyOtpSignInUseCase(gh<_i21.AuthRepository>()));
  gh.factory<_i42.VerifyOtpSignUpUseCase>(
      () => _i42.VerifyOtpSignUpUseCase(gh<_i21.AuthRepository>()));
  gh.factory<_i43.GetHomeBoutiqesUseCase>(
      () => _i43.GetHomeBoutiqesUseCase(gh<_i19.HomeRepository>()));
  gh.factory<_i44.GetMainCategoriesUseCase>(
      () => _i44.GetMainCategoriesUseCase(gh<_i19.HomeRepository>()));
  gh.factory<_i45.GetProductsWithoutFiltersUseCase>(
      () => _i45.GetProductsWithoutFiltersUseCase(gh<_i19.HomeRepository>()));
  gh.factory<_i46.GetProductDetailWithoutRelatedProductsUseCase>(() =>
      _i46.GetProductDetailWithoutRelatedProductsUseCase(
          gh<_i19.HomeRepository>()));
  gh.factory<_i47.GetProductFiltersUseCase>(
      () => _i47.GetProductFiltersUseCase(gh<_i19.HomeRepository>()));
  gh.factory<_i48.GetStartingSettingsUseCase>(
      () => _i48.GetStartingSettingsUseCase(gh<_i19.HomeRepository>()));
  gh.factory<_i49.GetStoryForProductUseCase>(
      () => _i49.GetStoryForProductUseCase(gh<_i19.HomeRepository>()));
  gh.factory<_i50.GetCommentForProductUseCase>(
      () => _i50.GetCommentForProductUseCase(gh<_i19.HomeRepository>()));
  gh.factory<_i51.GetCartItemUseCase>(
      () => _i51.GetCartItemUseCase(gh<_i19.HomeRepository>()));
  gh.lazySingleton<_i52.CommonUseRepository>(
      () => _i53.CommonUseRepositoryImpl(gh<_i3.CommonUseRemoteDataSource>()));
  gh.lazySingleton<_i54.CallsRepository>(
      () => _i55.CallsRepositoryImpl(gh<_i7.CallsRemoteDataSource>()));
  gh.lazySingleton<_i56.ChatRepository>(
      () => _i57.ChatRepositoryImpl(gh<_i8.ChatRemoteDataSource>()));
  gh.factory<_i58.UploadFileCloudinaryUseCase>(
      () => _i58.UploadFileCloudinaryUseCase(gh<_i52.CommonUseRepository>()));
  gh.factory<_i59.CreateUserUseCase>(
      () => _i59.CreateUserUseCase(gh<_i56.ChatRepository>()));
  gh.factory<_i60.ChangeChatPropertyUseCase>(
      () => _i60.ChangeChatPropertyUseCase(gh<_i56.ChatRepository>()));
  gh.factory<_i61.DeleteChatUseCase>(
      () => _i61.DeleteChatUseCase(gh<_i56.ChatRepository>()));
  gh.factory<_i62.GetContactsUseCase>(
      () => _i62.GetContactsUseCase(gh<_i56.ChatRepository>()));
  gh.factory<_i63.GetDateTimeUseCase>(
      () => _i63.GetDateTimeUseCase(gh<_i56.ChatRepository>()));
  gh.factory<_i64.GetWidthAndHeightUseCase>(
      () => _i64.GetWidthAndHeightUseCase(gh<_i56.ChatRepository>()));
  gh.factory<_i65.GetMediaCountUseCase>(
      () => _i65.GetMediaCountUseCase(gh<_i56.ChatRepository>()));
  gh.factory<_i66.GetMessagesBetweenUseCase>(
      () => _i66.GetMessagesBetweenUseCase(gh<_i56.ChatRepository>()));
  gh.factory<_i67.GetMessagesForChatUseCase>(
      () => _i67.GetMessagesForChatUseCase(gh<_i56.ChatRepository>()));
  gh.factory<_i68.GetMyChatsUseCase>(
      () => _i68.GetMyChatsUseCase(gh<_i56.ChatRepository>()));
  gh.factory<_i69.ReadAllMessagesUseCase>(
      () => _i69.ReadAllMessagesUseCase(gh<_i56.ChatRepository>()));
  gh.factory<_i70.ReceiveMessageUseCase>(
      () => _i70.ReceiveMessageUseCase(gh<_i56.ChatRepository>()));
  gh.factory<_i71.SaveContactsUseCase>(
      () => _i71.SaveContactsUseCase(gh<_i56.ChatRepository>()));
  gh.factory<_i72.SendErrorToServerUseCase>(
      () => _i72.SendErrorToServerUseCase(gh<_i56.ChatRepository>()));
  gh.factory<_i73.SendMessageUseCase>(
      () => _i73.SendMessageUseCase(gh<_i56.ChatRepository>()));
  gh.factory<_i74.UploadFileUseCase>(
      () => _i74.UploadFileUseCase(gh<_i56.ChatRepository>()));
  gh.factory<_i75.AnswerCallUseCase>(
      () => _i75.AnswerCallUseCase(gh<_i54.CallsRepository>()));
  gh.factory<_i76.DeleteMessageUseCase>(
      () => _i76.DeleteMessageUseCase(gh<_i54.CallsRepository>()));
  gh.factory<_i77.GetAgoraTokenUseCase>(
      () => _i77.GetAgoraTokenUseCase(gh<_i54.CallsRepository>()));
  gh.factory<_i78.GetMissedCalCountUseCase>(
      () => _i78.GetMissedCalCountUseCase(gh<_i54.CallsRepository>()));
  gh.factory<_i79.GetMyCallsUseCase>(
      () => _i79.GetMyCallsUseCase(gh<_i54.CallsRepository>()));
  gh.factory<_i80.MakeCallUseCase>(
      () => _i80.MakeCallUseCase(gh<_i54.CallsRepository>()));
  gh.factory<_i81.RejectCallUseCase>(
      () => _i81.RejectCallUseCase(gh<_i54.CallsRepository>()));
  gh.factory<_i82.WatchMissedCallUseCase>(
      () => _i82.WatchMissedCallUseCase(gh<_i54.CallsRepository>()));
  gh.lazySingleton<_i83.HomeBloc>(() => _i83.HomeBloc(
        gh<_i44.GetMainCategoriesUseCase>(),
        gh<_i49.GetStoryForProductUseCase>(),
        gh<_i51.GetCartItemUseCase>(),
        gh<_i50.GetCommentForProductUseCase>(),
        gh<_i43.GetHomeBoutiqesUseCase>(),
        gh<_i47.GetProductFiltersUseCase>(),
        gh<_i25.GetWidthAndHeightUseCase>(),
        gh<_i46.GetProductDetailWithoutRelatedProductsUseCase>(),
        gh<_i48.GetStartingSettingsUseCase>(),
        gh<_i45.GetProductsWithoutFiltersUseCase>(),
      ));
  gh.lazySingleton<_i84.StoryBloc>(() => _i84.StoryBloc(
        gh<_i58.UploadFileCloudinaryUseCase>(),
        gh<_i24.GetStoryUseCase>(),
        gh<_i25.GetWidthAndHeightUseCase>(),
        gh<_i27.UploadStoryUseCase>(),
        gh<_i26.IncreaseViewersUseCase>(),
        gh<_i23.AddStoryToOurServerUseCase>(),
      ));
  gh.lazySingleton<_i85.ChatBloc>(() => _i85.ChatBloc(
        gh<_i62.GetContactsUseCase>(),
        gh<_i68.GetMyChatsUseCase>(),
        gh<_i71.SaveContactsUseCase>(),
        gh<_i73.SendMessageUseCase>(),
        gh<_i66.GetMessagesBetweenUseCase>(),
        gh<_i58.UploadFileCloudinaryUseCase>(),
        gh<_i67.GetMessagesForChatUseCase>(),
        gh<_i61.DeleteChatUseCase>(),
        gh<_i60.ChangeChatPropertyUseCase>(),
        gh<_i74.UploadFileUseCase>(),
        gh<_i69.ReadAllMessagesUseCase>(),
        gh<_i70.ReceiveMessageUseCase>(),
        gh<_i65.GetMediaCountUseCase>(),
        gh<_i63.GetDateTimeUseCase>(),
        gh<_i72.SendErrorToServerUseCase>(),
      ));
  gh.lazySingleton<_i86.CallsBloc>(() => _i86.CallsBloc(
        gh<_i81.RejectCallUseCase>(),
        gh<_i80.MakeCallUseCase>(),
        gh<_i79.GetMyCallsUseCase>(),
        gh<_i82.WatchMissedCallUseCase>(),
        gh<_i75.AnswerCallUseCase>(),
        gh<_i78.GetMissedCalCountUseCase>(),
        gh<_i77.GetAgoraTokenUseCase>(),
        gh<_i76.DeleteMessageUseCase>(),
      ));
  gh.lazySingleton<_i87.AuthBloc>(() => _i87.AuthBloc(
        gh<_i39.UpdateStoriesUserUseCase>(),
        gh<_i37.UpdateChatUserNameUseCase>(),
        gh<_i59.CreateUserUseCase>(),
        gh<_i31.LoginToChatUseCase>(),
        gh<_i32.LoginToMarketUseCase>(),
        gh<_i33.LoginToStoriesUseCase>(),
        gh<_i36.StoreFcmUseCase>(),
        gh<_i38.UpdateNameUseCase>(),
        gh<_i34.RegisterGuestUseCase>(),
        gh<_i35.SendOtpUseCase>(),
        gh<_i29.GetCustomerInfoUseCase>(),
        gh<_i40.VerifyGuestPhoneUseCase>(),
        gh<_i41.VerifyOtpSignInUseCase>(),
        gh<_i30.GetUserCountryUseCase>(),
        gh<_i42.VerifyOtpSignUpUseCase>(),
      ));
  return getIt;
}

class _$AppModule extends _i88.AppModule {}
