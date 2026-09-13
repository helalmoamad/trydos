import 'dart:async';

/// Which token family a refresh belongs to.
///
/// `market` covers every server that carries the market access token — market,
/// marketGO, dashBoard and the media server.
enum RefreshScope { market, chat, stories, comment }

/// Lets the network layer wait for a token refresh that `AuthBloc` performs.
///
/// The bloc's refresh events are fire and forget: `add(...)` returns at once, so
/// the caller never learns when the refresh finished or whether it worked. This
/// coordinator supplies that missing signal, so a request that failed with 401
/// can wait for the new token and then be sent again.
///
/// It also collapses concurrent refreshes: ten requests that fail together share
/// one refresh, then all retry.
class TokenRefreshCoordinator {
  TokenRefreshCoordinator._();

  static final TokenRefreshCoordinator instance = TokenRefreshCoordinator._();

  /// Upper bound on how long a caller waits. The bloc throttles its refresh
  /// events, so a dispatched event can be dropped and never answered — without a
  /// timeout that caller would wait forever and its request would hang.
  static const Duration _timeout = Duration(seconds: 20);

  final Map<RefreshScope, Completer<bool>> _completers =
      <RefreshScope, Completer<bool>>{};
  final Map<RefreshScope, Future<bool>> _pending =
      <RefreshScope, Future<bool>>{};

  /// Asks for a refresh of [scope] and waits for its outcome.
  ///
  /// [start] dispatches the refresh. It is called only when no refresh for that
  /// scope is already running; a second caller joins the running one instead.
  /// Returns `true` only when the refresh replaced the stored token.
  Future<bool> refresh(RefreshScope scope, void Function() start) {
    final Future<bool>? running = _pending[scope];
    if (running != null) return running;

    final Completer<bool> completer = Completer<bool>();
    _completers[scope] = completer;

    final Future<bool> future = completer.future
        .timeout(_timeout, onTimeout: () => false)
        .whenComplete(() {
          _completers.remove(scope);
          _pending.remove(scope);
        });
    _pending[scope] = future;

    try {
      start();
    } catch (_) {
      // Dispatching failed, so nothing will ever report an outcome.
      complete(scope, false);
    }
    return future;
  }

  /// Reports the outcome of the refresh for [scope].
  ///
  /// Safe to call when nothing is waiting — an unmatched call is ignored.
  void complete(RefreshScope scope, bool succeeded) {
    final Completer<bool>? completer = _completers[scope];
    if (completer != null && !completer.isCompleted) {
      completer.complete(succeeded);
    }
  }
}
