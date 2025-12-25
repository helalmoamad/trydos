import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/api/api.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/features/dashBoard/data/data_source/dashBoard_remote_data_source_model.dart';
import 'package:trydos/features/dashBoard/data/models/get_seller_boutiques_model.dart';
import 'package:trydos/features/dashBoard/data/models/get_seller_orders_model.dart';
import 'package:trydos/features/dashBoard/data/models/get_seller_products_model.dart';
import 'package:trydos/features/dashBoard/data/models/get_user_permission_model.dart';
import 'package:trydos/features/dashBoard/data/models/get_user_roles_model.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';
import 'package:trydos/features/home/data/models/get_only_message_from_api_model.dart';

@LazySingleton(as: DashBoardRepository)
class DashBoardRepositoryImpl extends DashBoardRepository
    with HandlingExceptionRequest {
  DashBoardRemoteDataSource dataSource;
  DashBoardRepositoryImpl(this.dataSource);
  @override
  Future<Either<Failure, GetUserPermissionModel>> getUserPermission() {
    return handlingExceptionRequest(
      tryCall: () => dataSource.getUserPermission(),
    );
  }

  @override
  Future<Either<Failure, GetUserRolesModel>> getUserRoles() {
    return handlingExceptionRequest(tryCall: () => dataSource.getUserRoles());
  }

  @override
  Future<Either<Failure, ReadOnlyMessageFromApiModel>> addUser(
    Map<String, dynamic> params,
  ) {
    return handlingExceptionRequest(tryCall: () => dataSource.addUser(params));
  }

  @override
  Future<Either<Failure, GetSellerProductsModel>> getProducts() {
    return handlingExceptionRequest(tryCall: () => dataSource.getProducts());
  }

  @override
  Future<Either<Failure, GetSellerBoutiquesModel>> getBoutiques() {
    return handlingExceptionRequest(tryCall: () => dataSource.getBoutiques());
  }

  @override
  Future<Either<Failure, GetSellerOrdersModel>> getOrders() {
    return handlingExceptionRequest(tryCall: () => dataSource.getOrders());
  }

  @override
  Future<Either<Failure, ReadOnlyMessageFromApiModel>> changeOrderStatus(
    Map<String, dynamic> params,
  ) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.changeOrderStatus(params),
    );
  }
}
