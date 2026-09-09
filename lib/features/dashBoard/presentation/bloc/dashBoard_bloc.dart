import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/dashBoard/data/models/GetGalleryImagesModel.dart';
import 'package:trydos/features/dashBoard/data/models/UploadedExcelFileModel.dart';
import 'package:trydos/features/dashBoard/data/models/getExcelCategoriesModel.dart';
import 'package:trydos/features/dashBoard/data/models/get_new_ordersToDashboard.dart';
import 'package:trydos/features/dashBoard/data/models/seller_story_model.dart';
import 'package:trydos/features/dashBoard/domain/useCase/DeleteGalleryImagesUseCase.dart';
import 'package:trydos/features/dashBoard/domain/useCase/GetGalleryImagesUseCase.dart';
import 'package:trydos/features/dashBoard/data/models/GetShopInfoModel.dart';
import 'package:trydos/features/dashBoard/domain/useCase/GetShopInfoUseCase.dart';
import 'package:trydos/features/dashBoard/domain/useCase/UpdateShopInfoUseCase.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:trydos/features/dashBoard/data/models/get_shop_locations_model.dart';
import 'package:trydos/features/dashBoard/domain/useCase/get_shop_locations_usecase.dart';
import 'package:trydos/features/dashBoard/domain/useCase/create_shop_location_usecase.dart';
import 'package:trydos/features/dashBoard/domain/useCase/update_shop_location_usecase.dart';
import 'package:trydos/features/dashBoard/domain/useCase/change_shop_location_status_usecase.dart';
import 'package:trydos/features/dashBoard/domain/useCase/GetUploadedExcelFilesUsecase.dart';
import 'package:trydos/features/dashBoard/domain/useCase/change_orderDetail_to_packed_useCase.dart';
import 'package:trydos/features/dashBoard/domain/useCase/change_order_detail_status.dart';
import 'package:trydos/features/dashBoard/domain/useCase/downloadExcelTemplate_usecase.dart';
import 'package:trydos/features/dashBoard/domain/useCase/getExcelCategories_usecase.dart';
import 'package:trydos/features/dashBoard/domain/useCase/newGetUserOrders_useCase.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:trydos/features/dashBoard/data/models/get_user_permission_model.dart';
import 'package:trydos/features/dashBoard/data/models/get_seller_products_model.dart'
    as products_model;
import 'package:trydos/features/dashBoard/data/models/get_seller_orders_model.dart'
    as orders_model;
import 'package:trydos/features/dashBoard/data/models/get_seller_boutiques_model.dart'
    as boutiques_model;
import 'package:trydos/features/dashBoard/data/models/get_user_roles_model.dart';
import 'package:trydos/features/dashBoard/data/models/get_users_model.dart'
    as users_model;
import 'package:trydos/features/dashBoard/domain/useCase/add_user_usecase.dart';
import 'package:trydos/features/dashBoard/domain/useCase/get_user_permission_usecase.dart.dart';
import 'package:trydos/features/dashBoard/domain/useCase/get_user_roles_usecase.dart';
import 'package:trydos/features/dashBoard/domain/useCase/get_orders_usecase.dart';
import 'package:trydos/features/dashBoard/domain/useCase/get_products_usecase.dart';
import 'package:trydos/features/dashBoard/domain/useCase/get_boutiques_usecase.dart';
import 'package:trydos/features/dashBoard/domain/useCase/change_order_status_usecase.dart';
import 'package:trydos/features/dashBoard/domain/useCase/get_users_usecase.dart';
import 'package:trydos/features/dashBoard/domain/useCase/delete_user_usecase.dart';
import 'package:trydos/features/dashBoard/domain/useCase/update_user_role_usecase.dart';
import 'package:trydos/features/dashBoard/domain/useCase/leave_shop_usecase.dart';
import 'package:trydos/features/dashBoard/domain/useCase/get_presigned_url_usecase.dart';
import 'package:trydos/features/dashBoard/domain/useCase/upload_file_to_s3_usecase.dart';
import 'package:trydos/features/dashBoard/domain/useCase/submit_vendor_request_usecase.dart';
export 'package:trydos/features/dashBoard/domain/useCase/submit_vendor_request_usecase.dart';
import 'package:trydos/features/dashBoard/domain/useCase/get_vendor_request_usecase.dart';
import 'package:trydos/features/dashBoard/domain/useCase/update_vendor_request_usecase.dart';
import 'package:trydos/features/dashBoard/data/models/get_vendor_request_model.dart';
import 'package:trydos/features/dashBoard/domain/useCase/get_seller_stories_usecase.dart';
import 'package:trydos/features/dashBoard/domain/useCase/create_seller_story_usecase.dart';
export 'package:trydos/features/dashBoard/domain/useCase/create_seller_story_usecase.dart';
import 'package:trydos/features/dashBoard/domain/useCase/delete_seller_story_usecase.dart';
import 'package:trydos/core/domin/usecases/upload_file_media_server_usecase.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:equatable/equatable.dart';
part 'dashBoard_event.dart';
part 'dashBoard_state.dart';

@LazySingleton()
class DashboardBloc extends Bloc<DashBoardEvent, DashBoardState> {
  final GetUserPermissionUseCase getUserPermissionUseCase;
  final GetUserRolesUseCase getUserRolesUseCase;
  final GetUploadedExcelFilesUsecase getUploadedExcelFilesUsecase;
  final GetUsersUseCase getUsersUseCase;
  final AddUserUseCase addUserUseCase;
  final GetOrdersUseCase getOrdersUseCase;
  final GetexcelcategoriesUsecase getexcelcategoriesUsecase;
  final DownloadexceltemplateUsecase downloadexceltemplateUsecase;
  final NewGetOrdersUseCase newGetOrdersUseCase;
  final GetProductsUseCase getProductsUseCase;
  final GetBoutiquesUseCase getBoutiquesUseCase;
  final ChangeOrderStatusUseCase changeOrderStatusUseCase;
  final DeleteUserUseCase deleteUserUseCase;
  final UpdateUserRoleUseCase updateUserRoleUseCase;
  final LeaveShopUseCase leaveShopUseCase;
  final GetPresignedUrlUseCase getPresignedUrlUseCase;
  final UploadFileToS3UseCase uploadFileToS3UseCase;
  final SubmitVendorRequestUseCase submitVendorRequestUseCase;
  final GetVendorRequestUseCase getVendorRequestUseCase;
  final UpdateVendorRequestUseCase updateVendorRequestUseCase;
  final ChangeOrderDetailStatusToConfirmedUseCase
  changeOrderDetailStatusToConfirmedUseCase;
  final ChangeOrderDetailStatusToPackedUseCase
  changeOrderDetailStatusToPackedUseCase;
  final GetSellerStoriesUseCase getSellerStoriesUseCase;
  final CreateSellerStoryUseCase createSellerStoryUseCase;
  final DeleteSellerStoryUseCase deleteSellerStoryUseCase;
  final UploadFileMediaServerUseCase uploadFileMediaServerUseCase;
  final GetGalleryImagesUseCase getGalleryImagesUseCase;
  final DeleteGalleryImagesUseCase deleteGalleryImagesUseCase;
  final GetShopInfoUseCase getShopInfoUseCase;
  final UpdateShopInfoUseCase updateShopInfoUseCase;
  final GetShopLocationsUseCase getShopLocationsUseCase;
  final CreateShopLocationUseCase createShopLocationUseCase;
  final UpdateShopLocationUseCase updateShopLocationUseCase;
  final ChangeShopLocationStatusUseCase changeShopLocationStatusUseCase;

