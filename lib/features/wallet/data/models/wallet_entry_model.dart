/// اتّجاه الحركة: مالٌ داخلٌ (سهمٌ نازلٌ داكن) أو خارجٌ (صاعدٌ برتقاليّ).
enum WalletEntryFlow { income, outcome }

/// حالةُ الحركة كما يرسمها اللوح.
enum WalletEntryStatus {
  /// تمّت.
  done,

  /// بانتظار موعدها — يُرسم معها الوقتُ واليوم.
  waiting,

  /// محجوبة.
  blocked,
}

/// حركةٌ في كشف المحفظة — `WalletEntry` في `demoWallet.ts`.
///
/// > العنوان والحالة كلماتُ التطبيق نفسه فهي مفاتيح؛ وأمّا الملاحظات
/// > والتواريخ والأسماء فبيانات، تُكتب كما يُظهرها الملفّ.
///
/// ولا endpoint لها عندنا بعد: العقد هنا، وتُوصَل حين يُنشئه الباك —
/// انظر `docs/wallet-endpoints.md`.
class WalletEntryModel {
  const WalletEntryModel({
    required this.id,
    required this.flow,
    required this.title,
    required this.date,
    required this.note,
    required this.amount,
    required this.unit,
    this.status = WalletEntryStatus.done,
    this.hasReceipt = false,
    this.dueTime,
    this.dueDay,
    this.dueMonth,
  });

  final String id;
  final WalletEntryFlow flow;

  /// عنوان الحركة: «إيداع»، «تحويل»، «شراء»…
  final String title;

  /// تاريخها كما يُعرض.
  final String date;

  /// سطرُ الملاحظة تحت العنوان.
  final String note;

  /// المبلغ، نصّاً.
  final String amount;

  /// وحدتُه: `USD`، `SYP`.
  final String unit;

  final WalletEntryStatus status;

  /// لها إيصال (`Home Page – 18`)، فلمسُها يفتحه.
  final bool hasReceipt;

  /// حركةٌ منتظِرة: وقتُها ويومُها وشهرُها.
  final String? dueTime;
  final String? dueDay;
  final String? dueMonth;

  /// رماديّةُ العنوان والملاحظة والمبلغ — محجوبةٌ أو منتظِرة.
  bool get muted =>
      status == WalletEntryStatus.blocked ||
      status == WalletEntryStatus.waiting;

  factory WalletEntryModel.fromJson(Map<String, dynamic> json) {
    return WalletEntryModel(
      id: json['id']?.toString() ?? '',
      flow: (json['direction']?.toString() ?? json['flow']?.toString()) == 'out'
          ? WalletEntryFlow.outcome
          : WalletEntryFlow.income,
      title: json['title']?.toString() ?? '',
      date: json['date']?.toString() ?? json['created_at']?.toString() ?? '',
      note: json['note']?.toString() ?? json['description']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '0',
      unit: json['unit']?.toString() ?? json['currency']?.toString() ?? '',
      status: switch (json['status']?.toString()) {
        'waiting' || 'pending' => WalletEntryStatus.waiting,
        'blocked' || 'rejected' => WalletEntryStatus.blocked,
        _ => WalletEntryStatus.done,
      },
      hasReceipt: json['has_receipt'] == true || json['receipt'] != null,
      dueTime: json['due_time']?.toString(),
      dueDay: json['due_day']?.toString(),
      dueMonth: json['due_month']?.toString(),
    );
  }
}
