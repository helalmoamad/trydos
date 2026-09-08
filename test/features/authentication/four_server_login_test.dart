import 'package:flutter_test/flutter_test.dart';
import 'package:trydos/common/constant/configuration/chat_url_routes.dart';
import 'package:trydos/common/constant/configuration/market_url_routes.dart';
import 'package:trydos/common/constant/configuration/wallet_url_routes.dart';
import 'package:trydos/common/constant/configuration/web_app_url.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';

import '../../helpers/auth_fixtures.dart';
import '../../helpers/auth_flow_harness.dart';
import '../../helpers/network_harness.dart';
import '../../helpers/session_prefs.dart';

/// Test ledger · wave 02 Account and session · unit "The four-server login".
///
/// Trydos is not one backend. A signed-in user holds four separate sessions —
/// market, chat, stories and wallet — plus a fifth token for comments. Each one
/// lives under its own key, and the whole app breaks in quiet ways if they mix:
/// a chat token in the market slot means every market request goes out with
/// credentials the market server never issued, and the user sees an empty app
/// with no error to explain it.
///
/// **This is the wave gate**: sign-in must prove four tokens land in four
/// distinct keys.
void main() {
  late AuthFlowHarness harness;

  setUpAll(setUpFirebaseMocks);

  tearDown(() => tearDownAuthFlowHarness(harness));

  test('CreateUserEvent creates the chat-side account and starts no session',
      () async {
    // The ledger calls this "creates the market account". It does not: the
    // market account is created by the sign-up endpoint (see "Verify the OTP").
    // `CreateUserEvent` is the chat feature's create-user call — its use case is
    // the only one in `AuthBloc` that takes a `ChatRepository`.
    final SessionPrefs prefs = SessionPrefs();
    harness = buildAuthFlowHarness(
      prefs: prefs,
      routes: <String, List<ScriptedReply>>{
        ChatEndPoints.createUserEP: <ScriptedReply>[
          const ScriptedReply(200, <String, dynamic>{
            'id': 77,
            'name': 'Yaser',
            'mobile_phone': '963931234567',
          }),
        ],
      },
    );

    harness.bloc.add(
      const CreateUserEvent(
        name: 'Yaser',
        mobilePhone: '963931234567',
        password: 'secret',
      ),
    );
    await pumpEventQueue();

    expect(harness.bloc.state.createUserStatus, CreateUserStatus.success);
    expect(
      harness.adapter.urlOf(ChatEndPoints.createUserEP),
      contains(TestServers.chatNest),
      reason: 'the account being created is the chat one',
    );
    final Map<String, dynamic> body =
        harness.adapter.bodyOf(ChatEndPoints.createUserEP)!
            as Map<String, dynamic>;
    expect(body['name'], 'Yaser');
    expect(body['mobilePhone'], '963931234567');

    // Creating the user is not logging in: no token comes back and none is
    // stored, so a login still has to follow.
    expect(prefs.chatTokenValue, isNull);
    expect(prefs.marketTokenValue, isNull);
  });

  test(
      'the chat, stories and wallet logins each store their OWN token — four '
      'distinct keys, never overwriting each other', () async {
    final SessionPrefs prefs = SessionPrefs()
      // The market session is already in place; the other three log in on top.
      ..marketTokenValue = 'market-access-token'
      ..phoneNumberValue = '+963931234567';

    harness = buildAuthFlowHarness(
      prefs: prefs,
      routes: <String, List<ScriptedReply>>{
        AuthRoutes.chatLogin: <ScriptedReply>[
          ScriptedReply(
            200,
            chatLoginEnvelope(id: 77),
          ),
        ],
        AuthRoutes.storiesLogin: <ScriptedReply>[
          ScriptedReply(
            200,
            storiesLoginEnvelope(id: 88),
          ),
        ],
        WalletEndPoints.loginWithIdTokenEP: <ScriptedReply>[
          const ScriptedReply(200, <String, dynamic>{
            'accessToken': <String, dynamic>{'token': 'wallet-access-token'},
          }),
        ],
        WalletEndPoints.createWalletEP: <ScriptedReply>[
          const ScriptedReply(201, <String, dynamic>{'id': 'wallet-1'}),
        ],
        ChatEndPoints.storeFcmEP: <ScriptedReply>[
          const ScriptedReply(200, <String, dynamic>{
            'data': <String, dynamic>{'id': 1},
          }),
        ],
      },
    );

    harness.bloc.add(
      const LoginToChatEvent(
        mobilePhone: '+963931234567',
        otpIdToken: 'otp-id-token',
        originalUserId: '501',
        name: 'Yaser',
        fcmToken: 'fcm-1',
      ),
    );
    await pumpEventQueue();

    harness.bloc.add(
      LoginToStoriesEvent(
        phone: '+963931234567',
        name: 'Yaser',
        otpIdToken: 'otp-id-token',
        originalUserId: '501',
      ),
    );
    await pumpEventQueue();

    harness.bloc.add(
      LoginToWalletEvent(
        otpIdToken: 'otp-id-token',
        phone: '+963931234567',
        name: 'Yaser',
      ),
    );
    await pumpEventQueue();

    // The gate: four values, four keys, none of them equal to another.
    expect(prefs.marketTokenValue, 'market-access-token');
    expect(prefs.chatTokenValue, 'chat-access-token');
    expect(prefs.storiesTokenValue, 'stories-access-token');
    expect(prefs.walletTokenValue, 'wallet-access-token');
    expect(
      <String?>{
        prefs.marketTokenValue,
        prefs.chatTokenValue,
        prefs.storiesTokenValue,
        prefs.walletTokenValue,
      },
      hasLength(4),
      reason: 'two servers sharing a value means one login wrote the other slot',
    );

    // Each refresh token has its own key too, or the wrong server would be
    // asked to renew a session.
    expect(prefs.chatRefreshTokenValue, 'chat-refresh-token');
    expect(prefs.storiesRefreshTokenValue, 'stories-refresh-token');
    expect(
      prefs.marketRefreshTokenValue,
      isNull,
      reason: 'no market refresh happened here, so nothing may have touched it',
    );
  });

  test('myMarketId, myChatId and myStoriesId are all stored', () async {
    final SessionPrefs prefs = SessionPrefs()
      ..marketTokenValue = 'market-access-token'
      ..phoneNumberValue = '+963931234567';

    harness = buildAuthFlowHarness(
      prefs: prefs,
      routes: <String, List<ScriptedReply>>{
        MarketEndPoints.verifyOtpSignInEP: <ScriptedReply>[
          ScriptedReply(200, authEnvelope(user: userJson(id: 501))),
        ],
        ...fanOutRoutes(
          // The same account, or the customer-info refresh that sign-in fires
          // would be what moved the stored market id.
          customerInfo: customerInfoEnvelope(user: userJson(id: 501)),
          stories: ScriptedReply(200, storiesLoginEnvelope(id: 88)),
          chat: ScriptedReply(200, chatLoginEnvelope(id: 77)),
        ),
      },
    );

    harness.bloc.add(
      VerifyOtpSignInEvent(
        verificationId: 'vid-1',
        otp: '123456',
        phone: '+963931234567',
      ),
    );
    await pumpEventQueue();

    // Three servers, three identities. They are different numbers on purpose:
    // the app looks the user up by a different id on each backend.
    expect(prefs.myMarketIdValue, '501');
    expect(prefs.myChatIdValue, 77);
    expect(prefs.myStoriesIdValue, 88);
  });

  test('a chat login failure does not tear down the market session', () async {
    final SessionPrefs prefs = SessionPrefs()
      ..marketTokenValue = 'market-access-token'
      ..marketRefreshTokenValue = 'market-refresh-token'
      ..myMarketIdValue = '501'
      ..phoneNumberValue = '+963931234567';

    harness = buildAuthFlowHarness(
      prefs: prefs,
      routes: <String, List<ScriptedReply>>{
        AuthRoutes.chatLogin: <ScriptedReply>[
          ScriptedReply(500, failureBody(message: 'chat is down')),
        ],
        ChatEndPoints.storeFcmEP: <ScriptedReply>[
          const ScriptedReply(200, <String, dynamic>{
            'data': <String, dynamic>{'id': 1},
          }),
        ],
      },
    );

    harness.bloc.add(
      const LoginToChatEvent(
        mobilePhone: '+963931234567',
        otpIdToken: 'otp-id-token',
        originalUserId: '501',
        name: 'Yaser',
        fcmToken: 'fcm-1',
      ),
    );
    await pumpEventQueue();

    expect(harness.bloc.state.loginToChatStatus, LoginToChatStatus.failure);
    expect(
      prefs.isLogInToChatValue,
      isFalse,
      reason: 'the app records that chat is not available',
    );

    // The user still gets into the app: nothing about the market session moved.
    expect(prefs.marketTokenValue, 'market-access-token');
    expect(prefs.marketRefreshTokenValue, 'market-refresh-token');
    expect(prefs.myMarketIdValue, '501');
    expect(
      prefs.chatTokenValue,
      isNull,
      reason: 'a failed login must not leave a token behind either',
    );
  });

  test('CreateWalletEvent runs once and is not repeated on the next login',
      () async {
    final SessionPrefs prefs = SessionPrefs()
      ..marketTokenValue = 'market-access-token'
      ..walletTokenValue = 'wallet-access-token'
      ..phoneNumberValue = '+963931234567';

    harness = buildAuthFlowHarness(
      prefs: prefs,
      routes: <String, List<ScriptedReply>>{
        WalletEndPoints.createWalletEP: <ScriptedReply>[
          const ScriptedReply(201, <String, dynamic>{'id': 'wallet-1'}),
        ],
      },
    );

    harness.bloc.add(CreateWalletEvent());
    await pumpEventQueue();

    expect(harness.adapter.callsTo(WalletEndPoints.createWalletEP), 1);
    expect(
      prefs.isCreateWalletValue,
      isTrue,
      reason: 'the flag is what stops the second attempt',
    );

    // The next login dispatches it again — and it must stop at the flag.
    harness.bloc.add(CreateWalletEvent());
    await pumpEventQueue();

    expect(
      harness.adapter.callsTo(WalletEndPoints.createWalletEP),
      1,
      reason: 'a second wallet for the same user is money in the wrong place',
    );
    expect(
      harness.home.eventsOf<GetCurrenciesForWalletEvent>(),
      hasLength(2),
      reason: 'both runs still hand the wallet screen its currencies',
    );
  });

  test('GenerateTokenForCommentEvent stores the comment token used by the '
      'ratings screens', () async {
    final SessionPrefs prefs = SessionPrefs()
      // A leftover token: the handler clears it before it asks, so a failed
      // exchange cannot leave the previous account's token in place.
      ..commentTokenValue = 'stale-comment-token';

    harness = buildAuthFlowHarness(
      prefs: prefs,
      routes: <String, List<ScriptedReply>>{
        WebAppEndPoints.generateTokenForCommentEP: <ScriptedReply>[
          ScriptedReply(
            200,
            commentTokenEnvelope(
              token: 'fresh-comment-token',
              refreshToken: 'fresh-comment-refresh',
            ),
          ),
        ],
      },
    );

    harness.bloc.add(
      GenerateTokenForCommentEvent(
        userId: '501',
        mobilePhone: '+963931234567',
        otpIdToken: 'otp-id-token',
      ),
    );
    await pumpEventQueue();

    expect(
      harness.bloc.state.generateTokenForCommentStatus,
      GenerateTokenForCommentStatus.success,
    );
    expect(prefs.commentTokenValue, 'fresh-comment-token');
    expect(
      prefs.commentRefreshTokenValue,
      'fresh-comment-refresh',
      reason: 'a 401 on a rating is renewed with this, not re-exchanged',
    );
    expect(
      harness.adapter.urlOf(WebAppEndPoints.generateTokenForCommentEP),
      contains(TestServers.comment),
      reason: 'the comments token is issued by the comments server',
    );
  });
}
