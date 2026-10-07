---
ticket: add-and-edit-boutiques-in-seller-dashboard
stage: review
mode: standard
status: complete
owner: reviewer
updated: 2026-10-04
links:
  clickup: "https://app.clickup.com/t/z8n6b60hxc"
  github:
---

# Review — add-and-edit-boutiques-in-seller-dashboard

> Review gate — run by the ticket owner themselves (self-review). A comprehension
> check at the gate is the integrity control. Evaluates the spec and plan before
> any implementation.

## Review Scope

`spec.md` (13 FR, 40 AC, constraint C-2 [ASSUMED] create/lookups contract) and
`plan.md` (first plan, no revision), with `research.md` for context. Step 1
validation passed: PL-1..PL-5, PL-11, PL-12 (OQ-9, OQ-10, OQ-1a, OQ-6a
answered), PL-13 (one row per AC-1..AC-40, all `none — OQ-5`), PL-14 (coverage
searched in `test/`), and the requirement ↔ AC ↔ step table.

## Plan Summary

Copy the Locations layering for six new calls (lookups, create, edit, update,
change-status, languages). Keep the form in a new feature-local factory
`BoutiqueEditorBloc` so the app-wide `DashboardBloc` only gains a list-clear
event and `restartable()` on the list load, and `dashBoard_state.dart` is not
touched. Payload, validation and file checks are pure functions. Description
uses `flutter_quill` with HTML converted in and out. Uploads reuse the existing
single-file path. 422 `detailed_error` is not carried (owner decision; AC-35 and
AC-36 partly met). No automated tests (OQ-5); verify runs `codegen-change`, the
two locale checks, and a 16-step manual script.

## Risks

- Create payload shape is still [ASSUMED] (spec C-2); a wrong per-language key
  drops every translation on a backend record the website shares — not
  reversible by a code revert.
- Banner full-replace semantics: a payload bug deletes or duplicates banners.
- New native dependency raises the toolchain floor for the whole app.
- Memory pressure from full image decodes and full-size previews on low-end
  phones.

## Assumptions

- The backend owner confirms the create and lookups shapes before implement.
- CI and every developer machine meet Flutter `>=3.44` / Dart `^3.12`.
- The backend and the website sanitize boutique HTML when they render it.

## Open Questions

- none beyond the follow-ups below.

## Panel Findings (advisory)

