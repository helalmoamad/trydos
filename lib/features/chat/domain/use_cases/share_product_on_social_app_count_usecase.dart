import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class ShareProductOnAppsUseCase
    extends UseCase<bool, ShareProductOnAppsParams> {
  final ChatRepository repository;

  ShareProductOnAppsUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(ShareProductOnAppsParams params) {
    return repository.saveContacts(params.map);
  }
}

class ShareProductOnAppsParams {
  List<Map<String, dynamic>> contacts;

  ShareProductOnAppsParams({
    this.contacts = const [],
  });
  Map<String, dynamic> get map => {
        "contacts": contacts,
      };
}
