import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/dashBoard/data/models/GetShopInfoModel.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

/// الحقول الخمسة كلّها في كل حفظ — لا يوجد تحديث جزئي لهذه النقطة.
///
/// [image] و[banner] اسم ملف مجرّد أو `null`؛ التسطيح يقع قبل بناء هذه المعاملات.
class UpdateShopInfoParams {
  final String name;
  final String address;
  final String contact;
  final String? image;
  final String? banner;

  const UpdateShopInfoParams({
    required this.name,
    required this.address,
    required this.contact,
    required this.image,
    required this.banner,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'address': address,
    'contact': contact,
    'image': image,
    'banner': banner,
  };
}

@injectable
class UpdateShopInfoUseCase
    extends UseCase<UpdateShopInfoResponseModel, UpdateShopInfoParams> {
  final DashBoardRepository repository;

  UpdateShopInfoUseCase(this.repository);

  @override
  Future<Either<Failure, UpdateShopInfoResponseModel>> call(
    UpdateShopInfoParams params,
  ) {
    return repository.updateShopInfo(params.toMap());
  }
}
