import 'package:flutter_test/flutter_test.dart';
import 'package:trydos/common/constant/configuration/web_app_url.dart';
import 'package:trydos/features/home/data/models/get_product_filters_model.dart'
    as filters_model;
import 'package:trydos/features/home/data/models/get_product_listing_with_filters_model.dart'
    show Category;
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_event.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_state.dart';
import 'package:trydos/features/home/presentation/manager/categoryBloc/category_event.dart';
import 'package:trydos/core/data/model/pagination_model.dart';

import '../../helpers/auth_flow_harness.dart';
import '../../helpers/catalogue_fixtures.dart';
import '../../helpers/catalogue_flow_harness.dart';
import '../../helpers/network_harness.dart';

/// Test ledger · wave 03 Browsing, search and the product page · unit
/// "Filtering a listing".
///
/// A listing's filters live in two places on purpose. **Chosen** is what the
/// user has ticked in the sheet and not yet confirmed; **applied** is what the
/// product list is actually filtered by. The sheet can refresh its own counts
/// as the user ticks, but the product list must not move until they press
/// apply — or every tick would reload the page under their thumb.
///
/// Both halves are keyed by boutique + category, so two listings open one after
/// the other keep their own filters.
///
/// **One path answers two questions.** `api/products/searchInCatalog` returns
/// the product page *and* the filter facets. The only thing that tells the two
/// requests apart is the query: a facet request carries `with_products=false`.
/// Every assertion below that says "no product request went out" is reading
/// that flag, not counting calls to the path.
void main() {
  BoutiqueFlowHarness? harness;

  setUpAll(setUpFirebaseMocks);

  tearDown(() async {
    await tearDownBoutiqueFlowHarness(harness);
    harness = null;
  });

  const String search = WebAppEndPoints.searchProductEP;
  const String boutique = 'b1';
  const String category = 'dresses';
  const String key = '$boutique$category';

  bool isFacetRequest(Map<String, String>? query) =>
      query?['with_products'] == 'false';

  /// Every request that reached `searchInCatalog`, decoded.
  List<Map<String, String>> requests(BoutiqueFlowHarness flow) => <Map<String,
      String>>[
    for (int i = 0; i < flow.adapter.callsTo(search); i++)
      flow.adapter.queryOf(search, index: i)!,
  ];

  filters_model.GetProductFiltersModel filtersOf(filters_model.Filter f) =>
      filters_model.GetProductFiltersModel(filters: f);

  test('GetFiltersEvent returns the filter groups for the current category',
      () async {
    final BoutiqueFlowHarness flow = harness = buildBoutiqueFlowHarness(
      routes: <String, List<ScriptedReply>>{
        search: <ScriptedReply>[
          ScriptedReply(
            200,
            productListingEnvelope(
              products: const <Map<String, dynamic>>[],
              totalSize: 42,
              brands: <Map<String, dynamic>>[
                brandFacet('acme'),
                brandFacet('zeta', id: 4),
              ],
              colors: const <String>['red', 'blue'],
              attributes: <Map<String, dynamic>>[attributeFacet()],
            ),
          ),
        ],
      },
    );

    flow.bloc.add(
      const GetFiltersEvent(boutiqueSlug: boutique, category: category),
    );
    await pumpEventQueue();

    final Map<String, String> query = requests(flow).single;
    expect(isFacetRequest(query), isTrue,
        reason: 'the sheet asks for facets, never for a page of products');
    expect(
      query['category_slugs'],
      '["$category"]',
      reason: 'the facets are the facets of *this* category — a request '
          'without it would offer filters for the whole boutique',
    );
    expect(query['boutique_slugs'], '["$boutique"]');

    expect(
      flow.transitionsOf(
        (BoutiqueState s) => s.getProductFiltersStatus[key],
      ),
      <GetProductFiltersStatus?>[
        null,
        GetProductFiltersStatus.loading,
        GetProductFiltersStatus.success,
      ],
    );

    final filters_model.Filter? facets =
        flow.bloc.state.getProductFiltersModel[key]?.filters;
    expect(
      facets?.brands?.map((filters_model.Brand b) => b.slug),
      <String>['acme', 'zeta'],
    );
    expect(facets?.colors, <String>['red', 'blue']);
    expect(facets?.attributes?.single.options, <String>['S', 'M', 'L']);
    expect(
      flow.bloc.state.countOfProductExpectedByFiltering?[boutique],
      42,
      reason: 'the "show 42 products" button reads this before anything is '
          'applied',
    );
  });

  test('ChangeSelectedFiltersEvent only marks a filter — no product request '
      'goes out until it is applied', () async {
    // Ticking a brand in the sheet does send ONE request: the facets again,
    // narrowed by what is ticked, so the other groups' counts follow the
    // selection. What it must not send is a product request — that is the
    // page moving under the user's thumb.
    final BoutiqueFlowHarness flow = harness = buildBoutiqueFlowHarness(
      routes: <String, List<ScriptedReply>>{
        search: <ScriptedReply>[
          ScriptedReply(
            200,
            productListingEnvelope(
              products: const <Map<String, dynamic>>[],
              brands: <Map<String, dynamic>>[brandFacet('acme')],
            ),
          ),
        ],
      },
    );

    flow.bloc.add(
      ChangeSelectedFiltersEvent(
        boutiqueSlug: boutique,
        category: category,
        filtersChoosedByUser: filtersOf(
          filters_model.Filter(
            brands: <filters_model.Brand>[filters_model.Brand(slug: 'acme')],
          ),
        ),
      ),
    );
    await pumpEventQueue();

    expect(
      flow.bloc.state.choosedFiltersByUser[key]?.filters?.brands?.single.slug,
      'acme',
    );
    expect(
      flow.bloc.state.appliedFiltersByUser[key],
      isNull,
      reason: 'chosen is not applied — the product list is still filtered by '
          'whatever was applied before',
    );

    expect(
      requests(flow).where((Map<String, String> q) => !isFacetRequest(q)),
      isEmpty,
      reason: 'a tick must never reload the product list',
    );
    expect(
      requests(flow).single['brand_slugs'],
      '["acme"]',
      reason: 'the facet refresh is narrowed by the tick, so the counts next '
          'to every other filter are the counts *with* this brand',
    );
  });

  test('ChangeAppliedFiltersEvent stores the filters, and the fetch that '
      'follows carries every one of them', () async {
    // The ledger has `ChangeAppliedFiltersEvent` do the fetching. It does not:
    // it records what was applied and returns. The listing then dispatches
    // `GetProductsWithFiltersEvent`, which reads the applied filters back out
    // of the state. The contract that matters — nothing applied is lost on the
    // way to the server — is asserted across both.
    //
    // One attribute, several options: that is the only attribute shape the
    // app builds. The size sheet folds every chosen value into `attributes[0]`
    // (`sizes_filters_list.dart`), and the listing forwards exactly that entry.
    final BoutiqueFlowHarness flow = harness = buildBoutiqueFlowHarness(
      routes: <String, List<ScriptedReply>>{
        search: <ScriptedReply>[
          ScriptedReply(200, productListingEnvelope(products: productRange(1, 2))),
        ],
      },
    );

    flow.bloc.add(
      ChangeAppliedFiltersEvent(
        boutiqueSlug: boutique,
        category: category,
        filtersAppliedByUser: filtersOf(
          filters_model.Filter(
            brands: <filters_model.Brand>[
              filters_model.Brand(slug: 'acme'),
              filters_model.Brand(slug: 'zeta'),
            ],
            categories: <Category>[Category(slug: 'maxi')],
            colors: const <String>['red'],
            attributes: <filters_model.Attribute>[
              filters_model.Attribute(
                id: 5,
                name: 'Size',
                options: const <String>['M', 'L'],
              ),
            ],
            prices: filters_model.Prices(minPrice: 10, maxPrice: 90),
          ),
        ),
      ),
    );
    await pumpEventQueue();

    expect(flow.adapter.callCount, 0,
        reason: 'applying records the filters; it does not fetch by itself');
    expect(
      flow.bloc.state.appliedFiltersByUser[key]?.filters?.brands?.length,
      2,
    );

    flow.bloc.add(
      GetProductsWithFiltersEvent(
        boutiqueSlug: boutique,
        category: category,
        offset: 1,
      ),
    );
    await pumpEventQueue();

    final Map<String, String> query = requests(flow).single;
    expect(isFacetRequest(query), isFalse);
    expect(query['brand_slugs'], '["acme", "zeta"]');
    expect(
      query['category_slugs'],
      '["maxi", "$category"]',
      reason: 'the applied sub-category narrows the listing; the listing\'s '
          'own category is kept alongside it, not replaced by it',
    );
    expect(query['colors'], '["red"]');
    expect(query['attributes'], allOf(contains('Size'), contains('"M"'),
        contains('"L"')));
    expect(query['price'], '["10.0-90.0"]');

    expect(
      flow.bloc.state
          .getProductListingWithFiltersPaginationModels[key]
          ?.items
          .length,
      2,
      reason: 'a filtered result is kept under the filtered key …',
    );
    expect(
      flow.bloc.state.getProductListingWithFiltersPaginationModels
          .containsKey('${boutique}withoutFilter$category'),
      isFalse,
      reason: '… so it never overwrites the unfiltered list the user will go '
          'back to',
    );
  });

  test('ResetAllSelectedAppliedFilterEvent clears chosen and applied, and the '
      'next load of the listing is unfiltered', () async {
    // The ledger says the reset "refetches unfiltered". It does not fetch, and
    // it should not: it is dispatched on the way *out* of a listing — a tab
    // switch, the bottom bar, opening chat or the cart — when there is no
    // listing on screen to reload. What it guarantees is that whichever listing
    // opens next starts clean, which is asserted here through that next load.
    final BoutiqueFlowHarness flow = harness = buildBoutiqueFlowHarness(
      routes: <String, List<ScriptedReply>>{
        search: <ScriptedReply>[
          ScriptedReply(200, productListingEnvelope(products: productRange(1, 3))),
        ],
      },
    );

    final filters_model.GetProductFiltersModel acme = filtersOf(
      filters_model.Filter(
        brands: <filters_model.Brand>[filters_model.Brand(slug: 'acme')],
      ),
    );
    flow.bloc
      ..add(ChangeAppliedFiltersEvent(boutiqueSlug: boutique, category: category,
          filtersAppliedByUser: acme))
      ..add(ChangeSelectedFiltersEvent(boutiqueSlug: boutique, category: category,
          filtersChoosedByUser: acme, requestToUpdateFilters: false))
      ..add(AddPrefAppliedFilterForExtendFilterEvent(
          prefAppliedFilter: acme.filters));
    await pumpEventQueue();
    expect(flow.bloc.state.appliedFiltersByUser[key], isNotNull);
    expect(flow.bloc.state.choosedFiltersByUser[key], isNotNull);

    flow.bloc.add(ResetAllSelectedAppliedFilterEvent());
    await pumpEventQueue();

    expect(flow.bloc.state.appliedFiltersByUser, isEmpty);
    expect(flow.bloc.state.choosedFiltersByUser, isEmpty);
    expect(
      flow.bloc.state.prefAppliedFilterForExtendFilter?.brands,
      isNull,
      reason: 'the "last time" filters go too, or the next listing would '
          'quietly restore them',
    );
    expect(flow.adapter.callCount, 0, reason: 'nothing is on screen to reload');

    expect(
      flow.category.eventsOf<ReplyFromGeminiEvent>()
          .map((ReplyFromGeminiEvent e) => e.resetTheReply),
      <bool>[true, true],
      reason: 'the Gemini suggestion is dropped for the search screen and the '
          'listing both — otherwise the next search starts pre-filled',
    );

    flow.bloc.add(
      GetProductsWithFiltersEvent(
        boutiqueSlug: boutique,
        category: category,
        offset: 1,
      ),
    );
    await pumpEventQueue();

    final Map<String, String> next = requests(flow).single;
    expect(next.containsKey('brand_slugs'), isFalse,
        reason: 'the reset brand must not ride along on the next load');
    expect(
      flow.bloc.state.getProductListingWithFiltersPaginationModels
          .containsKey('${boutique}withoutFilter$category'),
      isTrue,
      reason: 'an unfiltered load lands under the unfiltered key',
    );
  });

  /// The facets a link to acme / maxi / red comes back with.
  Map<String, List<ScriptedReply>> linkRoutes() => <String, List<ScriptedReply>>{
        search: <ScriptedReply>[
          ScriptedReply(
            200,
            productListingEnvelope(
              products: const <Map<String, dynamic>>[],
              brands: <Map<String, dynamic>>[brandFacet('acme')],
              categories: <Map<String, dynamic>>[
                <String, dynamic>{'id': 21, 'name': 'Maxi', 'slug': 'maxi'},
              ],
            ),
          ),
        ],
      };

  GetFiltersForNavigatorFromLinkToListingPageEvent linkToAcme() =>
      GetFiltersForNavigatorFromLinkToListingPageEvent(
        boutiqueSlug: boutique,
        filtersChoosedByUser: filtersOf(
          filters_model.Filter(
            brands: <filters_model.Brand>[filters_model.Brand(slug: 'acme')],
            categories: <Category>[Category(slug: 'maxi')],
            colors: const <String>['red'],
          ),
        ),
      );

  test('a deep link opens the listing with the link\'s filters applied',
      () async {
    // The link carries slugs only. The handler asks for the facets narrowed by
    // those slugs, then keeps the full facet objects the server returns — the
    // name and icon the chips need — under the key "link".
    //
    // This is the *warm* path: some listing action has already run this
    // session. The reset below is what the tab bar dispatches on every switch.
    // Why it matters is the next test.
    final BoutiqueFlowHarness flow = harness = buildBoutiqueFlowHarness(
      routes: linkRoutes(),
    );
    flow.bloc.add(ResetAllSelectedAppliedFilterEvent());
    await pumpEventQueue();

    flow.bloc.add(linkToAcme());
    await pumpEventQueue();

    final Map<String, String> query = requests(flow).single;
    expect(isFacetRequest(query), isTrue);
    expect(query['brand_slugs'], '["acme"]');
    expect(query['category_slugs'], '["maxi"]');
    expect(query['colors'], '["red"]');

    expect(
      flow.transitionsOf(
        (BoutiqueState s) => s.getFiltersForNavigatorFromLinkToListingPageStatus,
      ).last,
      GetFiltersForNavigatorFromLinkToListingPageStatus.success,
    );
    final filters_model.Filter? applied =
        flow.bloc.state.appliedFiltersByUser['link']?.filters;
    expect(applied?.brands?.single.name, 'acme',
        reason: 'the chip shows the server\'s brand, not a bare slug');
    expect(applied?.brands?.single.icon?.filePath, isNotNull);
    expect(applied?.categories?.single.name, 'Maxi');
    expect(applied?.colors, <String>['red']);
  });

  test('a deep link works from a cold start too — nothing has to have run '
      'before it', () async {
    // This was a defect: the handler wrote into `state.appliedFiltersByUser`
    // itself, and on a cold start that is the initial `const {}`. `addAll`
    // threw between the loading emit and the success one, so a user who opened
    // the app *from a link* got a spinner that never stopped — while anyone who
    // had browsed first was fine, because any earlier filter action replaces
    // the map with a writable copy. Fixed by copying the map; this is the case
    // that used to fail.
    final BoutiqueFlowHarness flow = harness = buildBoutiqueFlowHarness(
      routes: linkRoutes(),
    );

    flow.bloc.add(linkToAcme());
    await pumpEventQueue();

    expect(
      flow.bloc.state.getFiltersForNavigatorFromLinkToListingPageStatus,
      GetFiltersForNavigatorFromLinkToListingPageStatus.success,
    );
    expect(
      flow.bloc.state.appliedFiltersByUser['link']?.filters?.brands?.single.name,
      'acme',
      reason: "the link's filters are applied on the first thing the app does",
    );
  });

  test('GetFiltersWithPaginatioEvent pages the facets themselves, and stops '
      'once a page comes back short', () async {
    // A boutique with many brands cannot send every one in the first facet
    // answer. The sheet asks for the next page as the user scrolls a group;
    // each page is appended, in order, and paging stops for good once no group
    // on a page is full.
    final BoutiqueFlowHarness flow = harness = buildBoutiqueFlowHarness(
      routes: <String, List<ScriptedReply>>{
        search: <ScriptedReply>[
          ScriptedReply(
            200,
            productListingEnvelope(
              products: const <Map<String, dynamic>>[],
              brands: <Map<String, dynamic>>[
                for (int i = 0; i < 10; i++) brandFacet('brand-$i', id: i),
              ],
              attributes: <Map<String, dynamic>>[
                attributeFacet(options: const <String>['S', 'M']),
              ],
            ),
          ),
          ScriptedReply(
            200,
            productListingEnvelope(
              products: const <Map<String, dynamic>>[],
              brands: <Map<String, dynamic>>[
                for (int i = 10; i < 13; i++) brandFacet('brand-$i', id: i),
              ],
              attributes: <Map<String, dynamic>>[
                attributeFacet(options: const <String>['XL']),
              ],
            ),
          ),
        ],
      },
    );

    flow.bloc.add(
      const GetFiltersEvent(boutiqueSlug: boutique, category: category),
    );
    await pumpEventQueue();
    expect(flow.bloc.state.finishGetAllFilter, isFalse,
        reason: 'a full group of ten means there may be more');

    flow.bloc.add(
      const GetFiltersWithPaginatioEvent(
        boutiqueSlug: boutique,
        category: category,
      ),
    );
    await pumpEventQueue();

    expect(requests(flow)[0]['filters_offset'], '1');
    expect(
      requests(flow)[1]['filters_offset'],
      '2',
      reason: 'the second facet request asks for the second page',
    );

    final filters_model.Filter? facets =
        flow.bloc.state.getProductFiltersModel[key]?.filters;
    expect(
      facets?.brands?.map((filters_model.Brand b) => b.slug).toList(),
      <String>[for (int i = 0; i < 13; i++) 'brand-$i'],
      reason: 'page two is appended after page one, not swapped in for it',
    );
    expect(facets?.attributes?.single.options, <String>['S', 'M', 'XL']);
    expect(flow.bloc.state.finishGetAllFilter, isTrue,
        reason: 'no group on page two was full');

    flow.bloc.add(
      const GetFiltersWithPaginatioEvent(
        boutiqueSlug: boutique,
        category: category,
      ),
    );
    await pumpEventQueue();
    expect(flow.adapter.callsTo(search), 2,
        reason: 'once finished, scrolling a group asks nothing more');
  });

  test('paging the facets works for a boutique with no size attribute',
      () async {
    // This was a defect: the merge asked
    // `(data[key]?.filters?.attributes ?? 0) == 0` for "no attributes yet", but
    // `Filter.fromJson` turns a missing or empty `attributes` into `[]`, never
    // null — so the comparison was `[] == 0`, always false, and the next line
    // read `attributes[0]` on an empty list. The `RangeError` landed in the
    // handler's own `catch`, which emitted the status and dropped the page, so
    // any boutique that does not sell sized products lost every facet page
    // after the first.
    final BoutiqueFlowHarness flow = harness = buildBoutiqueFlowHarness(
      routes: <String, List<ScriptedReply>>{
        search: <ScriptedReply>[
          ScriptedReply(
            200,
            productListingEnvelope(
              products: const <Map<String, dynamic>>[],
              brands: <Map<String, dynamic>>[
                for (int i = 0; i < 10; i++) brandFacet('brand-$i', id: i),
              ],
            ),
          ),
          ScriptedReply(
            200,
            productListingEnvelope(
              products: const <Map<String, dynamic>>[],
              brands: <Map<String, dynamic>>[
                for (int i = 10; i < 13; i++) brandFacet('brand-$i', id: i),
              ],
            ),
          ),
        ],
      },
    );

    flow.bloc.add(
      const GetFiltersEvent(boutiqueSlug: boutique, category: category),
    );
    await pumpEventQueue();
    flow.bloc.add(
      const GetFiltersWithPaginatioEvent(
        boutiqueSlug: boutique,
        category: category,
      ),
    );
    await pumpEventQueue();

    expect(
      flow.bloc.state.getProductFiltersModel[key]?.filters?.brands?.length,
      13,
      reason: 'both pages are there, with no size attribute anywhere',
    );
    expect(
      flow.bloc.state.getProductFiltersModel[key]?.filters?.attributes
          ?.single.options,
      isEmpty,
      reason: 'and the empty attribute is carried along rather than throwing',
    );
  });

  test('AddSizeAndColorFilterinTextToSearchEvent keeps the chosen size and '
      'colour for the search box, and clearing it clears both', () async {
    // The ledger says this "puts the size and colour into the search text". The
    // bloc does not compose any text: it keeps the map, and the listing page
    // renders it as chips in its search box (`product_listing_page.dart`). No
    // request reads it — the only reader in the bloc is commented out. What
    // the bloc owes the page is that the map is stored as given, and that the
    // close button's empty map really does clear both.
    final BoutiqueFlowHarness flow = harness = buildBoutiqueFlowHarness(
      routes: <String, List<ScriptedReply>>{},
    );

    flow.bloc.add(
      AddSizeAndColorFilterinTextToSearchEvent(
        sizeAndColorFilterinTextToSearch: const <String, List<String>>{
          'size': <String>['M'],
          'color': <String>['red'],
        },
      ),
    );
    await pumpEventQueue();
    expect(
      flow.bloc.state.sizeAndColorFilterinTextToSearch,
      <String, List<String>>{
        'size': <String>['M'],
        'color': <String>['red'],
      },
    );

    flow.bloc.add(
      AddSizeAndColorFilterinTextToSearchEvent(
        sizeAndColorFilterinTextToSearch: const <String, List<String>>{},
      ),
    );
    await pumpEventQueue();
    expect(
      flow.bloc.state.sizeAndColorFilterinTextToSearch,
      isEmpty,
      reason: 'the close button sends an empty map; merging it into the old '
          'one would leave both chips on screen',
    );
    expect(flow.adapter.callCount, 0);
  });

  test('AddPrefAppliedFilterForExtendFilterEvent keeps the filters the user '
      'had last time for the expanded sheet', () async {
    // The expanded filter sheet opens pre-ticked with these
    // (`product_listing_page.dart` reads them when it builds the sheet).
    final BoutiqueFlowHarness flow = harness = buildBoutiqueFlowHarness(
      routes: <String, List<ScriptedReply>>{},
    );

    final filters_model.Filter lastTime = filters_model.Filter(
      brands: <filters_model.Brand>[filters_model.Brand(slug: 'acme')],
      colors: const <String>['red'],
    );
    flow.bloc.add(
      AddPrefAppliedFilterForExtendFilterEvent(prefAppliedFilter: lastTime),
    );
    await pumpEventQueue();

    expect(
      flow.bloc.state.prefAppliedFilterForExtendFilter?.brands?.single.slug,
      'acme',
    );
    expect(flow.bloc.state.prefAppliedFilterForExtendFilter?.colors,
        <String>['red']);
    expect(flow.adapter.callCount, 0,
        reason: 'restoring the sheet is local — nothing is fetched');
  });

  test('an empty result is an empty list, not an error state', () async {
    // A filter combination nothing matches is a normal answer. The listing
    // shows "no products" for it; an error state would show "try again" — and
    // trying again would return the same nothing.
    final BoutiqueFlowHarness flow = harness = buildBoutiqueFlowHarness(
      routes: <String, List<ScriptedReply>>{
        search: <ScriptedReply>[
          ScriptedReply(
            200,
            productListingEnvelope(
              products: const <Map<String, dynamic>>[],
              totalSize: 0,
            ),
          ),
        ],
      },
    );

    flow.bloc.add(
      GetProductsWithFiltersEvent(
        boutiqueSlug: boutique,
        category: category,
        offset: 1,
      ),
    );
    await pumpEventQueue();

    final PaginationModel<dynamic>? page = flow.bloc.state
        .getProductListingWithFiltersPaginationModels[
            '${boutique}withoutFilter$category'];
    expect(page?.paginationStatus, PaginationStatus.success);
    expect(page?.items, isEmpty);
    expect(page?.hasReachedMax, isTrue,
        reason: 'nothing more to page in, so the list stops asking');
    expect(flow.bloc.state.countOfProductExpectedByFiltering?[boutique], 0);
  });
}

