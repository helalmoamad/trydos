---
ticket: read-and-reply-to-customer-comments-in-seller-dashboard
stage: plan
mode: standard          # single workflow form — no other modes (ADR-009)
status: complete        # not_started | in_progress | blocked | complete
owner: developer
updated: 2026-09-09
links:
  clickup: "https://app.clickup.com/t/z8n6b5yctu"
  github:
---

# Plan — read-and-reply-to-customer-comments-in-seller-dashboard

> Decide the approach before changing code. Plan only — no implementation here.

## Approach

Build the screen along the layer path the seller dashboard already uses —
endpoint constants → data source → repository → `@injectable` use cases → the one
dashboard bloc → the widget — and copy the Locations work item's shape wherever a
choice exists, because it is the newest sibling and it solved the same tenant and
permission problems.

The one place this work item cannot copy anything is the server routing. The
comments endpoints sit on the **web** server but need the **market** token, and no
`ServerName` sends that pair (`CON-1`). Of the two remaining options
(`OQ-1`), this plan **adds a new `ServerName` value** rather than giving
`ServerName.webApp` a token. Giving `webApp` a token would put an `Authorization`
header on **17 existing unauthenticated call sites** in the home feature, which
`AC-35` forbids outright; a new value is read by exactly one caller — the four new
data-source methods — and both `switch` statements over `ServerName` are
exhaustive, so the compiler forces both to be updated and neither can be
half-done. This is a **protected runtime path** edit and the review gate must
approve it as such.

## Steps

1. **Endpoint constants.** Add the four comments paths to `WebAppEndPoints` —
   they are `{WEB_API}` paths, so they belong beside the other web-server routes,
   not with the market-server dashboard routes.
2. **Server routing (protected).** Add one `ServerName` value for seller
   comments. In `getBaseUriForSpecificServer` it returns `WebUrls.baseUri`; in
   `getServerToken` it returns `prefsRepository.marketToken`. Touch no other
   `case`, so no existing call site changes (`AC-35`).
3. **Model.** One new model file holding the comment row, the page `meta`, and the
   list wrapper, with a hand-written tolerant `fromJson` in the style of
   `get_shop_locations_model.dart`: ids read as `String`, `rating` /
   `created_at` / `reply_created_at` nullable, `meta` optional, an `.empty()`
   const constructor. Reply writes reuse the existing
   `ReadOnlyMessageFromApiModel`, which already carries `{success, message}`.
4. **Data source.** Four methods: the list read (`GET`, `seller_id` + `type` +
   `page` + `page_size` in the query), reply create (`POST`), reply edit (`PUT`),
   reply delete (`DELETE` with a body — `DeleteClient` already supports one, as
   `deleteGalleryImages` shows). Each takes the shop id as an explicit parameter
   and puts it in the query or body; **no `extraHeaders` anywhere**, because only
   `POST` reads that field (`CON-2`) and a value written on the other three would
   silently do nothing.
5. **Repository.** Four signatures on the interface, four implementations wrapping
   the data source in `handlingExceptionRequest`, exactly like the Locations
   methods.
6. **Use cases.** Four `@injectable` `UseCase<Model, Params>` classes, one per
   call, each with its own `Params` class.
7. **Permissions.** Add `READ_COMMENTS`, `REPLY_COMMENT`, `EDIT_REPLY`,
   `DELETE_REPLY` to `DashBoardPermission`, and four
   `SUPER_ADMIN`-or-the-named-one methods to `DashboardPermissionChecker`
   (`AC-18`).
8. **State.** Add two status enums and five fields — one list model and one status
   per tab, plus one write status — to `DashBoardState`, with defaults in the
   constructor, entries in `copyWith`, and entries in `props`. **Each tab's page
   number lives inside its own `meta`**, so no separate page field is needed
   (`OQ-11`, `AC-6`).
9. **Events.** Four events: load a tab's first page, load the next page of a tab,
   submit a reply (create or edit), delete a reply. The load events carry the tab
   and a `canRead` flag, following `GetShopLocationsEvent`.
