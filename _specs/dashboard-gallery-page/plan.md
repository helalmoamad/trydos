---
ticket: dashboard-gallery-page
stage: plan
mode: standard          # single workflow form — no other modes (ADR-009)
status: complete        # not_started | in_progress | complete
owner: developer
updated: 2026-08-22
links:
  clickup:
  github:
---

# Plan — dashboard-gallery-page

> Decide the approach before changing code. Plan only — no implementation here.

**Revision 6.** Written after review round 3 recorded `CHANGES_REQUESTED` over revision 5
with fourteen follow-ups (J-1..J-14), and after the owner made three scope decisions
recorded in `review.md > Open Questions` on 2026-08-22:

1. **Cut the upload queue entirely** — no concurrency, no give-up timers, no lifecycle
   re-arm, no 3-strike connection stop, no temporary-file cleanup.
2. **Drop both caps** — no 30-per-pick trim, no 100-per-run budget.
3. **A failed file does not stop the run** — mark it failed and continue.

This revision is therefore much smaller than revision 5. Most of that is **removal**: five
follow-ups are answered by the mechanism no longer existing, not by a fix.

**Accuracy note.** Revisions 3, 4 and 5 each contained a confidently stated claim that the
panel proved false. Every code fact below was checked against the repository and carries
its file and line. Where something is *not* verified, this plan says so.

## Approach

Fill the dashboard tab that already exists: write `GalleryWidget`, return it from
`case 9`, leave navigation alone. `lib/routes/**` is untouched.

The uploaded list lives in `DashBoardState` on the existing `DashboardBloc`, following the
`SellerStoriesWidget` precedent — the bloc is already handed to this page by `_openTab`
(`dashboard_page.dart:1581`) and already holds `uploadFileMediaServerUseCase`.

Uploads are **serial and plain**: one file at a time, through the existing
`UploadFileMediaServerUseCase`, relying on Dio's own timeouts
(`di_container.dart:26-28`, two minutes each). No app-level timers, no concurrency, no
cancellation, no cleanup of picked files. A file that fails is marked `failed` and the run
moves to the next one (spec E-4, E-8). There are no upload limits, so every image the user
picks is uploaded (AC-8).

Identity is checked in two places: the grid filters on values read **live from prefs at
build time**, and the run **re-checks before every file** and stops when they change. That
is what stops a run that outlives a logout from uploading into the next seller's storage.

### Answers to the questions `spec.md` deferred

- **OQ-1 — bulk versus a loop: still the loop, for AC-10.** The bulk client code **does**
  exist — `BulkUploadResponseModel` (`lib/core/data/model/bulk_upload_response.dart:13`),
  `uploadMediaServerBulk` (`common_use_repo_data_source.dart:107`), `uploadBulkImages`
  (interface line 23, implementation line 48); only a use case is missing. The loop is
  kept because **AC-10** needs per-file Retry and one bulk call succeeds or fails as a
  whole. Cutting the queue does not change this: the loop is now a plain serial `for`,
  which is simpler than the bulk plumbing would be. Accepted cost: two round trips per
  file. **This overrides intake decision D-2 on AC-10 grounds.** *Lands in:* Approach,
  Step 7.
- **OQ-2 — the shared picker: two additive parameters.** `myMultiAssetPicker`
  (`helper_functions.dart:355`) is fixed at `maxAssets: 1` and never sets `requestType`,
  which defaults to `RequestType.common` — images **and videos**. It gains
  `int maxAssets = 1` and `RequestType requestType = RequestType.common`; both defaults
  reproduce today's behaviour, so the existing callers
  (`gallery_and_camera_dialog_widget.dart:107`, `add_photo_to_profile_page.dart:276`) are
  unchanged. The gallery passes `RequestType.image` and a `maxAssets` high enough not to
  act as a cap (the caps are dropped — see J-4). The `AssetPickerConfig` at
  `helper_functions.dart:371` stops being `const`. *Lands in:* Files to change,
  Integration surface.
- **OQ-3 — where the list lives: `DashBoardState`.** Rejected alternative: a separate
  singleton store, a second global state mechanism beside the bloc this page already has.
  *Lands in:* Files to change, Steps 2-3.
- **OQ-4 — a new widget file under `presentation/widgets/`.** Precedent:
  `_buildStoriesTab()` (`dashboard_page.dart:2390`) returns `const SellerStoriesWidget()`
  from `presentation/widgets/seller_stories_widget.dart`. *Lands in:* Files to change.

