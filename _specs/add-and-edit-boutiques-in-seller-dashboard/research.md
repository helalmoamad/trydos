---
ticket: add-and-edit-boutiques-in-seller-dashboard
stage: research
mode: standard
status: complete
owner: ai_agent
updated: 2026-10-04
links:
  clickup: "https://app.clickup.com/t/z8n6b60hxc"
  github:
---

# Research — add-and-edit-boutiques-in-seller-dashboard

> Read-only phase. **No implementation is allowed in this command.**

## Goal

Let a shop member create a boutique, open one in view mode, edit it in every
language, and set it active or inactive from the seller dashboard's Boutiques
tab, with the same contract and rules as the website
(`.claude/docs/seller-dashboard-boutiques-dev-guide.md`, design
`.claude/htmlScreens/addBoiutic.html`).

## Summary of findings

1. **The Boutiques tab is list-only today.** `_buildBoutiquesTab()`
   (`lib/features/dashBoard/presentation/pages/dashboard_page.dart:2002`) renders
   `BoutiquesGridWidget`. Its `onAddBoutique` is an empty `TODO` (`:2030-2032`),
   the empty-state action has no callback (`:2049-2054`), and `BoutiqueCard`'s tap
   only logs (`lib/features/dashBoard/presentation/widgets/boutiques_grid_widget.dart:80-81`).
2. **The only boutique endpoint is the list.** `DashBoardEndPoints.getBoutiques`
   (`lib/common/constant/configuration/dashBoard_url_routes.dart:18`), read by
   `getBoutiques({page})`
   (`lib/features/dashBoard/data/data_source/dashBoard_remote_data_source_model.dart:145`).
   The mobile list pages (`GetBoutiquesEvent(page)`, `boutiquesMeta`); the web does
   not. No lookups, create, edit, update or change-status call exists.
3. **Locations is the exact pattern to copy.** It has the same six-call shape —
   list, `lookups`, create (`POST` collection), `/{id}/edit`, `/{id}/update`
   (`POST`), `/{id}/change-status` (`POST`) — at
   `dashBoard_url_routes.dart:45-81` and data source `:603-716`. It was built and
   verified under `_specs/manage-shop-locations-in-seller-dashboard/` (status
   `completed`). Its plan, protected-path list and tenant-safety decisions apply
   here almost one to one.
4. **`X-Seller-ID` is sent two ways.** `BaseApi` adds it to every request from
   `PrefsRepository.getXSellerId` (`lib/core/api/base_api.dart:35`). Locations
   writes also pin the shop id captured when the action started, through
   `RequestConfig.extraHeaders` built by `_sellerHeader()` (data source
   `:855-860`). Only `post.dart` honours `extraHeaders`; `get.dart` ignores it.
   All boutique writes are `POST`, so the Locations approach works without
   touching `lib/core/api/**`.
5. **Shop-switch safety already has a pattern.** `LocationsWidget` records
   `_sellerIdAtOpen`, clears a list loaded for another shop
   (`loadedForSellerId`), and clears again on `dispose`, because `DashboardBloc`
   is an app-wide singleton that is never disposed (`dashboard_page.dart:3090-3115`).
6. **`DashboardBloc` is an app-wide `lazySingleton`**
   (`lib/core/di/di_container.config.dart:1132`, provided in
   `lib/service/service_provider.dart:30`). It is a plain `Bloc` with an
   `Equatable` state (`dashBoard_state.dart:107`), **not** a `HydratedBloc` — no
   stored payload to migrate. Locations writes use `droppable()` and loads use
   `restartable()` from `bloc_concurrency` (`dashBoard_bloc.dart:194-225`).
7. **Media upload is ready for single files with a folder.**
   `uploadToMediaServer` / `UploadFileMediaServerUseCase`
   (`lib/core/domin/usecases/upload_file_media_server_usecase.dart:20-66`) mints a
   ticket with `folder` and `count: 1`, then calls `/gated/upload`. Shop Info
   already uploads with `folder: 'seller'` and stores
   `_bareFileName(r.subPath ?? r.url)` (`dashBoard_bloc.dart:1181-1188`,
   `:1284-1320`) — the same "bare file name" rule the guide (§7.2) asks for.
   Bulk upload exists in the repository
   (`common_use_repo_data_source.dart:107`, `BulkUploadResponseModel` handles
   `url` / `urls`) but has **no use case** and no caller.
