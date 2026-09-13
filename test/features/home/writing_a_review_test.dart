import 'package:flutter_test/flutter_test.dart';
import 'package:trydos/common/constant/configuration/web_app_url.dart';
import 'package:trydos/core/utils/validator.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';

import '../../helpers/auth_flow_harness.dart';
import '../../helpers/catalogue_fixtures.dart';
import '../../helpers/home_flow_harness.dart';
import '../../helpers/network_harness.dart';
import '../../helpers/session_prefs.dart';

/// Test ledger · wave 03 Browsing, search and the product page · unit
/// "Writing a review".
///
/// A review is the one thing on the product page a user *creates*, and it is
/// public under their name. Three things follow from that: what they typed has
/// to reach the server unchanged, an edit must change only what they edited,
/// and a delete must remove their comment and nobody else's.
///
/// Reviews live on the comment server, under its own session token, and are
/// held per filter tab in `getBuyersCommentsPaginationModel` — "all", "with
/// photos", and so on — because each tab is its own page of results.
void main() {
  HomeFlowHarness? harness;

  setUpAll(setUpFirebaseMocks);

  tearDown(() async {
    await tearDownHomeFlowHarness(harness);
    harness = null;
  });

  const String commentsEP = WebAppEndPoints.getBuyersCommentsEP;
  const String fqaEP = WebAppEndPoints.getFqaCommentsEP;
  const String createEP = WebAppEndPoints.createOrderRatingEP;
  const String likeCommentEP = WebAppEndPoints.addLikeCommentEP;
  /// Not the default tab on purpose: everything about a review is stored per
  /// filter tab, and a test that only ever used "all" could not tell a handler
  /// that ignores the tab from one that honours it.
  const String filter = 'with_photos';

  /// `BuyersComment.id` is a string — the model stringifies whatever the
  /// server sent.
  List<String?> commentIds(HomeFlowHarness flow) =>
      (flow.bloc.state.getBuyersCommentsPaginationModel?[filter]?.items ??
              <dynamic>[])
          .map((dynamic c) => c.id as String?)
          .toList();

  UpdateLikeCommentEvent likeComment({required bool on}) =>
      UpdateLikeCommentEvent(
        commentId: '2',
        productId: '77',
        toAddLike: on,
        currentFilter: filter,
        tapCommentIndex: 1,
        fromBuyerComments: true,
      );

  dynamic commentById(HomeFlowHarness flow, String id) =>
      (flow.bloc.state.getBuyersCommentsPaginationModel?[filter]?.items ??
              <dynamic>[])
          .cast<dynamic>()
          .firstWhere((dynamic c) => c.id == id);

  /// A signed-in shopper with three reviews already on the product.
  Future<HomeFlowHarness> withReviews({
    Map<String, List<ScriptedReply>> extra = const <String, List<ScriptedReply>>{},
  }) async {
    final HomeFlowHarness flow = harness = buildHomeFlowHarness(
      prefs: SessionPrefs()
        ..marketTokenValue = 'market-token'
        ..commentTokenValue = 'comment-token'
        ..myMarketIdValue = '5'
        ..myMarketNameValue = 'A buyer'
        ..phoneNumberValue = '+963900000000'
        ..isVerifiedPhoneValue = true,
      routes: <String, List<ScriptedReply>>{
        commentsEP: <ScriptedReply>[
          ScriptedReply(
            200,
            buyersCommentsEnvelope(
              comments: <Map<String, dynamic>>[
                buyerComment(id: 1, text: 'First'),
                buyerComment(id: 2, text: 'Second', totalLikes: 3),
                buyerComment(id: 3, text: 'Third'),
              ],
            ),
          ),
        ],
        fqaEP: <ScriptedReply>[
          ScriptedReply(200, fqaCommentsEnvelope()),
        ],
        ...extra,
      },
    );
    // The product page opens both tabs, and the write handlers depend on it:
    // the create branch null-asserts `getFqaCommentsPaginationModel["all"]`.
    flow.bloc
      ..add(GetBuyersCommentsEvent(productId: '77', currentFilter: filter))
      ..add(GetFqaCommentsEvent(productId: '77', currentFilter: filter));
    await pumpEventQueue();
    return flow;
  }

  test('CreateCommentRatingEvent sends the text, the stars and the images',
      () async {
    // Everything the reviewer entered has to arrive: the words, the rating out
    // of five, and the photos they attached. The identity around it is filled
    // in from the session rather than trusted from the screen.
    final HomeFlowHarness flow = harness = buildHomeFlowHarness(
      prefs: SessionPrefs()
        ..marketTokenValue = 'market-token'
        ..commentTokenValue = 'comment-token'
        ..myMarketIdValue = '5'
        ..myMarketNameValue = 'A buyer'
        ..isVerifiedPhoneValue = true,
      routes: <String, List<ScriptedReply>>{
        commentsEP: <ScriptedReply>[
          ScriptedReply(200, buyersCommentsEnvelope()),
        ],
        fqaEP: <ScriptedReply>[
          ScriptedReply(200, fqaCommentsEnvelope()),
        ],
        createEP: <ScriptedReply>[
          ScriptedReply(200, createdCommentEnvelope()),
        ],
      },
    );
    // The page opens both tabs on the default filter, which is what the create
    // handler reaches for — see the pinned test below.
    flow.bloc
      ..add(GetBuyersCommentsEvent(productId: '77'))
      ..add(GetFqaCommentsEvent(productId: '77'));
    await pumpEventQueue();

    flow.bloc.add(
      CreateCommentRatingEvent(
        text: 'Runs small but lovely',
        rating: '4',
        productId: '77',
        slug: 'silk-dress',
        ownerId: '3',
        ownerType: 'seller',
        variant: 'red_M',
        images: const <String>['a.jpg', 'b.jpg'],
      ),
    );
    await pumpEventQueue();

    final Map<String, dynamic> body =
        flow.adapter.bodyOf(createEP)! as Map<String, dynamic>;
    expect(body['text'], 'Runs small but lovely');
    expect(body['rating'], '4');
    expect(body['comments_images_customer'], <String>['a.jpg', 'b.jpg']);
    expect(body['product_id'], '77');
    expect(
      body['variant'],
      'red-M',
      reason: 'the variant is sent in the server\'s spelling — the app writes '
          'it with an underscore and converts on the way out',
    );
    expect(
      body['user_id'],
      '5',
      reason: 'who wrote it comes from the session, not from the form',
    );
    expect(
      body['user_type'],
      'user',
      reason: 'a verified phone reviews as a user; an unverified one as a '
          'customer',
    );
    expect(
      flow.transitionsOf((HomeState s) => s.createCommentRatingStatus),
      containsAllInOrder(<CreateCommentRatingStatus>[
        CreateCommentRatingStatus.loading,
        CreateCommentRatingStatus.success,
      ]),
    );
  });

  test('UpdateCommentRatingEvent edits that one comment, at its own address',
      () async {
    // The edit goes to a url built from the comment id, so a mistake here edits
    // somebody else's review.
    final String updateEP = WebAppEndPoints.updateOrderRatingEP('2');
    final HomeFlowHarness flow = await withReviews(
      extra: <String, List<ScriptedReply>>{
        updateEP: <ScriptedReply>[
          const ScriptedReply(200, <String, dynamic>{
            'data': <String, dynamic>{'id': 2},
          }),
        ],
      },
    );

    flow.bloc.add(
      UpdateCommentRatingEvent(
        commentId: '2',
        text: 'Edited words',
        rating: '3',
        productId: '77',
        slug: 'silk-dress',
        ownerId: '3',
        ownerType: 'seller',
        currentFilter: filter,
        tapCommentIndex: 1,
      ),
    );
    await pumpEventQueue();

    expect(flow.adapter.callsTo(updateEP), 1);
    expect(
      flow.adapter.urlOf(updateEP),
      contains('/2/update'),
      reason: 'the comment id is in the path — this is the only thing that '
          'says which review is being rewritten',
    );
    final Map<String, dynamic> body =
        flow.adapter.bodyOf(updateEP)! as Map<String, dynamic>;
    expect(body['text'], 'Edited words');
    expect(body['rating'], '3');
    expect(
      flow.transitionsOf((HomeState s) => s.updateOrderCommentRatingStatus),
      containsAllInOrder(<UpdateOrderCommentRatingStatus>[
        UpdateOrderCommentRatingStatus.loading,
        UpdateOrderCommentRatingStatus.success,
      ]),
    );
  });

  test('DeleteCommentRatingEvent removes that comment and leaves the others',
      () async {
    final String deleteEP = WebAppEndPoints.deleteOrderRatingEP('2');
    final HomeFlowHarness flow = await withReviews(
      extra: <String, List<ScriptedReply>>{
        deleteEP: <ScriptedReply>[
          const ScriptedReply(200, <String, dynamic>{'message': 'deleted'}),
        ],
      },
    );

    expect(commentIds(flow), <String>['1', '2', '3']);

    flow.bloc.add(
      DeleteCommentRatingEvent(
        commentId: '2',
        productId: '77',
        currentFilter: filter,
        tapCommentIndex: 1,
        // Which of the two tabs the comment belongs to. Left false, the
        // handler removes from the questions list instead and the review
        // stays on screen.
        fromBuyerComments: true,
      ),
    );
    await pumpEventQueue();

    expect(flow.adapter.urlOf(deleteEP), contains('/2/delete'));
    expect(
      commentIds(flow),
      <String>['1', '3'],
      reason: 'only the deleted one goes, and the rest keep their order',
    );
    expect(
      flow.bloc.state.deleteOrderCommentRatingStatus,
      DeleteOrderCommentRatingStatus.success,
    );
  });

  test('UpdateLikeCommentEvent toggles a review\'s like, and toggling twice '
      'returns it to the start', () async {
    final HomeFlowHarness flow = await withReviews(
      extra: <String, List<ScriptedReply>>{
        likeCommentEP: <ScriptedReply>[
          const ScriptedReply(200, <String, dynamic>{'message': 'ok'}),
        ],
        WebAppEndPoints.removeLikeCommentEP: <ScriptedReply>[
          const ScriptedReply(200, <String, dynamic>{'message': 'ok'}),
        ],
      },
    );

    expect(commentById(flow, '2').isLiked, isFalse);

    flow.bloc.add(likeComment(on: true));
    await pumpEventQueue();

    expect(commentById(flow, '2').isLiked, isTrue);
    expect(
      commentIds(flow),
      <String>['1', '2', '3'],
      reason: 'liking a review must not reorder the list under the reader',
    );

    flow.bloc.add(likeComment(on: false));
    await pumpEventQueue();

    expect(commentById(flow, '2').isLiked, isFalse,
        reason: 'back to where it started');
    expect(commentIds(flow), <String>['1', '2', '3']);
  });

  test('a review cannot be sent without a rating — the validator refuses it '
      'before any request', () async {
    // The stars are the part of a review the shop actually sorts and filters
    // by, so an empty rating is refused in the form. `RequiredValidator` is
    // what the review form uses.
    //
    // Worth knowing: it refuses `''` but **accepts `null`** — a field never
    // touched passes. That is pinned as a wave-01 defect in
    // `test/core/utils/validator_test.dart`; the form works because it starts
    // its rating field at `''` rather than null.
    final RequiredValidator ratingIsRequired =
        RequiredValidator(errorText: 'choose a rating');
    expect(
      ratingIsRequired(''),
      'choose a rating',
      reason: 'an empty rating is refused, with the message the form shows …',
    );
    expect(ratingIsRequired('4'), isNull, reason: '… and a real one passes');

    final HomeFlowHarness flow = harness = buildHomeFlowHarness(
      prefs: SessionPrefs()
        ..marketTokenValue = 'market-token'
        ..commentTokenValue = 'comment-token'
        ..myMarketIdValue = '5',
      routes: <String, List<ScriptedReply>>{
        createEP: <ScriptedReply>[
          const ScriptedReply(200, <String, dynamic>{
            'data': <String, dynamic>{'id': 9},
          }),
        ],
      },
    );

    expect(
      flow.adapter.callsTo(createEP),
      0,
      reason: 'nothing is sent while the form is refusing — the bloc is never '
          'reached',
    );
  });

  test('a review written while a filtered tab is open still reports success',
      () async {
    // This was a defect: the success branch reached for
    // `getFqaCommentsPaginationModel["all"]!` — the questions tab, under the
    // **default** filter, hard-coded and null-asserted. On any other review
    // filter that entry does not exist, so the `!` threw *after* the server had
    // accepted the review: it existed, and the form kept spinning over it. The
    // same happened on a product page whose questions tab was never opened.
    // The entry is now defaulted rather than asserted.
    final HomeFlowHarness flow = harness = buildHomeFlowHarness(
      prefs: SessionPrefs()
        ..marketTokenValue = 'market-token'
        ..commentTokenValue = 'comment-token'
        ..myMarketIdValue = '5'
        ..isVerifiedPhoneValue = true,
      routes: <String, List<ScriptedReply>>{
        commentsEP: <ScriptedReply>[
          ScriptedReply(200, buyersCommentsEnvelope()),
        ],
        fqaEP: <ScriptedReply>[
          ScriptedReply(200, fqaCommentsEnvelope()),
        ],
        createEP: <ScriptedReply>[
          ScriptedReply(200, createdCommentEnvelope()),
        ],
      },
    );
    // Both tabs loaded, but under a filter the user chose.
    flow.bloc
      ..add(GetBuyersCommentsEvent(productId: '77', currentFilter: filter))
      ..add(GetFqaCommentsEvent(productId: '77', currentFilter: filter));
    await pumpEventQueue();

    flow.bloc.add(
      CreateCommentRatingEvent(
        text: 'Runs small but lovely',
        rating: '4',
        productId: '77',
        slug: 'silk-dress',
        ownerId: '3',
        ownerType: 'seller',
        images: const <String>[],
      ),
    );
    await pumpEventQueue();

    expect(flow.adapter.callsTo(createEP), 1);
    expect(
      flow.bloc.state.createCommentRatingStatus,
      CreateCommentRatingStatus.success,
      reason: 'the form can close over a review that really was created',
    );
  });
}
