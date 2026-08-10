import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/data/model/upload_file_media_server_response.dart';
import 'package:trydos/core/data/model/upload_ticket_response.dart';
import 'package:trydos/core/domin/repositories/common_use_repository.dart';
import 'package:trydos/core/domin/usecases/mint_upload_ticket_usecase.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/core/use_case/use_case.dart';

/// تدفّق الرفع المُقيَّد كاملاً في دالة واحدة: استخراج التذكرة ثم الرفع.
///
/// تستعملها كل المواضع التي ترفع ملفاً مفرداً إلى خادم الميديا، فلا يتكرّر
/// منطق التذكرة (ولا يُنسى) في كل حالة استخدام.
///
/// [folder] مسار المجلّد كما يقبله الخادم: مقاطع `[A-Za-z0-9._-]` يفصلها `/`،
/// بلا `/` في أوّله أو آخره — وتُقتطع هنا احتياطاً.
Future<Either<Failure, UploadFileMediaServerResponseModel>>
uploadToMediaServer({
  required CommonUseRepository repository,
  required File file,
  String? folder,
  bool isStory = false,
  bool usingOnUploadingFinishedFunction = false,
  bool usingSendProgressFunction = false,
}) async {
  final String? normalizedFolder = folder == null || folder.isEmpty
      ? null
      : folder.replaceAll(RegExp(r'^/+|/+$'), '');

  final ticketResult = await repository.mintUploadTicket(
    await MintUploadTicketParams(
      folder: normalizedFolder,
      count: 1,
      story: isStory,
    ).map(),
  );

  final UploadTicketResponseModel? ticket = ticketResult.fold(
    (failure) => null,
    (value) => value,
  );
  if (ticket == null) {
    return Left(
      ticketResult.swap().getOrElse(
        () => UploadFileMediaServerUseCase._missingTicketFailure,
      ),
    );
  }
  if (!ticket.isValid) {
    return const Left(UploadFileMediaServerUseCase._missingTicketFailure);
  }

  return repository.uploadFileMediaServer(
    await UploadFileMediaServerParams(
      file: file,
      folder: normalizedFolder,
      isStory: isStory,
      usingOnUploadingFinishedFunction: usingOnUploadingFinishedFunction,
      usingSendProgressFunction: usingSendProgressFunction,
    ).map(ticket: ticket.ticket!),
  );
}

/// رفع ملف واحد إلى خادم الميديا عبر التدفّق المُقيَّد بخطوتين:
///
/// 1. استخراج تذكرة (`POST /gated/ticket`) بـ `folder` و`story` و`count: 1`.
/// 2. الرفع (`POST /gated/upload`) بترويسة `X-Upload-Ticket`.
///
/// `folder` و`story` مقيَّدان بالتذكرة، فلا يُرسلان مع جسم الرفع.
@injectable
class UploadFileMediaServerUseCase
    extends
        UseCase<
          UploadFileMediaServerResponseModel,
          UploadFileMediaServerParams
        > {
  final CommonUseRepository repository;

  UploadFileMediaServerUseCase(this.repository);

  @override
  Future<Either<Failure, UploadFileMediaServerResponseModel>> call(
    UploadFileMediaServerParams params,
  ) => uploadToMediaServer(
    repository: repository,
    file: params.file,
    folder: params.folder,
    isStory: params.isStory,
    usingOnUploadingFinishedFunction: params.usingOnUploadingFinishedFunction,
    usingSendProgressFunction: params.usingSendProgressFunction,
  );

  static const ServerFailure _missingTicketFailure = ServerFailure(
    'Upload ticket is missing',
    message: 'Upload ticket is missing',
    statusCode: 403,
  );
}

class UploadFileMediaServerParams {
  UploadFileMediaServerParams({
    required this.file,
    this.folder,
    this.isStory = false,
    required this.usingOnUploadingFinishedFunction,
    required this.usingSendProgressFunction,
  });

  File file;
  String? folder;
  bool isStory = false;
  bool usingOnUploadingFinishedFunction;
  bool usingSendProgressFunction;

  Future<Map<String, dynamic>> map({required String ticket}) async {
    // حقل الملف وحده: `folder` مقيَّد بالتذكرة ويُتجاهَل هنا
    final FormData data = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path),
    });

    return {
      'data': data,
      'ticket': ticket,
      'usingOnUploadingFinishedFunction': usingOnUploadingFinishedFunction,
      'usingSendProgressFunction': usingSendProgressFunction,
    };
  }
}
