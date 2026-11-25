/// رصيدُ عملةٍ في المحفظة — `WalletBalance` في `demoWallet.ts`.
///
/// الويب يكتب القيم التي يرسمها الملفّ («1000» دولاراً و«1000» ليرة)؛ وعندنا
/// تأتي من `wallets/my/balances/{assetId}` على خادم المحفظة.
class WalletBalanceModel {
  const WalletBalanceModel({
    required this.assetId,
    required this.code,
    required this.name,
    required this.amount,
  });

  /// معرّف العملة على خادم المحفظة — به يُطلَب الرصيد.
  final String assetId;

  /// رمزُها كما يُكتب في البطاقة: `USD`، `SYP`.
  final String code;

  /// اسمُها الكامل تحت الرمز: «Amerikan dollars»، «syrian pounds».
  final String name;

  /// الرصيد كما يُعرض. نصٌّ لا عدد: الخادم قد يُعيد كسوراً، والعرضُ لا يحسب.
  final String amount;

  factory WalletBalanceModel.fromJson(Map<String, dynamic> json) {
    return WalletBalanceModel(
      assetId: json['asset_id']?.toString() ?? json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? json['symbol']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      amount: json['balance']?.toString() ?? json['amount']?.toString() ?? '0',
    );
  }

  WalletBalanceModel copyWith({String? amount}) => WalletBalanceModel(
    assetId: assetId,
    code: code,
    name: name,
    amount: amount ?? this.amount,
  );

  @override
  bool operator ==(Object other) =>
      other is WalletBalanceModel &&
      other.assetId == assetId &&
      other.amount == amount;

  @override
  int get hashCode => Object.hash(assetId, amount);
}
