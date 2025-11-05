import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repositories/auth_repository.dart';

@injectable
class UpdateStoriesUserUseCase
    implements UseCase<bool, UpdateStoriesUserParams> {
  UpdateStoriesUserUseCase(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, bool>> call(UpdateStoriesUserParams params) async {
    return repository.updateStoriesUser(params.map);
  }
}

class UpdateStoriesUserParams {
  String? otpIdToken;
  String? phone;
  String? photo;
  String? name;

  UpdateStoriesUserParams({
    this.name,
    this.phone,
    this.photo,
    this.otpIdToken,
  });
  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();
  Map<String, dynamic> get map => {
        "name": name,
        "otp_id_token": _prefsRepository.idToken,
        "mobile_phone": phone,
        "photo_path":
            (photo ?? "").contains("/") ? photo?.split("/").last : photo,
      }..removeWhere((key, value) => key == "");
}