  DashboardBloc(
    this.getUserPermissionUseCase,
    this.getUserRolesUseCase,
    this.getUsersUseCase,
    this.addUserUseCase,
    this.getOrdersUseCase,
    this.getexcelcategoriesUsecase,
    this.getProductsUseCase,
    this.getBoutiquesUseCase,
    this.changeOrderStatusUseCase,
    this.deleteUserUseCase,
    this.updateUserRoleUseCase,
    this.getUploadedExcelFilesUsecase,
    this.leaveShopUseCase,
    this.getPresignedUrlUseCase,
    this.uploadFileToS3UseCase,
    this.submitVendorRequestUseCase,
    this.getVendorRequestUseCase,
    this.updateVendorRequestUseCase,
    this.newGetOrdersUseCase,
    this.changeOrderDetailStatusToConfirmedUseCase,
    this.changeOrderDetailStatusToPackedUseCase,
    this.getSellerStoriesUseCase,
    this.createSellerStoryUseCase,
    this.deleteSellerStoryUseCase,
    this.uploadFileMediaServerUseCase,
    this.downloadexceltemplateUsecase,
    this.getGalleryImagesUseCase,
    this.deleteGalleryImagesUseCase,
    this.getShopInfoUseCase,
    this.updateShopInfoUseCase,
    this.getShopLocationsUseCase,
    this.createShopLocationUseCase,
    this.updateShopLocationUseCase,
    this.changeShopLocationStatusUseCase,
  ) : super(DashBoardState()) {
    on<GetOrdersEvent>(_onGetOrdersEvent);
    on<NewGetOrdersEvent>(_onNewGetOrdersEvent);
    on<GetProductsEvent>(_onGetProductsEvent);
    on<GetBoutiquesEvent>(_onGetBoutiquesEvent);
    on<ChangeOrderStatusEvent>(_onChangeOrderStatusEvent);
    on<GetUserPermissionEvent>(_onGetUserPermissionEvent);
    on<ChangeOrderDetailStatusEvent>(_onChangeOrderDetailStatus);
    on<GetUserRolesEvent>(_onGetUserRolesEvent);
    on<GetUsersEvent>(_onGetUsersEvent);
    on<AddUserEvent>(_onAddUserEvent);
    on<DeleteUserEvent>(_onDeleteUserEvent);
    on<ChangeUserRoleEvent>(_onChangeUserRoleEvent);
    on<LeaveShopEvent>(_onLeaveShopEvent);
    on<UploadDocumentEvent>(_onUploadDocumentEvent);
    on<SubmitVendorRequestEvent>(_onSubmitVendorRequestEvent);
    on<GetVendorRequestEvent>(_onGetVendorRequestEvent);
    on<UpdateVendorRequestEvent>(_onUpdateVendorRequestEvent);
    on<ResetVendorRequestStatesEvent>(_onResetVendorRequestStatesEvent);
    on<GetExcelCategoriesEvent>(_onGetExcelCategoriesEvent);
    on<GetSellerStoriesEvent>(_onGetSellerStoriesEvent);
    on<CreateSellerStoryEvent>(_onCreateSellerStoryEvent);
    on<DeleteSellerStoryEvent>(_onDeleteSellerStoryEvent);
    on<ResetCreateStoryStateEvent>(_onResetCreateStoryStateEvent);
    on<DownloadExcelTemplateEvent>(_onDownloadExcelTemplateEvent);
    on<GetUploadedExcelFilesEvent>(_onGetUploadedExcelFilesEvent);
    on<GetGalleryImagesEvent>(_onGetGalleryImagesEvent);
    on<DeleteGalleryImagesEvent>(_onDeleteGalleryImagesEvent);
    on<GetShopInfoEvent>(_onGetShopInfoEvent);
    on<ClearShopInfoEvent>(_onClearShopInfoEvent);
    on<UploadShopMediaEvent>(_onUploadShopMediaEvent);
    on<UpdateShopInfoEvent>(_onUpdateShopInfoEvent);

    // Locations. `bloc_concurrency` is already a dependency; `droppable` and
    // `restartable` come straight from it, so no local helper is copied here
    // and no throttle duration is introduced.
    //
    // | event         | transformer   | why                                    |
    // |---------------|---------------|----------------------------------------|
    // | load          | restartable() | only the newest load matters           |
    // | create        | droppable()   | backs AC-10 at the bloc level          |
    // | update        | droppable()   | same double-tap guard as create        |
    // | change status | droppable()   | one status change at a time, which is  |
    // |               |               | all the shared write enum can express  |
    // | clear         | none          | it issues no request and awaits        |
    // |               |               | nothing; a transformer here could      |
    // |               |               | reorder a clear against the load whose |
    // |               |               | result it is meant to invalidate       |
    on<GetShopLocationsEvent>(
      _onGetShopLocationsEvent,
      transformer: restartable(),
    );
    on<ClearShopLocationsEvent>(_onClearShopLocationsEvent);
    on<CreateShopLocationEvent>(
      _onCreateShopLocationEvent,
      transformer: droppable(),
    );
    on<UpdateShopLocationEvent>(
      _onUpdateShopLocationEvent,
      transformer: droppable(),
    );
    on<ChangeShopLocationStatusEvent>(
      _onChangeShopLocationStatusEvent,
      transformer: droppable(),
    );
  }

  String? ordersStatus;

  FutureOr<void> _onGetUserPermissionEvent(
    GetUserPermissionEvent event,
    Emitter<DashBoardState> emit,
  ) async {
    if ((GetIt.I<PrefsRepository>().myPhoneNumber?.length ?? 0) < 3) {
      emit(
        state.copyWith(
          getUserPermissionStatus: GetUserPermissionStatus.failure,
        ),
      );
      return;
    }
    emit(
      state.copyWith(getUserPermissionStatus: GetUserPermissionStatus.loading),
    );

    final response = await getUserPermissionUseCase(NoParams());
    response.fold(
      (l) {
        emit(
          (state.copyWith(
            getUserPermissionStatus: GetUserPermissionStatus.failure,
          )),
        );
      },
      (r) {
        emit(
          (state.copyWith(
            shops: r.shops ?? [],

            getUserPermissionStatus: GetUserPermissionStatus.success,
          )),
        );
      },
    );
  }

  FutureOr<void> _onGetUserRolesEvent(
    GetUserRolesEvent event,
    Emitter<DashBoardState> emit,
  ) async {
    emit(state.copyWith(getUserRolesStatus: GetUserRolesStatus.loading));

    final response = await getUserRolesUseCase(
      GetUserRolesParams(search: event.search, page: event.page),
    );
    response.fold(
      (l) {
        emit((state.copyWith(getUserRolesStatus: GetUserRolesStatus.failure)));
      },
      (r) {
        final List<ShopRole> updatedRoles;
        if (event.page == 1) {
          // صفحة جديدة - استبدل القائمة
          updatedRoles = r.data?.shopRoles ?? [];
        } else {
          // إضافة للصفحات السابقة
          updatedRoles = [
            ...(state.shopRoles ?? []),
            ...(r.data?.shopRoles ?? []),
          ];
        }

        emit(
          (state.copyWith(
            shopRoles: updatedRoles,
            rolesMeta: r.data!.meta,
            getUserRolesStatus: GetUserRolesStatus.success,
          )),
        );
      },
    );
  }

  FutureOr<void> _onAddUserEvent(
    AddUserEvent event,
    Emitter<DashBoardState> emit,
  ) async {
    emit(state.copyWith(addUserStatus: AddUserStatus.loading));

    final response = await addUserUseCase(
      AddUserParam(
        phone: event.phone,
        role_id: event.role_id,
        seller_id: event.seller_id,
      ),
    );
    response.fold(
      (l) {
        emit((state.copyWith(addUserStatus: AddUserStatus.failure)));
        showMessage(l.message, hasError: true);
      },
      (r) {
        emit((state.copyWith(addUserStatus: AddUserStatus.success)));
        showMessage(r.message ?? "");
        // Refresh users list after adding a user
        add(GetUsersEvent());
      },
    );
  }

