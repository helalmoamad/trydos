// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

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
import '../../features/authentication/domain/use_cases/create_wallet_usecase.dart'
    as _i650;
import '../../features/authentication/domain/use_cases/delete_fcm_from_chat_usecase.dart'
    as _i231;
import '../../features/authentication/domain/use_cases/generating_token_for_comment.dart'
    as _i100;
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
import '../../features/authentication/domain/use_cases/login_to_wallet_usecase.dart'
    as _i304;
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
import '../../features/authentication/domain/use_cases/verify_otp_in_profile_usecase.dart'
    as _i995;
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
import '../../features/calls/domain/useCase/end_call_usecase.dart' as _i592;
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
import '../../features/chat/domain/use_cases/block_user_id_usecase.dart'
    as _i900;
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
import '../../features/chat/domain/use_cases/get_order_recipient_id_usecase.dart'
    as _i1039;
import '../../features/chat/domain/use_cases/get_shared_product_count_usecase.dart'
    as _i538;
import '../../features/chat/domain/use_cases/read_all_messages_usecase.dart'
    as _i314;
import '../../features/chat/domain/use_cases/receive_message_usecase.dart'
    as _i40;
import '../../features/chat/domain/use_cases/save_contacts_usecase.dart'
    as _i777;
import '../../features/chat/domain/use_cases/search_For_message_text_in_chat_usecase.dart'
    as _i925;
import '../../features/chat/domain/use_cases/send_error_to_server_usecase.dart'
    as _i677;
import '../../features/chat/domain/use_cases/send_message_usecase.dart'
    as _i703;
import '../../features/chat/domain/use_cases/share_product_on_social_app_count_usecase.dart'
    as _i710;
import '../../features/chat/domain/use_cases/share_product_with_contacts_or_channels_usecase.dart'
    as _i139;
import '../../features/chat/domain/use_cases/update_profile_chat_usecase.dart'
    as _i750;
import '../../features/chat/domain/use_cases/upload_file_usecase.dart' as _i897;
import '../../features/chat/presentation/manager/chat_bloc.dart' as _i243;
import '../../features/chat/presentation/manager/preload_bloc/preloading_videos_bloc.dart'
    as _i243;
import '../../features/dashBoard/data/data_source/dashBoard_remote_data_source_model.dart'
    as _i57;
import '../../features/dashBoard/data/repositories/dashBoard_repository_impl.dart'
    as _i161;
import '../../features/dashBoard/domain/repositories/dashBoard_repository.dart'
    as _i70;
import '../../features/dashBoard/domain/useCase/add_user_usecase.dart' as _i602;
import '../../features/dashBoard/domain/useCase/change_order_detail_status.dart'
    as _i553;
import '../../features/dashBoard/domain/useCase/change_order_status_usecase.dart'
    as _i645;
import '../../features/dashBoard/domain/useCase/change_orderDetail_to_packed_useCase.dart'
    as _i288;
import '../../features/dashBoard/domain/useCase/delete_user_usecase.dart'
    as _i441;
import '../../features/dashBoard/domain/useCase/get_boutiques_usecase.dart'
    as _i412;
import '../../features/dashBoard/domain/useCase/get_orders_usecase.dart'
    as _i919;
import '../../features/dashBoard/domain/useCase/get_presigned_url_usecase.dart'
    as _i781;
import '../../features/dashBoard/domain/useCase/get_products_usecase.dart'
    as _i51;
import '../../features/dashBoard/domain/useCase/get_user_permission_usecase.dart.dart'
    as _i652;
import '../../features/dashBoard/domain/useCase/get_user_roles_usecase.dart'
    as _i246;
import '../../features/dashBoard/domain/useCase/get_users_usecase.dart'
    as _i900;
import '../../features/dashBoard/domain/useCase/get_vendor_request_usecase.dart'
    as _i135;
import '../../features/dashBoard/domain/useCase/leave_shop_usecase.dart'
    as _i858;
import '../../features/dashBoard/domain/useCase/newGetUserOrders_useCase.dart'
    as _i129;
import '../../features/dashBoard/domain/useCase/submit_vendor_request_usecase.dart'
    as _i916;
import '../../features/dashBoard/domain/useCase/update_user_role_usecase.dart'
    as _i1023;
import '../../features/dashBoard/domain/useCase/update_vendor_request_usecase.dart'
    as _i388;
import '../../features/dashBoard/domain/useCase/upload_file_to_s3_usecase.dart'
    as _i282;
import '../../features/dashBoard/presentation/bloc/dashBoard_bloc.dart'
    as _i976;
import '../../features/home/data/data_sources/home_remote_data_source.dart'
    as _i350;
import '../../features/home/data/repositories/home_repository_implementation.dart'
    as _i437;
import '../../features/home/domain/repositories/home_repository.dart' as _i0;
import '../../features/home/domain/use_cases/add_customer_address_usecase.dart'
    as _i70;
import '../../features/home/domain/use_cases/add_item_to_cart_usecase.dart'
    as _i1035;
import '../../features/home/domain/use_cases/add_like_to_product_usecase.dart'
    as _i33;
import '../../features/home/domain/use_cases/add_order_comment_usecase.dart'
    as _i823;
import '../../features/home/domain/use_cases/apply_coupon_usecase.dart'
    as _i493;
import '../../features/home/domain/use_cases/cancel_order_item_usecase.dart'
    as _i197;
import '../../features/home/domain/use_cases/cancel_order_usecase.dart'
    as _i811;
import '../../features/home/domain/use_cases/cancel_return_request_product_usecase.dart'
    as _i217;
import '../../features/home/domain/use_cases/cancel_return_request_usecase.dart'
    as _i441;
import '../../features/home/domain/use_cases/change_country_language_for_notification_usecase.dart'
    as _i814;
import '../../features/home/domain/use_cases/change_order_address_usecase.dart'
    as _i636;
import '../../features/home/domain/use_cases/change_order_item_variant_usecase.dart'
    as _i607;
import '../../features/home/domain/use_cases/check_availability_product_cart_usecase.dart'
    as _i812;
import '../../features/home/domain/use_cases/confirm_return_request_usecase.dart'
    as _i943;
import '../../features/home/domain/use_cases/convert_item_from_Cart_to_oldCart_usecase.dart'
    as _i94;
import '../../features/home/domain/use_cases/create_comment_order_rating.dart'
    as _i327;
import '../../features/home/domain/use_cases/delete_comment_order_rating.dart'
    as _i403;
import '../../features/home/domain/use_cases/delete_customer_address_usecase.dart'
    as _i71;