8. **Permissions exist in the enum but not in the checker.** `DashBoardPermission`
   has `CREATE_BUTIKS`, `UPDATE_BUTIKS`, `CHANGE_BOUTIQUE_STATUS`, `DELETE_BUTIKS`,
   `READ_BUTIKS`, `READ_BOUTIQUES`
   (`lib/features/dashBoard/presentation/widgets/permission_enum.dart:19-58`).
   `DashboardPermissionChecker` has only `canSeeBoutiques()` (READ_BOUTIQUES or
   READ_BUTIKS); Locations added one method per action — the pattern to follow.
   The web shows the tab for **any** of the five boutique permissions; mobile
   shows it only for read.
9. **No `GET /languages` call exists in the app.** The only language list is
   `StartingSettings.languages` (`lib/features/home/data/models/starting_settings_response_model.dart:201`),
   with `code` and `name` only — no `native_name`, no RTL flag. The app's own
   locales are the four in `assets/languages/` (`ar-SY`, `en-US`, `ku-IQ`, `tr-TR`).
10. **No rich-text editor package.** `pubspec.yaml` has `flutter_html: ^3.0.0-beta.2`
    (display only, used in chat and product details). Nothing edits HTML.
11. **No localized country names.** `lib/common/constant/countries.dart` holds
    English names only (`name`, `code`, `dialCode`). The guide wants chip labels
    built from `iso` in the app language. Locations accepted showing backend
    country names untranslated (its amended `AC-26`).
12. **Pickers and image checks.** Dashboard image flows use `file_picker`
    (`FilePicker.platform.pickFiles`, `dashboard_page.dart:3762`, `:4241`). No
    image-size package is used; width and height can be read with `dart:ui`
    (`decodeImageFromList`) without a new dependency.
13. **List model does not fit the edit answer.** `Boutique` in
    `get_seller_boutiques_model.dart:92-194` has `countriesIso` as a `String` and
    `banners` as `List<List<Banner>>`. The `/edit` answer (guide §9.4) has
    `restricted_countries_iso` (list), `related_product_ids`, `availability` and
    `translations[]` with per-language banners. New models are needed; the list
    model is not changed.
14. **List card shows HTML as text.** `BoutiqueCard` renders
    `boutique.description ?? boutique.bio` directly (`boutiques_grid_widget.dart:74`);
    the guide says strip tags and cut at 100 characters. Out of the ticket's
    scope (list unchanged), noted for `spec`.
15. **Locale keys.** `boutiques`, `no_boutiques_found`, `add_boutique` already
    exist (`assets/languages/en-US.json:311`, `:744`, `:747`). Every new string on
    the new pages needs a key in all four bundles, then `sh keys.sh`.

## Relevant directories

- `lib/features/dashBoard/presentation/pages/` — `dashboard_page.dart` (4762
  lines) holds `DashboardContentPage`, `_buildBoutiquesTab`, `LocationsWidget`,
  `ShopInfoWidget`, `GalleryScreen`. New boutique pages are better in their own
  file(s) than in this file.
- `lib/features/dashBoard/presentation/widgets/` — `boutiques_grid_widget.dart`,
  `dashboard_permission_checker.dart`, `permission_enum.dart`,
  `display_text_sanitizer.dart`, `location_form_sheet.dart` (form pattern),
  `empty_state_widget.dart`.
- `lib/features/dashBoard/presentation/bloc/` — `dashBoard_bloc.dart` (2299
  lines), `dashBoard_event.dart`, `dashBoard_state.dart`.
- `lib/features/dashBoard/data/` — remote data source, repository impl, models.
- `lib/features/dashBoard/domain/` — repository interface, one use case per call
  (`create_shop_location_usecase.dart`, `get_shop_location_for_edit_usecase.dart`,
  `update_shop_location_usecase.dart`, `change_shop_location_status_usecase.dart`
  are the models to copy).
- `lib/core/domin/usecases/upload_file_media_server_usecase.dart` and
  `lib/core/data/` — media-server upload (read and reused, not changed).
- `assets/languages/` — four locale bundles.
- `test/` — unit tests (see below).

## Relevant config files

- `lib/common/constant/configuration/dashBoard_url_routes.dart` — endpoint
  constants (**protected**, `*_url_routes.dart`).
- `lib/common/constant/configuration/media_server_url_routes.dart` — upload
  endpoints (read only; not changed).
- `lib/core/di/di_container.config.dart` — generated DI (**protected**,
  `lib/core/di/**`); regenerated by `sh gen.sh` when a new `@injectable` use case
  or a new bloc constructor argument appears.
- `assets/languages/*.json` and `lib/generated/locale_keys.g.dart` —
  **protected**; the second is generated by `sh keys.sh`.
- `pubspec.yaml` — changes only if `OQ-1` chooses an editor package.
- `.claude/project-config.yaml` — validation profiles (`flutter-standard`,
  `codegen-change`, `localization-change`).

## Possibly affected services

- **Market / dashboard backend** (`ServerName.dashBoard`, `MARKET_URL`) — six
  boutique calls under `/api/v1/shop/boutiques…`.
