import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class UpdateProfileInChatUseCase
    extends UseCase<bool, UpdateProfileInChatParams> {
  final ChatRepository repository;

  UpdateProfileInChatUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(UpdateProfileInChatParams params) {
    return repository.updateProfileInChat(params.map);
  }
}

class UpdateProfileInChatParams {
  final String userId;
  final String name;
  final String phone;
  final String photo;
  UpdateProfileInChatParams({
    required this.userId,
    required this.phone,
    required this.photo,
    required this.name,
  });
  Map<String, dynamic> get map => {
    "id": userId,
    "name": name,
    "mobile_phone": phone,
    "photo_path":
        (((photo).contains("/") ? photo.split("/").last : photo).length > 1)
        ? ("/customers/profile/" +
              "${(photo).contains("/") ? photo.split("/").last : photo}")
        : "",
  };
}
