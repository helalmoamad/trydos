class PaymentMethods {
  static const String cod = 'cash_on_delivery';

  /// الدفع عبر Ramaaz Digital Bank.
  ///
  /// الباك قد يرسل أحد الاسمين في `available_payment_method` أو في بيانات
  /// الطلب، فنعاملهما طريقة واحدة في الواجهة، ونطلب دائماً `checkout/rdb`.
  static const String trydosWallet = 'trydos_wallet';
  static const String rdb = 'rdb';

  static const String card = 'card';
  static const String crypto = 'crypto';

  static bool isRdb(String? method) => method == rdb || method == trydosWallet;

  static bool listHasRdb(List<String> methods) => methods.any(isRdb);
}
