import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trydos/common/constant/configuration/prefs_key.dart';
import 'package:trydos/core/data/repository/prefs_repository_impl.dart';
import 'package:trydos/core/di/di_container.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';

import '../../../helpers/secure_storage_harness.dart';

/// Test ledger · wave 02 Account and session · unit "Logging out".
///
/// Logging out is not one call. `base_page.dart:945` walks a list of setters,
/// and what it must leave behind is precise: every token and every piece of who
/// the user was is gone, while the things that belong to the **device** — the
/// language and the country the user picked — stay. Clearing those instead
/// would drop an Arabic user back into English on the next screen.
///
/// The four tokens each have their own key, and each lives in the keychain, not
/// in shared preferences. Two of those keys differing by one character is enough
/// to send the market token to the chat server, and nothing about that failure
/// says what went wrong — so the round-trip is asserted key by key.
///
/// One scenario of this unit is not here: "`DeleteFcmTokenEvent` and
/// `DeleteFcmTokenFromChatEvent` both run". That is bloc behaviour, not storage,
/// and lives in `test/features/authentication/logging_out_test.dart`.
void main() {
  late SecureStorageHarness keychain;
  late PrefsRepository prefs;
  late SharedPreferences sharedPreferences;

  /// Builds the repository the way the composition root does: tokens loaded out
  /// of the keychain once at startup and kept in memory, because the getters are
  /// synchronous.
  Future<PrefsRepository> buildRepository() async {
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();
    return PrefsRepositoryImpl(
      sharedPreferences,
      secureStorage,
      initialChatToken: await secureStorage.read(key: PrefsKey.chatToken),
      initialWalletToken: await secureStorage.read(key: PrefsKey.walletToken),
      initialMarketToken: await secureStorage.read(key: PrefsKey.marketToken),
      initialStoriesToken: await secureStorage.read(key: PrefsKey.storiesToken),
      initialTokenForComment:
          await secureStorage.read(key: PrefsKey.tokenForComment),
      initialIdToken: await secureStorage.read(key: PrefsKey.idToken),
    );
  }

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    keychain = SecureStorageHarness()..install();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    sharedPreferences = await SharedPreferences.getInstance();
    prefs = await buildRepository();
  });

  tearDown(() => keychain.uninstall());

  /// The sequence `base_page.dart:945` runs, in the same order.
  ///
  /// It is mirrored rather than called because it lives inside a widget's
  /// `State` and needs a `BuildContext`, three bloc providers and a router. If
  /// that list ever changes, this test keeps passing while the app changes
  /// behaviour — so treat it as a description of what logging out is *meant* to
  /// leave behind, and keep the two in step by hand.
  Future<void> runLogoutSequence(PrefsRepository p) async {
    await p.addFcmToken('');
    await p.setVerifiedPhone(false);
    await p.setPhoneNumber('');
    await p.setChatToken('');
    await p.setWalletToken('');
    await p.setStoriesToken('');
    await p.setStoriesRefreshToken('');
    await p.setTokenForComment('');
    await p.setCommentRefreshToken('');
    await p.setMarketToken(null);
    await p.setMyMarketName('');
    await p.setMyChatName('');
    await p.setMyStoriesName('');
    await p.setMyProfilePhoto('');
  }

  test('logout clears the four tokens and the identity keys', () async {
    await prefs.setMarketToken('market-token');
    await prefs.setChatToken('chat-token');
    await prefs.setStoriesToken('stories-token');
    await prefs.setWalletToken('wallet-token');
    await prefs.setTokenForComment('comment-token');
    await prefs.setMyMarketName('Yaser');
    await prefs.setMyChatName('Yaser');
    await prefs.setMyStoriesName('Yaser');
    await prefs.setMyProfilePhoto('customers/profile/me.jpg');
    await prefs.setPhoneNumber('+963931234567');
    await prefs.setVerifiedPhone(true);
    await prefs.addFcmToken('device-token-1');

    await runLogoutSequence(prefs);

    // Nothing usable is left. The market token is set to null, which the
    // repository stores as the empty string.
    expect(prefs.marketToken, '');
    expect(prefs.chatToken, '');
    expect(prefs.storiesToken, '');
    expect(prefs.walletToken, '');
    expect(prefs.tokenForComment, '');

    // Nor is anything left that says who this was.
    expect(prefs.myMarketName, '');
    expect(prefs.myChatName, '');
    expect(prefs.myStoriesName, '');
    expect(
      prefs.myProfilePhoto,
      isNull,
      reason: 'the getter reports an empty photo as no photo',
    );
    expect(prefs.myPhoneNumber, '');
    expect(prefs.isVerifiedPhone, isFalse);
    // The device token is blanked, not removed. `addFcmToken` replaces the whole
    // list with the one value it is given, so `addFcmToken('')` leaves a list of
    // one empty string rather than an empty list. What matters is that no usable
    // token is left — a real one here would keep push arriving for an account
    // nobody is signed into.
    expect(prefs.getFcmTokens, <String>['']);
    expect(prefs.getFcmTokens.first, isEmpty);
  });

  test('logout keeps the language and the chosen country', () async {
    await prefs.setLanguage('ar');
    await prefs.setUserChoosedCountryIso('SY');
    await prefs.setCountryIso('SY');
    await prefs.setUserCountryIsAvailable(1);
    await prefs.setMarketToken('market-token');

    await runLogoutSequence(prefs);

    expect(
      prefs.language,
      'ar',
      reason: 'these belong to the device, not to the account — an Arabic user '
          'must not be dropped into English by logging out',
    );
    expect(prefs.userChoosedCountryIso, 'SY');
    expect(prefs.countryIso, 'SY');
    expect(prefs.userCountryIsAvailable, 1);
  });

  test('each token round-trips under its own key and they never overwrite each '
      'other', () async {
    await prefs.setMarketToken('market-token');
    await prefs.setChatToken('chat-token');
    await prefs.setStoriesToken('stories-token');
    await prefs.setWalletToken('wallet-token');
    await prefs.setTokenForComment('comment-token');
    await prefs.setIdToken('otp-id-token');

    // Read back through the repository.
    expect(prefs.marketToken, 'market-token');
    expect(prefs.chatToken, 'chat-token');
    expect(prefs.storiesToken, 'stories-token');
    expect(prefs.walletToken, 'wallet-token');
    expect(prefs.tokenForComment, 'comment-token');
    expect(prefs.idToken, 'otp-id-token');

    // And read back out of the keychain itself, by key. This is what makes the
    // test able to fail on a copy-pasted key name: the repository getters would
    // still look right if two setters wrote the same key one after the other.
    expect(keychain.store[PrefsKey.marketToken], 'market-token');
    expect(keychain.store[PrefsKey.chatToken], 'chat-token');
    expect(keychain.store[PrefsKey.storiesToken], 'stories-token');
    expect(keychain.store[PrefsKey.walletToken], 'wallet-token');
    expect(keychain.store[PrefsKey.tokenForComment], 'comment-token');
    expect(keychain.store[PrefsKey.idToken], 'otp-id-token');

    // The refresh tokens too — six more keys, none of them shared with the
    // access tokens above.
    await prefs.setMarketRefreshToken('market-refresh');
    await prefs.setChatRefreshToken('chat-refresh');
    await prefs.setStoriesRefreshToken('stories-refresh');
    await prefs.setCommentRefreshToken('comment-refresh');

    expect(await prefs.getMarketRefreshToken(), 'market-refresh');
    expect(await prefs.getChatRefreshToken(), 'chat-refresh');
    expect(await prefs.getStoriesRefreshToken(), 'stories-refresh');
    expect(await prefs.getCommentRefreshToken(), 'comment-refresh');

    expect(
      keychain.store.values.toSet(),
      hasLength(keychain.store.length),
      reason: 'ten distinct values under ten distinct keys — a repeat means two '
          'setters share a key',
    );
    expect(
      keychain.store[PrefsKey.marketToken],
      'market-token',
      reason: 'storing the refresh tokens did not disturb the access tokens',
    );
  });

  test('a payload written by the previous release still reads — the migration '
      'guard', () async {
    // The release before this one kept the tokens in shared preferences. This is
    // what such a device looks like the moment it is updated: tokens in the old
    // place, keychain empty.
    SharedPreferences.setMockInitialValues(<String, Object>{
      PrefsKey.chatToken: 'old-chat-token',
      PrefsKey.walletToken: 'old-wallet-token',
      PrefsKey.marketToken: 'old-market-token',
      PrefsKey.storiesToken: 'old-stories-token',
      PrefsKey.tokenForComment: 'old-comment-token',
      PrefsKey.idToken: 'old-id-token',
      // Written by the old release too, and it must survive untouched.
      PrefsKey.language: 'ar',
      PrefsKey.marketName: 'Yaser',
    });
    keychain.store.clear();

    // The real migration, as the composition root runs it.
    final PrefsRepository migrated =
        await _TestAppModule().prefsRepository;

    expect(
      migrated.marketToken,
      'old-market-token',
      reason: 'the user must not be logged out by installing an update',
    );
    expect(migrated.chatToken, 'old-chat-token');
    expect(migrated.storiesToken, 'old-stories-token');
    expect(migrated.walletToken, 'old-wallet-token');
    expect(migrated.tokenForComment, 'old-comment-token');
    expect(migrated.idToken, 'old-id-token');

    // The tokens moved: they are in the keychain now and gone from the old
    // place, so a later read cannot pick up a stale copy.
    expect(keychain.store[PrefsKey.marketToken], 'old-market-token');
    final SharedPreferences after = await SharedPreferences.getInstance();
    expect(
      after.getString(PrefsKey.marketToken),
      isNull,
      reason: 'leaving the token in plain shared preferences is what the move '
          'was for',
    );

    // Everything that was not a token stayed where it was.
    expect(migrated.language, 'ar');
    expect(migrated.myMarketName, 'Yaser');
  });
}

/// A concrete `AppModule`, so the real migration can be run.
///
/// `AppModule` is abstract only because `injectable` generates its
/// implementation; it declares no abstract members, so extending it costs
/// nothing and keeps the test honest — the migration under test is the shipped
/// one, not a copy of it.
class _TestAppModule extends AppModule {}
