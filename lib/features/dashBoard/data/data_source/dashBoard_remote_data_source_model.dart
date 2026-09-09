import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:trydos/common/constant/configuration/dashBoard_url_routes.dart';
// `show` keeps the `ScopeApi` extension of both url-routes files from clashing.
import 'package:trydos/common/constant/configuration/stories_url_routes.dart'
    show StoriesEndPoints;
import 'package:trydos/common/constant/configuration/web_app_url.dart';
import 'package:trydos/core/api/client_config.dart';
import 'package:trydos/core/api/methods/detect_server.dart';
import 'package:trydos/core/api/methods/get.dart';
import 'package:trydos/core/api/methods/post.dart';
import 'package:trydos/core/api/methods/put.dart';
import 'package:trydos/core/api/methods/delete.dart';
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
import 'package:trydos/features/dashBoard/data/models/get_user_roles_model.dart';
import 'package:trydos/features/dashBoard/data/models/get_users_model.dart';
import 'package:trydos/features/dashBoard/data/models/get_presigned_url_model.dart';
import 'package:trydos/features/dashBoard/data/models/get_vendor_request_model.dart';
import 'package:trydos/features/dashBoard/data/models/seller_story_model.dart';
import 'package:trydos/features/home/data/models/get_only_message_from_api_model.dart';

@injectable
class DashBoardRemoteDataSource {
  Future<GetUserPermissionModel> getUserPermission() {
    GetClient<GetUserPermissionModel> getUserPermission =
        GetClient<GetUserPermissionModel>(
          serverName: ServerName.dashBoard,
          requestPrams: RequestConfig<GetUserPermissionModel>(
            endpoint: DashBoardEndPoints.getUserPermissionEP,
            response: ResponseValue<GetUserPermissionModel>(
              fromJson: (response) {
                // Handle 204 No Content or empty response
                if (response == null) {
                  return GetUserPermissionModel(shops: []);
                }

                // If response is a String (empty or not), return empty model
                if (response is String) {
                  if (response.isEmpty || response.trim().isEmpty) {
                    return GetUserPermissionModel(shops: []);
                  }
                  // Try to parse string as JSON
                  try {
                    final decoded = json.decode(response);
                    if (decoded is Map<String, dynamic>) {
                      return GetUserPermissionModel.fromJson(decoded);
                    }
                  } catch (e) {
                    // If parsing fails, return empty model
                    return GetUserPermissionModel(shops: []);
                  }
                }

                // If response is already a Map, use it directly
                if (response is Map<String, dynamic>) {
                  return GetUserPermissionModel.fromJson(response);
                }

                // Default: return empty model
                return GetUserPermissionModel(shops: []);
              },
            ),
          ),
        );
    return getUserPermission();
  }

  Future<GetUserRolesModel> getUserRoles({String? search, int page = 1}) {
    Map<String, String> queryParameters = {'page': page.toString()};
    if (search != null && search.isNotEmpty) {
      queryParameters['search'] = search;
    }

    GetClient<GetUserRolesModel> getUserRoles = GetClient<GetUserRolesModel>(
      serverName: ServerName.dashBoard,
      requestPrams: RequestConfig<GetUserRolesModel>(
        endpoint: DashBoardEndPoints.getUserRolesEP,
        queryParameters: queryParameters,
        response: ResponseValue<GetUserRolesModel>(
          fromJson: (response) => GetUserRolesModel.fromJson(response),
        ),
      ),
    );
    return getUserRoles();
  }

  Future<GetUsersModel> getUsers({int page = 1}) {
    GetClient<GetUsersModel> getUsers = GetClient<GetUsersModel>(
      serverName: ServerName.dashBoard,
      requestPrams: RequestConfig<GetUsersModel>(
        endpoint: DashBoardEndPoints.getUsersEP,
        queryParameters: {'page': page.toString()},
        response: ResponseValue<GetUsersModel>(
          fromJson: (response) => GetUsersModel.fromJson(response),
        ),
      ),
    );
    return getUsers();
  }

