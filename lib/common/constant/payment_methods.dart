class PaymentMethods {
  static const String cod = 'cash_on_delivery';

  /// محفظة Trydos: رصيد الزبون عندنا.
  ///
  /// كانت تُعامَل والـ`rdb` طريقةً واحدة، إذ ظُنّ الاسمان اسمَي شيء واحد.
  /// والباك يرسلهما اليوم **معاً** في القائمة نفسها
  /// (`[cash_on_delivery, trydos_wallet, rdb]`)، فهما طريقتان:
  ///   - `trydos_wallet` يُنشئ الطلب كما يُنشئه `cash_on_delivery`، والمبلغ
  ///     يُخصم من رصيد المحفظة؛
  ///   - `rdb` لا يُنشئ طلباً هنا: الباك يُنشئ طلب دفع ويعطينا كوداً يدخله
  ///     الزبون في تطبيق Ramaaz Digital Bank (`checkout/rdb`).
  static const String trydosWallet = 'trydos_wallet';

  /// الدفع عبر Ramaaz Digital Bank.
  static const String rdb = 'rdb';

  static const String card = 'card';
  static const String crypto = 'crypto';

  /// هل تذهب هذه الطريقة إلى مسار RDB؟ محفظةُ Trydos لا تذهب إليه.
  static bool isRdb(String? method) => method == rdb;

  static bool listHasRdb(List<String> methods) => methods.any(isRdb);
}