import '../../features/home/domain/use_cases/delete_like_of_product_usecase.dart'
    as _i878;
import '../../features/home/domain/use_cases/DeliveredOrdersResponse_usecase.dart'
    as _i504;
import '../../features/home/domain/use_cases/get_address_by_coordinate_usecase.dart'
    as _i970;
import '../../features/home/domain/use_cases/get_address_by_text_usecase.dart'
    as _i976;
import '../../features/home/domain/use_cases/get_allowed_country_usecase.dart'
    as _i318;
import '../../features/home/domain/use_cases/get_auth_product_details_usecase.dart'
    as _i143;
import '../../features/home/domain/use_cases/get_buyer_comments_usecase.dart'
    as _i626;
import '../../features/home/domain/use_cases/get_cart_item_usecase.dart'
    as _i307;
import '../../features/home/domain/use_cases/get_cart_overview_usecase.dart'
    as _i675;
import '../../features/home/domain/use_cases/get_colors_sizes_for_search_usecase.dart'
    as _i247;
import '../../features/home/domain/use_cases/get_count_view_of_product_usecase.dart'
    as _i922;
import '../../features/home/domain/use_cases/get_country_boundary_usecase.dart'
    as _i164;
import '../../features/home/domain/use_cases/get_currencies_usecase.dart'
    as _i603;
import '../../features/home/domain/use_cases/get_currency_for_country_usecase.dart'
    as _i762;
import '../../features/home/domain/use_cases/get_customer_addresses_usecase.dart'
    as _i489;
import '../../features/home/domain/use_cases/get_customer_wallet_usecase.dart'
    as _i361;
import '../../features/home/domain/use_cases/get_featured_products_usecase.dart'
    as _i146;
import '../../features/home/domain/use_cases/get_fqa_comments_usecase.dart'
    as _i131;
import '../../features/home/domain/use_cases/get_full_product_details_usecase.dart'
    as _i149;
import '../../features/home/domain/use_cases/get_home_boutiqes_usecase.dart'
    as _i518;
import '../../features/home/domain/use_cases/get_main_categories_usecase.dart'
    as _i158;
import '../../features/home/domain/use_cases/get_my_firebase_settings_usecase.dart'
    as _i171;
import '../../features/home/domain/use_cases/get_notification_type_for_product_usecase.dart'
    as _i929;
import '../../features/home/domain/use_cases/get_old_cart_item_usecase.dart'
    as _i318;
import '../../features/home/domain/use_cases/get_order_rating_usecase.dart'
    as _i863;
import '../../features/home/domain/use_cases/get_orders_by_cart_group_usecase.dart'
    as _i59;
import '../../features/home/domain/use_cases/get_orders_by_order_group_usecase.dart'
    as _i1003;
import '../../features/home/domain/use_cases/get_orders_usecase.dart' as _i558;
import '../../features/home/domain/use_cases/get_popular_search_terms_usecase.dart'
    as _i963;
import '../../features/home/domain/use_cases/get_product_color_size_sync_attribute_usecase.dart'
    as _i716;
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
import '../../features/home/domain/use_cases/get_provinces_by_iso_usecase.dart'
    as _i401;
import '../../features/home/domain/use_cases/get_recommend_products_usecase.dart'
    as _i889;
import '../../features/home/domain/use_cases/get_return_reasons_usecase.dart'
    as _i815;
import '../../features/home/domain/use_cases/get_starting_settings_usecase.dart'
    as _i815;
import '../../features/home/domain/use_cases/get_stories_for_product_usecase.dart'
    as _i533;
import '../../features/home/domain/use_cases/get_user_notification_usecase.dart'
    as _i1021;
import '../../features/home/domain/use_cases/GetRelatedProductsUseCase.dart'
    as _i1022;
import '../../features/home/domain/use_cases/hide_item_from_oldCart_usecase.dart'
    as _i104;
import '../../features/home/domain/use_cases/order_return_details_usecase.dart'
    as _i182;
import '../../features/home/domain/use_cases/order_return_requests_view_usecase.dart'
    as _i926;
import '../../features/home/domain/use_cases/place_order_usecase.dart' as _i649;
import '../../features/home/domain/use_cases/remove_item_from_cart_usecase.dart'
    as _i687;
import '../../features/home/domain/use_cases/request_for_notification_when_product_became_available_usecase.dart'
    as _i715;
import '../../features/home/domain/use_cases/search_by_images_usecase.dart'
    as _i889;
import '../../features/home/domain/use_cases/send_accept__of_notifications_usecase.dart'
    as _i608;
import '../../features/home/domain/use_cases/send_error_to_mobile_error_log.dart'
    as _i78;
import '../../features/home/domain/use_cases/set_customer_address_default_usecase.dart'
    as _i1064;
import '../../features/home/domain/use_cases/store_fcm_token_of_market_usecase.dart'
    as _i366;
import '../../features/home/domain/use_cases/store_return_request_product_usecase.dart'
    as _i285;
import '../../features/home/domain/use_cases/store_return_request_usecase.dart'
    as _i241;
import '../../features/home/domain/use_cases/subscribe_topic_for_notification_usecase.dart'
    as _i687;
import '../../features/home/domain/use_cases/translate_comment_usecase.dart'
    as _i358;
import '../../features/home/domain/use_cases/un_subscribe_topic_for_notification_usecase.dart'
    as _i424;
import '../../features/home/domain/use_cases/update_comment_order_rating.dart'
    as _i22;
import '../../features/home/domain/use_cases/update_customer_address_usecase.dart'
    as _i418;
import '../../features/home/domain/use_cases/update_email_notification_usecase.dart'
    as _i750;
import '../../features/home/domain/use_cases/update_firebase_notification_usecase.dart'
    as _i741;
import '../../features/home/domain/use_cases/update_item_from_cart_usecase.dart'
    as _i802;
import '../../features/home/domain/use_cases/update_like_comment_usecase.dart'
    as _i630;
import '../../features/home/domain/use_cases/update_like_share_product_usecase.dart'
    as _i580;
import '../../features/home/domain/use_cases/update_notification_frequency_usecase.dart'
    as _i432;
import '../../features/home/domain/use_cases/update_order_comment_usecase.dart'
    as _i1013;
import '../../features/home/domain/use_cases/update_profile_usecase.dart'
    as _i315;
import '../../features/home/domain/use_cases/update_return_request_product_usecase.dart'
    as _i799;
import '../../features/home/domain/use_cases/update_whatsapp_notification_usecase.dart'
    as _i744;
import '../../features/home/domain/use_cases/upload_images_product_return_useCase.dart'
    as _i291;
