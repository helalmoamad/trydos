import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/api/api.dart';
import 'package:trydos/core/data/model/bulk_upload_response.dart';
import 'package:trydos/core/data/model/excel_upload_response.dart';
import 'package:trydos/core/data/model/upload_file_cloudinary_response.dart';
import 'package:trydos/core/data/model/upload_file_media_server_response.dart';
import 'package:trydos/core/data/model/upload_ticket_response.dart';
import 'package:trydos/core/domin/repositories/common_use_repository.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/features/chat/data/models/upload_file_response_model.dart';

import '../data_source/common_use_repo_data_source.dart';

@LazySingleton(as: CommonUseRepository)
class CommonUseRepositoryImpl extends CommonUseRepository
    with HandlingExceptionRequest {
  final CommonUseRemoteDataSource commonUseRemoteDataSource;

  CommonUseRepositoryImpl(this.commonUseRemoteDataSource);

  @override
  Future<Either<Failure, UploadFileCloudinaryResponseModel>>
  uploadFileCloudinary(Map<String, dynamic> params) {
    return handlingExceptionRequest(
      tryCall: () => commonUseRemoteDataSource.uploadCloudinaryFile(params),
    );
  }

  @override
  Future<Either<Failure, UploadTicketResponseModel>> mintUploadTicket(
    Map<String, dynamic> params,
  ) {
    return handlingExceptionRequest(
      tryCall: () => commonUseRemoteDataSource.mintUploadTicket(params),
    );
  }

  @override
  Future<Either<Failure, UploadFileMediaServerResponseModel>>
  uploadFileMediaServer(Map<String, dynamic> params) {
    return handlingExceptionRequest(
      tryCall: () => commonUseRemoteDataSource.uploadMediaServerFile(params),
    );
  }

  @override
  Future<Either<Failure, BulkUploadResponseModel>> uploadBulkImages(
    Map<String, dynamic> params,
  ) {
    return handlingExceptionRequest(
      tryCall: () => commonUseRemoteDataSource.uploadMediaServerBulk(params),
    );
  }

  @override
  Future<Either<Failure, ExcelUploadResponseModel>> uploadExcelFile(
    Map<String, dynamic> params,
  ) {
    return handlingExceptionRequest(
      tryCall: () => commonUseRemoteDataSource.uploadMediaServerExcel(params),
    );
  }

  @override
  Future<Either<Failure, UploadFileResponseModel>> uploadChatFile(
    Map<String, dynamic> params,
  ) {
    return handlingExceptionRequest(
      tryCall: () => commonUseRemoteDataSource.uploadChatFileGated(params),
    );
  }
}
