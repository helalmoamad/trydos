part of 'dashBoard_bloc.dart';

abstract class DashBoardEvent {}

class GetUserPermissionEvent extends DashBoardEvent {
  GetUserPermissionEvent();
}

class GetUserRolesEvent extends DashBoardEvent {
  final String? search;
  final int page;
  GetUserRolesEvent({this.search, this.page = 1});
}

class AddUserEvent extends DashBoardEvent {
  final String phone;
  final String role_id;
  final String seller_id;
  AddUserEvent({
    required this.phone,
    required this.role_id,
    required this.seller_id,
  });
}

class ChangeOrderDetailStatusEvent extends DashBoardEvent {
  final int order_detail_id;
  final String status;
  ChangeOrderDetailStatusEvent({
    required this.order_detail_id,
    required this.status,
  });
}

class GetBoutiquesEvent extends DashBoardEvent {
  final int page;
  GetBoutiquesEvent({this.page = 1});
}

class GetOrdersEvent extends DashBoardEvent {
  final int page;
  GetOrdersEvent({this.page = 1});
}

class NewGetOrdersEvent extends DashBoardEvent {
  final int page;
  NewGetOrdersEvent({this.page = 1});
}

class GetProductsEvent extends DashBoardEvent {
  final int page;
  GetProductsEvent({this.page = 1});
}

class ChangeOrderStatusEvent extends DashBoardEvent {
  final int order_id;
  final String status;
  ChangeOrderStatusEvent({required this.order_id, required this.status});
}

class GetUsersEvent extends DashBoardEvent {
  final int page;
  GetUsersEvent({this.page = 1});
}

class DeleteUserEvent extends DashBoardEvent {
  final String userId;
  DeleteUserEvent({required this.userId});
}

class ChangeUserRoleEvent extends DashBoardEvent {
  final String userId;
  final String roleId;
  ChangeUserRoleEvent({required this.userId, required this.roleId});
}

class LeaveShopEvent extends DashBoardEvent {
  LeaveShopEvent();
}

class UploadDocumentEvent extends DashBoardEvent {
  final String filePath;
  final String mimeType;
  UploadDocumentEvent({required this.filePath, required this.mimeType});
}

class SubmitVendorRequestEvent extends DashBoardEvent {
  final SubmitVendorRequestParams params;
  SubmitVendorRequestEvent({required this.params});
}

class GetVendorRequestEvent extends DashBoardEvent {
  GetVendorRequestEvent();
}

class UpdateVendorRequestEvent extends DashBoardEvent {
  final UpdateVendorRequestParams params;
  UpdateVendorRequestEvent({required this.params});
}

class ResetVendorRequestStatesEvent extends DashBoardEvent {
  ResetVendorRequestStatesEvent();
}

class GetSellerStoriesEvent extends DashBoardEvent {
  final int page;
  final int perPage;
  GetSellerStoriesEvent({this.page = 1, this.perPage = 20});
}

/// Picks up the raw media file: the bloc uploads it to the media server and
/// then posts the story with the returned url (`add-seller-story`).
class CreateSellerStoryEvent extends DashBoardEvent {
  final File file;
  final bool isVideo;
  final String? link;
  final int? productId;
  final String? productSlug;
  CreateSellerStoryEvent({
    required this.file,
    required this.isVideo,
    this.link,
    this.productId,
    this.productSlug,
  });
}

class DeleteSellerStoryEvent extends DashBoardEvent {
  final int storyId;
  DeleteSellerStoryEvent({required this.storyId});
}

class ResetCreateStoryStateEvent extends DashBoardEvent {
  ResetCreateStoryStateEvent();
}

class GetExcelCategoriesEvent extends DashBoardEvent {
  GetExcelCategoriesEvent();
}

class DownloadExcelTemplateEvent extends DashBoardEvent {
  final int categoryId;
  DownloadExcelTemplateEvent({required this.categoryId});
  List<Object?> get props => [categoryId];
}

class GetUploadedExcelFilesEvent extends DashBoardEvent {
  final int page;
  GetUploadedExcelFilesEvent({this.page = 1});

  List<Object?> get props => [page];
}

class GetGalleryImagesEvent extends DashBoardEvent {
  final int page;
  final int perPage;
  final String? search;
  GetGalleryImagesEvent({this.page = 1, this.perPage = 20, this.search});
}

class DeleteGalleryImagesEvent extends DashBoardEvent {
  final List<int> ids;
  DeleteGalleryImagesEvent({required this.ids});
}

// ---------------------------------------------------------------------------
// Shop Info — ملف المتجر العام
// ---------------------------------------------------------------------------

/// تحميل ملف المتجر.
///
/// [canRead] هو قرار الصلاحية محسوباً في الواجهة، لأن الصلاحيات لا تعيش في
/// الحالة أصلاً — تصل الشاشة كمعامل بانٍ. حين يكون `false` لا يُرسل أي طلب.
class GetShopInfoEvent extends DashBoardEvent {
  final bool canRead;
  GetShopInfoEvent({required this.canRead});
}

/// مسح ما هو محمَّل عند تبديل المتجر: الحالة تعود إلى `init` والسجلّ يصير فارغاً.
/// لا يُسند `null` ولا تُبنى `DashBoardState` جديدة.
class ClearShopInfoEvent extends DashBoardEvent {
  ClearShopInfoEvent();
}

/// رفع شعار المتجر أو غلافه إلى مجلّد `seller` عبر تدفّق التذكرة.
class UploadShopMediaEvent extends DashBoardEvent {
  final File file;
  final bool isBanner;
  UploadShopMediaEvent({required this.file, required this.isBanner});
}

/// حفظ الحقول الخمسة كلّها.
///
/// [expectedSellerId] هو المتجر الذي حُمّل من أجله السجلّ؛ يُقارَن بالمتجر
/// المحدَّد حالياً كآخر خطوة متزامنة قبل استدعاء حالة الاستخدام.
class UpdateShopInfoEvent extends DashBoardEvent {
  final String name;
  final String address;
  final String contact;
  final String? image;
  final String? banner;
  final String? expectedSellerId;

  UpdateShopInfoEvent({
    required this.name,
    required this.address,
    required this.contact,
    required this.image,
    required this.banner,
    required this.expectedSellerId,
  });
}
