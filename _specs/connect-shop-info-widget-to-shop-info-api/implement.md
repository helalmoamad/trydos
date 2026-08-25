---
ticket: connect-shop-info-widget-to-shop-info-api
stage: implement
mode: standard          # single workflow form — no other modes (ADR-009)
status: complete        # not_started | in_progress | blocked | complete
owner: developer
updated: 2026-08-24
links:
  clickup: "https://app.clickup.com/t/z8n6b5xchm"
  github:
---

# Implement — connect-shop-info-widget-to-shop-info-api

> Record of what was actually built, following `plan.md`.

## Changes made

Applied to the working tree on **`ali_dev`** — no ticket branch, see
*Deviations* 1. Nothing is committed (IM-9).

### Planned files

- `lib/common/constant/configuration/dashBoard_url_routes.dart` — **PROTECTED.**
  Added one constant `shopInfoEP = 'info'.shopScope()`, used by both verbs.
- `lib/features/dashBoard/data/models/GetShopInfoModel.dart` — **new.** Tolerant
  model reading `data ?? root`; keeps `success`, `message`, the five profile
  fields, `currency`, `is_new_products_approval` (missing/null → not gated), and
  a locally-written `loadedForSellerId`. Also holds
  `UpdateShopInfoResponseModel` and a `GetShopInfoModel.empty()` used as the
  cleared value.
- `.../data_source/dashBoard_remote_data_source_model.dart` — `getShopInfo()`
  (`GetClient`) and `updateShopInfo(Map)` (`PutClient`), both on `shopInfoEP`.
- `.../domain/repositories/dashBoard_repository.dart` — two abstract methods.
- `.../data/repositories/dashBoard_repository_impl.dart` — both wrapped in
  `handlingExceptionRequest`.
- `.../domain/useCase/GetShopInfoUseCase.dart` — **new**, `@injectable`.
- `.../domain/useCase/UpdateShopInfoUseCase.dart` — **new**, `@injectable`, with
  `UpdateShopInfoParams` carrying the five fields.
- `.../presentation/widgets/permission_enum.dart` — appended `READ_SHOP_INFO`
  and `UPDATE_SHOP_INFO` (matched by `fromString`, so ordinal-safe).
- `.../presentation/widgets/dashboard_permission_checker.dart` — added
  `canReadShopInfo()` and `canUpdateShopInfo()`. Purely additive; no existing
  method touched, so no other tab's visibility moves.
- `.../presentation/bloc/dashBoard_event.dart` — `GetShopInfoEvent`,
  `ClearShopInfoEvent`, `UploadShopMediaEvent`, `UpdateShopInfoEvent`.
- `.../presentation/bloc/dashBoard_state.dart` — **PROTECTED glob.** Five new
  fields and three status enums, wired through declarations, constructor,
  `copyWith` parameters, `copyWith` body **and `props`**. The `copyWith` idiom is
  unchanged; clearing uses status → `init` plus `GetShopInfoModel.empty()`, never
  a null assignment and never a rebuilt `DashBoardState`. No migration path is
  written because `DashboardBloc extends Bloc`, not `HydratedBloc`.
- `.../presentation/bloc/dashBoard_bloc.dart` — two injected use cases and four
  handlers (`_onGetShopInfoEvent`, `_onClearShopInfoEvent`,
  `_onUploadShopMediaEvent`, `_onUpdateShopInfoEvent`), plus `_bareFileName`,
  `_currentSellerId` and `_logShopInfo`. Upload reuses the already-injected
  `uploadFileMediaServerUseCase` with `folder: 'seller'`.
- `.../presentation/pages/dashboard_page.dart` — `case 7` now builds
  `ShopInfoWidget(permissions: widget.permissions)`; `_ShopInfoWidgetState`
  rewritten against the bloc.
- `assets/languages/{en-US,ar-SY,ku-IQ,tr-TR}.json` — **PROTECTED.** 19 new
  `shop_info_*` keys, identical key set in all four.