  FutureOr<void> _onDeleteUserEvent(
    DeleteUserEvent event,
    Emitter<DashBoardState> emit,
  ) async {
    emit(state.copyWith(deleteUserStatus: DeleteUserStatus.loading));

    final response = await deleteUserUseCase(
      DeleteUserParams(userId: event.userId),
    );
    response.fold(
      (l) {
        emit((state.copyWith(deleteUserStatus: DeleteUserStatus.failure)));
        showMessage(l.message, hasError: true);
      },
      (r) {
        emit((state.copyWith(deleteUserStatus: DeleteUserStatus.success)));
        showMessage(r.message ?? "");
        // Refresh users list after deleting a user
        add(GetUsersEvent(page: state.usersMeta?.currentPage ?? 1));
      },
    );
  }

  FutureOr<void> _onChangeUserRoleEvent(
    ChangeUserRoleEvent event,
    Emitter<DashBoardState> emit,
  ) async {
    emit(state.copyWith(changeUserRoleStatus: ChangeUserRoleStatus.loading));

    final response = await updateUserRoleUseCase(
      UpdateUserRoleParams(userId: event.userId, roleId: event.roleId),
    );
    response.fold(
      (l) {
        emit(
          (state.copyWith(changeUserRoleStatus: ChangeUserRoleStatus.failure)),
        );
        showMessage(l.message, hasError: true);
      },
      (r) {
        emit(
          (state.copyWith(changeUserRoleStatus: ChangeUserRoleStatus.success)),
        );
        showMessage(r.message ?? "");
        // Refresh users list after changing user role
        add(GetUsersEvent(page: state.usersMeta?.currentPage ?? 1));
      },
    );
  }

  FutureOr<void> _onLeaveShopEvent(
    LeaveShopEvent event,
    Emitter<DashBoardState> emit,
  ) async {
    emit(state.copyWith(leaveShopStatus: LeaveShopStatus.loading));

    final response = await leaveShopUseCase(NoParams());
    response.fold(
      (l) {
        emit((state.copyWith(leaveShopStatus: LeaveShopStatus.failure)));
        showMessage(l.message, hasError: true);
      },
      (r) {
        emit((state.copyWith(leaveShopStatus: LeaveShopStatus.success)));
        showMessage(r.message ?? "");
        // Refresh shops list after leaving shop
        add(GetUserPermissionEvent());
      },
    );
  }

  FutureOr<void> _onGetUsersEvent(
    GetUsersEvent event,
    Emitter<DashBoardState> emit,
  ) async {
    emit(state.copyWith(getUsersStatus: GetUsersStatus.loading));

    final response = await getUsersUseCase(GetUsersParams(page: event.page));
    response.fold(
      (l) {
        emit((state.copyWith(getUsersStatus: GetUsersStatus.failure)));
      },
      (r) {
        emit(
          (state.copyWith(
            users: r.data?.users,
            usersMeta: r.data?.meta,
            getUsersStatus: GetUsersStatus.success,
          )),
        );
      },
    );
  }

  FutureOr<void> _onGetOrdersEvent(
    GetOrdersEvent event,
    Emitter<DashBoardState> emit,
  ) async {
    emit(state.copyWith(getOrdersStatus: GetOrdersStatus.loading));

    final response = await getOrdersUseCase(GetOrdersParams(page: event.page));
    response.fold(
      (l) {
        emit((state.copyWith(getOrdersStatus: GetOrdersStatus.failure)));
      },
      (r) {
        emit(
          (state.copyWith(
            orders: r.data?.orders,
            ordersMeta: r.data?.meta,
            ordersUserAbilities: r.data?.userAbilities,
            getOrdersStatus: GetOrdersStatus.success,
          )),
        );
      },
    );
  }

  FutureOr<void> _onNewGetOrdersEvent(
    NewGetOrdersEvent event,
    Emitter<DashBoardState> emit,
  ) async {
    emit(state.copyWith(newGetOrdersStatus: NewGetOrdersStatus.loading));

    final response = await newGetOrdersUseCase(
      NewGetOrdersParams(page: event.page, status: ordersStatus),
    );
    response.fold(
      (l) {
        emit((state.copyWith(newGetOrdersStatus: NewGetOrdersStatus.failure)));
      },
      (r) {
        emit(
          (state.copyWith(
            new_orders: r.data.orders,
            newOrdersMeta: r.data.meta,
            newOrdersUserAbilities: r.data.userAbilities,
            newGetOrdersStatus: NewGetOrdersStatus.success,
          )),
        );
      },
    );
  }

  FutureOr<void> _onChangeOrderDetailStatus(
    ChangeOrderDetailStatusEvent event,
    Emitter<DashBoardState> emit,
  ) async {
    emit(
      state.copyWith(
        changeOrderDetailStatusStatus: ChangeOrderDetailStatusStatus.loading,
      ),
    );

    final normalizedStatus = event.status.toLowerCase();
    final response = normalizedStatus == 'packed'
        ? await changeOrderDetailStatusToPackedUseCase(
            ChangeOrderDetailStatusToPackedParams(
              orderDetailId: event.order_detail_id,
            ),
          )
        : await changeOrderDetailStatusToConfirmedUseCase(
            ChangeOrderDetailStatusParams(orderDetailId: event.order_detail_id),
          );

    response.fold(
      (l) {
        emit(
          state.copyWith(
            changeOrderDetailStatusStatus:
                ChangeOrderDetailStatusStatus.failure,
          ),
        );
        showMessage(l.message, hasError: true);
      },
      (r) {
        final updatedOrders = r.hasContent
            ? r.data.orders
            : _applyOrderDetailStatusToExistingOrders(
                state.new_orders,
                event.order_detail_id,
                normalizedStatus,
              );

        emit(
          state.copyWith(
            new_orders: updatedOrders,
            newOrdersMeta: r.hasContent ? r.data.meta : state.newOrdersMeta,
            newOrdersUserAbilities: r.hasContent
                ? r.data.userAbilities
                : state.newOrdersUserAbilities,
            changeOrderDetailStatusStatus:
                ChangeOrderDetailStatusStatus.success,
          ),
        );
        showMessage(r.message);
      },
    );
  }

  List<UserOrderNew>? _applyOrderDetailStatusToExistingOrders(
    List<UserOrderNew>? orders,
    int orderDetailId,
    String status,
  ) {
    if (orders == null) {
      return null;
    }

    return orders.map((order) {
      final updatedDetails = order.details.map((detail) {
        if (detail.id != orderDetailId) {
          return detail;
        }

        return OrderDetail(
          id: detail.id,
          orderId: detail.orderId,
          cartImage: detail.cartImage,
          brandIcon: detail.brandIcon,
          qty: detail.qty,
          unitPrice: detail.unitPrice,
          isConfirm: status == 'confirmed' ? true : detail.isConfirm,
          isPacked: status == 'packed' ? true : detail.isPacked,
          productName: detail.productName,
          color: detail.color,
          size: detail.size,
        );
      }).toList();

      final updatedOrderStatus = _deriveOrderStatusFromDetails(
        order.orderStatus,
        updatedDetails,
      );

      return UserOrderNew(
        id: order.id,
        orderStatus: updatedOrderStatus,
        details: updatedDetails,
        orderAmount: order.orderAmount,
        createdAt: order.createdAt,
        items: order.items,
        remainingInMinutes: order.remainingInMinutes,
        availableOrderStatusChange: order.availableOrderStatusChange,
      );
    }).toList();
  }

