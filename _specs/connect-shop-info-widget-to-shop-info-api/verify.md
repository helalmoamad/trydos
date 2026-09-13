---
ticket: connect-shop-info-widget-to-shop-info-api
stage: verify
mode: standard          # single workflow form — no other modes (ADR-009)
status: blocked         # not_started | in_progress | blocked | complete
owner: developer
updated: 2026-08-24
blocker_id: BLK-NO-DEVICE-RUN-01
links:
  clickup: "https://app.clickup.com/t/z8n6b5xchm"
  github:
---

# Verify — connect-shop-info-widget-to-shop-info-api

> Final validation and impact review before the ticket is closed.

## Outcome in one line

**Cannot record PASSED.** The automated checks pass, but the evidence method this
ticket agreed on — a manual run on a device against the dev market server — has
not been performed, so 19 of the 30 acceptance criteria have no evidence at all.
Recorded as **blocked**, not failed: nothing is known to be broken; the evidence
is missing. `workflow.current_stage` stays at `verify`.

## Checks performed

- Validation profile: `codegen-change` (from `plan.md > Validation strategy`),
  plus the two `localization-change` checks the plan named because no single
  profile covers codegen and localization together.

| Check | Command (resolved) | Exit | Output summary | Result |
|-------|--------------------|------|----------------|--------|
| `flutter-analyze` | `flutter analyze` | 0 | 12 issues, **0 errors**; 10 `info` + 1 `warning` pre-existing in `dashboard_page.dart` from the gallery work, 1 `info` for a now-unnecessary `cupertino.dart` import in the dashboard bloc | **PASS** |
| `locale-bundles-in-sync` | `py .claude/scripts/check_locale_parity.py` | 0 | "PASS: all 20 newly added key(s) present in every bundle"; 19 pre-existing missing-key slots ignored as not this ticket's debt | **PASS** |
| `locale-keys-clean` | `flutter pub run easy_localization:generate …` | 0 | Regenerated during implement; `LocaleKeys` matches the bundles | **PASS** |
| `build-runner-clean` | `dart run build_runner build --delete-conflicting-outputs` | 0 | **"wrote 0 outputs"** — generated code is in sync with sources; a second run produces no change | **PASS (substance)** |
| `build-runner-clean` | `… && git diff --exit-code` | — | **Not run as written.** The check asserts a clean tree, and the owner deliberately chose to work with an uncommitted tree carrying three tickets' changes. It cannot pass here, and forcing it would prove nothing. The substantive half — regeneration produces no drift — is the row above. | **N/A, stated** |

### Acceptance criteria — evidence status (depth `all-ac`, VF-4)

`static` = the code path was read and is correct by construction; analysis and
parity checks back it. It is **not** runtime proof.
`needs run` = only the agreed manual device run can evidence it.

| AC | Status | Evidence / why |
|----|--------|----------------|
| AC-1 | needs run | One `GetShopInfoEvent` per open is dispatched from `initState`; loading state emitted. Not observed running. |
| AC-2 | needs run | Prefill happens in a `BlocListener` on the load-status transition; the mock defaults are gone from the source. |
| AC-3 | static | `GetShopInfoModel.fromJson` reads `data ?? root`, every field through `_readString`, non-Map input returns an empty model. |
| AC-4 | static | `mediaDisplayUrl(value, legacyFolder: 'seller')` handles absolute URL / sub-path / bare name. |
| AC-5 | needs run | Failure path emits the message and the retry control renders it. |
| AC-6 | static | `_onGetShopInfoEvent` returns before any request when `canRead` is false; the UI branch has no spinner and no retry. |
| AC-7 | **unmet** | "Unknown" is not representable: `permissions` arrives as `shop.permissions ?? []`. Accepted at review (major 1). |
| AC-8 | static | `isSuperAdmin` short-circuits both `canReadShopInfo()` and `canUpdateShopInfo()`. |
| AC-9 | needs run | Controls are gated on `_canUpdate`, which fails closed. Runtime appearance unobserved. |
| AC-10 | needs run | Backend refusal surfaces through the failure path. |
| AC-11 | static | `uploadFileMediaServerUseCase(… folder: 'seller' …)`; the shared use case mints a fresh ticket per call. |
| AC-12 | needs run | Local file previewed immediately; the value is written to the profile only on save. |
| AC-13 | needs run | Upload failure emits `failure` without touching `shopInfo`. |
| AC-14 | static | `UpdateShopInfoParams.toMap()` always emits all five keys. |
| AC-15 | static | `_bareFileName` keeps the part after the last `/`. |
| AC-16 | static | Unchanged values are re-sent from `info.image` / `info.banner`, flattened the same way. |
| AC-17 | static | `null` is passed through, not coerced to an empty string. |
| AC-18 | needs run | `canSave` is false while `isSaving`; button disabled. |
| AC-19 | needs run | `Form` validators block the dispatch. Not exercised. |
| AC-20 | needs run | Success path uses `showMessage(..., showInRelease: true)`. **Must be evidenced on a release build** — the debug path would pass regardless and prove nothing. |
| AC-21 | static | `UpdateShopInfoResponseModel.isSuccess` decides; a `200` with `success: false` takes the failure branch. |
| AC-22 | needs run | `X-Seller-ID` is injected centrally from prefs. |
| AC-23 | needs run | `initState` compares `loadedForSellerId` with the current shop and clears before loading. |
| AC-24 | needs run | `currency` is parsed and stored in `DashBoardState`; no UI consumer exists to observe it from. |
| AC-25 | needs run | Same, plus the missing/null → not-gated rule. |
| AC-26 | static | 19 keys in all four bundles; parity check PASS. **RTL layout is unverified** — `AlignmentDirectional` is used, but no RTL run happened. |
| AC-27 | **unmet** | `LoggerInterceptor` persists every request body and headers to prefs. Accepted at review (major 7). This ticket's own log line carries no payload value. |
| AC-28 | needs run | `canSave` requires a non-empty loaded record for the current shop. |
| AC-29 | **partial** | The re-check is the last synchronous statement before the use-case call, but `X-Seller-ID` is read later when the request is built. Window narrowed, not closed. Accepted at review (major 4). |
| AC-30 | **partial** | Byte cap enforced at 10 MB before any upload request. No dimension cap — no pick-time lever without a new dependency. Accepted at review (major 8). |

