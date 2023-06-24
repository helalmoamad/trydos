// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i10;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:logger/logger.dart' as _i24;
import 'package:shared_preferences/shared_preferences.dart' as _i35;

import '../../features/add_product/data/data_sources/add_product_datasource.dart'
    as _i3;
import '../../features/add_product/data/repositories/add_product_repository_impl.dart'
    as _i5;
import '../../features/add_product/domain/repositories/add_product_repository.dart'
    as _i4;
import '../../features/add_product/domain/use_cases/add_product_usecase.dart'
    as _i6;
import '../../features/add_product/domain/use_cases/get_all_category_usecase.dart'
    as _i13;
import '../../features/add_product/domain/use_cases/get_all_extra-item_usecase.dart'
    as _i14;
import '../../features/add_product/domain/use_cases/get_category_usecase.dart'
    as _i15;
import '../../features/add_product/domain/use_cases/get_cuisines_usecase.dart'
    as _i16;
import '../../features/add_product/domain/use_cases/get_items_by_categoryid_usecase.dart'
    as _i17;
import '../../features/add_product/domain/use_cases/get_products_usecase.dart'
    as _i18;
import '../../features/add_product/presentation/manager/add_product_bloc.dart'
    as _i43;
import '../../features/app/presentation/bloc/humy/humy_bloc.dart' as _i36;
import '../../features/app/presentation/bloc/sensitive_connectivity/sensitive_connectivity_bloc.dart'
    as _i34;
import '../../features/authentication/data/data_sources/auth_remote_datasource.dart'
    as _i7;
import '../../features/authentication/data/repositories/auth_repository_impl.dart'
    as _i9;
import '../../features/authentication/domain/repositories/auth_repository.dart'
    as _i8;
import '../../features/authentication/domain/use_cases/first_step_registration_usecase.dart'
    as _i11;
import '../../features/authentication/domain/use_cases/fourth_step_registration_usecase.dart'
    as _i12;
import '../../features/authentication/domain/use_cases/get_profile_info_usecase.dart'
    as _i19;
import '../../features/authentication/domain/use_cases/logout_usecase.dart'
    as _i23;
import '../../features/authentication/domain/use_cases/register_by_mobile_number_usecase.dart'
    as _i29;
import '../../features/authentication/domain/use_cases/register_usecase.dart'
    as _i30;
import '../../features/authentication/domain/use_cases/register_verfication_usecase.dart'
    as _i31;
import '../../features/authentication/domain/use_cases/second_step_registration_usecase.dart'
    as _i33;
import '../../features/authentication/domain/use_cases/third_step_registration_usecase.dart'
    as _i37;
import '../../features/authentication/presentation/manager/auth_bloc.dart'
    as _i44;
import '../../features/driver_journeys/data/data_sources/journeys_remote_data_source.dart'
    as _i20;
import '../../features/driver_journeys/data/data_sources/orders_remote_datasource.dart'
    as _i25;
import '../../features/driver_journeys/data/repositories/journeys_repository_impl.dart'
    as _i22;
import '../../features/driver_journeys/data/repositories/orders_repository_impl.dart'
    as _i27;
import '../../features/driver_journeys/domain/repositories/journeys_repository.dart'
    as _i21;
import '../../features/driver_journeys/domain/repositories/orders_repository.dart'
    as _i26;
import '../../features/driver_journeys/domain/use_cases/add_coordinates_usecase.dart'
    as _i39;
import '../../features/driver_journeys/domain/use_cases/add_file_usecase.dart'
    as _i40;
import '../../features/driver_journeys/domain/use_cases/add_money_to_order_usecase.dart'
    as _i41;
import '../../features/driver_journeys/domain/use_cases/add_orders_to_journey_usecase.dart'
    as _i42;
import '../../features/driver_journeys/domain/use_cases/change_order_status_usecase.dart'
    as _i45;
import '../../features/driver_journeys/domain/use_cases/create_journey_usecase.dart'
    as _i46;
import '../../features/driver_journeys/domain/use_cases/get_journey_status_usecase.dart'
    as _i47;
import '../../features/driver_journeys/domain/use_cases/get_journeys_usecase.dart'
    as _i48;
import '../../features/driver_journeys/domain/use_cases/get_orders_status_usecase.dart'
    as _i49;
import '../../features/driver_journeys/domain/use_cases/get_orders_usecase.dart'
    as _i50;
import '../../features/driver_journeys/domain/use_cases/reject_order_usecase.dart'
    as _i32;
