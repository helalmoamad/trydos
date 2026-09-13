---
ticket: connect-shop-info-widget-to-shop-info-api
stage: research
mode: standard          # single workflow form — no other modes (ADR-009)
status: complete        # not_started | in_progress | blocked | complete
owner: ai_agent
updated: 2026-08-24
links:
  clickup: "https://app.clickup.com/t/z8n6b5xchm"
  github:
---

# Research — connect-shop-info-widget-to-shop-info-api

> Read-only phase. **No implementation is allowed in this command.**

## Goal

Replace the mocked `ShopInfoWidget` with the real `GET`/`PUT
{MARKET_API}/shop/info` calls, including the logo and banner upload, wired
through the dashboard's existing data → domain → bloc layers.

## Relevant directories

- `lib/features/dashBoard/presentation/pages/dashboard_page.dart` — holds
  `ShopInfoWidget` (`:3369`–`:3652`). It is a plain `StatefulWidget` with **no
  bloc access at all**: three `TextEditingController`s seeded with `'Test'`,
  `'963937543498'`, `'sss'` (`:3378`–`:3386`), `_logoUrl` / `_bannerUrl` always
  `null` (`:3389`–`:3390`), `_pickLogo()` and `_pickBanner()` empty
  (`:3402`–`:3410`), and `_saveChanges()` awaiting
  `Future.delayed(const Duration(seconds: 1))` (`:3412`–`:3426`). It is mounted
  as tab `case 7` in `_buildTabContent()` (`:1921`).
- `lib/features/dashBoard/data/data_source/dashBoard_remote_data_source_model.dart`
  — `DashBoardRemoteDataSource`, one method per endpoint built from
  `GetClient` / `PutClient` with `serverName: ServerName.dashBoard`. The
  gallery methods are the closest model to copy.
- `lib/features/dashBoard/data/repositories/dashBoard_repository_impl.dart` and
  `lib/features/dashBoard/domain/repositories/dashBoard_repository.dart` — the
  repository pair. Every method returns `Either<Failure, T>` and the impl wraps
  the data source in `handlingExceptionRequest` (`:238`–`:250` for
  `getGalleryImages`).
- `lib/features/dashBoard/domain/useCase/` — one file per use case.
  `GetGalleryImagesUseCase.dart` is the pattern: an `@injectable` class
  extending `UseCase<Model, Params>` plus a small `Params` class.
- `lib/features/dashBoard/presentation/bloc/` — `dashBoard_bloc.dart`,
  `dashBoard_event.dart`, `dashBoard_state.dart`. `DashboardBloc` is
  `class DashboardBloc extends Bloc<DashBoardEvent, DashBoardState>`
  (`dashBoard_bloc.dart:65`) — **a plain `Bloc`, not a `HydratedBloc`**.
  `DashBoardState` is an `Equatable` with one `<Feature>Status` enum per call
  (`init | loading | success | failure`) and a `copyWith`.
- `lib/features/dashBoard/presentation/widgets/` —
  `dashboard_permission_checker.dart` (live `DashboardPermissionChecker`, used at
  `dashboard_page.dart:1551`/`:1556` and `dashboard_tab_bar.dart:29`),
  `permission_enum.dart` (87 lines, the `DashBoardPermission` enum), and
  `dashboard_tab_bar.dart`.
- `lib/core/domin/usecases/upload_file_media_server_usecase.dart` — **the gated
  upload flow already exists in the app.** The top-level helper
  `uploadToMediaServer({repository, file, folder, isStory, …})` mints a ticket
  (`POST /gated/ticket`) then uploads (`POST /gated/upload` with
  `X-Upload-Ticket`), and normalizes `folder`. `mint_upload_ticket_usecase.dart`
  and `lib/core/data/data_source/common_use_repo_data_source.dart` (`:52`, `:81`)
  hold the two halves.
- `lib/core/api/base_api.dart` — builds the headers for every request. For
  `ServerName.dashBoard` it sets `X-Seller-ID` from
  `GetIt.I<PrefsRepository>().getXSellerId` (`:34`), plus `country` (`:25`) and
  `lang` (`:37`). **Nothing per-call needs to add these headers.**
- `assets/languages/` — four locale files: `ar-SY.json`, `en-US.json`,
  `ku-IQ.json`, `tr-TR.json`.

## Relevant config files