10. **Bloc.** Four handlers plus the Locations staleness guard, copied
    field-for-field: a generation counter, the shop id captured when the request
    starts, and a drop that emits nothing at all when the response is stale
    (`AC-3`, `AC-4`). Add a private `_logComments(action, outcome)` that prints
    under `kDebugMode` only and carries the action, the outcome and the shop id —
    never a token, a body, a reply text, a customer name or an avatar address
    (`AC-27`, `AC-28`).
11. **Screen.** A new widget file holding `CustomerComments`, the comment card and
    the reply dialog (`OQ-10`). Two pill tabs, a list with a "load more" control
    driven by `meta.has_more_pages`, the empty state, and the dialog from
    `replayToComment.jpeg`. Reuse `EmptyStateWidget` with a chat-bubble icon
    (`OQ-6`) and `sanitizeForDisplay` from `display_text_sanitizer.dart` for every
    backend string rendered (`AC-34`).
12. **Entry point.** In `dashboard_page.dart`: delete the 13-line
    `CustomerComments` stub, import the new file, and set the index-10 filter
    item's `visible:` to `_permissionChecker.canReadComments()` — the same pattern
    the other gated tabs already use (`AC-19`).
13. **Localization.** Add every new string to the four bundles, then regenerate
    with `keys.sh`. Never hand-edit `locale_keys.g.dart`.
14. **Regenerate DI** with `gen.sh`, because four new `@injectable` use cases and
    four new bloc constructor parameters change `di_container.config.dart`.

## Files to change

**Protected runtime path — needs explicit review-gate approval:**

- `lib/core/api/methods/detect_server.dart` — add one `ServerName` value for
  seller comments and its two `case` arms (base URI → `WebUrls.baseUri`, token →
  `marketToken`). No existing `case` is edited.

**Everything else:**

- `lib/common/constant/configuration/web_app_url.dart` — four endpoint constants
  under `WebAppEndPoints`.
- `lib/features/dashBoard/data/models/get_seller_comments_model.dart` — **new**;
  comment row, `meta`, list wrapper.
- `lib/features/dashBoard/data/data_source/dashBoard_remote_data_source_model.dart`
  — four methods.
- `lib/features/dashBoard/domain/repositories/dashBoard_repository.dart` — four
  signatures.
- `lib/features/dashBoard/data/repositories/dashBoard_repository_impl.dart` — four
  implementations.
- `lib/features/dashBoard/domain/useCase/get_seller_comments_usecase.dart` — **new**.
- `lib/features/dashBoard/domain/useCase/reply_to_comment_usecase.dart` — **new**.
- `lib/features/dashBoard/domain/useCase/edit_comment_reply_usecase.dart` — **new**.
- `lib/features/dashBoard/domain/useCase/delete_comment_reply_usecase.dart` — **new**.
- `lib/features/dashBoard/presentation/bloc/dashBoard_state.dart` — two enums, five
  fields, defaults, `copyWith`, `props`.
- `lib/features/dashBoard/presentation/bloc/dashBoard_event.dart` — four events.
- `lib/features/dashBoard/presentation/bloc/dashBoard_bloc.dart` — four use-case
  fields and constructor parameters, four handlers, the staleness guard, the
  `_logComments` helper.
- `lib/features/dashBoard/presentation/widgets/permission_enum.dart` — four values.
- `lib/features/dashBoard/presentation/widgets/dashboard_permission_checker.dart` —
  four methods.
- `lib/features/dashBoard/presentation/widgets/customer_comments_widget.dart` —
  **new**; the whole screen, card and dialog.
- `lib/features/dashBoard/presentation/pages/dashboard_page.dart` — remove the
  stub, add the import, gate the index-10 filter item.
- `assets/languages/ar-SY.json`, `en-US.json`, `ku-IQ.json`, `tr-TR.json` — the new
  keys, in all four.
- `lib/generated/locale_keys.g.dart` — **regenerated** by `keys.sh`, never edited.
- `lib/core/di/di_container.config.dart` — **regenerated** by `gen.sh`, never
  edited.

## Integration surface

