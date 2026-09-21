import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/helper/dev_log.dart';
import 'package:trydos/common/helper/rdb_pending_payment.dart';
import 'package:trydos/features/home/data/models/rdb_payment_request_model.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';

/// مراحل شاشة الدفع عبر RDB.
enum RdbPaymentPhase {
  /// ننشئ طلب الدفع أو نفتح طلباً موجوداً.
  loading,

  /// الكود ظاهر وننتظر أن يدفع الزبون من تطبيق RDB.
  awaitingPayment,
  paid,
  expired,
  cancelled,
  failed,

  /// للزبون دفعة معلّقة أصلاً، فرفض الباك إنشاء طلب جديد (409). تُغلق النافذة
  /// وتظهر رسالة "لديك طلب لم يُدفع" نفسها التي تظهر عند تعديل السلة.
  blockedByPendingRequest,

  /// تعذّر إنشاء الطلب أو قراءته (شبكة، أو رفض من الباك).
  error,
}

class RdbPaymentState extends Equatable {
  const RdbPaymentState({
    this.phase = RdbPaymentPhase.loading,
    this.request,
    this.errorMessage,
    this.isCancelling = false,
  });

  final RdbPaymentPhase phase;
  final RdbPaymentRequestModel? request;
  final String? errorMessage;
  final bool isCancelling;

  bool get isPending => phase == RdbPaymentPhase.awaitingPayment;

  RdbPaymentState copyWith({
    RdbPaymentPhase? phase,
    RdbPaymentRequestModel? request,
    String? errorMessage,
    bool? isCancelling,
  }) => RdbPaymentState(
    phase: phase ?? this.phase,
    request: request ?? this.request,
    errorMessage: errorMessage,
    isCancelling: isCancelling ?? this.isCancelling,
  );

  @override
  List<Object?> get props => <Object?>[
    phase,
    request?.requestReference,
    request?.statusRaw,
    request?.shortCode,
    request?.orderIds,
    errorMessage,
    isCancelling,
  ];
}

/// يدير دفعة RDB واحدة: ينشئ الطلب، يسأل عن حالته كل بضع ثوانٍ، ويلغيه.
///
/// محلّي بالشاشة لا مسجّل في الـ DI: عمره عمر صفحة الدفع. التطبيق لا يتصل بـ
/// RDB إطلاقاً — كل شيء عبر الباك.
class RdbPaymentCubit extends Cubit<RdbPaymentState> {
  RdbPaymentCubit({HomeRepository? repository})
    : _repository = repository ?? GetIt.I<HomeRepository>(),
      super(const RdbPaymentState());

  final HomeRepository _repository;

  /// فاصل السؤال عن الحالة. الدليل يطلب بين 3 و5 ثوانٍ.
  static const Duration pollInterval = Duration(seconds: 4);

  Timer? _poll;

  /// ينشئ طلب دفع جديداً للسلة الحالية.
  ///
  /// إذا ردّ الباك 409 فللزبون طلب معلّق أصلاً: نفتحه بدل أن نعرض خطأً، لأن
  /// المرجع يصل مع جسم الـ 409 ويلتقطه [RdbPendingPayment].
  Future<void> createRequest({
    required int addressId,
    String orderNote = 'orderNote',
  }) async {
    emit(const RdbPaymentState());
    final result = await _repository.checkoutRdb(<String, dynamic>{
      'address_id': addressId,
      'order_note': orderNote,
    });
    await result.fold(
      (failure) async {
        // 409 = للزبون دفعة معلّقة. لا نفتحها هنا بصمت: نُعلم الشاشة لتغلق
        // نفسها وتعرض رسالة التنبيه، كما يحدث تماماً عند تعديل السلة.
        //
        // لا نكتفي برمز الحالة: طبقة الشبكة تبتلع خطأ Dio في بعض المسارات
        // فيصل 400 مكان 409، لذلك نسأل أيضاً إن كان المعترض قد رأى القفل للتوّ.
        if (failure.statusCode == 409 || RdbPendingPayment.wasJustRejected()) {
          emit(
            state.copyWith(
              phase: RdbPaymentPhase.blockedByPendingRequest,
              errorMessage: failure.message,
            ),
          );
          return;
        }
        emit(
          state.copyWith(
            phase: RdbPaymentPhase.error,
            errorMessage: failure.message,
          ),
        );
      },
      (response) async => _applyResponse(response),
    );
  }

