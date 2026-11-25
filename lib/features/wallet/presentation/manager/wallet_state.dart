import 'package:equatable/equatable.dart';

import '../../data/models/wallet_balance_model.dart';
import '../../data/models/wallet_entry_model.dart';

/// حالُ طلبٍ واحد.
enum WalletStatus { init, loading, success, failure }

/// العملة المفتوحة بطاقتُها، أو `null` والبطاقتان صغيرتان.
///
/// اللوح `– 11` يرسم البطاقتين جنباً إلى جنب، و`– 17` بطاقةً واحدةً ممدودة
/// ومعها الإيداعُ والسحبُ وكشفُ تلك العملة.
typedef WalletOpenCard = String?;

class WalletState extends Equatable {
  const WalletState({
    this.currencies = const <WalletBalanceModel>[],
    this.entries = const <String, List<WalletEntryModel>>{},
    this.openAssetId,
    this.currenciesStatus = WalletStatus.init,
    this.balanceStatus = WalletStatus.init,
    this.entriesStatus = WalletStatus.init,
    this.error,
  });

  /// العملات وأرصدتها، بترتيب الخادم.
  final List<WalletBalanceModel> currencies;

  /// كشفُ كلّ عملةٍ، بمعرّفها.
  final Map<String, List<WalletEntryModel>> entries;

  /// البطاقة الممدودة.
  final WalletOpenCard openAssetId;

  final WalletStatus currenciesStatus;
  final WalletStatus balanceStatus;
  final WalletStatus entriesStatus;

  /// آخرُ خطأٍ يُعرض للمستخدم.
  final String? error;

  /// كشفُ البطاقة المفتوحة.
  List<WalletEntryModel> get openEntries =>
      entries[openAssetId] ?? const <WalletEntryModel>[];

  WalletState copyWith({
    List<WalletBalanceModel>? currencies,
    Map<String, List<WalletEntryModel>>? entries,
    WalletOpenCard openAssetId,
    bool clearOpen = false,
    WalletStatus? currenciesStatus,
    WalletStatus? balanceStatus,
    WalletStatus? entriesStatus,
    String? error,
    bool clearError = false,
  }) {
    return WalletState(
      currencies: currencies ?? this.currencies,
      entries: entries ?? this.entries,
      openAssetId: clearOpen ? null : (openAssetId ?? this.openAssetId),
      currenciesStatus: currenciesStatus ?? this.currenciesStatus,
      balanceStatus: balanceStatus ?? this.balanceStatus,
      entriesStatus: entriesStatus ?? this.entriesStatus,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    currencies,
    entries,
    openAssetId,
    currenciesStatus,
    balanceStatus,
    entriesStatus,
    error,
  ];
}
