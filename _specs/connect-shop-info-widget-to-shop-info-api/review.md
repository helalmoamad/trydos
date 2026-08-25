---
ticket: connect-shop-info-widget-to-shop-info-api
stage: review
mode: standard          # single workflow form — no other modes (ADR-009)
status: complete        # not_started | in_progress | blocked | complete
owner: reviewer
updated: 2026-08-24
round: 2
links:
  clickup: "https://app.clickup.com/t/z8n6b5xchm"
  github:
---

# Review — connect-shop-info-widget-to-shop-info-api

> Review gate — run by the ticket owner themselves (self-review). A comprehension
> check at the gate is the integrity control. Evaluates the spec and plan before
> any implementation.

## Round 1 (2026-08-24) — for the record

Round 1 reviewed plan revision 1 and recorded **`CHANGES_REQUESTED`** on 6 `major`
findings, with a 12-item follow-up brief. Its gate record is retired at
`comprehension-review-1.md` (`attempt: 1`, passed 5/5). This file now holds
round 2; the round-1 decision remains in `ticket.md > State History`.

## Review Scope

`spec.md` as amended (12 FR, **30 AC** — AC-28/29/30 added, AC-9 and AC-27
amended) and `plan.md` **revision 2** (11 steps, 17 files, integration surface,
rollback, a 12-row *Follow-ups from review* table).

Step 1 validation passed: the revision carries every required section, answers
`OQ-7` (PL-12), and states its integration surface. The previous
`comprehension.md` was retired to `comprehension-review-1.md` before this round
began (§G / E1), so this round is `attempt: 2`.

## Plan Summary

Unchanged in shape from revision 1 — one dashboard vertical slice plus a rewrite
of `_ShopInfoWidgetState`. Revision 2 adds: `permissions` passed into the widget
at `case 7`, clearing expressed as *status → `init` + empty model*, the injected
upload use case, `props` alongside `copyWith`, a single endpoint constant, the
existing `mediaDisplayUrl` helper for AC-4, and a byte-size refusal for picked
images.

## Risks

- The `PUT` replaces the whole profile and no revert undoes a bad save.
- Several acceptance criteria now describe distinctions this codebase cannot
  currently express — see the majors below.
- Verification is a manual device run, and one finding below shows a defect that a
  **debug-mode** manual run cannot detect at all.

## Assumptions

- The permission list is loaded before this screen opens.
- `DashboardBloc` is not hydrated (verified, `dashBoard_bloc.dart:65`).
- The backend accepts folder `seller` on the existing gated upload.

## Open Questions

- Whether AC-24/AC-25 (`currency`, `is_new_products_approval`) should be deferred
  until a consumer exists, rather than adding two fields with a writer and no
  reader to a 48-field app-wide state.

## Panel Findings (advisory)

> Findings from the advisory review panel (senior / security / performance) —
> read-only lenses over `plan.md` + `spec.md` (ADR-010 / RP-1).
>
> **Advisory only:** these inform the owner; they never block the decision (RP-2).
>
> Findings raised by more than one lens are merged into a single row, with the
> lenses named. Every row was checked against the repository before being
> recorded — `CONFIRMED` marks the ones re-verified here directly.