- `lib/common/constant/configuration/dashBoard_url_routes.dart` —
  `DashBoardEndPoints` and the `shopScope()` / `usersScope()` extensions;
  `DashBoardUrls.baseUrl` reads `dotenv.env['MARKET_URL']`. **There is no
  `/shop/info` entry today.** This file is a **protected runtime path**
  (`*_url_routes.dart`).
- `lib/common/constant/configuration/media_server_url_routes.dart` —
  `MediaServerEndPoints.ticketEP = '/gated/ticket'`, `uploadEP =
  '/gated/upload'`, `ticketHeader = 'X-Upload-Ticket'`; base URL and api key from
  `MEDIA_SERVER_URL` / `MEDIA_API_KEY`. Also a protected runtime path.
- `.env` — holds `MARKET_URL`, `MEDIA_SERVER_URL`, `MEDIA_API_KEY`. Protected;
  **no new key is needed** — every value this ticket uses already exists.
- `lib/core/di/di_container.config.dart` — generated DI wiring. A new
  `@injectable` use case appears here only after `./gen.sh`; never hand-edited.
- `lib/features/dashBoard/presentation/widgets/permission_enum.dart` —
  `DashBoardPermission` carries `SUPER_ADMIN` (`:56`) and `READ_PRODUCTS`
  (`:60`), but **neither `READ_SHOP_INFO` nor `UPDATE_SHOP_INFO` exists**.
- `assets/languages/*.json` — `shop_name` (`:772`), `shop_information` (`:788`)
  and `shop_name_is_required` (`:812`) already exist in `en-US.json`. Protected
  runtime path.

## Possibly affected services

- **Market/dashboard backend** (`MARKET_URL`, `ServerName.dashBoard`) — two new
  calls, `GET` and `PUT /api/v1/shop/info`. Read and write; the `PUT` changes the
  shop's public profile, so a wrong body is visible to buyers.
- **Media server** (`MEDIA_SERVER_URL`) — two extra requests per picked image
  (ticket + upload) in the new folder `seller`. No other screen uses that folder
  today.
- **Permissions call** `GET /shop/auth/permissions` — already dispatched by
  `GetUserPermissionEvent` (`dashBoard_bloc.dart:132`, `:158`, and re-dispatched
  at `:325`). This ticket reads its result rather than adding a call.
- **`PrefsRepository`** — read-only use of `getXSellerId`. It is written at
  `dashboard_page.dart:1557` and `SelectShopForOrderPage.dart:308`; this ticket
  must not write it.

## Test / validation commands available

- `flutter analyze` — static analysis, configured by `analysis_options.yaml`.
- `flutter test` — the suite is **one file**, `test/core/json_size_cap_test.dart`.
  There is no widget test and no bloc test in the repository.
- `./gen.sh` → `dart run build_runner build --delete-conflicting-outputs` —
  regenerates `*.g.dart` and `di_container.config.dart`. Required after adding an
  `@injectable` use case.
- `./keys.sh` → `flutter pub run easy_localization:generate -S assets/languages
  -f keys -o locale_keys.g.dart` — regenerates `LocaleKeys`. Required after
  adding a translation key.
- `python .claude/scripts/check_locale_parity.py` — checks the four locale files
  hold the same keys.
- Manual run on a device against the dev market server — the only way to exercise
  the `PUT` and the upload end to end.

*Listed, not run — research is read-only.*

## Risks and unknowns

- **Protected runtime paths are unavoidable.** `dashBoard_url_routes.dart` must
  gain the `/shop/info` entry, and adding translation keys touches
  `assets/languages/**`. Both are on the CLAUDE.md protected list, so they may
  change only inside an approved `implement` stage with `plan.md` naming them.
  Impact: high if skipped (a hard stop); likelihood: certain.
- **The Shop Info tab is not gated at all today.** Its `_FilterItem` is written
  `visible: true` (`dashboard_page.dart:1684`), and
  `DashboardPermissionChecker` has `canSeeProducts()`, `canSeeBoutiques()`,
  `canSeeOrders()`, `canSeeUsers()`, `canSeeStories()` — **no `canSeeShopInfo()`**.
  The API guide's "skip the GET entirely" rule has nothing to hang on yet.
- **The permission enum is missing both values**, so a gate written today would
  compare raw strings unless the enum grows. Low effort, but it is a change to a
  shared enum other tabs read.
- **`*_state.dart` is a protected path by glob, but the risk it guards does not
  apply here.** The protection exists for `hydrated_bloc` payload migration;
  `DashboardBloc` extends plain `Bloc` (`dashBoard_bloc.dart:65`), so adding
  fields to `DashBoardState` cannot break a stored payload. The plan must say
  this out loud rather than let a reviewer assume a migration is needed.
