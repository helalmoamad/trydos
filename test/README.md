# Unit tests

One command runs everything in this folder, from the repository root:

```bash
flutter test
```

That is the single entry point. There is no aggregator file to keep in step —
`flutter test` finds every `*_test.dart` under `test/` on its own, so a new file
joins the run the moment it is saved.

Useful variants:

```bash
flutter test test/core/api                 # one folder
flutter test --name "refresh coordinator"  # one test by name
flutter test --coverage                    # writes coverage/lcov.info
```

## Layout

`test/` mirrors `lib/` one directory at a time, and each file keeps the name of
the unit it covers plus `_test`:

```
lib/core/api/token_refresh_coordinator.dart
test/core/api/token_refresh_coordinator_test.dart
```

Shared fakes and harness code go in `test/helpers/`. Each helper is written when
the first test actually needs it, so the folder never fills with scaffolding
nobody calls. What is there now:

| Helper | What it stands in for |
|--------|-----------------------|
| `network_harness.dart` | dotenv test values, a `Dio` whose transport is scripted, and the `FakePrefs` the network layer reads |
| `session_prefs.dart` | the stored session — four tokens, four refresh tokens, three identities and the flags |
| `hydrated_storage_harness.dart` | an in-memory `HydratedStorage`, without which no hydrated bloc can be built |
| `secure_storage_harness.dart` | the keychain, answered at the method channel so the real `FlutterSecureStorage` runs |
| `auth_flow_harness.dart` | the real `AuthBloc` over the real use cases and repository, with the four blocs it talks to recorded |
| `home_flow_harness.dart` | the same for `HomeBloc` and its 54 use cases |
| `catalogue_flow_harness.dart` | the same for `BoutiqueBloc` (every listing) and `CategoryBloc` (the home screen), each built with the other one recorded |
| `auth_fixtures.dart`, `home_fixtures.dart`, `catalogue_fixtures.dart` | the response bodies, so a test shows only the field it is about |

### Two things about the harnesses that are easy to get wrong

**The interceptor is not scenery.** Both flow harnesses install the real
`LoggerInterceptor`. Without it every non-2xx status collapses to 400 before a
handler can branch on it: Dio raises an exception, `PostClient`'s `catchError`
returns that exception where a `Response` belongs, the resulting `ArgumentError`
lands in the generic catch in `handlingExceptionRequest`, and out comes
`ServerFailure(400)` whatever the server said. The interceptor resolves the error
back into a `Response` carrying the real status. A harness without it would go
green against a code path the app never runs.

**Assert the sequence, not just the end.** Both harnesses record every state the
bloc passed through, and `transitionsOf` collapses the repeats. Checking only the
final state cannot tell "went loading, then succeeded" from "jumped straight to
success", and a handler that stops emitting `loading` leaves every spinner in the
app running forever. Where the loading emit is part of the contract, assert the
whole list.

**Two statics the app sets at startup and a test does not.** `ScreenUtil` and
`LanguageService.isKurdish` are both `late` and both read from inside catalogue
handlers — to size a prefetched image, to stamp an analytics event. Unset, most
of those reads were swallowed by a `try` and one was not: the handler that fills
the home rails threw on the first `.w`. `configureDeviceStatics()` in the
catalogue harness sets both, with the device the same size as the design so
`.w` and `.h` scale by exactly one. Both flow harnesses call it.

**One path can answer two questions.** `api/products/searchInCatalog` returns the
product page *and* the filter facets. Nothing in the path says which; a facet
request carries `with_products=false`. Use `RoutingAdapter.queryOf` and read the
query, or a test that means "no products were fetched" will be counting the
wrong calls.

**Two servers can share a path.** `ChatEndPoints.loginEP` and
`StoriesEndPoints.loginEP` are both `api/v1/users/login`, and the chat refresh
borrows `MarketEndPoints.refreshTokenEP`. Route those through `AuthRoutes`, which
names the host as well — see `auth_flow_harness.dart`.

## What belongs here, and what does not

This folder is for **unit tests** — one behaviour, no device, no real network.
Widget-level and end-to-end scenarios live in `integration_test/`, which needs a
running device and is not part of `flutter test`.

## The plan

Every test here comes from a scenario in the test ledger:

- open `docs/test-ledger.html` in a browser (works offline, straight from disk)
- 366 scenarios, in 8 waves, ordered so nothing depends on work not done yet
- tick a scenario once its test is written **and green**