### Protected runtime in scope, and why it is safe

`dashBoard_state.dart` matches `**/*_state.dart`. That rule guards **hydrated** state,
whose shape change must keep deserializing stored payloads. Not applicable:
`DashBoardState` is `@immutable class DashBoardState extends Equatable`
(`dashBoard_state.dart:50`) with no `HydratedBloc`, no `part` and no `.g.dart`;
`DashboardBloc extends Bloc` (`dashBoard_bloc.dart:62`). Nothing is persisted, so there is
no migration path to provide. The real risk on that file is a `copyWith` / `props`
mistake, handled in J-9 and by a non-optional hand check at `/verify`.

### Constraint carried over — no percentage progress

`usingSendProgressFunction` gives the caller no callback: at
`common_use_repo_data_source.dart:40-50` it routes progress into
`LocalNotificationService().uploadingNotification(...)`. AC-9 is met as a **per-file
status** — pending, uploading, done, failed — not a percentage. Both flags are `false`.
The owner should confirm at `/review` that a status satisfies AC-9.

## What the scope decision removed

These are gone from the plan. They are **not** fixed — the mechanism no longer exists, so
the finding has nothing to attach to. Listed explicitly so nobody re-adds them later
without re-reading why.

| Removed | Follow-ups it dissolves | Consequence now accepted |
|---------|------------------------|--------------------------|
| Concurrency (2 in flight) | **J-5** | A 20-file run is fully serial. AC-21 sets no time limit, but a large run on a slow link takes a long time. |
| Give-up timers (60 s + 20 s/MB) | **J-5**, **J-6** | A stalled file blocks the run until Dio's own two-minute timeout fires (`di_container.dart:26-28`). |
| Lifecycle re-arm on resume | **J-3**, **J-6** | Backgrounding is left to Dio. Nothing app-level fires a burst of timeouts on resume, because there are no app-level timers. |
| 3-strike connection stop | **J-7** | A dead network fails each file in turn at Dio's timeout. Matches the owner's decision that a failure does not stop the run. |
| Temporary-file cleanup | **J-2** | **Nothing is deleted, so nothing can delete a user's photo.** Picked copies stay in the app cache until the OS reclaims them — see Risks. |
| The 30-per-pick trim and the 100-per-run budget | **J-4**, **J-12** | Every picked image uploads, satisfying AC-8 as written. Nothing in the app brakes a user filling shared media storage — see Risks. |

## Review follow-ups addressed

