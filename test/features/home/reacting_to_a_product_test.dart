import 'package:flutter_test/flutter_test.dart';
import 'package:trydos/common/constant/configuration/web_app_url.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as listing;
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';

import '../../helpers/auth_flow_harness.dart';
import '../../helpers/catalogue_fixtures.dart';
import '../../helpers/home_flow_harness.dart';
import '../../helpers/network_harness.dart';
import '../../helpers/session_prefs.dart';

/// Test ledger · wave 03 Browsing, search and the product page · unit
/// "Reacting to a product".
///
/// A tapped heart has to fill immediately — waiting for a round trip to colour
/// it in feels broken. That is an optimistic update, and an optimistic update
/// owes the user one thing in return: if the request fails, the heart goes
/// back. A heart left filled over a like the server refused is worse than one
/// that never filled, because the user believes the product is saved.
///
/// **The three-second door.** `AddOrRemoveLikeForProductEvent` is registered
/// `throttleDroppable(3s)`: the first tap goes through and every tap for the
/// next three seconds is dropped, whichever product it is for. That is what
/// stops a double-tap sending two likes — and it is also what breaks the
/// reversal above, which the pinned test at the end of this file holds in
/// place.
///
/// The like itself lives on the product in
/// `cachedProductWithoutRelatedProductsModel[id].product` — `isLiked` and the
/// count beside it — which is what every product widget reads.
void main() {
  HomeFlowHarness? harness;

  setUpAll(setUpFirebaseMocks);

  tearDown(() async {
    await tearDownHomeFlowHarness(harness);
    harness = null;
  });

  /// Long enough for the like throttle to reopen.
  const Duration pastTheThrottle = Duration(milliseconds: 3200);

  const String detailsEP = 'api/mobile/product/details/';
  const String quantityEP = 'api/mobile/product/qty/';
  const String relatedEP = 'api/related-products/';
  const String likeEP = WebAppEndPoints.addLikeOFProductEP;
  const String unlikeEP = WebAppEndPoints.removeLikeOFProductEP;
  const String socialEP = WebAppEndPoints.editSocialProductEP;

  Map<String, List<ScriptedReply>> productRoutes({bool likeSucceeds = true}) =>
      <String, List<ScriptedReply>>{
        detailsEP: <ScriptedReply>[
          ScriptedReply(200, productDetailsEnvelope()),
        ],
        quantityEP: <ScriptedReply>[
          ScriptedReply(200, productQuantityEnvelope()),
        ],
        relatedEP: <ScriptedReply>[
          ScriptedReply(200, relatedProductsEnvelope()),
        ],
        'api/v1/web/product/delivery_times/': <ScriptedReply>[
          const ScriptedReply(200, <String, dynamic>{'data': <dynamic>[]}),
        ],
        'api/v1/stories/product_stories/': <ScriptedReply>[
          const ScriptedReply(200, <String, dynamic>{'data': <dynamic>[]}),
        ],
        socialEP: <ScriptedReply>[
          const ScriptedReply(200, <String, dynamic>{'message': 'ok'}),
        ],
        likeEP: <ScriptedReply>[
          likeSucceeds
              ? const ScriptedReply(200, <String, dynamic>{'message': 'ok'})
              : const ScriptedReply(500, <String, dynamic>{'message': 'no'}),
        ],
        unlikeEP: <ScriptedReply>[
          const ScriptedReply(200, <String, dynamic>{'message': 'ok'}),
        ],
      };

  dynamic productOf(HomeFlowHarness flow) =>
      flow.bloc.state.cachedProductWithoutRelatedProductsModel['77']?.product;

  AddOrRemoveLikeForProductEvent like({required bool on, String id = '77'}) =>
      AddOrRemoveLikeForProductEvent(
        isFavourite: on,
        productId: id,
        productSlug: 'silk-dress',
        productSlugForTopic: 'silk-dress',
      );

  Future<HomeFlowHarness> openedProduct({bool likeSucceeds = true}) async {
    final HomeFlowHarness flow = harness = buildHomeFlowHarness(
      prefs: SessionPrefs()
        ..marketTokenValue = 'market-token'
        // Liking and unliking both go to the comment server, which carries its
        // own session.
        ..commentTokenValue = 'comment-token'
        ..myMarketIdValue = '5',
      routes: productRoutes(likeSucceeds: likeSucceeds),
    );
    flow.bloc.add(const GetFullProductDetailsEvent(productSlug: 'silk-dress'));
    await pumpEventQueue();
    return flow;
  }

  test('liking fills the heart and moves the count in the same frame as the '
      'request', () async {
    final HomeFlowHarness flow = await openedProduct();

    final int likesBefore = (productOf(flow)?.countOfLikes as int?) ?? 0;
    expect(productOf(flow)?.isLiked, isFalse);

    flow.bloc.add(like(on: true));
    await pumpEventQueue();

    expect(productOf(flow)?.isLiked, isTrue);
    expect(
      productOf(flow)?.countOfLikes,
      likesBefore + 1,
      reason: 'the count moves with the heart — a filled heart over an '
          'unchanged count reads as a failed tap',
    );
    expect(flow.adapter.callsTo(likeEP), 1);
    expect(
      flow.bloc.state.addOrRemoveLikeOfProductStatus,
      AddOrRemoveLikeOfProductStatus.success,
    );
  });

  test('a second tap inside three seconds is dropped — including a tap on a '
      'different product', () async {
    // `throttleDroppable` is per event type, not per product. One heart tapped,
    // then another within the window, and only the first is sent. That is the
    // protection against a double-tap; it also means a user working quickly
    // down a list can tap a second heart and have nothing happen.
    final HomeFlowHarness flow = await openedProduct();

    flow.bloc.add(like(on: true));
    await pumpEventQueue();
    expect(flow.adapter.callsTo(likeEP), 1);

    flow.bloc.add(like(on: false));
    await pumpEventQueue();

    expect(flow.adapter.callsTo(unlikeEP), 0,
        reason: 'the second tap never reached the server …');
    expect(productOf(flow)?.isLiked, isTrue,
        reason: '… and the heart is still filled from the first');

    flow.bloc.add(like(on: true, id: '99'));
    await pumpEventQueue();
    expect(
      flow.adapter.callsTo(likeEP),
      1,
      reason: 'a different product inside the window is dropped too — the '
          'throttle is on the event, not the product',
    );
  });

  test('once the window has passed, unliking puts the product back exactly '
      'where it started', () async {
    // This test waits out the real three seconds. It is the only way to see
    // both halves of the toggle, and the toggle returning to its start is the
    // thing the ledger asks for.
    final HomeFlowHarness flow = await openedProduct();
    final int likesBefore = (productOf(flow)?.countOfLikes as int?) ?? 0;

    flow.bloc.add(like(on: true));
    await pumpEventQueue();
    expect(productOf(flow)?.isLiked, isTrue);

    await Future<void>.delayed(pastTheThrottle);

    flow.bloc.add(like(on: false));
    await pumpEventQueue();

    expect(productOf(flow)?.isLiked, isFalse);
    expect(
      productOf(flow)?.countOfLikes,
      likesBefore,
      reason: 'back to where it started — not one below it',
    );
    expect(flow.adapter.callsTo(unlikeEP), 1,
        reason: 'unliking is its own endpoint, not the same one again');
  });

  test('a like the server refuses puts the heart back', () async {
    // This was a defect. The reversal below existed but could not be reached:
    // `ErrorManager.shouldRetry` allowed one retry, the handler returned early
    // to schedule it, and the retry — dispatched back into this same handler,
    // the one registered `throttleDroppable(3s)` — was dropped milliseconds
    // later. The second failure never came, so the heart stayed filled over a
    // like the server had rejected, and the status stayed `loading` for good.
    //
    // The retry is gone: it could never run, and a like is a user action worth
    // reporting rather than repeating behind their back.
    final HomeFlowHarness flow = await openedProduct(likeSucceeds: false);
    final int likesBefore = (productOf(flow)?.countOfLikes as int?) ?? 0;

    flow.bloc.add(like(on: true));
    await pumpEventQueue();

    expect(flow.adapter.callsTo(likeEP), 1);
    expect(
      productOf(flow)?.isLiked,
      isFalse,
      reason: 'the heart is empty again — leaving it filled would tell the '
          'user the product is saved when the server never accepted it',
    );
    expect(
      productOf(flow)?.countOfLikes,
      likesBefore,
      reason: 'and the count is reversed with it',
    );
    expect(
      flow.bloc.state.addOrRemoveLikeOfProductStatus,
      AddOrRemoveLikeOfProductStatus.failure,
      reason: 'so the page can say so',
    );
  });

  test('IncreaseCountShareOfProductEvent counts the share on the device and '
      'tells the share service', () async {
    // The number next to the share button steps up as the sheet opens, without
    // waiting for anything. The one request it makes is to the web-app share
    // service, which renders the product for people who follow the link and
    // keeps its own copy of these counts.
    final HomeFlowHarness flow = await openedProduct();
    final int callsBefore = flow.adapter.callCount;

    flow.bloc.add(
      IncreaseCountShareOfProductEvent(
        productId: '77',
        socialMediaName: 'whatsapp',
        product: listing.Products(
          productId: 77,
          isProductNotifiedForUser: false,
        ),
      ),
    );
    await pumpEventQueue();

    expect(productOf(flow)?.sharedCount, 1);

    flow.bloc.add(
      IncreaseCountShareOfProductEvent(
        productId: '77',
        socialMediaName: 'telegram',
        product: listing.Products(
          productId: 77,
          isProductNotifiedForUser: false,
        ),
      ),
    );
    await pumpEventQueue();

    expect(
      productOf(flow)?.sharedCount,
      2,
      reason: 'each share counts once — two shares, two',
    );
    expect(
      flow.adapter.callsTo(socialEP),
      2,
      reason: 'and each one tells the share service to catch up',
    );
    expect(
      flow.adapter.callCount - callsBefore,
      2,
      reason: 'which is the only request a share makes',
    );
  });

  test('UpdateLikeSocialSharedProductsEvent updates the shared copy by product '
      'id', () async {
    // A product opened from a share link is rendered by the share service, so
    // an accepted like has to reach it as well. The like handler dispatches
    // this itself on success — the page never has to remember to.
    final HomeFlowHarness flow = await openedProduct();

    flow.bloc.add(like(on: true));
    await pumpEventQueue();
    expect(flow.adapter.callsTo(socialEP), 1,
        reason: 'a successful like carries through to the shared copy');

    flow.bloc.add(const UpdateLikeSocialSharedProductsEvent(productId: '77'));
    await pumpEventQueue();

    expect(flow.adapter.callsTo(socialEP), 2);
    expect(
      flow.adapter.urlOf(socialEP, index: 1),
      contains('77'),
      reason: 'by product id — the share link is what carries it',
    );
  });
}