  Future<ReadOnlyMessageFromApiModel> addUser(Map<String, dynamic> params) {
    PostClient<ReadOnlyMessageFromApiModel> addUser =
        PostClient<ReadOnlyMessageFromApiModel>(
          serverName: ServerName.dashBoard,
          requestPrams: RequestConfig<ReadOnlyMessageFromApiModel>(
            endpoint: DashBoardEndPoints.addUserEP,
            data: params,
            response: ResponseValue<ReadOnlyMessageFromApiModel>(
              fromJson: (response) =>
                  ReadOnlyMessageFromApiModel.fromJson(response),
            ),
          ),
        );
    return addUser();
  }

  Future<GetSellerProductsModel> getProducts({int page = 1}) {
    GetClient<GetSellerProductsModel> getProducts =
        GetClient<GetSellerProductsModel>(
          serverName: ServerName.dashBoard,
          requestPrams: RequestConfig<GetSellerProductsModel>(
            endpoint: DashBoardEndPoints.getProducts,
            queryParameters: {'page': page.toString()},
            response: ResponseValue<GetSellerProductsModel>(
              fromJson: (response) => GetSellerProductsModel.fromJson(response),
            ),
          ),
        );
    return getProducts();
  }

  Future<GetSellerBoutiquesModel> getBoutiques({int page = 1}) {
    GetClient<GetSellerBoutiquesModel> getBoutiques =
        GetClient<GetSellerBoutiquesModel>(
          serverName: ServerName.dashBoard,
          requestPrams: RequestConfig<GetSellerBoutiquesModel>(
            endpoint: DashBoardEndPoints.getBoutiques,
            queryParameters: {'page': page.toString()},
            response: ResponseValue<GetSellerBoutiquesModel>(
              fromJson: (response) =>
                  GetSellerBoutiquesModel.fromJson(response),
            ),
          ),
        );
    return getBoutiques();
  }

  Future<GetSellerOrdersModel> getOrders({int page = 1}) {
    GetClient<GetSellerOrdersModel> getOrders = GetClient<GetSellerOrdersModel>(
      serverName: ServerName.dashBoard,
      requestPrams: RequestConfig<GetSellerOrdersModel>(
        endpoint: DashBoardEndPoints.getOrders,
        queryParameters: {'page': page.toString()},
        response: ResponseValue<GetSellerOrdersModel>(
          fromJson: (response) => GetSellerOrdersModel.fromJson(response),
        ),
      ),
    );
    return getOrders();
  }

  Future<NewOrdersResponse> newGetOrders({int page = 1, String? status}) {
    GetClient<NewOrdersResponse> getOrders = GetClient<NewOrdersResponse>(
      serverName: ServerName.dashBoard,
      requestPrams: RequestConfig<NewOrdersResponse>(
        endpoint: DashBoardEndPoints.getOrders,
        queryParameters: {
          'page': page.toString(),
          if (status != null) 'status': status,
        },
        response: ResponseValue<NewOrdersResponse>(
          fromJson: (response) => NewOrdersResponse.fromJson(response),
        ),
      ),
    );
    return getOrders();
  }

  Future<NewOrdersResponse> ChangeOrderDetailStatusToConfirmed(
    Map<String, dynamic> params,
  ) {
    PutClient<NewOrdersResponse> getOrders = PutClient<NewOrdersResponse>(
      serverName: ServerName.dashBoard,
      requestPrams: RequestConfig<NewOrdersResponse>(
        endpoint: DashBoardEndPoints.changeOrderDetailStatusToConfirm,
        data: params,
        response: ResponseValue<NewOrdersResponse>(
          fromJson: (response) => NewOrdersResponse.fromJson(response),
        ),
      ),
    );
    return getOrders();
  }

  Future<NewOrdersResponse> ChangeOrderDetailStatusToPacked(
    Map<String, dynamic> params,
  ) {
    PutClient<NewOrdersResponse> getOrders = PutClient<NewOrdersResponse>(
      serverName: ServerName.dashBoard,
      requestPrams: RequestConfig<NewOrdersResponse>(
        endpoint: DashBoardEndPoints.changeOrderDetailStatusToPacked,
        data: params,
        response: ResponseValue<NewOrdersResponse>(
          fromJson: (response) => NewOrdersResponse.fromJson(response),
        ),
      ),
    );
    return getOrders();
  }

