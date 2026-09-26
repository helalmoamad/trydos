---
ticket: read-and-reply-to-customer-comments-in-seller-dashboard
stage: research
mode: standard          # single workflow form — no other modes (ADR-009)
status: complete        # not_started | in_progress | blocked | complete
owner: ai_agent
updated: 2026-09-09
links:
  clickup: "https://app.clickup.com/t/z8n6b5yctu"
  github:
---

# Research — read-and-reply-to-customer-comments-in-seller-dashboard

> Read-only phase. **No implementation is allowed in this command.**

## Goal

Build the "Customers Comments" screen of the seller dashboard: two tabs (FAQ and
Reviewing), a paginated comment list, an empty state, and a reply dialog that
creates, edits, and deletes a seller reply on FAQ comments only.

## Relevant directories

- `lib/features/dashBoard/presentation/pages/dashboard_page.dart` — **4778 lines**,
  and it holds the whole screen set. The entry point is already there: a
  `_FilterItem` at index 10 (`dashboard_page.dart:1713-1719`,
  `LocaleKeys.customers_comments.tr()`, subtitle `'Reply to reviews and FAQ'`),
  `_buildBody`'s `case 10: return CustomerComments();`
  (`dashboard_page.dart:1932-1933`), and the target widget itself
  (`dashboard_page.dart:4766-4778`) whose `build` returns `const Placeholder()`.
  `LocationsWidget` (`:3035`), `ShopInfoWidget` (`:3676`) and `GalleryScreen`
  (`:4200`) all live in this same file — so the house style puts a dashboard
  screen here, not in its own file. See `OQ-10`.
- `lib/features/dashBoard/presentation/widgets/` — the shared pieces this screen
  can reuse: `empty_state_widget.dart` (`EmptyStateWidget`: optional round grey
  icon, title, message — the exact shape of `emptyScreen.jpeg`),
  `pagination_widget.dart` (`PaginationWidget`, but it is a **previous / next**
  pager, not "Load More" — see `OQ-9`), `permission_enum.dart`,
  `dashboard_permission_checker.dart`, `display_text_sanitizer.dart`.
- `lib/features/dashBoard/presentation/bloc/` — one bloc for the whole dashboard:
  `dashBoard_bloc.dart` (1813 lines), `dashBoard_event.dart` (296),
  `dashBoard_state.dart` (405). `DashboardBloc extends Bloc<...>`
  (`dashBoard_bloc.dart:75`) — **not** `HydratedBloc`, so
  `CLAUDE.md`'s hydrated-state rule does not apply to this work item.
  `DashBoardState extends Equatable` (`dashBoard_state.dart:83`) with a single
  large `copyWith` (`:207`), and one `enum <Thing>Status { init, loading, success,
  failure }` per operation at the top of the file.
- `lib/features/dashBoard/data/data_source/dashBoard_remote_data_source_model.dart`
  (746 lines) — every dashboard HTTP call. Each method builds a
  `GetClient` / `PostClient` / `DeleteClient` with a `RequestConfig` and returns it.
- `lib/features/dashBoard/data/models/` — one model file per response, hand-written
  `fromJson` (no `json_serializable` in this feature). `get_shop_locations_model.dart`
  is the newest and the closest pattern, including its own `ShopLocationsMeta` (`:151`).
- `lib/features/dashBoard/domain/useCase/` — one `@injectable` use case per call,
  each a `UseCase<Model, Params>` returning `Either<Failure, Model>`.
- `lib/features/dashBoard/domain/repositories/` +
  `lib/features/dashBoard/data/repositories/` — the interface and its impl; every
  method wraps the data source in `handlingExceptionRequest`.
- `lib/core/api/` — the shared HTTP layer. **Protected runtime path.** The files
  that matter here are `base_api.dart`, `methods/detect_server.dart`,
  `methods/get.dart`, `methods/post.dart`, `methods/put.dart`, `methods/delete.dart`,
  `handling_exception.dart`.
- `assets/languages/` — the four bundles (`ar-SY`, `en-US`, `ku-IQ`, `tr-TR`).
- `.claude/docs/Images/` — the three design images that fix this screen.

## Relevant config files

- `.claude/docs/mobile-seller-dashboard-api-guide.md` — section **Comments &
  Reviews** (lines 366-431) is the contract: five endpoints, the comment field
  list, the `meta` shape, and the behaviour rules (reviews have no reply,
  create-vs-edit decided by `has_reply`, `reply_text` ≤ 1000 chars HTML-stripped,
  `page_size` default 10 / max 50, reactions display-only).
