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


// ---------------------------------------------------------------------------
// Locations — a shop's warehouses and pickup points
//
// Five events. The add/edit form owns the other two calls (the create form's
// country list, and load-for-edit) in its own state and calls those use cases
// directly: both results belong to one open sheet, nothing else renders from
// them, and putting them on the shared state would leave a location record and
// a country list sitting on a bloc that is never disposed.
// ---------------------------------------------------------------------------

/// Load the list for the open shop.
///
/// [canRead] is the permission decision computed in the widget, because
/// permissions do not live in the state — they reach the screen as a
/// constructor argument. When it is `false` no request is sent at all.
class GetShopLocationsEvent extends DashBoardEvent {
  final bool canRead;
  GetShopLocationsEvent({required this.canRead});
}

/// Clear what is loaded, on a shop switch or when the screen is disposed.
///
/// This is the only event that increments the load generation. Everything the
/// Locations feature puts on the shared state is reset here, in one place:
/// the status, the list wrapper (which carries `meta` and the shop stamp with
/// it) and the write status.
class ClearShopLocationsEvent extends DashBoardEvent {
  ClearShopLocationsEvent();
}

/// Create a location. [canRead] travels with it so the handler can refresh the
/// list afterwards without the widget having to dispatch a second event.
class CreateShopLocationEvent extends DashBoardEvent {
  final String name;
  final int countryId;
  final String? address;
  final double? latitude;
  final double? longitude;
  final bool canRead;

  CreateShopLocationEvent({
    required this.name,
    required this.countryId,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.canRead,
  });
}

/// Update a location. The coordinates a record already had travel through
/// untouched, so an edit never drops them (AC-34).
class UpdateShopLocationEvent extends DashBoardEvent {
  final int id;
  final String name;
  final int countryId;
  final String? address;
  final double? latitude;
  final double? longitude;
  final bool canRead;

  UpdateShopLocationEvent({
    required this.id,
    required this.name,
    required this.countryId,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.canRead,
  });
}

/// Take a location out of service, or put it back.
///
/// [status] is what is being asked for; the row's new marker is whatever the
/// response returns.
class ChangeShopLocationStatusEvent extends DashBoardEvent {
  final int id;
  final int status;

  ChangeShopLocationStatusEvent({required this.id, required this.status});
}
