import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/get_checklist_model.dart';
import '../repositories/home_repository.dart';

@injectable
class GetChecklistUseCase
    implements UseCase<GetChecklistModel, GetChecklistParams> {
  GetChecklistUseCase(this.repository);

  final HomeRepository repository;

  @override
  Future<Either<Failure, GetChecklistModel>> call(
    GetChecklistParams params,
  ) async {
    return repository.getChecklist(
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class GetChecklistParams {
  final int page;
  final int pageSize;

  GetChecklistParams({required this.page, required this.pageSize});
}
