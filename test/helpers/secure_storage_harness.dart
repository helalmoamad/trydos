import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test ledger · wave 02 Account and session — the secure-storage stand-in.
///
/// `FlutterSecureStorage` is a thin wrapper over one method channel. Rather than
/// implementing its Dart class, this answers the channel, so the real
/// `FlutterSecureStorage` object runs — including the argument shapes it sends
/// and the `Map<String, String>` it builds out of `readAll`.
///
/// The keychain it stands in for is a real one on the device, so the contents
/// survive an app update. That is exactly what the migration guard depends on,
/// and why a test needs to be able to see inside.
class SecureStorageHarness {
  SecureStorageHarness([Map<String, String>? seed])
      : store = <String, String>{...?seed};

  static const MethodChannel _channel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );

  /// What is in the keychain right now.
  final Map<String, String> store;

  /// Starts answering the channel. Call it before anything builds a
  /// `FlutterSecureStorage`.
  void install() {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, _handle);
  }

  /// Stops answering, so the next test starts from a clean keychain.
  void uninstall() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  }

  Future<Object?> _handle(MethodCall call) async {
    final Map<Object?, Object?> args =
        (call.arguments as Map<Object?, Object?>?) ?? <Object?, Object?>{};
    final String? key = args['key'] as String?;

    switch (call.method) {
      case 'write':
        store[key!] = (args['value'] as String?) ?? '';
        return null;
      case 'read':
        return store[key];
      case 'readAll':
        return Map<String, String>.from(store);
      case 'containsKey':
        return store.containsKey(key);
      case 'delete':
        store.remove(key);
        return null;
      case 'deleteAll':
        store.clear();
        return null;
      default:
        return null;
    }
  }
}