  String _deriveOrderStatusFromDetails(
    String currentStatus,
    List<OrderDetail> details,
  ) {
    if (details.isEmpty) {
      return currentStatus;
    }

    final hasPendingConfirmation = details.any(
      (detail) => !detail.isConfirm && !detail.isPacked,
    );

    if (hasPendingConfirmation) {
      return 'pending';
    }

    return 'packaged';
  }

  FutureOr<void> _onGetProductsEvent(
    GetProductsEvent event,
    Emitter<DashBoardState> emit,
  ) async {
    emit(state.copyWith(getProductsStatus: GetProductsStatus.loading));

    final response = await getProductsUseCase(
      GetProductsParams(page: event.page),
    );
    response.fold(
      (l) {
        emit((state.copyWith(getProductsStatus: GetProductsStatus.failure)));
      },
      (r) {
        emit(
          (state.copyWith(
            products: r.data?.products,
            productsMeta: r.data?.meta,
            getProductsStatus: GetProductsStatus.success,
          )),
        );
      },
    );
  }

  FutureOr<void> _onGetBoutiquesEvent(
    GetBoutiquesEvent event,
    Emitter<DashBoardState> emit,
  ) async {
    emit(state.copyWith(getBoutiquesStatus: GetBoutiquesStatus.loading));

    final response = await getBoutiquesUseCase(
      GetBoutiquesParams(page: event.page),
    );
    response.fold(
      (l) {
        emit((state.copyWith(getBoutiquesStatus: GetBoutiquesStatus.failure)));
      },
      (r) {
        emit(
          (state.copyWith(
            boutiques: r.data?.boutiques,
            boutiquesMeta: r.data?.meta,
            getBoutiquesStatus: GetBoutiquesStatus.success,
          )),
        );
      },
    );
  }

  FutureOr<void> _onChangeOrderStatusEvent(
    ChangeOrderStatusEvent event,
    Emitter<DashBoardState> emit,
  ) async {
    emit(
      state.copyWith(changeOrderStatusStatus: ChangeOrderStatusStatus.loading),
    );

    final response = await changeOrderStatusUseCase(
      ChangeOrderParams(order_id: event.order_id, status: event.status),
    );
    response.fold(
      (l) {
        emit(
          (state.copyWith(
            changeOrderStatusStatus: ChangeOrderStatusStatus.failure,
          )),
        );
        showMessage(l.message, hasError: true);
      },
      (r) {
        emit(
          (state.copyWith(
            changeOrderStatusStatus: ChangeOrderStatusStatus.success,
          )),
        );
        showMessage(r.message ?? "");
        // Refresh orders list after changing status
        add(GetOrdersEvent(page: state.ordersMeta?.currentPage ?? 1));
      },
    );
  }

  FutureOr<void> _onUploadDocumentEvent(
    UploadDocumentEvent event,
    Emitter<DashBoardState> emit,
  ) async {
    emit(state.copyWith(uploadDocumentStatus: UploadDocumentStatus.loading));

    final file = File(event.filePath);

    // Step 1: Get presigned URL
    final presignedUrlResponse = await getPresignedUrlUseCase(
      GetPresignedUrlParams(mimeType: event.mimeType),
    );

    // Handle presigned URL response
    if (presignedUrlResponse.isLeft()) {
      final failure = presignedUrlResponse.fold(
        (l) => l,
        (r) => throw Exception(),
      );
      if (!emit.isDone) {
        emit(
          state.copyWith(uploadDocumentStatus: UploadDocumentStatus.failure),
        );
      }
      showMessage(failure.message, hasError: true);
      return;
    }

    final presignedUrlModel = presignedUrlResponse.fold(
      (l) => throw Exception(),
      (r) => r,
    );

    // Step 2: Upload file to presigned URL using PUT
    final uploadResponse = await uploadFileToS3UseCase(
      UploadFileToS3Params(
        file: file,
        uploadUrl: presignedUrlModel.uploadUrl!,
        mimeType: event.mimeType,
      ),
    );

    // Handle upload response
    if (uploadResponse.isLeft()) {
      final failure = uploadResponse.fold((l) => l, (r) => throw Exception());
      if (!emit.isDone) {
        emit(
          state.copyWith(uploadDocumentStatus: UploadDocumentStatus.failure),
        );
      }
      showMessage(failure.message, hasError: true);
      return;
    }

    final success = uploadResponse.fold((l) => throw Exception(), (r) => r);
    if (!emit.isDone) {
      emit(
        state.copyWith(
          uploadDocumentStatus: UploadDocumentStatus.success,
          uploadedDocumentKey: presignedUrlModel.key ?? '',
        ),
      );
    }
    // Translate the message if it's a translation key, otherwise use default
    final message = success.message == 'file_uploaded_successfully'
        ? LocaleKeys.file_uploaded_successfully.tr()
        : (success.message ?? LocaleKeys.document_uploaded_successfully.tr());
    showMessage(message);
  }

  FutureOr<void> _onSubmitVendorRequestEvent(
    SubmitVendorRequestEvent event,
    Emitter<DashBoardState> emit,
  ) async {
    emit(
      state.copyWith(
        submitVendorRequestStatus: SubmitVendorRequestStatus.loading,
      ),
    );

    final response = await submitVendorRequestUseCase(event.params);

    response.fold(
      (l) {
        emit(
          state.copyWith(
            submitVendorRequestStatus: SubmitVendorRequestStatus.failure,
          ),
        );
      },
      (r) {
        emit(
          state.copyWith(
            submitVendorRequestStatus: SubmitVendorRequestStatus.success,
          ),
        );
        showMessage(r.message ?? LocaleKeys.registration_successful.tr());
      },
    );
  }

  FutureOr<void> _onGetVendorRequestEvent(
    GetVendorRequestEvent event,
    Emitter<DashBoardState> emit,
  ) async {
    emit(
      state.copyWith(getVendorRequestStatus: GetVendorRequestStatus.loading),
    );

    final response = await getVendorRequestUseCase(NoParams());

    response.fold(
      (l) {
        emit(
          state.copyWith(
            getVendorRequestStatus: GetVendorRequestStatus.failure,
          ),
        );
      },
      (r) {
        emit(
          state.copyWith(
            getVendorRequestStatus: GetVendorRequestStatus.success,
            vendorRequest: r.data,
          ),
        );
      },
    );
  }

  FutureOr<void> _onUpdateVendorRequestEvent(
    UpdateVendorRequestEvent event,
    Emitter<DashBoardState> emit,
  ) async {
    emit(
      state.copyWith(
        updateVendorRequestStatus: UpdateVendorRequestStatus.loading,
      ),
    );

    final response = await updateVendorRequestUseCase(event.params);

    response.fold(
      (l) {
        emit(
          state.copyWith(
            updateVendorRequestStatus: UpdateVendorRequestStatus.failure,
          ),
        );
      },
      (r) {
        emit(
          state.copyWith(
            updateVendorRequestStatus: UpdateVendorRequestStatus.success,
          ),
        );
        showMessage(r.message ?? LocaleKeys.registration_successful.tr());
      },
    );
  }

  // -------------------------------------------------------------------------
  // Seller stories
  //
  // The stories API needs two different ids: `user_id` is the logged-in user
  // (stories server id) and `seller_id` is the shop currently open in the
  // dashboard (`X-Seller-ID` value, set by DashboardPage).
  // -------------------------------------------------------------------------

  /// Max accepted video length, enforced by the backend as well.
  static const int _maxStoryVideoSeconds = 60;

  int? get _storiesUserId =>
      int.tryParse(GetIt.I<PrefsRepository>().myMarketId!);

  int? get _storiesSellerId =>
      int.tryParse(GetIt.I<PrefsRepository>().getXSellerId ?? '');