- `.claude/project-config.yaml` — the validation checks and profiles (below).
- `lib/common/constant/configuration/web_app_url.dart` — `WebAppEndPoints` (where
  the new `/api/seller/comments…` paths belong, since they are `{WEB_API}` paths,
  **not** `DashBoardEndPoints`) and `WebUrls.baseUri = dotenv['WEB_APP']`.
- `lib/core/api/methods/detect_server.dart` — `enum ServerName` (15 values) plus
  `getBaseUriForSpecificServer` and `getServerToken`. **Protected.**
- `.env` — `WEB_APP` is the `{WEB_API}` base; `MARKET_URL` is `{MARKET_API}`.
- `pubspec.yaml` — `dev_dependencies` already carry `flutter_test`,
  `integration_test` and `mockito ^5.4.4`.

## Possibly affected services

- **`{WEB_API}` (`WEB_APP`)** — the five comments endpoints. Already used by 17
  call sites in `lib/features/home/data/data_sources/home_remote_data_source.dart`
  through `ServerName.webApp`, all of them **unauthenticated** today.
- **`{MARKET_API}` (`MARKET_URL`)** — not called by this feature, but it is the
  source of the market token these endpoints need, and of the permission list
  (`auth/permissions`).
- **The shared `Dio` singleton** — `BaseApi`'s constructor mutates
  `client.options.headers` **in place** (`base_api.dart:13-50`) for every request,
  on a `Dio` resolved from `GetIt`. It sets `Authorization` only when
  `getServerToken(serverName)` is non-null and **never clears it otherwise**, so a
  request to a token-less server currently inherits whatever `Authorization` the
  previous request left behind. This is pre-existing and out of scope to fix, but
  it means "the call happened to work on a device" is not evidence that the token
  routing is correct. See `OQ-1` and the risks below.

## Test / validation commands available

From `.claude/project-config.yaml` (definitions in `validation_checks`, selection
in `validation_profiles`). **Not run at research.**

- `flutter analyze` — check `flutter-analyze`, pass on exit 0.
- `dart run build_runner build --delete-conflicting-outputs && git diff --exit-code`
  — check `build-runner-clean` (same as `sh gen.sh`); needed because every new
  `@injectable` use case changes `lib/core/di/di_container.config.dart`.
- `flutter pub run easy_localization:generate -S assets/languages -f keys -o locale_keys.g.dart && git diff --exit-code`
  — check `locale-keys-clean` (same as `sh keys.sh`).
- `py .claude/scripts/check_locale_parity.py` — check `locale-bundles-in-sync`.
- Profiles: `flutter-standard` (analyze only), `codegen-change` (build-runner +
  analyze), `localization-change` (parity + keys + analyze),
  `hydrated-state-change` (not applicable — this bloc is not hydrated).
  This work item adds `@injectable` use cases **and** locale keys, so `plan.md`
  will need the union of `codegen-change` and `localization-change`.

### Test layout and naming convention (`PL-14` input)

- **Unit / widget tests:** `test/`. It holds exactly **one** file —
  `test/core/json_size_cap_test.dart` — mirroring `lib/core/…`. Naming is
  `<subject>_test.dart`; the runner is `flutter test`.
- **Integration tests:** `integration_test/`, **20** files grouped by feature
  (`auth/`, `chat/`, `home/`, …), same `<subject>_test.dart` naming, run with
  `flutter test integration_test/…` on a device.
- **There is no test anywhere for the dashboard feature** — no widget, bloc,
  model or data-source test. Every row of `plan.md > Tests` would therefore be
  `new`, never `extend`.
- **Expected-failure marker:** `flutter_test` has no built-in strict
  expected-failure marker like `pytest.mark.xfail`; the nearest thing is
  `expect(..., throwsA(...))` for a thrown case, or `skip:` on a `test` /
  `testWidgets`, which is **not** strict — a skipped test that starts passing
  reports nothing. `grep` over `test/` and `integration_test/` finds **zero** uses
  of `skip:`, `markTestSkipped` or `throwsA`, so there is no precedent to copy.
  If this work item records a `BUG-n` under `IM-12`, `plan.md` must state the
  exact marker it will use and how the suite stays green without hiding the bug.

## Risks and unknowns