import '../../features/home/domain/use_cases/upload_user_photo_usecase.dart'
    as _i651;
import '../../features/home/domain/use_cases/wallet_checkout_usecase.dart'
    as _i682;
import '../../features/home/presentation/manager/BoutiqueBloc/boutique_bloc.dart'
    as _i511;
import '../../features/home/presentation/manager/categoryBloc/category_bloc.dart'
    as _i944;
import '../../features/home/presentation/manager/homeBloc/home_bloc.dart'
    as _i903;
import '../../features/home/presentation/manager/orderBloc/order_bloc.dart'
    as _i279;
import '../../features/story/data/data_source/story_data_source.dart' as _i777;
import '../../features/story/data/repository/story_repository_impl.dart'
    as _i213;
import '../../features/story/domain/repository/story_repository.dart' as _i505;
import '../../features/story/domain/useCases/add_story_to_our_server_usecase.dart'
    as _i737;
import '../../features/story/domain/useCases/delete_story_usecase.dart'
    as _i176;
import '../../features/story/domain/useCases/get_stories_usecase.dart' as _i804;
import '../../features/story/domain/useCases/get_width_and_height_usecase.dart'
    as _i912;
import '../../features/story/domain/useCases/increase_viewers_usecase.dart'
    as _i4;
import '../../features/story/domain/useCases/report_about_story_usecase.dart'
    as _i905;
import '../../features/story/domain/useCases/upload_story_usecase.dart'
    as _i290;
import '../../features/story/presentation/bloc/story_bloc.dart' as _i536;
import '../data/data_source/common_use_repo_data_source.dart' as _i672;
import '../data/repository/common_use_repository_impl.dart' as _i77;
import '../domin/repositories/common_use_repository.dart' as _i702;
import '../domin/repositories/prefs_repository.dart' as _i658;
import '../domin/usecases/upload_file_cloudinary_usecase.dart' as _i1043;
import '../domin/usecases/upload_file_media_server_usecase.dart' as _i318;
import 'di_container.dart' as _i198;

