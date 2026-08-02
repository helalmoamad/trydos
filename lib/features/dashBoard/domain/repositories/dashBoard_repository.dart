import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:trydos/features/dashBoard/data/models/get_new_ordersToDashboard.dart';
import 'package:trydos/features/dashBoard/data/models/get_seller_boutiques_model.dart';
import 'package:trydos/features/dashBoard/data/models/get_seller_orders_model.dart';
import 'package:trydos/features/dashBoard/data/models/get_seller_products_model.dart';
import 'package:trydos/features/dashBoard/data/models/get_user_permission_model.dart';
import '../../../../core/error/failures.dart';
import 'package:trydos/features/dashBoard/data/models/get_user_roles_model.dart';
import 'package:trydos/features/dashBoard/data/models/get_users_model.dart';
import 'package:trydos/features/dashBoard/data/models/get_presigned_url_model.dart';
import 'package:trydos/features/dashBoard/data/models/get_vendor_request_model.dart';
import 'package:trydos/features/dashBoard/data/models/seller_story_model.dart';
import 'package:trydos/features/home/data/models/get_only_message_from_api_model.dart';

abstract class DashBoardRepository {
  Future<Either<Failure, GetUserPermissionModel>> getUserPermission();
  Future<Either<Failure, GetUserRolesModel>> getUserRoles({
    String? search,
    int page = 1,
  });
  Future<Either<Failure, GetUsersModel>> getUsers({int page = 1});
  Future<Either<Failure, ReadOnlyMessageFromApiModel>> addUser(
    Map<String, dynamic> params,
  );
  Future<Either<Failure, GetSellerProductsModel>> getProducts({int page = 1});
  Future<Either<Failure, GetSellerBoutiquesModel>> getBoutiques({int page = 1});
  Future<Either<Failure, GetSellerOrdersModel>> getOrders({int page = 1});
  Future<Either<Failure, NewOrdersResponse>> ChangeOrderDetailStatusToConfirmed(Map<String, dynamic> params); 
  Future<Either<Failure, NewOrdersResponse>> ChangeOrderDetailStatusToPacked(Map<String, dynamic> params);
  Future<Either<Failure, NewOrdersResponse>> newGetOrders({int page = 1, String? status});
  Future<Either<Failure, ReadOnlyMessageFromApiModel>> changeOrderStatus(
    Map<String, dynamic> params,
  );
  Future<Either<Failure, ReadOnlyMessageFromApiModel>> deleteUser(
    String userId,
  );
  Future<Either<Failure, ReadOnlyMessageFromApiModel>> updateUserRole(
    Map<String, dynamic> params,
  );
  Future<Either<Failure, ReadOnlyMessageFromApiModel>> leaveShop();
  Future<Either<Failure, GetPresignedUrlModel>> getPresignedUrl(
    String mimeType,
  );
  Future<Either<Failure, ReadOnlyMessageFromApiModel>> uploadFileToS3({
    required File file,
    required String uploadUrl,
    required String mimeType,
  });
  Future<Either<Failure, List<SellerStoryModel>>> getSellerStories(
    Map<String, dynamic> params,
  );
  Future<Either<Failure, SellerStoryModel>> createSellerStory(
    Map<String, dynamic> params,
  );
  Future<Either<Failure, bool>> deleteSellerStory(Map<String, dynamic> params);
  Future<Either<Failure, GetVendorRequestModel>> getVendorRequest();
  Future<Either<Failure, ReadOnlyMessageFromApiModel>> submitVendorRequest(
    Map<String, dynamic> params,
  );
  Future<Either<Failure, ReadOnlyMessageFromApiModel>> updateVendorRequest(
    int vendorRequestId,
    Map<String, dynamic> params,
  );
}
