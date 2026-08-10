import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/home/data/models/upload_images_for_return_product_model.dart';

import '../../../../core/domin/repositories/common_use_repository.dart';
import '../../../../core/domin/usecases/upload_file_media_server_usecase.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

/// رفع صور تقييم الطلب وطلب الإرجاع عبر التدفّق المُقيَّد على خادم الميديا.
///
/// كانت الصور تُرفع إلى خادم السوق مباشرة؛ صارت تُرفع إلى
/// `POST /gated/upload` بالمجلّد الممرَّر (`rating_orders` أو
/// `return_request_products`)، ويُمرَّر المسار الفرعي الناتج في موضع
/// `sub_path` نفسه — فلا يتغيّر شيء عند المستهلكين ولا في شكل الروابط.
@injectable
class UploadImagesProductReturnUseCase
    extends
        UseCase<
          UploadImagesForReturnProductModel,
          UpdateImagesForReturnProductParams
        > {
  final CommonUseRepository repository;

  UploadImagesProductReturnUseCase(this.repository);

  @override
  Future<Either<Failure, UploadImagesForReturnProductModel>> call(
    UpdateImagesForReturnProductParams params,
  ) async {
    final result = await uploadToMediaServer(
      repository: repository,
      file: params.image,
      folder: params.path,
    );

    return result.fold(Left.new, (uploaded) {
      return Right(
        UploadImagesForReturnProductModel(
          isSuccessful: true,
          hasContent: true,
          code: 200,
          data: Data(subPath: uploaded.subPath),
        ),
      );
    });
  }
}

class UpdateImagesForReturnProductParams {
  /// يُستعمل الآن كـ `folder` في طلب التذكرة.
  final String path;

  final File image;

  UpdateImagesForReturnProductParams({
    required this.path,
    required this.image,
  });
}
