import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/home/data/models/get_address_by_coordinates_model.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class GetAddressByCoordinatesUsecase extends UseCase<
    GetAddressByCoordinatesModel, GetAddressByCoordinatesParams> {
  final HomeRepository repository;

  GetAddressByCoordinatesUsecase(this.repository);

  @override
  Future<Either<Failure, GetAddressByCoordinatesModel>> call(
      GetAddressByCoordinatesParams params) {
    return repository.getAddressByCoordinates(params.map);
  }
}

class GetAddressByCoordinatesParams {
  double? latitude;
  double? longitude;
  GetAddressByCoordinatesParams({this.longitude, this.latitude});
  Map<String, dynamic> get map =>
      {"longitude": longitude, "latitude": latitude};
}
