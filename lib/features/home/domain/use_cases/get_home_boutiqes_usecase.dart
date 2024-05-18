import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/home/data/models/get_home_boutiqes_model.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repositories/home_repository.dart';

@injectable
class GetHomeBoutiqesUseCase
    implements UseCase<GetHomeBoutiquesModel, GetHomeBoutiqesParams> {
  GetHomeBoutiqesUseCase(this.repository);

  final HomeRepository repository;

  @override
  Future<Either<Failure, GetHomeBoutiquesModel>> call(
      GetHomeBoutiqesParams params) async {
    return repository.getHomeBoutiqes(params.map);
  }
}

class GetHomeBoutiqesParams {
  final String? offset;

  GetHomeBoutiqesParams({
    this.offset,
  });

  Map<String, dynamic> get map => {
        "offset": offset,
      };
}
