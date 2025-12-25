import 'package:dartz/dartz.dart';
import 'package:trydos/features/dashBoard/data/models/get_seller_boutiques_model.dart';
import 'package:trydos/features/dashBoard/data/models/get_seller_orders_model.dart';
import 'package:trydos/features/dashBoard/data/models/get_seller_products_model.dart';
import 'package:trydos/features/dashBoard/data/models/get_user_permission_model.dart';
import '../../../../core/error/failures.dart';
import 'package:trydos/features/dashBoard/data/models/get_user_roles_model.dart';
import 'package:trydos/features/home/data/models/get_only_message_from_api_model.dart';

abstract class DashBoardRepository {
  Future<Either<Failure, GetUserPermissionModel>> getUserPermission();
  Future<Either<Failure, GetUserRolesModel>> getUserRoles();
  Future<Either<Failure, ReadOnlyMessageFromApiModel>> addUser(
    Map<String, dynamic> params,
  );
  Future<Either<Failure, GetSellerProductsModel>> getProducts();
  Future<Either<Failure, GetSellerBoutiquesModel>> getBoutiques();
  Future<Either<Failure, GetSellerOrdersModel>> getOrders();
  Future<Either<Failure, ReadOnlyMessageFromApiModel>> changeOrderStatus(
    Map<String, dynamic> params,
  );
}
