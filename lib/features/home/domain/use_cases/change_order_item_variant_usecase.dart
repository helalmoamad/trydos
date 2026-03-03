import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/home/data/models/get_only_message_from_api_model.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';

class ChangeOrderItemVariantParams {
  final String orderDetailId;
  final String size;
  final String color;
  final String? image;

  ChangeOrderItemVariantParams({
    required this.orderDetailId,
    required this.size,
    required this.color,
    this.image,
  });

  Map<String, dynamic> toMap() => {
    'order_detail_id': orderDetailId,
    'size': size,
    'color': color,
    'image': image?.split("/").last,
  };
}

@injectable
class ChangeOrderItemVariantUsecase
    extends UseCase<ReadOnlyMessageFromApiModel, ChangeOrderItemVariantParams> {
  final HomeRepository repository;

  ChangeOrderItemVariantUsecase(this.repository);

  @override
  Future<Either<Failure, ReadOnlyMessageFromApiModel>> call(
    ChangeOrderItemVariantParams params,
  ) {
    return repository.changeOrderItemVariant(params.toMap());
  }
}
