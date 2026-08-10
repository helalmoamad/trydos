import 'package:dartz/dartz.dart';

import '../../../features/chat/data/models/upload_file_response_model.dart';
import '../../data/model/bulk_upload_response.dart';
import '../../data/model/excel_upload_response.dart';
import '../../data/model/upload_file_cloudinary_response.dart';
import '../../data/model/upload_file_media_server_response.dart';
import '../../data/model/upload_ticket_response.dart';
import '../../error/failures.dart';

abstract class CommonUseRepository {
  Future<Either<Failure, UploadFileCloudinaryResponseModel>>
  uploadFileCloudinary(Map<String, dynamic> params);

  /// الخطوة الأولى في تدفّق الرفع المُقيَّد: استخراج تذكرة لمرّة واحدة.
  Future<Either<Failure, UploadTicketResponseModel>> mintUploadTicket(
    Map<String, dynamic> params,
  );

  Future<Either<Failure, UploadFileMediaServerResponseModel>>
  uploadFileMediaServer(Map<String, dynamic> params);

  Future<Either<Failure, BulkUploadResponseModel>> uploadBulkImages(
    Map<String, dynamic> params,
  );

  Future<Either<Failure, ExcelUploadResponseModel>> uploadExcelFile(
    Map<String, dynamic> params,
  );

  Future<Either<Failure, UploadFileResponseModel>> uploadChatFile(
    Map<String, dynamic> params,
  );
}