| J | What review round 3 required | How this revision answers it |
|---|------------------------------|------------------------------|
| **J-1** | Replace the token-derived session value: a token rotation is not a session change. | **The derived value is dropped entirely.** Identity is the pair (`myMarketId`, `getXSellerId`) — matching the stories flow at `dashBoard_bloc.dart:772-776` — **plus a requirement that the market token is non-empty**. This is correct across a refresh, because `_onRefreshTokenEvent` rotates the token for the same seller (`auth_bloc.dart:1152`) while the ids and the non-empty condition both hold. It is also correct across a logout, because `_logoutUser()` calls `setMarketToken(null)` (`base_page.dart:979`, verified) while leaving `userMarketId` set — so the empty token is the reliable logout signal. No hashing, so nothing to name and nothing that could be logged. **Residual risk, stated not hidden:** guest re-registration writes a new token (`auth_bloc.dart:1069`) *before* `setMyMarketId` (line 1100), a window where the token is non-empty and the ids are stale. The gallery is not reachable in that window — the app has navigated away from the dashboard — so this is accepted rather than solved. The alternative the security lens offered (a JWT `sub`) was rejected: it means parsing a token in a presentation feature, and a login-epoch counter was rejected because it needs a new key in `prefs_key.dart`, a protected path. |
| **J-2** | Never delete a file the app did not create. | **Dissolved** — no deletion happens at all. Non-terminal tiles draw a placeholder only and never read a local file, so nothing tempts an implementer back toward local previews of picked files. |
| **J-3** | Own the lifecycle or drop the claim. | **Dissolved** — dropped. There are no app-level deadlines to re-arm, so no observer is needed and none is added. |
| **J-4** | Resolve the AC-8 conflict. | **Dissolved by the owner's decision** — both caps are dropped, so every image chosen is uploaded and AC-8 holds as written. No `spec.md` change is needed, which matters because `/plan` cannot write it. |
| **J-5** | Bound real network concurrency. | **Dissolved** — one request at a time, and nothing gives up early, so the number of live requests is exactly one. |
| **J-6** | Reword the resume expectation. | **Dissolved** — the `/verify` check about bulk failures after a resume is removed, because there is no app-level deadline whose behaviour it was describing. |
| **J-7** | Drop or re-base the 3-strike rule. | **Dissolved** — dropped, which also matches the owner's decision that a failed file does not stop the run (E-8). |
| **J-8** | Time the asset resolve. | **Shrunk, and stated honestly.** With no slots there is nothing to hold, so the only cost is that the run waits. On iOS `AssetEntity.file` can download an iCloud-optimised original, and that wait is **unbounded and shown as `uploading`** on that entry. Accepted; recorded in Risks. |
| **J-9** | Make the concurrency rule precise. | The add, retry and open handlers still run with bloc's default concurrent behaviour (`dashBoard_bloc.dart:119-145` registers no transformers). The rule is therefore stated exactly: the run handler **reads `state.galleryEntries`, merges by entry id, and emits in one synchronous block, with no `await` between the read and the emit** — Dart interleaves handlers only at await points. `GalleryEntry` is kept small and `Equatable`, and `copyWith` passes the **same list instance** through when the gallery did not change, so other tabs' comparisons stay cheap. |
| **J-10** | Let a retry join the running run. | The run loop is defined as **"while any `pending` entry of the current owner exists"**, so a retry that arrives mid-run is picked up by the loop already running rather than waiting behind it. The run event keeps `sequential()` (verified correct in round 3) so two runs can never overlap; a redundant run finds nothing pending and returns. A retried entry shows as `pending` meanwhile. |
| **J-11** | Define the cap when nothing is evictable. | The 60-entry cap is a **display and memory bound on terminal entries only**. Eviction removes the oldest `done` / `failed` entries of the current owner. If the list is at 60 with nothing terminal to evict, the list is simply allowed to exceed 60 — the new entries are still added and still upload (required by AC-8 now that the caps are dropped), and eviction catches up as entries settle. This is stated so the behaviour is defined rather than undefined. |
| **J-12** | Fix the budget's edges. | **Dissolved** — there is no budget. The worst-case **byte** figures move into Risks, as the review asked, since they are now unbounded by anything in the app. |
| **J-13** | Fix the step ordering and two factual details. | Steps are reordered so nothing refers forward to a step that has not been introduced. Step 6 states that the pick dispatches the run event, which is what makes AC-8's auto-start happen. `FilePicker.pickFiles` copying every chosen file into the app cache **before it returns** is recorded in Risks. `MyCachedNetworkImage` is cited with its full path, `lib/features/app/my_cached_network_image.dart`. |
| **J-14** | Correct the security wording. | The identity check is described as **narrowing** the window, not closing it: the check and the send are not atomic — at least two awaits run before the token is read (`upload_file_media_server_usecase.dart:33-39` → `common_use_repo_data_source.dart:60`) and `_logoutUser` does not await `setMarketToken(null)`. The triple is therefore **re-checked again when the upload resolves**, and on a mismatch the entry is marked `failed` and its URL is never shown. `Uri.parse` is wrapped in try/catch so a malformed base cannot throw inside the handler and kill the bloc for all ten tabs; the comparison covers **scheme, host and port**. The gallery is cleared at the **first identity mismatch the run sees**, not only on tab open. The Risks sentence is corrected: `marketToken` is in **secure storage** (`prefs_repository_impl.dart:74-81`), not SharedPreferences. |

### Spec gaps this command cannot close

`/plan` may not write `spec.md` (GU-1), and `spec.md` cannot be rewritten from
`state: spec-complete`. AC-8's conflict is now gone (J-4), but two behaviours remain
planned with no `AC-n`:

1. **The logout criterion** (round 1, F-1): after logout and a login as a different user,
   the gallery shows the empty state.
2. **The run stopping on an identity change** (J-1 / J-14): queued files are not sent into
   the next session.

Both are listed as non-optional `/verify` checks. The owner should decide at `/review`
whether to accept them untraced or carry them formally, which needs a new ticket.

## Steps

