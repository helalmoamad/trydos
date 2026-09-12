import 'package:flutter_test/flutter_test.dart';
import 'package:trydos/common/constant/configuration/elastic_url_routes.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';

import '../../helpers/auth_flow_harness.dart';
import '../../helpers/catalogue_fixtures.dart';
import '../../helpers/home_flow_harness.dart';
import '../../helpers/network_harness.dart';
import '../../helpers/session_prefs.dart';

/// Test ledger · wave 03 Browsing, search and the product page · unit
/// "Loading the details".
///
/// Opening a product fans out. One request brings the product itself — price,
/// colours, sizes, images, the variations that decide what can actually be
/// bought — and three more follow it: the live stock for this user, the related
/// rail, and the delivery estimate. The page must be usable as soon as the
/// first one lands; the rest fill in around it.
///
/// **Where the page reads from.** Not from a "current product" field — there is
/// none. Everything is kept per product id in
/// `cachedProductWithoutRelatedProductsModel`, which is what the product
/// widgets read (`buyer_comment.dart`, `buyers_comments_panel.dart`), so two
/// products opened one after the other do not overwrite each other.
void main() {
  HomeFlowHarness? harness;

  setUpAll(setUpFirebaseMocks);

  tearDown(() async {
    await tearDownHomeFlowHarness(harness);
    harness = null;
  });

  const String detailsEP = 'api/mobile/product/details/';
  const String quantityEP = 'api/mobile/product/qty/';
  const String relatedEP = 'api/related-products/';
  const String deliveryEP = 'api/v1/web/product/delivery_times/';
  const String storiesEP = 'api/v1/stories/product_stories/';

  /// The two calls the details handler fans out to that no test here is about.
  Map<String, List<ScriptedReply>> quietFanOut() => <String, List<ScriptedReply>>{
        deliveryEP: <ScriptedReply>[
          const ScriptedReply(200, <String, dynamic>{'data': <dynamic>[]}),
        ],
        storiesEP: <ScriptedReply>[
          const ScriptedReply(200, <String, dynamic>{'data': <dynamic>[]}),
        ],
      };

  dynamic productOf(HomeFlowHarness flow, String id) =>
      flow.bloc.state.cachedProductWithoutRelatedProductsModel[id]?.product;

  test('GetFullProductDetailsEvent maps the price, the images and the '
      'variations the page is built from', () async {
    final HomeFlowHarness flow = harness = buildHomeFlowHarness(
      prefs: SessionPrefs()
        ..marketTokenValue = 'market-token'
        ..myMarketIdValue = '5',
      routes: <String, List<ScriptedReply>>{
        detailsEP: <ScriptedReply>[
          ScriptedReply(200, productDetailsEnvelope()),
        ],
        quantityEP: <ScriptedReply>[
          ScriptedReply(200, productQuantityEnvelope()),
        ],
        relatedEP: <ScriptedReply>[
          ScriptedReply(200, relatedProductsEnvelope()),
        ],
        ...quietFanOut(),
      },
    );

    flow.bloc.add(const GetFullProductDetailsEvent(productSlug: 'silk-dress'));
    await pumpEventQueue();

    expect(
      flow.adapter.urlOf(detailsEP),
      contains('silk-dress'),
      reason: 'the product is fetched by the slug the link carried',
    );
    expect(
      flow.adapter.queryOf(detailsEP)?['user_id'],
      '5',
      reason: 'the signed-in id goes with it — the answer carries this user\'s '
          'like state',
    );

    expect(
      flow.bloc.state.productStatus?['77'],
      GetProductDetailWithoutSimilarRelatedProductsStatus.success,
      reason: 'the page keys its own readiness off the product id, so two '
          'products open at once cannot mark each other ready',
    );

    final dynamic product = productOf(flow, '77');
    expect(product?.price, 120.0);
    expect(product?.offerPrice, 99.5,
        reason: 'the price actually charged, when there is an offer');
    expect(product?.images?.length, 2);
    expect(
      (product?.colors as List<dynamic>?)?.map((dynamic c) => c.name),
      <String>['red', 'blue'],
    );
    expect(
      product?.sizes,
      <String>['S', 'M'],
      reason: 'the colours and the sizes are what the page offers; the '
          'sellable combinations behind them arrive with the stock call, '
          'because this model does not expose `variation` at all — the field '
          'is commented out in `get_product_detail_without_related_products_'
          'model.dart`',
    );
  });

  test('opening a product also asks for its live stock, its related rail and '
      'its delivery estimate — the page does not wait for them', () async {
    // The page is built from the details answer. These three fill in after it,
    // and the product is already readable while they are in flight.
    final HomeFlowHarness flow = harness = buildHomeFlowHarness(
      prefs: SessionPrefs()
        ..marketTokenValue = 'market-token'
        ..myMarketIdValue = '5',
      routes: <String, List<ScriptedReply>>{
        detailsEP: <ScriptedReply>[
          ScriptedReply(200, productDetailsEnvelope()),
        ],
        quantityEP: <ScriptedReply>[
          ScriptedReply(200, productQuantityEnvelope(availableQuantity: 11)),
        ],
        relatedEP: <ScriptedReply>[
          ScriptedReply(
            200,
            relatedProductsEnvelope(products: productRange(90, 2)),
            const Duration(milliseconds: 80),
          ),
        ],
        ...quietFanOut(),
      },
    );

    flow.bloc.add(const GetFullProductDetailsEvent(productSlug: 'silk-dress'));
    await pumpEventQueue();

    expect(productOf(flow, '77'), isNotNull,
        reason: 'the product is on screen …');
    expect(flow.bloc.state.relatedProducts, anyOf(isNull, isEmpty),
        reason: '… while the related rail is still coming');

    await Future<void>.delayed(const Duration(milliseconds: 140));
    await pumpEventQueue();

    expect(
      flow.bloc.state.relatedProducts?.map((dynamic p) => p.productId),
      <int>[90, 91],
      reason: 'the rail fills in afterwards',
    );
    expect(
      flow.bloc.state.getRelatedProductsStatus,
      GetRelatedProductsStatus.success,
    );
    expect(flow.adapter.urlOf(relatedEP), contains('77'),
        reason: 'related products are asked for by product id, not slug');
  });

  test('FetchAuthProductDetailsEvent brings the live stock for this user — not '
      'the like state the ledger names', () async {
    // The ledger has this call "add the like state for a logged-in user". Its
    // endpoint is `product/qty/<slug>` and its payload is `available_quantity`
    // plus the per-variation quantities. The like state arrives with the main
    // details payload instead, as `is_liked`, which the request above carries
    // `user_id` for. Both are asserted here so the difference is on record.
    final HomeFlowHarness flow = harness = buildHomeFlowHarness(
      prefs: SessionPrefs()
        ..marketTokenValue = 'market-token'
        ..myMarketIdValue = '5',
      routes: <String, List<ScriptedReply>>{
        detailsEP: <ScriptedReply>[
          ScriptedReply(200, productDetailsEnvelope(isLiked: true)),
        ],
        quantityEP: <ScriptedReply>[
          ScriptedReply(
            200,
            productQuantityEnvelope(
              availableQuantity: 11,
              variations: <Map<String, dynamic>>[
                productVariation(id: 1, color: 'red', size: 'S', qty: 4),
                productVariation(id: 2, color: 'red', size: 'M', qty: 0),
              ],
            ),
          ),
        ],
        relatedEP: <ScriptedReply>[
          ScriptedReply(200, relatedProductsEnvelope()),
        ],
        ...quietFanOut(),
      },
    );

    flow.bloc.add(const FetchAuthProductDetailsEvent('silk-dress'));
    await pumpEventQueue();

    expect(
      flow.transitionsOf((HomeState s) => s.authProductDetailsStatus),
      <AuthProductDetailsStatus>[
        AuthProductDetailsStatus.init,
        AuthProductDetailsStatus.loading,
        AuthProductDetailsStatus.success,
      ],
    );
    expect(
      flow.bloc.state.authProductDetailsModel?.data?.availableQuantity,
      11,
      reason: 'how many are left — the add-to-cart button is bounded by this',
    );
    expect(
      flow.bloc.state.authProductDetailsModel?.data?.variation
          ?.map((dynamic v) => v.qty),
      <int>[4, 0],
      reason: 'and per variation, so a sold-out size can be disabled',
    );

    // And the like state, for contrast: it comes with the product itself.
    flow.bloc.add(const GetFullProductDetailsEvent(productSlug: 'silk-dress'));
    await pumpEventQueue();
    expect(
      productOf(flow, '77')?.isLiked,
      isTrue,
      reason: 'the like is part of the details payload, keyed to the user_id '
          'that request carried',
    );
  });

  test('GetProductDatailsWithoutRelatedProductsEvent renders the page on its '
      'own, without the related rail', () async {
    // The lighter path, used when a product is opened from somewhere that
    // already has most of it. It fills the same per-id cache the page reads, so
    // the page is complete without a related request ever going out.
    final HomeFlowHarness flow = harness = buildHomeFlowHarness(
      prefs: SessionPrefs()
        ..marketTokenValue = 'market-token'
        ..myMarketIdValue = '5',
      routes: <String, List<ScriptedReply>>{
        detailsEP: <ScriptedReply>[
          ScriptedReply(200, productDetailsEnvelope()),
        ],
        quantityEP: <ScriptedReply>[
          ScriptedReply(200, productQuantityEnvelope()),
        ],
        ...quietFanOut(),
      },
    );

    flow.bloc.add(
      const GetProductDatailsWithoutRelatedProductsEvent(
        // The lighter path files the answer under the id it was given, not the
        // one the server returns, so the caller has to know it already.
        productId: '77',
        productSlug: 'silk-dress',
        fromListingPage: true,
      ),
    );
    await pumpEventQueue();

    expect(productOf(flow, '77')?.price, 120.0,
        reason: 'the page has everything it needs to paint');
    expect(
      flow.bloc.state.productStatus?['77'],
      GetProductDetailWithoutSimilarRelatedProductsStatus.success,
    );
    expect(flow.adapter.callsTo(relatedEP), 0,
        reason: 'and the related rail was never asked for');
  });

  test('GetAndAddCountViewOfProductEvent records the view — but nothing in the '
      'app dispatches it', () async {
    // The ledger asks for "a view counted once per product per session". The
    // handler has no such guard: every dispatch sends another request, and the
    // status map it keeps is only a record of the last attempt. It does not
    // matter today, because **both** places that would dispatch it — inside
    // `_onGetProductDatailsWithoutRelatedProductsEvent` and inside
    // `_onGetFullProductDetailsEvent` — are commented out, and no widget
    // dispatches it either. Opening a product counts no views at all.
    //
    // This test holds both halves: the handler works when driven, and twice
    // means twice. If view counting is switched back on, the second assertion
    // is the one to look at.
    final HomeFlowHarness flow = harness = buildHomeFlowHarness(
      prefs: SessionPrefs()
        ..marketTokenValue = 'market-token'
        ..myMarketIdValue = '5',
      routes: <String, List<ScriptedReply>>{
        detailsEP: <ScriptedReply>[
          ScriptedReply(200, productDetailsEnvelope()),
        ],
        quantityEP: <ScriptedReply>[
          ScriptedReply(200, productQuantityEnvelope()),
        ],
        relatedEP: <ScriptedReply>[
          ScriptedReply(200, relatedProductsEnvelope()),
        ],
        ElasticEndPoints.getAndAddCountViewOfProductEP: <ScriptedReply>[
          const ScriptedReply(200, <String, dynamic>{
            'data': <String, dynamic>{'count_view': 1},
          }),
        ],
        ...quietFanOut(),
      },
    );

    flow.bloc.add(const GetFullProductDetailsEvent(productSlug: 'silk-dress'));
    await pumpEventQueue();
    expect(
      flow.adapter.callsTo(ElasticEndPoints.getAndAddCountViewOfProductEP),
      0,
      reason: 'opening a product counts no view — both dispatches are '
          'commented out',
    );

    flow.bloc
      ..add(GetAndAddCountViewOfProductEvent(productId: '77'))
      ..add(GetAndAddCountViewOfProductEvent(productId: '77'));
    await pumpEventQueue();

    expect(
      flow.adapter.callsTo(ElasticEndPoints.getAndAddCountViewOfProductEP),
      2,
      reason: 'driven twice it counts twice — there is no once-per-session '
          'guard in the handler, only a status map',
    );
    expect(
      flow.bloc.state.getAndAddCountViewOfProductStatus['77'],
      GetAndAddCountViewOfProductStatus.loading,
      reason: 'and it never leaves loading: the whole success branch of the '
          'handler is commented out, so a counted view emits nothing',
    );
  });
}
