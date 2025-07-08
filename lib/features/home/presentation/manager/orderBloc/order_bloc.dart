import 'dart:async';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/home/domain/use_cases/get_provinces_by_iso_usecase.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/main.dart';
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
import '../../../domain/use_cases/set_customer_address_default_usecase.dart';
import '../../../domain/use_cases/update_customer_address_usecase.dart';
import '../../widgets/cart_section/payment_method.dart';
import 'order_event.dart';
import 'order_state.dart';

@LazySingleton()
class OrderBloc extends HydratedBloc<OrderEvent, OrderState> {
  final PlaceOrderUsecase placeOrderUsecase;
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

  OrderBloc(
    this.placeOrderUsecase,
    this.getOrdersByOrderGroupIDUsecase,
    this.getOrdersByCartGroupIDUsecase,
    this.getProvincesByIsoUseCase,
    this.getCustomerWalletUseCase,
    this.getOrdersUseCase,
    this.setCustomerAddressDefaultUseCase,
    this.getCustomerAddressesUseCase,
    this.deleteCustomerAddressUseCase,
    this.addCustomerAddressUseCase,
    this.updateCustomerAddressUseCase,
    this.getAddressByCoordinatesUsecase,
    this.getAddressByTextUsecase,
    this.applyCouponUsecase,
  ) : super(OrderState()) {
    on<PlaceOrderEvent>(
      _onPlaceOrderEvent,
    );
    on<GetOrdersByOrderGroupIDEvent>(
      _onGetOrdersByOrderGroupIDEvent,
    );

    on<SaveLastAddress>(
      _onSaveLastAddress,
    );
    on<GetOrdersByCartGroupIDEvent>(
      _onGetOrdersByCartGroupIDEvent,
    );

    on<SaveCurrentOrederStatusEvent>(
      _onSaveCurrentOrederStatusEvent,
    );
    on<GetCustomerWalletEvent>(
      _onGetCustomerWalletEvent,
    );
    on<GetProvincesByIsoEvent>(
      _onGetProvincesByIsoEvent,
    );
    on<GetOrdersEvent>(
      _onGetOrdersEvent,
    );
    on<ChangeOrderByGroupStatus>(
      _onChangeOrderByGroupStatus,
    );

    on<SetCustomerAddressDefaultEvent>(
      _onSetCustomerAddressDefaultEvent,
      transformer: restartable(),
    );
    on<GetCustomerAddressesEvent>(
      _onGetCustomerAddressesEvent,
    );
    on<DeleteAdressInfoClassEvent>(
      _onDeleteAdressInfoClassEvent,
    );
    on<AddAddressInfoClassEvent>(
      _onAddAddressInfoClassEvent,
    );
    on<EditAdressInfoClassEvent>(
      _onEditAdressInfoClassEvent,
    );
    on<GetAddressByCoordinatesEvent>(
      _onGetAddressByCoordinatesEvent,
    );
    on<GetAddressByTextEvent>(
      _onGetAddressByTextEvent,
      transformer: restartable(),
    );
    on<SetCurrentAddressChoosedEvent>(
      _onSetCurrentAddressChoosedEvent,
    );
    on<ApplyCouponEvent>(
      _onApplyCouponEvent,
    );
  }

