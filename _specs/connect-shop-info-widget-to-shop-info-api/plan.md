---
ticket: connect-shop-info-widget-to-shop-info-api
stage: plan
mode: standard          # single workflow form — no other modes (ADR-009)
status: complete        # not_started | in_progress | blocked | complete
owner: developer
updated: 2026-08-24
revision: 2             # revision after review recorded CHANGES_REQUESTED (PL-7)
links:
  clickup: "https://app.clickup.com/t/z8n6b5xchm"
  github:
---

# Plan — connect-shop-info-widget-to-shop-info-api

> Decide the approach before changing code. Plan only — no implementation here.

> **Revision 2 (PL-7).** The review gate on 2026-08-24 recorded
> `CHANGES_REQUESTED` with a 12-item brief. Every item is addressed below and
> listed with its resolution in *Follow-ups from review*. Three of them needed new
> acceptance criteria, so `spec.md` was amended first (AC-28, AC-29, AC-30 added;
> AC-9 and AC-27 amended) — see `spec.md > Amendments`.

## Approach

Add one more vertical slice to the dashboard feature, shaped like the gallery
slice: endpoint constant → data source → repository → two use cases → bloc
events/state → widget. `ShopInfoWidget` stops holding its own data and reads
`DashboardBloc`.

Two things revision 1 got wrong and this revision fixes:

- **The permission list does not live in the bloc.** It is a constructor argument
  on `DashboardContentPage` (`dashboard_page.dart:1862`), and `case 7` builds
  `const ShopInfoWidget()` with no arguments (`:1921`). The widget therefore takes
  `permissions` as a constructor argument and `:1921` **is** edited to pass
  `widget.permissions` down. Revision 1 claimed that line was untouched, which
  made AC-6 and AC-9 impossible.
