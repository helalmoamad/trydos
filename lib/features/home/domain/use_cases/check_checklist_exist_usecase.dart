import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/checklist_exist_model.dart';
import '../repositories/home_repository.dart';

@injectable
class CheckChecklistExistUseCase implements UseCase<ChecklistExistModel, int> {
  CheckChecklistExistUseCase(this.repository);

  final HomeRepository repository;

  @override
  Future<Either<Failure, ChecklistExistModel>> call(int productId) async {
    return repository.checkChecklistExist(productId: productId);
  }
}
