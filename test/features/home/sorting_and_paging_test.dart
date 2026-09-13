import 'package:flutter_test/flutter_test.dart';
import 'package:trydos/common/constant/configuration/web_app_url.dart';
import 'package:trydos/core/data/model/pagination_model.dart';
import 'package:trydos/features/home/data/models/get_product_filters_model.dart'
    as filters_model;
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_event.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_state.dart';

import '../../helpers/auth_flow_harness.dart';
import '../../helpers/catalogue_fixtures.dart';
import '../../helpers/catalogue_flow_harness.dart';
import '../../helpers/network_harness.dart';

/// Test ledger · wave 03 Browsing, search and the product page · unit
/// "Sorting and paging".
///
/// A listing is a list that grows: page one, then each next page appended as
/// the user scrolls, each asked for with the **cursor** the page before it
/// returned (`offset` — a search-after pair, not a page number). Two things
/// can go wrong, and both look like the same bug on screen — products in the
/// wrong order, or products the user saw a second ago appearing again:
///
/// - a change of order (a new sort) must start a new list from page one, never
///   add its results to the end of the old one;
/// - a request that is overtaken must not land. The user changes the sort, the
///   old search answers late, and its products overwrite the new list.
///
/// **Which list the page reads.** Results are kept per key:
/// `boutique + (cashed ? "withoutFilter" : "") + category`. The unfiltered,
/// unsorted list of a boutique lives under `…withoutFilter…`; a filtered or
/// sorted load lives under the bare key. `state.cashedOrginalBoutique` is the
/// switch the listing page reads to pick one (`product_listing_page.dart`), so
/// every assertion about "the list on screen" goes through [onScreen] below.
void main() {
  BoutiqueFlowHarness? harness;

  setUpAll(setUpFirebaseMocks);

  tearDown(() async {
    await tearDownBoutiqueFlowHarness(harness);
    harness = null;
  });

  const String search = WebAppEndPoints.searchProductEP;
  const String boutique = 'b1';

  /// The list the listing page is showing, read the way the page reads it.
  PaginationModel<dynamic>? onScreen(BoutiqueState state) =>
      state.getProductListingWithFiltersPaginationModels[
          '$boutique${state.cashedOrginalBoutique ? 'withoutFilter' : ''}'];

  List<int?> idsOnScreen(BoutiqueFlowHarness flow) =>
      (onScreen(flow.bloc.state)?.items ?? <dynamic>[])
          .map((dynamic p) => p.productId as int?)
          .toList();

  Map<String, String> request(BoutiqueFlowHarness flow, int index) =>
      flow.adapter.queryOf(search, index: index)!;

  /// Page one of the boutique, opened the way the listing page opens it.
  GetProductsWithFiltersEvent openListing() => GetProductsWithFiltersEvent(
        boutiqueSlug: boutique,
        offset: 1,
        cashedOrginalBoutique: true,
      );

  /// The next page, asked for the way the listing page asks on scroll.
  GetProductsWithFiltersWithPaginationEvent nextPage() =>
      GetProductsWithFiltersWithPaginationEvent(
        boutiqueSlug: boutique,
        offset: 2,
        getWithPagination: true,
        cashedOrginalBoutique: true,
      );

  test('GetProductsWithFiltersEvent loads page one, and each next page is asked '
      'for with the cursor the last one returned and appended in order',
      () async {
    // Nothing on the client removes a product it has already shown: the cursor
    // is what stops the server sending it twice. So the contract to hold is
    // that the cursor is handed back exactly, and that pages are added, in
    // order, after what is already there.
    final BoutiqueFlowHarness flow = harness = buildBoutiqueFlowHarness(
      routes: <String, List<ScriptedReply>>{
        search: <ScriptedReply>[
          ScriptedReply(
            200,
            productListingEnvelope(
              products: productRange(1, 10),
              offset: const <num>[1.5, 10],
            ),
          ),
          ScriptedReply(
            200,
            productListingEnvelope(
              products: productRange(11, 4),
              offset: const <num>[0.5, 14],
            ),
          ),
        ],
      },
    );

    flow.bloc.add(openListing());
    await pumpEventQueue();

    expect(request(flow, 0).containsKey('offset'), isFalse,
        reason: 'page one starts from the top — no cursor');
    expect(idsOnScreen(flow), <int>[for (int i = 1; i <= 10; i++) i]);
    expect(onScreen(flow.bloc.state)?.hasReachedMax, isFalse,
        reason: 'a full page of ten means there may be more');

    flow.bloc.add(nextPage());
    await pumpEventQueue();

    expect(
      request(flow, 1)['offset'],
      '[1.5, 10.0]',
      reason: 'page two continues from exactly where page one ended',
    );
    expect(
      idsOnScreen(flow),
      <int>[for (int i = 1; i <= 14; i++) i],
      reason: 'appended after page one, in the order the server sent them',
    );
    expect(onScreen(flow.bloc.state)?.hasReachedMax, isTrue,
        reason: 'a short page is the last one — scrolling stops asking');
  });

  test('GetProductsWithFiltersUsingPaginationEvent — the third paging variant '
      'the ledger names — is dead: nothing handles it', () async {
    // It is declared in `boutique_event.dart` and registered by no bloc. The
    // one place that dispatched it is inside a commented-out block in
    // `home_bloc.dart`. Sent anyway, it falls through to `BoutiqueBloc`'s
    // catch-all `on<BoutiqueEvent>((event, emit) {})`. The live paging path is
    // `GetProductsWithFiltersWithPaginationEvent`, covered above.
    final BoutiqueFlowHarness flow = harness = buildBoutiqueFlowHarness(
      routes: <String, List<ScriptedReply>>{},
    );
    final BoutiqueState before = flow.bloc.state;

    flow.bloc.add(
      GetProductsWithFiltersUsingPaginationEvent(
        boutiqueSlug: boutique,
        offset: 2,
      ),
    );
    await pumpEventQueue();

    expect(flow.adapter.callCount, 0);
    expect(flow.bloc.state, before);
  });

  test('ChangeSortEvent starts a new list from page one — it never appends to '
      'the old order', () async {
    final BoutiqueFlowHarness flow = harness = buildBoutiqueFlowHarness(
      routes: <String, List<ScriptedReply>>{
        search: <ScriptedReply>[
          ScriptedReply(200, productListingEnvelope(products: productRange(1, 10),
              offset: const <num>[1.5, 10])),
          ScriptedReply(200, productListingEnvelope(products: productRange(20, 10),
              offset: const <num>[9, 29])),
          ScriptedReply(200, productListingEnvelope(products: productRange(30, 4),
              offset: const <num>[9, 33])),
          ScriptedReply(200, productListingEnvelope(products: productRange(40, 10),
              offset: const <num>[1, 49])),
        ],
      },
    );

    flow.bloc.add(openListing());
    await pumpEventQueue();

    flow.bloc.add(ChangeSortEvent(sortKey: 'price_asc', boutiqueSlug: boutique));
    await pumpEventQueue();

    expect(request(flow, 1)['sort'], 'price_asc');
    expect(request(flow, 1).containsKey('offset'), isFalse,
        reason: 'a new order has no cursor — the old one belongs to the old '
            'order and would skip or repeat products in the new one');
    expect(idsOnScreen(flow), <int>[for (int i = 20; i < 30; i++) i]);

    // Scroll the sorted list, then change the sort again: the second sort must
    // throw away both pages, not keep them.
    flow.bloc.add(nextPage());
    await pumpEventQueue();
    expect(idsOnScreen(flow), <int>[for (int i = 20; i < 34; i++) i]);

    flow.bloc.add(
      ChangeSortEvent(sortKey: 'price_desc', boutiqueSlug: boutique),
    );
    await pumpEventQueue();

    expect(request(flow, 3)['sort'], 'price_desc');
    expect(
      idsOnScreen(flow),
      <int>[for (int i = 40; i < 50; i++) i],
      reason: 'the new order replaces the two pages of the old one',
    );

    flow.bloc.add(
      ChangeSortEvent(sortKey: 'price_desc', boutiqueSlug: boutique),
    );
    await pumpEventQueue();
    expect(flow.adapter.callsTo(search), 4,
        reason: 'tapping the sort that is already active does not reload');
  });

  test('ResetSortEvent returns to the default order: the next load carries no '
      'sort', () async {
    // It clears the key and fetches nothing — it runs on the way out of a
    // listing, when there is nothing on screen to reload.
    final BoutiqueFlowHarness flow = harness = buildBoutiqueFlowHarness(
      routes: <String, List<ScriptedReply>>{
        search: <ScriptedReply>[
          ScriptedReply(200, productListingEnvelope(products: productRange(1, 3))),
        ],
      },
    );

    flow.bloc.add(ChangeSortEvent(sortKey: 'newest', boutiqueSlug: boutique));
    await pumpEventQueue();
    expect(flow.bloc.state.sortKey, 'newest');

    flow.bloc.add(ResetSortEvent());
    await pumpEventQueue();
    expect(flow.bloc.state.sortKey, isEmpty);
    expect(flow.adapter.callsTo(search), 1, reason: 'resetting fetches nothing');

    flow.bloc.add(openListing());
    await pumpEventQueue();
    expect(request(flow, 1).containsKey('sort'), isFalse,
        reason: 'the default order is "no sort sent", not a sort called '
            'default');
    expect(
      flow.bloc.state.getProductListingWithFiltersPaginationModels
          .containsKey('${boutique}withoutFilter'),
      isTrue,
      reason: 'with no sort and no filter the load is the plain list again',
    );
  });

  test('a filter change cancels the search in flight: a late answer never '
      'overwrites the newer list', () async {
    // `GetProductsWithFiltersEvent` is registered `restartable()`. The user
    // changes a filter while the first search is still out; the first search
    // answers *after* the second. Both requests reach the server — the
    // transport is not what cancels — but the first handler has been
    // abandoned, so its answer is dropped instead of painted over the new one.
    final BoutiqueFlowHarness flow = harness = buildBoutiqueFlowHarness(
      routes: <String, List<ScriptedReply>>{
        search: <ScriptedReply>[
          ScriptedReply(
            200,
            productListingEnvelope(products: productRange(1, 2)),
            const Duration(milliseconds: 150),
          ),
          ScriptedReply(200, productListingEnvelope(products: productRange(9, 1))),
        ],
      },
    );

    flow.bloc
      ..add(openListing())
      ..add(
        ChangeAppliedFiltersEvent(
          boutiqueSlug: boutique,
          filtersAppliedByUser: filters_model.GetProductFiltersModel(
            filters: filters_model.Filter(colors: const <String>['red']),
          ),
        ),
      )
      ..add(GetProductsWithFiltersEvent(boutiqueSlug: boutique, offset: 1));
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await pumpEventQueue();

    expect(flow.adapter.callsTo(search), 2,
        reason: 'the first search did go out — it is its answer that is '
            'dropped');
    expect(
      flow.bloc.state.getProductListingWithFiltersPaginationModels[boutique]
          ?.items
          .map((dynamic p) => p.productId),
      <int>[9],
      reason: 'the red list is what the user asked for last',
    );
    expect(
      flow.bloc.state
          .getProductListingWithFiltersPaginationModels['${boutique}withoutFilter']
          ?.paginationStatus,
      isNot(PaginationStatus.success),
      reason: 'the overtaken search never lands — its late products are not '
          'painted anywhere',
    );
  });

  test('GetProductWithFiltersWithoutCancelingPreviousEvents is the one path '
      'that does not cancel: the home screen\'s three rails all land',
      () async {
    // The home screen opens three rails at once — featured, flash deal,
    // recommended (`base_page.dart`). On the restartable path each dispatch
    // would abandon the one before it and only the last rail would ever fill.
    // This event is registered `concurrent()` for exactly that. The slowest
    // rail is sent first on purpose.
    final BoutiqueFlowHarness flow = harness = buildBoutiqueFlowHarness(
      routes: <String, List<ScriptedReply>>{
        WebAppEndPoints.productFeaturedEP: <ScriptedReply>[
          ScriptedReply(
            200,
            productListingEnvelope(products: productRange(1, 2)),
            const Duration(milliseconds: 150),
          ),
        ],
        search: <ScriptedReply>[
          ScriptedReply(200, productListingEnvelope(products: productRange(5, 2))),
        ],
        WebAppEndPoints.productRecommendedEP: <ScriptedReply>[
          ScriptedReply(200, productListingEnvelope(products: productRange(7, 2))),
        ],
      },
    );

    for (final String rail in <String>['*featured*', '*flashDeal*', '*recommended*']) {
      flow.bloc.add(
        GetProductWithFiltersWithoutCancelingPreviousEvents(
          categorySlugs: const <String>[],
          cashedOrginalBoutique: true,
          boutiqueSlug: rail,
        ),
      );
    }
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await pumpEventQueue();

    List<int?>? rail(String slug) => flow.bloc.state
        .getProductListingWithFiltersPaginationModels['${slug}withoutFilter']
        ?.items
        .map((dynamic p) => p.productId as int?)
        .toList();
    expect(rail('*featured*'), <int>[1, 2],
        reason: 'the slowest rail, sent first, still lands');
    expect(rail('*flashDeal*'), <int>[5, 6]);
    expect(rail('*recommended*'), <int>[7, 8]);
    expect(
      flow.adapter.queryOf(search)?['flash-deal'],
      'true',
      reason: 'the flash-deal rail is the catalogue search with the flag on',
    );
  });

  test('ClearAllBoutiquesEvent empties every listing, and the next open fetches '
      'afresh', () async {
    final BoutiqueFlowHarness flow = harness = buildBoutiqueFlowHarness(
      routes: <String, List<ScriptedReply>>{
        search: <ScriptedReply>[
          ScriptedReply(200, productListingEnvelope(products: productRange(1, 3))),
          ScriptedReply(200, productListingEnvelope(products: productRange(4, 2))),
        ],
      },
    );

    flow.bloc.add(openListing());
    await pumpEventQueue();
    expect(idsOnScreen(flow), <int>[1, 2, 3]);

    flow.bloc.add(ClearAllBoutiquesEvent());
    await pumpEventQueue();
    expect(flow.bloc.state.getProductListingWithFiltersPaginationModels, isEmpty,
        reason: 'nothing of the old session is left to paint');

    flow.bloc.add(openListing());
    await pumpEventQueue();
    expect(flow.adapter.callsTo(search), 2);
    expect(idsOnScreen(flow), <int>[4, 5],
        reason: 'the list is the fresh answer, not the old one plus it');
  });

  test('IscashedOreiginBotiqueEvent switches the page back to the original list '
      '— still in memory, so nothing is fetched', () async {
    // The ledger reads this as "marks the listing cached so returning does not
    // refetch". The event only flips `cashedOrginalBoutique`. What makes the
    // return free is the key scheme: a filtered load is stored under its own
    // key, so the boutique's original list is never overwritten, and flipping
    // the switch back (as the filter sheet does when it is cleared) shows it
    // again with no request.
    final BoutiqueFlowHarness flow = harness = buildBoutiqueFlowHarness(
      routes: <String, List<ScriptedReply>>{
        search: <ScriptedReply>[
          ScriptedReply(200, productListingEnvelope(products: productRange(1, 3))),
          ScriptedReply(200, productListingEnvelope(products: productRange(7, 1))),
        ],
      },
    );

    flow.bloc.add(openListing());
    await pumpEventQueue();
    expect(idsOnScreen(flow), <int>[1, 2, 3]);

    flow.bloc
      ..add(
        ChangeAppliedFiltersEvent(
          boutiqueSlug: boutique,
          filtersAppliedByUser: filters_model.GetProductFiltersModel(
            filters: filters_model.Filter(colors: const <String>['red']),
          ),
        ),
      )
      ..add(GetProductsWithFiltersEvent(boutiqueSlug: boutique, offset: 1));
    await pumpEventQueue();
    expect(flow.bloc.state.cashedOrginalBoutique, isFalse);
    expect(idsOnScreen(flow), <int>[7], reason: 'the filtered list is shown');

    final int callsBefore = flow.adapter.callCount;
    flow.bloc.add(
      const IscashedOreiginBotiqueEvent(iscashedOreiginBotique: true),
    );
    await pumpEventQueue();

    expect(flow.bloc.state.cashedOrginalBoutique, isTrue);
    expect(idsOnScreen(flow), <int>[1, 2, 3],
        reason: 'the original list, exactly as it was before the filter');
    expect(flow.adapter.callCount, callsBefore,
        reason: 'going back to it costs no request');
  });
}