- **Media server** (`ServerName.mediaServer`) — ticket + upload for icons
  (`boutiques/boutiques/icon`) and banners (`boutiques/boutiques`).
- **`GET /languages`** — server not yet decided (`OQ-6`).
- **`DashboardBloc` (app-wide)** — every dashboard tab shares it. New state
  fields and handlers affect `props` equality and therefore rebuilds of every
  `BlocBuilder` without a tight `buildWhen`.
- **Generated DI container** — a new use case changes `DashboardBloc`'s
  constructor, so the generated registration changes too (as it did for
  Locations).

## Protected runtime paths likely touched

| Path | Why | Note |
|---|---|---|
| `lib/common/constant/configuration/dashBoard_url_routes.dart` | new endpoints | additive, as Locations did |
| `lib/features/dashBoard/presentation/bloc/dashBoard_state.dart` | new status fields (if state lives in `DashboardBloc`, `OQ-9`) | not hydrated — nothing to migrate |
| `lib/core/di/di_container.config.dart` | regenerated for new use cases | generated — never hand-edit |
| `assets/languages/*.json` | new strings | all four bundles |
| `lib/generated/locale_keys.g.dart` | regenerated | generated — never hand-edit |

Nothing in `lib/core/api/**` needs to change: all writes are `POST`, and
`post.dart` already honours `extraHeaders` (finding 4). No `ServerName` entry is
added unless `OQ-6` chooses a server that has none.

## Test / validation commands available

Not run in this stage.

- `flutter analyze` — profile `flutter-standard` (check `flutter-analyze`).
- `dart run build_runner build --delete-conflicting-outputs && git diff --exit-code`
  — check `build-runner-clean`, profile `codegen-change` (same as `sh gen.sh`).
- `flutter pub run easy_localization:generate -S assets/languages -f keys -o locale_keys.g.dart && git diff --exit-code`
  — check `locale-keys-clean` (same as `sh keys.sh`).
- `py .claude/scripts/check_locale_parity.py` — check `locale-bundles-in-sync`.
- Profile `localization-change` = parity + keys + analyze.
- `flutter test` — runs every `*_test.dart` under `test/`. **Not** a check in
  `.claude/project-config.yaml`; that file says "No test-runner check by
  decision … a plan therefore records `none - <reason>` for every AC-n" (see
  `OQ-5`).

### Test layout and naming convention

- `test/` mirrors `lib/` one directory at a time; a file is the unit's name plus
  `_test.dart` (`test/README.md`, "Layout"). Example:
  `lib/core/api/token_refresh_coordinator.dart` →
  `test/core/api/token_refresh_coordinator_test.dart`. Some feature tests are
  named by scenario instead (`test/features/home/writing_a_review_test.dart`).
- Runner: `flutter test`; packages `flutter_test`, `bloc_test ^9.1.7`,
  `mockito ^5.4.4` (dev dependencies in `pubspec.yaml`).
- Shared fakes: `test/helpers/` (`network_harness.dart`, `session_prefs.dart`,
  flow harnesses). Helpers are written only when a test needs them.
- Expected-failure convention: a known defect is **pinned** — the test asserts
  the current wrong behaviour, says so in a comment, and is listed under
  "Defects" in `test/README.md`. `skip:` with a reason is used for disabled
  features (`four_server_login_test.dart:292`). There is no
  `expect-fail`-style marker in the suite.
- **Existing coverage for this change: none.** No file under `test/` covers
  `lib/features/dashBoard/**`. The closest unit test is
  `test/core/domin/usecases/upload_pipeline_test.dart` (the upload path this
  feature reuses, not changed by it).

## Risks and unknowns

- **Wrong per-language key on create** (`boutique_custom_data` vs
  `custom_data`) silently drops every translation (guide §8.2). High impact,
  easy to miss without a test on the payload builder.
- **Folder path in file names** doubles the folder on the backend (guide §7.2).
  The existing `_bareFileName` covers it if reused for both new uploads and
  existing URLs from `/edit`.
- **Banner list is full-replace per language.** A banner sent without its `id`
  is a new row; an existing banner left out is deleted. A payload bug can delete
  a seller's banners. High impact.
- **Shop switch during a long form session.** The form can stay open while the
  shop changes in prefs; a write must carry the shop id captured at open
  (Locations `AC-23` pattern), and a load answer for another shop must be
  dropped.
- **App-wide bloc growth.** Adding a large form state to `DashboardBloc` makes
  its state and constructor bigger again (already 2299 lines in the bloc,
  476 in the state). See `OQ-9`.
- **Size of the ticket.** Create + edit + status + 4-language form + upload
  queue + copy-from is large for one ticket (`OQ-4`).
