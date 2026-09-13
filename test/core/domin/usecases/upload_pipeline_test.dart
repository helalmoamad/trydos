import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trydos/core/data/model/upload_file_media_server_response.dart';
import 'package:trydos/core/data/model/upload_ticket_response.dart';
import 'package:trydos/core/domin/repositories/common_use_repository.dart';
import 'package:trydos/core/domin/usecases/upload_file_media_server_usecase.dart';
import 'package:trydos/core/error/failures.dart';

/// Test ledger · wave 01 Core runtime · unit "Upload pipeline".
///
/// Product photos, chat files, story media, return-request images and the
/// profile photo all pass through here. The upload is gated in two steps: mint a
/// one-shot ticket, then upload with it. Sending the upload without a valid
/// ticket wastes the file and the user sees a failure they cannot explain, so
/// the order and the guards matter more than the happy path.
class _FakeCommonUseRepo implements CommonUseRepository {
  /// Names of the repository methods, in the order they were called.
  final List<String> calls = <String>[];
  final List<Map<String, dynamic>> ticketParams = <Map<String, dynamic>>[];
  final List<Map<String, dynamic>> uploadParams = <Map<String, dynamic>>[];

  Either<Failure, UploadTicketResponseModel> ticketResult =
      const Right<Failure, UploadTicketResponseModel>(
    UploadTicketResponseModel(ticket: 'ticket-abc', expiresIn: 120),
  );

  Either<Failure, UploadFileMediaServerResponseModel> uploadResult =
      Right<Failure, UploadFileMediaServerResponseModel>(
    UploadFileMediaServerResponseModel(
      url: 'https://media.test/image/upload/photos/uuid.jpg',
    ),
  );

  @override
  Future<Either<Failure, UploadTicketResponseModel>> mintUploadTicket(
    Map<String, dynamic> params,
  ) async {
    calls.add('mintUploadTicket');
    ticketParams.add(params);
    return ticketResult;
  }

  @override
  Future<Either<Failure, UploadFileMediaServerResponseModel>>
      uploadFileMediaServer(Map<String, dynamic> params) async {
    calls.add('uploadFileMediaServer');
    uploadParams.add(params);
    return uploadResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
        'the upload tests do not use ${invocation.memberName}',
      );
}

void main() {
  late Directory tempDir;
  late File file;
  late _FakeCommonUseRepo repo;

  setUp(() {
    // `UploadFileMediaServerParams.map` reads the file off disk to build the
    // multipart part, so this has to be a real one.
    tempDir = Directory.systemTemp.createTempSync('trydos_upload_test');
    file = File('${tempDir.path}/photo.jpg')..writeAsBytesSync(<int>[1, 2, 3]);
    repo = _FakeCommonUseRepo();
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  test('the ticket is minted first, then the upload carries it', () async {
    final Either<Failure, UploadFileMediaServerResponseModel> result =
        await uploadToMediaServer(
      repository: repo,
      file: file,
      folder: 'rating_orders',
    );

    expect(repo.calls, <String>['mintUploadTicket', 'uploadFileMediaServer'],
        reason: 'an upload without a ticket in hand is rejected by the server');

    // The ticket asks for exactly this one file, in this folder.
    expect(repo.ticketParams.single['data'],
        <String, dynamic>{'folder': 'rating_orders', 'count': 1, 'story': false});

    // The upload carries the minted ticket, and only the file — folder and story
    // are already bound to the ticket and must not be sent again.
    expect(repo.uploadParams.single['ticket'], 'ticket-abc');
    expect(repo.uploadParams.single['data'], isA<FormData>());

    expect(result.isRight(), isTrue);
    expect(
      result.getOrElse(() => UploadFileMediaServerResponseModel()).url,
      'https://media.test/image/upload/photos/uuid.jpg',
    );
  });

  test('a refused ticket stops the upload before the file is sent', () async {
    repo.ticketResult = const Left<Failure, UploadTicketResponseModel>(
      ServerFailure('no ticket', message: 'quota reached', statusCode: 429),
    );

    final Either<Failure, UploadFileMediaServerResponseModel> result =
        await uploadToMediaServer(repository: repo, file: file);

    expect(repo.calls, <String>['mintUploadTicket'],
        reason: 'the file must not leave the device without a ticket');
    expect(result.isLeft(), isTrue);
    expect(result.swap().getOrElse(() => throw StateError('expected a Left')).statusCode,
        429,
        reason: 'the real reason reaches the caller, not a generic error');
  });

  test('a ticket that came back empty is treated as no ticket at all', () async {
    // The call succeeded but the body carried no ticket string. `isValid` is the
    // only thing standing between that and an upload guaranteed to be rejected.
    repo.ticketResult = const Right<Failure, UploadTicketResponseModel>(
      UploadTicketResponseModel(ticket: '', expiresIn: 120),
    );

    final Either<Failure, UploadFileMediaServerResponseModel> result =
        await uploadToMediaServer(repository: repo, file: file);

    expect(repo.calls, <String>['mintUploadTicket']);
    expect(result.isLeft(), isTrue);
    expect(result.swap().getOrElse(() => throw StateError('expected a Left')).statusCode,
        403);
  });

  test('a failed upload comes back as a Left and stores no url', () async {
    repo.uploadResult =
        const Left<Failure, UploadFileMediaServerResponseModel>(
      ServerFailure('upload failed', message: 'file too large', statusCode: 413),
    );

    final Either<Failure, UploadFileMediaServerResponseModel> result =
        await uploadToMediaServer(repository: repo, file: file, isStory: true);

    expect(repo.calls, <String>['mintUploadTicket', 'uploadFileMediaServer']);
    expect(result.isLeft(), isTrue);
    expect(result.getOrElse(() => UploadFileMediaServerResponseModel()).url,
        isNull,
        reason: 'nothing may be stored for an upload that did not happen');

    // A story upload is flagged on the ticket, which is what lowers the size cap.
    expect((repo.ticketParams.single['data'] as Map<String, dynamic>)['story'],
        isTrue);
  });
}