- **The widget is entirely hardcoded English** — `'Edit Shop Info'`,
  `'Shop Name'`, `'Contact'`, `'Address'`, `'Shop Logo'`, `'Shop Banner'`,
  `'Change'`, `'Change Banner'`, `'Save Changes'`, `'Saving...'`, and the hint
  `'Country code must lead, e.g. AE = 971'`. The app ships four locales and is
  RTL-aware, so leaving them hardcoded means shipping an untranslated screen.
- **No test harness for this kind of change.** With one unrelated test file, the
  `verify` stage has no automated path to prove the acceptance criteria; it will
  rest on `flutter analyze` plus a manual device run.
- **The bare-filename round trip is a known, untested gap** (API guide, *Shop
  Info*): flattening `image`/`banner` to the part after the last `/` only works
  while shop media stays in the single `seller` folder.
- **No screen reads `currency` or `is_new_products_approval` today** — a repo
  search finds neither in `lib/features/dashBoard/`. Storing them adds state with
  no consumer yet.

## Open questions

> Give each question a stable ID (`OQ-1`, `OQ-2`, …). `spec.md` must record an
> answer for every one of them (SP-9) — an answer given only in chat does not
> count.

| ID | Question | Why it matters |
|------|----------|----------------|
| OQ-1 | The backend's own validation rules for `PUT /shop/info` (max lengths, real phone format, whether `image` may be `null`) are marked **not verified** in the API guide. Do we ship the guide's weak client-side rules and surface whatever `message` the backend returns, or block until Mohamad Hassan confirms the real rules? | Decides whether the ticket can finish without an answer from outside the repo, and whether the spec can state a testable validation rule at all. |
| OQ-2 | Should the Shop Info **tab entry** be hidden when `READ_SHOP_INFO` is missing (`dashboard_page.dart:1684` is hardcoded `visible: true`), or does the gate live only inside the screen body? | Changes which files the plan touches. Hiding the tab means editing the tab list and `DashboardPermissionChecker`, both shared with the other tabs. |
| OQ-3 | `READ_SHOP_INFO` and `UPDATE_SHOP_INFO` are absent from `DashBoardPermission` (`permission_enum.dart`). Is adding them in scope, or should the gate compare raw permission strings? | A shared enum is read by every other dashboard tab; growing it is a wider blast radius than a local string compare. |
| OQ-4 | Are the widget's eleven hardcoded English strings in scope — new keys in all four locale files plus `./keys.sh` — or does this ticket keep them as they are and leave localization to a follow-up? | `assets/languages/**` is a protected path, and the app is RTL-aware. Including it enlarges the change; excluding it ships an untranslated screen. |
| OQ-5 | `GET /shop/info` also returns `currency` and `is_new_products_approval`, which no screen reads today. Do we store them in `DashBoardState` now, or ignore them until a consumer exists? | The backlog ticket asserts both as acceptance criteria. If they are stored with no reader, `verify` cannot observe them from the UI. |
| OQ-6 | What clears the loaded record when the shop changes? `X-Seller-ID` is written into prefs at `dashboard_page.dart:1557` and `SelectShopForOrderPage.dart:308`; `DashboardBloc` has no shop-switch event. | The tenant-safety criterion ("switching shops must refetch and never show shop A under shop B") needs a real trigger, or it is untestable. |
| OQ-7 | Does the existing `uploadToMediaServer(...)` accept folder `seller` unchanged, and does its response give a bare filename or a `/folder/filename` path? | Decides whether the upload is pure reuse or needs new code, and it decides the exact flattening step before the `PUT`. |
| OQ-8 | With only `test/core/json_size_cap_test.dart` in the suite, how will `verify` evidence the acceptance criteria — new widget/bloc tests, or a recorded manual run plus `flutter analyze`? | `verify` requires evidence per AC. Agreeing the method now avoids a gate failure at the end. |

## Notes

- No code was changed during research. The only files written are inside
  `_specs/connect-shop-info-widget-to-shop-info-api/`.
- No observability runtime configs were modified.
- No validation command was run — they are listed above for later stages.
- Confirmed by reading, not assumed: the gated upload flow already exists
  (`upload_file_media_server_usecase.dart`), `X-Seller-ID`/`country`/`lang` are
  already injected centrally (`base_api.dart:34`), and `DashboardBloc` is not a
  `HydratedBloc` (`dashBoard_bloc.dart:65`).
