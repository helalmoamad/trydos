import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/api/api.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/features/dashBoard/data/data_source/dashBoard_remote_data_source_model.dart';
import 'package:trydos/features/dashBoard/data/models/GetGalleryImagesModel.dart';
import 'package:trydos/features/dashBoard/data/models/GetShopInfoModel.dart';
import 'package:trydos/features/dashBoard/data/models/UploadedExcelFileModel.dart';
import 'package:trydos/features/dashBoard/data/models/getExcelCategoriesModel.dart';
import 'package:trydos/features/dashBoard/data/models/get_shop_locations_model.dart';
import 'package:trydos/features/dashBoard/data/models/get_new_ordersToDashboard.dart';
import 'package:trydos/features/dashBoard/data/models/get_seller_boutiques_model.dart';
import 'package:trydos/features/dashBoard/data/models/get_seller_orders_model.dart';
import 'package:trydos/features/dashBoard/data/models/get_seller_products_model.dart';
import 'package:trydos/features/dashBoard/data/models/get_user_permission_model.dart';
import 'dart:io';
import 'package:trydos/features/dashBoard/data/models/get_user_roles_model.dart';
import 'package:trydos/features/dashBoard/data/models/get_users_model.dart';
import 'package:trydos/features/dashBoard/data/models/get_presigned_url_model.dart';
import 'package:trydos/features/dashBoard/data/models/get_vendor_request_model.dart';
import 'package:trydos/features/dashBoard/data/models/seller_story_model.dart';
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
  Future<Either<Failure, NewOrdersResponse>> newGetOrders({
    int page = 1,
    String? status,
  }) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.newGetOrders(page: page, status: status),
    );
  }

  @override
  Future<Either<Failure, NewOrdersResponse>> ChangeOrderDetailStatusToConfirmed(
    Map<String, dynamic> params,
  ) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.ChangeOrderDetailStatusToConfirmed(params),
    );
  }

  @override
  Future<Either<Failure, NewOrdersResponse>> ChangeOrderDetailStatusToPacked(
    Map<String, dynamic> params,
  ) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.ChangeOrderDetailStatusToPacked(params),
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
  Future<Either<Failure, List<SellerStoryModel>>> getSellerStories(
    Map<String, dynamic> params,
  ) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.getSellerStories(params),
    );
  }

  @override
  Future<Either<Failure, SellerStoryModel>> createSellerStory(
    Map<String, dynamic> params,
  ) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.createSellerStory(params),
    );
  }

  @override
  Future<Either<Failure, bool>> deleteSellerStory(Map<String, dynamic> params) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.deleteSellerStory(params),
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

  @override
  Future<Either<Failure, GetExcelCategoriesModel>> getCategories() {
    return handlingExceptionRequest(tryCall: () => dataSource.getCategories());
  }

  @override
  Future<Either<Failure, String>> downloadexceltemplate(int categoryId) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.downloadExcel(categoryId),
    );
  }

  @override
  Future<Either<Failure, UploadedExcelFilesResponseModel>>
  getUploadedExcelFiles({int page = 1}) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.getUploadedExcelFiles(page: page),
    );
  }

  @override
  Future<Either<Failure, GetGalleryImagesModel>> getGalleryImages({
    int page = 1,
    int perPage = 20,
    String? search,
  }) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.getGalleryImages(
        page: page,
        perPage: perPage,
        search: search,
      ),
    );
  }

  @override
  Future<Either<Failure, GetShopInfoModel>> getShopInfo() {
    return handlingExceptionRequest(tryCall: () => dataSource.getShopInfo());
  }

  @override
  Future<Either<Failure, UpdateShopInfoResponseModel>> updateShopInfo(
    Map<String, dynamic> params,
  ) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.updateShopInfo(params),
    );
  }

  @override
  Future<Either<Failure, ReadOnlyMessageFromApiModel>> deleteGalleryImages(
    List<int> ids,
  ) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.deleteGalleryImages(ids),
    );
  }

  // --- Locations ---------------------------------------------------------

  @override
  Future<Either<Failure, GetShopLocationsModel>> getShopLocations({
    int? status,
  }) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.getShopLocations(status: status),
    );
  }

  @override
  Future<Either<Failure, LocationFormLookupsModel>> getLocationFormCountries() {
    return handlingExceptionRequest(
      tryCall: () => dataSource.getLocationFormCountries(),
    );
  }

  @override
  Future<Either<Failure, ShopLocationWriteResponseModel>> createShopLocation(
    Map<String, dynamic> params,
    String? sellerId,
  ) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.createShopLocation(params, sellerId),
    );
  }

  @override
  Future<Either<Failure, ShopLocationEditModel>> getShopLocationForEdit(int id) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.getShopLocationForEdit(id),
    );
  }

  @override
  Future<Either<Failure, ShopLocationWriteResponseModel>> updateShopLocation(
    int id,
    Map<String, dynamic> params,
    String? sellerId,
  ) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.updateShopLocation(id, params, sellerId),
    );
  }

  @override
  Future<Either<Failure, ChangeLocationStatusResponseModel>>
  changeShopLocationStatus(int id, int status, String? sellerId) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.changeShopLocationStatus(id, status, sellerId),
    );
  }
}
