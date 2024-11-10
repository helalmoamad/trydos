// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:logger/logger.dart' as _i974;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/app/blocs/app_bloc/app_bloc.dart' as _i721;
import '../../features/app/blocs/pre_caching_image_bloc/pre_caching_image_bloc.dart'
    as _i1026;
import '../../features/app/blocs/sensitive_connectivity/sensitive_connectivity_bloc.dart'
    as _i274;
import '../../features/authentication/data/data_sources/auth_remote_datasource.dart'
    as _i539;
import '../../features/authentication/data/repositories/auth_repository_impl.dart'
    as _i317;
import '../../features/authentication/domain/repositories/auth_repository.dart'
    as _i742;
import '../../features/authentication/domain/use_cases/create_user_usecase.dart'
    as _i589;
import '../../features/authentication/domain/use_cases/delete_fcm_usecase.dart'
    as _i260;
import '../../features/authentication/domain/use_cases/get_customer_info_usecase.dart'
    as _i862;
import '../../features/authentication/domain/use_cases/get_user_country_usecase.dart'
    as _i644;
import '../../features/authentication/domain/use_cases/login_to_chat_usecase.dart'
    as _i919;
import '../../features/authentication/domain/use_cases/login_to_market_usecase.dart'
    as _i832;
import '../../features/authentication/domain/use_cases/login_to_stories_usecase.dart'
    as _i656;
import '../../features/authentication/domain/use_cases/register_guest_usecase.dart'
    as _i49;
import '../../features/authentication/domain/use_cases/send_otp_usecase.dart'
    as _i952;
import '../../features/authentication/domain/use_cases/store_fcm_usecase.dart'
    as _i142;
import '../../features/authentication/domain/use_cases/update_chat_user_name_usecase.dart'
    as _i730;
import '../../features/authentication/domain/use_cases/update_name_usecase.dart'
    as _i58;
import '../../features/authentication/domain/use_cases/update_stories_user_usecase.dart'
    as _i434;
import '../../features/authentication/domain/use_cases/verify_guest_phone_usecase.dart'
    as _i236;
import '../../features/authentication/domain/use_cases/verify_otp_signin_usecase.dart'
    as _i574;
import '../../features/authentication/domain/use_cases/verify_otp_signup_usecase.dart'
    as _i282;
import '../../features/authentication/presentation/manager/auth_bloc.dart'
    as _i561;
import '../../features/calls/data/data_source/calls_remote_data_source_model.dart'
    as _i1061;
import '../../features/calls/data/repositories/calls_repository_impl.dart'
    as _i722;
import '../../features/calls/domain/repositories/calls_repository.dart'
    as _i1032;
import '../../features/calls/domain/useCase/answer_call_usecase.dart' as _i661;
import '../../features/calls/domain/useCase/delete_Message.dart' as _i95;
import '../../features/calls/domain/useCase/get_agora_token_use_case.dart'
    as _i1014;
import '../../features/calls/domain/useCase/get_missed_call_count.dart'
    as _i767;
import '../../features/calls/domain/useCase/get_my_calls.dart' as _i177;
import '../../features/calls/domain/useCase/make_call_usecase.dart' as _i643;
import '../../features/calls/domain/useCase/reject_call_usecase.dart' as _i711;
import '../../features/calls/domain/useCase/watch_missed_call.dart' as _i961;
import '../../features/calls/presentation/bloc/calls_bloc.dart' as _i547;
import '../../features/chat/data/data_sources/chat_remote_datasource.dart'
    as _i375;
import '../../features/chat/data/repositories/chat_repository_impl.dart'
    as _i504;
import '../../features/chat/domain/repositories/chat_repository.dart' as _i420;
import '../../features/chat/domain/use_cases/change_chat_property_usecase.dart'
    as _i142;
import '../../features/chat/domain/use_cases/delete_chat_usecase.dart' as _i361;
import '../../features/chat/domain/use_cases/get_contacts_usecase.dart'
    as _i418;
import '../../features/chat/domain/use_cases/get_date_time.dart' as _i668;
import '../../features/chat/domain/use_cases/get_image_width_and_height_usecase.dart'
    as _i148;
import '../../features/chat/domain/use_cases/get_media_count_usecase.dart'
    as _i109;