- **Components / shared config touched:**
  - `ServerName` and its two resolution functions in `lib/core/api/` — the shared
    HTTP layer every feature in the app routes through.
  - `DashboardBloc` — one `@LazySingleton` bloc shared by all eleven dashboard
    tabs; this adds four constructor parameters and five state fields to it.
  - `DashBoardState` — one flat `Equatable` class read by every dashboard tab's
    `BlocBuilder`.
  - `DashBoardRepository` and the dashboard data source — shared by every
    dashboard feature.
  - `DashBoardPermission` and `DashboardPermissionChecker` — read by every gated
    dashboard tab.
  - The four language bundles and the generated key file — shared by the whole
    app.
  - `di_container.config.dart` — the app-wide generated DI graph.
- **Who else depends on them:**
  - `ServerName`: every HTTP call in the app. In particular
    `ServerName.webApp` has **17 call sites** in the home feature, all
    unauthenticated today — the reason this plan does **not** give that value a
    token.
  - `DashBoardState`: adding fields re-runs `props`, so every dashboard
    `BlocBuilder` whose `buildWhen` is absent rebuilds when a comments field
    changes. Existing tabs that pass a `buildWhen` (Products, Locations, Shop
    Info) are unaffected.
  - `DashboardBloc`'s constructor: `di_container.config.dart` constructs it, so
    the generated file must be regenerated in the same change or the app will not
    compile.
  - The language bundles: every screen in the app reads them.
- **Overlapping flows:**
  - **Shop switching.** `PrefsRepository.getXSellerId` is the live shop id read by
    Shop Info and Locations as well. This screen reads the same value, so a shop
    switch affects all three at once — which is why the staleness guard is copied
    rather than invented.
  - **The shared `Dio` client.** `BaseApi` mutates `client.options.headers` in
    place and never clears `Authorization` when a server has no token. Adding a
    token-bearing `ServerName` means a comments request now *leaves* an
    `Authorization` header on the shared client that a later token-less request
    can inherit — the same pre-existing behaviour the market, chat and stories
    servers already produce. This work item neither fixes nor worsens it, and must
    not depend on it.
- **Ordering / lockstep dependencies:**
  1. The `ServerName` value must exist before any data-source method compiles.
  2. Both `switch` statements must be updated together — they are exhaustive, so
     the compiler enforces this.
  3. The four use cases must exist before the bloc constructor references them,
     and `gen.sh` must run after both or DI will not build.
  4. Locale keys go into all four bundles **before** `keys.sh` runs; the generated
     key file is an output, never an input.
- **What breaks if this is wrong:**
  - Giving `ServerName.webApp` a token instead would send `Authorization` on 17
    home-feature calls that never sent one. The likely failure is silent: those
    endpoints would keep working, and a change of behaviour on the backend would
    surface much later, far from this ticket. `AC-35` is the criterion that forbids
    it.
  - A wrong shop id produces an **empty list, not an error** (the API guide says a
    wrong `seller_id` "just returns nothing"), which is indistinguishable from a
    shop with no comments. The `_logComments` line carrying the shop id is what
    makes that case recognisable (`AC-27`).
  - Forgetting to regenerate `di_container.config.dart` breaks the whole app
    build, not just this screen — loud, and caught by `build-runner-clean`.
  - A missing key in one bundle shows the raw key string to users of that language
    only, and only on this screen.

## Tests

> Required (PL-13, ADR-026).

**Searched first, as `PL-14` requires.** `research.md` recorded the layout: unit
and widget tests live in `test/`, integration tests in `integration_test/`, both
named `<subject>_test.dart` and run with `flutter test`. `test/` holds exactly one
file, `test/core/json_size_cap_test.dart`; `integration_test/` holds 20, grouped by
feature. **Neither contains a single test for the dashboard feature** — no widget,
bloc, model, repository or data-source test exists. So there is no `existing`
coverage to name and no file to `extend`; every row below would have been `new`.

