import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trydos/features/authentication/data/data_sources/auth_remote_datasource.dart';
import 'package:trydos/features/authentication/data/models/create_user_response_model.dart';
import 'package:trydos/features/authentication/domain/use_cases/create_user_usecase.dart';

import '../../helpers/test_helper.mocks.dart';

void main() {
  late CreateUserUseCase createUserUseCase;
  late MockChatRepository mockChatRepository;

  setUp(() {
    mockChatRepository = MockChatRepository();
    createUserUseCase = CreateUserUseCase(mockChatRepository);
  });

  final testcreatusermodel = CreateUserResponseModel(
      mobilePhone: "0855566666666",
      id: 12,
      createdAt: DateTime.tryParse("2200-21-22"),
      name: "helal",
      updatedAt: DateTime.now(),
      username: "ali ,pha,a,");

  test('should get current weather detail from the repository', () async {
    // arrange
    when(mockChatRepository.createUser((CreateUserParams(
                name: "dd",
                mobilePhone: "0855566666666",
                password: "2233366535")
            .map)))
        .thenAnswer((_) async => Right(testcreatusermodel));

    // act
    final result = await createUserUseCase.call(CreateUserParams(
        name: "dd", mobilePhone: "0855566666666", password: "2233366535"));

    // assert
    expect(result, Right(testcreatusermodel));
  });
}