Each test file names the ledger wave and unit it belongs to in a comment at the
top, so a reader can go from a test back to the reason it exists.

## Writing a test that is worth keeping

A test that cannot fail is not protection, it is decoration. Before ticking a
scenario, break the code it covers on purpose and confirm the test goes red —
then undo the break. Every test in this folder has been checked that way.

Three kinds of hole showed up while checking that, and all three are easy to
repeat:

- A **test that proves the wrong thing.** `expect(AuthBloc, isNot(HydratedBloc))`
  compares two `Type` objects, which is true for any two distinct classes — it
  would have stayed green if `AuthBloc` had started extending `HydratedBloc`. Ask
  the built instance, not the type: `isNot(isA<HydratedBloc<…>>())`.
- A **helper tested away from its caller.** The OTP resend window was checked by
  driving `throttleDroppable` over a bare stream. That proves the transformer
  works, not that `AuthBloc` uses it — deleting `transformer:` from
  `on<SendOtpEvent>` left the suite green. It now also asks the bloc for two taps
  and counts the requests that left.
- Two mutations that **survived**, both the test's fault rather than the code's:
  - The hydration test asserted that the OTP id token is missing from the
    persisted payload — but built its user *without* a token, so the assertion
    held whether or not the scrub ran. Fixed by giving the user a token and
    asserting the in-memory state still has it.
  - The inbox test tried to prove that a first load replaces the list, by making
    the success branch always append. It stayed green because the handler guarded
    that **twice**: the model was reset to `PaginationModel.init` at the top of
    the handler for a non-pagination call, *and* the success branch had a ternary
    that replaced rather than appended. Neither guard alone changed the
    behaviour, so no single edit could. The redundant ternary has since been
    removed, the reset is now the only guard, and breaking it does turn the test
    red.

## Status

| Wave | Unit | Scenarios | Mutations caught | State |
|------|------|-----------|------------------|-------|
| 01 Core runtime | Refresh coordinator | 6 | 3 / 3 | green |
| 01 Core runtime | 401 refresh and replay | 8 | 4 / 4 | green |
| 01 Core runtime | Exception mapping | 5 | 3 / 3 | green |
| 01 Core runtime | Retry policy | 4 | 2 / 2 | green |
| 01 Core runtime | Status codes | 1 | 1 / 1 | green |
| 01 Core runtime | Media urls | 4 | 2 / 2 | green |
| 01 Core runtime | Form validators | 5 | 2 / 2 | green |
| 01 Core runtime | Server and token resolution | 4 | 3 / 3 | green |
| 01 Core runtime | Request headers | 5 | 3 / 3 | green |
| 01 Core runtime | Upload pipeline | 4 | 2 / 2 | green |
| 02 Account and session | Continue as guest | 3 | 2 / 2 | green |
| 02 Account and session | Request an OTP | 3 | 3 / 3 | green |
| 02 Account and session | Verify the OTP | 4 | 2 / 2 | green |
| 02 Account and session | The four-server login | 6 | 1 / 1 | green |
| 02 Account and session | Staying in | 4 | 1 / 1 | green |
| 02 Account and session | Logging out | 5 | 2 / 2 | green |
| 02 Account and session | Edit the profile | 4 | 2 / 2 | green |
| 02 Account and session | Change the display name everywhere | 2 | 2 / 2 | green |
| 02 Account and session | Country and currency | 5 | 1 / 1 | green |
| 02 Account and session | Notification settings | 6 | 2 / 2 | green |
| 02 Account and session | The notification inbox | 2 | 3 / 3 | green |
| 02 Account and session | AuthBloc contract | 3 | 2 / 2 | green |
| 03 Browsing and the product page | Opening the app | 3 | 6 / 6 | green |
| 03 Browsing and the product page | The home screen | 4 | 8 / 8 | green |
| 03 Browsing and the product page | Filtering a listing | 9 | 11 / 11 | green |
| 03 Browsing and the product page | Sorting and paging | 6 | 9 / 9 | green |
| 03 Browsing and the product page | Loading the details | 5 | 6 / 6 | green |
| 03 Browsing and the product page | Choosing a variant | 4 | 6 / 6 | green |
| 03 Browsing and the product page | Reacting to a product | 4 | 6 / 6 | green |
| 03 Browsing and the product page | Writing a review | 5 | 7 / 7 | green |