| AC | Existing coverage found | Disposition | Test file | Test case / name |
|----|-------------------------|-------------|-----------|------------------|
| every `AC-n` (`AC-1` … `AC-36`) | `none — searched test/ (1 file, test/core/json_size_cap_test.dart) and integration_test/ (20 files, none for dashBoard)` | `none — see reason below` | — | — |

**Why `none` and not `new`.** Not for want of tooling: `flutter_test`,
`integration_test` and `mockito ^5.4.4` are already dev dependencies. The reason is
`OQ-7`, answered by the owner on 2026-09-09: **the acceptance evidence for every
`AC-n` is code evidence plus the static checks in the validation profile**, not a
device run and not an automated suite. Writing tests this table does not declare
would be scope creep at `/implement` under `IM-4`.

**Three candidates a follow-up ticket should take**, all pure functions needing no
device, and all places where a defect is invisible until it reaches a user:

- **the model's tolerant parse** — `rating`, `created_at` and `reply_created_at`
  are nullable and `meta` may be absent; a wrong parse throws on a real payload
  and shows an empty tab;
- **the create-versus-edit choice** — it is read from `has_reply` alone
  (`AC-22`). Getting it backwards sends `POST` where `PUT` belongs and the reply
  silently fails to save;
- **the staleness guard** — the generation counter plus captured shop id
  (`AC-3`), including the rule that a stale response must emit *nothing at all*
  rather than a terminal status.

**If `/implement` finds existing behaviour to be wrong** (`IM-12`), note that
`flutter_test` has **no strict expected-failure marker**, and `test/` and
`integration_test/` contain zero uses of `skip:`, `markTestSkipped` or `throwsA` —
there is no precedent to copy. Record the `BUG-n` in `implement.md > Findings`,
carry it into `verify.md > Findings`, and open a separate ticket. Do **not** add a
skipped test to the suite: a `skip:` in `flutter_test` is not strict, so it would
stay green after the bug is fixed and prove nothing.

## Validation strategy

- Validation profile: `codegen-change`
- **The one-profile gap, stated rather than hidden.** A work item may name only one
  profile and none covers codegen *and* localization together. `codegen-change`
  gives `build-runner-clean` + `flutter-analyze`. This change also needs
  `locale-keys-clean` and `locale-bundles-in-sync` from `localization-change`, and
  `/verify` runs those two **in addition to** the profile, recording each exit code.
  Their commands stay in `.claude/project-config.yaml > validation_checks` (VP-4);
  none is written here. **This is the third work item to hit the same gap** — a
  combined profile is a governance change and is not made here.
- **All four checks, and what each proves:**
  - `flutter analyze` — no new errors anywhere in the package. This is the check
    that catches a missed `switch` arm over `ServerName`, since both switches are
    exhaustive.
  - `dart run build_runner build --delete-conflicting-outputs && git diff --exit-code`
    — the four new `@injectable` use cases and the four new bloc constructor
    parameters are reflected in `di_container.config.dart`.
  - `flutter pub run easy_localization:generate … && git diff --exit-code` — the
    generated key file matches the bundles, proving it was regenerated and not
    hand-edited.
  - `py .claude/scripts/check_locale_parity.py` — every key this work item adds is
    in all four bundles. The script is baseline-aware and ignores the 19
    pre-existing missing-key slots, which belong to the sibling work item's open
    `BUG-1` and are **not** this work item's debt.
- **Code evidence per `AC-n`.** `OQ-7` makes reading the implementation the
  acceptance evidence. `/verify` records, for each `AC-n`, the file and the lines
  that satisfy it — not a claim that it works.
- **One targeted check `AC-35` needs, because no automated check covers it.**
  `AC-35` says no request the app already sends gains or loses a header. Prove it
  by reading the diff of `detect_server.dart`: exactly two `case` arms are added
  and no existing arm is edited. Record the diff of that file in `verify.md`. This
  is cheap and it is the only evidence for the criterion with the widest blast
  radius in the change.
- **No device run is claimed.** Nothing in `verify.md` may state that a screen was
  observed working. `OQ-7` fixed this basis at `spec`, so it is a recorded
  limitation, not a shortfall discovered at the gate.

