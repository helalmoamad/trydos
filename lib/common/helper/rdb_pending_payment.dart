import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/home/data/models/rdb_payment_request_model.dart';

/// دفعة RDB المعلّقة للزبون.
///
/// ما دام هناك طلب دفع بانتظار الدفع، يرفض الباك أي تعديل على السلة أو أي
/// checkout جديد بالرمز 409 ومعه مرجع الطلب. نحفظ المرجع في مكانين:
/// [pending] ليتحدّث شريط السلة فوراً، والتخزين المحلي ليبقى المرجع بعد إغلاق
/// التطبيق. يكتبه إنشاء الطلب واعتراض الخطأ 409، ويمسحه انتهاء الطلب بأي حال.
class RdbPendingPayment {
  RdbPendingPayment._();

  static final ValueNotifier<RdbCartLockModel?> pending =
      ValueNotifier<RdbCartLockModel?>(null);


  static PrefsRepository get _prefs => GetIt.I<PrefsRepository>();

  static String? get requestReference => pending.value?.requestReference;

  /// يقرأ ما حُفظ سابقاً. يُستدعى مرّة عند فتح صفحة السلة.
  static void restore() {
    if (pending.value != null) return;
    final String? raw = _prefs.rdbPendingPayment;
    if (raw == null || raw.isEmpty) return;
    try {
      final Map<String, dynamic> body = Map<String, dynamic>.from(
        jsonDecode(raw) as Map,
      );
      final String reference = body['reference']?.toString() ?? '';
      if (reference.isEmpty) return;
      final DateTime? expiresAt = DateTime.tryParse(
        body['expires_at']?.toString() ?? '',
      );
      // مهلة منتهية: الطلب لم يعد يقفل السلة، فلا داعي لإظهار الشريط.
      if (expiresAt != null && expiresAt.isBefore(DateTime.now())) {
        clear();
        return;
      }
      pending.value = RdbCartLockModel(
        requestReference: reference,
        expiresAt: expiresAt,
      );
    } catch (_) {
      clear();
    }
  }

  /// لحظة آخر رفض 409 بسبب دفعة معلّقة.
  ///
  /// رمز الحالة لا يصل سليماً إلى طبقة الـ blocs: طبقة الشبكة تبتلع خطأ Dio
  /// في بعض المسارات فيصل 400 مكان 409. لذلك نعتمد على أن معترض الشبكة رأى
  /// القفل قبل لحظات، وهو ما يميّز هذا الرفض عن أي فشل آخر.
  static DateTime? _lastRejectionAt;

  /// يُستدعى من معترض الشبكة وحده عند رفض 409.
  static void rememberRejection(RdbCartLockModel lock) {
    _lastRejectionAt = DateTime.now();
    remember(lock);
  }

  /// رفض 409 بلا مرجع في جسمه.
  ///
  /// رفض `checkout/rdb` يصل بـ `data: null`، بخلاف رفض تعديل السلة الذي يحمل
  /// `rdb_request_reference`. فنسجّل الرفض على أي حال، ونستعيد المرجع المحفوظ
  /// عندنا — وهو موجود في الحالة الغالبة لأن هذا التطبيق هو من أنشأ الدفعة.
  static void rememberRejectionWithoutReference() {
    _lastRejectionAt = DateTime.now();
    restore();
  }

  static bool wasJustRejected({
    Duration within = const Duration(seconds: 8),
  }) {
    final DateTime? at = _lastRejectionAt;
    if (at == null) return false;
    return DateTime.now().difference(at) <= within;
  }

  static void remember(RdbCartLockModel lock) {
    pending.value = lock;
    _prefs.setRdbPendingPayment(
      jsonEncode(<String, dynamic>{
        'reference': lock.requestReference,
        'expires_at': lock.expiresAt?.toIso8601String(),
      }),
    );
  }

  static void rememberRequest(RdbPaymentRequestModel request) {
    if (request.isPending) {
      remember(
        RdbCartLockModel(
          requestReference: request.requestReference,
          expiresAt: request.expiresAt,
        ),
      );
    } else {
      clear();
    }
  }

  static void clear() {
    _lastRejectionAt = null;
    pending.value = null;
    _prefs.setRdbPendingPayment(null);
  }
}
