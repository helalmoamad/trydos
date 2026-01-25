import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';
import 'package:trydos/features/home/data/models/get_only_message_from_api_model.dart';

@injectable
class SubmitVendorRequestUseCase
    extends UseCase<ReadOnlyMessageFromApiModel, SubmitVendorRequestParams> {
  final DashBoardRepository repository;

  SubmitVendorRequestUseCase(this.repository);

  @override
  Future<Either<Failure, ReadOnlyMessageFromApiModel>> call(
    SubmitVendorRequestParams params,
  ) {
    return repository.submitVendorRequest(params.toJson());
  }
}

class SubmitVendorRequestParams {
  final String fName;
  final String lName;
  final String email;
  final String phone;
  final String password;
  final String repeatPassword;
  final String currencyCode;
  final String countryIso;
  final String languageCode;
  final String shopName;
  final String shopAddress;
  final String locationCountryIso;
  final String locationName;
  final String locationAddress;
  final double? latitude;
  final double? longitude;
  final List<DocumentParams> documents;

  SubmitVendorRequestParams({
    required this.fName,
    required this.lName,
    required this.email,
    required this.phone,
    required this.password,
    required this.repeatPassword,
    required this.currencyCode,
    required this.countryIso,
    required this.languageCode,
    required this.shopName,
    required this.shopAddress,
    required this.locationCountryIso,
    required this.locationName,
    required this.locationAddress,
    this.latitude,
    this.longitude,
    required this.documents,
  });

  Map<String, dynamic> toJson() {
    return {
      'f_name': fName,
      'l_name': lName,
      'email': email,
      'phone': phone,
      'password': password,
      'repeat_password': repeatPassword,
      'currency_code': currencyCode,
      'country_iso': countryIso,
      'language_code': languageCode,
      'shop_name': shopName,
      'shop_address': shopAddress,
      'location_country_iso': locationCountryIso,
      'location_name': locationName,
      'location_address': locationAddress,
      'latitude': latitude,
      'longitude': longitude,
      'documents': documents.map((doc) => doc.toJson()).toList(),
    };
  }
}

class DocumentParams {
  final String type;
  final String path;

  DocumentParams({required this.type, required this.path});

  Map<String, dynamic> toJson() {
    return {'type': type, 'path': path};
  }
}
