import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trydos/core/error/exception.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/features/authentication/data/models/create_user_response_model.dart';
import 'package:trydos/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:trydos/features/authentication/domain/use_cases/create_user_usecase.dart';

import '../../helpers/test_helper.mocks.dart';

void main() {
  late MockAuthRemoteDatasource mockAuthRemoteDatasource;
  late AuthRepositoryImpl authRepositoryImpl;

  setUp(() {
    mockAuthRemoteDatasource = MockAuthRemoteDatasource();
    authRepositoryImpl = AuthRepositoryImpl(mockAuthRemoteDatasource);
  });

  final testcreatusermodel = CreateUserResponseModel(
      mobilePhone: "0855566666666",
      id: 12,
      createdAt: DateTime.tryParse("2200-21-22"),
      name: "helal",
      updatedAt: DateTime.now(),
      username: "ali ,pha,a,");

  group('get current weather', () {
    test(
      'should return current weather when a call to data source is successful',
      () async {
        // arrange
        when(mockAuthRemoteDatasource.createUser(CreateUserParams(
                    name: "dd",
                    mobilePhone: "0855566666666",
                    password: "2233366535")
                .map))
            .thenAnswer((_) async => testcreatusermodel);

        // act
        final result = await authRepositoryImpl.createUser(CreateUserParams(
                name: "dd",
                mobilePhone: "0855566666666",
                password: "2233366535")
            .map);

        // assert
        expect(result, equals(Right(testcreatusermodel)));
      },
    );

    test(
      'should return server failure when a call to data source is unsuccessful',
      () async {
        // arrange
        when(mockAuthRemoteDatasource.createUser(CreateUserParams(
                    name: "dd",
                    mobilePhone: "0855566666666",
                    password: "2233366535")
                .map))
            .thenThrow(ServerException(message: "ServerException"));

        // act
        final result = await authRepositoryImpl.createUser(CreateUserParams(
                name: "dd",
                mobilePhone: "0855566666666",
                password: "2233366535")
            .map);

        // assert
        expect(result,
            equals(const Left(ServerFailure("***|| ServerException ||***"))));
      },
    );

    test(
      'should return connection failure when the device has no internet',
      () async {
        // arrange
        // arrange
        when(mockAuthRemoteDatasource.createUser(CreateUserParams(
                    name: "dd",
                    mobilePhone: "0855566666666",
                    password: "2233366535")
                .map))
            .thenThrow(
                const SocketException('Failed to connect to the network'));

        // act
        final result = await authRepositoryImpl.createUser(CreateUserParams(
                name: "dd",
                mobilePhone: "0855566666666",
                password: "2233366535")
            .map);

        // assert
        expect(result, equals(const Left(ServerFailure(""))));
      },
    );
  });
}
