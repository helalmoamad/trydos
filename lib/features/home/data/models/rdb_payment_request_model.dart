/// نموذج طلب الدفع عبر RDB.
///
/// التطبيق لا يتصل بـ RDB ولا يحمل مفتاحاً ولا توقيعاً: الباك ينشئ طلب الدفع
/// ويعيد كوداً من عشرة أرقام (`short_code`) يدخله الزبون في تطبيق RDB ويؤكّد.
/// ثم نسأل الباك عن حالة الطلب حتى تصبح `paid` أو تنتهي.
enum RdbPaymentStatus {
  awaitingPayment,
  paid,
  expired,
  cancelled,
  failed,

  /// حالة لم نعرفها — نعاملها كأنها ما زالت قيد الانتظار ولا نغلق الشاشة.
  unknown,
}

RdbPaymentStatus rdbPaymentStatusFromString(String? value) {
  switch (value) {
    case 'awaiting_payment':
      return RdbPaymentStatus.awaitingPayment;
    case 'paid':
      return RdbPaymentStatus.paid;
    case 'expired':
      return RdbPaymentStatus.expired;
    case 'cancelled':
      return RdbPaymentStatus.cancelled;
    case 'failed':
      return RdbPaymentStatus.failed;
    default:
      return RdbPaymentStatus.unknown;
  }
}

class RdbPaymentRequestModel {
  /// المعرّف الوحيد الثابت للطلب. `short_code` يعاد استعماله من RDB بعد انتهاء
  /// الطلب، فلا يصحّ أن يكون معرّفاً.
  final String requestReference;
  final RdbPaymentStatus status;
  final String statusRaw;
  final String? rdbRequestId;
  final String? requestCode;

  /// الكود العشري الذي يُعرض للزبون.
  final String? shortCode;

  /// صفحة الدفع من RDB. `null` حتى يفعّلها RDB. `qrPayload` و `deepLink`
  /// يحملان القيمة نفسها ويبقيان للنسخ القديمة.
  final String? paymentUrl;
  final String? deepLink;
  final String? qrPayload;

  /// يُعرض كما وصل نصاً بلا تحويل إلى عدد عشري.
  final String amount;
  final String? currency;
  final DateTime? expiresAt;
  final DateTime? paidAt;
  final String? receiptNumber;
  final String? failureReason;
  final List<int> orderIds;

  const RdbPaymentRequestModel({
    required this.requestReference,
    required this.status,
    required this.statusRaw,
    required this.amount,
    this.rdbRequestId,
    this.requestCode,
    this.shortCode,
    this.paymentUrl,
    this.deepLink,
    this.qrPayload,
    this.currency,
    this.expiresAt,
    this.paidAt,
    this.receiptNumber,
    this.failureReason,
    this.orderIds = const <int>[],
  });

  bool get isPending =>
      status == RdbPaymentStatus.awaitingPayment ||
      status == RdbPaymentStatus.unknown;

  bool get isFinished =>
      status == RdbPaymentStatus.paid ||
      status == RdbPaymentStatus.expired ||
      status == RdbPaymentStatus.cancelled ||
      status == RdbPaymentStatus.failed;

  /// صفحة الدفع إن فعّلها RDB. الحقول الثلاثة تحمل القيمة نفسها.
  String? get payPageUrl {
    for (final String? value in <String?>[paymentUrl, qrPayload, deepLink]) {
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  factory RdbPaymentRequestModel.fromJson(Map<String, dynamic> json) =>
      RdbPaymentRequestModel(
        requestReference: json["request_reference"]?.toString() ?? '',
        status: rdbPaymentStatusFromString(json["status"]?.toString()),
        statusRaw: json["status"]?.toString() ?? '',
        rdbRequestId: json["rdb_request_id"]?.toString(),
        requestCode: json["request_code"]?.toString(),
        shortCode: json["short_code"]?.toString(),
        paymentUrl: json["payment_url"]?.toString(),
        deepLink: json["deep_link"]?.toString(),
        qrPayload: json["qr_payload"]?.toString(),
        amount: json["amount"]?.toString() ?? '0',
        currency: json["currency"]?.toString(),
        expiresAt: DateTime.tryParse(json["expires_at"]?.toString() ?? ''),
        paidAt: DateTime.tryParse(json["paid_at"]?.toString() ?? ''),
        receiptNumber: json["receipt_number"]?.toString(),
        failureReason: json["failure_reason"]?.toString(),
        orderIds: json["order_ids"] == null
            ? const <int>[]
            : List<int>.from(
                (json["order_ids"] as List<dynamic>).map(
                  (dynamic x) => int.tryParse(x.toString()) ?? 0,
                ),
              ),
      );

  Map<String, dynamic> toJson() => {
    "request_reference": requestReference,
    "status": statusRaw,
    "rdb_request_id": rdbRequestId,
    "request_code": requestCode,
    "short_code": shortCode,
    "payment_url": paymentUrl,
    "deep_link": deepLink,
    "qr_payload": qrPayload,
    "amount": amount,
    "currency": currency,
    "expires_at": expiresAt?.toIso8601String(),
    "paid_at": paidAt?.toIso8601String(),
    "receipt_number": receiptNumber,
    "failure_reason": failureReason,
    "order_ids": orderIds,
  };
}

class RdbPaymentRequestResponseModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final String? message;
  final dynamic detailedError;
  final RdbPaymentRequestModel? data;

  const RdbPaymentRequestResponseModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  factory RdbPaymentRequestResponseModel.fromJson(Map<String, dynamic> json) =>
      RdbPaymentRequestResponseModel(
        isSuccessful: json["isSuccessful"] as bool?,
        hasContent: json["hasContent"] as bool?,
        code: json["code"] as int?,
        message: json["message"]?.toString(),
        detailedError: json["detailed_error"],
        data: json["data"] == null
            ? null
            : RdbPaymentRequestModel.fromJson(
                Map<String, dynamic>.from(json["data"] as Map),
              ),
      );
}

/// جسم الخطأ 409 حين تكون السلة مقفلة بانتظار دفعة RDB.
class RdbCartLockModel {
  final String requestReference;
  final DateTime? expiresAt;

  const RdbCartLockModel({required this.requestReference, this.expiresAt});

  /// يقرأ القفل من جسم أي استجابة 409. يعيد `null` إن لم يكن الجسم قفل سلة.
  static RdbCartLockModel? tryParse(dynamic body) {
    if (body is! Map) return null;
    final dynamic data = body["data"];
    if (data is! Map) return null;
    final String? reference = data["rdb_request_reference"]?.toString();
    if (reference == null || reference.isEmpty) return null;
    return RdbCartLockModel(
      requestReference: reference,
      expiresAt: DateTime.tryParse(data["expires_at"]?.toString() ?? ''),
    );
  }
}