**Wave 01 is complete: 46 / 46. Wave 02 is complete: 47 / 47. Wave 03's P0 is
complete: 40 / 40** — its P1 and P2 units (discovery rails, search by text and
by image, the wishlist, reading reviews, listing layout, compare, offer timers,
stories on a product: 32 scenarios) are not written yet. 140 of 366 overall,
counting the wave 00 setup already in place (`bloc_test`, `fake_async`,
dotenv test values, `GetIt` reset between tests, and now the in-memory
`HydratedStorage` and the bloc harness that hands back the emitted state list).

Wave 03 needed two more additions, both written because a test asked for them:
`ScriptedReply` takes an optional `delay`, without which no test can ask what
happens when an **old** request answers after a newer one; and `SessionPrefs`
grew the catalogue caches (main categories, each category's boutiques, each
boutique's first page and first five filters), because the home screen paints
from them before it paints from the network.

**One test is deliberately slow.** Liking is registered
`throttleDroppable(3s)`, so seeing a like and its undo takes a real three-second
wait — twice, in `reacting_to_a_product_test.dart`. Roughly seven seconds of the
suite is that door.

The bloc-harness scenario asks for "mocked use cases". The flow harnesses build
the bloc over the **real** use cases and repository with only the transport
mocked, which is what the wave-02 tier asks for in turn — "a mocked `Dio` at the
bottom, the real repository / use case / bloc chain above it". The part that
scenario is really about, a harness that hands back the states the bloc passed
through, is there: `emitted` and `transitionsOf`.

Wave 00 is still deliberately unfinished. The CI job and the `needs:` line on the
deploy workflow are not written yet, and two helpers — a fixture loader and the
non-JSON / timeout replies on `ScriptedAdapter` — wait for the first test that
needs them, per the rule above.

## Defects

Three wave-02 defects were fixed, under **Fixed here** below — two in
`home_bloc.dart`, one in `auth_bloc.dart` — and all five wave-03 defects were
fixed too, under **Found in wave 03**. Every one of them is mutation-checked. Everything else in this section is *pinned*: held in place by a
test that says so in a comment, and written so it fails the moment the defect is
fixed — which is what stops any of them being fixed quietly.

### Found in wave 01

- `base_api_test.dart` — the shared Dio keeps the previous request's bearer, so a
  public server carries a token it should never see.
- `handling_exception_test.dart` — `TryAgainException` has no branch and loses
  its retry count.
- `validator_test.dart` — `RequiredValidator` accepts `null`.

### Found in wave 02

- **`DeleteFcmTokenEvent` has no handler — and cannot get one yet.** It is
  declared in `auth_event.dart:86` and that is all: `AuthBloc`'s constructor
  registers no `on<DeleteFcmTokenEvent>`, so it falls through to the catch-all
  `on<AuthEvent>((event, emit) {})`, and nothing in `lib/` dispatches it either.
  The market device token is therefore never removed on logout, and the phone
  keeps receiving market push for an account nobody is signed into.

  It was left unfixed on purpose. The market side has **no endpoint to delete a
  device token**: `MarketEndPoints` has `storeFcmOfMarketEP`
  (`POST api/v1/firebase_device_tokens`) and
  `sendAcceptOfNotificationMarketEP` (`.../validate_token`), and nothing else —
  the chat server's `remove-token` has no market twin anywhere in the app. Adding
  a handler would mean calling a path nobody has confirmed exists, which ships a
  404 dressed as a fix. **This needs a backend endpoint first.** Pinned by
  `test/features/authentication/logging_out_test.dart`.
### Found in wave 03 — all five fixed

Each was pinned first — held by a test that failed the moment it was fixed —
then fixed, and the pin rewritten to assert the corrected behaviour. Every fix
is mutation-checked in reverse: the bug was put back and the new test went red.

- **A deep link opened from a cold start left the listing loading forever.**
  `_onGetFiltersForNavigatorFromLinkToListingPageEvent` wrote into
  `state.appliedFiltersByUser` itself rather than a copy, and `BoutiqueState`
  starts that map as `const {}`. `addAll` threw between the loading emit and the
  success one, so the spinner never stopped. It hid in any session that browsed
  first, because every other filter handler replaces the map with a fresh one.
  Fixed with `Map.of(...)`. Covered by `filtering_a_listing_test.dart`.
- **Paging the filter facets dropped every page after the first, for any
  boutique with no size attribute.** `_onGetFiltersWithPaginatioEvent` tested
  `(data[key]?.filters?.attributes ?? 0) == 0` for "no attributes yet", but
  `Filter.fromJson` turns a missing or empty `attributes` into `[]`, never
  null — so the test was `[] == 0`, always false, and the next line read
  `attributes[0]` on an empty list. The `RangeError` landed in the handler's own
  `catch`, which emitted the status and dropped the page. Fixed with
  `?.isEmpty ?? true`, in all three places. Covered by
  `filtering_a_listing_test.dart`.
- **One boutique with no banner took down the whole home tab.** The success
  branch of `_onGetHomeBoutiquesEvent` warmed each card's banner with
  `element.banners?.first.filePath`. `?.` guards a null list;
  `GetHomeBoutiquesModel` never makes one — a missing `banners` parses to `[]`,
  and `[].first` throws. Nothing caught it, so the emit that stores the
  boutiques never ran and the tab kept its loading state, dropping the
  boutiques that *did* have banners. Fixed by skipping a card with nothing to
  warm. Covered by `home_screen_test.dart`.
- **A like the server refused never went back.** The failure branch of
  `_onAddOrRemoveLikeForProductEvent` did reverse the heart and the count, but
  it was unreachable on a first failure: `ErrorManager.shouldRetry` allows one
  retry, the handler returned early to schedule it, and the retry — dispatched
  into the same handler, the one registered `throttleDroppable(3s)` — was
  dropped milliseconds later. The second failure never arrived, so the heart
  stayed filled over a rejected like and the status stayed `loading` for good.
  Fixed by dropping the retry: it could never run, and a like is a user action
  worth reporting rather than repeating silently. Covered by
  `reacting_to_a_product_test.dart`.
- **A review written while a filtered tab was open was accepted and never
  reported.** The success branch of `_onCreateCommentRatingEvent` reached for
  `getFqaCommentsPaginationModel["all"]!` — the questions tab, under the default
  filter, hard-coded and null-asserted. On any other review filter that entry
  does not exist, so the `!` threw *after* the server had accepted the review:
  it existed, and the form kept spinning. The same happened on a product page
  whose questions tab was never opened. Fixed by defaulting the entry instead of
  asserting it. Covered by `writing_a_review_test.dart`.

### Fixed here

- **`SendAcceptOfNotificationMarketEvent` had no dedupe.** The handler kept no
  record of which ids it had confirmed and the event is registered with no
  transformer, so the same greeting arriving twice confirmed twice. It now holds
  the confirmed ids in an in-memory set — in memory, not in `HomeState`, because
  persisting them would change the hydrated payload shape and need a migration of
  its own. A refused confirmation releases its id again, so the retry the handler
  already had still goes out. Covered by
  `test/features/home/notification_inbox_test.dart`.
- **A failed chat-name update retried the wrong flow.**
  `_onUpdateChatUserNameEvent` re-added `UpdateStoriesUserEvent` in all three of
  its failure branches, so a chat-name update that failed started the
  stories-first chain instead — running the stories update a second time and
  never retrying the chat name at all. It now re-adds its own event. Covered by
  `test/features/authentication/display_name_test.dart`, which counts the calls,
  because that is the only place the difference shows.

  Worth knowing: the re-added event is registered with `throttleDroppable(2min)`,
  so an immediate retry is dropped by the throttle anyway. The same is true of
  `UpdateStoriesUserEvent`. The retry is decorative in both — correcting which
  flow it names is the fix here; making retries actually run is a separate
  question.
- **The inbox guarded "replace, do not append" twice.** The redundant ternary in
  the success branch is gone; the reset at the top of the handler is now the one
  guard, and it is mutation-checked.

### Ledger wording that is not a defect

- **`VerifyOtpInProfileEvent` ignores the phone it was sent.** The response
  carries `phone` next to `id_token`, and the ledger expects the event to store
  it. It must not. `profile_personal_info_page.dart:443` dispatches
  `UpdateProfileEvent` the moment this verification succeeds, and
  `_onUpdateProfileEvent` stores the phone from the **server's** answer. Storing
  it at verification time would record a number the account does not have yet —
  and if the profile update then failed, the app would hold a phone the backend
  never accepted, which also flips `marketGO` host routing. The test in
  `test/features/authentication/verify_otp_test.dart` pins the correct
  behaviour; the ledger line is the thing that is wrong.

## Reported, not pinned

These have no test yet, for the reason given.

- **A rejected refresh token costs a 20-second hang.** When the market refresh
  endpoint itself answers 401, the 401 goes back through `LoggerInterceptor`,
  which asks `TokenRefreshCoordinator` for a market refresh. The coordinator sees
  one already running and hands back its pending future — the future that the
  waiting handler is itself supposed to complete. The two only come apart when the
  coordinator's own 20-second timeout fires, and only then does the guest-session
  recovery start. Pinning it costs twenty real seconds per suite run, so it is
  written up here instead; see the note in
  `test/features/authentication/staying_in_test.dart`.
- **`getFullProductDetailsStatus` is written but never read.** Nothing outside
  `HomeState` looks at it, and on a successful product load it is only set to
  `success` inside the `if (r.productItem?.productId == null)` branch — the one
  taken when the product is empty. The product page keys its readiness off
  `productStatus[productId]` instead, which is what the wave-03 tests assert.
  Harmless today; worth knowing before anyone starts trusting the field.
- **`Country.fromJson` casts `phonecode` straight into an `int?`.** A server that
  sent it as a string would throw inside the list build and take the whole
  allowed-countries answer down, leaving the country picker empty with no error
  the user can act on. No test, because inventing a server shape that has not been
  observed would pin a guess rather than a behaviour.

## Where the ledger and the code disagree

Three wave-02 scenarios describe something the code does not do. Each is covered
by a test of what the code *actually* does, with the divergence written into the
test file:

| Ledger says | The code does |
|-------------|---------------|
| "`SendOtpEvent` sets the timer flag so the resend button locks" | The flag is written by the OTP screen (`verify_otp.dart:74`) and only drives the countdown label. What stops a second request is the bloc's `throttleDroppable(10s)` on `SendOtpEvent`. |
| "`CreateUserEvent` creates the market account" | It creates the **chat** account — its use case is the only one in `AuthBloc` that takes a `ChatRepository`. The market account is created by the sign-up endpoint. |
| "hydrated `toJson`/`fromJson` round-trips" under **AuthBloc contract** | `AuthBloc` is a plain `Bloc` and persists nothing. The round-trip is written against `HomeBloc`, which is the bloc that does — `test/features/home/home_state_hydration_test.dart`. |

Wave 03 adds nine more. Each is covered by a test of what the code actually
does, with the divergence written into the test file:

| Ledger says | The code does |
|-------------|---------------|
| "`GetStartingSettingsEvent` completes before the first screen is allowed to build" | It is dispatched by `CategoryBloc.requestAPIAfterHome()`, which runs **after** the home categories answer. The home is already on screen, painting with the settings the previous session persisted — the fallback is the hydrated state, not a "cached prefetch". |
| "`ChangeAppliedFiltersEvent` fetches" | It records what was applied and returns. The listing then dispatches `GetProductsWithFiltersEvent`, which reads the applied filters back out of the state. |
| "`ResetAllSelectedAppliedFilterEvent` … refetches unfiltered" | It clears and fetches nothing — it runs on the way *out* of a listing (a tab switch, the bottom bar, the cart), when there is nothing on screen to reload. |
| "`ChangeSelectedFiltersEvent` … nothing is fetched" | Nothing **of the product list**. The facets are refetched, narrowed by the tick, so the counts beside every other filter follow the selection. |
| "`GetProductsWithFiltersUsingPaginationEvent`" is a paging variant to test | Dead: declared in `boutique_event.dart`, registered by no bloc, and dispatched only from a commented-out block. The live paging path is `GetProductsWithFiltersWithPaginationEvent`. |
| "switching back does not refetch" (the home tabs) | Every tab switch re-requests — the tab bar sends `getWithOutPrefetchForEachBoutiques: true`, which skips the once-only guard. What the user is promised is weaker and more useful: the tab is painted from its cached copy in the same frame, so it is never blank. |
| "the home sections (`get_home_sections_usecase`) come back in server order" | There are no home sections. The use case has no caller, its repository method is commented out, and so is its `HomeBloc` constructor slot. The home screen renders boutiques per category, which is what the test covers instead. |
| "`FetchAuthProductDetailsEvent` adds the like state" | It fetches `product/qty/<slug>` — the available quantity and the per-variation stock. The like arrives with the main details payload as `is_liked`, which is why that request carries `user_id`. |
| "`GetAndAddCountViewOfProductEvent` counts a view once per product per session" | No view is counted at all: both dispatches are commented out and no widget sends it. Driven by hand it counts once per dispatch — there is no guard — and its success branch is commented out too, so a counted view never leaves `loading`. |