import '../../features/chat/domain/use_cases/get_messages_between_usecase.dart'
    as _i912;
import '../../features/chat/domain/use_cases/get_messages_for_chat_usecase.dart'
    as _i304;
import '../../features/chat/domain/use_cases/get_my_chats_usecase.dart'
    as _i675;
import '../../features/chat/domain/use_cases/get_shared_product_count_usecase.dart'
    as _i538;
import '../../features/chat/domain/use_cases/read_all_messages_usecase.dart'
    as _i314;
import '../../features/chat/domain/use_cases/receive_message_usecase.dart'
    as _i40;
import '../../features/chat/domain/use_cases/save_contacts_usecase.dart'
    as _i777;
import '../../features/chat/domain/use_cases/send_error_to_server_usecase.dart'
    as _i677;
import '../../features/chat/domain/use_cases/send_message_usecase.dart'
    as _i703;
import '../../features/chat/domain/use_cases/share_product_on_social_app_count_usecase.dart'
    as _i710;
import '../../features/chat/domain/use_cases/share_product_with_contacts_or_channels_usecase.dart'
    as _i139;
import '../../features/chat/domain/use_cases/upload_file_usecase.dart' as _i897;
import '../../features/chat/presentation/manager/chat_bloc.dart' as _i243;
import '../../features/chat/presentation/manager/preload_bloc/preloading_videos_bloc.dart'
    as _i243;
import '../../features/home/data/data_sources/home_remote_data_source.dart'
    as _i350;
import '../../features/home/data/repositories/home_repository_implementation.dart'
    as _i437;
import '../../features/home/domain/repositories/home_repository.dart' as _i0;
import '../../features/home/domain/use_cases/add_comment_usecase.dart' as _i68;
import '../../features/home/domain/use_cases/add_item_to_cart_usecase.dart'
    as _i1035;
import '../../features/home/domain/use_cases/add_like_to_product_usecase.dart'
    as _i33;
import '../../features/home/domain/use_cases/convert_item_from_oldCart_to_Cart_usecase.dart'
    as _i190;
import '../../features/home/domain/use_cases/delete_like_of_product_usecase.dart'
    as _i878;
import '../../features/home/domain/use_cases/get_allowed_country_usecase.dart'
    as _i318;
import '../../features/home/domain/use_cases/get_cart_item_usecase.dart'
    as _i307;
import '../../features/home/domain/use_cases/get_count_view_of_product_usecase.dart'
    as _i922;
import '../../features/home/domain/use_cases/get_currency_for_country_usecase.dart'
    as _i762;
import '../../features/home/domain/use_cases/get_full_product_details_usecase.dart'
    as _i149;
import '../../features/home/domain/use_cases/get_home_boutiqes_usecase.dart'
    as _i518;
import '../../features/home/domain/use_cases/get_main_categories_usecase.dart'
    as _i158;
import '../../features/home/domain/use_cases/get_old_cart_item_usecase.dart'
    as _i318;
import '../../features/home/domain/use_cases/get_product_detail_without_related_products_uswcase.dart'
    as _i347;
import '../../features/home/domain/use_cases/get_product_filters_usecase.dart'
    as _i290;
import '../../features/home/domain/use_cases/get_product_list_in_cart_usecase.dart'
    as _i749;
import '../../features/home/domain/use_cases/get_products_usecase.dart'
    as _i397;
import '../../features/home/domain/use_cases/get_products_with_filters_usecase.dart'
    as _i955;
import '../../features/home/domain/use_cases/get_starting_settings_usecase.dart'
    as _i815;
import '../../features/home/domain/use_cases/get_stories_for_product_usecase.dart'
    as _i533;
import '../../features/home/domain/use_cases/GetCommentForProductUseCase.dart'
    as _i939;
import '../../features/home/domain/use_cases/hide_item_from_oldCart_usecase.dart'
    as _i104;
import '../../features/home/domain/use_cases/remove_item_from_cart_usecase.dart'
    as _i687;
import '../../features/home/domain/use_cases/request_for_notification_when_product_became_available_usecase.dart'
    as _i715;
import '../../features/home/domain/use_cases/update_item_from_cart_usecase.dart'
    as _i802;