| Lens | Severity | Finding | Ref (AC-n / step / file) | Owner's disposition |
|------|----------|---------|--------------------------|---------------------|
| senior + security | **major** | **CONFIRMED. "Unknown" and "denied" are the same value.** The screen receives a non-null `List<String>`, and its origin collapses the nullable source: `permissions: shop.permissions ?? []` (`select_shop_page.dart:312`). A failed permission load and a load that grants nothing are both `[]`. AC-6, AC-7 and AC-9 all branch on a distinction the data cannot carry. | spec.md AC-6, AC-7, AC-9; plan.md step 7 "Load", step 8 | **accept** |
| security | **major** | **CONFIRMED. The load gate has no permission list to read.** Revision 2 puts the load decision in the bloc, but `DashBoardState` holds no permission list and no `GetUserPermissionModel` — only a `GetUserPermissionStatus`. This is round 1's defect moved one layer down, not fixed. | plan.md step 7 "Load" | **accept** |
| security | **major** | **Nothing stores "the shop this profile was loaded for".** Step 2's model keeps `success`, `message`, five profile fields, `currency` and the approval flag — no shop id; the API contract returns none either. AC-23, AC-28 and AC-29 therefore have nothing to compare against. | plan.md steps 2, 7, 8; spec.md AC-23, AC-28, AC-29 | **accept** |
| security | **major** | **AC-29's re-check is on the wrong side of the async boundary.** `X-Seller-ID` is read in the `BaseApi` constructor when the `PutClient` is built (`base_api.dart:32`–`:35`) and only snapshotted at `put.dart:52`. A check "immediately before dispatch" is still separated from that read by an event-loop turn — the window is narrowed, not closed. | spec.md AC-29; plan.md step 7 "Save" | **accept** |
| senior | **major** | **CONFIRMED. The PUT's return type cannot express failure.** `ReadOnlyMessageFromApiModel` parses `message` and `response` only — there is no `success` field (`get_only_message_from_api_model.dart:14`–`:15`). AC-21 ("an HTTP 200 carrying `success: false` is a failure") cannot be evaluated, and adding `success` to that model would change one shared by home, orders, users and stories. | plan.md step 3; spec.md AC-21 | **accept** |
| senior | **major** | **CONFIRMED. The chosen outcome channel is release-suppressed.** `showMessage` runs only `if (kDebugMode \|\| showInRelease \|\| hasError)` (`show_message.dart:31`), and the convention lines the plan cites pass neither flag. AC-20's success message would never appear in a release build — **and a debug-mode manual run cannot detect this**, which is exactly how the ticket plans to verify it. | plan.md step 7 "Save" (follow-up 9); spec.md AC-20 | **accept** |
| senior + security | **major** | **CONFIRMED. AC-27 as amended is not satisfiable by this ticket.** `LoggerInterceptor.onRequest` already persists path, body and headers to prefs for **every** request (`log_interceptor.dart:42`–`:50`), outside any debug guard, and that file is a protected path not in *Files to change*. The AC would read as satisfied while the shop's contact number and address still leave the device. | spec.md AC-27 (amended); plan.md step 7 "Logging" | **accept** |
| performance + senior | **major** | **AC-30 is unmeetable by design.** The amended AC requires a maximum **dimension and** byte size; the plan deliberately delivers a byte-size refusal only, because no pick-time dimension lever exists (`image_picker` absent, `flutter_image_compress` commented at `pubspec.yaml:171`). One half of the criterion cannot be built as scoped. | spec.md AC-30 vs plan.md "The image size cap" | **accept** |
| performance | **major** | **Decode memory is still unbounded, and the fix is free.** Byte size does not bound decode — a 4 MB 4000×3000 JPEG decodes to roughly 48 MB. The repo already solves this with `Image.file(..., cacheWidth: …)` in chat (`image_message.dart:613`–`619`), while the new gallery code shows the anti-pattern (`dashboard_page.dart:4158`). Step 8's local-file preview would repeat it. | plan.md step 8 ("preview the picked local file") | **accept** |
| performance | minor | **CONFIRMED.** The 5 MB cap is unsourced and conflicts with the repo's own precedent: `_kMaxStoryFileBytes = 10 * 1024 * 1024` with the existing localized message `photo_or_video_up_to_10mb` (`seller_stories_widget.dart:31`, `:658`–`:667`). Aligning reuses a key instead of adding one. | plan.md "The image size cap"; spec.md AC-30 | **accept** |
| senior + security | minor | The plan justifies `mediaDisplayUrl` by saying it uses `startsWith('https://')`. It also passes `http://` through and matches `cloudinary` as a substring anywhere (`media_display_url.dart:28`–`:31`), so round 1's "absolute value from an arbitrary host" concern is not actually closed by naming that file. | plan.md step 8 (AC-4) | **accept** |
| security | minor | AC-16's flattening silently rewrites a value the `GET` returned as an absolute URL or from a non-`seller` folder. The plan accepts the folder loss as a known limit but adds no refusal — and this is the write that Rollback admits cannot be undone. | spec.md AC-15, AC-16; plan.md "Out of scope", "Rollback" | **accept** |
| performance | minor | Round 1 asked for `buildWhen` **and** `listenWhen`; revision 2 states `buildWhen` only. An unguarded prefill `BlocListener` runs on every unrelated dashboard emit. | plan.md step 8 | **accept** |
| performance | minor | The plan names no image widget for the rewrite. The current code uses `MyCachedNetworkImage`, which sets `memCacheWidth`/`memCacheHeight` and a disk cache (`my_cached_network_image.dart:118`–`:120`); a plain `Image.network` in the rewrite would lose both — the banner is the expensive one. | plan.md step 8; *Files to change* | **accept** |
| senior | minor | Step 7 "Logging" names no mechanism, and the repo has no breadcrumb convention outside debug pretty-printers, so FR-12's "a record a developer can find later" has no named implementation surface. | plan.md step 7 "Logging"; FR-12 | **accept** |
| senior | minor | `currency` and `is_new_products_approval` add two fields (plus `copyWith` and `props`) to the 48-field app-wide state with a writer and no reader. Worth deferring until a consumer exists. | plan.md step 7; spec.md AC-24, AC-25 (OQ-5) | **accept** |
| senior | minor | *Integration surface* omits three shared things the change depends on: the global `showMessage` helper, the app-wide `LoggerInterceptor` request recorder, and the fact that `permissions` is a **snapshot frozen at shop selection**, never refreshed while the dashboard is open — now driving a fail-closed write gate. | plan.md *Integration surface* (PL-11) | **accept** |
| performance | nit | Step 8 does not pin `withData`. `FilePicker.platform.pickFiles(withData: true)` would read the whole file into RAM before the size check could refuse it; `PlatformFile.size` is available without it. | plan.md step 8 (pick bullet) | **accept** |
| security | info | `BaseApi` mutates the shared singleton Dio's header map in place, so `X-Seller-ID` persists on the shared client for later requests to other servers. Pre-existing and correctly out of scope — noted because AC-22's evidence proves this screen sends the right id, not that the id stops there. | `base_api.dart:13`, `:33`–`:34`, `:51` | **accept** |
| performance | info | Each pick costs two round trips (ticket, then upload), so logo + banner + save is 5 requests. Correct per AC-11; noted only. | plan.md step 7 "Upload" | **accept** |

