import 'package:injectable/injectable.dart';

import 'package:trydos/common/constant/configuration/wallet_url_routes.dart';
import 'package:trydos/core/api/client_config.dart';
import 'package:trydos/core/api/methods/detect_server.dart';
import 'package:trydos/core/api/methods/get.dart';

import '../models/wallet_balance_model.dart';
import '../models/wallet_entry_model.dart';

/// طلباتُ المحفظة إلى خادمها (`ServerName.wallet`).
///
/// ما يصل اليومَ **مساران** من `WalletEndPoints`:
///
///  - `currencies` — العملات التي تحملها المحفظة، ومنها `assetId` كلِّ عملة؛
///  - `wallets/my/balances/{assetId}` — رصيدُ عملةٍ بعينها.
///
/// وأمّا كشفُ الحركات والإيداعُ والسحبُ والإيصالاتُ فلا مسارات لها بعد —
/// وهي التي يرسمها اللوح في `– 18` و`– 19` و`– 21` و`– 22`. ودوالُّها هنا
/// تحمل **عقدها** وترمي [UnimplementedError] صراحةً، فلا تُخفي النقص خلف
/// قائمةٍ فارغة. وما يلزم الباك إنشاؤه مسرودٌ في `docs/wallet-endpoints.md`.
@injectable
class WalletRemoteDataSource {
  /// العملات التي تحملها المحفظة.
  Future<List<WalletBalanceModel>> getCurrencies() {
    final GetClient<List<WalletBalanceModel>> request =
        GetClient<List<WalletBalanceModel>>(
          serverName: ServerName.wallet,
          requestPrams: RequestConfig<List<WalletBalanceModel>>(
            endpoint: WalletEndPoints.currenciesEP,
            response: ResponseValue<List<WalletBalanceModel>>(
              fromJson: (dynamic response) {
                final List<dynamic> list = response is List
                    ? response
                    : (response['data'] as List<dynamic>? ?? <dynamic>[]);
                return list
                    .map(
                      (dynamic e) => WalletBalanceModel.fromJson(
                        Map<String, dynamic>.from(e as Map<dynamic, dynamic>),
                      ),
                    )
                    .toList();
              },
            ),
          ),
        );
    return request();
  }

  /// رصيدُ عملةٍ بعينها.
  Future<WalletBalanceModel> getBalance(String assetId) {
    final GetClient<WalletBalanceModel> request = GetClient<WalletBalanceModel>(
      serverName: ServerName.wallet,
      requestPrams: RequestConfig<WalletBalanceModel>(
        endpoint: WalletEndPoints.walletBalanceEP(assetId),
        response: ResponseValue<WalletBalanceModel>(
          fromJson: (dynamic response) => WalletBalanceModel.fromJson(
            Map<String, dynamic>.from(
              (response is Map && response['data'] is Map
                      ? response['data']
                      : response)
                  as Map<dynamic, dynamic>,
            ),
          ),
        ),
      ),
    );
    return request();
  }

  /// كشفُ حركات عملةٍ — `WALLET_ENTRIES` في الويب.
  ///
  /// لا مسار له بعد. العقد المنتظَر: `GET wallets/my/transactions?asset_id=`
  /// يُعيد قائمةً بحقول [WalletEntryModel].
  Future<List<WalletEntryModel>> getEntries(String assetId) {
    throw UnimplementedError(
      'wallet transactions: no endpoint yet — see docs/wallet-endpoints.md',
    );
  }
}
