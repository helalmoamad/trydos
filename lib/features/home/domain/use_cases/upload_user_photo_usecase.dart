import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:trydos/features/home/data/models/upload_user_photo_model.dart';

import '../../../../core/domin/repositories/common_use_repository.dart';
import '../../../../core/domin/usecases/upload_file_media_server_usecase.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

/// رفع صورة الملف الشخصي عبر التدفّق المُقيَّد على خادم الميديا.
///
/// كانت الصورة تُرفع إلى خادم السوق مباشرة؛ صارت تُرفع إلى
/// `POST /gated/upload` بمجلّد `customers/profile`، ويُمرَّر المسار الفرعي
/// الناتج إلى خادم السوق في موضع `sub_path` نفسه — فلا يتغيّر شيء عند
/// المستهلكين ولا في شكل الروابط المخزَّنة.
@injectable
class UpdateUserPhotoUseCase
    extends UseCase<UploadUserPhotoModel, UpdatePhotoParams> {
  final CommonUseRepository repository;

  UpdateUserPhotoUseCase(this.repository);

  @override
  Future<Either<Failure, UploadUserPhotoModel>> call(
    UpdatePhotoParams params,
  ) async {
    final result = await uploadToMediaServer(
      repository: repository,
      file: params.image,
      folder: params.path,
    );

    return result.fold(Left.new, (uploaded) {
      return Right(
        UploadUserPhotoModel(
          isSuccessful: true,
          hasContent: true,
          code: 200,
          data: Data(subPath: uploaded.subPath),
        ),
      );
    });
  }
}

class UpdatePhotoParams {
  /// يُستعمل الآن كـ `folder` في طلب التذكرة (`customers/profile`).
  final String path;

  final File image;

  UpdatePhotoParams({required this.path, required this.image});
}
