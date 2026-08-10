import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:injectable/injectable.dart';
import 'package:mime_type/mime_type.dart';
import '../../../../core/data/model/upload_ticket_response.dart';
import '../../../../core/domin/repositories/common_use_repository.dart';
import '../../../../core/domin/usecases/mint_upload_ticket_usecase.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/upload_file_response_model.dart';

/// رفع مرفق دردشة واحد عبر التدفّق المُقيَّد:
///
/// 1. استخراج تذكرة (`POST /gated/ticket`).
/// 2. الرفع (`POST /gated/chat/upload_file`) بترويسة `X-Upload-Ticket`.
///
/// انتقل الطلب من خادم الدردشة إلى خادم الميديا؛ الملف يُخزَّن تحت
/// `originals/chat/` بحدّ أعلى 25 ميغابايت، والاستجابة بغلاف
/// `{isSuccessful, data:{file_path,...}}` نفسه، فلا يتغيّر ما تقرأه الطبقات
/// الأعلى.
@injectable
class UploadFileUseCase
    extends UseCase<UploadFileResponseModel, UploadFileParams> {
  final CommonUseRepository repository;

  UploadFileUseCase(this.repository);

  @override
  Future<Either<Failure, UploadFileResponseModel>> call(
    UploadFileParams params,
  ) async {
    final ticketResult = await repository.mintUploadTicket(
      await MintUploadTicketParams(count: 1).map(),
    );

    // فشل استخراج التذكرة (401 لانتهاء الرمز مثلاً) يُمرَّر كما هو إلى
    // المستدعي ليعرض الرسالة كفاشلة ويتيح إعادة المحاولة.
    final UploadTicketResponseModel? ticket = ticketResult.fold(
      (failure) => null,
      (value) => value,
    );
    if (ticket == null) {
      return Left(ticketResult.swap().getOrElse(() => _missingTicketFailure));
    }
    if (!ticket.isValid) {
      return const Left(_missingTicketFailure);
    }

    return repository.uploadChatFile(await params.map(ticket: ticket.ticket!));
  }

  static const ServerFailure _missingTicketFailure = ServerFailure(
    'Upload ticket is missing',
    message: 'Upload ticket is missing',
    statusCode: 403,
  );
}

class UploadFileParams {
  UploadFileParams(this.file, this.filePath);
  File file;

  /// لم يعد يُرسَل مع الطلب: نقطة النهاية المُقيَّدة تخزّن تحت `chat/` دائماً،
  /// وحقول الجسم عدا `file` تُتجاهَل. أُبقي عليه حتى لا تتغيّر واجهة الاستدعاء.
  final String filePath;

  Future<Map<String, dynamic>> map({required String ticket}) async {
    final String fileName = file.path.split('/').last;
    final String mimeType = mime(fileName) ?? '';
    final List<String> mimeParts = mimeType.split('/');

    return {
      'data': FormData.fromMap({
        "file": await MultipartFile.fromFile(
          file.path,
          filename: fileName,
          // نوع المحتوى إرشادي فقط: الخادم يستنتج النوع من البايتات الأولى
          contentType: mimeParts.length == 2
              ? MediaType(mimeParts[0], mimeParts[1])
              : null,
        ),
      }),
      'ticket': ticket,
      'usingOnUploadingFinishedFunction': false,
      'usingSendProgressFunction': false,
    };
  }
}
