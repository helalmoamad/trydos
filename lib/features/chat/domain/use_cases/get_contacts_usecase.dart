

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/chat/data/models/my_contacts_response_model.dart';
import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';



import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
@injectable
class GetContactsUseCase extends UseCase<MyContactsResponseModel , NoParams>{
  final ChatRepository repository;

  GetContactsUseCase(this.repository);

  @override
  Future<Either<Failure, MyContactsResponseModel>> call(NoParams params) {
    return repository.getContacts();
  }

}