  /// يفتح طلباً معلّقاً موجوداً (من شريط السلة أو بعد خطأ 409).
  Future<void> openExisting(String requestReference) async {
    emit(const RdbPaymentState());
    final result = await _repository.getRdbPaymentRequest(
      requestReference: requestReference,
    );
    result.fold((failure) {
      // 404: مرجع لا يخصّ هذا الزبون أو لم يعد موجوداً — لا تُبقِ السلة مقفلة.
      if (failure.statusCode == 404) {
        RdbPendingPayment.clear();
      }
      emit(
        state.copyWith(
          phase: RdbPaymentPhase.error,
          errorMessage: failure.message,
        ),
      );
    }, (response) => _applyResponse(response));
  }

  /// يلغي الطلب المعلّق فتعود السلة قابلة للتعديل.
  Future<void> cancel() async {
    final String? reference = state.request?.requestReference;
    if (reference == null || state.isCancelling) return;
    emit(state.copyWith(isCancelling: true));
    final result = await _repository.cancelRdbPaymentRequest(
      requestReference: reference,
    );
    result.fold(
      (failure) {
        // 409 هنا تعني أنّ الدفعة وصلت قبل الإلغاء: نسأل عن الحالة فنعرض النجاح.
        if (failure.statusCode == 409) {
          emit(state.copyWith(isCancelling: false));
          unawaited(_refresh());
          return;
        }
        emit(
          state.copyWith(isCancelling: false, errorMessage: failure.message),
        );
      },
      (response) {
        emit(state.copyWith(isCancelling: false));
        _applyResponse(response);
      },
    );
  }

  void _applyResponse(RdbPaymentRequestResponseModel response) {
    final RdbPaymentRequestModel? request = response.data;
    if (request == null) {
      emit(
        state.copyWith(
          phase: RdbPaymentPhase.error,
          errorMessage: response.message,
        ),
      );
      return;
    }

    RdbPendingPayment.rememberRequest(request);

    switch (request.status) {
      case RdbPaymentStatus.paid:
        _stopPolling();
        emit(
          RdbPaymentState(phase: RdbPaymentPhase.paid, request: request),
        );
        return;
      case RdbPaymentStatus.expired:
        _stopPolling();
        emit(
          RdbPaymentState(phase: RdbPaymentPhase.expired, request: request),
        );
        return;
      case RdbPaymentStatus.cancelled:
        _stopPolling();
        emit(
          RdbPaymentState(phase: RdbPaymentPhase.cancelled, request: request),
        );
        return;
      case RdbPaymentStatus.failed:
        _stopPolling();
        emit(
          RdbPaymentState(phase: RdbPaymentPhase.failed, request: request),
        );
        return;
      case RdbPaymentStatus.awaitingPayment:
      case RdbPaymentStatus.unknown:
        emit(
          RdbPaymentState(
            phase: RdbPaymentPhase.awaitingPayment,
            request: request,
          ),
        );
        _startPolling();
        return;
    }
  }

  void _startPolling() {
    _poll?.cancel();
    _poll = Timer.periodic(pollInterval, (_) => _refresh());
  }

  void _stopPolling() {
    _poll?.cancel();
    _poll = null;
  }

  Future<void> _refresh() async {
    final RdbPaymentRequestModel? request = state.request;
    if (request == null || isClosed) return;

    // انتهت المهلة: نسأل سؤالاً أخيراً (قد تكون الدفعة وصلت في آخر ثانية)، وإن
    // بقي معلّقاً نعدّه منتهياً محلياً بدل أن نظلّ نسأل بلا نهاية.
    final DateTime? expiresAt = request.expiresAt;
    final bool expired =
        expiresAt != null && expiresAt.isBefore(DateTime.now());
    if (expired) _stopPolling();

    final result = await _repository.getRdbPaymentRequest(
      requestReference: request.requestReference,
    );
    if (isClosed) return;
    result.fold(
      (failure) {
        devLog('rdb_payment_cubit.dart: poll failed', failure.message);
        // خطأ عابر أثناء السؤال لا يغيّر ما يراه الزبون؛ المحاولة التالية تكفي.
        if (expired) {
          RdbPendingPayment.clear();
          emit(
            state.copyWith(phase: RdbPaymentPhase.expired, request: request),
          );
        }
      },
      (response) {
        _applyResponse(response);
        if (expired && state.phase == RdbPaymentPhase.awaitingPayment) {
          RdbPendingPayment.clear();
          emit(
            state.copyWith(phase: RdbPaymentPhase.expired, request: request),
          );
        }
      },
    );
  }

  /// يُستدعى عند عودة التطبيق إلى المقدّمة: الزبون قد يكون دفع للتوّ في RDB.
  void refreshNow() {
    if (state.isPending) unawaited(_refresh());
  }

  @override
  Future<void> close() {
    _stopPolling();
    return super.close();
  }
}