  FutureOr<void> _onGetSellerStoriesEvent(
    GetSellerStoriesEvent event,
    Emitter<DashBoardState> emit,
  ) async {
    final userId = _storiesUserId;
    final sellerId = _storiesSellerId;

    if (userId == null || sellerId == null) {
      emit(state.copyWith(storiesStatus: GetSellerStoriesStatus.failure));
      return;
    }

    emit(state.copyWith(storiesStatus: GetSellerStoriesStatus.loading));

    final response = await getSellerStoriesUseCase(
      GetSellerStoriesParams(
        userId: userId,
        sellerId: sellerId,
        page: event.page,
        perPage: event.perPage,
      ),
    );
    response.fold(
      (l) {
        emit((state.copyWith(storiesStatus: GetSellerStoriesStatus.failure)));
      },
      (r) {
        emit(
          (state.copyWith(
            stories: r,
            storiesStatus: GetSellerStoriesStatus.success,
          )),
        );
      },
    );
  }

  FutureOr<void> _onCreateSellerStoryEvent(
    CreateSellerStoryEvent event,
    Emitter<DashBoardState> emit,
  ) async {
    final userId = _storiesUserId;
    final sellerId = _storiesSellerId;

    if (userId == null || sellerId == null) {
      emit(state.copyWith(createStoryStatus: CreateSellerStoryStatus.failure));
      showMessage(LocaleKeys.failed_to_add_story.tr(), hasError: true);
      return;
    }

    // Step 1: upload the media to the media server (folder `stories`, and
    // `?story=true` for videos so the server produces the story variants).
    emit(state.copyWith(createStoryStatus: CreateSellerStoryStatus.uploading));

    final uploadResponse = await uploadFileMediaServerUseCase(
      UploadFileMediaServerParams(
        file: event.file,
        folder: 'stories',
        isStory: event.isVideo,
        usingOnUploadingFinishedFunction: false,
        usingSendProgressFunction: false,
      ),
    );

    final uploaded = uploadResponse.fold((l) => null, (r) => r);

    if (uploaded?.url == null || uploaded!.url!.isEmpty) {
      emit(state.copyWith(createStoryStatus: CreateSellerStoryStatus.failure));
      showMessage(LocaleKeys.failed_to_add_story.tr(), hasError: true);
      return;
    }

    final int durationInSeconds = (uploaded.durationSeconds ?? 0).round();

    if (event.isVideo && durationInSeconds > _maxStoryVideoSeconds) {
      emit(state.copyWith(createStoryStatus: CreateSellerStoryStatus.failure));
      showMessage(LocaleKeys.video_up_to_60_seconds.tr(), hasError: true);
      return;
    }

    // Step 2: post the story with the full media url.
    emit(state.copyWith(createStoryStatus: CreateSellerStoryStatus.loading));

    final response = await createSellerStoryUseCase(
      CreateSellerStoryParams(
        userId: userId,
        sellerId: sellerId,
        filePath: '${dotenv.env['MEDIA_SERVER_URL']}${uploaded.url}',
        isVideo: event.isVideo,
        link: event.link,
        productId: event.productId,
        productSlug: event.productSlug,
        videoDurationInSecond: event.isVideo ? durationInSeconds : 0,
      ),
    );
    response.fold(
      (l) {
        emit(
          (state.copyWith(createStoryStatus: CreateSellerStoryStatus.failure)),
        );
        showMessage(l.message, hasError: true);
      },
      (r) {
        emit(
          (state.copyWith(createStoryStatus: CreateSellerStoryStatus.success)),
        );
        showMessage(LocaleKeys.succesfully_added_story.tr());
        // Refresh stories list after adding a story
        add(GetSellerStoriesEvent());
      },
    );
  }

  FutureOr<void> _onDeleteSellerStoryEvent(
    DeleteSellerStoryEvent event,
    Emitter<DashBoardState> emit,
  ) async {
    final userId = _storiesUserId;
    final sellerId = _storiesSellerId;

    if (userId == null || sellerId == null) {
      emit(state.copyWith(deleteStoryStatus: DeleteSellerStoryStatus.failure));
      return;
    }

    emit(state.copyWith(deleteStoryStatus: DeleteSellerStoryStatus.loading));

    final response = await deleteSellerStoryUseCase(
      DeleteSellerStoryParams(
        userId: userId,
        sellerId: sellerId,
        storyId: event.storyId,
      ),
    );
    response.fold(
      (l) {
        emit(
          (state.copyWith(deleteStoryStatus: DeleteSellerStoryStatus.failure)),
        );
        showMessage(l.message, hasError: true);
      },
      (r) {
        // Drop the deleted story locally so the grid updates immediately.
        final stories = (state.stories ?? const <SellerStoryModel>[])
            .where((story) => story.id != event.storyId)
            .toList();

        emit(
          (state.copyWith(
            stories: stories,
            deleteStoryStatus: DeleteSellerStoryStatus.success,
          )),
        );
        showMessage(LocaleKeys.story_deleted_successfully.tr());
      },
    );
  }

  FutureOr<void> _onResetCreateStoryStateEvent(
    ResetCreateStoryStateEvent event,
    Emitter<DashBoardState> emit,
  ) {
    emit(
      state.copyWith(
        createStoryStatus: CreateSellerStoryStatus.init,
        deleteStoryStatus: DeleteSellerStoryStatus.init,
        uploadDocumentStatus: UploadDocumentStatus.init,
      ),
    );
  }

  FutureOr<void> _onResetVendorRequestStatesEvent(
    ResetVendorRequestStatesEvent event,
    Emitter<DashBoardState> emit,
  ) {
    emit(
      state.copyWith(
        getVendorRequestStatus: GetVendorRequestStatus.init,
        updateVendorRequestStatus: UpdateVendorRequestStatus.init,
        submitVendorRequestStatus: SubmitVendorRequestStatus.init,
      ),
    );
  }

  FutureOr<void> _onGetExcelCategoriesEvent(
    GetExcelCategoriesEvent event,
    Emitter<DashBoardState> emit,
  ) async {
    emit(
      state.copyWith(
        getExcelCategoriesStatus: GetExcelCategoriesStatus.loading,
      ),
    );

    final response = await getexcelcategoriesUsecase(NoParams());
    response.fold(
      (l) {
        emit(
          (state.copyWith(
            getExcelCategoriesStatus: GetExcelCategoriesStatus.failure,
          )),
        );
        showMessage(l.message, hasError: true);
      },
      (r) {
        emit(
          state.copyWith(
            excelCategoriesModel: r,
            getExcelCategoriesStatus: GetExcelCategoriesStatus.success,
          ),
        );
      },
    );
  }

  FutureOr<void> _onDownloadExcelTemplateEvent(
    DownloadExcelTemplateEvent event,
    Emitter<DashBoardState> emit,
  ) async {
    emit(
      state.copyWith(
        downloadExcelTemplateStatus: DownloadExcelTemplateStatus.loading,
      ),
    );

    final response = await downloadexceltemplateUsecase(
      DownloadexceltemplateParams(categoryId: event.categoryId),
    );
    response.fold(
      (l) {
        emit(
          state.copyWith(
            downloadExcelTemplateStatus: DownloadExcelTemplateStatus.failure,
          ),
        );
        showMessage(l.message, hasError: true);
      },
      (r) {
        emit(
          state.copyWith(
            downloadExcelTemplateStatus: DownloadExcelTemplateStatus.success,
            downloadedTemplatePath: r, // r هو مسار الملف
          ),
        );
        showMessage('تم تحميل القالب بنجاح');
      },
    );
  }

