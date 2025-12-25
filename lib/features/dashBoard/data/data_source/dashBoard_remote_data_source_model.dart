import 'package:injectable/injectable.dart';
import 'package:trydos/common/constant/configuration/dashBoard_url_routes.dart';
import 'package:trydos/core/api/client_config.dart';
import 'package:trydos/core/api/methods/detect_server.dart';
import 'package:trydos/core/api/methods/get.dart';
import 'package:trydos/core/api/methods/post.dart';
import 'package:trydos/core/api/methods/put.dart';
import 'package:trydos/features/dashBoard/data/models/get_seller_boutiques_model.dart';
import 'package:trydos/features/dashBoard/data/models/get_seller_orders_model.dart';
import 'package:trydos/features/dashBoard/data/models/get_seller_products_model.dart';
import 'package:trydos/features/dashBoard/data/models/get_user_permission_model.dart';
import 'package:trydos/features/dashBoard/data/models/get_user_roles_model.dart';
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
              fromJson: (response) => GetUserPermissionModel.fromJson(response),
            ),
          ),
        );
    return getUserPermission();
  }

  Future<GetUserRolesModel> getUserRoles() {
    GetClient<GetUserRolesModel> getUserRoles = GetClient<GetUserRolesModel>(
      serverName: ServerName.dashBoard,
      requestPrams: RequestConfig<GetUserRolesModel>(
        endpoint: DashBoardEndPoints.getUserRolesEP,
        response: ResponseValue<GetUserRolesModel>(
          fromJson: (response) => GetUserRolesModel.fromJson(response),
        ),
      ),
    );
    return getUserRoles();
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

  Future<GetSellerProductsModel> getProducts() {
    GetClient<GetSellerProductsModel> getProducts =
        GetClient<GetSellerProductsModel>(
          serverName: ServerName.dashBoard,
          requestPrams: RequestConfig<GetSellerProductsModel>(
            endpoint: DashBoardEndPoints.getProducts,
            response: ResponseValue<GetSellerProductsModel>(
              fromJson: (response) => GetSellerProductsModel.fromJson(response),
            ),
          ),
        );
    return getProducts();
  }

  Future<GetSellerBoutiquesModel> getBoutiques() {
    GetClient<GetSellerBoutiquesModel> getBoutiques =
        GetClient<GetSellerBoutiquesModel>(
          serverName: ServerName.dashBoard,
          requestPrams: RequestConfig<GetSellerBoutiquesModel>(
            endpoint: DashBoardEndPoints.getBoutiques,
            response: ResponseValue<GetSellerBoutiquesModel>(
              fromJson: (response) =>
                  GetSellerBoutiquesModel.fromJson(response),
            ),
          ),
        );
    return getBoutiques();
  }

  Future<GetSellerOrdersModel> getOrders() {
    GetClient<GetSellerOrdersModel> getOrders = GetClient<GetSellerOrdersModel>(
      serverName: ServerName.dashBoard,
      requestPrams: RequestConfig<GetSellerOrdersModel>(
        endpoint: DashBoardEndPoints.getOrders,
        response: ResponseValue<GetSellerOrdersModel>(
          fromJson: (response) => GetSellerOrdersModel.fromJson(response),
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
}
