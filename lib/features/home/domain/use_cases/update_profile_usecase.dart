import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';
import 'package:trydos/features/home/data/models/firebase_setting_for_notification_model.dart';
import 'package:trydos/features/home/data/models/update_item_in_cart_model.dart';
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
  final String name;
  final String phone;
  final String email;
  final String image;
  final String tall;
  final String weight;
  final String gender;
  final String alternative_phone;

  UpdateProfileParams(
      {required this.name,
      required this.email,
      required this.image,
      required this.tall,
      required this.weight,
      required this.gender,
      required this.alternative_phone,
      required this.phone});
  Map<String, dynamic> get map => {
        "name": name,
        "phone": phone,
        "email": email,
        "image": image,
        "tall": tall,
        "weight": weight,
        "gender": gender,
        "alternative_phone": alternative_phone,
      };
}