  FutureOr<void> _onPlaceOrderEvent(
    PlaceOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    debugPrint(event.placeOrderParams.paymentMethod);
    debugPrint(event.placeOrderParams.addressId.toString());
    debugPrint(event.placeOrderParams.payByWallet.toString());
    ///////////////////////////
    emit(
      state.copyWith(
        placeOrderStatus: PlaceOrderStatus.loading,
      ),
    );

    final response = await placeOrderUsecase(
      event.placeOrderParams,
    );

    response.fold(
      (l) {
        if (l.statusCode == 403) {
          emit(
            state.copyWith(
              placeOrderStatus: PlaceOrderStatus.unavailable,
            ),
          );
        } else {
          if (!isFailedTheFirstTime.contains('PlaceOrderEvent')) {
            add(
              PlaceOrderEvent(placeOrderParams: event.placeOrderParams),
            );
            isFailedTheFirstTime.add('PlaceOrderEvent');
          }
          emit(
            state.copyWith(
              placeOrderStatus: PlaceOrderStatus.failure,
            ),
          );
        }
      },
      (r) async {
        isFailedTheFirstTime.remove('PlaceOrderEvent');

        debugPrint('PlaceOrderStatus success');

        debugPrint('orders length : ${r.data!.length}');
        List<String> getNotificationIdsToRemoveAfterplaceOrder =
            prefsRepository.getNotificationIdsToRemoveAfterplaceOrder ?? [];
        getNotificationIdsToRemoveAfterplaceOrder.forEach((element) {
          try {
            LocalNotificationService.localNotificationPlugin
                .cancel(int.tryParse(element) ?? 0);
          } catch (e) {}
        });
        prefsRepository.removeNotificationIdsToRemoveAfterplaceOrder();
        ////////////////////////////
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
    ///////////////////////////
    emit(
      state.copyWith(
        getOrdersByOrderGroupIDModel: null,
        getOrdersByOrderGroupIDStatus: GetOrdersByOrderGroupIDStatus.loading,
      ),
    );

    final response = await getOrdersByOrderGroupIDUsecase(
      event.orderGroupId,
    );

    response.fold(
      (l) {
        if (!isFailedTheFirstTime.contains('GetOrdersByOrderGroupIDEvent')) {
          add(
            GetOrdersByOrderGroupIDEvent(orderGroupId: event.orderGroupId),
          );
          isFailedTheFirstTime.add('GetOrdersByOrderGroupIDEvent');
        }

        emit(
          state.copyWith(
            getOrdersByOrderGroupIDStatus:
                GetOrdersByOrderGroupIDStatus.failure,
          ),
        );
      },
      (r) {
        isFailedTheFirstTime.remove('GetOrdersByOrderGroupIDEvent');

        debugPrint('GetOrdersByOrderGroupIDEvent success');

        debugPrint('orders length : ${r.data!.length}');
        ////////////////////////////
        emit(
          state.copyWith(
            getOrdersByOrderGroupIDStatus:
                GetOrdersByOrderGroupIDStatus.success,
            getOrdersByOrderGroupIDModel: r,
          ),
        );
      },
    );
  }

  FutureOr<void> _onGetOrdersByCartGroupIDEvent(
    GetOrdersByCartGroupIDEvent event,
    Emitter<OrderState> emit,
  ) async {
    ///////////////////////////
    emit(
      state.copyWith(
        getOrdersByCartGroupIDStatus: GetOrdersByCartGroupIDStatus.loading,
      ),
    );

    final response = await getOrdersByCartGroupIDUsecase(
      event.cartGroupId,
    );

    response.fold(
      (l) {
        if (!isFailedTheFirstTime.contains('GetOrdersByCartGroupIDEvent') &&
            l.statusCode != 400) {
          add(
            GetOrdersByCartGroupIDEvent(cartGroupId: event.cartGroupId),
          );
          isFailedTheFirstTime.add('GetOrdersByCartGroupIDEvent');
        }

        emit(
          state.copyWith(
            getOrdersByCartGroupIDStatus: GetOrdersByCartGroupIDStatus.failure,
          ),
        );
      },
      (r) {
        isFailedTheFirstTime.remove('GetOrdersByCartGroupIDEvent');

        debugPrint('GetOrdersByCartGroupIDEvent success');

        debugPrint('orders length : ${r.data!.length}');
        ////////////////////////////
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
    ///////////////////////////

    final response = await getProvincesByIsoUseCase.call(NoParams());

    response.fold(
      (l) {
        if (!isFailedTheFirstTime.contains('GetProvincesByIsoEvent')) {
          add(
            GetProvincesByIsoEvent(),
          );
          isFailedTheFirstTime.add('GetProvincesByIsoEvent');
          return;
        }
      },
      (r) {
        isFailedTheFirstTime.remove('GetProvincesByIsoEvent');

        emit(
          state.copyWith(
            provincesByIso: r.data,
          ),
        );
      },
    );
  }

  FutureOr<void> _onGetCustomerWalletEvent(
    GetCustomerWalletEvent event,
    Emitter<OrderState> emit,
  ) async {
    ///////////////////////////
    emit(
      state.copyWith(
        getCustomerWalletStatus: GetCustomerWalletStatus.loading,
      ),
    );

    final response = await getCustomerWalletUseCase.call(
      CustomerWalletParams(limit: event.limit, offset: event.offset),
    );

    response.fold(
      (l) {
        if (!isFailedTheFirstTime.contains('GetCustomerWalletEvent')) {
          add(
            GetCustomerWalletEvent(limit: event.limit, offset: event.offset),
          );
          isFailedTheFirstTime.add('GetCustomerWalletEvent');
          return;
        }
        emit(
          state.copyWith(
            getCustomerWalletStatus: GetCustomerWalletStatus.failure,
          ),
        );
      },
      (r) {
        isFailedTheFirstTime.remove('GetCustomerWalletEvent');

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
    emit(
      state.copyWith(
        lastAdressInfoClassToSave: event.lastAddress,
      ),
    );
  }

  FutureOr<void> _onSaveCurrentOrederStatusEvent(
    SaveCurrentOrederStatusEvent event,
    Emitter<OrderState> emit,
  ) async {
    ///////////////////////////
    emit(
      state.copyWith(
        currentOrederStatus: event.currentOrederStatus,
      ),
    );
  }

  FutureOr<void> _onChangeOrderByGroupStatus(
    ChangeOrderByGroupStatus event,
    Emitter<OrderState> emit,
  ) async {
    ///////////////////////////
    emit(
      state.copyWith(
        getOrdersByOrderGroupIDModel: null,
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
    ///////////////////////////
    emit(
      state.copyWith(getOrdersModel: getOrdersModel.map(
        (key, value) {
          if (key == event.status) {
            return MapEntry(key,
                value.copyWith(paginationStatus: PaginationStatus.loading));
          } else {
            return MapEntry(key, value);
          }
        },
      )),
    );
    ///////////////////////////////
    GetOrdersParams params = GetOrdersParams(
      offset:
          event.getWithPagination ? getOrdersModel[event.status]?.page ?? 1 : 1,
      status: event.status,
    );

    final response = await getOrdersUseCase(params);

    response.fold(
      (l) {
        getOrdersModel = state.getOrdersModel;

        if (!isFailedTheFirstTime.contains('GetOrdersEvent')) {
          add(
            GetOrdersEvent(
              status: event.status,
              getWithPagination: event.getWithPagination,
            ),
          );
          isFailedTheFirstTime.add('GetOrdersEvent');
        }

        emit(
          state.copyWith(getOrdersModel: getOrdersModel?.map(
            (key, value) {
              if (key == event.status)
                return MapEntry(key,
                    value.copyWith(paginationStatus: PaginationStatus.failure));
              return MapEntry(key, value);
            },
          )),
        );
      },
      (r) {
        getOrdersModel = state.getOrdersModel;

        isFailedTheFirstTime.remove('GetOrdersEvent');

        List<List<OrderListModel>> oldOrders = [];
        if (getOrdersModel?[event.status] != null &&
            ((getOrdersModel?[event.status]?.items.length ?? 0) > 0)) {
          oldOrders = getOrdersModel![event.status]!.items;
        }

        List<OrderListModel> ordersFromApi = List.of(r.data?.orders ?? []);
        List<List<OrderListModel>> newOrders = [];
        /*ordersFromApi.forEach((elements) => elements.details?.forEach(
            (element) => element.orderProductStatus = elements.orderStatus));*/
        final seen = <String>{};
        final List<String> duplicatesOrderGroupIds = [];

        for (var item in ordersFromApi) {
          if (!seen.add(item.orderGroupId ?? '')) {
            duplicatesOrderGroupIds.add(item.orderGroupId ?? '');
          }
        }
        final List<String> orderNewAdded = [];
        ordersFromApi.forEach(
          (element) {
            if (!(duplicatesOrderGroupIds.contains(element.orderGroupId))) {
              newOrders.add(ordersFromApi.where(
                (elements) {
                  return elements.orderGroupId == element.orderGroupId;
                },
              ).toList());
            }
            if (duplicatesOrderGroupIds.contains(element.orderGroupId) &&
                (!(orderNewAdded.contains(element.orderGroupId)))) {
              orderNewAdded.add(element.orderGroupId ?? "");
              newOrders.add(ordersFromApi.where(
                (elements) {
                  return elements.orderGroupId == element.orderGroupId;
                },
              ).toList());
            }
          },
        );

        /*  for (var duplicateId in duplicatesOrderGroupIds) {
          List<OrderListModel> ordersWithSameId = ordersFromApi.where(
            (element) {
              return element.orderGroupId == duplicateId;
            },
          ).toList();
          ordersFromApi.forEach(
            (element) {
              if (ordersWithSameId.contains(element)&&newOrders.contains(element)) {
                newOrders.insert(0, ordersWithSameId);
              }
            },
          );
          ///////////////////////////
          /*    OrderListModel firstOrder = ordersWithSameId[0];
          int firstOrderIndex = ordersFromApi.indexOf(firstOrder);
          ////////////////////
          ordersWithSameId.remove(firstOrder);
          ////////////////////////////////
          List<OrderListDetailModel> aggregatedDetails =
              firstOrder.details ?? [];
          for (var i = 0; i < aggregatedDetails.length; i++) {
            aggregatedDetails[i] = aggregatedDetails[i]
                .copyWith(orderProductStatus: firstOrder.orderStatus);
          }
          bool? statusIsOutForDelivary =
              firstOrder.orderStatus?.value == "out_for_delivery";
          double firstOrderAmount = firstOrder.orderAmount ?? 0;
          double firstOrderShippingCost = firstOrder.shippingCost ?? 0;

          double aggregatedAmount = firstOrderAmount;
          double aggregatedshippingCost = firstOrderShippingCost;
          for (var order in ordersWithSameId) {
            double orderAmount = order.orderAmount ?? 0;
            double shippingCost = order.shippingCost ?? 0;

            aggregatedAmount = aggregatedAmount + orderAmount;
            aggregatedshippingCost = aggregatedshippingCost + shippingCost;
            if (order.orderStatus?.value == "out_for_delivery") {
              statusIsOutForDelivary = true;
            }
            for (OrderListDetailModel detail in order.details ?? []) {
              aggregatedDetails
                  .add(detail.copyWith(orderProductStatus: order.orderStatus));
            }
          }

          OrderListModel aggregatedOrder = firstOrder.copyWith(
            orderAmount: aggregatedAmount,
            statusIsOutForDelivary: statusIsOutForDelivary,
            shippingCost: aggregatedshippingCost,
            details: aggregatedDetails,
          );

          ordersFromApi.removeWhere(
            (element) => element.orderGroupId == duplicateId,
          );
          // ordersFromApi.add(aggregatedOrder);*/

          //   ordersFromApi.insert(firstOrderIndex, aggregatedOrder);
        }*/

        ////////////////////////////
        emit(
          state.copyWith(
            orderTotalSize: r.data?.total ?? 0,
            getOrdersModel: getOrdersModel?.map(
              (key, value) {
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
              },
            ),
          ),
        );
      },
    );
  }

  FutureOr<void> _onSetCustomerAddressDefaultEvent(
    SetCustomerAddressDefaultEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWith(
        setCustomerAddressDefaultStatus:
            SetCustomerAddressDefaultStatus.loading));
    final response = await setCustomerAddressDefaultUseCase(
        SetCustomerAddressDefaultParams(addressId: event.adressId ?? 0));

    response.fold((l) {
      if (!isFailedTheFirstTime.contains('SetCustomerAddressDefaultEvent')) {
        add(SetCustomerAddressDefaultEvent(adressId: event.adressId));
        isFailedTheFirstTime.add('SetCustomerAddressDefaultEvent');
        return;
      }

      emit(state.copyWith(
          setCustomerAddressDefaultStatus:
              SetCustomerAddressDefaultStatus.failure));
    }, (r) async {
      add(GetCustomerAddressesEvent());
      GetIt.I<HomeBloc>().add(GetCartOverviewEvent());
      isFailedTheFirstTime.remove('SetCustomerAddressDefaultEvent');

      emit(state.copyWith(
          setCustomerAddressDefaultStatus:
              SetCustomerAddressDefaultStatus.success));
    });
  }

  FutureOr<void> _onGetCustomerAddressesEvent(
    GetCustomerAddressesEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWith(
        getCustomerAddressesStatus: GetCustomerAddressesStatus.loading));
    final response = await getCustomerAddressesUseCase(NoParams());

    response.fold((l) {
      if (!isFailedTheFirstTime.contains('getCustomerAddresses')) {
        add(GetCustomerAddressesEvent());
        isFailedTheFirstTime.add('getCustomerAddresses');
      }

      emit(state.copyWith(
          getCustomerAddressesStatus: GetCustomerAddressesStatus.failure));
    }, (r) async {
      isFailedTheFirstTime.remove('getCustomerAddresses');
      List<CustomerAddressesInfo>? listOfAdressInfoClassToSave = [];
      listOfAdressInfoClassToSave = [...r.data!];
      int currentAddressChoosed = 0;
      for (var i = 0; i < (r.data?.length ?? 0); i++) {
        if (r.data?[i].isDefault == 1) {
          currentAddressChoosed = i;
        }
      }
      if ((r.data?.length ?? 0) > 0 && (event.setDefault ?? false)) {
        add(SetCustomerAddressDefaultEvent(
            adressId: r.data?[currentAddressChoosed].id));
      }

      emit(state.copyWith(
        currentAddressChoosed: currentAddressChoosed,
        listOfAdressInfoClassToSave: List.of(listOfAdressInfoClassToSave),
        getCustomerAddressesStatus: GetCustomerAddressesStatus.success,
      ));
    });
  }

  FutureOr<void> _onDeleteAdressInfoClassEvent(
    DeleteAdressInfoClassEvent event,
    Emitter<OrderState> emit,
  ) async {
    final List<CustomerAddressesInfo> listOfAddressInfoClassToSave =
        List.of(state.listOfAddressInfoClassToSave ?? []);
    int index = listOfAddressInfoClassToSave
        .indexWhere((element) => element.id == event.adressInfoClassId);
    CustomerAddressesInfo preCustomerAddress =
        listOfAddressInfoClassToSave[index];

    listOfAddressInfoClassToSave
        .removeWhere((element) => element.id == event.adressInfoClassId);
    emit(state.copyWith(
        listOfAdressInfoClassToSave: listOfAddressInfoClassToSave,
        removeAddressToOrderStatus: RemoveAddressToOrderStatus.loading));
    final response = await deleteCustomerAddressUseCase(
        DeleteCustomerAddressParams(addressId: event.adressInfoClassId ?? 0));

    response.fold((l) {
      if (!isFailedTheFirstTime.contains('deleteCustomerAddress')) {
        add(DeleteAdressInfoClassEvent(
            adressInfoClassId: event.adressInfoClassId));
        isFailedTheFirstTime.add('deleteCustomerAddress');
      }
      showMessage(l.message,
          foreGroundColor: Colors.white,
          hasError: true,
          backGroundColor: Colors.black,
          showInRelease: true,
          timeShowing: Toast.LENGTH_LONG);
      final List<CustomerAddressesInfo> listOfAddressInfoClassToSave =
          List.of(state.listOfAddressInfoClassToSave ?? []);
      listOfAddressInfoClassToSave.insert(index, preCustomerAddress);
      emit(state.copyWith(
          listOfAdressInfoClassToSave: listOfAddressInfoClassToSave,
          removeAddressToOrderStatus: RemoveAddressToOrderStatus.failure));
    }, (r) async {
      add(GetCustomerAddressesEvent());
      showMessage(r.message ?? "",
          foreGroundColor: Colors.white,
          backGroundColor: Colors.black,
          showInRelease: true,
          timeShowing: Toast.LENGTH_LONG);
      isFailedTheFirstTime.remove('deleteCustomerAddress');

      emit(state.copyWith(
          removeAddressToOrderStatus: RemoveAddressToOrderStatus.success,
          listOfAdressInfoClassToSave: listOfAddressInfoClassToSave));
    });
  }

  FutureOr<void> _onAddAddressInfoClassEvent(
    AddAddressInfoClassEvent event,
    Emitter<OrderState> emit,
  ) async {
    final List<CustomerAddressesInfo> listOfAddressInfoClassToSave =
        List.of(state.listOfAddressInfoClassToSave ?? []);
    CustomerAddressesInfo adressInfoClassToSave = event.addressInfoClassToSave!;
    listOfAddressInfoClassToSave.insert(0, adressInfoClassToSave);
    emit(state.copyWith(
      listOfAdressInfoClassToSave: listOfAddressInfoClassToSave,
      addAddressToOrderStatus: AddAddressToOrderStatus.loading,
    ));

    final response = await addCustomerAddressUseCase(AddCustomerAddressParams(
      iso: (prefsRepository.userCountryIsAvailable == 1
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
      contactPersonName: event.addressInfoClassToSave?.contactInfo?.name ?? "",
    ));

    response.fold((l) {
      if (!isFailedTheFirstTime.contains('addCustomerAddress')) {
        add(AddAddressInfoClassEvent(
            addressInfoClassToSave: event.addressInfoClassToSave));
        isFailedTheFirstTime.add('addCustomerAddress');
      }
      showMessage(l.message,
          foreGroundColor: Colors.white,
          hasError: true,
          backGroundColor: Colors.black,
          showInRelease: true,
          timeShowing: Toast.LENGTH_LONG);
      final List<CustomerAddressesInfo> listOfAddressInfoClassToSave =
          List.of(state.listOfAddressInfoClassToSave ?? []);
      listOfAddressInfoClassToSave.removeAt(0);
      emit(state.copyWith(
          listOfAdressInfoClassToSave: listOfAddressInfoClassToSave,
          addAddressToOrderStatus: AddAddressToOrderStatus.failure));
    }, (r) async {
      GetIt.I<HomeBloc>().add(GetCartOverviewEvent());
      add(GetCustomerAddressesEvent());
      showMessage(r.message ?? "",
          foreGroundColor: Colors.white,
          backGroundColor: Colors.black,
          showInRelease: true,
          timeShowing: Toast.LENGTH_LONG);
      isFailedTheFirstTime.remove('addCustomerAddress');

      emit(state.copyWith(
          lastAdressInfoClassToSave: CustomerAddressesInfo(),
          addAddressToOrderStatus: AddAddressToOrderStatus.success,
          listOfAdressInfoClassToSave: listOfAddressInfoClassToSave));
    });
  }

  FutureOr<void> _onEditAdressInfoClassEvent(
    EditAdressInfoClassEvent event,
    Emitter<OrderState> emit,
  ) async {
    final List<CustomerAddressesInfo> listOfAddressInfoClassToSave =
        List.of(state.listOfAddressInfoClassToSave ?? []);

    int index = listOfAddressInfoClassToSave
        .indexWhere((element) => element.id == event.preIdToEdit);
    CustomerAddressesInfo preCustomerAddresses =
        listOfAddressInfoClassToSave[index];
    listOfAddressInfoClassToSave
        .removeWhere((element) => element.id == event.preIdToEdit);

    listOfAddressInfoClassToSave.insert(index, event.addressInfoClassToSave!);
    emit(state.copyWith(
        listOfAdressInfoClassToSave: listOfAddressInfoClassToSave,
        editAddressToOrderStatus: EditAddressToOrderStatus.loading));
    final response =
        await updateCustomerAddressUseCase(UpdateCustomerAddressParams(
      iso: (prefsRepository.userCountryIsAvailable == 1
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
      contactPersonName: event.addressInfoClassToSave?.contactInfo?.name ?? "",
    ));

    response.fold((l) {
      if (!isFailedTheFirstTime.contains('updateCustomerAddress')) {
        add(EditAdressInfoClassEvent(
          addressInfoClassToSave: event.addressInfoClassToSave,
          preIdToEdit: event.preIdToEdit,
        ));
        showMessage(l.message,
            foreGroundColor: Colors.white,
            backGroundColor: Colors.black,
            hasError: true,
            showInRelease: true,
            timeShowing: Toast.LENGTH_LONG);
        isFailedTheFirstTime.add('updateCustomerAddress');
      }
      final List<CustomerAddressesInfo> listOfAddressInfoClassToSave =
          List.of(state.listOfAddressInfoClassToSave ?? []);
      listOfAddressInfoClassToSave.insert(index, preCustomerAddresses);
      emit(state.copyWith(
          listOfAdressInfoClassToSave: listOfAddressInfoClassToSave,
          editAddressToOrderStatus: EditAddressToOrderStatus.failure));
    }, (r) async {
      add(GetCustomerAddressesEvent());
      showMessage(r.message ?? "",
          foreGroundColor: Colors.white,
          backGroundColor: Colors.black,
          showInRelease: true,
          timeShowing: Toast.LENGTH_LONG);
      isFailedTheFirstTime.remove('updateCustomerAddress');

      emit(state.copyWith(
          editAddressToOrderStatus: EditAddressToOrderStatus.success,
          listOfAdressInfoClassToSave: listOfAddressInfoClassToSave));
    });
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
        if (!isFailedTheFirstTime.contains('GetAddressByCoordinatesEvent')) {
          isFailedTheFirstTime.add('GetAddressByCoordinatesEvent');
        }
        emit(
          state.copyWith(
            getAddressByCoordinatesStatus:
                GetAddressByCoordinatesStatus.failure,
          ),
        );
      },
      (r) {
        isFailedTheFirstTime.remove('GetAddressByCoordinatesEvent');
        emit(
          state.copyWith(
              getAddressByCoordinatesStatus:
                  GetAddressByCoordinatesStatus.success,
              getAddressByCoordinatesModel: r),
        );
      },
    );
    await Future.delayed(
      Duration(seconds: 5),
      () {
        emit(state.copyWith(
          getAddressByCoordinatesStatus: GetAddressByCoordinatesStatus.failure,
        ));
      },
    );
  }

  FutureOr<void> _onGetAddressByTextEvent(
    GetAddressByTextEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(
        state.copyWith(getAddressByTextStatus: GetAddressByTextStatus.loading));
    if (event.reset) {
      emit(state.copyWith(
          getAddressByTextStatus: GetAddressByTextStatus.success,
          resultSearch: []));
      return;
    }
    final response = await getAddressByTextUsecase(
        GetAddressByTextParams(query: event.query));

    response.fold((l) {
      if (!isFailedTheFirstTime.contains('GetAddressByTextEvent')) {
        ;
        isFailedTheFirstTime.add('GetAddressByTextEvent');
      }
      emit(state.copyWith(
          getAddressByTextStatus: GetAddressByTextStatus.failure));
    }, (r) {
      isFailedTheFirstTime.remove('GetAddressByTextEvent');

      emit(state.copyWith(
        resultSearch: r.results,
        getAddressByTextStatus: GetAddressByTextStatus.success,
      ));
    });
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
    ///////////////////////////
    emit(
      state.copyWith(
        applyCouponStatus: ApplyCouponStatus.loading,
      ),
    );

    final response = await applyCouponUsecase(event.code);

    response.fold(
      (l) {
        if (!isFailedTheFirstTime.contains('ApplyCouponEvent')) {
          add(
            ApplyCouponEvent(code: event.code),
          );
          isFailedTheFirstTime.add('ApplyCouponEvent');
        }

        emit(
          state.copyWith(
            applyCouponStatus: ApplyCouponStatus.failure,
          ),
        );
      },
      (r) {
        isFailedTheFirstTime.remove('ApplyCouponEvent');
        var data = r.data;

        if (data!.status == 0) {
          emit(
            state.copyWith(
              applyCouponStatus: ApplyCouponStatus.failure,
              applyCouponModel: r,
            ),
          );
          //////////////
          showMessage(
            r.message ?? 'invalid',
            foreGroundColor: Colors.white,
            backGroundColor: Colors.black,
            showInRelease: true,
            timeShowing: Toast.LENGTH_LONG,
          );
        } else {
          debugPrint('ApplyCouponEvent success');
          ////////////////////////////
          emit(
            state.copyWith(
              applyCouponStatus: ApplyCouponStatus.success,
              applyCouponModel: r,
            ),
          );
          //////////////
          showMessage(
            r.message ?? 'Success',
            foreGroundColor: Colors.white,
            backGroundColor: Colors.black,
            showInRelease: true,
            timeShowing: Toast.LENGTH_LONG,
          );
        }
      },
    );
  }

  //////////////////////////////////////////////////////////

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
          applyCouponStatus: ApplyCouponStatus.init,
        )
        .toJson();
  }
}