## Rollback

- The change is one branch and one PR. Reverting the merge commit removes it
  whole; nothing here writes stored data, so there is no migration to undo.
- **The two generated files must be regenerated after a revert, not reverted by
  hand** — `gen.sh` for the DI config and `keys.sh` for the locale keys.
- **The riskiest single line is the new `ServerName` value.** It is additive: no
  existing `case` is touched, so reverting it cannot leave another feature without
  a base URI or a token. If it has to come out on its own, remove the value and the
  four data-source methods together — the compiler will find every reference.
- Nothing outside the seller dashboard is modified, so a revert cannot affect
  chat, calls, stories, wallet or the buyer-side product screens.

## Plan ↔ REQ / AC traceability

| Step | Satisfies |
|------|-----------|
| 1 Endpoint constants | REQ-3, REQ-6, REQ-7, REQ-8 |
| 2 Server routing (protected) | CON-1, CON-2, AC-35 |
| 3 Model | AC-8, AC-9, EC-1, EC-2, EC-3 |
| 4 Data source | AC-2, AC-17, REQ-3, REQ-6, REQ-7, REQ-8 |
| 5 Repository | AC-26 (status codes survive as `DioFailure`) |
| 6 Use cases | REQ-3, REQ-6, REQ-7, REQ-8 |
| 7 Permissions | AC-18, AC-19, AC-20 |
| 8 State | AC-5, AC-6, AC-13, AC-14 |
| 9 Events | AC-6, AC-13, AC-21, AC-23 |
| 10 Bloc | AC-3, AC-4, AC-21, AC-22, AC-23, AC-24, AC-26, AC-27, AC-28, AC-29, AC-30 |
| 11 Screen | AC-1, AC-8, AC-9, AC-10, AC-11, AC-12, AC-13, AC-14, AC-15, AC-16, AC-25, AC-29, AC-30, AC-33, AC-34 |
| 12 Entry point | AC-1, AC-19 |
| 13 Localization | AC-31, AC-32, AC-36 |
| 14 Regenerate DI | AC-36 |

## Answers to the questions the spec deferred (PL-12)

- **OQ-1 — Token routing.** **Add a new `ServerName` value.** Giving
  `ServerName.webApp` a token would change 17 existing unauthenticated calls,
  which `AC-35` forbids. The new value is referenced by four new methods and
  nothing else. It edits a protected runtime path, so the review gate approves it
  explicitly.
- **OQ-6 — Empty state.** **Reuse `EmptyStateWidget`.** It already draws a round
  grey circle with an icon, a title and a message — the exact structure of
  `emptyScreen.jpeg`. A bespoke widget would duplicate it.
- **OQ-10 — Where the screen lives.** **Its own file** under
  `presentation/widgets/`. `dashboard_page.dart` is already 4778 lines; adding a
  screen, a card and a dialog to it makes the file worse and the diff unreadable.
  Its change stays three lines: remove the stub, add the import, gate the tab. The
  two newest sibling files (`location_form_sheet.dart`,
  `display_text_sanitizer.dart`) were split out the same way.
- **OQ-11 — State shape.** **Flat per-tab fields**, matching the Locations
  precedent: one list model and one status per tab, plus one shared write status.
  **The page number is not a separate field** — it lives inside each tab's own
  `meta`, which is where the server puts it, so the two cannot drift apart.

## Out of scope

- The batch per-product counter endpoint (`OQ-12`).
- Liking or un-liking anything; replying to a review (`CON-7`).
- Adding a per-request header facility to `GET`, `PUT` or `DELETE` in
  `lib/core/api/` (`CON-2`). This work item is designed not to need one.
- Fixing `BaseApi`'s habit of leaving headers on the shared `Dio` client. It is
  pre-existing, its blast radius is the whole app, and `AC-35` ensures this change
  does not rely on it.
- Bringing the four language bundles back into parity — the sibling work item's
  open `BUG-1`.
- Any Sentry reporting (`OQ-8`).
- Any automated test (see **Tests** above, and the three follow-up candidates
  named there).