- **The token routing is narrower than the ticket assumed.** The ticket offered a
  third option — "pass the header per request from the data source without
  touching `lib/core/api/**`". **That option does not work for this feature.**
  `RequestConfig.extraHeaders` is read by **`post.dart` only**
  (`post.dart:29, 41, 72-74`); `get.dart`, `put.dart`, `delete.dart` and
  `patch.dart` contain no reference to it at all, and the locations code says so
  in a comment (`dashBoard_remote_data_source_model.dart:587-593`). This feature
  needs **GET** (list), **POST** (create), **PUT** (edit) and **DELETE** (delete),
  so three of its four calls have no per-request header path. The real choice is
  between changing `getServerToken(ServerName.webApp)` — which would start sending
  an `Authorization` header on all 17 existing unauthenticated `webApp` call sites
  — and adding a new `ServerName` value that maps to `WebUrls.baseUri` with
  `prefsRepository.marketToken`, which touches no existing call site. Both edit
  `lib/core/api/methods/detect_server.dart`, a **protected runtime path**, and
  adding a `ServerName` entry is itself a protected-runtime trigger under
  `CLAUDE.md`. → `OQ-1`.
- **The permission strings do not exist in the app.** `DashBoardPermission`
  (`permission_enum.dart`) has 80 values and **none** of `READ_COMMENTS`,
  `REPLY_COMMENT`, `EDIT_REPLY`, `DELETE_REPLY`.
  `DashBoardPermission.fromString` returns `null` for an unknown string, silently.
  → `OQ-3`.
- **The permission list cannot say "unknown".** It reaches the screen as a
  non-null `List<String>` built with `shop.permissions ?? []`, so a list that
  failed to load and one that grants nothing are indistinguishable — recorded
  already for Shop Info (AC-7) and Locations (AC-18). Any read gate here inherits
  the same limitation and must fail closed.
- **The four language bundles are already out of parity at HEAD**: `ar-SY` 967
  keys, `en-US` 966, `ku-IQ` 967, `tr-TR` 949. This is the sibling work item's
  open `BUG-1`, not this ticket's debt. `check_locale_parity.py` is
  baseline-aware — it reports "19 pre-existing missing-key slot(s) ignored" and
  passes — so the check will not fail for pre-existing debt, but a key this work
  item adds must land in all four files.
- **Sentry is initialised but never called from feature code.**
  `SentryFlutter.init` runs in `main.dart:508`, and `Sentry.captureException`
  appears **zero** times anywhere in `lib/`. The dashboard's actual logging
  convention is a private `_log<Feature>(action, outcome)` helper that prints only
  under `kDebugMode` and carries the seller id and no request body
  (`dashBoard_bloc.dart:1149-1158`, `:1466-1474`). The ticket's Audit & Logging
  criteria name Sentry; the repository does not work that way. → `OQ-8`.
- **`dashboard_page.dart` is 4778 lines.** Adding a full screen plus a dialog
  inside it makes an already large file larger; putting it in its own file breaks
  the pattern the other three dashboard screens set. → `OQ-10`.
- **A stale response can land on the wrong shop.** The locations code solves this
  with a generation counter plus a captured `sellerId`
  (`_locationsResponseIsStale`, `dashBoard_bloc.dart:1486-1489`), because
  `_currentSellerId` is read live from `PrefsRepository.getXSellerId`
  (`:1147`). This screen has the same exposure — two tabs, paging, and a dialog
  that can outlive a shop switch — and needs the same guard.
- **`X-Seller-ID` is sent to `{MARKET_API}` only.** `BaseApi` adds it when
  `serverName == ServerName.dashBoard` (`base_api.dart:33-36`). The comments API
  wants `seller_id` in the **query or body** instead, and it is a different
  server, so the value has to be passed explicitly by each call. → `OQ-2`.
- **Error mapping is usable but coarse.** Dio throws on non-2xx, and
  `handlingExceptionRequest` catches `DioException` and returns
  `DioFailure(statusCode: e.response?.statusCode ?? 400, message: <body.message>)`
  (`handling_exception.dart:86-123`). So **403, 404 and 429 all arrive intact**
  with the server's `message`, and 401 also arrives as `DioFailure` unless the
  client threw `Unauth` first. `StatusCode` (`lib/enums/status_code_type.dart`)
  knows only 200/201/400/401/500 — there is no named constant for 403/404/429.
- **No design reference for a review card.** `getComments.jpeg` shows the FAQ tab;
  `emptyScreen.jpeg` shows the Reviewing tab **empty**. Nothing shows a review
  card with its `rating` stars. → `OQ-5`.
- **Acceptance evidence.** The sibling work item completed with code evidence only
  because no seller account was available to run the app against a real shop (its
  FINDING-2). Nothing in the repository says that changed. → `OQ-7`.

## Open questions

> Give each question a stable ID (`OQ-1`, `OQ-2`, …). `spec.md` must record an
> answer for every one of them (SP-9) — an answer given only in chat does not
> count.