  Future<ReadOnlyMessageFromApiModel> changeOrderStatus(
    Map<String, dynamic> params,
  ) {
    PutClient<ReadOnlyMessageFromApiModel> changeOrderStatus =
        PutClient<ReadOnlyMessageFromApiModel>(
          serverName: ServerName.dashBoard,
          requestPrams: RequestConfig<ReadOnlyMessageFromApiModel>(
            endpoint: DashBoardEndPoints.changeOrderStatus,
            data: params,
            response: ResponseValue<ReadOnlyMessageFromApiModel>(
              fromJson: (response) =>
                  ReadOnlyMessageFromApiModel.fromJson(response),
            ),
          ),
        );
    return changeOrderStatus();
  }

  Future<ReadOnlyMessageFromApiModel> deleteUser(String userId) {
    DeleteClient<ReadOnlyMessageFromApiModel> deleteUser =
        DeleteClient<ReadOnlyMessageFromApiModel>(
          serverName: ServerName.dashBoard,
          requestPrams: RequestConfig<ReadOnlyMessageFromApiModel>(
            endpoint: DashBoardEndPoints.deleteUserEP(userId),
            response: ResponseValue<ReadOnlyMessageFromApiModel>(
              fromJson: (response) =>
                  ReadOnlyMessageFromApiModel.fromJson(response),
            ),
          ),
        );
    return deleteUser();
  }

  Future<ReadOnlyMessageFromApiModel> updateUserRole(
    Map<String, dynamic> params,
  ) {
    PutClient<ReadOnlyMessageFromApiModel> updateUserRole =
        PutClient<ReadOnlyMessageFromApiModel>(
          serverName: ServerName.dashBoard,
          requestPrams: RequestConfig<ReadOnlyMessageFromApiModel>(
            endpoint: DashBoardEndPoints.updateUserRoleEP,
            data: params,
            response: ResponseValue<ReadOnlyMessageFromApiModel>(
              fromJson: (response) =>
                  ReadOnlyMessageFromApiModel.fromJson(response),
            ),
          ),
        );
    return updateUserRole();
  }

  Future<ReadOnlyMessageFromApiModel> leaveShop() {
    DeleteClient<ReadOnlyMessageFromApiModel> leaveShop =
        DeleteClient<ReadOnlyMessageFromApiModel>(
          serverName: ServerName.dashBoard,
          requestPrams: RequestConfig<ReadOnlyMessageFromApiModel>(
            endpoint: DashBoardEndPoints.leaveShopEP,
            response: ResponseValue<ReadOnlyMessageFromApiModel>(
              fromJson: (response) =>
                  ReadOnlyMessageFromApiModel.fromJson(response),
            ),
          ),
        );
    return leaveShop();
  }

  Future<GetPresignedUrlModel> getPresignedUrl(String mimeType) {
    PostClient<GetPresignedUrlModel> getPresignedUrl =
        PostClient<GetPresignedUrlModel>(
          serverName: ServerName.dashBoard,
          requestPrams: RequestConfig<GetPresignedUrlModel>(
            endpoint: DashBoardEndPoints.getPresignedUrlEP,
            data: {'mime_type': mimeType},
            response: ResponseValue<GetPresignedUrlModel>(
              fromJson: (response) => GetPresignedUrlModel.fromJson(response),
            ),
          ),
        );
    return getPresignedUrl();
  }

  // ---------------------------------------------------------------------
  // Seller stories
  //
  // These three run against the stories server (STORY_URL + stories token)
  // and carry the shop in the `seller_id` field — no `X-Seller-ID` header.
  // ---------------------------------------------------------------------

