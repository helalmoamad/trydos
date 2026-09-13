import 'package:flutter_test/flutter_test.dart';
import 'package:trydos/features/home/data/models/get_product_detail_without_related_products_model.dart'
    show Variation;
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';

import '../../helpers/auth_flow_harness.dart';
import '../../helpers/catalogue_fixtures.dart';
import '../../helpers/home_flow_harness.dart';
import '../../helpers/network_harness.dart';
import '../../helpers/session_prefs.dart';

/// Test ledger · wave 03 Browsing, search and the product page · unit
/// "Choosing a variant".
///
/// A product is not one thing to buy. Red in S and red in M are different rows
/// with their own stock and their own price, and the page has to keep up: only
/// the sizes that exist in the chosen colour may be offered, the price has to
/// follow the pick, and a variant that just sold out has to be stepped away
/// from before the user taps add-to-cart.
///
/// **How a pick becomes a variant.** The bloc keeps the two halves apart —
/// `currentSelectedColorForEveryProduct[slug]` is the index of the chosen
/// colour, `currentColorSizeForCart` is the chosen size — and the page joins
/// them into `"<colour>-<size>"` and looks that string up against the `type` of
/// each variation in the **stock** payload
/// (`product_details_page.dart:1817-1826`). That is where a variant's own price
/// and quantity come from; the product payload itself does not carry them.
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

  /// The stock rows of the fixture product: red S in stock, red M sold out,
  /// blue M in stock and dearer. The red rows take the fixture's default price
  /// of 120 — the same as the product — which is the point of the price test.
  List<Map<String, dynamic>> stockRows() => <Map<String, dynamic>>[
        productVariation(id: 1, color: 'red', size: 'S', qty: 4),
        productVariation(id: 2, color: 'red', size: 'M', qty: 0),
        productVariation(id: 3, color: 'blue', size: 'M', qty: 7, price: 155),
      ];

  HomeFlowHarness openProduct() => buildHomeFlowHarness(
        prefs: SessionPrefs()
          ..marketTokenValue = 'market-token'
          ..myMarketIdValue = '5',
        routes: <String, List<ScriptedReply>>{
          detailsEP: <ScriptedReply>[
            ScriptedReply(200, productDetailsEnvelope()),
          ],
          quantityEP: <ScriptedReply>[
            ScriptedReply(
              200,
              productQuantityEnvelope(variations: stockRows()),
            ),
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
        },
      );

  /// The lookup the product page performs, done here so a test can show what
  /// the page would land on.
  Variation? variantOnScreen(HomeFlowHarness flow, String colourOption) {
    final String size =
        flow.bloc.state.currentColorSizeForCart?['choiceOption'] ?? '';
    final String type = size.isEmpty ? colourOption : '$colourOption-$size';
    return flow.bloc.state.authProductDetailsModel?.data?.variation
        ?.where((Variation v) => v.type?.contains(type) ?? false)
        .firstOrNull;
  }

  test('the chosen colour is kept per product, and the chosen size beside it',
      () async {
    // Two halves, two places. The colour is stored **per product slug**, so a
    // colour picked on one product cannot follow the user to another one; the
    // size is a single current pick, because only one product is open.
    final HomeFlowHarness flow = harness = openProduct();

    flow.bloc.add(
      const AddCurrentSelectedColorEvent(
        currentSelectedColor: 1,
        productSlug: 'silk-dress',
      ),
    );
    await pumpEventQueue();

    expect(
      flow.transitionsOf(
        (HomeState s) => s.currentSelectedColorForEveryProductStatus,
      ).last,
      CurrentSelectedColorForEveryProductStatus.success,
    );
    expect(flow.bloc.state.currentSelectedColorForEveryProduct['silk-dress'], 1);

    flow.bloc.add(
      const AddCurrentSelectedColorEvent(
        currentSelectedColor: 0,
        productSlug: 'linen-shirt',
      ),
    );
    await pumpEventQueue();

    expect(
      flow.bloc.state.currentSelectedColorForEveryProduct,
      <String, int>{'silk-dress': 1, 'linen-shirt': 0},
      reason: 'each product keeps its own colour — going back to the first one '
          'shows the colour it was left on',
    );

    flow.bloc.add(
      AddCurrentColorSizeEvent(choice_1: 'M', choiceOption: 'M'),
    );
    await pumpEventQueue();

    expect(
      flow.bloc.state.currentColorSizeForCart,
      <String, String>{'size': 'M', 'choiceOption': 'M'},
      reason: 'the size the cart line will be built from',
    );
  });

  test('AddSizesForColorsEvent offers only the sizes that exist in the chosen '
      'colour', () async {
    // Red has S and M; blue has only M. Offering M in blue is fine, offering S
    // in blue would let the user add a row the warehouse does not have.
    final HomeFlowHarness flow = harness = openProduct();

    flow.bloc.add(
      AddSizesForColorsEvent(
        currentColorName: 'red',
        variation: stockRows()
            .map((Map<String, dynamic> v) => Variation.fromJson(v))
            .toList(),
      ),
    );
    await pumpEventQueue();

    expect(
      flow.bloc.state.sizesForEachColor,
      <String>['S', 'M'],
      reason: 'both red rows, in the order the stock answer lists them',
    );
    expect(
      flow.bloc.state.sizesQuantitiesForEachColor,
      <int>[4, 0],
      reason: 'with their quantities alongside — the zero is what greys out '
          'red / M rather than hiding it',
    );
    expect(
      flow.transitionsOf((HomeState s) => s.changeSizesForEveryProduct).last,
      ChangeSizesForEveryProduct.success,
    );

    flow.bloc.add(
      AddSizesForColorsEvent(
        currentColorName: 'blue',
        variation: stockRows()
            .map((Map<String, dynamic> v) => Variation.fromJson(v))
            .toList(),
      ),
    );
    await pumpEventQueue();

    expect(
      flow.bloc.state.sizesForEachColor,
      <String>['M'],
      reason: 'blue exists in M only — S must not be offered in blue',
    );
    expect(flow.bloc.state.sizesQuantitiesForEachColor, <int>[7]);
  });

  test('the price follows the chosen variant, not the base product', () async {
    // The product says 120. Blue / M is 155. Whichever the user is looking at
    // is what has to be charged, and the join that decides it is the variant
    // `type`.
    final HomeFlowHarness flow = harness = openProduct();

    flow.bloc.add(const GetFullProductDetailsEvent(productSlug: 'silk-dress'));
    await pumpEventQueue();

    final dynamic product =
        flow.bloc.state.cachedProductWithoutRelatedProductsModel['77']?.product;
    expect(product?.price, 120.0, reason: 'the product\'s own price');

    flow.bloc.add(AddCurrentColorSizeEvent(choice_1: 'M', choiceOption: 'M'));
    await pumpEventQueue();

    expect(
      variantOnScreen(flow, 'blue')?.price,
      155.0,
      reason: 'blue / M is dearer than the product it belongs to, and it is '
          'the blue / M price the page must show',
    );
    expect(
      variantOnScreen(flow, 'red')?.price,
      120.0,
      reason: 'while red / M is the product price — same product, two prices, '
          'chosen by the variant',
    );
    expect(
      variantOnScreen(flow, 'red')?.qty,
      0,
      reason: 'and the same lookup is what knows red / M cannot be bought',
    );
  });

  test('IsChangedVariationWhenQtyZeroEvent raises the flag the page steps away '
      'from a sold-out variant on', () async {
    // The bloc does not choose the replacement variant — the page does, from
    // the sizes and quantities above. What the bloc owns is the signal, and
    // the "finished" flag that stops the page doing it twice.
    final HomeFlowHarness flow = harness = openProduct();

    expect(flow.bloc.state.isChangedvariationWhenQtyZero, isFalse,
        reason: 'nothing to step away from on a fresh page');

    flow.bloc.add(
      const IsChangedVariationWhenQtyZeroEvent(
        isChangedVariationWhenQtyZero: true,
        finishLoadingAfterChangedVariationWhenQtyZero: false,
      ),
    );
    await pumpEventQueue();

    expect(flow.bloc.state.isChangedvariationWhenQtyZero, isTrue);
    expect(
      flow.bloc.state.finishLoadingAfterChangedVariationWhenQtyZero,
      isFalse,
      reason: 'the move is under way — the page holds its spinner until it is '
          'told the new variant has settled',
    );

    flow.bloc.add(
      const IsChangedVariationWhenQtyZeroEvent(
        isChangedVariationWhenQtyZero: false,
      ),
    );
    await pumpEventQueue();

    expect(flow.bloc.state.isChangedvariationWhenQtyZero, isFalse);
    expect(
      flow.bloc.state.finishLoadingAfterChangedVariationWhenQtyZero,
      isTrue,
      reason: 'and the default puts the page back to normal',
    );
  });
}
