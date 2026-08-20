part of 'dashBoard_bloc.dart';

enum GetUserPermissionStatus { init, loading, success, failure }

enum GetUserRolesStatus { init, loading, success, failure }

enum AddUserStatus { init, loading, success, failure }

enum GetBoutiquesStatus { init, loading, success, failure }

enum GetOrdersStatus { init, loading, success, failure }

enum NewGetOrdersStatus { init, loading, success, failure }

enum ChangeOrderDetailStatusStatus { init, loading, success, failure }

enum GetProductsStatus { init, loading, success, failure }

enum GetUsersStatus { init, loading, success, failure }

enum ChangeOrderStatusStatus { init, loading, success, failure }

enum DeleteUserStatus { init, loading, success, failure }

enum ChangeUserRoleStatus { init, loading, success, failure }

enum LeaveShopStatus { init, loading, success, failure }

enum UploadDocumentStatus { init, loading, success, failure }

enum SubmitVendorRequestStatus { init, loading, success, failure }

enum GetVendorRequestStatus { init, loading, success, failure }

enum UpdateVendorRequestStatus { init, loading, success, failure }

enum GetSellerStoriesStatus { init, loading, success, failure }

enum CreateSellerStoryStatus { init, uploading, loading, success, failure }

enum DeleteSellerStoryStatus { init, loading, success, failure }

enum GetExcelCategoriesStatus { init, loading, success, failure }

enum DownloadExcelTemplateStatus { init, loading, success, failure }

enum GetUploadedExcelFilesStatus { initial, loading, success, failure }

@immutable
class DashBoardState extends Equatable {
  final GetUploadedExcelFilesStatus getUploadedExcelFilesStatus;
  final UploadedExcelFilesResponseModel? uploadedExcelFilesModel;
  final GetExcelCategoriesModel? excelCategoriesModel;
  final GetUserPermissionStatus getUserPermissionStatus;
  final GetUserRolesStatus getUserRolesStatus;
  final GetBoutiquesStatus getBoutiquesStatus;
  final GetOrdersStatus getOrdersStatus;
  final NewGetOrdersStatus newGetOrdersStatus;
  final ChangeOrderDetailStatusStatus changeOrderDetailStatusStatus;
  final GetProductsStatus getProductsStatus;
  final GetUsersStatus getUsersStatus;
  final ChangeOrderStatusStatus changeOrderStatusStatus;
  final AddUserStatus addUserStatus;
  final DeleteUserStatus deleteUserStatus;
  final ChangeUserRoleStatus changeUserRoleStatus;
  final LeaveShopStatus leaveShopStatus;
  final UploadDocumentStatus uploadDocumentStatus;
  final String? uploadedDocumentKey;
  final SubmitVendorRequestStatus submitVendorRequestStatus;
  final GetVendorRequestStatus getVendorRequestStatus;
  final UpdateVendorRequestStatus updateVendorRequestStatus;
  final VendorRequestData? vendorRequest;
  final List<Shop>? shops;
  final List<ShopRole>? shopRoles;
  final Meta? rolesMeta;
  final List<boutiques_model.Boutique>? boutiques;
  final boutiques_model.Meta? boutiquesMeta;
  final List<orders_model.UserOrder>? orders;
  final List<UserOrderNew>? new_orders;
  final orders_model.Meta? ordersMeta;
  final newMeta? newOrdersMeta;
  final orders_model.UserAbilities? ordersUserAbilities;
  final newUserAbilities? newOrdersUserAbilities;
  final List<products_model.Product>? products;
  final products_model.Meta? productsMeta;
  final List<users_model.User>? users;
  final users_model.Meta? usersMeta;
  final GetSellerStoriesStatus storiesStatus;
  final CreateSellerStoryStatus createStoryStatus;
  final DeleteSellerStoryStatus deleteStoryStatus;
  final List<SellerStoryModel>? stories;
  final GetExcelCategoriesStatus getExcelCategoriesStatus;
  final DownloadExcelTemplateStatus downloadExcelTemplateStatus;
  final String? downloadedTemplatePath;