| # | Lens | Severity | Finding | Ref (AC-n / step / file) | Owner's disposition |
|---|------|----------|---------|--------------------------|---------------------|
| P-1 | performance | major | Reading banner width/height with `dart:ui.decodeImageFromList` decodes every pixel (a 12 MP photo ≈ 48 MB); several banners at once can exhaust memory. Suggest checking `PlatformFile.size` first, then reading only the header with `ImmutableBuffer.fromFilePath` + `ImageDescriptor.encoded`. | Step 12, Step 7 `checkBannerFile`, AC-24 || **mitigate** — inside Steps 7/12: check `PlatformFile.size` before reading bytes; read width/height from the header only (`ImmutableBuffer.fromFilePath` + `ImageDescriptor.encoded`), dispose both. Replaces the `decodeImageFromList` call named in Step 12. |
| P-2 | performance | major | Decoded previews are not size-limited: 4 languages × N banners + 4 icons at full size, doubled by copied banners, can hold hundreds of MB. Suggest `cacheWidth` / `ResizeImage` sized to the tile and building only the active tab. | Step 8, Step 12 `boutique_banner_grid.dart`, AC-21, AC-27 || **mitigate** — inside Step 12: every local and network preview uses `cacheWidth` / `ResizeImage` sized to its tile; only the active language tab is built. |
| P-3 | performance | major | The large form (and its `saved` copy) is copied on every field edit; one `BlocBuilder` would rebuild every section, the Quill editor and banner grid included, on each keystroke. Suggest controllers for text, per-section `buildWhen` / `BlocSelector`, and structural sharing between `form` and `saved`. | Step 8 || **mitigate** — inside Steps 8/12: text lives in controllers and reaches the form on save / validate / copy / tab change; each section rebuilds through its own `buildWhen` / `BlocSelector`; `saved` shares unchanged parts with `form`. |
| S-1 | senior | major | `flutter_quill` needs Dart `^3.12` / Flutter `>=3.44` while the app declares `sdk: '>=3.8.0 <4.0.0'` (`pubspec.yaml:22`), and its native plugin (`quill_native_bridge`) changes the tracked `ios/Podfile.lock`. Neither is in Integration surface, Files to change or Rollback. Suggest naming both, and stopping at Step 1 if `pub add` upgrades an existing direct dependency. | Step 1, OQ-1a, Integration surface, Files to change, Rollback || **mitigate** — before implement, confirm CI and every developer machine meet Flutter `>=3.44` / Dart `^3.12`, recorded in `implement.md`; `ios/Podfile.lock` is treated as part of Step 1 (see follow-ups). |
| P-4 | performance | minor | When HTML conversion runs is not stated; four live `QuillController`s. Convert once at load and only in `buildPayload`; check empty with `document.isEmpty()`; dispose controllers. | OQ-1a, Step 12, AC-25, AC-26, AC-30 | |
| P-5 | performance | minor | Two requests per file (ticket + upload), up to 32 sequential requests for a full create. Accept; show per-file progress; batching tickets is a later option. | OQ-10, Step 8 | |
| P-6 | performance | minor | Uploads continue after the page closes or a load restarts; a late upload may emit on a closed bloc. Use a `CancelToken` or check `isClosed`, and stop the queue in `close()`. | Step 8, AC-3, AC-38 | |
| P-7 | performance | minor | Languages then lookups/edit run in sequence and languages is refetched on every open. Run them in parallel and cache languages for the session. | Step 8, OQ-6a | |
| P-8 | performance | minor | No limit on banners per pick or per language; never use `FilePicker` `withData: true`. | Step 12, AC-23 | |
| P-9 | performance | minor | `ClearBoutiquesEvent` emits on every tab visit; the home card count shows 0 until reload. Emit only when needed. | Step 9, Step 11 | |
| S-2 | security | minor | Rich-text round trip can carry links/embeds from website HTML (e.g. a `javascript:` href) and the editor can launch links. Strip to bold/italic/underline/H2, drop or limit links, disable link launching; backend and website must still sanitize. | OQ-1a, Step 12, AC-25, AC-26 | |
| S-3 | security | minor | An empty seller id makes `_sellerHeader` return `null`, so the write silently falls back to the prefs `X-Seller-ID` (`base_api.dart:33-36`). Add a guard in the write use cases / data source too. | AC-1, AC-2, Steps 4, 6, 8 | |
| S-4 | security | minor | Only load answers are checked for a shop switch; Save and uploads still run for the captured shop after prefs changed. Check before Save and each upload. | AC-3, Step 8 | |
| S-5 | security | minor | Full-image decode of a small file with huge pixel dimensions can crash the app (same root as P-1). | Step 12, AC-24 | |
| S-6 | security | minor | Image type is judged by extension/MIME, not content. Check magic bytes; confirm the media server checks the new folders. | Step 7, AC-24 | |
| S-7 | security | minor | M-10's "debug route" would touch protected `lib/routes/**` and is not in Files to change. Use an uncommitted local change or a proxy instead. | Validation M-10 | |
| S-8 | security | minor | Three new packages; small maintainer base for `vsc_quill_delta_to_html`. Pin versions and review the transitive `pubspec.lock` diff. | Step 1 | |
| C-1 | senior | minor | Shop-switch guard is weaker than Locations: an old list load that finishes after opening shop B's dashboard (before the tab is opened) shows shop A's total on B's home card. Accept and record, or also clear on tab-page dispose. | AC-3, Steps 9, 11 | |
| C-2 | senior | minor | Step 11 may read as gating the Clear behind `canReadBoutiques()`; state that Clear always runs and only the load is gated. | Step 11, AC-3, AC-6 | |
| C-3 | senior | minor | `_buildBoutiquesTab` is in `DashboardContentPage`, which has no permission checker today; one must be built from `widget.permissions`. | Step 11 | |
| C-4 | senior | minor | `restartable()` also changes pagination (a fast second page tap cancels the first), and the Clear can flash the empty state before `loading`; reset status in the Clear handler. | Step 9, Integration surface | |
| S-9 | security | info | A 422 message logged on refusal can echo form content (a duplicate name). | Step 8, AC-40 | |
| S-10 | security | info | Existing, not added here: debug `LoggerInterceptor` prints the bearer token and full body. | AC-40 | |
| S-11 | security | info | Existing: `BaseApi` writes `X-Seller-ID` into shared Dio headers; plan correctly uses `extraHeaders` for writes. | Step 4, OQ-6a | |
| S-12 | security | info | Hidden controls are UX only; backend 403 is the enforcement (AC-10). Run M-9 with a DELETE-only account too. | Step 10, AC-5..AC-9 | |
| S-13 | security | info | Blast radius reversible except backend records written with a wrong payload; keep C-2 as a hard precondition and test on a test shop first. | Files to change, Rollback, spec C-2 | |
| C-5 | senior | info | Two toasts on a refused status change (interceptor + AC-35) — known and accepted. | AC-35 | |
| C-6 | senior | info | Scope is right-sized; no over-engineering found. | Approach, Steps 2-8 | |
| C-7 | senior | info | Rollback must also revert `pubspec.lock` and `ios/Podfile.lock` and run `pod install`. | Rollback | |
| P-10 | performance | info | Upload streams from file path; a 10 MB file is never fully in memory there. | OQ-10 | |
| P-11 | performance | info | Feature-local factory bloc is the cheaper choice. | Approach, OQ-9 | |

