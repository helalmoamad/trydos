import 'package:flutter/foundation.dart' hide Category;
import 'dart:async';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/home/domain/use_cases/confirm_return_request_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_provinces_by_iso_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/order_return_requests_view_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/store_return_request_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/update_return_request_product_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/upload_images_product_return_useCase.dart';
import 'package:trydos/features/home/domain/use_cases/wallet_checkout_usecase.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/service/notification_service/notification_service/handle_notification/local_notification_service.dart';
import '../../../../../common/helper/show_message.dart';
import '../../../../../core/data/model/pagination_model.dart';
import '../../../../../core/use_case/use_case.dart';
import '../../../data/models/get_list_of_customer_addresses_model.dart';
import '../../../data/models/get_orders_model.dart';
import '../../../domain/use_cases/add_customer_address_usecase.dart';
import '../../../domain/use_cases/apply_coupon_usecase.dart';
import '../../../domain/use_cases/delete_customer_address_usecase.dart';
import '../../../domain/use_cases/get_address_by_coordinate_usecase.dart';
import '../../../domain/use_cases/get_address_by_text_usecase.dart';
import '../../../domain/use_cases/get_customer_addresses_usecase.dart';
import '../../../domain/use_cases/get_customer_wallet_usecase.dart';
import '../../../domain/use_cases/get_orders_by_cart_group_usecase.dart';
import '../../../domain/use_cases/get_orders_by_order_group_usecase.dart';
import '../../../domain/use_cases/get_orders_usecase.dart';
import '../../../domain/use_cases/place_order_usecase.dart';
import '../../../domain/use_cases/cancel_order_item_usecase.dart';
import '../../../domain/use_cases/cancel_order_usecase.dart';
import '../../../domain/use_cases/change_order_address_usecase.dart';
import '../../../domain/use_cases/get_product_color_size_sync_attribute_usecase.dart';
import '../../../domain/use_cases/set_customer_address_default_usecase.dart';
import '../../../domain/use_cases/update_customer_address_usecase.dart';
import '../../../domain/use_cases/change_order_item_variant_usecase.dart';
import '../../widgets/cart_section/payment_method.dart';
import 'order_event.dart';
import 'order_state.dart';
import 'package:trydos/core/error/error_manager.dart';
import '../../../domain/use_cases/get_return_reasons_usecase.dart';
import '../../../domain/use_cases/store_return_request_product_usecase.dart';
import '../../../domain/use_cases/cancel_return_request_usecase.dart';
import '../../../domain/use_cases/cancel_return_request_product_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/order_return_details_usecase.dart';
import '../../../data/models/get_order_details_return_model.dart';

@LazySingleton()
class OrderBloc extends HydratedBloc<OrderEvent, OrderState> {
  final PlaceOrderUsecase placeOrderUsecase;
  final CancelOrderItemUsecase cancelOrderItemUsecase;
  final CancelOrderUsecase cancelOrderUsecase;
  final ChangeOrderAddressUsecase changeOrderAddressUsecase;
  final GetOrdersByOrderGroupIDUsecase getOrdersByOrderGroupIDUsecase;
  final GetOrdersByCartGroupIDUsecase getOrdersByCartGroupIDUsecase;
  final GetCustomerWalletUseCase getCustomerWalletUseCase;
  final GetOrdersUseCase getOrdersUseCase;
  final SetCustomerAddressDefaultUseCase setCustomerAddressDefaultUseCase;
  final GetCustomerAddressesUseCase getCustomerAddressesUseCase;
  final DeleteCustomerAddressUseCase deleteCustomerAddressUseCase;
  final AddCustomerAddressUseCase addCustomerAddressUseCase;
  final UpdateCustomerAddressUseCase updateCustomerAddressUseCase;
  final GetAddressByCoordinatesUsecase getAddressByCoordinatesUsecase;
  final GetAddressByTextUsecase getAddressByTextUsecase;
  final ApplyCouponUsecase applyCouponUsecase;
  final GetProvincesByIsoUseCase getProvincesByIsoUseCase;
  final GetProductColorSizeSyncAttributeUseCase
  getProductColorSizeSyncAttributeUseCase;
  final WalletCheckoutUseCase walletCheckoutUseCase;
  final ConfirmReturnRequestUseCase confirmReturnRequestUseCase;
  final OrderReturnRequestsViewUseCase orderReturnRequestsViewUseCase;
  final ChangeOrderItemVariantUsecase changeOrderItemVariantUsecase;
  // final AddOrderCommentUseCase addOrderCommentUseCase;
  // final UpdateOrderCommentUseCase updateOrderCommentUseCase;
  final GetReturnReasonsUseCase getReturnReasonsUseCase;

  final StoreReturnRequestProductUseCase storeReturnRequestProductUseCase;
  final CancelReturnRequestUseCase cancelReturnRequestUseCase;
  final CancelReturnRequestProductUseCase cancelReturnRequestProductUseCase;
  final StoreReturnRequestUseCase storeReturnRequestUseCase;
  final UploadImagesProductReturnUseCase uploadImagesProductReturnUseCase;
  final OrderReturnDetailsUseCase orderReturnDetailsUseCase;
  final UpdateReturnRequestProductUseCase updateReturnRequestProductUseCase;
  OrderBloc(
    this.placeOrderUsecase,
    this.walletCheckoutUseCase,
    this.cancelOrderItemUsecase,
    this.cancelOrderUsecase,
    this.uploadImagesProductReturnUseCase,
    this.changeOrderAddressUsecase,
    this.getOrdersByOrderGroupIDUsecase,
    this.getOrdersByCartGroupIDUsecase,
    this.getProvincesByIsoUseCase,
    this.getCustomerWalletUseCase,
    this.storeReturnRequestUseCase,
    this.confirmReturnRequestUseCase,
    this.orderReturnRequestsViewUseCase,
    this.getOrdersUseCase,
    this.setCustomerAddressDefaultUseCase,
    this.getCustomerAddressesUseCase,
    this.deleteCustomerAddressUseCase,
    this.addCustomerAddressUseCase,
    this.updateCustomerAddressUseCase,
    this.getAddressByCoordinatesUsecase,
    this.getAddressByTextUsecase,
    this.applyCouponUsecase,
    this.getProductColorSizeSyncAttributeUseCase,
    this.changeOrderItemVariantUsecase,
    //  this.addOrderCommentUseCase,
    // this.updateOrderCommentUseCase,
    this.getReturnReasonsUseCase,
    this.storeReturnRequestProductUseCase,
    this.cancelReturnRequestUseCase,
    this.cancelReturnRequestProductUseCase,
    this.updateReturnRequestProductUseCase,
    this.orderReturnDetailsUseCase,
  ) : super(const OrderState()) {
    on<PlaceOrderEvent>(_onPlaceOrderEvent);
    on<GetOrdersByOrderGroupIDEvent>(_onGetOrdersByOrderGroupIDEvent);
    on<WalletCheckoutEvent>(_onWalletCheckoutEvent);
    on<SaveLastAddress>(_onSaveLastAddress);
    on<UploadImagesToCloudinaryEvent>(_onUploadImagesToCloudinaryEvent);
    on<ResetAllStatusEvent>(_onResetAllStatusEvent);
    on<GetOrdersByCartGroupIDEvent>(_onGetOrdersByCartGroupIDEvent);
    on<UploadImagesForReturnProductEvent>(_onUploadImagesForReturnProductEvent);
    on<RemoveImagesForReturnProductEvent>(_onRemoveImagesForReturnProductEvent);
    on<RemoveImagesForCommentEvent>(_onRemoveImagesForCommentEvent);
    on<OrderReturnRequestsViewEvent>(_onOrderReturnRequestsViewEvent);
    on<ConfirmReturnRequestEvent>(_onConfirmReturnRequestEvent);
    on<SaveCurrentOrederStatusEvent>(_onSaveCurrentOrederStatusEvent);
    on<GetCustomerWalletEvent>(_onGetCustomerWalletEvent);
    on<UpdateReturnRequestProductEvent>(_onUpdateReturnRequestProductEvent);
    on<GetProvincesByIsoEvent>(_onGetProvincesByIsoEvent);
    on<StoreReturnRequestEvent>(_onStoreReturnRequestEvent);
    on<GetOrdersEvent>(_onGetOrdersEvent);
    on<ChangeOrderByGroupStatus>(_onChangeOrderByGroupStatus);

    on<SetCustomerAddressDefaultEvent>(
      _onSetCustomerAddressDefaultEvent,
      transformer: restartable(),
    );
    on<GetCustomerAddressesEvent>(_onGetCustomerAddressesEvent);
    on<DeleteAdressInfoClassEvent>(_onDeleteAdressInfoClassEvent);
    on<AddAddressInfoClassEvent>(_onAddAddressInfoClassEvent);
    on<EditAdressInfoClassEvent>(_onEditAdressInfoClassEvent);
    on<GetAddressByCoordinatesEvent>(_onGetAddressByCoordinatesEvent);
    on<GetAddressByTextEvent>(
      _onGetAddressByTextEvent,
      transformer: restartable(),
    );
    on<SetCurrentAddressChoosedEvent>(_onSetCurrentAddressChoosedEvent);
    on<ApplyCouponEvent>(_onApplyCouponEvent);
    on<CancelOrderItemEvent>(_onCancelOrderItemEvent);
    on<StoreImagesForUpdateReturnEvent>(_onStoreImagesForUpdateReturnEvent);
    on<CancelOrderEvent>(_onCancelOrderEvent);
    on<ChangeOrderAddressEvent>(_onChangeOrderAddressEvent);
    on<GetProductColorSizeSyncAttributeEvent>(
      _onGetProductColorSizeSyncAttributeEvent,
    );
    on<ChangeOrderItemVariantEvent>(_onChangeOrderItemVariantEvent);
    // on<AddOrderCommentEvent>(_onAddOrderCommentEvent);
    //on<UpdateOrderCommentEvent>(_onUpdateOrderCommentEvent);
    on<GetReturnReasonsEvent>(_onGetReturnReasonsEvent);
    on<StoreReturnRequestProductEvent>(_onStoreReturnRequestProductEvent);
    on<CancelReturnRequestEvent>(_onCancelReturnRequestEvent);
    on<CancelReturnRequestProductEvent>(_onCancelReturnRequestProductEvent);
    on<FetchOrderReturnDetailsEvent>(
      _onFetchOrderReturnDetailsEvent,
      transformer: restartable(),
    );
  }
  FutureOr<void> _onRemoveImagesForReturnProductEvent(
    RemoveImagesForReturnProductEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(
      state.copyWith(
        uploadImagesForReturnProductStatus:
            UploadImagesForReturnProductStatus.init,
      ),
    );
    List<String> imagesForReturn = List.of(state.imagesForReturn ?? []);

    imagesForReturn.removeAt(event.index);
    await Future.delayed(const Duration(milliseconds: 300));
    emit(
      state.copyWith(
        uploadImagesForReturnProductStatus:
            UploadImagesForReturnProductStatus.success,
        imagesForReturn: imagesForReturn,
      ),
    );
  }

