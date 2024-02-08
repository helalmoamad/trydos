

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/calls/domain/repositories/calls_repository.dart';
import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';



import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
@injectable
class DeleteCallRegUseCase extends UseCase<bool , DeleteCallRegParams>{
  final CallsRepository repository;

  DeleteCallRegUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(DeleteCallRegParams params) {
    return repository.deleteCallRegister(params.map);
  }

}
class DeleteCallRegParams{
  final String callId;

  DeleteCallRegParams.DeleteCallRegParams({
    required this.callId,
  });
  Map<String, dynamic> get map =>{
    "id" :callId,
  };
}