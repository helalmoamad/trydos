import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:trydos/features/home/data/models/update_profile_model.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class UpdateProfileUseCase
    extends UseCase<UpdateProfileModel, UpdateProfileParams> {
  final HomeRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, UpdateProfileModel>> call(UpdateProfileParams params) {
    return repository.updateProfile(params.map);
  }
}

class UpdateProfileParams {
  final String? name;
  final String? phone;
  final String? email;
  final String? image;
  final String? tall;
  final String? weight;
  final String? idToken;
  final String? gender;
  final String? alternative_phone;

  UpdateProfileParams(
      {this.name,
      this.email,
      this.image,
      this.tall,
      this.weight,
      this.idToken,
      this.gender,
      this.alternative_phone,
      this.phone});
  Map<String, dynamic> get map => {
        "name": name,
        "phone": phone,
        "email": email,
        "image": (image ?? "").contains("/") ? image?.split("/").last : image,
        "id_token": idToken,
        "tall": tall,
        "weight": weight,
        "gender": gender,
        "alternative_phone": alternative_phone,
      }..removeWhere((key, value) => value == null || value == "");
}
