import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trydos/core/api/handling_exception.dart';
import 'package:trydos/core/error/exception.dart';
import 'package:trydos/core/error/failures.dart';

/// Test ledger · wave 01 Core runtime · unit "Exception mapping".
///
/// Every repository call in the app is wrapped by
/// `handlingExceptionRequest`, so this is the funnel that decides what a
/// failure looks like by the time a bloc sees it. Get the status code wrong
/// here and a screen shows the wrong message for every endpoint at once.

/// The mixin needs a host class; nothing else about it matters.
class _Mapper with HandlingExceptionRequest {}

void main() {
  final _Mapper mapper = _Mapper();

  /// Runs the wrapper over a call that throws [error].
  Future<Either<Failure, String>> mapThrown(Object error) {
    return mapper.handlingExceptionRequest<String>(
      tryCall: () async => throw error,
    );
  }

  /// The `Failure` side, or a failure of the test if it came back `Right`.
  Failure failureOf(Either<Failure, Object?> either) {
    return either.fold((Failure f) => f, (Object? r) {
      fail('expected a Left, got Right($r)');
    });
  }

  test('getException maps each status code to its own exception type', () {
    expect(mapper.getException(statusCode: 400), isA<OperationFailedException>());
    expect(mapper.getException(statusCode: 401), isA<Unauth>());
    expect(mapper.getException(statusCode: 500),
        isA<ServerExceptionForCode500>());

    // Anything with no branch of its own falls back to the general type.
    expect(mapper.getException(statusCode: 404), isA<ServerException>());
    expect(mapper.getException(statusCode: 200), isA<ServerException>());

    // The message passed in survives onto the exception.
    final Unauth unauth =
        mapper.getException(statusCode: 401, message: 'token expired') as Unauth;
    expect(unauth.message, 'token expired');
    expect(unauth.statusCode, 401);
  });

  test('a successful call comes back as Right carrying the value', () async {
    final Either<Failure, String> result =
        await mapper.handlingExceptionRequest<String>(
      tryCall: () async => 'the payload',
    );

    expect(result.isRight(), isTrue);
    expect(result.getOrElse(() => 'not this'), 'the payload');
  });

  test('each exception becomes its matching Failure with the status code kept',
      () async {
    expect(failureOf(await mapThrown(ServerExceptionForCode500())).statusCode,
        500);
    expect(failureOf(await mapThrown(Unauth())).statusCode, 401);
    expect(failureOf(await mapThrown(ServerException())).statusCode, 400);

    final RequestOptions options = RequestOptions(path: '/orders');
    final Failure dioFailure = failureOf(
      await mapThrown(
        DioException(
          requestOptions: options,
          response: Response<dynamic>(
            requestOptions: options,
            statusCode: 503,
            data: const <String, dynamic>{'message': 'service down'},
          ),
        ),
      ),
    );
    expect(dioFailure, isA<DioFailure>());
    expect(dioFailure.statusCode, 503,
        reason: 'the transport status code must reach the bloc');
    expect(dioFailure.message, 'service down',
        reason: 'the backend message is the one worth showing');

    // 422 is the one path that carries the backend text through a ServerFailure.
    final Failure validation = failureOf(
      await mapThrown(
        DioException(
          requestOptions: options,
          response: Response<dynamic>(
            requestOptions: options,
            statusCode: 422,
            data: const <String, dynamic>{'message': 'phone already taken'},
          ),
        ),
      ),
    );
    expect(validation.statusCode, 422);
    expect(validation.message, 'phone already taken');
  });

  test('TryAgainException has no branch and loses tryCount', () async {
    // Pinning what the code does today, not what the name promises. There is no
    // `on TryAgainException` clause, so it lands in the general `catch` and comes
    // back as a plain 400 — `tryCount` never reaches the caller, and no bloc can
    // act on it. Changing this should be a deliberate edit that breaks this test.
    final Failure failure =
        failureOf(await mapThrown(TryAgainException(tryCount: 3)));

    expect(failure, isA<ServerFailure>());
    expect(failure.statusCode, 400);
    expect(failure, isNot(isA<TryAgainFailure>()),
        reason: 'documented gap: the retry count is dropped here');
  });

  test('an error nobody planned for still comes back as a Left', () async {
    // The wrapper must never let anything escape as a throw: a bloc that gets an
    // exception instead of a Left crashes the screen it was building.
    for (final Object thrown in <Object>[
      ArgumentError('bad input'),
      const FormatException('not json'),
      StateError('closed'),
    ]) {
      final Either<Failure, String> result = await mapThrown(thrown);
      expect(result.isLeft(), isTrue, reason: '$thrown escaped the wrapper');
      expect(failureOf(result).statusCode, 400);
    }
  });
}