  DashBoardState({
    this.getUploadedExcelFilesStatus = GetUploadedExcelFilesStatus.initial,
    this.uploadedExcelFilesModel,
    this.downloadedTemplatePath,
    this.storiesStatus = GetSellerStoriesStatus.init,
    this.createStoryStatus = CreateSellerStoryStatus.init,
    this.deleteStoryStatus = DeleteSellerStoryStatus.init,
    this.stories,
    this.changeOrderDetailStatusStatus = ChangeOrderDetailStatusStatus.init,
    this.new_orders,
    this.getUserPermissionStatus = GetUserPermissionStatus.init,
    this.newGetOrdersStatus = NewGetOrdersStatus.init,
    this.getUserRolesStatus = GetUserRolesStatus.init,
    this.addUserStatus = AddUserStatus.init,
    this.getBoutiquesStatus = GetBoutiquesStatus.init,
    this.getOrdersStatus = GetOrdersStatus.init,
    this.getProductsStatus = GetProductsStatus.init,
    this.getUsersStatus = GetUsersStatus.init,
    this.changeOrderStatusStatus = ChangeOrderStatusStatus.init,
    this.deleteUserStatus = DeleteUserStatus.init,
    this.changeUserRoleStatus = ChangeUserRoleStatus.init,
    this.leaveShopStatus = LeaveShopStatus.init,
    this.uploadDocumentStatus = UploadDocumentStatus.init,
    this.uploadedDocumentKey,
    this.submitVendorRequestStatus = SubmitVendorRequestStatus.init,
    this.getVendorRequestStatus = GetVendorRequestStatus.init,
    this.updateVendorRequestStatus = UpdateVendorRequestStatus.init,
    this.vendorRequest,
    this.shops,
    this.shopRoles,
    this.excelCategoriesModel,
    this.boutiques,
    this.boutiquesMeta,
    this.orders,
    this.ordersMeta,
    this.ordersUserAbilities,
    this.newOrdersMeta,
    this.newOrdersUserAbilities,
    this.products,
    this.productsMeta,
    this.users,
    this.usersMeta,
    this.rolesMeta,
    this.getExcelCategoriesStatus = GetExcelCategoriesStatus.init,
    this.downloadExcelTemplateStatus = DownloadExcelTemplateStatus.init,
  });
  DashBoardState copyWith({
    GetUploadedExcelFilesStatus? getUploadedExcelFilesStatus,
    UploadedExcelFilesResponseModel? uploadedExcelFilesModel,
    String? downloadedTemplatePath,
    GetExcelCategoriesModel? excelCategoriesModel,
    GetExcelCategoriesStatus? getExcelCategoriesStatus,
    ChangeOrderDetailStatusStatus? changeOrderDetailStatusStatus,
    newMeta? newOrdersMeta,
    orders_model.Meta? ordersMeta,
    orders_model.UserAbilities? ordersUserAbilities,
    newUserAbilities? newOrdersUserAbilities,
    GetUserPermissionStatus? getUserPermissionStatus,
    GetUserRolesStatus? getUserRolesStatus,
    NewGetOrdersStatus? newGetOrdersStatus,
    GetBoutiquesStatus? getBoutiquesStatus,
    GetOrdersStatus? getOrdersStatus,
    GetProductsStatus? getProductsStatus,
    GetUsersStatus? getUsersStatus,
    ChangeOrderStatusStatus? changeOrderStatusStatus,
    AddUserStatus? addUserStatus,
    DeleteUserStatus? deleteUserStatus,
    ChangeUserRoleStatus? changeUserRoleStatus,
    LeaveShopStatus? leaveShopStatus,
    UploadDocumentStatus? uploadDocumentStatus,
    String? uploadedDocumentKey,
    SubmitVendorRequestStatus? submitVendorRequestStatus,
    GetVendorRequestStatus? getVendorRequestStatus,
    UpdateVendorRequestStatus? updateVendorRequestStatus,
    VendorRequestData? vendorRequest,
    List<Shop>? shops,
    List<ShopRole>? shopRoles,
    Meta? rolesMeta,
    List<boutiques_model.Boutique>? boutiques,
    boutiques_model.Meta? boutiquesMeta,
    List<orders_model.UserOrder>? orders,
    List<UserOrderNew>? new_orders,
    List<products_model.Product>? products,
    products_model.Meta? productsMeta,
    List<users_model.User>? users,
    users_model.Meta? usersMeta,
    GetSellerStoriesStatus? storiesStatus,
    CreateSellerStoryStatus? createStoryStatus,
    DeleteSellerStoryStatus? deleteStoryStatus,
    List<SellerStoryModel>? stories,
    DownloadExcelTemplateStatus? downloadExcelTemplateStatus,
  }) {
    return DashBoardState(
      downloadedTemplatePath:
          downloadedTemplatePath ?? this.downloadedTemplatePath,
      storiesStatus: storiesStatus ?? this.storiesStatus,
      createStoryStatus: createStoryStatus ?? this.createStoryStatus,
      deleteStoryStatus: deleteStoryStatus ?? this.deleteStoryStatus,
      stories: stories ?? this.stories,
      changeOrderDetailStatusStatus:
          changeOrderDetailStatusStatus ?? this.changeOrderDetailStatusStatus,
      newOrdersMeta: newOrdersMeta ?? this.newOrdersMeta,
      newOrdersUserAbilities:
          newOrdersUserAbilities ?? this.newOrdersUserAbilities,
      getUserPermissionStatus:
          getUserPermissionStatus ?? this.getUserPermissionStatus,
      newGetOrdersStatus: newGetOrdersStatus ?? this.newGetOrdersStatus,
      getUserRolesStatus: getUserRolesStatus ?? this.getUserRolesStatus,
      getBoutiquesStatus: getBoutiquesStatus ?? this.getBoutiquesStatus,
      getOrdersStatus: getOrdersStatus ?? this.getOrdersStatus,
      getProductsStatus: getProductsStatus ?? this.getProductsStatus,
      getUsersStatus: getUsersStatus ?? this.getUsersStatus,
      changeOrderStatusStatus:
          changeOrderStatusStatus ?? this.changeOrderStatusStatus,
      addUserStatus: addUserStatus ?? this.addUserStatus,
      deleteUserStatus: deleteUserStatus ?? this.deleteUserStatus,
      changeUserRoleStatus: changeUserRoleStatus ?? this.changeUserRoleStatus,
      leaveShopStatus: leaveShopStatus ?? this.leaveShopStatus,
      uploadDocumentStatus: uploadDocumentStatus ?? this.uploadDocumentStatus,
      uploadedDocumentKey: uploadedDocumentKey ?? this.uploadedDocumentKey,
      submitVendorRequestStatus:
          submitVendorRequestStatus ?? this.submitVendorRequestStatus,
      getVendorRequestStatus:
          getVendorRequestStatus ?? this.getVendorRequestStatus,
      updateVendorRequestStatus:
          updateVendorRequestStatus ?? this.updateVendorRequestStatus,
      vendorRequest: vendorRequest ?? this.vendorRequest,
      shops: shops ?? this.shops,
      shopRoles: shopRoles ?? this.shopRoles,
      rolesMeta: rolesMeta ?? this.rolesMeta,
      boutiques: boutiques ?? this.boutiques,
      boutiquesMeta: boutiquesMeta ?? this.boutiquesMeta,
      orders: orders ?? this.orders,
      new_orders: new_orders ?? this.new_orders,
      ordersMeta: ordersMeta ?? this.ordersMeta,
      ordersUserAbilities: ordersUserAbilities ?? this.ordersUserAbilities,
      products: products ?? this.products,
      productsMeta: productsMeta ?? this.productsMeta,
      users: users ?? this.users,
      usersMeta: usersMeta ?? this.usersMeta,
      getExcelCategoriesStatus:
          getExcelCategoriesStatus ?? this.getExcelCategoriesStatus,
      excelCategoriesModel: excelCategoriesModel ?? this.excelCategoriesModel,
      downloadExcelTemplateStatus:
          downloadExcelTemplateStatus ?? this.downloadExcelTemplateStatus,
      getUploadedExcelFilesStatus:
          getUploadedExcelFilesStatus ?? this.getUploadedExcelFilesStatus,
      uploadedExcelFilesModel:
          uploadedExcelFilesModel ?? this.uploadedExcelFilesModel,
    );
  }

  @override
  List<Object?> get props => [
    getUserPermissionStatus,
    getUserRolesStatus,
    newGetOrdersStatus,
    changeOrderDetailStatusStatus,
    getBoutiquesStatus,
    getOrdersStatus,
    getProductsStatus,
    getUsersStatus,
    changeOrderStatusStatus,
    addUserStatus,
    deleteUserStatus,
    changeUserRoleStatus,
    leaveShopStatus,
    uploadDocumentStatus,
    uploadedDocumentKey,
    submitVendorRequestStatus,
    getVendorRequestStatus,
    updateVendorRequestStatus,
    vendorRequest,
    shops,
    shopRoles,
    rolesMeta,
    boutiques,
    boutiquesMeta,
    orders,
    new_orders,
    ordersMeta,
    ordersUserAbilities,
    newOrdersMeta,
    newOrdersUserAbilities,
    products,
    productsMeta,
    users,
    usersMeta,
    storiesStatus,
    createStoryStatus,
    deleteStoryStatus,
    stories,
    getExcelCategoriesStatus,
    excelCategoriesModel,
    downloadExcelTemplateStatus,
    downloadedTemplatePath,
    getUploadedExcelFilesStatus,
    uploadedExcelFilesModel,
  ];
}