**Panel summary (round 2):** 9 `major`, 8 `minor`, 1 `nit`, 2 `info`.

**Follow-up verification.** Of the 12-item brief, the panel confirms **2, 3, 6, 7,
10, 11** fully resolved. Items **1, 4, 5, 8, 9, 12** are only *partly* resolved —
each was answered in form, but the answer does not hold against the code:
the permission source was named while the unknown-vs-denied signal was not (1);
the size cap covers bytes but not the dimension the amended AC demands (4);
the AC-4 helper was named with an inaccurate justification (5); the PUT's return
type cannot carry `success` (8); the chosen message channel is release-suppressed
(9); and AC-27 is contradicted by a shared interceptor the ticket does not touch
(12).

## Decision

`APPROVED`

- Rationale: the comprehension gate passed 5/5 at `attempt: 2`, and the owner
  approved the plan with every `major` finding **accepted** rather than mitigated.
  The plan's shape is sound — one vertical slice matching the gallery slice, reuse
  of the existing gated upload, both protected runtime paths declared — and six of
  the twelve round-1 follow-ups are fully resolved. The nine round-2 majors are
  accepted knowingly: the owner chose to start implementation rather than run a
  third plan revision. What that costs is written below, so it is a recorded
  decision and not an oversight.

## Approvals

> Single self-approval by the ticket owner (no distinct reviewer, no second approver).

- Approver (owner): developer (self-review, ADR-009) — recorded 2026-08-24 after
  the comprehension gate passed 5/5 (`comprehension.md`, `attempt: 2`).

## Major finding dispositions

All nine are **accept**. None is mitigated in the plan and none is dismissed as
wrong — each is a real defect that implementation will meet.

1. **Unknown vs denied is not representable** — accept. AC-6/AC-7/AC-9 will be
   implemented against the list-only reality; the "unknown" branch cannot be built
   as specified.
2. **The bloc has no permission list** — accept. The gate will read whatever the
   widget can pass it.
3. **Nothing stores the shop the profile was loaded for** — accept. AC-23/28/29
   need a field that the plan does not name; implementation will have to add one
   or leave the criteria unmet.
4. **AC-29's re-check is on the wrong side of the async boundary** — accept. The
   TOCTOU window is narrowed, not closed.
5. **The PUT's return type cannot express failure** — accept. AC-21 is not
   evaluable for the save without widening a shared model.
6. **`showMessage` is release-suppressed** — accept. AC-20's success message will
   not appear in a release build, and the planned debug-mode manual run cannot
   detect it.
7. **AC-27 is unsatisfiable** — accept. A shared interceptor outside this ticket's
   scope already persists request bodies.
8. **AC-30 is unmeetable by design** — accept. The dimension half of the criterion
   has no lever in this repository.
9. **Decode memory is unbounded** — accept. `Image.file(cacheWidth:)` is available
   but is not in the plan.

## ADR reference

- ADR: none

## Required Follow-up Actions

Approval does not erase the findings — it moves them to `verify`, where each one
becomes an acceptance criterion that will not pass. Carry these forward:

1. **Ten acceptance criteria are expected to fail or be recorded unmet at
   `/wf:verify`:** AC-6, AC-7, AC-9 (unknown vs denied), AC-20 (release-suppressed
   message), AC-21 (no `success` on the PUT return type), AC-23, AC-28, AC-29
   (no stored shop id; async boundary), AC-27 (shared interceptor), AC-30
   (dimension cap). `/wf:verify` must record them honestly rather than mark them
   passed.
2. **`implement` may only edit the files listed in `plan.md > Files to change`**
   (IM-4/IM-5). Anything the findings imply beyond that list — for example a new
   state field for the loaded shop id — is scope growth and must be recorded as a
   deviation in `implement.md`, or the work item blocks.
3. **The manual run cannot be debug-only.** Finding 6 is invisible in debug mode.
   Any evidence for AC-20 must come from a release build.
4. **Use a test shop, never a live seller's shop** — the `PUT` replaces the whole
   profile and no revert undoes it.
5. Three free improvements the panel named, available during implementation
   without new scope: `Image.file(cacheWidth: …)` for the preview, the existing
   10 MB precedent `_kMaxStoryFileBytes` with its localized message instead of an
   unsourced 5 MB, and `showMessage(..., showInRelease: true)` for the save
   outcome.