import '../../features/home/presentation/manager/home_bloc.dart' as _i801;
import '../../features/story/data/data_source/story_data_source.dart' as _i777;
import '../../features/story/data/repository/story_repository_impl.dart'
    as _i213;
import '../../features/story/domain/repository/story_repository.dart' as _i505;
import '../../features/story/domain/useCases/add_story_to_our_server_usecase.dart'
    as _i737;
import '../../features/story/domain/useCases/get_stories_usecase.dart' as _i804;
import '../../features/story/domain/useCases/get_width_and_height_usecase.dart'
    as _i912;
import '../../features/story/domain/useCases/increase_viewers_usecase.dart'
    as _i4;
import '../../features/story/domain/useCases/upload_story_usecase.dart'
    as _i290;
import '../../features/story/presentation/bloc/story_bloc.dart' as _i536;
import '../data/data_source/common_use_repo_data_source.dart' as _i672;
import '../data/repository/common_use_repository_impl.dart' as _i77;
import '../domin/repositories/common_use_repository.dart' as _i702;
import '../domin/repositories/prefs_repository.dart' as _i658;
import '../domin/usecases/upload_file_cloudinary_usecase.dart' as _i1043;
import 'di_container.dart' as _i198;

// initializes the registration of main-scope dependencies inside of GetIt
Future<_i174.GetIt> $initGetIt(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) async {
  final gh = _i526.GetItHelper(
    getIt,
    environment,
    environmentFilter,
  );
  final appModule = _$AppModule();
  gh.factory<_i672.CommonUseRemoteDataSource>(
      () => _i672.CommonUseRemoteDataSource());
  gh.factory<_i361.BaseOptions>(() => appModule.dioOption);
  gh.factory<_i274.SensitiveConnectivityBloc>(
      () => _i274.SensitiveConnectivityBloc());
  gh.factory<_i539.AuthRemoteDatasource>(() => _i539.AuthRemoteDatasource());
  gh.factory<_i1061.CallsRemoteDataSource>(
      () => _i1061.CallsRemoteDataSource());
  gh.factory<_i375.ChatRemoteDataSource>(() => _i375.ChatRemoteDataSource());
  gh.factory<_i243.PreloadingVideosBloc>(() => _i243.PreloadingVideosBloc());
  gh.factory<_i350.HomeRemoteDatasource>(() => _i350.HomeRemoteDatasource());
  gh.factory<_i777.StoriesDataSource>(() => _i777.StoriesDataSource());
  gh.singleton<_i974.Logger>(() => appModule.logger);
  await gh.singletonAsync<_i460.SharedPreferences>(
    () => appModule.sharedPreferences,
    preResolve: true,
  );
  await gh.singletonAsync<_i658.PrefsRepository>(
    () => appModule.prefsRepository,
    preResolve: true,
  );
  gh.lazySingleton<_i721.AppBloc>(() => _i721.AppBloc());
  gh.lazySingleton<_i1026.PreCachingImageBloc>(
      () => _i1026.PreCachingImageBloc());
  gh.lazySingleton<_i505.StoryRepository>(
      () => _i213.StoryRepositoryImpl(gh<_i777.StoriesDataSource>()));
  gh.lazySingleton<_i0.HomeRepository>(
      () => _i437.HomeRepositoryImpl(gh<_i350.HomeRemoteDatasource>()));
  gh.lazySingleton<_i742.AuthRepository>(
      () => _i317.AuthRepositoryImpl(gh<_i539.AuthRemoteDatasource>()));
  gh.factory<_i737.AddStoryToOurServerUseCase>(
      () => _i737.AddStoryToOurServerUseCase(gh<_i505.StoryRepository>()));
  gh.factory<_i804.GetStoryUseCase>(
      () => _i804.GetStoryUseCase(gh<_i505.StoryRepository>()));
  gh.factory<_i912.GetWidthAndHeightUseCase>(
      () => _i912.GetWidthAndHeightUseCase(gh<_i505.StoryRepository>()));
  gh.factory<_i4.IncreaseViewersUseCase>(
      () => _i4.IncreaseViewersUseCase(gh<_i505.StoryRepository>()));
  gh.factory<_i290.UploadStoryUseCase>(
      () => _i290.UploadStoryUseCase(gh<_i505.StoryRepository>()));
  gh.singleton<_i361.Dio>(() => appModule.dio(
        gh<_i361.BaseOptions>(),
        gh<_i974.Logger>(),
      ));
  gh.factory<_i260.DeleteFcmUseCase>(
      () => _i260.DeleteFcmUseCase(gh<_i742.AuthRepository>()));
  gh.factory<_i862.GetCustomerInfoUseCase>(
      () => _i862.GetCustomerInfoUseCase(gh<_i742.AuthRepository>()));
  gh.factory<_i644.GetUserCountryUseCase>(
      () => _i644.GetUserCountryUseCase(gh<_i742.AuthRepository>()));
  gh.factory<_i919.LoginToChatUseCase>(
      () => _i919.LoginToChatUseCase(gh<_i742.AuthRepository>()));
  gh.factory<_i832.LoginToMarketUseCase>(
      () => _i832.LoginToMarketUseCase(gh<_i742.AuthRepository>()));
  gh.factory<_i656.LoginToStoriesUseCase>(
      () => _i656.LoginToStoriesUseCase(gh<_i742.AuthRepository>()));
  gh.factory<_i49.RegisterGuestUseCase>(
      () => _i49.RegisterGuestUseCase(gh<_i742.AuthRepository>()));
  gh.factory<_i952.SendOtpUseCase>(
      () => _i952.SendOtpUseCase(gh<_i742.AuthRepository>()));
  gh.factory<_i142.StoreFcmUseCase>(
      () => _i142.StoreFcmUseCase(gh<_i742.AuthRepository>()));
  gh.factory<_i730.UpdateChatUserNameUseCase>(
      () => _i730.UpdateChatUserNameUseCase(gh<_i742.AuthRepository>()));
  gh.factory<_i58.UpdateNameUseCase>(
      () => _i58.UpdateNameUseCase(gh<_i742.AuthRepository>()));
  gh.factory<_i434.UpdateStoriesUserUseCase>(
      () => _i434.UpdateStoriesUserUseCase(gh<_i742.AuthRepository>()));
  gh.factory<_i236.VerifyGuestPhoneUseCase>(
      () => _i236.VerifyGuestPhoneUseCase(gh<_i742.AuthRepository>()));
  gh.factory<_i574.VerifyOtpSignInUseCase>(
      () => _i574.VerifyOtpSignInUseCase(gh<_i742.AuthRepository>()));
  gh.factory<_i282.VerifyOtpSignUpUseCase>(
      () => _i282.VerifyOtpSignUpUseCase(gh<_i742.AuthRepository>()));
  gh.factory<_i68.AddCommentUseCase>(
      () => _i68.AddCommentUseCase(gh<_i0.HomeRepository>()));
  gh.factory<_i1035.AddItemToCartUseCase>(
      () => _i1035.AddItemToCartUseCase(gh<_i0.HomeRepository>()));
  gh.factory<_i33.AddLikeToProductUsecase>(
      () => _i33.AddLikeToProductUsecase(gh<_i0.HomeRepository>()));
  gh.factory<_i878.DeleteLikeOfProductUsecase>(
      () => _i878.DeleteLikeOfProductUsecase(gh<_i0.HomeRepository>()));
  gh.factory<_i939.GetCommentForProductUseCase>(
      () => _i939.GetCommentForProductUseCase(gh<_i0.HomeRepository>()));
  gh.factory<_i318.GetAllowedCountryUseCase>(
      () => _i318.GetAllowedCountryUseCase(gh<_i0.HomeRepository>()));
  gh.factory<_i307.GetCartItemUseCase>(
      () => _i307.GetCartItemUseCase(gh<_i0.HomeRepository>()));
  gh.factory<_i762.GetCurrencyForCountryUseCase>(
      () => _i762.GetCurrencyForCountryUseCase(gh<_i0.HomeRepository>()));
  gh.factory<_i149.GetFullProductDetailsUseCase>(
      () => _i149.GetFullProductDetailsUseCase(gh<_i0.HomeRepository>()));
  gh.factory<_i518.GetHomeBoutiqesUseCase>(
      () => _i518.GetHomeBoutiqesUseCase(gh<_i0.HomeRepository>()));
  gh.factory<_i158.GetMainCategoriesUseCase>(
      () => _i158.GetMainCategoriesUseCase(gh<_i0.HomeRepository>()));
  gh.factory<_i397.GetProductsWithoutFiltersUseCase>(
      () => _i397.GetProductsWithoutFiltersUseCase(gh<_i0.HomeRepository>()));
  gh.factory<_i955.GetProductsWithFiltersUseCase>(
      () => _i955.GetProductsWithFiltersUseCase(gh<_i0.HomeRepository>()));
  gh.factory<_i347.GetProductDetailWithoutRelatedProductsUseCase>(() =>
      _i347.GetProductDetailWithoutRelatedProductsUseCase(
          gh<_i0.HomeRepository>()));
  gh.factory<_i290.GetProductFiltersUseCase>(
      () => _i290.GetProductFiltersUseCase(gh<_i0.HomeRepository>()));
  gh.factory<_i815.GetStartingSettingsUseCase>(
      () => _i815.GetStartingSettingsUseCase(gh<_i0.HomeRepository>()));
  gh.factory<_i533.GetStoryForProductUseCase>(
      () => _i533.GetStoryForProductUseCase(gh<_i0.HomeRepository>()));
  gh.factory<_i687.RemoveItemToCartUseCase>(
      () => _i687.RemoveItemToCartUseCase(gh<_i0.HomeRepository>()));
  gh.factory<_i715.RequestForNotificationWhenProductBecameAvailableUseCase>(
      () => _i715.RequestForNotificationWhenProductBecameAvailableUseCase(
          gh<_i0.HomeRepository>()));
  gh.factory<_i802.UpdateItemInCartUseCase>(
      () => _i802.UpdateItemInCartUseCase(gh<_i0.HomeRepository>()));
  gh.factory<_i190.ConvertItemFromOldcartToCartUsecase>(() =>
      _i190.ConvertItemFromOldcartToCartUsecase(gh<_i0.HomeRepository>()));
  gh.factory<_i922.GetAndAddCountViewOfProductUsecase>(
      () => _i922.GetAndAddCountViewOfProductUsecase(gh<_i0.HomeRepository>()));
  gh.factory<_i318.GetOldCartItemUseCase>(
      () => _i318.GetOldCartItemUseCase(gh<_i0.HomeRepository>()));
  gh.factory<_i104.HideItemsInOldCartUseCase>(
      () => _i104.HideItemsInOldCartUseCase(gh<_i0.HomeRepository>()));
  gh.factory<_i749.GetProductsListInCartUseCase>(
      () => _i749.GetProductsListInCartUseCase(gh<_i0.HomeRepository>()));
  gh.lazySingleton<_i702.CommonUseRepository>(() =>
      _i77.CommonUseRepositoryImpl(gh<_i672.CommonUseRemoteDataSource>()));
  gh.lazySingleton<_i801.HomeBloc>(() => _i801.HomeBloc(
        gh<_i158.GetMainCategoriesUseCase>(),
        gh<_i533.GetStoryForProductUseCase>(),
        gh<_i687.RemoveItemToCartUseCase>(),
        gh<_i190.ConvertItemFromOldcartToCartUsecase>(),
        gh<_i307.GetCartItemUseCase>(),
        gh<_i318.GetOldCartItemUseCase>(),
        gh<_i878.DeleteLikeOfProductUsecase>(),
        gh<_i33.AddLikeToProductUsecase>(),
        gh<_i802.UpdateItemInCartUseCase>(),
        gh<_i1035.AddItemToCartUseCase>(),
        gh<_i939.GetCommentForProductUseCase>(),
        gh<_i518.GetHomeBoutiqesUseCase>(),
        gh<_i749.GetProductsListInCartUseCase>(),
        gh<_i290.GetProductFiltersUseCase>(),
        gh<_i318.GetAllowedCountryUseCase>(),
        gh<_i912.GetWidthAndHeightUseCase>(),
        gh<_i347.GetProductDetailWithoutRelatedProductsUseCase>(),
        gh<_i815.GetStartingSettingsUseCase>(),
        gh<_i762.GetCurrencyForCountryUseCase>(),
        gh<_i104.HideItemsInOldCartUseCase>(),
        gh<_i149.GetFullProductDetailsUseCase>(),
        gh<_i922.GetAndAddCountViewOfProductUsecase>(),
        gh<_i397.GetProductsWithoutFiltersUseCase>(),
        gh<_i68.AddCommentUseCase>(),
        gh<_i715.RequestForNotificationWhenProductBecameAvailableUseCase>(),
        gh<_i955.GetProductsWithFiltersUseCase>(),
      ));
  gh.lazySingleton<_i1032.CallsRepository>(
      () => _i722.CallsRepositoryImpl(gh<_i1061.CallsRemoteDataSource>()));
  gh.lazySingleton<_i420.ChatRepository>(
      () => _i504.ChatRepositoryImpl(gh<_i375.ChatRemoteDataSource>()));
  gh.factory<_i1043.UploadFileCloudinaryUseCase>(() =>
      _i1043.UploadFileCloudinaryUseCase(gh<_i702.CommonUseRepository>()));
  gh.factory<_i589.CreateUserUseCase>(
      () => _i589.CreateUserUseCase(gh<_i420.ChatRepository>()));
  gh.factory<_i142.ChangeChatPropertyUseCase>(
      () => _i142.ChangeChatPropertyUseCase(gh<_i420.ChatRepository>()));
  gh.factory<_i361.DeleteChatUseCase>(
      () => _i361.DeleteChatUseCase(gh<_i420.ChatRepository>()));
  gh.factory<_i418.GetContactsUseCase>(
      () => _i418.GetContactsUseCase(gh<_i420.ChatRepository>()));
  gh.factory<_i668.GetDateTimeUseCase>(
      () => _i668.GetDateTimeUseCase(gh<_i420.ChatRepository>()));
  gh.factory<_i148.GetWidthAndHeightUseCase>(
      () => _i148.GetWidthAndHeightUseCase(gh<_i420.ChatRepository>()));
  gh.factory<_i109.GetMediaCountUseCase>(
      () => _i109.GetMediaCountUseCase(gh<_i420.ChatRepository>()));
  gh.factory<_i912.GetMessagesBetweenUseCase>(
      () => _i912.GetMessagesBetweenUseCase(gh<_i420.ChatRepository>()));
  gh.factory<_i304.GetMessagesForChatUseCase>(
      () => _i304.GetMessagesForChatUseCase(gh<_i420.ChatRepository>()));
  gh.factory<_i675.GetMyChatsUseCase>(
      () => _i675.GetMyChatsUseCase(gh<_i420.ChatRepository>()));
  gh.factory<_i538.GetSharedProductCountUseCase>(
      () => _i538.GetSharedProductCountUseCase(gh<_i420.ChatRepository>()));
  gh.factory<_i314.ReadAllMessagesUseCase>(
      () => _i314.ReadAllMessagesUseCase(gh<_i420.ChatRepository>()));
  gh.factory<_i40.ReceiveMessageUseCase>(
      () => _i40.ReceiveMessageUseCase(gh<_i420.ChatRepository>()));
  gh.factory<_i777.SaveContactsUseCase>(
      () => _i777.SaveContactsUseCase(gh<_i420.ChatRepository>()));
  gh.factory<_i677.SendErrorToServerUseCase>(
      () => _i677.SendErrorToServerUseCase(gh<_i420.ChatRepository>()));
  gh.factory<_i703.SendMessageUseCase>(
      () => _i703.SendMessageUseCase(gh<_i420.ChatRepository>()));
  gh.factory<_i710.ShareProductOnAppsUseCase>(
      () => _i710.ShareProductOnAppsUseCase(gh<_i420.ChatRepository>()));
  gh.factory<_i139.ShareProductWithContactsOrChannelsUsecase>(() =>
      _i139.ShareProductWithContactsOrChannelsUsecase(
          gh<_i420.ChatRepository>()));
  gh.factory<_i897.UploadFileUseCase>(
      () => _i897.UploadFileUseCase(gh<_i420.ChatRepository>()));
  gh.factory<_i661.AnswerCallUseCase>(
      () => _i661.AnswerCallUseCase(gh<_i1032.CallsRepository>()));
  gh.factory<_i95.DeleteMessageUseCase>(
      () => _i95.DeleteMessageUseCase(gh<_i1032.CallsRepository>()));
  gh.factory<_i1014.GetAgoraTokenUseCase>(
      () => _i1014.GetAgoraTokenUseCase(gh<_i1032.CallsRepository>()));
  gh.factory<_i767.GetMissedCalCountUseCase>(
      () => _i767.GetMissedCalCountUseCase(gh<_i1032.CallsRepository>()));
  gh.factory<_i177.GetMyCallsUseCase>(
      () => _i177.GetMyCallsUseCase(gh<_i1032.CallsRepository>()));
  gh.factory<_i643.MakeCallUseCase>(
      () => _i643.MakeCallUseCase(gh<_i1032.CallsRepository>()));
  gh.factory<_i711.RejectCallUseCase>(
      () => _i711.RejectCallUseCase(gh<_i1032.CallsRepository>()));
  gh.factory<_i961.WatchMissedCallUseCase>(
      () => _i961.WatchMissedCallUseCase(gh<_i1032.CallsRepository>()));
  gh.lazySingleton<_i536.StoryBloc>(() => _i536.StoryBloc(
        gh<_i1043.UploadFileCloudinaryUseCase>(),
        gh<_i804.GetStoryUseCase>(),
        gh<_i912.GetWidthAndHeightUseCase>(),
        gh<_i290.UploadStoryUseCase>(),
        gh<_i4.IncreaseViewersUseCase>(),
        gh<_i737.AddStoryToOurServerUseCase>(),
      ));
  gh.lazySingleton<_i547.CallsBloc>(() => _i547.CallsBloc(
        gh<_i711.RejectCallUseCase>(),
        gh<_i643.MakeCallUseCase>(),
        gh<_i177.GetMyCallsUseCase>(),
        gh<_i961.WatchMissedCallUseCase>(),
        gh<_i661.AnswerCallUseCase>(),
        gh<_i767.GetMissedCalCountUseCase>(),
        gh<_i1014.GetAgoraTokenUseCase>(),
        gh<_i95.DeleteMessageUseCase>(),
      ));
  gh.lazySingleton<_i243.ChatBloc>(() => _i243.ChatBloc(
        gh<_i418.GetContactsUseCase>(),
        gh<_i675.GetMyChatsUseCase>(),
        gh<_i710.ShareProductOnAppsUseCase>(),
        gh<_i777.SaveContactsUseCase>(),
        gh<_i703.SendMessageUseCase>(),
        gh<_i538.GetSharedProductCountUseCase>(),
        gh<_i912.GetMessagesBetweenUseCase>(),
        gh<_i1043.UploadFileCloudinaryUseCase>(),
        gh<_i304.GetMessagesForChatUseCase>(),
        gh<_i361.DeleteChatUseCase>(),
        gh<_i142.ChangeChatPropertyUseCase>(),
        gh<_i897.UploadFileUseCase>(),
        gh<_i314.ReadAllMessagesUseCase>(),
        gh<_i40.ReceiveMessageUseCase>(),
        gh<_i139.ShareProductWithContactsOrChannelsUsecase>(),
        gh<_i109.GetMediaCountUseCase>(),
        gh<_i668.GetDateTimeUseCase>(),
        gh<_i677.SendErrorToServerUseCase>(),
      ));
  gh.lazySingleton<_i561.AuthBloc>(() => _i561.AuthBloc(
        gh<_i434.UpdateStoriesUserUseCase>(),
        gh<_i730.UpdateChatUserNameUseCase>(),
        gh<_i589.CreateUserUseCase>(),
        gh<_i919.LoginToChatUseCase>(),
        gh<_i656.LoginToStoriesUseCase>(),
        gh<_i142.StoreFcmUseCase>(),
        gh<_i58.UpdateNameUseCase>(),
        gh<_i49.RegisterGuestUseCase>(),
        gh<_i952.SendOtpUseCase>(),
        gh<_i862.GetCustomerInfoUseCase>(),
        gh<_i236.VerifyGuestPhoneUseCase>(),
        gh<_i574.VerifyOtpSignInUseCase>(),
        gh<_i644.GetUserCountryUseCase>(),
        gh<_i282.VerifyOtpSignUpUseCase>(),
      ));
  return getIt;
}

class _$AppModule extends _i198.AppModule {}