  FutureOr<void> _onGetUploadedExcelFilesEvent(
    GetUploadedExcelFilesEvent event,
    Emitter<DashBoardState> emit,
  ) async {
    emit(
      state.copyWith(
        getUploadedExcelFilesStatus: GetUploadedExcelFilesStatus.loading,
      ),
    );

    final response = await getUploadedExcelFilesUsecase(
      GetUploadedExcelFilesParams(page: event.page),
    );

    response.fold(
      (l) {
        emit(
          state.copyWith(
            getUploadedExcelFilesStatus: GetUploadedExcelFilesStatus.failure,
          ),
        );
        showMessage(l.message, hasError: true);
      },
      (r) {
        emit(
          state.copyWith(
            getUploadedExcelFilesStatus: GetUploadedExcelFilesStatus.success,
            uploadedExcelFilesModel: r,
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // Shop Info — ملف المتجر العام (GET/PUT /shop/info)
  // -------------------------------------------------------------------------

  /// اسم الملف المجرّد كما تريده الخلفية: ما بعد آخر `/` فقط.
  ///
  /// المجلّد لا يُرسل — الخلفية تستنتجه. صحيح ما دامت وسائط المتجر في
  /// مجلّد `seller` وحده؛ قيمة عائدة من مجلّد آخر تفقد مجلّدها هنا
  /// (حدّ معروف ومقبول، AC-16).
  String? _bareFileName(String? value) {
    if (value == null) return null;
    final String trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final int slash = trimmed.lastIndexOf('/');
    final String name = slash == -1 ? trimmed : trimmed.substring(slash + 1);
    return name.isEmpty ? null : name;
  }

  String? get _currentSellerId => GetIt.I<PrefsRepository>().getXSellerId;

  /// سجلّ تشخيصي: النقطة والحالة ومعرّف المتجر فقط.
  /// لا رمز دخول ولا تذكرة ولا أي قيمة من جسم الطلب (AC-27).
  void _logShopInfo(String action, String outcome, {String? message}) {
    if (kDebugMode) {
      print(
        'shop-info | $action | $outcome | seller=$_currentSellerId'
        '${message == null ? '' : ' | message=$message'}',
      );
    }
  }

  FutureOr<void> _onGetShopInfoEvent(
    GetShopInfoEvent event,
    Emitter<DashBoardState> emit,
  ) async {
    // لا صلاحية قراءة: لا يُرسل الطلب أصلاً — لا دوّارة ولا زرّ إعادة
    // محاولة، لأن الإعادة لا يمكن أن تنجح.
    if (!event.canRead) {
      _logShopInfo('load', 'skipped-no-permission');
      emit(
        state.copyWith(
          getShopInfoStatus: GetShopInfoStatus.permissionDenied,
          shopInfo: const GetShopInfoModel.empty(),
        ),
      );
      return;
    }

    emit(state.copyWith(getShopInfoStatus: GetShopInfoStatus.loading));

    final String? sellerIdAtRequest = _currentSellerId;
    final response = await getShopInfoUseCase(NoParams());

    response.fold(
      (l) {
        _logShopInfo('load', 'failure', message: l.message);
        emit(
          state.copyWith(
            getShopInfoStatus: GetShopInfoStatus.failure,
            shopInfoMessage: l.message,
          ),
        );
      },
      (r) {
        // غلاف يحمل `success: false` فشلٌ ولو كان رمز HTTP ناجحاً.
        if (r.success == false) {
          _logShopInfo('load', 'failure-envelope', message: r.message);
          emit(
            state.copyWith(
              getShopInfoStatus: GetShopInfoStatus.failure,
              shopInfoMessage: r.message,
            ),
          );
          return;
        }
        _logShopInfo('load', 'success');
        emit(
          state.copyWith(
            getShopInfoStatus: GetShopInfoStatus.success,
            // المتجر الذي حُمّل من أجله السجلّ يُكتب هنا: لا ترسله الخلفية.
            shopInfo: r.copyWith(loadedForSellerId: sellerIdAtRequest),
          ),
        );
      },
    );
  }

  /// المسح عند تبديل المتجر: الحالة إلى `init` والسجلّ إلى الفارغ.
  /// `copyWith` لا يستطيع إعادة حقل إلى `null`، ولا تُبنى حالة جديدة لأن
  /// ذلك يمسح ما خزّنته بقية التبويبات.
  FutureOr<void> _onClearShopInfoEvent(
    ClearShopInfoEvent event,
    Emitter<DashBoardState> emit,
  ) async {
    emit(
      state.copyWith(
        getShopInfoStatus: GetShopInfoStatus.init,
        updateShopInfoStatus: UpdateShopInfoStatus.init,
        uploadShopMediaStatus: UploadShopMediaStatus.init,
        shopInfo: const GetShopInfoModel.empty(),
      ),
    );
  }

  FutureOr<void> _onUploadShopMediaEvent(
    UploadShopMediaEvent event,
    Emitter<DashBoardState> emit,
  ) async {
    emit(
      state.copyWith(uploadShopMediaStatus: UploadShopMediaStatus.uploading),
    );

    // تذكرة جديدة لكل رفع، ومجلّد `seller` — نفس المسار المشترك مع الستوري.
    final uploadResponse = await uploadFileMediaServerUseCase(
      UploadFileMediaServerParams(
        file: event.file,
        folder: 'seller',
        isStory: false,
        usingOnUploadingFinishedFunction: false,
        usingSendProgressFunction: false,
      ),
    );

    uploadResponse.fold(
      (l) {
        _logShopInfo('upload', 'failure', message: l.message);
        showMessage(l.message, hasError: true);
        // الصورة المعروضة سابقاً تبقى، والقيمة التي ستُحفظ لا تتغيّر.
        emit(
          state.copyWith(uploadShopMediaStatus: UploadShopMediaStatus.failure),
        );
      },
      (r) {
        final String? stored = _bareFileName(r.subPath ?? r.url);
        if (stored == null) {
          _logShopInfo('upload', 'failure-empty-path');
          emit(
            state.copyWith(
              uploadShopMediaStatus: UploadShopMediaStatus.failure,
            ),
          );
          return;
        }
        _logShopInfo('upload', 'success');
        emit(
          state.copyWith(
            uploadShopMediaStatus: UploadShopMediaStatus.success,
            shopInfo: event.isBanner
                ? state.shopInfo.copyWith(banner: stored)
                : state.shopInfo.copyWith(image: stored),
          ),
        );
      },
    );
  }

  FutureOr<void> _onUpdateShopInfoEvent(
    UpdateShopInfoEvent event,
    Emitter<DashBoardState> emit,
  ) async {
    // آخر فحص متزامن قبل الاستدعاء: هل ما زال المتجر المحدّد هو الذي
    // حُمّل السجلّ من أجله؟ الترويسة `X-Seller-ID` تُقرأ لاحقاً عند بناء
    // الطلب، فهذا يضيّق النافذة ولا يغلقها (AC-29، حدّ معروف ومقبول).
    final String? current = _currentSellerId;
    if (event.expectedSellerId != null && event.expectedSellerId != current) {
      _logShopInfo('save', 'abandoned-shop-changed');
      emit(
        state.copyWith(
          updateShopInfoStatus: UpdateShopInfoStatus.init,
          getShopInfoStatus: GetShopInfoStatus.init,
          shopInfo: const GetShopInfoModel.empty(),
        ),
      );
      showMessage(
        LocaleKeys.shop_info_shop_changed.tr(),
        hasError: true,
      );
      return;
    }

    emit(state.copyWith(updateShopInfoStatus: UpdateShopInfoStatus.loading));

    final response = await updateShopInfoUseCase(
      UpdateShopInfoParams(
        name: event.name,
        address: event.address,
        contact: event.contact,
        image: event.image,
        banner: event.banner,
      ),
    );

    response.fold(
      (l) {
        _logShopInfo('save', 'failure', message: l.message);
        showMessage(l.message, hasError: true);
        emit(
          state.copyWith(
            updateShopInfoStatus: UpdateShopInfoStatus.failure,
            shopInfoMessage: l.message,
          ),
        );
      },
      (r) {
        if (!r.isSuccess) {
          // `HTTP 200` مع `success: false` فشل — تعديلات المستخدم تبقى.
          _logShopInfo('save', 'failure-envelope', message: r.message);
          showMessage(
            r.message ?? LocaleKeys.shop_info_save_failed.tr(),
            hasError: true,
          );
          emit(
            state.copyWith(
              updateShopInfoStatus: UpdateShopInfoStatus.failure,
              shopInfoMessage: r.message,
            ),
          );
          return;
        }
        _logShopInfo('save', 'success');
        // `showInRelease` لازم: `showMessage` يُسكِت رسائل النجاح في نسخة
        // الإصدار (kDebugMode || showInRelease || hasError).
        showMessage(
          r.message ?? LocaleKeys.shop_info_saved.tr(),
          showInRelease: true,
        );
        emit(
          state.copyWith(
            updateShopInfoStatus: UpdateShopInfoStatus.success,
            shopInfo: state.shopInfo.copyWith(
              name: event.name,
              address: event.address,
              contact: event.contact,
              image: event.image,
              banner: event.banner,
            ),
          ),
        );
      },
    );
  }

  FutureOr<void> _onGetGalleryImagesEvent(
    GetGalleryImagesEvent event,
    Emitter<DashBoardState> emit,
  ) async {
    emit(
      state.copyWith(getGalleryImagesStatus: GetGalleryImagesStatus.loading),
    );

    final response = await getGalleryImagesUseCase(
      GetGalleryImagesParams(
        page: event.page,
        perPage: event.perPage,
        search: event.search,
      ),
    );

    response.fold(
      (l) {
        emit(
          state.copyWith(
            getGalleryImagesStatus: GetGalleryImagesStatus.failure,
          ),
        );
        showMessage(l.message, hasError: true);
      },
      (r) {
        final List<GalleryImageModel> updatedImages = event.page == 1
            ? r.images
            : [...(state.galleryImages ?? <GalleryImageModel>[]), ...r.images];

        emit(
          state.copyWith(
            galleryImages: updatedImages,
            galleryMeta: r.meta,
            getGalleryImagesStatus: GetGalleryImagesStatus.success,
          ),
        );
      },
    );
  }

  FutureOr<void> _onDeleteGalleryImagesEvent(
    DeleteGalleryImagesEvent event,
    Emitter<DashBoardState> emit,
  ) async {
    emit(
      state.copyWith(
        deleteGalleryImagesStatus: DeleteGalleryImagesStatus.loading,
      ),
    );

    final response = await deleteGalleryImagesUseCase(
      DeleteGalleryImagesParams(ids: event.ids),
    );

    response.fold(
      (l) {
        emit(
          state.copyWith(
            deleteGalleryImagesStatus: DeleteGalleryImagesStatus.failure,
          ),
        );
        showMessage(l.message, hasError: true);
      },
      (r) {
        // احذف الصور محذوفة محلياً فوراً بدون انتظار إعادة الجلب
        final remainingImages = (state.galleryImages ?? [])
            .where((img) => !event.ids.contains(img.id))
            .toList();

        emit(
          state.copyWith(
            galleryImages: remainingImages,
            deleteGalleryImagesStatus: DeleteGalleryImagesStatus.success,
          ),
        );
        showMessage(r.message ?? '');
      },
    );
  }

  // ===========================================================================
  // Locations
  // ===========================================================================

  /// Counts the clears. A response that started before a clear ran belongs to a
  /// screen that is gone, or to a shop that is no longer open, and must not be
  /// written anywhere.
  ///
  /// A plain field on the bloc, **not** on `DashBoardState`: nothing renders
  /// from it, and every mutation of a state field emits to all eleven dashboard
  /// tabs plus `become_seller_page.dart` and `profile_page.dart`.
  int _locationsLoadGeneration = 0;

  /// Diagnostic trace: the action, the outcome and the shop id only.
  /// No request body, no headers, no token (AC-27).
  void _logLocations(String action, String outcome, {String? message}) {
    if (kDebugMode) {
      print(
        'locations | $action | $outcome | seller=$_currentSellerId'
        '${message == null ? '' : ' | message=$message'}',
      );
    }
  }

  /// The arrival guard, stated once and used by both handlers that write the
  /// list.
  ///
  /// A response is dropped when the shop changed while it was in flight, or
  /// when a clear ran after it started. Note what the caller must do on a drop:
  /// **nothing at all** — do not write the row, do not emit, and do not write a
  /// terminal write-status value either. The clear already reset that field, so
  /// writing it again would both re-dirty state the clear had just cleaned and
  /// emit into a bloc nothing will dispose, which is the exact harm this guard
  /// exists to prevent.
  bool _locationsResponseIsStale(String? sellerIdAtRequest, int generation) {
    return generation != _locationsLoadGeneration ||
        sellerIdAtRequest != _currentSellerId;
  }

  FutureOr<void> _onGetShopLocationsEvent(
    GetShopLocationsEvent event,
    Emitter<DashBoardState> emit,
  ) async {
    // No read permission: no request is sent, no loading state, and no retry
    // control — a retry could not succeed (AC-17, AC-18).
    if (!event.canRead) {
      _logLocations('load', 'skipped-no-permission');
      emit(
        state.copyWith(
          getLocationsStatus: GetLocationsStatus.permissionDenied,
          locations: const GetShopLocationsModel.empty(),
          locationWriteStatus: LocationWriteStatus.init,
        ),
      );
      return;
    }

    emit(state.copyWith(getLocationsStatus: GetLocationsStatus.loading));

    final String? sellerIdAtRequest = _currentSellerId;
    final int generationAtRequest = _locationsLoadGeneration;

    final response = await getShopLocationsUseCase(
      const GetShopLocationsParams(),
    );

    if (_locationsResponseIsStale(sellerIdAtRequest, generationAtRequest)) {
      _logLocations('load', 'dropped-stale');
      return;
    }

    response.fold(
      (l) {
        _logLocations('load', 'failure', message: l.message);
        emit(
          state.copyWith(
            getLocationsStatus: GetLocationsStatus.failure,
            locationsMessage: l.message,
          ),
        );
      },
      (r) {
        // An envelope carrying `success: false` is a failure even when the HTTP
        // status was a success.
        if (r.success == false) {
          _logLocations('load', 'failure-envelope', message: r.message);
          emit(
            state.copyWith(
              getLocationsStatus: GetLocationsStatus.failure,
              locationsMessage: r.message,
            ),
          );
          return;
        }
        _logLocations('load', 'success');
        emit(
          state.copyWith(
            getLocationsStatus: GetLocationsStatus.success,
            // The shop this list was loaded for. The backend does not send it.
            locations: r.copyWith(loadedForSellerId: sellerIdAtRequest),
          ),
        );
      },
    );
  }

  /// The one place everything this feature holds on the shared state is reset.
  ///
  /// Incrementing the generation first is what makes every response already in
  /// flight stale, so none of them can write after this point.
  FutureOr<void> _onClearShopLocationsEvent(
    ClearShopLocationsEvent event,
    Emitter<DashBoardState> emit,
  ) async {
    _locationsLoadGeneration++;
    _logLocations('clear', 'cleared');
    emit(
      state.copyWith(
        getLocationsStatus: GetLocationsStatus.init,
        // The empty wrapper drops the list, its `meta` (so the header count
        // cannot outlive it) and the shop stamp together.
        locations: const GetShopLocationsModel.empty(),
        locationWriteStatus: LocationWriteStatus.init,
      ),
    );
  }

  /// Shared by create and update: both refetch the list, and neither may do so
  /// when the screen it would render on is gone.
  ///
  /// The refetch cannot be left to guard itself. Its own load captures the
  /// generation **after** a clear has already incremented it, so it would pass
  /// its own arrival check and store a full list for a dead screen. The gate
  /// has to be here, against the generation captured when the *write* started.
  void _refreshLocationsAfterWrite({
    required String? sellerIdAtRequest,
    required int generationAtRequest,
    required bool canRead,
  }) {
    if (_locationsResponseIsStale(sellerIdAtRequest, generationAtRequest)) {
      _logLocations('refresh', 'skipped-stale');
      return;
    }
    if (!canRead) return;
    add(GetShopLocationsEvent(canRead: canRead));
  }

  /// Guards the path where a write would be sent with no shop selected. It
  /// still writes a terminal value, because a handler that returns leaving the
  /// enum at `inFlight` disables every row's status control for the lifetime of
  /// the app.
  bool _locationWriteCanProceed(
    String? sellerId,
    Emitter<DashBoardState> emit,
  ) {
    if (sellerId == null || sellerId.isEmpty) {
      _logLocations('write', 'skipped-no-shop');
      emit(state.copyWith(locationWriteStatus: LocationWriteStatus.failure));
      showMessage(LocaleKeys.locations_action_failed.tr(), hasError: true);
      return false;
    }
    return true;
  }

  FutureOr<void> _onCreateShopLocationEvent(
    CreateShopLocationEvent event,
    Emitter<DashBoardState> emit,
  ) async {
    final String? sellerIdAtRequest = _currentSellerId;
    final int generationAtRequest = _locationsLoadGeneration;
    if (!_locationWriteCanProceed(sellerIdAtRequest, emit)) return;

    emit(state.copyWith(locationWriteStatus: LocationWriteStatus.inFlight));

    final response = await createShopLocationUseCase(
      SaveShopLocationParams(
        name: event.name,
        countryId: event.countryId,
        address: event.address,
        latitude: event.latitude,
        longitude: event.longitude,
        sellerId: sellerIdAtRequest,
      ),
    );

    response.fold(
      (l) {
        _logLocations('create', 'failure', message: l.message);
        emit(
          state.copyWith(
            locationWriteStatus: LocationWriteStatus.failure,
            locationsMessage: l.message,
          ),
        );
        // This screen's own words. The backend's own text reaches the member
        // only for a 400 or a 422, through the shared error toast, outside the
        // form — and on a permission refusal there is no backend text at all.
        showMessage(LocaleKeys.locations_save_failed.tr(), hasError: true);
      },
      (r) {
        if (!r.isSuccess) {
          _logLocations('create', 'failure-envelope', message: r.message);
          emit(
            state.copyWith(
              locationWriteStatus: LocationWriteStatus.failure,
              locationsMessage: r.message,
            ),
          );
          return;
        }
        _logLocations('create', 'success');
        emit(state.copyWith(locationWriteStatus: LocationWriteStatus.success));
        showMessage(r.message ?? LocaleKeys.locations_saved.tr());
        _refreshLocationsAfterWrite(
          sellerIdAtRequest: sellerIdAtRequest,
          generationAtRequest: generationAtRequest,
          canRead: event.canRead,
        );
      },
    );
  }

  FutureOr<void> _onUpdateShopLocationEvent(
    UpdateShopLocationEvent event,
    Emitter<DashBoardState> emit,
  ) async {
    final String? sellerIdAtRequest = _currentSellerId;
    final int generationAtRequest = _locationsLoadGeneration;
    if (!_locationWriteCanProceed(sellerIdAtRequest, emit)) return;

    emit(state.copyWith(locationWriteStatus: LocationWriteStatus.inFlight));

    final response = await updateShopLocationUseCase(
      UpdateShopLocationParams(
        id: event.id,
        body: SaveShopLocationParams(
          name: event.name,
          countryId: event.countryId,
          address: event.address,
          latitude: event.latitude,
          longitude: event.longitude,
          sellerId: sellerIdAtRequest,
        ),
      ),
    );

    response.fold(
      (l) {
        _logLocations('update', 'failure', message: l.message);
        emit(
          state.copyWith(
            locationWriteStatus: LocationWriteStatus.failure,
            locationsMessage: l.message,
          ),
        );
        showMessage(LocaleKeys.locations_save_failed.tr(), hasError: true);
      },
      (r) {
        if (!r.isSuccess) {
          _logLocations('update', 'failure-envelope', message: r.message);
          emit(
            state.copyWith(
              locationWriteStatus: LocationWriteStatus.failure,
              locationsMessage: r.message,
            ),
          );
          return;
        }
        _logLocations('update', 'success');
        emit(state.copyWith(locationWriteStatus: LocationWriteStatus.success));
        showMessage(r.message ?? LocaleKeys.locations_saved.tr());
        _refreshLocationsAfterWrite(
          sellerIdAtRequest: sellerIdAtRequest,
          generationAtRequest: generationAtRequest,
          canRead: event.canRead,
        );
      },
    );
  }

  /// The toggle writes one row in place and issues no reload — the contract
  /// says the new value comes from the response.
  ///
  /// The bloc owns that write, and only the bloc. The widget renders and writes
  /// nothing.
  FutureOr<void> _onChangeShopLocationStatusEvent(
    ChangeShopLocationStatusEvent event,
    Emitter<DashBoardState> emit,
  ) async {
    final String? sellerIdAtRequest = _currentSellerId;
    final int generationAtRequest = _locationsLoadGeneration;
    if (!_locationWriteCanProceed(sellerIdAtRequest, emit)) return;

    emit(state.copyWith(locationWriteStatus: LocationWriteStatus.inFlight));

    final response = await changeShopLocationStatusUseCase(
      ChangeShopLocationStatusParams(
        id: event.id,
        status: event.status,
        sellerId: sellerIdAtRequest,
      ),
    );

    // This write touches the list, so it carries the same arrival guard the
    // load does. On a drop: write nothing and emit nothing — the clear that
    // caused it has already reset both the list and the write status.
    if (_locationsResponseIsStale(sellerIdAtRequest, generationAtRequest)) {
      _logLocations('change-status', 'dropped-stale');
      return;
    }

    response.fold(
      (l) {
        _logLocations('change-status', 'failure', message: l.message);
        emit(
          state.copyWith(
            locationWriteStatus: LocationWriteStatus.failure,
            locationsMessage: l.message,
          ),
        );
        showMessage(LocaleKeys.locations_action_failed.tr(), hasError: true);
      },
      (r) {
        if (!r.isSuccess || r.status == null) {
          _logLocations(
            'change-status',
            'failure-envelope',
            message: r.message,
          );
          emit(
            state.copyWith(
              locationWriteStatus: LocationWriteStatus.failure,
              locationsMessage: r.message,
            ),
          );
          showMessage(LocaleKeys.locations_action_failed.tr(), hasError: true);
          return;
        }

        // A **new** list, not a mutation in place: mutating the existing one
        // would leave `props` comparing equal and the emit would be dropped
        // silently, so the row would never redraw.
        final List<ShopLocationModel> updated = <ShopLocationModel>[
          for (final ShopLocationModel row in state.locations.locations)
            if (row.id == event.id) row.copyWith(status: r.status) else row,
        ];

        _logLocations('change-status', 'success');
        emit(
          state.copyWith(
            locationWriteStatus: LocationWriteStatus.success,
            // `copyWith` on the wrapper preserves the stamp rather than
            // re-reading the shop id — re-reading would re-stamp a stale list
            // with the current shop, and the first-frame gate would then pass
            // for the wrong shop.
            locations: state.locations.copyWith(locations: updated),
          ),
        );
      },
    );
  }
}