1. Add the locale keys to the four bundles, then regenerate with `sh keys.sh`. New keys:
   `gallery_drop_images_here`, `gallery_or_choose_files_folder`, `gallery_select_files`,
   `gallery_select_folder`, `gallery_no_images_found`,
   `gallery_uploaded_images_will_appear_here`, `gallery_session_only_note`. Reused:
   `gallery`, `failed`, `try_again`, `permission_denied`, `error_picking_file`.
2. Extend `DashBoardState` with **non-nullable** gallery fields:
   `List<GalleryEntry> galleryEntries` defaulting to `const []`, and
   `String galleryOwnerUserId` / `String galleryOwnerShopId` defaulting to `''`. A
   `GalleryEntry` holds a stable id, the picked source (a file path or an asset id), a
   status (`pending` / `uploading` / `done` / `failed`), the full address when done, an
   error message when failed, and the owner pair. Keep the class small and `Equatable`.
   Add `copyWith` handling that passes the **same list instance** through when the gallery
   did not change (J-9), and add the fields to `props`.
3. Add the gallery events to `dashBoard_event.dart` and their handlers to
   `dashBoard_bloc.dart`. The open handler compares the live owner pair with the stored
   one — and treats an empty market token as "no owner" — and clears the entries when they
   differ (J-1). Register the **run** event with `sequential()`: one `on<...>` line inside
   the existing constructor body (`dashBoard_bloc.dart:119-145`), plus a
   `bloc_concurrency` import (already a dependency, `pubspec.yaml:119`).
4. Add `GalleryWidget` in `presentation/widgets/`: the dashed upload box matching the
   reference image (icon, "Drop images here", "or choose files / folder", "Select Files"
   filled dark, "Select Folder" outlined blue), and the images area below.
5. Build the images area: the empty state when nothing is visible, otherwise a lazy
   `GridView.builder` of three square tiles per row, each keyed by the entry's stable id.
   `done` tiles render with `MyCachedNetworkImage`
   (`lib/features/app/my_cached_network_image.dart`) passing the **tile size as `width`
   and `height`** — `memCacheWidth` / `memCacheHeight` derive from those, not from
   `imageWidth` / `imageHeight`, which the widget ignores (lines 101-120). **Non-terminal
   tiles draw a placeholder only and never read a local file** (J-2). `buildWhen` compares
   only the gallery fields. **A tile renders only when its stamped owner pair matches the
   values read live from `PrefsRepository` during build** — never from the state fields —
   and the live pair is read **once per grid build** and passed down, not per tile. The
   temporary-list note sits with this area.
6. Wire the pick buttons. "Select Files" calls
   `FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: true)`; "Select
   Folder" calls `myMultiAssetPicker` with `RequestType.image` and a `maxAssets` high
   enough not to act as a limit, dropping any non-image asset. All picked sources are
   added as `pending` in a **single** emit, and the pick then **dispatches the run event**
   — this is what makes AC-8's auto-start happen (J-13). No `File` is resolved here.
   Messages use `showMessage(..., hasError: true)`, required for them to appear in a
   release build (`show_message.dart:31`).