  Future<List<SellerStoryModel>> getSellerStories(Map<String, dynamic> params) {
    GetClient<List<SellerStoryModel>> getSellerStories =
        GetClient<List<SellerStoryModel>>(
          serverName: ServerName.stories,
          requestPrams: RequestConfig<List<SellerStoryModel>>(
            endpoint: StoriesEndPoints.getSellerStoriesEP,
            // `Uri` only accepts String values in its query parameters.
            queryParameters: params.map(
              (key, value) => MapEntry(key, value.toString()),
            ),
            response: ResponseValue<List<SellerStoryModel>>(
              fromJson: (response) =>
                  SellerStoryModel.listFromResponse(response),
            ),
          ),
        );
    return getSellerStories();
  }

  Future<SellerStoryModel> createSellerStory(Map<String, dynamic> params) {
    PostClient<SellerStoryModel> createSellerStory =
        PostClient<SellerStoryModel>(
          serverName: ServerName.stories,
          requestPrams: RequestConfig<SellerStoryModel>(
            endpoint: StoriesEndPoints.addSellerStoryEP,
            data: params,
            response: ResponseValue<SellerStoryModel>(
              fromJson: (response) => SellerStoryModel.fromResponse(response),
            ),
          ),
        );
    return createSellerStory();
  }

  Future<bool> deleteSellerStory(Map<String, dynamic> params) {
    PostClient<bool> deleteSellerStory = PostClient<bool>(
      serverName: ServerName.stories,
      requestPrams: RequestConfig<bool>(
        endpoint: StoriesEndPoints.deleteSellerStoryEP,
        data: params,
        response: ResponseValue<bool>(returnValueOnSuccess: true),
      ),
    );
    return deleteSellerStory();
  }