- `lib/generated/locale_keys.g.dart` — regenerated (`keys.sh`).
- `lib/core/di/di_container.config.dart` — regenerated (`gen.sh`).

### Out-of-plan files (see Deviations 9 and 11)

- `lib/features/home/presentation/widgets/profile_section/profile_personal_info_page.dart`
  — one line, `LocaleKeys.other` → `LocaleKeys.other_gender`.
- `lib/features/story/presentation/pages/story_collection.dart` — same, one line.
- `lib/features/home/presentation/manager/homeBloc/home_state.dart` —
  **PROTECTED glob** (`**/*_state.dart`). One added import,
  `import 'package:geodesy/geodesy.dart' show LatLng;`. No state field, no
  serializer shape, no hydrated payload is affected.

## Changes prepared (uncommitted)

No commit was created (IM-9 / ADR-008), so there are no SHAs. The files above are
in the working tree, mixed with the pre-existing `dashboard-gallery-page` changes
the owner chose to ship together.

## Deviations from plan

1. **No ticket branch (IM-3 waived by the owner).** The working tree was dirty in
   ten of this plan's own files — the uncommitted `dashboard-gallery-page` work —
   so the stage first blocked as `BLK-DIRTY-TREE-01`. The owner resumed it with
   the instruction to work on `ali_dev` and push everything together. The two
   tickets' diffs are therefore **not separable**, and `plan.md > Rollback` no
   longer holds: reverting this work would also revert the gallery.
2. **A dedicated `UpdateShopInfoResponseModel`** instead of the planned
   `ReadOnlyMessageFromApiModel` (plan step 3). That shared model parses only
   `message` and `response`, so AC-21 could not be evaluated; widening it would
   have touched home, orders, users and stories. Addresses accepted major 5.
3. **`loadedForSellerId` added to the model.** The plan's step 2 field list had
   no place to store which shop a record belongs to, which left AC-23/28/29 with
   nothing to compare. Written locally at load success from `getXSellerId`.
   Addresses accepted major 3.
4. **Size cap is 10 MB, not 5 MB**, reusing the repo's own `_kMaxStoryFileBytes`
   figure and its existing localized message `photo_or_video_up_to_10mb` instead
   of adding an unsourced number and a new key. Review follow-up 5.
5. **`Image.file(..., cacheWidth: 600)`** for the local preview and
   `MyCachedNetworkImage` retained for the stored image, so decode memory is
   bounded and the disk cache is not lost. Review follow-up 5.
6. **`showMessage(..., showInRelease: true)`** on the save success path.
   `showMessage` runs only `if (kDebugMode || showInRelease || hasError)`, so
   without the flag AC-20's message would never appear in a release build.
   Review follow-up 5.
7. **`listenWhen` added alongside `buildWhen`**, so the prefill listener does not
   run on every unrelated dashboard emit.
8. **`withData: false`** on the picker, so the size check runs before any bytes
   are read into memory.
9. **Two out-of-scope one-line edits, and a key rename.** Regenerating the locale
   keys (plan step 10, mandatory) revealed that `LocaleKeys.other` **can never be
   generated**: `other` is an ICU plural keyword and `easy_localization`'s
   generator skips it. The committed `locale_keys.g.dart` was stale and still
   carried the constant, so two call sites compiled against a key no bundle had.
   After regeneration the package no longer compiled. Fixed minimally by renaming
   the bundle key to `other_gender` in all four bundles and updating the two call
   sites. This is scope growth, recorded here rather than hidden; without it the
   tree does not build.
10. **`LocaleKeys.try_again` reused** for the load-failure retry control instead
    of adding a new key.
11. **The pre-existing `LatLng` build break was fixed, at the owner's request.**
    It is not this ticket's regression and was originally recorded here as
    out of scope; the owner asked for it directly after the implement stage
    closed, so it is folded into the same working tree and recorded here rather
    than left implicit. Details below.