7. Add the run handler — a plain serial loop, `while` any `pending` entry of the current
   owner exists (J-10):
   - **Before each file**, re-read the live owner pair and the market token and compare
     with that entry's stamp. On a mismatch, clear the gallery entries and stop the run
     (J-1, J-14).
   - Resolve the picked source to a `File` (`AssetEntity.file` for the asset path). This
     wait is unbounded on iOS (J-8) and is shown as `uploading`.
   - Upload through `UploadFileMediaServerUseCase` with `folder: 'gallery'` and
     `isStory: false`, awaiting Dio's own timeouts. **Nothing is deleted afterwards.**
   - Build the address: guard `Uri.parse` with try/catch, use `Uri.parse(base).resolve(url)`,
     and fail the entry unless the resolved **scheme, host and port** match the configured
     media server, or when `MEDIA_SERVER_URL` is null or empty (J-14).
   - **Re-check the owner pair again when the upload resolves**; on a mismatch mark the
     entry `failed` and never show its URL (J-14).
   - Mark `done` only on a usable resolved address; anything else is `failed` with its
     message, and **the loop continues to the next file** (owner's decision; E-4, E-8).
   - Entries are found **by id**; a result whose id is gone is dropped. Every read-merge-emit
     is one synchronous block with no `await` between the read and the emit (J-9), and
     every emit is guarded with `if (!emit.isDone)` — the pattern this bloc already uses at
     `dashBoard_bloc.dart:619, 645, 655`.
   - Evict the oldest **terminal** entries of the current owner beyond 60; if none are
     terminal, let the list exceed 60 (J-11).
8. Add Retry on a failed entry: disabled while that entry is `uploading`; it sets the entry
   back to `pending` by id and dispatches the run event, which the running loop absorbs
   (J-10).
9. Add the full-screen preview opened by tapping a `done` tile: it shows the thumbnail
   image first and loads the full-size one behind it — these are **different URLs**,
   because `addSuitableWidthAndHeightToImage` bakes the requested size into the URL
   (`my_cached_network_image.dart:309-348`), so the preview is a second download, not a
   cache hit. Closable back to the grid.
10. Replace `case 9` in `dashboard_page.dart` with `return const GalleryWidget();`, add the
    import, and add an `index == 9` branch to `_loadDataFor` dispatching the open event.
11. Check by hand on a device: English and Arabic (RTL); empty state; single pick; a
    20-file pick; cancel; permission refusal; a video offered to the picker; a forced
    failure with Retry, confirming **the run continues past it**; leaving during a run and
    opening Orders; a restart; **logout then login as a different seller**; **switching
    shops**; and **logging out while a run is still uploading**.

## Files to change

- `assets/languages/en-US.json` — **PROTECTED RUNTIME.** Add the seven new keys.
- `assets/languages/ar-SY.json` — **PROTECTED RUNTIME.** Same keys, Arabic.
- `assets/languages/ku-IQ.json` — **PROTECTED RUNTIME.** Same keys, Kurdish.
- `assets/languages/tr-TR.json` — **PROTECTED RUNTIME.** Same keys, Turkish.
- `lib/generated/locale_keys.g.dart` — **PROTECTED / GENERATED.** Regenerated by
  `sh keys.sh`; never hand-edited.
- `lib/features/dashBoard/presentation/bloc/dashBoard_state.dart` — **PROTECTED RUNTIME
  (`**/*_state.dart`).** Add the non-nullable gallery fields, the `GalleryEntry` class,
  `copyWith` handling and `props`. Safe on hydration grounds; the real risk is
  `copyWith` / `props`, covered by the `/verify` hand check.
- `lib/features/dashBoard/presentation/bloc/dashBoard_event.dart` — **EDIT.** Add the
  gallery events.
- `lib/features/dashBoard/presentation/bloc/dashBoard_bloc.dart` — **EDIT.** Add the
  gallery handlers and one `on<...>` registration with `sequential()` **inside the
  existing constructor body**, plus a `bloc_concurrency` import. No change to the
  constructor **signature**, the DI registration, or any existing handler.
- `lib/features/dashBoard/presentation/widgets/gallery_widget.dart` — **NEW.** The screen.
- `lib/features/dashBoard/presentation/pages/dashboard_page.dart` — **EDIT, minimal.**
  `case 9`, one import, one `_loadDataFor` branch.
- `lib/common/helper/helper_functions.dart` — **EDIT, additive.** `myMultiAssetPicker`
  gains `maxAssets` and `requestType`, both defaulting to today's behaviour; the
  `AssetPickerConfig` at line 371 stops being `const`.

**Not touched:** `lib/base_page.dart`, `lib/routes/**`, `lib/core/api/**`,
`lib/core/di/**`, `lib/core/data/**`, `lib/service/service_provider.dart`,
`lib/main.dart`, `lib/trydos_application.dart`, `lib/common/constant/configuration/prefs_key.dart`,
any `*_url_routes.dart`, any `*.g.dart` except the regenerated locale keys, `pubspec.yaml`.

## Integration surface

> Required (PL-11, ADR-012). What this change touches **beyond its own files** —
> the source of the mandatory integration question at `/review` (CG-5).
> `none — self-contained` is valid only with the reason stated.

- **Components / shared config touched:**
  1. **`DashboardBloc` and `DashBoardState`** — an app-wide `lazySingleton`
     (`di_container.config.dart:1040`) provided in `service_provider.dart:30`, shared by
     all 11 dashboard tabs. This ticket adds state fields and one event registration
     inside its constructor body.
  2. The tab switch and `_loadDataFor` in `dashboard_page.dart`.
  3. `HelperFunctions.myMultiAssetPicker` — shared picker in `lib/common/helper/`.
  4. The four language bundles and the generated `locale_keys.g.dart`.
  5. The media server (`ServerName.mediaServer`) and its ticket flow — shared with chat,
     story, profile and product-return uploads.
  6. **`MEDIA_SERVER_URL` from `.env`** — read to build and validate the address.
  7. **The login session** — `PrefsRepository.myMarketId`, `getXSellerId` and the market
     token, written by the auth flow on every login, logout and guest registration.
  8. `MyCachedNetworkImage` and the shared cache behind it (`CustomCacheManagers`,
     `maxNrOfCacheObjects: 500`, **no byte cap** — `my_cached_network_image.dart:299`).
  9. **The device photo library and the app cache directory** — read by both pickers.
     Nothing is written back and nothing is deleted.

- **Who else depends on them:**
  1. Every dashboard tab observes this one state object. `_buildOrdersTab`
     (`dashboard_page.dart:2050`) has **no** `buildWhen`, so while a run is in progress,
     opening Orders rebuilds its whole list on every gallery emit — which is why a pick
     emits once and `copyWith` reuses the same list instance when the gallery is unchanged.
  2. Tabs 0–8 and 10 render through the same switch; `_loadDataFor` already branches per
     index.
  3. `myMultiAssetPicker` is reached through `getAssetFromGallery`, called from
     `gallery_and_camera_dialog_widget.dart:107` and `add_photo_to_profile_page.dart:276`.
     Both take a single asset and both currently receive images **or videos**.
  4. Every screen reads `LocaleKeys`; `keys.sh` regenerates it from the bundles.
  5. `UploadFileMediaServerUseCase` is shared; the dashboard bloc already uses it with
     `folder: 'stories'`. **The ticket is minted at send time with the token current
     then** (`common_use_repo_data_source.dart:60`) — the fact that makes the per-file
     identity re-check necessary.
  6. `MEDIA_SERVER_URL` must exist in `.env`; the stories flow already depends on it.
  7. `_logoutUser()` (`base_page.dart:944-997`) clears the market token
     (`setMarketToken(null)`, line 979) but **not** `userMarketId`. Guest registration
     then writes a new token (`auth_bloc.dart:1069`) **before** `setMyMarketId` (line
     1100). A token **refresh** (`auth_bloc.dart:1152`, reached from
     `log_interceptor.dart:307-318`) rotates the token for the **same** seller — which is
     why identity is the id pair plus token-presence, and never the token's value.
  8. `CustomCacheManagers` evicts by object count, so the gallery costs up to **2 slots per
     image** (thumbnail plus preview) out of 500, and an unbounded number of **bytes**.
  9. Picked files are copied into the app cache by `FilePicker.pickFiles` before it
     returns; nothing in this ticket removes them.

- **Overlapping flows:**
  - The gallery and the seller-stories tab share the **same bloc and the same state
    object** and upload through the same use case. They stay apart by field and by
    `folder`, and now share the identity convention the stories flow already uses
    (`_storiesUserId` / `_storiesSellerId`, `dashBoard_bloc.dart:772-776`).
  - The gallery and the profile-photo / camera-dialog flows share `helper_functions.dart`;
    the defaults on both new parameters keep them unchanged.
  - **Logout, guest registration, token refresh and login all share the process with this
    bloc.** `DashboardBloc` is a `lazySingleton`, so its state and any running upload
    outlive a logout. This is the most important overlap in the ticket, and the one the
    identity check exists for.
  - Gallery uploads share the media server's rate and quota with chat and story uploads.
    One at a time makes the gallery the quietest of those neighbours.

- **Ordering / lockstep dependencies:**
  - The four bundles must be edited **together with the same key set**, and `sh keys.sh`
    must run **after** them and before the widget compiles.
  - `dashBoard_state.dart` must gain its fields before the handlers compile, and the
    handlers before the widget dispatches to them.
  - The read-time filter (Step 5) and the per-file identity re-check (Step 7) must **both**
    exist: the filter governs what is **drawn**, the re-check governs what is **sent**.
    Neither alone is sufficient.
  - Every new state field must be added to **`copyWith` and `props` in the same edit** —
    one without the other is a silent bug, not a compile error.
  - The `case 9` edit must come after `GalleryWidget` exists.

- **What breaks if this is wrong:**
  - **A gallery field missing from `props`** makes `Equatable` treat two different states
    as equal, so the grid silently stops updating while uploads really run.
  - A gallery field mishandled in `copyWith` can wipe or freeze another tab's data.
  - **If the run does not re-check identity per file, a run that outlives a logout uploads
    into the next seller's storage** — the read-time filter cannot prevent this, because it
    only controls what is drawn.
  - **If the filter compares against the state fields instead of live prefs, it is a
    no-op**, because those fields still hold the previous owner's values until the clear
    runs — and `_loadDataFor` fires before the route is pushed.
  - **If identity used the token's value, a routine refresh would look like a new seller**
    and would fail the run, hide finished tiles and clear the list.
  - An unguarded `Uri.parse` on a malformed base throws inside the handler and kills the
    bloc — breaking **all ten** dashboard tabs, not just the gallery.
  - An `await` between reading `state.galleryEntries` and emitting loses entries added or
    retried meanwhile.
  - Emitting after the handler returns throws `StateError` and kills the bloc.
  - Deleting a resolved picked file would delete the user's own photo — which is why this
    plan deletes nothing at all.
  - Changing a picker default instead of adding a parameter silently changes the
    profile-photo and camera-dialog flows.
  - A key added to `en-US.json` but missed elsewhere shows a raw key string to Arabic,
    Kurdish and Turkish users.
  - Passing `isStory: true` or the wrong folder drops gallery images into the story
    pipeline.

## Validation strategy

- Validation profile: `localization-change`
- The profile fits: the four bundles stay in step (`locale-bundles-in-sync`), the generated
  keys match (`locale-keys-clean`), and the package analyses clean (`flutter-analyze`).
- `codegen-change` is **not** needed: `DashBoardState` has no `part` and no `.g.dart`, and
  no `@injectable` class or DI registration is added. `hydrated-state-change` does not
  apply — this bloc is not hydrated.
- No profile can catch a `copyWith` / `props` mistake or an identity bug, so the hand
  checks below are not optional.
- Automated tests cannot cover these criteria: the repository has one test
  (`test/core/json_size_cap_test.dart`) and no widget-test setup for the dashboard. ACs are
  proven by hand at `/verify`: AC-1..AC-4 (layout against the reference image), AC-5..AC-8
  (both pickers, cancel, auto-start, and **every** picked image uploading now that the caps
  are gone), AC-9..AC-10 (per-file status, Retry), AC-11..AC-12 (grid and preview),
  AC-13..AC-15 (survives the tab, empty after restart, the note), AC-16..AC-18 (four
  languages, RTL, no overflow), AC-19 (permission refused), AC-20 (the other ten tabs still
  open), AC-21..AC-22 (a 20-file run, leaving mid-upload).
- **Extra checks with no AC behind them** — non-optional:
  - **Logout, then login as a different seller: the gallery shows the empty state.**
  - **Log out while a run is still uploading: the remaining files are not sent, and nothing
    appears in the next session's gallery.**
  - **Force a token refresh during a run (or verify by inspection): the run continues, the
    finished tiles stay visible, and the list is not cleared** (J-1 — the defect that made
    revision 5 unapprovable).
  - **Switch shops: the gallery shows that shop's own list.**
  - **After a gallery upload, each of the ten other dashboard tabs still holds its data.**
  - **Start a run, leave the gallery, open Orders: no jank.**
  - **Force one file to fail in a multi-file run: the run continues to the next file**
    (owner's decision; E-4, E-8).
  - A video offered to "Select Folder" is never uploaded.
  - **The picked files still exist on the device after a run** — nothing was deleted (J-2).
  - **One real uploaded URL is inspected to confirm it takes the `media_server` transform
    branch** of `addSuitableWidthAndHeightToImage` (needs both `upload` and `media_server`
    in the URL — `my_cached_network_image.dart:319, 333`). If it does not, tiles **and the
    preview** pull full originals and the sizing must be revisited.

## Rollback

- All work sits on `ticket/dashboard-gallery-page`, off `dev_new`. Reverting the commit,
  or not merging the PR, restores `dev_new` completely.
- Partial rollback is safe: restoring the single line
  `case 9: return Center(child: Text(LocaleKeys.gallery.tr()));` in `dashboard_page.dart`
  turns the feature off even with the new state fields and files present. The gallery
  fields are additive and default to empty, so no other tab notices them.
- Removing the two picker parameters restores the helper exactly; the `const` on
  `AssetPickerConfig` comes back with them.
- The new language keys are additive; leaving them behind breaks nothing.
- No schema change and no stored state — `DashBoardState` is never persisted.
- **Not reversible:** images already sent to the media server stay there. Rollback does not
  delete them and nothing in the app can reach them.

## Risks

- **Nothing brakes uploads any more.** With the caps dropped, no permission gate (accepted
  in an earlier round) and no app-side size limit (spec OQ-7), a single user can upload an
  unbounded amount into media storage shared with chat, stories and profile, with no delete
  path (C-2, C-3). As a figure rather than a file count: 30 phone photos of roughly 4 MB is
  about 120 MB in one pick, and nothing stops the pick being repeated. The owner accepted
  this when choosing to drop the caps; it is written here so the acceptance is on record.
- **Picked files accumulate in the app cache.** `FilePicker.pickFiles` copies every chosen
  file into the cache **before it returns**, so a 30-file pick writes about 120 MB up
  front, and this plan never deletes it. That is the deliberate price of not risking the
  user's photos (J-2). The OS reclaims cache space under pressure.
- **A stalled file blocks the run** until Dio's two-minute timeout fires, and an iOS
  iCloud fetch inside `AssetEntity.file` is unbounded and displays as `uploading` (J-8).
- **The identity check narrows a window, it does not close it.** The check and the send are
  not atomic, and `_logoutUser` does not await clearing the token. The re-check when the
  upload resolves means a slipped file is never shown, but it may already have been sent.
- **A guest-registration window exists** where the token is new and the ids are stale
  (`auth_bloc.dart:1069` before line 1100). The gallery is not reachable then, so this is
  accepted rather than solved.
- **This ticket fixes only the gallery slice of a wider leak.** `DashBoardState` already
  carries the previous seller's orders, products, users, boutiques, shops, stories and
  vendor request across a logout, because the bloc is a `lazySingleton` and nothing clears
  it. `/verify` must not read the gallery checks as proof the whole state is clean.
- **The identity pair is a privacy filter, not access control.** `myMarketId` and
  `getXSellerId` are plain SharedPreferences strings writable from the QR-login page; the
  market token itself is in **secure storage** (`prefs_repository_impl.dart:74-81`).
- The gallery adds fields to a state shared by ten tabs, and no validation profile can
  catch a `copyWith` / `props` error.
- The shared image cache evicts by object count with **no byte cap**, so up to 60
  thumbnails plus their previews can push a large number of other images out.
- Thumbnails decode at roughly 1/3 resolution on a 3x screen, because `memCacheWidth` is in
  physical pixels while the tile size is logical. Removing the bound to "fix" softness
  would remove the grid's only memory bound.
- A 401 on an upload replays the whole multipart body with a fresh token
  (`log_interceptor.dart:328-356`), re-sending those bytes.
- Two behaviours have no acceptance criterion (see the spec-gap list).

## Out of scope

- The bulk upload endpoint `/gated/upload/bulk` — its client code exists, but the per-file
  loop is kept for AC-10 (OQ-1).
- **Upload concurrency, app-level timeouts, cancellation, lifecycle handling and
  temporary-file cleanup** — removed by the owner's scope decision; see *What the scope
  decision removed*.
- **Any upload count or size limit** — removed by the owner's scope decision.
- **Masking `X-Upload-Ticket` in stored request data** (round 1 F-9) — pre-existing,
  app-wide, in a protected file; needs its own ticket.
- **Clearing the rest of `DashBoardState` at logout** — needs a ticket that may touch
  `lib/base_page.dart`.
- Threading a `CancelToken` through the upload path — none exists under `lib/core`;
  protected runtime, own ticket.
- Changing the shared Dio timeouts in `lib/core/di/**`.
- A permission gate on the gallery tab — accepted risk.
- Cleaning up orphan uploads — no list or delete API (C-2, C-3), duplicates allowed (E-7).
- Any change to `lib/base_page.dart`, `lib/core/api/**`, `lib/core/data/**`,
  `lib/core/di/**`, `lib/service/service_provider.dart`, or `lib/routes/**`.
- A real percentage progress bar per file.
- Image compression or resizing.
- Deleting, reordering, or reusing a gallery image on a product.
- Any list-images endpoint or backend work, so images never survive an app restart.
- Real device folder browsing, and drag and drop.
- Uploading videos or documents.
- Automated widget tests for the dashboard.
