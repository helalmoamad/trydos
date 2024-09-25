import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/home/data/models/get_cart_item_model.dart';
import 'package:trydos/features/home/data/models/get_category_model.dart';
import 'package:trydos/features/home/data/models/get_currency_for_country_model.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repositories/home_repository.dart';

@injectable
class GetCurrencyForCountryUseCase
    implements UseCase<GetCurrencyForCountryModel, NoParams> {
  GetCurrencyForCountryUseCase(this.repository);
  final HomeRepository repository;
  @override
  Future<Either<Failure, GetCurrencyForCountryModel>> call(
      NoParams params) async {
    return repository.getCurrencyForCountry();
  }
}
