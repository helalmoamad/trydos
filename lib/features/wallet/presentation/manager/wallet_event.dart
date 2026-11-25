import 'package:equatable/equatable.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// يجلب العملات ثمّ رصيدَ كلٍّ منها.
///
/// `currencies` يُعيد العملات ومعرّفاتها، ثمّ يُطلب رصيدُ كلِّ معرّفٍ على
/// حدة (`wallets/my/balances/{assetId}`) — فلا مسارَ يُعيدها مجتمعةً.
class GetWalletCurrenciesEvent extends WalletEvent {
  const GetWalletCurrenciesEvent();
}

/// يُحدّث رصيد عملةٍ بعينها.
class GetWalletBalanceEvent extends WalletEvent {
  const GetWalletBalanceEvent({required this.assetId});

  final String assetId;

  @override
  List<Object?> get props => <Object?>[assetId];
}

/// يجلب كشف حركات عملة. لا مسار له بعد.
class GetWalletEntriesEvent extends WalletEvent {
  const GetWalletEntriesEvent({required this.assetId});

  final String assetId;

  @override
  List<Object?> get props => <Object?>[assetId];
}

/// يفتح بطاقةَ عملةٍ أو يُرجع البطاقتين — اللوحان `– 17` و`– 11`.
class OpenWalletCardEvent extends WalletEvent {
  const OpenWalletCardEvent({this.assetId});

  /// `null` تُرجع البطاقتين صغيرتين.
  final String? assetId;

  @override
  List<Object?> get props => <Object?>[assetId];
}