  Future<ReadOnlyMessageFromApiModel> uploadFileToS3({
    required File file,
    required String uploadUrl,
    required String mimeType,
  }) async {
    // Create a new Dio instance without interceptors for S3 upload
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(minutes: 2),
        receiveTimeout: const Duration(minutes: 2),
        sendTimeout: const Duration(minutes: 2),
      ),
    );

    final fileBytes = await file.readAsBytes();

    final response = await dio.put(
      uploadUrl,
      data: fileBytes,
      options: Options(
        responseType: ResponseType.bytes,
        headers: {
          'Content-Type': mimeType,
          'Content-Length': fileBytes.length.toString(),
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return ReadOnlyMessageFromApiModel.fromJson({
        'message': 'file_uploaded_successfully', // Translation key
      });
    } else {
      throw Exception('Upload failed with status: ${response.statusCode}');
    }
  }

  Future<GetVendorRequestModel> getVendorRequest() {
    GetClient<GetVendorRequestModel> getVendorRequest =
        GetClient<GetVendorRequestModel>(
          serverName: ServerName.dashBoard,
          requestPrams: RequestConfig<GetVendorRequestModel>(
            endpoint: DashBoardEndPoints.vendorRequestsEP,
            response: ResponseValue<GetVendorRequestModel>(
              fromJson: (response) => GetVendorRequestModel.fromJson(response),
            ),
          ),
        );
    return getVendorRequest();
  }

  Future<ReadOnlyMessageFromApiModel> submitVendorRequest(
    Map<String, dynamic> params,
  ) {
    PostClient<ReadOnlyMessageFromApiModel> submitVendorRequest =
        PostClient<ReadOnlyMessageFromApiModel>(
          serverName: ServerName.dashBoard,
          requestPrams: RequestConfig<ReadOnlyMessageFromApiModel>(
            endpoint: DashBoardEndPoints.vendorRequestsEP,
            data: params,
            response: ResponseValue<ReadOnlyMessageFromApiModel>(
              fromJson: (response) =>
                  ReadOnlyMessageFromApiModel.fromJson(response),
            ),
          ),
        );
    return submitVendorRequest();
  }

  Future<ReadOnlyMessageFromApiModel> updateVendorRequest(
    int vendorRequestId,
    Map<String, dynamic> params,
  ) {
    PutClient<ReadOnlyMessageFromApiModel> updateVendorRequest =
        PutClient<ReadOnlyMessageFromApiModel>(
          serverName: ServerName.dashBoard,
          requestPrams: RequestConfig<ReadOnlyMessageFromApiModel>(
            endpoint: DashBoardEndPoints.updateVendorRequestEP(vendorRequestId),
            data: params,
            response: ResponseValue<ReadOnlyMessageFromApiModel>(
              fromJson: (response) =>
                  ReadOnlyMessageFromApiModel.fromJson(response),
            ),
          ),
        );
    return updateVendorRequest();
  }

  // upload excel file //

  Future<GetExcelCategoriesModel> getCategories() {
    final getExcelCategoriesModel = GetClient<GetExcelCategoriesModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<GetExcelCategoriesModel>(
        endpoint: WebAppEndPoints.getCategoriesEP,
        response: ResponseValue<GetExcelCategoriesModel>(
          fromJson: (response) => GetExcelCategoriesModel.fromJson(response),
        ),
      ),
    );

    return getExcelCategoriesModel();
  }

  Future<String> downloadExcel(int categoryId) async {
    GetClient<List<int>> getExcelClient = GetClient<List<int>>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<List<int>>(
        endpoint: WebAppEndPoints.downloadExcel(categoryId),
        responseType: ResponseType.bytes,
        response: ResponseValue<List<int>>(
          fromJson: (response) => response as List<int>,
        ),
      ),
    );

    final bytes = await getExcelClient();

    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'excel_template_$categoryId.xlsx';
    final filePath = '${directory.path}/$fileName';

    final file = File(filePath);
    await file.writeAsBytes(bytes);

    return filePath;
  }

  Future<UploadedExcelFilesResponseModel> getUploadedExcelFiles({
    int page = 1,
  }) async {
    GetClient<UploadedExcelFilesResponseModel> getFiles =
        GetClient<UploadedExcelFilesResponseModel>(
          serverName: ServerName.market,
          requestPrams: RequestConfig<UploadedExcelFilesResponseModel>(
            endpoint: WebAppEndPoints.getUploadedExcelFiles(page: page),
            response: ResponseValue<UploadedExcelFilesResponseModel>(
              fromJson: (response) =>
                  UploadedExcelFilesResponseModel.fromJson(response),
            ),
          ),
        );
    return await getFiles();
  }

  // Future<MainCategoriesResponseModel> uploadExcel() async {
  //   GetClient<dynamic> getMainCategories = GetClient<dynamic>(
  //     serverName: ServerName.market,
  //     //ServerName.elastic,
  //     requestPrams: RequestConfig<dynamic>(
  //       endpoint: WebAppEndPoints.downloadExcel(),
  //       //ElasticEndPoints.getMainCategoriesEP,
  //       // MarketEndPoints.getMainCategoriesRelatedWithBoutiquesEP,
  //       queryParameters: ,
  //       response: ResponseValue<dynamic>(fromJson: (response) => response),
  //     ),
  //   );
  //   final raw = await getMainCategories();
  //   return parseMainCategoriesInBackground(raw);
  // }

   Future<GetGalleryImagesModel> getGalleryImages({
    int page = 1,
    int perPage = 20,
    String? search,
  }) {
    Map<String, String> queryParameters = {
      'page': page.toString(),
      'per_page': perPage.toString(),
    };
    if (search != null && search.isNotEmpty) {
      queryParameters['search'] = search;
    }

    GetClient<GetGalleryImagesModel> getGalleryImages =
        GetClient<GetGalleryImagesModel>(
          serverName: ServerName.dashBoard,
          requestPrams: RequestConfig<GetGalleryImagesModel>(
            endpoint: DashBoardEndPoints.getGalleryImagesEP,
            queryParameters: queryParameters,
            response: ResponseValue<GetGalleryImagesModel>(
              fromJson: (response) => GetGalleryImagesModel.fromJson(response),
            ),
          ),
        );
    return getGalleryImages();
  }

  /// `GET /shop/info` — ملف المتجر العام للمتجر المحدَّد حالياً.
  ///
  /// ترويسات `Authorization` و`X-Seller-ID` و`country` و`lang` تُحقن مركزياً في
  /// `BaseApi`، فلا يضيفها هذا الطلب.
  Future<GetShopInfoModel> getShopInfo() {
    GetClient<GetShopInfoModel> getShopInfo = GetClient<GetShopInfoModel>(
      serverName: ServerName.dashBoard,
      requestPrams: RequestConfig<GetShopInfoModel>(
        endpoint: DashBoardEndPoints.shopInfoEP,
        response: ResponseValue<GetShopInfoModel>(
          fromJson: (response) => GetShopInfoModel.fromJson(response),
        ),
      ),
    );
    return getShopInfo();
  }

  /// `PUT /shop/info` — استبدال كامل: الحقول الخمسة تُرسل كلّها في كل مرة.
  Future<UpdateShopInfoResponseModel> updateShopInfo(
    Map<String, dynamic> params,
  ) {
    PutClient<UpdateShopInfoResponseModel> updateShopInfo =
        PutClient<UpdateShopInfoResponseModel>(
          serverName: ServerName.dashBoard,
          requestPrams: RequestConfig<UpdateShopInfoResponseModel>(
            endpoint: DashBoardEndPoints.shopInfoEP,
            data: params,
            response: ResponseValue<UpdateShopInfoResponseModel>(
              fromJson: (response) =>
                  UpdateShopInfoResponseModel.fromJson(response),
            ),
          ),
        );
    return updateShopInfo();
  }

  // ---------------------------------------------------------------------------
  // Locations
  //
  // The tenant guard is split by direction. Every **write** carries the shop id
  // captured when the action started, on the request itself, through
  // `extraHeaders` — so a shop switch between starting the write and sending it
  // cannot make it land on another shop (AC-23). Only `post.dart` honours that
  // field, and every write here is a `POST`, so no shared client is touched.
  //
  // The **read** deliberately does not carry it. `get.dart` discards
  // `extraHeaders` silently, and adding the merge there would touch the shared
  // `GET` client used by every screen in the app. The bloc re-checks the shop
  // when the response arrives instead.
  // ---------------------------------------------------------------------------

  /// `GET /shop/locations` — one request, one page. Paging is a separate work
  /// item, so no `page` parameter is sent.
  ///
  /// `status` is sent only when set. The contract's second trap: `status=0` is
  /// a real filter value, so this tests for null, never for falsy.
  Future<GetShopLocationsModel> getShopLocations({int? status}) {
    final Map<String, String> queryParameters = <String, String>{};
    if (status != null) {
      queryParameters['status'] = status.toString();
    }

    GetClient<GetShopLocationsModel> getShopLocations =
        GetClient<GetShopLocationsModel>(
          serverName: ServerName.dashBoard,
          requestPrams: RequestConfig<GetShopLocationsModel>(
            endpoint: DashBoardEndPoints.shopLocationsEP,
            queryParameters: queryParameters,
            response: ResponseValue<GetShopLocationsModel>(
              fromJson: (response) => GetShopLocationsModel.fromJson(response),
            ),
          ),
        );
    return getShopLocations();
  }

  /// `GET /shop/locations/lookups` — the create form's country list.
  Future<LocationFormLookupsModel> getLocationFormCountries() {
    GetClient<LocationFormLookupsModel> getLocationFormCountries =
        GetClient<LocationFormLookupsModel>(
          serverName: ServerName.dashBoard,
          requestPrams: RequestConfig<LocationFormLookupsModel>(
            endpoint: DashBoardEndPoints.shopLocationLookupsEP,
            response: ResponseValue<LocationFormLookupsModel>(
              fromJson: (response) =>
                  LocationFormLookupsModel.fromJson(response),
            ),
          ),
        );
    return getLocationFormCountries();
  }

  /// `POST /shop/locations` — create.
  Future<ShopLocationWriteResponseModel> createShopLocation(
    Map<String, dynamic> params,
    String? sellerId,
  ) {
    PostClient<ShopLocationWriteResponseModel> createShopLocation =
        PostClient<ShopLocationWriteResponseModel>(
          serverName: ServerName.dashBoard,
          requestPrams: RequestConfig<ShopLocationWriteResponseModel>(
            endpoint: DashBoardEndPoints.shopLocationsEP,
            data: params,
            extraHeaders: _sellerHeader(sellerId),
            response: ResponseValue<ShopLocationWriteResponseModel>(
              fromJson: (response) =>
                  ShopLocationWriteResponseModel.fromJson(response),
            ),
          ),
        );
    return createShopLocation();
  }

  /// `GET /shop/locations/{id}/edit` — the record and its country list.
  Future<ShopLocationEditModel> getShopLocationForEdit(int id) {
    GetClient<ShopLocationEditModel> getShopLocationForEdit =
        GetClient<ShopLocationEditModel>(
          serverName: ServerName.dashBoard,
          requestPrams: RequestConfig<ShopLocationEditModel>(
            endpoint: DashBoardEndPoints.shopLocationEditEP(id),
            response: ResponseValue<ShopLocationEditModel>(
              fromJson: (response) => ShopLocationEditModel.fromJson(response),
            ),
          ),
        );
    return getShopLocationForEdit();
  }

  /// `POST /shop/locations/{id}/update` — note the method: POST, not PUT.
  Future<ShopLocationWriteResponseModel> updateShopLocation(
    int id,
    Map<String, dynamic> params,
    String? sellerId,
  ) {
    PostClient<ShopLocationWriteResponseModel> updateShopLocation =
        PostClient<ShopLocationWriteResponseModel>(
          serverName: ServerName.dashBoard,
          requestPrams: RequestConfig<ShopLocationWriteResponseModel>(
            endpoint: DashBoardEndPoints.shopLocationUpdateEP(id),
            data: params,
            extraHeaders: _sellerHeader(sellerId),
            response: ResponseValue<ShopLocationWriteResponseModel>(
              fromJson: (response) =>
                  ShopLocationWriteResponseModel.fromJson(response),
            ),
          ),
        );
    return updateShopLocation();
  }

  /// `POST /shop/locations/{id}/change-status`.
  Future<ChangeLocationStatusResponseModel> changeShopLocationStatus(
    int id,
    int status,
    String? sellerId,
  ) {
    PostClient<ChangeLocationStatusResponseModel> changeShopLocationStatus =
        PostClient<ChangeLocationStatusResponseModel>(
          serverName: ServerName.dashBoard,
          requestPrams: RequestConfig<ChangeLocationStatusResponseModel>(
            endpoint: DashBoardEndPoints.shopLocationChangeStatusEP(id),
            data: <String, dynamic>{'status': status},
            extraHeaders: _sellerHeader(sellerId),
            response: ResponseValue<ChangeLocationStatusResponseModel>(
              fromJson: (response) =>
                  ChangeLocationStatusResponseModel.fromJson(response),
            ),
          ),
        );
    return changeShopLocationStatus();
  }

  /// One `const` key, built at one place. `post.dart` merges the caller's map
  /// **last**, and Dio normalises header keys case-insensitively — so a caller
  /// key of `authorization`, `country` or `lang` would replace auth material.
  /// Building the map here from a single fixed key is what keeps this feature
  /// unable to exercise that. Hardening `post.dart` is a `lib/core/api/**`
  /// change and belongs to its own ticket.
  static const String _kSellerIdHeader = 'X-Seller-ID';

  Map<String, dynamic>? _sellerHeader(String? sellerId) {
    if (sellerId == null || sellerId.isEmpty) return null;
    return <String, dynamic>{_kSellerIdHeader: sellerId};
  }

  Future<ReadOnlyMessageFromApiModel> deleteGalleryImages(List<int> ids) {
    DeleteClient<ReadOnlyMessageFromApiModel> deleteGalleryImages =
        DeleteClient<ReadOnlyMessageFromApiModel>(
          serverName: ServerName.dashBoard,
          requestPrams: RequestConfig<ReadOnlyMessageFromApiModel>(
            endpoint: DashBoardEndPoints.getGalleryImagesEP, // نفس المسار — DELETE بجسم { ids }
            data: {'ids': ids},
            response: ResponseValue<ReadOnlyMessageFromApiModel>(
              fromJson: (response) =>
                  ReadOnlyMessageFromApiModel.fromJson(response),
            ),
          ),
        );
    return deleteGalleryImages();
  }
}