## Decision

`APPROVED`

- Rationale: the owner passed the comprehension gate 4/4 (degraded — see
  `comprehension.md > degraded`) and chose `approved`. The plan meets PL-1..PL-5,
  PL-11..PL-14 and is traceable to all 40 AC. The four `major` findings are all
  dispositioned `mitigate` inside the approved steps and files; no finding
  required a new file or a new approach. Minor and info findings are advisory and
  are carried as implementation notes below.

## Approvals

- Approver (owner): developer (Ali Fouaad), self-approval, 2026-10-04.

## ADR reference

- ADR: none

## Required Follow-up Actions

Before `implement` starts:

1. **Spec C-2 (hard precondition):** record the backend owner's confirmation of
   the create and lookups shapes in `implement.md`, or block.
2. **S-1:** record in `implement.md` that CI and every developer machine meet
   Flutter `>=3.44` / Dart `^3.12`.

During `implement` (inside the approved steps and files — record each in
`implement.md` as an owner-approved review mitigation):

3. **P-1 / S-5:** header-only image size read and size check before reading
   bytes (Steps 7, 12) instead of `decodeImageFromList`.
4. **P-2:** size-limited previews; only the active tab is built (Step 12).
5. **P-3:** controllers + per-section rebuilds + structural sharing (Steps 8, 12).
6. **S-1 / C-7 — `ios/Podfile.lock`:** it is **not** in `plan.md > Files to
   change`. On Windows `flutter pub add` does not run `pod install`, so the file
   is not expected to change in this ticket. If it does change, do not stage it
   under IM-4; record it in `implement.md` and leave it for the first iOS build
   (`pod install` on macOS). Rollback of the dependency then also needs a
   `pod install`.

Implementation notes from minor findings (advisory; apply where they fit the
approved files, otherwise record and leave):

- S-2: limit the Quill document to bold / italic / underline / header 2, drop
  link and embed ops, disable link launching.
- S-3: the three write use cases return a `Failure` and send nothing when
  `sellerId` is null or empty.
- S-4 / C-1: check captured-vs-prefs shop id before Save and before each upload.
- S-6: check image magic bytes in `checkBannerFile`.
- S-7: produce the M-10 `404` with an uncommitted local change or a proxy — no
  debug route, no `lib/routes/**` change.
- S-8: pin exact versions; review the transitive `pubspec.lock` diff.
- P-4: convert HTML ↔ Delta only at load and in `buildPayload`; dispose controllers.
- P-6: stop the upload queue in `close()`; check `isClosed` before emits.
- P-7: run languages and lookups/edit in parallel.
- P-8: never use `FilePicker` `withData: true`.
- C-2: `ClearBoutiquesEvent` always runs; only `GetBoutiquesEvent` is gated by
  `canReadBoutiques()`.
- C-3: build a `DashboardPermissionChecker` in `_DashboardContentPageState`.
- C-4 / P-9: the Clear handler also resets `getBoutiquesStatus`; note that
  `restartable()` also affects pagination.
