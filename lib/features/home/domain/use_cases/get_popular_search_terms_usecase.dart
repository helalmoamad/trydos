import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:trydos/features/home/data/models/popular_search_terms_model.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class GetPopularSearchItemUseCase
    implements UseCase<PopularSearchTermsModel, NoParams> {
  final HomeRepository repository;

  GetPopularSearchItemUseCase(this.repository);

  @override
  Future<Either<Failure, PopularSearchTermsModel>> call(NoParams params) {
    return repository.getPopularSearchTerms();
  }
}
