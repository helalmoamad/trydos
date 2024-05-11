import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/features/authentication/data/models/create_user_response_model.dart';
import 'package:trydos/features/authentication/domain/use_cases/create_user_usecase.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';

import '../../../helpers/test_helper.mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockAuthRemoteDatasource mockAuthRemoteDatasource;
  late MockCreateUserUseCase mockCreateUserUseCase;
  late MockChatRepository mockChatRepository;
  late MockUpdateStoriesUserUseCase mockUpdateStoriesUserUseCase;
  late MockUpdateChatUserNameUseCase mockUpdateChatUserNameUseCase;
  late MockLoginToMarketUseCase mockLoginToMarketUseCase;
  late MockLoginToChatUseCase mockLoginToChatUseCase;
  late MockLoginToStoriesUseCase mockLoginToStoriesUseCase;
  late MockStoreFcmUseCase mockStoreFcmUseCase;
  late MockUpdateNameUseCase mockUpdateNameUseCase;
  late MockRegisterGuestUseCase mockRegisterGuestUseCase;
  late MockSendOtpUseCase mockSendOtpUseCase;
  late MockGetCustomerInfoUseCase mockGetCustomerInfoUseCase;
  late MockVerifyGuestPhoneUseCase mockVerifyGuestPhoneUseCase;
  late MockVerifyOtpSignInUseCase mockVerifyOtpSignInUseCase;
  late MockVerifyOtpSignUpUseCase mockVerifyOtpSignUpUseCase;
  late MockGetUserCountryUseCase mockGetUserCountryUseCase;
  late AuthBloc authBloc;
  late MockAppModule mockAppModule;
  late MockPrefsRepository mockPrefsRepository;

  setUp(() {
    mockPrefsRepository = MockPrefsRepository();
    mockAppModule = MockAppModule();
    mockUpdateStoriesUserUseCase = MockUpdateStoriesUserUseCase();
    mockUpdateChatUserNameUseCase = MockUpdateChatUserNameUseCase();
    mockCreateUserUseCase = MockCreateUserUseCase();
    mockLoginToChatUseCase = MockLoginToChatUseCase();
    mockLoginToMarketUseCase = MockLoginToMarketUseCase();
    mockLoginToStoriesUseCase = MockLoginToStoriesUseCase();
    mockStoreFcmUseCase = MockStoreFcmUseCase();
    mockUpdateNameUseCase = MockUpdateNameUseCase();
    mockRegisterGuestUseCase = MockRegisterGuestUseCase();
    mockSendOtpUseCase = MockSendOtpUseCase();
    mockGetCustomerInfoUseCase = MockGetCustomerInfoUseCase();
    mockVerifyGuestPhoneUseCase = MockVerifyGuestPhoneUseCase();
    mockVerifyOtpSignInUseCase = MockVerifyOtpSignInUseCase();
    mockGetUserCountryUseCase = MockGetUserCountryUseCase();
    mockVerifyOtpSignUpUseCase = MockVerifyOtpSignUpUseCase();
    authBloc = AuthBloc(
      mockUpdateStoriesUserUseCase,
      mockUpdateChatUserNameUseCase,
      mockCreateUserUseCase,
      mockLoginToChatUseCase,
      mockLoginToMarketUseCase,
      mockLoginToStoriesUseCase,
      mockStoreFcmUseCase,
      mockUpdateNameUseCase,
      mockRegisterGuestUseCase,
      mockSendOtpUseCase,
      mockGetCustomerInfoUseCase,
      mockVerifyGuestPhoneUseCase,
      mockVerifyOtpSignInUseCase,
      mockGetUserCountryUseCase,
      mockVerifyOtpSignUpUseCase,
    );
  });

  final testcreatusermodel = CreateUserResponseModel(
      mobilePhone: "0855566666666",
      id: 12,
      createdAt: DateTime.tryParse("2200-21-22"),
      name: "helal",
      updatedAt: DateTime.now(),
      username: "ali ,pha,a,");

  test('initial state should be empty', () {
    expect(authBloc.state,
        authBloc.state.copyWith(createUserStatus: CreateUserStatus.init));
  });

  blocTest<AuthBloc, AuthState>(
      'should emit [WeatherLoading, WeatherLoaded] when data is gotten successfully',
      build: () {
        when(mockCreateUserUseCase.call((CreateUserParams(
                name: "dd",
                mobilePhone: "0855566666666",
                password: "2233366535"))))
            .thenAnswer((_) async => Right(testcreatusermodel));
        return authBloc;
      },
      act: (bloc) => bloc.add(const CreateUserEvent(
          mobilePhone: "0855566666666", name: "dd", password: "2233366535")),
      wait: const Duration(milliseconds: 500),
      expect: () => [CreateUserStatus.loading, CreateUserStatus.success]);

  blocTest<AuthBloc, AuthState>(
      'should emit [WeatherLoading, WeatherLoadFailure] when get data is unsuccessful',
      build: () {
        when(mockCreateUserUseCase.call((CreateUserParams(
                name: "dd",
                mobilePhone: "0855566666666",
                password: "2233366535"))))
            .thenAnswer(
                (_) async => const Left(ServerFailure('Server failure')));
        return authBloc;
      },
      act: (bloc) => bloc.add(const CreateUserEvent(
          mobilePhone: "0855566666666", name: "dd", password: "2233366535")),
      wait: const Duration(milliseconds: 500),
      expect: () => [CreateUserStatus.loading, CreateUserStatus.failure]);
}
