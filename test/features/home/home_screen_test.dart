import 'package:flutter_test/flutter_test.dart';
import 'package:trydos/common/constant/configuration/web_app_url.dart';
import 'package:trydos/core/data/model/pagination_model.dart';
import 'package:trydos/features/home/presentation/manager/categoryBloc/category_event.dart';
import 'package:trydos/features/home/presentation/manager/categoryBloc/category_state.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';

import '../../helpers/auth_flow_harness.dart';
import '../../helpers/catalogue_fixtures.dart';
import '../../helpers/catalogue_flow_harness.dart';
import '../../helpers/network_harness.dart';
import '../../helpers/session_prefs.dart';

/// Test ledger · wave 03 Browsing, search and the product page · unit
/// "The home screen".
///
/// The home screen is a row of main-category tabs with a list of boutique cards
/// under the selected one. `CategoryBloc` owns both, and both are
/// **cache-then-network**: the last successful answer is kept in preferences,
/// painted the moment the screen opens, and replaced when the server answers.
/// That is why the screen has no empty first frame, and why a tab the user goes
/// back to is filled before the request for it returns.
///
/// The boutiques of each tab are kept in
/// `getHomeBoutiquesPaginationObjectByMainCategory`, keyed by category slug.
/// The "all" tab is the slug `Empty`, which the request drops rather than
/// sends.
void main() {
  CategoryFlowHarness? harness;

  setUpAll(setUpFirebaseMocks);

  tearDown(() async {
    await tearDownCategoryFlowHarness(harness);
    harness = null;
  });

  const String categoriesEP = WebAppEndPoints.mainCategoriesEP;
  const String boutiquesEP = WebAppEndPoints.homeBoutiquesEP;

  List<String?> tabs(CategoryFlowHarness flow) =>
      (flow.bloc.state.mainCategoriesResponseModel?.data?.mainCategories ??
              <dynamic>[])
          .map((dynamic c) => c.slug as String?)
          .toList();

  PaginationModel<dynamic>? tabOf(CategoryFlowHarness flow, String slug) =>
      flow.bloc.state.getHomeBoutiquesPaginationObjectByMainCategory[slug];

  List<String?> boutiquesOf(CategoryFlowHarness flow, String slug) =>
      (tabOf(flow, slug)?.items ?? <dynamic>[])
          .map((dynamic b) => b.slug as String?)
          .toList();

  test('GetMainCategoriesEvent returns the tabs in server order, and only then '
      'asks for everything the rest of the app needs', () async {
    // The order is the merchandising order — the server decides which category
    // is first, and re-sorting them here would put the wrong one under the
    // user's thumb. This also pins where the app's startup calls come from:
    // `requestAPIAfterHome()` runs on the categories' success, and is the only
    // place `GetStartingSettingsEvent` is dispatched from.
    final CategoryFlowHarness flow = harness = buildCategoryFlowHarness(
      routes: <String, List<ScriptedReply>>{
        categoriesEP: <ScriptedReply>[
          ScriptedReply(
            200,
            mainCategoriesEnvelope(<String>['women', 'men', 'kids']),
          ),
        ],
        boutiquesEP: <ScriptedReply>[
          ScriptedReply(200, homeBoutiquesEnvelope()),
        ],
      },
    );

    flow.bloc.add(const GetMainCategoriesEvent());
    await pumpEventQueue();

    expect(
      flow.transitionsOf((CategoryState s) => s.getMainCategoriesStatus),
      <GetMainCategoriesStatus>[
        GetMainCategoriesStatus.init,
        GetMainCategoriesStatus.loading,
        GetMainCategoriesStatus.success,
      ],
    );
    expect(
      tabs(flow),
      <String>['women', 'men', 'kids'],
      reason: 'server order, untouched',
    );
    expect(
      flow.home.eventsOf<GetStartingSettingsEvent>(),
      hasLength(1),
      reason: 'the app\'s starting settings are asked for once the home has '
          'its categories — this is the only place that asks',
    );
    expect(
      flow.home.eventsOf<GetCurrencyForCountryEvent>(),
      hasLength(1),
      reason: 'and the currency every price is printed in',
    );
  });

  test('the tabs are painted from the last session before the server answers, '
      'and the fresh answer replaces them', () async {
    // A cold home screen with a warm cache: the categories from last time are
    // on screen in the same frame as the spinner, so the tab row never flashes
    // empty. Cache first, network second, network wins.
    final SessionPrefs prefs = SessionPrefs()
      ..mainCategoriesPrefetchValue = jsonOf(
        mainCategoriesEnvelope(<String>['cached-women', 'cached-men']),
      );

    final CategoryFlowHarness flow = harness = buildCategoryFlowHarness(
      prefs: prefs,
      routes: <String, List<ScriptedReply>>{
        categoriesEP: <ScriptedReply>[
          ScriptedReply(
            200,
            mainCategoriesEnvelope(<String>['women', 'men', 'kids']),
            const Duration(milliseconds: 60),
          ),
        ],
        boutiquesEP: <ScriptedReply>[
          ScriptedReply(200, homeBoutiquesEnvelope()),
        ],
      },
    );

    flow.bloc.add(const GetMainCategoriesEvent());
    await pumpEventQueue();

    expect(
      flow.bloc.state.getMainCategoriesStatus,
      GetMainCategoriesStatus.loading,
      reason: 'still waiting on the server …',
    );
    expect(
      tabs(flow),
      <String>['cached-women', 'cached-men'],
      reason: '… with last session\'s tabs already on screen',
    );

    await Future<void>.delayed(const Duration(milliseconds: 120));
    await pumpEventQueue();

    expect(tabs(flow), <String>['women', 'men', 'kids']);
    expect(
      prefs.mainCategoriesPrefetchValue,
      contains('kids'),
      reason: 'and the fresh answer becomes next session\'s cache',
    );
  });

  test('GetHomeBoutiqesEvent fills the selected tab, in server order',
      () async {
    final CategoryFlowHarness flow = harness = buildCategoryFlowHarness(
      routes: <String, List<ScriptedReply>>{
        boutiquesEP: <ScriptedReply>[
          ScriptedReply(
            200,
            homeBoutiquesEnvelope(
              boutiques: <Map<String, dynamic>>[
                homeBoutique('zara'),
                homeBoutique('adidas', id: 2),
                homeBoutique('nike', id: 3),
              ],
              offset: '3',
            ),
          ),
        ],
      },
    );

    flow.bloc.add(
      GetHomeBoutiqesEvent(
        categorySlug: 'women',
        offset: '1',
        getWithPrefetchToStoreInMemory: false,
        getWithOutPrefetchForEachBoutiques: true,
      ),
    );
    await pumpEventQueue();

    expect(
      flow.adapter.queryOf(boutiquesEP)?['category_slugs'],
      '["women"]',
      reason: 'the tab asks only for its own category',
    );
    expect(
      boutiquesOf(flow, 'women'),
      <String>['zara', 'adidas', 'nike'],
      reason: 'server order — the home screen is merchandised, not sorted here',
    );
    expect(tabOf(flow, 'women')?.paginationStatus, PaginationStatus.success);
    expect(tabOf(flow, 'women')?.hasReachedMax, isTrue,
        reason: 'three of a possible ten is the last page');
  });

  test('the "all" tab drops its slug rather than sending "Empty"', () async {
    // `Empty` is the app's own name for "no category". Sending it as a filter
    // would ask the server for a category that does not exist and come back
    // with nothing on the first screen the user ever sees.
    final CategoryFlowHarness flow = harness = buildCategoryFlowHarness(
      routes: <String, List<ScriptedReply>>{
        boutiquesEP: <ScriptedReply>[
          ScriptedReply(200, homeBoutiquesEnvelope()),
        ],
      },
    );

    flow.bloc.add(
      GetHomeBoutiqesEvent(
        categorySlug: 'Empty',
        offset: '1',
        getWithPrefetchToStoreInMemory: false,
        getWithOutPrefetchForEachBoutiques: true,
      ),
    );
    await pumpEventQueue();

    expect(
      flow.adapter.queryOf(boutiquesEP)?.containsKey('category_slugs'),
      isFalse,
    );
    expect(boutiquesOf(flow, 'Empty'), <String>['b1'],
        reason: 'and the answer is still filed under the "all" tab',
    );
  });

  test('switching tabs and coming back shows that tab filled at once, from its '
      'cache, while it is re-requested', () async {
    // The ledger reads this as "switching back does not refetch". It does
    // refetch — the tab bar sends `getWithOutPrefetchForEachBoutiques: true`,
    // which skips the once-only guard. What the user is promised is weaker and
    // more useful: the tab is never blank. Its boutiques are painted from the
    // preferences copy written when it last succeeded, in the same frame as the
    // request going out.
    //
    // Worth knowing while reading this: a first (non-paged) load starts the map
    // from `{}`, so the tab being left keeps nothing in memory. The cache is
    // what carries it, not the state.
    final CategoryFlowHarness flow = harness = buildCategoryFlowHarness(
      routes: <String, List<ScriptedReply>>{
        boutiquesEP: <ScriptedReply>[
          ScriptedReply(
            200,
            homeBoutiquesEnvelope(
              boutiques: <Map<String, dynamic>>[homeBoutique('zara')],
            ),
          ),
          ScriptedReply(
            200,
            homeBoutiquesEnvelope(
              boutiques: <Map<String, dynamic>>[homeBoutique('gap')],
            ),
          ),
          ScriptedReply(
            200,
            homeBoutiquesEnvelope(
              boutiques: <Map<String, dynamic>>[
                homeBoutique('zara'),
                homeBoutique('mango', id: 2),
              ],
              offset: '2',
            ),
            const Duration(milliseconds: 60),
          ),
        ],
      },
    );

    GetHomeBoutiqesEvent openTab(String slug) => GetHomeBoutiqesEvent(
          categorySlug: slug,
          offset: '1',
          getWithPrefetchToStoreInMemory: false,
          getWithOutPrefetchForEachBoutiques: true,
        );

    flow.bloc.add(openTab('women'));
    await pumpEventQueue();
    expect(boutiquesOf(flow, 'women'), <String>['zara']);
    // The cache is written off the event loop, so let it land.
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(flow.prefs.boutiquesPrefetch['women'], contains('zara'));

    flow.bloc
      ..add(openTab('men'))
      ..add(ChangeCurrentIndexForMainCategoryEvent(index: 1));
    await pumpEventQueue();
    expect(boutiquesOf(flow, 'men'), <String>['gap']);
    expect(flow.bloc.state.currentIndexForMainCategoryEvent, 1);

    // Back to women. The slow answer is still out; what is on screen already is
    // the cache.
    flow.bloc
      ..add(openTab('women'))
      ..add(ChangeCurrentIndexForMainCategoryEvent()); // back to the first tab
    await pumpEventQueue();

    expect(
      boutiquesOf(flow, 'women'),
      <String>['zara'],
      reason: 'filled from the cache before the server answers — not blank',
    );
    expect(tabOf(flow, 'women')?.paginationStatus, PaginationStatus.loading,
        reason: 'and it is being refreshed at the same time');
    expect(flow.bloc.state.currentIndexForMainCategoryEvent, 0);

    await Future<void>.delayed(const Duration(milliseconds: 120));
    await pumpEventQueue();

    expect(
      boutiquesOf(flow, 'women'),
      <String>['zara', 'mango'],
      reason: 'the fresh answer replaces the cached one',
    );
    expect(flow.adapter.callsTo(boutiquesEP), 3,
        reason: 'three opens, three requests — coming back does re-request');
  });

  test('an empty tab is an empty list, not a blank row or an error', () async {
    // A category with no boutiques yet is a normal answer. It must read as
    // "nothing here", finished — not as a failure the user can retry into the
    // same nothing, and not as a page that keeps asking for more.
    final CategoryFlowHarness flow = harness = buildCategoryFlowHarness(
      routes: <String, List<ScriptedReply>>{
        boutiquesEP: <ScriptedReply>[
          ScriptedReply(
            200,
            homeBoutiquesEnvelope(boutiques: const <Map<String, dynamic>>[]),
          ),
        ],
      },
    );

    flow.bloc.add(
      GetHomeBoutiqesEvent(
        categorySlug: 'women',
        offset: '1',
        getWithPrefetchToStoreInMemory: false,
        getWithOutPrefetchForEachBoutiques: true,
      ),
    );
    await pumpEventQueue();

    expect(tabOf(flow, 'women')?.paginationStatus, PaginationStatus.success);
    expect(tabOf(flow, 'women')?.items, isEmpty);
    expect(tabOf(flow, 'women')?.hasReachedMax, isTrue);
  });

  test('a boutique with no banner does not stop the tab loading', () async {
    // This was a defect: the success branch warmed each card's banner with
    // `element.banners?.first.filePath`. `?.` guards a *null* list, and
    // `GetHomeBoutiquesModel` never makes one — a missing `banners` parses to
    // `[]`, and `[].first` throws. Nothing caught it, so the emit that stores
    // the boutiques never ran: one banner-less boutique left the tab spinning
    // and threw away the boutiques that did have banners.
    final CategoryFlowHarness flow = harness = buildCategoryFlowHarness(
      routes: <String, List<ScriptedReply>>{
        boutiquesEP: <ScriptedReply>[
          ScriptedReply(
            200,
            homeBoutiquesEnvelope(
              boutiques: <Map<String, dynamic>>[
                homeBoutique('zara'),
                homeBoutique('no-banner', id: 2, withBanner: false),
              ],
            ),
          ),
        ],
      },
    );

    flow.bloc.add(
      GetHomeBoutiqesEvent(
        categorySlug: 'women',
        offset: '1',
        getWithPrefetchToStoreInMemory: false,
        getWithOutPrefetchForEachBoutiques: true,
      ),
    );
    await pumpEventQueue();

    expect(tabOf(flow, 'women')?.paginationStatus, PaginationStatus.success);
    expect(
      boutiquesOf(flow, 'women'),
      <String>['zara', 'no-banner'],
      reason: 'both cards are shown; the one with no banner simply has no '
          'image to warm',
    );
    expect(
      flow.images.events,
      hasLength(1),
      reason: 'and exactly one image was queued: the one card that has a '
          'banner',
    );
  });
}
