---
ticket: add-and-edit-boutiques-in-seller-dashboard
stage: plan
mode: standard
status: complete
owner: developer
updated: 2026-10-04
links:
  clickup: "https://app.clickup.com/t/z8n6b60hxc"
  github:
---

# Plan — add-and-edit-boutiques-in-seller-dashboard

> Decide the approach before changing code. Plan only — no implementation here.

## Approach

Copy the **Locations** layering (data source → repository → one `@injectable`
use case per call), which already solved the same six-call contract and its
tenant safety (`_specs/manage-shop-locations-in-seller-dashboard/`). Put the
boutique page's state in a **new feature-local `BoutiqueEditorBloc`**, registered
as a DI *factory* and created by the boutique page, instead of growing the
app-wide `DashboardBloc`. The form logic that decides what is sent — building the
form from `/edit`, building the create / update body, validation, banner file
checks — lives in **pure functions** with no Flutter or network dependency, so
it is small, reviewable, and testable later. Description uses **`flutter_quill`**
with HTML converted in and out.

**Why the feature-local bloc over `DashboardBloc`:** the form state is large
(four languages × five fields, two saved copies, an upload queue). On the
app-wide singleton it would need clear-on-dispose and shop-switch guards, and it
would change `dashBoard_state.dart` (protected). A bloc that lives and dies with
the page is dropped automatically when the page closes (AC-3), and
`dashBoard_state.dart` is **not touched**. A feature-local bloc is normal work
per CLAUDE.md; the repository already registers `@injectable` factory blocs
(`SensitiveConnectivityBloc`, `di_container.config.dart:475`).

## Deferred questions answered (PL-12)

