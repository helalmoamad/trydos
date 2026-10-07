---
ticket: add-and-edit-boutiques-in-seller-dashboard
stage: verify
mode: standard
status: complete
owner: developer
updated: 2026-10-04
links:
  clickup: "https://app.clickup.com/t/z8n6b60hxc"
  github:
---

# Verify — add-and-edit-boutiques-in-seller-dashboard

> Final validation and impact review before the ticket is closed.

## Checks performed

- Validation profile: **`codegen-change`** (`build-runner-clean` +
  `flutter-analyze`), plus the extra checks the plan named:
  `locale-bundles-in-sync` and `locale-keys-clean`.
- `plan.md > Tests`: **`none — OQ-5`** for AC-1..AC-40 (no test-runner check in
  `.claude/project-config.yaml`). No test path runs; that recorded reason is
  what this stage checks (VF-11).

| Check | Command (resolved) | Exit | Output summary | Result |
|-------|--------------------|------|----------------|--------|
| `build-runner-clean` | `dart run build_runner build --delete-conflicting-outputs`, then compare | `0` | "Built … in 236s; wrote 30 outputs." MD5 of `di_container.config.dart` identical before and after (`80c72bb03f1d23cc74317419941f98c4`). Only the two declared generated files differ from `HEAD` (`di_container.config.dart`, `locale_keys.g.dart`); no other `.g.dart` rode along. | **PASS** |
| `flutter-analyze` | `flutter analyze` | `0` | "No issues found! (ran in 186.6s)" — whole package. | **PASS** |
| `locale-keys-clean` | `flutter pub run easy_localization:generate -S assets/languages -f keys -o locale_keys.g.dart`, then compare | `0` | MD5 of `locale_keys.g.dart` identical before and after (`dcbe829e7839a3ab6776f451a25f21f1`). | **PASS** |
| `locale-bundles-in-sync` | `py .claude/scripts/check_locale_parity.py` | `0` | "PASS: all 57 newly added key(s) present in every bundle." 19 pre-existing gaps ignored (not this ticket's). | **PASS** |

**Why `git diff --exit-code` was not the comparison** for `build-runner-clean`
and `locale-keys-clean`: it cannot pass while the work is uncommitted, and IM-9
forbids this work item to commit. The property each check asserts — regeneration
produces no change — was tested by hashing the generated file, regenerating and
comparing (same method as `_specs/manage-shop-locations-in-seller-dashboard`).
The check definitions were not edited (VP-4).

**Manual device run (plan > Validation strategy, M-1..M-16):** reported by the
owner on 2026-10-04 as **run, all 16 steps passed**. It is recorded as the
owner's observed evidence; this stage did not drive the device itself, and no
per-step logs or screenshots are attached.

## Acceptance criteria (all-ac)

Evidence kinds: **device** = owner-reported manual step (M-n); **code** = read in
the implementation; **check** = a validation check above.

| AC | Met? | Evidence |
|----|------|----------|
| AC-1 | yes | code: writes carry `extraHeaders: _sellerHeader(sellerId)` with the shop captured at page open; reads use `BaseApi`'s `X-Seller-ID`. device: M-12. |
| AC-2 | yes | code: `_onSaved` refuses an empty captured shop id; the three write use cases return `missingBoutiqueShopFailure` and send nothing (S-3). |
| AC-3 | yes | code: `ClearBoutiquesEvent` always runs on tab open + `restartable()` on the list load; the editor drops read answers and closes on a shop change. device: M-11. |
| AC-4 | yes | code: `404` → `notFound` → "Boutique not found.", no form, no save control. device: M-10. |
| AC-5 | yes | code: `canSeeBoutiques()` checks the six boutique strings or `SUPER_ADMIN`. device: M-9. |
| AC-6 | yes | code: Add button / empty-state action only when `canCreateBoutique()`. device: M-9. |
| AC-7 | yes | code: `onBoutiqueTap` is `null` without `canUpdateBoutique()` → inert card. device: M-9. |
| AC-8 | yes | code: Edit / Save hidden without `UPDATE_BUTIKS`. device: M-9. |
| AC-9 | yes | code: status button only in edit mode, not on create, only with `canChangeBoutiqueStatus()`. device: M-1, M-9. |
| AC-10 | yes | code: `403` → `accessDenied` message, no form. device: M-10. |
| AC-11 | yes | code: tabs from `GET api/v1/languages`, labels from `native_name`, duplicates removed. device: M-1. |
| AC-12 | yes | code: failure or empty answer → `BoutiqueLanguage.fallback` (en, ar, tr, ku). device: M-13. |
| AC-13 | yes | code: lookups loaded on Add; countries + availabilities from them; empty availabilities → 1/2/3. Contract confirmed (C-2, `implement.md`). device: M-1. |
| AC-14 | yes | code: create page always editable, header + bottom bar, `emptyForm` = Web + Mobile, no country. device: M-1. |
| AC-15 | yes | code: view mode locks fields, hides upload / remove / reorder / copy. device: M-2. |
| AC-16 | yes | code: header shows icon, name, Active/Inactive pill, `ID: {id}`. device: M-2. |
| AC-17 | yes | code: Edit unlocks; Cancel + Save in header and bottom bar. device: M-2. |
| AC-18 | yes | code: Cancel copies `saved` back, bumps `formRevision`, sends nothing. device: M-3. |
| AC-19 | yes | code: section order; missing language → empty entry; availability normalized to 3. device: M-2. |
| AC-20 | yes | code: other load errors → error box with Retry (`BoutiqueEditorRetried`). device: M-13. |
| AC-21 | yes | code: `copySources` lists only filled other languages; menu hidden in view mode. device: M-5. |
| AC-22 | yes | code: `copyField` copies banners with `withoutId()`. device: M-5 (checked on the website). |
| AC-23 | yes | code: banner queue on `sequential()`; a warning stops the queue until answered. device: M-6. |
| AC-24 | yes | code: size first, magic bytes, header-only width / ratio; unknown size accepted. device: M-6. |
| AC-25 | yes | code: Quill editor with B / I / U / H2, HTML via `vsc_quill_delta_to_html`. device: M-7. |
| AC-26 | yes | code: HTML → Delta on load (limited to the four styles). device: M-7 (website formatting kept). |
| AC-27 | yes | code: `bareFileName` for new uploads and for `/edit` URLs; local preview at once. device: M-4 (no doubled folder on the website). |
| AC-28 | yes | code: move / delete per tile, order → `sequence`, LTR banner row. device: M-4. |
| AC-29 | yes | code: chips with backend `name`, toggle, empty = everywhere. device: M-1. |
| AC-30 | yes | code: `validateForm` on every language; empty editor counts as empty. device: M-8. |
| AC-31 | yes | code: jump to first error tab, red fields, toast, no request. device: M-8. |
| AC-32 | yes | code: create body under `boutique_custom_data`, no ids, no status, `product_resources: []`, globals from English; on success the same page loads the new boutique in view mode (Inactive) — see `implement.md` deviation 1. device: M-1. |
| AC-33 | yes | **code only:** no id in the create answer → `backToList`. Cannot be forced on a real backend (as the plan stated). |
| AC-34 | yes | code: update body under `custom_data`, existing ids kept, full banner lists, ids unchanged, no status; success toast and view mode. device: M-4. |
| AC-35 | **partly** | code: status change only after a successful update; refusal keeps edits, restores old status, red box, AC-35 toast. **Only the backend `message` is listed, not every `detailed_error` entry** — owner-accepted deviation (`plan.md > Recorded deviation`). device: M-14. |
| AC-36 | **partly** | code: failed save shows the backend `message` or the fixed fallback, stays in edit mode. **Cannot join several messages with " • "** — same owner-accepted deviation. device: M-15. |
| AC-37 | yes | code: page pops `true` when `didChange`; list reloads page 1. device: M-1, M-4. |
| AC-38 | yes | code: Save on `droppable()`; buttons disabled while saving or uploading; spinner on Save. device: M-4. |
| AC-39 | yes | check: `locale-bundles-in-sync` PASS (57 keys × 4). device: M-16 (RTL, banner row LTR). |
| AC-40 | yes | **code only:** every `devLog` line in `boutique_editor_bloc.dart` carries action, outcome, shop, boutique, HTTP code; the backend message only on a refused status change; no form content, file names, tokens or tickets. |

**Result: 38 met, 2 partly met (AC-35, AC-36) under the owner-accepted recorded
deviation. No criterion is unmet.**

## Integration surface — did it hold?

- **`DashboardBloc`:** only `ClearBoutiquesEvent` and `restartable()` on the
  list load; `dashBoard_state.dart` untouched. Held.
- **`DashboardPermissionChecker`:** widened `canSeeBoutiques()`; the old
  `dashboard_tab_bar.dart` shares it but `DashboardTabBar` is not instantiated in
  live code (only in commented-out blocks of `dashboard_page.dart`). Held.
- **Upload use case:** reused unchanged; other callers (stories, Shop Info,
  product returns, profile photo) untouched. Held.
- **DI:** six factory use cases + one factory bloc; nothing app-wide;
  `ServiceProvider`, `main.dart`, `trydos_application.dart`, `lib/core/api/**`,
  `lib/routes/**` untouched (`git diff HEAD -- lib/core lib/main.dart lib/service
  lib/trydos_application.dart lib/routes` shows only `di_container.config.dart`).
  Held.
- **`pubspec.yaml` / `pubspec.lock`:** 3 direct, 24 added, 0 changed. Held.
- **Did not fully hold — native build files.** The new dependency also
  regenerates `macos/Flutter/GeneratedPluginRegistrant.swift`,
  `windows/flutter/generated_plugin_registrant.cc` and
  `windows/flutter/generated_plugins.cmake` on every `pub get`, and will change
  `ios/Podfile.lock` on the first `pod install`. The plan's integration surface
  did not name them (panel finding S-1 / C-7). They are outside
  `plan.md > Files to change` and are **not in the publishable set**
  (`implement.md`). See FINDING-1.

## Commands run

- `dart run build_runner build --delete-conflicting-outputs` → exit 0, "wrote 30
  outputs", DI MD5 unchanged.
- `flutter pub run easy_localization:generate -S assets/languages -f keys -o locale_keys.g.dart`
  → exit 0, keys MD5 unchanged.
- `py .claude/scripts/check_locale_parity.py` → exit 0, PASS (57 keys).
- `flutter analyze` → exit 0, "No issues found!".

## Findings — confirmed bugs, out of scope

No `BUG-n` was recorded in `implement.md` (no test was written), and none was
confirmed here.

| BUG  | Scenario that is wrong | Confirming test (file::case + marker) | Where the bug lives | Expected vs actual | Ticket |
|------|------------------------|---------------------------------------|---------------------|--------------------|--------|
| none | — | — | — | — | — |

Other findings (not bugs; for the owner):

- **FINDING-1 — tool-generated native files outside the plan.** The three
  desktop plugin registrants show as modified in the working tree and come back
  on every `pub get`; `ios/Podfile.lock` will change on the first iOS build.
  Before `/publish-pr`: exclude them from the publishable set, or add them
  through a plan revision. The first iOS build must run `pod install`.
- **FINDING-2 — AC-35 / AC-36 partly met.** Carrying `detailed_error` through
  `lib/core/api/handling_exception.dart` is a follow-up ticket (owner decision at
  plan).
- **FINDING-3 — device evidence is owner-reported.** M-1..M-16 were reported as
  passed by the owner; no per-step record is attached here.
- **FINDING-4 — stash to restore.** The owner's unrelated `ali_dev` changes are
  in `stash@{0}` (see `implement.md > Entry`).

## Observability & runtime impact review

- Were any `observability/` runtime configs changed by this ticket? **no**
  (`features.observability: false`).
- Runtime impact: three new packages (one with native plugins); a new
  feature-local bloc per boutique page; no hydrated state, no prefs key, no
  `lib/core/api/**` change.

## Sign-off

- Outcome: **passed** — every AC-n is met except AC-35 and AC-36, which are
  **partly met** under the owner-accepted deviation recorded at plan
  (`plan.md > Recorded deviation`); no AC-n is unmet. All four validation checks
  exit 0. The verify comprehension gate passed 4/4 (full, not degraded).
- Final ticket state: `status: completed`, stage stays `verify`.
- Sign-off: developer (Ali Fouaad), self sign-off, 2026-10-04.
- Commit: none created at verify (VF-10 / ADR-008 — committing is the delivery
  boundary's job, owned by `/publish-pr`)
- Notes:
  - The outcome rests on owner-reported device evidence (FINDING-3).
  - Before `/publish-pr`: handle FINDING-1 (exclude the three desktop plugin
    registrants, or revise the plan); the publishable set is the file list in
    `implement.md > Changes made`.
  - Follow-up ticket to open: carry `detailed_error` through the core error
    path (FINDING-2).