- **`DashBoardState.copyWith` cannot set a field back to `null`** — all 48 entries
  use `x ?? this.x`. Clearing is therefore expressed as *status back to `init`
  plus an empty model*, never as a null assignment, and **never** by emitting a
  fresh `DashBoardState()` (which would discard every other tab's cached data).

The logo and banner reuse the already-injected `UploadFileMediaServerUseCase`
(`dashBoard_bloc.dart:93`), called exactly as the stories flow calls it (`:841`),
with `folder: 'seller'`.

## Steps

1. Add **one** endpoint constant `shopInfoEP = 'info'.shopScope()` to the
   dashboard URL routes, used by both the GET and the PUT.
2. Add a tolerant shop-info model that reads the envelope as `data ?? root` and
   keeps: `success` and `message` (needed because `handlingExceptionRequest`
   returns `Right` for an HTTP 200 carrying `success: false`), the five profile
   fields, `currency` (`code`, `name`), and `is_new_products_approval` with
   "missing or null means not gated". It also exposes an `isEmpty`/empty
   constructor used as the cleared value in step 7.
3. Add `getShopInfo()` and `updateShopInfo(Map<String, dynamic>)` to the dashboard
   remote data source — `GetClient` and `PutClient` on `ServerName.dashBoard`,
   both on `shopInfoEP`. `updateShopInfo` returns `ReadOnlyMessageFromApiModel`,
   as the other dashboard writes do.
4. Declare both on the repository interface and implement them wrapped in
   `handlingExceptionRequest`.
5. Add two `@injectable` use cases following `GetGalleryImagesUseCase`;
   `UpdateShopInfoParams` carries the five fields.
6. Add `READ_SHOP_INFO` and `UPDATE_SHOP_INFO` to the dashboard permission enum,
   and add `canReadShopInfo()` / `canUpdateShopInfo()` to
   `DashboardPermissionChecker` — purely additive, no existing tab changes, and
   it keeps the permission logic in the class that documents itself as the single
   place for it.
7. Add bloc events, state fields, statuses, `copyWith` entries **and `props`
   entries** (a field missing from `props` makes `Equatable` treat the states as
   equal and the screen never rebuilds — silent, no compile error). Handlers:
   - **Load** — decide from the permission list: known-denied → emit a
     `permissionDenied` status and send nothing; unknown or granted → send.
   - **Clear** — status back to `init` plus the empty model from step 2. Never a
     null assignment, never a fresh `DashBoardState()`.
   - **Upload** — `uploadFileMediaServerUseCase(UploadFileMediaServerParams(file:
     …, folder: 'seller', isStory: false, …))`, then reduce the returned
     `subPath` to the part after the last `/`.
   - **Save** — capture the shop id at load; re-read `getXSellerId` immediately
     before dispatching and abandon the save on a mismatch (AC-29); refuse when no
     successful load has completed for the current shop (AC-28); emit the outcome
     and surface the message through the bloc's existing `showMessage(...)`
     convention (`dashBoard_bloc.dart:833`, `:940`, `:989`) — the widget does not
     raise its own toast, so one outcome cannot produce two.
   - **Logging** — record endpoint, status, `success` and shop id. Never a token,
     a ticket, the api key, or any request body value (AC-27 as amended).
8. Give `ShopInfoWidget` a `required List<String> permissions` argument and pass
   `widget.permissions` at `case 7` (`dashboard_page.dart:1921`). Rewrite
   `_ShopInfoWidgetState`:
   - `initState` — compare the selected shop with the held profile's shop once
     and dispatch load or clear+load. Never in `build`.
   - Prefill the three controllers from a **`BlocListener`** on the load-status
     transition, never inside a `BlocBuilder.builder` — writing
     `TextEditingController.text` on every emit of the shared state would reset
     the text and the cursor while the member is typing.
   - `buildWhen` limited to the new shop-info statuses and fields, matching the
     other tabs (`:1934`, `:1991`, `:2531`).
   - Pick with `file_picker` (`FileType.image`, single). **Refuse a file above the
     size cap before any upload request** (AC-30) with a localized message.
   - Preview the picked **local file** until save; use the remote URL only for the
     profile loaded from the server, so the app never re-downloads bytes it just
     uploaded.
   - Build display URLs with the existing `mediaDisplayUrl(value, legacyFolder:
     'seller')` from `lib/core/utils/media_display_url.dart` — it already handles
     absolute URL / sub-path / bare file name and uses `startsWith('https://')`
     rather than a loose `contains('http')` (AC-4).
   - Gate the controls: read via `canReadShopInfo()`, write via
     `canUpdateShopInfo()` **failing closed on an unknown permission list**
     (AC-9 as amended).
9. Add translation keys for every visible string to all four language bundles —
   the same key set in each.
10. Regenerate: `sh gen.sh` (DI + models), `sh keys.sh` (locale keys). Never
    hand-edit either generated file.
11. Run the validation profile and the extra locale checks below, then the manual
    device run that OQ-8 settled as the evidence for the acceptance criteria.

## The image size cap (AC-30)

Stated here because the repository constrains the options: **`image_picker` is not
a dependency** (only `file_picker` is), and `flutter_image_compress` is commented
out in `pubspec.yaml:171`. There is therefore no pick-time `maxWidth` /
`imageQuality` lever and no resize path without adding a dependency, which this
ticket does not do.

The cap is consequently a **refusal, not a resize**: read `PlatformFile.size` after
picking and refuse anything above **5 MB** with a localized message, before the
ticket is minted and before any byte is uploaded. This is a deliberate, stated
limitation — a member with a large photo is told to pick a smaller one rather than
having it silently shrunk. Adding a compression dependency is a separate ticket.

## Files to change

- `lib/common/constant/configuration/dashBoard_url_routes.dart` — **PROTECTED
  RUNTIME PATH.** Adds **one** constant, `shopInfoEP`. Additive; nothing renamed
  or re-pointed. (Step 1)
- `lib/features/dashBoard/data/models/GetShopInfoModel.dart` — **new file.**
  (Step 2)
- `lib/features/dashBoard/data/data_source/dashBoard_remote_data_source_model.dart`
  — two new methods. (Step 3)
- `lib/features/dashBoard/domain/repositories/dashBoard_repository.dart` — two
  new abstract methods. (Step 4)
- `lib/features/dashBoard/data/repositories/dashBoard_repository_impl.dart` —
  the two implementations. (Step 4)
- `lib/features/dashBoard/domain/useCase/GetShopInfoUseCase.dart` — **new file.**
  (Step 5)
- `lib/features/dashBoard/domain/useCase/UpdateShopInfoUseCase.dart` — **new
  file.** (Step 5)
- `lib/features/dashBoard/presentation/widgets/permission_enum.dart` — adds two
  values. Matched by `fromString` on the string value (`:79`–`:85`), not by
  ordinal, so appending is safe for every other tab. (Step 6)
- `lib/features/dashBoard/presentation/widgets/dashboard_permission_checker.dart`
  — adds `canReadShopInfo()` and `canUpdateShopInfo()`. Additive; no existing
  method changes, so no existing tab's visibility moves. (Step 6)
- `lib/features/dashBoard/presentation/bloc/dashBoard_event.dart` — new events.
  (Step 7)
- `lib/features/dashBoard/presentation/bloc/dashBoard_state.dart` — **matches the
  protected `**/*_state.dart` glob.** New statuses and fields, with **both**
  `copyWith` and `props` entries. **No migration path is needed and none is
  written:** `DashboardBloc extends Bloc` (`dashBoard_bloc.dart:65`), not
  `HydratedBloc`, so no stored payload exists to deserialize. The `copyWith`
  idiom is **not** changed — clearing uses status + empty model instead. (Step 7)
- `lib/features/dashBoard/presentation/bloc/dashBoard_bloc.dart` — two injected
  use cases and their handlers; reuses the already-injected
  `uploadFileMediaServerUseCase`. (Step 7)
- `lib/features/dashBoard/presentation/pages/dashboard_page.dart` — **two** edits:
  `case 7` at `:1921` now passes `permissions: widget.permissions`, and
  `_ShopInfoWidgetState` (`:3376`–`:3652`) is rewritten. The tab list at `:1684`
  is still **not** touched — OQ-2 kept tab visibility out of scope. (Step 8)
- `assets/languages/en-US.json`, `ar-SY.json`, `ku-IQ.json`, `tr-TR.json` —
  **PROTECTED RUNTIME PATH.** New keys only, identical key set in all four.
  Existing keys (`shop_name`, `shop_information`, `shop_name_is_required`) are
  reused where they fit and never edited. (Step 9)
- `lib/generated/locale_keys.g.dart` — **generated** by `sh keys.sh`. (Step 10)
- `lib/core/di/di_container.config.dart` — **generated** by `sh gen.sh`. (Step 10)

**Read but not changed:** `lib/core/utils/media_display_url.dart`,
`lib/core/domin/usecases/upload_file_media_server_usecase.dart`,
`lib/core/api/base_api.dart`.

## Integration surface

- **Components / shared config touched:**
  - `DashBoardEndPoints` — shared by every dashboard call.
  - `DashBoardPermission` enum **and** `DashboardPermissionChecker` — the checker
    drives the visibility of the Products, Boutiques, Orders, Users and Stories
    tabs.
  - `DashBoardState` / `DashboardBloc` — one app-wide bloc registered in
    `ServiceProvider` (`:30`), used by every dashboard tab.
  - `DashBoardRepository` interface + implementation.
  - `DashboardContentPage`'s `case 7` — the tab dispatch shared by all eleven
    tabs.
  - The four language bundles and generated `LocaleKeys` — read by the whole app.
  - The shared media upload use case — already used by stories, chat and Excel.
  - Generated DI — rebuilt for the whole app.
- **Who else depends on them:** every other dashboard tab depends on the bloc, the
  state, the repository interface, the permission enum and the checker. The whole
  app depends on `LocaleKeys` and DI. Stories, chat and Excel depend on the upload
  use case this ticket reuses. The permission list originates outside the
  dashboard, in the shop-selection screen (`select_shop_page.dart:312` →
  `dashboard_page.dart:1590` → `:1862`) — this ticket reads it and changes nothing
  about where it comes from.
- **Overlapping flows:** the permission list is the same `GetUserPermissionEvent`
  result the tab bar and the other tabs use — read only; when it is dispatched and
  how it is stored do not change. The upload use case is shared with stories and
  chat: called with a new `folder` value, not modified.
- **Ordering / lockstep dependencies:** the new `@injectable` use cases must exist
  before `sh gen.sh`, and the bloc cannot resolve them until it has. New locale
  keys must be in **all four** bundles before `sh keys.sh`. Both generated files
  must be regenerated in the same change as the sources that caused them. Within
  step 7, a new state field must land in the class, `copyWith` **and** `props`
  together.
- **What breaks if this is wrong:**
  - A renamed or re-pointed endpoint constant breaks other dashboard calls with a
    runtime 404 — no compile error.
  - A field in `copyWith` but missing from `props` makes the screen never rebuild
    — silent, no compile error.
  - Emitting a fresh `DashBoardState()` to clear a field wipes the cached
    products, orders, boutiques, stories and gallery, forcing every tab to
    refetch.
  - Changing `case 7`'s signature without passing `permissions` fails at compile
    time — the one failure in this list that cannot reach a user.
  - A key added to only one bundle ships an untranslated label in the other three;
    `locale-bundles-in-sync` catches it.
  - Forgetting `sh gen.sh` leaves DI unable to construct `DashboardBloc` — the app
    fails at start, not at build.
  - Sending the wrong five values to the `PUT` overwrites a real shop profile that
    buyers see. The app cannot undo it — see Rollback.

## Validation strategy

- Validation profile: `codegen-change`
- **Gap, stated rather than hidden:** a ticket may name only one profile, and none
  covers codegen *and* localization together. `codegen-change` gives
  `build-runner-clean` + `flutter-analyze`; this change also needs
  `locale-bundles-in-sync` and `locale-keys-clean` from `localization-change`.
  Both extra check-ids are run at `/verify` in addition to the profile. Their
  commands stay in `.claude/project-config.yaml > validation_checks` (VP-4) — none
  is written here. A combined profile would be a governance change and is not made
  by this ticket.
- Manual device run against the dev market server, per OQ-8: one recorded
  observation per `AC-n`. The run must cover a shop with full permissions, a
  member without the update permission, a failed permission load, a shop switch
  with the screen open, and an oversized image.
- **The run must use a test shop, not a live seller's shop** — see Rollback.
- No automated widget or bloc test is added (Out of scope, per OQ-8).

## Rollback

- One branch, `ticket/connect-shop-info-widget-to-shop-info-api`. Every edit is
  additive except the `_ShopInfoWidgetState` rewrite and the one-line `case 7`
  change. Reverting the merge restores the mock screen; no other tab changes
  behaviour, because nothing existing is re-pointed and the `copyWith` idiom is
  untouched.
- The two generated files rebuild from sources: revert, then `sh gen.sh` /
  `sh keys.sh`.
- No database, no server-side migration, no stored client state —
  `DashboardBloc` is not hydrated, so a revert leaves nothing on disk to clean up.
- **What a revert does not undo:** a shop profile already saved through the `PUT`
  stays saved. There is no undo endpoint. AC-28 and AC-29 narrow *how* a wrong
  save can happen, but they do not make one reversible.

## Deferred question answered (PL-12)

- **OQ-7 — what the existing upload path returns, and what it needs to store into
  the shop-media folder.** `uploadToMediaServer` / `UploadFileMediaServerUseCase`
  works unchanged: `folder` is normalized there and bound to the minted ticket, so
  `folder: 'seller'` needs nothing new. Its response model carries `url` (delivery
  form, `/image/upload/seller/<name>.png`), `key`, and a `subPath` getter that
  strips the `/…/upload/` prefix to leave `seller/<name>.png`. The plain file name
  AC-15 requires is the part after the last `/` of `subPath`. **No change to the
  shared upload path.** Revision 2 additionally fixes *how* it is called: the
  already-injected use case, not the free function with a new repository
  dependency.

## Follow-ups from review (PL-7)

| # | Follow-up | Resolution in this revision |
|---|-----------|------------------------------|
| 1 | Name the permission source; correct the `:1921` claim | Approach + step 8 + Files to change: `ShopInfoWidget` takes `permissions`; `:1921` is edited and listed |
| 2 | State how a field is cleared; add `props` | Step 7 "Clear": status → `init` + empty model, never null, never a fresh state object; `props` named in step 7, Files to change, and the failure list |
| 3 | Add the two missing acceptance criteria | `spec.md` amended first: **AC-28** (no save before a successful load) and **AC-29** (shop re-check before dispatch); recorded in `spec.md > Amendments` |
| 4 | Decide the image size cap | **AC-30** added; the cap and why it is a refusal rather than a resize are in *The image size cap* |
| 5 | Name the file that satisfies AC-4 | Step 8: existing `lib/core/utils/media_display_url.dart` with `legacyFolder: 'seller'`; listed under *Read but not changed* — no protected path involved |
| 6 | Resolve the FR-4 / AC-9 fail-open contradiction | `spec.md` AC-9 amended to fail **closed** on unknown for the write gate; step 8 states it |
| 7 | Reuse the injected upload use case | Approach + step 7 "Upload": `uploadFileMediaServerUseCase(UploadFileMediaServerParams(…))`, as stories does at `:841` |
| 8 | Name the success/message fields and the PUT return | Step 2 (model keeps `success` + `message`, with the `handlingExceptionRequest` reason) and step 3 (`ReadOnlyMessageFromApiModel`) |
| 9 | One place for the outcome message | Step 7 "Save": the bloc's `showMessage(...)` convention; the widget raises no toast |
| 10 | Pin prefill and shop check off `build`; state `buildWhen` | Step 8: `initState` for the shop check, `BlocListener` for prefill, `buildWhen` scoped to the new fields |
| 11 | Fold the two endpoint constants into one | Step 1: a single `shopInfoEP` |
| 12 | Exclude request body values from the log record | `spec.md` AC-27 amended; step 7 "Logging" states it |

## Plan ↔ REQ / AC traceability

| Step | Files | Satisfies |
|------|-------|-----------|
| 1 | dashboard URL routes | FR-1, FR-6 — AC-1, AC-14 |
| 2 | new shop-info model | FR-2, FR-8, FR-10 — AC-3, AC-4, AC-21, AC-24, AC-25 |
| 3, 4, 5 | data source, repository, use cases | FR-1, FR-6, FR-8 — AC-1, AC-5, AC-14, AC-20, AC-21 |
| 6 | permission enum + checker | FR-3, FR-4 — AC-6, AC-8, AC-9 |
| 7 | bloc events, state, handlers | FR-1, FR-3, FR-4, FR-5, FR-6, FR-8, FR-9, FR-10, FR-12 — AC-1, AC-5, AC-6, AC-7, AC-8, AC-10, AC-11, AC-13, AC-18, AC-20, AC-21, AC-22, AC-23, AC-24, AC-25, AC-27, AC-28, AC-29 |
| 8 | `case 7` + `_ShopInfoWidgetState` rewrite | FR-2, FR-5, FR-6, FR-7 — AC-2, AC-3, AC-4, AC-9, AC-12, AC-13, AC-15, AC-16, AC-17, AC-18, AC-19, AC-30 |
| 9 | four language bundles | FR-11 — AC-26 |
| 10 | generated DI + locale keys | supports steps 5, 6, 9 — no AC of its own |
| 11 | validation + manual run | evidence for AC-1 … AC-30 |

## Out of scope

- Hiding or reordering the Shop Info tab, and any change to the tab list at
  `:1684` (OQ-2). Adding two additive methods to `DashboardPermissionChecker` is
  **in** scope — OQ-2 ruled out changing tab *visibility*, not the checker class.
- The shop switcher and anything that writes which shop is selected — this ticket
  only reads `getXSellerId`.
- Editing currency, approval standing, boutique banners or shop locations.
- Any change to the shared upload path, to `base_api.dart`, or to how
  `X-Seller-ID` is attached.
- Changing the `copyWith` idiom of `DashBoardState`.
- Adding an image compression dependency — the cap is a refusal, not a resize.
- New automated test infrastructure (OQ-8).
- Fixing the folder-loss limit when a returned image lives outside the `seller`
  folder — recorded as a known limit in the code.
- Adding a combined codegen + localization validation profile to
  `.claude/project-config.yaml`.