import '../../features/driver_journeys/domain/use_cases/upload_file_usecase.dart'
    as _i38;
import '../../features/driver_journeys/presentation/manager/journeys_bloc.dart'
    as _i51;
import '../domin/repositories/prefs_repository.dart' as _i28;
import 'di_container.dart' as _i52; // ignore_for_file: unnecessary_lambdas

// ignore_for_file: lines_longer_than_80_chars
/// initializes the registration of provided dependencies inside of [GetIt]
Future<_i1.GetIt> $initGetIt(
  _i1.GetIt get, {
  String? environment,
  _i2.EnvironmentFilter? environmentFilter,
}) async {
  final gh = _i2.GetItHelper(
    get,
    environment,
    environmentFilter,
  );
  final appModule = _$AppModule();
  gh.factory<_i3.AddProductDatasource>(() => _i3.AddProductDatasource());
  gh.lazySingleton<_i4.AddProductRepository>(() => _i5.AddProductRepositoryImpl(
      datasource: get<_i3.AddProductDatasource>()));
  gh.factory<_i6.AddProductUsecase>(
      () => _i6.AddProductUsecase(repository: get<_i4.AddProductRepository>()));
  gh.factory<_i7.AuthRemoteDatasource>(() => _i7.AuthRemoteDatasource());
  gh.lazySingleton<_i8.AuthRepository>(
      () => _i9.AuthRepositoryImpl(get<_i7.AuthRemoteDatasource>()));
  gh.factory<_i10.BaseOptions>(() => appModule.dioOption);
  gh.factory<_i11.FirsStepRegistrationUsecase>(() =>
      _i11.FirsStepRegistrationUsecase(repository: get<_i8.AuthRepository>()));
  gh.factory<_i12.FourthStepRegistrationUsecase>(() =>
      _i12.FourthStepRegistrationUsecase(
          repository: get<_i8.AuthRepository>()));
  gh.factory<_i13.GetAllCategoryUsecase>(() =>
      _i13.GetAllCategoryUsecase(repository: get<_i4.AddProductRepository>()));
  gh.factory<_i14.GetAllExtraItemUsecase>(() =>
      _i14.GetAllExtraItemUsecase(repository: get<_i4.AddProductRepository>()));
  gh.factory<_i15.GetCategoryUsecase>(() =>
      _i15.GetCategoryUsecase(repository: get<_i4.AddProductRepository>()));
  gh.factory<_i16.GetCuisinesUsecase>(() =>
      _i16.GetCuisinesUsecase(repository: get<_i4.AddProductRepository>()));
  gh.factory<_i17.GetItemsByCategoryIdUsecase>(() =>
      _i17.GetItemsByCategoryIdUsecase(
          repository: get<_i4.AddProductRepository>()));
  gh.factory<_i18.GetProductsUsecase>(() =>
      _i18.GetProductsUsecase(repository: get<_i4.AddProductRepository>()));
  gh.factory<_i19.GetProfileInfoUseCase>(
      () => _i19.GetProfileInfoUseCase(get<_i8.AuthRepository>()));
  gh.factory<_i20.JourneysRemoteDataSource>(
      () => _i20.JourneysRemoteDataSource());
  gh.lazySingleton<_i21.JourneysRepository>(
      () => _i22.JourneysRepositoryImpl(get<_i20.JourneysRemoteDataSource>()));
  gh.factory<_i23.LogOutUseCase>(
      () => _i23.LogOutUseCase(get<_i8.AuthRepository>()));
  gh.singleton<_i24.Logger>(appModule.logger);
  gh.factory<_i25.OrdersRemoteDataSource>(() => _i25.OrdersRemoteDataSource());
  gh.lazySingleton<_i26.OrdersRepository>(
      () => _i27.OrderRepositoryImpl(get<_i25.OrdersRemoteDataSource>()));
  await gh.singletonAsync<_i28.PrefsRepository>(
    () => appModule.prefsRepository,
    preResolve: true,
  );
  gh.factory<_i29.RegisterByMobileNumberUsecase>(
      () => _i29.RegisterByMobileNumberUsecase(get<_i8.AuthRepository>()));
  gh.factory<_i30.RegisterUsecase>(
      () => _i30.RegisterUsecase(repository: get<_i8.AuthRepository>()));
  gh.factory<_i31.RegisterVerificationUsecase>(() =>
      _i31.RegisterVerificationUsecase(repository: get<_i8.AuthRepository>()));
  gh.factory<_i32.RejectOrderUseCase>(
      () => _i32.RejectOrderUseCase(get<_i21.JourneysRepository>()));
  gh.factory<_i33.SecondStepRegistrationUsecase>(() =>
      _i33.SecondStepRegistrationUsecase(
          repository: get<_i8.AuthRepository>()));
  gh.factory<_i34.SensitiveConnectivityBloc>(
      () => _i34.SensitiveConnectivityBloc());
  await gh.singletonAsync<_i35.SharedPreferences>(
    () => appModule.sharedPreferences,
    preResolve: true,
  );
  gh.factory<_i36.ShippingBloc>(() => _i36.ShippingBloc());
  gh.factory<_i37.ThirdStepRegistrationUsecase>(() =>
      _i37.ThirdStepRegistrationUsecase(repository: get<_i8.AuthRepository>()));
  gh.factory<_i38.UploadFileForOrderUseCase>(
      () => _i38.UploadFileForOrderUseCase(get<_i26.OrdersRepository>()));
  gh.factory<_i39.AddCoordinatesForOrderUseCase>(
      () => _i39.AddCoordinatesForOrderUseCase(get<_i26.OrdersRepository>()));
  gh.factory<_i40.AddFileForOrderUseCase>(
      () => _i40.AddFileForOrderUseCase(get<_i26.OrdersRepository>()));
  gh.factory<_i41.AddMoneyToOrderUseCase>(
      () => _i41.AddMoneyToOrderUseCase(get<_i26.OrdersRepository>()));
  gh.factory<_i42.AddOrdersToJourneyUseCase>(
      () => _i42.AddOrdersToJourneyUseCase(get<_i21.JourneysRepository>()));
  gh.factory<_i43.AddProductBloc>(() => _i43.AddProductBloc(
        get<_i6.AddProductUsecase>(),
        get<_i14.GetAllExtraItemUsecase>(),
        get<_i17.GetItemsByCategoryIdUsecase>(),
        get<_i16.GetCuisinesUsecase>(),
        get<_i15.GetCategoryUsecase>(),
        get<_i18.GetProductsUsecase>(),
        get<_i13.GetAllCategoryUsecase>(),
      ));
  gh.factory<_i44.AuthBloc>(() => _i44.AuthBloc(
        registerByMobileNumberUsecase:
            get<_i29.RegisterByMobileNumberUsecase>(),
        getProfileInfoUseCase: get<_i19.GetProfileInfoUseCase>(),
        logOutUseCase: get<_i23.LogOutUseCase>(),
      ));
  gh.factory<_i45.ChangeOrderStatusUseCase>(
      () => _i45.ChangeOrderStatusUseCase(get<_i26.OrdersRepository>()));
  gh.factory<_i46.CreateJourneyUseCase>(
      () => _i46.CreateJourneyUseCase(get<_i21.JourneysRepository>()));
  gh.singleton<_i10.Dio>(appModule.dio(
    get<_i10.BaseOptions>(),
    get<_i24.Logger>(),
  ));
  gh.factory<_i47.GetJourneyStatusUseCase>(
      () => _i47.GetJourneyStatusUseCase(get<_i21.JourneysRepository>()));
  gh.factory<_i48.GetJourneysUseCase>(
      () => _i48.GetJourneysUseCase(get<_i21.JourneysRepository>()));
  gh.factory<_i49.GetOrdersStatusUseCase>(
      () => _i49.GetOrdersStatusUseCase(get<_i26.OrdersRepository>()));
  gh.factory<_i50.GetOrdersUseCase>(
      () => _i50.GetOrdersUseCase(get<_i26.OrdersRepository>()));
  gh.factory<_i51.JourneysBloc>(() => _i51.JourneysBloc(
        get<_i50.GetOrdersUseCase>(),
        get<_i42.AddOrdersToJourneyUseCase>(),
        get<_i40.AddFileForOrderUseCase>(),
        get<_i38.UploadFileForOrderUseCase>(),
        get<_i49.GetOrdersStatusUseCase>(),
        get<_i32.RejectOrderUseCase>(),
        get<_i41.AddMoneyToOrderUseCase>(),
        get<_i47.GetJourneyStatusUseCase>(),
        get<_i45.ChangeOrderStatusUseCase>(),
        get<_i48.GetJourneysUseCase>(),
        get<_i46.CreateJourneyUseCase>(),
      ));
  return get;
}

class _$AppModule extends _i52.AppModule {}
