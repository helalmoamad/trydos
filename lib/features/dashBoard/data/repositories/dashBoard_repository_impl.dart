import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/api/api.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/features/dashBoard/data/data_source/dashBoard_remote_data_source_model.dart';
import 'package:trydos/features/dashBoard/data/models/get_seller_boutiques_model.dart';
import 'package:trydos/features/dashBoard/data/models/get_seller_orders_model.dart';
import 'package:trydos/features/dashBoard/data/models/get_seller_products_model.dart';
import 'package:trydos/features/dashBoard/data/models/get_user_permission_model.dart';
import 'dart:io';
import 'package:trydos/features/dashBoard/data/models/get_user_roles_model.dart';
import 'package:trydos/features/dashBoard/data/models/get_users_model.dart';
import 'package:trydos/features/dashBoard/data/models/get_presigned_url_model.dart';
import 'package:trydos/features/dashBoard/data/models/get_vendor_request_model.dart';
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
  Future<Either<Failure, GetUserRolesModel>> getUserRoles({
    String? search,
    int page = 1,
  }) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.getUserRoles(search: search, page: page),
    );
  }

  @override
  Future<Either<Failure, GetUsersModel>> getUsers({int page = 1}) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.getUsers(page: page),
    );
  }

  @override
  Future<Either<Failure, ReadOnlyMessageFromApiModel>> addUser(
    Map<String, dynamic> params,
  ) {
    return handlingExceptionRequest(tryCall: () => dataSource.addUser(params));
  }

  @override
  Future<Either<Failure, GetSellerProductsModel>> getProducts({int page = 1}) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.getProducts(page: page),
    );
  }

  @override
  Future<Either<Failure, GetSellerBoutiquesModel>> getBoutiques({
    int page = 1,
  }) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.getBoutiques(page: page),
    );
  }

  @override
  Future<Either<Failure, GetSellerOrdersModel>> getOrders({int page = 1}) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.getOrders(page: page),
    );
  }

  @override
  Future<Either<Failure, ReadOnlyMessageFromApiModel>> changeOrderStatus(
    Map<String, dynamic> params,
  ) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.changeOrderStatus(params),
    );
  }

  @override
  Future<Either<Failure, ReadOnlyMessageFromApiModel>> deleteUser(
    String userId,
  ) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.deleteUser(userId),
    );
  }

  @override
  Future<Either<Failure, ReadOnlyMessageFromApiModel>> updateUserRole(
    Map<String, dynamic> params,
  ) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.updateUserRole(params),
    );
  }

  @override
  Future<Either<Failure, ReadOnlyMessageFromApiModel>> leaveShop() {
    return handlingExceptionRequest(tryCall: () => dataSource.leaveShop());
  }

  @override
  Future<Either<Failure, GetPresignedUrlModel>> getPresignedUrl(
    String mimeType,
  ) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.getPresignedUrl(mimeType),
    );
  }

  @override
  Future<Either<Failure, ReadOnlyMessageFromApiModel>> uploadFileToS3({
    required File file,
    required String uploadUrl,
    required String mimeType,
  }) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.uploadFileToS3(
        file: file,
        uploadUrl: uploadUrl,
        mimeType: mimeType,
      ),
    );
  }

  @override
  Future<Either<Failure, GetVendorRequestModel>> getVendorRequest() {
    return handlingExceptionRequest(
      tryCall: () => dataSource.getVendorRequest(),
    );
  }

  @override
  Future<Either<Failure, ReadOnlyMessageFromApiModel>> submitVendorRequest(
    Map<String, dynamic> params,
  ) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.submitVendorRequest(params),
    );
  }

  @override
  Future<Either<Failure, ReadOnlyMessageFromApiModel>> updateVendorRequest(
    int vendorRequestId,
    Map<String, dynamic> params,
  ) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.updateVendorRequest(vendorRequestId, params),
    );
  }
}