| ID | Question | Why it matters |
|------|----------|----------------|
| OQ-1 | How do the comments calls get the **market token** onto the `{WEB_API}` base — by giving `ServerName.webApp` a token in `getServerToken`, or by adding a new `ServerName` value mapped to `WebUrls.baseUri` + `marketToken`? (The ticket's third option, a per-request header, is **ruled out**: only `post.dart` reads `extraHeaders`, and this feature needs GET, PUT and DELETE too.) | Both options edit `lib/core/api/methods/detect_server.dart`, a protected runtime path, so `/review` must approve it explicitly. Option (a) would add an `Authorization` header to 17 existing unauthenticated `webApp` calls; option (b) touches no existing call site. Without a decision, no request in this feature can be written. |
| OQ-2 | Is `PrefsRepository.getXSellerId` — the value the dashboard sends as the `X-Seller-ID` header to `{MARKET_API}` — the same id `{WEB_API}` expects in `seller_id`? | Every one of the five endpoints takes `seller_id`. A wrong id returns nothing rather than an error (the API guide says so), which looks exactly like an empty shop. |
| OQ-3 | Do `READ_COMMENTS`, `REPLY_COMMENT`, `EDIT_REPLY` and `DELETE_REPLY` actually arrive in the `auth/permissions` payload for a seller account? | They are absent from `DashBoardPermission`, and `fromString` drops unknown values silently. If the backend does not send them, every gate fails closed and the screen is unreachable. |
| OQ-4 | Without `READ_COMMENTS`, is the tab **hidden** (what the ticket says) or **visible with a message inside** (what Locations does, AC-28)? | Two live precedents disagree. It decides whether the change touches the filter-item list in `dashboard_page.dart` or only the screen body. |
| OQ-5 | How is a review card's `rating` drawn — how many stars, filled/half/empty, and where on the card? | No design image shows a review card. Guessing here produces a screen the designer did not approve. |
| OQ-6 | Does the empty state reuse `EmptyStateWidget` with `Icons.chat_bubble_outline`, or does `emptyScreen.jpeg` need its own asset? | `EmptyStateWidget` already draws a round grey icon + title + message, which matches the image. Reuse avoids a new widget; a bespoke asset does not. |
| OQ-7 | What counts as acceptance evidence for each `AC-n` — a manual run on a device against the development server, or static analysis plus code reading? Are seller credentials available this time? | The sibling shipped with code evidence only (its FINDING-2). Deciding at `spec` avoids discovering the gap at `verify`, where it becomes a completion caveat. |
| OQ-8 | The ticket's Audit & Logging criteria say failures go to **Sentry**. `Sentry.captureException` is called **nowhere** in `lib/`; the dashboard logs with a private `kDebugMode` print helper. Which does this work item implement? | Written as-is, the AC cannot be met by the pattern the repository actually uses. Either the AC changes to the `_log…` convention, or this work item becomes the first Sentry caller — a decision, not a detail. |
| OQ-9 | Is paging the ticket's **"Load More"** (append, one growing list) or the existing `PaginationWidget` (previous / next, one page at a time)? | `PaginationWidget` exists and is used by other dashboard tabs, but it is a different interaction from what the ticket describes, and `meta.has_more_pages` is shaped for "Load More". |
| OQ-10 | Does the screen stay inside `dashboard_page.dart` (4778 lines, where `LocationsWidget`, `ShopInfoWidget` and `GalleryScreen` all live) or move to its own file under `presentation/widgets/`? | It decides `plan.md > Files to change`. The newest sibling files (`location_form_sheet.dart`, `display_text_sanitizer.dart`) were split out, so the convention is drifting. |
| OQ-11 | Are FAQ and Reviewing two lists in **one** `DashBoardState` pair of fields, or one list plus a `type` field re-fetched on tab switch? | The ticket requires each tab to keep its own list, page and status. `DashBoardState` is one flat `Equatable` class with a single `copyWith`, so this decides how many fields the state grows. |
| OQ-12 | Which of the five endpoints does this work item call? The ticket puts `POST /comments/social` out of scope — confirm nothing on the screen needs the per-product counters. | It fixes the surface: four endpoints, not five, and no product-id batching logic. |

## Notes

- No code was changed during research. Only `_specs/<slug>/` was written.
- No observability runtime configs were modified — `features.observability` is
  `false` for this project.
- No validation command was run. `check_locale_parity.py` was executed once as a
  **read-only** measurement to establish the parity baseline quoted above; it
  writes nothing.
- The ClickUp task `z8n6b5yctu` was read once at intake and not written to.