// initializes the registration of main-scope dependencies inside of GetIt
Future<_i174.GetIt> $initGetIt(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) async {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  final appModule = _$AppModule();
  gh.factory<_i672.CommonUseRemoteDataSource>(
    () => _i672.CommonUseRemoteDataSource(),
  );
  gh.factory<_i361.BaseOptions>(() => appModule.dioOption);
  gh.factory<_i274.SensitiveConnectivityBloc>(
    () => _i274.SensitiveConnectivityBloc(),
  );
  gh.factory<_i539.AuthRemoteDatasource>(() => _i539.AuthRemoteDatasource());
  gh.factory<_i1061.CallsRemoteDataSource>(
    () => _i1061.CallsRemoteDataSource(),
  );
  gh.factory<_i375.ChatRemoteDataSource>(() => _i375.ChatRemoteDataSource());
  gh.factory<_i243.PreloadingVideosBloc>(() => _i243.PreloadingVideosBloc());
  gh.factory<_i57.DashBoardRemoteDataSource>(
    () => _i57.DashBoardRemoteDataSource(),
  );
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
    () => _i1026.PreCachingImageBloc(),
  );
  gh.lazySingleton<_i505.StoryRepository>(
    () => _i213.StoryRepositoryImpl(gh<_i777.StoriesDataSource>()),
  );
  gh.lazySingleton<_i0.HomeRepository>(
    () => _i437.HomeRepositoryImpl(gh<_i350.HomeRemoteDatasource>()),
  );
  gh.factory<_i217.CancelReturnRequestProductUseCase>(
    () => _i217.CancelReturnRequestProductUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i441.CancelReturnRequestUseCase>(
    () => _i441.CancelReturnRequestUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i943.ConfirmReturnRequestUseCase>(
    () => _i943.ConfirmReturnRequestUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i143.GetAuthProductDetailsUseCase>(
    () => _i143.GetAuthProductDetailsUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i182.OrderReturnDetailsUseCase>(
    () => _i182.OrderReturnDetailsUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i926.OrderReturnRequestsViewUseCase>(
    () => _i926.OrderReturnRequestsViewUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i285.StoreReturnRequestProductUseCase>(
    () => _i285.StoreReturnRequestProductUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i241.StoreReturnRequestUseCase>(
    () => _i241.StoreReturnRequestUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i799.UpdateReturnRequestProductUseCase>(
    () => _i799.UpdateReturnRequestProductUseCase(gh<_i0.HomeRepository>()),
  );
  gh.lazySingleton<_i742.AuthRepository>(
    () => _i317.AuthRepositoryImpl(gh<_i539.AuthRemoteDatasource>()),
  );
  gh.factory<_i737.AddStoryToOurServerUseCase>(
    () => _i737.AddStoryToOurServerUseCase(gh<_i505.StoryRepository>()),
  );
  gh.factory<_i176.DeleteStoryUseCase>(
    () => _i176.DeleteStoryUseCase(gh<_i505.StoryRepository>()),
  );
  gh.factory<_i804.GetStoryUseCase>(
    () => _i804.GetStoryUseCase(gh<_i505.StoryRepository>()),
  );
  gh.factory<_i912.GetWidthAndHeightUseCase>(
    () => _i912.GetWidthAndHeightUseCase(gh<_i505.StoryRepository>()),
  );
  gh.factory<_i4.IncreaseViewersUseCase>(
    () => _i4.IncreaseViewersUseCase(gh<_i505.StoryRepository>()),
  );
  gh.factory<_i905.ReportAboutStoryUseCase>(
    () => _i905.ReportAboutStoryUseCase(gh<_i505.StoryRepository>()),
  );
  gh.factory<_i290.UploadStoryUseCase>(
    () => _i290.UploadStoryUseCase(gh<_i505.StoryRepository>()),
  );
  gh.singleton<_i361.Dio>(
    () => appModule.dio(gh<_i361.BaseOptions>(), gh<_i974.Logger>()),
  );
  gh.factory<_i650.CreateWalletUseCase>(
    () => _i650.CreateWalletUseCase(gh<_i742.AuthRepository>()),
  );
  gh.factory<_i231.DeleteFcmFromChatUseCase>(
    () => _i231.DeleteFcmFromChatUseCase(gh<_i742.AuthRepository>()),
  );
  gh.factory<_i100.GeneratingTokenForCommentUseCase>(
    () => _i100.GeneratingTokenForCommentUseCase(gh<_i742.AuthRepository>()),
  );
  gh.factory<_i862.GetCustomerInfoUseCase>(
    () => _i862.GetCustomerInfoUseCase(gh<_i742.AuthRepository>()),
  );
  gh.factory<_i644.GetUserCountryUseCase>(
    () => _i644.GetUserCountryUseCase(gh<_i742.AuthRepository>()),
  );
  gh.factory<_i919.LoginToChatUseCase>(
    () => _i919.LoginToChatUseCase(gh<_i742.AuthRepository>()),
  );
  gh.factory<_i832.LoginToMarketUseCase>(
    () => _i832.LoginToMarketUseCase(gh<_i742.AuthRepository>()),
  );
  gh.factory<_i656.LoginToStoriesUseCase>(
    () => _i656.LoginToStoriesUseCase(gh<_i742.AuthRepository>()),
  );
  gh.factory<_i304.LoginToWalletUseCase>(
    () => _i304.LoginToWalletUseCase(gh<_i742.AuthRepository>()),
  );
  gh.factory<_i49.RegisterGuestUseCase>(
    () => _i49.RegisterGuestUseCase(gh<_i742.AuthRepository>()),
  );
  gh.factory<_i952.SendOtpUseCase>(
    () => _i952.SendOtpUseCase(gh<_i742.AuthRepository>()),
  );
  gh.factory<_i142.StoreFcmUseCase>(
    () => _i142.StoreFcmUseCase(gh<_i742.AuthRepository>()),
  );
  gh.factory<_i730.UpdateChatUserNameUseCase>(
    () => _i730.UpdateChatUserNameUseCase(gh<_i742.AuthRepository>()),
  );
  gh.factory<_i58.UpdateNameUseCase>(
    () => _i58.UpdateNameUseCase(gh<_i742.AuthRepository>()),
  );
  gh.factory<_i434.UpdateStoriesUserUseCase>(
    () => _i434.UpdateStoriesUserUseCase(gh<_i742.AuthRepository>()),
  );
  gh.factory<_i236.VerifyOtpFromGuestUseCase>(
    () => _i236.VerifyOtpFromGuestUseCase(gh<_i742.AuthRepository>()),
  );
  gh.factory<_i995.VerifyOtpInProfileUseCase>(
    () => _i995.VerifyOtpInProfileUseCase(gh<_i742.AuthRepository>()),
  );
  gh.factory<_i574.VerifyOtpSignInUseCase>(
    () => _i574.VerifyOtpSignInUseCase(gh<_i742.AuthRepository>()),
  );
  gh.factory<_i282.VerifyOtpSignUpUseCase>(
    () => _i282.VerifyOtpSignUpUseCase(gh<_i742.AuthRepository>()),
  );
  gh.lazySingleton<_i70.DashBoardRepository>(
    () => _i161.DashBoardRepositoryImpl(gh<_i57.DashBoardRemoteDataSource>()),
  );
  gh.factory<_i504.GetDeliveredOrdersResponseUseCase>(
    () => _i504.GetDeliveredOrdersResponseUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i1022.GetRelatedProductsUseCase>(
    () => _i1022.GetRelatedProductsUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i70.AddCustomerAddressUseCase>(
    () => _i70.AddCustomerAddressUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i1035.AddItemToCartUseCase>(
    () => _i1035.AddItemToCartUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i33.AddLikeToProductUsecase>(
    () => _i33.AddLikeToProductUsecase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i823.AddOrderCommentUseCase>(
    () => _i823.AddOrderCommentUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i493.ApplyCouponUsecase>(
    () => _i493.ApplyCouponUsecase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i197.CancelOrderItemUsecase>(
    () => _i197.CancelOrderItemUsecase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i811.CancelOrderUsecase>(
    () => _i811.CancelOrderUsecase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i814.ChangeCountryLanguageFornotificationUseCase>(
    () => _i814.ChangeCountryLanguageFornotificationUseCase(
      gh<_i0.HomeRepository>(),
    ),
  );
  gh.factory<_i636.ChangeOrderAddressUsecase>(
    () => _i636.ChangeOrderAddressUsecase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i607.ChangeOrderItemVariantUsecase>(
    () => _i607.ChangeOrderItemVariantUsecase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i812.CheckAvailabilityProductCartUsecase>(
    () => _i812.CheckAvailabilityProductCartUsecase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i94.ConvertItemFromcartToOldCartUsecase>(
    () => _i94.ConvertItemFromcartToOldCartUsecase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i327.CreateOrderCommentRatingUseCase>(
    () => _i327.CreateOrderCommentRatingUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i403.DeleteOrderCommentRatingUseCase>(
    () => _i403.DeleteOrderCommentRatingUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i71.DeleteCustomerAddressUseCase>(
    () => _i71.DeleteCustomerAddressUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i878.DeleteLikeOfProductUsecase>(
    () => _i878.DeleteLikeOfProductUsecase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i970.GetAddressByCoordinatesUsecase>(
    () => _i970.GetAddressByCoordinatesUsecase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i976.GetAddressByTextUsecase>(
    () => _i976.GetAddressByTextUsecase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i318.GetAllowedCountryUseCase>(
    () => _i318.GetAllowedCountryUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i626.GetBuyerCommentsUsecase>(
    () => _i626.GetBuyerCommentsUsecase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i307.GetCartItemUseCase>(
    () => _i307.GetCartItemUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i675.GetCartOverviewUseCase>(
    () => _i675.GetCartOverviewUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i247.GetColorsAndSizesForSearchUseCase>(
    () => _i247.GetColorsAndSizesForSearchUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i922.GetAndAddCountViewOfProductUsecase>(
    () => _i922.GetAndAddCountViewOfProductUsecase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i164.CountryBoundaryByIsoUseCase>(
    () => _i164.CountryBoundaryByIsoUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i603.GetCurrenciesForWalletUseCase>(
    () => _i603.GetCurrenciesForWalletUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i762.GetCurrencyForCountryUseCase>(
    () => _i762.GetCurrencyForCountryUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i489.GetCustomerAddressesUseCase>(
    () => _i489.GetCustomerAddressesUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i361.GetCustomerWalletUseCase>(
    () => _i361.GetCustomerWalletUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i146.GetFeaturedProductsUseCase>(
    () => _i146.GetFeaturedProductsUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i131.GetFqaCommentsUsecase>(
    () => _i131.GetFqaCommentsUsecase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i149.GetFullProductDetailsUseCase>(
    () => _i149.GetFullProductDetailsUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i518.GetHomeBoutiqesUseCase>(
    () => _i518.GetHomeBoutiqesUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i158.GetMainCategoriesUseCase>(
    () => _i158.GetMainCategoriesUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i171.GetMyFirebaseSettingsUseCase>(
    () => _i171.GetMyFirebaseSettingsUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i929.GetNotificationTypeProductUseCase>(
    () => _i929.GetNotificationTypeProductUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i318.GetOldCartItemUseCase>(
    () => _i318.GetOldCartItemUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i863.GetOrderRatingUsecase>(
    () => _i863.GetOrderRatingUsecase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i59.GetOrdersByCartGroupIDUsecase>(
    () => _i59.GetOrdersByCartGroupIDUsecase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i1003.GetOrdersByOrderGroupIDUsecase>(
    () => _i1003.GetOrdersByOrderGroupIDUsecase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i558.GetOrdersUseCase>(
    () => _i558.GetOrdersUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i963.GetPopularSearchItemUseCase>(
    () => _i963.GetPopularSearchItemUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i716.GetProductColorSizeSyncAttributeUseCase>(
    () =>
        _i716.GetProductColorSizeSyncAttributeUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i347.GetProductDetailWithoutRelatedProductsUseCase>(
    () => _i347.GetProductDetailWithoutRelatedProductsUseCase(
      gh<_i0.HomeRepository>(),
    ),
  );
  gh.factory<_i290.GetProductFiltersUseCase>(
    () => _i290.GetProductFiltersUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i749.GetProductsListInCartUseCase>(
    () => _i749.GetProductsListInCartUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i397.GetProductsWithoutFiltersUseCase>(
    () => _i397.GetProductsWithoutFiltersUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i955.GetProductsWithFiltersUseCase>(
    () => _i955.GetProductsWithFiltersUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i401.GetProvincesByIsoUseCase>(
    () => _i401.GetProvincesByIsoUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i889.GetRecommendProductsUseCase>(
    () => _i889.GetRecommendProductsUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i815.GetReturnReasonsUseCase>(
    () => _i815.GetReturnReasonsUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i815.GetStartingSettingsUseCase>(
    () => _i815.GetStartingSettingsUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i533.GetStoryForProductUseCase>(
    () => _i533.GetStoryForProductUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i1021.GetUserNotificationUseCase>(
    () => _i1021.GetUserNotificationUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i104.HideItemsInOldCartUseCase>(
    () => _i104.HideItemsInOldCartUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i649.PlaceOrderUsecase>(
    () => _i649.PlaceOrderUsecase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i687.RemoveItemToCartUseCase>(
    () => _i687.RemoveItemToCartUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i715.RequestForNotificationWhenProductBecameAvailableUseCase>(
    () => _i715.RequestForNotificationWhenProductBecameAvailableUseCase(
      gh<_i0.HomeRepository>(),
    ),
  );
  gh.factory<_i889.SearchByImageFromGeminiUseCase>(
    () => _i889.SearchByImageFromGeminiUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i608.SendAcceptOfNotificationsUseCase>(
    () => _i608.SendAcceptOfNotificationsUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i78.SendErrorToMobileErrorLogUseCase>(
    () => _i78.SendErrorToMobileErrorLogUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i1064.SetCustomerAddressDefaultUseCase>(
    () => _i1064.SetCustomerAddressDefaultUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i366.StoreFcmTokenOfMarketUseCase>(
    () => _i366.StoreFcmTokenOfMarketUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i687.SubscribeTopicFornotificationUseCase>(
    () => _i687.SubscribeTopicFornotificationUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i358.TranslateCommentUsecase>(
    () => _i358.TranslateCommentUsecase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i424.UnSubscribeTopicFornotificationUseCase>(
    () =>
        _i424.UnSubscribeTopicFornotificationUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i22.UpdateOrderCommentRatingUseCase>(
    () => _i22.UpdateOrderCommentRatingUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i418.UpdateCustomerAddressUseCase>(
    () => _i418.UpdateCustomerAddressUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i750.UpdateEmailNotificationUseCase>(
    () => _i750.UpdateEmailNotificationUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i741.UpdateFirebaseNotificationUseCase>(
    () => _i741.UpdateFirebaseNotificationUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i802.UpdateItemInCartUseCase>(
    () => _i802.UpdateItemInCartUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i630.UpdateLikeCommentUseCase>(
    () => _i630.UpdateLikeCommentUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i580.UpdateLikeSocialSharedProductsUsecase>(
    () => _i580.UpdateLikeSocialSharedProductsUsecase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i432.UpdateNotificationFrequencyUseCase>(
    () => _i432.UpdateNotificationFrequencyUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i1013.UpdateOrderCommentUseCase>(
    () => _i1013.UpdateOrderCommentUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i315.UpdateProfileUseCase>(
    () => _i315.UpdateProfileUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i744.UpdateWhatsappNotificationUseCase>(
    () => _i744.UpdateWhatsappNotificationUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i291.UploadImagesProductReturnUseCase>(
    () => _i291.UploadImagesProductReturnUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i651.UpdateUserPhotoUseCase>(
    () => _i651.UpdateUserPhotoUseCase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i682.WalletCheckoutUseCase>(
    () => _i682.WalletCheckoutUseCase(gh<_i0.HomeRepository>()),
  );
  gh.lazySingleton<_i702.CommonUseRepository>(
    () => _i77.CommonUseRepositoryImpl(gh<_i672.CommonUseRemoteDataSource>()),
  );
  gh.lazySingleton<_i1032.CallsRepository>(
    () => _i722.CallsRepositoryImpl(gh<_i1061.CallsRemoteDataSource>()),
  );
  gh.lazySingleton<_i420.ChatRepository>(
    () => _i504.ChatRepositoryImpl(gh<_i375.ChatRemoteDataSource>()),
  );
  gh.factory<_i1043.UploadFileCloudinaryUseCase>(
    () => _i1043.UploadFileCloudinaryUseCase(gh<_i702.CommonUseRepository>()),
  );
  gh.factory<_i318.UploadFileMediaServerUseCase>(
    () => _i318.UploadFileMediaServerUseCase(gh<_i702.CommonUseRepository>()),
  );
  gh.lazySingleton<_i944.CategoryBloc>(
    () => _i944.CategoryBloc(
      gh<_i889.SearchByImageFromGeminiUseCase>(),
      gh<_i158.GetMainCategoriesUseCase>(),
      gh<_i518.GetHomeBoutiqesUseCase>(),
    ),
  );
  gh.factory<_i602.AddUserUseCase>(
    () => _i602.AddUserUseCase(gh<_i70.DashBoardRepository>()),
  );
  gh.factory<_i288.ChangeOrderDetailStatusToPackedUseCase>(
    () => _i288.ChangeOrderDetailStatusToPackedUseCase(
      gh<_i70.DashBoardRepository>(),
    ),
  );
  gh.factory<_i553.ChangeOrderDetailStatusToConfirmedUseCase>(
    () => _i553.ChangeOrderDetailStatusToConfirmedUseCase(
      gh<_i70.DashBoardRepository>(),
    ),
  );
  gh.factory<_i645.ChangeOrderStatusUseCase>(
    () => _i645.ChangeOrderStatusUseCase(gh<_i70.DashBoardRepository>()),
  );
  gh.factory<_i441.DeleteUserUseCase>(
    () => _i441.DeleteUserUseCase(gh<_i70.DashBoardRepository>()),
  );
  gh.factory<_i412.GetBoutiquesUseCase>(
    () => _i412.GetBoutiquesUseCase(gh<_i70.DashBoardRepository>()),
  );
  gh.factory<_i919.GetOrdersUseCase>(
    () => _i919.GetOrdersUseCase(gh<_i70.DashBoardRepository>()),
  );
  gh.factory<_i781.GetPresignedUrlUseCase>(
    () => _i781.GetPresignedUrlUseCase(gh<_i70.DashBoardRepository>()),
  );
  gh.factory<_i51.GetProductsUseCase>(
    () => _i51.GetProductsUseCase(gh<_i70.DashBoardRepository>()),
  );
  gh.factory<_i652.GetUserPermissionUseCase>(
    () => _i652.GetUserPermissionUseCase(gh<_i70.DashBoardRepository>()),
  );
  gh.factory<_i246.GetUserRolesUseCase>(
    () => _i246.GetUserRolesUseCase(gh<_i70.DashBoardRepository>()),
  );
  gh.factory<_i900.GetUsersUseCase>(
    () => _i900.GetUsersUseCase(gh<_i70.DashBoardRepository>()),
  );
  gh.factory<_i135.GetVendorRequestUseCase>(
    () => _i135.GetVendorRequestUseCase(gh<_i70.DashBoardRepository>()),
  );
  gh.factory<_i858.LeaveShopUseCase>(
    () => _i858.LeaveShopUseCase(gh<_i70.DashBoardRepository>()),
  );
  gh.factory<_i129.NewGetOrdersUseCase>(
    () => _i129.NewGetOrdersUseCase(gh<_i70.DashBoardRepository>()),
  );
  gh.factory<_i916.SubmitVendorRequestUseCase>(
    () => _i916.SubmitVendorRequestUseCase(gh<_i70.DashBoardRepository>()),
  );
  gh.factory<_i1023.UpdateUserRoleUseCase>(
    () => _i1023.UpdateUserRoleUseCase(gh<_i70.DashBoardRepository>()),
  );
  gh.factory<_i388.UpdateVendorRequestUseCase>(
    () => _i388.UpdateVendorRequestUseCase(gh<_i70.DashBoardRepository>()),
  );
  gh.factory<_i282.UploadFileToS3UseCase>(
    () => _i282.UploadFileToS3UseCase(gh<_i70.DashBoardRepository>()),
  );
  gh.factory<_i589.CreateUserUseCase>(
    () => _i589.CreateUserUseCase(gh<_i420.ChatRepository>()),
  );
  gh.factory<_i900.BlockOrDeleteBlockUserUseCase>(
    () => _i900.BlockOrDeleteBlockUserUseCase(gh<_i420.ChatRepository>()),
  );
  gh.factory<_i142.ChangeChatPropertyUseCase>(
    () => _i142.ChangeChatPropertyUseCase(gh<_i420.ChatRepository>()),
  );
  gh.factory<_i361.DeleteChatUseCase>(
    () => _i361.DeleteChatUseCase(gh<_i420.ChatRepository>()),
  );
  gh.factory<_i418.GetContactsUseCase>(
    () => _i418.GetContactsUseCase(gh<_i420.ChatRepository>()),
  );
  gh.factory<_i668.GetDateTimeUseCase>(
    () => _i668.GetDateTimeUseCase(gh<_i420.ChatRepository>()),
  );
  gh.factory<_i148.GetWidthAndHeightUseCase>(
    () => _i148.GetWidthAndHeightUseCase(gh<_i420.ChatRepository>()),
  );
  gh.factory<_i109.GetMediaCountUseCase>(
    () => _i109.GetMediaCountUseCase(gh<_i420.ChatRepository>()),
  );
  gh.factory<_i912.GetMessagesBetweenUseCase>(
    () => _i912.GetMessagesBetweenUseCase(gh<_i420.ChatRepository>()),
  );
  gh.factory<_i304.GetMessagesForChatUseCase>(
    () => _i304.GetMessagesForChatUseCase(gh<_i420.ChatRepository>()),
  );
  gh.factory<_i675.GetMyChatsUseCase>(
    () => _i675.GetMyChatsUseCase(gh<_i420.ChatRepository>()),
  );
  gh.factory<_i1039.GetOrderRecipientIdUseCase>(
    () => _i1039.GetOrderRecipientIdUseCase(gh<_i420.ChatRepository>()),
  );
  gh.factory<_i538.GetSharedProductCountUseCase>(
    () => _i538.GetSharedProductCountUseCase(gh<_i420.ChatRepository>()),
  );
  gh.factory<_i314.ReadAllMessagesUseCase>(
    () => _i314.ReadAllMessagesUseCase(gh<_i420.ChatRepository>()),
  );
  gh.factory<_i40.ReceiveMessageUseCase>(
    () => _i40.ReceiveMessageUseCase(gh<_i420.ChatRepository>()),
  );
  gh.factory<_i777.SaveContactsUseCase>(
    () => _i777.SaveContactsUseCase(gh<_i420.ChatRepository>()),
  );
  gh.factory<_i925.SearchForMessageTextInChatUseCase>(
    () => _i925.SearchForMessageTextInChatUseCase(gh<_i420.ChatRepository>()),
  );
  gh.factory<_i677.SendErrorToServerUseCase>(
    () => _i677.SendErrorToServerUseCase(gh<_i420.ChatRepository>()),
  );
  gh.factory<_i703.SendMessageUseCase>(
    () => _i703.SendMessageUseCase(gh<_i420.ChatRepository>()),
  );
  gh.factory<_i710.ShareProductOnAppsUseCase>(
    () => _i710.ShareProductOnAppsUseCase(gh<_i420.ChatRepository>()),
  );
  gh.factory<_i139.ShareProductWithContactsOrChannelsUsecase>(
    () => _i139.ShareProductWithContactsOrChannelsUsecase(
      gh<_i420.ChatRepository>(),
    ),
  );
  gh.factory<_i750.UpdateProfileInChatUseCase>(
    () => _i750.UpdateProfileInChatUseCase(gh<_i420.ChatRepository>()),
  );
  gh.factory<_i897.UploadFileUseCase>(
    () => _i897.UploadFileUseCase(gh<_i420.ChatRepository>()),
  );
  gh.lazySingleton<_i903.HomeBloc>(
    () => _i903.HomeBloc(
      gh<_i533.GetStoryForProductUseCase>(),
      gh<_i687.RemoveItemToCartUseCase>(),
      gh<_i94.ConvertItemFromcartToOldCartUsecase>(),
      gh<_i307.GetCartItemUseCase>(),
      gh<_i318.GetOldCartItemUseCase>(),
      gh<_i905.ReportAboutStoryUseCase>(),
      gh<_i366.StoreFcmTokenOfMarketUseCase>(),
      gh<_i878.DeleteLikeOfProductUsecase>(),
      gh<_i33.AddLikeToProductUsecase>(),
      gh<_i802.UpdateItemInCartUseCase>(),
      gh<_i131.GetFqaCommentsUsecase>(),
      gh<_i626.GetBuyerCommentsUsecase>(),
      gh<_i1035.AddItemToCartUseCase>(),
      gh<_i403.DeleteOrderCommentRatingUseCase>(),
      gh<_i315.UpdateProfileUseCase>(),
      gh<_i580.UpdateLikeSocialSharedProductsUsecase>(),
      gh<_i318.GetAllowedCountryUseCase>(),
      gh<_i929.GetNotificationTypeProductUseCase>(),
      gh<_i912.GetWidthAndHeightUseCase>(),
      gh<_i171.GetMyFirebaseSettingsUseCase>(),
      gh<_i1022.GetRelatedProductsUseCase>(),
      gh<_i603.GetCurrenciesForWalletUseCase>(),
      gh<_i143.GetAuthProductDetailsUseCase>(),
      gh<_i750.UpdateEmailNotificationUseCase>(),
      gh<_i741.UpdateFirebaseNotificationUseCase>(),
      gh<_i432.UpdateNotificationFrequencyUseCase>(),
      gh<_i744.UpdateWhatsappNotificationUseCase>(),
      gh<_i814.ChangeCountryLanguageFornotificationUseCase>(),
      gh<_i863.GetOrderRatingUsecase>(),
      gh<_i22.UpdateOrderCommentRatingUseCase>(),
      gh<_i608.SendAcceptOfNotificationsUseCase>(),
      gh<_i687.SubscribeTopicFornotificationUseCase>(),
      gh<_i424.UnSubscribeTopicFornotificationUseCase>(),
      gh<_i347.GetProductDetailWithoutRelatedProductsUseCase>(),
      gh<_i327.CreateOrderCommentRatingUseCase>(),
      gh<_i815.GetStartingSettingsUseCase>(),
      gh<_i963.GetPopularSearchItemUseCase>(),
      gh<_i504.GetDeliveredOrdersResponseUseCase>(),
      gh<_i651.UpdateUserPhotoUseCase>(),
      gh<_i762.GetCurrencyForCountryUseCase>(),
      gh<_i104.HideItemsInOldCartUseCase>(),
      gh<_i149.GetFullProductDetailsUseCase>(),
      gh<_i164.CountryBoundaryByIsoUseCase>(),
      gh<_i922.GetAndAddCountViewOfProductUsecase>(),
      gh<_i78.SendErrorToMobileErrorLogUseCase>(),
      gh<_i397.GetProductsWithoutFiltersUseCase>(),
      gh<_i630.UpdateLikeCommentUseCase>(),
      gh<_i715.RequestForNotificationWhenProductBecameAvailableUseCase>(),
      gh<_i812.CheckAvailabilityProductCartUsecase>(),
      gh<_i675.GetCartOverviewUseCase>(),
      gh<_i358.TranslateCommentUsecase>(),
      gh<_i1021.GetUserNotificationUseCase>(),
    ),
  );
  gh.lazySingleton<_i976.DashboardBloc>(
    () => _i976.DashboardBloc(
      gh<_i652.GetUserPermissionUseCase>(),
      gh<_i246.GetUserRolesUseCase>(),
      gh<_i900.GetUsersUseCase>(),
      gh<_i602.AddUserUseCase>(),
      gh<_i919.GetOrdersUseCase>(),
      gh<_i51.GetProductsUseCase>(),
      gh<_i412.GetBoutiquesUseCase>(),
      gh<_i645.ChangeOrderStatusUseCase>(),
      gh<_i441.DeleteUserUseCase>(),
      gh<_i1023.UpdateUserRoleUseCase>(),
      gh<_i858.LeaveShopUseCase>(),
      gh<_i781.GetPresignedUrlUseCase>(),
      gh<_i282.UploadFileToS3UseCase>(),
      gh<_i976.SubmitVendorRequestUseCase>(),
      gh<_i135.GetVendorRequestUseCase>(),
      gh<_i388.UpdateVendorRequestUseCase>(),
      gh<_i129.NewGetOrdersUseCase>(),
      gh<_i553.ChangeOrderDetailStatusToConfirmedUseCase>(),
      gh<_i288.ChangeOrderDetailStatusToPackedUseCase>(),
    ),
  );
  gh.factory<_i661.AnswerCallUseCase>(
    () => _i661.AnswerCallUseCase(gh<_i1032.CallsRepository>()),
  );
  gh.factory<_i95.DeleteMessageUseCase>(
    () => _i95.DeleteMessageUseCase(gh<_i1032.CallsRepository>()),
  );
  gh.factory<_i592.EndCallUseCase>(
    () => _i592.EndCallUseCase(gh<_i1032.CallsRepository>()),
  );
  gh.factory<_i1014.GetAgoraTokenUseCase>(
    () => _i1014.GetAgoraTokenUseCase(gh<_i1032.CallsRepository>()),
  );
  gh.factory<_i767.GetMissedCalCountUseCase>(
    () => _i767.GetMissedCalCountUseCase(gh<_i1032.CallsRepository>()),
  );
  gh.factory<_i177.GetMyCallsUseCase>(
    () => _i177.GetMyCallsUseCase(gh<_i1032.CallsRepository>()),
  );
  gh.factory<_i643.MakeCallUseCase>(
    () => _i643.MakeCallUseCase(gh<_i1032.CallsRepository>()),
  );
  gh.factory<_i711.RejectCallUseCase>(
    () => _i711.RejectCallUseCase(gh<_i1032.CallsRepository>()),
  );
  gh.factory<_i961.WatchMissedCallUseCase>(
    () => _i961.WatchMissedCallUseCase(gh<_i1032.CallsRepository>()),
  );
  gh.lazySingleton<_i547.CallsBloc>(
    () => _i547.CallsBloc(
      gh<_i711.RejectCallUseCase>(),
      gh<_i643.MakeCallUseCase>(),
      gh<_i592.EndCallUseCase>(),
      gh<_i177.GetMyCallsUseCase>(),
      gh<_i961.WatchMissedCallUseCase>(),
      gh<_i661.AnswerCallUseCase>(),
      gh<_i767.GetMissedCalCountUseCase>(),
      gh<_i1014.GetAgoraTokenUseCase>(),
      gh<_i95.DeleteMessageUseCase>(),
    ),
  );
  gh.lazySingleton<_i536.StoryBloc>(
    () => _i536.StoryBloc(
      gh<_i1043.UploadFileCloudinaryUseCase>(),
      gh<_i804.GetStoryUseCase>(),
      gh<_i912.GetWidthAndHeightUseCase>(),
      gh<_i290.UploadStoryUseCase>(),
      gh<_i4.IncreaseViewersUseCase>(),
      gh<_i737.AddStoryToOurServerUseCase>(),
      gh<_i318.UploadFileMediaServerUseCase>(),
      gh<_i176.DeleteStoryUseCase>(),
    ),
  );
  gh.lazySingleton<_i511.BoutiqueBloc>(
    () => _i511.BoutiqueBloc(
      gh<_i146.GetFeaturedProductsUseCase>(),
      gh<_i955.GetProductsWithFiltersUseCase>(),
      gh<_i889.GetRecommendProductsUseCase>(),
      gh<_i290.GetProductFiltersUseCase>(),
    ),
  );
  gh.lazySingleton<_i279.OrderBloc>(
    () => _i279.OrderBloc(
      gh<_i649.PlaceOrderUsecase>(),
      gh<_i682.WalletCheckoutUseCase>(),
      gh<_i197.CancelOrderItemUsecase>(),
      gh<_i811.CancelOrderUsecase>(),
      gh<_i291.UploadImagesProductReturnUseCase>(),
      gh<_i636.ChangeOrderAddressUsecase>(),
      gh<_i1003.GetOrdersByOrderGroupIDUsecase>(),
      gh<_i59.GetOrdersByCartGroupIDUsecase>(),
      gh<_i401.GetProvincesByIsoUseCase>(),
      gh<_i361.GetCustomerWalletUseCase>(),
      gh<_i241.StoreReturnRequestUseCase>(),
      gh<_i943.ConfirmReturnRequestUseCase>(),
      gh<_i926.OrderReturnRequestsViewUseCase>(),
      gh<_i558.GetOrdersUseCase>(),
      gh<_i1064.SetCustomerAddressDefaultUseCase>(),
      gh<_i489.GetCustomerAddressesUseCase>(),
      gh<_i71.DeleteCustomerAddressUseCase>(),
      gh<_i70.AddCustomerAddressUseCase>(),
      gh<_i418.UpdateCustomerAddressUseCase>(),
      gh<_i970.GetAddressByCoordinatesUsecase>(),
      gh<_i976.GetAddressByTextUsecase>(),
      gh<_i493.ApplyCouponUsecase>(),
      gh<_i716.GetProductColorSizeSyncAttributeUseCase>(),
      gh<_i607.ChangeOrderItemVariantUsecase>(),
      gh<_i815.GetReturnReasonsUseCase>(),
      gh<_i285.StoreReturnRequestProductUseCase>(),
      gh<_i441.CancelReturnRequestUseCase>(),
      gh<_i217.CancelReturnRequestProductUseCase>(),
      gh<_i799.UpdateReturnRequestProductUseCase>(),
      gh<_i182.OrderReturnDetailsUseCase>(),
    ),
  );
  gh.lazySingleton<_i561.AuthBloc>(
    () => _i561.AuthBloc(
      gh<_i434.UpdateStoriesUserUseCase>(),
      gh<_i730.UpdateChatUserNameUseCase>(),
      gh<_i589.CreateUserUseCase>(),
      gh<_i919.LoginToChatUseCase>(),
      gh<_i656.LoginToStoriesUseCase>(),
      gh<_i142.StoreFcmUseCase>(),
      gh<_i995.VerifyOtpInProfileUseCase>(),
      gh<_i58.UpdateNameUseCase>(),
      gh<_i49.RegisterGuestUseCase>(),
      gh<_i650.CreateWalletUseCase>(),
      gh<_i304.LoginToWalletUseCase>(),
      gh<_i100.GeneratingTokenForCommentUseCase>(),
      gh<_i952.SendOtpUseCase>(),
      gh<_i862.GetCustomerInfoUseCase>(),
      gh<_i236.VerifyOtpFromGuestUseCase>(),
      gh<_i574.VerifyOtpSignInUseCase>(),
      gh<_i644.GetUserCountryUseCase>(),
      gh<_i231.DeleteFcmFromChatUseCase>(),
      gh<_i282.VerifyOtpSignUpUseCase>(),
    ),
  );
  gh.lazySingleton<_i243.ChatBloc>(
    () => _i243.ChatBloc(
      gh<_i418.GetContactsUseCase>(),
      gh<_i675.GetMyChatsUseCase>(),
      gh<_i710.ShareProductOnAppsUseCase>(),
      gh<_i777.SaveContactsUseCase>(),
      gh<_i703.SendMessageUseCase>(),
      gh<_i538.GetSharedProductCountUseCase>(),
      gh<_i912.GetMessagesBetweenUseCase>(),
      gh<_i1039.GetOrderRecipientIdUseCase>(),
      gh<_i1043.UploadFileCloudinaryUseCase>(),
      gh<_i304.GetMessagesForChatUseCase>(),
      gh<_i361.DeleteChatUseCase>(),
      gh<_i925.SearchForMessageTextInChatUseCase>(),
      gh<_i142.ChangeChatPropertyUseCase>(),
      gh<_i897.UploadFileUseCase>(),
      gh<_i314.ReadAllMessagesUseCase>(),
      gh<_i40.ReceiveMessageUseCase>(),
      gh<_i750.UpdateProfileInChatUseCase>(),
      gh<_i139.ShareProductWithContactsOrChannelsUsecase>(),
      gh<_i109.GetMediaCountUseCase>(),
      gh<_i668.GetDateTimeUseCase>(),
      gh<_i900.BlockOrDeleteBlockUserUseCase>(),
      gh<_i677.SendErrorToServerUseCase>(),
    ),
  );
  return getIt;
}

class _$AppModule extends _i198.AppModule {}