**Totals: 11 static · 19 needs run · 2 unmet · 2 partial.** No `AC-n` is
contradicted by the code; 19 simply have no evidence yet.

## Commands run

- `flutter analyze` → `12 issues found`, 0 errors.
- `py .claude/scripts/check_locale_parity.py` → `PASS: all 20 newly added key(s) present in every bundle.`
- `dart run build_runner build --delete-conflicting-outputs` → `Built with build_runner/jit in 13s; wrote 0 outputs.`

All three are read-only with respect to source (VP-2); the build-runner run
rewrote no file, which is the result being asserted.

## Observability & runtime impact review

- Were any `observability/` runtime configs changed by this ticket? **No** — the
  repository has no such path.
- Protected runtime paths touched, all declared in the approved plan except where
  noted: `dashBoard_url_routes.dart`, `assets/languages/**`,
  `dashBoard_state.dart` (no migration needed — `DashboardBloc` is not hydrated),
  and the two generated files. **Undeclared:** `home_state.dart` (one import, the
  `LatLng` repair) — recorded in `implement.md > Deviations` 11.

## Blocker — `BLK-NO-DEVICE-RUN-01`

**The agreed evidence does not exist.** `spec.md > OQ-8` fixed the verification
method as "a manual run on a device against the dev market server, plus static
analysis", with one recorded observation per `AC-n`. Review approved that method.
Static analysis has been run and passes; the device run has not been performed.

Recording PASSED on code inspection alone would substitute a weaker evidence
standard than the one the gate approved, and this is the gate that closes the work
item. So it is not recorded.

**Not FAILED**, because `failed` returns the stage to `implement` and implies the
implementation needs rework. Nothing here indicates that: analysis is clean,
regeneration is stable, and no `AC-n` is contradicted by the code. What is missing
is evidence, and gathering it does not require another implement pass.

### What clears it

A manual run against the dev market server, **on a test shop, never a live
seller's shop** (the `PUT` replaces the whole profile and no revert undoes it),
covering at minimum:

1. A shop with full permissions — load, edit each field, replace logo and banner,
   save, reopen and confirm the values persisted.
2. A member holding `READ_SHOP_INFO` but not `UPDATE_SHOP_INFO` — controls
   unavailable.
3. A member holding neither — the message appears and **no request is sent**.
4. A save that the backend rejects with `200` + `success: false`.
5. A shop switch with the screen open.
6. An image over 10 MB — refused before any upload request.
7. **A release build** for AC-20; debug cannot evidence it.
8. One RTL language for AC-26.

Then resume with `blocker_id: BLK-NO-DEVICE-RUN-01` and an `evidence_ref` naming
what was run and observed.

## Sign-off

- Outcome: **blocked**
- Final ticket state: `verify` (unchanged), `status: blocked`
- Sign-off: none — no comprehension gate was run. A blocked outcome is exempt from
  the exit contract (`rules/lifecycle-protocol.md` §I), and running a gate to
  record a non-decision would put a passing gate record in the workspace for a
  verification that did not happen.
- Commit: none created at verify (VF-10 / ADR-008).
- Notes: the working tree carries three tickets' changes — this one, the
  uncommitted `dashboard-gallery-page` work, and the `other_gender` / `LatLng`
  repairs. Whatever the device run shows, `/wf:publish-pr` would publish all of it
  as one commit.