| OQ | Answer |
|----|--------|
| OQ-9 | New feature-local `BoutiqueEditorBloc` (`@injectable`, factory — not a singleton, not added to `ServiceProvider`). Created per page with the shop id captured at open. `DashboardBloc` only gains a list-clear event and a `restartable()` transformer on the list load (Step 9). |
| OQ-10 | One `UploadFileMediaServerUseCase` call per file (the existing, tested single-file path; `test/core/domin/usecases/upload_pipeline_test.dart`). Icon folder `boutiques/boutiques/icon`, banner folder `boutiques/boutiques`. The banner queue runs files one at a time (AC-23), so bulk upload adds nothing. No core code changes. |
| OQ-1a | `flutter_quill` (11.6.0 on pub.dev, needs Dart `^3.12.0` / Flutter `>=3.44.0`; the machine has Dart 3.13.1 / Flutter 3.47.1; its `intl >=0.19.0 <0.21.0` matches the app's `intl ^0.20.2`). HTML → editor: `flutter_quill_delta_from_html` (already a dependency of `flutter_quill`, added as a direct dependency because the app imports it). Editor → HTML: `vsc_quill_delta_to_html` (1.0.5). The HTML sent is **only** what the converter produces from the editor document, so no raw user HTML is sent. Toolbar limited to Bold, Italic, Underline, Heading 2. `FlutterQuillLocalizations.delegate` is added **locally** with `Localizations.override` around the editor — the app-wide `localizationsDelegates` in `lib/trydos_application.dart` is not changed. |
| OQ-6a | `GET api/v1/languages` on `ServerName.dashBoard` (the same core `MARKET_URL` backend as every `/shop/*` call; no new `ServerName`). Parsed tolerantly as in the guide §9.8: list from `data.languages`, `languages`, `data` or the root; `code` from `code`/`language_code`/`iso`/`slug` (lower-case); label from `native_name`/`name`/`title`/`label`/code; duplicates removed; empty or unreadable → the four built-in languages. |

## Recorded deviation from the spec (owner decision, 2026-10-04)

The shared error path keeps only the top-level `message` of a 422 answer
(`lib/core/api/handling_exception.dart:85-119`); `Failure` carries `message` and
`statusCode` only (`lib/core/error/failures.dart:8-11`). The `detailed_error`
list never reaches a feature. Carrying it would change `lib/core/api/**`
(protected, used by every call in the app). **Owner decision: show `message`
only and record the gap.**

- **AC-35** — the red "Status could not be changed:" box lists the backend
  `message` (the first error; guide §3.4), not every `detailed_error` entry.
  The three known refusal reasons are each a single message, so the common
  cases show the right text. **Partly met — accepted.**
- **AC-36** — a failed save shows the backend `message`, or the fixed fallback
  text; it cannot join several messages with " • ". **Partly met — accepted.**
- Note: the shared `LoggerInterceptor` already shows a toast with `message` on
  every 400 / 422 (`lib/core/api/log_interceptor.dart:126-135`). The new pages
  do **not** add a second toast with the same text; they show the message
  inline (and the AC-35 toast, whose text is different).
- A follow-up ticket can carry `detailed_error` through the core; it is out of
  scope here.

## Steps

1. **Dependencies.** Add `flutter_quill`, `flutter_quill_delta_from_html` and
   `vsc_quill_delta_to_html` to `pubspec.yaml` with `flutter pub add`; commit the
   updated `pubspec.lock`. If resolution fails, **stop and block** — do not pin
   around a conflict without a plan revision.
2. **Endpoints** (`dashBoard_url_routes.dart`, additive, Locations shape):
   `shopBoutiqueLookupsEP` (`boutiques/lookups`), `shopBoutiquesEP`
   (`boutiques`, `POST` create; the existing `getBoutiques` stays for the list),
   `shopBoutiqueEditEP(int id)`, `shopBoutiqueUpdateEP(int id)`,
   `shopBoutiqueChangeStatusEP(int id)`, and `languagesEP` =
   `api/v1/languages` (not shop-scoped).
3. **Models** (new file `boutique_edit_model.dart`): edit answer (`boutique` with
   `id`, `name`, `icon`, `status`, `availability`, `restricted_countries_iso`,
   `related_product_ids`, `translations[]` with `id`, `language_code`, `name`,
   `description`, `bio`, `icon`, `banners[]` with `id`, `banner`, `sequence`);
   lookups (`countries[] {iso, name}`, `availabilities[] {value, label}`, read
   from `data.lookups ?? data`); create answer (id from `data.boutique_id`, then
   `data.boutique.id`, then `data.id`); change-status answer (`data.status`);
   update answer (message only); language list (Step 2 parsing rules). All
   hand-written `fromJson` like the Locations models — no `json_serializable`,
   so no new `*.g.dart`. The list model `get_seller_boutiques_model.dart` is not
   changed.
4. **Data source** (`dashBoard_remote_data_source_model.dart`): six methods
   mirroring Locations (`:603-716`). Reads (`GetClient`): lookups, edit,
   languages — they rely on `BaseApi`'s `X-Seller-ID` from prefs. Writes
   (`PostClient`): create, update, change-status, each with
   `extraHeaders: _sellerHeader(sellerId)` (existing helper `:855-860`).
5. **Repository** (interface + impl): six methods, same `Either<Failure, T>`
   wrapping as the Locations methods.
6. **Use cases** (six new files, `@injectable`, one small `Params` each):
   `GetBoutiqueLookupsUseCase`, `CreateBoutiqueUseCase`,
   `GetBoutiqueForEditUseCase`, `UpdateBoutiqueUseCase`,
   `ChangeBoutiqueStatusUseCase`, `GetLanguagesUseCase`. Write params carry
   `sellerId`.
7. **Pure form logic** (new file `boutique_form.dart`, no Flutter imports):
   - `BoutiqueForm` / `TranslationForm` / `BannerItem` value types, as guide §6.1.
   - `buildFormFromEdit(edit, languages)` — guide §8.1: translations matched by
     lower-case `language_code`; missing language → empty entry with no id;
     banners sorted by `sequence`; every image value reduced to its bare file
     name, full URL kept only for preview; availability not 1/2/3 → 3 (AC-19).
   - `emptyForm(languages)` for create: availability 3, no countries (AC-14).
   - `buildPayload(form, languages, mode)` — guide §8.2: global values from
     `en`, else the first language; per-language key **`boutique_custom_data`
     for create, `custom_data` for update**; `id` only when present on
     translations and banners; banner `sequence` = position + 1; full banner
     list per language; `product_resources` = loaded ids, `[]` on create; never
     a `status` (AC-32, AC-34).
   - `validate(form)` → map of `translations.<code>.<field>` → message key,
     every language, with an empty editor counted as empty (AC-30).
   - `checkBannerFile(bytesLength, mime, width?, height?)` → `blocked` /
     `warn` / `ok` per guide §6.4 (AC-24); icon uses the same type and size
     rule without the ratio warning.
   - `bareFileName(value)` — same rule as `DashboardBloc._bareFileName`
     (`dashBoard_bloc.dart:1181-1188`); a copy, because that one is private to
     another bloc.
   - `copyField(form, from, to, field)` — banners copied **without** ids
     (AC-21, AC-22).
8. **`BoutiqueEditorBloc`** (new files `boutique_editor_bloc.dart`,
   `boutique_editor_event.dart`, `boutique_editor_state.dart`; `@injectable`
   factory). Built with the six use cases plus `UploadFileMediaServerUseCase`.
   - Opened with `sellerId` captured from prefs and the permission flags.
   - Events: `Load(create | edit id)`, `EnterEdit`, `Cancel`, `ChangeTab`,
     field edits, `ToggleStatus`, `CopyField`, `PickIcon`, `AddBanners(files)`,
     `AnswerBannerWarning(ignore|cancel)`, `MoveBanner`, `RemoveBanner`, `Save`.
   - Load: languages (fallback on failure) then lookups (create) or edit (edit).
     A load answer is dropped if prefs' shop id no longer equals the captured
     one (AC-3). 403 → `accessDenied`; 404 → `notFound`; else `error` with Retry
     (AC-4, AC-10, AC-20).
   - Keeps `form` and `saved` copies; `Cancel` copies `saved` back (AC-18).
   - Upload queue: one file at a time; a `warn` result pauses the queue until
     `AnswerBannerWarning` (AC-23, AC-24); success stores the bare file name and
     keeps the local file for preview (AC-27).
   - Save: empty shop id → error, no request (AC-2). `validate` → first tab with
     an error + highlight + toast (AC-31). Create → id → `replaceWith(id)`; no
     id → `popToList` (AC-32, AC-33). Update → if status moved, change-status
     after success; refusal restores old status, shows the box and the AC-35
     toast; success sets the pill from `data.status` (AC-34, AC-35). Failure
     keeps input and edit mode (AC-36).
   - `Save` uses `droppable()`; loads use `restartable()` (AC-38).
   - A `didChange` flag the page returns on pop, so the list can reload (AC-37).
   - `devLog` lines: action, shop id, boutique id, result, HTTP code, and the
     backend message on refusal only; no form content, file names, tokens or
     tickets (AC-40).
9. **`DashboardBloc` — list only:** add `ClearBoutiquesEvent` (emits
   `boutiques: const []` and an empty `Meta`) and put `restartable()` on
   `GetBoutiquesEvent`, so an old shop's list is never shown while a new load
   runs and a late answer from an earlier load is discarded (AC-3). No change to
   `dashBoard_state.dart`: `copyWith` already accepts both values.
10. **Permissions** (`dashboard_permission_checker.dart`): widen
    `canSeeBoutiques()` to any of the six boutique strings or `SUPER_ADMIN`
    (AC-5); add `canReadBoutiques()`, `canCreateBoutique()`,
    `canUpdateBoutique()`, `canChangeBoutiqueStatus()` (AC-6..AC-9). The old
    `dashboard_tab_bar.dart` calls `canSeeBoutiques()` too and follows the same
    rule — no edit to that file.
11. **List wiring** (`dashboard_page.dart` and `boutiques_grid_widget.dart`):
    - `_loadDataFor(1)`: dispatch `ClearBoutiquesEvent` then `GetBoutiquesEvent`,
      and only when `canReadBoutiques()`; a create-only user sees the empty
      state with Add (AC-5, AC-6).
    - `BoutiquesGridWidget`: new header row "Boutiques (count)" with
      **+ Add Boutique** shown only when `canCreate` (it accepts
      `onAddBoutique` today but never draws it); `BoutiqueCard` gets an
      `onTap` that is `null` without `canUpdate` (AC-6, AC-7).
    - `_buildBoutiquesTab()`: Add and empty-state action open the New Boutique
      page; card tap opens the boutique page; when the page returns
      `didChange == true`, dispatch `GetBoutiquesEvent(page: 1)` (AC-37).
12. **Pages and widgets** (new files under
    `lib/features/dashBoard/presentation/pages/boutique/`):
    `boutique_editor_page.dart` (one page, `create` / `edit` mode; header card,
    sticky bottom bar, access-denied / not-found / error states),
    `widgets/boutique_availability_section.dart`,
    `widgets/boutique_translations_section.dart` (pill tabs, five fields, copy
    menus), `widgets/boutique_banner_grid.dart` (16:9 tiles, always LTR, move /
    delete, dashed Add tile), `widgets/boutique_countries_section.dart` (chips
    with backend names, AC-29), `widgets/boutique_rich_text_field.dart`
    (Quill editor + 4-button toolbar + local localizations override, AC-25,
    AC-26). Visual style from `addBoiutic.html` (white cards radius 15, shadow
    `0 3px 10px rgba(0,0,0,.1)`, `#5d5d5d` primary button, `#388CFF` upload
    button, `#f8f8f8` inputs). Image width / height read with
    `dart:ui.decodeImageFromList`; files picked with `FilePicker`
    (`FileType.image`, `allowMultiple` for banners) as the dashboard already
    does.
13. **Strings:** add every new string to `ar-SY`, `en-US`, `ku-IQ`, `tr-TR`
    (AC-39), reusing `boutiques`, `add_boutique`, `no_boutiques_found`.
14. **Regenerate:** `sh gen.sh` (DI for six use cases and the new bloc), then
    `sh keys.sh`. Review the generated diffs: only the new registrations and
    the new keys may appear. `gen.sh` touches `**/*.g.dart` repo-wide, so any
    other regenerated `.g.dart` in the diff is reverted or explained.
15. **Validate** (see Validation strategy) and run the manual device script.

**Implement precondition (spec C-2):** before Step 2, the backend owner's
confirmation of the create and lookups shapes is recorded in `implement.md`,
or `implement` blocks.

**Unrelated working-tree changes** (`home_bloc.dart`,
`product_collection_in_cart_page1.dart`, three story files) are not part of
this ticket and are not touched or staged.

## Files to change

**Protected runtime paths** (CLAUDE.md → Project profile), changed only inside
this approved plan:

- `lib/common/constant/configuration/dashBoard_url_routes.dart` — **protected**
  (`*_url_routes.dart`). Additive: five boutique endpoints + `languagesEP`
  (Step 2).
- `lib/features/dashBoard/presentation/pages/boutique/boutique_editor_state.dart`
  — **new**, matches the protected `**/*_state.dart` pattern. The bloc is a
  plain `Bloc`, not hydrated; nothing is stored, nothing to migrate (Step 8).
- `lib/core/di/di_container.config.dart` — **protected, generated**
  (`lib/core/di/**`). Regenerated by `sh gen.sh`; never hand-edited. Adds six
  factory use cases and one factory bloc — **no new app-wide registration and no
  `ServiceProvider` change** (Step 14).
- `assets/languages/ar-SY.json`, `en-US.json`, `ku-IQ.json`, `tr-TR.json` —
  **protected**. New keys in all four (Step 13).
- `lib/generated/locale_keys.g.dart` — **protected, generated**. Regenerated by
  `sh keys.sh` (Step 14).

**Not protected:**

- `pubspec.yaml`, `pubspec.lock` — three new dependencies (Step 1).
- `lib/features/dashBoard/data/models/boutique_edit_model.dart` — new (Step 3).
- `lib/features/dashBoard/data/data_source/dashBoard_remote_data_source_model.dart`
  — six methods (Step 4).
- `lib/features/dashBoard/domain/repositories/dashBoard_repository.dart` and
  `lib/features/dashBoard/data/repositories/dashBoard_repository_impl.dart` —
  six methods (Step 5).
- `lib/features/dashBoard/domain/useCase/get_boutique_lookups_usecase.dart`,
  `create_boutique_usecase.dart`, `get_boutique_for_edit_usecase.dart`,
  `update_boutique_usecase.dart`, `change_boutique_status_usecase.dart`,
  `get_languages_usecase.dart` — new (Step 6).
- `lib/features/dashBoard/presentation/pages/boutique/boutique_form.dart` — new,
  pure logic (Step 7).
- `lib/features/dashBoard/presentation/pages/boutique/boutique_editor_bloc.dart`,
  `boutique_editor_event.dart` — new (Step 8).
- `lib/features/dashBoard/presentation/bloc/dashBoard_bloc.dart` and
  `dashBoard_event.dart` — `ClearBoutiquesEvent` + handler, `restartable()` on
  `GetBoutiquesEvent` (Step 9).
- `lib/features/dashBoard/presentation/widgets/dashboard_permission_checker.dart`
  — Step 10.
- `lib/features/dashBoard/presentation/widgets/boutiques_grid_widget.dart` —
  header with Add, card `onTap` (Step 11).
- `lib/features/dashBoard/presentation/pages/dashboard_page.dart` —
  `_loadDataFor` and `_buildBoutiquesTab` only (Step 11).
- `lib/features/dashBoard/presentation/pages/boutique/boutique_editor_page.dart`
  and `lib/features/dashBoard/presentation/pages/boutique/widgets/boutique_availability_section.dart`,
  `boutique_translations_section.dart`, `boutique_banner_grid.dart`,
  `boutique_countries_section.dart`, `boutique_rich_text_field.dart` — new
  (Step 12).

**Explicitly not changed:** anything in `lib/core/api/**` (all writes are
`POST`, `post.dart` already honours `extraHeaders`; 422 handling kept as is —
see the recorded deviation), `lib/main.dart`, `lib/trydos_application.dart`,
`lib/service/service_provider.dart`, `dashBoard_state.dart`,
`get_seller_boutiques_model.dart`, `upload_file_media_server_usecase.dart`.

## Integration surface

- **Components / shared config touched:** the app-wide `DashboardBloc` (one new
  event, a transformer on the list load); `DashboardPermissionChecker` (shared by
  every dashboard tab and the old `dashboard_tab_bar.dart`);
  `DashBoardEndPoints`; the generated DI container; the four locale bundles and
  generated keys; `pubspec.yaml` / `pubspec.lock` (new packages for the whole
  app); the media server upload ticket flow (new folders
  `boutiques/boutiques/icon` and `boutiques/boutiques`).
- **Who else depends on them:** every dashboard tab reads `DashboardBloc` state
  and the permission checker; Products, Orders, Locations, Shop Info, Gallery,
  Comments and Stories share the dashboard data source and repository; stories,
  chat, profile photo, product returns and Shop Info share
  `UploadFileMediaServerUseCase` (reused, not changed); every screen depends on
  DI resolving.
- **Overlapping flows:** the Boutiques list (`_buildBoutiquesTab`) shares
  `getBoutiquesStatus` / `boutiques` with the tab card count on the dashboard
  home (`state.boutiquesMeta?.total`, `dashboard_page.dart:1629`) — clearing the
  list resets that count to 0 until the reload lands. The website edits the
  same boutiques through the same endpoints, so the payload must match its
  shape exactly (FR-13).
- **Ordering / lockstep dependencies:** backend-owner confirmation of create +
  lookups (spec C-2) before Step 2; `flutter pub add` before any editor code;
  endpoints → models → data source → repository → use cases → bloc → pages;
  language keys added before `sh keys.sh`; use cases and bloc annotated before
  `sh gen.sh`; both regenerations before `flutter analyze`.
- **What breaks if this is wrong:**
  - Wrong per-language key on create → the backend silently drops all
    translations; the boutique has no content on the web.
  - A banner sent without its id, or left out → banners duplicated or deleted
    for that language on the website too.
  - A folder path in a file name → broken images (doubled folder) on every
    surface that shows the boutique.
  - Widening `canSeeBoutiques()` wrongly → the tab shows for users with no
    boutique permission, or hides for users who have one.
  - A missed DI regeneration → `GetIt` throws when the boutique page opens.
  - A `flutter_quill` dependency conflict → the whole app fails to build.
  - The new list clear without `restartable()` → a late answer for the previous
    shop could repaint its boutiques (AC-3).

## Tests

No automated test is declared. **Owner decision OQ-5 (2026-10-04):**
`.claude/project-config.yaml` has no test-runner check ("No test-runner check by
decision"), so a declared test would have no profile to run it at `/verify`
(PL-13 / VF-11 — an ERROR). The pure functions in Step 7 are written so a later
ticket can cover them without refactoring. Search for existing coverage: no
file under `test/` covers `lib/features/dashBoard/**` (searched `test/` with
`grep -ril "dashboard\|boutique" test` — matches are unrelated home / API
tests).

| AC | Existing coverage found | Disposition | Test file | Test case / name |
|----|-------------------------|-------------|-----------|------------------|
| AC-1 | none — searched `test/` | none — OQ-5: no test-runner profile; proven by code review of the data source + manual run step M-12 | — | — |
| AC-2 | none — searched `test/` | none — OQ-5; code review of the bloc save guard | — | — |
| AC-3 | none — searched `test/` | none — OQ-5; manual run M-11 | — | — |
| AC-4 | none — searched `test/` | none — OQ-5; manual run M-10 | — | — |
| AC-5 | none — searched `test/` | none — OQ-5; manual run M-9 | — | — |
| AC-6 | none — searched `test/` | none — OQ-5; manual run M-9 | — | — |
| AC-7 | none — searched `test/` | none — OQ-5; manual run M-9 | — | — |
| AC-8 | none — searched `test/` | none — OQ-5; manual run M-9 | — | — |
| AC-9 | none — searched `test/` | none — OQ-5; manual run M-1, M-9 | — | — |
| AC-10 | none — searched `test/` | none — OQ-5; manual run M-10 | — | — |
| AC-11 | none — searched `test/` | none — OQ-5; manual run M-1 | — | — |
| AC-12 | none — searched `test/` | none — OQ-5; manual run M-13 | — | — |
| AC-13 | none — searched `test/` | none — OQ-5; manual run M-1 | — | — |
| AC-14 | none — searched `test/` | none — OQ-5; manual run M-1 | — | — |
| AC-15 | none — searched `test/` | none — OQ-5; manual run M-2 | — | — |
| AC-16 | none — searched `test/` | none — OQ-5; manual run M-2 | — | — |
| AC-17 | none — searched `test/` | none — OQ-5; manual run M-2 | — | — |
| AC-18 | none — searched `test/` | none — OQ-5; manual run M-3 | — | — |
| AC-19 | none — searched `test/` | none — OQ-5; manual run M-2 | — | — |
| AC-20 | none — searched `test/` | none — OQ-5; manual run M-13 | — | — |
| AC-21 | none — searched `test/` | none — OQ-5; manual run M-5 | — | — |
| AC-22 | none — searched `test/` | none — OQ-5; manual run M-5 (check on the website) | — | — |
| AC-23 | none — searched `test/` | none — OQ-5; manual run M-6 | — | — |
| AC-24 | none — searched `test/` | none — OQ-5; manual run M-6 | — | — |
| AC-25 | none — searched `test/` | none — OQ-5; manual run M-7 | — | — |
| AC-26 | none — searched `test/` | none — OQ-5; manual run M-7 | — | — |
| AC-27 | none — searched `test/` | none — OQ-5; manual run M-4 (check image on the website) | — | — |
| AC-28 | none — searched `test/` | none — OQ-5; manual run M-4 | — | — |
| AC-29 | none — searched `test/` | none — OQ-5; manual run M-1 | — | — |
| AC-30 | none — searched `test/` | none — OQ-5; manual run M-8 | — | — |
| AC-31 | none — searched `test/` | none — OQ-5; manual run M-8 | — | — |
| AC-32 | none — searched `test/` | none — OQ-5; manual run M-1 + request log check | — | — |
| AC-33 | none — searched `test/` | none — OQ-5; code review only (cannot be forced on a real backend) | — | — |
| AC-34 | none — searched `test/` | none — OQ-5; manual run M-4 + request log check | — | — |
| AC-35 | none — searched `test/` | none — OQ-5; manual run M-14 (partly met — recorded deviation) | — | — |
| AC-36 | none — searched `test/` | none — OQ-5; manual run M-15 (partly met — recorded deviation) | — | — |
| AC-37 | none — searched `test/` | none — OQ-5; manual run M-1, M-4 | — | — |
| AC-38 | none — searched `test/` | none — OQ-5; manual run M-4 | — | — |
| AC-39 | none — searched `test/` | none — OQ-5; check `locale-bundles-in-sync` + manual run M-16 | — | — |
| AC-40 | none — searched `test/` | none — OQ-5; code review of every `devLog` call | — | — |

## Validation strategy

- **Validation profile: `codegen-change`** (`build-runner-clean` +
  `flutter-analyze`) — the change adds `@injectable` use cases and a bloc.
- **Extra checks** from `.claude/project-config.yaml`, run at `/verify` because
  the locale bundles change: `locale-bundles-in-sync` and `locale-keys-clean`
  (together with analyze they form the `localization-change` profile).
- `flutter pub get` must succeed with the new dependencies.
- **Manual device run** (debug build, a test shop with `SUPER_ADMIN` and a
  second account with limited permissions), results recorded in `verify.md`:
  - **M-1** Create a boutique in all four languages with one banner each and
    one country; it opens Inactive; back on the list it appears (page 1).
  - **M-2** Open it: locked view mode, header shows icon, name, pill, ID.
  - **M-3** Edit, change fields in two languages, Cancel → all restored.
  - **M-4** Edit: reorder two banners, add one, delete one, change bio, Save;
    double-tap Save sends one request; check on the website: same order, deleted
    banner gone, images display (no doubled folder).
  - **M-5** Copy banners from English to Turkish, Save; English banners
    unchanged on the website.
  - **M-6** Add three banners at once, one 800×800: the queue stops at the
    warning; Cancel skips it; a 12 MB file and a PDF are blocked.
  - **M-7** Description: bold + heading, Save, check on the website; open a
    website-formatted description on mobile, Save unchanged, formatting kept.
  - **M-8** Leave Kurdish bio empty, Save: jumps to Kurdish tab, field marked,
    toast, no request in the log.
  - **M-9** Limited account: READ only (no Add, cards not tappable);
    CREATE only (tab visible, Add shown); UPDATE without CHANGE_STATUS (no
    status button).
  - **M-10** Force a 403 (remove UPDATE after the list loaded) and a 404
    (another shop's id via a debug route): correct screens, no form.
  - **M-11** Open shop A's boutiques, switch to shop B: no A boutique flashes.
  - **M-12** Request log: every boutique write carries `X-Seller-ID` of the
    open shop.
  - **M-13** Languages call failing (airplane toggle during load / debug
    override): four fallback tabs; another load error shows Retry.
  - **M-14** Set active a boutique with no active products: edits saved, pill
    back to Inactive, red box with the backend message, AC-35 toast.
  - **M-15** Save a duplicate name: backend message shown, edit mode kept.
  - **M-16** Arabic and Kurdish: RTL layout correct, banner row LTR, no
    untranslated new text.

## Rollback

- Revert the implementation commit(s). Then `flutter pub get`, `sh gen.sh` and
  `sh keys.sh` so the generated DI and keys match the reverted sources.
- Nothing is stored on the device (no hydrated state, no prefs key), so no
  migration or cleanup is needed.
- Boutiques already created or edited from mobile stay on the backend; they use
  the same shape as the website, so the website keeps managing them.

## Out of scope

- Carrying `detailed_error` through `lib/core/api/**` (recorded deviation;
  follow-up ticket).
- Delete, product attaching, `position` / `request_status`.
- Translating country names.
- Any other list change: paging, card layout, stripping HTML from card text.
- Changing the app-wide localization delegates, `main.dart`, or
  `ServiceProvider`.
- Automated tests (OQ-5).
- Website or backend changes.

## Plan ↔ requirement / AC traceability

| Requirement | ACs | Steps |
|-------------|-----|-------|
| FR-1 Tenant safety | AC-1..AC-4 | 4, 8, 9, 11 |
| FR-2 Permissions | AC-6..AC-10 | 8, 10, 11, 12 |
| FR-3 Tab access | AC-5 | 10, 11 |
| FR-4 Create | AC-13, AC-14, AC-32, AC-33 | 2-8, 12 |
| FR-5 View and edit | AC-15..AC-19, AC-34 | 7, 8, 12 |
| FR-6 Status | AC-9, AC-35 | 8, 12 |
| FR-7 Per-language content | AC-11, AC-12, AC-21, AC-22 | 7, 8, 12 |
| FR-8 Rich description | AC-25, AC-26 | 1, 12 |
| FR-9 Images | AC-23, AC-24, AC-27, AC-28 | 7, 8, 12 |
| FR-10 Availability and countries | AC-13, AC-19, AC-29 | 7, 12 |
| FR-11 Validation and errors | AC-20, AC-30, AC-31, AC-36 | 7, 8, 12 |
| FR-12 List stays current | AC-37 | 8, 9, 11 |
| FR-13 Same payload as website | AC-22, AC-26, AC-27, AC-32, AC-34 | 7 |
| NFR Responsiveness | AC-38 | 8 |
| NFR Localization | AC-39 | 12, 13, 14 |
| NFR Privacy in logs | AC-40 | 8 |