## Known-unmet acceptance criteria

Recorded now so `/wf:verify` does not have to rediscover them. All follow from
findings the review gate **accepted**:

| AC | Status | Why |
|----|--------|-----|
| AC-7 | **unmet** | "Unknown" permission state is not representable — `permissions` arrives as `shop.permissions ?? []`. The gate treats unknown as denied. |
| AC-20 | **met, but only via deviation 6** | Would have been unmet with the planned `showMessage` call. |
| AC-21 | **met, via deviation 2** | Would have been unmet with the planned return type. |
| AC-23, AC-28, AC-29 | **met, via deviation 3** | Would have been unmet with the planned model. |
| AC-29 | **partial** | The re-check is the last synchronous statement before the use-case call, but `X-Seller-ID` is read later when the request is built. The window is narrowed, not closed. |
| AC-27 | **unmet** | `LoggerInterceptor` persists every request body and headers to prefs. Out of scope; this ticket's own log line carries no payload value. |
| AC-30 | **partial** | Byte cap enforced (10 MB). No dimension cap: no pick-time lever exists without a new dependency. |

## Validation run during implementation

- `flutter pub run easy_localization:generate …` (`keys.sh`) — **pass**, ran 3×
  during the `other_gender` diagnosis; final output includes all 19 new keys.
- `dart run build_runner build --delete-conflicting-outputs` (`gen.sh`) — **pass**,
  58 outputs written; the two new `@injectable` use cases are wired into
  `di_container.config.dart`.
- `py .claude/scripts/check_locale_parity.py` — **PASS**: "all 19 newly added
  key(s) present in every bundle"; 19 pre-existing missing-key slots ignored as
  not this ticket's debt.
- `flutter analyze` — **0 errors, 12 issues, none from this ticket's code.**
  Breakdown: 10 `info` (redundant-argument / deprecated `withOpacity`) and 1
  `warning` (`_confirmDeleteSelected` unused) — all pre-existing in
  `dashboard_page.dart` from the gallery work; plus 1 `info` for a
  now-unnecessary `cupertino.dart` import in the dashboard bloc.
  The single error that was open when this stage closed has since been fixed —
  see below.

### Pre-existing build error — diagnosed here, fixed on request

`lib/features/home/presentation/manager/homeBloc/home_state.g.dart:208` —
`Undefined name 'LatLng'`.

**Cause.** `json_serializable` emits `LatLng.fromJson(...)` into the generated
part without the `geod.` prefix, while `home_state.dart` imported `geodesy`
only as `geod`. The generated part therefore had no unprefixed `LatLng` in
scope. The file was already modified in the working tree when this session
began, and `git diff` showed that single line as its only change from `HEAD`,
so the regression predates this ticket. Regenerating reproduces it.

**Status when this stage closed:** open, recorded as out of scope, and noted as
blocking the manual device run.

**Fixed afterwards, at the owner's explicit request** (deviation 11). One line
added to `home_state.dart`:

```dart
import 'package:geodesy/geodesy.dart' show LatLng;
```

alongside the existing prefixed import. Same library, same type — it only puts
the name in scope for the generated part.

**Why the source and not the generated file:** a generated file is rewritten by
the next `sh gen.sh`, so patching it would have restored the break. Verified:
`dart run build_runner build --delete-conflicting-outputs` was re-run (28
outputs), the generator still emits the unprefixed `LatLng.fromJson`, and
`flutter analyze` reports **0 errors**.

**Scope note.** `home_state.dart` matches the protected `**/*_state.dart` glob
and is not in `plan.md > Files to change`. It is an import line: no state field
changes, no serializer shape changes, and `HomeBloc`'s stored payloads are
unaffected, so no migration path is needed. It is still an unplanned edit to a
protected path and will land in the same push as this ticket — it deserves its
own line in the commit message, or its own work item.
