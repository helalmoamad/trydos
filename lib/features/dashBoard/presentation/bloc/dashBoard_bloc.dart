import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/dashBoard/data/models/get_user_permission_model.dart';
import 'package:trydos/features/dashBoard/data/models/get_seller_products_model.dart'
    as products_model;
import 'package:trydos/features/dashBoard/data/models/get_seller_orders_model.dart'
    as orders_model;
import 'package:trydos/features/dashBoard/data/models/get_seller_boutiques_model.dart'
    as boutiques_model;
import 'package:trydos/features/dashBoard/data/models/get_user_roles_model.dart';
import 'package:trydos/features/dashBoard/domain/useCase/add_user_usecase.dart';
import 'package:trydos/features/dashBoard/domain/useCase/get_user_permission_usecase.dart.dart';
import 'package:trydos/features/dashBoard/domain/useCase/get_user_roles_usecase.dart';
import 'package:trydos/features/dashBoard/domain/useCase/get_orders_usecase.dart';
import 'package:trydos/features/dashBoard/domain/useCase/get_products_usecase.dart';
import 'package:trydos/features/dashBoard/domain/useCase/get_boutiques_usecase.dart';
import 'package:trydos/features/dashBoard/domain/useCase/change_order_status_usecase.dart';
import 'package:equatable/equatable.dart';
part 'dashBoard_event.dart';
part 'dashBoard_state.dart';

@LazySingleton()
class DashboardBloc extends Bloc<DashBoardEvent, DashBoardState> {
  final GetUserPermissionUseCase getUserPermissionUseCase;
  final GetUserRolesUseCase getUserRolesUseCase;
  final AddUserUseCase addUserUseCase;
  final GetOrdersUseCase getOrdersUseCase;
  final GetProductsUseCase getProductsUseCase;
  final GetBoutiquesUseCase getBoutiquesUseCase;
  final ChangeOrderStatusUseCase changeOrderStatusUseCase;

  DashboardBloc(
    this.getUserPermissionUseCase,
    this.getUserRolesUseCase,
    this.addUserUseCase,
    this.getOrdersUseCase,
    this.getProductsUseCase,
    this.getBoutiquesUseCase,
    this.changeOrderStatusUseCase,
  ) : super(DashBoardState()) {
    on<GetOrdersEvent>(_onGetOrdersEvent);
    on<GetProductsEvent>(_onGetProductsEvent);
    on<GetBoutiquesEvent>(_onGetBoutiquesEvent);
    on<ChangeOrderStatusEvent>(_onChangeOrderStatusEvent);
    on<GetUserPermissionEvent>(_onGetUserPermissionEvent);
    on<GetUserRolesEvent>(_onGetUserRolesEvent);
    on<AddUserEvent>(_onAddUserEvent);
  }

  FutureOr<void> _onGetUserPermissionEvent(
    GetUserPermissionEvent event,
    Emitter<DashBoardState> emit,
  ) async {
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
            shops: r.shops,
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

    final response = await getUserRolesUseCase(NoParams());
    response.fold(
      (l) {
        emit((state.copyWith(getUserRolesStatus: GetUserRolesStatus.failure)));
      },
      (r) {
        emit(
          (state.copyWith(
            shopRoles: r.data?.shopRoles,
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
            getOrdersStatus: GetOrdersStatus.success,
          )),
        );
      },
    );
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
      },
    );
  }
}
