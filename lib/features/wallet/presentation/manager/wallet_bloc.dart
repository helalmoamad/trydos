import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:trydos/common/helper/dev_log.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/core/use_case/use_case.dart';

import '../../data/models/wallet_balance_model.dart';
import '../../data/models/wallet_entry_model.dart';
import '../../domain/use_cases/get_wallet_balance_usecase.dart';
import '../../domain/use_cases/get_wallet_currencies_usecase.dart';
import '../../domain/use_cases/get_wallet_entries_usecase.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

/// بلوك المحفظة.
///
/// خاصٌّ بها لا يشاركه غيرُها: المحفظة سطحُ مال، وخلطُ حالتها بحالة الصفحة
/// الرئيسيّة يجعل كلَّ انبعاثٍ هناك يمسّ رصيداً هنا.
///
/// وهو **ليس** `hydrated`: الرصيد لا يُحفظ على القرص ولا يُعرض من ذاكرةٍ
/// قديمة — رقمُ مالٍ قديمٌ أسوأ من لا رقم.
@injectable
class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletBloc(
    this.getWalletCurrenciesUseCase,
    this.getWalletBalanceUseCase,
    this.getWalletEntriesUseCase,
  ) : super(const WalletState()) {
    on<GetWalletCurrenciesEvent>(_onGetCurrencies);
    on<GetWalletBalanceEvent>(_onGetBalance);
    on<GetWalletEntriesEvent>(_onGetEntries);
    on<OpenWalletCardEvent>(_onOpenCard);
  }

  final GetWalletCurrenciesUseCase getWalletCurrenciesUseCase;
  final GetWalletBalanceUseCase getWalletBalanceUseCase;
  final GetWalletEntriesUseCase getWalletEntriesUseCase;

  /// العملات، ثمّ رصيدُ كلٍّ منها.
  Future<void> _onGetCurrencies(
    GetWalletCurrenciesEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(
      state.copyWith(currenciesStatus: WalletStatus.loading, clearError: true),
    );
    devLog('WalletBloc → currencies');

    final Either<Failure, List<WalletBalanceModel>> response =
        await getWalletCurrenciesUseCase(NoParams());

    await response.fold(
      (Failure failure) async {
        devLog('WalletBloc ✗ currencies', failure);
        emit(
          state.copyWith(
            currenciesStatus: WalletStatus.failure,
            error: failure.message,
          ),
        );
      },
      (List<WalletBalanceModel> currencies) async {
        devLog('WalletBloc ✓ currencies: ${currencies.length}');
        emit(
          state.copyWith(
            currencies: currencies,
            currenciesStatus: WalletStatus.success,
          ),
        );
        // الأرصدة واحداً واحداً: لا مسارَ يُعيدها مجتمعةً.
        for (final WalletBalanceModel c in currencies) {
          if (c.assetId.isEmpty) continue;
          add(GetWalletBalanceEvent(assetId: c.assetId));
        }
      },
    );
  }

  Future<void> _onGetBalance(
    GetWalletBalanceEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(state.copyWith(balanceStatus: WalletStatus.loading));

    final Either<Failure, WalletBalanceModel> response =
        await getWalletBalanceUseCase(event.assetId);

    response.fold(
      (Failure failure) {
        devLog('WalletBloc ✗ balance ${event.assetId}', failure);
        emit(
          state.copyWith(
            balanceStatus: WalletStatus.failure,
            error: failure.message,
          ),
        );
      },
      (WalletBalanceModel balance) {
        // يُستبدَل الرصيدُ في موضعه، فلا يتبدّل ترتيبُ البطاقات.
        final List<WalletBalanceModel> next = state.currencies
            .map(
              (WalletBalanceModel c) => c.assetId == event.assetId
                  ? c.copyWith(amount: balance.amount)
                  : c,
            )
            .toList();
        emit(
          state.copyWith(currencies: next, balanceStatus: WalletStatus.success),
        );
      },
    );
  }

  /// كشفُ الحركات. لا مسار له بعد، فيُسجَّل الخطأ ولا تُعرض قائمةٌ كاذبة.
  Future<void> _onGetEntries(
    GetWalletEntriesEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(state.copyWith(entriesStatus: WalletStatus.loading, clearError: true));

    final Either<Failure, List<WalletEntryModel>> response =
        await getWalletEntriesUseCase(event.assetId);

    response.fold(
      (Failure failure) {
        devLog('WalletBloc ✗ entries ${event.assetId}', failure);
        emit(
          state.copyWith(
            entriesStatus: WalletStatus.failure,
            error: failure.message,
          ),
        );
      },
      (List<WalletEntryModel> entries) {
        emit(
          state.copyWith(
            entries: <String, List<WalletEntryModel>>{
              ...state.entries,
              event.assetId: entries,
            },
            entriesStatus: WalletStatus.success,
          ),
        );
      },
    );
  }

  /// يفتح بطاقةً أو يُرجع البطاقتين، ويجلب كشفَ المفتوحة إن لم يُجلَب.
  void _onOpenCard(OpenWalletCardEvent event, Emitter<WalletState> emit) {
    if (event.assetId == null) {
      emit(state.copyWith(clearOpen: true));
      return;
    }
    emit(state.copyWith(openAssetId: event.assetId));
    if (!state.entries.containsKey(event.assetId)) {
      add(GetWalletEntriesEvent(assetId: event.assetId!));
    }
  }
}
