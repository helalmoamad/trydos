import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:trydos/features/home/data/models/get_address_by_text_model.dart';

import 'package:trydos/features/home/domain/repositories/home_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class GetAddressByTextUsecase
    extends UseCase<GetAddressByTextModel, GetAddressByTextParams> {
  final HomeRepository repository;

  GetAddressByTextUsecase(this.repository);

  @override
  Future<Either<Failure, GetAddressByTextModel>> call(
      GetAddressByTextParams params) {
    return repository.getAddressByText(params.map);
  }
}

class GetAddressByTextParams {
  String? query;
  GetAddressByTextParams({this.query});
  Map<String, dynamic> get map => {
        "query": query,
      };
}
