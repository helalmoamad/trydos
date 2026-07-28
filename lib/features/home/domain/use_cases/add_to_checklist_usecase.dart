import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/checklist_action_model.dart';
import '../repositories/home_repository.dart';

@injectable
class AddToChecklistUseCase implements UseCase<ChecklistActionModel, int> {
  AddToChecklistUseCase(this.repository);

  final HomeRepository repository;

  @override
  Future<Either<Failure, ChecklistActionModel>> call(int productId) async {
    return repository.addToChecklist(productId: productId);
  }
}
