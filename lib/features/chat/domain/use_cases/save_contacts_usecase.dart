

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';



import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
@injectable
class SaveContactsUseCase extends UseCase<bool , SaveContactsParams>{
  final ChatRepository repository;

  SaveContactsUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(SaveContactsParams params) {
    return repository.saveContacts(params.map);
  }

}
class SaveContactsParams{
  List<Map<String,dynamic>> contacts;

  SaveContactsParams({
    this.contacts=const [],
  });
  Map<String, dynamic> get map =>{
    "contacts" :contacts,
  };
}