  FutureOr<void> _onWalletCheckoutEvent(
    WalletCheckoutEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWith(walletCheckoutStatus: WalletCheckoutStatus.loading));

    final response = await walletCheckoutUseCase(event.params);

    response.fold(
      (l) {
        if (kDebugMode) print("DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD${l.statusCode}");
        if (l.statusCode == 401) {
          emit(
            state.copyWith(walletCheckoutStatus: WalletCheckoutStatus.unAuth),
          );
          return;
        }
        if (ErrorManager.shouldRetry('WalletCheckoutEvent', l.statusCode)) {
          ErrorManager.incrementRetry('WalletCheckoutEvent');
          add(WalletCheckoutEvent(params: event.params));
          return;
        }
        emit(
          state.copyWith(walletCheckoutStatus: WalletCheckoutStatus.failure),
        );
      },
      (r) {
        ErrorManager.resetRetry('WalletCheckoutEvent');
        emit(
          state.copyWith(walletCheckoutStatus: WalletCheckoutStatus.success),
        );
      },
    );
  }

  FutureOr<void> _onRemoveImagesForCommentEvent(
    RemoveImagesForCommentEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(
      state.copyWith(
        uploadImagesToCloudinaryStatus: UploadImagesToCloudinaryStatus.init,
      ),
    );
    List<String> imagesForComment = List.of(state.imagesForComment ?? []);
    if (event.initialImages?.isNotEmpty ?? false) {
      imagesForComment.clear();
      imagesForComment.addAll(event.initialImages ?? []);
    } else if (event.index == -1) {
      imagesForComment.clear();
    } else {
      imagesForComment.removeAt(event.index);
    }

    await Future.delayed(const Duration(milliseconds: 300));
    emit(
      state.copyWith(
        uploadImagesToCloudinaryStatus: UploadImagesToCloudinaryStatus.success,
        imagesForComment: imagesForComment,
      ),
    );
  }

  FutureOr<void> _onUploadImagesToCloudinaryEvent(
    UploadImagesToCloudinaryEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(
      state.copyWith(
        uploadImagesToCloudinaryStatus: UploadImagesToCloudinaryStatus.loading,
      ),
    );
    final response = await uploadImagesProductReturnUseCase(
      UpdateImagesForReturnProductParams(
        path: "rating_orders/",
        image: event.file,
      ),
    );

    response.fold(
      (l) {
        emit(
          state.copyWith(
            uploadImagesToCloudinaryStatus:
                UploadImagesToCloudinaryStatus.failure,
          ),
        );
      },
      (r) {
        List<String> imagesForComment = List.of(state.imagesForComment ?? []);
        imagesForComment.add(r.data?.subPath ?? "");
        emit(
          state.copyWith(
            imagesForComment: imagesForComment,
            uploadImagesToCloudinaryStatus:
                UploadImagesToCloudinaryStatus.success,
          ),
        );
      },
    );
  }

  FutureOr<void> _onPlaceOrderEvent(
    PlaceOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    debugPrint(event.placeOrderParams.paymentMethod);
    debugPrint(event.placeOrderParams.addressId.toString());
    debugPrint(event.placeOrderParams.payByWallet.toString());
    emit(state.copyWith(placeOrderStatus: PlaceOrderStatus.loading));
    final response = await placeOrderUsecase(event.placeOrderParams);
    response.fold(
      (l) {
        if (l.statusCode == 403) {
          emit(state.copyWith(placeOrderStatus: PlaceOrderStatus.unavailable));
        } else {
          if (ErrorManager.shouldRetry('PlaceOrderEvent', l.statusCode)) {
            ErrorManager.incrementRetry('PlaceOrderEvent');
            add(PlaceOrderEvent(placeOrderParams: event.placeOrderParams));
          }
          emit(state.copyWith(placeOrderStatus: PlaceOrderStatus.failure));
        }
      },
      (r) async {
        ErrorManager.resetRetry('PlaceOrderEvent');
        debugPrint('PlaceOrderStatus success');
        debugPrint('orders length :  r.data!.length}');
        List<String> getNotificationIdsToRemoveAfterplaceOrder =
            prefsRepository.getNotificationIdsToRemoveAfterplaceOrder ?? [];
        getNotificationIdsToRemoveAfterplaceOrder.forEach((element) {
          try {
            LocalNotificationService.localNotificationPlugin.cancel(
              int.tryParse(element) ?? 0,
            );
          } catch (e) {}
        });
        prefsRepository.removeNotificationIdsToRemoveAfterplaceOrder();
        emit(
          state.copyWith(
            placeOrderStatus: PlaceOrderStatus.success,
            placeOrderModel: r,
          ),
        );
      },
    );
  }

  FutureOr<void> _onGetOrdersByOrderGroupIDEvent(
    GetOrdersByOrderGroupIDEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(
      state.copyWith(
        getOrdersByOrderGroupIDStatus: event.firstOpenPage
            ? GetOrdersByOrderGroupIDStatus.init
            : GetOrdersByOrderGroupIDStatus.loading,
      ),
    );
    final response = await getOrdersByOrderGroupIDUsecase(event.orderGroupId);
    response.fold(
      (l) {
        if (ErrorManager.shouldRetry(
          'GetOrdersByOrderGroupIDEvent',
          l.statusCode,
        )) {
          ErrorManager.incrementRetry('GetOrdersByOrderGroupIDEvent');
          add(GetOrdersByOrderGroupIDEvent(orderGroupId: event.orderGroupId));
        }
        emit(
          state.copyWith(
            getOrdersByOrderGroupIDStatus:
                GetOrdersByOrderGroupIDStatus.failure,
          ),
        );
      },
      (r) {
        ErrorManager.resetRetry('GetOrdersByOrderGroupIDEvent');
        debugPrint('GetOrdersByOrderGroupIDEvent success');
        debugPrint('orders length :  r.data!.length}');
        Map<String, PaginationModel<List<OrderListModel>>>? getOrdersModel =
            Map.of(state.getOrdersModel ?? {});
        List<List<OrderListModel>> listOrder =
            getOrdersModel[event.status]?.items ?? [];
        int index = listOrder.indexWhere(
          (element) => element[0].orderGroupId == event.orderGroupId,
        );
        if (index != -1) {
          listOrder[index] = r.orders ?? [];
          getOrdersModel[event.status] = PaginationModel<List<OrderListModel>>(
            page: 1,
            items: listOrder,
            paginationStatus:
                getOrdersModel[event.status]?.paginationStatus ??
                PaginationStatus.success,
            hasReachedMax: getOrdersModel[event.status]?.hasReachedMax ?? false,
          );
        }
        /* if (event.fromNotification) {
          bool canFetchReturnDetails = false;
          r.orders?.forEach(
            (element) {
              if (element.returnRequestId != null) {
                canFetchReturnDetails = true;
              }
            },
          );
          if (canFetchReturnDetails) {
            add(FetchOrderReturnDetailsEvent(
              r.orders?[0].orderGroupId ?? "",
            ));
          }
        }*/
        emit(
          state.copyWith(
            getOrdersByOrderGroupIDStatus:
                GetOrdersByOrderGroupIDStatus.success,
            getOrdersModel: getOrdersModel,
            getOrdersByOrderGroupIDModel: r,
          ),
        );
      },
    );
  }

  _onCancelReturnRequestEvent(
    CancelReturnRequestEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(
      state.copyWith(
        cancelReturnRequestStatus: CancelReturnRequestStatus.loading,
      ),
    );
    final response = await cancelReturnRequestUseCase(
      CancelReturnRequestParams(returnRequestId: event.returnRequestId),
    );
    response.fold(
      (l) {
        if (ErrorManager.shouldRetry(
          'CancelReturnRequestEvent',
          l.statusCode,
        )) {
          ErrorManager.incrementRetry('CancelReturnRequestEvent');
          add(
            CancelReturnRequestEvent(
              returnRequestId: event.returnRequestId,
              orderGroupId: event.orderGroupId,
            ),
          );
          return;
        }
        showMessage(l.message, hasError: true);
        emit(
          state.copyWith(
            cancelReturnRequestStatus: CancelReturnRequestStatus.failure,
          ),
        );
      },
      (r) {
        add(FetchOrderReturnDetailsEvent(event.orderGroupId));
        add(GetOrdersByOrderGroupIDEvent(orderGroupId: event.orderGroupId));
        showMessage(r.message ?? '');
        ErrorManager.resetRetry('CancelReturnRequestEvent');
        emit(
          state.copyWith(
            orderReturnDetailsModel: GetOrderReturntDetailsModel(
              data: Data(returnRequestsData: []),
            ),
            cancelReturnRequestStatus: CancelReturnRequestStatus.success,
          ),
        );
      },
    );
  }

  _onCancelReturnRequestProductEvent(
    CancelReturnRequestProductEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(
      state.copyWith(
        cancelReturnRequestProductStatus:
            CancelReturnRequestProductStatus.loading,
      ),
    );
    final response = await cancelReturnRequestProductUseCase(event.params);
    response.fold(
      (l) {
        if (ErrorManager.shouldRetry(
          'CancelReturnRequestProductEvent',
          l.statusCode,
        )) {
          ErrorManager.incrementRetry('CancelReturnRequestProductEvent');
          add(
            CancelReturnRequestProductEvent(
              orderGroupId: event.orderGroupId,
              params: event.params,
              returnRequestId: event.returnRequestId,
            ),
          );
          return;
        }
        showMessage(l.message, hasError: true);
        emit(
          state.copyWith(
            cancelReturnRequestProductStatus:
                CancelReturnRequestProductStatus.failure,
          ),
        );
      },
      (r) {
        add(FetchOrderReturnDetailsEvent(event.orderGroupId));
        showMessage(r.message ?? '');
        ErrorManager.resetRetry('CancelReturnRequestProductEvent');
        emit(
          state.copyWith(
            cancelReturnRequestProductStatus:
                CancelReturnRequestProductStatus.success,
          ),
        );
      },
    );
  }

  FutureOr<void> _onGetOrdersByCartGroupIDEvent(
    GetOrdersByCartGroupIDEvent event,
    Emitter<OrderState> emit,
  ) async {
    if (state.getOrdersByCartGroupIDStatus ==
        GetOrdersByCartGroupIDStatus.loading) {
      return;
    }
    emit(
      state.copyWith(
        getOrdersByCartGroupIDStatus: GetOrdersByCartGroupIDStatus.loading,
      ),
    );
    final response = await getOrdersByCartGroupIDUsecase(event.cartGroupId);
    response.fold(
      (l) {
        emit(
          state.copyWith(
            getOrdersByCartGroupIDStatus: GetOrdersByCartGroupIDStatus.failure,
          ),
        );
        Future.delayed(const Duration(seconds: 1), () {
          add(GetOrdersByCartGroupIDEvent(cartGroupId: event.cartGroupId));
        });
      },
      (r) {
        ErrorManager.resetRetry('GetOrdersByCartGroupIDEvent');
        debugPrint('GetOrdersByCartGroupIDEvent success');
        debugPrint('orders length :  r.data!.length}');
        if (r.data!.length < 1) {
          emit(
            state.copyWith(
              getOrdersByCartGroupIDStatus:
                  GetOrdersByCartGroupIDStatus.failure,
            ),
          );
          Future.delayed(const Duration(seconds: 1), () {
            add(GetOrdersByCartGroupIDEvent(cartGroupId: event.cartGroupId));
          });
          return;
        }
        emit(
          state.copyWith(
            getOrdersByCartGroupIDStatus: GetOrdersByCartGroupIDStatus.success,
            getOrdersByCartGroupIDModel: r,
          ),
        );
      },
    );
  }

  FutureOr<void> _onGetProvincesByIsoEvent(
    GetProvincesByIsoEvent event,
    Emitter<OrderState> emit,
  ) async {
    final response = await getProvincesByIsoUseCase.call(NoParams());
    response.fold(
      (l) {
        if (ErrorManager.shouldRetry('GetProvincesByIsoEvent', l.statusCode)) {
          ErrorManager.incrementRetry('GetProvincesByIsoEvent');
          add(const GetProvincesByIsoEvent());
          return;
        }
      },
      (r) {
        ErrorManager.resetRetry('GetProvincesByIsoEvent');
        emit(state.copyWith(provincesByIso: r.data));
      },
    );
  }

  FutureOr<void> _onStoreImagesForUpdateReturnEvent(
    StoreImagesForUpdateReturnEvent event,
    Emitter<OrderState> emit,
  ) {
    emit(state.copyWith(imagesForReturn: event.images));
  }

  FutureOr<void> _onResetAllStatusEvent(
    ResetAllStatusEvent event,
    Emitter<OrderState> emit,
  ) {
    emit(
      state.copyWith(
        cancelReturnRequestProductStatus: CancelReturnRequestProductStatus.init,
        cancelReturnRequestStatus: CancelReturnRequestStatus.init,
        cancelOrderStatus: CancelOrderStatus.init,
        cancelOrderItemStatus: CancelOrderItemStatus.init,
        confirmReturnRequestStatus: ConfirmReturnRequestStatus.init,
        changeOrderItemVariantStatus: ChangeOrderItemVariantStatus.init,
        changeOrderAddressStatus: ChangeOrderAddressStatus.init,
        storeReturnRequestProductStatus: StoreReturnRequestProductStatus.init,
        orderReturnDetailsStatus: OrderReturnDetailsStatus.init,
        updateReturnRequestProductStatus: UpdateReturnRequestProductStatus.init,
        storeReturnRequestStatus: StoreReturnRequestStatus.init,
      ),
    );
  }

  FutureOr<void> _onGetCustomerWalletEvent(
    GetCustomerWalletEvent event,
    Emitter<OrderState> emit,
  ) async {
    if (event.assetId == "" ||
        ((prefsRepository.walletToken?.length ?? 0) < 6)) {
      if ((prefsRepository.myPhoneNumber?.length ?? 0) < 3) {
        emit(
          state.copyWith(
            getCustomerWalletStatus: GetCustomerWalletStatus.loading,
          ),
        );
        await Future.delayed(const Duration(seconds: 1));
        emit(
          state.copyWith(
            customerWalletModel: state.customerWalletModel?.copyWith(
              available: 0,
            ),
            getCustomerWalletStatus: GetCustomerWalletStatus.success,
          ),
        );
      }

      return;
    }
    if (event.assetId == "LOADING") {
      emit(
        state.copyWith(
          getCustomerWalletStatus: GetCustomerWalletStatus.loading,
        ),
      );
      return;
    }
    if (event.assetId == "FAILED") {
      emit(
        state.copyWith(
          getCustomerWalletStatus: GetCustomerWalletStatus.failure,
        ),
      );
      return;
    }
    if (event.statusInitToRefreshAmount) {
      emit(
        state.copyWith(getCustomerWalletStatus: GetCustomerWalletStatus.init),
      );
    } else {
      emit(
        state.copyWith(
          getCustomerWalletStatus: GetCustomerWalletStatus.loading,
        ),
      );
    }
    final response = await getCustomerWalletUseCase.call(
      CustomerWalletParams(assetId: event.assetId),
    );
    response.fold(
      (l) {
        if (ErrorManager.shouldRetry('GetCustomerWalletEvent', l.statusCode)) {
          ErrorManager.incrementRetry('GetCustomerWalletEvent');
          add(
            GetCustomerWalletEvent(
              assetId: event.assetId,
              statusInitToRefreshAmount: event.statusInitToRefreshAmount,
            ),
          );
          return;
        }
        emit(
          state.copyWith(
            getCustomerWalletStatus: GetCustomerWalletStatus.failure,
          ),
        );
      },
      (r) {
        ErrorManager.resetRetry('GetCustomerWalletEvent');
        emit(
          state.copyWith(
            getCustomerWalletStatus: GetCustomerWalletStatus.success,
            customerWalletModel: r,
          ),
        );
      },
    );
  }

  FutureOr<void> _onSaveLastAddress(
    SaveLastAddress event,
    Emitter<OrderState> emit,
  ) async {
    ///////////////////////////
    emit(state.copyWith(lastAdressInfoClassToSave: event.lastAddress));
  }

  FutureOr<void> _onSaveCurrentOrederStatusEvent(
    SaveCurrentOrederStatusEvent event,
    Emitter<OrderState> emit,
  ) async {
    ///////////////////////////
    emit(state.copyWith(currentOrederStatus: event.currentOrderStatus));
  }

  FutureOr<void> _onChangeOrderByGroupStatus(
    ChangeOrderByGroupStatus event,
    Emitter<OrderState> emit,
  ) async {
    ///////////////////////////
    emit(
      state.copyWith(
        getOrdersByOrderGroupIDStatus: event.loading
            ? GetOrdersByOrderGroupIDStatus.loading
            : GetOrdersByOrderGroupIDStatus.init,
      ),
    );
  }

  FutureOr<void> _onGetOrdersEvent(
    GetOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    if (event.index != -1 && event.orders.isNotEmpty) {
      Map<String, PaginationModel<List<OrderListModel>>>? getOrdersModel =
          state.getOrdersModel;
      List<List<OrderListModel>> listOrder =
          getOrdersModel?[event.status]?.items ?? [];
      listOrder[event.index] = event.orders;
      getOrdersModel?[event.status] = PaginationModel<List<OrderListModel>>(
        page: 1,
        items: listOrder,
        paginationStatus:
            getOrdersModel[event.status]?.paginationStatus ??
            PaginationStatus.loading,
        hasReachedMax: getOrdersModel[event.status]?.hasReachedMax ?? false,
      );

      emit(state.copyWith(getOrdersModel: getOrdersModel));

      await Future.delayed(const Duration(seconds: 1));
      getOrdersModel?[event.status] = PaginationModel<List<OrderListModel>>(
        page: 1,
        items: listOrder,
        paginationStatus:
            getOrdersModel[event.status]?.paginationStatus ??
            PaginationStatus.success,
        hasReachedMax: getOrdersModel[event.status]?.hasReachedMax ?? false,
      );

      emit(state.copyWith(getOrdersModel: getOrdersModel));
      return;
    }
    Map<String, PaginationModel<List<OrderListModel>>>? getOrdersModel =
        !event.getWithPagination ? {} : Map.of(state.getOrdersModel ?? {});

    if (getOrdersModel[event.status] == null) {
      getOrdersModel[event.status] =
          const PaginationModel<List<OrderListModel>>.init(page: 1);
    }
    if (event.getWithPagination &&
        (getOrdersModel[event.status]!.hasReachedMax ||
            getOrdersModel[event.status]!.paginationStatus ==
                PaginationStatus.loading)) {
      return;
    }

    emit(
      state.copyWith(
        getOrdersModel: getOrdersModel.map((key, value) {
          if (key == event.status) {
            return MapEntry(
              key,
              value.copyWith(paginationStatus: PaginationStatus.loading),
            );
          } else {
            return MapEntry(key, value);
          }
        }),
      ),
    );

    GetOrdersParams params = GetOrdersParams(
      offset: event.getWithPagination
          ? getOrdersModel[event.status]?.page ?? 1
          : 1,
      status: event.status,
    );

    final response = await getOrdersUseCase(params);

    response.fold(
      (l) {
        getOrdersModel = state.getOrdersModel;

        if (ErrorManager.shouldRetry('GetOrdersEvent', l.statusCode)) {
          ErrorManager.incrementRetry('GetOrdersEvent');
          add(
            GetOrdersEvent(
              status: event.status,
              getWithPagination: event.getWithPagination,
            ),
          );
          return; // لا تحدث الحالة
        }

        emit(
          state.copyWith(
            getOrdersModel: getOrdersModel?.map((key, value) {
              if (key == event.status)
                return MapEntry(
                  key,
                  value.copyWith(paginationStatus: PaginationStatus.failure),
                );
              return MapEntry(key, value);
            }),
          ),
        );
      },
      (r) {
        getOrdersModel = state.getOrdersModel;
        ErrorManager.resetRetry('GetOrdersEvent');

        List<List<OrderListModel>> oldOrders = [];
        if (getOrdersModel?[event.status] != null &&
            ((getOrdersModel?[event.status]?.items.length ?? 0) > 0)) {
          oldOrders = getOrdersModel![event.status]!.items;
        }

        List<OrderListModel> ordersFromApi = List.of(r.data?.orders ?? []);
        List<List<OrderListModel>> newOrders = [];

        final seen = <String>{};
        final List<String> duplicatesOrderGroupIds = [];

        for (var item in ordersFromApi) {
          if (!seen.add(item.orderGroupId ?? '')) {
            duplicatesOrderGroupIds.add(item.orderGroupId ?? '');
          }
        }
        final List<String> orderNewAdded = [];
        ordersFromApi.forEach((element) {
          if (!(duplicatesOrderGroupIds.contains(element.orderGroupId))) {
            newOrders.add(
              ordersFromApi.where((elements) {
                return elements.orderGroupId == element.orderGroupId;
              }).toList(),
            );
          }
          if (duplicatesOrderGroupIds.contains(element.orderGroupId) &&
              (!(orderNewAdded.contains(element.orderGroupId)))) {
            orderNewAdded.add(element.orderGroupId ?? "");
            newOrders.add(
              ordersFromApi.where((elements) {
                return elements.orderGroupId == element.orderGroupId;
              }).toList(),
            );
          }
        });

        emit(
          state.copyWith(
            orderTotalSize: r.data?.total ?? 0,
            getOrdersModel: getOrdersModel?.map((key, value) {
              if (key == event.status) {
                return MapEntry(
                  key,
                  value.copyWith(
                    hasReachedMax:
                        (r.data!.orders?.length ?? kPageSize) < kPageSize,
                    paginationStatus: PaginationStatus.success,
                    page: event.getWithPagination
                        ? getOrdersModel![event.status]!.page + 1
                        : 2,
                    items: !event.getWithPagination
                        ? [...newOrders]
                        : [...oldOrders, ...newOrders],
                  ),
                );
              } else {
                return MapEntry(key, value);
              }
            }),
          ),
        );
      },
    );
  }

  FutureOr<void> _onSetCustomerAddressDefaultEvent(
    SetCustomerAddressDefaultEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(
      state.copyWith(
        setCustomerAddressDefaultStatus:
            SetCustomerAddressDefaultStatus.loading,
      ),
    );
    final response = await setCustomerAddressDefaultUseCase(
      SetCustomerAddressDefaultParams(addressId: event.adressId ?? 0),
    );

    response.fold(
      (l) {
        if (ErrorManager.shouldRetry(
          'SetCustomerAddressDefaultEvent',
          l.statusCode,
        )) {
          ErrorManager.incrementRetry('SetCustomerAddressDefaultEvent');
          add(SetCustomerAddressDefaultEvent(adressId: event.adressId));
          return;
        }

        emit(
          state.copyWith(
            setCustomerAddressDefaultStatus:
                SetCustomerAddressDefaultStatus.failure,
          ),
        );
      },
      (r) async {
        GetIt.I<HomeBloc>().add(GetCartOverviewEvent());
        ErrorManager.resetRetry('SetCustomerAddressDefaultEvent');

        emit(
          state.copyWith(
            currentAddressChoosed: event.index == -1
                ? state.currentAddressChoosed
                : event.index,
            setCustomerAddressDefaultStatus:
                SetCustomerAddressDefaultStatus.success,
          ),
        );
      },
    );
  }

  FutureOr<void> _onGetCustomerAddressesEvent(
    GetCustomerAddressesEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(
      state.copyWith(
        getCustomerAddressesStatus: GetCustomerAddressesStatus.loading,
      ),
    );
    final response = await getCustomerAddressesUseCase(NoParams());

    response.fold(
      (l) {
        if (ErrorManager.shouldRetry('getCustomerAddresses', l.statusCode)) {
          ErrorManager.incrementRetry('getCustomerAddresses');
          add(GetCustomerAddressesEvent());
        }

        emit(
          state.copyWith(
            getCustomerAddressesStatus: GetCustomerAddressesStatus.failure,
          ),
        );
      },
      (r) async {
        ErrorManager.resetRetry('getCustomerAddresses');
        List<CustomerAddressesInfo>? listOfAdressInfoClassToSave = [];
        listOfAdressInfoClassToSave = [...r.data!];
        int currentAddressChoosed = 0;
        for (var i = 0; i < (r.data?.length ?? 0); i++) {
          if (r.data?[i].isDefault == 1) {
            currentAddressChoosed = i;
          }
        }
        if ((r.data?.length ?? 0) > 0 && (event.setDefault ?? false)) {
          add(
            SetCustomerAddressDefaultEvent(
              adressId: r.data?[currentAddressChoosed].id,
            ),
          );
        }

        emit(
          state.copyWith(
            currentAddressChoosed: currentAddressChoosed,
            listOfAdressInfoClassToSave: List.of(listOfAdressInfoClassToSave),
            getCustomerAddressesStatus: GetCustomerAddressesStatus.success,
          ),
        );
      },
    );
  }

  FutureOr<void> _onDeleteAdressInfoClassEvent(
    DeleteAdressInfoClassEvent event,
    Emitter<OrderState> emit,
  ) async {
    final List<CustomerAddressesInfo> listOfAddressInfoClassToSave = List.of(
      state.listOfAddressInfoClassToSave ?? [],
    );
    int index = listOfAddressInfoClassToSave.indexWhere(
      (element) => element.id == event.adressInfoClassId,
    );
    CustomerAddressesInfo preCustomerAddress =
        listOfAddressInfoClassToSave[index];

    listOfAddressInfoClassToSave.removeWhere(
      (element) => element.id == event.adressInfoClassId,
    );
    emit(
      state.copyWith(
        listOfAdressInfoClassToSave: listOfAddressInfoClassToSave,
        removeAddressToOrderStatus: RemoveAddressToOrderStatus.loading,
      ),
    );
    final response = await deleteCustomerAddressUseCase(
      DeleteCustomerAddressParams(addressId: event.adressInfoClassId ?? 0),
    );

    response.fold(
      (l) {
        if (ErrorManager.shouldRetry('deleteCustomerAddress', l.statusCode)) {
          ErrorManager.incrementRetry('deleteCustomerAddress');
          add(
            DeleteAdressInfoClassEvent(
              adressInfoClassId: event.adressInfoClassId,
            ),
          );
          return; // لا تعرض رسالة ولا تحدث الحالة
        }
        // فقط بعد انتهاء المحاولات
        showMessage(
          l.message,
          foreGroundColor: Colors.white,
          hasError: true,
          backGroundColor: Colors.black,
          showInRelease: true,
        );
        final List<CustomerAddressesInfo> listOfAddressInfoClassToSave =
            List.of(state.listOfAddressInfoClassToSave ?? []);
        listOfAddressInfoClassToSave.insert(index, preCustomerAddress);
        emit(
          state.copyWith(
            listOfAdressInfoClassToSave: listOfAddressInfoClassToSave,
            removeAddressToOrderStatus: RemoveAddressToOrderStatus.failure,
          ),
        );
      },
      (r) async {
        add(GetCustomerAddressesEvent());
        showMessage(
          r.message ?? "",
          foreGroundColor: Colors.white,
          backGroundColor: Colors.black,
          showInRelease: true,
        );
        ErrorManager.resetRetry('deleteCustomerAddress');

        emit(
          state.copyWith(
            removeAddressToOrderStatus: RemoveAddressToOrderStatus.success,
            listOfAdressInfoClassToSave: listOfAddressInfoClassToSave,
          ),
        );
      },
    );
  }

  FutureOr<void> _onAddAddressInfoClassEvent(
    AddAddressInfoClassEvent event,
    Emitter<OrderState> emit,
  ) async {
    final List<CustomerAddressesInfo> listOfAddressInfoClassToSave = List.of(
      state.listOfAddressInfoClassToSave ?? [],
    );
    CustomerAddressesInfo adressInfoClassToSave = event.addressInfoClassToSave!;
    listOfAddressInfoClassToSave.insert(0, adressInfoClassToSave);
    emit(
      state.copyWith(
        listOfAdressInfoClassToSave: listOfAddressInfoClassToSave,
        addAddressToOrderStatus: AddAddressToOrderStatus.loading,
      ),
    );

    final response = await addCustomerAddressUseCase(
      AddCustomerAddressParams(
        iso:
            (prefsRepository.userCountryIsAvailable == 1
                ? prefsRepository.userChoosedCountryIso
                : prefsRepository.countryIso) ??
            "",
        address: event.addressInfoClassToSave?.address ?? "",
        addressDetail: event.addressInfoClassToSave?.addressDetail ?? "",
        country: event.addressInfoClassToSave?.regionDetails?.country ?? "",
        city: event.addressInfoClassToSave?.regionDetails?.city ?? "",
        district: event.addressInfoClassToSave?.regionDetails?.city ?? "",
        town: event.addressInfoClassToSave?.regionDetails?.town ?? "",
        street: event.addressInfoClassToSave?.regionDetails?.street ?? "",
        zip: event.addressInfoClassToSave?.regionDetails?.zip ?? '',
        phone: event.addressInfoClassToSave?.contactInfo?.phone ?? "",
        alternativePhone:
            event.addressInfoClassToSave?.contactInfo?.alternativePhone ?? "",
        latitude: event.addressInfoClassToSave?.location?.latitude ?? "",
        longitude: event.addressInfoClassToSave?.location?.longitude ?? "",
        province: event.addressInfoClassToSave?.regionDetails?.province ?? "",
        building: event.addressInfoClassToSave?.regionDetails?.building ?? "",
        contactPersonName:
            event.addressInfoClassToSave?.contactInfo?.name ?? "",
      ),
    );

    response.fold(
      (l) {
        if (ErrorManager.shouldRetry('addCustomerAddress', l.statusCode)) {
          ErrorManager.incrementRetry('addCustomerAddress');
          add(
            AddAddressInfoClassEvent(
              addressInfoClassToSave: event.addressInfoClassToSave,
            ),
          );
          return; // لا تعرض رسالة ولا تحدث الحالة
        }
        // فقط بعد انتهاء المحاولات
        showMessage(
          l.message,
          foreGroundColor: Colors.white,
          hasError: true,
          backGroundColor: Colors.black,
          showInRelease: true,
        );
        final List<CustomerAddressesInfo> listOfAddressInfoClassToSave =
            List.of(state.listOfAddressInfoClassToSave ?? []);
        listOfAddressInfoClassToSave.removeAt(0);
        emit(
          state.copyWith(
            listOfAdressInfoClassToSave: listOfAddressInfoClassToSave,
            addAddressToOrderStatus: AddAddressToOrderStatus.failure,
          ),
        );
      },
      (r) async {
        GetIt.I<HomeBloc>().add(GetCartOverviewEvent());
        add(GetCustomerAddressesEvent());
        showMessage(
          r.message ?? "",
          foreGroundColor: Colors.white,
          backGroundColor: Colors.black,
          showInRelease: true,
        );
        ErrorManager.resetRetry('addCustomerAddress');

        emit(
          state.copyWith(
            lastAdressInfoClassToSave: CustomerAddressesInfo(),
            addAddressToOrderStatus: AddAddressToOrderStatus.success,
            listOfAdressInfoClassToSave: listOfAddressInfoClassToSave,
          ),
        );
      },
    );
  }

  FutureOr<void> _onEditAdressInfoClassEvent(
    EditAdressInfoClassEvent event,
    Emitter<OrderState> emit,
  ) async {
    final List<CustomerAddressesInfo> listOfAddressInfoClassToSave = List.of(
      state.listOfAddressInfoClassToSave ?? [],
    );

    int index = listOfAddressInfoClassToSave.indexWhere(
      (element) => element.id == event.preIdToEdit,
    );
    CustomerAddressesInfo preCustomerAddresses =
        listOfAddressInfoClassToSave[index];
    listOfAddressInfoClassToSave.removeWhere(
      (element) => element.id == event.preIdToEdit,
    );

    listOfAddressInfoClassToSave.insert(index, event.addressInfoClassToSave!);
    emit(
      state.copyWith(
        listOfAdressInfoClassToSave: listOfAddressInfoClassToSave,
        editAddressToOrderStatus: EditAddressToOrderStatus.loading,
      ),
    );
    final response = await updateCustomerAddressUseCase(
      UpdateCustomerAddressParams(
        iso:
            (prefsRepository.userCountryIsAvailable == 1
                ? prefsRepository.userChoosedCountryIso
                : prefsRepository.countryIso) ??
            "",
        id: event.preIdToEdit,
        address: event.addressInfoClassToSave?.address ?? "",
        addressDetail: event.addressInfoClassToSave?.addressDetail ?? "",
        country: event.addressInfoClassToSave?.regionDetails?.country ?? "",
        city: event.addressInfoClassToSave?.regionDetails?.city ?? "",
        district: event.addressInfoClassToSave?.regionDetails?.city ?? "",
        town: event.addressInfoClassToSave?.regionDetails?.town ?? "",
        street: event.addressInfoClassToSave?.regionDetails?.street ?? "",
        zip: event.addressInfoClassToSave?.regionDetails?.zip ?? '',
        phone: event.addressInfoClassToSave?.contactInfo?.phone ?? "",
        alternativePhone:
            event.addressInfoClassToSave?.contactInfo?.alternativePhone ?? "",
        latitude: event.addressInfoClassToSave?.location?.latitude ?? "",
        longitude: event.addressInfoClassToSave?.location?.longitude ?? "",
        province: event.addressInfoClassToSave?.regionDetails?.province ?? "",
        building: event.addressInfoClassToSave?.regionDetails?.building ?? "",
        contactPersonName:
            event.addressInfoClassToSave?.contactInfo?.name ?? "",
      ),
    );

    response.fold(
      (l) {
        if (ErrorManager.shouldRetry('updateCustomerAddress', l.statusCode)) {
          ErrorManager.incrementRetry('updateCustomerAddress');
          add(
            EditAdressInfoClassEvent(
              addressInfoClassToSave: event.addressInfoClassToSave,
              preIdToEdit: event.preIdToEdit,
            ),
          );
          return; // لا تعرض رسالة ولا تحدث الحالة
        }
        // فقط بعد انتهاء المحاولات
        showMessage(
          l.message,
          foreGroundColor: Colors.white,
          backGroundColor: Colors.black,
          hasError: true,
          showInRelease: true,
        );
        final List<CustomerAddressesInfo> listOfAddressInfoClassToSave =
            List.of(state.listOfAddressInfoClassToSave ?? []);
        listOfAddressInfoClassToSave.insert(index, preCustomerAddresses);
        emit(
          state.copyWith(
            listOfAdressInfoClassToSave: listOfAddressInfoClassToSave,
            editAddressToOrderStatus: EditAddressToOrderStatus.failure,
          ),
        );
      },
      (r) async {
        add(GetCustomerAddressesEvent());
        showMessage(
          r.message ?? "",
          foreGroundColor: Colors.white,
          backGroundColor: Colors.black,
          showInRelease: true,
        );
        ErrorManager.resetRetry('updateCustomerAddress');

        emit(
          state.copyWith(
            editAddressToOrderStatus: EditAddressToOrderStatus.success,
            listOfAdressInfoClassToSave: listOfAddressInfoClassToSave,
          ),
        );
      },
    );
  }

  FutureOr<void> _onGetAddressByCoordinatesEvent(
    GetAddressByCoordinatesEvent event,
    Emitter<OrderState> emit,
  ) async {
    if (event.latitude == 0 && event.longitude == 0) {
      return;
    }
    ///////////////////////////
    emit(
      state.copyWith(
        getAddressByCoordinatesStatus: GetAddressByCoordinatesStatus.loading,
      ),
    );

    final response = await getAddressByCoordinatesUsecase(
      GetAddressByCoordinatesParams(
        latitude: event.latitude,
        longitude: event.longitude,
      ),
    );

    response.fold(
      (l) {
        if (ErrorManager.shouldRetry(
          'GetAddressByCoordinatesEvent',
          l.statusCode,
        )) {
          ErrorManager.incrementRetry('GetAddressByCoordinatesEvent');
        }
        emit(
          state.copyWith(
            getAddressByCoordinatesStatus:
                GetAddressByCoordinatesStatus.failure,
          ),
        );
      },
      (r) {
        ErrorManager.resetRetry('GetAddressByCoordinatesEvent');
        emit(
          state.copyWith(
            getAddressByCoordinatesStatus:
                GetAddressByCoordinatesStatus.success,
            getAddressByCoordinatesModel: r,
          ),
        );
      },
    );
    await Future.delayed(const Duration(seconds: 5), () {
      emit(
        state.copyWith(
          getAddressByCoordinatesStatus: GetAddressByCoordinatesStatus.failure,
        ),
      );
    });
  }

  FutureOr<void> _onGetAddressByTextEvent(
    GetAddressByTextEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(
      state.copyWith(getAddressByTextStatus: GetAddressByTextStatus.loading),
    );
    if (event.reset) {
      emit(
        state.copyWith(
          getAddressByTextStatus: GetAddressByTextStatus.success,
          resultSearch: [],
        ),
      );
      return;
    }
    final response = await getAddressByTextUsecase(
      GetAddressByTextParams(query: event.query),
    );

    response.fold(
      (l) {
        if (ErrorManager.shouldRetry('GetAddressByTextEvent', l.statusCode)) {
          ErrorManager.incrementRetry('GetAddressByTextEvent');
        }
        emit(
          state.copyWith(
            getAddressByTextStatus: GetAddressByTextStatus.failure,
          ),
        );
      },
      (r) {
        ErrorManager.resetRetry('GetAddressByTextEvent');

        emit(
          state.copyWith(
            resultSearch: r.results,
            getAddressByTextStatus: GetAddressByTextStatus.success,
          ),
        );
      },
    );
  }

  Future<void> _onSetCurrentAddressChoosedEvent(
    SetCurrentAddressChoosedEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWith(currentAddressChoosed: event.index));
  }

  FutureOr<void> _onApplyCouponEvent(
    ApplyCouponEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWith(applyCouponStatus: ApplyCouponStatus.loading));
    final response = await applyCouponUsecase(event.code);
    response.fold(
      (l) {
        if (ErrorManager.shouldRetry('ApplyCouponEvent', l.statusCode)) {
          ErrorManager.incrementRetry('ApplyCouponEvent');
          add(ApplyCouponEvent(code: event.code));
          return; // لا تعرض رسالة ولا تحدث الحالة
        }
        // فقط بعد انتهاء المحاولات
        emit(state.copyWith(applyCouponStatus: ApplyCouponStatus.failure));
      },
      (r) {
        ErrorManager.resetRetry('ApplyCouponEvent');
        var data = r.data;

        if (data!.status == 0) {
          emit(
            state.copyWith(
              applyCouponStatus: ApplyCouponStatus.failure,
              applyCouponModel: r,
            ),
          );
          showMessage(
            r.message ?? 'invalid',
            foreGroundColor: Colors.white,
            backGroundColor: Colors.black,
            showInRelease: true,
          );
        } else {
          debugPrint('ApplyCouponEvent success');
          emit(
            state.copyWith(
              applyCouponStatus: ApplyCouponStatus.success,
              applyCouponModel: r,
            ),
          );
          showMessage(
            r.message ?? 'Success',
            foreGroundColor: Colors.white,
            backGroundColor: Colors.black,
            showInRelease: true,
          );
        }
      },
    );
  }

  FutureOr<void> _onCancelOrderItemEvent(
    CancelOrderItemEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWith(cancelOrderItemStatus: CancelOrderItemStatus.loading));
    final response = await cancelOrderItemUsecase(event.cancelOrderItemParams);
    response.fold(
      (l) {
        if (ErrorManager.shouldRetry('CancelOrderItemEvent', l.statusCode)) {
          ErrorManager.incrementRetry('CancelOrderItemEvent');
          add(
            CancelOrderItemEvent(
              cancelOrderItemParams: event.cancelOrderItemParams,
            ),
          );
          return; // لا تعرض رسالة ولا تحدث الحالة
        }
        // فقط بعد انتهاء المحاولات
        emit(
          state.copyWith(cancelOrderItemStatus: CancelOrderItemStatus.failure),
        );
        showMessage(
          l.message,
          foreGroundColor: Colors.white,
          backGroundColor: Colors.red,
          showInRelease: true,
        );
      },
      (r) async {
        ErrorManager.resetRetry('CancelOrderItemEvent');
        debugPrint('CancelOrderItemStatus success');
        showMessage(
          r.message ?? 'تم إلغاء العنصر بنجاح',
          foreGroundColor: Colors.white,
          backGroundColor: Colors.black,
          showInRelease: true,
        );
        emit(
          state.copyWith(cancelOrderItemStatus: CancelOrderItemStatus.success),
        );
      },
    );
  }

  FutureOr<void> _onCancelOrderEvent(
    CancelOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWith(cancelOrderStatus: CancelOrderStatus.loading));
    final response = await cancelOrderUsecase(event.cancelOrderParams);
    response.fold(
      (l) {
        if (ErrorManager.shouldRetry('CancelOrderEvent', l.statusCode)) {
          ErrorManager.incrementRetry('CancelOrderEvent');
          add(CancelOrderEvent(cancelOrderParams: event.cancelOrderParams));
          return; // لا تعرض رسالة ولا تحدث الحالة
        }
        // فقط بعد انتهاء المحاولات
        emit(state.copyWith(cancelOrderStatus: CancelOrderStatus.failure));
      },
      (r) async {
        ErrorManager.resetRetry('CancelOrderEvent');
        debugPrint('CancelOrderStatus success');
        showMessage(
          r.message ?? 'تم إلغاء الطلب بنجاح',
          foreGroundColor: Colors.white,
          backGroundColor: Colors.black,
          showInRelease: true,
        );
        emit(state.copyWith(cancelOrderStatus: CancelOrderStatus.success));
      },
    );
  }

  FutureOr<void> _onChangeOrderAddressEvent(
    ChangeOrderAddressEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(
      state.copyWith(
        changeOrderAddressStatus: ChangeOrderAddressStatus.loading,
      ),
    );
    final response = await changeOrderAddressUsecase(
      event.changeOrderAddressParams,
    );
    response.fold(
      (l) {
        if (ErrorManager.shouldRetry('ChangeOrderAddressEvent', l.statusCode)) {
          ErrorManager.incrementRetry('ChangeOrderAddressEvent');
          add(
            ChangeOrderAddressEvent(
              changeOrderAddressParams: event.changeOrderAddressParams,
            ),
          );
          return; // لا تعرض رسالة ولا تحدث الحالة
        }
        // فقط بعد انتهاء المحاولات
        emit(
          state.copyWith(
            changeOrderAddressStatus: ChangeOrderAddressStatus.failure,
          ),
        );
        showMessage(
          l.message,
          foreGroundColor: Colors.white,
          backGroundColor: Colors.red,
          showInRelease: true,
        );
      },
      (r) async {
        ErrorManager.resetRetry('ChangeOrderAddressEvent');
        debugPrint('ChangeOrderAddressStatus success');
        showMessage(
          r.message ?? 'تم تغيير العنوان بنجاح',
          foreGroundColor: Colors.white,
          backGroundColor: Colors.black,
          showInRelease: true,
        );
        emit(
          state.copyWith(
            changeOrderAddressStatus: ChangeOrderAddressStatus.success,
          ),
        );
      },
    );
  }

  FutureOr<void> _onGetProductColorSizeSyncAttributeEvent(
    GetProductColorSizeSyncAttributeEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(
      state.copyWith(
        getProductColorSizeSyncAttributeStatus:
            GetProductColorSizeSyncAttributeStatus.loading,
      ),
    );
    final response = await getProductColorSizeSyncAttributeUseCase(event.id);
    response.fold(
      (l) {
        if (ErrorManager.shouldRetry(
          'GetProductColorSizeSyncAttributeEvent',
          l.statusCode,
        )) {
          ErrorManager.incrementRetry('GetProductColorSizeSyncAttributeEvent');
          add(GetProductColorSizeSyncAttributeEvent(id: event.id));
          return; // لا تعرض رسالة ولا تحدث الحالة
        }
        // فقط بعد انتهاء المحاولات
        emit(
          state.copyWith(
            getProductColorSizeSyncAttributeStatus:
                GetProductColorSizeSyncAttributeStatus.failure,
          ),
        );
      },
      (r) async {
        ErrorManager.resetRetry('GetProductColorSizeSyncAttributeEvent');
        debugPrint('GetProductColorSizeSyncAttributeStatus success');
        emit(
          state.copyWith(
            getProductColorSizeSyncAttributeStatus:
                GetProductColorSizeSyncAttributeStatus.success,
            colorSizeForProductModel: r,
          ),
        );
      },
    );
  }

  Future<void> _onChangeOrderItemVariantEvent(
    ChangeOrderItemVariantEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(
      state.copyWith(
        changeOrderItemVariantStatus: ChangeOrderItemVariantStatus.loading,
      ),
    );
    final result = await changeOrderItemVariantUsecase(event.params);
    result.fold(
      (failure) {
        if (ErrorManager.shouldRetry(
          'ChangeOrderItemVariantEvent',
          failure.statusCode,
        )) {
          ErrorManager.incrementRetry('ChangeOrderItemVariantEvent');
          add(ChangeOrderItemVariantEvent(params: event.params));
          return; // لا تعرض رسالة ولا تحدث الحالة
        }
        // فقط بعد انتهاء المحاولات
        emit(
          state.copyWith(
            changeOrderItemVariantStatus: ChangeOrderItemVariantStatus.failure,
          ),
        );
      },
      (response) {
        ErrorManager.resetRetry('ChangeOrderItemVariantEvent');
        showMessage(
          response.message ?? "",
          foreGroundColor: Colors.white,
          backGroundColor: Colors.black,
          showInRelease: true,
        );
        emit(
          state.copyWith(
            changeOrderItemVariantStatus: ChangeOrderItemVariantStatus.success,
          ),
        );
      },
    );
  }

  /* Future<void> _onAddOrderCommentEvent(
      AddOrderCommentEvent event, Emitter<OrderState> emit) async {
    emit(state.copyWith(addOrderCommentStatus: AddOrderCommentStatus.loading));
    final result = await addOrderCommentUseCase(event.params);
    result.fold(
      (failure) {
        if (ErrorManager.shouldRetry(
            'AddOrderCommentEvent', failure.statusCode)) {
          ErrorManager.incrementRetry('AddOrderCommentEvent');
          add(AddOrderCommentEvent(params: event.params));
          return; // لا تعرض رسالة ولا تحدث الحالة
        }
        // فقط بعد انتهاء المحاولات
        emit(state.copyWith(
            addOrderCommentStatus: AddOrderCommentStatus.failure));
      },
      (response) {
        ErrorManager.resetRetry('AddOrderCommentEvent');
        showMessage(
          response.message ?? 'تم إضافة التقييم بنجاح',
          foreGroundColor: Colors.white,
          backGroundColor: Colors.black,
          showInRelease: true,
        );
        emit(state.copyWith(
            addOrderCommentStatus: AddOrderCommentStatus.success));
      },
    );
  }
*/
  /* Future<void> _onUpdateOrderCommentEvent(
      UpdateOrderCommentEvent event, Emitter<OrderState> emit) async {
    emit(state.copyWith(
        updateOrderCommentStatus: UpdateOrderCommentStatus.loading));
    final result = await updateOrderCommentUseCase(event.params);
    result.fold(
      (failure) {
        if (ErrorManager.shouldRetry(
            'UpdateOrderCommentEvent', failure.statusCode)) {
          ErrorManager.incrementRetry('UpdateOrderCommentEvent');
          add(UpdateOrderCommentEvent(params: event.params));
          return; // لا تعرض رسالة ولا تحدث الحالة
        }
        // فقط بعد انتهاء المحاولات
        emit(state.copyWith(
            updateOrderCommentStatus: UpdateOrderCommentStatus.failure));
      },
      (response) {
        ErrorManager.resetRetry('UpdateOrderCommentEvent');
        showMessage(
          response.message ?? 'تم تعديل التقييم بنجاح',
          foreGroundColor: Colors.white,
          backGroundColor: Colors.black,
          showInRelease: true,
        );
        emit(state.copyWith(
          updateOrderCommentStatus: UpdateOrderCommentStatus.success,
        ));
      },
    );
  }
*/
  Future<void> _onGetReturnReasonsEvent(
    GetReturnReasonsEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(
      state.copyWith(getReturnReasonsStatus: GetReturnReasonsStatus.loading),
    );
    final result = await getReturnReasonsUseCase(NoParams());
    result.fold(
      (failure) {
        if (ErrorManager.shouldRetry(
          'GetReturnReasonsEvent',
          failure.statusCode,
        )) {
          ErrorManager.incrementRetry('GetReturnReasonsEvent');
          add(const GetReturnReasonsEvent());
          return;
        }
        emit(
          state.copyWith(
            getReturnReasonsStatus: GetReturnReasonsStatus.failure,
          ),
        );
      },
      (response) {
        ErrorManager.resetRetry('GetReturnReasonsEvent');
        emit(
          state.copyWith(
            getReturnReasonsStatus: GetReturnReasonsStatus.success,
            returnReasonsModel: response,
          ),
        );
      },
    );
  }

  Future<void> _onStoreReturnRequestProductEvent(
    StoreReturnRequestProductEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(
      state.copyWith(
        storeReturnRequestProductStatus:
            StoreReturnRequestProductStatus.loading,
      ),
    );
    final result = await storeReturnRequestProductUseCase(event.params);
    result.fold(
      (failure) {
        if (ErrorManager.shouldRetry(
          'StoreReturnRequestProductEvent',
          failure.statusCode,
        )) {
          ErrorManager.incrementRetry('StoreReturnRequestProductEvent');
          add(
            StoreReturnRequestProductEvent(
              orderGroupId: event.orderGroupId,
              params: event.params,
              withConfirm: event.withConfirm,
              returnRequestId: event.returnRequestId,
            ),
          );
          return;
        }
        showMessage(failure.message, hasError: true);
        emit(
          state.copyWith(
            storeReturnRequestProductStatus:
                StoreReturnRequestProductStatus.failure,
          ),
        );
      },
      (response) {
        ErrorManager.resetRetry('StoreReturnRequestProductEvent');
        if (event.withConfirm) {
          showMessage(response.message ?? "");
          add(
            ConfirmReturnRequestEvent(
              orderGroupId: event.orderGroupId,
              returnRequestId: event.returnRequestId,
            ),
          );
        } else {
          add(FetchOrderReturnDetailsEvent(event.orderGroupId));
          showMessage(response.message ?? "");
        }
        emit(
          state.copyWith(
            storeReturnRequestProductStatus:
                StoreReturnRequestProductStatus.success,
          ),
        );
      },
    );
  }

  //////////////////////////////////////////////////////////
  Future<void> _onUpdateReturnRequestProductEvent(
    UpdateReturnRequestProductEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(
      state.copyWith(
        updateReturnRequestProductStatus:
            UpdateReturnRequestProductStatus.loading,
      ),
    );
    final result = await updateReturnRequestProductUseCase(event.params);
    result.fold(
      (failure) {
        if (ErrorManager.shouldRetry(
          'UpdateReturnRequestProductEvent',
          failure.statusCode,
        )) {
          ErrorManager.incrementRetry('UpdateReturnRequestProductEvent');
          add(
            UpdateReturnRequestProductEvent(
              orderGroupId: event.orderGroupId,
              params: event.params,
              withConfirm: event.withConfirm,
              returnRequestId: event.returnRequestId,
            ),
          );
          return;
        }
        showMessage(failure.message, hasError: true);
        emit(
          state.copyWith(
            updateReturnRequestProductStatus:
                UpdateReturnRequestProductStatus.failure,
          ),
        );
      },
      (response) {
        ErrorManager.resetRetry('UpdateReturnRequestProductEvent');
        if (event.withConfirm) {
          add(
            ConfirmReturnRequestEvent(
              orderGroupId: event.orderGroupId,
              returnRequestId: event.returnRequestId,
            ),
          );
        } else {
          add(FetchOrderReturnDetailsEvent(event.orderGroupId));
          showMessage(response.message ?? "");
        }
        emit(
          state.copyWith(
            updateReturnRequestProductStatus:
                UpdateReturnRequestProductStatus.success,
          ),
        );
      },
    );
  }

  ///
  Future<void> _onStoreReturnRequestEvent(
    StoreReturnRequestEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(
      state.copyWith(
        cancelReturnRequestProductStatus: CancelReturnRequestProductStatus.init,
        cancelReturnRequestStatus: CancelReturnRequestStatus.init,
        confirmReturnRequestStatus: ConfirmReturnRequestStatus.init,
        changeOrderItemVariantStatus: ChangeOrderItemVariantStatus.init,
        changeOrderAddressStatus: ChangeOrderAddressStatus.init,
        storeReturnRequestProductStatus: StoreReturnRequestProductStatus.init,
        orderReturnDetailsStatus: OrderReturnDetailsStatus.init,
        updateReturnRequestProductStatus: UpdateReturnRequestProductStatus.init,
        storeReturnRequestStatus: StoreReturnRequestStatus.loading,
      ),
    );
    final result = await storeReturnRequestUseCase(event.params);
    result.fold(
      (failure) {
        if (ErrorManager.shouldRetry(
          'StoreReturnRequestEvent',
          failure.statusCode,
        )) {
          ErrorManager.incrementRetry('StoreReturnRequestEvent');
          add(
            StoreReturnRequestEvent(
              params: event.params,
              orderGroupId: event.orderGroupId,
            ),
          );
          return;
        }
        emit(
          state.copyWith(
            storeReturnRequestStatus: StoreReturnRequestStatus.failure,
          ),
        );
      },
      (response) {
        add(FetchOrderReturnDetailsEvent(event.orderGroupId));
        ErrorManager.resetRetry('StoreReturnRequestEvent');
        emit(
          state.copyWith(
            storeReturnRequestStatus: StoreReturnRequestStatus.success,
          ),
        );
      },
    );
  }

  ///

  @override
  OrderState? fromJson(Map<String, dynamic> json) {
    return OrderState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(OrderState state) {
    return state
        .copyWith(
          placeOrderStatus: PlaceOrderStatus.init,
          getOrdersModel: {},
          cancelReturnRequestProductStatus:
              CancelReturnRequestProductStatus.init,
          cancelReturnRequestStatus: CancelReturnRequestStatus.init,
          confirmReturnRequestStatus: ConfirmReturnRequestStatus.init,
          storeReturnRequestProductStatus: StoreReturnRequestProductStatus.init,
          orderReturnDetailsStatus: OrderReturnDetailsStatus.init,
          updateReturnRequestProductStatus:
              UpdateReturnRequestProductStatus.init,
          uploadImagesToCloudinaryStatus: UploadImagesToCloudinaryStatus.init,
          uploadImagesForReturnProductStatus:
              UploadImagesForReturnProductStatus.init,
          getOrdersByCartGroupIDStatus: GetOrdersByCartGroupIDStatus.init,
          applyCouponStatus: ApplyCouponStatus.init,
          cancelOrderItemStatus: CancelOrderItemStatus.init,
          cancelOrderStatus: CancelOrderStatus.init,
        )
        .toJson();
  }

  //////////////////////////////////////////////////////////
  Future<void> _onOrderReturnRequestsViewEvent(
    OrderReturnRequestsViewEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(
      state.copyWith(
        orderReturnRequestsViewStatus: OrderReturnRequestsViewStatus.loading,
      ),
    );
    final result = await orderReturnRequestsViewUseCase(event.params);
    result.fold(
      (failure) {
        if (ErrorManager.shouldRetry(
          'OrderReturnRequestsViewEvent',
          failure.statusCode,
        )) {
          ErrorManager.incrementRetry('OrderReturnRequestsViewEvent');
          add(OrderReturnRequestsViewEvent(params: event.params));
          return;
        }
        emit(
          state.copyWith(
            orderReturnRequestsViewStatus:
                OrderReturnRequestsViewStatus.failure,
          ),
        );
      },
      (response) {
        ErrorManager.resetRetry('OrderReturnRequestsViewEvent');
        emit(
          state.copyWith(
            orderReturnRequestsViewStatus:
                OrderReturnRequestsViewStatus.success,
          ),
        );
      },
    );
  }

  FutureOr<void> _onUploadImagesForReturnProductEvent(
    UploadImagesForReturnProductEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(
      state.copyWith(
        uploadImagesForReturnProductStatus:
            UploadImagesForReturnProductStatus.loading,
      ),
    );
    final result = await uploadImagesProductReturnUseCase(
      UpdateImagesForReturnProductParams(
        path: "return_request_products/",
        image: event.file,
      ),
    );
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            uploadImagesForReturnProductStatus:
                UploadImagesForReturnProductStatus.failure,
          ),
        );
      },
      (response) {
        List<String> imagesForReturns = List.of(state.imagesForReturn ?? []);
        imagesForReturns.add(response.data?.subPath ?? "");
        emit(
          state.copyWith(
            imagesForReturn: imagesForReturns,
            uploadImagesForReturnProductStatus:
                UploadImagesForReturnProductStatus.success,
          ),
        );
      },
    );
  }

  ///
  ///
  ///
  /// //////////////////////////////////////////////////////////
  Future<void> _onConfirmReturnRequestEvent(
    ConfirmReturnRequestEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(
      state.copyWith(
        confirmReturnRequestStatus: ConfirmReturnRequestStatus.loading,
      ),
    );
    final result = await confirmReturnRequestUseCase(
      ConfirmReturnRequestParams(returnRequestId: event.returnRequestId),
    );
    result.fold(
      (failure) {
        if (ErrorManager.shouldRetry(
          'ConfirmReturnRequestEvent',
          failure.statusCode,
        )) {
          ErrorManager.incrementRetry('ConfirmReturnRequestEvent');
          add(
            ConfirmReturnRequestEvent(
              orderGroupId: event.orderGroupId,
              returnRequestId: event.returnRequestId,
            ),
          );
          return;
        }
        showMessage(failure.message, hasError: true);
        emit(
          state.copyWith(
            confirmReturnRequestStatus: ConfirmReturnRequestStatus.failure,
          ),
        );
      },
      (response) {
        add(FetchOrderReturnDetailsEvent(event.orderGroupId));
        add(GetOrdersByOrderGroupIDEvent(orderGroupId: event.orderGroupId));
        showMessage(response.message ?? "");
        ErrorManager.resetRetry('ConfirmReturnRequestEvent');
        emit(
          state.copyWith(
            confirmReturnRequestStatus: ConfirmReturnRequestStatus.success,
          ),
        );
      },
    );
  }

  ///
  FutureOr<void> _onFetchOrderReturnDetailsEvent(
    FetchOrderReturnDetailsEvent event,
    Emitter<OrderState> emit,
  ) async {
    if (event.notFound) {
      emit(
        state.copyWith(
          orderReturnDetailsStatus: OrderReturnDetailsStatus.success,
          orderReturnDetailsModel: GetOrderReturntDetailsModel(
            data: Data(returnRequestsData: []),
          ),
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        orderReturnDetailsStatus: OrderReturnDetailsStatus.loading,
        orderReturnDetailsModel: GetOrderReturntDetailsModel(
          data: Data(returnRequestsData: []),
        ),
      ),
    );
    final response = await orderReturnDetailsUseCase(
      GetOrderReturntDetailsParams(orderGroupId: event.orderGroupId.toString()),
    );
    response.fold(
      (failure) {
        if (ErrorManager.shouldRetry(
          'FetchOrderReturnDetailsEvent',
          failure.statusCode,
        )) {
          ErrorManager.incrementRetry('FetchOrderReturnDetailsEvent');
          add(FetchOrderReturnDetailsEvent(event.orderGroupId));

          return;
        }
        if (failure.statusCode == 400) {
          emit(
            state.copyWith(
              orderReturnDetailsStatus: OrderReturnDetailsStatus.failure,
            ),
          );
          return;
        }
        emit(
          state.copyWith(
            orderReturnDetailsStatus: OrderReturnDetailsStatus.failure,
          ),
        );
      },
      (details) {
        ErrorManager.resetRetry('FetchOrderReturnDetailsEvent');
        emit(
          state.copyWith(
            orderReturnDetailsStatus: OrderReturnDetailsStatus.success,
            orderReturnDetailsModel: details,
          ),
        );
      },
    );
  }
}
