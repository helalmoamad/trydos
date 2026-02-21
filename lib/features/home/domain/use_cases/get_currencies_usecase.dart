import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/home/data/models/currencies_response_model.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class GetCurrenciesForWalletUseCase
    implements UseCase<CurrenciesForWalletResponseModel, NoParams> {
  GetCurrenciesForWalletUseCase(this.repository);

  final HomeRepository repository;

  @override
  Future<Either<Failure, CurrenciesForWalletResponseModel>> call(
    NoParams params,
  ) async {
    return repository.getCurrenciesForWallet();
  }
}
