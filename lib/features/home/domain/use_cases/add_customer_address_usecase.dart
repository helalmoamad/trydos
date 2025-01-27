import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';

import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';
import 'package:trydos/features/home/data/models/add_item_to_cart_model.dart';
import 'package:trydos/features/home/data/models/response_only_message_model.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/get_comment_for_product_model.dart';

@injectable
class AddCustomerAddressUseCase
    extends UseCase<ResponseOnlyMessageModel, AddCustomerAddressParams> {
  final HomeRepository repository;

  AddCustomerAddressUseCase(this.repository);

  @override
  Future<Either<Failure, ResponseOnlyMessageModel>> call(
      AddCustomerAddressParams params) {
    return repository.addCustomerAddress(params.map);
  }
}

class AddCustomerAddressParams {
  final String address;
  final String addressDetail;
  final String country;
  final String city;
  final String district;
  final String town;
  final String street;
  final String zip;
  final String phone;
  final String alternativePhone;
  final String latitude;
  final String longitude;
  final String province;
  final String building;
  final String contactPersonName;
  AddCustomerAddressParams(
      {required this.address,
      required this.addressDetail,
      required this.country,
      required this.city,
      required this.district,
      required this.town,
      required this.street,
      required this.zip,
      required this.phone,
      required this.alternativePhone,
      required this.latitude,
      required this.longitude,
      required this.province,
      required this.building,
      required this.contactPersonName});
  Map<String, dynamic> get map => {
        "address": address,
        "address_detail": addressDetail,
        "country": country,
        "contact_person_name": contactPersonName,
        "city": city,
        "district": district,
        "town": town,
        "street": street,
        "phone": phone,
        "alternative_phone": alternativePhone == "" ? null : alternativePhone,
        "latitude": latitude,
        "longitude": longitude,
        "province": province,
        "building": building
      };
}