- **Activation will often be refused** for new boutiques (no product picker,
  `OQ-3`); the refused-status path must be solid, not an edge case.
- **Contract not in the backend repo** for create and lookups (`OQ-2`).
- **Rich-text choice** may add a dependency and change the estimate (`OQ-1`).

## Open questions

| ID | Question | Why it matters |
|----|----------|----------------|
| OQ-1 | How is **Description** edited on mobile: (a) add a rich-text editor package with Bold / Italic / Underline / H2 that outputs HTML, or (b) a plain multi-line field whose text is sent wrapped in `<p>…</p>` (and existing HTML shown read-only / stripped for editing)? | No editor package exists (finding 10). (a) adds a dependency and ~6h; (b) can lose existing formatting on save. Decides `pubspec.yaml` scope and an AC. |
| OQ-2 | Are the shapes of `POST /shop/boutiques` (`boutique_custom_data`, answer `data.boutique_id`) and `GET /shop/boutiques/lookups` (object directly under `data`) confirmed by the backend owner, or recorded as explicit assumptions? | Guide §10.1: they come from web code, not from the backend contract. Intake condition: `spec` may not fix an `AC-n` on them until answered. |
| OQ-3 | How is a boutique created on mobile expected to reach **active**, given there is no product picker? Is the refused-status message enough, or should create mode explain it up front? | Activation needs active related products (guide §5.4). Without an answer, the "set active" happy path is not reachable for a new boutique. |
| OQ-4 | Keep one ticket, or split — for example (A) view + edit + status, then (B) create? | "One ticket = one focused outcome" (CLAUDE.md). Both halves share models, form and upload, so a split puts the form in A and only the create call + create page in B. |
| OQ-5 | Tests: `.claude/project-config.yaml` has no test-runner check, so PL-13 forces `none — <reason>` for every `AC-n`. Do we (a) keep that, or (b) first add a `flutter test` check/profile in a separate governance change so the payload builder (`custom_data` vs `boutique_custom_data`, banner ids/sequence, bare file names) can be proven by a unit test? | The riskiest logic here is pure and easy to unit-test, and `test/` already exists with a runner and conventions — but no profile can execute it today. |
| OQ-6 | Where do the **language tabs** come from: (a) new `GET /languages` call (guide §9.8; which `ServerName`?), (b) `StartingSettings.languages` already loaded by the app (code + name only), or (c) the four app locales fixed in code? | No `/languages` call exists (finding 9). (a) may need a server decision and has an unfixed answer shape; (b) lacks `native_name`; (c) misses a new backend language. |
| OQ-7 | **Country chip labels**: show the backend `name` from lookups (as Locations did), or build a localized name from `iso` (guide §6.6), which needs a localized country table the app does not have? | `countries.dart` is English-only (finding 11). Localizing adds data for 4 languages; not localizing differs from the web. |
| OQ-8 | Should the Boutiques **tab** show for any of the five boutique permissions (web behaviour), or keep today's rule (READ only)? | `canSeeBoutiques()` checks only READ (finding 8). A user with only `CREATE_BUTIKS` cannot reach the Add button on mobile today. |
| OQ-9 | Where does the editor state live: (a) new fields and handlers in the app-wide `DashboardBloc` (Locations pattern), or (b) a feature-local Bloc/Cubit created by the boutique page? | (a) grows a 2299-line singleton and `dashBoard_state.dart` (protected) and needs clear-on-dispose; (b) is "normal work" per CLAUDE.md, keeps the form off the singleton, but is a new pattern in this feature. Both need DI regeneration if use cases are `@injectable`. |
| OQ-10 | Banner upload: one `uploadToMediaServer` call per file (matches the web's one-at-a-time queue, reuses the tested path), or add a use case over the existing bulk upload? | Bulk has no use case or caller (finding 7). Single uploads need no new core code. |
| OQ-11 | Does the mobile list need any change in this ticket: refresh after save (`GetBoutiquesEvent` for the current page or page 1?), status pill after a status change, HTML stripped in card text (finding 14)? | The ticket says "list unchanged" but also "refresh after save". Paging (finding 2) makes "which page" a real choice. |
| OQ-12 | Is the **view mode** needed on mobile, or does tapping a card open edit directly (still with Cancel)? | The web opens in view mode then **Edit**. A user without `UPDATE_BUTIKS` gets 403 anyway (guide §3.3 note), so view mode only matters for users who can edit. Affects screens and ACs. |

## Notes

- No code was changed during research.
- No observability runtime configs were modified (`features.observability: false`).
- Sources read: the dev guide, the HTML design, intake, the Locations work item
  (`plan.md` "Files to change" and steps 13-14), and the files cited above.
